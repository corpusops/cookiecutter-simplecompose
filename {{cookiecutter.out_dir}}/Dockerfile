# syntax=docker/dockerfile:1.3
ARG BASE_IMAGE={{cookiecutter.base_image}}
FROM $BASE_IMAGE AS base
USER root
WORKDIR /tmp/install
ARG \
{%- if cookiecutter.with_pyapp %}
    PY_VER="3.8" \
    USER_VENV="" \
    PIP_SRC="" \
{%- endif %}
{%- if cookiecutter.with_node %}
    NPM_TARGET="ci" \
    NVM_DLURI="https://raw.githubusercontent.com/nvm-sh/nvm" \
    NVM_RELEASE="latest" \
    NVM_URI="https://api.github.com/repos/nvm-sh/nvm/releases" \
    PACKAGEJSON_LOCATION="requirements" \
{%- endif %}
{%- if cookiecutter.with_pyapp %}
    PIP_REQ=>=22 SETUPTOOLS_REQ=<60 \
    REQUIREMENTS="requirements/requirements.txt requirements/requirements-dev.txt" \
{%- endif %}
    APP_HOME="/w" \
    DEV_DEPENDENCIES_PATTERN="^#\s*dev dependencies" \
    GITHUB_PAT="NTA2N2MxYTQzNDgzOGRkYzZkZTczZTZlNjljZTFkNGEzNWZjMWMxOAo=" \
    IMAGE_USER_RUNNER="root" \
    USER_GID="" \
    USER_GROUP="" \
    USER_HOME="/home/app" \
    USER_NAME="app" \
    USER_UID="1000"
ENV \
    USER_NAME="$USER_NAME" \
    USER_HOME="$USER_HOME" \
    USER_UID="$USER_UID" \
    USER_GID="${USER_GID:-$USER_UID}" \
    USER_GROUP="${USER_GROUP:-$USER_NAME}" \
    APP_HOME="${APP_HOME:-$USER_HOME}" \
{%- if cookiecutter.with_pyapp %}
    PY_VER="${PY_VER}" \
{%- endif %}
{%- if cookiecutter.with_node %}
    NVM_RELEASE="$NVM_RELEASE" \
    PACKAGEJSON_LOCATION="$PACKAGEJSON_LOCATION" \
    REQUIREMENTS="$REQUIREMENTS" \
{%- endif %}
    IMAGE_USER_RUNNER="$IMAGE_USER_RUNNER"
{%- if cookiecutter.with_pyapp %}
ENV USER_VENV="${USER_VENV:-$APP_HOME/venv}"
{%- endif%}
ENV \
{%- if cookiecutter.with_pyapp %}
    PIP_SRC="${PIP_SRC:-$APP_HOME/lib}" \
{%- endif%}
    PATH="{% if cookiecutter.with_pyapp%}$USER_VENV/bin{%endif%}{% if cookiecutter.with_node%}:/$APP_HOME/node_modules/.bin{%endif%}:$USER_HOME/bin:$APP_HOME/sbin:$APP_HOME/bin:$PATH"

# system dependendencies (pkgs, users, etc)
ADD apt*.txt ./
RUN bash -exc ': \
    \
    && : "install packages" \
    && (mkdir ${APP_HOME} || true) \
    && apt-get update -qq \
    && sed -re "/$DEV_DEPENDENCIES_PATTERN/,$ d" apt.txt|grep -vE "^\s*#"|tr "\n" " " | xargs -n1 > ${APP_HOME}/apt.base.txt \
{%- if cookiecutter.with_pyapp %}
    && sed -i -re "s/(python-?)[0-9]\.[0-9]+/\1$PY_VER/g" ${APP_HOME}/apt.base.txt \
{%- endif %}
    && apt-get install -qq -y $(cat ${APP_HOME}/apt.base.txt) \
    && apt-get clean all && apt-get autoclean && rm -rf /var/lib/apt/lists/* \
    && ( mkdir -pv ${APP_HOME}/{sbin,bin} || true ) \
    '
RUN bash -exc ': \
    && : "install users" \
    && if ! ( getent group $USER_GROUP 2>/dev/null );then groupadd -g $USER_GID $USER_GROUP;fi \
    && if ! ( getent passwd $USER_NAME 2>/dev/null );then useradd -s /bin/bash -d $USER_HOME -m -u $USER_UID -g $USER_UID $USER_NAME;fi \
    && mkdir -pv ${APP_HOME}/{sbin,bin} \
{%- if cookiecutter.with_sudo %}
    && echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
{%- endif %}
    && chown ${USER_NAME}:${USER_GROUP} ${APP_HOME} \
    '
###
# ADD HERE CUSTOM THINGS TO ADD TO BASEIMAGE WHICH ARE REQUIRED AT BUILDTIMe
###

FROM base AS appsetup
RUN bash -exc ': \
    && : "install dev packages" \
    && cat apt.txt|grep -vE "^\s*#"|tr "\n" " " | xargs -n1 > ${APP_HOME}/apt.dev.txt \
    && apt-get update -qq \
    && apt-get install -qq -y $(cat ${APP_HOME}/apt.dev.txt) \
    && apt-get clean all && apt-get autoclean && rm -rf /var/lib/apt/lists/* \
    '
WORKDIR $APP_HOME
{%- if cookiecutter.with_node %}

# install node packages
RUN bash -lc "set -ex \
  && if !( echo $NVM_RELEASE|grep -E -q ^latest$ );then NVM_URI=\"$NVM_URI/tags\";fi \
  && curl -sH \"Authorization: token $(echo $GITHUB_PAT|base64 -d)\" \
        \"$NVM_URI/$NVM_RELEASE\"|grep tag_name|cut -d '\"' -f 4 > /tmp/install/node_version \
  && curl -sL $NVM_DLURI/\$(cat /tmp/install/node_version)/install.sh -o /bin/install_nvm.sh \
  && chmod +x /bin/install_nvm.sh \
    "

USER $USER_NAME
ADD --chown=${USER_NAME}:${USER_GROUP} .nvmrc ./
RUN bash -ic '/bin/install_nvm.sh && . .bashrc && set -e && nvm install $(cat .nvmrc)'

# add and install node app
ADD --chown=${USER_NAME}:${USER_GROUP} $PACKAGEJSON_LOCATION/*json ${PACKAGEJSON_LOCATION}/
ADD --chown=${USER_NAME}:${USER_GROUP} package*json ./
RUN bash -ic ': \
    && nvm use && set -e \
    && if !( grep -q '"name"' package-lock.json );then NPM_TARGET=install;fi \
    && npm $NPM_TARGET'
USER root
{%- endif %}
{%- if cookiecutter.with_pyapp %}

# install python app
ADD --chown=${USER_NAME}:${USER_GROUP} lib/ lib/
ADD --chown=${USER_NAME}:${USER_GROUP} src/ src/
ADD --chown=${USER_NAME}:${USER_GROUP} *.py *txt *md *.in ./
ADD --chown=${USER_NAME}:${USER_GROUP} requirements/requirement*txt requirements/
RUN bash -ec ': \
  && : "install pip" \
  && python${PY_VER} <(curl https://bootstrap.pypa.io/get-pip.py) \
  && python${PY_VER} -m pip install virtualenv \
    '
USER $USER_NAME
RUN bash -ec ': \
  && : "install app venv & deps" \
  && python${PY_VER} -m virtualenv --python=python${PY_VER} $USER_VENV \
  && pip install --upgrade pip${PIP_REQ} setuptools${SETUPTOOLS_REQ} \
  && python -m pip install --no-cache -r <( cat $REQUIREMENTS | grep -vE "^\s*#"  ) \
  '
USER root
{%- endif %}
ADD --chown=${USER_NAME}:${USER_GROUP} bin/  bin/
ADD --chown=${USER_NAME}:${USER_GROUP} sys/  sys/

FROM appsetup AS final
###
# ADD HERE CUSTOM BUILD PROJECT SETUP
###
### </ADD>
RUN bash -exc ': \
    && : "fixperms" \
    && while read f;do chown -Rf $USER_NAME $f;done < <( find $USER_HOME $APP_HOME -not -uid ${USER_UID} ) \
    '

FROM base AS runner
RUN --mount=type=bind,from=final,target=/s bash -exc ': \
    && for i in /home/ $APP_HOME/ $USER_HOME/;do rsync -aAH --numeric-ids /s${i} ${i};done \
    '
WORKDIR $APP_HOME
# image will drop privileges itself using gosu at the end of the entrypoint
# run settings
USER ${IMAGE_USER_RUNNER}

###
# ADD HERE CUSTOM RUNTIME PROJECT SETUP
###
### </ADD>

{%- if cookiecutter.with_docker_git %}
ADD --chown=${USER_NAME}:${USER_GROUP} .git .git/
{%- endif %}
CMD []
ENTRYPOINT ["docker-entrypoint.sh"]
