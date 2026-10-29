"""
:author:  Essi Passoja
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""
import re
import sys
from robot.libraries.BuiltIn import BuiltIn
from traceback import format_exception
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin.exceptions import AliasInUse
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (BTSConfigurationNotFound, EnvironmentIssue,
                                                                        ScriptIssue, ErrorFromAdmin)
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import warning, error, info


class RMODs:
    """
    RMODs is used for finding "Radio Configuration Identifier" - RCI and other RMOD related information.

    RCI explanation: RMOD(x.y.z.i) --> x = SMOD connection, y = BBMOD connection, z = BBMOD port, i = RMOD port if
    chained radio.

    RMODs is called in common_resources.robot. If the class is already initiated once, import robot
    BuiltIn
        >> from robot.libraries.BuiltIn import BuiltIn
    and call with
        >> BuiltIn().get_library_instance("RMODS")
    """
    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.bts = None
        self.logger = BuiltIn().get_library_instance("LOG")

        self.unit_info = []
        self.chained_radios_and_bb = []

    def update_bbmods_for_chained_rmods_to_rci(self):
        """
        This check is needed, if RCI was found for the chained radio before the directly connected (mother) radio.
        """
        mother_radio = ""
        for rmod in self.bts.radios:
            if rmod.name[-6] == "0":  # if bbmod is 0 we need to check if radio is really chained radio
                for first_in_chain, second_in_chain, _ in self.chained_radios_and_bb:
                    if "RMOD_R-" in second_in_chain and "RMOD_R-" in second_in_chain:
                        if rmod.dist_name in second_in_chain:
                            mother_radio = first_in_chain
                for second_in_chain, _, bb in self.chained_radios_and_bb:
                    if mother_radio[:mother_radio.rfind('/')] in second_in_chain:
                        rmod.name = f"{rmod.name[:-6]}{bb}{rmod.name[-5:]}"

    def get_hw_path(self, rmod_name, rmod_dist_name):
        """
        Parses hw_path from the name of the RMOD unit.

        :param str rmod_name: Name of RMOD unit, value of RMODUnit.name, for example FRHA(1.1.1.1)
        :param str rmod_dist_name: Dist_name of RMOD, for example
                                   /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1
        :return str: Returns RMOD unit's hw_path, for example /SMOD_R-1(Left)/BBMOD_R-3(Left_Top)/rf1/RMOD_R-3
        """
        hw_path = ""
        rmod_name, rmod_dist_name = self.get_main_name_of_radio(rmod_name, rmod_dist_name)
        all_radios = [rmod_name]
        for radio in self.bts.radios:
            if rmod_name == radio.name:
                all_radios.extend(radio.multi_fibre_connection)

        for rmod_name in all_radios:
            single_hw_path = self._get_hw_path_for_rmod_name(rmod_dist_name, rmod_name)
            if not hw_path:
                hw_path = single_hw_path
            else:
                hw_path = f"{hw_path} / {single_hw_path}"
        return hw_path

    def _construct_hw_path_for_chain(self, rmod_name, abil_bbmod, bbmod_hw_path, rmod_realtime, chain_path,
                                     multifibre_radio_port=None):
        """
        Construct hw path for chain
        """
        hw_path = ""
        hw_path2 = ""
        rmod_port = rmod_name[-4] if rmod_name[-5] == "." else rmod_name[-5:-3]
        if abil_bbmod:
            abil_port = self._get_abil_port(rmod_port)
            hw_path = f"{bbmod_hw_path}/{abil_port}/{rmod_realtime}{chain_path}"
        else:
            hw_path = f"{bbmod_hw_path}/rf{rmod_port}/{rmod_realtime}{chain_path}"
        if multifibre_radio_port:
            hw_path2 = hw_path.replace(f"rf{rmod_port}", f"rf{multifibre_radio_port}")
        if rmod_name.count(".") == 4:
            hw_path = self._get_rmod_hw_path_when_attached_to_fhs(rmod_name, hw_path, self.bts.bts_info)
            if multifibre_radio_port:
                hw_path2 = self._get_rmod_hw_path_when_attached_to_fhs(rmod_name, hw_path2, self.bts.bts_info)
        if multifibre_radio_port:
            return f"{hw_path} / {hw_path2}"
        return hw_path

    def _get_hw_path_for_rmod_name(self, rmod_dist_name, rmod_name):
        """
        Get hw_path for RMOD name. Useful when radio has multiple fibres connected and hw path needs to be
        created for all of them.

        :param str rmod_dist_name: RMOD dist_name.
        :param str rmod_name: RMOD name.

        :return str: Returns hw_path for RMOD name.
        """
        smod_number = "1"
        hw_path = ""
        abil_bbmod = False
        position = {"1": "Bottom", "2": "Middle", "3": "Top"}
        side = "Left"
        if (not self.bts.fullrack and self.bts.side == "4") or (self.bts.fullrack and rmod_name[-8] == '2') or (
                "MRBTS_R-4" in rmod_dist_name):
            side = "Right"
        smod_side = f"({side})"
        if not self.bts.position_in_subrack:
            smod_side = ""
        if "0" in (rmod_name[-6], rmod_name[-7]):
            print("Radio is connected directly to SMOD, to internal FSP unit")
            rmod_realtime = rmod_dist_name.split('/')[-1]
            hw_path = f"/SMOD_R-{smod_number}{smod_side}/rf{rmod_name[-4]}/{rmod_realtime}"
        elif rmod_name[-6] in position or rmod_name[-7] in position:
            rmod_realtime = rmod_dist_name.split('/')[-1]  # this is valid if not in chain
            bbmod_hw_path = ""
            for bbmod in self.bts.bbmods:
                if self.bts.fullrack:
                    if bbmod.name[-1] in (rmod_name[-6], rmod_name[-7]) and (
                            (side == "Right" and '.' in bbmod.name) or (side == "Left" and '.' not in bbmod.name)):
                        bbmod_hw_path = bbmod.hw_path
                        abil_bbmod = True if "ABIL" in bbmod.name else False
                        break
                elif '.' not in bbmod.name and (bbmod.name[-1] in (rmod_name[-6], rmod_name[-7])):
                    bbmod_hw_path = bbmod.hw_path
                    abil_bbmod = True if "ABIL" in bbmod.name else False
                    break
            if rmod_name[-2] != "1":
                for rmod in self.bts.radios:
                    opt_if3 = False
                    if rmod.name[-2] == "1" and (rmod.name[-8:-2] in rmod_name or rmod.name[-9:-2] in rmod_name):
                        if rmod.multi_fibre_connection:
                            print(f"Radio {rmod.name} is connected with multi-fibre {rmod.multi_fibre_connection} only "
                                  f"opt_if3 is possible for chained radio, because 2 of fibre connections are already "
                                  f"used.")
                            opt_if3 = True
                        rmod_realtime = rmod.dist_name.split('/')[-1]
                        chain_path = self._get_hw_path_of_chained_rmod(rmod_name, rmod_dist_name, opt_if3=opt_if3)
                        hw_path = self._construct_hw_path_for_chain(rmod_name, abil_bbmod, bbmod_hw_path, rmod_realtime,
                                                                    chain_path)
                        if rmod.multi_fibre_connection:
                            for multi_fibre_radio in rmod.multi_fibre_connection:
                                multifibre_radio_port = multi_fibre_radio[-4] if multi_fibre_radio[-5] == "." \
                                    else multi_fibre_radio[-5:-3]
                                chain_path = self._get_hw_path_of_chained_rmod(multi_fibre_radio, rmod_dist_name,
                                                                               opt_if3=opt_if3)
                                single_hw_path = self._construct_hw_path_for_chain(rmod_name, abil_bbmod, bbmod_hw_path,
                                                                                   rmod_realtime, chain_path,
                                                                                   multifibre_radio_port)
                                hw_path = f"{hw_path} / {single_hw_path}"
                        break
            else:
                hw_path = self._construct_hw_path_for_chain(rmod_name, abil_bbmod, bbmod_hw_path, rmod_realtime, "")
        else:
            warning(f"WARNING Name of RMOD {rmod_name} is unknown format, cannot get HW path for the RMOD.")
        return hw_path

    def get_main_name_of_radio(self, rmod_name, rmod_dist_name):
        """
        Get the main name of the radio.

        :param str rmod_name: Name of the radio.
        :param str rmod_dist_name: Radio distName.

        :return str: Main name of the radio.
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        for radio in self.bts.radios:
            if radio.name == rmod_name:
                return rmod_name, rmod_dist_name
            for multi_fibre_radio in radio.multi_fibre_connection:
                if rmod_name in multi_fibre_radio:
                    print(f"Radio is connected to multi-fibre cable. Use main radio name {radio.name} "
                          f"for searching the hw_path.")
                    return radio.name, radio.dist_name
        print(f"WARNING Could not find {rmod_name} from the radios. Take contact to script developer.")
        return rmod_name, rmod_dist_name

    def get_cells_mapped_to_rmod(self, rmod_name):
        """
        Get cells of radio.

        :param str rmod_name: Radio which cells are wanted. Possible values f.ex. FRHA(1.1.1.1), FXEB(1.3.2.1)...
        :return list: List of cells mapped to selected radio.
        """
        cells_mapped_to_rmod = []
        if self.bts.rmod_cell_links:
            for radio in self.bts.rmod_cell_links:
                if rmod_name == radio:
                    for cell in self.bts.rmod_cell_links[radio]:
                        cells_mapped_to_rmod.append(cell)
            return cells_mapped_to_rmod
        else:
            print("ERROR RMOD-cell links are not found, take contact to script developer!")
            raise EnvironmentIssue("RMOD-cell links are not found.")

    def get_directions_of_cell_on_radio(self, selected_radio, cells_of_radio=None):
        """
        Gets directions of cell on radio.
        :param str selected_radio: Radio which directions of cells will be collected for example FRHA(1.1.1.1)
        :param list cells_of_radio: List of cells on radio if not given searches cells of radio.
        :return dict: Returns dictionary where cell is a key and it's directions in list as value.
        """
        if not cells_of_radio:
            cells_of_radio = self.get_cells_mapped_to_rmod(selected_radio)
        cell_directions = {}
        for radio in self.bts.radios:
            if radio.name == selected_radio:
                for cell in cells_of_radio:
                    for antenna in self.bts.antennae:
                        if (antenna.connected_cells and cell in antenna.connected_cells and
                                radio.scf_dist_name in antenna.connected_radios):
                            if not cell_directions or cell not in cell_directions:
                                cell_directions[cell] = [antenna.direction]
                            else:
                                cell_directions[cell].append(antenna.direction)
                break  # breaks out of radio for loop
        print(f"Cells of {selected_radio} and directions: {cell_directions}")
        return cell_directions

    def get_radios_in_chain(self, radio, return_names=False, print_to_eventlog=True):
        """
        Get all radios that are chained to the selected radio.

        :param str radio: Radio which chained radios are get. Possible values f.ex. FRHA(1.1.1.1), FXEB(1.3.2.1)...
        :param bool return_names: Default value is False and then returns radio objects, if set to True returns just
                                  name of radio.
        :param bool print_to_eventlog: Prints chain information to eventlog if True otherwise not.
        :return list: List of radios chained to selected radio.
        :raise EnvironmentIssue if no radios found from the environment.
        """
        chained_rmods = []
        if self.bts.radios:
            for rmod in self.bts.radios:
                if rmod.name != radio and (rmod.name[-8:-2] == radio[-8:-2] or rmod.name[-9:-3] == radio[-9:-3]):
                    if print_to_eventlog:
                        print(f"Selected {radio} and {rmod.name} are in chain")
                    else:
                        print(f"Selected {radio} and {rmod.name} are in chain")
                    if int(rmod.name[-2]) > int(radio[-2]):
                        if print_to_eventlog:
                            print(f"{rmod.name} is chained to {radio}")
                        else:
                            print(f"{rmod.name} is chained to {radio}")
                        if return_names:
                            chained_rmods.append(rmod.name)
                        else:
                            chained_rmods.append(rmod)
            return chained_rmods
        else:
            print("ERROR No radios found from the environment. Unable to get chained radios.")
            raise EnvironmentIssue("No radios found from the environment. Unable to get chained radios.")

    def get_radio_connections(self, remote=False):
        """
        Get RCIs (Radio Configuration Identifier).

        :param bool remote: If RFS and we want radios from the not tested side then this should be True.
        :return list(obj) radio_list: List of radio objects with following info:
        name, distName, serial number, scf_distName.
        """
        try:
            if not self.bts:
                self.bts = BuiltIn().get_library_instance("BTS")
            if not self.bts.bts_info and not remote:
                print("ERROR Site information could not be retrieved. Cannot start the test without site information.")
                raise BTSConfigurationNotFound("Site information cannot be retrieved.")
            if not self.bts.bts_info_remote and remote:
                print("ERROR Site information could not be retrieved from the not tested side. Cannot start test "
                      "because we cannot get information from the other side")
                raise BTSConfigurationNotFound("Site information cannot be retrieved from the not tested side (remote)")
            radio_list = []
            if remote:
                rmods = self.bts.bts_info_remote['requestMessage']['radioModules']
                all_rmod_parameters = self.admin.get_parameters_for_all("RMOD", timeout=60, connection="remote")
            else:
                rmods = self.bts.bts_info['requestMessage']['radioModules']
                all_rmod_parameters = self.admin.get_parameters_for_all("RMOD", timeout=60)
            for rmod in all_rmod_parameters:
                connections = self._parse_connection_list(radio=rmod['id'], remote=remote)
                skip_duplicate_radio = False
                for connection in connections:
                    connection_with_radio_name = f"{rmod['productName']}({connection})"
                    for radio in radio_list:
                        if radio.serial_number == rmod['serialNumber']:
                            radio.multi_fibre_connection.append(connection_with_radio_name)
                            skip_duplicate_radio = True
                    if not skip_duplicate_radio:
                        new_radio = self._create_radio_object(
                            connection_with_radio_name, rmod['id'], rmod['serialNumber'],
                            self.get_scf_dist_name(rmods, rmod['id']), rmod['ipAddress'], rmod['productCode'],
                            self.get_cablink_type_for_radio(rmods, rmod['id']), remote=remote)
                        radio_list.append(new_radio)
            radio_list = self._organize_radio_names_according_to_port_numbers(radio_list)
            return radio_list
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AdminApiConnectionClosedException,
                AliasInUse) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"Loop {self.logger.loop + 1}: Error noticed during get_radio_connections. "
                  f"{admin_error.__class__.__name__}:{admin_error} was raised.\n{tb}")
            raise ErrorFromAdmin(f"{admin_error.__class__.__name__}:{admin_error}")

    @staticmethod
    def get_scf_dist_name(radios, radio_id):
        """
        Get scf distName of radio.

        :param dict[obj] radios: detailed information of radios.
        :param str radio_id: internal radio id.
        :return str scf_dist_name: SCF dist_name of the radio.
        """
        rmods = radios['rmod']
        for rmod in rmods:
            if rmod['id']['internal'] == radio_id:
                if "configuration" in rmod['id']:
                    return rmod['id']['configuration']
                else:
                    warning(f"Configuration key was not found for {rmod['id']['internal']}")
        return None

    def get_cablink_type_for_radio(self, radios, radio_id):
        """
        Get cablink type of radio

        :param dict[obj] radios: detailed information of radios.
        :param str radio_id: internal radio id.
        :return str cablink_type: cablink type of the radio.
        """
        rmods = radios['rmod']
        for rmod in rmods:
            if rmod['id']['internal'] == radio_id:
                cables = self.bts.bts_info['requestMessage']['cables']
                for cable in cables:
                    # if rmod["id"]["configuration"] in cable["secondEndPointId"]["configuration"]:
                    if "configuration" not in cable["secondEndPointId"]:
                        warning(f"Configuration key is not found for {cable['secondEndPointId']}. "
                                f"If test runs OK, this warning can be ignored.")
                        continue
                    elif "configuration" not in rmod["id"]:
                        warning(f"Configuration key is not found for {rmod['id']['internal']}. "
                                f"If test runs OK, this warning can be ignored.")
                        continue
                    else:
                        if rmod["id"]["configuration"] in cable["secondEndPointId"]["configuration"]:
                            return cable.get('cablinkType')
        return None

    def _parse_connection_list(self, radio="", remote=False):
        """
        Parses a list of RCIs (Radio Configuration Identifier) from BTS info.

        :param str radio: The radio in question.
        :raise BTSConfigurationNotFound: If site information can't be retrieved.
        :param bool remote: Default is false if RFS environment may also be true
        :return list: Returns a list of BTS RMOD connections.
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        if remote:
            bts_info = self.bts.bts_info_remote
        else:
            bts_info = self.bts.bts_info
        if (not bts_info) or ('requestMessage' not in bts_info) or (
                'requestMessage' in bts_info and "cables" not in bts_info['requestMessage']):
            print(f"Found BTS info: {bts_info}")
            print("WARNING: Cable information could not be retrieved. "
                  "Cannot start the test without cable information. Try to retrieve it again.")
            if remote:
                bts_info = self.admin.get_bts_info(detailed_output=True, connection="remote")
                self.bts.bts_info_remote = bts_info
            else:
                bts_info = self.admin.get_bts_info(detailed_output=True)
                self.bts.bts_info = bts_info
            if "cables" not in bts_info['requestMessage']:
                print(f"BTS info: {bts_info}")
                print("ERROR: Cable information could not be retrieved. Cannot start the test without cable info.")
                raise BTSConfigurationNotFound("Cable information could not be retrieved.")
        return self._create_connection_list(radio, bts_info['requestMessage']['cables'], remote=remote)

    def _create_connection_list(self, radio, cables, detected_connection_list=False, remote=False):
        """
        Creates a list of connections.

        :param str radio: The radio in question.
        :param list cables: Cables in bts_info json.
        :param list detected_connection_list: (Optional) Set to False if not given. List of detected connections.
        :raise BTSConfigurationNotFound: If the correct port number can not be parsed, BBMod distName can't be found,
                                         connection list can't be parsed or a KeyError is found.
        :return list connections: A list of connections.
        """
        self._find_all_units(remote=remote)
        bbmod = -1
        smod = 0
        fhs = 0  # FHS = Front-haul switch
        connections = []
        for cable in cables:
            radio_port = -1
            radio_label = ""
            try:
                if not cable:
                    continue

                if 'cablinkType' not in cable:
                    print(f"WARNING CableLinkType missing for {cable['id']['internal']}. "
                          f"If test runs OK, this warning can be ignored.")
                    continue

                if not self._check_that_correct_link_type(cable['cablinkType']):
                    # This code supports 3 types of links: RP3_01Link, "EthLink", "CPRILink"
                    continue

                second_end_point = str(cable['secondEndPointId']['internal'])
                second_end_point = second_end_point[0:second_end_point.rfind("/")]
                if radio != second_end_point:
                    continue

                first_end_point = str(cable['firstEndPointId']['internal'])
                label, port = self._get_label_and_port_of_first_end_point(first_end_point)

                if first_end_point and "SMOD_R-" in first_end_point:
                    smod, bbmod, order = self._get_rci_values_from_smod_r(first_end_point, smod)
                    if (not detected_connection_list and any(not c.startswith(str(smod)) for c in connections) and
                            cable['linkMode']['configuration'] == "True"):
                        """
                        A special case where we have ASIA and FSMF together, so we need to check conf mode
                        also for SMOD but only if SMODs are different. Usually connections are sorted and the
                        first one is used without checking link mode.
                        """
                        connections = []
                elif first_end_point and "BBMOD_R-" in first_end_point:
                    bbmod, bbmod_info = self._get_bbmod_id_and_info(bbmod, first_end_point)
                    self._check_bbmod_configuration_correctness(bbmod_info)
                    bbmod_conf = bbmod_info['id']['configuration']
                    bbmod_side = self._get_bbmod_side(first_end_point)
                    if self.bts.fullrack and bbmod_side == 2:  # fullrack and right side
                        smod, bbmod = self._get_smod_and_bbmod_id_when_fullrack_and_right_side(
                            bbmod_conf, first_end_point)
                    else:
                        smod, bbmod = self._get_smod_and_bbmod_id_when_not_fullrack_and_right_side(
                            bbmod_info, first_end_point)
                    order = 1
                elif first_end_point and "RMOD_R-" in first_end_point:  # Chained radios
                    smod, bbmod, radio_port, fhs, radio_label, order = (
                        self._get_unit_connections_recursively(cables, first_end_point, 1))
                elif first_end_point and "FHS_R-" in first_end_point:  # FHS
                    smod, bbmod, fhs, _, radio_label, order = self._get_unit_connections_recursively(
                        cables, first_end_point, 1)
                    order -= 1
                elif first_end_point and "SMOD_EXT_R-" in first_end_point:
                    print("Radio connection from external SMOD detected.")
                    continue
                else:
                    raise BTSConfigurationNotFound("Could not parse connection list. Take contact to script developer.")

            except KeyError as e:
                raise BTSConfigurationNotFound("Something is wrong when fetching information from Cablink data. "
                                               f"Take contact to script developer. ({e})\n"
                                               f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            else:
                if radio_port != -1:
                    if int(fhs) > 0:
                        """ Use the FHS port in the chain if recursion used and FHS detected """
                        port = radio_label[-1]
                        label = radio_label
                    else:
                        """ Use the first port in the chain if recursion used """
                        port = radio_port
                        label = radio_label
                if label.startswith("S_RF") or label.startswith("Q_RF"):
                    labels = {"S_RF1": "1", "S_RF2": "2", "Q_RF1": "3", "Q_RF2": "4"}
                    label = labels.get(label, "")
                    port = ""
                else:
                    label = ""
                if int(fhs) > 0:
                    connection = f"{smod}.{bbmod}.{fhs}.{port}.{order}"
                else:
                    connection = f"{smod}.{bbmod}.{label}{port}.{order}"

                connections.append(connection)
        return connections

    def _get_unit_connections_recursively(self, cables, source, order):
        """
        Get original BB unit number and port in case the radio is chained or connected with a front haul switch.

        :param list cables: Cables in question.
        :param str source: Source unit.
        :param int order: Order of units.
        :raise BTSConfigurationNotFound: If BBMOD port and BBunit can't be parsed correctly.
        :return tuple(int, int, int, int, int, str): smod_id, bbmod_id, port, front_haul_port, label, order.
        """
        port = sys.maxsize
        label = ""
        smod_port = 0
        bbmod_port = 0
        fhs_port = 0
        order += 1

        for cable in cables:
            if not cable:
                continue
            if 'cablinkType' not in cable:
                continue
            if not self._check_that_correct_link_type(cable['cablinkType']):
                # This code supports 3 types of links: RP3_01Link, "EthLink", "CPRILink"
                continue

            second_end_point = str(cable['secondEndPointId']['internal'])
            second_end_point = second_end_point[0:second_end_point.rfind("/")]

            source_unit = source[0:source.rfind("/")]
            if source_unit != second_end_point:
                continue

            first_end_point = str(cable['firstEndPointId']['internal'])
            if not first_end_point:
                continue

            if first_end_point == source:
                continue  # avoid stack overflow

            if "SMOD_R-" in first_end_point:
                smod_port, bbmod_port, order = self._get_rci_values_from_smod_r(first_end_point, smod_port)
                port = int(first_end_point[-1])
                label = first_end_point[first_end_point.rfind("/")+1:]
                return smod_port, bbmod_port, port, fhs_port, label, order
            elif "BBMOD_R-" in first_end_point:
                smod_port, bbmod_port, label, port = self._get_rci_values_using_bbmod_r(
                    bbmod_port, cable, first_end_point, label, port)
            elif "FHS_R-" in first_end_point:
                smod_port, bbmod_port, port, _, label, order = \
                    self._get_unit_connections_recursively(cables, first_end_point, order)
                fhs_port = port
                if first_end_point.split("/")[-2][-2:].isdigit():  # port > 9
                    port = first_end_point.split("/")[-2][-2:]
                else:  # port <= 9
                    port = first_end_point.split("/")[-2][-1]
                label = first_end_point.split("/")[-1]
                order -= 1
                return smod_port, bbmod_port, port, fhs_port, label, order
            elif "RMOD_R-" in first_end_point:
                smod_port, bbmod_port, port, fhs_port, label, order = \
                    self._get_unit_connections_recursively(cables, first_end_point, order)
                return smod_port, bbmod_port, port, fhs_port, label, order
            else:
                print("ERROR Could not parse BBUnit for chained radio. Take contact to script developer.")
                raise BTSConfigurationNotFound("Could not parse BBUnit for chained radio.")

        return smod_port, bbmod_port, port, fhs_port, label, order

    def _get_label_and_port_of_first_end_point(self, first_end_point):
        label = first_end_point[first_end_point.rfind("/") + 1:]
        if label.startswith("RFEXT") or label.startswith("RF_EXT"):
            label, port = self._get_port_using_label(label)
        elif first_end_point[-2:].isdigit():
            port = int(first_end_point[-2:])
        elif first_end_point[-1].isdigit():
            port = int(first_end_point[-1:])
        else:
            print("ERROR Port number could not be parsed. Take contact to script developer.")
            raise BTSConfigurationNotFound("Port number could not be parsed.")
        return label, port

    def _get_number_of_bbmods_on_left_side(self):
        """
        Checks the number of baseband modules on the left side of a rack.

        :return int: Number of baseband modules on the left side of a rack.
        """
        # important only in fullrack config
        number_of_bbmods_on_left_side = 0
        for bb_mod in self.bts.bts_info['requestMessage']['basebandModules']:
            if self._get_bbmod_side(bb_mod['id']['internal']) == 1:
                number_of_bbmods_on_left_side += 1
        return number_of_bbmods_on_left_side

    @staticmethod
    def _get_port_using_label(label):
        label = label.replace("RFEXT", "")
        label = label.replace("RF_EXT", "")
        if not label:
            label = str(0)
        port = int(label) + 6
        return label, port

    def _get_smod_and_bbmod_id_when_not_fullrack_and_right_side(self, bbmod, first_end_point):
        bbmod_id = int(self._get_unit_id(first_end_point))
        if "configuration" in bbmod['id']:
            bbmod_conf = bbmod['id']['configuration']
            bbmod_conf_id = int(self._get_unit_id(bbmod_conf))
            if bbmod_id != bbmod_conf_id:
                print("Internal DistName and configuration DistName have different numerical values.")
                bbmod_id = bbmod_conf_id
        smod_id = 1
        return smod_id, bbmod_id

    def _get_smod_and_bbmod_id_when_fullrack_and_right_side(self, bbmod_conf, first_end_point):
        number_of_bbmods_on_left_side = self._get_number_of_bbmods_on_left_side()
        bbmod_id = int(self._get_unit_id(first_end_point))
        bbmod_conf_id = self._get_unit_id(bbmod_conf)
        if int(bbmod_conf_id) > 3:
            bbmod_conf_id = int(bbmod_conf_id) - 3
        else:
            bbmod_id = bbmod_id - number_of_bbmods_on_left_side
        if bbmod_id != bbmod_conf_id:
            print("Internal DistName and configuration DistName have different numerical values.")
            bbmod_id = bbmod_conf_id
        smod_id = 2
        return smod_id, bbmod_id

    @staticmethod
    def _check_bbmod_configuration_correctness(bbmod):
        if bbmod['id']['internal'] == "":
            print("ERROR Cannot find BBMod DistName. Take contact to script developer.")
            raise BTSConfigurationNotFound
        if bbmod['id']['configuration'] == "":
            print("ERROR Cannot find BBMOD configuration DistName. Take contact to script developer")
            raise BTSConfigurationNotFound

    def _get_rci_values_from_smod_r(self, first_end_point, smod_port):
        smod_dn = first_end_point[0:first_end_point.rfind("/")]
        for unit_info in self.unit_info:
            try:
                if unit_info['id']['internal'] == smod_dn:
                    smod_port = int(self._get_unit_id(smod_dn))
                    break
            except KeyError:
                pass
        bbmod_port = 0
        order = 1
        return smod_port, bbmod_port, order

    def _find_all_units(self, remote):
        """
        Finds the system modules and baseband modules from the site info and adds them to unit info -list.
        """
        if remote:
            bts_info = self.bts.bts_info_remote
        else:
            bts_info = self.bts.bts_info
        for smod in bts_info['requestMessage']['systemModules']:
            self.unit_info.append(smod)
        for bb_mod in bts_info['requestMessage']['basebandModules']:
            self.unit_info.append(bb_mod)

    @staticmethod
    def _check_that_correct_link_type(link):
        """
        Checks if the link type is correct.

        :param str link: The link type being checked.
        :return bool: Link type is one of the 3 supported types if returns True.
        """
        if link == "RP3_01Link" or link == "EthLink" or link == "CPRILink":
            return True
        return False

    @staticmethod
    def _get_unit_id(value):
        """
        Checks a string for an ID value.
        Example: Gets 1 from the following string:
        /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1
        or from:
        /MRBTS-23262/EQM-1/APEQM-1/CABINET-1/BBMOD-1

        :param str value: The value that is being searched.
        :return str: Returns the unit ID.
        """
        regex = re.compile(r".*/.*MOD_R-(?P<id>\d*).*")
        regex2 = re.compile(r".*/.*MOD-(?P<id>\d*)")
        match = regex.match(value)
        if not match:
            match = regex2.match(value)
        if match:
            return match.group("id")
        print(f"WARNING Could not parse unit ID from {value}")
        return ""

    def _get_bbmod_side(self, bbmod_dn):
        """
        Checks if the BB module is on the right side --> horizontalPosition = 2.

        This is meaningful only when Fullrack in question.

        :param str bbmod_dn: BBMOD DistName.
        :return int: BB module horizontal position in the rack.
        """
        bbmod_mos = self.admin.get_managed_objects('BBMOD_R')
        for bbmod in bbmod_mos:
            if bbmod['distName'] in bbmod_dn:
                return int(bbmod['parameters']['horizontalPosition'])
        print("WARNING Could not find BBMOD side, assume it is left (1).")
        return 1

    def _get_hw_path_of_chained_rmod(self, rmod_name, rmod_dist_name, opt_if3=False):
        """
        Get hw_path of chained radio.

        :param str rmod_name: Radio connections name, eventlog style f.ex. FRHA(1.1.1.2)
        :param str rmod_dist_name: Dist name of radio f.ex
                                   /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-2
        :param bool opt_if3: If True opt_if3 is used instead of opt_if2 for chained radio.
        :return str: Hw_path of chained RMOD. Radio can be f.ex. 4th in row:
        /SMOD_R-1(Left)/BBMOD_R-1(Left_Bottom)/rf1/RMOD_R-1/opt_if2/RMOD_R-2/opt_if2/RMOD_R-3/opt_if2/RMOD_R-4"""
        hw_path = ""
        if opt_if3:
            opt_if = "opt_if3"
        else:
            opt_if = "opt_if2"
        for position_in_chain in range(2, int(rmod_name[-2])):
            if position_in_chain < int(rmod_name[-2]):
                chained_radio_position = f"{rmod_name[-8:-2]}{position_in_chain}"
                chained_radio = self.bts.get_bbmod_object_from_user_given_values(chained_radio_position)
                parsed_radio_r = chained_radio.dist_name.split('/')[-1]
                hw_path = f"{hw_path}/{opt_if}/{parsed_radio_r}"
        parsed_radio_r = rmod_dist_name.split('/')[-1]
        hw_path = f"{hw_path}/{opt_if}/{parsed_radio_r}"
        return hw_path

    def _get_rmod_hw_path_when_attached_to_fhs(self, rmod_name, old_hw_path, bts_info):
        hw_path_beginning, hw_path_end = self._split_hw_path_for_fhs_connected_radio(old_hw_path)
        fh = f"fh{rmod_name[-4]}"
        fhs_r, rf = self._get_fhs_information_for_hw_path(bts_info)
        print(f"FHS ports {rf}")
        if len(rf) > 1:
            allowed_fhs_ports = []
            info(f"FHS is connected with multiple fibers ({rf}). Add all fiber ports to allowed/expected to hw_path.")
            for r in rf:
                allowed_fhs_ports.append(f"{hw_path_beginning}/{r}/{fhs_r}/{fh}/{hw_path_end}")
            print(f"Allowed FHS ports {allowed_fhs_ports}")
            return " / ".join(allowed_fhs_ports)
        return f"{hw_path_beginning}/{rf[0]}/{fhs_r}/{fh}/{hw_path_end}"

    def _get_fhs_information_for_hw_path(self, bts_info):
        rf = ""
        fhs_r = ""
        for fhs in bts_info['requestMessage']['fhs']:
            fhs_dist_name = fhs['id']['internal']
            fhs_r = fhs_dist_name.split("/")[-1]
            rf = self._get_bbmod_fhs_port(bts_info, fhs_r)
        return fhs_r, rf

    @staticmethod
    def _get_bbmod_fhs_port(bts_info, fhs_r):
        fhs_ports = []
        for cable in bts_info['requestMessage']['cables']:
            if fhs_r in cable['secondEndPointId']['internal']:  # and not cable['linkMode']['configuration']:
                port = cable['firstEndPointId']['internal'].split("/")[-1].lower()
                if port not in fhs_ports:
                    fhs_ports.append(port)
        if fhs_ports:
            return fhs_ports
        print("WARNING Could not find FHS port connected to BBMOD, assume it is 'RF2'.")
        return ["rf2"]

    @staticmethod
    def _split_hw_path_for_fhs_connected_radio(old_hw_path):
        i = old_hw_path.rfind("/rf")
        return old_hw_path[:i], old_hw_path[(i+5):]

    def _get_bbmod_id_and_info(self, bbmod_id, first_end_point):
        """
        Returns BBMOD ID for RCI and BBMOD information from unit_info.
        """
        bbmod_dn = first_end_point[0:first_end_point.rfind("/")]
        bbmod_info = {"id": {"internal": "",
                             "configuration": ""
                             }
                      }
        for unit_info in self.unit_info:
            try:
                if unit_info['id']['internal'] == bbmod_dn:
                    bbmod_info = unit_info  # bbu
                    bbmod_id = int(self._get_unit_id(bbmod_dn))
                    if "configuration" in unit_info['id']:
                        bbmod_conf = unit_info['id']['configuration']
                        bb_unit_configuration = int(self._get_unit_id(bbmod_conf))
                        if bb_unit_configuration > 3:
                            bb_unit_configuration -= 3
                        if bbmod_id != bb_unit_configuration:
                            print(f"Internal DistName and configuration DistName have different numerical values. "
                                  f"Choose id from configuration DistName {unit_info['id']}")
                            bbmod_id = bb_unit_configuration
                    break
            except KeyError:
                pass
        return bbmod_id, bbmod_info

    def _get_bb_unit(self, bb_unit, bbmod_dn, cable, unit_info):
        """
        Used to find bb_unit for RCI when FHS or chained radios in question.
        """
        if unit_info['id']['internal'] == bbmod_dn:
            bb_id = int(self._get_unit_id(bbmod_dn))
            if bb_unit == 0 or str(cable['linkMode']['configuration']) == "False":
                bb_unit = bb_id
                if "configuration" in unit_info['id']:
                    bbmod_conf = unit_info['id']['configuration']
                    bb_unit_configuration = int(self._get_unit_id(bbmod_conf))
                    if bb_unit_configuration > 3:
                        bb_unit_configuration -= 3
                    if bb_unit != bb_unit_configuration:
                        print(f"Internal DistName and configuration DistName have different numerical values. "
                              f"Choose number of configuration DistName {unit_info['id']}")
                        bb_unit = bb_unit_configuration
        return bb_unit

    def _get_rci_values_using_bbmod_r(self, bbmod_id, cable, first_end_point, label, port):
        bbmod_dn = first_end_point[0:first_end_point.rfind("/")]
        for unit_info in self.unit_info:
            bbmod_id = self._get_bb_unit(bbmod_id, bbmod_dn, cable, unit_info)
        if first_end_point.endswith("RF_EXT"):
            # special where RF_EXT in internal name instead SFP_R-1
            bb_mod_port = 1
        else:
            if first_end_point[-1].isdigit():
                bb_mod_port = int(first_end_point[-1])  # port > 9 ??
            else:
                print("ERROR Cannot parse BBMOD port, take contact to script developer.")
                raise BTSConfigurationNotFound("Cannot parse BBMOD port.")
        if first_end_point and int(self._get_bbmod_side(first_end_point)) == 2 and self.bts.fullrack:
            smod_id = 2
        else:
            smod_id = 1
        if bb_mod_port < port:
            port = bb_mod_port
            label = first_end_point[first_end_point.rfind("/") + 1:]
        return smod_id, bbmod_id, label, port

    @staticmethod
    def _get_abil_port(rmod_port):
        """
        This method parses ABIL specific name for rf port in hw_path
        :param str rmod_port: ABIL has 4 ports for radio. So this parameter can be 1-4.
        """
        if rmod_port == "1":
            abil_port = "s_rf1"
        elif rmod_port == "2":
            abil_port = "s_rf2"
        elif rmod_port == "3":
            abil_port = "q_rf1"
        elif rmod_port == "4":
            abil_port = "q_rf2"
        else:
            print(f"ERROR ABIL can have 1-4 radios connected. Now radio port {rmod_port} is given")
            raise ScriptIssue
        return abil_port

    def _create_radio_object(self, radio_name, dist_name, serial_number, scf_dist_name, ip_address, product_code,
                             cablink_type, remote=False):
        """
        Creates an object for a radio.

        :param str radio_name: RCI (Radio Configuration Identifier)
        :param str dist_name: DistName of the radio.
        :param str serial_number: Serial number of the radio.
        :param str scf_dist_name: SCF dist_name of the radio.
        :param str ip_address: IP address of the radio.
        :param str cablink_type: Cablink type of the radio.
        :param bool remote: Default is False, if needed from other side give True
        :return obj radio: Returns the created radio class object.
        """
        radio = RCI()
        radio.name = radio_name
        radio.dist_name = dist_name
        radio.serial_number = serial_number
        radio.scf_dist_name = scf_dist_name
        if remote:
            radio.unit_path = f"[{self.bts.bts_name_remote}] {scf_dist_name}"
        else:
            radio.unit_path = f"[{self.bts.bts_name}] {scf_dist_name}"
        radio.ip = ip_address
        radio.hw_path = self.get_hw_path(radio_name, dist_name)
        radio.product_code = product_code
        radio.cablink_type = cablink_type
        return radio

    @staticmethod
    def _organize_radio_names_according_to_port_numbers(radio_list):
        """
        Organizes the radio names according to the port numbers within each radio object.
        Uses the following order: BBMOD port, BBMOD, SMOD.

        :param list radio_list: List of radio objects.
        """
        for radio in radio_list:
            chosen_radio_name = radio.name
            if radio.multi_fibre_connection:
                for other_radio in radio.multi_fibre_connection:
                    # Extract the numbers from the radio names
                    radio_name_parts = radio.name[radio.name.index("(") + 1:radio.name.index(")")].split('.')
                    other_radio_name_parts = other_radio[other_radio.index("(") + 1:other_radio.index(")")].split('.')

                    # Convert the numbers to integers
                    radio_name_parts = [int(num) for num in radio_name_parts]
                    other_radio_name_parts = [int(num) for num in other_radio_name_parts]

                    # Compare the BBMOD ports, use the smaller port number
                    if radio_name_parts[2] > other_radio_name_parts[2]:
                        chosen_radio_name = other_radio
                    elif radio_name_parts[2] == other_radio_name_parts[2]:
                        # If the BBMOD ports are the same, compare the BBMODs, and use the smaller BBMOD number
                        if radio_name_parts[1] > other_radio_name_parts[1]:
                            chosen_radio_name = other_radio
                        elif radio_name_parts[1] == other_radio_name_parts[1]:
                            # If the BBMODs are the same, compare the SMODs, and use the smaller SMOD number
                            if radio_name_parts[0] > other_radio_name_parts[0]:
                                chosen_radio_name = other_radio

            # Re-arrange the radio names if needed
            if radio.name != chosen_radio_name:
                radio.multi_fibre_connection.append(radio.name)
                radio.multi_fibre_connection.remove(chosen_radio_name)
                radio.name = chosen_radio_name
        return radio_list

    def check_if_shared_radios_and_not_master(self, remote=False):
        """
        Check if radio is shared and not master method checks the value of peerBtsActSharedRUIndControl and
         radioMasterDN. If there are values in the parameters -> radio is not master, and it is a shared resource.

        :param bool remote: Default False, if check should be done from Other side then use True
        """
        rfs = BuiltIn().get_variable_value("${RFS}")
        if rfs:
            print(f"RFS environment. Check if radios are shared and if not a master radio.")
            if not self.bts:
                self.bts = BuiltIn().get_library_instance("BTS")
            if remote:
                rmod_mos = self.admin.get_managed_objects("RMOD_R", connection="remote")
                bts_radios = self.bts.radios_remote
            else:
                rmod_mos = self.admin.get_managed_objects("RMOD_R")
                bts_radios = self.bts.radios
            if rmod_mos and bts_radios:
                for radio in bts_radios:
                    for rmod_mo in rmod_mos:
                        if radio.dist_name == rmod_mo['distName']:
                            if 'peerBtsActSharedRUIndControl' in rmod_mo['parameters']:  # has values True/False/None
                                shared_ru_control = str(rmod_mo['parameters']['peerBtsActSharedRUIndControl'])
                                print(f"peerBtsActSharedRUIndControl = {shared_ru_control}")
                                if shared_ru_control.lower() in ("true", "false"):
                                    if 'radioMasterDN' in rmod_mo['parameters']:
                                        rmod_master_dn = str(rmod_mo['parameters']['radioMasterDN'])
                                        if rmod_master_dn and "SMOD_EXT" in rmod_master_dn:
                                            print(f"Radio {radio.name} is shared and not a master radio ("
                                                  f"radioMasterDN={rmod_master_dn}).")
                                            radio.master_radio = False
                                        else:
                                            print(f"Radio {radio.name} is shared and it is a master radio "
                                                  f"(radioMasterDN={rmod_master_dn}).")
                                else:
                                    print(f"Radio {radio.name} is not shared and it is a master radio.")

    def get_cells_of_all_master_radios(self):
        """
        Get cells of all master radios.
        """
        all_cells_of_masters = []
        master_radios = self.get_all_master_radios()
        for master_rmod in master_radios:
            cells = self.get_cells_mapped_to_rmod(master_rmod)
            print(f"Cells of {master_rmod}: {cells}")
            for cell in cells:
                if cell not in all_cells_of_masters:
                    all_cells_of_masters.append(cell)
        print(f"All cells of master radios: {all_cells_of_masters}")
        self.logger.debug(f"All cells of master radios: {all_cells_of_masters}")
        return all_cells_of_masters

    def get_all_master_radios(self):
        """Get all master radios"""
        master_radios = []
        for rmod in self.bts.radios:
            if rmod.master_radio:
                print(f"Master radio: {rmod.name}")
                master_radios.append(rmod.name)
        print(f"Master radios: {master_radios}")
        self.logger.debug(f"Master radios: {master_radios}")
        return master_radios


class RCI(object):
    """
    Initializes a RMOD Configuration Identifier -object.
    """
    def __init__(self):
        self.name = None
        self.dist_name = None
        self.serial_number = None
        self.scf_dist_name = None
        self.unit_path = None
        self.hw_path = None
        self.ip = None
        self.cablink_type = None
        self.multi_fibre_connection = []
        self.master_radio = True
        self.shared_radio = None
