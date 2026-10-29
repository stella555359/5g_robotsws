*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Samik Sarkar
...              :contact: samik.sarkar@nokia.com

Variables    ta5g_global_var

Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../resources/robot/TTI_Traces.robot
Resource         ../resources/NPS/SWENG/robot/PacketSearch.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/ECEcommon/common_setup_teardown.robot

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          luashark_tools.analyzer       WITH NAME       analyzer
Library          taf.sbts.oam.coam.admin               WITH NAME   ute_adm
Library          Collections
#Library          OperatingSystem
Library          ta5g_tshark
Library          ta5g_commissioning
Library          taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library          taf.transport.ssh                 WITH NAME    csn
Library          OperatingSystem
Library          String
Library          ../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library          ../resources/NPS/SWENG/python_libs/luashark_tools.py
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ././resources/python/PM_Counter_Verify.py    WITH NAME     pm_analyzer
Library          ./resources/python/execute_command.py
Library          ./resources/python/increase_buffer_size.py
Library          ./resources/python/utility.py
Library          ./resources/python/CB009425_Verification.py
Library          DateTime
Library          ./resources/python/l1b_tag_gnb.py

*** Variables ***
&{GNB_ASIK}                ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${BIP_SCRIPT_PATH}         /home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/resources/NPS/SWENG/config/script/
${port}                    22

#   Add your vonr codec speed
&{vonr_codec_rate}         amr_wb_18_25=18.6      amr_wb_23_85=21.4
@{gbr_qfi_list_cfg}        3	4	5 	6	7	8	9	10	11	12	13	14	15

*** Keywords ***
## Delta Commissioning
Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Increase Buffer Size for VM and IPHY
    increase_buffer_size.increase_buffer_size     ${AP_ASIK.ip}      ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}

Change GSCN Value
    [Arguments]    ${GSCN}
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
    Run    cat ${file_path}|grep -m 1 "GSCN"|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
    Send IPHY XML To Airphone   ${file_path}

Start and Stop TTI TRACE
    [Arguments]    ${pysical_cell_ids}=50    ${duration}=${3}
    Start Ttitrace With Streaming Mode_3    ${pysical_cell_ids}
    sleep    ${duration}s
    Stop Ttitrace

Collect TTI Trace
    [Arguments]    ${ttitrace_path}
    ${new_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}
    Convert Ttitrace From Pcap To Excelcsv        ${new_path}
    Convert Tti To Csv Mode          ${new_path}
    [Return]        ${new_path}

Convert Tti To Csv Mode
    [Arguments]         ${path}
    Format Tti In Stream Mode         ${path}/output_dl.csv     ${path}/output_dl_formated.csv
    Format Tti In Stream Mode         ${path}/output_ul.csv     ${path}/output_ul_formated.csv


Check Cell On Air
    [Arguments]             ${wts_cfg_file}
    Stop Edaemon and Egate process
    Stop Sim_enb
    run    command=sudo rm -rf ${WTS_DIR}/*.log.*
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    wtsrunner.configure                   file=${wts_cfg_file}
    wtsrunner.read_wtsemu_output_until_re    expected=Airphone: Cell Setup completed     timeout=240

Create Modify PDU session
    [Arguments]     ${st_ue_id}     ${en_ue_id}    ${qos_profile}   ${pdu_id}     ${gfbr_mfbr_profile}=-1
         ...        ${num_ues}=${en_ue_id}          ${ue_to_bearer_list}=${bearer_list}
    [Documentation]    This keyword is wrepar for the ADD PDU  session and modification
    FOR     ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
        ${QOS_prof}=      Set Variable  ${qos_profile}[${ue_id}][1:]
        ${len}=     Get Length  ${QOS_prof}
        ${QOS_strng}=    Run Keyword If  ${len} >0   Evaluate    ",".join(${QOS_prof})  #Got the QOS string
        ${pdu_id}=   Set Variable If      '2' in ${QOS_prof} or '3' in ${QOS_prof} or '4' in ${QOS_prof}   2   1
        ${gw_id}=       Evaluate    ${ue_id}+${num_ues}
        Run Keyword if  ${len} >0   CB009425_Resource_New.Add PDU session     ${ue_id}      ${pdu_id}      ${gw_id}     ${QOS_strng}
        ...    ue_to_bearer_list=${ue_to_bearer_list}
    END
    Log to Console     ${gfbr_mfbr_profile}

Add PDU session
     [Arguments]     ${ue_id}      ${pdu_id}      ${gw_id}     ${Q_O_ADD}      ${ue_to_bearer_list}=${bearer_list}
     [Documentation]    This keyword starts the ADD PDU  session and modification
        Run Keyword If   ${pdu_id} == 2
        ...     CB009425_Resource_New.Modified UE PDU Addition should be Successful       ${ue_id}     ${pdu_id}     1   ${gw_id}
       ${x}=   Run Keyword If    ${pdu_id} != ${2}  execute_command.modify_pdu_session_verify     ${ue_id}    ${pdu_id}
       ...     qosflows_to_add=${Q_O_ADD}   ue_to_bearer_list=${ue_to_bearer_list}
        ...    ELSE
        ...    VONR GBR NON GBR Add PDU session    ${ue_id}    ${pdu_id}    ${Q_O_ADD}      ue_to_bearer_list=${ue_to_bearer_list}
        Should Contain    ${x}   Pass

Modified UE PDU Addition should be Successful
    [Arguments]    ${ue_id}     ${pdu_id}     ${nw_id}    ${gw_id}
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    ${RAN_UE_NGAP_ID}=      Evaluate    ${ue_id}-${1}
    ${pdu_addition_pattern}=    Set Variable    Pdu Session Resource Setup Response Message with RAN UE NGAP ID
    ${output}=      Read WTS Output For Pattern And Print matching Lines    ${pdu_addition_pattern}    ${Timeout_SA}
    ${str_len}=     Get Length     ${output}
    Should Not Be Equal     ${str_len}      ${0}
    BuiltIn.Log                ue_pdu_addition_is_ok
    sleep    30s

VONR GBR NON GBR Add PDU session
    [Arguments]    ${ue_id}    ${pdu_id}    ${Q_O_ADD}      ${ue_to_bearer_list}=${bearer_list}
      ${x}=		execute_command.modify_pdu_session_verify    ${ue_id}    ${pdu_id}   qosflows_to_add=${Q_O_ADD}
      ...   ue_to_bearer_list=${ue_to_bearer_list}
      Should Contain    ${x}   Pass
      [Return]      ${x}

MultiUE Register should be Successful with Fetch Bearer ID
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    ${ue_to_bearer_list}=    Create Dictionary
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/regst.txt	    ${output}
#    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk '{print $9}'
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
    Append To List  ${crnti_list}   ${crnti_string}
    BuiltIn.Log     ${crnti_string}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}
    ${output}=  Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    ${bearer_list}       Create List
    Create File	    ${OUTPUT_DIR}/bearer.txt	    ${output}
    ${bearer_id}=    Run     cat ${OUTPUT_DIR}/bearer.txt |grep -i "servedRadioBearer drb-Identity" |awk '{print $4}'|sed 's/,//g'
    Append To List	   ${bearer_list}        ${bearer_id}
    Set To Dictionary	${ue_to_bearer_list} 	${ue_idx}	    ${bearer_list}
    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}     ${ue_to_bearer_list}

Start Data Transfer
    [Arguments]    ${st_ue_id}     ${en_ue_id}    ${duration}    ${Dir}  ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...   ${qos_profile_speed_dl}    ${qos_profile}
    [Documentation]    This keyword is used to start the data transfer in UL and DL
    FOR     ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
        ${ul_timestamp}=    Run Keyword If  '${Dir}' == 'ul'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${qos_profile_speed_ul}[${ue_id}]    dir=${Dir}    pdu_id=1    trf_id=${trf_id}    qfi_id=${qos_profile}[${ue_id}]
        ...    sec=${duration}

         ${dl_timestamp}=   Run Keyword If  '${Dir}' == 'dl'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${qos_profile_speed_dl}[${ue_id}]    dir=${Dir}    pdu_id=1    trf_id=${trf_id}    qfi_id=${qos_profile}[${ue_id}]
        ...    sec=${duration}

        ${dl_timestamp1}=   Run Keyword If  '${Dir}' == 'both'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${qos_profile_speed_dl}[${ue_id}]    dir=dl    pdu_id=1    trf_id=${trf_id}    qfi_id=${qos_profile}[${ue_id}]
        ...    sec=${duration}
        ${ul_timestamp1}=   Run Keyword If  '${Dir}' == 'both'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${qos_profile_speed_ul}[${ue_id}]    dir=ul    pdu_id=1    trf_id=${trf_id}    qfi_id=${qos_profile}[${ue_id}]
        ...    sec=${duration}
    END

UE Trigger Traffic for SA QFI Based
    [Arguments]     ${ue_idx}      ${Traffic_rate}    ${data_rate}    ${dir}=${Dir}    ${sec}=-1    ${pdu_id}=${Pdu_session_ID}
    ...     ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    ${idx}=     Set Variable    ${1}
    ${unit_idx}=     Set Variable    ${0}
    ${data_start_time}=     Create List
    FOR     ${Q_id}   IN    @{qfi_id}   #replace with QOS 1,2,3,4 or one by one
    Log to Console    \nRunning DL Traffic for ${data_rate} ${Traffic_rate}...
    ${pdu_id}=         Set Variable If      '${Q_id}' == '2' or '${Q_id}' == '3' or '${Q_id}' == '4'     2     1
    #${expected_str}=       Set Variable If   '${dir}' == 'dl'    Started Downlink Internal traffic Receiver*    Started Uplink Internal traffic*
    ${expected_str}=       Set Variable If   '${dir}' == 'dl'    Started Downlink*    Started Uplink*
    ${expected_trf}=       Set Variable If   '${dir}' == 'dl'    DL TRF:    UL TRF:   # U is in new Line
    ${t_idx}=       Set Variable If      '${Q_id}' == '2' or '${Q_id}' == '3' or '${Q_id}' == '4'   ${Q_id}     ${idx}
    ${unit}     Set variable if    '${Traffic_rate[${unit_idx}]}' == 'mbps'      ${1048576}      ${1024}
    ${spd}=   Run Keyword If   'amr' in '${data_rate[${unit_idx}]}' or 'g7' in '${data_rate[${unit_idx}]}' or 'custom' in '${data_rate[${unit_idx}]}'
    ...       Set Variable   ${data_rate[${unit_idx}]}
    ...      ELSE
    ...      Evaluate     (${unit} * ${data_rate[${unit_idx}]})
    ${rate}     Set variable if    '${Traffic_rate[${unit_idx}]}' == 'rtp_codec'    rtp_codec    bps
    Run Keyword If      ${sec}==-1 #QOS{5,6,5} 1-3
    ...    wtsrunner.trf_data_start     ue=${ue_idx}     pdu=${pdu_id}   qfi=${t_idx}    dir=${dir}    trf_id=${trf_id}    ${rate}=${spd}
    ...    ELSE
    ...    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${t_idx}    dir=${dir}    trf_id=${trf_id}    seconds=${sec}
    ...    ${rate}=${spd}
    ${time}=    DateTime.Get Current Date
    Append To List	${data_start_time}	    ${time}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=${expected_str}    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    ${expected_trf}    partial_match=${TRUE}
    #   Log to Console    ${output}
    ${m} =    utility.check_op      ${output}
    Run Keyword If      ${m} != ${1}
    ...    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${t_idx}    dir=${dir}    trf_id=${trf_id}    seconds=${sec}
    ...    ${Traffic_rate[${unit_idx}]}=${data_rate[${unit_idx}]}
    ${output1}=      Run Keyword If      ${m} != ${1}
    ...        wtsrunner.read_wtsemu_output_until_re    expected=${expected_str}    timeout=10
    ${output}=      Set Variable If   ${m} != ${1}    ${output1}    ${output}
    ${output}    Get Lines Matching Regexp    ${output}    ${expected_trf}    partial_match=${TRUE}
    Log to Console    ${output}
    ${unit_idx}=    Evaluate    ${unit_idx}+${1}
    Continue For Loop If    '${Q_id}' == '2' or '${Q_id}' == '3' or '${Q_id}' == '4'
    ${idx}=     Evaluate    ${idx}+${1}
	END
    BuiltIn.Log    traffic_data_is_started_successfully
    [Return]        ${data_start_time}

Reset Bearer Stats
    [Arguments]     ${st_ue_id}    ${en_ue_id}
    FOR   ${UE_ID}  IN RANGE      ${st_ue_id}    ${en_ue_id}+${1}
        Run Keyword And Continue on Failure    wtsrunner.bearer_stats_clear     ue=${UE_ID}    pdu=${1}
        Run Keyword And Continue on Failure    wtsrunner.bearer_stats_clear     ue=${UE_ID}    pdu=${2}
    END

MultiUE PDU Release should be Successful
    [Arguments]    ${start_ue_id}   ${end_ue_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
        wtsrunner.ue_pdu_session_release    ue=${ue_idx}    pdu=1    by=amf
        wtsrunner.ue_pdu_session_release    ue=${ue_idx}    pdu=2    by=amf
        wtsrunner.read_wtsemu_output_until    expected=Received Pdu Session Resource Release Response Message
        ...                     timeout=30
        BuiltIn.Log          ue=${ue_idx} pdu=1 release with successfully
        Log to Console       ue=${ue_idx} pdu=1 release with successfully
	END
	BuiltIn.Log       All_ue_release_their_pdu_successfuly
	Log to Console    All_ue_release_their_pdu_successfuly

Set fixed cqi bler for single UE
    [Arguments]  ${ue_id}    ${dirct}
    # For DL BLER
    Run Keyword if  '${dirct}' == 'dl'    wtsrunner.bler_testmode_nr    profile_id=40    target_mcs=3
    ...    num_dl_pkts=2000    #num_harq_nack=2000
    Run Keyword if  '${dirct}' == 'dl'    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=bler    action=activate    profile_id=40
    # Fr UL SINR
    Run Keyword if  '${dirct}' == 'ul'
    ...    wtsrunner.ul_sinr_testmode_nr    profile_id=3    sinr_target_srs=-250    sinr_target_pusch=-250
    ...    sinr_target_pucch=-250    sinr_target_preamble=-250
    Run Keyword if  '${dirct}' == 'ul'
    ...    wtsrunner.ue_testmode_set_nr  id=${ue_id}  testmode=ul_sinr    action=activate    profile_id=3
    Run Keyword if  '${dirct}' == 'ul'    wtsrunner.bler_testmode_nr    profile_id=10   ul_bler=100,100
    Run Keyword if  '${dirct}' == 'ul'    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=bler    action=activate    profile_id=10


Set fixed cqi bler for multiple UE
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${dirct}
    FOR     ${ue_id}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
        Run Keyword if  '${dirct}' == 'dl'    wtsrunner.bler_testmode_nr    profile_id=40    target_mcs=3
        ...    num_dl_pkts=2000    #num_harq_nack=2000
        Run Keyword if  '${dirct}' == 'dl'    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=bler    action=activate    profile_id=40
        # Fr UL SINR
        Run Keyword if  '${dirct}' == 'ul'
        ...    wtsrunner.ul_sinr_testmode_nr    profile_id=3    sinr_target_srs=-250    sinr_target_pusch=-250
        ...    sinr_target_pucch=-250    sinr_target_preamble=-250
        Run Keyword if  '${dirct}' == 'ul'
        ...    wtsrunner.ue_testmode_set_nr  id=${ue_id}  testmode=ul_sinr    action=activate    profile_id=3
	END

Set user defined bler for multiple UE
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${dirct}    ${bler_per}    ${profile}=1
    FOR     ${ue_id}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
        Run Keyword if  '${dirct}' == 'dl'    wtsrunner.bler_testmode_nr    profile_id=${profile}
        ...    dl_bler=${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per}
        Run Keyword if  '${dirct}' == 'dl'    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=bler
        ...    action=activate    profile_id=${profile}
        # Fr UL SINR
        Run Keyword if  '${dirct}' == 'ul'    wtsrunner.bler_testmode_nr    profile_id=1
        ...    ul_bler=${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per}
        Run Keyword if  '${dirct}' == 'ul'    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=bler
        ...    action=activate    profile_id=${profile}
        # For both UL & DL
        Run Keyword if  '${dirct}' == 'both'    wtsrunner.bler_testmode_nr    profile_id=${profile}
        ...    dl_bler=${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per}
        ...    ul_bler=${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per}
        Run Keyword if  '${dirct}' == 'both'    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=bler
        ...    action=activate    profile_id=${profile}
	END

final_verdict_dl
    [Arguments]    ${rnti}    ${file_name}    ${actVoNRInc}=True    ${numTxPrb}=${2}    ${maxPrbsVoNR}=${32}    ${stepUpNumPrbs}=${2}
    ...    ${actTargetBlerVoNR}=True    ${dlMcsDropLimitForVoNR}=${2}    ${tc_scen}=${0}

    ${result}    dummy_func_dl    ${rnti}    ${file_name}    ${actVoNRInc}    ${numTxPrb}    ${maxPrbsVoNR}
    ...    ${stepUpNumPrbs}    ${actTargetBlerVoNR}    ${dlMcsDropLimitForVoNR}    ${tc_scen}
    Should Contain    ${result}    Pass


Compare UsedMcs and McsFromCodeRate
    [Arguments]    ${rnti}    ${dire}    ${file_name}    ${tc_scen}=${0}
    ${result}     map_code_rate_with_mcs    ${rnti}    ${dire}    ${file_name}    ${tc_scen}
    Should Contain    ${result}    Pass

Start VoNR Call
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${rtp_codec}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning SIP Messaging for ${ue_idx}...
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=2   qfi=2    dir=dl    trf_id=1      kbps=32
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=2    dir=ul    trf_id=1      kbps=32
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic Receiver*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}

    Log to Console    \nRunning 5QI-1 traffic for ${ue_idx}...
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=2   qfi=3    dir=dl    trf_id=1    rtp_codec=${rtp_codec}
    ...     rtp_ps=900 period_ms=10 rtp_voice_silence=200:1 rtp_send_silence_period=10 rtp_silence_ps=900
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic Receiver*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=2   qfi=3    dir=ul    trf_id=1    rtp_codec=${rtp_codec}
    ...     rtp_ps=900 period_ms=10 rtp_voice_silence=200:1 rtp_send_silence_period=10 rtp_silence_ps=900
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic Receiver*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
	END

Stop VoNR Call
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.trf_data_stop    pdu=2    ue=${ue_idx}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Stopped Downlink Internal traffic on Ue:${ue_idx}*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UE${ue_idx}: Stopping Uplink Internal traffic    partial_match=${TRUE}
    END

MultiUE VoNr PDU Release should be Successful
    [Arguments]    ${st_ue_id}   ${en_ue_id}
    FOR     ${ue_idx}   IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        wtsrunner.ue_pdu_session_release    ue=${ue_idx}    pdu=2    by=amf
        wtsrunner.read_wtsemu_output_until    expected=Received Pdu Session Resource Release Response Message
        ...                     timeout=30
        BuiltIn.Log          ue=${ue_idx} pdu=1 release with successfully
        Log to Console       ue=${ue_idx} pdu=1 release with successfully
	END
	BuiltIn.Log       All_ue_release_their_pdu_successfuly
	Log to Console    All_ue_release_their_pdu_successfuly

Start Collecting Syslog
    [Arguments]    ${VM_IP}=${tl.test_pc.default_ssh_connection_details.addr}    ${NAME}=5g
    ${ports}=   Create List   51000    51001    51003    50011
    ${CURRENT_SYSLOG_PATH}  Set Variable  ${LOG_PATH}/
    set test variable      ${CURRENT_SYSLOG_PATH}
    ute_syslog.Start Syslog  log_dir=${CURRENT_SYSLOG_PATH}  log_name=syslog_${NAME}.log  ip=192.168.255.126
    ...    ssh_username=ute    ssh_password=ute    ports=${ports}  alias=${NAME}
    Log to Console  ${VM_IP}
Stop Collecting Syslog
    [Arguments]    ${NAME}=5g
    ${file_path}    ute_syslog.Collect Syslog Results    alias=${NAME}
    [Return]      ${file_path}

Compare UseMcs with or without Bler
    [Arguments]    ${mcs_without_bler}    ${mcs_with_bler}
    ${result}    Set Variable if    ${mcs_without_bler[0]} > ${mcs_with_bler[0]} or ${mcs_without_bler[1]} > ${mcs_with_bler[1]}   Pass    Fail
    Should Contain    ${result}   Pass

final verdict for mcs drop
    [Arguments]    ${rnti}    ${file_name}    ${dlMcsDropLimitForVoNR}=${2}    ${tc_scen}=${0}
    ${result}    mcs_drop_verify    ${rnti}    ${file_name}    ${dlMcsDropLimitForVoNR}    ${tc_scen}
    Should Contain    ${result}    Pass

final verdict for enh retx
    [Arguments]    ${rnti}    ${file_name}    ${actVoNRInc}=True    ${numTxPrb}=${2}    ${maxPrbsVoNR}=${32}
    ...    ${stepUpNumPrbs}=${2}    ${tc_scen}=${0}
    ${result}    enh_retx_verify    ${rnti}    ${file_name}    ${actVoNRInc}    ${numTxPrb}    ${maxPrbsVoNR}
    ...    ${stepUpNumPrbs}    ${tc_scen}
    Should Contain    ${result}    Pass

final verdict for min tbs prb
    [Arguments]    ${rnti}    ${file_name}    ${actUlMinTbsForVoNR}=True
    ...    ${minPuschPrbForMinTbsVoNR}=${2}    ${ulMinTbsForVoNR}=${32}    ${tc_scen}=${0}
    ${result}    min_tbs_prb_verify    ${rnti}    ${file_name}    ${actUlMinTbsForVoNR}
    ...    ${minPuschPrbForMinTbsVoNR}    ${ulMinTbsForVoNR}    ${tc_scen}
    Should Contain    ${result}    Pass

UE Register should be Successful Vonr
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal   log_traffic_stats=off
    wtsrunner.ue_register   id=${ue_id}    nwslice=${nw_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Log to Console    ---> ${UE_register_complete_pattern}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    BuiltIn.Log                first_ue_register_is_ok
    [Return]      ${output}

 Configure UTE ETH3 IPs
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3
