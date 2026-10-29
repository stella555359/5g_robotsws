from bcolors import bcolors
from robot.libraries.BuiltIn import BuiltIn

import json
import requests


rf_built_in = BuiltIn()
wft_token = '0Q0pCnoXyoTweJZccVvHYBVxEP887y25bBncQJIK'
default_promotion_tags = [
    'RAN_5G_CIT', 'RAN_5G_CRT', 'RAN_5G_MP_CIT', 'RAN_5G_MP_CRT', 'RAN_5GSC_CIT', 'RAN_5GSC_CRT', 'RAN_5GSC_MP_CIT',
    'RAN_5GSC_MP_CRT', 'RAN_5G_TDD_CIT', 'RAN_5G_TDD_CRT', 'RAN_5G_TDD_MP_CIT', 'RAN_5G_TDD_MP_CRT']


def _log(message, console=True):
    rf_built_in.log(message='\n'+message, console=console)


def today_builds(view=6829, page=1, promotion_tag=None, access_key=wft_token, output='dict', build_filter=''):
    _log(bcolors.INFO_MSG+'Getting builds from WFT...')
    wft_url = 'https://wft.int.net.nokia.com:8091/api/v1/view/{}.json?view[page]={}&access_key={}'.format(
            view, page, access_key)
    req = requests.get(wft_url)
    wft_json = json.loads(req.text)

    if promotion_tag is None:
        promotion_tag = default_promotion_tags

    builds = []
    for tag_name, tag_contents in wft_json['items'].items():
        if tag_name in promotion_tag:
            for build in tag_contents:
                if build_filter in build['build.baseline']:
                    builds.append(build['build.baseline'])

    _log(bcolors.INFO_MSG + 'Found Builds ' + (','.join(builds)))
    if output == 'csv':
        return ','.join(builds)
    return builds


if __name__ == '__main__':
    import argparse

    arg = argparse.ArgumentParser(description="Get list of today's promoted loads",
                                  formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    arg.add_argument('-v', '--view', default='6829',
                     help='Custom view id.\
                     Must be generated from https://wft.int.net.nokia.com/ALL/toolbox/db_queries/Promotion')
    arg.add_argument('-p', '--page', default='1', choices=[1, 2, 3], help='Page on the generated view.')
    arg.add_argument('-t', '--promotion_tag', nargs='+', choices=default_promotion_tags,
                     help='Promotion tag: Ex: RAN_5G_CIT')
    arg.add_argument('-k', '--key', default=wft_token,
                     help='Access key needed by the WFT API.\
                     Generated from https://wft.int.net.nokia.com/profile#tab_user=3')
    arg.add_argument('-o', '--output', default='dict', choices=['csv', 'dict'],
                     help='Output format. Csv string, or dict object')
    arg.add_argument('-f', '--build_filter', default='SBTS',
                     help='Filter for load')

    args = vars(arg.parse_args())
    today_builds = today_builds(view=args['view'], page=args['page'], promotion_tag=args['promotion_tag'],
                                access_key=args['key'], output=args['output'], build_filter=args['build_filter'])
