#!/bin/bash

curl -fsSLk https://git.lan/dev/scripts/raw/branch/main/cert/create.sh | bash -s -- $1
curl -fsSLk https://git.lan/dev/scripts/raw/branch/main/cert/install.sh | bash -s -- $1