"""
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import re
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin.exceptions import AliasInUse
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import EnvironmentIssue, ScriptIssue, ErrorFromAdmin


class CellResources:
    """
    Class for parsing cell resources.

    CellResources is called in common_resources.robot. If the class is already initiated once, import robot BuiltIn
        >> from robot.libraries.BuiltIn import BuiltIn
    and call with
        >> BuiltIn().get_library_instance("CELL_RESOURCES")
    """
    bbpools_cells = {}

    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.bts = None
        self.logger = BuiltIn().get_library_instance("LOG")

    def get_corepools_of_cell(self, return_just_core_pools=False):
        """
        Gets corepools of cells. This method is needed for parsing cell resources.

        :param bool return_just_core_pools: Default is False. If set to True returns just corepools otherwise gets also
                                            soc information.
        :return dict: Returns dictionary where cell is a key and corepools as a list value or .
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")

        info("Get cell resources.")
        cell_cores = {}
        cell_to_pool_mos = self.admin.get_managed_objects("CELL_TO_POOL_MAPPING_L")
        if cell_to_pool_mos:
            for cell_to_pool_mo in cell_to_pool_mos:
                cell_cores = self._get_cell_resources_from_cell_to_pool_mo(cell_to_pool_mo, cell_cores)
            if cell_cores:
                for cell, cores in cell_cores.items():
                    info("Resources of cell-{} are in core pools: {}".format(cell, cores))
            else:
                error("Could not parse cell resources. Check from ims2 logs if names of objects have changed")
        else:
            error("No CELL_TO_POOL_MAPPING_L information found. Cannot parse cell resources.")
        if cell_cores:
            if return_just_core_pools:
                return cell_cores
            else:
                cells_affected = self._get_soc_information(cell_cores)
                return cells_affected
        else:
            raise EnvironmentIssue("Cell resources could not be found.")

    def check_correct_bbpool(self, user_given_bbpool, bbpool_cells=None):
        """
        Check that BBPool is correct and can be reset. Correct bbpool means that bbpool is connected to cell(s) with
        resources only on K2C or K2D. If resources on K2A or K2B, ABIA makes reset as well.

        :param str user_given_bbpool: BB Pool which correctness will be checked. Can be for example BBPool12.
        :param list bbpool_cells: Default None. List of cells of BBPool for example ['2']. If None then gets cell
                                  ids of given BBPool.
        :return bool: True if no cells of the selected pool on K2A or K2B.
        """
        cell_cores = self.get_corepools_of_cell(return_just_core_pools=True)
        cell_fsp_res = self._get_soc_information(cell_cores)
        if bbpool_cells is None:
            bbpool_cells = self.get_cell_ids_of_bbpool(user_given_bbpool)
        for cell, fsp_and_k2 in cell_fsp_res.items():
            for fsp, k2 in fsp_and_k2.items():
                if CellResources.bbpools_cells:
                    for bbpool, cells_of_bbpool in CellResources.bbpools_cells.items():
                        if cells_of_bbpool and cell in cells_of_bbpool:
                            info("{} is connected to {} of {}".format(bbpool, k2, fsp))
                else:
                    self.logger.debug("CellResources.bbpools_cells is empty...")
                if ("K2A" in k2 or "K2B" in k2) and cell in bbpool_cells:
                    info("User has selected {} and it is connected to {}. NOTE that K2A and K2B resets {}.".format(
                        user_given_bbpool, k2, fsp))
                    BuiltIn().set_suite_variable("${BBPOOL_RESETS_BBMOD}", "${True}")
                    # raise EnvironmentIssue("Unallowed BBPool is selected to test.")

    def get_cell_ids_of_virtual_node(self, virtual_node):
        """
        Returns a list of cell ids for given virtual node.

        :param str virtual_node: Virtual node which cells are get. Can be for example SW_NODE_L-4
        """
        cells_on_virtual_nodes = self._get_cells_mapped_to_virtual_nodes()
        if virtual_node not in cells_on_virtual_nodes:
            info("No cells mapped to {}".format(virtual_node))
            return []
        return cells_on_virtual_nodes[virtual_node]

    def get_cells_of_soc(self, bbmod, selected_soc):
        """
        Get cells of selected SOC. Returns a list of cell ids for given SOC.

        :param str bbmod: Name of selected BBMOD. For example ABIA1, ABIO2, ABIN3 etc.
        :param str selected_soc: Name of selected SOC. For example K2A, K2D, SNF, LOKI#A, LFA, LUNUM, Thor, Marlin etc.
        """
        cell_fsp_res = self.get_corepools_of_cell()
        cells_of_soc = []
        for cell, fsp_and_soc in cell_fsp_res.items():
            for fsp, soc in fsp_and_soc.items():
                if fsp == bbmod and selected_soc in soc:
                    self.logger.debug("{} is supported by {} of {}".format(cell, selected_soc, fsp))
                    if cell not in cells_of_soc:
                        cells_of_soc.append(cell)
        if not cells_of_soc:
            info("{} of {} doesn't have any cell resources.".format(selected_soc, bbmod))
        else:
            info("Cells {} are supported by {} of {}".format(cells_of_soc, selected_soc, bbmod))
        return cells_of_soc

    def get_cell_ids_and_socs_of_bbpool(self, bbpool):
        """
        Returns the list of cell ids for given BB pool.

        :param str bbpool: BB Pool which cells are get. Can be for example BBPool12
        :raise ScriptIssue: If given BBPool is not found from the environment
        """
        bbpool_cells, bbppool_socs = self._get_cell_ids_and_socs_of_all_bbpools()
        if bbpool not in bbpool_cells:
            error("User given BB Pool {} not found, cannot get cells of the pool ({}).".format(bbpool, bbpool_cells))
            raise ScriptIssue
        return bbpool_cells[bbpool], bbppool_socs[bbpool]

    def get_alarm_id_based_on_sw_node(self, sw_node):
        """
        Select alarm_id according to cell resources on virtual node.

        :param str sw_node: Virtual node for example SW_NODE_L-4
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        cells_on_vn = self.get_cell_ids_of_virtual_node(sw_node)
        if not cells_on_vn:
            info("No affected cells on virtual node {} -> alarm_id: 7651 (legacy)".format(sw_node))
            return "7651"
        elif self.bts.cells and len(self.bts.cells) == len(cells_on_vn):
            info("All cell resources on BTS are on selected virtual node {} -> alarm_id: 7650 (legacy)".format(sw_node))
            return "7650"
        else:
            info("Cell resources on virtual node {} -> alarm_id: 7653 (legacy)".format(sw_node))
            return "7653"

    def get_alarm_id_based_on_cell_resources_on_bbmod(self, bbmod_name, cells_on_bbmod=None):
        """
        Select alarm_id according to cell resources on bbmod.

        :param str bbmod_name: Namu of BBMOD unit for example ABIA1, ABIO2, ABIN3 etc.
        :param str cells_on_bbmod: List of cells on BBMOD or None if not given.
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        if cells_on_bbmod is None:
            cells_on_bbmod = self.bts.get_cells_of_bbmod(bbmod_name)
        if not cells_on_bbmod:
            info("No cell resources on selected BBMOD {} -> alarm_id: 7651 (legacy)".format(bbmod_name))
            return "7651"
        elif self.bts.cells and len(self.bts.cells) == len(cells_on_bbmod):
            info("All cell resources of BTS are on selected BBMOD {} -> alarm_id: 7650 (legacy)".format(bbmod_name))
            return "7650"
        else:
            info("Cell resources on selected BBMOD {} -> alarm_id: 7653 (legacy)".format(bbmod_name))
            return "7653"

    def _get_cell_resources_from_cell_to_pool_mo(self, cell_to_pool_mo, cell_cores):
        cell_to_pool_parser = re.compile(r".*/MRBTS-\d+/RAT-\d+/MCTRL-{}/BBTOP_M-\d+/LAYOUT_MAP-\d+"
                                         r"/CELL_TO_POOL_MAPPING_L-\d+.*".format(self.bts.side))

        cell_to_pool_dn = cell_to_pool_parser.match(cell_to_pool_mo["distName"])
        if cell_to_pool_dn:
            parameter_dict = cell_to_pool_mo["parameters"]
            if "cellDN" in parameter_dict:
                cell_cores = self._get_cell_cores(cell_cores, parameter_dict)
            else:
                error("No cellDN found from parameters. Check ims2 log and request an update for unit names.")
        else:
            self.logger.debug(
                r"distName of CELL_TO_POOL_MAPPING_L {} was not match to regex: .*/MRBTS-\d+/RAT-\d+/MCTRL-{}/BBTOP_M-"
                r"\d+/LAYOUT_MAP-\d+/CELL_TO_POOL_MAPPING_L-\d+.*".format(cell_to_pool_mo["distName"],
                                                                          self.bts.side))
        self.logger.debug("Cell cores after _get_cell_resources_from_cell_to_pool_mo: {}".format(cell_cores))
        return cell_cores

    def _get_cell_cores(self, cell_cores, parameter_dict):
        cell_id = self._parse_cell_id(parameter_dict)
        if cell_id and cell_id.group("cell"):
            cell = str(cell_id.group("cell"))
            corepools = self._get_corepools_in_cell_using_corepool_dn(parameter_dict)
            cell_cores[cell] = corepools
        else:
            self.logger.debug("Could not parse cell ID from cellDN.")
        self.logger.debug("Cell cores in _get_cell_cores: {}".format(cell_cores))
        return cell_cores

    def _parse_cell_id(self, parameter_dict):
        cell_id_parser = re.compile(r".*RAT-\d+/MCTRL-{}/BBTOP_M-\d+/MRBTS_M-\d+/..BTS_M-\d+"
                                    r"/CELL_M-(?P<cell>\d+).*".format(self.bts.side))
        cell_dn = parameter_dict["cellDN"]
        self.logger.debug("CellDN for parsing cell ID: {}".format(cell_dn))
        cell_id = cell_id_parser.match(cell_dn)
        return cell_id

    def _get_corepools_in_cell_using_corepool_dn(self, parameter_dict):
        corepool_parser = re.compile(r".*/MRBTS-\d+/RAT-\d+/MCTRL-{}/BBTOP_M-\d+/LAYOUT_MAP-\d+/"
                                     r"(?P<corepool>CORE_POOL_L-\d+).*".format(self.bts.side))
        corepools = []
        if "cellSlots" in parameter_dict:
            cell_slots = parameter_dict["cellSlots"]
            for slot in cell_slots:
                if "poolDN" in slot:
                    pool_dn = corepool_parser.match(str(slot["poolDN"]))
                    if pool_dn and pool_dn.group("corepool"):
                        if str(pool_dn.group("corepool")) not in corepools:
                            corepools.append(str(pool_dn.group("corepool")))
                    else:
                        error("Appearance of poolDN have changed. Check values from "
                              "ims2 log and request update for regex.")
                else:
                    error("No poolDN found. Check values from ims2 log and request update for regex.")
                    raise EnvironmentIssue("No poolDN found from cellSlots of CELL_TO_POOL_MAPPING_L.")
        return corepools

    def _get_soc_information(self, cell_cores):
        socs_of_cell = self._get_socs_of_cell_from(cell_cores)
        cell_and_fsp_soc_dict = self._get_cell_and_fsp_soc_dict(socs_of_cell)
        return cell_and_fsp_soc_dict

    def _all_unique_sw_nodes(self, sw_class):
        sw_node_schema_and_socs = {}
        sw_node_schema_objects = self.admin.get_managed_objects(sw_class)
        if sw_node_schema_objects:
            for sw_node_schema in sw_node_schema_objects:
                parameters = sw_node_schema["parameters"]
                sw_node_schema_and_socs[sw_node_schema["distName"]] = (str(parameters["instanceNumber"]),
                                                                       (str(parameters["uniqueInstanceId"])))
        return sw_node_schema_and_socs

    def _find_sw_node_l_objects(self):
        sw_node_schema_ids = self._all_unique_sw_nodes("SW_NODE_SCHEMA")
        sw_node_ids = self._all_unique_sw_nodes("SW_NODE_L")
        schema_to_l_object_relation = {}
        for schema, schema_id in sw_node_schema_ids.items():
            for l_object, l_id in sw_node_ids.items():
                if schema_id[0] == l_id[0] and schema_id[1] == l_id[1]:
                    schema_to_l_object_relation[schema] = l_object
        self.logger.debug(f"Schema to L object relation: {schema_to_l_object_relation}")
        return schema_to_l_object_relation

    def _get_socs_of_cell_from(self, cell_cores):
        socs_of_cell = {}
        schema_to_l_object_relation = self._find_sw_node_l_objects()
        corepool_mos = self.admin.get_managed_objects("CORE_POOL_L")
        for cell, cores in cell_cores.items():
            all_socs = self._get_all_socs_in_core(corepool_mos, cores, schema_to_l_object_relation)
            socs_of_cell[cell] = all_socs
        return socs_of_cell

    def _get_all_socs_in_core(self, corepool_mos, cores, schema_to_l_object_relation):
        parse_corepool = re.compile(
            rf".*/MRBTS-\d+/RAT-\d+/(LTS-|NRTS-){self.bts.side}/(?P<corepool>CORE_POOL_L-\d+).*")
        all_socs = []
        if corepool_mos:
            all_socs = self._search_corepool_mos_for_socs_in_core(all_socs, corepool_mos, cores, parse_corepool,
                                                                  schema_to_l_object_relation)
        return all_socs

    def _search_corepool_mos_for_socs_in_core(self, all_socs, corepool_mos, cores, parse_corepool,
                                              schema_to_l_object_relation):
        for corepool_mo in corepool_mos:
            parameter_dict = corepool_mo["parameters"]
            corepool_dn = parse_corepool.match(corepool_mo["distName"])
            if corepool_dn and corepool_dn.group("corepool"):
                corepool = str(corepool_dn.group("corepool"))
                if corepool in cores:
                    all_socs = self._search_cores_for_socs_from_corepool_mo(all_socs, parameter_dict,
                                                                            schema_to_l_object_relation)
        return all_socs

    def _search_cores_for_socs_from_corepool_mo(self, all_socs, parameter_dict, schema_to_l_object_relation):
        if "cores" in parameter_dict:
            cores = parameter_dict["cores"]
            for core in cores:
                all_socs = self._add_core_dn_to_soc_list(all_socs, core, schema_to_l_object_relation)
        else:
            error("Name of cores may have changed. Check values from ims2 logs and request update.")
            raise EnvironmentIssue
        return all_socs

    @staticmethod
    def _add_core_dn_to_soc_list(all_socs, core, schema_to_l_object_relation):
        if "coreDN" in core:
            core_dn = str(core["coreDN"])
            if core_dn not in all_socs and 'SW_NODE_SCHEMA' not in core_dn and "SMOD_L" not in core_dn:
                all_socs.append(core_dn)
            elif "SW_NODE_SCHEMA" in core_dn:
                if core_dn in schema_to_l_object_relation:
                    if schema_to_l_object_relation[core_dn] not in all_socs:
                        all_socs.append(schema_to_l_object_relation[core_dn])
                else:
                    error(f"SW_NODE_SCHEMA object '{core_dn}' can't be linked to SW_NODE_L object")
        return all_socs

    def _get_cell_and_fsp_soc_dict(self, cells_and_socs):
        cell_and_fsp_soc_dict = self._fsp_soc_cells(cells_and_socs)
        if cell_and_fsp_soc_dict:
            self._check_that_cells_and_socs_info_is_correct(cell_and_fsp_soc_dict)
        else:
            info("Cell-FSP-SoC dict is empty, this is OK if SoC has SW_NODE_SCHEMA instead of SW_NODE_L in coreDN.")
        return cell_and_fsp_soc_dict

    @staticmethod
    def _check_that_cells_and_socs_info_is_correct(cells_and_socs):
        for cell, fsp_socs in cells_and_socs.items():
            if len(fsp_socs.keys()) == 1:
                for fsp, socs in fsp_socs.items():
                    info("Resources of cell-{} are supported in {} of {}".format(cell, socs, fsp))
            elif len(fsp_socs.keys()) > 1:
                info("Resources of cell-{} are supported in:".format(cell))
                for fsp, socs in fsp_socs.items():
                    info("{} of {}".format(socs, fsp))
            else:
                error("There are no supported resources found for any FSP that is mapped to cell-{}".format(cell))
                raise EnvironmentIssue

    def _fsp_soc_cells(self, cells_and_socs):
        cell_and_fsp_soc_dict = {}
        soc_mos = self.admin.get_managed_objects("SOC_L")
        if soc_mos:
            for cell, socs in cells_and_socs.items():
                cell_and_fsp_soc_dict = self._fill_cell_and_fsp_soc_dict(cell, cell_and_fsp_soc_dict, soc_mos, socs)
        else:
            error("SOC_L not found from ims2. Check values from ims2 log and request update from script developer.")
            raise EnvironmentIssue
        return cell_and_fsp_soc_dict

    def _fill_cell_and_fsp_soc_dict(self, cell, cells_and_socs, soc_mos, socs):
        sw_nodes = self._get_affected_sw_nodes_by(socs)
        if sw_nodes:
            info("SW_NODE_Ls that supports resources of cell-{} are {}".format(cell, sw_nodes))
            node_ids_of_affected_sw_nodes = self._collect_node_ids_of_affected_sw_nodes(sw_nodes)
            info("NodeIDs of SW_NODE_Ls that supports cell-{} are {}".format(
                cell, node_ids_of_affected_sw_nodes))
            fsp_soc_dict = self._parse_fsp_and_soc(soc_mos, socs, node_ids_of_affected_sw_nodes)
            cells_and_socs[cell] = fsp_soc_dict
        return cells_and_socs

    def _get_affected_sw_nodes_by(self, socs):
        parse_socs_sw_node = re.compile(
            rf".*RAT-\d+/(?P<bbmod_bbu>BTS_L-{self.bts.side}/EQM_L-\d+/CABINET_L-\d+/BBMOD_L-\d+/(BBU|BOARD)_L-\d+)/"
            rf"(?P<pwr>POWER_GROUP_L-\d+)/(?P<soc>SOC_L-\d+)/(?P<swnode>SW_NODE_L-\d+).*")
        affected_swnodes = []
        for soc in socs:
            match = parse_socs_sw_node.match(soc)
            if match:
                swnode = str(match.group("swnode"))
                affected_swnodes.append(swnode)  # SW_NODE_L-2, SW_NODE_L-3, SW_NODE_L-4, SW_NODE_L-7
            if not match:
                self.logger.debug(f"Could not parse value {soc} to find SW_NODE_L.")
        return affected_swnodes

    def _collect_node_ids_of_affected_sw_nodes(self, sw_nodes):
        """Collects nodeId as hex"""
        affected_node_ids = []
        mos = self.admin.get_managed_objects("SW_NODE_L")
        if mos:
            for mo in mos:
                parameter_dict = mo["parameters"]
                dist_name = str(mo.get("distName", ""))
                last_segment = self._safe_split(dist_name, "/")[-1]
                if any(j for j in sw_nodes if j == last_segment):
                    if 'nodeId' in parameter_dict:
                        ni = int(parameter_dict["nodeId"])
                        hex_id = hex(ni)
                        if hex_id not in affected_node_ids:
                            affected_node_ids.append(hex_id)
                    else:
                        error("nodeId is not found from SW_NODE_L. Check ims2 log and contact script developer")
                        raise EnvironmentIssue
        return affected_node_ids

    def _parse_fsp_and_soc(self, soc_mos, socs, node_ids_of_affected_cells):
        fsp_soc_dict = {}
        parse_socs = re.compile(
            r".*RAT-\d+/(?P<bbu>BTS_L-{}/EQM_L-\d+/CABINET_L-\d+/(BBMOD|SMOD)_L-\d+/(BBU|BOARD)_L-\d+)/"
            r"(?P<power_group>(POWER_GROUP_L-\d+|))/(?P<soc>SOC_L-\d+).*".format(self.bts.side))
        for soc_mo in soc_mos:
            parameter_dict = soc_mo["parameters"]
            for i in socs:
                match = parse_socs.match(i)
                if match:
                    bbu = str(match.group("bbu"))
                    power_group = str(match.group("power_group"))
                    soc_l = str(match.group("soc"))
                    if (bbu in str(soc_mo["distName"]) and power_group in str(soc_mo["distName"])
                            and soc_l in str(soc_mo["distName"])):
                        fsp_soc_dict = self._get_fsp_soc_dict_using_hw_variant(
                            bbu, fsp_soc_dict, node_ids_of_affected_cells, parameter_dict, power_group, soc_l)
        return fsp_soc_dict

    def _get_fsp_soc_dict_using_hw_variant(self, bbmod, fsp_soc_dict, node_ids_of_affected_cells, soc_mos,
                                           power_group, soc_l):
        if "hwVariant" in soc_mos:
            variant = str(soc_mos["hwVariant"])
            if self._check_if_kepler2(variant):
                soc = self._get_k2_soc_by(power_group, soc_l)
            else:
                soc = self._fsp_other_cells(soc_mos, variant, node_ids_of_affected_cells)
            if soc:
                fsp_soc_dict = self._modify_fsp_soc_dict(fsp_soc_dict, bbmod, soc)
        else:
            error("hwVariant is not found from SOC_L. Check ims2 log and contact script developer")
            raise EnvironmentIssue
        return fsp_soc_dict

    @staticmethod
    def _check_if_kepler2(variant):
        """Check if kepler"""
        if variant:
            if variant == "Kepler2":
                return True
        else:
            error("Parameter hwVariant is not found under SOC_L -object. Check ims2 logs "
                  "and take contact to script developer.")
            raise EnvironmentIssue
        return False

    def _fsp_other_cells(self, soc_mo, variant, node_ids_of_affected_cells):
        soc = ""
        s_id = int(soc_mo["id"])
        if variant and s_id and any(j for j in node_ids_of_affected_cells if hex(s_id) in j):
            soc = self._get_soc_by(variant, str(s_id))
        return soc

    def _modify_fsp_soc_dict(self, fsp_soc_dict, bbmod, soc):
        bci = self._get_bci_for(bbmod)
        if bci not in fsp_soc_dict:
            fsp_soc_dict[bci] = [soc]
        elif soc not in fsp_soc_dict[bci]:
            fsp_soc_dict[bci].append(soc)
        return fsp_soc_dict

    @staticmethod
    def _get_soc_by(hw_variant, node_id):
        """Get name of soc"""
        # LFA/SFN/XEONA 0x123,0x133,0x133, 0x223,0x233,0x243
        if node_id in ('291', '307', '323', '513', '547', '563', '579'):
            if hw_variant in "Marlin":
                soc = "Marlin"  # ABIP
            elif hw_variant in ("Snowfish", "snowfish", "Loki", "loki"):
                soc = "SNF"  # ABIN/ABIO
            elif hw_variant in ("Lionfish", "lionfish", "StratixLunumFpga", "Lunum"):
                soc = "LFA"  # ABIC
            elif hw_variant in ("StratixLonerFpga", "XeonD", "XEON", "Xeon", "Loner", "LONER", 'loner'):
                soc = "XEONA"  # ABIL
            else:
                error("Unknown HW variant {}".format(hw_variant))
                raise EnvironmentIssue
        elif node_id in ('292', '308', '324', '548', '564', '580'):  # LOKI#A 0x124,0x134,0x144, 0x224,0x234,0x244
            if hw_variant in "Thor":
                soc = "Thor"  # ABIP
            elif hw_variant in "Magni":
                soc = "Magni"  # ABIQ
            elif hw_variant in ("Snowfish", "snowfish", "Loki", "loki"):
                soc = "LOKI#A"  # ABIN/ABIO
            elif hw_variant in ("Lionfish", "lionfish", "StratixLunumFpga", "Lunum"):
                soc = "LFB"  # ABIC
            elif hw_variant in ("StratixLonerFpga", "XeonD", "XEON", "Xeon", "Loner", "LONER", 'loner'):
                soc = "XEONB"  # ABIL
            else:
                error("Unknown HW variant {}".format(hw_variant))
                raise EnvironmentIssue
        # LOKI#B 0x125,0x135,0x145, 0x225,0x235,0x245
        elif node_id in ('293', '309', '325', '549', '550', '565', '566', '581', '582'):
            if hw_variant in ("Snowfish", "snowfish", "Loki", "loki"):
                soc = "LOKI#B"  # ABIN/ABIO
            elif hw_variant in ("Lionfish", "lionfish", "StratixLunumFpga", "Lunum"):
                soc = "Lunum"  # ABIC
            elif hw_variant in ("StratixLonerFpga", "XeonD", "XEON", "Xeon", "Loner", "LONER", 'loner'):
                soc = "LONER"  # ABIL
            else:
                error("Unknown HW variant {}".format(hw_variant))
                raise EnvironmentIssue
        else:
            error("Unknown id value '{i}' for SOC_L, check ims2 file and "
                  "take contact to script developer".format(i=node_id))
            raise EnvironmentIssue
        return soc

    @staticmethod
    def _get_k2_soc_by(power_group, soc_l):
        """Parse name of cores"""
        soc = ""
        if "1" in power_group and "1" in soc_l:
            if "K2A" not in soc:
                soc = "K2A"
        elif "1" in power_group and "2" in soc_l:
            if "K2B" not in soc:
                soc = "K2B"
        elif "2" in power_group and "1" in soc_l:
            if "K2C" not in soc:
                soc = "K2C"
        elif "2" in power_group and "2" in soc_l:
            if "K2D" not in soc:
                soc = "K2D"
        return soc

    def _get_bci_for(self, bbu):
        """
        Get BCI (BBMOD Configuration Identifier).
        """
        node_id = self._get_node_id_for(bbu)
        bci = self._get_bci_by(node_id)
        if not bci:
            error("Problems to get BBMOD Configuration Identifier.")
            raise ScriptIssue
        return bci

    def _get_node_id_for(self, bbu):
        fsp_mos = self._get_fsp_mos()
        node_id = ""
        for fsp_mo in fsp_mos:
            parameter_dict = fsp_mo["parameters"]
            correct_fsp_mo = self._check_if_fsp_mo_corresponds_bbu(bbu, fsp_mo)
            if correct_fsp_mo:
                if "nodeId" in parameter_dict:
                    node_id = str(parameter_dict["nodeId"])
                    break
                elif "nodeIdOwn" in parameter_dict:
                    node_id = str(parameter_dict["nodeIdOwn"])
                    break
        if not node_id:
            error("Could not get nodeId value of BBU_L nor BOARD_L object. Check ims2 logs and take "
                  "contact to script developer")
            raise EnvironmentIssue
        return node_id

    def _get_fsp_mos(self):
        fsp_mos = list(self.admin.get_managed_objects("BBU_L"))
        fsp_mos.extend(self.admin.get_managed_objects("BOARD_L"))
        if not fsp_mos:
            error("Could not get BBU_L or BOARD_L objects from ims2. Check ims2 logs and take contact to "
                  "script developer")
            raise EnvironmentIssue
        return fsp_mos

    def _check_if_fsp_mo_corresponds_bbu(self, bbu, fsp_mo):
        bbu_regex = r".*RAT-1(/%s/|/)EQM_L-1.*/(?P<bbu>{}).*".format(self.bts.side, bbu)
        if len(bbu) > 17:
            bbu_regex = r".*RAT-1(/{}).*".format(bbu)
        parse_bbu = re.compile(bbu_regex)
        match = parse_bbu.match(fsp_mo["distName"])
        if match:
            return True
        else:
            return False

    def _get_bci_by(self, node_id):
        for fsp in self.bts.bbmods:
            unit_name = fsp.name
            if node_id == '18':
                if "1" in unit_name and 'FBB' not in unit_name and '.' not in unit_name:
                    # location is 0x12 (18 as decimal) ABIA1
                    return unit_name
            elif node_id == '19':
                if 'ABI' in unit_name and "2" in unit_name and '.' not in unit_name:
                    # location is 0x13 (19 as decimal) ABIA2
                    return unit_name
                elif 'FBB' in unit_name and "1" in unit_name:
                    # location is 0x13 (19 as decimal) FBBA1
                    return unit_name
            elif node_id == '20':
                if 'ABI' in unit_name and "3" in unit_name and '.' not in unit_name:
                    # location is 0x14 (20 as decimal) ABIA3
                    return unit_name
                elif 'FBB' in unit_name and "2" in unit_name:
                    # location is 0x14 (20 as decimal) FBBA2
                    return unit_name
            elif node_id == '34':
                # location is 0x22 (34 as decimal) ABIA2.1 or in right
                if "1" == unit_name[-1] and '.' in unit_name and self.bts.side == r"\d+":
                    return unit_name
                # location is 0x22 (34 as decimal) left/right side of rack, not fullrack
                elif "1" == unit_name[-1] and self.bts.side != r"\d+":
                    return unit_name
            elif node_id == '35':
                # location is 0x23 (35 as decimal) ABIA2.2  fullrack
                if "2" == unit_name[-1] and '.' in unit_name and self.bts.side == r"\d+":
                    return unit_name
                # location is 0x23 (35 as decimal) ABIA2  left/right side of rack, not fullrack
                elif "2" == unit_name[-1] and self.bts.side != r"\d+":
                    return unit_name
            elif node_id == '36':
                # location is 0x24 (36 as decimal) ABIA2.3
                if "3" == unit_name[-1] and '.' in unit_name and self.bts.side == r"\d+":
                    return unit_name
                # location is 0x24 (36 as decimal) ABIA3  left/right side of rack, not fullrack
                elif "3" == unit_name[-1] and self.bts.side != r"\d+":
                    return unit_name
        return ""

    def _get_cell_ids_and_socs_of_all_bbpools(self):
        """
        Returns dictionary of cell ids of all BB pools.

        :return dict: BBPool as key and cells as value
        """
        bbpool_cells = None
        bbpool_socs = None
        try:
            bbpools = list(self.admin.get_managed_objects("BBPOOL_L"))
            bbpool_cells = {}
            bbpool_socs = {}
            if bbpools:
                for bbpool in bbpools:
                    bbpool_cells = self._get_bbpool_cells(bbpool_cells, bbpool)
                    bbpool_socs = self._get_bbpool_socs(bbpool_socs, bbpool)
            else:
                error("BBPOOL_L object is not found. Check ims2 logs and take contact to script developer.")
                raise EnvironmentIssue
            for bbpool, cells in bbpool_cells.items():
                info("Cells of {} are {}".format(bbpool, cells))
            # for bbpool, socs in bbpool_socs.items():
                info("SOCs of {} are {}".format(bbpool, bbpool_socs[bbpool]))
            CellResources.bbpools_cells = bbpool_cells
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"Problems when _get_cell_ids_and_socs_of_all_bbpools. {admin_error.__class__.__name__}:{admin_error}"
                  f" was raised.\n{tb}")
        return bbpool_cells, bbpool_socs

    def _get_bbpool_cells(self, bbpool_cells, bbpool):
        if "distName" in bbpool:
            self.logger.debug("Distname of bbpool is {}".format(bbpool["distName"]))
            bbpool_dn = bbpool["distName"]
            bbpool_name = "BBPool{}".format(bbpool_dn[bbpool_dn.rfind("-") + 1:])
            self.logger.debug("{} modified to {}".format(bbpool_dn, bbpool_name))
            parameter_dict = bbpool["parameters"]
            ids = self._find_cell_ids(bbpool_dn, parameter_dict)
            bbpool_cells[bbpool_name] = ids
        else:
            error("distName is not found for BBPOOL_L")
            raise EnvironmentIssue
        return bbpool_cells

    def _get_bbpool_socs(self, bbpool_socs, bbpool):
        if "distName" in bbpool:
            self.logger.debug("Distname is {}".format(bbpool["distName"]))
            bbpool_dn = bbpool["distName"]
            bbpool_name = "BBPool{}".format(bbpool_dn[bbpool_dn.rfind("-") + 1:])
            self.logger.debug("{} modified to {}".format(bbpool_dn, bbpool_name))
            parameter_dict = bbpool["parameters"]
            ids = self._find_socs(bbpool_dn, parameter_dict)
            bbpool_socs[bbpool_name] = ids
        else:
            error("distName is not found for BBPOOL_L")
            raise EnvironmentIssue
        return bbpool_socs

    def _find_cell_ids(self, bbpool_dn, parameter_dict):
        cell_ids = []
        if "assignedLCellsDNs" in parameter_dict:
            cell_list = parameter_dict["assignedLCellsDNs"]
            self.logger.debug("assignedLCellsDNs: {}".format(cell_list))
            if cell_list:
                for cell in cell_list:
                    cell_ids.append(cell[cell.rfind("-") + 1:])
            else:
                self.logger.debug("No cells mapped to {}".format(bbpool_dn))
        return cell_ids

    def _find_socs(self, bbpool_dn, parameter_dict):
        socs = []
        if "assignedLCellsDNs" in parameter_dict:
            soc_list = parameter_dict["dspsDNs"]
            self.logger.debug(f"dspsDNs: {soc_list}")
            if soc_list:
                for soc in soc_list:  # remove DSP part from the affected SOC
                    socs.append(soc[:soc.rfind("/DSP_L")])
            else:
                self.logger.debug("No SOCs mapped to {}".format(bbpool_dn))
        return socs

    def _get_cells_mapped_to_virtual_nodes(self):
        """
        Gets cells mapped to virtual nodes.

        :return dict: Return dictionary SW_NODE as a key and cells mapped to it as value.
        """
        vnu_mapped_to_cells = {}
        core_pools_of_vnu = {}
        core_pool_mos = self.admin.get_managed_objects("CORE_POOL_L")
        if not core_pool_mos:
            error("Couldn't find CORE_POOL_L from Admin.")
            raise EnvironmentIssue
        for core_pool in core_pool_mos:
            core_pools_of_vnu = self._get_vnu_in_core_pool(core_pool, core_pools_of_vnu)
        if core_pools_of_vnu:
            cell_to_pool_mos = self.admin.get_managed_objects("CELL_TO_POOL_MAPPING_L")
            if not cell_to_pool_mos:
                error("Couldn't find CELL_TO_POOL_MAPPING_L from Admin.")
                raise EnvironmentIssue
            for cell_to_pool_mo in cell_to_pool_mos:
                vnu_mapped_to_cells = self._get_vnu_mapped_to_cell(
                    cell_to_pool_mo, core_pools_of_vnu, vnu_mapped_to_cells)
            if not vnu_mapped_to_cells:
                error("Cannot find any cells that are mapped to SW_NODE_Ls")
                raise EnvironmentIssue
            else:
                for vnu, cells in vnu_mapped_to_cells.items():
                    info("Cell(s) {} mapped to {}".format(cells, vnu))
        return vnu_mapped_to_cells

    def _get_vnu_mapped_to_cell(self, cell_to_pool_mo, core_pools_of_vnu, vnu_mapped_to_cells):
        parameter_dict = cell_to_pool_mo["parameters"]
        if "cellSlots" in parameter_dict:
            cell_slots = list(parameter_dict["cellSlots"])
            if "cellDN" in parameter_dict:
                cell_dn = str(parameter_dict["cellDN"])
            else:
                error("Something has changed in admin, cellDN is not found from "
                      "CELL_TO_POOL_MAPPING_L ({}).".format(cell_to_pool_mo))
                raise EnvironmentIssue
            cell = self._find_cell_name(cell_dn)
            for cell_slot in cell_slots:
                vnu_mapped_to_cells = self._add_cells_to_correct_vnu(
                    cell, cell_slot, core_pools_of_vnu, vnu_mapped_to_cells)
        return vnu_mapped_to_cells

    def _add_cells_to_correct_vnu(self, cell, cell_slot, core_pools_of_vnu, vnu_mapped_to_cells):
        if cell_slot["poolDN"]:
            if (str(cell_slot["poolDN"]) in core_pools_of_vnu and
                    (core_pools_of_vnu[str(cell_slot["poolDN"])] not in vnu_mapped_to_cells)):
                vnu_mapped_to_cells[core_pools_of_vnu[str(cell_slot["poolDN"])]] = [cell]
            elif (str(cell_slot["poolDN"]) in core_pools_of_vnu and
                  (core_pools_of_vnu[str(cell_slot["poolDN"])] in vnu_mapped_to_cells)):
                if cell not in vnu_mapped_to_cells[core_pools_of_vnu[str(cell_slot["poolDN"])]]:
                    vnu_mapped_to_cells[core_pools_of_vnu[str(cell_slot["poolDN"])]].append(cell)
                else:
                    self.logger.debug("{} is already on the list.".format(cell))
        return vnu_mapped_to_cells

    def _find_cell_name(self, cell_carrier_list_dn):
        for cell in self.bts.cells:
            for carrier in self.bts.cells[cell]["carrierList"]:
                cell_dn = carrier["id"]["internal"]
                if cell_carrier_list_dn in cell_dn:
                    return cell

    @staticmethod
    def _check_vnu_match(core_dn, core_pool, vnu_parser, core_pools_of_vnu):
        vnu_match = vnu_parser.match(core_dn)
        if vnu_match:
            vnu = str(vnu_match.group("vnu"))
            if vnu not in core_pools_of_vnu:
                core_pools_of_vnu[str(core_pool["distName"])] = vnu
        return core_pools_of_vnu

    def _get_vnu_in_core_pool(self, core_pool, core_pools_of_vnu):
        vnu_parser = re.compile(r".*CABINET_L-\d+/(SMOD_L-\d+/CCU_L-\d+/SOC_L-\d+|SMOD_L-\d+/(BBU|BOARD)_L-\d+/"
                                r"POWER_GROUP_L-\d+/SOC_L-\d+|BBMOD_L-\d+/(BBU_L|BOARD_L)-\d+/POWER_GROUP_L-\d+/"
                                r"SOC_L-\d+)/(CPU_L-\d+/|)(?P<vnu>SW_NODE_L-\d+).*")
        parameter_dict = core_pool["parameters"]
        schema_to_l_object_relation = self._find_sw_node_l_objects()
        if "LTS" in core_pool["distName"]:
            if "cores" in parameter_dict:
                cores = list(parameter_dict["cores"])
                for core in cores:
                    if "coreDN" in core:
                        core_dn = str(core["coreDN"])
                        if 'SW_NODE_L' in core_dn:
                            core_pools_of_vnu = self._check_vnu_match(core_dn, core_pool, vnu_parser, core_pools_of_vnu)
                        elif "SW_NODE_SCHEMA" in core_dn:
                            if core_dn in schema_to_l_object_relation:
                                core_pools_of_vnu = self._check_vnu_match(schema_to_l_object_relation[core_dn],
                                                                          core_pool, vnu_parser, core_pools_of_vnu)
                            else:
                                error(f"SW_NODE_SCHEMA object '{core_dn}' can't be linked to SW_NODE_L object")
        return core_pools_of_vnu

    def get_channels_of_antenna_of_radio(self, radio, antenna):
        """
        Get channels that have radio and antenna.
        :param object radio: Radio object.
        :param str antenna: Antenna of radio, for example 1.
        """
        try:
            channels_of_antenna = []
            ant_pattern = re.compile(f"{radio.dist_name}/ANTL_R-(?P<antenna>{antenna})")
            devices_mos = self.admin.get_managed_objects("DEVICES_LIST")
            if not devices_mos:
                error("Unable to get DEVICES_LIST objects from admin.")
                raise EnvironmentIssue
            for device in devices_mos:
                parameter_dict = device["parameters"]
                if "deviceDNs" in parameter_dict:
                    device_dns = list(parameter_dict["deviceDNs"])
                    for device_dn in device_dns:
                        dn = str(device_dn["deviceDN"])
                        match = ant_pattern.match(dn)
                        if match:
                            if device["distName"] not in channels_of_antenna:
                                channels_of_antenna.append(device["distName"])
            self.logger.debug(f"Channels of antenna {antenna} of {radio.dist_name}: {channels_of_antenna}\nRemove "
                              f"DEVICES_LIST information")
            channels_of_antenna = [
                self._safe_split(distname, "/DEVICES_LIST")[0] for distname in channels_of_antenna
            ]
            self.logger.debug(f"Channels of ANTL-{antenna} of {radio.name}({radio.dist_name}): {channels_of_antenna}")
            return channels_of_antenna
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            error(f"Unable to get DEVICES_LIST. {admin_error.__class__.__name__}:{admin_error} was raised.\n"
                  f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            raise ErrorFromAdmin(f"Unable to get DEVICES_LIST, {admin_error.__class__.__name__} was raised.")

    def get_cells_of_antenna_with_given_direction_from_radio(self, direction, radio, antenna):
        """
        Get all channels that have given direction on given radio. Parse cell information from the channel that has
        given antenna.
        :param str direction: Can have value TX or RX.
        :param object radio: Radio object.
        :param str antenna: Antenna of radio, for example 1.
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        parse_pattern = re.compile(r".*/MRBTS-\d+/RAT-\d+/MCTRL-{}+/BBTOP_M-\d+/MRBTS_M-\d+/..BTS_M-\d+/"
                                   r"CELL_M-(?P<cell>\d+)/CHANNEL_GROUP_M-(?P<channel_group>\d+)/CHANNEL_M-"
                                   r"(?P<channel>\d+)".format(self.bts.side))
        try:
            channels_of_antenna = self.get_channels_of_antenna_of_radio(radio, antenna)
            channel_mos = self.admin.get_managed_objects("CHANNEL_M")
            lncels = self.admin.get_managed_objects("LNCEL_L")
            cells = []
            if not channel_mos:
                error("Unable to get CHANNEL_M objects from admin.")
                raise EnvironmentIssue
            for channel in channel_mos:
                if (("direction" in channel["parameters"] and channel["parameters"]["direction"] == direction) and
                        (channel["distName"] in channels_of_antenna)):
                    self.logger.debug(f"Channel {channel['distName']} has direction {direction} and ANTL-{antenna} of "
                                      f"{radio.name} is configured to it.")
                    match = parse_pattern.match(str(channel["distName"]))
                    if match:
                        cell = match.group("cell")
                        if "LNBTS" in str(channel["distName"]):
                            if f"LNCell-{cell}" not in cells:
                                for lncel in lncels:
                                    if str(lncel['parameters']['lcrId']) == cell:
                                        cells.append(f"LNCell-{lncel['parameters']['phyCellId']}")
                                        break
                        elif "NRBTS" in str(channel["distName"]):
                            if f"NRCell-{cell}" not in cells:
                                cells.append(f"NRCell-{cell}")
                        else:
                            error(f"No LNBTS nor NRBTS found from distName {channel['distName']}. Take contact to "
                                  f"script developer.")
                            raise EnvironmentIssue
                        self.logger.debug(f"Channel {channel['distName']} has direction {direction} and ANTL-{antenna}"
                                          f" of {radio.name} is configured to it and cells {cells} are affected.")
            return cells
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            error(f"Unable to get channels with direction {direction} from radio {radio.name}. "
                  f"{admin_error.__class__.__name__}:{admin_error} was raised.\n"
                  f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            raise ErrorFromAdmin(f"Unable to get channels, {admin_error.__class__.__name__} was raised.")

    @staticmethod
    def _safe_split(value, sep):
        """Safely split values that may be None; returns list from splitting str(value)."""
        if value is None:
            return [""]
        return str(value).split(sep)
