*** Settings ***
Resource          ../common_aic_setup_teardown.robot
Force Tags        CONFIGS_7_5_UTE5GAIC015/test_config.yaml
Suite Setup       Run Keywords    Common Suite Setup
Suite Teardown    Common Suite Teardown    debug
Test Setup        Create Test Directory
Test Teardown     Common Test Teardown    debug

*** Variables ***
${LOCAL_WTS_DIR}    ${CURDIR}/config
${WTS_CFG}          basic_setup_hz.cfg
${ENB_ID}           1
${GNB_ID}           2
${UE_ID}            1

*** Test Cases ***
Capture TTiTrace Log
    # Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    # Start WTS And Check OnAir
    # SA Set Traffic Type To Internal    ${UE_ID}
    # SA 5G Attach    ${UE_ID}
    # SA 5G PDU Session Setup    ${UE_ID}
    # SA Start DL Traffic Internal    ue_id=${UE_ID}    mbps=50
    # SA Start UL Traffic Internal    ue_id=${UE_ID}    mbps=5
    # Sleep    20s
    # ${dl_tpt}    SA Get UE Average Traffic Internal    ${ue_id}    dl
    # ${ul_tpt}    SA Get UE Average Traffic Internal    ${ue_id}    ul
    ${trace_id}    Start TTiTrace Log
    Sleep    2s
    Stop TTiTrace Log    ${trace_id}
    Decode TTiTrace Log


