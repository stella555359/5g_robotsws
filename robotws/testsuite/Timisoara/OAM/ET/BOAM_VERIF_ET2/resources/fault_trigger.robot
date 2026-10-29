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

Resource    admin.robot
Resource    pretest_posttest.robot
Resource    system.robot

*** Variables ***
${CORRUPTED_SW_PACKAGE_PATH}       /home/ute/nu_sterge/
${CORRUPTED_SW_PACKAGE_VERSION}    Airscale_corrupted.zip  #AirScale-0.816.318.zip    # AirScale-6.8351.764.zip
${VALIDATED_SW_PACKAGE_PATH}       /home/ute/Downloads/
${VALIDATED_SW_PACKAGE_VERSION}    AirScale-0.890.209.zip  #AirScale-0.816.318.zip    # AirScale-6.8351.764.zip
${VCONTAINER}                      0xe002
${BLACKBOX_ALARMS_PATH}            /ffs/run/config/lifedata/blackbox_alarms

*** Keywords ***
Test Preconditions Check Allowed Faults
    Test Preconditions
    Wait Until Keyword Succeeds
    ...    300
    ...    10
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    Run Keyword And Return Status
    ...    ADMIN Assert No Unexpected Active Alarms
    ...    alowed_alarms_list=@{ALLOWED_ALARMS}

Test Preconditions Fault 28
#    ADMIN Reset Site
#    Wait Until Keyword Succeeds
#    ...    1200
#    ...    5
#    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    Assure Directory Exists    ${CORRUPTED_SW_PACKAGE_PATH}
    ${file_in_dir}    Run Keyword And Return Status
    ...    SYSTEM Check If File Is In Directory
    ...    fileName=${CORRUPTED_SW_PACKAGE_VERSION}
    ...    fileDirectory=${CORRUPTED_SW_PACKAGE_PATH}
    Run Keyword If    ${file_in_dir} == ${FALSE}
    ...    SYSTEM Download File From Server
    ...    password=ute
    ...    user=ute
    ...    server_IP=10.5.25.105
    ...    file_path=/opt/ute/nu_sterge      #/home/ute/Desktop/yaft/trunk/corrupted
    ...    file_name=${CORRUPTED_SW_PACKAGE_VERSION}
    ...    current_path=${CORRUPTED_SW_PACKAGE_PATH}
    ...    current_name=${CORRUPTED_SW_PACKAGE_VERSION}
    SYSTEM Check If File Is In Directory
    ...    fileName=${CORRUPTED_SW_PACKAGE_VERSION}
    ...    fileDirectory=${CORRUPTED_SW_PACKAGE_PATH}
#    Assure Directory Exists    ${VALIDATED_SW_PACKAGE_PATH}
#    ${file_in_dir}    Run Keyword And Return Status
#    ...    SYSTEM Check If File Is In Directory
#    ...    fileName=${VALIDATED_SW_PACKAGE_VERSION}
#    ...    fileDirectory=${VALIDATED_SW_PACKAGE_PATH}
#    Run Keyword If    ${file_in_dir} == ${FALSE}
#    ...    SYSTEM Download File From Server
#    ...    password=ute
#    ...    user=ute
#    ...    server_IP=10.44.180.141
#    ...    file_path=/home/ute/Desktop/yaft/trunk
#    ...    file_name=${VALIDATED_SW_PACKAGE_VERSION}
#    ...    current_path=${VALIDATED_SW_PACKAGE_PATH}
#    ...    current_name=${VALIDATED_SW_PACKAGE_VERSION}
#    SYSTEM Check If File Is In Directory
#    ...    fileName=${VALIDATED_SW_PACKAGE_VERSION}
#    ...    fileDirectory=${VALIDATED_SW_PACKAGE_PATH}

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

Check not uncommissioned state for BTS
    Run Keyword If     '${OUT_ADMIN_SMOD_POSITION}' == 'left'
    ...       Check If BTS Is Not In Uncommissioned State
    Run Keyword If     '${OUT_ADMIN_SMOD_POSITION}' == 'right'
    ...       Check If BTS on Right side Is Not In Uncommissioned State

Check If BTS Is Not In Uncommissioned State
    ${proceduralState}    ADMIN Get Parameter
    ...    dist_name=/MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1
    ...    parameter=proceduralState
    ...    timeout=300
    ${proceduralState}    Get From Dictionary    ${proceduralState}    stateInfo
    ${proceduralState}    Get From Dictionary    ${proceduralState}    proceduralState
    ${bts_acceptable_states}    Set Variable    Configured Commissioned IntegratedToRan OnAir
    Should Contain    ${bts_acceptable_states}    ${proceduralState}

Check If BTS on Right side Is Not In Uncommissioned State
    ${proceduralState}    ADMIN Get Parameter
    ...    dist_name=/MRBTS-1/RAT-1/MCTRL-4/BBTOP_M-1/MRBTS_M-1
    ...    parameter=proceduralState
    ...    timeout=300
    ${proceduralState}    Get From Dictionary    ${proceduralState}    stateInfo
    ${proceduralState}    Get From Dictionary    ${proceduralState}    proceduralState
    ${bts_acceptable_states}    Set Variable    Configured Commissioned IntegratedToRan OnAir
    Should Contain    ${bts_acceptable_states}    ${proceduralState}

Check If Recovery Action Is Performed
    Wait Until Keyword Succeeds
    ...    300
    ...    1
    ...    SYSTEM Check If Host Is Not Pingable
    ...    host_ip_address=${ADMIN_BTS_HOST}
    Wait Until Keyword Succeeds
    ...    240
    ...    10
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
    [Arguments]
    ...    ${build_path}=${CORRUPTED_SW_PACKAGE_PATH}
    ...    ${build_version}=${CORRUPTED_SW_PACKAGE_VERSION}
    SYSTEM Check If File Is In Directory
    ...    fileName=${build_version}
    ...    fileDirectory=${build_path}
    ${status}    Run Keyword And Return Status
    ...    ADMIN Update Software Without Activation
    ...    sw_package=${build_path}/${build_version}
    Should Be Equal
    ...    first=${status}
    ...    second=${False}
    Wait Until Keyword Succeeds
    ...    360
    ...    5
    ...    ADMIN Check If Alarm Is Active
    ...    fault_id=28

Cancel Fault 28
    [Arguments]
    ...    ${build_path}=${VALIDATED_SW_PACKAGE_PATH}
    ...    ${build_version}=${VALIDATED_SW_PACKAGE_VERSION}
    ...    ${connection}=${ADMIN_ALIAS}
    SYSTEM Check If File Is In Directory
    ...    fileName=${build_version}
    ...    fileDirectory=${build_path}
    ${admin_interface}    Get Library Instance    taf.sbts.oam.coam.admin
    ${output_task_abort_in_background}    taf.sbts.oam.coam.admin.Run Keyword In Background
    ...    interface=${admin_interface}
    ...    name=update_software
    ...    sw_package=${build_path}/${build_version}
    ...    should_activate=${FALSE}
    ...    connection=${connection}
    ADMIN Setup Admin
    ...    alias=abort_alias
    ${output_task_abort_software_update}    Wait Until Keyword Succeeds
    ...    60
    ...    1
    ...    ADMIN Abort Software Update
    ...    alias=abort_alias
    Wait Until Keyword Succeeds
    ...    120
    ...    1
    ...    Update Output Check
    ...    task=${output_task_abort_in_background}
    ADMIN Teardown Admin
    ...    alias=abort_alias
    Wait Until Keyword Succeeds
    ...    180
    ...    10
    ...    ADMIN Check If Alarm Is Not Active
    ...    fault_id=28

Trigger Fault 4383
    ${response}    SYSTEM Execute Command On gNB
    ...    command=lxc-attach -n ${VCONTAINER} -- hostname
    ${status}    Run Keyword And Return Status    Should Contain    ${response}    ${VCONTAINER}
    Run Keyword If    ${status}
    ...   SYSTEM Execute Command On gNB
    ...   command=lxc-attach -n ${VCONTAINER} -- kill -9 -1

Check If Fault 4383 Was Raised
    ${status_list}    Create List
    ${status}    SYSTEM Execute Command On gNB
    ...    command=cat ${BLACKBOX_ALARMS_PATH} | grep 4383 | grep ${marked_date} | grep ${marked_time}:*: | cut -d \\( -f2 |cut -d \\) -f1
    Append To List    ${status_list}    ${status}
    Mark Date And Time
    ${status}    SYSTEM Execute Command On gNB
    ...    command=cat ${BLACKBOX_ALARMS_PATH} | grep 4383 | grep ${marked_date} | grep ${marked_time}:*: | cut -d \\( -f2 |cut -d \\) -f1
    Append To List    ${status_list}    ${status}
    Should Contain    '${status_list}'    4383

Check If BTS Is OnAir And Alarm Is Not Active
    [Arguments]   ${nr_alarm}
    Wait Until Keyword Succeeds
    ...    300
    ...    5
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    ADMIN Check If Alarm Is Not Active
    ...     fault_id=${nr_alarm}

Check If BTS Is Configured And Alarm Is Not Active
    [Arguments]   ${nr_alarm}
    Wait Until Keyword Succeeds
    ...    300
    ...    5
    ...    ADMIN Check BTS Configured
    ADMIN Check If Alarm Is Not Active
    ...     fault_id=${nr_alarm}

5GC001525_SA_16_A_Fault_management-Recovery_actions_mechanism_verification
    Trigger Fault 4383
    Mark Date And Time
    Check If Recovery Action Is Performed
    Wait Until Keyword Succeeds
    ...    300
    ...    5
    ...    Check If BTS Is Not In Uncommissioned State
    Check If Fault 4383 Was Raised
