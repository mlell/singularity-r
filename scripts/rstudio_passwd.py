#!/usr/bin/env python3

import argparse
import sys
from getpass import getpass
from crypt import crypt

DEBUG = False # set to True to show stack trace
if DEBUG: import traceback

class StreamHandler:
  "Context manager that closes a stream if it is not one of the standard streams"
  def __init__(self, stream):
    self.s = stream
  def __enter__(self):
    pass
  def __exit__(self, type, value, traceback):
    if not any(self.s is x for x in [sys.stdin, sys.stdout, sys.stderr]):
      self.s.close()


def parse_args(argv):
  p = argparse.ArgumentParser(
    description = "Set the RStudio Server access password")
  p.add_argument("-o", type = str, default = ".rstudio-passwd", help =
    """Output file to save the hashed password to. Default: ./.rstudio-passwd.
    '-o -' writes the hash to standard output""")
  a = p.parse_args(argv)
  return(a)

def main(argv):
  args = parse_args(argv[1:])
  outfile = open(args.o, "w") if args.o != "-" else sys.stdout
  pw = getpass()
  with StreamHandler(outfile):
    print(crypt(pw), file = outfile)
  if outfile is not sys.stdout:
    print(f"Password has been written to {args.o}")

if __name__ == "__main__":
  try:
    sys.exit(main(sys.argv))
  except Exception as e:
    print(e, file = sys.stderr)
    if DEBUG:
      print(traceback.format_exc(), file = sys.stderr)
    sys.exit(1)
