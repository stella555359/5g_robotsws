from taf.transport.ssh import ssh
from taf.nms.netact.facade import Netact
from Exceptions import *

import os
import logging
import subprocess
import pysftp
import time
import re


logger = logging.getLogger(__name__)
connection = ssh()


class CM_operations(object):

    def __init__(self):
        self.import_dir = '/var/opt/oss/global/racops/import/'
        self.alias = 'netact_cm'
        self.connected = False
        self.connection = ssh()

    def contain_error(self, operation_result):
        return re.search(r'Type:\sError', operation_result)

    def parse_statuses(self, operation_result):
        return re.findall(r'Status\sreceived:\s.*\s', operation_result)

    def parse_error_details(self, operation_result):
        error_details = re.search(r'Details:\s.*\s', operation_result)
        if error_details:
            return error_details.group()
        return 'No error Details found'

    def parse_error_info(self, operation_result):
        error_details = re.search(r'Distname.*non-existing', operation_result)
        if error_details:
            error_number = re.search(r'FAILED MOS.*', operation_result)
            return error_details.group(), error_number.group()
        return 'No error Details found'

    def copy_file_to_Netact(self, sw_version, source_file_path, file_name, username, password, vm):
        release = ['SBTS21B', 'SBTS22R1', 'SBTS22R2', 'SBTS22R3', 'SBTS00']
        version = re.split('_', sw_version)[0]
        if version in release:
            release_SCF_file_path = source_file_path + version + '/'
            logger.info('path to file: {}'.format(release_SCF_file_path))
            __command = 'sshpass -p {} scp {} {}@{}:{}'.format(password, release_SCF_file_path + file_name,
                                                               username, vm, self.import_dir)
            try:
                remote_files = self.connection.execute('ls {}'.format(self.import_dir))
                if file_name not in remote_files:
                    os.system(__command)
                    logger.info('copy file {} to {}'.format(file_name, self.import_dir))
                else:
                    raise NetactImportFileException('file {} already exists in path {}'.format(file_name,
                                                                                               self.import_dir))
            except Exception as e:
                raise e
            return self.import_dir + file_name
        else:
            raise NetactImportFileException('SW release version {} is not correct'.format(version))

    def import_plan(self, file_name, planname, merge_import=False):
        if not isinstance(merge_import, bool):
            raise ValueError('mergeImport is bool values')
        if merge_import:
            merge_import = 'true'
        if not merge_import:
            merge_import = 'false'
        __command = "racclimx.sh -op Import_SCF -inputFile {} -planName {} -mergeImport {} \
            -v".format(file_name, planname, merge_import)
        try:
            remote_files = self.connection.execute('ls {}'.format(self.import_dir))
            if file_name not in remote_files:
                raise NetactImportFileNotFound('file not found in remote files, remote files {}'.format(remote_files))
            response = self.connection.execute(__command)
            logger.info('NetAct output from import operation : {}'.format(response))
            if self.contain_error(response):
                raise NetactImportFileException('Import file exception, {}'.format(self.parse_error_details(response)))
        except Exception as e:
            raise e
        return response

    def prevalidation(self, planname):
        logger.info('Prepare for prevalidation plan name:{}'.format(planname))
        __command = "racclimx.sh -op PreValidate -planName {} -v".format(planname)
        try:
            response = self.connection.execute(__command)
            logger.info('NetAct output from prevalidation operation {}'.format(response))
            if self.contain_error(response):
                error_info, error_number = self.parse_error_info(response)
                if error_info == "Distname parameter 'targetDN' references non-existing" and error_number[-2] == "1":
                    raise NetactValidationTargetDNException()
                else:
                    raise NetactValidationException('Validation plan exeption, {}'.
                                                    format(self.parse_error_details(response)))
        except Exception as e:
            raise e
        return response

    def check_and_delete_file_from_remote_directory(self, file_name):
        _command = 'rm {}'.format(self.import_dir + file_name)
        output = connection.execute('ls {}'.format(self.import_dir))
        if file_name in output:
            logger.info('Removing file {} from {}'.format(file_name, self.import_dir))
            connection.execute(_command)
        else:
            logger.info('Missing file {} in path {}'.format(file_name, self.import_dir))

    def remove_plan(self, planname='test_176'):
        __command = "racclimx.sh -op planDeletion -planName {} -v".format(planname)
        try:
            response = connection.execute(__command)
            logger.debug('remove plan output :: {}'.format(response))
            if self.contain_error(response):
                logger.debug('plan deletion failure, received statuses are :{}'.format(self.parse_statuses(response)))
                raise NetactRemovePlanException('Plan Deletion Failure, {}'.format(self.parse_error_details(response)))
        except Exception as e:
            raise e
        return response


def copy_SCF_to_netact(sw_version, BTS_file_path, file_name, username, password, vm):
    Netact_cm = CM_operations()
    test_path = Netact_cm.copy_file_to_Netact(sw_version, BTS_file_path, file_name, username, password, vm)
    return test_path


def generate_plan_with_diff_MRBTS_ID(MRBTS_id, file_path, MRBTS_new_id):
    _command = "sed -i 's/" + str(MRBTS_id) + "/" + str(MRBTS_new_id) + "/g' " + str(file_path)
    connection.execute(_command)
    print("MRBTS id changed to {}".format(MRBTS_new_id))


def import_file_cm(file_name, planname):
    Netact_cm = CM_operations()
    Netact_cm.import_plan(file_name, planname)


def prevalidation(planname):
    Netact_cm = CM_operations()
    output = Netact_cm.prevalidation(planname)
    return output


def delete_test_plans_from_netact(fileName):
    Netact_cm = CM_operations()
    Netact_cm.check_and_delete_file_from_remote_directory(fileName)


def remove_plan_from_netact_cm(planname):
    Netact_cm = CM_operations()
    Netact_cm.remove_plan(planname)


def edit_plan_with_planned_sw_version(planname, MRBTS_new_id, planned_version, web_url, username, password):
    Netact_cm = Netact()
    Netact_cm.add_web_url(web_url, username, password)
    configuration = Netact_cm.get_plan_configuration(planname)
    mo_id = "PLMN-PLMN/{}/MNL-1".format(MRBTS_new_id)
    managed_object = Netact_cm.get_managed_object(configuration, mo_id)
    new_parameters = {'plannedSWReleaseVersion': planned_version}
    Netact_cm.edit_managed_object(managed_object, operation='UPDATE', **new_parameters)


def edit_plan_with_error(planname, MRBTS_new_id, web_url, username, password):
    Netact_cm = Netact()
    Netact_cm.add_web_url(web_url, username, password)
    configuration = Netact_cm.get_plan_configuration(planname)
    mo_id = "PLMN-PLMN/{}/MNL-1/MNLENT-1".format(MRBTS_new_id)
    managed_object = Netact_cm.get_managed_object(configuration, mo_id)
    new_parameters = {'targetDN': '{}/EQM-1/APEQM-2'.format(MRBTS_new_id)}
    Netact_cm.edit_managed_object(managed_object, operation='UPDATE', **new_parameters)
