import logging
import re

from taf.transport.ssh import ssh
from robot.libraries.BuiltIn import BuiltIn
from taf.config.scf import scf


def get_CCS_Daemon_node_id(connection):
    command = "sh /usr/bin/ownnid"
    result = ssh().execute(command=command, connection=connection, timeout="60 s")
    CCS_Daemon_node_id = result.split("\r\n")[0]
    return CCS_Daemon_node_id


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
                num_of_frms_dict[str(gnb)] += len(
                    dus[du].airscale.common_units[comu].capacity_units
                )
    logging.debug("get_num_of_frms_per_gnb(): %s" % num_of_frms_dict)
    logging.debug("============================== End get_num_of_frms_per_gnb()")
    return num_of_frms_dict


def get_distNames_from_scf(regex, scf_content):
    logging.debug("============================== Begin get_distNames_from_scf()")
    distNames = re.findall(regex, scf_content)
    distNames = list(set(distNames))
    logging.debug("============================== End get_distNames_from_scf()")
    return distNames


def get_phy_cell_ids(scf_path, distnames):
    dict_cell_number = {}
    pattern_cell_id = re.compile(r"NRCELL-(\d+)")
    scf_obj = scf()
    scf_obj.load_scf(file_path=scf_path)
    for distname in distnames:
        cell_id_obj = pattern_cell_id.search(distname)
        cell_id = cell_id_obj.groups()[0]
        try:
            dict_cell_number["NRCELL-" + cell_id] = scf_obj.get_value_from_scf(
                dist_name=distname, p_name="physCellId"
            )
        except KeyError:
            logging.warning(
                "No Physical Cell ID present with given distname: %s" % distname
            )
    return dict_cell_number


def get_ip_addr(addr):
    if hasattr(addr, "v4"):
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


if __name__ == "__main__":
    scf_content = 'class="com.nokia.srbts.nrbts:NRBTS" distName="MRBTS-231/NRBTS-231" version="NRBTS5G19A_1904_201"'
    distName = get_distNames_from_scf(r"MRBTS-\d+/NRBTS-\d+", scf_content)
    print("distName = %s" % distName)
