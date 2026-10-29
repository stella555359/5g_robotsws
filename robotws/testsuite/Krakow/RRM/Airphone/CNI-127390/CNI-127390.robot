*** Settings ***
Documentation
...  author:  Dawid Chuchnowski, dawid.chuchnowski@nokia.com
...  maintainer:  Dawid Chuchnowski, dawid.chuchnowski@nokia.com

Library     DateTime
Library     ute_wtssim
Library     ./resources/BIP_verification_keywords.py
Library     ../../Airphone/resources/former_l2_sw1/python/traffic_handling.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../../Airphone/resources/former_l2_sw1/robot/collectors.robot
Resource    ../../Airphone/resources/former_l2_sw1/robot/common_keywords.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./resources/delta_commissioning.py

Suite Setup    Prepare Test Environment

*** Variables ***
${LUA_CFG_FILE}=   ${CURDIR}/config/basic_setup.cfg
${WTS_DIR} =    /opt/wts/latest
${GNB_IP}=    192.168.255.129
@{BIP_columns}=    3gpp.sfn    3gpp.slot    _ws.col.Info
${BIP_filter}=    (dldata_pdcchsendreql1sw || dldata_pdschpayloadtbsendreql1sw || uldata_puschreceiveresplol1sw) && !3gpp.rnti==65535
@{ADDITIONAL_ALLOWED_ALARMS}=    4334       #Serial console activated
*** Test Cases ***
CNI_127390-D_RRC_message_processing_delay_interaction_with_CB012734
    [Setup]    Run keywords
    ...    Common Preconditions
    ...    AND    Perform delta recommissioning
    Start collecting BIP logs
    Register UE    UE_ID=1    CELL_ID=1
    Set pdu param for internal traffic    UE_ID=1
    Establish PDU session    UE_ID=1
    Start SA traffic  ue=1  dir=dl  traffic_rate=100Mbps
    Start SA traffic  ue=1  dir=ul  traffic_rate=50Mbps
    Deregister UE    UE_ID=1
    Stop collecting BIP logs
    Convert BIP logs pcap to csv
    ...  pcap_path=${OUTPUT_DIR}/${TEST_NAME}/L1L2_BIP_Logs/tcpdump.pcap
    ...  filter=${BIP_filter}
    ...  dir_path=${OUTPUT_DIR}
    ...  csv_log_name=BIP_logs.csv
    ...  columns=@{BIP_columns}
    Verify RRC processing delay for RRC Reconfiguration
    [Teardown]  Common Postconditions

*** Keywords ***
Prepare Test Environment
    [Documentation]    Configures interfaces required for WTS, setups edameon and egate processes, loads wts cfg file
    ...                and establishes x2 link
    Configure UTE ETH3
    Setup Edaemon                  edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
    Start Edaemon Process          alias=edaemon
    Setup Egate                    egate_port=20000    tool_dir=${WTS_DIR}
    Start Egate Process
    Execute Egate Command          cfg file\=${LUA_CFG_FILE}
    Wait Until Keyword Succeeds    60sec    15sec
    ...                            Execute Egate Command    state_sim_disp    pass_regexp=The state is ACTIVE
    Execute Egate Command          cmd=enb_x2_link_up enb=1 target=2

Perform delta recommissioning
    [Documentation]    Creates and activates delta commissioning of actRrcReconfProcessingDelay (FAF for CNI-127390)
    ...    and actHighNumberOfUEs (FAF for CB012734)
    Log Action To Console    Activate CNI-127390 and CB012734 on NRCELL-1
    Perform Delta Commissioning On gNB    delta=${FAFs_activation}

Configure UTE ETH3
    [Documentation]    Configures interfaces required for WTS
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.99/24 dev eth3
    Run    sudo ip addr add 10.0.1.121/24 dev eth3

Log Action To Console
    [Arguments]   ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${False}
    [Documentation]    Logs message to console
    ...                :param msg:     message logged
    ...                :datatime:    determines if include timestamp in log
    ...                :new_line_before:    determines if include new line before log
    ...                :new_line_after:    determines if include new line after log

    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'   Get Current Date
    Run keyword if    '${datatime}'=='${True}'   Log To Console    --> [${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'   Log To Console    --> ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}
