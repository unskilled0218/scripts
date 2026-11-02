# setup

```bash
sudo apt update && sudo apt install -y curl &&\
curl -fsSLk https://git.lan/dev/scripts/raw/branch/main/setup-ubuntu/init.sh | bash
```

# create/install cert

```bash
curl -fsSLk https://git.lan/dev/scripts/raw/branch/main/cert/create.sh | bash -s -- home.lan
curl -fsSLk https://git.lan/dev/scripts/raw/branch/main/cert/install.sh | bash -s -- home.lan
```

or just

```bash
curl -fsSLk https://git.lan/dev/scripts/raw/branch/main/cert/create-install.sh | bash -s -- home.lan
```

# install docker

```bash
curl -fsSLk https://git.lan/dev/scripts/raw/branch/main/install-docker.sh | bash
```