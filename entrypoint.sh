#!/bin/sh -l

set -u

cd /github/workspace || exit 1

# Env and options
if [ -z "${GITHUB_TOKEN}" ]
then
    echo "The GITHUB_TOKEN environment variable is not defined."
    exit 1
fi

BRANCH="${1}"
NAME="${2}"
MESSAGE="${3}"
DRAFT="${4}"
PRE="${5}"
CREATE_RELEASE="${6}"

# Fetch git tags
git fetch --depth=1 origin +refs/tags/*:refs/tags/*

NEXT_RELEASE=$(date '+%Y.%V')

LAST_HASH=$(git rev-list --tags --max-count=1)
echo "Last hash : ${LAST_HASH}"

LAST_RELEASE=$(git describe --tags "${LAST_HASH}")
echo "Last release : ${LAST_RELEASE}"

MAJOR_LAST_RELEASE=$(echo "${LAST_RELEASE}" | awk  '{ string=substr($0, 1, 7); print string; }' )
echo "Last major release : ${MAJOR_LAST_RELEASE}"

if [ "${MAJOR_LAST_RELEASE}" = "${NEXT_RELEASE}" ]; then
    MINOR_LAST_RELEASE=$(echo "${LAST_RELEASE}" | awk  '{ string=substr($0, 9); print string; }' )
    NEXT_RELEASE=${MAJOR_LAST_RELEASE}.$((${MINOR_LAST_RELEASE} + 1))
    echo "Minor release"
fi

if [ "${NAME}" = "0" ]; then
	NAME="release: version ${NEXT_RELEASE}"
fi

if [ "${MESSAGE}" = "0" ]; then
  MESSAGE=$(conventional-changelog)
fi

echo "Next release : ${NEXT_RELEASE}"

echo "${MESSAGE}"

if [ "${CREATE_RELEASE}" = "true" ]; then
  API_JSON=$(printf '{"tag_name": "%s","target_commitish": "%s","name": "%s","body": "%s","draft": %s,"prerelease": %s}' "$NEXT_RELEASE" "$BRANCH" "$NEXT_RELEASE" "$MESSAGE" "$DRAFT" "$PRE" )
  curl --fail --data "${API_JSON}" -s -i "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases?access_token=${GITHUB_TOKEN}"
fi;

echo ::set-output name=release::"${NEXT_RELEASE}"
