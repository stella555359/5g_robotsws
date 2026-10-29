import subprocess
import requests
import json
import argparse
from robot.api import logger

version_file = '/home/ute/Downloads/VERSIONS_INFORMATION'


def get_SBTS_Candidate_build_version(release, promotion_tag):
    access_key = "mzwMktgLPhlMbaBy9ckoBlJA3vt458S8EeBsOJue"
    URL = "https://wft.int.net.nokia.com:8091/ALL/api/v1/build_branch.json?access_key={access_key}\
    &view[items]={item_num}&view[sorting_field]=created_at&view[sorting_direction]=DESC&view[columns[][id]]=version\
    &view[columns[][id]]=quicktest_status&view[columns[][id]]=quicktest2_status&view[columns[][id]]=test_result_group\
    &view[columns[][element]]=1&view[columns[][id]]=build_reasons&view[columns[][id]]=test_result_group\
    &view[columns[][element]]=3&view[columns[][id]]=delivery_date&view[columns[][id]]=ps_env\
    &view[columns[][id]]=changed_baselines&view[columns[][id]]=promotion_status_td\
    &view[view_filters_attributes[857024566428061]][column]=state_machine_title\
    &view[view_filters_attributes[857024566428061]][operation]=eq_any\
    &view[view_filters_attributes[857024566428061]][value][]=Central\
    &view[view_filters_attributes[857024566428061]][value][]=Imported%20Central\
    &view[view_filters_attributes[857024566428061]][value][]=Central_A1\
    &view[view_filters_attributes[1891286220526]][column]=branch.title\
    &view[view_filters_attributes[1891286220526]][operation]=eq\
    &view[view_filters_attributes[1891286220526]][value][]={release}&\
    ".replace('    ', '').format(access_key=access_key, item_num=20, release=release.upper())
    proxy = {"https": "http://10.158.100.8:8080"}
    result = requests.get(URL, proxies=proxy, verify=False, timeout=90)
    if result.status_code != 200:
        logger.console(URL)
        raise Exception("REQUEST_FAIL")
    BUILD_INFO = []
    logger.console('-'*55)
    for item in result.json()["items"]:
        # REGRESSION build
        if promotion_tag:
            for status_td in item["promotion_status_td"]:
                if status_td["promotion_tag"]["tag"] == promotion_tag.upper():
                    logger.console('QT1 status           :  {}'.format(item['quicktest_status']['state']))
                    logger.console('Not released reasons :  {}'.format(item['build_reasons']))
                    logger.console('PS / ENV             :  {}'.format(item['ps_env'][0]['baseline']))
                    logger.console('Delivery_date        :  {}'.format(item['delivery_date']))
                    BUILD_INFO.append(item["version"])
        # Released_with_restrictions / Released
        else:
            if item['quicktest_status']['state'] in ("released_with_restrictions", "released"):
                logger.console('QT1 status           :  {}'.format(item['quicktest_status']['state']))
                logger.console('Not released reasons :  {}'.format(item['build_reasons']))
                logger.console('PS / ENV             :  {}'.format(item['ps_env'][0]['baseline']))
                logger.console('Delivery_date        :  {}'.format(item['delivery_date']))
                BUILD_INFO.append(item["version"])
                break
    if not BUILD_INFO:
        logger.console(result.json())
        raise Exception("[ERROR] No candidate build")

    selected_build = BUILD_INFO.pop(0)
    return selected_build


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Personal information')
    parser.add_argument('-r', '--release', dest='release', type=str, default='SBTS00',
                        help='release of the candidate, like as SBTS00/SBTS23R2/SBTS23R3/SBTS23R4, default is SBTS00')
    parser.add_argument('-t', '--promotion_tag', dest='promotion_tag', type=str, default='',
                        help="promotion_tag of the candidate package, should be REGRESSION, default is null.")
    parser.add_argument('-b', '--build_name', dest='build_name', type=str, default='', help='specific build name')
    args = parser.parse_args()
    logger.console('release:             {}'.format(args.release))
    logger.console('promotion_tag:       {}'.format(args.promotion_tag))
    logger.console('specific build name: {}'.format(args.build_name))
    assert args.release.upper().startswith('SBTS'), 'release should be SBTS00/SBTS23R2/SBTS23R3/SBTS23R4/SBTS24R1'
    subprocess.Popen('rm -f {}'.format(version_file), stdout=subprocess.PIPE, shell=True)
    # subprocess.Popen('echo isLatest=>> {}'.format(version_file), stdout=subprocess.PIPE, shell=True)
    if args.build_name:
        build_on_wft = args.build_name
    else:
        build_on_wft = get_SBTS_Candidate_build_version(args.release, args.promotion_tag)
    logger.console('-'*55)
    logger.console("SELECTED_BUILD       :  {}\n".format(build_on_wft))
    # link_hz = 'http://sw1.tc.china.nsn-net.net/build/' + build_on_wft + '/' + build_on_wft + '.zip'
    link_hz1 = 'https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/'
    link_espo = 'https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/'
    release_tag = build_on_wft.split('_')[0]
    link_ep = link_espo + release_tag + '/' + build_on_wft + '/' + build_on_wft + '_release_BTSSM_downloadable_A54.zip'
    link_hz = link_hz1 + release_tag + '/' + build_on_wft + '/' + build_on_wft + '_release_BTSSM_downloadable_A54.zip'

    isExist = subprocess.Popen("curl -s -I {}".format(link_hz), stdout=subprocess.PIPE, shell=True)
    link = link_ep if "404 Not Found" in str(isExist.stdout.read()) else link_hz

    package_path = version_file.rsplit('/', 1)[0] + '/' + build_on_wft + '.zip'
    download = subprocess.Popen("wget -t 0 -c --progress=bar {} -O {}".format(link, package_path),
                                stdout=subprocess.PIPE, shell=True)
    logger.console(download.stdout.read())
    ls_result = subprocess.Popen('ls -l {}'.format(package_path), stdout=subprocess.PIPE, shell=True)
    isdownload = ls_result.stdout.read()
    assert build_on_wft in str(isdownload), '[ERROR] Failed to download! {}'.format(isdownload)
    assert int(isdownload.split()[4]) > 8888888888, '[ERROR] Download build size = {}'.format(isdownload.split()[4])
    isLatest = 'Trunk' if args.release.upper() == 'SBTS00' else 'Branch'
    print(subprocess.Popen('echo build=%s> %s' % (build_on_wft, version_file), stdout=subprocess.PIPE, shell=True))
    print(subprocess.Popen('echo isLatest=%s>> %s' % (isLatest, version_file), stdout=subprocess.PIPE, shell=True))
