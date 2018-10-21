# XXX
# docker login

DOCKER_ID_USER := "srghma"

docker_build_and_upload23:
	DOCKER_ID_USER=$(DOCKER_ID_USER) \
		DOCKER_IMAGE_NAME="stretch-ruby23-postgres10-node10" \
		RUBY_VERSION='2.3' \
		./build.sh

docker_build_and_upload24:
	DOCKER_ID_USER=$(DOCKER_ID_USER) \
		DOCKER_IMAGE_NAME="stretch-ruby24-postgres10-node10" \
		RUBY_VERSION='2.4' \
		./build.sh

docker_build_and_upload: docker_build_and_upload23 docker_build_and_upload24
