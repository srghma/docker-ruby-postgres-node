# XXX
# docker login

DOCKER_ID_USER := "srghma"

docker_build_and_upload330:
	DOCKER_ID_USER=$(DOCKER_ID_USER) \
		DOCKER_IMAGE_NAME="bookworm-ruby342-postgres17-node23" \
		RUBY_VERSION="3.4.2" \
		./build.sh

# docker_build_and_upload27:
# 	DOCKER_ID_USER=$(DOCKER_ID_USER) \
# 		DOCKER_IMAGE_NAME="bullseye-ruby27-postgres16-node18" \
# 		RUBY_VERSION="2-bullseye" \
# 		./build.sh

docker_build_and_upload: docker_build_and_upload27
