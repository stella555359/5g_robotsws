"""

Package keeps all connection names(aliases) used in common keywords

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
"""
# Moler dev_name for sshconnection to DU Eg GNB0_DU0,ENB_DU0
ssh_bts_du = "{}{}_DU{}"
# Moler dev_name for ssh connection to Capacity Unit Eg GNB0_DU0_CU0_CPTY1
ssh_cap_unit = "{}{}_DU{}_CU{}_CPTY{}"
# Moler dev_name for sylsog streaming from DU Eg GNB0_DU0_SYSLOG
syslog_bts_du = "{}{}_DU{}_SYSLOG"
# Moler dev_name for ssh connection to RU Eg GNB0_DU0_RU0
ssh_bts_du_ru = "{}{}_DU{}_RU{}"
# Alias for rest api to DU, Eg REST_GNB0_DU0,REST_GNB0_DU1
rest_bts_du = "REST_{}{}_DU{}"
# Alias for GUI to DU, Eg GUI_GNB0_DU0, GUI_GNB0_DU1
gui_bts_du = "GUI_{}{}_DU{}"
# Moler dev_name for ssh connection to BTS Workstation eg: GNB0_DU0_WS
ws_du = "{}{}_DU{}_WS"

# Additional devices for CloudBts
# Moler device name for ssh connection to CU Eg GNB0_CU
ssh_gnb_cu = "GNB{}_CU"
# Alias for rest api to CU, Eg REST_GNB0_CU, REST_GNB1_CU
rest_gnb_cu = "REST_GNB{}_CU"
# Alias for GUI for DU, Eg GUI_GNB0_CU, GUI_GNB1_CU
gui_gnb_cu = "GUI_GNB{}_CU"

# PC for controlling UE
# Moler device name for ssh connection to PC for controling UE eg UE0_PC
ue_pc = "UE{}_PC"
