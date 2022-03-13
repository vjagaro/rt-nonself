echo "Client configs:"

shopt -s nullglob
for config in clients/*.conf; do
  echo "  $config:"
  echo -n "    public key:  "
  grep "^PrivateKey = " "$config" | sed 's/.* = //' | wg pubkey
  echo -n "    allowed ips: "
  grep "^Address = " "$config" | sed 's/.* = //'
done

echo "Wireguard peers:"

wg | tail -n +6 | grep -v '^$' | sed 's/^/  /g'
