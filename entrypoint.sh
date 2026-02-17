#!/bin/bash
set -e

# サーバーが異常終了した時に残るPIDファイルを削除
rm -f /rails/tmp/pids/server.pid

# コンテナのメインプロセス（CMDで指定した内容）を実行
exec "$@"
