*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           #SISO Coam Test Setup
Test Teardown        #SISO Coam Test Teardown
Test Timeout         120 min

Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource             ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource             ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot

Resource             testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/resource/resources_l3call.robot
Resource             testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008952_SG05/resource/resource.robot

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature 'CB012532 FR1 TDD Habrok 32/64 with eCPRI 7-2 enhanced FH' in SBTS25R3 program phase
...    which testing in HAZ4 5 including sub-features:
...    CB012532-A '64TRX RU AVQL/AVQE/AVQG/AVQQB' in Release 25R3
...    Configuration:
...    ClassicalBTS; TDD; ABIP/ASOG; SingleRAT; AVQE (64TRX RU AVQL/AVQE/AVQG/AVQQB)

Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all

*** Test Cases ***
# PC and UE to be updated
[1]CB012532-SR-A-A1_010_16RX_IRC_SB_BF_Based_DL_SU-MIMO
    [Tags]    SBTS00    1S-4CC-16D4U_16Rx_CB012532-A
    [Setup]    SISO Coam Test Setup
#    General_SiSo_RF_module_reset_from_GUI    with_call=${False}
    ${cell_list}    create list    ${1}
    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
    ...    cell_list=${cell_list}    with_peak=${False}   4G_check=${False}
    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    SISO Coam Test Teardown
