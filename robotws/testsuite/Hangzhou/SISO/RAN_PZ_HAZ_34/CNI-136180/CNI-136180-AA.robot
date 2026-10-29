*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup
Test Teardown
Test Timeout         120 min

Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource             ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource             ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
#Resource             testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/resource/resources_l3call.robot
#Resource             testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008952_SG05/resource/resource.robot

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CNI-136180 RF6.2 32/64TRX mMIMO SRS support on UL subframe SW knife productization

Force Tags     SBTS00    PY310   master_classicalbts_all

*** Test Cases ***
# PC and UE to be updated
[1]CNI136180_07_tput_verify_with_concurrent_mode_64TRX
    [Tags]    1S-2CC_LTETDD-NRTDD_CNI-136180-AA    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${False}

##   UE not ready
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${False}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown
