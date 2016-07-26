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

echo "Update theme ..."
git submodule update --init themes/lanyon

echo "Checkout ${POSTS_REPO} ..."
git clone --depth=1 --single-branch -b ${POSTS_BRANCH} ${POSTS_REPO} blog-posts

echo "Create symlinks to content"
mkdir -p content/post
cp -R blog-posts/post/* content/post/
ln -s ${CHECKOUT_DIR}/blog-posts/static static

echo "Checkout ${GITHUB_PUBLISH_REPO} ..."
git clone --depth=1 --single-branch -b ${GITHUB_PUBLISH_BRANCH} ${GITHUB_PUBLISH_REPO} public

echo "Re-generate blog ..."
hugo -t lanyon

# Pull requests and commits to other branches shouldn't try to deploy, just build to verify
if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$CONTENT_BRANCH" ]; then
    echo "Skipping deploy; just doing a build. Done."
    exit 0
fi

echo "Check for changes in ${GITHUB_PUBLISH_REPO}"
cd public
if git diff-index --quiet HEAD --; then
    echo "No changes to the spec on this push; exiting."
    exit 0
fi

echo "Something changed; commit changes to ${GITHUB_PUBLISH_REPO} ..."
git config user.name ${TRAVIS_AUTHOR}
git config user.email ${TRAVIS_EMAIL}
git add .
git commit -m "publish: ${LAST_COMMIT_MSG}"
git push ${GITHUB_PUBLISH_REPO_WITH_TOKEN} ${GITHUB_PUBLISH_BRANCH}

echo "Done."
