import logging
import re
import xmltodict
import json
import testline
from taf.transport.ssh import ssh
from robot.libraries.BuiltIn import BuiltIn


def fetch_classical_sw_version(alias):
    """
    Fetches the software version of a classical network element. Gets the given alias from setup_oam_http_session

    :param alias: The alias is given by the setup_oam_http_session

    Returns the gnb_sw_version
    """
    try:
        api = BuiltIn().get_library_instance("admin")
    except RuntimeError:
        raise AssertionError(
            "You need to import: 'Library   taf.sbts.oam.coam.admin  WITH NAME  admin'")
    gnb_sw_version = api.get_sw_version(connection=alias)
    gnb_sw_version = testline.reform_coam_sw_version(gnb_sw_version)
    return gnb_sw_version


def get_CCS_Daemon_node_id(connection):
    """
    Determine the CCS Daemon node id via command /usr/bin/ownid

    :param connection: The alias or connection object of a connected taf.transport.ssh connection
    """
    command = "sh /usr/bin/ownnid"
    result = ssh().execute(command=command, connection=connection, timeout='60 s')
    CCS_Daemon_node_id = result.split('\r\n')[0]
    return CCS_Daemon_node_id


def get_airscale_board_and_cpu_status(connection):
    """
    Fetches from a system module the MCU-HW-API autodetection (ADET) status.
    It uses the PLTF abstraction command instead of calling AdetS.py.
    This generates a different output than the direct AdetS.py call!

    :param connection: The alias or connection object of a connected taf.transport.ssh connection
    """

    command = 'chk mcuadet'

    result = ssh().execute(command=command, connection=connection, timeout='60 s')

    return result


def get_cpu_lines(chk_adet_output):
    """
    Takes the adet output and return a list of all cpu nodeIds and their status
    """

    output_lines = [line.strip()
                    for line in chk_adet_output.split('\n') if line]

    return [line.split()[2:4] for line in output_lines if 'cpu' in line]


def get_unit_lines(chk_adet_output):
    """
    Takes the adet output and returns a list of units/boards with their Id, name and state.
    """

    output_lines = [line.strip()
                    for line in chk_adet_output.split('\n') if line]

    unit_lines = [line.split()[2:5] for line in output_lines if 'unit' in line]
    for item in unit_lines:
        item[2] = item[2].split('[')[0]

    return unit_lines


def get_board_ids_and_status_for(unit_type, chk_adet_output):
    """
    Takes the adet output and returns the unit/board ids+status for the given unit/board name.
    e.g. for FCT or FSP
    """

    unit_lines = get_unit_lines(chk_adet_output)

    board_ids = [[board_id, status] for board_id, name,
                 status in unit_lines if unit_type.lower() in name.lower()]

    return board_ids


def get_cpu_status_for(unit_type, chk_adet_output):
    """
    Takes the adet output and returns the cpu ids+status for the given unit/board name.
    e.g. for FCT or FSP
    """

    cpu_lines = get_cpu_lines(chk_adet_output)
    board_ids = get_board_ids_and_status_for(unit_type, chk_adet_output)

    board_daemon_ids = [board_id[0] for board_id in board_ids]

    cpu_status = []
    for board_daemon_id in board_daemon_ids:
        cpu_status += [cpu_line for cpu_line in cpu_lines if board_daemon_id in cpu_line[0]]

    return cpu_status


def check_all_items_ready(itemslist, accept_sleep_state=False):
    """
    Checks that for given unit/board/cpu list all entries are 'ready'.
    If not it raises an exception indicating the mismatch.

    When the optional parameter 'accept_sleep_state' is set to True,
    this function will also consider unit/board/cpu state 'sleep' as
    synonymous to state 'ready'.
    """

    nbr_items_ready = 0

    for item_list in itemslist:
        if not accept_sleep_state:
            if item_list[-1] == 'ready':
                nbr_items_ready += 1
        else:
            if item_list[-1] in ['ready', 'sleep']:
                nbr_items_ready += 1

    if nbr_items_ready != len(itemslist) or nbr_items_ready == 0:
        raise AssertionError("Only {} of {} items are ready".format(
            nbr_items_ready, len(itemslist)))


def check_all_boards_and_cpus_are_ready(connection, accept_sleep_state=False):
    """
    Fetches the ADET status and verifies all units and cpus are in ready state.
    """

    chk_adet_output = get_airscale_board_and_cpu_status(connection)

    cpu_lines = get_cpu_lines(chk_adet_output)
    logging.debug("Adet CPU states: {}".format(cpu_lines))
    unit_lines = get_unit_lines(chk_adet_output)
    logging.debug("Adet Unit states: {}".format(unit_lines))

    check_all_items_ready(cpu_lines, accept_sleep_state)
    check_all_items_ready(unit_lines, accept_sleep_state)


def get_adet_state_for_board(connection, board_id):
    """
    Retrieve the output of the AdetS.py script on the given board id.

    :param connection: The alias or connection object of a connected taf.transport.ssh connection
    :param board_id: The board ID to grep for in the AdetS output.
    """
    ccs_daemon_node_id = get_CCS_Daemon_node_id(connection)

    command = 'PYTHONPATH=/opt/hwmt/python python3 ' \
              '/opt/hwmt/python/hwapi/AdetS.py -s -p 15004 ' \
              '-n {} | grep {}'.format(ccs_daemon_node_id, board_id)

    result = ssh().execute(command=command, connection=connection, timeout='60 s')

    return result


def convert_scf_to_json(scf_path):
    with open(scf_path) as fd:
        doc = xmltodict.parse(fd.read())
    return json.dumps(doc)


def get_distNames_from_scf(regex, scf_content):
    logging.debug(
        "============================== Begin get_distNames_from_scf()")
    distNames = re.findall(regex, scf_content)
    distNames = list(set(distNames))
    logging.debug(
        "============================== End get_distNames_from_scf()")
    return distNames


def get_distNames_from_json(regex, json_obj):
    logging.debug(
        "============================== Begin get_distNames_from_json()")
    json_str = json.dumps(json_obj)
    distNames = re.findall(regex, json_str)
    distNames = list(set(distNames))
    logging.debug(
        "============================== End get_distNames_from_json()")
    return distNames


def get_phy_cell_ids(cell_info):
    cell_info = [cell for cell in cell_info['cells']['nr']]
    cell_mapping = {}
    pattern_cell_id = re.compile(r'NRCELL-(\d+)')
    for item in cell_info:
        cell_id_obj = pattern_cell_id.search(
            item.get('id').get('configuration'))
        cell_id = cell_id_obj.groups()[0]
        cell_mapping["NRCELL-"+cell_id] = item.get('physicalCellId')
    return cell_mapping


def get_ip_addr(addr):
    if hasattr(addr, 'v4'):
        if addr.v4 is not None:
            return addr.v4
        elif addr.v6 is not None:
            return addr.v6
    else:
        return addr


def get_gnb_du_host_ip(du):
    if du.f1_m_ip_addr is not None:
        return get_ip_addr(du.f1_m_ip_addr)
    elif du.airscale.common_units[0].lmp_connection.addr is not None:
        return get_ip_addr(du.airscale.common_units[0].lmp_connection.addr)
    elif du.oam_ip is not None:
        return get_ip_addr(du.oam_ip)


def get_cell_id_lcrId_map(cell_info):
    cell_lcrid = {}
    for cells in cell_info.values():
        for cell_id, cell_info in cells.items():
            for contents in cell_info.values():
                if contents.get('parameters').get('lcrId'):
                    cell_lcrid[cell_id] = contents.get(
                        'parameters').get('lcrId')
    return cell_lcrid


def parse_slave_cpu_ready(chk_adet_output):
    output_lines = [line.strip()
                    for line in chk_adet_output.split('\n') if line]

    cpu_lines = [line.split()[2:4] for line in output_lines if 'cpu' in line]

    for item in cpu_lines:
        item[0] = item[0][-2:]

    cpu_data = dict(cpu_lines)
    slave_cpu_ready = {x: cpu_data[y]
                       for x, y in ((0, '30'), (1, '40'), (2, '50'))}

    return slave_cpu_ready


if __name__ == "__main__":
    scf_content = 'class="com.nokia.srbts.nrbts:NRBTS" distName="MRBTS-231/NRBTS-231" version="NRBTS5G19A_1904_201"'
    distName = get_distNames_from_scf(r'MRBTS-\d+/NRBTS-\d+', scf_content)
    print("distName = %s" % distName)
