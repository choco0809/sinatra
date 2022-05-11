# WebアプリからのDB利用
## 内容
* [x] DBはPostgreSQLを使おう。
* [x] DBアクセスのライブラリにはActiveRecordは使わず、pgを使おう。
   * DB接続は遅い(重い)処理なので使い回せるようにしよう。
   * SQL実行時には SQLインジェクション(検索して調べてください)を起こさないようにしましょう。
* [x] 前回のアプリへの変更なので、Pull Requestを作成して提出してみよう！
## 前提条件
* `Ruby`が導入済みであること
* `Postgresql`が導入済みであること
## 手順
1. Gemのインストール
`bundle install`を実行し、必要なGemをインストール
1. `memos`テーブルの作成
`Postgresql`で下記コマンドを実行し、`memos`テーブルを作成する
   ```
   create table memos (
       id       serial,
       title    varchar(100) not null,
       contents text
   );
   ```

1. メモアプリの起動
`bundle exec ruby memo.rb`
1. 下記URLにアクセス
http://localhost:4567/
