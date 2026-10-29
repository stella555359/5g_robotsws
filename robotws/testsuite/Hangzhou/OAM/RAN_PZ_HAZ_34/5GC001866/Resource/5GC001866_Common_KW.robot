*** Settings ***
Documentation     author: Liu Yue
...               Group: HGZ_SG5
...               contact: yue.2.liu@nokia-sbell.com

Library           ../libraries/compare_alarm.py
Resource          ${CURDIR}/../../common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot

*** Variables ***
${DU_Username}      ${asik_username}
${DU_Password}      ${asik_password}
${VM_IP}            ${host_addr}
${VM_username}      ${host_username}
${VM_password}      ${host_password}
${BSR_file1}       BSR_AEQE_4_H4_ALN45_ARP45_P00_COVERAGE_00421_00001
${BSR_file2}       BSR_AEQE_4_H3H1_ALN45_ARP45_P04_COVERAGE_00569_00001
${File_path1}    /home/ute/TA/BSR/BSR_AEQE_4_H4_ALN45_ARP45_P00_COVERAGE_00421_00001.zip
${File_path2}    /home/ute/TA/BSR/BSR_AEQE_4_H3H1_ALN45_ARP45_P04_COVERAGE_00569_00001.zip
#${File_path1}     ${CURDIR}/../TestData/BSR_AEQE_4_H4_ALN45_ARP45_P00_COVERAGE_00005_00001.zip
#${File_path2}     ${CURDIR}/../TestData/BSR_AEQE_8_H3H3H2_ALN45_ARP45_P00_COVERAGE_00396_00001.zip

${mrbtsId}                   ${tl.gnbs[0].instance_id}
${nrbtsId}                   ${tl.gnbs[0].global_bts_id}

*** Keywords ***
"${Step}" Enable feature 1866
    Log To Console    "${Step}" Enable feature 1866
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
	...   filter_param=Activate Beamforming   new_value=true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    ...  filter_param=Activate custom beam set realization    new_value=true
    Validate and activate and check activate plan status

"${Step}" Check gNB and Cell onAir
    Log To Console    Check gNB and Cell onAir
	run keyword and ignore error    selenium_coam.close_start_up_view_window
	run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
	run keyword and ignore error    selenium_coam.disable_message_box
	run keyword and ignore error    selenium_coam.refresh_page
    Wait Until Keyword Succeeds    30min    1min    check gNB Staus onAir
    ...  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}    search_text=Operational state
    sleep    5s

"${Step}" Download BSR package
    Log To Console    "${Step}" Download BSR package
	selenium_coam.load_software_package_from_local_drive    file_path=${File_path1}
	sleep    5s
	selenium_coam.software_update    is_activate=${True}

"${Step}" Download BSR2 package
    Log To Console    "${Step}" Download BSR2 package
	selenium_coam.load_software_package_from_local_drive    file_path=${File_path2}
	sleep    5s
	selenium_coam.software_update    is_activate=${True}

"${Step}" Check installed BSR
    Log To Console    "${Step}" Check installed BSR
	${beamSetInstall}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
	...  filter_param=Beam set installed    node_index=${0}
	Should Be Equal    ${beamSetInstall}    ${BSR_file1}
	#${beamSetInstall1}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
  #  ...    filter_param=Beam set installed    node_index=${1}

"${Step}" Activate BSR through WebEM
    Log To Console    "${Step}" Activate BSR through WebEM
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
	...  filter_param=Activate Beamforming   new_value=true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    ...  filter_param=Activate custom beam set realization    new_value=true
	sleep    2s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
	...  filter_param=Basic Beam Set   new_value=beamSet_1
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
	...   filter_param=Custom Beam Set Name   new_value=${BSR_file1}
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELLGRP-0
	...   filter_param=Number of transmitted Synchronization Signal Blocks   new_value=4 beams
    ${currentBeam}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELLGRP-0
    ...   filter_param=Number of transmitted Synchronization Signal Blocks
	run keyword if    '${currentBeam}'=='4 beams'    Validate and activate and check activate plan status
	run keyword if    '${currentBeam}'!='4 beams'    Activate parameter which need reset

"${Step}" Activate BSR2 through WebEM
    Log To Console    "${Step}" Activate BSR through WebEM
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-2
	...   filter_param=Activate Beamforming   new_value=true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    ...  filter_param=Activate custom beam set realization    new_value=true
	sleep    2s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-2
	...   filter_param=Basic Beam Set   new_value=beamSet_1
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-2
	...   filter_param=Custom Beam Set Name   new_value=${BSR_file2}
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELLGRP-1
	...   filter_param=Number of transmitted Synchronization Signal Blocks   new_value=8 beams
    ${currentBeam}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELLGRP-1
    ...   filter_param=Number of transmitted Synchronization Signal Blocks
	run keyword if    '${currentBeam}'=='8 beams'    Validate and activate and check activate plan status
	run keyword if    '${currentBeam}'!='8 beams'    Activate parameter which need reset

"${Step}" Activate BSR2 through WebEM for Cell1
    Log To Console    "${Step}" Activate BSR through WebEM
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
	...   filter_param=Activate Beamforming   new_value=true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    ...   filter_param=Activate custom beam set realization    new_value=true
	sleep    2s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
	...   filter_param=Basic Beam Set   new_value=beamSet_1
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
	...   filter_param=Custom Beam Set Name   new_value=${BSR_file2}
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELLGRP-0
	...   filter_param=Number of transmitted Synchronization Signal Blocks   new_value=8 beams
    ${currentBeam}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELLGRP-0
    ...  filter_param=Number of transmitted Synchronization Signal Blocks
	run keyword if    '${currentBeam}'=='8 beams'    Validate and activate and check activate plan status
	run keyword if    '${currentBeam}'!='8 beams'    Activate parameter which need reset

"${Step}" Activate cell2 same BSR through WebEM
    Log To Console    "${Step}" Activate cell2 same BSR through WebEM
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-2
	...   filter_param=Activate Beamforming   new_value=true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    ...  filter_param=Activate custom beam set realization    new_value=true
	sleep    2s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-2
	...   filter_param=Basic Beam Set   new_value=beamSet_1
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-2
	...   filter_param=Custom Beam Set Name   new_value=${BSR_file1}
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELLGRP-1
	...  filter_param=Number of transmitted Synchronization Signal Blocks   new_value=4 beams
    ${currentBeam}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELLGRP-1
    ...   filter_param=Number of transmitted Synchronization Signal Blocks
	run keyword if    '${currentBeam}'=='4 beams'    Validate and activate and check activate plan status
	run keyword if    '${currentBeam}'!='4 beams'    Activate parameter which need reset

"${Step}" Check Inused basicBeamset
    Log To Console    "${Step}" Check Inused basicBeamset
	Wait Until Keyword Succeeds    5min    1min    Check Used Beamset    cellName=NRCELL-1    beamSetName=beamSet_4

"${Step}" Check Inused defaultBeamset
    Log To Console    "${Step}" Check Inused defaultBeamset
	Wait Until Keyword Succeeds    5min    1min    Check Used Beamset    cellName=NRCELL-1    beamSetName=beamSet_1

"${Step}" Check Inused BSR
    Log To Console    "${Step}" Check Inused BSR
	Wait Until Keyword Succeeds    5min    1min    Check Used Beamset    cellName=NRCELL-1    beamSetName=${BSR_file1}

"${Step}" Check Inused BSR2 Cell1
    Log To Console    "${Step}" Check Inused BSR
	Wait Until Keyword Succeeds    5min    1min    Check Used Beamset    cellName=NRCELL-1    beamSetName=${BSR_file2}

"${Step}" Check Inused BSR2
    Log To Console    "${Step}" Check Inused BSR
	Wait Until Keyword Succeeds    5min    1min    Check Used Beamset    cellName=NRCELL-2    beamSetName=${BSR_file2}

"${Step}" Check Inused same BSR
    Log To Console    "${Step}" Check Inused BSR
	Wait Until Keyword Succeeds    5min    1min    Check Used Beamset    cellName=NRCELL-2    beamSetName=${BSR_file1}

"${Step}" Check If there is new alarm
    Log To Console    "${Step}" Check If there is new alarm
	${alarmAfter}    Get Active Alarm
	${alarmDelta}    compare_Alarm    alarmName=${alarmBefore}    alarmNameNew=${alarmAfter}
	${ints}=	Create List    ${0}
	Should Be Equal    ${alarmDelta}    ${ints}

"${Step}" Disable feature 1866
    Log To Console    "${Step}" Disable feature 1866
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
	...  filter_param=Activate Beamforming   new_value=true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    ...   filter_param=Activate custom beam set realization    new_value=false
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
	...   filter_param=Basic Beam Set   new_value=beamSet_4
	sleep    1s
	run keyword and ignore error    selenium_coam.delete_parameter    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
	...   filter_param=Custom Beam Set Name
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELLGRP-0
	...   filter_param=Number of transmitted Synchronization Signal Blocks   new_value=4 beams
    sleep    1s
    ${currentBeam}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELLGRP-0
    ...   filter_param=Number of transmitted Synchronization Signal Blocks
	run keyword if    '${currentBeam}'=='4 beams'    Validate and activate and check activate plan status
	run keyword if    '${currentBeam}'!='4 beams'    Activate parameter which need reset

"${Step}" Update gNB SW
    Log To Console    "${Step}" Update gNB SW
	#selenium_coam.load_software_package_from_local_drive
	file_path=/home/ute/TA/AirScale-10.1800.227.zip
	#sleep    5s
	#selenium_coam.software_update
	#selenium_coam.disable_screen_lock
	#Wait Until Keyword Succeeds    25min    1min    Check SW Download Complete
	#selenium_coam.enable_screen_lock
	#selenium_coam.software_update    is_activate=True
	selenium_coam.reset_site
	sleep    10min
	
"${Step}" Trigger predefine basicBeamSet
    Log To Console    "${Step}" Trigger predefine basicBeamSet
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
	...   filter_param=Activate Beamforming   new_value=true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    ...   filter_param=Activate custom beam set realization    new_value=true
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
	...   filter_param=Basic Beam Set   new_value=beamSet_4
	sleep    1s
	run keyword and ignore error    selenium_coam.delete_parameter    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
	...   filter_param=Custom Beam Set Name
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELLGRP-0
	...   filter_param=Number of transmitted Synchronization Signal Blocks   new_value=4 beams
    sleep    3s
    ${currentBeam}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELLGRP-0
    ...   filter_param=Number of transmitted Synchronization Signal Blocks
	run keyword if    '${currentBeam}'=='4 beams'    Validate and activate and check activate plan status
	run keyword if    '${currentBeam}'!='4 beams'    Activate parameter which need reset

"${Step}" Trigger predefine defaultBeamSet
    Log To Console    "${Step}" Trigger predefine basicBeamSet
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
	...   filter_param=Activate Beamforming   new_value=true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    ...   filter_param=Activate custom beam set realization    new_value=true
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
	...   filter_param=Basic Beam Set   new_value=beamSet_1
	sleep    1s
	run keyword and ignore error    selenium_coam.delete_parameter    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
	...   filter_param=Custom Beam Set Name
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELLGRP-0
	...   filter_param=Number of transmitted Synchronization Signal Blocks   new_value=1 beam
    sleep    3s
    ${currentBeam}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELLGRP-0
    ...   filter_param=Number of transmitted Synchronization Signal Blocks
	run keyword if    '${currentBeam}'=='1 beam'    Validate and activate and check activate plan status
	run keyword if    '${currentBeam}'!='1 beam'    Activate parameter which need reset

Check Used Beamset
    [Arguments]    ${cellName}    ${beamSetName}
	${beamSetInused}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/${cellName}
	...   filter_param=Beam Set in Use
	Should Be Equal    ${beamSetInused}    ${beamSetName}

Get Active Alarm
    Log To Console   Get Active Alarm	
	${activeAlarm}    selenium_coam.get_active_alarm_info
	[Return]    ${activeAlarm}

Check SW Download Complete
    Log To Console    Check SW Download Complete
    ${updateProcess}    selenium_coam.check_software_update_progress
	#log    &{updateProcess}[percentage]
	Should Be Equal    ${updateProcess}[percentage]    100%

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
    csn.connect_to    hostname=${gNB IP}    username=${gNB account}    password=${gNB password}    alias=gNB
	
Activate parameter which need reset
	Validate and activate and check activate plan status
    sleep    3min
	Run Keyword And Ignore Error    Wait Until Keyword Succeeds    5min    1min    Check start up window exist
	run keyword and ignore error    selenium_coam.close_start_up_view_window
	run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
	run keyword and ignore error    selenium_coam.disable_message_box

Check start up window exist
    ${start_up}    selenium_coam.start_up_view_window_exists
	Should Be Equal    ${start_up}    True
