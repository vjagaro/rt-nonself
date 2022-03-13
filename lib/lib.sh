_rt_apt_installed() {
  dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q ' installed'
}

_rt_apt_ensure() {
  local pkg
  for pkg in "$@"; do
    _rt_apt_installed "$pkg" ||
      DEBIAN_FRONTEND=noninteractive _rt_indent apt-get install -qqy "$pkg"
  done
}

_rt_indent() {
  {
    "$@" 2>&1 1>&3 |
      sed -u 's/^\(.*\)/  \x1b[31m\1\x1b[0m/'
  } 3>&1 1>&2 |
    sed -u 's/^\(.*\)/  \x1b[37m\1\x1b[0m/'
}

_rt_client_find() {
  local n="$(echo "$1" | sed 's|^\(.*/\)\?\([0-9]\+\).*$|\2|')"
  if [ -n "$n" ]; then
    conf="$(ls -1 "clients/$n-"*".conf" 2>/dev/null | head -1)"
  else
    conf=""
  fi
  echo "$conf"
}

_rt_load_conf() {
  if ! test -f rt.conf; then
    echo >&2 "ERROR: rt.conf not found."
    exit 1
  fi
  chmod 600 rt.conf
  source rt.conf
}

_rt_require_client_config() {
  local arg="$1"
  CLIENT_CONFIG="$(_rt_client_find "$arg")"
  if [ -z "$CLIENT_CONFIG" ]; then
    echo >&2 "ERROR: Client $arg not found."
    echo >&2
    echo >&2 "To see available clients, try: $0 client list"
    exit 1
  fi
}

_rt_require_root() {
  if test "$(id -u)" -ne "0"; then
    echo >&2 "ERROR: Must run as root."
    exit 1
  fi
}
