"""
:author:  Essi Passoja
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import re
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import TestSettingsError
from testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Resources.exceptions import ParsingIssue


def get_all_virtual_nodes_with_specific_vnu_variant(applications, vnu_variant):
    """
    Get all virtual nodes with VNU variant given by user.

    :param obj applications: Applications class self.
    :param str vnu_variant: VNU variant selected by user.
    :returns list[tuple]: VNUs which correspond to the given VNU variant. Each VNU tuple includes:
                          (dist_name, vnu, node_id, sw_path, sw_node)
    """
    specific_vnus = []
    all_vnus = _get_virtual_nodes(applications)
    info("All found virtual nodes are:")
    for vnu in all_vnus:
        info(vnu)
        if vnu_variant in vnu:
            specific_vnus.append(vnu)
    if specific_vnus:
        info(f"All found {vnu_variant} virtual nodes are:")
        for vnu in specific_vnus:
            info(vnu)
    else:
        error("The given vnu variant {} was not found from all virtual nodes.".format(vnu_variant))
        info("If application should exist on the SW_NODE, check from ims2 log if SW_NODE_L "
             "paths have changed or if there are some other structural changes.")
    return specific_vnus


def get_node_swpool_application_and_pid(applications, unit, selected_soc, ipv6):
    """
    Get node swpool application and pid
    """
    bbmod = False
    ip_of_unit = ""
    if unit:
        if isinstance(unit, str) and (("BBMOD" in unit) or ("ABI" in unit)):
            bbmod = True
        elif not isinstance(unit, str) and hasattr(unit, "primary_soc"):  # BBMOD unit object
            unit = unit.name
            bbmod = True
        elif not isinstance(unit, str) and hasattr(unit, "master"):  # SMOD unit object
            if "2" in unit.name:
                info(f"IP of the extension {unit.name} is 192.168.255.119")
                ip_of_unit = "192.168.255.119"
            unit = unit.name
        elif isinstance(unit, str) and (("ASI" in unit) or ("SMOD" in unit)) and "2" in unit:  # SMOD unit
            ip_of_unit = "192.168.255.119"
        if bbmod:
            ip_of_unit = applications.fsp_ips.get_ip_of_selected_fsp(unit, selected_soc, ipv6)
        if ip_of_unit:
            applications.ssh.take_ssh_connection(ip_of_unit, alias="chosen_unit", proxy="SMOD")
    alias = "SMOD" if (not unit or not ip_of_unit) else "chosen_unit"
    process_information = applications.ssh.send_command_to_ip_return_output("ps auxf -w -w", alias)
    return _parse_process_information(process_information, unit)


def get_virtual_pids_from_nodes_applications_pids(nodes_applications_pids, node_ids):
    virtual_pids = []
    for node in nodes_applications_pids:
        if node in node_ids:
            for naps_of_node in nodes_applications_pids[node]:
                if type(naps_of_node) is list:
                    for nap in naps_of_node:
                        pid, naps_of_node = nap
                        virtual_pids.append(pid)
    return virtual_pids


def _get_virtual_nodes(applications):
    managed_objects = applications.admin.get_managed_objects(class_name="SW_NODE_L")
    if managed_objects:
        return _parse_virtual_nodes_from_managed_objects(managed_objects)
    else:
        error("Virtual nodes are not found from IMC (no SW_NODE_L in IMC).")


def _parse_virtual_nodes_from_managed_objects(managed_objects):
    virtual_nodes = []
    for managed_object in managed_objects:
        virtual_node = _parse_virtual_node_info_from_managed_object(managed_object)
        if virtual_node:
            virtual_nodes.append(virtual_node)
    return virtual_nodes


def _parse_virtual_node_info_from_managed_object(managed_object):
    parse_power_group_and_soc = re.compile(
        r".*CABINET_L-\d+/(SMOD_L-\d+/CCU_L-\d+/SOC_L-\d+|(SMOD|BBMOD)_L-\d+/(BBU|BOARD)_L-\d+(/POWER_GROUP_L-\d+|)/"
        r"SOC_L-\d+)/(CPU_L-\d+/|)(?P<sw_node>SW_NODE_L-\d+).*.*")
    dist_name = managed_object['distName']
    if "RAT" in dist_name and "EQM" in dist_name and "CABINET" in dist_name:
        vnu, node_id, sw_path = _get_node_variant_node_id_and_software_path_from_managed_object(managed_object)
        match = parse_power_group_and_soc.match(dist_name)
        if match:
            sw_node = match.group("sw_node")
            return dist_name, vnu, node_id, sw_path, sw_node


def _get_node_variant_node_id_and_software_path_from_managed_object(managed_object):
    vnu = managed_object["parameters"]["applicationGroup"]
    node_id = managed_object["parameters"]["nodeId"]
    software_path = managed_object["parameters"]["softwarePath"]
    return vnu, node_id, software_path


def _parse_process_information(process_information, unit):
    if process_information:

        # if r"  |       |       \_ lxc-execute -f " in process_information:
        #     node_list = process_information.split(r"  |       |       \_ lxc-execute -f ")
        # elif r"  |   |       \_ lxc-execute -f " in process_information:
        #     node_list = process_information.split(r"  |   |       \_ lxc-execute -f ")
        # elif r"  |   |   \_ lxc-execute -f " in process_information:
        #     node_list = process_information.split(r"  |   |   \_ lxc-execute -f ")
        # elif r"\_ lxc-execute -f " in process_information:
        #     node_list = process_information.split(r"\_ lxc-execute -f ")
        # elif r"/usr/bin/lxc-execute -f" in process_information:
        #     node_list = process_information.split(r"/usr/bin/lxc-execute -f ")
        # elif r"lxc-start -f" in process_information:
        #     node_list = process_information.split(r"lxc-start -f ")
        # elif r"/usr/bin/lxc-start -F -f" in process_information:
        #     node_list = process_information.split(r"/usr/bin/lxc-start -F -f ")
        if "lxc-start " in process_information:
            node_list = process_information.split(r"lxc-start ")
        elif "lxc-execute " in process_information:
            node_list = process_information.split(r"lxc-execute ")
        else:
            error("Output of ps auxf -w -w has changed, take contact to script developer.")
            raise ParsingIssue("Output of ps auxf -w -w has changed. Text 'lxc-start ' and 'lxc-execute ' are not found"
                               " from output \n({}). Take contact to script developer.".format(process_information))
        return _parse_node_list(node_list, unit)


def _parse_node_list(node_list, unit):
    v_app = {}
    for node in node_list:
        if _node_contains_important_info(node):
            v_app = _parse_node(node, v_app, unit)
    return v_app


def _node_contains_important_info(node):
    return True if any(i for i in (
        "/ram/node_0x1015", "/ram/node_0x1016", "/ram/node_0x101b", "/ram/node_0x120b", "/ram/node_0x130b",
        "/ram/node_0x140b", "/ram/node_0x2015", "/ram/node_0x2016", "/ram/node_0x201b", "/ram/node_0x220b",
        "/ram/node_0x230b", "/ram/node_0x240b", "/ram/node_C_CPNODE", "/ram/node_D_CPNODE", "/ram/node_FHNET",
        "/ram/node_L_DCPNODE00", "/ram/node_L_DCPNODE01", "/ram/node_L_DCPNODE02", "/ram/node_L_DCPNODE40",
        "/ram/node_D-CPNODE00", "/ram/node_D-CPNODE", "/ram/node_D-CPNODE01", "/ram/node_C-CPNODE00",
        "/ram/node_L_CCPNODE00", " -n 0x1015", " -n 0x1016", " -n 0x1017", " -n 0x101b", " -n 0x101c", " -n 0x2015",
        " -n 0x2016", " -n 0x2017", " -n 0x201b", " -n 0x201c", " -n 0x120b", " -n 0x130b", " -n 0x140b", " -n 0x220b",
        " -n 0x230b", " -n 0x240b") if i in node) else False


def _parse_node(node, v_app, unit):
    pid_app_list = []
    node_list = node.split('\n')
    for row in node_list:
        v_app, pid_app_list = _create_app_lib(row, v_app, pid_app_list, unit)
    return v_app


def _create_app_lib(row, v_app, pid_app_list, unit):
    node, sw = _parse_node_and_sw(row, unit)
    pid_app_list = _parse_pid_and_app(row, pid_app_list)
    if node:
        v_app[str(node)] = [sw, pid_app_list]
    return v_app, pid_app_list


def _parse_node_and_sw(row, unit):
    if unit and any(i for i in ("FBB", "FSP", "ABIN", "ABIO", "ABIL", "ABIP") if i in unit):
        node_and_sw_parser = re.compile(
            r".*/ram/node_(0x120b|0x130b|0x140b|0x220b|0x230b|0x240b|D-CPNODE\d+|D-CPNODE\w\d+)/lxc.cfg\s+-n\s+"
            r"(?P<node>0x.{4}).*?(?P<sw>/ffs/run/lte|/ffs/run/swpool/\w+/\w+|/ffs/run/swpool/|ffs/run/devicecfg/"
            r"containers/\w+/\w+).*")
    elif unit and "ABIA" in unit:
        error("There aren't any virtual nodes on FSP units(ABIA/ABIC) of AirScale(ASIA/ASIB).")
        raise TestSettingsError("There aren't any virtual nodes on FSP units(ABIA/ABIC) of AirScale(ASIA/ASIB).")
    else:
        node_and_sw_parser = re.compile(
            r"(.*/ram/node_.*lxc.cfg)\s+.n\s+"
            r"(?P<node>0x1015|0x1016|0x1017|0x101b|0x101c|0x2015|0x2016|0x2017|0x201b|0x201c).+?"
            r"(?P<sw>/ffs/run/lte|/ffs/run/swpool/\w+/\w+|ffs/run/devicecfg/containers/\w+/\w+).*")
    if "/ram/node_" in row:
        match = node_and_sw_parser.match(row)
        if match:
            return str(match.group("node")), str(match.group("sw"))
        else:
            print(f"Method _parse_node_and_sw ROW that did not match:\n{row}")
    return "", ""


def _parse_pid_and_app(row, pid_app_list):
    pid_and_application_parser = re.compile(
        r".*?(root|btssw)\s+(?P<pid>\d+)\s+.+[?]\s+.+([|]|)(\s+[|]\s+[|]|)(\s{7}|\s+[|]\s{3}|\s{3})..\s+"
        r"(?P<app>/opt/\w+\W\w+|\w+)")
    if (r"  |       |       " in row or "  |   |                   |   " in row) or (
            r"\_ /opt/" in row and row.count('|') in (1, 3, 4, 5, 6)):
        match = pid_and_application_parser.match(row)
        if match:
            pid_app_list.append((str(match.group("pid")), str(match.group("app"))))
        else:
            print(f"Method _parse_pid_and_app ROW that did not match:\n{row}")
    return pid_app_list
