# *** Settings ***
# Documentation    author:Lou Shuhui
# ...               contact: shuhui.lou@nokia-sbell.com
# ...               squad group: SG_01
# ...               feature : CB005752
# Suite Setup       Suite setup
# Suite Teardown    Teardown Suite
# Force Tags            
# ...    PY36
# Resource          ../../../OAM/RAN_PZ_HAZ_34/5GC002479/Resources/5GC002479_Resouce.robot
# Resource          ../CB005752/Resources/CB005752_Resouce.robot
# 
# 
# *** Test Cases ***
# [1]CB005752_5G_B_14_Call setup KPI checking in two cells
#     [Documentation]
#     [Tags]
#     [Setup]    Setup case for two CELL L3 call
#     [Teardown]  Teardown case for two CELL L3 call
#     TC.CB005752_5G_B_14_Call setup KPI checking in two cells
# 
# [1]CB005752_5G_B_12_Single UE tput testing with beamforming enabled
#     [Documentation]     KPI1A
#     [Tags]     CRT_TRUNK     CRT_22R1
#     [Setup]    Setup case for two CELL L3 call
#     [Teardown]  Teardown case for two CELL L3 call
#     TC.CB005752_5G_B_12_Single UE tput testing with beamforming enabled
# 
# [1]CB005752_5G_B_24_ASOE site reset KPI check
#     [Documentation]     KPI1
#     [Tags]
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.GC002479_HA_01_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
# 
# 
# [1]CB005752_5G_B_23_ASOE power on KPI check
#     [Documentation]     KPI2
#     [Tags]
#     [Setup]    SetUp Case
#     [Teardown]  Teardown case
#     TC.5GC002479_HA_04_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
# 
# 
# 
# 
# *** Keywords ***
# 
# Suite setup for 2479
#     #Import Variables     ${CFGFILE_PATH}/CB005752/Delta_SCF.py
#     kw.suite setup for 2479
# 
# Suite setup
#     #kw.suite setup for 2479
#     suite setup for 5752
# 
# Teardown Suite
#     run    command=cp ${CFGFILE_PATH}/TL1109_golden.xml ${LOG_PATH}/TL1109_golden.xml
#     gNB.CommissionWithRetry   scf_file=${LOG_PATH}/TL1109_golden.xml    model=${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}
#      ...    RUmodel=${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.vendor}
#     kw.teardown suite
