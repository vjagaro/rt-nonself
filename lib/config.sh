_rt_apt_ensure wireguard

if ! test -f rt.conf; then
  echo "Creating rt.conf..."
  cp rt.conf.example rt.conf
  chmod 600 rt.conf
  perl -pi -e "s|^(WG_PRIVATE_KEY=).*|\${1}\"$(wg genkey)\"|" rt.conf
fi
