echo "Updating client..."

_rt_report_client

wg set "$WG_IFACE" peer "$CLIENT_PUBLIC_KEY" allowed-ips "$CLIENT_ADDRESS"
wg-quick save "$WG_IFACE" 2>/dev/null

echo
echo "Updated peer."
