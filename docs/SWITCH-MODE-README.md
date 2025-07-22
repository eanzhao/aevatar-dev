# Aevatar 项目模式切换工具

## 概述

本工具用于在开发模式和发布模式之间切换 Aevatar 项目的依赖引用方式。

- **开发模式（dev）**：使用 `ProjectReference` 直接引用源代码，便于调试和修改框架代码
- **发布模式（release）**：使用 `PackageReference` 引用 NuGet 包，用于生产环境部署

> 📌 **注意**：本项目使用 `Directory.Packages.props` 进行中央包版本管理，因此切换到发布模式时无需指定版本号。

## 支持的包

工具会自动处理以下框架包的引用切换：

- `Aevatar.Core.Abstractions`
- `Aevatar.Core`
- `Aevatar.EventSourcing.Core`
- `Aevatar`

## 使用方法

### Windows / PowerShell

```powershell
# 切换到开发模式
./switch-mode.ps1 -Mode dev

# 切换到发布模式
./switch-mode.ps1 -Mode release
```

### Linux / macOS

```bash
# 切换到开发模式
./switch-mode.sh dev

# 切换到发布模式
./switch-mode.sh release
```

## 工作原理

### 开发模式

将所有 `PackageReference` 转换为 `ProjectReference`：

```xml
<!-- 之前 -->
<PackageReference Include="Aevatar.Core" />

<!-- 之后 -->
<ProjectReference Include="../../../aevatar-station/framework/src/Aevatar.Core/Aevatar.Core.csproj" />
```

### 发布模式

将所有 `ProjectReference` 转换为 `PackageReference`：

```xml
<!-- 之前 -->
<ProjectReference Include="../../../aevatar-station/framework/src/Aevatar.Core/Aevatar.Core.csproj" />

<!-- 之后 -->
<PackageReference Include="Aevatar.Core" />
```

## 注意事项

1. **运行位置**：脚本必须在项目根目录下运行
2. **自动排除**：脚本会自动排除 `aevatar-station` 目录下的项目文件
3. **相对路径**：脚本会自动计算正确的相对路径，无需手动调整
4. **恢复依赖**：切换模式后，建议运行 `dotnet restore` 来更新依赖

## 示例工作流

### 开发调试流程

```bash
# 1. 切换到开发模式
./switch-mode.sh dev

# 2. 恢复依赖
dotnet restore

# 3. 开始开发和调试
# 现在可以直接修改 aevatar-station 中的源代码并立即看到效果
```

### 发布部署流程

```bash
# 1. 切换到发布模式
./switch-mode.sh release

# 2. 恢复依赖
dotnet restore

# 3. 构建和发布
dotnet build --configuration Release
dotnet publish --configuration Release
```

## 故障排除

### 权限问题

如果遇到权限错误，请先添加执行权限：

```bash
chmod +x switch-mode.sh
chmod +x switch-mode.ps1
```

### 系统要求

1. **Bash 版本**：脚本兼容 bash 3.x 及以上版本（包括 macOS 默认的 bash 3.2）
2. **Python 依赖**：Bash 版本脚本需要 Python 3 来计算相对路径。如果没有安装 Python 3，请使用 PowerShell 版本

### 版本冲突

如果切换后遇到版本冲突，请确保：
1. `Directory.Packages.props` 中的包版本与实际发布的版本一致
2. 运行 `dotnet clean` 清理缓存后重试

## 扩展配置

如需添加更多包的映射关系，可以编辑脚本中的 `packageMappings` 部分：

```powershell
# PowerShell 版本
$packageMappings = @{
    "Your.Package.Name" = "relative/path/to/Your.Package.Name.csproj"
}
```

```bash
# Bash 版本
declare -A PACKAGE_MAPPINGS=(
    ["Your.Package.Name"]="relative/path/to/Your.Package.Name.csproj"
)
``` 