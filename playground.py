#!/usr/local/bin/python

# cloud testing (you must have a picloud.com account AND set
# cloudconf.py correctly for any of this to work)

import cloud; import os;
jid = cloud.call(os.system, "curl http://pi.barrycarter.info/")
print cloud.result(jid)

# in my logs:

# 184.73.142.136 pi.barrycarter.info - [25/Oct/2011:11:44:35 -0600] "GET / HTTP/1.1" 200 94 "-" "curl/7.21.0 (x86_64-pc-linux-gnu) libcurl/7.21.0 OpenSSL/0.9.8o zlib/1.2.3.4 libidn/1.18"
