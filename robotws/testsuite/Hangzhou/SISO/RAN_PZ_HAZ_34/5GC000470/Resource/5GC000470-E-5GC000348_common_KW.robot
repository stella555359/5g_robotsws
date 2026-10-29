*** Settings ***
Documentation    Resource file used for  Feature 5GC000470-E-5GC000348 cases
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library           taf.sbts.oam.coam.admin    WITH NAME    coam

*** Variables ***


*** Keywords ***
"${Step}" Login gNB via WebUI
    log to console    Login gNB via WebUI
    WEBUI Login

"${Step}" Check HW led status
    log to console    Check HW led status
    Check unit led green    unit_with_index=RMOD-1
	Check unit led green    unit_with_index=BBMOD-1
    Check unit led green    unit_with_index=SMOD-1

"${Step}" Check HW components status
    log to console    Check HW components status
    Check GNSSE status well
    Check RMOD status well
	Check BBMOD status well
    Check SMOD status well

"${Step}" Check HW information
    log to console    Check HW information
    Check RMOD info
	Check BBMOD info
    Check SMOD info
	
"${Step}" Check EQM subTree display normal
    log to console    Check EQM subTree display normal
	Check EQM subTree contain RMOD
	Check EQM subTree contain BBMOD
	Check EQM subTree contain SMOD
	
	
Check unit led green
    [Arguments]    ${unit_with_index}
    ${led_status}   selenium_coam.get_led_status_of_an_unit    unit=${unit_with_index}
    should be equal    ${led_status}     Enabled

Check GNSSE status well
    log to console    GNSSE status
	run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_tmp}    selenium_coam.get_gnss_info
    ${output}    set variable    ${output_tmp}[Status]
    should be equal      ${output}[Administrative state]    Unlocked
    #should be equal      ${output}[Availability status]     Online
    should be equal      ${output}[Operational state]     enabled

Check RMOD status well
    log to console    RMOD status
	check RU STATUS

Check BBMOD status well
    log to console    BBMOD status
	Check ABIL is UP

Check SMOD status well
    log to console    SMOD status
	run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_tmp}    selenium_coam.get_hw_parameters    hw_type=SMOD    index=1
	${output}    set variable    ${output_tmp}[Runtime parameters]
    #should be equal      &{output}[Administrative state]    Unlocked
	#should be equal      &{output}[Availability status]    Online
    should be equal      ${output}[Procedural status]     configured
    should be equal      ${output}[Operational state]     enabled

Compare_value
    [Arguments]    ${dist_name}    ${P_code}   ${P_name}    ${S_NO}
	#${dist_name}    set variable    MRBTS-${mrbts_id}/${DSN}
	${P_code_2}    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=Product code
	${P_name_2}    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=Product name
	${S_NO_2}    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=Serial number
	should be equal      ${P_code}    ${P_code_2}
    should be equal      ${P_name}    ${P_name_2}
    should be equal      ${S_NO}     ${S_NO_2}

Check SMOD info
    log to console    SMOD info
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output}    selenium_coam.get_hw_parameters    hw_type=SMOD    index=1
	${output_tmp}    set variable    ${output}[Runtime parameters]
	${P_code_smod}    set variable    ${output_tmp}[Product code]
	${P_name_smod}    set variable    ${output_tmp}[Product name]
	${S_NO_smod}    set variable    ${output_tmp}[Serial number]
	Compare_value    dist_name=MRBTS-${mrbts_id}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
	...    P_code=${P_code_smod}    P_name=${P_name_smod}    S_NO=${S_NO_smod}

Check RMOD info
    log to console    RMOD info
	run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_tmp}    selenium_coam.get_ru_info
	${P_code_rmod}    set variable    ${output_tmp}[Product code]
	${P_name_rmod}    set variable    ${output_tmp}[Product name]
	${S_NO_rmod}    set variable    ${output_tmp}[Serial number]
	Compare_value    dist_name=MRBTS-${mrbts_id}/EQM_R-1/APEQM_R-1/RMOD_R-1
	...    P_code=${P_code_rmod}    P_name=${P_name_rmod}    S_NO=${S_NO_rmod}
	
Check BBMOD info
    log to console    BBMOD info
	run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_tmp}    selenium_coam.get_abil_info
	${P_code_bbmod}    set variable    ${output_tmp}[Product code]
	${P_name_bbmod}    set variable    ${output_tmp}[Product name]
	${S_NO_bbmod}    set variable    ${output_tmp}[Serial number]
	Compare_value    dist_name=MRBTS-${mrbts_id}/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1
	...    P_code=${P_code_bbmod}    P_name=${P_name_bbmod}    S_NO=${S_NO_bbmod}	
	
Check EQM subTree contain RMOD
	  run keyword and ignore error    coam.teardown    connection=GNB_OAM
    coam.connect_to    bts_host=${asik_addr}    name=GNB_OAM
    ${hw_info}    coam.get_detected_hw_info    connection=GNB_OAM
    ${frm}    coam.get_frm    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
	  ${dist_name}    set variable    ${frm[0]['id']['runtime']}
    ${administrative_state}    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=Administrative state
    should be equal    ${administrative_state}    Unlocked    ignore_case=True
    #${availability_status}    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=Availability status
    #should be equal    ${availability_status}    Toggle Dropdown    ignore_case=True
    ${operational_state}    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=Operational state
    should be equal    ${operational_state}    enabled    ignore_case=True
    ${procedural_status}    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=Procedural status
    should be equal    ${procedural_status}    configured    ignore_case=True

Check EQM subTree contain BBMOD
    coam.connect_to    bts_host=${asik_addr}    name=GNB_OAM
    ${hw_info}    coam.get_detected_hw_info    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${dist_name}    set variable    ${hw_info['basebandModules'][0]['id']['runtime']}
    ${administrative_state}    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=Administrative state
    should be equal    ${administrative_state}    Unlocked    ignore_case=True
	${operational_state}    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=Operational state
    should be equal    ${operational_state}    enabled    ignore_case=True
    ${procedural_status}    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=Procedural status
    should be equal    ${procedural_status}    configured    ignore_case=True
	
Check EQM subTree contain SMOD
    coam.connect_to    bts_host=${asik_addr}    name=GNB_OAM
    ${hw_info}    coam.get_detected_hw_info    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${dist_name}    set variable    ${hw_info['systemModules'][0]['id']['runtime']}
    ${operational_state}    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=Operational state
    should be equal    ${operational_state}    enabled    ignore_case=True
    ${procedural_status}    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=Procedural status
    should be equal    ${procedural_status}    configured    ignore_case=True
