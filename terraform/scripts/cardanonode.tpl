#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
set -e

sudo yum update -y
sudo yum install git gcc gcc-c++ tmux gmp-devel make tar xz wget zlib-devel libtool autoconf -y
sudo yum install systemd-devel ncurses-devel ncurses-compat-libs -y
sudo yum install g++ gmp  ncurses realpath xz-utils -y

wget https://downloads.haskell.org/~cabal/cabal-install-3.4.0.0/cabal-install-3.4.0.0-x86_64-alpine-3.11.6-static-noofd.tar.xz
tar -xf cabal-install-3.4.0.0-x86_64-alpine-3.11.6-static-noofd.tar.xz
rm cabal-install-3.4.0.0-x86_64-alpine-3.11.6-static-noofd.tar.xz
mkdir -p ~/.local/bin
mv cabal ~/.local/bin/

echo $PATH
export PATH="~/.local/bin:$PATH"
source ~/.bashrc
cabal update
cabal --version

mkdir -p ./src
cd src
wget https://downloads.haskell.org/ghc/8.10.2/ghc-8.10.2-x86_64-deb9-linux.tar.xz
tar -xf ghc-8.10.2-x86_64-deb9-linux.tar.xz
rm ghc-8.10.2-x86_64-deb9-linux.tar.xz
cd ghc-8.10.2
./configure
make install
ghc --version
cd ..

git clone https://github.com/input-output-hk/libsodium
cd libsodium
git checkout 66f017f1
./autogen.sh
./configure
make
make install

export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"

git clone https://github.com/input-output-hk/cardano-node.git
ls cardano-node
cd cardano-node

git fetch --all --recurse-submodules --tags
git tag
git checkout tags/1.27.0

cabal configure --with-compiler=ghc-8.10.2

echo "package cardano-crypto-praos" >>  cabal.project.local
echo "  flags: -external-libsodium-vrf" >>  cabal.project.local

cabal clean
cabal update
cabal build all

cp -p "$(./scripts/bin-path.sh cardano-node)" ~/.local/bin/
cp -p "$(./scripts/bin-path.sh cardano-cli)" ~/.local/bin/

cardano-cli --version