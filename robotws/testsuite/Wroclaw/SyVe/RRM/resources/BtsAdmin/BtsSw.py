from testsuite.Wroclaw.SyVe.RRM.resources.TimeStamp import TimeStamp
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsAdminApi import BtsAdminApi
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from time import sleep
from testsuite.Wroclaw.SyVe.RRM.resources.NetWorking import NetWorking
from testsuite.Wroclaw.SyVe.RRM.resources.Troubleshooting import Troubleshooting

SW_UPDATE_ADMIN_TIMEOUT = 40 * 60  # SW update may take more than 30m, 40m in seconds to be sure
RETRY_UPDATE_TIMEOUT = 45 * 60   # To Try once again in case of SW_UPDATE_ADMIN_TIMEOUT


class BtsSw(object):

    def __init__(self):
        self.ips = NetWorking()

    def software_update(self, path_to_sw_package, gnb_id=0, lmp_ip_if_gnb0=True, independent_sw_update_type="All",
                        override_ru_software=False):
        Logger.info("Updating {} SW on gNB, update type: {}".format(path_to_sw_package,
                                                                    independent_sw_update_type))
        with BtsAdminApi(self.ips.get_gnb_mplane_ip(gnb_id, lmp_ip_if_gnb0)) as api:
            info = api.update_software(sw_package=path_to_sw_package, should_activate=True,
                                       override_ru_software=override_ru_software,
                                       independent_sw_update_type=independent_sw_update_type,
                                       timeout=SW_UPDATE_ADMIN_TIMEOUT)
        BtsAdminApi(self.ips.get_gnb_mplane_ip(gnb_id, lmp_ip_if_gnb0)).wait_for_admin_connection_possibility()
        Logger.info("SW {} Updated successfully and connection with admin is again possible".format(info))

    def try_to_update_software_ignoring_procedure_failures(self, path_to_sw_package, timeout=RETRY_UPDATE_TIMEOUT,
                                                           gnb_id=0, lmp_ip_if_gnb0=True):
        interval = 30
        update_procedure_end_time = TimeStamp().unix_timestamp + timeout
        Logger.info("Trying perform several update attempts within {}m".format(timeout//60))
        while TimeStamp().unix_timestamp < update_procedure_end_time:
            Troubleshooting().check_active_fault_and_freeze_test_line_if_forbidden_fault_found()
            try:
                self.software_update(path_to_sw_package, gnb_id, lmp_ip_if_gnb0)
                return
            except Exception as e:
                Logger.debug("SW update procedure exception: {}".format(e))
                sleep(interval)
        assert False, "SW update procedure has failed with every attempt during given {}m time".format(timeout//60)
