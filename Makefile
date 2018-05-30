# XXX
# docker login

DOCKER_ID_USER := "srghma"
DOCKER_IMAGE_NAME := "stretch-ruby23-postgres10-node9"

docker_build_and_upload:
	@echo "Building image $(DOCKER_ID_USER)/$(DOCKER_IMAGE_NAME)"
	@echo
	@echo
	docker build -t $(DOCKER_ID_USER)/$(DOCKER_IMAGE_NAME) .
	docker push $(DOCKER_ID_USER)/$(DOCKER_IMAGE_NAME)
