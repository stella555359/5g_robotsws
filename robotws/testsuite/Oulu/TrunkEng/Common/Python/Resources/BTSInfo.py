"""
:author:  Essi Passoja
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import os
import re
from datetime import datetime
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.Links import Links


class BTSInfo:
    """
    Collects information to bts_info.txt.
    """

    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.alarms = BuiltIn().get_library_instance("ALARMS")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.cells = BuiltIn().get_library_instance("CELLS")
        self.fsp_units = BuiltIn().get_library_instance("FSPUNITS")
        self.links = Links()
        self.logger = BuiltIn().get_library_instance("LOG")
        self.scf = BuiltIn().get_library_instance("SCF")
        self.collect_logs = None

        self.file_name = "BTS_info_{}.txt".format(datetime.now().strftime("%Y%m%d_%H%M%S"))
        self.path_to_info_file = os.path.join(self.logger.log_dir, self.file_name)

    def collect_bts_info(self):
        info("Collecting BTS info -file")
        if os.path.exists(self.path_to_info_file) and os.path.getsize(self.path_to_info_file) > 0:
            info("BTS info file already exists, not adding information to it.")
        else:
            self.collect_information_to_bts_info(commissioned=True)

    def collect_information_to_bts_info(self, commissioned):
        try:
            self._write_to_bts_info_file("1. SMODs")
            self._write_to_bts_info_file(
                self._get_hw_information("SMOD_L", ["productName", "productCode", "serialNumber"]))
            self._write_to_bts_info_file('2. BBMODs')
            fsp_info = self._get_hw_information("BBMOD_L", ["productName", "productCode", "serialNumber"])
            if fsp_info:
                self._write_to_bts_info_file(fsp_info)
            else:
                self._write_to_bts_info_file(" - No external FSP units")
            self._write_to_bts_info_file("3. RMODs")
            self._write_to_bts_info_file(
                self._get_hw_information("RMOD_L", ["productName", "hwVersion", "serialNumber"]))
            self._write_to_bts_info_file("4. Cells")
            if commissioned:
                self._write_to_bts_info_file(self._get_cell_information())
                pass
            else:
                self._write_to_bts_info_file(" - BTS is not commissioned -> there are no cells")
            self._write_to_bts_info_file("5. Cell relations")
            if commissioned:
                antenna_information = self._get_cell_relations()
                self._write_to_bts_info_file(antenna_information)
            else:
                self._write_to_bts_info_file(" - BTS is not commissioned -> cannot get antenna information")
            self._write_to_bts_info_file("6. Used synchronization for BTS")
            self._write_to_bts_info_file(
                self._get_hw_information("CLOCK_L", ["selectedSource", "tuningMode", "syncHubRole"]))
            self._write_to_bts_info_file("7. Other info")
            self._get_additional_info_to_file_end()
            if not self.collect_logs:
                self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
            if self.collect_logs.rfs:
                self._write_to_bts_info_file("Information about the remote side (not-tested side)\n"
                                             "---------------------------------------------------")
                connection = "log_admin_remote"
                bts_infos = self.admin.get_parameters_for_all("BTS", connection=connection)
                bts_id = bts_infos[0]["btsId"]
                bts_name = bts_infos[0]["btsName"]
                self._write_to_bts_info_file("8. SMODs")
                self._write_to_bts_info_file(
                    self._get_hw_information("SMOD_L", ["productName", "productCode", "serialNumber"], connection))
                self._write_to_bts_info_file(f" - btsId -> {bts_id}\n"
                                             f" - btsName -> {bts_name}")
                self._write_to_bts_info_file('9. BBMODs')
                fsp_info = self._get_hw_information("BBMOD_L", ["productName", "productCode", "serialNumber"],
                                                    connection)
                if fsp_info:
                    self._write_to_bts_info_file(fsp_info)
                else:
                    self._write_to_bts_info_file(" - No external FSP units")
                self._write_to_bts_info_file("10. RMODs")
                self._write_to_bts_info_file(
                    self._get_hw_information("RMOD_L", ["productName", "hwVersion", "serialNumber"], connection))
                self._write_to_bts_info_file("11. Cells")
                if commissioned:
                    self._write_to_bts_info_file(self._get_cell_information(connection))
                    pass
                else:
                    self._write_to_bts_info_file(" - BTS is not commissioned -> there are no cells")
                self._write_to_bts_info_file("12. Used synchronization for BTS")
                self._write_to_bts_info_file(
                    self._get_hw_information("CLOCK_L", ["selectedSource", "tuningMode", "syncHubRole"], connection))
                self._write_to_bts_info_file("13. Other info")
                self._get_additional_info_to_file_end()
        except (ValueError, OSError, MemoryError, IndexError, TypeError) as ex:
            error(f"Problems while constructing file {self.path_to_info_file}. Reason: {ex}\n"
                  f"{''.join(format_exception(type(ex), ex, ex.__traceback__))}")
            if "No space left on device" in str(ex):
                self.logger.command_via_commandline("df -h")
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def _get_hw_information(self, managed_object, element_list, connection="log_admin"):
        object_dictionary = {}
        mrbts_r = "MRBTS_R-{}".format(self.bts.side[-1]) if "d+" not in self.bts.side else ""
        try:
            mos = self.admin.get_managed_objects(class_name=managed_object, connection=connection)
            if mos:
                for mo in mos:
                    distname = str(mo["distName"])
                    if (managed_object == "LNCEL_R" and
                            (("d+" not in self.bts.side and mrbts_r in distname) or ("d+" in self.bts.side))) or (
                            "d+" not in self.bts.side and self.bts.side in distname) or ("d+" in self.bts.side):
                        object_dictionary = self._search_elements(mo, distname, element_list, object_dictionary)
                    if managed_object == "SMOD_L":
                        object_dictionary = self._add_smod_info_to_obj_dict(object_dictionary)
                    if managed_object == "BBMOD_L":
                        if ("d+" not in self.bts.side and self.bts.side in distname) or (
                                "d+" in self.bts.side):  # if half rack selected side or full rack
                            object_dictionary = self._add_bbmod_info_to_obj_dict(distname, object_dictionary)
                    if managed_object == "RMOD_L":
                        if ('d+' not in self.bts.side and self.bts.side in distname) or (
                                'd+' in self.bts.side):  # if half rack selected side or full rack
                            object_dictionary = self._add_rmod_info_to_obj_dict(distname, mo, object_dictionary)
                    if managed_object == "CLOCK_L" and (("d+" not in self.bts.side and self.bts.side in distname) or
                                                        "d+" in self.bts.side):
                        object_dictionary = self._add_sync_element_to_obj_dict(distname, object_dictionary)
        except (ValueError, OSError, MemoryError, IndexError, TypeError, AttributeError, IOError, KeyError) as ex:
            error(f"Failure while getting HW information. Reason: \"{ex}\".\n"
                  f"{''.join(format_exception(type(ex), ex, ex.__traceback__))}")
            if "No space left on device" in str(ex):
                self.logger.command_via_commandline("df -h")
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")
        return object_dictionary

    def _get_cell_information(self, connection="log_admin"):
        cell_information = {}
        all_cells = self.cells.get_all_cells(admin_connection=connection)
        for cell, cell_param_list in all_cells.items():
            cell_information[cell] = []
            for param in cell_param_list:
                if str(param) == "id":
                    cell_information[cell].append(" - {} -> {}".format(param, all_cells[cell][param]["configuration"]))
                    continue
                if str(param) in ["globalCellId", "physicalCellId", "eutranCellId", "downlinkChannelBandwidth",
                                  "uplinkChannelBandwidth", "chBw", "downlinkMimoMode", "earfcnUplink",
                                  "earfcnDownlink", "cellDepType"]:
                    cell_information[cell].append(" - {} -> {}".format(param, all_cells[cell][param]))
        return cell_information

    def _get_cell_relations(self):
        self.links.update_rmod_cell_links()
        antenna_information = []
        for radio in self.bts.rmod_cell_links:
            antenna_information.append("Radio {} ..".format(radio))
            for cell in self.bts.rmod_cell_links[radio]:
                for antenna in self.bts.rmod_cell_links[radio][cell]:
                    antenna_information.append("- has {} connected with antenna {}: {}".format(
                        cell, antenna, self.bts.rmod_cell_links[radio][cell][antenna]))
        return antenna_information

    def _add_sync_element_to_obj_dict(self, distname, object_dictionary):
        try:
            mo_distname = distname[distname.rfind("/CABINET") + 1:distname.rfind("/CLOCK")]
            mo_distname = mo_distname.replace('_L', '')
            clock_mos = self.scf.get_class_dict("CLOCK")
            if clock_mos:
                object_dictionary = self._get_sync_input_type(clock_mos, distname, mo_distname, object_dictionary)
        except KeyError:
            pass
        except ValueError as ex:
            error(f"Failure while collecting HW information (com.nokia.srbts.mnl:CLOCK) "
                  f"from configuration file. Reason: {ex}.\n"
                  f"{''.join(format_exception(type(ex), ex, ex.__traceback__))}")
        return object_dictionary

    @staticmethod
    def _get_sync_input_type(clock_mos, distname, mo_distname, object_dictionary):
        for clock_mo in clock_mos:
            smod_distname = clock_mos[clock_mo]["sModDN"]
            if mo_distname in smod_distname:
                item_list = clock_mos[clock_mo]["syncInputList"]
                for item, value in item_list:
                    if item == "syncInputType":
                        add_to_list = " - syncInputType -> {}".format(value)
                        object_dictionary[distname].append(add_to_list)
        return object_dictionary

    def _add_rmod_info_to_obj_dict(self, distname, mo, object_dictionary):
        if object_dictionary and distname in object_dictionary:
            for radio in self.bts.radios:
                object_dictionary = self._get_radio_name(distname, mo, object_dictionary, radio)
                object_dictionary = self._get_radio_ip(distname, mo, object_dictionary)
        return object_dictionary

    @staticmethod
    def _get_radio_ip(distname, mo, object_dictionary):
        add_to_list = " - IP of RMOD -> {}".format(mo["parameters"]["ipAddress"])
        if (add_to_list not in object_dictionary[distname] and not [
                i for i in list(object_dictionary[distname]) if "IP of RMOD ->" in i]):
            object_dictionary[distname].append(add_to_list)
        return object_dictionary

    @staticmethod
    def _get_radio_name(distname, mo, object_dictionary, radio):
        if radio.serial_number == mo["parameters"]["serialNumber"]:
            add_to_list = " - Radio Configuration Identifier -> {}".format(radio.name)
            if (add_to_list not in object_dictionary[distname] and not
                    [i for i in list(object_dictionary[distname]) if " - Radio Configuration Identifier ->" in i]):
                object_dictionary[distname].append(add_to_list)
        return object_dictionary

    def _find_sync_input_type_from_list(self, cmo, mo, object_dictionary):
        if cmo["syncInputList"]:
            item_list = list(cmo["syncInputList"])
            if item_list:
                object_dictionary = self._add_sync_input_types_to_dict(item_list, mo, object_dictionary)
        return object_dictionary

    @staticmethod
    def _add_sync_input_types_to_dict(item_list, mo, object_dictionary):
        for i in item_list:
            if i["syncInputType"]:
                add_to_list = " - syncInputType -> {}".format(i["syncInputType"])
                object_dictionary[str(mo.DistName)].append(add_to_list)
        return object_dictionary

    def _get_additional_info_to_file_end(self, connection="log_admin"):
        other_list = [self._category_alarm_info()]
        lnbts_mos = self.admin.get_managed_objects(class_name="NOKLTE:LNBTS", connection=connection)
        other_list.append(self._element_in_mos("txPathFailureMode", lnbts_mos, "NOKLTE:LNBTS", "N/A"))
        other_list.append(self._element_in_mos("actBbPooling", lnbts_mos, "NOKLTE:LNBTS", "N/A"))
        other_list.append(self._element_in_scf("actForceAutoReset", "com.nokia.srbts.mnl:FMCADM", "false"))
        other_list.append(self._element_in_scf("actForceUnitAutoReset", "com.nokia.srbts.mnl:FMCADM", "false"))
        other_list.append(self._element_in_scf("allowBbPoolRecoveryReset", "com.nokia.srbts.eqm:APEQM", "true"))
        other_list.append(self._element_in_scf("recoveryResetDelay", "com.nokia.srbts.mnl:MNLENT", "-"))
        other_list.append(self._oam_peer_element())
        self._write_to_bts_info_file(other_list)

    def _write_to_bts_info_file(self, content):
        try:
            with open(self.path_to_info_file, "a+") as info_file:
                if isinstance(content, dict):
                    self._add_details_and_write_to_file(info_file, content)
                elif isinstance(content, str):
                    info_file.write("{}\n".format(content))
                elif isinstance(content, list):
                    for key in content:
                        info_file.write(" {}\n".format(key))
                info_file.write("\n")
        except OSError as e:
            error(f"{e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            if "No space left on device" in str(e):
                self.logger.command_via_commandline("df -h")
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def _add_bbmod_info_to_obj_dict(self, distname, object_dictionary):
        units_with_conf_identifiers = self.fsp_units.connect_fsp_units_to_configuration_identifiers()
        for unit in units_with_conf_identifiers:
            bci = units_with_conf_identifiers[unit]
            if (unit in distname and not
                    [fst for fst in list(object_dictionary[distname]) if "BBMOD Configuration Identifier ->" in fst]):
                add_to_list = " - BBMOD Configuration Identifier -> {}".format(str(bci))
                object_dictionary[distname].append(add_to_list)
            mos = self.scf.get_class_dict("BBMOD")
            if mos:
                object_dictionary = self._add_bb_card_usage(unit, distname, mos, object_dictionary)
        return object_dictionary

    @staticmethod
    def _add_bb_card_usage(unit, distname, mos, object_dictionary):
        cabin_unit_pattern = re.compile(r".*(EQM-\d+/APEQM-\d+|BTS_L-\d+/EQM_L-\d)/(CABINET-|CABINET_L-)"
                                        r"(?P<cabin_nro>\d+)/(BBMOD-|BBMOD_L-)(?P<unit_nro>\d+).*")
        bci_match = cabin_unit_pattern.match(unit)
        for mo_distname in mos:
            cabinet_match = cabin_unit_pattern.match(mo_distname)
            if cabinet_match and bci_match:
                if cabinet_match.group("cabin_nro") == bci_match.group(
                        "cabin_nro") and cabinet_match.group("unit_nro") == bci_match.group("unit_nro"):
                    try:
                        if (" - bbCardUsage -> {}".format(str(mos[mo_distname]["bbCardUsage"]))
                                not in object_dictionary[distname]):
                            object_dictionary[distname].append(
                                " - bbCardUsage -> {}".format(str(mos[mo_distname]["bbCardUsage"])))
                    except KeyError:
                        pass
        return object_dictionary

    @staticmethod
    def _search_elements(mo, distname, element_list, object_dictionary):
        for element in element_list:
            if distname in object_dictionary:
                elem_print = " - {} -> {}".format(element, mo["parameters"][element])
                if elem_print not in object_dictionary[distname] and not [j for j in list(
                        object_dictionary[distname]) if '- %s ->' % element in j]:
                    object_dictionary[distname].append(elem_print)
            else:
                object_dictionary[distname] = [" - {} -> {}".format(element, mo["parameters"][element])]
        return object_dictionary

    def _add_smod_info_to_obj_dict(self, object_dictionary, connection="log_admin"):
        bts_mos = self.admin.get_managed_objects(class_name="BTS_L", timeout=10, connection=connection)
        if bts_mos:
            for bts_mo in bts_mos:
                bts_distname = bts_mo["distName"]
                if ('d+' not in self.bts.side and self.bts.side in bts_distname) or ('d+' in self.bts.side):
                    # if half rack selected side or full rack
                    object_dictionary = self._get_bts_id(bts_distname, bts_mo, object_dictionary)
                    object_dictionary = self._get_bts_name(bts_distname, object_dictionary)
        return object_dictionary

    def _get_bts_name(self, bts_distname, object_dictionary):
        try:
            bts_name = self.scf.get_element_based_on_class("com.nokia.srbts:MRBTS", "btsName")
            for sn in list(object_dictionary.keys()):
                if bts_distname in sn and not [si for si in list(object_dictionary[sn]) if 'btsName ->' in si]:
                    object_dictionary[sn].append(" - btsName -> {bts_name}".format(
                        bts_name=bts_name))
        except KeyError as e:
            error("Failure while getting btsName.\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        return object_dictionary

    @staticmethod
    def _get_bts_id(bts_distname, bts_mo, object_dictionary):
        try:
            bts_id = bts_mo["parameters"]["btsId"]
            for sn in list(object_dictionary.keys()):
                if bts_distname in sn and not [si for si in list(object_dictionary[sn])
                                               if 'btsId ->' in si]:
                    object_dictionary[sn].append(" - btsId -> {}".format(bts_id))
        except KeyError as e:
            error("Failure while getting btsId.\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        return object_dictionary

    def _add_details_and_write_to_file(self, info_file, content):
        try:
            for unit, unit_param_list in content.items():
                new_key = self._add_unit_side_to_value(unit)
                if "/LNCEL_FDD-0" in unit:
                    new_key = new_key.replace("/LNCEL_FDD-0", "")
                info_file.write(" {}\n".format(new_key))
                for parameter in unit_param_list:
                    info_file.write("{}\n".format(parameter))
        except OSError as e:
            error(f"{e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            if "No space left on device" in str(e):
                self.logger.command_via_commandline("df -h")
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def _add_unit_side_to_value(self, value):
        rel3 = True if any("FSMF" in bbmod.name for bbmod in self.bts.bbmods) else False
        if 'BTS_L-1' in value and not rel3:
            return "{} (LEFT-side unit)".format(value)
        elif 'BTS_L-4' in value and not rel3:
            return "{} (RIGHT-side unit)".format(value)
        return value

    def _category_alarm_info(self):
        if self.alarms.active_category_alarms:
            return "- actCategoryAlarms -> true"
        else:
            return "- actCategoryAlarms -> false"

    @staticmethod
    def _element_in_mos(element, mos, class_name, assumed_value):
        if mos:
            for mo in mos:
                if element in mo:
                    return "- {} -> {}".format(element, mo[element])
        return "- {} -> {} (Assumed value, could not find class '{}' from ConfigurationPlan)".format(
            element, assumed_value, class_name)

    def _element_in_scf(self, element, class_name, assumed_value):
        value = self.scf.get_element_based_on_class(class_name, element)
        if value:
            return "- {} -> {}".format(element, value)
        return "- {} -> {} (Assumed value, could not find class '{}'from ConfigurationPlan)".format(
            element, assumed_value, class_name)

    def _oam_peer_element(self):
        oam_peer = self.scf.get_element_based_on_class("com.nokia.srbts.mnl:MPLANENW", "oamPeerIpAddress")
        if oam_peer and (oam_peer == "0.0.0.0" or oam_peer == "::"):
            return ("- OAM connection type -> standalone mode, BTSMED connection is disabled "
                    "and no NE3S connection is expected (oamPeerIpAddress = {})".format(oam_peer))
        if oam_peer and (oam_peer.count(".") == 3 or oam_peer.count(":") > 2):
            return "- OAM connection type -> soam, BTSMED is configured (oamPeerIpAddress = {})".format(oam_peer)
        if oam_peer:
            return ("- OAM connection type -> flat oam, directly connected to NetAct "
                    "(oamPeerIpAddress = {})".format(oam_peer))
        return "- OAM connection type -> flat oam, directly connected to NetAct"
