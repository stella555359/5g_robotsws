*** Settings ***
Documentation    ...
#Documentation     Author :
#...               Squad group : SG_09
#...               Feature : 5GC002063
#Resource          5GC002063_common_keywords.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#
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
#5GC002063-ET-A014-Verify Data transmission in shared cell with 10MHZ and UDP with sharing ratio 50 percent
#    [Tags]    Owner_lilid    case_A014    CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
#    Verify Coam Site Is Ready
#    Log To Console   ${ASP_BOARD_TYPE}
#    #Run Keyword If    '${ASP_BOARD_TYPE}'=='ABIL'
#    #...    Configure Gnb    ${JSON_PATH}/${DELTA_PATH_10M}
#    #...    ELSE
#    #...    Configure Gnb    ${JSON_PATH}/BO/${DELTA_PATH_10M}
#    Configure Gnb    ${JSON_PATH}/${DELTA_PATH_10M}
#    Reboot TL And Check Configured
#    Start UTE WTS FOR DSS
#    Set Suite Variable    ${WTS_CFG}    ${WTS_CFG_10M}
#    Log To Console    ${WTS_CFG}
#    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    Load Cfg File    ${WTS_CFG}
#    Setup XP    ${ALLOC_SUBFRAME_10M_20M_50_50}    1,50    30    70    30    70
#    Setup SA L3 Call
#    SA Stop DLUL Traffic
#    Check SA Traffic    ${SA_DL_10M}    ${SA_UL}
#    [Teardown]    Recover TL
#
#5GC002063-ET-A016-Verify Data transmission in shared cell with 15MHZ and TCP with sharing ratio 50 percent
#    [Tags]    Owner_HaiYan    case_A016    CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
#    Verify Coam Site Is Ready
#    #Run Keyword If    '${ASP_BOARD_TYPE}'=='ABIL'
#    #...    Configure Gnb    ${JSON_PATH}/${DELTA_PATH_15M}
#    #...    ELSE
#    #...    Configure Gnb    ${JSON_PATH}/BO/${DELTA_PATH_15M}
#    Configure Gnb    ${JSON_PATH}/${DELTA_PATH_15M}
#    Reboot TL And Check Configured
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
#5GC002063-ET-A017-Verify Data transmission in shared cell with 20MHZ and UDP with sharing ratio 50 percent
#    [Tags]    Owner_susie    case_A017    CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
#    Verify Coam Site Is Ready
#    #Run Keyword If    '${ASP_BOARD_TYPE}'=='ABIL'
#    #...    Configure Gnb    ${JSON_PATH}/${DELTA_PATH_20M}
#    #...    ELSE
#    #...    Configure Gnb    ${JSON_PATH}/BO/${DELTA_PATH_20M}
#    Configure Gnb    ${JSON_PATH}/${DELTA_PATH_20M}
#    Reboot TL And Check Configured
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
#
#5GC002063-ET-A018-Verify Multiple UEs in shared cell with sharing ratio 50 percent
#    [Tags]    Owner_susie    case_A018    P1_REG    AP_REG
#    Verify Coam Site Is Ready
#    Configure Gnb    ${JSON_PATH}/${DELTA_PATH_10M}
#    Verify Coam Site Is Ready
#    Deploy MultiUE SCRIPT
#    Start UTE WTS FOR DSS
#    Set Suite Variable    ${WTS_CFG}    ${WTS_CFG_10M}
#    Log To Console    ${WTS_CFG}
#    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    Load Cfg File    ${WTS_CFG}
#    Setup XP    ${ALLOC_SUBFRAME_10M_20M_50_50}    3,46    30    70    30    70
#    Sleep    90s    reason=wait for process completed
#    Log To Console   please start log
#    Start Ttitrace With Streaming Mode
#    SA Attach And Traffic For MultiUE    3
#    Log To Console    please stop log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/
#    :FOR    ${id}    IN RANGE    1    4
#    \    SA Check Average Traffic Bigger Than Target For Multi UE    dl    ${MULTI_DL_10M}    ${id}
#    \    SA Check Average Traffic Bigger Than Target For Multi UE    ul    ${SA_UL}    ${id}
#    #Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/
#    [Teardown]    Recover TL
#
#5GC002063-ET-A022-Verify Interaction with PRB blanking with 20MHz and sharing ratio 50 percent
#    [Tags]    Owner_Abby    case_A022    P1_REG    AP_REG
#    Verify Coam Site Is Ready
#    Config TL And Start Egate    ${JSON_PATH}/${DELTA_PATH_20M_PRB}    ${WTS_CFG_20M}
#    Setup XP    ${ALLOC_SUBFRAME_15M_50_50}    12,50    30    70    30    70
#    SA Register UE    ${UE_ID}    ${PROFILE_ID}
#    Verify UE RRC Connection Release
#    Teardown All Connections
#    Log To Console    SA Traffic...
#    Sleep    60s    reason=wait for process completed
#    SA Start DLUL Traffic    5    5    30
#    Log To Console    Start BIP...
#    Start Gnb BIP Log    10
#    Sleep    60s    reason=wait for BIP file completed
#    SA Stop DLUL Traffic
#    Collect And Convert GNB BIP    ${OUTPUT_DIR}/A022
#    Check PRB Enable 20M Bip Log    ${OUTPUT_DIR}/A022/coreset.csv
#    [Teardown]    Recover TL
#
#5GC002063-ET-A023-Verify Interaction with PRB blanking with 15MHz and minimum sharing ratio
#    [Tags]    Owner_Abby    case_A023    P2_REG    AP_REG
#    Verify Coam Site Is Ready
#    Config TL And Start Egate    ${JSON_PATH}/${DELTA_PATH_15M_PRB}    ${WTS_CFG_15M}
#    Setup XP    ${ALLOC_SUBFRAME_15M_50_50}    6,50    30    70    30    70
#    SA Register UE    ${UE_ID}    ${PROFILE_ID}
#    Verify UE RRC Connection Release
#    Teardown All Connections
#    Log To Console    SA Traffic...
#    Sleep    60s    reason=wait for process completed
#    SA Start DLUL Traffic    5    5    30
#    Log To Console    Start BIP...
#    Start Gnb BIP Log    10
#    Sleep    60s    reason=wait for BIP file completed
#    SA Stop DLUL Traffic
#    Collect And Convert GNB BIP    ${OUTPUT_DIR}/A023
#    Check PRB Enable 15M Bip Log    ${OUTPUT_DIR}/A023/coreset.csv
#    [Teardown]    Recover TL
#
#5GC002063-ET-A026-Verify IWK2 First UE entering shared cell
#    [Tags]    Owner_susie    case_A026
#    Verify Coam Site Is Ready
#    Configure Gnb    ${JSON_PATH}/${DELTA_PATH_10M}
#    Verify Coam Site Is Ready
#    Online Configure Srb And Drb InactivityTimer
#    Start UTE WTS FOR DSS
#    Set Suite Variable    ${WTS_CFG}    ${WTS_CFG_10M}
#    Log To Console    ${WTS_CFG}
#    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    Load Cfg File    ${WTS_CFG}
#    Setup XP    ${ALLOC_SUBFRAME_10M_20M_50_50}    1,50    30    70    30    70
#    SA Register UE    ${UE_ID}    ${PROFILE_ID}
#    Verify UE RRC Connection Release
#    Log To Console    SA Traffic...
#    Sleep    60s    reason=wait for process completed
#    SA Start TCP DLUL Traffic    5    5    10
#    SA Stop DLUL Traffic
#    Check SA TCP Traffic
#    [Teardown]    Recover TL
#
#5GC002063-ET-A028-Verify IWK4 Admission control in shared cell
#    [Tags]    Owner_lilid    case_A028
#    Verify Coam Site Is Ready
#    Configure Gnb    ${JSON_PATH}/${DELTA_PATH_10M}
#    Verify Coam Site Is Ready
#    Start UTE WTS FOR DSS
#    Set Suite Variable    ${WTS_CFG}    ${WTS_CFG_10M_NORATEMATCH}
#    Log To Console    ${WTS_CFG}
#    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    Load Cfg File    ${WTS_CFG}
#    Setup XP    ${ALLOC_SUBFRAME_10M_20M_50_50}    1,50    30    70    30    70
#    SA Register UE    ${UE_ID}    ${PROFILE_ID}
#    Verify RRC Release For TC A28
#    [Teardown]    Recover TL
#
#5GC002063-ET-A029-Verify IWK5 Interaction with CMAS with 20MHZ with sharing ratio 50 percent
#    [Tags]    Owner_Abby    case_A029
#    Verify Coam Site Is Ready
#    Configure Gnb    ${JSON_PATH}/${DELTA_PATH_20M}
#    Verify Coam Site Is Ready
#    Online Active CMAS
#    Start UTE WTS FOR DSS
#    Set Suite Variable    ${WTS_CFG}    ${WTS_CFG_20M}
#    Log To Console    ${WTS_CFG}
#    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    Load Cfg File    ${WTS_CFG}
#    Setup XP    ${ALLOC_SUBFRAME_10M_20M_50_50}    1,50    30    70    30    70
#    CMAS Broadcast And Analysis    "attention"
#    [Teardown]    Recover TL
#
#5GC002063-ET-A021-Verify inter-gnb handover among shared and another shared cell with minimum sharing ratio
#    [Tags]    Owner_Hailiu    case_A021    P1_REG    AP_REG
#    Verify Coam Site Is Ready
#    Configure Gnb    ${JSON_PATH}/${DELTA_PATH_10M_INTERHO}
#    Verify Coam Site Is Ready
#    Configure IP For InterHO
#    Start UTE WTS FOR DSS
#    Setup WTS Config For InterHO
#    Setup XP    ${ALLOC_SUBFRAME_10M_20M_50_50}    1,50    30    70    30    70
#    Set Parameter For Trigger Hanover By A3 Event Should Success
#    Setup SA L3 Call For InterHO
#    Trigger A3 Rsrp Measurement From Real To Sim
#    Trigger A3 Rsrp Measurement From Sim To Real
#    SA Stop DLUL Traffic
#    Check SA Traffic    ${SA_DL_HO}    ${SA_UL_HO}
#    Delete InterHO IP
#    [Teardown]    Recover TL
#
#5GC002063-ET-A027-Verify IWK3 First UE entering shared cell via HO
#    [Tags]    Owner_Hailiu    case_A027    P2_REG    AP_REG
#    Verify Coam Site Is Ready
#    Configure Gnb    ${JSON_PATH}/${DELTA_PATH_10M_INTERHO27}
#    Verify Coam Site Is Ready
#    Configure IP For InterHO
#    Start UTE WTS FOR DSS
#    Setup WTS Config For InterHO
#    Setup XP    ${ALLOC_SUBFRAME_10M_20M_50_50}    1,50    30    70    30    70
#    Set Parameter For Trigger Hanover By A3 Event Should Success
#    Setup SA L3 Call For InterHO
#    Trigger A3 Rsrp Measurement From Real To Sim
#    Trigger A3 Rsrp Measurement From Sim To Real
#    SA Stop DLUL Traffic
#    Check SA Traffic    ${SA_DL_HO}    ${SA_UL_HO}
#    Delete InterHO IP
#    [Teardown]    Recover TL
#
#5GC002063-ET-A024-Verify IWK1 Shared cell in concurrent mode with sharing ratio 50 percent
#    [Tags]    Owner_susie    case_A024    P2_REG    AP_REG
#    Verify Coam Site Is Ready
#    #Modify Delta File
#    Configure Gnb    ${JSON_PATH}/${DELTA_PATH_10M}
#    Verify Coam Site Is Ready
#    Start UTE WTS FOR DSS
#    Set Suite Variable    ${WTS_CFG}    ${WTS_CFG_10M_CONDUCT}
#    Log To Console    ${WTS_CFG}
#    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    Load Cfg File    ${WTS_CFG}
#    Setup XP    ${ALLOC_SUBFRAME_10M_20M_50_50}    1,50    30    70    30    70
#    Setup SA L3 Call
#    SA Stop DLUL Traffic
#    Check SA Traffic    ${SA_DL_10M}    ${SA_UL}
#    Setup NSA L3 Call For Concurrent Mode
#    [Teardown]    Recover TL2
#
#
#
