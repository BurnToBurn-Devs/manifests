# Infra

easyshift 프로젝트 인프라 구성을 위한 저장소입니다.

## Terraform 구성

DigitalOcean의 Singapore(sgp1) 리전에 Ubuntu 24.04 기반의 Droplet을 생성하고 일정 시간 대기 후 Reserved IP를 할당합니다.

### 준비 사항

로컬에 다음과 같은 사전 준비가 필요합니다.

- Terraform 설치
- DigitalOcean에서 API Token을 발급 받고 환경변수로 설정

DigitalOcean에 다음과 같은 사전 설정이 필요합니다.

- 미리 생성 후 SSH 키를 DigitalOcean에 등록합니다.
  - 저는 `jubuntu-oci`라는 이름으로 미리 생성한 SSH 키를 저장해두었습니다.
- 미리 VPC를 생성합니다.
  - 저는 `default-sgp1`라는 이름으로 자동 생성된 VPC를 사용했습니다.

### 사용법

1. 환경변수로 API 토큰을 설정합니다.

   ```sh
   export DIGITALOCEAN_TOKEN="YOUR_DIGITALOCEAN_API_TOKEN"
   export TF_VAR_do_token="YOUR_DIGITALOCEAN_API_TOKEN"
   ```

2. 테라폼을 초기화합니다.

   ```sh
   terraform init
   ```

3. 테라폼 plan을 확인하고 배포합니다.

   plan 확인

   ```sh
   terraform plan
   ```

   배포

   ```sh
   terraform apply # -auto-approve
   ```

### 설정 정보

Droplet 설정

- Name: `easyshift-prod`
- Region: `sgp1`
- Size: `s-2vcpu-2gb-amd`
- Image: `ubuntu-24-04-x64`
- 사용한 SSH Key: `jubuntu-oci`
- VPC: `default-sgp1`
- Tags: `Goorm`, `Terraform`, `Java`

- 고정 IP 설정
  - Droplet 생성 후 14초 대기(`time_sleep` 리소스) 후 할당

#### 출력

추후에 스트림에서 사용할 수 있는 출력 값을 제공합니다.

- droplet_ip: 생성된 Droplet의 공인 IPv4 주소
- reserved_ip: 할당된 Reserved IP 주소

#### 삭제

모든 리소스를 삭제하려면:

```sh
terraform destroy -auto-approve
```

### 참고

- 최신 DigitalOcean Provider 문서: [DigitalOcean Provider](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs)

## Ansible 구성
