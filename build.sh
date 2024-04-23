#!/bin/sh

set -euxo pipefail

echo "Building image $DOCKER_ID_USER/$DOCKER_IMAGE_NAME"

echo "RUBY_VERSION=$RUBY_VERSION"

# temp_file=$(mktemp)
temp_file=./Dockerfile

sed -e 's/%%RUBY_VERSION%%/'"$RUBY_VERSION"'/g;' \
  Dockerfile.template > $temp_file

# does this fix caching?

# cat $temp_file

VERSION=v0.1
docker build -t $DOCKER_ID_USER/$DOCKER_IMAGE_NAME:latest -t $DOCKER_ID_USER/$DOCKER_IMAGE_NAME:$VERSION -f $temp_file --pull .
docker push $DOCKER_ID_USER/$DOCKER_IMAGE_NAME:$VERSION
docker push $DOCKER_ID_USER/$DOCKER_IMAGE_NAME:latest

rm $temp_file
