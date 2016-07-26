#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

# Save some useful information
TRAVIS_AUTHOR="Travis CI"
TRAVIS_EMAIL="travis@shiv.me"

CONTENT_BRANCH="all_md"

BLOG_REPO="https://github.com/shiva/blog.shiv.me.source.git"
BLOG_REPO_WITH_TOKEN=${BLOG_REPO/https:\/\/github.com\//https://${GH_TOKEN}@github.com/}
BLOG_BRANCH="master"

GITHUB_PUBLISH_REPO="https://github.com/shiva/shiva.github.io.git"
GITHUB_PUBLISH_REPO_WITH_TOKEN=${GITHUB_PUBLISH_REPO/https:\/\/github.com\//https://${GH_TOKEN}@github.com/}
GITHUB_PUBLISH_BRANCH="master"

LAST_COMMIT_MSG=`git log -1 --pretty=format:%s`

echo "Starting publish for ${LAST_COMMIT_MSG}."
CHECKOUT_DIR=`pwd`

echo "Checkout ${BLOG_REPO} ..."
git clone --depth=1 --single-branch -b ${BLOG_BRANCH} ${BLOG_REPO} blog
cd blog
git submodule update --init themes/lanyon
cd ..

echo "create symlinks to content"
mkdir -p blog/content/post
cp -R ${CHECKOUT_DIR}/post/* blog/content/post/
rm -rf blog/static
ln -s ${CHECKOUT_DIR}/static blog/static

echo "Checkout ${GITHUB_PUBLISH_REPO} ..."
git clone --depth=1 --single-branch -b ${GITHUB_PUBLISH_BRANCH} ${GITHUB_PUBLISH_REPO} blog/public

echo "Re-generate blog ..."
cd blog
hugo -t lanyon

# Pull requests and commits to other branches shouldn't try to deploy, just build to verify
if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$CONTENT_BRANCH" ]; then
    echo "Skipping deploy; just doing a build. Done."
    exit 0
fi

echo "check for changes in ${GITHUB_PUBLISH_REPO}"
cd public
if git diff-index --quiet HEAD --; then
    echo "No changes to the spec on this push; exiting."
    exit 0
fi

echo "Something changed; commit changes to ${GITHUB_PUBLISH_REPO} ..."
git config user.name ${TRAVIS_AUTHOR}
git config user.email ${TRAVIS_EMAIL}
git add .
git commit -m "sync:${LAST_COMMIT_MSG}"
git push ${GITHUB_PUBLISH_REPO_WITH_TOKEN} ${GITHUB_PUBLISH_BRANCH}

echo "Done."
