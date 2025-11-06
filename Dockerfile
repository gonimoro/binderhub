# Current binderhub image
ARG BASE_IMAGE=quay.io/jupyterhub/k8s-binderhub:1.0.0-0.dev.git.3850.h7ccf7c8e

# binderhub uses node 22
# see https://github.com/jupyterhub/binderhub/blob/main/.github/workflows/publish.yml#L50
FROM node:22 AS build

COPY . /binderhub

WORKDIR /binderhub

RUN npm install \
    && npm run webpack

# The actual image
FROM $BASE_IMAGE

# Moving files to /tmp/binderhub to then put it in the correct package path
RUN mkdir /tmp/binderhub
COPY --from=build /binderhub/binderhub/static/dist/ /tmp/binderhub/dist
COPY full-replay.svg /tmp/binderhub/

RUN PKG_PATH=$(python -c 'import importlib.resources as impres; print(impres.files("binderhub"))') \
	&& mv /tmp/binderhub/dist/* "$PKG_PATH/static/dist" \
	&& mv /tmp/binderhub/full-replay.svg "$PKG_PATH/static/logo.svg" \
	&& rm -rf /tmp/binderhub

