import logging
import time
import os
import openpyxl
from office365.runtime.auth.authentication_context import AuthenticationContext
from office365.sharepoint.client_context import ClientContext
from office365.sharepoint.file import File
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion
from taf.rfrl.utilities.test_config import get_configuration
from taf.rfrl.utilities.robot.general import get_builtin_value, set_robot_suite_variable
from taf.rfrl.utilities.cloud_manager.artifacts import (get_cm_uuf_tags, get_cm_build_artifacts,
                                                        get_cm_source_build_for_customer,
                                                        get_cm_default_upgrade_paths)


def get_source_build_for_customer(customer_name=None, configuration_id=None, target_build=None, ):
    """
    Get source build for customer and configuration

    :param customer_name: customer name. if not provided, it will be fetched from CM_TAGS env variable.
    :param configuration_id: configuration id. if not provided, it will be fetched from CM_TAGS env variable.
    :param target_build: target build. It is needed only for getting source build from WFT.

    :return: source build
    :raises ValueError:
        if customer name or configuration not defined
    """
    try:
        return get_cm_source_build_for_customer(customer_name=customer_name, configuration_id=configuration_id)
    except ValueError:
        pass

    logging.debug("ENV: CM_ARTIFACTS not defined. Getting source build from WFT.")
    if target_build is None:
        target_build = get_target_build()

    # TODO - get build_artifacts from WFT & customer_deployments
    raise NotImplementedError("Getting build artifacts from WFT is not implemented yet. "
                              "At this moment it could be run from CM only.")
    # return _get_cm_source_build_for_customer(customer_deployments, customer_name, configuration_id)


def get_builds_to_testing(start_from_level=None):
    """
    Get builds to testing
    :param start_from_level: level to start from. If not provided, it will be fetched from CM_TAGS env variable.
    :return: list of builds
    """
    paths_for_testing = get_paths_for_testing(start_from_level)
    upgrade_paths = get_cm_default_upgrade_paths()
    builds_to_testing = {level: upgrade_paths[level] for level in paths_for_testing}
    return builds_to_testing


def get_paths_for_testing(start_from_level=None):
    """
    Get paths for testing
    :param start_from_level: level to start from. If not provided, it will be fetched from CM_TAGS env variable.
    :return: list of levels eg. ['n2', 'n1', 'n0']
    """
    if start_from_level is None:
        start_from_level = get_cm_uuf_tags()['UPDATE_PATH']

    number_of_levels = int(start_from_level[1:]) + 1
    levels = ['n{}'.format(i) for i in reversed(range(number_of_levels))]
    return levels


def get_target_build():
    """
    Get target build
    :return: target build
    """
    build_artifacts = get_cm_build_artifacts()
    if build_artifacts:
        return build_artifacts.get('name')
    elif get_builtin_value('ENB_BUILD'):
        return get_builtin_value('ENB_BUILD')
    else:
        sw_version = GnbDuOperations().get_bts_sw_version(bts_id=0, du_id=0)
        return sw_version


def get_proper_set_of_qc_ids(bts_build, qc_ids_mapping):
    release = SbtsSwVersion(bts_build).release
    return qc_ids_mapping[release]


# LEGACY solution with Excel - most probably could be deleted in the future
def get_sources_for_testline(uuf_details, target_build, testline):
    sources = []
    for record in uuf_details:
        if record['target_sw_build'] == target_build and record['testline'] == testline:
            sources.extend(record['source_sw_build'])
    sources.sort()
    return sources


def wait_for_target_source(target_build, testline, interval_checking=15 * 60, timeout=60 * 60 * 3,
                           uuf_file_path='/tmp/UUF_builds.xlsx'):
    uuf_getter = UUFExcelGetter(file_path=uuf_file_path)
    start_time = time.time()
    timeout = int(timeout)
    while time.time() < start_time + timeout:
        uuf_getter.download_report()
        details = uuf_getter.get_uuf_details()
        sources = get_sources_for_testline(uuf_details=details, target_build=target_build, testline=testline)
        if sources:
            return sources
        logging.debug("Source builds for {} and {} not exists in UUF_builds.xlsx".format(target_build, testline))
        logging.debug("Waiting {} seconds for UUF source data".format(sources))
        time.sleep(interval_checking)


def set_source_and_target_build_variables():
    """
    For UUF4ALL_SW_UPGRADE_TEST procedure(taf.rfrl.uuf4all)
    """
    source_sw = get_builtin_value('5G_SOURCE_SW')
    target_sw = get_builtin_value('5G_TARGET_SW')
    if source_sw is None or target_sw is None:
        testline_name = get_configuration()[1]
        target_build = get_builtin_value('ENB_BUILD')
        source_build_list = wait_for_target_source(target_build=target_build, testline=testline_name)
        set_robot_suite_variable('5G_SOURCE_SW', source_build_list[0])
        set_robot_suite_variable('5G_TARGET_SW', target_build)


def set_source_list_and_target_build_variables():
    """
    For 'UUF_SW_UPGRADE_ROLLBACK procedure' (testsuite/Krakow/resources/UUF_ASIR/)
    """
    source_build_list = get_builtin_value('SOURCE_ENB_BUILDS')
    target_sw = get_builtin_value('TARGET_BUILD')
    if source_build_list is None or target_sw is None:
        testline_name = get_configuration()[1]
        target_build = get_builtin_value('ENB_BUILD')
        source_build_list = wait_for_target_source(target_build=target_build, testline=testline_name)
        set_robot_suite_variable('TARGET_BUILD', target_build)

    source_build_list = sorted(source_build_list, key=lambda x: x.replace("00", "99"))
    set_robot_suite_variable('SOURCE_ENB_BUILDS', source_build_list)


def set_hub_factory_loads_variable(uuf_file_path='/tmp/UUF_builds.xlsx'):
    hub_builds = get_builtin_value('HUBS_BUILDS')
    if hub_builds is None:
        hub_builds = {}
        uuf_getter = UUFExcelGetter(file_path=uuf_file_path)
        uuf_getter.download_report()
        factory_loads = uuf_getter.get_hub_factory_loads()
        for factory_load in factory_loads:
            hub_builds[factory_load['hw_type']] = factory_load['build']
        set_robot_suite_variable('HUBS_BUILDS', hub_builds)


class UUFExcelGetter(object):
    HTTPS_PROXY = 'http://proxy-lab.krk-lab.nsn-rdnet.net:8080'
    AUTH_CLIENT_ID = 'caeb9226-ad24-418b-9c7c-6587f4067c5a'
    AUTH_CLIENT_SECRET = 'xv1UhDqWT3d7VuJSqKbY/ckZXVeXeD8+nqMR2503Kno='
    SITE_URL = 'https://nokia.sharepoint.com/sites/MN5GSCmmWSCPzKRKTribe/'

    def __init__(self,
                 file_url='/sites/MN5GSCmmWSCPzKRKTribe/Shared Documents/Regression/UUF_builds.xlsx',
                 file_path='/tmp/UUF_builds.xlsx'):
        """

        :param file_url:  relative URL path to the file
        :param file_path: local path where file will be downloaded.
        """
        self.file_url = file_url
        self.file_path = file_path

    def download_report(self):
        os.environ['HTTPS_PROXY'] = self.HTTPS_PROXY
        ctx = self._create_context()
        response = File.open_binary(ctx, self.file_url)

        with open(os.path.abspath(self.file_path), "wb") as local_file:
            local_file.write(response.content)

    def get_hub_factory_loads(self):
        column_mapping = [
            ('hw_type', 'A'),
            ('build', 'B'),
        ]
        wb_obj = openpyxl.load_workbook(self.file_path)
        sheet = wb_obj['HUB_Factory_Load']
        factory_loads = []
        for row_number in range(2, sheet.max_row + 1):
            factory_load = {}
            for column in column_mapping:
                column_alias = column[0]
                column_name = column[1]
                value = sheet["{}{}".format(column_name, row_number)].value
                factory_load[column_alias] = value
            factory_loads.append(factory_load)

        return factory_loads

    def get_uuf_details(self):
        column_mapping = [
            ('target_sw_build', 'A'),
            ('customer', 'B'),
            ('testline', 'C'),
            ('source_sw_build', 'D'),
        ]

        wb_obj = openpyxl.load_workbook(self.file_path)
        sheet = wb_obj['UUF']
        request_details = []
        prev_record = {
            'target_sw_build': None,
            'customer': None,
            'testline': None,
            'source_sw_build': None,
        }
        for row_number in range(2, sheet.max_row + 1):
            current_record = {}
            for column in column_mapping:
                column_alias = column[0]
                column_name = column[1]
                value = sheet["{}{}".format(column_name, row_number)].value
                if value and column_alias == 'source_sw_build':
                    if ',' in value:
                        value = value.replace('\n', '').split(',')
                    else:
                        value = value.split('\n')
                if value is None:
                    value = prev_record[column_alias]
                current_record[column_alias] = value

            request_details.append(current_record.copy())
            prev_record = current_record.copy()

        return request_details

    def _create_context(self):
        context_auth = AuthenticationContext(self.SITE_URL)
        context_auth.acquire_token_for_app(client_id=self.AUTH_CLIENT_ID, client_secret=self.AUTH_CLIENT_SECRET)
        context = ClientContext(self.SITE_URL, context_auth)

        return context
