*** Settings ***
Documentation     author: Fred Li
...               Group: HGZ_SG7
...               contact: fred.li@nokia-sbell.com

Library           ../libraries/compare_alarm.py
Resource          ../../common/coam_resource.robot
Library       taf.transport.ssh   WITH NAME   csn
Library      ../libraries/ru.py
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    ../../common${/}coam_resource.robot

*** Variables ***
${DU_Username}      ${asik_username}
${DU_Password}      ${asik_password}
${VM_IP}            ${host_addr}
${VM_username}      ${host_username}
${VM_password}      ${host_password}
#${BSR_name}    BSR_${ru_type}_4_H4_ALN60_ARP60_P00_COVERAGE_00422_00001.zip

*** Keywords ***
Check gNB and Cell onAir
    Log To Console    Check gNB and Cell onAir
	run keyword and ignore error    selenium_coam.close_start_up_view_window
	run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
	run keyword and ignore error    selenium_coam.disable_message_box
    Wait Until Keyword Succeeds    30min    1min    check gNB Staus onAir
    ...  dist_name=MRBTS-${btsId}/NRBTS-${btsId}    search_text=Operational state
    sleep    5s

Read Current RU Type
    COAM Login   alias=ru_info
    ${bts_info}   coam.get_bts_info   connection=ru_info   timeout=${30}
    ${ru_type_info}   Create Dictionary
    FOR   ${rmod}   IN   @{bts_info['radioModules']['rmod']}
        ${rmod_index}   Set Variable   ${rmod['id']['configuration'].split("/")[-1].split("-")[-1]}
        Set To Dictionary   ${ru_type_info}   ${rmod_index}   ${rmod['productName']}
    END
    ${ru_list}   Get Dictionary Values   ${ru_type_info}
    ${ru_no_dup_list}   RU List To Str   ru_list=${ru_list}
    ${ru_type}   Evaluate   "+".join(${ru_no_dup_list})
    Set Test Variable    ${ru_type}
#    Set suite Variable
    [Return]   ${ru_type}
    [Teardown]   COAM Logout   connection=ru_info

Download BSR package
    [Arguments]    ${BSR_path}=/home/ute/BSR_${ru_type}_4_H4_ALN60_ARP60_P00_COVERAGE_00422_00001.zip
    Log To Console     Download BSR package
	selenium_coam.load_software_package_from_local_drive    file_path=${BSR_path}
	sleep    5s
	selenium_coam.software_update    is_activate=${True}

Check installed BSR
    Log To Console     Check installed BSR
	${beamSetInstall}    selenium_coam.get_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}
	...  filter_param=Beam set installed    node_index=${0}
	Should Be Equal    ${beamSetInstall}    BSR_${ru_type}_4_H4_ALN60_ARP60_P00_COVERAGE_00422_00001

Enable feature 1866
    Log To Console     Enable feature 1866
	selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-2
	...   filter_param=Activate Beamforming   new_value=true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}
    ...  filter_param=Activate custom beam set realization    new_value=true
    Validate and activate and check activate plan status

Check If there is new alarm
    Log To Console     Check If there is new alarm
	${alarmAfter}    Get Active Alarm
	${alarmDelta}    compare_Alarm    alarmName=${alarmBefore}    alarmNameNew=${alarmAfter}
	${ints}=	Create List    ${0}
	Should Be Equal    ${alarmDelta}    ${ints}

Get Active Alarm
    Log To Console   Get Active Alarm
	${activeAlarm}    selenium_coam.get_active_alarm_info
	[Return]    ${activeAlarm}

Get BTS Id online
    run keyword and ignore error    selenium_coam.close_start_up_view_window
	run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
	run keyword and ignore error    selenium_coam.disable_message_box
    ${btsId}    selenium_coam.get_bts_id
	set suite variable    ${btsId}
	${alarmBefore}    Get Active Alarm
    set suite variable    ${alarmBefore}

Close feature 1866
    Log To Console     close feature 1866
    run keyword and ignore error    WEBUI Login
    selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}
    ...  filter_param=Activate custom beam set realization    new_value=false
    Validate and activate and check activate plan status

Activate BSR through WebEM
    Log To Console     Activate BSR through WebEM
	selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-2
	...  filter_param=Activate Beamforming   new_value=true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}
    ...  filter_param=Activate custom beam set realization    new_value=true
	sleep    2s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-2
	...  filter_param=Basic Beam Set   new_value=beamSet_1
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-2
	...  filter_param=Left Cell Edge Angle   new_value=60
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-2
	...  filter_param=Right Cell Edge Angle   new_value=60
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-2
	...   filter_param=Custom Beam Set Name   new_value=BSR_${ru_type}_4_H4_ALN60_ARP60_P00_COVERAGE_00422_00001
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELLGRP-1
	...   filter_param=Number of transmitted Synchronization Signal Blocks   new_value=4 beams
    ${currentBeam}    selenium_coam.get_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELLGRP-1
    ...   filter_param=Number of transmitted Synchronization Signal Blocks
	run keyword if    '${currentBeam}'=='4 beams'    Validate and activate and check activate plan status
	run keyword if    '${currentBeam}'!='4 beams'    Activate parameter which need reset

#Recover Configuration through WebEM
#    Log To Console    recover configuration through webem Configuration
#

Check Inused BSR
    Log To Console     Check Inused BSR
	Wait Until Keyword Succeeds    5min    1min    Check Used Beamset    cellName=NRCELL-2
	...    beamSetName=BSR_${ru_type}_4_H4_ALN60_ARP60_P00_COVERAGE_00422_00001

Check BSR not Inuse
    Log To Console     Check BSR bot Inuse
	Wait Until Keyword Succeeds    5min    1min    Check Used Beamset    cellName=NRCELL-2    beamSetName=beamSet_4

Disable feature 1866
    Log To Console     Disable feature 1866
    run keyword and ignore error     COAM WEBUI Login
	selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-2
	...  filter_param=Activate Beamforming   new_value=true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}
    ...   filter_param=Activate custom beam set realization    new_value=false
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-2
	...   filter_param=Basic Beam Set   new_value=beamSet_4
	sleep    1s
	run keyword and ignore error    selenium_coam.delete_parameter    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELL-2
	...   filter_param=Custom Beam Set Name
	sleep    1s
	selenium_coam.set_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELLGRP-1
	...   filter_param=Number of transmitted Synchronization Signal Blocks   new_value=4 beams
    sleep    1s
    ${currentBeam}    selenium_coam.get_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/NRCELLGRP-1
    ...   filter_param=Number of transmitted Synchronization Signal Blocks
	run keyword if    '${currentBeam}'=='4 beams'    Validate and activate and check activate plan status
	run keyword if    '${currentBeam}'!='4 beams'    Activate parameter which need reset

Check Used Beamset
    [Arguments]    ${cellName}    ${beamSetName}
	${beamSetInused}    selenium_coam.get_parameter_value    dist_name=MRBTS-${btsId}/NRBTS-${btsId}/${cellName}
	...   filter_param=Beam Set in Use
	Should Be Equal    ${beamSetInused}    ${beamSetName}

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

Delete BSR XML
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   ${host}   ${username}   ${password}   alias=rm_bsr
    csn.Execute   rm /rom/TargetBD_BSR_*    connection=rm_bsr
    [Teardown]   csn.Disconnect   connection=rm_bsr

