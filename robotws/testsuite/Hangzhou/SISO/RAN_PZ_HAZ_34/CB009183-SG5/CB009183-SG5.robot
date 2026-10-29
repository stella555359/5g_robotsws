*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup
Test Teardown
Test Timeout         60 min

Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource             ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource             testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/resource/resources_l3call.robot
Resource             testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008952_SG05/resource/resource.robot

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature "CB009183 ABIP/ABIQ NR FDD/LTE FDD/NR TDD concurrent tri-mode" in SBTS24R2 program

Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all

*** Test Cases ***
[1]CB009183-SR-A_001_L3_call_on_M1-L_configuration_for_tri-mode_LTE_FDD_normal_cell
    [Tags]    5S-CB009183-A_BBCellSet-M1-L    CRT_24R2    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    log    To be updated after UE prepared.
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${False}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB009183-SR-C_001_L3_call_on_M2_configuration_for_tri-mode_LTE_FDD_normal_cell
    [Tags]    5S-CB009183-C_BBCellSet-M2    CRT_24R2    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    log    To be updated after UE prepared.
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${False}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown
