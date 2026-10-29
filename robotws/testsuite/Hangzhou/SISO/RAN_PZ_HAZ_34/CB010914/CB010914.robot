*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           #SISO Coam Test Setup
Test Teardown        #SISO Coam Test Teardown
Test Timeout         300 min

Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource             ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource             ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
#Resource             ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource             ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource             ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
Resource             testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/resource/resources_l3call.robot
Resource             testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008952_SG05/resource/resource.robot

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB010914 FR1 TDD configs eCPRI for ABIP/ABIQ #3 in 24R3 program phase which including sub-features:
...        CB010914-SR-A: ABIP/ABIQ NR FR1 TDD eCPRI configuration block with 50GE link rate and up to 2cc per radio
...        CB010914-SR-B: ABIP/ABIQ NR FR1 TDD eCPRI configuration block with 50GE link rate and up to 4cc per radio
...    Configuration: This feature introduces configurations using 50Gbps link rate for RF7.1 MAA on ABIP/ABIQ.

Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY39    master_classicalbts_all

*** Test Cases ***
# PC and UE to be updated
[1]CB010914-SR_General_SiSo_Cell_block_and_unblock
    [Tags]    3S-2CC-8D8U_CB010914_3    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    #General_SiSo_Cell_block_and_unblock    with_call=${False}
    ${fault_list}    Create List    49    7319    7300
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${False}
    #WA for tl692-NSA as 9 enbs used; FID:7319 No X2 link available for a specific LTEENB
    [Teardown]    Run Keywords    add fault to the allowed fault list    faultId=${7319}    AND
    ...           add fault to the allowed fault list    faultId=${7300}    AND
    ...           add fault to allowed history fault list    faultId=${7319}    AND
    ...           add fault to allowed history fault list    faultId=${7300}    AND
    ...           SISO Coam Test Teardown

[1]CB010914-SR_General_SiSo_RU_lock_unlock
    [Tags]    2S-3CC-16D8U-8D8U_CB010914_6    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${False}
    #WA for tl692-NSA as 9 enbs used; FID:7319 No X2 link available for a specific LTEENB
    [Teardown]    Run Keywords    add fault to the allowed fault list    faultId=${7319}    AND
    ...           add fault to the allowed fault list    faultId=${7300}    AND
    ...           add fault to allowed history fault list    faultId=${7319}    AND
    ...           add fault to allowed history fault list    faultId=${7300}    AND
    ...           SISO Coam Test Teardown

[1]CB010914-SR_Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    3S-4CC-8D8U-8D4U_CB010914_5    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_Auto_BTS_site_reset    with_call=${False}
    #WA for tl692-NSA as 9 enbs used; FID:7319 No X2 link available for a specific LTEENB
    [Teardown]    Run Keywords    add fault to the allowed fault list    faultId=${7319}    AND
    ...           add fault to the allowed fault list    faultId=${7300}    AND
    ...           add fault to allowed history fault list    faultId=${7319}    AND
    ...           add fault to allowed history fault list    faultId=${7300}    AND
    ...           SISO Coam Test Teardown

#[1]CB008997-SR_48_General_SiSo_E2E_system_setup_with_data_transfer_conducted_100M+100M_peak_tput
#    [Tags]    1S-2CC-8D4U_A5_100-100M_C2-191_TA-3000    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${True}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
#    [Teardown]    SISO Coam Test Teardown
