#!/bin/bash

# Check if the version number is passed as an argument
if [ -z "$1" ]; then
  echo "Error: No version number provided."
  echo "Usage: $0 2.1.1"
  exit 1
fi

VERSION=$1
# RELEASE_BRANCH="release/$VERSION"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +"%m/%d/%Y, %I:%M:%S %p")

# Prompt message
echo "INFO: Update release.md with latest release information."
echo "WARNING: The release should be created from the release branch with the latest/desired pull."
read -p "Are you sure you want to proceed? (yes/no): " CONFIRMATION

if [ "$CONFIRMATION" != "yes" ]; then
  echo "Release process aborted."
  exit 0
fi

# Get the Git user
GIT_USER=$(git config user.name)
if [ -z "$GIT_USER" ]; then
  GIT_USER="Unknown"
fi

# Step 3: Append new version info to version.md
echo "Appending new version information to version.md..."
{
  echo "v$VERSION => $GIT_USER on $TIMESTAMP"
} >> version.md

# Step 4: Copy the content of release.md to the top of CHANGELOG.md with --- appended
if [ -f "release.md" ]; then
  echo "Copying release.md content to the top of CHANGELOG.md..."
  {
    echo "# Release v$VERSION - $DATE"
    echo ""
    cat release.md
    echo ""
    echo "---"
    echo ""
    cat CHANGELOG.md
  } > tmp_CHANGELOG.md && mv tmp_CHANGELOG.md CHANGELOG.md
else
  echo "Error: release.md file not found. Please prepare release.md manually."
  exit 1
fi

# Step 4.1: Copy the content of release.md.sample to release.md
if [ -f "release.md.sample" ]; then
  echo "Copying release.md.sample content to release.md..."
  {
    cat release.md.sample
  } > tmp_release.md && mv tmp_release.md release.md
else
  echo "Error: release.md.sample file not found. Please prepare release.md.sample manually."
  exit 1
fi

# # Step 5: Commit changes and push the release branch
echo "Committing release changes and pushing new tag..."
git add release.md CHANGELOG.md version.md
git commit -m "Release v$VERSION - $DATE"
git push

# # Step 6: Create a tag for the release
# echo "Creating a tag: v$VERSION"
# git tag v$VERSION
# git push origin v$VERSION

echo "Release process completed successfully."
