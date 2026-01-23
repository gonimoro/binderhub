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

RUN PKG_PATH=$(python -c 'import importlib.resources as impres; print(impres.files("binderhub"))') \
	&& mv /tmp/binderhub/dist/* "$PKG_PATH/static/dist" \
	&& rm -rf /tmp/binderhub

# EC template go to separate dir so can be enabled in configration as needed
# c.BinderHub.template_path = '/ec-templates/'
# the template assumes hub static assets are avaialable at `/hub/static` URL,
# if that's not the case, this URL should be defined with `template_variables`
# config:
# c.BinderHub.template_variables = {'hub_static_url': 'https://example.com/static'}
COPY ec-templates /ec-templates
