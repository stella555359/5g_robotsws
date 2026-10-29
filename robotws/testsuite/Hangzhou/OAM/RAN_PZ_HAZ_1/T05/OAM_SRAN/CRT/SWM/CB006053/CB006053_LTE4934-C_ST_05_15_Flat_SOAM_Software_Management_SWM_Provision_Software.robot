*** Settings ***
Documentation     [PURPOSE]
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Mrat_resource_new.robot
Library           taf.sbts.oam.coam.admin
Library           String
Library           DateTime
Library           OperatingSystem
Library           ute_async


*** Variables ***
${sw_package_path}    /home/ute/btsauto/TARGET_SW
#${sw_package_path}    /home/ute/btsauto/BASE_SW
# Direct path to directory where desired sw package is stored, should be the same as passive SW before fallback
#${SW Update Timeout}    1800    # Given in seconds; That is a timeout for SW download and activation (without reset)
${ping_loss_timeout}    240    # Timeout for ping loss during reset
${ping_regain_timeout}    900    # Timeout for ping regain during reset
${restore_timeout}    240    # Timeout for cells to go OnAir after last update
${esm_ip}         192.168.255.119    # ESM trs ip
${FAULT_4001_TIMEOUT}    15    # How long should KW wait for fault 4001 [in minutes]
#${PC_IP2}                         ${tl.test_pcs[1].default_ssh_connection_details.addr}  # Secondy PC IP


*** Keywords ***
LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${feature_ID}: <description>
    [Arguments]    ${feature_ID}
    Set Tags    CA-SWM
    set test variable  ${feature_ID}
    Change parameter to connect netact with BTS
    Step 1: Check active and passive sw version
    Step 2: Import Target SW To NA
    Step_get_provision_expected_time
    Step 3: SW update by NA
    Step 4: check SW version after provision
    Step 5: Check BTS is onair
    Run keyword if   '${feature_ID}'=='CB008457' or '${feature_ID}'=='CB008681'   Step add swm upload kpi check
    Step 6: SW rollback on MSM
    Step 7: Check BTS is onair after rollback

SWM duration of cancel SW Management from NetAct single BTS
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${feature_ID}: <description>
#    [Arguments]    ${feature_ID}
    Set Tags    CA-SWM
#    set test variable  ${feature_ID}
    Change parameter to connect netact with BTS
    Step 1: Check active and passive sw version
    Step 2: Import Target SW To NA
    Step_get_provision_expected_time
    Step 3: SW Downaload And Cancel From NMS

Step_get_provision_expected_time
    [Documentation]    Short description.
    ${HW_TYPE}    Get_HW_Type
    ${provision_expect_time}    Get_SW_Provision_expected_time    ${HW_TYPE}
    set test variable    ${provision_expect_time}

Get_SW_Provision_expected_time
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${HW_TYPE}: <description>
    ...
    ...    Returns:
    ...        ${provision_expect_time}: <description>
    [Arguments]    ${HW_TYPE}
    ${provision_expect_time}    Run keyword if    '${HW_TYPE}'=='FSMF'    set variable    1200
    ...   ELSE IF    '${HW_TYPE}'=='FSIH'    set variable    1140
    ...   ELSE IF    '${HW_TYPE}'=='ASIA' or '${HW_TYPE}'=='ASIA_ASIA'   set variable    1320
    ...   ELSE IF
    ...   '${HW_TYPE}'=='ASIB' or '${HW_TYPE}'=='ASIL' or '${HW_TYPE}'=='ASIB_ASIB' or '${HW_TYPE}'=='ASIL_ASIL'
    ...   set variable    2520
    ...   ELSE IF    '${HW_TYPE}'=='ASIK'    set variable    2040
    ...   ELSE IF    '${HW_TYPE}'=='ASOE'    set variable    1920
    ...   ELSE IF    '${HW_TYPE}'=='ASOG'    set variable    1920
    ...   ELSE IF    '${HW_TYPE}'=='ASIA_FSMF'    set variable    1620
    ...   ELSE IF    '${HW_TYPE}'=='ASIB_FSMF'    set variable    2820
    ...   ELSE IF    '${HW_TYPE}'=='ASIB_ASIA'    set variable    2520
    ...   ELSE IF    '${HW_TYPE}'=='ASIM_ASIM'    set variable    1800
    ...   ELSE IF    '${HW_TYPE}'=='ASIM'    set variable    1800
    ...   ELSE IF    '${HW_TYPE}'=='ASIM_ASIB'    set variable    2220
    ...   ELSE IF    '${HW_TYPE}'=='ASIM_ASIL'    set variable    1800
    [Return]  ${provision_expect_time}

Step 1: Check active and passive sw version
    [Documentation]    Short description.
    Log step header    Step 1: Check active and passive sw version
    ${active_sw_before_master}    ${passive_sw_before_master}=    Infomodel Get SW Versions    module=MSM

Step 2: Import Target SW To NA
    Log step header    Step 2: Import Target SW To NA
    [Documentation]    choose the target package to upgrade, first import to netact, then upgrade by netact
    ${target_path}=    Common_Find SW name    ${Target SW dir}
    ${release_Num}    Get release num    ${target_path}
    set test variable    ${release_Num}
    ${package name}    OperatingSystem.List files in directory    ${Target SW dir}
    ${package name}    set variable    ${package_name[0]}
    ${package_release}=    Find release version    ${package name}    ${release_list_1}
    ...    ${release_list_2}    ${release_list_3}
    ${package_release_changed}    run keyword if    '${target_release}'=='SBTS00'
    ...    Replace String Using Regexp    ${package_release}    SBTS\\d{2}[A-Z]?[0-9]?    ${release_NUM}
    ...    ELSE    set variable    ${package_release}
    set test variable    ${package_release_changed}
    Log  Check build in Netact otherwise Import
    ${Mid_Server}  ${Mid_Server_usr}  ${Mid_Server_pwd}=  Choose_Mid_Server4Netact  ${NETACT_SERVER_INFO.IP}
    build_download_upload_on_remote_server_and_import_to_Netact  target_sw=${package_release}
                                                            ...  release_NUM=${release_NUM}
                                                            ...  remote_ip=${Mid_Server}
                                                            ...  remote_usr=${Mid_Server_usr}
                                                            ...  remote_pwd=${Mid_Server_pwd}

Step 3: SW update by NA
    [Documentation]    Short description.
    Log step header    Step 3: SW update by NA
    ${provision_start}    Get Current date
    wait until keyword succeeds    90min    30s    _do SW provision from NetAct    ${package_release_changed}    90min
    ${provision_end}    Get Current date
    ${SW_PROVISION_KPI_Check}=  Run keyword if
    ...   '${feature_ID}'=='CB008457' or '${feature_ID}'=='CB008681'   Operation_KPI_Check
    ...    ${provision_end}    ${provision_start}    ${provision_expect_time}    SW_PROVISION_BTS_KPI
    Run keyword if   '${feature_ID}'=='CB008457' or '${feature_ID}'=='CB008681'
    ...    set suite variable     ${SW_PROVISION_KPI_Check}
#    sleep    12min

Step 3: SW Downaload And Cancel From NMS
    [Documentation]    Start SW download and cancel it when progress exceed the given ratio.
    ...    Retured 'Start date' and 'End date' in kw 'get_progress_of_swm_operation' are NMS
    ...    time which may be different with local time. Offset is used in case of that.
    set test variable   ${Download_cancel_expect_time}    180
    Log step header    Step 3: SW Downaload And Cancel From NMS
    taf.nms.netact.Add Node    cmwas    ${NETACT_SERVER_INFO.IP}    ${NETACT_SERVER_INFO.USERNAME}
    ...    ${NETACT_SERVER_INFO.PASSWORD}    alias=ta_netact
    ${download_start_local}=    Get Current Date
    ${op_id}=    taf.nms.netact.start_swm_operation    download   PLMN-PLMN/${BTS_INFO.MRBTS}
    ...    ${package_release_changed}    alias=ta_netact
    ${status}=    taf.nms.netact.get_progress_of_swm_operation    ${op_id}    alias=ta_netact
    ${download_start_nms}=    Convert Date    ${status}[Start date]
    ...    exclude_millis=yes	date_format=%d.%m.%Y %H:%M:%S
    ${offset}=    Subtract Date From Date    ${download_start_local}    ${download_start_nms}
    Wait until keyword succeeds    5min    10s    SW Download Is Ongoing    ${op_id}
    Wait until keyword succeeds    60min    10s    SW Download Progress Exceed Given Ratio    10
    ${download_cancel_start}=    Get Current Date
    ${download_cancel_start}=    Subtract Time From Date    ${download_cancel_start}    ${offset}
    ${result}=    taf.nms.netact.cancel_swm_operation    ${op_id}    alias=ta_netact
    Wait until keyword succeeds    10min    10s    SW Download Is Cancelled    ${op_id}
    ${status}=    taf.nms.netact.get_progress_of_swm_operation    ${op_id}    alias=ta_netact
    ${download_cancel_end}=    Convert Date    ${status}[End date]
    ...    exclude_millis=yes	date_format=%d.%m.%Y %H:%M:%S
    taf.nms.netact.Clean All    alias=ta_netact
    Operation_KPI_Check    ${download_cancel_end}    ${download_cancel_start}    ${Download_cancel_expect_time}
    ...    CANCEL_SW_MANAGEMENT_BTS_KPI

SW Download Is Ongoing
    [arguments]    ${op_id}
    ${status}=    taf.nms.netact.get_progress_of_swm_operation    ${op_id}    alias=ta_netact
    Should Be True    '${status}[Status]'=='ONGOING'
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     SW_DOWNLOAD_STATUS
    Should Not Be Empty    ${objs}

SW Download Is Cancelled
    [arguments]    ${op_id}
    ${status}=    taf.nms.netact.get_progress_of_swm_operation    ${op_id}    alias=ta_netact
    Should Be True    '${status}[Status]'=='CANCELED'

SW Download Progress Exceed Given Ratio
    [Documentation]    Short description.
    [arguments]    ${ratio}=75
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     SW_DOWNLOAD_STATUS
    ${len_objs}=    Get Length    ${objs}
    Run Keyword If    ${len_objs}==0    Fail    SW download complete before the progress reach ${ratio}%
    ${progress}=    Set Variable    ${objs}[0][parameters][downloadProgress]
    Should Be True    ${progress}>${ratio}

Step 4: check SW version after provision
    [Documentation]    Short description.
    Log step header    Step 4: check SW version after provision
    _check SW version after provision

Step 5: Check BTS is onair
    [Documentation]    Short description.
    Log step header    Step 5: Check BTS is onair
    check BTS is onair after update to tested software

Step add swm upload kpi check
    [Documentation]    Short description.
    taf.nms.netact.Add Node    cmwas    ${NETACT_SERVER_INFO.IP}    ${NETACT_SERVER_INFO.USERNAME}
    ...    ${NETACT_SERVER_INFO.PASSWORD}    alias=ta_netact
#    ${software_upload_start}  Get Current Date
#    ${log}    taf.nms.netact.Upload SW    PLMN-PLMN/${BTS_INFO.MRBTS}    alias=ta_netact
    ${op_id}=    taf.nms.netact.start_swm_operation   upload    PLMN-PLMN/${BTS_INFO.MRBTS}    alias=ta_netact
#    Should Contain    ${log}    SUCCESS
    taf.nms.netact.wait_for_swm_operation    ${op_id}    120    alias=ta_netact
    ${status}=    taf.nms.netact.get_progress_of_swm_operation    ${op_id}    alias=ta_netact
    ${software_upload_start}=    Convert Date    ${status}[Start date]
    ...    exclude_millis=yes	date_format=%d.%m.%Y %H:%M:%S
    set test variable   ${software_upload_start}
    ${software_upload_end}=    Convert Date    ${status}[End date]
    ...    exclude_millis=yes	date_format=%d.%m.%Y %H:%M:%S
    set test variable    ${software_upload_end}
    ${Mo_output}    taf.nms.netact.Get Mo Status    PLMN-PLMN/${BTS_INFO.MRBTS}    alias=ta_netact
    ${acive_sw_upload}=    Get From Dictionary     ${Mo_output}[PLMN-PLMN/${BTS_INFO.MRBTS}]    active_sw
    ${passive_sw_upload}=    Get From Dictionary     ${Mo_output}[PLMN-PLMN/${BTS_INFO.MRBTS}]    passive_sw
    Should Be Equal    ${active_version_after}    ${active_version_after}
    taf.nms.netact.Clean All    alias=ta_netact
#    ${software_upload_end}  Get Current Date
    set test variable    ${upload_expected_time}   30
    ${SW_UPLOAD_KPI_Check}=    Operation_KPI_Check    ${software_upload_end}
    ...    ${software_upload_start}    ${upload_expected_time}    SW_CONFIGURATION_UPLOAD_OPERATION_KPI
    set suite variable    ${SW_UPLOAD_KPI_Check}

Step 6: SW rollback on MSM
    [Documentation]    Short description.
    Log step header  Step 6: SW rollback on MSM
    ${software_rollback_start_A}    Get Current Date
    ${rollback_status}=  Run keyword and return status  taf.sbts.oam.coam.admin.Rollback software
    ${software_rollback_end_A}    Get Current Date
    set test variable    ${software_rollback_start_A}
    set test variable    ${software_rollback_end_A}
    set test variable    ${rollback_expected_time}   540
    Run keyword if    not ${rollback_status}  FAIL  Software rollback was not performed.
    ${SW_Rollback_KPI_Check}=  Run keyword if   '${feature_ID}'=='CB008457' or '${feature_ID}'=='CB008681'
    ...  Operation_KPI_Check    ${software_rollback_end_A}    ${software_rollback_start_A}
    ...    ${rollback_expected_time}    SW_ROLLBACK_BTS_KPI
    Run keyword if   '${feature_ID}'=='CB008457' or '${feature_ID}'=='CB008681'
    ...  set suite variable    ${SW_Rollback_KPI_Check}
    Log  Software rollback triggered successfully.  console=${TRUE}
    Log  Wait till BTS is stable and ensure admin connectivity  console=${TRUE}
    ${ping_status}  Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=300  max_downtime=300  timeout=1200
    Run keyword if    not ${ping_status}  FAIL  BTS is not stable after rollback.
    Log  BTS is stable after rollback.  console=${TRUE}
    ${admin_working_state}  Reset admin and infomodel connection if broken
    Run keyword if    not ${admin_working_state}  Fail
    ...  Admin and/or infomodel failure after reset. Interface reset did not help.  console=${TRUE}

Step 7: Check BTS is onair after rollback
    [Documentation]    Short description.
    Log step header    Step 7: Check BTS is onair after rollback
    check BTS is onair after update to tested software

_check SW version after provision
    [Documentation]    Short description.
    Setup eNB Fsm Access    alias=enb1
    ${active_version_after}=    Get Enb Sw Version    active    alias=enb1
    set test variable    ${active_version_after}
    Teardown Enb Fsm Access    alias=enb1
    ${release_name}    Get Substring    ${package_release_changed}    12
    Should Contain    ${active_version_after}    ${release_name}

Find release version
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${package name}: <description>
    ...        ${release_1}: <description>
    ...        ${release_2}: <description>
    ...        ${release_3}: <description>
    ...
    ...    Returns:
    ...        ${release}: <description>
    [Arguments]    ${package name}    ${release_1}    ${release_2}    ${release_3}
    ${release}=    set variable if    '${release_1}' in '${package name}'
    ...    ${release_1}    '${release_2}' in '${package name}'    ${release_2}    '${release_3}' in '${package name}'
    ...    ${release_3}
    [Return]    ${release}

Common_Find SW name
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${SW_PATH}: <description>
    ...
    ...    Returns:
    ...        ${SW_PATH_package}: <description>
    [Arguments]    ${SW_PATH}
    ${package name}    OperatingSystem.List files in directory    ${SW_PATH}
    should not be empty    ${package name}    Required package not present in ${SW_PATH}
    ${SW_PATH_package}=    Join Path    ${SW_PATH}    ${package name[0]}
    OperatingSystem.File should exist    ${SW_PATH_package}
    [Return]    ${SW_PATH_package}

check BTS is onair after update to tested software
    [Documentation]    Short description.
#    ${ping loss status}    Run keyword and return status    Wait For Target To Be Not Reachable
#    ...    hostname=${SMOD1['TRS_IP']}    timeout=600
#    Run keyword if    ${ping loss status}==${FALSE}
#    ...  Log    BTS RESET after successful SW activation DID NOT OCCUR    console=${TRUE}
#    ...    ELSE    Log    BTS is resetting after successful SW activation...    console=${TRUE}
    ${ping regain status}    Run keyword and return status    Wait For Target To Be Reachable
    ...    hostname=${SMOD1['TRS_IP']}    timeout=300
    Run keyword if    ${ping regain status}==${FALSE}    Set Test Failed    Ping has not been regained within timeout
    ...    ELSE    Log    BTS ping regained    console=${TRUE}
    Log    Waiting for stable ping...    console=${TRUE}
    ${ping stable status}    Run keyword and return status    Check If Target Is Stable
    ...    ${SMOD1['TRS_IP']}    min_uptime=240    max_downtime=0    timeout=361
    Run keyword if    ${ping stable status}==${FALSE}    Set Test Failed    Ping has not been available for 60 seconds
    ...    ELSE    Log    Ping is stable after SWM operation    console=${TRUE}
    Wait until keyword succeeds  15 min  30 sec  Check SBTS SOAM cells and modules

Check if modules states ok after sw updates
    [Documentation]    Short description.
    Log    Will now check if modules states are correct, for maximum of 60 times with 10s interval...    console=True
    FOR    ${run}    IN RANGE    1    60
    ${modules_status}=    Verify modules    RMOD    scf_check=${FALSE}
    run keyword if    '${modules_status}' == 'True'    Run Keywords
    ...    Log    Modules states are correct. Check attempt: ${run}    console=true
    ...    AND    Return from keyword    ${modules_status}
    Sleep    10
    END
    Set Test Failed    Modules states not correct within timeout

Verify cells states
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${cells_state}: <description>
    ${cells_state}=    Run keyword and return status    Wait Until Keyword Succeeds
    ...    ${restore_timeout}    5s    Fail if not all cells are on air
    [Return]    ${cells_state}

Check If Fault 23 present on ESM
    [Documentation]    If active alarm exist and is Major return True otherwise return False
    @{active_alarms} =    taf.sbts.oam.coam.admin.Get Active Alarms
    FOR    ${alarm}    IN    @{active_alarms}
    Log    FaultId: ${alarm.faultId}, Severity: ${alarm.severity}, Notifier: ${alarm.notifier}    console=yes
    ${notifier_is_smod}    run keyword and return status    should contain    ${alarm.notifier}    SMOD_R
    Run Keyword If    '${alarm.faultId}'=='23' and '${alarm.severity}'=='Critical' and ${notifier_is_smod}
    ...    Return From Keyword    ${TRUE}
    END
    Log    Out of loop false    console=yes
    [Return]    ${FALSE}

Check If Fault 23 cleared on SMOD
    [Documentation]    If fault 23 on SMOD is not cleared return FALSE
    @{active_alarms} =    taf.sbts.oam.coam.admin.Get Active Alarms
    Log    ${\n}Active alarms on BTS:    console=${TRUE}
    FOR    ${alarm}    IN    @{active_alarms}
    Log    FaultId: ${alarm.faultId}, Severity: ${alarm.severity}, Notifier: ${alarm.notifier}    console=yes
    ${notifier_is_smod}    run keyword and return status    should contain    ${alarm.notifier}    SMOD_R
    Run Keyword If    '${alarm.faultId}'=='23' and ${notifier_is_smod}    Fail    Alarm with fault 23 on ESM active
    END
    Log    ${\n}Fault23 cleared on ESM    console=yes

Check If Fault 23 present after update
    [Documentation]    Short description.
    Check if modules states ok after sw updates
    ${EXPECTED_ALARM1}=    Create Dictionary    faultId=4082
    ${EXPECTED}=    Create List    ${EXPECTED_ALARM1}
    ${CRITICAL_ALARM1}=    Create Dictionary    faultId=23
    ${CRITICAL}=    Create List    ${CRITICAL_ALARM1}
    Admin Check Active Alarms    expected_patterns=${EXPECTED}    critical_patterns=${CRITICAL}

TC_Custom Setup
    [Documentation]    Short description.
    Common Test Setup
    Delete_uboot_parameters

TC_Custom Teardown
    [Documentation]    Short description.
    Common Test Teardown
    Add_uboot_parameters
