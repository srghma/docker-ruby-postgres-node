#!/bin/sh

echo "Building image $DOCKER_ID_USER/$DOCKER_IMAGE_NAME"

echo "RUBY_VERSION=$RUBY_VERSION"

temp_file=$(mktemp)

sed -e 's/%%RUBY_VERSION%%/'"$RUBY_VERSION"'/g;' \
  Dockerfile.template >> $temp_file

# cat $temp_file

docker build -t $DOCKER_ID_USER/$DOCKER_IMAGE_NAME -f $temp_file .
docker push $DOCKER_ID_USER/$DOCKER_IMAGE_NAME

rm $temp_file
