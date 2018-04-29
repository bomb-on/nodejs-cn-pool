#!/bin/bash

cd "$HOME"
git clone https://github.com/LMDB/lmdb
cd lmdb
git checkout 4d2154397afd90ca519bfa102b2aad515159bd50
cd libraries/liblmdb/
make -j `nproc`
sudo make install
rm -rf "$HOME"/lmdb
