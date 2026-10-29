*** Settings ***
Documentation     [PURPOSE]
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
#Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_syve.robot
##Library           hran_tools
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/tool_ping.py
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
TC_CB007335_02_01_Copy_BTS_SW_and_configuration_from_active_to_passive_partition_WithoutHeatlthCheck
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
    [Timeout]    50 minutes
    Set Tags    CA-SWM    PHASE-CRT    SW-SBTS22R2    FEATURE-CB007335
    Step 1: Check initial BTS state and alarm status
    Step 2: Compare active and passive SW version
    Step 3: Create and Active passive sync without healthy check plan
    Step 4: Check_result_after_sync_topassvie
    step 5: check final BTS state and alarm status
    Step 6: Recover BTS env by remvoe objects

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
    ${alarms_status}    ${alarms_msg}=    Run Keyword If    ${alarms_check}
    ...    Run Keyword And Ignore Error
    ...    Admin Check Active Alarms
    ...    expected_patterns=${expected_alarms}
    ...    ignored_patterns=${ignored_alarms}
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

Step ${index}: Create and Active passive sync without healthy check plan
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Log Step Header    Step ${index}: Create and Active passive sync without healthy check plan
    set test variable  ${value_without_check}    SW and config without health check
    create file    ${BTSFiles}${/}plan${/}7335_01_01_P01.json
    file_operation.Update Json File
    ...    target_json_file=${BTSFiles}${/}plan${/}7335_01_01_P01.json
    ...    dist_operation=create
    ...    dist_name=MRBTS-${BTS_INFO.ID}/MNL-1/CMD-1/COPYSWTOPASSIVEREQ-1
    ...    parameter_operation=update
    ...    copyToPassive=${value_without_check}
    ${Acitve_result}  Run keyword and return status
    ...    _Perform Delta Commission By Admin    ${BTSFiles}${/}plan${/}7335_01_01_P01.json
    Run keyword if  ${Acitve_result}  Log  The synchronization parameters are activated successfully

Step ${index}: Check_result_after_sync_topassvie
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Log Step Header    Step ${index}: Check_result_after_sync_topassvie
    set test variable  ${scf_sync_distName}  MRBTS-${BTS_INFO.ID}/MNL-1/CMD-1/COPYSWTOPASSIVEREQ-1/COPYSWTOPASSIVERES-1
    set test variable  &{result_synv_dic}  result=success
    set test variable  ${scf_syncversion_distName}  MRBTS-${BTS_INFO.ID}/MNL-1/MNL_R-1
    set test variable  &{result_syncversion_dic}  activeSWReleaseVersion=${active_version_before_sync}
    ...    passiveSWReleaseVersion=${active_version_before_sync}
    sleep  3min
    Wait Until Keyword Succeeds    5x   1min   Check parameters by Scf  ${scf_sync_distName}  &{result_synv_dic}
    Wait Until Keyword Succeeds    10x   1min
    ...    Check parameters by Scf  ${scf_syncversion_distName}  &{result_syncversion_dic}

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
    create file    ${BTSFiles}${/}plan${/}7335_01_01_P02.json
    file_operation.Update Json File    target_json_file=${BTSFiles}${/}plan${/}7335_01_01_P02.json
    ...    dist_operation=delete    dist_name=MRBTS-${BTS_INFO.ID}/MNL-1/CMD-1/COPYSWTOPASSIVEREQ-1
    ${Acitve_result_Remove}  Run keyword and return status
    ...    _Perform Delta Commission By Admin    ${BTSFiles}${/}plan${/}7335_01_01_P02.json
    Run keyword if  ${Acitve_result_Remove}  Log  The synchronization parameters are deleted successfully
