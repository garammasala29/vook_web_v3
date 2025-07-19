#!/bin/bash

# 最新のコードを取得
git pull origin main

# 必要なGemをインストール
bundle install

# データベースのマイグレーションを実行 (必要に応じて)
RAILS_ENV=production bundle exec rails db:migrate

# Cronスケジュールを更新
RAILS_ENV=production bundle exec whenever --update-crontab

# アセットのプリコンパイル
RAILS_ENV=production bundle exec rails assets:precompile

# Nginxを再起動
sudo systemctl restart nginx
# Pumaを再起動
sudo systemctl restart puma
