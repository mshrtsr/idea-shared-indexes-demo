#!/bin/bash -ex
set -euo pipefail
shopt -s nullglob

export WORKSPACE=$GITHUB_WORKSPACE
export COMMIT_HASH=$(git -C $WORKSPACE rev-parse --short HEAD)
export FILE_STORAGE_REPO="https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git"

echo "workspace: $WORKSPACE"
echo "project: $PROJECT_NAME"
echo "commit: $COMMIT_HASH"
echo "file storage url: $FILE_STORAGE_ROOT_URL"
echo "file storage repo: $FILE_STORAGE_REPO"

# プロジェクト内の依存関係を解消しておく
$WORKSPACE/mvnw dependency:resolve

# https://www.jetbrains.com/help/idea/shared-indexes.html#export-project-indexes-command-line
# 共有インデックスの生成
/opt/idea/bin/idea.sh dump-shared-index project --output=$TEMP/generate-output --tmp=$TEMP/temp --project-dir=$WORKSPACE --project-id=$PROJECT_NAME
ls -la $TEMP/generate-output

echo "save to $TEMP/indexes/project/$PROJECT_NAME/$COMMIT_HASH/share"
# https://www.jetbrains.com/help/idea/shared-indexes.html#copy-files-to-folder
git clone --single-branch -b gh-pages --depth=1 $FILE_STORAGE_REPO $TEMP/file-storage/
mkdir -p $TEMP/file-storage/indexes/project/$PROJECT_NAME/$COMMIT_HASH/share
cp $TEMP/generate-output/* $TEMP/file-storage/indexes/project/$PROJECT_NAME/$COMMIT_HASH/share/
ls -la $TEMP/file-storage/indexes/project/$PROJECT_NAME/$COMMIT_HASH/share/

# https://www.jetbrains.com/help/idea/shared-indexes.html#generate-metadata
# 共有インデックスのメタデータを更新
/opt/cdn-layout-tool/bin/cdn-layout-tool --indexes-dir=$TEMP/file-storage/indexes --url=$FILE_STORAGE_ROOT_URL

# 更新した共有インデックスをcommitしてpushする
git -C $TEMP/file-storage/ config --local user.email "github-actions[bot]@users.noreply.github.com"
git -C $TEMP/file-storage/ config --local user.name "github-actions[bot]"
git -C $TEMP/file-storage/ add -A
git -C $TEMP/file-storage/ commit -m "update shared indexes by $COMMIT_HASH"
git -C $TEMP/file-storage/ push
