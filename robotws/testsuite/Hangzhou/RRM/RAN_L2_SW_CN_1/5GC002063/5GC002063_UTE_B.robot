*** Settings ***
Documentation    ...
#Documentation     Author :
#...               Squad group : SG_09
#...               Feature : 5GC002063
#Resource          5GC002063_common_keywords.robot
#Suite Setup       Run Keywords
#...               Check TL Type And Suite Setup
#...               Prepare Test Env
#Test Setup    Common Test Setup 2
#Suite Teardown           Run Keywords
#...        Recover TL Configuration
#
#Force Tags        Classical    IPV4    FR1    PRI-High    SBTS00    SBTS23R1
#...               5GC002063    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
#...               RAN_5G    RAN_5G_FDD    CN1_SQ    CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD
#
#*** Variables ***
#
#*** Test Cases ***
#5GC002063-ET-B003-Verify increased UL grants with 20Mhz
#    [Tags]    Owner_Susie    case_B003
#    Verify Coam Site Is Ready
#    Configure Gnb    ${JSON_PATH}/${DELTA_PATH_20M}
#    Verify Coam Site Is Ready
#    Online Configure Srb And Drb InactivityTimer
#    Deploy MultiUE SCRIPT
#    Start UTE WTS FOR DSS
#    Set Suite Variable    ${WTS_CFG}    ${WTS_CFG_20M}
#    Log To Console    ${WTS_CFG}
#    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    Load Cfg File    ${WTS_CFG}
#    Setup XP    ${ALLOC_SUBFRAME_10M_20M_50_50}    1,50    30    70    30    70
#    Sleep    90s    reason=wait for process completed
#    SA Attach Release And Traffic For MultiUE    2
#    :FOR    ${id}    IN RANGE    1    3
#    \    SA Check Average Traffic Bigger Than Target For Multi UE    dl    ${MULTI_DL_20M}    ${id}
#    \    SA Check Average Traffic Bigger Than Target For Multi UE    ul    ${SA_UL}    ${id}
#    [Teardown]    Recover TL
#
#5GC002063-ET-B004-Verify increased UL grants with 15Mhz with 2 dssDlDcis
#    [Tags]    Owner_Abby    case_B004
#    Verify Coam Site Is Ready
#    Deploy MultiUE SCRIPT
#    Config TL And Start Egate    ${JSON_PATH}/${DELTA_PATH_15M_B004}    ${WTS_CFG_15M}
#    Setup XP    ${ALLOC_SUBFRAME_15M_50_50}    1,50    30    70    30    70
#    Start Multiue Register
#    Log To Console    Multi UE Register Start...
#    Teardown All Connections
#    SA Start Multi DLUL Traffic
#    Log To Console    Start Bip...
#    Start Gnb BIP Log    10
#    Sleep    60s    reason=wait for BIP file completed
#    Collect And Convert GNB BIP    ${OUTPUT_DIR}/B004
#    Check 15M Bip Log    ${OUTPUT_DIR}/B004/coreset.csv
#
#    [Teardown]    Recover TL
#
#5GC002063-ET-B005-Verify increased UL grants with 10Mhz with 2 dssDlDcis
#    [Tags]    Owner_Abby    case_B005
#    Verify Coam Site Is Ready
#    Deploy MultiUE SCRIPT
#    Config TL And Start Egate    ${JSON_PATH}/${DELTA_PATH_10M_B005}    ${WTS_CFG_10M}
#    Setup XP    ${ALLOC_SUBFRAME_10M_20M_50_50}    1,50    30    70    30    70
#    Start Multiue Register
#    Log To Console    Multi UE Register Start...
#    Teardown All Connections
#    SA Start Multi DLUL Traffic
#    Log To Console    Start Bip...
#    Start Gnb BIP Log    20
#    Sleep    60s    reason=wait for BIP file completed
#    Collect And Convert GNB BIP    ${OUTPUT_DIR}/B005
#    Check 10M Bip Log    ${OUTPUT_DIR}/B005/coreset.csv
#    [Teardown]    Recover TL
#
#*** Keywords ***
