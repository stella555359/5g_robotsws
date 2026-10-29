*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ./NetAct_Fast_Pass_common.robot

*** Variables ***
@{empty_list}

*** Keyword ***
Megazone Get All Suite Variables
    Megazone Client Login
    ${release}   Megazone Client Get SW Release
    Set Suite Variable   ${RELEASE}

    ${software_version}   Megazone Client Get SW Version
    Set Suite Variable   ${SOFTWARE_VERSION}

    Set Suite Variable   ${SYSTEM_MODULE}   ASIK

    Megazone Client Backup SCF
    ${XML}   XML.Parse XML   source=${OUTPUT_DIR}/old_commission.xml

    ${oam_tls_status}   xml.Get Element Text   ${XML}   xpath=(cmData/managedObject[@class="com.nokia.srbts.mnl:MPLANENW"]/p[@name="oamTls"])[1]
    Run Keyword If    '${oam_tls_status}'=='off'    Set Suite Variable    ${NE3SWS_mode}    noTLS
    ...    ELSE    Set Suite Variable    ${NE3SWS_mode}    TLS

    ${status_ip}=    Run Keyword And Return Status    Should Contain    ${oam_addr}    :
    Run Keyword If    ${status_ip}    Set Suite Variable    ${NE3SWS_IPversion}    IPv6
    ...    ELSE    Set Suite Variable    ${NE3SWS_IPversion}    IPv4
    [Teardown]   Megazone Client Logout

Megazone Wait GNB Startup
    Run Keyword And Ignore Error   Megazone Client Logout
    Wait Until Keyword Succeeds   15m   1m   Megazone Client Login
    ${status}   Run Keyword And Return Status   Wait Until Keyword Succeeds   15m   1m   Megazone Client Check BTS OnAir
    Log To Console   BTS OnAir Status: ${status}
    [Teardown]   Run Keyword And Ignore Error   Megazone Client Logout

Megazone Check Cell Status Expected
    [Arguments]    ${cell_target_status}
    Wait Until Keyword Succeeds    1m    20s   megazone.create_session
    ...   base_url=https://${WEBUI_ADDR}    user=${WEBUI_USER}    password=${WEBUI_PASSWORD}    alias=webui_connection
    ${cell_status}   megazone.get_cell_specific_info   cell_number=1   session=webui_connection
    ${cell_status}   Set Variable   ${cell_status['administrativeState']}
    Should Be Equal   ${cell_status.lower()}   ${cell_target_status.lower()}

Megazone Login And Backup SCF
    [Arguments]   ${local_dir}=${OUTPUT_DIR}   ${file_name}=old_commission.xml
    Run Keyword And Ignore Error   Megazone Client Logout
    Wait Until Keyword Succeeds   10m   1m   Megazone Client Login
    Megazone Client Backup SCF   local_dir_path=${local_dir}   file_name=${file_name}
    [Teardown]   Run Keyword And Ignore Error   Megazone Client Logout

Megazone Login And Load SCF
    [Arguments]   ${filepath}=${OUTPUT_DIR}/old_commission.xml
    Run Keyword And Ignore Error   Megazone Client Logout
    Wait Until Keyword Succeeds   10m   1m   Megazone Client Login
    Megazone Client Load SCF   filepath=${filepath}
    [Teardown]   Run Keyword And Ignore Error   Megazone Client Logout

Megazone Login And Check Parameter Value
    [Arguments]   ${dist_name}   ${parameter}   ${expect_value}
    Run Keyword And Ignore Error   Megazone Client Logout
    Wait Until Keyword Succeeds   10m   1m   Megazone Client Login
    ${actual_value}   Megazone Client Get Parameter Value   dist_name=${dist_name}   parameter=${parameter}
    Should Be Equal   ${actual_value}   ${expect_value}
    [Teardown]   Run Keyword And Ignore Error   Megazone Client Logout

#--------------------------------------------------------------OLD------------------------------------------------------------
# Check Active Alarms
#     [Arguments]   ${ignore_alarms}=${empty_list}

#     ${platform}   Get Web Platform
#     ${alarm_list}   Run Keyword   Get Active Alarms ${platform}
#     Set Ignore Alarms FP    ${alarm_list}    @{ignore_alarms}
#     Run Keyword If    ${new_list}    Log    ${new_list}    Warn
#     Run Keyword If    ${new_list}    Fail

# Get Active Alarms Megazone
#     megazone.create_session    base_url=https://${WEBUI_ADDR}/    alias=WEBUI
#     @{alarm_list}    megazone.get_active_alarms    session=WEBUI
#     [Return]   ${alarm_list}
#     [Teardown]   megazone.teardown_session    session=WEBUI

# Get Active Alarms COAM
#     COAM Login    alias=WEBUI
#     @{alarm_list}    coam.get_active_alarms    session=WEBUI
#     [Return]   ${alarm_list}
#     [Teardown]   COAM Logout    connection=WEBUI

# Set Ignore Alarms FP
#     [Arguments]    ${alarm_list}    @{ignore_alarms}
#     @{new_list}    Create list
#     : FOR    ${alarm}    IN    @{alarm_list}
#     \    Run Keyword If    ${alarm["specificProblem"]} in @{ignore_alarms}    Continue For Loop
#         ...    ELSE    Append to List    ${new_list}    ${alarm}
#     Set Suite Variable   ${new_list}

# Get Web Platform
#     Return From Keyword If   '${gnb_type}'=='cloud'   Megazone
#     [Return]   COAM

# Setup X2
#     csn.Connect To    hostname=${epc_addr}    username=root    password=${epc_password}    alias=LTEEMU_ROOT    timeout=10
#     csn.Execute    killall edaemon    connection=LTEEMU_ROOT
#     csn.Execute    cd ${epc_dir_path}; ./edaemon --port 22222    connection=LTEEMU_ROOT
#     csn.Disconnect    connection=LTEEMU_ROOT
#     csn.Connect To    hostname=${epc_addr}    username=nokia    password=${epc_password}    alias=LTEEMU_NOKIA    timeout=10
#     csn.Execute    killall egate    connection=LTEEMU_NOKIA    timeout=10
#     csn.Execute    cd ${epc_dir_path}; ./egate --port 20000    connection=LTEEMU_NOKIA    timeout=10
#     csn.Disconnect    connection=LTEEMU_NOKIA
#     Telnet.Open Connection    host=${epc_addr}    port=20000    alias=EGATE
#     Telnet.Execute Command    re
#     Telnet.Execute Command    cfg file=${epc_dir_path}/${epc_filename}
#     Sleep    3s
#     Telnet.Execute Command    enb_x2_link_up enb=1 target=2
#     Sleep    3s
#     Telnet.Close Connection

# Check Cell Status is ready Locked or Unlocked on WebUI
#     [Arguments]    ${cell_target_status}
#     ${platform}   Get Web Platform
#     Run Keyword   Check Cell Status is ready Locked or Unlocked on WebUI ${platform}   cell_target_status=${cell_target_status}

# Check Cell Status is ready Locked or Unlocked on WebUI Megazone
#     [Arguments]    ${cell_target_status}
#     ${cell_status}   Get Cell Status Megazone
#     Should Be Equal   ${cell_status.lower()}   ${cell_target_status.lower()}

# Check Cell Status is ready Locked or Unlocked on WebUI COAM
#     [Arguments]    ${cell_target_status}
#     ${cell_status}   Get Cell Status COAM
#     Should Be Equal   ${cell_status.lower()}   ${cell_target_status.lower()}

# Get Cell Status COAM
#     Run Keyword And Ignore Error    Wait Until Keyword Succeeds    1m    20s
#     ...    selenium_coam.login    url=https://${WEBUI_ADDR}    username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
#     ${cell_information}    selenium_coam.get_cell_info    cell_idx=1
#     Set Suite Variable    ${cell_status}    ${cell_information['Status']['Administrative state']}
#     [Return]    ${cell_status}
#     [Teardown]   selenium_coam.Logout

# Get Cell Status Megazone
#     Wait Until Keyword Succeeds    1m    20s   megazone.create_session
#     ...   base_url=https://${WEBUI_ADDR}    user=${WEBUI_USER}    password=${WEBUI_PASSWORD}    alias=webui_connection
#     ${cell_status}   megazone.get_cell_specific_info   cell_number=1   session=webui_connection
#     ${cell_status}   Set Variable   ${cell_status['administrativeState']}
#     [Return]    ${cell_status}
#     [Teardown]   megazone.teardown_session    session=webui_connection

# Change Cell Status to unlock
#     ${platform}   Get Web Platform
#     ${cell_status}   Run Keyword   Get Cell Status ${platform}
#     Run Keyword   Restore Cell Unlock Status ${platform}

# Restore Cell Unlock Status Megazone
#     megazone.create_session    base_url=https://${WEBUI_ADDR}    user=${WEBUI_USER}    password=${WEBUI_PASSWORD}    alias=webui_connection
#     run keyword if  '${cell_status}'=='locked'    megazone.cell_unlock    cell_id=1    session=webui_connection
#     [Teardown]   megazone.teardown_session    session=webui_connection

# Restore Cell Unlock Status COAM
#     COAM Login    alias=webui_connection
#     run keyword if  '${cell_status}'=='locked'    coam.unlock_cell
#     ...    dist_name=/MRBTS-${BTS_ID}/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1    connection=webui_connection
#     [Teardown]   COAM Logout    connection=webui_connection

# Catch Logs of Classical BTS
#     [Arguments]    ${logname}
# #    Catch snapshot megazone    local_file_path=${OUTPUT_DIR}/snapshot_${logname}.zip
# #    ...   http_addr=${WEBUI_ADDR}    web_user=${WEBUI_USER}    web_password=${WEBUI_PASSWORD}
#     csn.connect_to    hostname=${oam_addr}    username=${oam_username}    password=${oam_password}    alias=ASIK
#     csn.download_file    remote_path=/ffs/run/config/node_0xe000/siteoam/config/noma/managers/nomaCfg.json
#     ...   local_path=${OUTPUT_DIR}/nomaCfg_${logname}.json    connection=ASIK
#     csn.download_file    remote_path=/ffs/run/config/node_0xe000/siteoam/config/noma/managers/nomaSoc.json
#     ...   local_path=${OUTPUT_DIR}/nomaSoc_${logname}.json    connection=ASIK
#     csn.download_file    remote_path=/tmp/node_0xe000/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/logs/startup_SITEOAM.log
#     ...   local_path=${OUTPUT_DIR}/startup_SITEOAM_${logname}.log    connection=ASIK
#     csn.disconnect    connection=ASIK
