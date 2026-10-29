*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           #SISO Coam Test Setup
Test Teardown        #SISO Coam Test Teardown
Test Timeout         120 min

Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource             ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource             ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource             ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource             ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
Resource             ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource             ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
Resource             testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/resource/resources_l3call.robot
Resource             testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008952_SG05/resource/resource.robot
Resource             ./resource/CB008997_Common_KW.robot

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB008997 in SBTS23R4 program with AVQE

Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY36    master_classicalbts_all

*** Test Cases ***
##==== CB008997-SR-A-Operability for AVQE ====##
#[1]CB008997-SR_02_General_SiSo_Commissioning_BTS_Template_Commissioning
#    [Tags]    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    General_SiSo_Commissioning_BTS_Template_Commissioning
#    [Teardown]    SISO Coam Test Teardown
#
#[1]CB008997-SR_08_General_SiSo_RU_module_reset_from_GUI
#    [Tags]    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    General_SiSo_RF_module_reset_from_GUI    with_call=${False}
#    [Teardown]    SISO Coam Test Teardown
#
#[1]CB008997-SR_09_Manual_SiSo_SM_BTS_Site_Reset
#    [Tags]    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    General_SiSo_Auto_BTS_site_reset    with_call=${False}
#    [Teardown]    SISO Coam Test Teardown
#
#[1]CB008997-SR_12_General_SiSo_Cell_block_and_unblock
#    [Tags]    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    General_SiSo_Cell_block_and_unblock    with_call=${False}
#    [Teardown]    SISO Coam Test Teardown

[1]CB008997-SR_13_Manual_SiSo_SM_RF_Module_lock_unlock
    [Tags]   1S-1CC-8D4U_A8_20M_C2-195    CIT_23R4    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${True}    with_peak=${True}
    [Teardown]    Run Keywords    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB008997-SR_28_Manual_Siso_PM_5G_uDTX
    [Tags]   CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    step 1: Check power consumption counter with uDTX disabled on OnAir state
    step 2: Note the values of RU power consumption
    step 3: Change actMicroDtx parameter from false to true
    step 4: Check power consumption counter with uDTX enabled on OnAir state
    # step 5: Perform L3Call with DL and UL data
    step 6: Change actMicroDtx parameter from true to false
    step 7: Check power consumption counter with uDTX disabled on OnAir state
    # step 8: Perform L3Call with DL and UL data
    [Teardown]    SISO Coam Test Teardown

##==== CB008997-SR-B-SyVe Call performance with full set of configurations for AVQE ====##
#[1]CB008997-SR_34_General_SiSo_E2E_system_setup_with_data_transfer_conducted_70M_peak_tput
#    [Tags]   CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    ${cell_list}    create list    ${1}
#    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
#    [Teardown]    SISO Coam Test Teardown

[1]CB008997-SR_38_General_SiSo_E2E_system_setup_with_data_transfer_conducted_20M_peak_tput
    [Tags]    1S-1CC-8D4U_A8_20M_C2-195    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${cell_list}    create list    ${1}
    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
    ...    cell_list=${cell_list}    with_peak=${True}   4G_check=${False}
    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
    [Teardown]    SISO Coam Test Teardown

[1]CB008997-SR_42_General_SiSo_E2E_system_setup_with_data_transfer_conducted_60M+80M_peak_tput
    [Tags]    1S-2CC-8D4U_A6_60-80M_A2-98    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${cell_list}    create list    ${1}
    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
    ...    cell_list=${cell_list}    with_peak=${True}   4G_check=${False}
    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
    [Teardown]    SISO Coam Test Teardown

#[1]CB008997-SR_44_General_SiSo_E2E_system_setup_with_data_transfer_conducted_30M+40M_peak_tput
#    [Tags]   CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    ${cell_list}    create list    ${1}
#    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
#    [Teardown]    SISO Coam Test Teardown

[1]CB008997-SR_46_General_SiSo_E2E_system_setup_with_data_transfer_conducted_50M+70M_peak_tput
    [Tags]    1S-2CC-8D4U_A3_50-70M_F0-7    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${cell_list}    create list    ${1}
    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
    ...    cell_list=${cell_list}    with_peak=${True}   4G_check=${False}
    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB008997-SR_48_General_SiSo_E2E_system_setup_with_data_transfer_conducted_100M+100M_peak_tput
    [Tags]    1S-2CC-8D4U_A5_100-100M_C2-191_TA-3000    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${cell_list}    create list    ${1}
    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
    ...    cell_list=${cell_list}    with_peak=${True}   4G_check=${False}
    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
    [Teardown]    SISO Coam Test Teardown

#[1]CB008997-SR_50_General_SiSo_E2E_system_setup_with_data_transfer_conducted_16DL-8UL_basic_call
#    [Tags]   CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${True}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
#    [Teardown]    SISO Coam Test Teardown
