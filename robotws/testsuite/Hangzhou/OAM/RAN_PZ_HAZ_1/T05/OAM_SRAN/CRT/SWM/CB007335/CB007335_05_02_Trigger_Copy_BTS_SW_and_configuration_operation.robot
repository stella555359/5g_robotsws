*** Settings ***
Documentation     [PURPOSE]
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
#Library           hran_tools
#Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/tool_ping.py
Library           taf.sbts.oam.coam.admin
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/file_operation.py


*** Variables ***
${TARGET_SW_NAME}    ${None}    # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}    /home/ute/btsauto/TARGET_SW/
#...    # Directory in which TC should look for sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${UPDATE_TIMEOUT}    1500    # Timeout for Download and Activation [sec]
${SW Download Timeout}    1800
${SW Activation Timeout}    150  # Given in seconds; That is a timeout for SW download and activation (without reset)
${Ping loss timeout}    420  # Timeout for ping loss during reset
${Ping regain timeout}    600  # Timeout for ping regain during reset
${BTS_OnAir_Timeout}    15  # Timeout for BTS on Air (in minutes)
${Test_Timeout}    30  # Test timeout (in minutes)


*** Keywords ***
TC_CB007335_05_02_Trigger_Copy_BTS_SW_and_configuration_operation_need_site_reset
    [Documentation]    ********************
    ...    1. Basic information
    ...    ********************
    ...
    ...    **Request ID:** TAT-14706
    ...
    ...    ***********************************************************
    ...    2. Description
    ...    ***********************************************************
    ...    Main purpose of this test is to BTS allows to copy SW and configuration
    ...    on the active partition to the passive partition.
    ...    ******************
    ...    History of changes
    ...    ******************
    [Timeout]    100 minutes
    Set Tags    CA-SWM    PHASE-CRT    SW-SBTS22R2    FEATURE-CB007335
    Step 1: Check initial BTS state and alarm status
    Step 2: Compare active and passive SW version
    Step 3: Trigger SW copy via cm parameter and modify reset parameter
    Step 4: Check BTS reset
    Step 5: Check_sync_topassvie_result after reset
    step 6: check final BTS state and alarm status
    Step 7: Recover BTS env by remvoe objects
    Step 8: Recover BTS by Update software to make A-P different

Step ${index}: Check ${when} BTS state and alarm status
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    ...        ${when}: <description>
    Log Step Header  Step ${index}: Check ${when} BTS state
    Log  Will now check if BTS is OnAir, timeout=${BTS_OnAir_Timeout}min, interval=10sec  console=${TRUE}
    Wait until keyword succeeds  ${BTS_OnAir_Timeout} min  10 sec  Verify BTS states
    Log Important Message  BTS is OnAir, all cells and modules are in expected states

Step ${index}: Check ${when} alarms status
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    ...        ${when}: <description>
    Log Step Header  Step ${index}: Check ${when} alarms status
    ${alarms_status}    ${alarms_msg}=    Run Keyword If    ${alarms_check}    Run Keyword And Ignore Error
    ...    Admin Check Active Alarms    expected_patterns=${expected_alarms}   ignored_patterns=${ignored_alarms}
    ...    critical_patterns=${critical_alarms}
    Run keyword if    '${alarms_status}'=='FAIL'
    ...    Log    Critical fail while checking alarms: ${alarms_msg}    console=${TRUE}
    ...    ELSE IF    ${alarms_msg}    Set test restriction    Unexpected alarms are present: ${alarms_msg}

Step ${index}: Compare active and passive SW version
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Log Step Header    Step ${index}: Compare active and passive SW version
    ${software_info}    taf.sbts.oam.coam.admin.Get Software Info
    Log    Active SW: ${software_info['Active SW version']}    console=${TRUE}
    Log    Passive SW: ${software_info['Passive SW version']}    console=${TRUE}
    ${active_sw_before_list}    Get Regexp Matches    ${software_info['Active SW version']}    SBTS([09]{0,2}).+
    ${passive_sw_before_list}    Get Regexp Matches    ${software_info['Passive SW version']}    SBTS([09]{0,2}).+
    Set Test Variable    ${active_version_before_sync}    ${active_sw_before_list[0]}
    Set Test Variable    ${passive_sw_before_sync}    ${passive_sw_before_list[0]}
    Should not be equal  ${active_version_before_sync}  ${passive_sw_before_sync}

Step ${index}: Trigger SW copy via cm parameter and modify reset parameter
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Log Step Header    Step ${index}: Create and Active passive sync without healthy check plan
    set test variable  ${value_without_check}    SW and config without health check
    ${actual_value}  ${change_value}=  compare actual value and set change value
    set test variable  ${actual_value}  ${change_value}
    set test variable  ${value_to_resetsite}  ${change_value}
    create file    ${BTSFiles}${/}plan${/}7335_02_P01.json
    file_operation.update json file    target_json_file=${BTSFiles}${/}plan${/}7335_02_P01.json
    ...    dist_operation=update    dist_name=MRBTS-${BTS_INFO.ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter_operation=update    actDistributedSite=${value_to_resetsite}
    file_operation.update json file    target_json_file=${BTSFiles}${/}plan${/}7335_02_P01.json
    ...    dist_operation=create    dist_name=MRBTS-${BTS_INFO.ID}/MNL-1/CMD-1/COPYSWTOPASSIVEREQ-1
    ...    parameter_operation=update    copyToPassive=SW and config with health check
    ${perfrom_task}  taf.sbts.oam.coam.admin.Run keyword in background    Perform Delta Recommissioning
                                        ...    ${BTSFiles}${/}plan${/}7335_02_P01.json
                                        ...    skip_parameter_relation_errors=${True}
                                        ...    timeout=800s
                                        ...    alias=default
    Log to console with time  ${perfrom_task}
    #Run keyword in background  passive_synchronize  copy_to_passive=0  timeout=100s  connection=default

compare actual value and set change value
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${actual_value}: <description>
    ...        ${CHANGE_VALUE}: <description>
    set test variable    ${dist_name}   MRBTS-${BTS_INFO.ID}/MNL-1/MNLENT-1/FEATCADM-1
    set test variable    ${param}    actDistributedSite
    ${scf}    _Get Scf By Admin   ${Test Results Dir}/scf.xml
    log  ${scf}
    import library   XML  use_lxml=True
    ${scf_xml}=    XML.Parse Xml    ${Test Results Dir}/scf.xml
    ${PARAM_EXIST}    RUN KEYWORD AND RETURN STATUS
    ...    Element Should Exist    ${scf_xml}    .//managedObject[@distName="${dist_name}"]/p[@name="${param}"]
    ${actual_value}    RUN KEYWORD IF  ${PARAM_EXIST}  XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@distName="${dist_name}"]/p[@name="${param}"]
    ${CHANGE_VALUE}   SET VARIABLE IF   '${actual_value}'=='true'   false    true
    log  ${actual_value}
    log  ${CHANGE_VALUE}
    [Return]    ${actual_value}  ${CHANGE_VALUE}

Step ${index}: Check BTS reset
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Log Step Header  Check if reset is performed
    Log  Check if BTS is stable for 5 min  console=${TRUE}
    ${ping_loss_status}=  run keyword and return status
    ...    wait_for_target_to_be_not_reachable  hostname=${SMOD1['TRS_IP']}  timeout=200
    Run keyword if   ${ping_loss_status}==${False}
    ...  Set Test Failed  BTS reset did not occur  console=${TRUE}
    ...  ELSE
    ...  Log  Reset is performed. BTS cannot ping 192.168.255.129 successful.  console=${TRUE}
    ${ping_regain_status}=  Run keyword and return status
    ...    wait_for_target_to_be_reachable  hostname=${SMOD1['TRS_IP']}  timeout=300
    Run keyword if   ${ping_regain_status}==${False}
    ...  Set Test Failed  Ping has not been regained within timeout
    ...  ELSE
    ...  Log  BTS is ping regained  console=${TRUE}

    ${ping_stable_status}=  Check If Target Is Stable
    ...    ip=${SMOD1['TRS_IP']}  min_uptime=300  max_downtime=300  timeout=900
    Run keyword if   ${ping_stable_status}==${False}
    ...  Set Test Failed  Ping has not been stable within timeout.
    ...  ELSE
    ...  Log   Ping is stalbe after reset.
    Wait Until Keyword Succeeds  5 min  10 sec  Fail if connection with admin is not available

Fail if connection with admin is not available
    [Documentation]    Short description.
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  Return from keyword
    ${admin_reset_status}  Run keyword and return status  taf.sbts.oam.coam.admin.Reset admin
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  Return from keyword
    Fail  ${admin_reset_status}

Step ${index}: Check_sync_topassvie_result after reset
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Log Step Header    Step ${index}: Check_result_after_sync_topassvie
    set test variable  ${scf_sync_distName}  MRBTS-${BTS_INFO.ID}/MNL-1/CMD-1/COPYSWTOPASSIVEREQ-1/COPYSWTOPASSIVERES-1
    set test variable  &{result_synv_dic}  result=success
    set test variable  ${scf_syncversion_distName}  MRBTS-${BTS_INFO.ID}/MNL-1/MNL_R-1
    set test variable  &{result_syncversion_dic}
    ...    activeSWReleaseVersion=${active_version_before_sync}  passiveSWReleaseVersion=${active_version_before_sync}
    sleep  3min
    Wait Until Keyword Succeeds    5x   1min   Check parameters by Scf  ${scf_sync_distName}  &{result_synv_dic}
    Wait Until Keyword Succeeds
    ...    10x   1min   Check parameters by Scf  ${scf_syncversion_distName}  &{result_syncversion_dic}

Check parameters by Scf
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${scf_distName}: <description>
    ...        &{parameters_dict}: <description>
    [Arguments]    ${scf_distName}  &{parameters_dict}
    Run keyword and ignore error    Check WebEM After Modify Parameters  ${scf_distName}  &{parameters_dict}

Step ${index}: Recover BTS env by remvoe objects
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Log Step Header    Step ${index}: Recover admin env by remvoe objects
    ${Recover_result}  Run keyword and return status
    ...    _Perform Full Commision By Admin  ${Test Results Dir}/back_scf.xml  ${BTS_INFO.ID}
    Run keyword if  ${Recover_result}
    ...    Log  The parameters of synchronization is deleted, actDistributedSite is recovered successfully
    ${ping_stable_status}=
    ...    Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=300  max_downtime=300  timeout=900
    Run keyword if   ${ping_stable_status}==${False}
    ...  Set Test Failed  Ping has not been stable within timeout.
    ...  ELSE
    ...  Log   Ping is stalbe after reset.
    Wait Until Keyword Succeeds  5 min  10 sec  Fail if connection with admin is not available

Step ${index}: Recover BTS by Update software to make A-P different
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Find path to SW package
    Run Keyword If  '${Target SW path}'== ${None}   Fail
    ${software_update_start}=  Get current date
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Update Software  ${Target SW path}  True  3000s
    Run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  Software update failed: ${sw_update_msg}
    ${ping loss status}  Run keyword and return status
    ...    Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=240
    Run keyword if  ${ping loss status}==${FALSE}
    ...    Log    BTS RESET after successful sw update DID NOT OCCUR   console=${TRUE}
    ...       ELSE    Log    BTS is resetting after successful sw update          console=${TRUE}
    ${ping regain status}  Run keyword and return status
    ...    Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=300
    Run keyword if  ${ping regain status}==${False}  Set Test Failed  Ping has not been regained within timeout
    ${ping stable status}  Run keyword and return status
    ...    Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=120  max_downtime=0  timeout=121
    Run keyword if  ${ping stable status}==${False}  Set Test Failed  Ping has not been available for 120 seconds
    Wait Until Keyword Succeeds  5 min  10 sec  Fail if connection with admin is not available
    sleep    10min
    Verify BTS states
