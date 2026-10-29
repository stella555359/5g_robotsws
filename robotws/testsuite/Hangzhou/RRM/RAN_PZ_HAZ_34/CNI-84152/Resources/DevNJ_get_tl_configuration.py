from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from bs4 import BeautifulSoup
import shutil
import json
import os
import re
import sys
try:
    from functools import reduce
except Exception as e:
    pass
try:
    import urllib.request
except Exception as e:
    import urllib


url_5g_commission = 'http://10.66.11.27/repo/5g-commission'
local_dir = "/home/ute/pkgload"

builtin_tl = BuiltIn()


def get_testline_name():
    # logger.info(sys.modules.values())

    return os.path.basename(
        os.path.dirname(
            [
                module.__file__
                for module in sys.modules.values()
                if "testline_configuration" in str(module) and "tl" in dir(module)
            ][0]
        )
    )


def get_full_commission_dir():
    if not os.path.exists(local_dir):
        os.makedirs(local_dir)
    logger.info('local_commission_path={}'.format(local_dir), also_console=True)
    return local_dir


def get_info_from_5g_commission_webpage(url, content):
    try:
        commission_5g_response = urllib.urlopen(url).read()
    except Exception as e:
        commission_5g_response = urllib.request.urlopen(url).read()

    if '7_21_' in content and '.xml' not in content:
        # Aims to find the first testline under the same testline type in case of dont have this testline info
        testline_selection = BeautifulSoup(commission_5g_response, features="lxml")
        content = testline_selection.find(href=re.compile(content)).get_text()
        logger.info('Get testline {} info from {}'.format(content, url), also_console=True)
        logger.info('================================', also_console=True)

    url_subpage = url + '/' + content
    logger.info('{}_url={}'.format(content, url_subpage), also_console=True)
    logger.info('================================', also_console=True)
    try:
        assert (content in commission_5g_response), 'Cant find {} in {}'.format(content, url)
    except Exception as e:
        assert (content.encode() in commission_5g_response), 'Cant find {} in {}'.format(content, url)
    return url_subpage


def get_configure_json_file(local_build_dir):
    logger.info('============Enter search and download commission file process====================', also_console=True)
    commission_type_url = get_info_from_5g_commission_webpage(url_5g_commission, 'commission_type.json')
    commission_type_json_path = os.path.join(local_build_dir, 'commission_type.json')
    os.system("curl {} -o {}".format(commission_type_url, commission_type_json_path))
    logger.info('local_commission_type_json_path={}'.format(commission_type_json_path), also_console=True)
    logger.info('================================', also_console=True)

    testline_url = get_info_from_5g_commission_webpage(url_5g_commission, 'testline.json')
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

    assert (testline in testline_info.keys()), \
        "{} don't include this testline info, please config it firstly!".format(testline_json_path)
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

    assert (os.path.isfile(commission_type_json_path)), "{} file dont exist, please add it firstly to 5g-commission".\
        format(commission_type_json_path)

    testline_type_file = open(commission_type_json_path, "r")
    all_testline_type_info = json.load(testline_type_file)
    if commission_type_number in all_testline_type_info.keys():
        testline_type = all_testline_type_info[commission_type_number]

    assert testline_type, "Dont have this tl type in file {}, please add it firstly".format(commission_type_json_path)
    logger.info('Get testline type = {} from commission_type.json'.format(testline_type), also_console=True)
    logger.info('================================', also_console=True)

    return testline_type


def get_gnb_and_asir_commission_path(local_dir, testline_name, testline_type, sw_build_info, subtype):
    assert local_dir, "{} dont exist".format(local_dir)
    gnb_commission_list = []
    asir_commission_list = []
    local_gnb_commission_path = ''
    local_asir_commission_path = ''

    sw_build_path = reduce(get_info_from_5g_commission_webpage,
                           [url_5g_commission, testline_type, testline_name, sw_build_info])
    # testline_type_path = get_info_from_5g_commission_webpage(url_5g_commission, testline_type)
    # testline_name_path = get_info_from_5g_commission_webpage(testline_type_path, testline_name)
    # sw_build_path = get_info_from_5g_commission_webpage(testline_name_path, sw_build_info)
    try:
        sw_build_path_response = urllib.urlopen(sw_build_path).read()
    except Exception as e:
        sw_build_path_response = urllib.request.urlopen(sw_build_path).read()

    bs_xml = BeautifulSoup(sw_build_path_response, features="lxml")

    for ele in bs_xml.findAll(href=re.compile("7_21_*")):
        if 'enb' in ele.get_text() or 'gnb' in ele.get_text():
            gnb_commission_list.append(ele.get_text())
        else:
            asir_commission_list.append(ele.get_text())

    logger.info('gnb_commission_list={}, asir_commission_list={}'.
                format(gnb_commission_list, asir_commission_list), also_console=True)
    logger.info('================================', also_console=True)

    for gnb_commission in gnb_commission_list:
        if subtype in gnb_commission:
            gnb_commission_url = get_info_from_5g_commission_webpage(sw_build_path, gnb_commission)
            local_gnb_commission_path = os.path.join(local_dir, gnb_commission)
            os.system("curl {} -o {}".format(gnb_commission_url, local_gnb_commission_path))
            assert (os.path.exists(local_gnb_commission_path)), 'curl failed from {}'.format(gnb_commission_url)
    if 'CDD' not in testline_type and 'DAS' not in testline_type:
        for asir_commission in asir_commission_list:
            if subtype in asir_commission:
                asir_commission_url = get_info_from_5g_commission_webpage(sw_build_path, asir_commission)
                local_asir_commission_path = os.path.join(local_dir, asir_commission)
                os.system("curl {} -o {}".format(asir_commission_url, local_asir_commission_path))
                assert (os.path.exists(local_asir_commission_path)), 'curl failed from {}'.\
                    format(local_asir_commission_path)

    assert local_gnb_commission_path, 'cant get commission with parameter:{};{};{};{}'.\
        format(testline_type, testline_name, sw_build_info, subtype)
    logger.info('local_gnb_commission_path={}, local_asir_commission_path={}'.
                format(local_gnb_commission_path, local_asir_commission_path), also_console=True)
    logger.info('===============End of download commission file process===========================', also_console=True)
    return local_gnb_commission_path, local_asir_commission_path


def get_swconfig_template_path(local_dir, release):
    swconfig_list = []
    swconfig_release = "swconfig.txt"

    try:
        swconfig_response = urllib.urlopen(url_5g_commission).read()
    except Exception as e:
        swconfig_response = urllib.request.urlopen(url_5g_commission).read()
    swconfig_xml = BeautifulSoup(swconfig_response, features="lxml")
    for ele in swconfig_xml.findAll(href=re.compile("swconfig*")):
        if 'swconfig' in ele.get_text():
            swconfig_list.append(ele.get_text())
    for swconfig in swconfig_list:
        if release in swconfig:
            swconfig_release = swconfig

    os.system("curl {}/{} -o {}".
              format(url_5g_commission, swconfig_release, os.path.join(local_dir, swconfig_release)))
    logger.info('Download {} from {}'.format(swconfig_release, url_5g_commission), also_console=True)
    return os.path.join(local_dir, swconfig_release)


def change_gnb_commission_btsid_nrbtsid(gnb_commission_path, btsid):
    filepath, tempfilename = os.path.split(gnb_commission_path)
    fname, extension = os.path.splitext(tempfilename)
    bkfile_path = os.path.join(local_dir, '{}_backup{}'.format(fname, extension))
    try:
        shutil.copyfile(gnb_commission_path, bkfile_path)
        shutil.rmtree(gnb_commission_path, ignore_errors=True)
    except IOError as e:
        raise Exception('Copy file from {} to {} failed'.format(gnb_commission_path, bkfile_path))

    with open(bkfile_path, 'r') as current_scf:
        current_scf_content = current_scf.read()
    with open(gnb_commission_path, 'w') as new_scf:
        new_scf_content = re.sub(r'MRBTS-[0-9]*', 'MRBTS-'+str(btsid), current_scf_content)
        new_scf_content = re.sub(r'NRBTS-[0-9]*', 'NRBTS-'+str(btsid), new_scf_content)
        new_scf.write(new_scf_content)


def change_hub_commission_targetbtsid(hub_commission_path, btsid):
    filepath, tempfilename = os.path.split(hub_commission_path)
    fname, extension = os.path.splitext(tempfilename)
    bkfile_path = os.path.join(local_dir, '{}_backup{}'.format(fname, extension))
    try:
        shutil.copyfile(hub_commission_path, bkfile_path)
        shutil.rmtree(hub_commission_path, ignore_errors=True)
    except IOError as e:
        raise Exception('Copy file from {} to {} failed'.format(hub_commission_path, bkfile_path))

    with open(bkfile_path, 'r') as current_scf:
        current_scf_content = current_scf.read()
        search_scf_content = re.search(r'targetBtsId">[0-9]*</p>\s*<p name="technology">(?P<technology>5G)',
                                       current_scf_content, re.M | re.I)
        if search_scf_content.group("technology") == '5G':
            replace_scf_content = re.sub(r'targetBtsId">[0-9]*', 'targetBtsId">'+btsid, search_scf_content.group())

    with open(hub_commission_path, 'w') as new_scf:
        new_scf_content = re.sub(r'{}'.format(search_scf_content.group()), replace_scf_content, current_scf_content)
        new_scf.write(new_scf_content)


def get_specific_type_gnb_and_asir_commission(local_dir, testline_name, testline_type, sw_build, subtype):
    """
    This method used to download specific commission file from URL repo.
    :param local_dir: testline local dir for downloaded commission
    :param testline_name: test line name, format should be like : 7_21_UTE5G034TL087
    :param testline_type: test line type
    :param sw_build: SW build info
    :param subtype: sub type of commission file, values of 2T2R, host and so on
    """

    assert local_dir, "{0} is not exist, please check !".format(local_dir)
    commission_file_list = []
    local_commission_path = ''

    sw_build_path = reduce(get_info_from_5g_commission_webpage,
                           [url_5g_commission, testline_type, testline_name, sw_build])
    try:
        sw_build_path_response = urllib.urlopen(sw_build_path).read()
    except Exception as e:
        sw_build_path_response = urllib.request.urlopen(sw_build_path).read()
    bs_xml = BeautifulSoup(sw_build_path_response, features="lxml")

    [commission_file_list.append(ele.get_text()) for ele in bs_xml.findAll(href=re.compile("7_21_*"))]
    logger.info("commission list : {0}".format(commission_file_list))

    for commission_file_name in commission_file_list:
        if subtype in commission_file_name:
            commission_url = get_info_from_5g_commission_webpage(sw_build_path, commission_file_name)
            local_commission_path = os.path.join(local_dir, commission_file_name)
            os.system("curl {0} -o {1}".format(commission_url, local_commission_path))

    return local_commission_path if local_commission_path else None


if __name__ == "__main__":
    local_dir = get_full_commission_dir()
    # testline_name = get_testline_name()
    commission_type_json_path, testline_json_path = get_configure_json_file(local_dir)
    mrbtsId, commission_type_number, commission_sub_type, testline_configuration_list = \
        get_testline_configuration_info_from_testline_json_file(testline_json_path, '7_21_CLOUD018TL028')
    testline_type = get_testline_type_from_commission_type_json(commission_type_json_path, commission_type_number)
    gnb_commission_path, asir_commission_path = \
        get_gnb_and_asir_commission_path(local_dir, '7_21_CLOUD018TL028', testline_type,
                                         'SBTS00_ENB_9999_211128_000007', commission_sub_type)
    # swconfig_path = get_swconfig_template_path(local_dir, '21A')
    # change_gnb_commission_btsid_nrbtsid(gnb_commission_path, '7')
    # change_hub_commission_targetbtsid(asir_commission_path, '7')
