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
# Aevatar.Core 相关包
$corePackageMappings = @{
    "Aevatar.Core.Abstractions" = "aevatar-station/framework/src/Aevatar.Core.Abstractions/Aevatar.Core.Abstractions.csproj"
    "Aevatar.Core" = "aevatar-station/framework/src/Aevatar.Core/Aevatar.Core.csproj"
    "Aevatar.EventSourcing.Core" = "aevatar-station/framework/src/Aevatar.EventSourcing.Core/Aevatar.EventSourcing.Core.csproj"
    "Aevatar.EventSourcing.MongoDB" = "aevatar-station/framework/src/Aevatar.EventSourcing.MongoDB/Aevatar.EventSourcing.MongoDB.csproj"
    "Aevatar.PermissionManagement" = "aevatar-station/framework/src/Aevatar.PermissionManagement/Aevatar.PermissionManagement.csproj"
    "Aevatar.Plugins" = "aevatar-station/framework/src/Aevatar.Plugins/Aevatar.Plugins.csproj"
    "Aevatar" = "aevatar-station/framework/src/Aevatar/Aevatar.csproj"
}

# Aevatar.GAgents 相关包
$gagentsPackageMappings = @{
    "Aevatar.GAgents.AElf" = "aevatar-gagents/src/Aevatar.GAgents.AElf/Aevatar.GAgents.AElf.csproj"
    "Aevatar.GAgents.AI.Abstractions" = "aevatar-gagents/src/Aevatar.GAgents.AI.Abstractions/Aevatar.GAgents.AI.Abstractions.csproj"
    "Aevatar.GAgents.AIGAgent" = "aevatar-gagents/src/Aevatar.GAgents.AIGAgent/Aevatar.GAgents.AIGAgent.csproj"
    "Aevatar.GAgents.AIGAgent.Core" = "aevatar-gagents/src/Aevatar.GAgents.AIGAgent.Core/Aevatar.GAgents.AIGAgent.Core.csproj"
    "Aevatar.GAgents.Basic" = "aevatar-gagents/src/Aevatar.GAgents.Basic/Aevatar.GAgents.Basic.csproj"
    "Aevatar.GAgents.ChatAgent" = "aevatar-gagents/src/Aevatar.GAgents.ChatAgent/Aevatar.GAgents.ChatAgent.csproj"
    "Aevatar.GAgents.Executor" = "aevatar-gagents/src/Aevatar.GAgents.Executor/Aevatar.GAgents.Executor.csproj"
    "Aevatar.GAgents.GraphRetrievalAgent" = "aevatar-gagents/src/Aevatar.GAgents.GraphRetrievalAgent/Aevatar.GAgents.GraphRetrievalAgent.csproj"
    "Aevatar.GAgents.GroupChat" = "aevatar-gagents/src/Aevatar.GAgents.GroupChat/Aevatar.GAgents.GroupChat.csproj"
    "Aevatar.GAgents.GroupChat.Core" = "aevatar-gagents/src/Aevatar.GAgents.GroupChat.Core/Aevatar.GAgents.GroupChat.Core.csproj"
    "Aevatar.GAgents.GroupChat.GroupMember" = "aevatar-gagents/src/Aevatar.GAgents.GroupChat.GroupMember/Aevatar.GAgents.GroupChat.GroupMember.csproj"
    "Aevatar.GAgents.InputGAgent" = "aevatar-gagents/src/Aevatar.GAgents.InputGAgent/Aevatar.GAgents.InputGAgent.csproj"
    "Aevatar.GAgents.MCP" = "aevatar-gagents/src/Aevatar.GAgents.MCP/Aevatar.GAgents.MCP.csproj"
    "Aevatar.GAgents.MCP.Core" = "aevatar-gagents/src/Aevatar.GAgents.MCP.Core/Aevatar.GAgents.MCP.Core.csproj"
    "Aevatar.GAgents.MultiAIChatGAgent" = "aevatar-gagents/src/Aevatar.GAgents.MultiAIChatGAgent/Aevatar.GAgents.MultiAIChatGAgent.csproj"
    "Aevatar.GAgents.PsiOmni" = "aevatar-gagents/src/Aevatar.GAgents.PsiOmni/Aevatar.GAgents.PsiOmni.csproj"
    "Aevatar.GAgents.PsiOmni.Plugins" = "aevatar-gagents/src/Aevatar.GAgents.PsiOmni.Plugins/Aevatar.GAgents.PsiOmni.Plugins.csproj"
    "Aevatar.GAgents.Pumpfun" = "aevatar-gagents/src/Aevatar.GAgents.Pumpfun/Aevatar.GAgents.Pumpfun.csproj"
    "Aevatar.GAgents.Router" = "aevatar-gagents/src/Aevatar.GAgents.Router/Aevatar.GAgents.Router.csproj"
    "Aevatar.GAgents.SemanticKernel" = "aevatar-gagents/src/Aevatar.GAgents.SemanticKernel/Aevatar.GAgents.SemanticKernel.csproj"
    "Aevatar.GAgents.SocialGAgent" = "aevatar-gagents/src/Aevatar.GAgents.SocialGAgent/Aevatar.GAgents.SocialGAgent.csproj"
    "Aevatar.GAgents.Telegram" = "aevatar-gagents/src/Aevatar.GAgents.Telegram/Aevatar.GAgents.Telegram.csproj"
    "Aevatar.GAgents.Twitter" = "aevatar-gagents/src/Aevatar.GAgents.Twitter/Aevatar.GAgents.Twitter.csproj"
}

# 获取脚本所在目录（项目根目录）
$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "🔄 切换到 $Mode 模式..." -ForegroundColor Cyan
Write-Host "📁 项目根目录: $rootPath" -ForegroundColor Gray

# 处理单个项目文件的函数
function Process-ProjectFile {
    param(
        [string]$CsprojPath,
        [hashtable]$PackageMappings
    )
    
    $modified = $false
    $xml = [xml](Get-Content $CsprojPath -Encoding UTF8)
    
    # 计算从项目目录到根目录的相对路径
    $projectDir = Split-Path -Parent $CsprojPath
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
                
                if ($PackageMappings.ContainsKey($packageName)) {
                    $projectPath = Join-Path $relativePrefix $PackageMappings[$packageName]
                    
                    # 创建新的 ProjectReference
                    $projectRef = $xml.CreateElement("ProjectReference", $xml.DocumentElement.NamespaceURI)
                    $projectRef.SetAttribute("Include", $projectPath)
                    
                    # 添加到父节点
                    $itemGroup.AppendChild($projectRef) | Out-Null
                    
                    # 标记要删除的 PackageReference
                    $toRemove += $packageRef
                    
                    Write-Host "  ✅ $((Split-Path -Leaf $CsprojPath)): PackageReference '$packageName' -> ProjectReference" -ForegroundColor Green
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
                foreach ($package in $PackageMappings.Keys) {
                    if ($projectPath -like "*$($PackageMappings[$package])") {
                        # 创建新的 PackageReference
                        $packageRef = $xml.CreateElement("PackageReference", $xml.DocumentElement.NamespaceURI)
                        $packageRef.SetAttribute("Include", $package)
                        
                        # 添加到父节点
                        $itemGroup.AppendChild($packageRef) | Out-Null
                        
                        # 标记要删除的 ProjectReference
                        $toRemove += $projectRef
                        
                        Write-Host "  ✅ $((Split-Path -Leaf $CsprojPath)): ProjectReference -> PackageReference '$package'" -ForegroundColor Green
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
        $xml.Save($CsprojPath)
        return $true
    }
    
    return $false
}

$totalFiles = 0
$modifiedFiles = 0

# 处理 aevatar-workshop 中的项目文件
Write-Host "`n📁 处理 aevatar-workshop 项目..." -ForegroundColor Yellow
$workshopFiles = Get-ChildItem -Path "$rootPath/aevatar-workshop" -Filter "*.csproj" -Recurse
foreach ($csprojFile in $workshopFiles) {
    $totalFiles++
    Write-Progress -Activity "处理 aevatar-workshop 项目文件" -Status "$totalFiles 个文件" -PercentComplete (($totalFiles / ($workshopFiles.Count + 1)) * 100)
    
    # 只处理 GAgents 相关的包
    if (Process-ProjectFile -CsprojPath $csprojFile.FullName -PackageMappings $gagentsPackageMappings) {
        $modifiedFiles++
    }
}

# 处理 aevatar-station/station 中的项目文件
Write-Host "`n📁 处理 aevatar-station/station 项目..." -ForegroundColor Yellow
$stationFiles = Get-ChildItem -Path "$rootPath/aevatar-station/station" -Filter "*.csproj" -Recurse -ErrorAction SilentlyContinue
foreach ($csprojFile in $stationFiles) {
    $totalFiles++
    Write-Progress -Activity "处理 aevatar-station/station 项目文件" -Status "$totalFiles 个文件" -PercentComplete (($totalFiles / ($stationFiles.Count + $workshopFiles.Count + 1)) * 100)
    
    # 处理所有包（Core 和 GAgents）
    $allMappings = $corePackageMappings + $gagentsPackageMappings
    if (Process-ProjectFile -CsprojPath $csprojFile.FullName -PackageMappings $allMappings) {
        $modifiedFiles++
    }
}

# 处理其他目录中的项目文件（排除 aevatar-station, aevatar-workshop 和 aevatar-gagents）
Write-Host "`n📁 处理其他项目..." -ForegroundColor Yellow
$otherFiles = Get-ChildItem -Path $rootPath -Filter "*.csproj" -Recurse | 
    Where-Object { 
        $_.FullName -notlike "*\aevatar-station\*" -and 
        $_.FullName -notlike "*\aevatar-workshop\*" -and 
        $_.FullName -notlike "*\aevatar-gagents\*" 
    }
foreach ($csprojFile in $otherFiles) {
    $totalFiles++
    Write-Progress -Activity "处理其他项目文件" -Status "$totalFiles 个文件" -PercentComplete (($totalFiles / ($otherFiles.Count + $stationFiles.Count + $workshopFiles.Count + 1)) * 100)
    
    # 处理所有包（Core 和 GAgents）
    $allMappings = $corePackageMappings + $gagentsPackageMappings
    if (Process-ProjectFile -CsprojPath $csprojFile.FullName -PackageMappings $allMappings) {
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