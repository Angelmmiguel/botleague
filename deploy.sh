#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

# TODO: This is temporal. Switch it to master!
SOURCE_BRANCH="travis"
TARGET_BRANCH="results"

# Pull requests and commits to other branches shouldn't try to deploy, just build to verify
if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "Skipping deploy; just doing a build."
    exit 0
fi

# Save some useful information
REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=`git rev-parse --verify HEAD`

git config user.name "Travis CI"
git config user.email "angel@laux.es"

# Checkout
git clone $REPO out
cd out
git checkout -b $TARGET_BRANCH origin/$TARGET_BRANCH
cd ..

# Copy results
mkdir -p out/images
cp ./results/*.png out/images
cp ./results/game-*.md out
cd out

# Commit the "changes", i.e. the new version.
# The delta will show diffs between new and old versions.

git status

git add .
git commit -m "Deploy results from ${SHA}"

git status

# Get the deploy key by using Travis's stored variables to decrypt deploy_key.enc
ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in ../deploy/deploy_key.enc -out ../deploy/deploy_key -d
chmod 600 ../deploy/deploy_key
eval `ssh-agent -s`
ssh-add ../deploy/deploy_key

# Now that we're all set up, we can push.
git push $SSH_REPO $TARGET_BRANCH
