#!/bin/bash
set -e
cache_file=/tmp/dn42_roa_bird2_46.conf
roa_file="dn42_roa_$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr ':' '-').conf"
as_set="$1"

exec &> >(tee $roa_file)

if command -v rg &> /dev/null; then
    search_tool="rg --color=never --no-line-number"
else
    search_tool="grep -s"
fi
# Cache: 1h
if [[ ! -f "$cache_file" ]] || [[ $(find "$cache_file" -mmin +60 2>/dev/null) ]]; then
    echo "# Updating cache..."
    curl -q -s -o "$cache_file" https://dn42.burble.com/roa/dn42_roa_bird2_46.conf || {
        echo "# Error downloading dn42_roa_bird2_46.conf" >&2
        return 1
    }
fi

cat <<EOF
#
# liuzhen932 DN42 ROA Generator
# Last Updated: $(date -u '+%Y-%m-%d %H:%M:%S.%N %z')
# AS-SET: $as_set
#
EOF

whois $as_set | awk '/^members:/{match($0,/AS[0-9]+/); print substr($0,RSTART+2,RLENGTH-2)}' | while read -r asn; do
    $search_tool "$asn" $cache_file
done
