*** Settings ***
Documentation     vdu
#Resource          ../common_aic_setup_teardown.robot
#Force Tags        CONFIGS_7_5_UTE5GAIC015/test_config.yaml
#Suite Setup       Run Keywords    Common Suite Setup
#...               AND    Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#Suite Teardown    Common Suite Teardown    debug
#Test Setup        Create Test Directory
#Test Teardown     Common Test Teardown    debug
#
#*** Variables ***
#${CONFIG_FILE_PATH}    ${CURDIR}/config
#${VCU_SCFC_FILE}       vcu_scfc.xml
#${VDU_SCFC_FILE}       vdu_scfc.xml
#${GNB_INDEX}           0
#${IPHY_FILE}           ${CURDIR}/config/iphy.xml
#${LOCAL_WTS_DIR}       ${CURDIR}/config
#${WTS_CFG}             basic_setup_hz.cfg
#${ENB_ID}              1
#${GNB_ID}              2
#${SA_UE_ID}            1
#${NSA_UE_ID}           11
#${PROFILE_ID}          1
#${CELL_ID}             1
#${BEARER_ID}           2
#
#*** Test Cases ***
#SA_L3_Call_Template
#    [Setup]    Run Keywords    Create Test Directory
#    ...    AND    Update Aic GNB    IPHY_FILE=${IPHY_FILE}
#    ...           VCU_SCFC_PATH=${CONFIG_FILE_PATH}/${BRANCH}/${VCU_SCFC_FILE}
#    ...           VDU_SCFC_PATH=${CONFIG_FILE_PATH}/${BRANCH}/${VDU_SCFC_FILE}
#    ...    AND    Start WTS And Check OnAir
#    SA Set Traffic Type To Internal    ${SA_UE_ID}
#    SA 5G Attach    ${SA_UE_ID}
#    SA 5G PDU Session Setup    ${SA_UE_ID}
#    SA Start DL Traffic Internal    ue_id=${SA_UE_ID}    mbps=50
#    SA Start UL Traffic Internal    ue_id=${SA_UE_ID}    mbps=5
#    Sleep    20s
#    ${dl_tpt}    SA Get UE Average Traffic Internal    ${SA_UE_ID}    dl
#    ${ul_tpt}    SA Get UE Average Traffic Internal    ${SA_UE_ID}    ul
#    Start BIP Log    L1BIPRT
#    ${trace_id}    Start TTiTrace Log
#    Sleep    2s
#    Stop TTiTrace Log    ${trace_id}
#    Stop BIP Log    L1BIPRT
#    Decode TTiTrace Log
#
#NSA_L3_Call_Template
#    [Setup]    Run Keywords    Create Test Directory
#    ...    AND    Update Aic GNB    IPHY_FILE=${IPHY_FILE}
#    ...           VCU_SCFC_PATH=${CONFIG_FILE_PATH}/${BRANCH}/${VCU_SCFC_FILE}
#    ...           VDU_SCFC_PATH=${CONFIG_FILE_PATH}/${BRANCH}/${VDU_SCFC_FILE}
#    ...    AND    Start WTS And Check OnAir
#    NSA LTE Attach    ${NSA_UE_ID}    ${profile_id}
#    NSA 5G Attach    ${NSA_UE_ID}    ${gnb_id}    ${CELL_ID}    ${bearer_id}
#    NSA Start DL Traffic    ${NSA_UE_ID}    ${bearer_id}    100
#    NSA Start UL Traffic    ${NSA_UE_ID}    ${bearer_id}    5
#    Sleep    6s    reason=wait for traffic stable
#    ${dl_tpt}    NSA Get Average Throughput    ${NSA_UE_ID}    ${bearer_id}    dl
#    ${ul_tpt}    NSA Get Average Throughput    ${NSA_UE_ID}    ${bearer_id}    ul
#    Start BIP Log    L2BIPRT
#    ${trace_id}    Start TTiTrace Log
#    Sleep    2s
#    Stop TTiTrace Log    ${trace_id}
#    Stop BIP Log    L2BIPRT
#    Decode TTiTrace Log