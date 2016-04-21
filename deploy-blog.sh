!/bin/bash
set -e # Exit with nonzero exit code if anything fails

# Save some useful information
TRAVIS_AUTHOR="Travis CI"
TRAVIS_EMAIL="travis@shiv.me"
GITHUB_PUBLISH_BRANCH="master"
BLOG_REPO="https://github.com/shiva/blog.shiv.me.source.git"
BLOG_BRANCH="master"
BLOG_REPO_WITH_TOKEN=${BLOG_REPO/https:\/\/github.com\//https://${GH_TOKEN}@github.com/}
GITHUB_PUBLISH_REPO="https://github.com/shiva/shiva.github.io.git"
GITHUB_PUBLISH_REPO_WITH_TOKEN=${GITHUB_PUBLISH_REPO/https:\/\/github.com\//https://${GH_TOKEN}@github.com/}
GITHUB_PUBLISH_BRANCH="master"

# Pull requests and commits to other branches shouldn't try to deploy, just build to verify
if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$BLOG_BRANCH" ]; then
    echo "Skipping deploy; just doing a build."
    exit 0
fi

echo "Clone $BLOG_REPO ..."
git clone $BLOG_REPO blog
cd blog
git checkout $BLOG_BRANCH
git submodule init
git submodule update themes/lanyon
git submodule update content

LAST_COMMIT_MSG=`git log -1 --pretty=format:%s`

echo "Checkout ${GITHUB_PUBLISH_REPO} ..."
git clone ${GITHUB_PUBLISH_REPO} public
git checkout ${GITHUB_PUBLISH_BRANCH}

echo "Re-generate blog ..."
hugo -t lanyon

# check if no changes
if git diff-index --quiet HEAD --; then
    echo "No changes to the spec on this push; exiting."
    exit 0
fi

echo "Commit the changes to blog ..."
git config user.email "${TRAVIS_EMAIL}"
git config user.name "${TRAVIS_AUTHOR}"
git add .
git commit -m "publish:${LAST_COMMIT_MSG}"
git push $GITHUB_PUBLISH_REPO_WITH_TOKEN $GITHUB_PUBLISH_BRANCH

echo "Done."
