#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

REPO="https://github.com/shiva/tools.git"
BRANCH="master"
CHECKOUT_DIR=`pwd`

echo "Install hugo ..."
rm -rf ${CHECKOUT_DIR}/binaries/
git clone --depth=1 --single-branch -b ${BRANCH} ${REPO} binaries

echo "Done."
