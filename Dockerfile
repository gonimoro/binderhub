# Current binderhub image
ARG BASE_IMAGE=quay.io/jupyterhub/k8s-binderhub:1.0.0-0.dev.git.3850.h7ccf7c8e

# binderhub uses node 22
# see https://github.com/jupyterhub/binderhub/blob/main/.github/workflows/publish.yml#L50
FROM node:22 AS build

COPY . /binderhub

WORKDIR /binderhub

RUN npm install \
    && npm run webpack


FROM $BASE_IMAGE

COPY --from=build /binderhub/binderhub/static/dist/ /tmp/dist

RUN mv /tmp/dist/* $(python -c "import importlib.resources as impres; print(impres.files('binderhub'))")/static/dist
