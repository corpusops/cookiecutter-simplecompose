#ode!/usr/bin/env bash
# entrypoint is called either by
# $0 shell
# $0 without args, $START_COMMAND is sued
# $0 with args, args are used in shell command
#
set -e
[[ ! -e flags ]] && mkdir /flags;rm -f /flags/.started
{%- if cookiecutter.with_pyapp %}
PYTHON=${PYTHON-python}
NO_PIP_INSTALL=${NO_PIP_INSTALL-}
PIP_DEVELOP_ARGS="${PIP_DEVELOP_ARGS:---no-deps --no-cache}"
REQUIREMENTS="${REQUIREMENTS:-requirements/requirements.txt}"
VERBOSE_PIP_INSTALL=${VERBOSE_PIP_INSTALL-}
{%- endif %}
{%- if cookiecutter.with_node %}
NO_NVM_INSTALL=${NO_NVM_INSTALL-1}
VERBOSE_NVM_INSTALL=${VERBOSE_NVM_INSTALL-}
{%- endif %}
START_COMMAND="${START_COMMAND:-"sh -c 'while true;do sleep  65535;done'"}"
USER_NAME=${USER_NAME:-$(ls -1 /home|head -n1)}
USER_GROUP=${USER_NAME:-${USER_NAME}-group}
APP_HOME="${APP_HOME:-/w}"
USER_HOME="$(getent passwd $USER_NAME| cut -d: -f6)"
USER_OLD_UID="$(getent passwd $USER_NAME| cut -d: -f3)"
USER_OLD_GID="$(getent passwd $USER_NAME| cut -d: -f4)"
export NO_ALL_FIXPERMS=${NO_ALL_FIXPERMS-}
export NO_FIXPERMS=${NO_FIXPERMS-}
SHELL=${SHELL:-bash}
SHELL_USER=${SHELL_USER:-$USER_NAME}
SHELL_WRAP=${SHELL_WRAP-}
FILES_EXTRA_DIRS="${FILES_EXTRA_DIRS:-}"
FILES_DIRS="${FILES_DIRS:-"$USER_HOME $FILES_EXTRA_DIRS"}"
USER_DIRS="${USER_DIRS:-"$USER_HOME $APP_HOME"}"
VERBOSE=""
SHELLVERBOSE=
if [[ -n $SDEBUG ]];then set -x;VERBOSE="v";SHELLVERBOSE="x";fi
INIT_HOOKS_DIR=${INIT_HOOKS_DIR:-${USER_HOME}/bin}
NO_CREATE_USER_DIRS=${NO_CREATE_USER_DIRS-}
log() { echo "$@" >&2; }
debuglog() { if [[ -n "$DEBUG" ]];then echo "$@" >&2;fi; }
die() { log "$@";exit 1; }
vv() { log "$@";"$@"; }
execute_hooks() {
    local step="$1"
    local hdir="$INIT_HOOKS_DIR/${step}"
    if [ ! -d "$hdir" ];then return 0;fi
    shift
    while read f;do
        if ( echo "$f" | grep -E -q "\.sh$" );then
            debuglog "running shell hook($step): $f"
            . "${f}"
        else
            debuglog "running executable hook($step): $f"
            "$f" "$@"
        fi
    done < <(find "$hdir" -type f -executable 2>/dev/null | grep -E -iv readme | sort -V; )
}
# export back the gateway ip as a host if ip is available in container
if ( ip -4 route list match 0/0 &>/dev/null );then
    ip -4 route list match 0/0 \
        | awk '{print $3" host.docker.internal"}' >> /etc/hosts
fi

cd "${APP_HOME}"
execute_hooks pre $@
if [[ -z $USER_UID ]] || [[ -z $USER_GID ]];then
    die 'set $USER_UID / $USER_GID'
fi
if [[ "${USER_OLD_UID}::${USER_OLD_GID}" != "${USER_UID}::${USER_GID}" ]];then
    if !(getent group $USER_GID &>/dev/null );then
        groupadd="groupmod"
        if !(getent group $USER_GROUP &>/dev/null);then groupadd="groupadd";fi
        $groupadd -g $USER_GID $USER_GROUP
    fi
    usermod -o -g $USER_GID -u $USER_UID $USER_NAME
    NO_TRANSFER=
else
    NO_TRANSFER=1
fi
NO_TRANSFER=
NO_FIXPERMS=
if [[ -z ${NO_CREATE_USER_DIRS} ]];then
    for i in $FILES_DIRS;do
        if [ ! -e $i ];then mkdir -p${VERBOSE} "$i";fi
    done
fi
if [[ -z ${NO_ALL_FIXPERMS} ]];then
    if [[ -z "$NO_TRANSFER" ]];then
        while read f;do chown -f${VERBOSE} $USER_UID:$USER_GID "$f";ls -dl $f;exit 1;done < \
            <( find $USER_DIRS \( -uid $USER_OLD_UID -or -gid $USER_OLD_GID \) \
                -and -not -uid $USER_UID )
    fi
    if [[ -z ${NO_FIXPERMS} ]];then
        while read f;do chown -f${VERBOSE} $USER_UID:$USER_GID "$f";done < \
            <( find $FILES_DIRS -not -uid $USER_UID )
    fi
fi
{%- if cookiecutter.with_node %}

nvminstall() {
    NPM_TARGET=ci
    if !( grep -q '"name"' package-lock.json );then NPM_TARGET=install;fi
    cmd="( nvm use $(cat .nvmrc) && npm $NPM_TARGET )"
    if [[ -z ${VERBOSE_NVM_INSTALL} ]];then
        cmd="$cmd &>/dev/null"
    fi
    gosu $SHELL_USER bash -lic "$cmd"
}
if [[ -z "$NO_NVM_INSTALL" ]];then
    if [[ -n $VERBOSE_NVM_INSTALL ]];then
        log "Reinstalling node modules"
    fi
    if !(nvminstall);then VERBOSE_NVM_INSTALL="1" nvminstall;fi
fi
{%- endif %}
{%- if cookiecutter.with_pyapp %}
# only reinstall editable requirements
pipinstall() {
    end=""
    if [[ -z ${VERBOSE_PIP_INSTALL} ]];then
        end="&>/dev/null"
    fi
    eval "vv ${PYTHON} -m \
        pip install $PIP_DEVELOP_ARGS -r <( grep -E "^-e" $REQUIREMENTS ) $end"
}
if [[ -z $NO_PIP_INSTALL ]] && ( for i in $REQUIREMENTS;do \
    if [ -e $i ] && ( grep -E -q -- ^-e $i; );then exit 0;fi;done; \
        exit 1; );then
    if [[ -n $VERBOSE_PIP_INSTALL ]];then
        log "Reinstalling $REQUIREMENTS editable dependencies"
    fi
    if !(pipinstall);then VERBOSE_PIP_INSTALL="1" pipinstall;fi
fi
{%- endif %}

execute_hooks post $@

touch /flags/.started
if ( echo "$@" | grep -E -q "^shell$" );then set -- $SHELL;fi
if ( echo "$@" | grep -E -q '^(/[^ /]+/)+/?((z|ba|a)?sh)$' );then
    SHELL_WRAP=
fi
if [[ -z $@ ]];then
    exec gosu $SHELL_USER $SHELL -${SHELLVERBOSE}lic "$START_COMMAND"
else
    exec gosu $SHELL_USER $( [[ -n $SHELL_WRAP ]] && echo "$SHELL -${SHELLVERBOSE}liec" ) "$@"
fi
# vim:set et sts=4 ts=4 tw=0:
