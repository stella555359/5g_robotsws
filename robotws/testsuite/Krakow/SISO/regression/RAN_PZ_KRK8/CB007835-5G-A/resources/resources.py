"""
    Test related functions
    :author: Piotr Wasek, Miroslaw Wiacek
    :contact: piotr.wasek@nokia.com, miroslaw.wiacek@nokia.com
"""
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.du.sw_update import GnbSwUpdate
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
import re


class CB007835AResources(object):
    def __init__(self):
        self.generic_recommissioning = GnbCommissioning()
        self.cell_operations = GnbCellOperations()
        self.sw_update = GnbSwUpdate()
        self.du_operations = GnbDuOperations()

    def get_current_build_regex(self):
        current = self.du_operations.get_bts_sw_version()
        regex = r"(?P<release>[a-zA-Z0-9]+_ENB_(?P<type>[0-9]{4}))_(?P<date>[0-9]{6})_(?P<id>[0-9]{6})"
        search = re.search(regex, current, re.IGNORECASE)
        if int(search.group("type")) >= 9000:
            return "SBTS00_ENB_9[0-9]{3}_" + search.group("date") + "_" + search.group("id")
        else:
            return current

    def get_previous_sw_build_regex(self):
        """
        Get previous candidate build relative to the current build on BTS (same release)
        It assumes that builds with "9999" after "ENB" are trunk builds, and those have
        a different release prefix than one visible in WebEM

        :return: str regex to be used in curl when searching database for builds
        """
        current = self.du_operations.get_bts_sw_version()
        regex = r"(?P<release>[a-zA-Z0-9]+_ENB_(?P<type>[0-9]{4}))_(?P<date>[0-9]{6})_[0-9]{6}"
        search = re.search(regex, current, re.IGNORECASE)
        if int(search.group("type")) >= 9000:
            return "SBTS00_ENB_9[0-9]{3}_" + "{:06d}".format(int(search.group("date"))-1) + "_[0-9]{6}"
        else:
            return "{}_{:06d}".format(search.group("release"), int(search.group("date"))-1) + "_[0-9]{6}"

    def update_gnb_to_build_via_oam(self, sw_build, timeout):
        """
        Update BTS to given build using OAM, downloading the package if needed

        :param sw_build: build name to update to
        :param timeout: int timeout for update operation
        """
        sw_path = self.sw_update.download_sw_package(sw_build, "/home/ute/Downloads/")
        self.sw_update.update_software(sw_path, timeout=timeout)

    def update_gnb_to_build_via_gui(self, sw_build):
        """
        Update BTS to given build using WebEM, downloading the package if needed

        :param sw_build: build name to update to
        """
        sw_path = self.sw_update.download_sw_package(sw_build, "/home/ute/Downloads/")
        self.sw_update.login_gui()
        self.sw_update.gui_coam.load_software_package_from_local_drive(sw_path)
        self.sw_update.gui_coam.software_update(is_activate=True)
        self.sw_update.logout_gui()

    def _create_update_delta_object(self, to_update):
        """
        Create a serializable object that describes a delta recommissioning for the OAM API

        :param to_update: iterable of tuples (dist_name, dict(parameter_name, new_value))
        :return dict for delta recommissioning
        """
        outer = []
        for t in to_update:
            outer.append({
                "distName": t[0],
                "operation": "update",
                "parameters": [{
                    "parameterName": parameter,
                    "value": t[1][parameter],
                    "operation": "update"
                } for parameter in t[1].keys()],
            })

        return outer

    def recommission_test_parameters(self, parameter_set, bts_id=0, du_id=0):
        """
        Setup test parameters according to given parameter set.
        Parameter set is available in variables.py for this test

        :param parameter_set: dict that holds information about parameters to be changed
        :param bts_id:        int of BTS instance ID
        :param du_id:         int of DU instance ID
        :return:              bool of recommissioning operation status
        """
        parameters_to_update = []
        cell_ids = self.cell_operations.get_all_cells_id()
        cell_params = parameter_set["cell_params"]
        bts_params = parameter_set["bts_params"]

        # Cell parameters
        for cell_id in cell_ids:
            for parameter_name in cell_params["params"].keys():
                parameters_to_update.append((cell_params["path_template"] + str(cell_id),
                                             {parameter_name: cell_params["params"][parameter_name]}))

        # BTS parameters
        for parameter_name in bts_params["params"].keys():
            parameters_to_update.append((bts_params["path_template"],
                                         {parameter_name: bts_params["params"][parameter_name]}))

        delta = self._create_update_delta_object(parameters_to_update)
        result = self.generic_recommissioning.perform_bts_delta_commissioning(delta, bts_id=bts_id, du_id=du_id)
        success = result["commissioningResult"]["activationResult"]["resultNode"]["parameters"]["result"].lower() \
            == "success"

        return success
