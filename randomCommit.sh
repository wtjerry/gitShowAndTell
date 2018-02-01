#!/bin/bash 

RANDOM_FILE=$(shuf -i 0-9 -n 1)
RANDOM_CONTENT=$(shuf -i 0-9 -n 1)

echo $RANDOM_CONTENT >> $RANDOM_FILE

GIT_MESSAGE="added $RANDOM_CONTENT to file $RANDOM_FILE"
echo $GIT_MESSAGE

git add "$RANDOM_FILE"
git commit -m "$GIT_MESSAGE"
