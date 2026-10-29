__author__ = 'Anna Bien'
__maintainer__ = 'Anna Bien'
__team__ = 'I_5G_SW_MMW_PLKRK_04'
__email__ = 'I_5G_SW_MMW_PLKRK_04 <I_5G_SW_MMW_PLKRK_04@nokia.com>'
__owner_email__ = 'anna.bien@nokia.com'

from taf.sw.reporting_portal import reporting_portal
from common_gnb import get_gnb_build
from robot.api import logger
from os.path import isfile
import subprocess
import json
import re
import sys


def get_qc_info_from_file(tc_name, suite_path, gnb_sw_version):
    """
    Get info from .qc file for reporting test results to QC.

    :param suite_path: STRING - absolute path to test suite
    :param gnb_sw_version: STRING - gNB software version
    :param tc_name: STRING - QC Test Instance name including the instance number
    :return qc_info_dict: DICT - data from .qc file corresponding to given tc_name and gnb_sw_version
    """
    qc_info_dict = {'qc_project': '', 'qc_domain': '', 'qc_testlab_path': '', 'qc_test_set_name': ''}
    qc_file_path = suite_path.replace('.robot', '.qc')
    if isfile(qc_file_path):
        try:
            with open(qc_file_path, 'rb') as qc_json:
                qc_info = json.load(qc_json)
            for sw_release in list(qc_info.keys()):
                sw_rel_pattern = re.compile(sw_release)
                result = sw_rel_pattern.findall(gnb_sw_version)
                if not result:
                    continue
                qc_path = [key for key in list(qc_info[sw_release].keys()) if u'Root\\' in key][0]
                for test_case in list(qc_info[sw_release][qc_path].values())[0]:
                    test_case_pattern = re.compile(test_case)
                    result = test_case_pattern.findall(tc_name)
                    if not result and test_case != tc_name:
                        continue
                    qc_info_dict.update({'qc_project': qc_info[sw_release]['qc_project']})
                    qc_info_dict.update({'qc_domain': qc_info[sw_release]['qc_domain']})
                    qc_info_dict.update({'qc_testlab_path': qc_path})
                    qc_info_dict.update({'qc_test_set_name': list(qc_info[sw_release][qc_path].keys())[0]})
        except Exception as e:
            logger.warn(e)
    else:
        logger.warn('Report status to RP error: File not found: {}'.format(qc_file_path))
    if not qc_info_dict:
        logger.warn('Report status to RP error: Could not match {} in {}'.format(tc_name, qc_file_path))
    return qc_info_dict


def report_results_to_rp(tc_name, tc_result, suite_path, result_dir='', pm_counters='', test_tags='', doc='',
                         gnb_sw_version='', features_covered='', tl_name=''):
    """
    Report test result to Reporting Portal and Quality Center.
    Requirement: .qc file corresponding to test suite has to be created.

    :param tc_name: STRING - QC Test Instance name including the instance number,
               e.g. "[1]CB007827-G#2_Long_PUCCH_for_FD_BF_FR1-TDD_with_pCSI_multiplexing-SA_multi_UE_traffic_ABIL"
    :param tc_result: STRING - verification verdict, possible values: "passed" or "failed" (case insensitive)
    :param suite_path: STRING - absolute path to test suite
    :param pm_counters: STRING (default=EMPTY) - PM Counters under test,
        e.g. "[{'piid': 'M55319C00001', 'result': 'Passed', 'value': 30},
               {'piid': 'M55320C00001', 'result': 'Passed', 'value': 30}]"
    :param test_tags: LIST Should contain tags determining covered feature with 'FT_' prefix e.g. FT_CB007827-G
    :param result_dir: STRING (default=EMPTY) - result directory (for future usage)
    :param doc: STRING - Documentation
    :param gnb_sw_version: STRING - gNB software version (No need to define, obtained automatically)
    :param features_covered: STRING - e.g. CB007827-G (No need to define, obtained automatically)
    :param tl_name: STRING - testline name (No need to define, obtained automatically)

    :Example Robot usage (only automatic Robot variables):
        Report results to RP
        ...    tc_name=${TEST NAME}
        ...    tc_result=${TEST STATUS}
        ...    suite_path=${SUITE SOURCE}
        ...    result_dir=${OUTPUT DIR}
        ...    test_tags=${TEST TAGS}
        ...    doc=${TEST DOCUMENTATION}
    """
    qc_info = {'qc_project': '', 'qc_domain': '', 'qc_testlab_path': '', 'qc_test_set_name': ''}
    try:
        gnb_sw_version = get_gnb_build(convert_to_trunk=True) if not None else gnb_sw_version
        qc_info = get_qc_info_from_file(tc_name, suite_path, gnb_sw_version)
        features_covered = [tag.split('_', 1)[-1] for tag in test_tags if 'FT_' in tag] if not [] else features_covered
        hostname = subprocess.check_output(['hostname'])  # Python3 returns bytes object here, Python2 returns str
        if hostname:
            if isinstance(hostname, bytes):
                hostname = hostname.decode(encoding=sys.getdefaultencoding() if not None else 'utf-8')
            tl_name = hostname.replace('-', '_')
        if '' in qc_info.values():
            raise ValueError('Report without QC.')
    except Exception as e:
        logger.warn('Report status to RP error: {}'.format(e))
        logger.warn('Report status to RP error: Could not collect all data for report')
    finally:
        logger.info('====== data gathered for report ======')
        logger.info('gNB software version: {}'.format(gnb_sw_version))
        logger.info('QC details: {}'.format(qc_info))
        logger.info('Features covered: {}'.format(features_covered))
        logger.info('Testline name: {}'.format(tl_name))
    try:
        ute_rep = reporting_portal()
        result = ute_rep.report_to_rp(name=tc_name,
                                      qc_test_instance_name=tc_name,
                                      result=tc_result,
                                      links={},
                                      ca='',
                                      add_info=['UTE', 'TAF'],
                                      build=gnb_sw_version,
                                      suite_path=suite_path,
                                      tool='Robot',
                                      hw_id='',
                                      username='',
                                      features_covered=features_covered,
                                      qc_test_set_name=qc_info['qc_test_set_name'],
                                      qc_testlab_path=qc_info['qc_testlab_path'],
                                      qc_domain=qc_info['qc_domain'],
                                      qc_project=qc_info['qc_project'],
                                      qc_id=None,
                                      counter_results=pm_counters,
                                      kpi_results=[],
                                      testline=tl_name,
                                      doc=doc)
        logger.info('Report sent to RP: {}'.format(result), also_console=True)
    except Exception as e:
        logger.warn(e)
        logger.warn('Report status to RP failed: Failure in sending report')
