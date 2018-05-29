DOCKER_REG := docker.aws-dev.veritone.com
IMAGE_NAME := aiware/aiware-engine-cluster-agent

IMAGE_TAG := v1
NOW_TAG := $(shell date +%Y%m%d-%H%M%S)
GIT_COMMIT := $(shell git rev-parse HEAD)

NAME := engine-agent
NETWORK := aiware_default
PORTMAPPING := 9510:9000
SRC := /Users/home/go/src/github.com/veritone/
TESTDATA:=/Users/home/testdata/aiware-grey/payload

ECR_DOCKER_REG=026972849384.dkr.ecr.us-east-1.amazonaws.com


.PHONY: gen-build-manifest
gen-build-manifest:
	sh ./gen-build-manifest.sh

.PHONY: build-docker
	docker build -t $(DOCKER_REG)/${IMAGE_NAME}:$(IMAGE_TAG) --build-arg ARG_GITHUB_ACCESS_TOKEN=$(GITHUB_ACCESS_TOKEN) .

# this assumes the following has been done:
# Set BLK_VERSION environment variable
# aws ecr get-login --no-include-email --region us-east-1
# then invoke the `docker login` command as output by the above
.PHONY: push-ecr
push-ecr:
	docker tag $(DOCKER_REG)/${IMAGE_NAME}:$(GIT_COMMIT) $(ECR_DOCKER_REG)/${IMAGE_NAME}:$(GIT_COMMIT)
	docker tag $(DOCKER_REG)/${IMAGE_NAME}:$(GIT_COMMIT) $(ECR_DOCKER_REG)/${IMAGE_NAME}:$(BLK_VERSION)
	docker push $(ECR_DOCKER_REG)/${IMAGE_NAME}:$(GIT_COMMIT)
	docker push $(ECR_DOCKER_REG)/${IMAGE_NAME}:$(BLK_VERSION)

# start the test container
# note that the Docker API version will need to be same as the host
# best is to retrieve the server version from the host
.PHONY: test-run
test-run:
	docker run -it --rm --name $(NAME) --network ${NETWORK} --entrypoint=sh -p $(PORTMAPPING) -e MINIO_ACCESS_KEY=$(MINIO_ACCESS_KEY) -e MINIO_SECRET_KEY=$(MINIO_SECRET_KEY) -e DOCKER_API_VERSION=1.35 -e STACK_NETWORK=${NETWORK} -e CLUSTER_ID=MYCLUSTER -e CLUSTER_PRIORITIES=0 -e POSTGRES_PASSWORD=L0r3mtocsum4m0r3 -v /var/run/docker.sock:/var/run/docker.sock -v $(SRC):/vsrc $(DOCKER_REG)/${IMAGE_NAME}:$(IMAGE_TAG)

.PHONY: push-docker
push-docker:
	docker push $(DOCKER_REG)/${IMAGE_NAME}:$(IMAGE_TAG)
	docker push $(DOCKER_REG)/${IMAGE_NAME}:$(GIT_COMMIT)
