#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

# Save some useful information
TRAVIS_AUTHOR="Travis CI"
TRAVIS_EMAIL="travis@shiv.me"

CONTENT_BRANCH="master"

POSTS_REPO="https://github.com/shiva/blog-posts.git"
POSTS_BRANCH="all_md"

GITHUB_PUBLISH_REPO="https://github.com/shiva/shiva.github.io.git"
GITHUB_PUBLISH_REPO_WITH_TOKEN=${GITHUB_PUBLISH_REPO/https:\/\/github.com\//https://${GH_TOKEN}@github.com/}
GITHUB_PUBLISH_BRANCH="master"

LAST_COMMIT_MSG=`git log -1 --pretty=format:%s`

echo "Starting publish for ${LAST_COMMIT_MSG}."
CHECKOUT_DIR=`pwd`

#echo "Update theme ..."
#git submodule update --init themes/lithium

echo "Checkout ${POSTS_REPO} ..."
rm -rf content
git clone --depth=1 --single-branch -b ${POSTS_BRANCH} ${POSTS_REPO} content

echo "Checkout ${GITHUB_PUBLISH_REPO} ..."
rm -rf public
git clone --depth=1 --single-branch -b ${GITHUB_PUBLISH_BRANCH} ${GITHUB_PUBLISH_REPO} public

echo "Re-generate blog ..."
${CHECKOUT_DIR}/binaries/hugo 

echo "Done."
