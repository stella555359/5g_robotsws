# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# MR_NR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/MNL-1/MNLENT-1/SYNC-1'
MR_NR_CDSCP_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_UDSCP_NAME = MR_NR_CDSCP_NAME + '/NRDRB-7'
MR_NR_UDSCP_eNB_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/LNBTS-719'
CU_UDSCP_NAME = MR_NR_CDSCP_NAME + '/NRDRB-1'
gNB_ip = str(tl.gnbs[0].dus[0].f1_m_ip_addr)
eNB_ip = str(tl.enbs[0].airscale.common_units[0].lmp_connection.addr)
cu_fronthual_ip = str(tl.gnbs[0].cu.f1u.v4)
cu_backhual_ip1 = str(tl.gnbs[0].cu.x2c.v4)
cu_backhual_ip2 = str(tl.gnbs[0].cu.x2u.v4)

DU_DSCP_value_web = [dict(dist_name=MR_NR_UDSCP_NAME, filter_param='DSCP', abbr='dscp')]

CU_DSCP_value_web = [dict(object_name=CU_UDSCP_NAME, filter_param='DSCP', abbreviation='dscp'),
                     dict(object_name=MR_NR_CDSCP_NAME, filter_param='Control plane DSCP', abbreviation='cPlaneDscp')]

Modify_eNB_DSCP_value = ['23', '24']

Modify_CU_DSCP_value_web = ['25', '26']

Modify_DU_DSCP_value = [dict(dist_name=MR_NR_UDSCP_NAME, parameter='dscp', value=27)]

listen_port_list = ['fronthaul', 'backhaul', 'x2', 'br1']

filter_list = [" ", " ", " ", " "]

src_dst_iplist = [[gNB_ip, cu_fronthual_ip], [eNB_ip, cu_backhual_ip2],
                  [eNB_ip, cu_backhual_ip1], [eNB_ip, '10.107.182.164']]

filename_list1 = ['F1_1.pcap', 'X2U_1.pcap', 'X2C_1.pcap', 'S1C_1.pcap']

filename_list2 = ['F1_2.pcap', 'X2U_2.pcap', 'X2C_2.pcap', 'S1C_2.pcap']

filename_list3 = ['F1_3.pcap', 'X2U_3.pcap', 'X2C_3.pcap', 'S1C_3.pcap']

# src_dst_iplist1 = [[cu_fronthual_ip, gNB_ip], [cu_backhual_ip2, eNB_ip]]
# 10.107.199.60 是S-GW 侧的 S1U 地址，可以询问核心网的人
src_dst_iplist1 = [[cu_fronthual_ip, gNB_ip], [cu_backhual_ip2, '10.107.199.60']]
