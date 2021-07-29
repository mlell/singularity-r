#!/usr/bin/env python3
import os
import sys
from crypt import crypt
import hmac
from getpass import getpass

def msg(str): print(msg, file = sys.stderr)

if len(sys.argv) < 1:
  msg("Usage: auth USERNAME")
  sys.exit(2)

pwfile = os.environ["RSTUDIO_PASSWORD_FILE"]
if pwfile == None:
  msg("Variable RSTUDIO_PASSWORD_FILE is not set")
  sys.exit(3)

with open(pwfile) as f:
  pw = f.readline().strip("\n")

testpw = sys.stdin.readline().strip("\n")
cpw = crypt(testpw, pw)
correct = hmac.compare_digest(cpw, pw)

if correct:
  sys.exit(0)
else:
  sys.exit(1)
