from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsAdminApi import BtsAdminApi
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.NetWorking import NetWorking
from time import sleep, time
LTE_CELL = "MRBTS-{enb_id}/LNBTS-{enb_id}/LNCEL-{cell_number}"
NR_CELL = "MRBTS-{gnb_id}/NRBTS-{gnb_id}/NRCELL-{cell_number}"
LTE = "lte"
NR_5G = "nr"
RAT_RESET_TIMEOUT = 300


class BtsOam(object):

    def __init__(self):
        self.ips = NetWorking()

    def perform_nr_rat_reset(self, reset_type="Soft", sbts_id=0, lmp_ip_if_gnb0=True):
        self._perform_rat_reset("NR", reset_type, sbts_id=sbts_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)

    def perform_lte_rat_reset(self, reset_type="Soft", sbts_id=0, lmp_ip_if_gnb0=True):
        self._perform_rat_reset("LTE", reset_type, sbts_id=sbts_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)

    def make_sure_gnb_site_is_blocked(self, gnb_id=0, lmp_ip_if_gnb0=True):
        nr5g_host = self.ips.get_gnb_mplane_ip(gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)
        Logger.info("Making sure gNB_{} is blocked".format(gnb_id))
        with BtsAdminApi(bts_host=nr5g_host) as api:
            if api.get_bts_info().get('status').get('blockingState').lower() == 'blocked':
                Logger.warning("gNB_{} already blocked!".format(gnb_id))
                return
            api.block()

    def make_sure_enb_site_is_blocked(self, enb_id=0):
        enb_host = self.ips.get_enb_mplane_ip(enb_id)
        Logger.info("Making sure eNB_{} is blocked".format(enb_id))
        with BtsAdminApi(bts_host=enb_host) as api:
            if api.get_bts_info().get('status').get('blockingState').lower() == 'blocked':
                return
            api.block()

    def reset_gnb_site(self, gnb_id=0, lmp_ip_if_gnb0=True):
        nr5g_host = self.ips.get_gnb_mplane_ip(gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)
        Logger.info("Resetting gNB")
        with BtsAdminApi(bts_host=nr5g_host) as api:
            api.reset_site()

    def reset_enb_site(self, enb_id=0):
        enb_host = self.ips.get_enb_mplane_ip(enb_id)
        Logger.info("Resetting eNB")
        with BtsAdminApi(bts_host=enb_host) as api:
            api.reset_site()

    def block_gnb_cell(self, cell_number, gnb_id=0, lmp_ip_if_gnb0=True):
        Logger.info("Blocking gNB_{} cell {}".format(gnb_id, cell_number))
        cell_dist_name = NR_CELL.format(gnb_id=Env.GNBS[gnb_id].global_bts_id, cell_number=cell_number)
        nr5g_host = self.ips.get_gnb_mplane_ip(gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)
        self._block_cell(target_host=nr5g_host, cell_dist_name=cell_dist_name)
        self._wait_for_cell_blocked(nr5g_host, NR_5G, cell_number, timeout=60, interval=5)

    def block_gnb_cells(self, cells_numbers, gnb_id=0, lmp_ip_if_gnb0=True):
        Logger.info("Blocking gNB_{} cells {}".format(gnb_id, cells_numbers))
        cells_dist_names = [NR_CELL.format(gnb_id=Env.GNBS[gnb_id].global_bts_id, cell_number=cell_number)
                            for cell_number in cells_numbers]
        nr5g_host = self.ips.get_gnb_mplane_ip(gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)
        self._block_cells(target_host=nr5g_host, cells_dist_names=cells_dist_names)
        self._wait_for_cells_blocked(nr5g_host, NR_5G, cells_numbers, timeout=60, interval=5)

    def unblock_gnb_cell(self, cell_number, gnb_id=0, lmp_ip_if_gnb0=True):
        Logger.info("Unblocking gNB_{} cell {}".format(gnb_id, cell_number))
        cell_dist_name = NR_CELL.format(gnb_id=Env.GNBS[gnb_id].global_bts_id, cell_number=cell_number)
        nr5g_host = self.ips.get_gnb_mplane_ip(gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)
        self._unblock_cell(target_host=nr5g_host, cell_dist_name=cell_dist_name)
        self._wait_for_cell_unblocked(nr5g_host, NR_5G, cell_number, timeout=60, interval=5)

    def unblock_gnb_cells(self, cells_numbers, gnb_id=0, lmp_ip_if_gnb0=True):
        Logger.info("Unblocking gNB_{} cells {}".format(gnb_id, cells_numbers))
        cells_dist_names = [NR_CELL.format(gnb_id=Env.GNBS[gnb_id].global_bts_id, cell_number=cell_number)
                            for cell_number in cells_numbers]
        nr5g_host = self.ips.get_gnb_mplane_ip(gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)
        self._unblock_cells(target_host=nr5g_host, cells_dist_names=cells_dist_names)
        self._wait_for_cells_unblocked(nr5g_host, NR_5G, cells_numbers, timeout=60, interval=5)

    def make_sure_gnb_cell_is_unblocked(self, cell_number, gnb_id=0, lmp_ip_if_gnb0=True):
        nr5g_host = self.ips.get_gnb_mplane_ip(gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)
        if self._is_cell_blocked(target_host=nr5g_host, technology=NR_5G, cell_number=cell_number):
            self.unblock_gnb_cell(cell_number=cell_number, gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)
        Logger.info(f"Unblocked gNB_{gnb_id} cell {cell_number}")

    def make_sure_gnb_cell_is_blocked(self, cell_number, gnb_id=0, lmp_ip_if_gnb0=True):
        nr5g_host = self.ips.get_gnb_mplane_ip(gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)
        if self._is_cell_unblocked(target_host=nr5g_host, technology=NR_5G, cell_number=cell_number):
            self.block_gnb_cell(cell_number=cell_number, gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)
        Logger.info(f"Blocked gNB_{gnb_id} cell {cell_number}")

    def make_sure_gnb_cells_are_blocked(self, cells_numbers, gnb_id=0, lmp_ip_if_gnb0=True):
        nr5g_host = self.ips.get_gnb_mplane_ip(gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)
        cells_to_be_blocked = [cell_id for cell_id, cell_blocked
                               in self._get_cells_blocked_states(target_host=nr5g_host,
                                                                 technology=NR_5G,
                                                                 cells_numbers=cells_numbers).items()
                               if cell_blocked is False]
        self.block_gnb_cells(cells_numbers=cells_to_be_blocked, gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)

    def make_sure_gnb_cells_are_unblocked(self, cells_numbers, gnb_id=0, lmp_ip_if_gnb0=True):
        nr5g_host = self.ips.get_gnb_mplane_ip(gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)
        cells_to_be_unblocked = [cell_id for cell_id, cell_blocked
                                 in self._get_cells_blocked_states(target_host=nr5g_host,
                                                                   technology=NR_5G,
                                                                   cells_numbers=cells_numbers).items() if cell_blocked]
        self.unblock_gnb_cells(cells_numbers=cells_to_be_unblocked, gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)

    def block_enb_cell(self, cell_number, enb_id=0):
        Logger.info("Blocking enb cell {}".format(cell_number))
        cell_dist_name = LTE_CELL.format(enb_id=Env.ENBS[enb_id].global_bts_id, cell_number=cell_number)
        self._block_cell(target_host=self.ips.get_enb_mplane_ip(enb_id), cell_dist_name=cell_dist_name)
        self._wait_for_cell_blocked(self.ips.get_enb_mplane_ip(enb_id), LTE, cell_number, timeout=60, interval=5)

    def unblock_enb_cell(self, cell_number, enb_id=0):
        Logger.info("Unblocking enb cell {}".format(cell_number))
        cell_dist_name = LTE_CELL.format(enb_id=Env.ENBS[enb_id].global_bts_id, cell_number=cell_number)
        self._unblock_cell(target_host=self.ips.get_enb_mplane_ip(enb_id), cell_dist_name=cell_dist_name)
        self._wait_for_cell_unblocked(self.ips.get_enb_mplane_ip(enb_id), LTE, cell_number, timeout=60, interval=5)

    def make_sure_enb_cell_is_blocked(self, cell_number, enb_id=0):
        lte4g_host = self.ips.get_enb_mplane_ip(enb_id=enb_id)
        if self._is_cell_unblocked(target_host=lte4g_host, technology=LTE, cell_number=cell_number):
            self.block_enb_cell(cell_number=cell_number, enb_id=enb_id)
        Logger.info(f"Blocked eNB_{enb_id} cell {cell_number}")

    def make_sure_enb_cell_is_unblocked(self, cell_number, enb_id=0):
        lte4g_host = self.ips.get_enb_mplane_ip(enb_id=enb_id)
        if self._is_cell_blocked(target_host=lte4g_host, technology=LTE, cell_number=cell_number):
            self.unblock_enb_cell(cell_number=cell_number, enb_id=enb_id)
        Logger.info(f"Unblocked eNB_{enb_id} cell {cell_number}")

    def block_all_gnb_cells(self, gnb_id=0, lmp_ip_if_gnb0=True):
        try:
            nr5g_host = self.ips.get_gnb_mplane_ip(gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)
            nr_cells_list = self._get_cells_global_id(ip_host=nr5g_host, technology=NR_5G)
            for cell_id in nr_cells_list:
                if self._is_cell_unblocked(target_host=nr5g_host, technology=NR_5G, cell_number=cell_id):
                    self.block_gnb_cell(cell_id, gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)
        except Exception as error:
            Logger.warning("Block NR cell failed err: {}".format(error))

    def block_all_enb_cells(self, enb_id=0):
        try:
            lte4g_host = self.ips.get_enb_mplane_ip(enb_id=enb_id)
            lte_cells_list = self._get_cells_global_id(ip_host=lte4g_host, technology=LTE)
            for cell_id in lte_cells_list:
                self.make_sure_enb_cell_is_blocked(cell_number=cell_id, enb_id=enb_id)
        except Exception as error:
            Logger.warning("Block LTE cell failed err: {}".format(error))

    def make_sure_dss_cell_is_running(self, enb_dss_cell_id, enb_id=0, waiting_time=300):
        cell_dist_name = LTE_CELL.format(enb_id=Env.ENBS[enb_id].global_bts_id, cell_number=enb_dss_cell_id)
        Logger.info(f"Waiting for DSS cell {cell_dist_name} to be running on eNB_{enb_id}")
        start_time = time()
        while time() - start_time < waiting_time:
            if self._is_dss_cell_running(cell_dist_name, enb_id):
                Logger.info(f"DSS cell {cell_dist_name} is running on eNB_{enb_id}")
                return
            sleep(5)
        assert False, (f"DSS cell {cell_dist_name} on eNB_{enb_id} is not running, "
                       f"current state is {self._get_dss_cell_state(cell_dist_name, enb_id)}")

    def _is_dss_cell_running(self, cell_dist_name, enb_id):
        return self._get_dss_cell_state(cell_dist_name, enb_id).lower() == "running"

    def _get_dss_cell_state(self, cell_dist_name, enb_id):
        with BtsAdminApi(bts_host=self.ips.get_enb_mplane_ip(enb_id)) as api:
            dss_cell_info = api.get_parameter_by_distname(f"{cell_dist_name}/DSSNR-0/CRMINFO-0")
            dss_cell_state = dss_cell_info[0].get('parameters').get('crmStatus')
            Logger.debug(f"Current DSS Cell: {cell_dist_name} state is {dss_cell_state}")
            return dss_cell_state

    @staticmethod
    def _block_cell(target_host, cell_dist_name):
        with BtsAdminApi(bts_host=target_host) as api:
            api.block_cell(dist_name=cell_dist_name)

    @staticmethod
    def _block_cells(target_host, cells_dist_names):
        with BtsAdminApi(bts_host=target_host) as api:
            for cell_dist_name in cells_dist_names:
                api.block_cell(dist_name=cell_dist_name)

    @staticmethod
    def _unblock_cell(target_host, cell_dist_name):
        with BtsAdminApi(bts_host=target_host) as api:
            api.unblock_cell(dist_name=cell_dist_name)

    @staticmethod
    def _unblock_cells(target_host, cells_dist_names):
        with BtsAdminApi(bts_host=target_host) as api:
            for cell_dist_name in cells_dist_names:
                api.unblock_cell(dist_name=cell_dist_name)

    def _wait_for_cell_blocked(self, target_host, technology, cell_number, timeout, interval):
        Logger.debug("Waiting for {} cell {} block".format(technology, cell_number))
        fail_msg = "Cell {} was not blocked within {}s timeout".format(cell_number, timeout)
        self._wait_for_cell_state_change(target_host, technology, cell_number, fail_msg=fail_msg,
                                         check_function=self._is_cell_blocked, timeout=timeout, interval=interval)

    def _wait_for_cell_unblocked(self, target_host, technology, cell_number, timeout, interval):
        Logger.debug("Waiting for {} cell {} unblock".format(technology, cell_number))
        fail_msg = "Cell {} was still blocked within {}s timeout".format(cell_number, timeout)
        self._wait_for_cell_state_change(target_host, technology, cell_number, fail_msg=fail_msg,
                                         check_function=self._is_cell_unblocked, timeout=timeout, interval=interval)

    def _wait_for_cells_blocked(self, target_host, technology, cells_numbers, timeout, interval):
        Logger.debug("Waiting for {} cells {} block".format(technology, cells_numbers))
        fail_msg = "Cells {} were not blocked within {}s timeout".format(cells_numbers, timeout)
        self._wait_for_cell_state_change(target_host, technology, cells_numbers, fail_msg=fail_msg,
                                         check_function=self._are_cells_blocked, timeout=timeout, interval=interval)

    def _wait_for_cells_unblocked(self, target_host, technology, cells_numbers, timeout, interval):
        Logger.debug("Waiting for {} cells {} unblock".format(technology, cells_numbers))
        fail_msg = "Cell {} were still blocked within {}s timeout".format(cells_numbers, timeout)
        self._wait_for_cell_state_change(target_host, technology, cells_numbers, fail_msg=fail_msg,
                                         check_function=self._are_cells_unblocked, timeout=timeout, interval=interval)

    @staticmethod
    def _wait_for_cell_state_change(target_host, technology, cell_number, fail_msg, check_function, timeout, interval):
        while timeout > 0:
            if check_function(target_host, technology, cell_number):
                return
            sleep(interval)
            timeout -= interval
        assert False, fail_msg

    def _is_cell_unblocked(self, target_host, technology, cell_number):
        return not self._is_cell_blocked(target_host, technology, cell_number)

    def _is_cell_blocked(self, target_host, technology, cell_number):
        with BtsAdminApi(bts_host=target_host) as api:
            info = api.get_bts_info()
            if info["cells"][technology]:
                state = self._get_blocking_state_from_bts_info(info, technology, cell_number)
            return True if state.lower() == "blocked" else False

    def _are_cells_blocked(self, target_host, technology, cells_numbers):
        return all(self._get_cells_blocked_states(target_host, technology, cells_numbers).values())

    def _are_cells_unblocked(self, target_host, technology, cells_numbers):
        return not any(self._get_cells_blocked_states(target_host, technology, cells_numbers).values())

    def _get_cells_blocked_states(self, target_host, technology, cells_numbers):
        with BtsAdminApi(bts_host=target_host) as api:
            info = api.get_bts_info()
            if info["cells"][technology]:
                return {cell_number: self._get_blocking_state_from_bts_info(info,
                                                                            technology,
                                                                            cell_number).lower() == "blocked"
                        for cell_number in cells_numbers}

    @staticmethod
    def _get_blocking_state_from_bts_info(bts_info, technology, cell_number):
        for cell in bts_info["cells"][technology]:
            if cell["globalCellId"] == cell_number:
                return cell["status"]["blockingState"]

    @staticmethod
    def _get_cells_global_id(ip_host, technology):
        with BtsAdminApi(bts_host=ip_host) as api:
            cells_info = api.get_bts_info()["cells"][technology]
            return [cell_info["globalCellId"] for cell_info in cells_info]

    def _perform_rat_reset(self, rat_type, reset_type, sbts_id=0, lmp_ip_if_gnb0=True):
        sbts_host = self.ips.get_gnb_mplane_ip(gnb_id=sbts_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)
        with BtsAdminApi(bts_host=sbts_host) as api:
            api.rat_reset(rat_type=rat_type, timeout=RAT_RESET_TIMEOUT, reset_type=reset_type)
