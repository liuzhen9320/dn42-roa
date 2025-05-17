#!/bin/bash
set -e
cache_file_v4=/tmp/dn42_roa_bird2_4.conf
cache_file_v6=/tmp/dn42_roa_bird2_6.conf
roa_file_v4="dn42_roa_$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr ':' '-')_4.conf"
roa_file_v6="dn42_roa_$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr ':' '-')_6.conf"
as_set="$1"

if command -v rg &> /dev/null; then
    search_tool="rg --color=never --no-line-number"
else
    search_tool="grep -s"
fi
# Cache: 1h
if [[ ! -f "$cache_file" ]] || [[ $(find "$cache_file" -mmin +60 2>/dev/null) ]]; then
    echo "# Updating cache..."
    curl -q -s -o "$cache_file_v4" https://dn42.burble.com/roa/dn42_roa_bird2_4.conf || {
        echo "# Error downloading dn42_roa_bird2_4.conf" >&2
        return 1
    }
    curl -q -s -o "$cache_file_v6" https://dn42.burble.com/roa/dn42_roa_bird2_6.conf || {
        echo "# Error downloading dn42_roa_bird2_6.conf" >&2
        return 1
    }
fi

cat < EOF > $roa_file_v4
#
# liuzhen932 DN42 ROA Generator - IPv4
# Last Updated: $(date -u '+%Y-%m-%d %H:%M:%S.%N %z')
# AS-SET: $as_set
#
EOF

cat < EOF > $roa_file_v6
#
# liuzhen932 DN42 ROA Generator - IPv6
# Last Updated: $(date -u '+%Y-%m-%d %H:%M:%S.%N %z')
# AS-SET: $as_set
#
EOF

whois $as_set | awk '/^members:/{match($0,/AS[0-9]+/); print substr($0,RSTART+2,RLENGTH-2)}' | while read -r asn; do
    $search_tool "$asn" $cache_file_v4 >> $roa_file_v4
done

whois $as_set | awk '/^members:/{match($0,/AS[0-9]+/); print substr($0,RSTART+2,RLENGTH-2)}' | while read -r asn; do
    $search_tool "$asn" $cache_file_v6 >> $roa_file_v6
done
