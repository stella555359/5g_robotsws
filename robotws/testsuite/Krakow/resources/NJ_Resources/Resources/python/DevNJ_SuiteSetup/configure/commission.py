import json
import os
import re

try:
    from functools import reduce
except Exception as e:
    pass
try:
    import urllib.request
except Exception as e:
    import urllib
from robot.api import logger
# from robot.libraries.BuiltIn import BuiltIn
from bs4 import BeautifulSoup
from taf.transport.ssh import ssh
from .server import PKG_LOCAL_ROOTPATH, URL_5G_Commission


def get_testline_name(hostname, username, password, port, connection="testline_name"):
    ssh_manager = ssh()
    try:
        ssh_manager.connect_to(hostname=hostname, username=username, password=password, port=port,
                               alias=connection)
        ssh_manager.send_command(command="hostname", connection=connection)
        result = ssh_manager.read_output(connection=connection)
        result = str(result).replace(r"-", "_")
        return result
    except Exception:
        raise Exception("Cant connect to host: {} with username: {} and password: {} and port: {}".format(hostname,
                                                                                                          username,
                                                                                                          password,
                                                                                                          port))
    finally:
        ssh_manager.disconnect(connection=connection)


def get_full_commission_dir(local_dir=PKG_LOCAL_ROOTPATH):
    if not os.path.exists(local_dir):
        os.makedirs(local_dir)
    logger.info('local_commission_path={}'.format(local_dir), also_console=True)
    return local_dir


def _get_info_from_5g_commission_webpage(url, content):
    try:
        commission_5g_response = urllib.urlopen(url).read()
    except Exception as e:
        commission_5g_response = urllib.request.urlopen(url).read()

    if '_21_' in content and '.xml' not in content:
        # Aims to find the first testline under the same testline type in case of dont have this testline info
        testline_selection = BeautifulSoup(commission_5g_response, features="lxml")
        try:
            content = testline_selection.find(href=re.compile(content)).get_text()
        except Exception as e:
            if "has no attribute 'get_text'" in str(e):
                logger.info('Dont have content: {} in url: {}'.format(content, url), also_console=True)
        logger.info('Get testline {} info from {}'.format(content, url), also_console=True)
        logger.info('================================', also_console=True)

    url_subpage = url + '/' + content
    logger.info('{}_url={}'.format(content, url_subpage), also_console=True)
    logger.info('================================', also_console=True)

    decode_resp = commission_5g_response.decode(encoding="utf-8") if type(commission_5g_response) is bytes \
        else commission_5g_response

    if str(content) not in decode_resp:
        assert False, 'Cant find {} in {}'.format(content, url)
    return url_subpage


def get_configure_json_file(local_build_dir):
    logger.info('============Enter search and download commission file process====================', also_console=True)
    commission_type_url = _get_info_from_5g_commission_webpage(URL_5G_Commission, 'commission_type.json')
    commission_type_json_path = os.path.join(local_build_dir, 'commission_type.json')
    os.system("curl {} -o {}".format(commission_type_url, commission_type_json_path))
    logger.info('local_commission_type_json_path={}'.format(commission_type_json_path), also_console=True)
    logger.info('================================', also_console=True)

    testline_url = _get_info_from_5g_commission_webpage(URL_5G_Commission, 'testline.json')
    testline_json_path = os.path.join(local_build_dir, 'testline.json')
    os.system("curl {} -o {}".format(testline_url, testline_json_path))
    logger.info('local_testline_json_path={}'.format(testline_json_path), also_console=True)
    logger.info('================================', also_console=True)

    assert (os.path.exists(testline_json_path) or os.path.exists(testline_json_path)), \
        'Download commission_type.json or testline.json failed'
    return commission_type_json_path, testline_json_path


def get_testline_configuration_info_from_testline_json_file(testline_json_path, testline):
    testline_configuration_list = []
    testline_json_file = open(testline_json_path, "r")
    testline_info = json.load(testline_json_file)

    # assert (testline in testline_info.keys()), \
    #     "{} don't include this testline info, please config it firstly!".format(testline_json_path)

    if testline not in testline_info.keys():
        raise Exception("{} don't include this testline info, please config it firstly!".format(testline_json_path))
    for key in list(testline_info[testline]):
        if not testline_info[testline].get(key):
            del testline_info[testline][key]
        if "commission_type" in testline_info[testline].keys() and testline_info[testline]["commission_type"]:
            commission_type_number = testline_info[testline]["commission_type"]
            del testline_info[testline]["commission_type"]
        if "commission_sub_type" in testline_info[testline].keys() and testline_info[testline]["commission_sub_type"]:
            commission_sub_type = testline_info[testline]["commission_sub_type"]
            del testline_info[testline]["commission_sub_type"]
        if "mrbtsId" in testline_info[testline].keys() and testline_info[testline]["mrbtsId"]:
            mrbtsId = testline_info[testline]["mrbtsId"]
            del testline_info[testline]["mrbtsId"]

        for key in list(testline_info[testline]):
            MO_obj = key + testline_info[testline][key]
            testline_configuration_list.append(MO_obj)
        logger.info('Get commission_type_number={}, and subtype={} from testline.json'.
                    format(commission_type_number, commission_sub_type), also_console=True)
        logger.info('================================', also_console=True)
        return mrbtsId, commission_type_number, commission_sub_type, testline_configuration_list


def get_testline_type_from_commission_type_json(commission_type_json_path, commission_type_number):
    testline_type = ""

    assert (os.path.isfile(commission_type_json_path)), "{} file dont exist, please add it firstly to 5g-commission". \
        format(commission_type_json_path)

    testline_type_file = open(commission_type_json_path, "r")
    all_testline_type_info = json.load(testline_type_file)
    if commission_type_number in all_testline_type_info.keys():
        testline_type = all_testline_type_info[commission_type_number]

    assert testline_type, "Dont have this tl type in file {}, please add it firstly".format(commission_type_json_path)
    logger.info('Get testline type = {} from commission_type.json'.format(testline_type), also_console=True)
    logger.info('================================', also_console=True)

    return testline_type


def get_gnb_and_asir_commission_path(local_dir, testline_name, sw_build_info, subtype, testline_type=None):
    assert local_dir, "{} dont exist".format(local_dir)
    gnb_commission_list = []
    asir_commission_list = []
    local_gnb_commission_path = ''
    local_asir_commission_path = ''

    if testline_type:
        logger.info("Get testline commission with commission type solution", also_console=True)
        sw_build_path = reduce(_get_info_from_5g_commission_webpage,
                               [URL_5G_Commission, testline_type, testline_name, sw_build_info])
    else:
        logger.info("Get testline commission directly from testline dir", also_console=True)
        sw_build_path = reduce(_get_info_from_5g_commission_webpage,
                               [URL_5G_Commission, testline_name, sw_build_info])

    try:
        sw_build_path_response = urllib.urlopen(sw_build_path).read()
    except Exception as e:
        sw_build_path_response = urllib.request.urlopen(sw_build_path).read()

    bs_xml = BeautifulSoup(sw_build_path_response, features="lxml")

    for ele in bs_xml.findAll(href=re.compile("7_21_*")):
        if ('enb' in ele.get_text() or 'gnb' in ele.get_text()) and 'asirmgr' not in ele.get_text():
            gnb_commission_list.append(ele.get_text())
        else:
            asir_commission_list.append(ele.get_text())

    logger.info('gnb_commission_list={}, asir_commission_list={}'.
                format(gnb_commission_list, asir_commission_list), also_console=True)
    logger.info('================================', also_console=True)

    if len(gnb_commission_list) < 1:
        logger.info('Get commission failed for testline:{}'.format(testline_name), also_console=True)
        return
    elif len(gnb_commission_list) == 1:
        logger.info('Only one macro commission for testline:{}, so use it'.format(testline_name),
                    also_console=True)
        local_gnb_commission_tmp = gnb_commission_list[0]
    else:
        logger.info('Have more then one macro commission for testline:{}, so get it according to subtype: {}'.
                    format(testline_name, subtype),
                    also_console=True)
        for gnb_commission in gnb_commission_list:
            if subtype in gnb_commission:
                local_gnb_commission_tmp = gnb_commission
                break
    gnb_commission_url = _get_info_from_5g_commission_webpage(sw_build_path, local_gnb_commission_tmp)
    local_gnb_commission_path = os.path.join(local_dir, local_gnb_commission_tmp)
    os.system("curl {} -o {}".format(gnb_commission_url, local_gnb_commission_path))
    assert (os.path.exists(local_gnb_commission_path)), 'curl failed from {}'.format(gnb_commission_url)

    local_asir_commission_tmp = None
    if len(asir_commission_list) < 1:
        logger.info('Get asir commission failed for testline:{}'.format(testline_name), also_console=True)
    elif len(asir_commission_list) == 1:
        logger.info('Only one asir commission for testline:{}, so use it'.format(testline_name),
                    also_console=True)
        local_asir_commission_tmp = asir_commission_list[0]
    else:
        logger.info('Have more then one asir commission for testline:{}, so get it according to subtype: {}'.
                    format(testline_name, subtype),
                    also_console=True)
        for asir_commission in asir_commission_list:
            if subtype in asir_commission:
                local_asir_commission_tmp = asir_commission
                break
    if local_asir_commission_tmp:
        asir_commission_url = _get_info_from_5g_commission_webpage(sw_build_path, local_asir_commission_tmp)
        local_asir_commission_path = os.path.join(local_dir, local_asir_commission_tmp)
        os.system("curl {} -o {}".format(asir_commission_url, local_asir_commission_path))
        assert (os.path.exists(local_asir_commission_path)), 'curl failed from {}'. \
            format(local_asir_commission_path)

    logger.info('local_gnb_commission_path={}, local_asir_commission_path={}'.
                format(local_gnb_commission_path, local_asir_commission_path), also_console=True)
    logger.info('===============End of download commission file process===========================', also_console=True)
    return local_gnb_commission_path, local_asir_commission_path


def get_swconfig_template_path(local_dir, release):
    swconfig_list = []
    swconfig_release = "swconfig.txt"

    try:
        swconfig_response = urllib.urlopen(URL_5G_Commission).read()
    except Exception as e:
        swconfig_response = urllib.request.urlopen(URL_5G_Commission).read()
    swconfig_xml = BeautifulSoup(swconfig_response, features="lxml")
    for ele in swconfig_xml.findAll(href=re.compile("swconfig*")):
        if 'swconfig' in ele.get_text():
            swconfig_list.append(ele.get_text())
    for swconfig in swconfig_list:
        if release in swconfig:
            swconfig_release = swconfig

    os.system("curl {}/{} -o {}".
              format(URL_5G_Commission, swconfig_release, os.path.join(local_dir, swconfig_release)))
    logger.info('Download {} from {}'.format(swconfig_release, URL_5G_Commission), also_console=True)
    return os.path.join(local_dir, swconfig_release)


if __name__ == "__main__":
    # local_dir = get_full_commission_dir()
    # testline_name = get_testline_name()
    # commission_type_json_path, testline_json_path = get_configure_json_file(local_dir)
    # mrbtsId, commission_type_number, commission_sub_type, testline_configuration_list = \
    #     get_testline_configuration_info_from_testline_json_file(testline_json_path, '7_21_CLOUD018TL028')
    # testline_type = get_testline_type_from_commission_type_json(commission_type_json_path, commission_type_number)
    # gnb_commission_path, asir_commission_path = \
    #     get_gnb_and_asir_commission_path('/home/ute/pkgload', '7_21_UTE5G036TL342',
    #                                      'SBTS00_ENB_9999_221128_000007', subtype='4T4R')
    # swconfig_path = get_swconfig_template_path(local_dir, '21A')
    # change_gnb_commission_btsid_nrbtsid(gnb_commission_path, '7')
    # change_hub_commission_targetbtsid(asir_commission_path, '7')

    result = get_testline_name("10.66.29.31", "ute", "Nokia666@ute!", "22")
