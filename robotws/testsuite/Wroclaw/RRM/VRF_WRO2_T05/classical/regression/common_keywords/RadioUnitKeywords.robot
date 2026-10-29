*** Settings ***
Documentation    Suite description
...    Author: Rafal Golicki
...    Contact: rafal.golicki@nokia.com
...    Keywords used for actions on RU

Library     taf.sbts.oam.coam.admin    WITH NAME    admin_cli
Library     taf.transport.ssh    WITH NAME    ssh
Library     PythonKeywords/admin_info_model.py

Resource    admin/BasicKeywords.robot
Resource    ConnectivityKeywords.robot

*** Variables ***

${read RU faults}=             cd ../../ram ; cat fault_history_log.txt

*** Keywords ***

Check if fault is active on RU in History log
    [Arguments]  ${text}
    Connect Ssh To Asix
    ${RU_IP}=     Get RU IP from ASIK
    Connect to RU via Asik   ${RU_IP}
    ${terminal}=    ssh.Execute      ${read RU faults}   connection=ru
    Log to console      ${terminal}
    ${active}=    Fetch From Left    string=${terminal}   marker=InActive faults:
    Log to console      ${active}
    Should contain      ${active}    ${text}
    [Teardown]  run_keywords    Disconnect from RU  AND
    ...                         Disconnect Ssh From Asix

Check if fault is not active on RU in History log
    [Arguments]  ${text}
    Connect Ssh To Asix
    ${RU_IP}=     Get RU IP from ASIK
    Connect to RU via Asik   ${RU_IP}
    ${terminal}=    ssh.Execute      ${read RU faults}   connection=ru
    Log to console      ${terminal}
    ${active}=    Fetch From Left    string=${terminal}   marker=InActive faults:
    Log to console      ${active}
    Should not contain  ${active}    ${text}
    [Teardown]  run_keywords    Disconnect from RU  AND
    ...                         Disconnect Ssh From Asix

Check if fault is visible as inactive on RU in History log
    [Arguments]  ${text}
    Connect Ssh To Asix
    ${RU_IP}=     Get RU IP from ASIK
    Connect to RU via Asik   ${RU_IP}
    ${terminal}=    ssh.Execute      ${read RU faults}   connection=ru
    Log to console      ${terminal}
    ${active}=    evaluate  $terminal[$terminal.find("InActive faults"):$terminal.find("Fault events")]
    Log to console      ${active}
    Should contain      ${active}    ${text}
    [Teardown]  run_keywords    Disconnect from RU  AND
    ...                         Disconnect Ssh From Asix

Reset Radio Unit from SSH
    Connect Ssh To Asix
    ${RU_IP}=     Get RU IP from ASIK
    Connect to RU via Asik   ${RU_IP}
    ssh.execute     rfsw-reboot    connection=ru
    [Teardown]  run_keywords    Disconnect from RU  AND
    ...                         Disconnect Ssh From Asix

Get RU IP from Info Model
    ${RU_IP_DICT}=    admin_cli.get_parameters     /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1
    ${RU_IP}=    get from dictionary    ${RU_IP_DICT}    ipAddress
    should not be equal as strings    ${RU_IP}    0.0.0.0
    [Return]    ${RU_IP}

Get RU IP from ASIK
    Connect Ssh To Asix
    ${FRIps}=     ssh.execute   cat /rom/config/FRIps.txt    connection=asik
    ${RU_IP}=    Get Regexp Matches     ${FRIps}    ;[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+;
    ${RU_IP}=    get from list    ${RU_IP}    -1
    ${RU_IP}=    Remove String   ${RU_IP}    ;
    should not be empty  ${RU_IP}
    [Return]    ${RU_IP}

Check if RU is locked
    [Arguments]  ${RU id}
    ${info}=    admin_cli.get_parameters    dist_name=${RU id}
    should be equal as strings      ${info['stateInfo']['administrativeState']}     Locked
    log to console    ${RU id} is ${info['stateInfo']['administrativeState']}

Check if RU is unlocked
    [Arguments]  ${RU id}
    ${info}=    admin_cli.get_parameters    dist_name=${RU id}
    should be equal as strings      ${info['stateInfo']['administrativeState']}     Unlocked
    log to console    ${RU id} is ${info['stateInfo']['administrativeState']}

Lock RU via admin
    [Arguments]  ${RU id}
    ${result}=      admin_cli.lock_RU   dist_name=${RU id}
    should be equal as strings  ${result}   completed

Unlock RU via admin
    [Arguments]  ${RU id}
    ${result}=      admin_cli.unlock_RU   dist_name=${RU id}
    should be equal as strings  ${result}   completed


Lock RU and check if success
    [Arguments]    ${RU_id}
    Lock RU via admin     ${RU id}
    Wait until keyword succeeds    3min    10sec     Check if RU is locked   ${RU id}

Ru Reset from Admin CLI
    [Arguments]    ${RU_id}
    ${RU_dn}=     Catenate    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-${RU_id}
    admin_cli.reset_unit        dist_name=${RU_dn}
    ...                         reset_type=Hard
    ...                         force_radio_reset=True
    ...                         timeout=240

Admin Get number of Radio Units cOAM1
    [Arguments]        ${connection}=admin
    ${bts_info}=       admin.get_bts_info    connection=${connection}
    ${number_of_ru}=   Get Length   ${bts_info["radioModules"]["rmod"]}
    [Return]           ${number_of_ru}    ${bts_info}

Check statuses for disabled radio if disabled
    [Arguments]    ${connection}=admin
    ${disabled_ru_mrbts}   get_mrbts_by_operational_state   status=Disabled   connection=${connection}
    : FOR  ${mrbts}  IN  @{disabled_ru_mrbts}
    \  ${op_state}    check_ru_parameter_status  dist_name=${mrbts}  parameter=operationalState   connection=${connection}
    \  ${proc_state}  check_ru_parameter_status  dist_name=${mrbts}  parameter=proceduralStatus   connection=${connection}
    \  should be equal as strings   ${op_state}     Disabled
    \  should be equal as strings   ${proc_state}   not initialized
