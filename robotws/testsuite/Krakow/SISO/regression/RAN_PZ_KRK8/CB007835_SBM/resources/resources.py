"""
    Test related functions
    :author: Bartosz Odziomek
    :contact: bartosz.odziomek@nokia.com
"""
import re
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.du.sw_update import GnbSwUpdate
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations


class CB007835SBM(object):
    def __init__(self):
        self.generic_recommissioning = GnbCommissioning()
        self.cell_operations = GnbCellOperations()
        self.sw_update = GnbSwUpdate()
        self.du_operations = GnbDuOperations()
        self.current_build_regex = re.compile(
            r"(?P<release>[a-zA-Z0-9]+_ENB_(?P<type>[0-9]{4}))_(?P<date>[0-9]{6})_(?P<id>[0-9]{6})", re.IGNORECASE)
        self.previous_build_regex = re.compile(
            r"(?P<release>[a-zA-Z0-9]+_ENB_(?P<type>[0-9]{4}))_(?P<date>[0-9]{6})_[0-9]{6}", re.IGNORECASE)

    def get_current_build_regex(self):
        current = self.du_operations.get_bts_sw_version()
        search = self.current_build_regex.search(current)
        if int(search.group("type")) >= 9000:
            return f"SBTS00_ENB_9[0-9]{{3}}_{search.group('date')}_{search.group('id')}"
        else:
            return current

    def get_previous_sw_build_regex(self):
        current = self.du_operations.get_bts_sw_version()
        search = self.previous_build_regex.search(current)
        if int(search.group("type")) >= 9000:
            return f"SBTS00_ENB_9[0-9]{{3}}_{int(search.group('date')) - 1:06d}_[0-9]{{6}}"
        else:
            return f"{search.group('release')}_{int(search.group('date')) - 1:06d}_[0-9]{{6}}"

    def update_gnb_to_build_via_oam(self, sw_build, timeout):
        sw_path = self.sw_update.download_sw_package(sw_build, "/home/ute/Downloads/")
        self.sw_update.update_software(sw_path, timeout=timeout)

    def update_gnb_to_build_via_gui(self, sw_build):
        sw_path = self.sw_update.download_sw_package(sw_build, "/home/ute/Downloads/")
        self.sw_update.login_gui()
        self.sw_update.gui_coam.load_software_package_from_local_drive(sw_path)
        self.sw_update.gui_coam.software_update(is_activate=True)
        self.sw_update.logout_gui()

    @staticmethod
    def _create_update_delta_object(to_update):
        return [{
            "distName": t[0],
            "operation": "update",
            "parameters": [{
                "parameterName": parameter,
                "value": t[1][parameter],
                "operation": "update"
            } for parameter in t[1].keys()],
        } for t in to_update]

    def recommission_test_parameters(self, parameter_set, bts_id=0, du_id=0):
        parameters_to_update = []
        cell_ids = self.cell_operations.get_all_cells_id()
        cell_params = parameter_set["cell_params"]
        bts_params = parameter_set["bts_params"]

        # Cell parameters
        for cell_id in cell_ids:
            parameters_to_update.extend(
                (cell_params["path_template"] + str(cell_id), {parameter_name: cell_params["params"][parameter_name]})
                for parameter_name in cell_params["params"].keys()
            )

        # BTS parameters
        parameters_to_update.extend(
            (bts_params["path_template"], {parameter_name: bts_params["params"][parameter_name]})
            for parameter_name in bts_params["params"].keys()
        )

        delta = self._create_update_delta_object(parameters_to_update)
        result = self.generic_recommissioning.perform_bts_delta_commissioning(delta, bts_id=bts_id, du_id=du_id)
        success = result["commissioningResult"]["activationResult"]["resultNode"]["parameters"][
                      "result"].lower() == "success"

        return success
