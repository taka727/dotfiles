# AWS 開発環境まわりのツール解説

このマシンに導入した AWS 関連ツールが「それぞれ何のためのものか」をまとめたメモ。
特定プロジェクトの作業とは無関係な、マシン全体のセットアップに関するドキュメントとして
`~/dotfiles/Brewfile` と合わせてここに置いている。

## 導入したツール

### 1. `awscli`（AWS CLI v2）

AWS の各サービス（S3, EC2, IAM, Lambda など）をターミナルから操作するための公式CLI。
`aws s3 ls` のように `aws <サービス名> <コマンド>` の形で使う。ほぼすべてのAWS作業の土台になる。

- 初回セットアップ: `aws configure`（アクセスキー・シークレットキー・リージョンを対話入力）
  - ただし下記の aws-vault を使う場合はこちらのコマンドは使わず、aws-vault 経由で認証情報を登録する方が安全
- 動作確認: `aws --version`

### 2. `aws-vault`

AWS の認証情報（アクセスキー/シークレットキー）を **平文で `~/.aws/credentials` に保存せず**、
macOS のキーチェーン（Keychain）に暗号化して保存し、必要なときだけ一時的な認証情報を発行してくれるツール。

なぜ必要か:
- `~/.aws/credentials` に平文でキーを置くと、他のツールやマルウェア、うっかりのgit commitで漏洩するリスクがある
- aws-vault はキーチェーンに保存 + 一時的なSTSトークンを都度発行するので、漏洩リスクと影響範囲を小さくできる

基本的な使い方:
```bash
# プロファイル追加（アクセスキーを聞かれる。これがキーチェーンに保存される）
aws-vault add my-profile

# そのプロファイルの認証情報を使ってコマンドを実行
aws-vault exec my-profile -- aws s3 ls

# 一時的にシェルにエクスポートして使う
aws-vault exec my-profile -- $SHELL
```

### 3. `session-manager-plugin`

AWS Systems Manager (SSM) の `aws ssm start-session` を使うために必要な AWS CLI 用プラグイン。
これがあると、EC2インスタンスに **SSH鍵や踏み台サーバーなしに** ブラウザ/CLI経由で直接接続できる。

- モダンなAWS運用ではSSH鍵管理そのものを避け、IAM権限だけでインスタンスにアクセスするのが推奨されているため導入
- 使用例: `aws ssm start-session --target i-xxxxxxxxxxxxxxxxx`
- インストールはGUIインストーラ（pkg）を使うため sudo パスワード入力が必要。
  ターミナルで以下を実行して手動インストールすること:
  ```bash
  brew install --cask session-manager-plugin
  ```

## 導入していないが、今後必要になりそうなもの（参考）

今回は「AWSをまず使う」という方針だったため未導入。Azure/GCPやIaCを本格的に使う際に検討する。

| ツール | 用途 |
|---|---|
| `terraform` (`brew install hashicorp/tap/terraform`) | AWS/Azure/GCP共通で使えるIaC(Infrastructure as Code)ツール。リソースをコードで宣言的に管理する |
| `az` (Azure CLI) | Azureリソースの操作用CLI。`brew install azure-cli` |
| `gcloud` (Google Cloud SDK) | GCPリソースの操作用CLI。`brew install --cask google-cloud-sdk` |
| `eksctl` | AWS EKS(Kubernetes)クラスタ作成・管理用CLI |
| `sam-cli` | AWS Lambda等のサーバーレスアプリをローカルでビルド・デバッグするCLI |

## 認証情報の保存場所

- `~/.aws/` — AWS CLI の設定・認証情報ディレクトリ（このマシンには本メモ作成時点で未作成 = 未ログイン状態）
- aws-vault を使う場合、実際のシークレットは `~/.aws/credentials` ではなく macOS キーチェーンに保存される
