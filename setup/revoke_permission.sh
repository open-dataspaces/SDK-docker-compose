#!/bin/bash

# ============================================
# OpenFGA 権限取り消しスクリプト
# ============================================
# 機能:
#   operator_id から指定したAPIの権限を取り消し
#
# 使用方法:
#   ./revoke_permission.sh <operator_id> <api_permission>
#   ./revoke_permission.sh <operator_id> all              # 全API権限を取り消し
#
# 例:
#   ./revoke_permission.sh user-001 eligibility-post
#   ./revoke_permission.sh user-001 all
# ============================================

set -e

# --------------------------------------------
# 設定
# --------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env.openfga"

# 利用可能なAPI権限
AVAILABLE_PERMISSIONS=(
    "eligibility-post"
    "eligibility-non-fee-model-post"
    "data-exchange-post"
    "data-exchange-put"
    "data-exchange-non-fee-model-post"
    "fee-model-post"
    "fee-model-get"
    "fee-model-put"
    "fee-model-delete"
    "payment-post"
    "billing-post"
)

# --------------------------------------------
# 引数チェック
# --------------------------------------------
show_usage() {
    echo "Usage: $0 <operator_id> <api_permission>"
    echo ""
    echo "Arguments:"
    echo "  operator_id      - ユーザーのoperator_id"
    echo "  api_permission   - 取り消す権限（以下のいずれか）"
    echo ""
    echo "利用可能なAPI権限:"
    echo "  eligibility-post              - 取引可否確認API"
    echo "  eligibility-non-fee-model-post - 取引可否確認API(利用料モデル無)"
    echo "  data-exchange-post            - データ交換状態登録API"
    echo "  data-exchange-put             - データ交換状態更新API"
    echo "  data-exchange-non-fee-model-post - データ交換取引金額確定API(利用料モデル無)"
    echo "  all                           - 上記全ての権限"
    echo ""
    echo "例:"
    echo "  $0 user-001 eligibility-post"
    echo "  $0 user-001 all"
    exit 1
}

if [ $# -lt 2 ]; then
    show_usage
fi

OPERATOR_ID="$1"
API_PERMISSION="$2"

# --------------------------------------------
# 環境変数の読み込み
# --------------------------------------------
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "❌ Error: .env.openfga not found"
    echo "   先に setup_openfga.sh を実行してください"
    exit 1
fi

FGA_API_URL="${FGA_API_URL:-http://localhost:18080}"

if [ -z "$FGA_STORE_ID" ] || [ -z "$FGA_MODEL_ID" ]; then
    echo "❌ Error: FGA_STORE_ID or FGA_MODEL_ID not set"
    echo "   先に setup_openfga.sh を実行してください"
    exit 1
fi

# --------------------------------------------
# 権限取り消し関数
# --------------------------------------------
revoke_single_permission() {
    local operator_id="$1"
    local permission="$2"

    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$FGA_API_URL/stores/$FGA_STORE_ID/write" \
      -H "Content-Type: application/json" \
      -d "{
        \"authorization_model_id\": \"$FGA_MODEL_ID\",
        \"deletes\": {
          \"tuple_keys\": [
            {
              \"user\": \"user:$operator_id\",
              \"relation\": \"can_access\",
              \"object\": \"api_endpoint:$permission\"
            }
          ]
        }
      }")

    HTTP_CODE=$(echo "$RESPONSE" | tail -1)
    RESPONSE_BODY=$(echo "$RESPONSE" | head -n -1)

    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ 権限取り消し成功: $operator_id -> $permission"
        return 0
    else
        echo "❌ 権限取り消し失敗: $operator_id -> $permission"
        echo "   Response: $RESPONSE_BODY"
        return 1
    fi
}

# --------------------------------------------
# 権限の検証
# --------------------------------------------
validate_permission() {
    local perm="$1"
    for valid_perm in "${AVAILABLE_PERMISSIONS[@]}"; do
        if [ "$perm" = "$valid_perm" ]; then
            return 0
        fi
    done
    return 1
}

# --------------------------------------------
# メイン処理
# --------------------------------------------
echo "============================================"
echo "OpenFGA Permission Revoke"
echo "============================================"
echo "Operator ID: $OPERATOR_ID"
echo "Permission:  $API_PERMISSION"
echo "Store ID:    $FGA_STORE_ID"
echo ""

if [ "$API_PERMISSION" = "all" ]; then
    # 全権限を取り消し
    echo "全てのAPI権限を取り消します..."
    echo ""
    SUCCESS_COUNT=0
    for perm in "${AVAILABLE_PERMISSIONS[@]}"; do
        if revoke_single_permission "$OPERATOR_ID" "$perm"; then
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        fi
    done
    echo ""
    echo "============================================"
    echo "完了: $SUCCESS_COUNT/${#AVAILABLE_PERMISSIONS[@]} 権限を取り消しました"
    echo "============================================"
else
    # 単一権限を取り消し
    if ! validate_permission "$API_PERMISSION"; then
        echo "❌ Error: 無効な権限名: $API_PERMISSION"
        echo ""
        echo "利用可能な権限:"
        for perm in "${AVAILABLE_PERMISSIONS[@]}"; do
            echo "  - $perm"
        done
        echo "  - all (全権限)"
        exit 1
    fi

    revoke_single_permission "$OPERATOR_ID" "$API_PERMISSION"
fi
