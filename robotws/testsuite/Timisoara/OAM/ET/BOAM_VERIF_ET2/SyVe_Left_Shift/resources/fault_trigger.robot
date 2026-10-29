*** Settings ***
Documentation
...    Author: piotr.zukrowski@nokia.com
...    Maintainer: piotr.zukrowski@nokia.com
...    Test Description: The purpose of the test is to verify mechanism of raising selected faults
...    Group in charge: I_MN_5GSC_PZ_5G_IV7_WRO_5_GMS
...    Review: piotr.zukrowski@nokia.com, damian.muszynski@nokia.com, sylwia.swiatkiewicz@nokia.com

Library    OperatingSystem
Library    String

Library    taf.sbts.oam.coam.admin
Library    ../CommonKeywords/sw_editors.py

Resource    admin.robot
Resource    pretest_posttest.robot
Resource    system.robot

*** Variables ***
${BLACKBOX_ALARMS_PATH}            /ffs/run/config/lifedata/blackbox_alarms
${delta_delete_toggling}           ${CURDIR}/configuration/delta_file/delta_delete_toggling.json
${delta_1525_SA_18}                ${CURDIR}/configuration/delta_file/delta_1525_SA_18.json
${delta_1525_SA_19}                ${CURDIR}/configuration/delta_file/delta_1525_SA_19.json
${delta_1525_SA_20}                ${CURDIR}/configuration/delta_file/delta_1525_SA_20.json
${delta_1525_SA_21}                ${CURDIR}/configuration/delta_file/delta_1525_SA_21.json
${delta_1525_SA_21_inUse_false}    ${CURDIR}/configuration/delta_file/delta_1525_SA_21_inUse_false.json
${delta_1525_SA_22}                ${CURDIR}/configuration/delta_file/delta_1525_SA_22.json

*** Keywords ***
Test Setup Fault 28
    [Documentation]
    ...    Assert fault 28 is not raised.
    ...    Download predecessor software. One version leave as valid and corrupt second version, both in separate special directories.
    [Timeout]    34 min    # TL 021: 34
    Log To Console    Test Setup Fault 28
    ADMIN Reset Site
    Wait Until Keyword Succeeds
    ...    15 min
    ...    5 sec
    ...    ADMIN INFOMODEL Check If BTS Is OnAir

    Run    mkdir /home/ute/BTS_SW_corrupted
    ${path}    ADMIN Download Predecessor Software And Corrupt    /home/ute/BTS_SW_corrupted
    Set Suite Variable    ${path_predecessor_sw_package_corrupted}    ${path}
    Run    mkdir /home/ute/BTS_SW_valid
    ${path}    ADMIN Download Predecessor Software    /home/ute/BTS_SW_valid
    Set Suite Variable    ${path_predecessor_sw_package}    ${path}


Test Preconditions Check Allowed Faults
    Test Preconditions
    Log To Console    Test Preconditions Check Allowed Faults
    Wait Until Keyword Succeeds
    ...    5 min
    ...    10 sec
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    Run Keyword And Return Status
    ...    ADMIN Assert No Unexpected Active Alarms
    ...    alowed_alarms_list=@{ALLOWED_ALARMS}

Test Preconditions Toggling
    [Arguments]    ${delta_file}=${delta_1525_SA_18}
    Change Mrbts In Recommissioning File
    ...    path_delta_file_org=${delta_file}
    ...    path_delta_file_mod=${delta_file}
    ADMIN Perform Delta Recommissioning
    ...    delta_file=${delta_file}

Change Mrbts In Recommissioning File
    [Arguments]
    ...             ${path_delta_file_org}
    ...             ${path_delta_file_mod}
    ...             ${OUT_MRBTS_ID}=${OUT_MRBTS_ID}
    Run  sudo cp ${path_delta_file_org} ${path_delta_file_mod}
    Run  sed -i 's/MRBTS-[0-9]*[0-9]/MRBTS-${OUT_MRBTS_ID}/' ${path_delta_file_mod}

Assure Directory Exists
    [Documentation]  Create Directory method doesnt fail even if dir already exists, so just running it makes sense
    [Arguments]  ${dir}
    OperatingSystem.Create Directory   ${dir}

Mark Date And Time
    ${marked_date}    SYSTEM Execute Command On gNB
    ...    command=(date +%Y-%b-%d)
    ${marked_time}    SYSTEM Execute Command On gNB
    ...    command=date +%H
    ${marked_date}    Fetch From Left
    ...    string=${marked_date}
    ...    marker=\r\n
    ${marked_time}    Fetch From Left
    ...    string=${marked_time}
    ...    marker=\r\n
    ${marked_time}    Convert To Integer    ${marked_time}
    Set Test Variable    ${marked_date}
    Set Test Variable    ${marked_time}

Check If BTS Is Not In Uncommissioned State
    ${path}  Get IM Path MRBTS_M
    ${proceduralState}   ADMIN Get Parameter
    ...    dist_name=${path}
    ...    parameter=proceduralState
    ...    timeout=300
    ${proceduralState}    Get From Dictionary    ${proceduralState}    stateInfo
    ${proceduralState}    Get From Dictionary    ${proceduralState}    proceduralState
    ${bts_acceptable_states}    Set Variable    Configured Commissioned IntegratedToRan OnAir
    Should Contain    ${bts_acceptable_states}    ${proceduralState}

Get IM Path MRBTS_M
    ${is_left}    Run Keyword And Return Status
    ...    Should Be Equal
    ...    ${OUT_ADMIN_SMOD_POSITION}
    ...    left
    ${path}    Set Variable If    ${is_left}
    ...    /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1
    ...    /MRBTS-1/RAT-1/MCTRL-4/BBTOP_M-1/MRBTS_M-1
   [Return]  ${path}

Check If Recovery Action Is Performed
    Log To Console    Check If Recovery Action Is Performed
    Wait Until Keyword Succeeds
    ...    5 min
    ...    1 sec
    ...    SYSTEM Check If Host Is Not Pingable
    ...    host_ip_address=${ADMIN_BTS_HOST}
    Wait Until Keyword Succeeds
    ...    2 min
    ...    10 sec
    ...    SYSTEM Check If Host Is Pingable
    ...    host_ip_address=${ADMIN_BTS_HOST}

Update Output Check
    [Arguments]
    ...    ${task}
    ...    ${connection}=${ADMIN_ALIAS}
    @{list_abort_output}    Run Keyword And Ignore Error
    ...    taf.sbts.oam.coam.admin.Collect Keyword Result
    ...    task=${task}
    ...    connection=${connection}
    ${error_type}    Fetch From Left
    ...    string=@{list_abort_output}[1]
    ...    marker=${SPACE}
    Should Be Equal
    ...    first=${error_type}
    ...    second=AdminApiProcedureFailureException:

Trigger Fault 28
    [Timeout]    24 min    # TL 021: 24
    ${status}    Run Keyword And Return Status
    ...    ADMIN Update Software Without Activation
    ...    sw_package=${path_predecessor_sw_package_corrupted}
    Should Be Equal
    ...    first=${status}
    ...    second=${False}
    Wait Until Keyword Succeeds
    ...    6 min
    ...    5 sec
    ...    ADMIN Check If Alarm Is Active
    ...    fault_id=28

Cancel Fault 28
    [Arguments]
    ...    ${connection}=${ADMIN_ALIAS}
    [Timeout]    20 min    # TL 021: 20
    ${admin_interface}    Get Library Instance    taf.sbts.oam.coam.admin
    ${output_task_abort_in_background}    taf.sbts.oam.coam.admin.Run Keyword In Background
    ...    interface=${admin_interface}
    ...    name=update_software
    ...    sw_package=${path_predecessor_sw_package}
    ...    should_activate=${FALSE}
    ...    connection=${connection}
    ADMIN Setup Admin
    ...    alias=abort_alias
    ${output_task_abort_software_update}    Wait Until Keyword Succeeds
    ...    1 min
    ...    1 sec
    ...    ADMIN Abort Software Update
    ...    alias=abort_alias
    Wait Until Keyword Succeeds
    ...    2 min
    ...    1 sec
    ...    Update Output Check
    ...    task=${output_task_abort_in_background}
    ADMIN Teardown Admin
    ...    alias=abort_alias
    Wait Until Keyword Succeeds
    ...    3 min
    ...    10 sec
    ...    ADMIN Check If Alarm Is Not Active
    ...    fault_id=28

Trigger Fault 4383
    [Documentation]
    ...    Use Suite Variable `suite_setup_vn_container_id` which must be set in SUITE SETUP.
    Log To Console    Trigger Fault 4383
        # ${response}    SYSTEM Execute Command On gNB
        # ...    command=lxc-attach -n ${suite_setup_vn_container_id} -- hostname
        # Log To Console    check \${response}=${response}
        # ${status}    Run Keyword And Return Status    Should Contain    ${response}    ${suite_setup_vn_container_id}
        # Log To Console    check \${status}=${status}
        # Run Keyword If    ${status}
        # ...   SYSTEM Execute Command On gNB
        # ...   command=lxc-attach -n ${suite_setup_vn_container_id} -- kill -9 -1
    SYSTEM Execute Command On gNB    command=lxc-attach -n ${suite_setup_vn_container_id} -- kill -9 -1

Check If Fault 4383 Was Raised
    Log To Console    Check If Fault 4383 Was Raised
    ${status_list}    Create List
    ${status}    SYSTEM Execute Command On gNB
    ...    command=cat ${BLACKBOX_ALARMS_PATH} | grep 4383 | grep ${marked_date} | grep ${marked_time}:*: | cut -d \\( -f2 |cut -d \\) -f1
    Append To List    ${status_list}    ${status}
    Mark Date And Time
    ${status}    SYSTEM Execute Command On gNB
    ...    command=cat ${BLACKBOX_ALARMS_PATH} | grep 4383 | grep ${marked_date} | grep ${marked_time}:*: | cut -d \\( -f2 |cut -d \\) -f1
    Append To List    ${status_list}    ${status}
    Should Contain    '${status_list}'    4383

Check If BTS Is OnAir And Alarm 4383 Is Not Active
    Wait Until Keyword Succeeds
    ...    900
    ...    15
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    ADMIN Check If Alarm Is Not Active
    ...     fault_id=4383

5GC001525_SA_16_A_Fault_management-Recovery_actions_mechanism_verification
    Trigger Fault 4383
    Mark Date And Time
    Check If Recovery Action Is Performed
    Wait Until Keyword Succeeds
    ...    5 min
    ...    5 sec
    ...    Check If BTS Is Not In Uncommissioned State
    Check If Fault 4383 Was Raised
