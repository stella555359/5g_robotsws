#!/usr/bin/env python3
import sys
import json


def main(argv):
    with open(argv[1], 'r') as f:
        data = json.load(f)
    l2lo_info = sorted(data['l2resource']['l2loList']
                       ['l2loInfo'], key=lambda v: v['l2loPoolId'])
    print(json.dumps(l2lo_info, indent=4))


if __name__ == '__main__':
    main(sys.argv)
