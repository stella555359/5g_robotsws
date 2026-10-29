# *** Settings ***
# Suite Setup          Dedicate_Suite_Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# 
# #Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/Rjio_HAZ3_SG2/Resources/made_variable.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/gnb_sync.robot
# Resource    ./Resources/L3call_keywords.robot
# 
# Documentation
# ...    Author: Dong Tingting
# ...    Contact: tingting.dong@nokia-sbell.com
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
# #@{gci_list}    1    2    3    21    22    23
# #@{gci_list}    0    1    2    16    17    18
# @{gci_list}    2    18
# #${if_commissioning}    False
# 
# *** Test Cases ***
# [1]Rjio_E2E_23_PTP_Failure_Between_SM_And_RM_Reference
#     [Setup]    run keywords    SISO Coam Test Setup    AND    PTP failure_Setup
#     PTP_failure_between_SM_and_RM_reference
#     [Teardown]    run keywords    PTP failure_teardown    AND    SISO Coam Test Teardown
# 
# [1]Rjio_E2E_25_Data_Call_–_Dl_Ul_Throughput_Check
#     [Documentation]    Rjio_E2E_25_Data_Call_Dl_Ul_Throughput_Check
#     [Tags]
#     [Timeout]    1h
#     Set_PA_Value    value=${20}    attenuator_index=${2}
#     Prepare_UE_Only
#     L3call_Traffic_CA_CELL_18_2
# 
# [1]Rjio_E2E_26_CA_Call
#     [Documentation]    Rjio_E2E_26_CA_Call
#     [Tags]
#     [Timeout]    1h
#     Set_PA_Value    value=${20}    attenuator_index=${2}
#     Prepare_UE_Only
#     L3call_Traffic_CA_CELL_18_2
# 
# [1]Rjio_E2E_36_SRS-Based_SU-MIMO
#     [Documentation]    Rjio_E2E_36_SRS-Based_SU-MIMO
#     [Tags]
#     [Timeout]    1h
#     Set_PA_Value    value=${120}    attenuator_index=${2}
#     Prepare_UE_Only
#     L3call_Traffic_CELL_2
# 
# [1]Rjio_E2E_37_Code_Book_Based_Ul_SU-Mimo_2_Layers
#     [Documentation]    Rjio_E2E_37_Code_Book_Based_Ul_SU-Mimo_2_Layers
#     [Tags]
#     [Timeout]    1h
#     Set_PA_Value    value=${120}    attenuator_index=${2}
#     Prepare_UE_Only
#     L3call_Traffic_CELL_2
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
#     Set_PA_Value    value=${20}    attenuator_index=${2}
#     sleep    30s
#     Prepare_UE_Only
#     L3call_Traffic_CA_CELL_18_2
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
#     Set_PA_Value    value=${15}    attenuator_index=${2}
#     Parallel_Operation_RAT_Block_Unblock_and_L3call
# 
# [1]Rjio_E2E_14_Frame_Struture_Change_From_3ms_To_0ms
#     [Documentation]    Rjio_E2E_14_Frame_Struture_Change_From_3ms_To_0ms
#     [Tags]
#     [Timeout]    1h
#     Rjio_commission_scf    scf_suffix=.xml
# 
# #[1]Rjio_E2E_16_Prach_Index_190_And_L3_Call
# #    [Documentation]    Rjio_E2E_16_Prach_Index_190_And_L3_Call
# #    [Tags]
# #    [Timeout]    1h
# #    Rjio_commission_scf    scf_suffix=_190_3ms.xml    L3call=${True}
# 
# *** Keywords ***
# Dedicate_Suite_Setup
#     Import Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/TLData/${testline_name}/TLConfiguration.py
#     SISO Coam Suite Setup
# 
# #Rjio_CA_Call
# #    Set_PA_Value    value=${20}    attenuator_index=${2}
# #    sleep    300s
# #    Prepare_UE_Only
# #    L3call_Traffic_CA_CELL_18_2
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
#     Set_PA_Value    value=${20}    attenuator_index=${2}
#     Prepare_UE_Only
#     L3call_Traffic_CA_CELL_18_2
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
#     ${accpetclock}    selenium_coam.get_parameter_value    dist_name=${accpetclock_path}    filter_param=Accepted clock class list
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
#     Prepare_UE_Only
#     ${passed21}    Run Keyword And Return Status    L3call_Traffic_CA_CELL_18_2
#     Should Not Be True    ${passed21}
#     selenium_coam.unblock_rat    NR
#     Wait For Expect Fault To Disappear  faultId=4614    timeout=180
#     Wait Until Keyword Succeeds    10min    20s    Verify all cells should be onair
#     sleep    60s
#     L3call_Traffic_CA_CELL_18_2
#     [Teardown]    Run Keywords
#     ...    run keyword and ignore error    selenium_coam.unblock_rat    NR
#     ...    AND  run keyword and ignore error    Selenium Logout And Close Browser
# 
# Parallel_Operation_Cell_Lock_Unlock_and_L3call
#     Set_PA_Value    value=${15}    attenuator_index=${2}
#     log to console    \n***L3call_Traffic_CA_CELL_18_2***\n
#     Prepare_UE_Only
#     L3call_Traffic_CA_CELL_18_2
#     Get X2 link shutdown waiting time
#     Lock cells or groups and check status
#     ...    lock_list=${gci_list}
#     ...    is_group=${False}
#     ...    check_alarm=${True}
#     ...    gnb_type='${gNb_CuType}'
#     ...    connection=OAM_ssl
#     sleep    2s
#     ${passed21}    Run Keyword And Return Status    L3call_Traffic_CA_CELL_18_2
#     Should Not Be True    ${passed21}
#     Unlock cells or groups and check status
#     ...    lock_list=${gci_list}
#     ...    is_group=${False}
#     ...    check_alarm=${True}
#     ...    gnb_type='${gNb_CuType}'
#     ...    connection=OAM_ssl
#     sleep    30s
#     L3call_Traffic_CA_CELL_18_2
#     [Teardown]    run keyword and ignore error    Unlock cells or groups and check status
#     ...    lock_list=${gci_list}
#     ...    is_group=${False}
#     ...    check_alarm=${True}
#     ...    gnb_type='${gNb_CuType}'
#     ...    connection=OAM_ssl
# 
# Parallel_Operation_Cell_Barred_Unbarred
#     ${CELL18_Barred}    set variable    ${False}
#     ${CELL2_Barred}    set variable    ${False}
#     log to console    \n***Set PA to ensure CA cells CELL18 and CELL2 are both L3call ok***\n
#     Set_PA_Value    value=${15}    attenuator_index=${2}
#     Prepare_UE_Only
#     L3call_Traffic_CELL_18
#     ${CELL18_Barred}    Modify_CELL18_cellBarred_to_barred_Parameters_via_WebEM
#     sleep    60s
#     log to console    \n***CELL18 should not be attached as pCell.***\n
#     ${passed21}    Run Keyword And Return Status    L3call_Traffic_CELL_18
#     Should Not Be True    ${passed21}
#     log to console    \n***CELL2 should be attached as pCell.***\n
#     L3call_Traffic_CELL_2
#     ${CELL2_Barred}    Modify_CELL2_cellBarred_to_barred_Parameters_via_WebEM
#     sleep    60s
#     log to console    \n***CELL18 and CELL2 should not be attached as pCell.***\n
#     ${passed3}    Run Keyword And Return Status    L3call_Traffic_CELL_2
#     Should Not Be True    ${passed3}
#     ${CELL2_Barred}    Modify_CELL2_cellBarred_to_notBarred_Parameters_via_WebEM
#     sleep    60s
#     log to console    \n***CELL2 should be attached as pCell.***\n
#     L3call_Traffic_CELL_2
#     ${CELL18_Barred}    Modify_CELL18_cellBarred_to_notBarred_Parameters_via_WebEM
#     sleep    60s
#     log to console    \n***CELL18 should be attached as pCell.***\n
#     L3call_Traffic_CA_CELL_18_2
#     [Teardown]    Run Keywords
#     ...    Run keyword if    ${CELL2_Barred}    Modify_CELL2_cellBarred_to_notBarred_Parameters_via_WebEM
#     ...    AND  Run keyword if    ${CELL18_Barred}    Modify_CELL18_cellBarred_to_notBarred_Parameters_via_WebEM
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
