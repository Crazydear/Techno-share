ble File  12 lines (9 sloc)  300 Bytes
  
#!/bin/sh
#

# Import ardnspod functions
. /your_real_path/ardnspod

# Combine your token ID and token together as follows
arToken="12345,7676f344eaeaea9074c123451234512d"

# Place each domain you want to check as follows
# you can have multiple arDdnsCheck blocks
arDdnsCheck "test.org" "subdomain"
