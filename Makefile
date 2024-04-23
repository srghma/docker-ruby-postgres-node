# XXX
# docker login

DOCKER_ID_USER := "srghma"

docker_build_and_upload330:
	DOCKER_ID_USER=$(DOCKER_ID_USER) \
		DOCKER_IMAGE_NAME="bookworm-ruby330-postgres16-node20" \
		RUBY_VERSION='3.3.0-bookworm' \
		./build.sh

docker_build_and_upload: docker_build_and_upload330
