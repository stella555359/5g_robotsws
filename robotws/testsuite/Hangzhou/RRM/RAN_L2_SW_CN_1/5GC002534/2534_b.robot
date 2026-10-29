*** Settings ***
Documentation    ...
#Documentation     Author :
#...               Squad group :
#...               Feature : 5GC002534
#Resource          ./../5GC002063/5GC002063_common_keywords.robot
#
#Suite Setup       Run Keywords
#...               Suite Setup Update GNB
#...               Prepare Test Env
#Test Setup        Common Test Setup 2
#Suite Teardown    Run Keywords
#...        Recover TL Configuration
#
#Force Tags            SBTS00    SBTS23R1    SBTS22R4    5GC002534    CRT    RAN_5G    RAN_5G_FDD
#...                   CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD
#
#
#*** Variables ***
#${dist_name}           MRBTS-1/NRBTS-1/NRCELL-1
#${parameter}           actPdschAtSsbSlots
#${value}               true
#
#
#*** Test Cases ***
#5GC002534_B_01_PDSCH_Traffic_At_SSB_Slot_In_DSS_Case_15MHz_No_PRB_Blanking_Share_Ratio_50
#    [Tags]
#    Verify Coam Site Is Ready
#    Configure Gnb    ${JSON_PATH}/${DELTA_PATH_15M}
#    Verify Coam Site Is Ready
#    Online Change One Para With Admin    ${dist_name}    ${parameter}    ${value}
#    Start UTE WTS FOR DSS
#    Set Suite Variable    ${WTS_CFG}    ${WTS_CFG_15M}
#    Log To Console    ${WTS_CFG}
#    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    Load Cfg File    ${WTS_CFG}
#    Setup XP    ${ALLOC_SUBFRAME_15M_50_50}    1,50    30    70    30    70
#    Setup SA L3 Call For TCP Traffic
#    SA Stop DLUL Traffic
#    Check SA TCP Traffic
#    [Teardown]    Recover TL
#
#
#
#5GC002534_A012_PDSCH_at_SSBslot_multiple_users_capacity_verification_10MHz
#    [Tags]
#    Verify Coam Site Is Ready
#    Configure Gnb    ${JSON_PATH}/${DELTA_PATH_10M}
#    Verify Coam Site Is Ready
#    Online Change One Para With Admin    ${dist_name}    ${parameter}    ${value}
#    Deploy MultiUE SCRIPT
#    Start UTE WTS FOR DSS
#    Set Suite Variable    ${WTS_CFG}    ${WTS_CFG_10M}
#    Log To Console    ${WTS_CFG}
#    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    Load Cfg File    ${WTS_CFG}
#    Setup XP    ${ALLOC_SUBFRAME_10M_20M_50_50}    1,50    30    70    30    70
#    Sleep    90s    reason=wait for process completed
#    SA Attach And Traffic For MultiUE    3
#    :FOR    ${id}    IN RANGE    1    4
#    \    SA Check Average Traffic Bigger Than Target For Multi UE    dl    ${MULTI_DL_10M}    ${id}
#    \    SA Check Average Traffic Bigger Than Target For Multi UE    ul    ${SA_UL}    ${id}
#    [Teardown]    Recover TL
#
#5GC002534_B_04_PDSCH_Traffic_At_SSB_Slot_In_DSS_Case_20MHz_With_3PRB_Blanking_Share_Ratio_50
#    [Tags]
#    Verify Coam Site Is Ready
#    Configure Gnb    ${JSON_PATH}/${DELTA_PATH_20M}
#    Verify Coam Site Is Ready
#    Online Change One Para With Admin    ${dist_name}    ${parameter}    ${value}
#    Start UTE WTS FOR DSS
#    Set Suite Variable    ${WTS_CFG}    ${WTS_CFG_20M}
#    Log To Console    ${WTS_CFG}
#    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    Load Cfg File    ${WTS_CFG}
#    Setup XP    ${ALLOC_SUBFRAME_10M_20M_50_50}    1,50    30    70    30    70
#    Setup SA L3 Call
#    SA Stop DLUL Traffic
#    Check SA Traffic    ${SA_DL_20M}    ${SA_UL}
#    [Teardown]    Recover TL
