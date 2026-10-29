*** Settings ***
Documentation     author: Meiya Cheng
...               contact: meiya.cheng@nokia-sbell.com
...               squad group: SG_07
Force Tags            
...    PY36

Library    taf.analyzer.pcap     WITH NAME    pcap
Resource        ./resources/common_1732.robot
Resource        ../../../resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Suite Setup    robot_common_operations.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown


*** Variables ***

${du_scf_name}    /home/ute/CB007608/load-334_1937.xml
${full_path1}     CELLS/NRCELL-1/NCELA/DL_SLOT_DUMMY_PDSCH
${full_path2}     CELLS/NRCELL-2/NCELA/DL_SLOT_DUMMY_PDSCH

${local_path}      /home/ute/CB007608
${filters}           uldata_pucchreceiverespharqd
${LUA_SCRIPT_PATH}    /home/ute/generated_luashark/luashark.lua

${tshark_path}    /usr/bin/tshark
${command_template_with_Y}       tshark -r {pcap_file} -Y \"uldata_pucchreceiverespharqd\" -T pdml


*** Test Cases ***
#[1]5GC000526_A_Generating_artificial_load_on_SSB_beams_SU_MIMO__one_abil_random_beam_mmWaves
[1][1.0] 5GC000526_A_Generating_artificial_load_on_SSB_beams_SU_MIMO_one_abil_random_beam_mmWaves_case
    [Documentation]    This test case shall validate the artificial load generation procedure on SSB in a cell that uses analog beamforming.
    [Tags]    CIT_20B
    [Setup]    robot_common_operations.Common Case Setup
	#5GC001937_AEWB.Common Setup
	Commissioning 2CC scf
	Du login page via webUI
	set targetTotalLoad in webui
	Sleep    310s
    ${value_newest}    GetBtsCounter_value    counter_id=M55308C00007    full_path=${full_path1}
	should not be equal    ${value_newest}    ${0}
	${value_newest}    GetBtsCounter_value    counter_id=M55308C00007    full_path=${full_path2}
	should be equal    ${value_newest}    ${0}
	
    ${bip_log_path}    ASIL Common Capture BIP log and download
	${filter_result}    Filter PDML from bip    pcap_file=${bip_log_path}
	should be empty  ${filter_result}
    [Teardown]    Cases Common teardown

*** Keywords ***
Commissioning 2CC scf
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${du_scf_name}
    ...                              timeout=${600}    is_pdl_checking_needed=${False}
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air


Filter PDML from bip
    [Documentation]    Author: meiya.cheng
    ...    Description: Filter PDML from bip
    [Arguments]    ${pcap_file}
    ${filtered_packets}    Check pcaplog with filter    pcap_file=${pcap_file}    filter_expression=${filters}
    ...    command_template=${command_template_with_Y}
	${values}   pcap.Get Field Value By Name    field_name=${filters}    attribute_name=show 
    [Return]    ${values}	
	
Check pcaplog with filter
    [Documentation]    Author: meiya.cheng
    ...    Description: Check pcaplog with filter
    [Arguments]    ${pcap_file}    ${filter_expression}    ${command_template}=${None}
    ${all_packets}=    pcap.load_pcap_file    pcap_file=${pcap_file}    command_template=${command_template}
    ${filtered_packets}=    pcap.Filter Packets By Expression    filter_expression=${filter_expression}
    [Return]    ${filtered_packets}
	
GetBtsCounter_value
    [Documentation]    Author: meiya.cheng
    ...    Description: get bts counter's and return for check
    [Arguments]    ${counter_id}    ${full_path}
    ${date}    DateTime.Get Current Date    exclude_millis=True
    ${res}    wait until keyword succeeds    1 min    5 sec
    ...    selenium_coam.get_bts_counters_info    counter_id=${counter_id}    full_path=${full_path}
    ${values}    get dictionary values    ${res}
	${value_newest}    Evaluate    expression=${values[-1]} 
    [return]    ${value_newest}

Cases common Setup
    [Documentation]    Author: meiya.cheng
    ...                Description: case common setup
    Sleep    2s

set targetTotalLoad in webui
    [Documentation]  Author:meiya.cheng
    ...              Description: restore targetTotalLoad
	${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-1/NRCELL-1
    ...    abbr=targetTotalLoad
    ...    new_value=100
    ...    filter_param=Target total load with artificial load
    sleep    1s
    selenium_coam.validate_plan
    sleep    8s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
	
Restore targetTotalLoad in webui
    [Documentation]  Author:meiya.cheng
    ...              Description: restore targetTotalLoad
	${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-1/NRCELL-1
    ...    abbr=targetTotalLoad
    ...    new_value=0
    ...    filter_param=Target total load with artificial load
    sleep    1s
    selenium_coam.validate_plan
    sleep    8s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
	
Cases Common teardown
    [Documentation]    Author: meiya.cheng
    ...                Description: case common teardown
    robot_common_operations.Common Case Teardown
	Restore targetTotalLoad in webui
	Run Keyword And Ignore Error    run    command=rm -rf ${bip_log_path}
	DU COAM selenium logout






