#!/bin/bash

# Stop at any error, show all commands
set -exuo pipefail

# Export variable needed by 'docker build --build-arg'
export POLICY
export PLATFORM

# get docker default multiarch image prefix for PLATFORM
if [ "${PLATFORM}" == "aarch64" ]; then
	MULTIARCH_PREFIX="arm64v8/"
elif [ "${PLATFORM}" == "ppc64le" ]; then
	MULTIARCH_PREFIX="ppc64le/"
else
	echo "Unsupported platform: '${PLATFORM}'"
	exit 1
fi

if [ "${POLICY}" == "manylinux2014" ]; then
        BASEIMAGE="${MULTIARCH_PREFIX}centos:7"
	DEVTOOLSET_ROOTPATH="/opt/rh/devtoolset-9/root"
	PREPEND_PATH="${DEVTOOLSET_ROOTPATH}/usr/bin:"
        LD_LIBRARY_PATH_ARG="${DEVTOOLSET_ROOTPATH}/usr/lib64:${DEVTOOLSET_ROOTPATH}/usr/lib:${DEVTOOLSET_ROOTPATH}/usr/lib64/dyninst:${DEVTOOLSET_ROOTPATH}/usr/lib/dyninst:/usr/local/lib64"
else
	echo "Unsupported policy: '${POLICY}'"
	exit 1
fi
export BASEIMAGE
export DEVTOOLSET_ROOTPATH
export PREPEND_PATH
export LD_LIBRARY_PATH_ARG

docker buildx build \
	--load \
	--cache-from=type=local,src=$(pwd)/.buildx-cache-${POLICY}_${PLATFORM} \
	--cache-to=type=local,dest=$(pwd)/.buildx-cache-staging-${POLICY}_${PLATFORM} \
	--build-arg POLICY --build-arg PLATFORM --build-arg BASEIMAGE \
	--build-arg DEVTOOLSET_ROOTPATH --build-arg PREPEND_PATH --build-arg LD_LIBRARY_PATH_ARG \
	--rm -t quay.io/pypa/${POLICY}_${PLATFORM}:${COMMIT_SHA} \
	-f docker/Dockerfile docker/

docker run --rm -v $(pwd)/tests:/tests:ro quay.io/pypa/${POLICY}_${PLATFORM}:${COMMIT_SHA} /tests/run_tests.sh

if [ -d $(pwd)/.buildx-cache-${POLICY}_${PLATFORM} ]; then
	rm -rf $(pwd)/.buildx-cache-${POLICY}_${PLATFORM}
fi
mv $(pwd)/.buildx-cache-staging-${POLICY}_${PLATFORM} $(pwd)/.buildx-cache-${POLICY}_${PLATFORM}
