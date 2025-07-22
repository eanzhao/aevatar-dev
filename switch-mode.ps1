#!/usr/bin/env pwsh

<#
.SYNOPSIS
    切换 Aevatar 项目的开发模式和发布模式
.DESCRIPTION
    此脚本用于在开发模式（使用 ProjectReference）和发布模式（使用 PackageReference）之间切换
.PARAMETER Mode
    指定切换到的模式: dev (开发模式) 或 release (发布模式)
.EXAMPLE
    ./switch-mode.ps1 -Mode dev
    ./switch-mode.ps1 -Mode release
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "release")]
    [string]$Mode
)

# 定义需要处理的包映射
$packageMappings = @{
    "Aevatar.Core.Abstractions" = "aevatar-station/framework/src/Aevatar.Core.Abstractions/Aevatar.Core.Abstractions.csproj"
    "Aevatar.Core" = "aevatar-station/framework/src/Aevatar.Core/Aevatar.Core.csproj"
    "Aevatar.EventSourcing.Core" = "aevatar-station/framework/src/Aevatar.EventSourcing.Core/Aevatar.EventSourcing.Core.csproj"
    "Aevatar" = "aevatar-station/framework/src/Aevatar/Aevatar.csproj"
}

# 获取脚本所在目录（项目根目录）
$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "🔄 切换到 $Mode 模式..." -ForegroundColor Cyan
Write-Host "📁 项目根目录: $rootPath" -ForegroundColor Gray

# 获取所有 .csproj 文件，排除 aevatar-station 目录
$csprojFiles = Get-ChildItem -Path $rootPath -Filter "*.csproj" -Recurse | 
    Where-Object { $_.FullName -notlike "*\aevatar-station\*" }

$totalFiles = $csprojFiles.Count
$processedFiles = 0
$modifiedFiles = 0

foreach ($csprojFile in $csprojFiles) {
    $processedFiles++
    $modified = $false
    
    Write-Progress -Activity "处理项目文件" -Status "$processedFiles / $totalFiles" -PercentComplete (($processedFiles / $totalFiles) * 100)
    
    # 读取项目文件
    $xml = [xml](Get-Content $csprojFile.FullName -Encoding UTF8)
    
    # 计算从项目目录到根目录的相对路径
    $projectDir = $csprojFile.DirectoryName
    $relativePath = [System.IO.Path]::GetRelativePath($projectDir, $rootPath)
    
    # 将反斜杠统一转换为正斜杠，以便跨平台兼容
    $relativePrefix = $relativePath -replace '\\', '/'
    
    # 创建命名空间管理器
    $nsManager = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
    $nsManager.AddNamespace("ns", $xml.DocumentElement.NamespaceURI)
    
    # 查找所有 ItemGroup
    $itemGroups = $xml.SelectNodes("//ns:ItemGroup", $nsManager)
    if (-not $itemGroups) {
        $itemGroups = $xml.SelectNodes("//ItemGroup")
    }
    
    foreach ($itemGroup in $itemGroups) {
        if ($Mode -eq "dev") {
            # 发布模式转开发模式：PackageReference -> ProjectReference
            $packageRefs = $itemGroup.SelectNodes("PackageReference")
            $toRemove = @()
            
            foreach ($packageRef in $packageRefs) {
                $packageName = $packageRef.GetAttribute("Include")
                
                if ($packageMappings.ContainsKey($packageName)) {
                    $projectPath = Join-Path $relativePrefix $packageMappings[$packageName]
                    
                    # 创建新的 ProjectReference
                    $projectRef = $xml.CreateElement("ProjectReference", $xml.DocumentElement.NamespaceURI)
                    $projectRef.SetAttribute("Include", $projectPath)
                    
                    # 添加到父节点
                    $itemGroup.AppendChild($projectRef) | Out-Null
                    
                    # 标记要删除的 PackageReference
                    $toRemove += $packageRef
                    
                    Write-Host "  ✅ $($csprojFile.Name): PackageReference '$packageName' -> ProjectReference" -ForegroundColor Green
                    $modified = $true
                }
            }
            
            # 删除标记的节点
            foreach ($node in $toRemove) {
                $node.ParentNode.RemoveChild($node) | Out-Null
            }
        }
        else {
            # 开发模式转发布模式：ProjectReference -> PackageReference
            $projectRefs = $itemGroup.SelectNodes("ProjectReference")
            $toRemove = @()
            
            foreach ($projectRef in $projectRefs) {
                $projectPath = $projectRef.GetAttribute("Include")
                
                # 检查是否是我们需要转换的项目引用
                foreach ($package in $packageMappings.Keys) {
                    if ($projectPath -like "*$($packageMappings[$package])") {
                        # 创建新的 PackageReference
                        $packageRef = $xml.CreateElement("PackageReference", $xml.DocumentElement.NamespaceURI)
                        $packageRef.SetAttribute("Include", $package)
                        
                        # 添加到父节点
                        $itemGroup.AppendChild($packageRef) | Out-Null
                        
                        # 标记要删除的 ProjectReference
                        $toRemove += $projectRef
                        
                        Write-Host "  ✅ $($csprojFile.Name): ProjectReference -> PackageReference '$package'" -ForegroundColor Green
                        $modified = $true
                        break
                    }
                }
            }
            
            # 删除标记的节点
            foreach ($node in $toRemove) {
                $node.ParentNode.RemoveChild($node) | Out-Null
            }
        }
        
        # 清理空的 ItemGroup
        if ($itemGroup.ChildNodes.Count -eq 0) {
            $itemGroup.ParentNode.RemoveChild($itemGroup) | Out-Null
        }
    }
    
    # 如果有修改，保存文件
    if ($modified) {
        $xml.Save($csprojFile.FullName)
        $modifiedFiles++
    }
}

Write-Progress -Activity "处理项目文件" -Completed

Write-Host "`n✨ 完成！" -ForegroundColor Green
Write-Host "📊 处理了 $totalFiles 个项目文件，修改了 $modifiedFiles 个文件" -ForegroundColor Cyan

if ($Mode -eq "dev") {
    Write-Host "`n💡 现在处于开发模式" -ForegroundColor Yellow
    Write-Host "   - 使用 ProjectReference 直接引用源代码" -ForegroundColor Gray
    Write-Host "   - 可以直接调试和修改框架代码" -ForegroundColor Gray
}
else {
    Write-Host "`n📦 现在处于发布模式" -ForegroundColor Yellow
    Write-Host "   - 使用 PackageReference 引用 NuGet 包" -ForegroundColor Gray
    Write-Host "   - 版本由 Directory.Packages.props 管理" -ForegroundColor Gray
}

Write-Host "`n🔧 建议运行 'dotnet restore' 来更新依赖" -ForegroundColor Cyan 