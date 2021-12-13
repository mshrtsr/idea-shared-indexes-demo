#!/bin/bash -ex
set -euo pipefail
shopt -s nullglob

echo "workspace: $WORKSPACE"
ls -la $WORKSPACE

$WORKSPACE/mvnw dependency:resolve

export COMMIT_HASH=$(git -C $WORKSPACE rev-parse --short HEAD)
echo "project: $PROJECT_NAME"
echo "commit: $COMMIT_HASH"
echo "url: $FILE_STORAGE_ROOT_URL"

# https://www.jetbrains.com/help/idea/shared-indexes.html#export-project-indexes-command-line
/opt/idea/bin/idea.sh dump-shared-index project --output=$TEMP/generate-output --tmp=$TEMP/temp --project-dir=$WORKSPACE --project-id=$PROJECT_NAME 
ls -la $TEMP/generate-output

echo "save to $TEMP/indexes/project/$PROJECT_NAME/$COMMIT_HASH/share"
# https://www.jetbrains.com/help/idea/shared-indexes.html#copy-files-to-folder
mkdir -p $TEMP/indexes/project/$PROJECT_NAME/$COMMIT_HASH/share
cp $TEMP/generate-output/* $TEMP/indexes/project/$PROJECT_NAME/$COMMIT_HASH/share/
ls -la $TEMP/indexes/project/$PROJECT_NAME/$COMMIT_HASH/share/

# https://www.jetbrains.com/help/idea/shared-indexes.html#generate-metadata
/opt/cdn-layout-tool/bin/cdn-layout-tool --indexes-dir=$TEMP/indexes --url=$FILE_STORAGE_ROOT_URL
ls -la $TEMP/indexes
git -C $TEMP/indexes status
