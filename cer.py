# install_certifi.py
#
# sample script to install or update a set of default Root Certificates
# for the ssl module.  Uses the certificates provided by the certifi package:
#       https://pypi.python.org/pypi/certifi

import os
import os.path
import ssl
import stat
import subprocess
import sys

STAT_0o775 = ( stat.S_IRUSR | stat.S_IWUSR | stat.S_IXUSR
             | stat.S_IRGRP | stat.S_IWGRP | stat.S_IXGRP
             | stat.S_IROTH |                stat.S_IXOTH )


res =[]
def testHamNe(index):
    anotherList = []
    a = 10
    for x in range(0, index):
        anotherList.append(x);
    return a, anotherList

k,res = testHamNe(5);
for x in res:
    print(x)

x,res = testHamNe(10);
for x in res:
    print(x)