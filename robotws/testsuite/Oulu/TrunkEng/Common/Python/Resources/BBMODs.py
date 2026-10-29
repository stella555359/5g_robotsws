"""
:author:  Essi Passoja
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import re
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import error, warning
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import BTSConfigurationNotFound
import testsuite.Oulu.TrunkEng.Common.Python.Resources.bbmods_and_socs as bbmods_and_socs


class BBMODs:
    """
    GetBCIs is used for finding baseband configurations. Script can be used to create a list of baseband
    connection objects.

    GetBCIs is called in common_resources.robot. If the class is already initiated once, import robot
    BuiltIn
        >> from robot.libraries.BuiltIn import BuiltIn
    and call with
        >> BuiltIn().get_library_instance("BBMODS")
    """
    bbmod_r_mos = None
    bbmod_l_mos = None

    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.bts = None
        self.logger = BuiltIn().get_library_instance("LOG")
        self.remote = False

    def get_bbmod_connections(self, remote=False):
        """
        Get BBMOD connections.
        :param bool remote: If RFS and we want BBMODs from the not tested side then this should be True.

        :return list(obj): List of baseband objects with following info: name, distName, serial number, product code,
        unit type, variant, id, SCF distName.
        """
        self.remote = remote
        self.bts = BuiltIn().get_library_instance("BTS")
        if self.remote:
            bbmods = self.bts.bts_info_remote["requestMessage"]["basebandModules"]
        else:
            bbmods = self.bts.bts_info["requestMessage"]["basebandModules"]
        # clear saved bbmod mos objects so their values will also be updated
        BBMODs.bbmod_r_mos = None
        BBMODs.bbmod_l_mos = None
        self.bbmod_r_mos = None
        self.bbmod_l_mos = None
        return self._get_bbmod_object_list(bbmods)

    def _check_if_side_is_sane(self, side, dist_name, bbmod_name):
        """
        Check if side is sane.

        :param str side: Side of the BBMOD.
        :param str dist_name: SCF DistName of the BBMOD.
        :param str bbmod_name: Name of the BBMOD.
        """
        if "BTS_L-4" in dist_name and "Left" in side:
            warning("Test has parsed that side is left, but in l_dist_name there is BTS_L-4 that indicates that side "
                    "should be right. \nSide check results: (not self.bts.fullrack and self.bts.side == '4') = {} "
                    "(self.bts.fullrack and '.' in bbmod_name) = {}\n  Check logs for more information.".format((
                        not self.bts.fullrack and self.bts.side == '4'), (self.bts.fullrack and '.' in bbmod_name)))
        elif "BTS_L-1" in dist_name and "Right" in side:
            warning("Test has parsed that side is right, but in l_dist_name there is BTS_L-1 that indicates that side "
                    "should be left. Check logs for more information.")
        if self.bts.position_in_subrack and not self.remote:
            if not side[:-1] in self.bts.position_in_subrack:
                error(f"Side is expected to be {side[:-1]}, but in positionInSubrack parameter it is "
                      f"{self.bts.position_in_subrack}. Check if commissioning of positionInSubrack parameter of this "
                      f"environment is correct.")

    def get_hw_path(self, bbmod_name, dist_name, l_dist_name):
        """
        Parses hw_path from the name of the BBMOD unit and position of SMOD.

        :param str bbmod_name: Name of BBMOD unit value of BBMODUnit.name, for example ABIA1 or ABIL2.3
        :param str dist_name: DistName of BBMOD, for example
                              /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-3
        :param str l_dist_name: BBMOD_L distname of BBMOD, for example:
                                /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1/BBMOD_L-3
        :return str: Returns BBMOD unit's hw_path
        """
        position = {"1": "Bottom", "2": "Middle", "3": "Top"}
        side = "Left_"
        smod_number = self._get_connected_smod_number(bbmod_name)
        hw_path = ""
        if (not self.bts.fullrack and self.bts.side == "4") or (self.bts.fullrack and "." in bbmod_name) or (
                self.bts.side == r"\d+" and "BTS_L-4" in l_dist_name):
            side = "Right_"
        smod_side = "({})".format(side[:-1])
        self._check_if_side_is_sane(side, l_dist_name, bbmod_name)
        # ASOE/ASOG/ASOH don't have position in subrack.
        # Fullrack/RFS has sides, but parameter position_in_subrack is empty
        if not self.bts.position_in_subrack and self.bts.side != r"\d+":
            self.logger.debug(f"No value in BTS.position_in_subrack (={self.bts.position_in_subrack}) and BTS.side is "
                              f"not d+ (={self.bts.side}) so we assume that ASOE/ASOG/ASOH in question and no side.")
            smod_side = ""
        if bbmod_name[-1] in position:
            bbmod_position = position[bbmod_name[-1]]  # rel3 support will need more parsing if support to it is needed
            last_part = dist_name[dist_name.rfind("/")+1:]
            hw_path = f"/SMOD_R-{smod_number}{smod_side}/{last_part}({side}{bbmod_position})"
        elif bbmod_name[-1] == '0':
            warning("BBMOD port is 0 -> internal FSP unit. Hw_path of internal FSP unit is hw_path of SMOD.")
            hw_path = f"/SMOD_R-{smod_number}{smod_side}"
        else:
            warning(f"Name of BBMOD {bbmod_name} is unknown format, cannot get HW path for the BBMOD.")
        return hw_path

    def get_cells_mapped_to_bbmod(self, bbmod_name):
        """
        Get cells that have resources on BBMOD.

        :param str bbmod_name: BBMOD which cells are wanted. Possible values f.ex. ABIA1, ABIL3, ABIB2.2...
        :return list: List of cells that have resources on BBMOD.
        """
        cells_on_bbmod = []
        if self.bts.rmod_cell_links:
            for radio in self.bts.rmod_cell_links:
                for cell in self.bts.rmod_cell_links[radio]:
                    if self.bts.bbmods_connected_to_rmods and bbmod_name in self.bts.bbmods_connected_to_rmods:
                        for rmod in self.bts.bbmods_connected_to_rmods[bbmod_name]:
                            if rmod == radio and cell not in cells_on_bbmod:
                                cells_on_bbmod.append(cell)
        self.logger.debug("Cells on BBMOD: {}".format(cells_on_bbmod))
        return cells_on_bbmod

    def _get_connected_smod_number(self, bbmod_name):
        if self.bts.fullrack:
            for smod in self.bts.smods:
                if ("." in bbmod_name and "2" in smod.name) or ("." not in bbmod_name and "1" in smod.name):
                    return smod.r_dist_name[-1]
        else:
            return "1"

    def _get_bbmod_object_list(self, bbmods):
        """
        Get BBMOD object list, if BBMOD is commissioned.

        :param list bbmods: BBMODs in question.
        :return list bbmod_list: BBMOD object list.
        """
        bbmod_list = []
        if not self.bbmod_l_mos:
            if self.remote:
                self.bbmod_l_mos = self.admin.get_managed_objects("BBMOD_L", connection="remote")
            else:
                self.bbmod_l_mos = self.admin.get_managed_objects("BBMOD_L")
        # bbmod_l_objects = self.admin.get_managed_objects("BBMOD_L")
        for bbmod in bbmods:
            scf_dist_name = ""
            dist_name = str(bbmod["id"]["internal"])
            if not self._correct_runtime_view(dist_name):
                continue
            if bbmod["productName"] == "":
                continue
            name = str(bbmod["productName"])
            if "FBB" not in name and "ABI" not in name and "FBI" not in name:
                continue
            if "configuration" not in bbmod["id"]:
                warning(f"Key 'configuration' was not found for BBMOD: {dist_name}")
            elif not bbmod["id"]["configuration"]:
                warning("Non-commissioned BBMOD found: {}".format(dist_name))
            else:
                scf_dist_name = bbmod["id"]["configuration"]
            new_bbmod = self._create_bbmod_object(bbmod, dist_name, name, scf_dist_name, self.bbmod_l_mos)
            bbmod_list.append(new_bbmod)
        return bbmod_list

    def _create_bbmod_object(self, bbmod, dist_name, name, scf_dist_name, bbmod_l_objects):
        """
        Create a BBMOD object.

        :param lib bbmod: BBMOD in question.
        :param str dist_name: DistName of the BBMOD.
        :param str name: Name of the BBMOD.
        :param str scf_dist_name: SCF distName of the BBMOD.
        :param list bbmod_l_objects: List of BBMOD_L objects.
        :return obj bbmod_unit: Returns the created BBMOD class object.
        """
        self.logger.debug("Creating BBMOD object for {}. All found information: {}".format(scf_dist_name, bbmod))
        bbmod_unit = BCI()
        name = self._define_name_from_product(name)
        bbmod_id, bbmod_side, node_id = self._get_bbmod_node_id_and_side(bbmod)
        bbmod_unit.bbu_or_board_node_id = node_id
        if bbmod_side == 2 and self.bts.fullrack:
            name += "2."
        # elif self.bts.fullrack:
        #     name += "1."
        if name.startswith("FBB"):
            bbmod_id -= 1
        bbmod_unit.name = f"{name}{bbmod_id}"
        bbmod_unit.dist_name = dist_name
        bbmod_unit.serial_nmbr = str(bbmod["serialNumber"])
        bbmod_unit.product_code = str(bbmod["productCode"])
        bbmod_unit.variant = name[3:]
        bbmod_unit.id = bbmod_id
        bbmod_unit.scf_dist_name = scf_dist_name
        bbmod_unit.l_dist_name = self._get_bbmod_l_dist_name(bbmod_unit.serial_nmbr, bbmod_l_objects)
        self.logger.debug("bts_name in bts {}".format(self.bts.bts_name))
        bbmod_unit.unit_path = "[{}] {}".format(self.bts.bts_name, scf_dist_name)
        bbmod_unit.hw_path = self.get_hw_path(f"{name}{bbmod_id}", dist_name, bbmod_unit.l_dist_name)
        bbmod_unit.primary_soc = bbmods_and_socs.get_primary_soc(bbmod_unit.name)
        self.logger.debug(f"Primary soc of {bbmod_unit.name} is {bbmod_unit.primary_soc}")
        bbmod_unit.secondary_socs = bbmods_and_socs.get_secondary_socs(bbmod_unit.name)
        self.logger.debug(f"Secondary socs of {bbmod_unit.name} are {bbmod_unit.secondary_socs}")
        return bbmod_unit

    @staticmethod
    def _get_bbmod_l_dist_name(serial_number, bbmod_l_objects):
        """
        Get BBMOD l_dist_name.

        :param str serial_number: BBMOD serial number to be compared to serial numbers in BBMOD_L objects.
        :param list bbmod_l_objects: List of BBMOD_L objects.
        """
        for bbmod_l in bbmod_l_objects:
            if serial_number == bbmod_l["parameters"]["serialNumber"]:
                return bbmod_l["distName"]
        warning(f"Cannot find BBMOD_L distName for serial number {serial_number}")
        return ""

    @staticmethod
    def _define_name_from_product(name):
        """
        Defines a name from product name.

        :param str name: Product name of the BBMOD.
        :return str name: Defined name for the BBMOD.
        """
        if "FBB" in name:
            name = name[name.rfind("FBB"):]
        elif "FBI" in name:
            name = name[name.rfind("FBI"):]
        else:
            name = name[name.rfind("ABI"):]
        if " " in name:
            name = name[0:name.find(" ")]
        return name

    def _correct_runtime_view(self, dist_name):
        """
        Checks if runtime view is correct.

        :param str dist_name: DistName of the BBMOD.
        :return boolean: If correct runtime view is found in dist_name and it matches mr_bts_nmbr, return True.
        """
        mr_bts_nmbr = self._get_mr_bts_nmbr(dist_name)
        regex = re.compile(r".*RUNTIME_VIEW-(?P<value>\d).*")
        match = regex.match(dist_name)
        if match and match.group("value") == str(mr_bts_nmbr):
            return True
        return False

    @staticmethod
    def _get_mr_bts_nmbr(dist_name):
        """
        Checks if runtime view value is same as MRBTS number.

        :param str dist_name: DistName of the BBMOD.
        :raise BTSConfigurationNotFound: If MRBTS number cannot be found from distName.
        :return str: Returns the MRBTS number.
        """
        regex = re.compile(r".*MRBTS_R-(?P<value>\d).*")
        match = regex.match(dist_name)
        if match:
            return match.group("value")
        error("Cannot find MRBTS number from distName {}".format(dist_name))
        raise BTSConfigurationNotFound("Cannot find MRBTS number from distName {}".format(dist_name))

    def _get_bbmod_node_id_and_side(self, bbmod):
        """
        Get BBMOD ID, side and node ID.

        :param lib bbmod: The BBMOD in question.
        :return tuple(int, bool): tuple includes node_id, right_side.
        """
        # configuration = bbmod['id']['configuration']
        # bbmod_no = int(configuration[-1])  # 1, 2, 3, 4, 5 or 6
        bbmod_side = self._get_bbmod_side(bbmod)
        bbmod_no = self._get_bbmod_position(bbmod)
        side_no = 17 if bbmod_side == 1 else 33
        # if self.bts.fullrack and bbmod_side == 2:
        #     number_of_bbmods_on_left_side = self._get_number_of_bbmods_on_left_side()
        #     if bbmod_no > 3:  # fullrack might have 4, 5 and 6
        #         bbmod_no -= 3
        #     else:
        #         bbmod_no = bbmod_no - number_of_bbmods_on_left_side
        node_id = side_no + bbmod_no
        self._confirm_bbu_or_board_exists(node_id)
        return bbmod_no, bbmod_side, node_id

    def _get_number_of_bbmods_on_left_side(self):
        """
        Checks the number of baseband modules on the left side of a rack.

        :return int: Number of baseband modules on the left side of a rack.
        """
        # important only in fullrack config
        number_of_bbmods_on_left_side = 0
        if self.remote:
            bbmods = self.bts.bts_info_remote["requestMessage"]["basebandModules"]
        else:
            bbmods = self.bts.bts_info["requestMessage"]["basebandModules"]
        for bbmod in bbmods:
            if self._get_bbmod_side(bbmod) == 1:
                number_of_bbmods_on_left_side += 1
        return number_of_bbmods_on_left_side

    def _get_bbmod_side(self, bbmod):
        if not self.bbmod_r_mos:
            if not self.remote:
                self.bbmod_r_mos = self.admin.get_managed_objects('BBMOD_R')
            else:
                self.bbmod_r_mos = self.admin.get_managed_objects("BBMOD_R", connection="remote")
        for bbmod_mo in self.bbmod_r_mos:
            if bbmod_mo['distName'] in bbmod['id']['internal']:
                return int(bbmod_mo['parameters']['horizontalPosition'])
        warning(f"Could not find BBMOD side, horizontalPosition was not found from BBMOD_R object assume it is left (1)"
                f". BBMOD info: {bbmod}")
        return 1

    def _get_bbmod_position(self, bbmod):
        if not self.bbmod_r_mos:
            if not self.remote:
                self.bbmod_r_mos = self.admin.get_managed_objects('BBMOD_R')
            else:
                self.bbmod_r_mos = self.admin.get_managed_objects("BBMOD_R", connection="remote")
        for bbmod_mo in self.bbmod_r_mos:
            if bbmod_mo['distName'] in bbmod['id']['internal']:
                return int(bbmod_mo['parameters']['verticalPosition']) - 1  # verticalPosition can have value 2,3 or 4
        warning(f"Could not find BBMOD position, verticalPosition was not found from BBMOD_R object. "
                f"BBMOD info: {bbmod}")
        return 0

    def _confirm_bbu_or_board_exists(self, node_id):
        if not self.remote:
            bbu_parameters = self.admin.get_parameters_for_all(class_name="BBU")
        else:
            bbu_parameters = self.admin.get_parameters_for_all(class_name="BBU", connection="remote")
        for bbu in bbu_parameters:
            self.logger.debug(f'nodeId of BBU: {bbu["nodeId"]}')
            if node_id == bbu["nodeId"]:
                return True
        warning("nodeId did not correspond to any BBU, and we cannot check BOARD objects due to "
                "https://jiradc.ext.net.nokia.com/browse/TAF-2918. We assume everything is OK.")
        return True
        # for board in self.admin.get_parameters_for_all(class_name="BOARD"):
        #     if node_id == board["nodeId"]:
        #         return True
        # raise BTSConfigurationNotFound("Cannot confirm that the BBU/BOARD -object with nodeId {} "
        #                                "exists.".format(node_id))


class BCI(object):
    """
    Initializes a BBMOD Configuration Identifier -object.
    """
    def __init__(self):
        self.name = ""
        self.dist_name = ""
        self.l_dist_name = ""
        self.serial_nmbr = ""
        self.product_code = ""
        self.unit_type = "FSP"
        self.variant = ""
        self.id = ""
        self.unit_path = ""
        self.hw_path = ""
        self.cells = []
        self.bbu_or_board_node_id = ""
        self.connected_radios = []
        self.primary_soc = ""
        self.secondary_socs = []
