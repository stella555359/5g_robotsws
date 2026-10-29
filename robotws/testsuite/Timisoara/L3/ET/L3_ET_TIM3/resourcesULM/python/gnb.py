import logging
import re
import xmltodict
import json

from taf.transport.ssh import ssh
from robot.libraries.BuiltIn import BuiltIn
from testline import identify_module
from testline_information import get_testline_configuration


def get_CCS_Daemon_node_id(connection):
    """
    Determine the CCS Daemon node id via command /usr/bin/ownid

    :param connection: The alias or connection object of a connected taf.transport.ssh connection
    """
    command = "sh /usr/bin/ownnid"
    result = ssh().execute(command=command, connection=connection, timeout='60 s')
    CCS_Daemon_node_id = result.split('\r\n')[0]
    return CCS_Daemon_node_id


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


def get_board_ids(connection, gnb_id=0, du_id=0, comu_id=0):
    """
    Retrieves the board ids on a connection to a system module

    :param connection: The connection or connection alias of an existing ssh connection
    """
    ccs_daemon_node_id = get_CCS_Daemon_node_id(connection)
    board_type = identify_module(connection)
    tl = get_testline_configuration()

    if 'ASO' in board_type:
        end_index = 1
    else:
        end_index = len(tl.gnbs[gnb_id].dus[du_id].airscale.common_units[comu_id].capacity_units)

    try:
        return {'0x1011': ['0x10', '0x12', '0x13', '0x14'][0:end_index],
                '0x2011': ['0x20', '0x22', '0x23', '0x24'][0:end_index],
                '0x5011': ['0x50', '0x52']}[ccs_daemon_node_id]
    except KeyError:
        raise AssertionError("Wrong node id {}".format(ccs_daemon_node_id))
    except IndexError:
        raise AssertionError("Wrong End Index for detection of board ids!}")


def get_num_of_frms_per_gnb():
    logging.debug("============================== Begin get_num_of_frms_per_gnb()")
    """Author: Vasileios Papoutsis, Keyword: Get DU list (Temporary solution)
    Up to now 1RF is connected to 1 capacity unit (e.g. ABIL), i.e. number of capacity units == num of RFs"""
    tl = BuiltIn().get_variable_value("${tl}")
    num_of_frms_dict = {}
    gnb_num = len(tl.gnbs)
    for gnb in range(gnb_num):
        num_of_frms_dict.update({str(gnb): 0})
        dus = tl.gnbs[gnb].dus
        du_num = len(dus)
        for du in range(du_num):
            common_units = len(dus[du].airscale.common_units)
            for comu in range(common_units):
                num_of_frms_dict[str(gnb)] += len(dus[du].airscale.common_units[comu].capacity_units)
    logging.debug("get_num_of_frms_per_gnb(): %s" % num_of_frms_dict)
    logging.debug("============================== End get_num_of_frms_per_gnb()")
    return num_of_frms_dict


def convert_scf_to_json(scf_path):
    with open(scf_path) as fd:
        doc = xmltodict.parse(fd.read())
    return json.dumps(doc)


def get_distNames_from_scf(regex, scf_content):
    logging.debug("============================== Begin get_distNames_from_scf()")
    distNames = re.findall(regex, scf_content)
    distNames = list(set(distNames))
    logging.debug("============================== End get_distNames_from_scf()")
    return distNames


def get_distNames_from_json(regex, json_obj):
    logging.debug("============================== Begin get_distNames_from_json()")
    json_str = json.dumps(json_obj)
    distNames = re.findall(regex, json_str)
    distNames = list(set(distNames))
    logging.debug("============================== End get_distNames_from_json()")
    return distNames


def get_phy_cell_ids(cell_info):
    cell_info = [cell for cell in cell_info['cells']['nr']]
    cell_mapping = {}
    pattern_cell_id = re.compile(r'NRCELL-(\d+)')
    for item in cell_info:
        cell_id_obj = pattern_cell_id.search(item.get('id').get('configuration'))
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
                    cell_lcrid[cell_id] = contents.get('parameters').get('lcrId')
    return cell_lcrid


def parse_slave_cpu_ready(chk_adet_output):
    output_lines = [line.strip() for line in chk_adet_output.split('\n') if line]

    cpu_lines = [line.split()[2:4] for line in output_lines if 'cpu' in line]

    for item in cpu_lines:
        item[0] = item[0][-2:]

    cpu_data = dict(cpu_lines)
    slave_cpu_ready = {x: cpu_data[y] for x, y in ((0, '30'), (1, '40'), (2, '50'))}

    return slave_cpu_ready


if __name__ == "__main__":
    scf_content = 'class="com.nokia.srbts.nrbts:NRBTS" distName="MRBTS-231/NRBTS-231" version="NRBTS5G19A_1904_201"'
    distName = get_distNames_from_scf(r'MRBTS-\d+/NRBTS-\d+', scf_content)
    print("distName = %s" % distName)
