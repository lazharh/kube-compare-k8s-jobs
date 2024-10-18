default: podman_build
include .env

VARS:=$(shell sed -ne 's/ *\#.*$$//; /./ s/=.*$$// p' .env )
$(foreach v,$(VARS),$(eval $(shell echo export $(v)="$($(v))")))
BASE_IMAGE ?= registry.redhat.io/openshift4/ose-cli-rhel9:v4.16
DOCKER_IMAGE ?= quay.io/bzhai/kube-compare-job
DOCKER_TAG ?= v4.16

podman_build:
	podman build \
	  --build-arg BASE_IMAGE=$(BASE_IMAGE) \
	  -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

podman_push:
	# Push to DockerHub
	podman push $(DOCKER_IMAGE):$(DOCKER_TAG)