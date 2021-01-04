#!/usr/bin/env fish

# Script to update a CloudFlare DNS A record with the IP address of the host
# 
# The cfdyndns and ddclient seem to authenticate via email and global API key,
# which seems way too permissive for a dynamic DNS client, so I'm writing my own
# script that just uses a simple API token with two permissions.
# The script uses fish, which has a saner scripting language.
#
# See also: https://nickperanzi.com/blog/cloudflare-ddns-with-token/

# Authorization is done via an API token with the Zone/DNS/Edit and Zone/Zone/Read
# permissions, which is read from the CLOUDFLARE_API_TOKEN environment variable.
#
# Set CLOUDFLARE_RECORD to the hostname of the record to be updated
# and CLOUDFLARE_ZONEID to the zone ID provided by CloudFlare (see the API section in
# your website's overview in the CloudFlare dashboard).

if not set -q CLOUDFLARE_API_TOKEN
    echo "FATAL: Environment variable CLOUDFLARE_API_TOKEN not set."
    exit 1
end

if not set -q CLOUDFLARE_RECORD
    echo "FATAL: Environment variable CLOUDFLARE_RECORD not set."
    exit 1
end

if not set -q CLOUDFLARE_ZONEID
    echo "FATAL: Environment variable CLOUDFLARE_ZONEID not set."
    exit 1
end

set api_url "https://api.cloudflare.com/client/v4"
set auth_header "Authorization: Bearer "$CLOUDFLARE_API_TOKEN

# Set $ip to the current IP address
set ip (curl -s https://ifconfig.me)

# Get DNS record identifier
set get_cfdnsrec (curl -s -X GET $api_url"/zones/"$CLOUDFLARE_ZONEID"/dns_records?name="$CLOUDFLARE_RECORD \
   -H $auth_header \
   -H "Content-Type: application/json")

# Check that we got exactly one A record
if [ (echo $get_cfdnsrec | jq .success) = "false" ]
    echo "ERROR: Couldn't get DNS record. Resulting JSON: "$get_cfdnsrec
    echo "Make sure your API token is valid."
    exit 2
end
set num_cfdnsrec (echo $get_cfdnsrec | jq '.result[] | select(.type == "A") | .id' | wc -l)
if [ ! $num_cfdnsrec -eq 1 ]
    echo "ERROR: Expected to get exactly one DNS A record, got "$num_cfdnsrec" instead."
    echo "Check your record name ("$CLOUDFLARE_RECORD") and DNS configuration in CloudFlare."
    exit 3
end

# At this point, we have exactly one DNS record we can use, so PUT the new IP address 
# into that record.
set dns_recordid (echo $get_cfdnsrec | jq -r '.result[] | select(.type == "A") | .id')

# Update the DNS record!
set put_json '{"type":"A","name":"'$CLOUDFLARE_RECORD'","content":"'$ip'","ttl":1}'
set put_cfdnsrec (curl -s -X PUT $api_url"/zones/"$CLOUDFLARE_ZONEID"/dns_records/"$dns_recordid \
    -H $auth_header \
    -H "Content-Type: application/json" --data $put_json)

if [ (echo $put_cfdnsrec | jq .success) = "false" ]
    echo "ERROR: Couldn't set DNS record. Resulting JSON: "$get_cfdnsrec
    exit 4
end

# At this point, the script succeeded
echo "Sent updated IP ("$ip")."
