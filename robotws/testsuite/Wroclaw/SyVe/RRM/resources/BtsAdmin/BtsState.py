from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsAdminApi import BtsAdminApi
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.NetWorking import NetWorking
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsOam import NR_5G

CELLS_CLASS_MANAGED_OBJECT = 'NRCELL_R'
NOK_STATUSES = ['degraded', 'failed', 'offline', 'off line', 'dependency', 'not installed', 'power off']
SW_INFO = "swInfo"
SW_VERSION = "swVersion"


class BtsState(object):

    def __init__(self):
        self.ips = NetWorking()

    def are_all_cells_on_air(self, gnb_id=0, lmp_ip_if_gnb0=True):
        Logger.debug("Checking if all cells are OnAir")
        cells = self._get_raw_class_name_managed_object(CELLS_CLASS_MANAGED_OBJECT, gnb_id, lmp_ip_if_gnb0)
        for cell in cells:
            state_info = cell["parameters"]
            Logger.debug(f"Cell: {cell['distName']} state info is {state_info}")
            if not self._is_on_air_status(state_info):
                return False
        return True if cells else False

    def is_cell_on_air(self, cell_id, gnb_id=0, lmp_ip_if_gnb0=True):
        Logger.debug(f"Checking if cell {cell_id} is OnAir")
        nr5g_host = self.ips.get_gnb_mplane_ip(gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)
        with BtsAdminApi(bts_host=nr5g_host) as api:
            info = api.get_bts_info()
            assert info["cells"][NR_5G], f"No cells found: {info['cells'][NR_5G]}"
            for cell in info["cells"][NR_5G]:
                if cell["globalCellId"] == cell_id:
                    state_info = cell["status"]
                    return self._is_on_air_status(state_info)

    def are_all_cell_dep_type_as_expected(self, dep_type, gnb_id=0, lmp_ip_if_gnb0=True):
        cell_dep_types = self.get_all_cells_cell_dep_type_values(gnb_id, lmp_ip_if_gnb0)
        Logger.info(f"GNB_{gnb_id} Cells types: {cell_dep_types}")
        for cell in cell_dep_types:
            if cell_dep_types[cell] != dep_type:
                return False
            return True

    def get_all_cells_cell_dep_type_values(self, gnb_id=0, lmp_ip_if_gnb0=True):
        cell_dep_types_dict = {}
        Logger.debug("Getting cellDepType for all configured cells")
        self._assert_bts_commissioned(gnb_id, lmp_ip_if_gnb0)
        for cell in self._get_nr_cells_info(gnb_id, lmp_ip_if_gnb0):
            cell_id = cell["globalCellId"]
            cell_dep_type = cell["cellDepType"]
            cell_dep_types_dict.update({cell_id: cell_dep_type})
        return cell_dep_types_dict

    def is_x2_link_available(self, gnb_id=0, lmp_ip_if_gnb0=True):
        if self._get_raw_class_name_managed_object("LTEENB_R", gnb_id, lmp_ip_if_gnb0):
            return self._is_x2_link_status_correct(gnb_id, lmp_ip_if_gnb0)
        return False

    def confirm_that_all_cells_are_on_air(self, gnb_id=0, lmp_ip_if_gnb0=True):
        cells = self._get_raw_class_name_managed_object(CELLS_CLASS_MANAGED_OBJECT, gnb_id, lmp_ip_if_gnb0)
        assert cells, f"No cells found in {CELLS_CLASS_MANAGED_OBJECT}"
        checked_cells = ", ".join([cell.get("distName").split("/")[-1] for cell in cells])
        Logger.info(f"Confirming cells {checked_cells} OnAir status")
        for cell in cells:
            state_info = cell["parameters"]
            self._confirm_availability_status(cell, state_info, "distName")
            self._confirm_operational_state(cell, state_info, "distName")
        Logger.info("All cells are now OnAir!")

    def confirm_that_cell_is_on_air(self, cell_id, gnb_id=0, lmp_ip_if_gnb0=True):
        nr5g_host = self.ips.get_gnb_mplane_ip(gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)
        Logger.info(f"Confirming cell {cell_id} OnAir status")
        with BtsAdminApi(bts_host=nr5g_host) as api:
            info = api.get_bts_info()
            assert info["cells"][NR_5G], f"No cells found: {info['cells'][NR_5G]}"
            for cell in info["cells"][NR_5G]:
                if cell["globalCellId"] == cell_id:
                    state_info = cell["status"]
                    self._confirm_availability_status(cell, state_info, "globalCellId")
                    self._confirm_operational_state(cell, state_info, "globalCellId")
        Logger.info(f"Cell NRCELL_R-{cell_id} is now OnAir!")

    def are_all_rf_modules_detected(self, gnb_id=0, lmp_ip_if_gnb0=True):
        Logger.debug("Checking if all RF modules are starting up")
        self._assert_bts_commissioned(gnb_id, lmp_ip_if_gnb0)
        for radio in self._get_radio_modules_info(gnb_id, lmp_ip_if_gnb0):
            if radio['status'].get('availabilityStatus') in ['NotInstalled', 'not installed']:
                return False
        return True

    def are_bb_cards_online(self, gnb_id=0, lmp_ip_if_gnb0=True):
        bb_cards_status = self.get_fbb_info(gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)
        Logger.debug("Checking if BB cards are enabled")
        if not bb_cards_status:
            return False
        for bb_card in bb_cards_status:
            if bb_card['status'].get('operationalState').lower() != 'enabled':
                return False
        return True

    def get_fbb_info(self, gnb_id, lmp_ip_if_gnb0):
        with BtsAdminApi(self.ips.get_gnb_mplane_ip(gnb_id, lmp_ip_if_gnb0)) as api:
            return api.get_fbb_info()

    def get_gnb_running_sw_version(self, gnb_id=0, lmp_ip_if_gnb0=True):
        return self.bts_info(gnb_id, lmp_ip_if_gnb0).get(SW_INFO).get(SW_VERSION)

    def get_lte_running_sw_version(self, enb_id=0):
        return self.enb_info(enb_id).get(SW_INFO).get(SW_VERSION)

    def bts_info(self, gnb_id, lmp_ip_if_gnb0):
        with BtsAdminApi(self.ips.get_gnb_mplane_ip(gnb_id, lmp_ip_if_gnb0)) as api:
            return api.get_bts_info(timeout=30)

    def enb_info(self, enb_id):
        with BtsAdminApi(self.ips.get_enb_mplane_ip(enb_id)) as api:
            return api.get_bts_info()

    def get_rats_state(self, gnb_id=0, lmp_ip_if_gnb0=True):
        info = self.bts_info(gnb_id, lmp_ip_if_gnb0)
        return info.get('ratState')

    @staticmethod
    def _is_on_air_status(state_info):
        availability_status = state_info.get("availabilityStatus")
        Logger.debug(f"Availabilty status is: {availability_status}")
        if availability_status is not None and availability_status.lower() in NOK_STATUSES:
            return False
        return True

    @staticmethod
    def _confirm_operational_state(cell, state_info, cell_name_param):
        operational_state = state_info.get("operationalState").lower()
        Logger.debug(f"Cell's {cell[cell_name_param]} operationaState is {operational_state}")
        assert operational_state == 'enabled', \
            f"Cell {cell[cell_name_param]} is not on Air. The operational state is: {operational_state}"

    @staticmethod
    def _confirm_availability_status(cell, state_info, cell_name_param):
        status = state_info.get("availabilityStatus")
        Logger.debug(f"Cell's {cell[cell_name_param]} availability status is {status}")
        if status is not None:
            assert status.lower() not in NOK_STATUSES, \
                f"Cell {cell[cell_name_param]} is not on Air. The availability status is: {status}"

    def _is_x2_link_status_correct(self, gnb_id, lmp_ip_if_gnb0):
        for x2_link in self._get_raw_class_name_managed_object("LTEENB_R", gnb_id, lmp_ip_if_gnb0):
            if x2_link['parameters']['x2LinkStatus'] != 'available':
                return False
        return True

    def _get_raw_class_name_managed_object(self, class_name, gnb_id, lmp_ip_if_gnb0):
        with BtsAdminApi(self.ips.get_gnb_mplane_ip(gnb_id, lmp_ip_if_gnb0)) as api:
            return api.get_managed_objects(class_name=class_name, timeout=30)

    def _get_radio_modules_info(self, gnb_id, lmp_ip_if_gnb0):
        return self.bts_info(gnb_id, lmp_ip_if_gnb0)['radioModules']['rmod']

    def _get_nr_cells_info(self, gnb_id, lmp_ip_if_gnb0):
        return self.bts_info(gnb_id, lmp_ip_if_gnb0)['cells']['nr']

    def _assert_bts_commissioned(self, gnb_id, lmp_ip_if_gnb0):
        assert self._is_bts_commissioned(gnb_id, lmp_ip_if_gnb0), "BTS is not commissioned"

    def _is_bts_commissioned(self, gnb_id, lmp_ip_if_gnb0):
        return False if self.bts_info(gnb_id, lmp_ip_if_gnb0)['status']['proceduralState'] == 'NotCommissioned' \
            else True
