#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "$SCRIPT_DIR/config/config.ini"
SCOPES_LIST=`cat "$SCRIPT_DIR/config/$REPO_PREFIX-scopes.txt" | tr '\n' ' '`

# Need at least 2 args
if [ $# -le 1 ]
then
	echo -e "\nUsage: $0 scope <branch-name> *<target-path>\n"
	echo -e "Create a branch in each repo\n"
	echo -e "scope: specify a valid scope for \"$REPO_PREFIX\" repos from the list: $SCOPES_LIST"
	echo -e "branch-name: the name of the new branch to be created."
	echo -e "target-path: optional argument specifying the path where the clone should be located. If not specified the current directory will be used.\n"
	exit 1
fi

SCOPE=$1
BRANCH_NAME=$2
TARGET_PATH=$3

. "$SCRIPT_DIR/helper/functions.sh"

#
# Check all the pre-requisites, if any fail a message will be printed and script will exit
#

check_valid_scope
echo -e "Create branch starting for \"$REPO_PREFIX\" repos with scope: $SCOPE\n"
TARGET_PATH=$(get_target_path)
check_target_path_exists
check_any_directories_missing_prior_to_run

#
# Now for every repo starting creating the branch!
#

while read line; do
	REPO_NAME=`echo $line | awk '{print $1}'`
	UPSTREAM_ORG=`echo $line | awk '{print $2}'`
	BASE_BRANCH=`echo $line | awk '{print $3}'`

	if [ "$SCOPE" = "all" ] || [ "$UPSTREAM_ORG" = "$SCOPE" ]
	then
		"$SCRIPT_DIR/2-create-branch-repo.sh" "$REPO_NAME" "$BRANCH_NAME" "$TARGET_PATH" "multi_run"
	fi
done < "$SCRIPT_DIR/config/$REPO_PREFIX-repos.txt"
