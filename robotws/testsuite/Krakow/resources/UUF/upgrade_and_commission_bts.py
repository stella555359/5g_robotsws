import logging
import os
import re
import time
import datetime
from on_air_tl_preparation.bts.bts_operations import GenericBtsPreparator
from on_air_tl_preparation.testline_preparation_resources import is_asir_configuration, power_on_all_pdu_ports
from taf.rfrl.utilities.tl_config import get_configuration
from taf.rfrl.utilities.test_config import get_repository_path
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from taf.rfrl.utilities.threads import ThreadWithReturnValue
from taf.rfrl.utilities.transfer_files import download_files
from taf.rfrl.bts import commissioning
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations, EnbDuOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning, EnbCommissioning
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations, EnbCellOperations
from taf.rfrl.bts.devices.du.alarm_verification import GnbAlarmVerification, EnbAlarmVerification
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations, EnbRuOperations
from taf.rfrl.bts.devices.du.logs_collecting.basic_logs import GnbLog, EnbLog
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations, EnbAsirHubOperations
from taf.rfrl.bts.devices.du.sw_update import GnbSwUpdate, EnbSwUpdate

build_downloader = {}


def upgrade_and_commission_gnb(sw_build, scf_path=None, prefix_tag=None, asir_scf_path=None, builds_dir=None, gnb_id=0,
                               du_id=0, upgrade_via_yaft=False):
    power_on_all_pdu_ports()
    if scf_path is None:
        scf_path = _get_default_scf_path(sw_build, 'GNB', gnb_id, prefix_tag=prefix_tag)
    if asir_scf_path is None:
        asir_scf_path = _get_default_scf_path(sw_build, 'GNB', gnb_id, prefix_tag=prefix_tag, asir=True)
    uac = UpgradeAndCommissionGnb(bts_id=gnb_id, du_id=du_id)
    uac.upgrade_and_commission_bts(sw_build=sw_build, scf_path=scf_path, asir_scf_path=asir_scf_path,
                                   builds_dir=builds_dir, upgrade_via_yaft=upgrade_via_yaft)


def upgrade_and_wait_for_onair(sw_build, builds_dir=None, gnb_id=0, du_id=0, delete_sw_package=False):
    uac = UpgradeAndCommissionGnb(bts_id=gnb_id, du_id=du_id)
    uac.upgrade_and_wait_for_onair(sw_build=sw_build, builds_dir=builds_dir, delete_sw_package=delete_sw_package)


def upgrade_and_commission_enb(sw_build, scf_path=None, prefix_tag=None, asir_scf_path=None, builds_dir=None, enb_id=0,
                               du_id=0, upgrade_via_yaft=False):
    power_on_all_pdu_ports()
    if scf_path is None:
        scf_path = _get_default_scf_path(sw_build, 'ENB', enb_id, prefix_tag=prefix_tag)
    if asir_scf_path is None:
        asir_scf_path = _get_default_scf_path(sw_build, 'ENB', enb_id, prefix_tag=prefix_tag, asir=True)
    uac = UpgradeAndCommissionEnb(bts_id=enb_id, du_id=du_id)
    uac.upgrade_and_commission_bts(sw_build=sw_build, scf_path=scf_path, asir_scf_path=asir_scf_path,
                                   builds_dir=builds_dir, upgrade_via_yaft=upgrade_via_yaft)


def _get_default_scf_path(sw_build, bts_type, bts_id, prefix_tag=None, asir=False):
    location, testline_name = get_configuration()
    repository_path = get_repository_path()
    branch = sw_build.split('_')[0]
    prefix = '{}_'.format(prefix_tag) if prefix_tag else ''
    commissioning_dir = os.path.join(repository_path, 'commissionings', location, testline_name, branch)
    if asir:
        return os.path.join(commissioning_dir, '{}{}{}_ASIR_SCF.xml'.format(prefix, bts_type, bts_id))
    else:
        return os.path.join(commissioning_dir, '{}{}{}_SCF.xml'.format(prefix, bts_type, bts_id))


class UpgradeAndCommissionBts(GenericBtsPreparator):
    def __init__(self, bts_type, bts_comm, bts_du, bts_alarm, bts_log, bts_ru, bts_cell, bts_asir, sw_update,
                 bts_id=0, du_id=0):
        super(UpgradeAndCommissionBts, self).__init__(bts_type, bts_comm, bts_du, bts_alarm, bts_log, bts_ru, bts_cell,
                                                      bts_id, du_id)
        self.bts_asir = bts_asir
        self.sw_update = sw_update

    def upgrade_and_wait_for_onair(self, sw_build, builds_dir=None, update_timeout=1800, delete_sw_package=False):
        self.connect(increase_time_for_check=False, interface='lmp')
        active_build = self.bts_comm.admin.get_sw_version(connection=self.bts_connection_name)
        active_build = re.sub(r'SBTS\d+R\d+_ENB_9999', 'SBTS00_ENB_9999', active_build)

        if active_build == sw_build:
            log_info_to_console('Active build is the same as build to upload({}) - skip procedure'.format(active_build),
                                log_hierarchy=2)
        else:
            path_to_sw = self.download_build(sw_build=sw_build, builds_dir=builds_dir, wait_till_downloaded=True)
            log_info_to_console('Upgrade BTS software to {}'.format(sw_build), log_hierarchy=2)
            self.update_software(sw_package=path_to_sw,
                                 connection=self.bts_connection_name,
                                 timeout=update_timeout)
            self.disconnect()
            if delete_sw_package:
                logging.debug("'delete_sw_package' enabled - deleting {}".format(path_to_sw))
                os.remove(path_to_sw)

        self.wait_for_bts_on_air_state(increase_time_for_checking_radios=False,
                                       increase_time_for_checking_cells=False)
        log_info_to_console('BTS is prepared properly')

    def upgrade_and_commission_bts(self, sw_build, scf_path, asir_scf_path=None, builds_dir=None, update_timeout=1800,
                                   sleep_after_configuration_reset=600, sleep_after_software_update=600,
                                   sleep_after_asir_commissioning=180, upgrade_via_yaft=False):
        """
        Function to upgrade and commission BTS to On-Air state.
        """
        self.connect(increase_time_for_check=False, interface='lmp')
        active_build = self.bts_comm.admin.get_sw_version(connection=self.bts_connection_name)
        active_build = re.sub(r'SBTS\d+R\d+_ENB_9999', 'SBTS00_ENB_9999', active_build)

        if active_build == sw_build:
            log_info_to_console('Active build is the same as build to upload({}) - skip procedure'.format(active_build),
                                log_hierarchy=2)
        else:
            if upgrade_via_yaft:
                self.disconnect()
                path_to_sw = self.upgrade_via_yaft(sw_build, builds_dir)
            else:
                path_to_sw = self.rest_configuration_and_upgrade(sw_build, sleep_after_configuration_reset,
                                                                 update_timeout, builds_dir)

            log_info_to_console('Waiting {} seconds for BTS availability after software update'.
                                format(sleep_after_software_update), log_hierarchy=2)
            time.sleep(sleep_after_software_update)
            self.connect(increase_time_for_check=False, interface='lmp')
            log_info_to_console('Validate SCF {}'.format(scf_path), log_hierarchy=2)
            self.bts_comm.admin.validate_scf_online(scf_file=scf_path,
                                                    skip_parameter_relation_errors=False,
                                                    detailed_output=True,
                                                    connection=self.bts_connection_name)
            log_info_to_console('Commission BTS', log_hierarchy=2)
            self.bts_comm.perform_bts_full_commissioning(scf_file=scf_path,
                                                         bts_id=self.bts_id,
                                                         skip_parameter_relation_errors=True,
                                                         should_activate=True,
                                                         validate_scf=False,
                                                         timeout=600,
                                                         du_id=self.du_id)
            log_info_to_console('Verify if another sw upload is needed', log_hierarchy=2)
            commissioning.verify_if_another_sw_upload_is_needed(awaiting_time=600,
                                                                readiness_timeout=600,
                                                                bts_id=self.bts_id,
                                                                bts_type=self.bts_type,
                                                                build_directory=os.path.dirname(str(path_to_sw)),
                                                                update_timeout=update_timeout)
            log_info_to_console('Uploaded SCF file', log_hierarchy=2)

            if is_asir_configuration(scf_path):
                self.bts_asir.perform_asir_commissioning(scf_path=asir_scf_path)
                log_info_to_console('Uploaded ASIR SCF file', log_hierarchy=2)
                time.sleep(sleep_after_asir_commissioning)

            self.wait_for_bts_on_air_state(increase_time_for_checking_radios=False,
                                           increase_time_for_checking_cells=False)
            log_info_to_console('BTS is prepared properly')

    def rest_configuration_and_upgrade(self, sw_build, sleep_after_configuration_reset, update_timeout,
                                       builds_dir=None):
        self.download_build(sw_build=sw_build, builds_dir=builds_dir)
        log_info_to_console('Configuration Reset', log_hierarchy=2)
        self.bts_comm.reset_configuration(bts_id=self.bts_id, du_id=self.du_id, timeout=900)
        self.disconnect()

        log_info_to_console('Waiting {} seconds for BTS availability after config reset'.
                            format(sleep_after_configuration_reset), log_hierarchy=2)
        time.sleep(sleep_after_configuration_reset)
        path_to_sw = self.download_build(sw_build=sw_build, wait_till_downloaded=True)
        log_info_to_console('Upgrade BTS software to {}'.format(sw_build), log_hierarchy=2)
        self.connect(increase_time_for_check=False, interface='lmp')
        self.update_software(sw_package=path_to_sw,
                             connection=self.bts_connection_name,
                             timeout=update_timeout)
        self.disconnect()
        return path_to_sw

    def upgrade_via_yaft(self, sw_build, builds_dir=None):
        bts_ws_name = self.ws_du_alias.format(self.bts_id, self.du_id)
        yaft_base_log_dir = os.path.join('/tmp/yaft/', datetime.datetime.now().strftime("%Y%m%d-%H%M%S"))
        local_path_to_sw = self.download_build(sw_build=sw_build, wait_till_downloaded=True, builds_dir=builds_dir)
        if self.bts_du.check_if_local_pc_is_the_same_machine_as_bts_ws(self.bts_id, self.du_id):
            path_to_sw = local_path_to_sw
        else:
            path_to_sw = self.sw_update.copy_sw_build_from_local_unix_to_ws(sw_package_path=local_path_to_sw,
                                                                            bts_id=self.bts_id, du_id=self.du_id)
        self.sw_update.download_yaft()
        self.sw_update.update_software_via_yaft(sw_package_path=path_to_sw,
                                                yaft_log_dir=os.path.join(yaft_base_log_dir, bts_ws_name),
                                                bts_id=self.bts_id, du_id=self.du_id)
        download_files(local_dir=os.path.join(get_builtin_value('OUTPUT_DIR'), 'yaft'),
                       remote_dir=yaft_base_log_dir, remote_file='*', device_name=bts_ws_name)

        return local_path_to_sw

    def download_build(self, sw_build, wait_till_downloaded=False, builds_dir=None):
        build = build_downloader.get(sw_build)
        if build and build['status'] == 'started':
            logging.debug("Downloading build {} already started".format(sw_build))
            if wait_till_downloaded:
                logging.debug("Waiting till downloading {} finish".format(sw_build))
                path_to_sw = build['thread'].join(timeout=2 * 60 * 60)
                build['status'] = 'finished'
                build['path'] = path_to_sw
                return path_to_sw
            else:
                return None
        if build and build['status'] == 'finished':
            return build['path']

        build_downloader[sw_build] = {}
        build = build_downloader.get(sw_build)
        log_info_to_console('Download build {}'.format(sw_build), log_hierarchy=2)
        build['thread'] = ThreadWithReturnValue(target=self.sw_update.download_sw_package,
                                                kwargs={'sw_version': sw_build, 'target_dir': builds_dir})
        build['thread'].start()
        build['status'] = 'started'
        if wait_till_downloaded:
            path_to_sw = build['thread'].join(timeout=2 * 60 * 60)
            return path_to_sw


class UpgradeAndCommissionGnb(UpgradeAndCommissionBts):
    bts_type = 'GNB'

    def __init__(self, du_id=0, bts_id=0):
        super(UpgradeAndCommissionGnb, self).__init__(bts_type=UpgradeAndCommissionGnb.bts_type,
                                                      bts_comm=GnbCommissioning(),
                                                      bts_du=GnbDuOperations(),
                                                      bts_ru=GnbRuOperations(),
                                                      bts_cell=GnbCellOperations(),
                                                      bts_alarm=GnbAlarmVerification(),
                                                      bts_log=GnbLog(),
                                                      bts_asir=GnbAsirHubOperations(),
                                                      sw_update=GnbSwUpdate(),
                                                      du_id=du_id,
                                                      bts_id=bts_id)


class UpgradeAndCommissionEnb(UpgradeAndCommissionBts):
    bts_type = 'ENB'

    def __init__(self, du_id=0, bts_id=0):
        super(UpgradeAndCommissionEnb, self).__init__(bts_type=UpgradeAndCommissionEnb.bts_type,
                                                      bts_comm=EnbCommissioning(),
                                                      bts_du=EnbDuOperations(),
                                                      bts_ru=EnbRuOperations(),
                                                      bts_cell=EnbCellOperations(),
                                                      bts_alarm=EnbAlarmVerification(),
                                                      bts_log=EnbLog(),
                                                      bts_asir=EnbAsirHubOperations(),
                                                      sw_update=EnbSwUpdate(),
                                                      du_id=du_id,
                                                      bts_id=bts_id)
