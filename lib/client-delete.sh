echo "Deleting client..."

_rt_report_client

rm -f "$CLIENT_CONFIG"

if test "$(find clients -name '*.conf' | wc -l)" = "0"; then
  rm clients/index
fi

wg set "$WG_IFACE" peer "$CLIENT_PUBLIC_KEY" remove
wg-quick save "$WG_IFACE" 2>/dev/null

echo
echo "Deleted client."
