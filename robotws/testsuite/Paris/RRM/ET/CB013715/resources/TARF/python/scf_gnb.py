import logging
import re
import xmltodict
import json


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
    scf_content = 'class="com.nokia.srbts.nrbts:NRBTS" distName="MRBTS-1/NRBTS-2" version="NRBTS5G19A_1904_201"'
    distName = get_distNames_from_scf(r'MRBTS-\d+/NRBTS-\d+', scf_content)
    print("distName = %s" % distName)
