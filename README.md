# Infra - EasyShift

[![Terraform](https://img.shields.io/badge/Terraform-1.10.5-623CE4?logo=terraform)](https://www.terraform.io/)
[![Ansible](https://img.shields.io/badge/Ansible-2.17.8-EE0000?logo=ansible)](https://www.ansible.com/)

EasyShift 프로젝트 인프라 구성을 위한 저장소입니다.

## Terraform - Digital Ocean

DigitalOcean의 Singapore(sgp1) 리전에 `Ubuntu 24.04` 기반의 Droplet을 생성하고 일정 시간 대기 후 Reserved IP를 할당합니다.

### Terraform 준비 사항

먼저 Terraform을 실행할 수 있는 환경을 준비합니다.

- Terraform 설치
- DigitalOcean에서 API Token을 발급 받고 환경변수로 설정

Digital Ocean에 다음과 같은 사전 설정이 필요합니다.

- 미리 생성 후 SSH 키를 DigitalOcean에 등록합니다.
  - 저는 `jubuntu-oci`라는 이름으로 미리 생성한 SSH 키를 저장해두었습니다.
- 미리 VPC를 생성합니다.
  - 저는 `default-sgp1`라는 이름으로 자동 생성된 VPC를 사용했습니다.

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

#### 출력

추후에 스트림에서 사용할 수 있는 출력 값을 제공합니다.

- droplet_ip: 생성된 Droplet의 공인 IPv4 주소
- reserved_ip: 할당된 Reserved IP 주소

#### 삭제

모든 리소스를 삭제하려면:

```sh
terraform destroy -auto-approve
```

#### 참고

최신 DigitalOcean Provider 문서: [DigitalOcean Provider](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs)

---

## Ansible - 서버 환경 설정

서버 환경 설정을 위해 Ansible을 사용합니다.

### 주요 작업

- APT 캐시 업데이트 및 필수 패키지 설치
  - `zsh`, `tmux`, `python3`, `vim`, `git` 등 여러 유틸리티 설치
  - oh-my-zsh 설치
- APT 자동 업데이트 및 타이머 비활성화
  - `apt-daily.timer`, `apt-daily-upgrade.timer` 중지 및 서비스 마스킹
- Git 글로벌 설정
  - 사용자 이름과 이메일 설정
- Docker 설치 및 구성
  - Docker 의존 패키지 설치
  - 공식 GPG 키/리포지토리 추가
  - Docker 패키지 설치 및 서비스 실행 보장
- SDKMAN을 통한 Java 21, Gradle 8.12 설치

### 파일 구성

`site.yml`

- 실제 서버 환경 설정 플레이북 파일입니다.

`inventory.ini` (예시 파일로 제공)

- 실제 정보가 담긴 `inventory.ini` 파일은 GitHub에 업로드하지 않았습니다.
- 예시 파일(`inventory.sample.ini`)을 참고하여 실제 정보를 입력하고 `inventory.ini` 파일로 저장합니다.

### Ansible 준비 사항

1. 로컬에 Ansible을 설치합니다.

   ```sh
   pip install ansible
   ```

   대상 서버에 SSH로 접속할 수 있어야 하며 sudo 권한이 필요합니다.

2. `inventory.sample.ini` 파일을 참고하여 실제 서버 정보를 설정합니다.

   ```ini
   [all]
   <SERVER_IP> ansible_user=root
   ```

### Ansible 사용법

플레이북 실행

```sh
ansible-playbook -i inventory.ini site.yml
```

특정 태그만 실행하려면 `--tags` 옵션을 사용합니다.

```sh
# Docker 관련 작업만 실행
ansible-playbook -i inventory.ini site.yml --tags docker
```

참고. Dry Run을 실행하려면 `--check` 옵션을 사용합니다.

```sh
ansible-playbook -i inventory.ini site.yml --check --diff
```
