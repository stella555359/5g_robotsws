# *** Settings ***
# Suite Setup          Dedicate_Suite_Setup
# Suite Teardown       Dedicate_Suite_Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# 
# 
# Resource    ./Resources/dingli_call_keywords.robot
# Resource    ./Resources/L3call_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/gnb_sync.robot
# 
# Documentation
# ...    Author: Deng Xueqin
# ...    Contact: xueqin.deng@nokia-sbell.com
# ...    squad group: HAZ3_SG2
# ...    E2E Rjio
# 
# Force Tags    PY36
# 
# 
# *** Variables ***
# ${DU_OAM_IP}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# ${acceptedClock_path_GPS}    MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
# ${acceptedClock_path_TOP-P}   MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1
# ${accept_clock_value_modify}    7
# ${X2_link_shutdown_time}    ${30}
# @{gci_list}    1    17
# 
# *** Test Cases ***
# [1]Rjio_E2E_23_PTP_Failure_Between_SM_And_RM_Reference
#     [Tags]
#     [Setup]    run keywords    SISO Coam Test Setup    AND    PTP failure_Setup
#     PTP_failure_between_SM_and_RM_reference
#     [Teardown]    run keywords    PTP failure_teardown    AND    SISO Coam Test Teardown
# 
# [1]Rjio_E2E_25_Data_Call_–_Dl_Ul_Throughput_Check
#     [Documentation]    Rjio_E2E_25_Data_Call_Dl_Ul_Throughput_Check
#     [Tags]    REPEAT_TEST
#     [Timeout]    1h
#     Set PA value for CA call    pCellAttenuatorIndex=${1}    sCellAttenuatorIndex=${0}
#     Dingli l3call traffic CA    gcip=${17}    gcis=${1}
# 
# [1]Rjio_E2E_26_CA_Call
#     [Documentation]    Rjio_E2E_26_CA_Call
#     [Tags]
#     [Timeout]    1h
#     Set PA value for CA call    pCellAttenuatorIndex=${1}    sCellAttenuatorIndex=${0}
#     Dingli l3call traffic CA    gcip=${17}    gcis=${1}
# 
# [1]Rjio_E2E_36_SRS-Based_SU-MIMO
#     [Documentation]    Rjio_E2E_36_SRS-Based_SU-MIMO
#     [Tags]    REPEAT_TEST
#     [Timeout]    1h
#     Set PA value for nCA call    CellAttenuatorIndex=${0}    MuteCellAttenuatorIndex=${1}
#     Dingli l3call traffic nCA    gci=${1}
# 
# [1]Rjio_E2E_37_Code_Book_Based_Ul_SU-Mimo_2_Layers
#     [Documentation]    Rjio_E2E_37_Code_Book_Based_Ul_SU-Mimo_2_Layers
#     [Tags]
#     [Timeout]    1h
#     Set PA value for nCA call    CellAttenuatorIndex=${0}    MuteCellAttenuatorIndex=${1}
#     Dingli l3call traffic nCA    gci=${1}
# 
# [1]Rjio_E2E_24_Site_Reset_With_L3_Call
#     [Documentation]    Rjio_E2E_24_Site_Reset_With_L3_Call
#     [Tags]
#     [Timeout]    1h
#     Selenium Login And Disable Screen Lock
#     Perform BTS Site Reset On WebUI
#     sleep    60s
#     Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
#     sleep    30s
#     Set PA value for CA call    pCellAttenuatorIndex=${1}    sCellAttenuatorIndex=${0}
#     sleep    30s
#     Dingli l3call traffic CA    gcip=${17}    gcis=${1}
#     [Teardown]    run keywords    selenium logout and close browser    AND    SISO Coam Test Teardown
# 
# [1]Rjio_AQQJ_3_Parallel_Operation_Cell_Lock_Unlock_and_L3call
#     [Documentation]    Rjio_AQQJ_3_Parallel_Operation_Cell_Lock_Unlock_and_L3call
#     [Tags]
#     [Timeout]    2h
#     Parallel_Operation_Cell_Lock_Unlock_and_L3call
# 
# [1]Rjio_AQQJ_4_Parallel_Operation_Cell_Barred_Unbarred_and_L3call
#     [Documentation]    Rjio_AQQJ_4_Parallel_Operation_Cell_Barred_Unbarred_and_L3call
#     [Tags]
#     [Timeout]    2h
#     Parallel_Operation_Cell_Barred_Unbarred
# 
# [1]Rjio_AQQJ_5_Parallel_Operation_RAT_Block_Unblock_and_L3call
#     [Documentation]    Rjio_AQQJ_5_Parallel_Operation_RAT_Block_Unblock_and_L3call
#     [Tags]
#     [Timeout]    2h
#     Parallel_Operation_RAT_Block_Unblock_and_L3call
# 
# [1]Rjio_E2E_14_Frame_Struture_Change_From_3ms_To_0ms
#     [Documentation]    Rjio_E2E_14_Frame_Struture_Change_From_3ms_To_0ms
#     [Tags]
#     [Timeout]    1h
#     Rjio_commission_scf    scf_suffix=.xml
# 
# [1]Rjio_E2E_16_Prach_Index_190_And_L3_Call
#     [Documentation]    Rjio_E2E_16_Prach_Index_190_And_L3_Call
#     [Tags]
#     [Timeout]    1h
#     Rjio_commission_scf    scf_suffix=_190_3ms.xml    L3call=${True}
# 
# *** Keywords ***
# Set PA value for CA call
#     [Arguments]    ${pCellAttenuatorIndex}    ${sCellAttenuatorIndex}
#     Log to console    \n***set PA: pCellPAindex:${pCellAttenuatorIndex}, sCellPAindex:${sCellAttenuatorIndex}***\n
#     Set_PA_Value    value=${20}    attenuator_index=${pCellAttenuatorIndex}
#     Set_PA_Value    value=${80}    attenuator_index=${sCellAttenuatorIndex}
# 
# Set PA value for nCA call
#     [Arguments]    ${CellAttenuatorIndex}    ${MuteCellAttenuatorIndex}
#     Log to console    \n***set PA: cellPAindex:${CellAttenuatorIndex}, MuteCellPAindex:${MuteCellAttenuatorIndex}***\n
#     Set_PA_Value    value=${20}    attenuator_index=${CellAttenuatorIndex}
#     Set_PA_Value    value=${127}    attenuator_index=${MuteCellAttenuatorIndex}
# 
# Dedicate_Suite_Setup
#     Import Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/TLData/${testline_name}/TLConfiguration.py
#     SISO Coam Suite Setup
#     Connect to gnb coam via ssl
#     ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
#     ${cell_17_id}    Convert To String    ${cell_mapping[17]['nrCellIdentity']}
#     ${cell_1_id}    Convert To String    ${cell_mapping[1]['nrCellIdentity']}
#     set suite variable    ${cell_17_id}
#     set suite variable    ${cell_1_id}
#     Dingli call setup
# 
# Dedicate_Suite_Teardown
#     run keyword and ignore error    Dingli call teardown
#     SISO Coam Suite Teardown
# 
# Rjio_CA_Call
#     Set PA value for CA call    pCellAttenuatorIndex=${1}    sCellAttenuatorIndex=${0}
#     sleep    300s
#     Dingli l3call traffic CA    gcip=${17}    gcis=${1}
# 
# PTP_failure_between_SM_and_RM_reference
#     set sync info of GNB1    accpetclock_path=${acceptedClock_path_GPS}    acceptclock=${accept_clock_value_modify}
#     set sync info of GNB1    accpetclock_path=${acceptedClock_path_TOP-P}    acceptclock=${accept_clock_value_modify}
#     check sync status change of GNB
#     Wait For Expect Fault Present    faultId=${16}    timeout=1200
#     Wait For Expect Fault Present    faultId=${4298}    timeout=1200
#     set sync info of GNB1    accpetclock_path=${acceptedClock_path_GPS}    acceptclock=${accpetclock_gps}
#     set sync info of GNB1    accpetclock_path=${acceptedClock_path_TOP-P}    acceptclock=${accpetclock_top}
#     Wait For Expect Fault To Disappear    faultId=${16}    timeout=1200
#     Wait For Expect Fault To Disappear    faultId=${4298}    timeout=1200
#     Connect to gnb coam via ssl
#     wait until keyword succeeds    10min    30s    verify all cells should be onair
#     #Run Keyword And Ignore Error    COAM Teardown gnb connections
#     Log To Console    Check call
#     Set PA value for CA call    pCellAttenuatorIndex=${1}    sCellAttenuatorIndex=${0}
#     Dingli l3call traffic CA    gcip=${17}    gcis=${1}
# 
# PTP failure_Setup
#     ${accpetclock_gps}    get sync info of GNB1    accpetclock_path=${acceptedClock_path_GPS}
#     ${accpetclock_top}    get sync info of GNB1    accpetclock_path=${acceptedClock_path_TOP-P}
#     set global variable    ${accpetclock_gps}
#     set global variable    ${accpetclock_top}
# 
# PTP failure_teardown
#     set sync info of GNB1    accpetclock_path=${acceptedClock_path_GPS}    acceptclock=${accpetclock_gps}
#     set sync info of GNB1    accpetclock_path=${acceptedClock_path_TOP-P}    acceptclock=${accpetclock_top}
#     #Connect to gnb coam via ssl
#     wait until keyword succeeds    10min    30s    verify all cells should be onair
#     Run Keyword And Ignore Error    COAM Teardown gnb connections
#     Run Keyword And Ignore Error    Selenium Logout And Close Browser
# 
# get sync info of GNB1
#     [Documentation]
#     [Arguments]
#     ...    ${accpetclock_path}=${acceptedClock_path}
#     Selenium Login And Disable Screen Lock
#     ${accpetclock}    selenium_coam.get_parameter_value
#     ...    dist_name=${accpetclock_path}    filter_param=Accepted clock class list
#     sort list    ${accpetclock}
#     [Return]    ${accpetclock}
#     [Teardown]   Selenium Logout And Close Browser
# 
# set sync info of GNB1
#     [Documentation]
#     [Arguments]
#     ...    ${accpetclock_path}=${acceptedClock_path}
#     ...    ${acceptclock}=${accept_clock_value_modify}
#     Selenium Login And Disable Screen Lock
#     selenium_coam.set_parameter_value
#     ...    abbr=acceptedClockClass
#     ...    dist_name=${accpetclock_path}
#     ...    filter_param=Accepted clock class list
#     ...    new_value=${acceptclock}
#     selenium_coam.validate_plan
#     selenium_coam.activate_plan    activate_plan_despite_errors=True
#     [Teardown]   Selenium Logout And Close Browser
# 
# Parallel_Operation_RAT_Block_Unblock_and_L3call
#     Log to console    \n***RAT Block and UnBlock***\n
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     sleep    5s
#     selenium_coam.block_rat    NR
#     Wait For Expect Fault Present    faultId=4614    timeout=180
#     ${passed21}    Run Keyword And Return Status    Dingli l3call traffic CA    gcip=${17}    gcis=${1}
#     Should Not Be True    ${passed21}
#     selenium_coam.unblock_rat    NR
#     Wait For Expect Fault To Disappear  faultId=4614    timeout=180
#     Wait Until Keyword Succeeds    10min    20s    Verify all cells should be onair
#     sleep    10s
#     Dingli l3call traffic CA    gcip=${17}    gcis=${1}
#     [Teardown]    Run Keywords
#     ...    run keyword and ignore error    selenium_coam.unblock_rat    NR
#     ...    AND  run keyword and ignore error    Selenium Logout And Close Browser
# 
# Parallel_Operation_Cell_Lock_Unlock_and_L3call
#     Set PA value for CA call    pCellAttenuatorIndex=${1}    sCellAttenuatorIndex=${0}
#     log to console    \n***Dingli l3call traffic CA    gcip=${17}    gcis=${1}***\n
#     Dingli l3call traffic CA    gcip=${17}    gcis=${1}
#     Get X2 link shutdown waiting time
#     Lock cells or groups and check status
#     ...    lock_list=${gci_list}
#     ...    is_group=${False}
#     ...    check_alarm=${True}
#     ...    gnb_type='${gNb_CuType}'
#     ...    connection=OAM_ssl
#     sleep    2s
#     ${passed21}    Run Keyword And Return Status    Dingli l3call traffic CA    gcip=${17}    gcis=${1}
#     Should Not Be True    ${passed21}
#     Unlock cells or groups and check status
#     ...    lock_list=${gci_list}
#     ...    is_group=${False}
#     ...    check_alarm=${True}
#     ...    gnb_type='${gNb_CuType}'
#     ...    connection=OAM_ssl
#     sleep    10s
#     Dingli l3call traffic CA    gcip=${17}    gcis=${1}
#     [Teardown]    run keyword and ignore error    Unlock cells or groups and check status
#     ...    lock_list=${gci_list}
#     ...    is_group=${False}
#     ...    check_alarm=${True}
#     ...    gnb_type='${gNb_CuType}'
#     ...    connection=OAM_ssl
# 
# Parallel_Operation_Cell_Barred_Unbarred
#     ${CELL17_Barred}    set variable    ${False}
#     ${CELL1_Barred}    set variable    ${False}
#     log to console    \n***Set PA to ensure CA cells CELL17 and CELL1 are both L3call ok***\n
#     Set PA value for CA call    pCellAttenuatorIndex=${1}    sCellAttenuatorIndex=${0}
#     Dingli l3call traffic nCA    gci=${17}
#     ${CELL17_Barred}    Modify_CELL17_cellBarred_to_barred_Parameters_via_WebEM
#     sleep    60s
#     log to console    \n***CELL17 should not be attached as pCell.***\n
#     ${passed21}    Run Keyword And Return Status    Dingli l3call traffic nCA    gci=${17}
#     Should Not Be True    ${passed21}
#     log to console    \n***CELL1 should be attached as pCell.***\n
#     Dingli l3call traffic nCA    gci=${1}
#     ${CELL1_Barred}    Modify_CELL1_cellBarred_to_barred_Parameters_via_WebEM
#     sleep    60s
#     log to console    \n***CELL17 and CELL1 should not be attached as pCell.***\n
#     ${passed3}    Run Keyword And Return Status    Dingli l3call traffic nCA    gci=${1}
#     Should Not Be True    ${passed3}
#     ${CELL1_Barred}    Modify_CELL1_cellBarred_to_notBarred_Parameters_via_WebEM
#     sleep    60s
#     log to console    \n***CELL1 should be attached as pCell.***\n
#     Dingli l3call traffic nCA    gci=${1}
#     ${CELL17_Barred}    Modify_CELL17_cellBarred_to_notBarred_Parameters_via_WebEM
#     sleep    60s
#     log to console    \n***CELL17 should be attached as pCell.***\n
#     Dingli l3call traffic CA    gcip=${17}    gcis=${1}
#     [Teardown]    Run Keywords
#     ...    Run keyword if    ${CELL1_Barred}    Modify_CELL1_cellBarred_to_notBarred_Parameters_via_WebEM
#     ...    AND  Run keyword if    ${CELL17_Barred}    Modify_CELL17_cellBarred_to_notBarred_Parameters_via_WebEM
# 
# Modify_CELL${GCI}_cellBarred_to_${value}_Parameters_via_WebEM
#     [Documentation]
#     ...    ********************************
#     ...    GCI: Global cell ID
#     ...    value:e.g.:barred,notBarred;
#     ...    barred cell can't be used as pCell.
#     log to console  \n***Modify_CELL${GCI}_cellBarred_to_${value}_Parameters_via_WebEM***\n
#     ${CELL_Barred}    set variable    ${False}
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     Check and Modify Single Parameter on WebUI
#     ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${GCI}
#     ...    filter_param=Cell Barred
#     ...    abbr=cellBarred
#     ...    new_value=${value}
#     ${CELL_Barred}    Run keyword if    '${value}'=='barred'    set variable    ${True}
#     [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser
#     [Return]    ${CELL_Barred}
