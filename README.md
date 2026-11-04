# setup

```bash
sudo apt update && sudo apt install -y curl &&\
curl -fsSLk https://git.lan/dev/scripts/raw/branch/main/setup-ubuntu/init.sh | bash
```

# create/install cert

```bash
curl -fsSLk https://git.lan/dev/scripts/raw/branch/main/cert/create-install.sh | bash -s -- home.lan
```

# install custom script

```bash
curl -fsSLk https://git.lan/dev/scripts/raw/branch/main/dev/install.sh | bash
```