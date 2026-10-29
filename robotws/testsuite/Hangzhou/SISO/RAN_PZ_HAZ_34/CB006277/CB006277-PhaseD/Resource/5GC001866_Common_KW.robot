*** Settings ***
Documentation     author: Liu Yue
...               Group: HGZ_SG5
...               contact: yue.2.liu@nokia-sbell.com

Library           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/compare_alarm_list.py
Resource          ../../../common/siso_resource.robot

*** Variables ***
${DU_Username}      ${asik_username}
${DU_Password}      ${asik_password}
${VM_IP}            ${host_addr}
${VM_username}      ${host_username}
${VM_password}      ${host_password}
${BSR_file1}    BSR_AQQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
${BSR_file2}    BSR_AEQE_8_H3H3H2_ALN45_ARP45_P00_COVERAGE_00396_00001
${File_path1}    /home/ute/TA/BSR/BSR_AQQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001.zip

*** Keywords ***
"${Step}" Enable feature 1866
    Log To Console    "${Step}" Enable feature 1866
	selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-1
    ...    filter_param=Activate Beamforming   new_value=true
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}
    ...    filter_param=Activate custom beam set realization
    ...    new_value=true
    Validate and activate and check activate plan status	
"${Step}" Check gNB and Cell onAir
    Log To Console    Check gNB and Cell onAir
	run keyword and ignore error    selenium_coam.close_start_up_view_window
	run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
	run keyword and ignore error    selenium_coam.disable_message_box
    Wait Until Keyword Succeeds    30min    1min    check gNB Staus onAir
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}
    ...    search_text=Operational state
    sleep    5s

"${Step}" Download BSR package
    Log To Console    "${Step}" Download BSR package
	selenium_coam.load_software_package_from_local_drive    file_path=${File_path1}
	sleep    5s
	selenium_coam.software_update    is_activate=${True}

"${Step}" Check installed BSR
    Log To Console    "${Step}" Check installed BSR
	${beamSetInstall}    selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}
    ...    filter_param=Beam set installed
    ...    node_index=${0}
	Should Be Equal    ${beamSetInstall}    ${BSR_file1}
	
"${Step}" Activate BSR through WebEM
    Log To Console    "${Step}" Activate BSR through WebEM
	selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-1
    ...    filter_param=Activate Beamforming
    ...    new_value=true
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}
    ...    filter_param=Activate custom beam set realization
    ...    new_value=true
	sleep    2s
	selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-1
    ...    filter_param=Basic Beam Set
    ...    new_value=beamSet_1
	sleep    1s
	selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-1
    ...    filter_param=Custom Beam Set Name
    ...    new_value=${BSR_file1}
	sleep    1s
	selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELLGRP-0
    ...    filter_param=Number of transmitted Synchronization Signal Blocks
    ...    new_value=2 beams
    Validate and activate and check activate plan status
"${Step}" Activate cell2 same BSR through WebEM
    Log To Console    "${Step}" Activate cell2 same BSR through WebEM
	selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-2
    ...    filter_param=Activate Beamforming
    ...    new_value=true
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}
    ...    filter_param=Activate custom beam set realization
    ...    new_value=true
	sleep    2s
	selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-2
    ...    filter_param=Basic Beam Set
    ...    new_value=beamSet_1
	sleep    1s
	selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-2
    ...    filter_param=Custom Beam Set Name
    ...    new_value=${BSR_file1}
	sleep    1s
	selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELLGRP-1
    ...    filter_param=Number of transmitted Synchronization Signal Blocks
    ...    new_value=4 beams
    ${currentBeam}    selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELLGRP-1
    ...    filter_param=Number of transmitted Synchronization Signal Blocks
	run keyword if    '${currentBeam}'=='4 beams'    Validate and activate and check activate plan status
	run keyword if    '${currentBeam}'!='4 beams'    Activate parameter which need reset
"${Step}" Check Inused basicBeamset
    Log To Console    "${Step}" Check Inused basicBeamset
	Wait Until Keyword Succeeds    5min    1min    Check Used Beamset    NRCELL-1    beamSet_2
"${Step}" Check Inused defaultBeamset
    Log To Console    "${Step}" Check Inused defaultBeamset
	Wait Until Keyword Succeeds    5min    1min    Check Used Beamset    NRCELL-1    beamSet_1
"${Step}" Check Inused BSR
    Log To Console    "${Step}" Check Inused BSR
	Wait Until Keyword Succeeds    5min    1min    Check Used Beamset    NRCELL-1    ${BSR_file1}
"${Step}" Check Inused same BSR
    Log To Console    "${Step}" Check Inused BSR
	Wait Until Keyword Succeeds    5min    1min    Check Used Beamset    NRCELL-2    ${BSR_file1}
"${Step}" Check If there is new alarm
    Log To Console    "${Step}" Check If there is new alarm
	${alarmAfter}    Get Active Alarm
	${alarmDelta}    compare_Alarm    alarmName=${alarmBefore}    alarmNameNew=${alarmAfter}
	${ints}=	Create List    ${0}
	Should Be Equal    ${alarmDelta}    ${ints}
"${Step}" Disable feature 1866
    Log To Console    "${Step}" Disable feature 1866
	selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-1
    ...    filter_param=Activate Beamforming     new_value=true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}
    ...    filter_param=Activate custom beam set realization    new_value=false
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-1
    ...    filter_param=Basic Beam Set   new_value=beamSet_4
	sleep    1s
	run keyword and ignore error    selenium_coam.delete_parameter
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-1
    ...    filter_param=Custom Beam Set Name
	sleep    1s
	selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELLGRP-0
    ...    filter_param=Number of transmitted Synchronization Signal Blocks
    ...    new_value=4 beams
    sleep    1s
    ${currentBeam}    selenium_coam.get_parameter_value 
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELLGRP-0
    ...    filter_param=Number of transmitted Synchronization Signal Blocks
	run keyword if    '${currentBeam}'=='4 beams'    Validate and activate and check activate plan status
	run keyword if    '${currentBeam}'!='4 beams'    Activate parameter which need reset

	
"${Step}" Trigger predefine basicBeamSet
    Log To Console    "${Step}" Trigger predefine basicBeamSet
	selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-1
    ...    filter_param=Activate Beamforming   new_value=true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}
    ...    filter_param=Activate custom beam set realization    new_value=true
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-1
    ...    filter_param=Basic Beam Set   new_value=beamSet_2
	sleep    1s
	run keyword and ignore error    selenium_coam.delete_parameter
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-1
    ...    filter_param=Custom Beam Set Name
	sleep    1s
	selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELLGRP-0
    ...    filter_param=Number of transmitted Synchronization Signal Blocks
    ...    new_value=2 beams
    sleep    3s
    Validate and activate and check activate plan status
	
"${Step}" Trigger predefine defaultBeamSet
    Log To Console    "${Step}" Trigger predefine basicBeamSet
	selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-1
    ...    filter_param=Activate Beamforming     new_value=true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}
    ...    filter_param=Activate custom beam set realization    new_value=true
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-1
    ...    filter_param=Basic Beam Set   new_value=beamSet_1
	sleep    1s
	run keyword and ignore error    selenium_coam.delete_parameter
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-1
    ...    filter_param=Custom Beam Set Name
	sleep    1s
	selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELLGRP-0
    ...    filter_param=Number of transmitted Synchronization Signal Blocks
    ...    new_value=1 beam
    sleep    3s
    ${currentBeam}    selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELLGRP-0
    ...    filter_param=Number of transmitted Synchronization Signal Blocks
	run keyword if    '${currentBeam}'=='1 beam'    Validate and activate and check activate plan status
	run keyword if    '${currentBeam}'!='1 beam'    Activate parameter which need reset
Check Used Beamset
    [Arguments]    ${cellName}    ${beamSetName}
	${beamSetInused}    selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/${cellName}
    ...    filter_param=Beam Set in Use
	Should Be Equal    ${beamSetInused}    ${beamSetName}
Get Active Alarm
    Log To Console   Get Active Alarm	
	${activeAlarm}    selenium_coam.get_active_alarm_info
	[Return]    ${activeAlarm}

Lock or unlock cell
    [Arguments]    ${Operation}
    selenium.change_list_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-1
    ...    abbr=administrativeState    new_value=${Operation}
    selenium.validate_changes
    sleep    2s
    selenium.activate_changes
    sleep    5s
Get BTS Id online
    run keyword and ignore error    selenium_coam.close_start_up_view_window
	run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
	run keyword and ignore error    selenium_coam.disable_message_box
    ${btsId}    selenium_coam.get_bts_id
	set suite variable    ${btsId}
	${alarmBefore}    Get Active Alarm
    set suite variable    ${alarmBefore}
Connect To gNB
    [Arguments]    ${gNB IP}    ${gNB account}    ${gNB password}
    csn.connect_to    ${gNB IP}    ${gNB account}    ${gNB password}    alias=gNB
	
Check start up window exist
    ${start_up}    selenium_coam.start_up_view_window_exists
	Should Be Equal    ${start_up}    True
