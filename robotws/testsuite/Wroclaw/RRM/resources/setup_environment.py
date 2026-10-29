import re
from taf.lteemu import lteemu
from taf.config.scf import scf

lteemu = lteemu()
scf = scf()

lteemu_cfg_file = './../resources/basic_cfg_LteEmu.cfg'

modified_params = [
    dict(value='192.168.4.134',
         p_name='ENB1_X2_ADDR'),
    dict(value='192.168.4.111',
         p_name='ENB2_X2_ADDR'),
]


def lteemu_conf(lteemu_ip):
    modified_params.append(dict(value=lteemu_ip, p_name='DAEMON_IP'))
    lteemu.modify_cfg_file(lteemu_cfg_file, lteemu_cfg_file, modified_params)


def remove_cells_from_scf(original_scf, bts_id):
    scf.load_scf(original_scf)
    scf.remove_element_from_scf(dist_name="MRBTS-"+str(bts_id)+"/NRBTS-1/NRCELL-2")
    scf.remove_element_from_scf(dist_name="MRBTS-"+str(bts_id)+"/NRBTS-1/NRCELL-2/NRCELL_FDD-1")
    scf.remove_element_from_scf(dist_name="MRBTS-"+str(bts_id)+"/NRBTS-1/NRCELL-3")
    scf.remove_element_from_scf(dist_name="MRBTS-"+str(bts_id)+"/NRBTS-1/NRCELL-3/NRCELL_FDD-1")
    scf.remove_element_from_scf(dist_name="MRBTS-"+str(bts_id)+"/NRBTS-1/NRCELL-4")
    scf.remove_element_from_scf(dist_name="MRBTS-"+str(bts_id)+"/NRBTS-1/NRCELL-4/NRCELL_FDD-1")
    scf.remove_element_from_scf(list_name="nrCellList", index=1)
    scf.remove_element_from_scf(list_name="nrCellList", index=1)
    scf.remove_element_from_scf(list_name="nrCellList", index=1)
    scf.save_scf(original_scf)


def add_gps_out_synchronisation_to_scf(original_scf):
    scf.load_scf(original_scf)
    scf.add_element_to_scf(dist_name="MNL-1/MNLENT-1/SYNC-1/CLOCK-1",
                           p_name='outputConfiguration1Pps',
                           value='EnabledWithBtsInputReference')
    scf.save_scf(original_scf)


def modify_x2_ip_from_scf(original_scf, bts_id):
    scf.load_scf(original_scf)
    scf.modify_scf_element(value='192.168.4.111',
                           dist_name="MRBTS-"+str(bts_id)+"/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1",
                           p_name='localIpAddr')
    scf.modify_scf_element(value='192.168.4.112',
                           dist_name="MRBTS-"+str(bts_id)+"/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1",
                           p_name='localIpAddr')
    scf.save_scf(original_scf)


def modify_rap_profile_to_AEQUA_in_scf(original_scf, bts_id):
    scf.load_scf(original_scf)
    scf.modify_scf_element(value='5G18A/5g_pid12_abil_l2rt_eoc',
                           dist_name="MRBTS-"+str(bts_id)+"/EQM-1/APEQM-1",
                           p_name='rapProfile')
    scf.save_scf(original_scf)
