FROM ruby:3.2.2

# 必要なパッケージのインストール
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs postgresql-client

# 作業ディレクトリの設定
WORKDIR /rails

# 依存関係のコピーとインストール
COPY Gemfile Gemfile.lock ./
RUN bundle install

# プロジェクトファイルのコピー
COPY . .

# サーバー起動時にPIDファイルを削除するスクリプト（おまじない）
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

# Railsサーバー起動
CMD ["rails", "server", "-b", "0.0.0.0"]
