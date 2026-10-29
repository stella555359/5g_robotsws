from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsAdminApi import BtsAdminApi
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.NetWorking import NetWorking
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
import re
from testsuite.Wroclaw.SyVe.RRM.resources.TimeStamp import TimeStamp
from time import sleep


class BtsConfig(object):

    def __init__(self):
        self.ips = NetWorking()

    def perform_full_commissioning(self, scf_path, gnb_id=0,
                                   skip_parameter_relation_errors=True, timeout=900, lmp_ip_if_gnb0=True):
        try:
            self._commission_bts(scf_path, gnb_id, skip_parameter_relation_errors, timeout, lmp_ip_if_gnb0,
                                 bts_type="gnb")
        finally:
            Env.set_suite_flag_if_was_attempt_to_commission_bts()

    def perform_full_commissioning_enb(self, scf_path, enb_id=0, skip_parameter_relation_errors=True, timeout=900):
        try:
            self._commission_bts(scf_path, enb_id, skip_parameter_relation_errors, timeout,
                                 bts_type="enb")
        finally:
            Env.set_suite_flag_if_was_attempt_to_commission_bts()

    def perform_delta_commissioning(self, delta, gnb_id=0,
                                    skip_parameter_relation_errors=True, timeout=900, lmp_ip_if_gnb0=True):
        Logger.info("Performing delta commissioning with:\n {}".format(delta))
        with BtsAdminApi(self.ips.get_gnb_mplane_ip(gnb_id, lmp_ip_if_gnb0)) as api:
            status = api.perform_delta_recommissioning(delta_file=delta,
                                                       skip_parameter_relation_errors=skip_parameter_relation_errors,
                                                       timeout=timeout)
        Logger.debug("Received recommissioning status: {}".format(status))

    def perform_cell_parameter_recommissioning(self, cell_id, parameter, value, operation='update',
                                               skip_parameter_relation_errors=False, should_activate=True, timeout=300,
                                               gnb_id=0, lmp_ip_if_gnb0=True):
        bts_id = Env.GNBS[gnb_id].global_bts_id
        dist_name = "MRBTS-{bts_id}/NRBTS-{bts_id}/NRCELL-{cell_id}".format(bts_id=bts_id, cell_id=cell_id)
        with BtsAdminApi(self.ips.get_gnb_mplane_ip(gnb_id, lmp_ip_if_gnb0)) as api:
            status = api.perform_parameter_recommissioning(
                dist_name, parameter, operation, value, skip_parameter_relation_errors=skip_parameter_relation_errors,
                should_activate=should_activate, timeout=timeout)
            Logger.debug("Received parameter recommissioning status: {}".format(status))

    def perform_parameter_recommissioning(self, dist_name, parameters, value, operation='update', gnb_id=0,
                                          lmp_ip_if_gnb0=True, skip_parameter_relation_errors=False,
                                          should_activate=True, timeout=300):
        with BtsAdminApi(self.ips.get_gnb_mplane_ip(gnb_id, lmp_ip_if_gnb0)) as api:
            for parameter in parameters:
                Logger.info("Performing {} {} with new value '{}'".format(parameter, operation, value))
                status = api.perform_parameter_recommissioning(
                    dist_name, parameter, operation, value,
                    skip_parameter_relation_errors=skip_parameter_relation_errors,
                    should_activate=should_activate, timeout=timeout)
                Logger.debug("Received parameter '{}' recommissioning status: {}".format(parameter, status))

    def get_csi_report_periodicity_for_cells(self, gnb_id=0, lmp_ip_if_gnb0=True):
        csi_report_periodicity_dict = {}
        with BtsAdminApi(self.ips.get_gnb_mplane_ip(gnb_id, lmp_ip_if_gnb0)) as api:
            for cell_info in api.get_managed_objects(class_name="NRCELL_A", timeout=30):
                assert cell_info['parameters']['periodicCsiAcquisition']['csiReportPeriodicity'],\
                    "Problem with SCF check parameter csiReportPeriodicity. For cell info: {}".format(cell_info)
                dist_name = cell_info['distName'].split('/')[-1]
                csi_report_periodicity = re.search(r'(\d+)', cell_info['parameters']['periodicCsiAcquisition']
                                                                      ['csiReportPeriodicity']).group(1)
                csi_report_periodicity_dict.update({dist_name: csi_report_periodicity})
            return csi_report_periodicity_dict

    def _commission_bts(self, scf_path, bts_id=0, skip_parameter_relation_errors=True, timeout=900,
                        lmp_ip_if_gnb0=True, bts_type="gnb"):
        from taf.internal.sbts.admin.exceptions.exception import AdminApiProcedureFailureException
        interval = 30
        timeout_for_cplane_busy = 1000
        cplane_timeout = TimeStamp().unix_timestamp + timeout_for_cplane_busy
        while cplane_timeout > TimeStamp().unix_timestamp:
            try:
                Logger.info("Performing full commissioning with {}".format(scf_path))
                bts_ip = self.ips.get_gnb_mplane_ip(bts_id, lmp_ip_if_gnb0) if bts_type == "gnb" \
                    else self.ips.get_enb_mplane_ip(bts_id)
                with BtsAdminApi(bts_ip) as api:
                    status = api.perform_commissioning(scf_file=scf_path,
                                                       skip_parameter_relation_errors=skip_parameter_relation_errors,
                                                       timeout=timeout)
                    Logger.debug("Received commissioning status: {}".format(status))
                return
            except AdminApiProcedureFailureException as error:
                Logger.debug(f"Log error AdminApiProcedureFailureException: {error.args}")
                if "CPlane is busy" in str(error):
                    Logger.info(f"Wait {interval}s and check if CPlane is not busy")
                else:
                    assert False, "Commissioning has failed on other AdminApiProcedureFailureException error"
            sleep(interval)
        assert False, "Commissioning has failed, please check the logs - timeout"
