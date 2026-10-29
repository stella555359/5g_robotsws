*** Settings ***
Documentation
...  author:  Dawid Chuchnowski, dawid.chuchnowski@nokia.com
...  maintainer:  Dawid Chuchnowski, dawid.chuchnowski@nokia.com

Library     DateTime
Library     OperatingSystem
Library     ute_fsmaccess
Library     ta5g_iphy
Library     ta5g_testline_management
Library     ute_syslog
Library     ute_wtssim
Library     ./resources/CNI140840_keywords.py
Library     ./resources/CNI140840_syslog_verification.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../resources/former_l2_sw1/robot/collectors.robot
Resource    ../resources/former_l2_sw1/robot/ssh.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup    Run keywords
...       Modify AP Swconfig
...       AND    Prepare Test Environment


*** Variables ***
${LUA_CFG_FILE}=   ${WTS_DIR}/basic_setup.cfg
${WTS_DIR} =    /opt/wts/latest
@{AP_noise_RaD_param}=    0x70687=-157 #ERadParam_UlCellIdleThermalNoise
@{ADDITIONAL_ALLOWED_ALARMS}=    4334       #Serial console activated
*** Test Cases ***
CNI140840_01_Fake_UEs_invalid_UL_measurements_error_logging_verification_FR1_TDD+FDD
    [Setup]    Common Preconditions
    Start collecting GNB syslog
    Start TTI trace
    Stop TTI trace    delay=5
    Sleep    120s    Reason=Log collecting
    Stop collecting GNB syslog
    Convert TTI trace pcap
    Verify that only invalid measurements are reported
    ...    csv_file_path=${OUTPUT_DIR}/${TEST NAME}/output_ul.csv
    ...    num_of_cells=4
    Verify invalid antenna RSSI and noise values error messages in syslog
    ...    num_of_cells=4
    ...    consecutive_occurrences=10
    [Teardown]    Common Postconditions

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

Start collecting GNB syslog
    Log action to console    Starting GNB Syslog Collection
    ute_syslog.Start syslog    log_dir=${OUTPUTDIR}/    log_name=GNB_syslog.txt    ip=192.168.255.126    alias=GNB_syslog

Stop collecting GNB syslog
    Log action to console    Stopping GNB Syslog Collection
    ute_syslog.Collect syslog results    alias=GNB_syslog    unzip=True

Modify AP Swconfig
    [Documentation]    Connects to AirPhone via SSH modifies swconfig, performs reboot and waits for radios availability
    Connect using ssh to    AP
    Modify AP swconfig file    parameters_list=@{AP_noise_RaD_param}    connection=AP
    Reboot AP Via Ssh
    Wait for testline ICMP Echo replies and SSH services
    ta5g_iphy.Check radios availability

Reboot AP Via Ssh
    [Documentation]    Connects to AirPhone via SSH and performs reboot
    ssh.connect to
    ...    hostname=${tl.ues[0].l1.common_units[0].lmp_connection.addr}
    ...    username=${tl.ues[0].l1.common_units[0].lmp_connection.username}
    ...    password=${tl.ues[0].l1.common_units[0].lmp_connection.password}
    ...    alias=Airphone
    ssh.send_command    system-module-reboot    connection=Airphone
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=Airphone

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
