*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           
Test Teardown        
Test Timeout         150 min

Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource             ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
#Resource             ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource             ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource             testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/resource/resources_l3call.robot
Resource             testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008952_SG05/resource/resource.robot

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature "CB009182:ABIP/ABIQ LTE FDD/NR TDD concurrent mode (with dedicated FH)" in SBTS24R1 program
...    Configure: A1/2/3/4 for BBMOD:ABIP; B1/2/3/4 for BBMOD:ABIQ

Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY36    master_classicalbts_all

*** Variables ***

*** Test Cases ***
[1]CB009182_General_SiSo_Cell_block_and_unblock_A1
    [Tags]    5S-CB009182-A1_CellSet-9142-A-9015-A    CRT_24R1    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    #General_SiSo_Cell_block_and_unblock   with_call=${False}    with_peak=${False}
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${False}
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${False}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    Run Keywords    add fault to allowed history fault list    faultId=${49}   AND
    ...    SISO Coam Test Teardown
##    [Teardown]    Run Keywords    add fault to the allowed fault list    faultId=${4681}
##    ...    AND    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
##    ...    AND    SISO Coam Test Teardown

[1]CB009182_General_SiSo_Cell_block_and_unblock_B1
    [Tags]    5S-CB009182-B1_CellSet-10553-A-10550-A    CRT_24R1    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    #General_SiSo_Cell_block_and_unblock   with_call=${False}    with_peak=${False}
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${False}
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${False}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    Run Keywords    add fault to allowed history fault list    faultId=${49}   AND
    ...    SISO Coam Test Teardown
##    [Teardown]    Run Keywords    add fault to the allowed fault list    faultId=${4681}
##    ...    AND    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
##    ...    AND    SISO Coam Test Teardown

*** Keywords ***
