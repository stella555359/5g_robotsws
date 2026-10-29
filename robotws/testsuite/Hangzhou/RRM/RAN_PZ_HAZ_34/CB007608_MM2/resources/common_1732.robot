*** Settings ***
Documentation      author: meiya cheng
...                Group: I_NSB_MN_5GSC_MMW_SC_PZ_HZ_02_GMS
...                contact: meiya.cheng@nokia-sbell.com
...                Description
Library            OperatingSystem
Library            Process
Library            String
Library            DateTime
Library            taf.transport.ssh    WITH NAME    ssh
Library            Collections

#Resource           ../../../../resources/sites/Hangzhou/PROD/robot/coam_siso_common.robot
#Resource           ../../../../Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
#Resource           ../../../../resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Resource     ../../../../resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
#Resource        ../../../../resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot

*** Variables ***
${x2_check_measGap}    .//x2ap.SgNBModificationRequest_element//nr-rrc.CG_ConfigInfo_element
${logPath}        /tmp/CB007608

*** Keywords ***
Stop BIP Capture On Asil
    [Arguments]     ${interface}=nac_eth2  ${connection}=ASIK Master  ${kill_type}=2
    ${check_process_command}    Set Variable    ps -ef | grep tcpdump | grep -v grep | grep ${interface}
    ${is_process_on}    csn.execute    command=${check_process_command}    connection=${connection}
    Should Not Be Empty    ${is_process_on}    msg=Fail to stop bip log capturing on ASIK
    csn.Execute        ps -ef | grep tcpdump | grep -v grep | grep ${interface} | awk '{print $2}' | xargs kill -${kill_type}
    ...                connection=${connection}
    sleep  3 sec
    ${is_process_killed} =    csn.Execute    command=${check_process_command}    connection=${connection}
    Should Be Empty    ${is_process_killed}

ASIL Common Capture BIP log and download
    [Arguments]    ${duration}=10s    ${log_path}=${logPath}
    Connect to Common Unit Master
    Precondition for bip capture with gnbMirroring scripts
    #Asil Bip Capture with gnbMirroring scripts
	common_1732.Asil Bip Capture with gnbMirroring scripts
    sleep    ${duration}
	Stop BIP Capture On Asil
	${list_log_path_local}    Download BIP Logs From ASIK To TestPC and rename it    log_path=${log_path}
	#${list_log_path_local}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    log_path=${log_path}
    set test variable    ${bip_log_path}    ${list_log_path_local}[0]
    ssh.Disconnect    connection=ASIK Master
    [Return]    ${bip_log_path}
	
Asil Bip Capture with gnbMirroring scripts
    [Arguments]    ${connection}=ASIK Master    ${gnb_mirroring}=gnbMirroring.sh     ${mirroring_mode}=local
    ...            ${bb_slot_1}=false    ${bb_slot_2}=false    ${bb_slot_3}=false
    ...            ${bb_slot_5}=true    ${bb_slot_6}=false    ${bb_slot_7}=false    ${l2_l1_bip}=true
    ...            ${syscom_mirroring}=true    ${carrier_aggregation}=false    ${backhaul_mirroring}=false
    ...            ${l2hi_l2lo_mirroring}=false    ${filtering}=off    ${use_gulp}=false     ${capturing_time_seconds}=infinite
    ...            ${number_of_files}=1    ${file_size_mbytes}=100    ${xtrace}=off    ${sleep_time}=20s    ${bip_prefix}=tcpdump_L2L1
    ${cmd_local}    catenate    nohup sh /ffs/run/config/scripts/${gnb_mirroring} --mirroring_mode=${mirroring_mode}
    ...             --bb_slot_1=${bb_slot_1} --bb_slot_2=${bb_slot_2}
    ...             --bb_slot_3=${bb_slot_3} --bb_slot_5=${bb_slot_5} --bb_slot_6=${bb_slot_6} --bb_slot_7=${bb_slot_7}
    ...             --l2_l1_bip=${l2_l1_bip} --syscom_mirroring=${syscom_mirroring}
    ...             --carrier_aggregation=${carrier_aggregation} --backhaul_mirroring=${backhaul_mirroring}
    ...             --l2hi_l2lo_mirroring=${l2hi_l2lo_mirroring} --filtering=${filtering} --use_gulp=${use_gulp}
    ...             --capturing_time_seconds=${capturing_time_seconds} --number_of_files=${number_of_files}
    ...             --file_size_mbytes=${file_size_mbytes} --xtrace=${xtrace} &>/dev/null &
    csn.send_command    command=${cmd_local}    connection=${connection}
    Sleep    ${sleep_time}
    Trace capturing process should be triggered    log_prefix=${bip_prefix}    connection_alias=${connection}
	
Get field value by xpath
    [Documentation]    Author: Deng xueqin
    ...                This key word is to load pcap file with filter condition.
    ...                :param ${packets}: a list contains only one generator
    ...                :param ${xpath}: field xpath in a packet, e.g. .//nr-rrc.codebookMode
    ...                :param ${attribute_name}: attribute of packet field, e.g. “show”, “value”, or “showname”, default: “show”
    ...                Return: field value list
    [Arguments]    ${packets}    ${xpath}    ${attribute_name}=show
    ${values}    cap.get_field_value_by_xpath    pdml_list=${packets}
    ...    xpath=${xpath}    attribute_name=${attribute_name}
    [Return]    ${values}
	
Delete log
    [Documentation]    Author: Deng xueqin
    ...                Description: Delete the download log
    [Arguments]    ${log_file}
    Run Keyword And Ignore Error    run    command=rm -rf ${log_file}
	
Start to collect X2log on eNB
    [Documentation]  Author: meiya.cheng
    ...              Description: collect X2 LOGS for classical BTS
    [Arguments]    ${log_name}
    wait until keyword succeeds    10 min    10 sec    Connect to eNB   alias=ENB
    #csn.send command    command=tcpdump -i br1 sctp -w /tmp/${log_name}   connection=ENB
	csn.send command    command=tcpdump -i br1 -w /tmp/${log_name}   connection=ENB


Stop and get X2Logs on eNB
    [Documentation]  Author: meiya.cheng
    ...              Description: stop collect X2 LOGS and upload for classical BTS
    [Arguments]     ${log_name}
    wait until keyword succeeds    10 min    10 sec    Connect to eNB   alias=ENB
    sleep    30
    csn.send command    command=killall tcpdump     connection=ENB
    sleep    5
    csn.download_file   remote_path=/tmp${/}${log_name}    local_path=${logPath}${/}${log_name}   connection=ENB

	
Get Filter pucchF2MaxCodeRate 
    [Documentation]  Author: meiya.cheng
    ...              Description: get pucchF2MaxCodeRate value
	${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    ${pucchF2MaxCodeRate_value}    selenium_coam.get_parameter_value
    ...   dist_name=${MRBTS_ID}/NRBTS-1/NRCELLGRP-0
    ...   abbr=pucchF2MaxCodeRate
    ...   filter_param=Pucch F2 Max Code Rate
    set suite variable    ${pucchF2MaxCodeRate_value}

Modify pucchF2MaxCodeRate08inwebui
    [Documentation]  Author: meiya.cheng
    ...              Description: modify pucchF2MaxCodeRate value
	${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-1/NRCELLGRP-0
    ...    abbr=pucchF2MaxCodeRate
    ...    new_value=zeroDot08
    ...    filter_param=Pucch F2 Max Code Rate
    sleep    1s
    selenium_coam.validate_plan
    sleep    8s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
	
Modify pucchF2MaxCodeRate25inwebui
    [Documentation]  Author: meiya.cheng
    ...              Description: modify pucchF2MaxCodeRate value
	${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-1/NRCELLGRP-0
    ...    abbr=pucchF2MaxCodeRate
    ...    new_value=zeroDot25
    ...    filter_param=Pucch F2 Max Code Rate
    sleep    1s
    selenium_coam.validate_plan
    sleep    8s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
	
Restore pucchF2MaxCodeRateinwebui
    [Documentation]  Author:meiya.cheng
    ...              Description: restore pucchF2MaxCodeRate value
	${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-1/NRCELLGRP-0
    ...    abbr=pucchF2MaxCodeRate
    ...    new_value=zeroDot35
    ...    filter_param=Pucch F2 Max Code Rate
    sleep    1s
    selenium_coam.validate_plan
    sleep    8s
    selenium_coam.activate_plan    activate_plan_despite_errors=True

Check pucch Resource in x2 log
    [Documentation]    Author: cheng meiya
    ...                Description: Check pucch Resource value in x2 log
    [Arguments]    ${pcap_file}    ${filter}
    ${filtered_packets}=    Load pcap with filter    pcap_file=${pcap_file}    filter_expression=${filter}
	${x2_result}=    Get field value by xpath    packets=${filtered_packets}    xpath=${x2_check_pucch}    attribute_name=show
	${length}    Get Length    ${x2_result}
    FOR    ${i}    IN RANGE    ${length}
         Should be true    ${x2_result}[${i}] == 10
    END

Get ucibits from bip
    [Arguments]    ${bip_file}
    #${filtered_packets}    Load pcap with filter    pcap_file=${bip_file}    filter_expression=${bip_pucch_filter}
    #...    luashark_path=${luashark_path}    command_template=${command_template_with_Z}
    ${Parser}    cap.setup    infile=${bip_file}    display_filter=${bip_pucch_filter}
	...    extension=${luashark_path}    tshark_path=${tshark_path}    alias="Parser"
    [Return]     ${Parser}
Get and check field values
    [Arguments]    ${filtered_packets}
    ${ucibits_0}    get_field_value_by_name    field_name=${uciBits_field_name0}    attribute_name=value    pcap_parser="Parser"
    should not contain    ${ucibits_0}    0
    ${ucibits_1}    get_field_value_by_name    field_name=${uciBits_field_name1}    attribute_name=value    pcap_parser="Parser"
    should not contain    ${ucibits_1}    0
    ${ucibits_2}    get_field_value_by_name    field_name=${uciBits_field_name2}    attribute_name=value    pcap_parser="Parser"
    should not contain    ${ucibits_2}    0
    ${ucibits_3}    get_field_value_by_name    field_name=${uciBits_field_name3}    attribute_name=value    pcap_parser="Parser"
    should not contain    ${ucibits_3}    0
    ${ucibits_4}    get_field_value_by_name    field_name=${uciBits_field_name4}    attribute_name=value    pcap_parser="Parser"
    should not contain    ${ucibits_4}    0
    ${ucibits_5}    get_field_value_by_name    field_name=${uciBits_field_name5}    attribute_name=value    pcap_parser="Parser"
    should not contain    ${ucibits_5}    0
    ${ucibits_6}    get_field_value_by_name    field_name=${uciBits_field_name6}    attribute_name=value    pcap_parser="Parser"
    should not contain    ${ucibits_6}    0    
