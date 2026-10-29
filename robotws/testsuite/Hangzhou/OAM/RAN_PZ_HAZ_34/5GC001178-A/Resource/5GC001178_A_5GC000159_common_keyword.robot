*** Settings ***
Documentation     author: zora zhang
...               Group: HGZ_SG5
...               contact: zora.zhang@nokia-sbell.com

#Library           taf.transport.ssh    WITH NAME    csn
Library           ./../../libraries/get_bts_info.py    WITH NAME    lib
Resource          ./../../common/coam_resource.robot
Library           ./../../libraries/compare_alarm_list.py
Library            OperatingSystem
Library            Process

*** Variables ***
${create_backup_dir}        backupscf/

*** Keywords ***

"${Step}" Confirm cell is onair
    Log To Console    "${Step}" Confirm cell is onair
    wait until keyword succeeds    10mins    1min    Check gNB status onAir

Get MRBTS Id
    log to console    Get MRBTS Id online
	${mrbtsId}    Wait Until Keyword Succeeds    2min    10s    selenium_coam.get_bts_id
    ${mrbts_id}=    Set Variable    MRBTS-${mrbtsId}
    set suite variable    ${mrbts_id}
    sleep    2s

Get NRBTS Id
    log to console    Get NRBTS Id online
    ${nrbtsId}    Wait Until Keyword Succeeds    2min    10s    selenium_coam.get_bts_id
    ${nrbts_id}=    Set Variable    NRBTS-${nrbtsId}
    set suite variable    ${nrbts_id}
    sleep    2s

Check gNB status onAir
    Log To Console    	Check gNB status onAir
    Log to Console  "${mrbts_id}/${nrbts_id}"
    ${gnb_state}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/${nrbts_id}
    ...    filter_param=Operational state    abbr=operationalState    timeout=60
    set suite variable    ${gnb_state}
    should be equal     ${gnb_state}   onAir
	sleep    2s

Validate and activate
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=20
    sleep    3s

"${Step}" Check Operational State of gNB
    Log To Console    "${Step}" Check Operational State of gNB
    Log to Console  "${mrbts_id}/${nrbts_id}"
    ${gnb_state}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/${nrbts_id}
    ...    filter_param=Operational state    abbr=operationalState    timeout=60
    set suite variable    ${gnb_state}
    should be equal     ${gnb_state}   onAir
    sleep    2s
  
"${Step}" Check Operational State of SMOD
    Log To Console    "${Step}" Check Operational State of SMOD
    ${smod_Ope_state}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
    ...    filter_param=Operational state    abbr=operationalState    timeout=60
    set suite variable    ${smod_Ope_state}
    should be equal     ${smod_Ope_state}   enabled
    sleep    2s

"${Step}" Check Availability Status of SMOD
    Log To Console    "${Step}" Check Availability Status of SMOD
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_tmp}    selenium_coam.get_asik_info
    ${output}    set variable    ${output_tmp}[Status]
    should be equal      ${output}[Availability status]     Online
    sleep    2s

"${Step}" Check Procedural Status of SMOD
    Log To Console    "${Step}" Check Procedural Status of SMOD
    ${smod_Pro_state}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
    ...    filter_param=Procedural status    abbr=proceduralStatus    timeout=60
    set suite variable    ${smod_Pro_state}
    should be equal     ${smod_Pro_state}   configured
    sleep    2s

"${Step}" Check Operational status of BBMOD
    Log To Console    "${Step}" Check Procedural status of BBMOD
    ${bbmod_Ope_state}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1
    ...    filter_param=Operational state    abbr=operationalState    timeout=60
    set suite variable    ${bbmod_Ope_state}
    should be equal     ${bbmod_Ope_state}    enabled
    sleep    2s

"${Step}" Check Availability status of BBMOD
    Log To Console    "${Step}" Check Availability status of BBMOD
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_tmp}    selenium_coam.get_abil_info
    ${output}    set variable    ${output_tmp}[Status]
    should be equal      ${output}[Availability status]     Online
    sleep    2s

"${Step}" Check Procedural status of BBMOD
    Log To Console    "${Step}" Check Procedural status of BBMOD
    ${bbmod_Pro_state}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1
    ...    filter_param=Procedural status    abbr=proceduralStatus    timeout=60
    set suite variable    ${bbmod_Pro_state}
    should be equal     ${bbmod_Pro_state}   configured
    sleep    2s

"${Step}" Check Administrative State of BBMOD
    Log To Console    "${Step}" Check Administrative State of BBMOD
    ${bbmod_Admi_state}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1
    ...    filter_param=Administrative state   abbr=administrativeState    timeout=60
    set suite variable    ${bbmod_Admi_state}
    should be equal     ${bbmod_Admi_state}   Unlocked
    sleep    2s

"${Step}" Check Operational state of GNSS
    Log To Console    "${Step}" Check Operational state of GNSS
    ${gnss_Ope_state}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/GNSSE_R-1
    ...    filter_param=Operational state   abbr=operationalState   timeout=60
    set suite variable    ${gnss_Ope_state}
    should be equal     ${gnss_Ope_state}   enabled
    sleep    2s

"${Step}" Check Availability status of GNSS
    Log To Console    "${Step}" Check Availability status of GNSS
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_tmp}    selenium_coam.get_gnss_info
    ${output}    set variable    ${output_tmp}[Status]
    should be equal      ${output}[Availability status]     Online
    sleep    2s

"${Step}" Check Administrative State of RMOD
    Log To Console    "${Step}" Check Administrative State of RMOD
    ${rmod_Admi_state}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...    filter_param=Administrative state   abbr=administrativeState    timeout=60
    set suite variable    ${rmod_Admi_state}
    should be equal    ${rmod_Admi_state}   Unlocked
    sleep    2s

"${Step}" Check Operational state of RMOD
    Log To Console    "${Step}" Check Operational state of RMOD
    ${rmod_Ope_state}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...    filter_param=Operational state   abbr=operationalState   timeout=60
    set suite variable    ${rmod_Ope_state}
    should be equal    ${rmod_Ope_state}   enabled
    sleep    2s

"${Step}" Check Availability status of RMOD
    Log To Console    "${Step}" Check Availability status of RMOD
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_tmp}    selenium_coam.get_ru_info
    ${output}    set variable    ${output_tmp}[Status]
    should be equal      ${output}[Availability status]     Online
    sleep    2s

"${Step}" Check Procedural status of RMOD
    Log To Console    "${Step}" Check Procedural status of RMOD
    ${rmod_Ope_state}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...    filter_param=Procedural status    abbr=proceduralStatus    timeout=60
    set suite variable    ${rmod_Ope_state}
    should be equal     ${rmod_Ope_state}   configured
    sleep    2s

"${Step}" Check Administrative State of CELL
    Log To Console    "${Step}" Check Administrative State of CELL
    ${cell_Admi_state}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/${nrbts_id}/NRCELL-1
    ...    filter_param=Administrative state   abbr=administrativeState    timeout=60
    set suite variable    ${cell_Admi_state}
    should be equal    ${cell_Admi_state}   Unlocked
    sleep    2s

"${Step}" Check Operational state of CELL
    Log To Console    "${Step}" Check Operational state of CELL
    ${cell_Ope_state}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/${nrbts_id}/NRCELL-1
    ...    filter_param=Operational state    abbr=operationalState    timeout=60
    set suite variable    ${cell_Ope_state}
    should be equal     ${cell_Ope_state}   enabled
    sleep    2s

"${Step}" Check Availability status of CELL
    Log To Console    "${Step}" Check Availability status of CELL
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_tmp}    selenium_coam.get_cell_info
    ${output}    set variable    ${output_tmp}[Status]
    should be equal      ${output}[Availability status]     Online
    sleep    2s

"${Step}" Check Procedural status of CELL
    Log To Console    "${Step}" Check Procedural status of CELL
    ${cell_Pro_state}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/${nrbts_id}/NRCELL-1
    ...    filter_param=Procedural status    abbr=proceduralStatus    timeout=60
    set suite variable    ${cell_Pro_state}
    should be equal     ${cell_Pro_state}   configured
    sleep    2s


"${Step}" Check Alarm
    Log To Console    "${Step}" Check alarm
    @{alarm_info}=    Wait Until Keyword Succeeds    5min    10s    selenium_coam.get_active_alarm_info    timeout=100
    sleep    5s
    Set Suite Variable    @{alarm_info}

"${Step}" Check If there is new alarm
    Log To Console    "${Step}" Check If there is new alarm
    @{alarm_new1}=    Wait Until Keyword Succeeds    5min    10s    selenium_coam.get_active_alarm_info    timeout=100
    @{alarm_new2}    ignore_Alarm    alarmList=@{alarm_new1}    ignoreAlarm=7220
    @{alarm_new3}    ignore_Alarm    alarmList=@{alarm_new1}    ignoreAlarm=7116
    @{alarm_new4}    ignore_Alarm    alarmList=@{alarm_new1}    ignoreAlarm=61050
    @{alarm_result}    compare_Alarm    alarmName=@{alarm_info}    alarmNameNew=@{alarm_new1}
    Set Suite Variable    ${alarm_result}
    Should Be Equal    ${alarm_result}    ${0}
    sleep    5s

Remove CMD object
    Log To Console     Delete CMD parameter
    run keyword and ignore error    selenium_coam.remove_object    CMD-1
    Validate and activate and check activate plan status
    sleep    2s

Check GNSS status changed
    &{GNSS_info1}    Wait Until Keyword Succeeds    2min    2s    selenium_coam.get_gnss_info
    ${GNSS_status1}    set variable    ${GNSS_info1}[Status]
    should be equal    ${GNSS_status1}[Operational state]    Disabled    ignore_case=True

Check Cell status changed
    &{Cell_info1}    Wait Until Keyword Succeeds    2min    2s    selenium_coam.get_cell_info
    ${Cell_status1}    set variable    ${Cell_info1}[Status]
    should be equal    ${Cell_status1}[Operational state]    Disabled    ignore_case=True
    should be equal    ${Cell_status1}[Procedural status]    not initialized    ignore_case=True
    should be equal    ${Cell_status1}[Availability status]    Failed   ignore_case=True
    should be equal    ${Cell_status1}[Administrative state]    Unlocked    ignore_case=True

Check RU status changed
    &{RU_info1}    Wait Until Keyword Succeeds    2min    2s    selenium_coam.get_ru_info
    ${RU_status1}    set variable    ${RU_info1}[Status]
    should be equal    ${RU_status1}[Operational state]    Disabled    ignore_case=True
    should be equal    ${RU_status1}[Procedural status]    not initialized    ignore_case=True
    should be equal    ${RU_status1}[Availability status]    NotInstalled    ignore_case=True
    should be equal    ${RU_status1}[Administrative state]    Unlocked    ignore_case=True

Check normal GNSS status
    Log To Console    Check normal GNSS status
    &{GNSS_info2}    Wait Until Keyword Succeeds    10min    30s    selenium_coam.get_gnss_info
    ${GNSS_status2}    set variable    ${GNSS_info2}[Status]
    should be equal    ${GNSS_status2}[Operational state]     Enabled    ignore_case=True
    should be equal    ${GNSS_status2}[Availability status]    Online   ignore_case=True
    should be equal    ${GNSS_status2}[Administrative state]    Unlocked    ignore_case=True

Check normal Cell status
    &{Cell_info2}    Wait Until Keyword Succeeds    2min    2s    selenium_coam.get_cell_info
    ${Cell_status2}    set variable    ${Cell_info2}[Status]
    should be equal    ${Cell_status2}[Operational state]    Enabled    ignore_case=True
    should be equal    ${Cell_status2}[Procedural status]    configured    ignore_case=True
    should be equal    ${Cell_status2}[Availability status]    Online   ignore_case=True
    should be equal    ${Cell_status2}[Administrative state]    Unlocked    ignore_case=True

Check normal RU status
    &{RU_info2}    Wait Until Keyword Succeeds    2min    2s    selenium_coam.get_ru_info
    ${RU_status2}    set variable    ${RU_info2}[Status]
    should be equal    ${RU_status2}[Operational state]    Enabled    ignore_case=True
    should be equal    ${RU_status2}[Procedural status]    configured    ignore_case=True
    should be equal    ${RU_status2}[Availability status]    Online    ignore_case=True
    should be equal    ${RU_status2}[Administrative state]    Unlocked    ignore_case=True

Get HWRESETRES-1 value
    Log To Console    Get HWRESETRES-1 value
    ${hwReset_resault}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/MNL-1/CMD-1/HWRESETREQ-1/HWRESETRES-1
    ...    filter_param=HW reset result
    set suite variable    ${hwReset_resault}
    should be equal     ${hwReset_resault}   success
    sleep    2s

Get unormal status of cell
    &{Cell_info3}    Wait Until Keyword Succeeds    2min    2s    selenium_coam.get_cell_info
    ${Cell_status3}    set variable    ${Cell_info3}[Status]
    should be equal    ${Cell_status3}[Operational state]    Disabled    ignore_case=True
    should be equal    ${Cell_status3}[Procedural status]    configured    ignore_case=True
    should be equal    ${Cell_status3}[Availability status]    Dependency   ignore_case=True
    should be equal    ${Cell_status3}[Administrative state]    Unlocked    ignore_case=True

Unlock cell via WEBUI
    Log To Console    Unlock cell via WEBUI
    run keyword and ignore error    selenium_coam.unlock_cell
    sleep    20s
    ${cell_unlock}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/${nrbts_id}/NRCELL-1
    ...    filter_param=Administrative state    abbr=administrativeState    timeout=60
    set suite variable    ${cell_unlock}
    should be equal    ${cell_unlock}    Unlocked
    sleep    5s

Confirm cell status is locked
    &{Cell_locked}    Wait Until Keyword Succeeds    3min    2s    selenium_coam.get_cell_info
    ${Cell_Locked}    set variable    ${Cell_locked}[Status]
    should be equal    ${Cell_Locked}[Operational state]    Disabled    ignore_case=True
    should be equal    ${Cell_Locked}[Procedural status]    initialization required    ignore_case=True
    should be equal    ${Cell_Locked}[Availability status]    offline   ignore_case=True
    should be equal    ${Cell_Locked}[Administrative state]    Locked    ignore_case=True

Unlock cell_group via WEBUI
    Log To Console    Unlock cell_group via WEBUI
    run keyword and ignore error    selenium_coam.unlock_cell_group
    sleep    20s

Unlock RU via WEBUI
    Log To Console    Unlock RU via WEBUI
    run keyword and ignore error    selenium_coam.unlock_ru
    sleep    20s
    ${RU_unlock}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Administrative state    abbr=administrativeState    timeout=60
    set suite variable    ${RU_unlock}
    should be equal     ${RU_unlock}    Unlocked
    sleep    2s

Unlock BBMOD via WEBUI
    Log To Console    Unlock BBMOD via WEBUI
    run keyword and ignore error    selenium_coam.unlock_abil
    sleep    20s
    ${abil_unlock}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1
    ...    filter_param=Administrative state    abbr=administrativeState    timeout=60
    set suite variable    ${abil_unlock}
    should be equal     ${abil_unlock}    Unlocked
    sleep    2s

Check normal BBMOD status
    &{BBMOD_info}    Wait Until Keyword Succeeds    2min    2s    selenium_coam.get_abil_info
    ${BBMOD_status}    set variable    ${BBMOD_info}[Status]
    should be equal    ${BBMOD_status}[Operational state]    Enabled    ignore_case=True
    should be equal    ${BBMOD_status}[Procedural status]    configured    ignore_case=True
    should be equal    ${BBMOD_status}[Administrative state]    Unlocked    ignore_case=True
    should be equal    ${BBMOD_status}[Availability status]    Online    ignore_case=True

Check BBMOD status changed
    &{BBMOD_info}    Wait Until Keyword Succeeds    2min    2s    selenium_coam.get_abil_info
    ${BBMOD_status}    set variable    ${BBMOD_info}[Status]
    should be equal    ${BBMOD_status}[Operational state]    Disabled    ignore_case=True
    should be equal    ${BBMOD_status}[Procedural status]    initializing    ignore_case=True
    should be equal    ${BBMOD_status}[Administrative state]    Unlocked    ignore_case=True
    should be equal    ${BBMOD_status}[Availability status]    Offline    ignore_case=True

Check normal ASIK status
    &{ASIK_info}    Wait Until Keyword Succeeds    2min    2s    selenium_coam.get_asik_info
    ${ASIK_status}    set variable    ${ASIK_info}[Status]
    should be equal    ${ASIK_status}[Operational state]    Enabled    ignore_case=True
    should be equal    ${ASIK_status}[Procedural status]    configured    ignore_case=True
    should be equal    ${ASIK_status}[Administrative state]    Unlocked    ignore_case=True
    should be equal    ${ASIK_status}[Availability status]    Online    ignore_case=True

Check ASIK status changed
    &{ASIK_info}    Wait Until Keyword Succeeds    2min    2s    selenium_coam.get_asik_info
    ${ASIK_status}    set variable    ${ASIK_info}[Status]
    should be equal    ${ASIK_status}[Operational state]    Disabled    ignore_case=True
    should be equal    ${ASIK_status}[Availability status]    Failed    ignore_case=True
    should be equal    ${ASIK_status}[Procedural status]    configured    ignore_case=True

Unlock BTS via WEBUI
    Log To Console    Unlock BTS via WEBUI
    run keyword and ignore error    selenium_coam.unlock_bts
    sleep    20s
    ${bts_unlock}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/${nrbts_id}
    ...    filter_param=Operational state   abbr=operationalState    timeout=60
    set suite variable    ${bts_unlock}
    should be equal     ${bts_unlock}    onAir
    sleep    2s
    ${DU_unlock}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/${nrbts_id}/NRDU-1
    ...    filter_param=Administrative state   abbr=administrativeState    timeout=60
    set suite variable    ${DU_unlock}
    should be equal     ${DU_unlock}    Unlocked
    sleep    2s


Case setup
    cOAM Common Test Setup
    WEBUI Login
    Obtain_BTS_Name_ID
    #Get NRBTS Id
    #Get MRBTS Id

Obtain_BTS_Name_ID
    Backup_SCF_file_on_WebEM
    ${mrbtsId}    lib.Get_MRBTSID_cOAM    scf_path=${scf_file_path}
    ${nrbtsId}    lib.Get_NRBTSID_cOAM    scf_path=${scf_file_path}
    set suite variable     ${mrbtsId}
    set suite variable     ${nrbtsId}
    ${mrbts_id}=    Set Variable    MRBTS-${mrbtsId}
    set suite variable    ${mrbts_id}
    ${nrbts_id}=    Set Variable    NRBTS-${nrbtsId}
    set suite variable    ${nrbts_id}
    ${BTS_Name}    Wait Until Keyword Succeeds    2min    10s
    ...    selenium_coam.get_parameter_value    dist_name=${mrbts_id}     filter_param=BTS name
    set suite variable     ${BTS_Name}

Backup_SCF_file_on_WebEM
    log to console    Backup_SCF_file_on_WebEM
    ${flag_result}   ${scf_file}    Run Keyword And Ignore Error    selenium_coam.backup_bts_site_configuration    download_timeout=600
    sleep    5s
    ${scf_file_path}    OperatingSystem.Copy File    ${scf_file}    ${SAVE LOG DIRECTORY}
    set suite variable     ${scf_file_path}
