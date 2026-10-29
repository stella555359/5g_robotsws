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
...    Feature 'CB009843 NR FR1 TDD eCPRI 7-2e BB cell set 16DL ABIP 12 ABIQ 6 cells' in LL program phase
...    which testing in HAZ4 5 including sub-features:
...    CB009843-B 'Commercial BB cell set for 3 cells up to 8DL/4UL on half ABIQ' in Release 25R3
...    CB009843-D 'Internal BB cell set for 3 cells up to 16DL/4UL on half ABIP' in Release 25R2
...    CB009843-G 'Commercial BB cell set for 3 cells up to 8DL/8UL on half ABIQ' in Release 26R1
...    Configuration:
...    ClassicalBTS; TDD; ABIP/ABIQ; SingleRAT; 3*AVQC

Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all

*** Test Cases ***
# PC and UE to be updated
[1]CB009843-B4-09_General_SiSo_RU_module_reset_from_GUI
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_RF_module_reset_from_GUI    with_call=${False}
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${False}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    SISO Coam Test Teardown

#[1]CB009843-B5-01_General_SiSo_Cell_block_and_unblock
#    [Tags]    SBTS00
#    [Setup]    SISO Coam Test Setup
#    General_SiSo_Cell_block_and_unblock    with_call=${False}
#    [Teardown]    SISO Coam Test Teardown
#
#[1]CB009843-B4-03_Manual_SiSo_SM_BTS_Site_Reset
#    [Tags]    SBTS00
#    [Setup]    SISO Coam Test Setup
#    General_SiSo_Auto_BTS_site_reset    with_call=${False}
#    [Teardown]    SISO Coam Test Teardown
