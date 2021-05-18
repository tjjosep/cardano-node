#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
set -e

PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:
rpm --setugids sudo && rpm --setperms sudo

sudo yum update -y
sudo yum install git gcc gcc-c++ tmux gmp-devel make tar xz wget zlib-devel libtool autoconf -y
sudo yum install systemd-devel ncurses-devel ncurses-compat-libs -y


wget https://downloads.haskell.org/~cabal/cabal-install-3.4.0.0/cabal-install-3.4.0.0-x86_64-alpine-3.11.6-static-noofd.tar.xz
tar -xf cabal-install-3.4.0.0-x86_64-alpine-3.11.6-static-noofd.tar.xz
rm cabal-install-3.4.0.0-x86_64-alpine-3.11.6-static-noofd.tar.xz
mkdir -p ~/.local/bin
mv cabal ~/.local/bin/

echo $PATH

curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
ghcup upgrade
ghcup install 8.10.2
ghcup set 8.10.2
ghc --version

export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"

mkdir -p ~/src
cd ~/src
git clone https://github.com/input-output-hk/libsodium
cd libsodium
git checkout 66f017f1
./autogen.sh
./configure
make
sudo make install

mkdir -p ~/src
cd ~/src
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