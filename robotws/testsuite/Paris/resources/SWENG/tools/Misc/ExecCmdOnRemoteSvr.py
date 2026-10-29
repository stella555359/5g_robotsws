#!/usr/bin/env python3

import argparse
import sys
import os
import re

from taf.transport.ssh import ssh

'''
Description:
    Parse scripts arguments

Return value :
    The parsed arguments list
'''


def parse_arguments():
    parser = argparse.ArgumentParser(description='Perform SSH command, using proxy or not, on remote server')

    parser.add_argument(
        '-proxyIp',
        required=False,
        help='The proxy IP (optional)')

    parser.add_argument(
        '-proxyLogin',
        required=False,
        help='The proxy login (optional, must be present if proxyIp is provided)')

    parser.add_argument(
        '-proxyPassword',
        required=False,
        help='The proxy password (optional, must be present if proxyIp is provided)')

    parser.add_argument(
        '-destIp',
        required=True,
        help='The destination server IP')

    parser.add_argument(
        '-destLogin',
        required=True,
        help='The destination login')

    parser.add_argument(
        '-destPassword',
        required=True,
        help='The destination password')

    parser.add_argument(
        '-destCmd',
        required=True,
        help='The command to be run on the destination server')

    return parser.parse_args()


def main():

    args = parse_arguments()

    proxyIp = args.proxyIp
    proxyLogin = args.proxyLogin
    proxyPassword = args.proxyPassword
    proxyAlias = None

    destIp = args.destIp
    destLogin = args.destLogin
    destPassword = args.destPassword
    destAlias = "destAlias"

    destCmd = args.destCmd

    csn = ssh()

    if proxyIp is not None:
        proxyAlias = "proxyAlias"
        csn.connect_to(hostname=proxyIp, username=proxyLogin,
                       password=proxyPassword, alias=proxyAlias)

    csn.connect_to(hostname=destIp, username=destLogin,
                   password=destPassword, proxy=proxyAlias, alias=destAlias)

    # output = csn.send_command(command=cmd, connection=destAlias)
    output = csn.execute(command=destCmd, connection=destAlias)

    # print ("output = {}".format(output))


if __name__ == "__main__":
    main()
