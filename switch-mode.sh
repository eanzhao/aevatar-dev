#!/bin/bash

# 切换 Aevatar 项目的开发模式和发布模式
# 用法: ./switch-mode.sh <dev|release>

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
# Aevatar.Core 相关包
CORE_PACKAGE_NAMES=(
    "Aevatar.Core.Abstractions"
    "Aevatar.Core"
    "Aevatar.EventSourcing.Core"
    "Aevatar.EventSourcing.MongoDB"
    "Aevatar.PermissionManagement"
    "Aevatar.Plugins"
    "Aevatar"
)

CORE_PACKAGE_PATHS=(
    "aevatar-station/framework/src/Aevatar.Core.Abstractions/Aevatar.Core.Abstractions.csproj"
    "aevatar-station/framework/src/Aevatar.Core/Aevatar.Core.csproj"
    "aevatar-station/framework/src/Aevatar.EventSourcing.Core/Aevatar.EventSourcing.Core.csproj"
    "aevatar-station/framework/src/Aevatar.EventSourcing.MongoDB/Aevatar.EventSourcing.MongoDB.csproj"
    "aevatar-station/framework/src/Aevatar.PermissionManagement/Aevatar.PermissionManagement.csproj"
    "aevatar-station/framework/src/Aevatar.Plugins/Aevatar.Plugins.csproj"
    "aevatar-station/framework/src/Aevatar/Aevatar.csproj"
)

# Aevatar.GAgents 相关包
GAGENTS_PACKAGE_NAMES=(
    "Aevatar.GAgents.AElf"
    "Aevatar.GAgents.AI.Abstractions"
    "Aevatar.GAgents.AIGAgent"
    "Aevatar.GAgents.AIGAgent.Core"
    "Aevatar.GAgents.Basic"
    "Aevatar.GAgents.ChatAgent"
    "Aevatar.GAgents.Executor"
    "Aevatar.GAgents.GraphRetrievalAgent"
    "Aevatar.GAgents.GroupChat"
    "Aevatar.GAgents.GroupChat.Core"
    "Aevatar.GAgents.GroupChat.GroupMember"
    "Aevatar.GAgents.InputGAgent"
    "Aevatar.GAgents.MCP"
    "Aevatar.GAgents.MCP.Core"
    "Aevatar.GAgents.MultiAIChatGAgent"
    "Aevatar.GAgents.PsiOmni"
    "Aevatar.GAgents.PsiOmni.Plugins"
    "Aevatar.GAgents.Pumpfun"
    "Aevatar.GAgents.Router"
    "Aevatar.GAgents.SemanticKernel"
    "Aevatar.GAgents.SocialGAgent"
    "Aevatar.GAgents.Telegram"
    "Aevatar.GAgents.Twitter"
)

GAGENTS_PACKAGE_PATHS=(
    "aevatar-gagents/src/Aevatar.GAgents.AElf/Aevatar.GAgents.AElf.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.AI.Abstractions/Aevatar.GAgents.AI.Abstractions.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.AIGAgent/Aevatar.GAgents.AIGAgent.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.AIGAgent.Core/Aevatar.GAgents.AIGAgent.Core.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.Basic/Aevatar.GAgents.Basic.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.ChatAgent/Aevatar.GAgents.ChatAgent.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.Executor/Aevatar.GAgents.Executor.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.GraphRetrievalAgent/Aevatar.GAgents.GraphRetrievalAgent.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.GroupChat/Aevatar.GAgents.GroupChat.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.GroupChat.Core/Aevatar.GAgents.GroupChat.Core.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.GroupChat.GroupMember/Aevatar.GAgents.GroupChat.GroupMember.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.InputGAgent/Aevatar.GAgents.InputGAgent.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.MCP/Aevatar.GAgents.MCP.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.MCP.Core/Aevatar.GAgents.MCP.Core.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.MultiAIChatGAgent/Aevatar.GAgents.MultiAIChatGAgent.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.PsiOmni/Aevatar.GAgents.PsiOmni.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.PsiOmni.Plugins/Aevatar.GAgents.PsiOmni.Plugins.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.Pumpfun/Aevatar.GAgents.Pumpfun.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.Router/Aevatar.GAgents.Router.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.SemanticKernel/Aevatar.GAgents.SemanticKernel.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.SocialGAgent/Aevatar.GAgents.SocialGAgent.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.Telegram/Aevatar.GAgents.Telegram.csproj"
    "aevatar-gagents/src/Aevatar.GAgents.Twitter/Aevatar.GAgents.Twitter.csproj"
)

# 统计信息
TOTAL_FILES=0
MODIFIED_FILES=0

# 处理单个项目文件的函数
process_csproj() {
    local CSPROJ_FILE=$1
    local PACKAGE_NAMES=("${!2}")
    local PACKAGE_PATHS=("${!3}")
    local MODIFIED=false
    
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
}

# 处理 aevatar-workshop 中的项目文件
echo ""
echo "📁 处理 aevatar-workshop 项目..."
while IFS= read -r -d '' CSPROJ_FILE; do
    ((TOTAL_FILES++))
    # 只处理 GAgents 相关的包
    process_csproj "$CSPROJ_FILE" GAGENTS_PACKAGE_NAMES[@] GAGENTS_PACKAGE_PATHS[@]
done < <(find "$ROOT_PATH/aevatar-workshop" -name "*.csproj" -type f -print0)

# 处理 aevatar-station/station 中的项目文件
echo ""
echo "📁 处理 aevatar-station/station 项目..."
# 合并 Core 和 GAgents 包
ALL_PACKAGE_NAMES=("${CORE_PACKAGE_NAMES[@]}" "${GAGENTS_PACKAGE_NAMES[@]}")
ALL_PACKAGE_PATHS=("${CORE_PACKAGE_PATHS[@]}" "${GAGENTS_PACKAGE_PATHS[@]}")
while IFS= read -r -d '' CSPROJ_FILE; do
    ((TOTAL_FILES++))
    # 处理所有包（Core 和 GAgents）
    process_csproj "$CSPROJ_FILE" ALL_PACKAGE_NAMES[@] ALL_PACKAGE_PATHS[@]
done < <(find "$ROOT_PATH/aevatar-station/station" -name "*.csproj" -type f -print0)

# 处理其他目录中的项目文件（排除 aevatar-station 和 aevatar-workshop）
echo ""
echo "📁 处理其他项目..."
while IFS= read -r -d '' CSPROJ_FILE; do
    ((TOTAL_FILES++))
    # 处理所有包（Core 和 GAgents）
    process_csproj "$CSPROJ_FILE" ALL_PACKAGE_NAMES[@] ALL_PACKAGE_PATHS[@]
done < <(find "$ROOT_PATH" -name "*.csproj" -type f ! -path "*/aevatar-station/*" ! -path "*/aevatar-workshop/*" ! -path "*/aevatar-gagents/*" -print0)

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