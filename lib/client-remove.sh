echo "Removing client $CLIENT_CONFIG..."

PRIVATE_KEY="$(cat "$CLIENT_CONFIG" | grep '^PrivateKey =' |
  sed 's/PrivateKey = //')"
PUBLIC_KEY="$(echo "$PRIVATE_KEY" | wg pubkey)"

echo "Client has public key $PUBLIC_KEY..."

wg set "$WG_IFACE" peer "$PUBLIC_KEY" remove
wg-quick save "$WG_IFACE" 2>/dev/null

echo "Removed peer $PUBLIC_KEY."

rm -f "$CLIENT_CONFIG"

if test "$(find clients -name '*.conf' | wc -l)" = "0"; then
  rm clients/index
fi

echo "Removed client $CLIENT_CONFIG."
