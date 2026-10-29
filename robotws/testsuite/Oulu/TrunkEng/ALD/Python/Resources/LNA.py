import re
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info
from testsuite.Oulu.TrunkEng.ALD.Python.Resources.AldRMOD import AldRMOD


class LNA:

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.rmod = AldRMOD()
        self.radios = None
        self.lnas = None
        self.loglinks = None
        self.mhas = None
        self.bts_info = None

    def find_lnas_from_bts(self, uncommissioned=False, given_mha=None):
        """
         Gets all the information for LnaUnit object and adds it to a list.

        :param bool uncommissioned: Used for uncommissioned MHAs, False by default
        :param obj given_mha: Used for uncommissioned MHAs, None by default
        :return list[LnaUnit]: List of LNA objects
        """
        self.bts_info = self.admin.get_bts_info()
        self.radios = self.rmod.get_radio_dist_names()
        if not uncommissioned:
            self.lnas = self._get_lnas_from_managed_objects()
        else:
            self.lnas = self._get_lnas_from_managed_objects(given_mha=given_mha)
        self.loglinks = self._get_loglink_tuples()
        self.mhas = self._get_objects("ALD_R")
        lna_units = []
        for mha_object in self.mhas:
            dist_name = mha_object["distName"].split("/")
            dist_name = dist_name[-1]
            for config_lna, runtime_lna, gain, availability_status, unit_path in self.lnas:
                # Uncommissioned MHA/LNA
                if config_lna is None and gain is None:
                    lna = LnaUnit()
                    self._handle_uncommissioned_lna(lna, given_mha, runtime_lna, availability_status, unit_path)
                    if lna not in lna_units:
                        lna_units.append(lna)
                if dist_name in runtime_lna:
                    lna = LnaUnit()
                    for first_endpoint, second_endpoint, link_mode in self.loglinks:
                        if first_endpoint in runtime_lna or second_endpoint in runtime_lna:
                            self._set_lna_attributes(lna, first_endpoint, second_endpoint, runtime_lna, config_lna,
                                                     link_mode, unit_path)
                            lna.gain = gain
                            self._check_lna_status(lna, availability_status)
                    if lna.name and lna not in lna_units:
                        lna_units.append(lna)
        return lna_units

    @staticmethod
    def print_lna_details(lna):
        info("status: {}, name: {}, dist_name: {}, unit path: {},"
             " hw path: {}, data: {}, dc: {}, gain: {}, cells: {}".format(lna.status, lna.name, lna.dist_name,
                                                                          lna.unit_path, lna.hw_path, lna.data, lna.dc,
                                                                          lna.gain, list(lna.cells.keys())))

    def _handle_uncommissioned_lna(self, lna, given_mha, runtime_lna, availability_status, unit_path):
        """
        Handles linking RMOD/ANTL with ALD_R/LNA_R for uncommissioned MHA/LNAs

        :param LnaUnit lna: LNA object
        :param mha_details given_mha: MHA object from ALD.py, e.g. ALD_R-x
        :param runtime_lna: Index of _get_objects("LNA_R")["distName"], e.g. ALD_R-x/LNA_R-x
        :param availability_status:
        :return:
        """
        for first_endpoint, second_endpoint, link_mode in self.loglinks:
            for config_radio, runtime_radio in self.radios:
                if given_mha in first_endpoint or given_mha in second_endpoint:
                    if runtime_radio in first_endpoint or runtime_radio in second_endpoint:
                        if link_mode["configuration"] and given_mha in runtime_lna:
                            lna.dist_name = "{}/{}".format(config_radio, runtime_lna)
                            lna.status = availability_status
                            lna.unit_path = unit_path
                            self._set_hw_path_for_lna(runtime_radio, config_radio, lna, uncommissioned=True,
                                                      runtime_lna=runtime_lna)

    def _set_lna_attributes(self, lna, first_endpoint, second_endpoint, runtime_lna, config_lna, link_mode, obj_path):
        """
        Sets all parameters for LNA object excluding gain and status

        :param LnaUnit lna: LNA object
        :param obj first_endpoint: loglinks first endpoint
        :param obj second_endpoint: loglinks second endpoint
        :param obj runtime_lna: Index of _get_objects("LNA_R")["distName"], e.g. ALD_R-x/LNA_R-x
        :param obj config_lna: Index of _get_objects("LNA_R")["parameters"]["configDN"], e.g. ALD-x/LNA-x
        :param obj link_mode: contains information about data, dc, configuration and synchronization
        """
        for config_radio, runtime_radio in self.radios:
            if runtime_radio in first_endpoint or runtime_radio in second_endpoint:
                radio_name = ""
                splitted_runtime_radio = runtime_radio.split("/")
                first_runtime_radio = splitted_runtime_radio[0]
                self._find_lna_configuration_identifier(lna, first_runtime_radio, radio_name, config_lna)
                self._find_affected_cells(lna, config_radio)
                lna.dist_name = self._get_complete_dist_names(given_lna=runtime_lna)
                self._set_data_and_dc(lna, link_mode, config_radio)
                self._set_hw_path_for_lna(runtime_radio, config_radio, lna)
                lna.unit_path = obj_path

    def _set_hw_path_for_lna(self, runtime_radio, config_radio, lna, uncommissioned=False, runtime_lna=""):
        """
        Sets hw path for LNA.

        :param runtime_radio:
        :param config_radio:
        :param runtime_lna:
        """
        split_config_radio = config_radio.split("/")[0]
        split_runtime_radio = runtime_radio.split("/")[0]
        antl_number = ""
        for radio in self.bts.radios:
            radio_hw_path = radio.hw_path
            pattern = re.compile(r'RMOD_R-\d+/ANTL_R-(?P<antl_no>\d+)')
            match = pattern.match(runtime_radio)
            if match:
                antl_number = match.group('antl_no')
            antl_for_hw_path = f"ant{antl_number}"
            if (split_config_radio in radio.scf_dist_name and lna.dc and antl_number == lna.dc[-1] and
                    config_radio in lna.dist_name and split_runtime_radio in radio_hw_path):
                hw_path = f"{radio_hw_path}/{antl_for_hw_path}"
                lna.hw_path = hw_path
            elif (uncommissioned and split_config_radio in radio.scf_dist_name and config_radio in lna.dist_name and
                    split_runtime_radio in radio_hw_path):
                hw_path = f"{radio_hw_path}/{antl_for_hw_path}/{runtime_lna}"
                lna.hw_path = hw_path

    def _find_lna_configuration_identifier(self, lna, runtime_radio, radio_name, config_lna):
        """
        Finds the Radio Configuration Identifier

        :param LnaUnit lna: LNA object
        :param obj runtime_radio: e.g. RMOD_R-x
        :param str radio_name: empty string, will be e.g. FRGS(x.x.x.x)-ALDx(x)
        :param obj config_lna: ALD-x/LNA-x
        """
        for rf in self.bts.radios:
            if runtime_radio in rf.dist_name:
                radio_name += rf.name
                split_config_lna = config_lna.split("/")
                lna_name = split_config_lna[-1]
                lna_name = lna_name.strip("LNA-")
                mha_name = split_config_lna[-2]
                mha_name = mha_name.replace("-", "")
                radio_name += "-{}({})".format(mha_name, lna_name)
                lna.name = radio_name

    @staticmethod
    def _check_lna_status(lna, availability_status):
        """
        Checks the status of LNA

        :param LnaUnit lna:
        :param obj availability_status:
        """
        if availability_status is None:
            lna.status = "OK"
        else:
            lna.status = availability_status

    def _find_affected_cells(self, lna, config_radio):
        """
        Compares the RMOD/ANTL found from a cell to the config_radio. If a match is found, adds the cell to cells list

        :param LnaUnit lna: LNA object
        :param obj config_radio: e.g. RMOD-x/ANTL-x
        """
        for physical_id, info_dict in self.bts.cells.items():
            for index in info_dict["carrierList"]:
                config_antennaline = index["antennaLineId"]["configuration"]
                if config_radio in config_antennaline:
                    if physical_id not in lna.cells:
                        lna.cells[physical_id] = info_dict

    @staticmethod
    def _set_data_and_dc(lna, link_mode, config_radio):
        """
        Sets data and dc to LNA object

        :param LnaUnit lna: LNA object
        :param obj link_mode: contains information about data, dc, configuration and synchronization
        :param obj config_radio: e.g. RMOD-x/ANTL-x
        """
        if link_mode["data"] and link_mode["dc"]:
            lna.data = config_radio
            lna.dc = config_radio
        elif link_mode["data"] and not link_mode["dc"]:
            lna.data = config_radio
        elif not link_mode["data"] and link_mode["dc"]:
            lna.dc = config_radio

    def _get_lnas_from_managed_objects(self, given_mha=None):
        """
        Gets information about lna from _get_objects

        :param (optional) str given_mha: specific MHA, used for checking uncommissioned LNAs
        :return List[Tuple(str, str, Any)]: (configured name, runtime name, lna gain)
        """

        lna_tuples = []
        lna_objects = self._get_objects("LNA_R")
        for lna in lna_objects:
            runtime_lna = lna["distName"].split("/")
            runtime_lna = "{}/{}".format(runtime_lna[-2], runtime_lna[-1])
            configured_lna = lna["parameters"]["configDN"]
            availability_status = lna["parameters"]["availabilityStatus"]
            if configured_lna:
                configured_lna = configured_lna.replace("_A", "")
                configured_lna = configured_lna.split("/")
                config_unit_path = "{}/{}/{}/{}/{}".format(configured_lna[-5], configured_lna[-4], configured_lna[-3],
                                                           configured_lna[-2], configured_lna[-1])
                configured_lna = "{}/{}".format(configured_lna[-2], configured_lna[-1])
                gain = lna["parameters"]["gain"]
                lna_tuples.append((configured_lna, runtime_lna, gain, availability_status, config_unit_path))
            else:
                if given_mha and given_mha in runtime_lna:
                    if availability_status is None:
                        lna_tuples.append((None, runtime_lna, None, "OK", None))
                    else:
                        lna_tuples.append((None, runtime_lna, None, availability_status, None))
        return lna_tuples

    def _get_cell_tuples(self):
        """
        Gets information about cells from bts_info

        :return List[Tuple(str, str)]: (configured cell, runtime cell)
        """
        cell_tuples = []
        for cell in self.bts.cells:
            carrier_list = cell["carrierList"]
            config_name = cell["id"]["configuration"]
            runtime_name = cell["id"]["internal"]
            cell_tuples.append((config_name, runtime_name, carrier_list))
        return cell_tuples

    def _get_loglink_tuples(self):
        """
        Gets information about loglinks from bts_info

        :return List[Tuple(str, str, Any)]: (firstEndPointId, secondEndPointId, linkMode)
        """
        loglink_tuples = []
        loglinks = self.bts_info["loglinks"]
        for loglink in loglinks:
            first_end_point = loglink["firstEndPointId"]
            second_end_point = loglink["secondEndPointId"]
            link_mode = loglink["linkMode"]
            loglink_tuples.append((first_end_point, second_end_point, link_mode))
        return loglink_tuples

    def _get_complete_dist_names(self, given_lna=""):
        """
        Gets the complete distname for all lnas (or a single lna). Distname RMOD/ANTL is the same as the RMOD/ANTL
        where lna.data comes from.

        :param (Optional) str given_lna: Runtime lna object (e.g. ALD_R-1/LNA_R-1)
        :return list[str] or str: Can be either all lna dist names or just one specific based on given_lna
        """
        dist_names = []
        for first, second, link_mode in self.loglinks:
            distname_string = ""
            for configured_radio, runtime_radio in self.radios:
                if runtime_radio in first or runtime_radio in second:
                    distname_string += configured_radio
                    for configured_lna, runtime_lna, gain, availability_status, unit_path in self.lnas:
                        if runtime_lna in first or runtime_lna in second:
                            distname_string += "/{}".format(configured_lna)
                            if runtime_lna in given_lna:
                                return distname_string
                            dist_names.append(distname_string)
        return dist_names

    def _get_objects(self, obj):
        objects = self.admin.get_managed_objects(obj, timeout=10)
        return objects


class LnaUnit:

    def __init__(self):
        self.name = ""
        self.dist_name = ""
        self.unit_path = ""
        self.hw_path = ""
        self.data = ""
        self.dc = ""
        self.gain = 0
        self.link_mode = ""
        self.status = ""
        self.cells = {}
