output=$(DBUS_SESSION_BUS_ADDRESS= eduvpn-cli status 2>&1 > /dev/null | tail -n +2)

if [ "$output" = "You are currently not connected to a server" ]; then
	echo "not connected"
else
	echo "connected"
fi
