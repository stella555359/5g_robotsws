*** Settings ***
Documentation
...  author: dalwang
...  contact: dali.wang@nokia-sbell.com
Library    ./server.py
Library    String
Library    taf.sbts.oam.coam.admin.admin   WITH NAME   admin_cli
Library    taf.sbts.oam.coam.admin
Library    taf.sbts.oam.coam.admin.interface
Library    Collections
Library    OperatingSystem
Library     ute_syslog
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.tshark  WITH NAME   tshark


Resource    ./btslog_collecting.robot
Resource   ./tshark.robot
Resource    ../../common/taf_coam.robot
Resource    ../../common/gnb.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
*** Variables ***
${path}    /home/ute/tshark
${filename}    tshark.pcap
${ADMIN_ALIAS}=  default



*** Keywords ***
Common Suite Setup
    COAM Try Connect gNB
    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
    ${gnb_release}   Get gnb release
    Wait Until Keyword Succeeds   10m   1m   COAM WEBUI Login
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    COAM Backup SCF
#    Wait Until Keyword Succeeds   3x   30s   Perform sub-feature SCF   feature_name=CB007308
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check All Cells Onair
    Log to Console   Check all cells should be onair result is ${is_cells_onair}
    COAM WEBUI Whether Close Start Up View Window
    Configure Rsyslog Service

Common Suite Teardown
    clear syslogs on server
    Disable remote syslog transmission
    Run Keyword And Ignore Error   COAM Login
#    wait until keyword succeeds     5x    5min   COAM SCF Commission
    Run Keyword And Ignore Error   COAM WEBUI Logout
    Run Keyword And Ignore Error   COAM Logout
    CI_interface.Common Case Teardown

Case Setup
    Wait Until Keyword Succeeds   10m   1m   COAM WEBUI Login
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Configure Rsyslog Service

clear syslogs on server
    Run  sudo rm -rf /var/log/btslog-udp.json
    Run  sudo rm -rf /home/ute/Remote.pcap

Perform remoteSyslogIPaddress parameter activation


    [Arguments]      ${time}=3    ${DSCPvalue}=16
    run keyword and ignore error    Disable remote syslog transmission
    run keyword and ignore error     selenium_coam.delete_parameter     dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Remote syslog configuration
    sleep    2s
    Validate and Activate Parameter
    run keyword and ignore error     selenium_coam.add_element    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
     ...    filter_param=Remote syslog configuration     timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.set_parameter_value  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Remote syslog DSCP
    ...                                new_value=${DSCPvalue}
    run keyword and ignore error    selenium_coam.set_parameter_value  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Remote syslog format
    ...                                new_value= ${SyslogFormat}
    run keyword and ignore error     selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Remote syslog format
    ...    new_value=RFC5424     node_index=${0}
    run keyword and ignore error    selenium_coam.set_parameter_value  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Remote syslog server IP address
    ...                                new_value=${IPv4address}
    run keyword and ignore error    selenium_coam.set_parameter_value  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Remote syslog transmit duration
    ...                                new_value=${time}
    run keyword and ignore error    selenium_coam.set_parameter_value  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Remote syslog server IP port number
    ...                                new_value=6514
    run keyword and ignore error     selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Remote syslog transport protocol
    ...    new_value=UDP    node_index=${0}
    Run Keyword And Ignore Error   Validate and Activate Parameter

Enable remote syslog transmission
    [Documentation]
    ...    set parameter Activate remote syslog transmission to true
    ...    validate and activate it
    run keyword and ignore error    selenium_coam.set_parameter_value  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                    filter_param=Activate remote syslog transmission
    ...                                    new_value=true
    Run Keyword And Ignore Error   Validate and Activate Parameter

Assert that syslog server is receiving logs
    [Documentation]
    ...    in manual tests logs are checked on remote server in Wireshark tool
    ...    start_stop_collect_Tshark_log
    [Arguments]  ${outputPath}   ${captureTimeInSeconds}=120
    capture pcap
    ...     outputPath=${outputPath}
    ...     captureTimeInSeconds=${captureTimeInSeconds}

    ${syslog_file}=          get file size         ${outputPath}
    Should Not Be Equal      ${syslog_file}    ${0}      Server is not receiving logs

Disable remote syslog transmission
    [Documentation]
    ...    set parameter Activate remote syslog transmission to false
    ...    validate and activate it

    run keyword and ignore error    selenium_coam.set_parameter_value  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                    filter_param=Activate remote syslog transmission
    ...                                    new_value=false
    Run Keyword And Ignore Error   Validate and Activate Parameter



Wait for Cell Onair
    [Arguments]   ${wait_timer}   ${cell_index}
    ${status}   run keyword and return status   wait until keyword succeeds   ${wait_timer}   20s
    ...   COAM WEBUI Check Cell Status   cell_index=${cell_index}
    run keyword if  not ${status}   selenium_coam.refresh_page
    run keyword and ignore error     COAM WEBUI Whether Close Start Up View Window
    run keyword if  not ${status}   COAM WEBUI Check Cell Status   cell_index=${cell_index}
    run keyword if  not ${status}   Log to Console   Found cell ${cell_index} status not refresh automatically

Case Teardown
    clear syslogs on server
    Disable remote syslog transmission
#    Run Keyword And Ignore Error   COAM WEBUI Logout
#    Run Keyword And Ignore Error   COAM Logout
    CI_interface.Common Case Teardown

Validate and Activate Parameter
    selenium_coam.validate_plan
    selenium_coam.activate_plan   activate_plan_despite_errors=True    timeout=120
