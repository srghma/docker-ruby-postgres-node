# XXX
# docker login

DOCKER_ID_USER := "srghma"

# docker_build_and_upload23:
# 	DOCKER_ID_USER=$(DOCKER_ID_USER) \
# 		DOCKER_IMAGE_NAME="stretch-ruby23-postgres13-node12" \
# 		RUBY_VERSION='2.3' \
# 		./build.sh

# docker_build_and_upload24:
# 	DOCKER_ID_USER=$(DOCKER_ID_USER) \
# 		DOCKER_IMAGE_NAME="stretch-ruby24-postgres13-node12" \
# 		RUBY_VERSION='2.4' \
# 		./build.sh

docker_build_and_upload263:
	DOCKER_ID_USER=$(DOCKER_ID_USER) \
		DOCKER_IMAGE_NAME="buster-ruby263-postgres13-node12" \
		RUBY_VERSION='2.6.3' \
		./build.sh

docker_build_and_upload273:
	DOCKER_ID_USER=$(DOCKER_ID_USER) \
		DOCKER_IMAGE_NAME="buster-ruby273-postgres13-node12" \
		RUBY_VERSION='2.7.3' \
		./build.sh

docker_build_and_upload30:
	DOCKER_ID_USER=$(DOCKER_ID_USER) \
		DOCKER_IMAGE_NAME="buster-ruby3-postgres13-node12" \
		RUBY_VERSION='3.0' \
		./build.sh

docker_build_and_upload: docker_build_and_upload263 docker_build_and_upload273 docker_build_and_upload30
