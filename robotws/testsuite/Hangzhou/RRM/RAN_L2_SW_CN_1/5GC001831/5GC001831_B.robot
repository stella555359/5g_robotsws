*** Settings ***
Documentation    ...
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Resource    ./resources/5GC001831_resource.robot
#Library      ./../python/ta_kiss_gnb/    WITH NAME    ta_kiss_gnb
#Suite Setup       Run Keywords    Common Suite Setup
#...               AND    Setup TL for 1831    ${1831_SCF}    ${IPHY_4CC}    ${WTS_CFG}
#Test Setup       Common Test Setup
#Test Teardown    Common Test Teardown
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD    SBTS00    CN1_SQ
#...                RAN_5G    RAN_5G_TDD    CRT
#*** Variables ***
#${UE_ID}               11
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${Egatelog_path}    ${CURDIR}
#${LOCAL_IPHY_DIR}    ${CURDIR}/config
#${LOCAL_WTS_DIR}    ${CURDIR}/config
#${WTS_DIR}    /opt/iphy/latest
#${SCF_DIR}    ${CURDIR}/config
#${1831_SCF}    SCF_1831_mcs.xml
#${WTS_CFG}    basic_setup_1831.cfg
#${IPHY_4CC}    iphy_1831.xml
#${gnb_swconfig}    ${CURDIR}/config/swconfig_gnb.txt
#${ap_swconfig}    ${CURDIR}/config/swconfig_ap.txt
#${file_name}    ${CURDIR}/test_pmcounter
#
#*** Test Cases ***
#5GC001831-ET-B001 Verify CA_UL_Data_Trans_Single_CA_UE_With_2CC_In_mmW_Band
#    [Tags]    Owner_dguan
#    Attach NSA UE with cqi    ${UE_ID}
#    NSA Start UL Traffic    ue_id=${UE_ID}    bearer_id=2    trf_id=1    mbps=175
#    Capture And Decode TTitrace
#    Verify Tbsize On 2Cells UL As Expected
#    NSA LTE Detach    ${UE_ID}
#
#5GC001831-ET-B012 Verify bufferBased_sCellActivationMethod_1UE_ULandDLtrafficIncrease_4CCsgNB_mmW
#    [Tags]    Owner_dguan
#    Attach NSA UE with cqi    ${UE_ID}
#    Start NSA DL Big Traffic Internal    ue_id=${UE_ID}    mbps=700
#    NSA Start UL Traffic    ue_id=${UE_ID}    bearer_id=2    trf_id=1    mbps=175
#    Check Scell Active Status    cell_nums=4    scell_active_status=activated
#    NSA Stop Traffic    ${UE_ID}    ${BEARER_ID}    ul
#    NSA Stop Traffic    ${UE_ID}    ${BEARER_ID}    dl    1-4
#    Sleep    5S    wait traffic stable
#    Check Scell Active Status    cell_nums=4    scell_active_status=deactivated
#    NSA LTE Detach    ${UE_ID}
#
#5GC001831-ET-B013 Verify bufferBased_sCellActivationMethod_1UE_ULtrafficDecrease_4CCsgNB_mmW
#    [Tags]    Owner_dguan
#    Attach NSA UE with cqi    ${UE_ID}
#    NSA Start UL Traffic    ue_id=${UE_ID}    bearer_id=2    trf_id=1    mbps=175
#    Check Scell Active Status    cell_nums=2    scell_active_status=activated
#    NSA Stop Traffic    ${UE_ID}    ${BEARER_ID}    ul
#    Check Scell Active Status    cell_nums=2    scell_active_status=deactivated
#    NSA LTE Detach    ${UE_ID}
#
#5GC001831-ET-B019 Verify PM counters_SCELL_DEACT_CHANNEL_STATE
#    [Tags]    Owner_dguan
#    Attach NSA UE with cqi    ${UE_ID}
#    Start NSA DL Big Traffic Internal    ue_id=${UE_ID}    mbps=700
#    NSA Start UL Traffic    ue_id=${UE_ID}    bearer_id=2    trf_id=1    mbps=175
#    Set Value For BLER Testmode
#    Send Action To GNB    ue_id=11    testmode=bler    action=activate    profile_id=30    scell=1-4
#    Check PM counter M55316C09002 SCELL_DEACT_CHANNEL_STATE
#
#*** Keywords ***
#Common Test Setup
#    Create Test Directory
#
#Common Test Teardown
#    Run Keyword And Ignore Error    NSA LTE Detach    ${UE_ID}
#
