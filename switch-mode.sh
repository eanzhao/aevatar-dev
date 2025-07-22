#!/bin/bash

# 切换 Aevatar 项目的开发模式和发布模式
# 用法: ./switch-mode.sh <dev|release>

set -e

# 检查参数
if [ $# -lt 1 ]; then
    echo "用法: $0 <dev|release>"
    echo "示例:"
    echo "  $0 dev              # 切换到开发模式"
    echo "  $0 release          # 切换到发布模式"
    exit 1
fi

MODE=$1

# 验证模式
if [ "$MODE" != "dev" ] && [ "$MODE" != "release" ]; then
    echo "错误: 模式必须是 'dev' 或 'release'"
    exit 1
fi

# 获取脚本所在目录（项目根目录）
ROOT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "🔄 切换到 $MODE 模式..."
echo "📁 项目根目录: $ROOT_PATH"

# 定义包映射（使用平行数组以兼容 bash 3.x）
PACKAGE_NAMES=(
    "Aevatar.Core.Abstractions"
    "Aevatar.Core"
    "Aevatar.EventSourcing.Core"
    "Aevatar.EventSourcing.MongoDB"
    "Aevatar.PermissionManagement"
    "Aevatar.Plugins"
    "Aevatar"
)

PACKAGE_PATHS=(
    "aevatar-station/framework/src/Aevatar.Core.Abstractions/Aevatar.Core.Abstractions.csproj"
    "aevatar-station/framework/src/Aevatar.Core/Aevatar.Core.csproj"
    "aevatar-station/framework/src/Aevatar.EventSourcing.Core/Aevatar.EventSourcing.Core.csproj"
    "aevatar-station/framework/src/Aevatar.EventSourcing.MongoDB/Aevatar.EventSourcing.MongoDB.csproj"
    "aevatar-station/framework/src/Aevatar.PermissionManagement/Aevatar.PermissionManagement.csproj"
    "aevatar-station/framework/src/Aevatar.Plugins/Aevatar.Plugins.csproj"
    "aevatar-station/framework/src/Aevatar/Aevatar.csproj"
)

# 统计信息
TOTAL_FILES=0
MODIFIED_FILES=0

# 查找所有 .csproj 文件（排除 aevatar-station 目录）
while IFS= read -r -d '' CSPROJ_FILE; do
    ((TOTAL_FILES++))
    MODIFIED=false
    
    # 获取项目文件的目录
    PROJECT_DIR=$(dirname "$CSPROJ_FILE")
    
    # 计算从项目目录到根目录的相对路径
    RELATIVE_PATH=$(python3 -c "import os.path; print(os.path.relpath('$ROOT_PATH', '$PROJECT_DIR'))")
    
    echo "处理: ${CSPROJ_FILE#$ROOT_PATH/}"
    
    if [ "$MODE" == "dev" ]; then
        # 发布模式转开发模式：PackageReference -> ProjectReference
        for i in "${!PACKAGE_NAMES[@]}"; do
            PACKAGE="${PACKAGE_NAMES[$i]}"
            PROJECT_PATH="${PACKAGE_PATHS[$i]}"
            FULL_PROJECT_PATH="$RELATIVE_PATH/$PROJECT_PATH"
            
            # 检查是否存在 PackageReference
            if grep -q "<PackageReference Include=\"$PACKAGE\"" "$CSPROJ_FILE"; then
                # 创建临时文件
                TEMP_FILE=$(mktemp)
                
                # 替换 PackageReference 为 ProjectReference
                sed -E "s|<PackageReference Include=\"$PACKAGE\"[^/]*/?>|<ProjectReference Include=\"$FULL_PROJECT_PATH\" />|g" "$CSPROJ_FILE" > "$TEMP_FILE"
                
                # 如果文件有变化，则更新
                if ! cmp -s "$CSPROJ_FILE" "$TEMP_FILE"; then
                    mv "$TEMP_FILE" "$CSPROJ_FILE"
                    echo "  ✅ PackageReference '$PACKAGE' -> ProjectReference"
                    MODIFIED=true
                else
                    rm "$TEMP_FILE"
                fi
            fi
        done
    else
        # 开发模式转发布模式：ProjectReference -> PackageReference
        for i in "${!PACKAGE_NAMES[@]}"; do
            PACKAGE="${PACKAGE_NAMES[$i]}"
            PROJECT_PATH="${PACKAGE_PATHS[$i]}"
            
            # 检查是否存在对应的 ProjectReference
            if grep -q "$PROJECT_PATH" "$CSPROJ_FILE"; then
                # 创建临时文件
                TEMP_FILE=$(mktemp)
                
                # 替换 ProjectReference 为 PackageReference
                sed -E "s|<ProjectReference Include=\"[^\"]*$PROJECT_PATH\"[^/]*/?>|<PackageReference Include=\"$PACKAGE\" />|g" "$CSPROJ_FILE" > "$TEMP_FILE"
                
                # 如果文件有变化，则更新
                if ! cmp -s "$CSPROJ_FILE" "$TEMP_FILE"; then
                    mv "$TEMP_FILE" "$CSPROJ_FILE"
                    echo "  ✅ ProjectReference -> PackageReference '$PACKAGE'"
                    MODIFIED=true
                else
                    rm "$TEMP_FILE"
                fi
            fi
        done
    fi
    
    if [ "$MODIFIED" = true ]; then
        ((MODIFIED_FILES++))
    fi
    
done < <(find "$ROOT_PATH" -name "*.csproj" -type f ! -path "*/aevatar-station/*" -print0)

echo ""
echo "✨ 完成！"
echo "📊 处理了 $TOTAL_FILES 个项目文件，修改了 $MODIFIED_FILES 个文件"

if [ "$MODE" == "dev" ]; then
    echo ""
    echo "💡 现在处于开发模式"
    echo "   - 使用 ProjectReference 直接引用源代码"
    echo "   - 可以直接调试和修改框架代码"
else
    echo ""
    echo "📦 现在处于发布模式"
    echo "   - 使用 PackageReference 引用 NuGet 包"
    echo "   - 版本由 Directory.Packages.props 管理"
fi

echo ""
echo "🔧 建议运行 'dotnet restore' 来更新依赖" 