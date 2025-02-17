# Infra - EasyShift

[![Terraform](https://img.shields.io/badge/Terraform-1.10.5-623CE4?logo=terraform)](https://www.terraform.io/)
[![Ansible](https://img.shields.io/badge/Ansible-2.17.8-EE0000?logo=ansible)](https://www.ansible.com/)

EasyShift 프로젝트의 인프라 구성을 위한 Terraform, Ansible 스크립트입니다.

## Terraform - DigitalOcean 서버 생성

Terraform을 이용해 싱가포르(sgp1) 리전에 `Ubuntu 24.04` 기반 Droplet(AWS EC2와 비슷한 리소스)을 생성하고, 일정 시간 후 Reserved IP를 할당합니다.

### Terraform 사전 준비

먼저 Terraform을 실행할 수 있는 환경을 준비합니다.

1. Terraform 설치 (설치 가이드)

2. DigitalOcean API Token 발급 및 환경 변수 설정
3. DigitalOcean에서 미리 SSH 키와 VPC 생성
   - 저는 `jubuntu-oci`라는 이름으로 미리 생성한 SSH 키를 저장했고 `default-sgp1`라는 이름으로 자동 생성된 VPC를 사용했습니다.
   - 본인의 환경에 맞게 terraform 파일을 수정해주세요.

### Terraform 설정 정보

- Name: `easyshift-prod`
- Region: `sgp1`
- Size: `s-2vcpu-2gb-amd`
- Image: `ubuntu-24-04-x64`
- 사용한 SSH Key: `jubuntu-oci`
- VPC: `default-sgp1`
- Tags: `Goorm`, `Terraform`, `Java`
- Reserved IP: Droplet 생성 후 14초 후 할당

### Terraform 실행 방법

```sh
# 환경 변수 설정
export DIGITALOCEAN_TOKEN="DIGITALOCEAN_API_TOKEN" # 자신의 API 토큰으로 변경
export TF_VAR_do_token="DIGITALOCEAN_API_TOKEN" # 자신의 API 토큰으로 변경(위와 동일한 값)

# Terraform 초기화
terraform init

# 실행 계획 확인
terraform plan

# 배포 실행
terraform apply # -auto-approve 옵션을 사용하면 바로 배포 가능
```

배포가 완료되면 추후에 스크립트에서 사용할 수 있게 생성된 IP 리소스 정보를 출력합니다.

- droplet_ip: 생성된 Droplet의 공인 IPv4 주소
- reserved_ip: 할당된 Reserved IP 주소

### 삭제

```sh
terraform destroy # -auto-approve
```

### 참고

- DigitalOcean Provider 문서: [DigitalOcean Provider](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs)

---

## Ansible - 서버 환경 설정

Terraform을 통해 생성한 서버 환경을 Ansible을 이용해서 설정합니다.

### 주요 작업

- 필수 패키지 설치 (zsh, tmux, vim, git 등)
- apt 자동 업데이트 및 타이머 비활성화
- git 설정
- docker 설치 및 구성
- sdkman을 통한 Java 21 및 Gradle 8.12 설치
- 배포 사용자 생성과 ssh key 등록
- MySQL 8 컨테이너 실행

### 파일 구성

1. `site.yml`: 서버 환경 설정 플레이북
2. `inventory.sample.ini`: 예시 인벤토리 파일
   - 실제 정보가 담긴 `inventory.ini` 파일은 업로드하지 않았습니다.
   - 예시 파일(`inventory.sample.ini`)을 참고하여 실제 정보를 입력하고 `inventory.ini` 파일로 저장해주세요.

### Ansible 준비 사항

1. Ansible을 설치합니다.

   ```sh
   pip install ansible
   ```

2. `inventory.sample.ini` 파일을 참고해서 실제 서버 정보를 입력하고 `inventory.ini` 파일로 저장합니다.

   ```ini
   [all]
   <SERVER_IP> ansible_user=root
   ```

   대상 서버에 SSH로 접속할 수 있어야 하고 `root` 권한이 필요합니다.

### Ansible 실행 방법

플레이북 실행 - `site.yml` 파일을 실행하면 설정이 적용됩니다.

```sh
ansible-playbook -i inventory.ini site.yml
```

특정 태그만 실행하려면 `--tags` 옵션을 사용하면 됩니다.

```sh
ansible-playbook -i inventory.ini site.yml --tags docker # Docker 관련 작업만 실행
```

Dry Run을 하려면 `--check` 옵션을 사용합니다.

```sh
ansible-playbook -i inventory.ini site.yml --check --diff
```
