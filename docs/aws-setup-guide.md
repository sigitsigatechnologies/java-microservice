# 🚀 AWS Setup Guide - CMS Microservices

Panduan lengkap untuk setup AWS account, tools, dan deployment CMS Microservices ke AWS ECS Fargate.

---

## 📋 Prerequisites

Pastikan sudah ter-install di komputer kamu:
- **Java 17** (sudah ada)
- **Maven** (sudah ada via mvnw)
- **Git** (sudah ada)

---

## Step 1: Buat AWS Account

1. Buka [https://aws.amazon.com](https://aws.amazon.com)
2. Klik **"Create an AWS Account"**
3. Isi:
   - Email address
   - Password
   - AWS account name (contoh: `cms-microservices`)
4. Pilih **Personal** atau **Business** account
5. Masukkan informasi pembayaran (credit card diperlukan, tapi bisa pakai Free Tier)
6. Verifikasi identitas via SMS/telepon
7. Pilih **Basic Support (Free)**
8. Selesai! Login ke AWS Console

> ⚠️ **PENTING**: Aktifkan **MFA (Multi-Factor Authentication)** untuk root account:
> - AWS Console → IAM → Security credentials → Assign MFA device

---

## Step 2: Buat IAM User (Jangan Pakai Root!)

Root account hanya untuk billing. Buat IAM user untuk development:

1. Buka **AWS Console** → **IAM** → **Users** → **Create User**
2. Username: `cms-developer`
3. Centang **"Provide user access to the AWS Management Console"**
4. Pilih **"I want to create an IAM user"**
5. Set password
6. **Attach policies directly**, pilih:
   - `AmazonECS_FullAccess`
   - `AmazonEC2ContainerRegistryFullAccess`
   - `AmazonRDSFullAccess`
   - `AmazonVPCFullAccess`
   - `CloudFormationFullAccess` (cari `AWSCloudFormationFullAccess`)
   - `SecretsManagerReadWrite`
   - `ElasticLoadBalancingFullAccess`
   - `CloudWatchFullAccess`
   - `AmazonEC2FullAccess`
7. **Create User**
8. **SIMPAN** Access Key ID dan Secret Access Key!

### Buat Access Key untuk CLI:
1. Klik user `cms-developer` → **Security credentials**
2. **Create access key** → Pilih **"Command Line Interface (CLI)"**
3. **Download .csv file** — simpan dengan aman!

---

## Step 3: Install AWS CLI

### macOS (via Homebrew):
```bash
# Install Homebrew jika belum ada
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install AWS CLI
brew install awscli

# Verify
aws --version
```

### macOS (via Installer):
```bash
# Download dan install
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# Verify
aws --version
```

### Configure AWS CLI:
```bash
aws configure
```
Masukkan:
```
AWS Access Key ID: <dari Step 2>
AWS Secret Access Key: <dari Step 2>
Default region name: ap-southeast-1
Default output format: json
```

### Verify konfigurasi:
```bash
aws sts get-caller-identity
```
Harusnya return account ID dan user ARN kamu.

---

## Step 4: Install Docker Desktop

### macOS:
1. Download dari [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)
2. Install dan jalankan Docker Desktop
3. Verify:
```bash
docker --version
docker-compose --version
```

---

## Step 5: Login ke ECR (Elastic Container Registry)

```bash
# Login ke ECR
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.ap-southeast-1.amazonaws.com
```

Ganti `<ACCOUNT_ID>` dengan AWS Account ID kamu (12 digit number, bisa dicek di AWS Console kanan atas).

---

## Step 6: Deploy! 🚀

Setelah semua setup selesai:

```bash
# Dari root project directory
cd /path/to/java-microservice

# 1. Build dan push Docker images ke ECR
./aws/scripts/build-and-push.sh

# 2. Deploy infrastructure dan services
./aws/scripts/deploy.sh

# 3. Initialize database
./aws/scripts/init-rds.sh
```

---

## 🔧 Troubleshooting

### "Unable to locate credentials"
```bash
aws configure list  # Check current config
aws configure       # Re-configure
```

### "Docker daemon is not running"
- Pastikan Docker Desktop sedang berjalan

### "Access Denied"
- Pastikan IAM user punya semua policies yang diperlukan (Step 2)

### "Rate exceeded"
- Tunggu beberapa menit, lalu coba lagi

---

## 📊 Monitoring

Setelah deploy:
- **ECS Console**: https://ap-southeast-1.console.aws.amazon.com/ecs
- **RDS Console**: https://ap-southeast-1.console.aws.amazon.com/rds
- **CloudWatch Logs**: https://ap-southeast-1.console.aws.amazon.com/cloudwatch

---

## 💰 Cost Management

Tips hemat biaya:
1. **Free Tier**: RDS db.t3.micro gratis 12 bulan pertama
2. **Stop saat tidak dipakai**: Scale ECS services ke 0 task saat tidak dipakai
3. **Budget Alert**: Set budget alert di AWS Billing
   - AWS Console → Billing → Budgets → Create Budget
   - Set $100/bulan alert
