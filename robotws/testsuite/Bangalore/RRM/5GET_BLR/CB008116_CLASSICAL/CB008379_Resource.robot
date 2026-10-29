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
#Resource         ../resources/ECEcommon/common_setup_teardown.robot
Resource         ./resources/common/common_setup_teardown.robot

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          luashark_tools.analyzer       WITH NAME       analyzer
Library          taf.sbts.oam.coam.admin                       WITH NAME   ute_adm
Library          Collections
Library          OperatingSystem
Library          ta5g_tshark
Library          ta5g_commissioning
Library          taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library          taf.transport.ssh                 WITH NAME    csn
#Library          OperatingSystem
Library          String
Library          ../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library          ../resources/NPS/SWENG/python_libs/luashark_tools.py
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ./python/PM_Counter_Verify.py    WITH NAME     pm_analyzer
Library          ./python/execute_command.py
Library          ./python/increase_buffer_size.py
Library          ./python/utility.py
Library          ./python/tti_trace_utility.py
Library          DateTime
Library          ./python/l1b_tag_gnb.py


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

Enhanced Buffer Size for VM and IPHY
    increase_buffer_size.enhanced_buffer_size    ${AP_ASIK.ip}      ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}

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

# Add pdu sessions for the UE based on QOS
#Create Modify PDU session
#    [Arguments]     ${st_ue_id}     ${en_ue_id}    ${qos_profile}   ${pdu_id}     ${gfbr_mfbr_profile}=-1
#         ...        ${num_ues}=${en_ue_id}          ${ue_to_bearer_list}=${bearer_list}
#	builtin.Log    ${gfbr_mfbr_profile}
#    [Documentation]    This keyword is wrepar for the ADD PDU  session and modification
#    FOR     ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
#        ${QOS_prof}=      Set Variable  ${qos_profile}[${ue_id}][1:]
#        ${len}=     Get Length  ${QOS_prof}
#        ${QOS_strng}=    Run Keyword If  ${len} >0   Evaluate    ",".join(${QOS_prof})  #Got the QOS string
#        ${pdu_id}=   Set Variable If      '2' in ${QOS_prof} or '3' in ${QOS_prof} or '4' in ${QOS_prof}   2   1
#
#        ${gw_id}=       Evaluate    ${ue_id}+${num_ues}
#        Run Keyword if  ${len} >0   Add PDU session     ${ue_id}      ${pdu_id}      ${gw_id}     ${QOS_strng}
#        ...    ue_to_bearer_list=${ue_to_bearer_list}
#    END

Create Modify PDU session New
    [Arguments]     ${st_ue_id}     ${en_ue_id}    ${qos_profile}   ${pdu_id}     ${gfbr_mfbr_profile}=-1
         ...        ${num_ues}=${en_ue_id}          ${ue_to_bearer_list}=${bearer_list}
	builtin.Log    ${gfbr_mfbr_profile}
    [Documentation]    This keyword is wrepar for the ADD PDU  session and modification
    FOR     ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
        ${QOS_prof}=      Set Variable  ${qos_profile}[${ue_id}][1:]
        ${len}=     Get Length  ${QOS_prof}
        ${QOS_strng}=    Run Keyword If  ${len} >0   Evaluate    ",".join(${QOS_prof})  #Got the QOS string
        ${pdu_id}=   Set Variable If      '2' in ${QOS_prof} or '3' in ${QOS_prof} or '4' in ${QOS_prof}   2   1
        ${gw_id}=       Evaluate    ${ue_id}+${num_ues}
        Run Keyword if  ${len} >0   Add PDU session New     ${ue_id}      ${pdu_id}      ${gw_id}     ${QOS_strng}
        ...    ue_to_bearer_list=${ue_to_bearer_list}
    END

Create Modify PDU session for GFBR Update
    [Arguments]     ${st_ue_id}     ${en_ue_id}    ${qos_profile}   ${pdu_id}     ${gfbr_mfbr_profile}
    [Documentation]    This keyword is wrepar for the ADD PDU  session and modification
    FOR     ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
        ${QOS_prof}=      Set Variable  ${qos_profile}[${ue_id}][1:]
        ${len}=     Get Length  ${QOS_prof}
        ${QOS_strng}=    Run Keyword If  ${len} >0   Evaluate    ",".join(${QOS_prof})
        ${pdu_id}=   Set Variable If      '2' in ${QOS_prof} or '3' in ${QOS_prof} or '4' in ${QOS_prof}   2   1
        ${gw_id}=       Evaluate    ${ue_id}+${en_ue_id}
        Run Keyword if  ${len} >0   Update QOS Flow GFBR MFBR    ${ue_id}   ${pdu_id}    ${QOS_prof}     ${gfbr_mfbr_profile}
    END

#Modified UE PDU Addition should be Successful
#    [Arguments]    ${ue_id}     ${pdu_id}     ${nw_id}    ${gw_id}
#    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
#    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
#    ${RAN_UE_NGAP_ID}=      Evaluate    ${ue_id}-${1}
#    ${pdu_addition_pattern}=    Set Variable    Pdu Session Resource Setup Response Message with RAN UE NGAP ID ${RAN_UE_NGAP_ID} handled
#    ${output}=      Read WTS Output For Pattern And Print matching Lines    ${pdu_addition_pattern}    ${Timeout_SA}
#    ${str_len}=     Get Length     ${output}
#    Should Not Be Equal     ${str_len}      ${0}
#    BuiltIn.Log                ue_pdu_addition_is_ok

Modified UE PDU Addition should be Successful New
    [Arguments]    ${ue_id}     ${pdu_id}     ${nw_id}    ${gw_id}
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    ${RAN_UE_NGAP_ID}=      Evaluate    ${ue_id}-${1}
    ${pdu_addition_pattern}=    Set Variable    Pdu Session Resource Setup Response Message with RAN UE NGAP ID
    ${output}=      Read WTS Output For Pattern And Print matching Lines    ${pdu_addition_pattern}    ${Timeout_SA}
    ${str_len}=     Get Length     ${output}
    Should Not Be Equal     ${str_len}      ${0}
    BuiltIn.Log                ue_pdu_addition_is_ok

#Add PDU session
#     [Arguments]     ${ue_id}      ${pdu_id}      ${gw_id}     ${Q_O_ADD}      ${ue_to_bearer_list}=${bearer_list}
#     [Documentation]    This keyword starts the ADD PDU  session and modification
#        Run Keyword If   ${pdu_id} == 2
#        ...     Modified UE PDU Addition should be Successful       ${ue_id}     ${pdu_id}     1   ${gw_id}
#       ${x}=   Run Keyword If    ${pdu_id} != ${2}  execute_command.modify_pdu_session_verify     ${ue_id}    ${pdu_id}
#       ...     qosflows_to_add=${Q_O_ADD}   ue_to_bearer_list=${ue_to_bearer_list}
#        ...    ELSE
#        ...    VONR GBR NON GBR Add PDU session    ${ue_id}    ${pdu_id}    ${Q_O_ADD}      ue_to_bearer_list=${ue_to_bearer_list}
#        Should Contain    ${x}   Pass

Add PDU session New
     [Arguments]     ${ue_id}      ${pdu_id}      ${gw_id}     ${Q_O_ADD}      ${ue_to_bearer_list}=${bearer_list}
     [Documentation]    This keyword starts the ADD PDU  session and modification
        Run Keyword If   ${pdu_id} == 2
        ...     Modified UE PDU Addition should be Successful New       ${ue_id}     ${pdu_id}     1   ${gw_id}
       ${x}=   Run Keyword If    ${pdu_id} != ${2}  execute_command.modify_pdu_session_verify     ${ue_id}    ${pdu_id}
       ...     qosflows_to_add=${Q_O_ADD}   ue_to_bearer_list=${ue_to_bearer_list}
        ...    ELSE
        ...    VONR GBR NON GBR Add PDU session    ${ue_id}    ${pdu_id}    ${Q_O_ADD}      ue_to_bearer_list=${ue_to_bearer_list}
        Should Contain    ${x}   Pass

Update QOS Flow GFBR MFBR
    [Arguments]     ${ue_id}   ${pdu_id}    ${QOS_prof}     ${gfbr_mfbr_profile}
        ${result}=      execute_command.update_pdu_session_gfbr_mfbr    ${ue_id}    ${pdu_id}    ${QOS_prof}
        ...     ${gbr_qfi_list_cfg}     ${gfbr_mfbr_profile}
#        Should Contain    ${result}   Pass

#VONR GBR NON GBR Add PDU session
#    [Arguments]    ${ue_id}    ${pdu_id}    ${Q_O_ADD}      ${ue_to_bearer_list}=${bearer_list}
#
#      ${x}=		execute_command.modify_pdu_session_verify    ${ue_id}    ${pdu_id}   qosflows_to_add=${Q_O_ADD}
#      ...   ue_to_bearer_list=${ue_to_bearer_list}
#      Should Contain    ${x}   Pass
#      [Return]      ${x}


#Modify it run on QOS basis per ue
#UE Trigger Traffic for SA QFI Based
#    [Arguments]     ${ue_idx}      ${Traffic_rate}    ${data_rate}    ${dir}=${Dir}    ${sec}=-1    ${pdu_id}=${Pdu_session_ID}
#    ...     ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
#    [Documentation]    This keyword starts the DL Traffic for the SA variant
#    ${idx}=     Set Variable    ${1}
#    ${unit_idx}=     Set Variable    ${0}
#    ${data_start_time}=     Create List
#    FOR     ${Q_id}   IN    @{qfi_id}   #replace with QOS 1,2,3,4 or one by one
#    Log to Console    \nRunning DL Traffic for ${data_rate} ${Traffic_rate}...
#    ${pdu_id}=         Set Variable If      '${Q_id}' == '2' or '${Q_id}' == '3' or '${Q_id}' == '4'     2     1
#    #${expected_str}=       Set Variable If   '${dir}' == 'dl'    Started Downlink Internal traffic Receiver*    Started Uplink Internal traffic*
#    ${expected_str}=       Set Variable If   '${dir}' == 'dl'    Started Downlink*    Started Uplink*
#    ${expected_trf}=       Set Variable If   '${dir}' == 'dl'    DL TRF:    UL TRF:   # U is in new Line
#    ${t_idx}=       Set Variable If      '${Q_id}' == '2' or '${Q_id}' == '3' or '${Q_id}' == '4'   ${Q_id}     ${idx}
#    ${unit}     Set variable if    '${Traffic_rate[${unit_idx}]}' == 'mbps'      ${1048576}      ${1024}
#    ${spd}=   Run Keyword If   'amr' in '${data_rate[${unit_idx}]}' or 'g7' in '${data_rate[${unit_idx}]}' or 'custom' in '${data_rate[${unit_idx}]}'
#    ...       Set Variable   ${data_rate[${unit_idx}]}
#    ...      ELSE
#    ...      Evaluate     (${unit} * ${data_rate[${unit_idx}]})
#    ${rate}     Set variable if    '${Traffic_rate[${unit_idx}]}' == 'rtp_codec'    rtp_codec    bps
#    Run Keyword If      ${sec}==-1 #QOS{5,6,5} 1-3
#    ...    wtsrunner.trf_data_start     ue=${ue_idx}     pdu=${pdu_id}   qfi=${t_idx}    dir=${dir}    trf_id=${trf_id}    ${rate}=${spd}
#    ...    ELSE
#    ...    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${t_idx}    dir=${dir}    trf_id=${trf_id}    seconds=${sec}
#    ...    ${rate}=${spd}
#    ${time}=    DateTime.Get Current Date
#    Append To List	${data_start_time}	    ${time}
#    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=${expected_str}    timeout=10
#    ${output}         Get Lines Matching Regexp    ${output}    ${expected_trf}    partial_match=${TRUE}
#    #   Log to Console    ${output}
#    ${m} =    utility.check_op      ${output}
#    Run Keyword If      ${m} != ${1}
#    ...    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${t_idx}    dir=${dir}    trf_id=${trf_id}    seconds=${sec}
#    ...    ${Traffic_rate[${unit_idx}]}=${data_rate[${unit_idx}]}
#    ${output1}=      Run Keyword If      ${m} != ${1}
#    ...        wtsrunner.read_wtsemu_output_until_re    expected=${expected_str}    timeout=10
#    ${output}=      Set Variable If   ${m} != ${1}    ${output1}    ${output}
#    ${output}    Get Lines Matching Regexp    ${output}    ${expected_trf}    partial_match=${TRUE}
#    Log to Console    ${output}
#    ${unit_idx}=    Evaluate    ${unit_idx}+${1}
#    Continue For Loop If    '${Q_id}' == '2' or '${Q_id}' == '3' or '${Q_id}' == '4'
#    ${idx}=     Evaluate    ${idx}+${1}
#	END
#    BuiltIn.Log    traffic_data_is_started_successfully
#    [Return]        ${data_start_time}

#Start Data Transfer
#    [Arguments]    ${st_ue_id}     ${en_ue_id}    ${duration}    ${Dir}  ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
#    ...   ${qos_profile_speed_dl}    ${qos_profile}
#    [Documentation]    This keyword is used to start the data transfer in UL and DL
#    FOR     ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
#        ${ul_timestamp}=    Run Keyword If  '${Dir}' == 'ul'
#        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
#        ...    data_rate=${qos_profile_speed_ul}[${ue_id}]    dir=${Dir}    pdu_id=1    trf_id=${trf_id}    qfi_id=${qos_profile}[${ue_id}]
#        ...    sec=${duration}
#
#         ${dl_timestamp}=   Run Keyword If  '${Dir}' == 'dl'
#        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
#        ...    data_rate=${qos_profile_speed_dl}[${ue_id}]    dir=${Dir}    pdu_id=1    trf_id=${trf_id}    qfi_id=${qos_profile}[${ue_id}]
#        ...    sec=${duration}
#
#        ${dl_timestamp1}=   Run Keyword If  '${Dir}' == 'both'
#        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
#        ...    data_rate=${qos_profile_speed_dl}[${ue_id}]    dir=dl    pdu_id=1    trf_id=${trf_id}    qfi_id=${qos_profile}[${ue_id}]
#        ...    sec=${duration}
#        ${ul_timestamp1}=   Run Keyword If  '${Dir}' == 'both'
#        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
#        ...    data_rate=${qos_profile_speed_ul}[${ue_id}]    dir=ul    pdu_id=1    trf_id=${trf_id}    qfi_id=${qos_profile}[${ue_id}]
#        ...    sec=${duration}
#    END



Verify data transfer and get tp
     [Arguments]    ${st_ue_id}     ${en_ue_id}    ${duration}    ${Dir}  ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...   ${qos_profile_speed_dl}    ${qos_profile}
	builtin.Log    ${trf_id}

    [Documentation]    This keyword is used to start the data transfer in UL and DL
    ${tp_ue_dir_ul}=   Run Keyword If  '${Dir}' == 'ul'
    ...    Calculate Throughput    ${st_ue_id}    ${en_ue_id}    ${qos_profile}    ${duration}    ${qos_profile_speed_ul}
    ...    ${qos_profile_unit}    ${Dir}

     ${tp_ue_dir_dl}=   Run Keyword If  '${Dir}' == 'dl'
    ...    Calculate Throughput    ${st_ue_id}    ${en_ue_id}    ${qos_profile}    ${duration}    ${qos_profile_speed_dl}
    ...    ${qos_profile_unit}    ${Dir}

    ${tp_ue_dl}=    Run Keyword If  '${Dir}' == 'both'    Calculate Throughput    ${st_ue_id}    ${en_ue_id}    ${qos_profile}    ${duration}
    ...     ${qos_profile_speed_dl}    ${qos_profile_unit}    dl
    ${tp_ue_ul}=     Run Keyword If  '${Dir}' == 'both'    Calculate Throughput    ${st_ue_id}    ${en_ue_id}    ${qos_profile}    ${duration}
    ...     ${qos_profile_speed_ul}    ${qos_profile_unit}    ul

    Return From Keyword If    '${Dir}' == 'dl'     ${tp_ue_dir_dl}
    Return From Keyword If    '${Dir}' == 'ul'     ${tp_ue_dir_ul}

    [Return]    ${tp_ue_ul}     ${tp_ue_dl}

Start and Stop TTI TRACE
    [Arguments]    ${duration}=${3}
    Start Ttitrace With Streaming Mode
    sleep    ${duration}s
    Stop Ttitrace

Collect TTI Trace
    [Arguments]    ${ttitrace_path}
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    ${new_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}/
    Convert Ttitrace From Pcap To Excelcsv        ${new_path}
    Convert Tti To Csv Mode          ${new_path}
    [Return]        ${new_path}

#Convert Tti To Csv Mode
#    [Arguments]         ${path}
#    Format Tti In Stream Mode         ${path}/output_dl.csv     ${path}/output_dl_formated.csv
#    Format Tti In Stream Mode         ${path}/output_ul.csv     ${path}/output_ul_formated.csv

Calculate Throughput
   [Arguments]    ${st_ue_id}    ${en_ue_id}    ${qos_profile}    ${duration}      ${qos_profile_speed}
   ...    ${qos_profile_unit}    ${dir}
   ${ue_tp_qos_wise}         Create Dictionary
   FOR     ${x}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
        ${pdu_id}=   Set Variable If      '2' in ${qos_profile}[${x}] or '3' in ${qos_profile}[${x}]   2   1
        ${len}=     Get Length      ${qos_profile}[${x}]
        #[Arguments]    ${ue_id}     ${len}   &{qos_profile_speed}    &{qos_profile_unit}    ${pdu_id}
        ${Ue_tp}=      Fetch Throughput    ${x}    ${len}    ${duration}    ${pdu_id}      ${qos_profile_speed}
        ...    ${qos_profile_unit}    ${dir}     ${qos_profile}
        Set To Dictionary	${ue_tp_qos_wise} 	${x}	${Ue_tp}
        ${Ue_tp}         Create List  #Empty the list
    END
    [Return]    ${ue_tp_qos_wise}


Get PDU ID
    [Arguments]     ${QFI}
    # Returns the PDU id based on QFI
     Return Keyword if      '${QFI}'== 2  or  '${QFI}'== 3  or '${QFI}'== 4      2       1

Fetch Throughput
    [Arguments]    ${ue_id}     ${len}      ${duration}    ${pdu_id}    ${qos_profile_speed}    ${qos_profile_unit}
    ...    ${dir}    ${qos_profile}
	${qoslist_ue}=      Set Variable    ${qos_profile}[${ue_id}]
    ${non_gbr_Ue_dtp}         Create List
    ${idx}=     Set Variable    ${1}
    FOR     ${ue_qfi}    IN RANGE    ${len}

		${pdu_id}=   Set Variable If    '2' == '${qoslist_ue[${ue_qfi}]}' or '3' == '${qoslist_ue[${ue_qfi}]}' or '4' == '${qoslist_ue[${ue_qfi}]}'
		...	    2   1
		#[1,2,3]
        ${t_idx}=    utility.get_qfi    ${qoslist_ue}   ${ue_qfi}   ${idx}

        ${tp}=    Validate Traffic For SA updated    ${ue_id}    ${qos_profile_speed}[${ue_id}][${ue_qfi}]
        ...       ${qos_profile_unit}[${ue_id}][${ue_qfi}]     ${duration}    ${dir}    ${pdu_id}      ${t_idx}
        Append To List  ${non_gbr_Ue_dtp}     ${tp}
        Continue For Loop If    '2' == '${qoslist_ue[${ue_qfi}]}' or '3' == '${qoslist_ue[${ue_qfi}]}' or '4' == '${qoslist_ue[${ue_qfi}]}'
        ${idx}=     Evaluate    ${idx}+${1}
    END
    [Return]    ${non_gbr_Ue_dtp}

Validate Traffic For SA updated
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. UL/DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${rate}    ${data_unit}    ${call_dur}    ${dir}   ${pdu_id}=${Pdu_session_ID}    ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=${dir}
    ${bearer_stat}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    ${tp}=      Check Average Rate Mod      ${bearer_stat}    ${dir}    ${rate}    ${data_unit}    ${call_dur}
#    Run Keyword If      '${dir}'=='dl'      Check DL Data Loss      ${bearer_stat}    ${bearer_stat}
#    ...     ELSE    Check UL Data Loss      ${bearer_stat}    ${bearer_stat}
    [Return]    ${tp}

Check Average Rate Mod
    [Arguments]    ${bearer_stat}    ${dir}    ${mbps}      ${data_rate}    ${call_dur}
    ${speed}         Set variable if      '${data_rate}' == 'mbps'      ${1048576}      ${1024}
    ${rcv_bytes}         Get Regexp Matches    ${bearer_stat}    Bytes received +(\\d+)    1
    ${sent_byts}     Get Regexp Matches    ${bearer_stat}    Bytes sent +(\\d+)    1
    Should be equal     ${rcv_bytes[0]}    ${sent_byts[0]}      receive bytes equal to sent bytes
    #Uncomment above code as well as differenctiate UL and DL for UL bytes sent for DL bytes recv
    ${mbps}=   Set Variable If      'amr' in '${mbps}' or 'g7' in '${mbps}' or 'custom' in '${mbps}'     ${vonr_codec_rate}[${mbps}]     ${mbps}
    ${rcv_bits}         Evaluate      ((float(${rcv_bytes[0]})*8)/ ${call_dur})
    ${result}         Evaluate    (${mbps} * ${speed} * 1.1) > ${rcv_bits} > (${mbps} * ${speed} * 0.9)
    Run Keyword if    ${result}    Log to Console    ${dir} Average data rate: ${rcv_bits}
    ...               ELSE    BuiltIn.Log     ${dir} Average data rate: ${rcv_bits}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=${dir} Average data rate failed!
    # Throughput is in the unit of Kbps
    ${tot_bps}=    Evaluate     float(${rcv_bits}/${1024})
    [Return]    ${tot_bps}

Start Data Transfer After GFBR Update
    [Arguments]    ${st_ue_id}     ${en_ue_id}    ${init_duration}   ${trigger_point_dur}    ${Dir}  ${trf_id}   ${qos_profile_unit}
    ...   ${qos_profile_speed_ul}    ${qos_profile_speed_dl}    ${qos_profile}    ${updated_ue_list}    ${updated_qos_profile_speed_ul}
    ...   ${updated_qos_profile_speed_dl}   ${updated_dirct}      ${gfbr_mfbr_profile}    ${ttitrace_streaming}   ${update}=0    ${tti_dur}=${3}
    [Documentation]    This keyword is used to start the data transfer in UL and DL
    ${ul_ue_time_stamp}=    Create Dictionary
    ${dl_ue_time_stamp}=    Create Dictionary
    ${ul_ue_time_stamp1}=   Create Dictionary
    ${dl_ue_time_stamp1}=   Create Dictionary
    FOR     ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
        ${ul_timestamp}=    Run Keyword If  '${Dir}' == 'ul'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${qos_profile_speed_ul}[${ue_id}]    dir=${Dir}    pdu_id=1    trf_id=${trf_id}    qfi_id=${qos_profile}[${ue_id}]
        ...    sec=${init_duration}
         ${dl_timestamp}=   Run Keyword If  '${Dir}' == 'dl'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${qos_profile_speed_dl}[${ue_id}]    dir=${Dir}    pdu_id=1    trf_id=${trf_id}    qfi_id=${qos_profile}[${ue_id}]
        ...    sec=${init_duration}
        ${ul_timestamp1}=    Run Keyword If  '${Dir}' == 'both'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${qos_profile_speed_ul}[${ue_id}]    dir=ul    pdu_id=1    trf_id=${trf_id}    qfi_id=${qos_profile}[${ue_id}]
        ...    sec=${init_duration}
        ${dl_timestamp1}=    Run Keyword If  '${Dir}' == 'both'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${qos_profile_speed_dl}[${ue_id}]    dir=dl    pdu_id=1    trf_id=${trf_id}    qfi_id=${qos_profile}[${ue_id}]
        ...    sec=${init_duration}

        Run Keyword If  '${Dir}' == 'ul'    Set To Dictionary	${ul_ue_time_stamp}	    ${ue_id}    ${ul_timestamp}
        Run Keyword If  '${Dir}' == 'dl'    Set To Dictionary	${dl_ue_time_stamp}	    ${ue_id}    ${dl_timestamp}

        Run Keyword If  '${Dir}' == 'both'    Set To Dictionary	    ${ul_ue_time_stamp}	    ${ue_id}    ${ul_timestamp1}
        Run Keyword If  '${Dir}' == 'both'    Set To Dictionary	    ${dl_ue_time_stamp}	    ${ue_id}    ${dl_timestamp1}
    END
    sleep    ${trigger_point_dur}s      # Sleep tiil updated point
    Run Keyword If  '${update}' == '1'    Create Modify PDU session for GFBR Update   ${st_ue_id}     ${en_ue_id}    ${qos_profile}
    ...    pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    # Updated QOS file
    ${dur}=     Evaluate    ${init_duration} - ${trigger_point_dur}
    FOR     ${ue_id}    IN  @{updated_ue_list}
        ${ul_timestamp_2nd}=    Run Keyword If  '${updated_dirct}' == 'ul'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${updated_qos_profile_speed_ul}[${ue_id}]    dir=${Dir}    pdu_id=1
        ...    trf_id=${trf_id}    qfi_id=${qos_profile}[${ue_id}]    sec=${dur}

         ${dl_timestamp_2nd}=   Run Keyword If  '${updated_dirct}' == 'dl'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${updated_qos_profile_speed_dl}[${ue_id}]    dir=${Dir}    pdu_id=1    trf_id=${trf_id}
        ...    qfi_id=${qos_profile}[${ue_id}]    sec=${dur}

        ${ul_timestamp1_2nd}=       Run Keyword If  '${updated_dirct}' == 'both'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${updated_qos_profile_speed_ul}[${ue_id}]    dir=ul    pdu_id=1    trf_id=${trf_id}
        ...    qfi_id=${qos_profile}[${ue_id}]    sec=${dur}

        ${dl_timestamp1_2nd}=      Run Keyword If  '${updated_dirct}' == 'both'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${updated_qos_profile_speed_dl}[${ue_id}]    dir=dl    pdu_id=1    trf_id=${trf_id}
        ...    qfi_id=${qos_profile}[${ue_id}]    sec=${dur}

        Run Keyword If  '${Dir}' == 'ul'    Set To Dictionary	${ul_ue_time_stamp1}	${ue_id}    ${ul_timestamp_2nd}
        Run Keyword If  '${Dir}' == 'dl'    Set To Dictionary	${dl_ue_time_stamp1}	${ue_id}    ${dl_timestamp_2nd}

        Run Keyword If  '${Dir}' == 'both'    Set To Dictionary	    ${ul_ue_time_stamp1}	    ${ue_id}    ${ul_timestamp1_2nd}
        Run Keyword If  '${Dir}' == 'both'    Set To Dictionary	    ${dl_ue_time_stamp1}	    ${ue_id}    ${dl_timestamp1_2nd}
    END
    Start and Stop TTI TRACE    ${tti_dur}
    sleep    ${dur}s
    ${new_path}        Collect TTI Trace   ${ttitrace_streaming}
    ${ue_to_delta_time_ul}=    Get Time Diff     ${ul_ue_time_stamp1}      ${ul_ue_time_stamp}
    ${ue_to_delta_time_dl}=    Get Time Diff     ${dl_ue_time_stamp1}      ${dl_ue_time_stamp}
    [Return]    ${ue_to_delta_time_ul}    ${ue_to_delta_time_dl}    ${new_path}

Reset Bearer Stats
    [Arguments]     ${st_ue_id}    ${en_ue_id}
    FOR   ${UE_ID}  IN RANGE      ${st_ue_id}    ${en_ue_id}+${1}
        Run Keyword And Continue on Failure    wtsrunner.bearer_stats_clear     ue=${UE_ID}    pdu=${1}
        Run Keyword And Continue on Failure    wtsrunner.bearer_stats_clear     ue=${UE_ID}    pdu=${2}
    END

#Counter Verification Code
Wait for PM Interval to begin
    Wait until the next Measurement Period starts  additional_time=${0}

Collect PM Counters
    ${pm_counters_dir}=  Collect PM Counter  target_dir=${OUTPUT_DIR}/PMC
    Set Suite variable  ${pm_counters_dir}

Get PM counter value modified
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        get the value of a counter in the last reporting period
    ...
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=PM*
    ${last_report}    Get From List   ${PM_report_dict_list}     -1
    ${pi_dict}   Get Dictionary Values   ${last_report}
    ${first_pi}    Get From List   ${pi_dict}     0
    ${cell_dict_list}   Get Dictionary Values   ${first_pi}
    ${cell_dict}   Get From List   ${cell_dict_list}     0
    ${moc_list}   get dictionary keys   ${cell_dict}
    ${full_moc}    Create List
    ${pi_value}    Create List
    FOR  ${key}  IN   @{moc}
          ${key_is_moc}  Run Keyword And Return Status    Should contain   ${moc_list}   ${key}
          Run Keyword If   ${key_is_moc}     Append To List    ${full_moc}    ${key}
    END
    FOR  ${new_key}  IN   @{full_moc}
           ${value}     Get From Dictionary      ${cell_dict}    ${new_key}
           ${value_int}=   convert to integer    ${value}
           Append To List    ${pi_value}    ${value_int}
    END
    BuiltIn.Log    ${pi_id} value: ${pi_value}   console=${P_console}
    [Return]    ${pi_value}

Fetch PM counter values
    [Arguments]    ${pi_list}        ${NRCELL}=NRCELL-1
    @{counter_val} =  Create List
    @{moc_values}=  Create List    MRBTS-1/NRBTS-1/${NRCELL}/PLMN-PLMN/NRPMQAP-1   MRBTS-1/NRBTS-1/${NRCELL}/PLMN-PLMN/NRPMQAP-2
    ...   MRBTS-1/NRBTS-1/${NRCELL}/PLMN-PLMN/NRPMQAP-3    MRBTS-1/NRBTS-1/${NRCELL}/PLMN-PLMN/NRPMQAP-4
    ...   MRBTS-1/NRBTS-1/${NRCELL}/PLMN-PLMN/NRPMQAP-5    MRBTS-1/NRBTS-1/${NRCELL}/PLMN-PLMN/NRPMQAP-6
	...   MRBTS-1/NRBTS-1/${NRCELL}/PLMN-PLMN/NRPMQAP-7    MRBTS-1/NRBTS-1/${NRCELL}/PLMN-PLMN/NRPMQAP-8
    ...   MRBTS-1/NRBTS-1/${NRCELL}/PLMN-PLMN/NRPMQAP-9    MRBTS-1/NRBTS-1/${NRCELL}/PLMN-PLMN/NRPMQAP-10
    ...	  MRBTS-1/NRBTS-1/${NRCELL}/PLMN-PLMN/NRPMQAP-11   MRBTS-1/NRBTS-1/${NRCELL}/PLMN-PLMN/NRPMQAP-12
    ...   MRBTS-1/NRBTS-1/${NRCELL}/PLMN-PLMN/NRPMQAP-13   MRBTS-1/NRBTS-1/${NRCELL}/PLMN-PLMN/NRPMQAP-14
    ...   MRBTS-1/NRBTS-1/${NRCELL}/PLMN-PLMN/NRPMQAP-15
    FOR    ${counter}    IN    @{pi_list}
        ${actual_pm_values}=    Get PM counter value modified    pm_files_location=${OUTPUT_DIR}/PMC/gnb_pm_counters
        ...    moc=${moc_values}    pi_id=${counter}
        Append To List    ${counter_val}    ${actual_pm_values}
    END
    [Return]    ${counter_val}

Get Retainability counters and validate
    [Arguments]    ${NG_FLOW_SETUP_SUCC_PMQAP}      ${NG_FLOW_SETUP_ATT_TOT_PMQAP}
    ...    ${NG_FLOW_REL_PMQAP}    ${NG_FLOW_REL_NORMAL_PMQAP}     ${qos_profile}      ${NRCELL}=NRCELL-1
    @{list}=  Create List   ${NG_FLOW_SETUP_SUCC_PMQAP}    ${NG_FLOW_SETUP_ATT_TOT_PMQAP}
    ...    ${NG_FLOW_REL_PMQAP}    ${NG_FLOW_REL_NORMAL_PMQAP}
    @{counter_value} =   Fetch PM counter values     ${list}       ${NRCELL}
    ${ng_setup_succ}=  Set variable     @{counter_value}[0]
    ${ng_setup_succ_att}=  Set variable     @{counter_value}[1]
    ${ng_setup_rel}=  Set variable     @{counter_value}[2]
    ${ng_setup_rel_normal}=  Set variable     @{counter_value}[3]
    Lists Should Be Equal    ${ng_setup_succ}    ${ng_setup_succ_att}   #PDU session setup successfull,no failure
    Lists Should Be Equal    ${ng_setup_succ}    ${ng_setup_rel}
    Lists Should Be Equal    ${ng_setup_rel}     ${ng_setup_rel_normal}
    ${pmqap_list}=       List from user profile set     ${qos_profile}
    Lists Should Be Equal  ${ng_setup_succ_att}   ${pmqap_list}
    Lists Should Be Equal  ${ng_setup_rel}        ${pmqap_list}

Get Throughput counters and validate
    [Arguments]    ${DL_PDCP_VOL_UE_TPUT_PMQAP}    ${DL_PDCP_TIME_UE_TPUT_PMQAP}
    ...    ${UL_RLC_VOL_UE_TPUT_PMQAP}    ${UL_RLC_TIME_UE_TPUT_PMQAP}    ${AVE_NUMBER_OF_SA_RRC_PMQAP}
    ...    ${AVE_NUMB_OF_SA_DENOM_PMQAP}     ${qos_profile}      ${NRCELL}=NRCELL-1
    @{list}=  Create List   ${DL_PDCP_VOL_UE_TPUT_PMQAP}    ${DL_PDCP_TIME_UE_TPUT_PMQAP}
    ...    ${UL_RLC_VOL_UE_TPUT_PMQAP}    ${UL_RLC_TIME_UE_TPUT_PMQAP}    ${AVE_NUMBER_OF_SA_RRC_PMQAP}
    ...    ${AVE_NUMB_OF_SA_DENOM_PMQAP}
    @{counter_value} =   Fetch PM counter values     ${list}      ${NRCELL}
    ${PDCP_VOL} =   Set variable     @{counter_value}[0]
    ${PDCP_TIME}=   Set variable     @{counter_value}[1]
    ${RLC_VOL} =   Set variable     @{counter_value}[2]
    ${RLC_TIME}=   Set variable     @{counter_value}[3]
    ${SA_RRC}=   Set variable     @{counter_value}[4]
    ${SA_RRC_Denom}=   Set variable     @{counter_value}[5]
    @{SA_RRC_mod} =  Create List
    ${SA_RRC_len}=   Get Length    ${SA_RRC}
    ${pmqap_list}=       List from user profile set     ${qos_profile}
    FOR  ${id}   IN RANGE    ${0}      ${SA_RRC_len}
            Run Keyword IF  ${SA_RRC}[${id}] == ${0} and ${pmqap_list}[${id}] == ${0}    continue for loop
            ${stat}=    Evaluate    (${SA_RRC}[${id}] > 0)
            Should Be True  ${stat}
    END
    ${pmqap_len}=   Get Length    ${PDCP_VOL}
    @{DL_PDCP_Tput} =  Create List
    @{UL_RLC_Tput} =  Create List
    @{tput_ratio}=  Create List
    @{condition}=   Create List
    FOR  ${id}   IN RANGE    ${0}      ${pmqap_len}
            Run Keyword IF  ${PDCP_VOL}[${id}] == ${0}    Append To List    ${DL_PDCP_Tput}   ${0}
            Run Keyword IF  ${RLC_VOL}[${id}] == ${0}    Append To List    ${UL_RLC_Tput}   ${0}
            Continue For Loop IF  ${PDCP_VOL}[${id}] == ${0} and ${RLC_VOL}[${id}] == ${0}
            ${cal1} =   pm_analyzer.ue_count_from_counters     ${PDCP_VOL}[${id}]    @{PDCP_TIME}[${id}]
            Append To List    ${DL_PDCP_Tput}   ${cal1}
            ${cal2} =   pm_analyzer.ue_count_from_counters     ${RLC_VOL}[${id}]     @{RLC_TIME}[${id}]
            Append To List    ${UL_RLC_Tput}   ${cal2}
    END
    Log To Console    DL PDCP Throughput as per PMQAP profile ${DL_PDCP_Tput}
    Log To Console    UL RLC Throughput as per PMQAP profile ${UL_RLC_Tput}
    ${len}=   Get Length    ${DL_PDCP_Tput}
    FOR  ${val}   IN RANGE    ${0}      ${len}
            Run Keyword IF  ${DL_PDCP_Tput}[${val}] == ${0} and ${UL_RLC_Tput}[${val}] == ${0}    Append To List    ${tput_ratio}   ${0}
            Continue For Loop IF  ${DL_PDCP_Tput}[${val}] == ${0} and ${UL_RLC_Tput}[${val}] == ${0}
            Run Keyword IF   ${val} == 3      Append To List    ${tput_ratio}   ${1}
            Continue for Loop IF   ${val} == 3
            ${ratio}=    pm_analyzer.ue_count_from_counters     @{DL_PDCP_Tput}[${val}]     @{UL_RLC_Tput}[${val}]
            Append To List    ${tput_ratio}   ${ratio}
            ${cal3}=     Evaluate  (0.90<= @{tput_ratio}[${val}] <=1.10)
            Run Keyword IF    ${cal3}        Append To List    ${condition}   ${cal3}
            Run Keyword And Ignore Error      Run Keyword IF  ${pmqap_list}[${val}] != ${0}    Should Be True   ${cal3}
    END
    Log To Console     Throughput verified ${condition}

List from user profile set
    [Arguments]       ${qos_profile}
    ${set_pmqap_list}=  create list
    @{gbr_pmqap_list}=  Create List       1    2   3   4   5   6   7   8   9   10   11   12   13    14    15
    ${total_ue_set}=   Get Dictionary Keys   ${qos_profile}
    ${prof}=   Get Dictionary Values   ${qos_profile}
    ${pmqap_set}    Evaluate    [item for sublist in $prof for item in (sublist if isinstance(sublist, list) else [sublist])]
    FOR     ${id}    IN    @{gbr_pmqap_list}
         ${value1}=   Get Match Count   ${pmqap_set}   ${id}
         Append To List  ${set_pmqap_list}   ${value1}
         Run Keyword If   ${id} != 4     continue for loop
         ${status}=  run keyword and return status    should contain   ${pmqap_set}    4
         Run Keyword If   ${status} == False     continue for loop
         ${value2}=   Evaluate   ${value1} + ${set_pmqap_list}[0]
         Set List Value   ${set_pmqap_list}   0    ${value2}
    END
    [Return]       ${set_pmqap_list}

Get PDCP Discard QoS Group counters and validate
    [Arguments]    ${QoS_Group_01}    ${QoS_Group_02}   ${QoS_Group_03}     ${QoS_Group_04}     ${QoS_Group_05}     ${QoS_Group_06}
    ...    ${QoS_Group_07}    ${QoS_Group_08}    ${QoS_Group_09}    ${QoS_Group_10}     ${QoS_Group_11}     ${QoS_Group_12}     ${QoS_Group_13}
    ...    ${QoS_Group_14}     ${QoS_Group_15}     ${QoS_Group_16}     ${QoS_Group_17}     ${QoS_Group_18}     ${QoS_Group_19}     ${QoS_Group_20}
    @{pi_list}=  Create List   ${QoS_Group_01}    ${QoS_Group_02}   ${QoS_Group_03}     ${QoS_Group_04}     ${QoS_Group_05}     ${QoS_Group_06}
    ...    ${QoS_Group_07}    ${QoS_Group_08}    ${QoS_Group_09}    ${QoS_Group_10}     ${QoS_Group_11}     ${QoS_Group_12}     ${QoS_Group_13}
    ...    ${QoS_Group_14}     ${QoS_Group_15}     ${QoS_Group_16}     ${QoS_Group_17}     ${QoS_Group_18}     ${QoS_Group_19}    ${QoS_Group_20}
    @{counter_value} =  Create List
    @{moc_values}=  Create List    MRBTS-1/NRBTS-1     MRBTS-1/NRBTS-1/NRCELL-3
    FOR    ${counter}    IN    @{pi_list}
        ${actual_pm_values}=    Get PM counter value modified    pm_files_location=${OUTPUT_DIR}/PMC/gnb_pm_counters
        ...    moc=${moc_values}    pi_id=${counter}
        Append To List    ${counter_value}    ${actual_pm_values}
    END
    ${PDCP_discard_QoS_Group} =   Set variable     @{counter_value}

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

Start CPRT Trace Capturing
    ${capture_cprt}     Capture CPRT Set Upon Config
    Set suite variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}
#Stop CPRT capture
#    [Arguments]         ${capture_var_cprt}
#    Capture stop        ${capture_var_cprt}
#Set CPRT capture
#    [Arguments]         ${capture_var_cprt}
#    Capture init        ${capture_var_cprt}
#    Capture start       ${capture_var_cprt}
Verify locationAndBandwith for allocated BWP on Scelladdition
    [Arguments]      ${logpath}     ${locationandbandwidth_value}
    [Documentation]      this KW Verifies the largeBWP or smallBWP or PSBWP from locationAndBandwith IE captured CPRT logs
    log to console       Verifies the value of largeBWP or smallBWP or PSBWP from locationAndBandwith IE captured CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}    nr-rrc.rrcReconfiguration_element
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...          field_name=nr-rrc.sCellConfigDedicated_element      attrib_name=showname     attrib_value=sCellConfigDedicated
	${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=nr-rrc.locationAndBandwidth    attrib_name=showname
    ${attrib_values}    convert to string       ${attrib_values}
    should contain    ${attrib_values}    ${locationandbandwidth_value}

Verify locationAndBandwith for allocated BWP during Initial access
    [Arguments]      ${logpath}     ${locationandbandwidth_value}       ${psbwpvalue}=0
    [Documentation]      this KW Verifies the value of largeBWP or smallBWP or PSBWP from locationAndBandwith IE captured CPRT logs
    log to console       Verifies the value of largeBWP or smallBWP or PSBWP from locationAndBandwith IE captured CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}    nr-rrc.rrcReconfiguration_element
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...          field_name=nr-rrc.spCellConfigDedicated_element      attrib_name=showname     attrib_value=spCellConfigDedicated
	${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=nr-rrc.locationAndBandwidth    attrib_name=showname
    ${attrib_values}    convert to string       ${attrib_values}
    Run Keyword If      ${psbwpvalue}==0      should contain    ${attrib_values}    ${locationandbandwidth_value}
    ...     ELSE    should contain    ${attrib_values}    ${locationandbandwidth_value}     ${psbwpvalue}


#Get filtered PDML file from pcap
#    [Arguments]                     ${pcapFile}       ${filterExp}=None
#    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
#    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
#    ...                             filterName=${filterExp}         filterExp=${filterExp}
#    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}
#    [Return]    ${pdmlFile}

Attach ue and verify bwp configured
      [Arguments]    ${ueid}     ${locandbwp}     ${psbwp}=0    ${num_ues}=4
    Start CPRT Trace Capturing
    ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID     ${ueid}    ${ueid}    pdu_id=1    nw_id=1
    Create Modify PDU session New   ${ueid}     ${ueid}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...                         ue_to_bearer_list=${ue_to_bearer_list[1]}       num_ues=${num_ues}
    Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UEs_Attach_UE${ueid}.pcap
    Verify locationAndBandwith for allocated BWP during Initial access    ${LOG_PATH}/NODECPRT_GNB_UEs_Attach_UE${ueid}.pcap    ${locandbwp}
    ...     ${psbwp}
    append to list      ${Rnti_list}    ${ue_to_bearer_list[0]}
Attach ue and verify bwp configured with crnti
      [Arguments]    ${ueid}     ${locandbwp}     ${psbwp}=0    ${num_ues}=4
    Start CPRT Trace Capturing
    ${rnti}=       MultiUE Register should be Successful with Fetch crnti     ${ueid}    ${ueid}    pdu_id=1    nw_id=1
    Create Modify PDU session New   ${ueid}     ${ueid}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...                         ue_to_bearer_list=${ue_to_bearer_list[1]}       num_ues=${num_ues}
    Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UEs_Attach_UE${ueid}.pcap
    Verify locationAndBandwith for allocated BWP during Initial access    ${LOG_PATH}/NODECPRT_GNB_UEs_Attach_UE${ueid}.pcap    ${locandbwp}
    ...     ${psbwp}
    append to list      ${Rnti_list}    ${rnti}
Verify locationAndBandwidth of scell
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${locandbwp}
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    Verify locationAndBandwith for allocated BWP on Scelladdition       ${LOG_PATH}/NODECPRT_GNB_UEs_Attach_UE${ue_idx}.pcap    ${locandbwp}
    END
Verify bwp configured
      [Arguments]    ${ueid}     ${locandbwp}     ${psbwp}=0
    Verify locationAndBandwith for allocated BWP during Initial access    ${LOG_PATH}/NODECPRT_GNB_UEs_Attach_UE${ueid}.pcap    ${locandbwp}
    ...     ${psbwp}

Attach ue and verify psbwp configured
    [Arguments]    ${ueid}     ${locandbwp}     ${psbwp}=0
    Start CPRT Trace Capturing
    ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID     ${ueid}    ${ueid}    pdu_id=1    nw_id=1
    Create Modify PDU session   ${ueid}     ${ueid}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...                         ue_to_bearer_list=${ue_to_bearer_list[1]}       num_ues=4
    Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UEs_Attach_UE${ueid}.pcap
    Verify locationAndBandwith for allocated BWP during Initial access    ${LOG_PATH}/NODECPRT_GNB_UEs_Attach_UE${ueid}.pcap    ${locandbwp}
    ...     ${psbwp}

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


Get Received Sent Bytes
   [Arguments]    ${st_ue_id}    ${en_ue_id}    ${qos_profile}      ${dir}
   ${ue_sent_recv_qos_wise}         Create Dictionary
   FOR     ${x}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
        ${pdu_id}=   Set Variable If      '2' in ${qos_profile}[${x}] or '3' in ${qos_profile}[${x}]   2   1
        ${len}=     Get Length      ${qos_profile}[${x}]

        ${Ue_tp}=    Get Bearer Stats     ${x}    ${len}      ${pdu_id}     ${dir}	${qos_profile}
        Set To Dictionary	${ue_sent_recv_qos_wise} 	${x}	${Ue_tp}
        ${Ue_tp}         Create List  #Empty the list
    END
    [Return]    ${ue_sent_recv_qos_wise}

Get Bearer Stats
    [Arguments]    ${ue_id}     ${len}        ${pdu_id}   ${dir}	${qos_profile}
	${qoslist_ue}=      Set Variable    ${qos_profile}[${ue_id}]
    ${sent_rcv}         Create List
    ${idx}=     Set Variable    ${1}
    FOR     ${ue_qfi}    IN RANGE    ${len}
		${pdu_id}=   Set Variable If    '2' == '${qoslist_ue[${ue_qfi}]}' or '3' == '${qoslist_ue[${ue_qfi}]}' or '4' == '${qoslist_ue[${ue_qfi}]}'
		...	    2   1
		#[1,2,3]
        ${t_idx}=    utility.get_qfi    ${qoslist_ue}   ${ue_qfi}   ${idx}
        ${reading}=    Read Bearer stats Command    ${ue_id}    ${dir}    ${pdu_id}      ${t_idx}
        Append To List  ${sent_rcv}     ${reading}
        Continue For Loop If    '2' == '${qoslist_ue[${ue_qfi}]}' or '3' == '${qoslist_ue[${ue_qfi}]}' or '4' == '${qoslist_ue[${ue_qfi}]}'
        ${idx}=     Evaluate    ${idx}+${1}
    END
    [Return]    ${sent_rcv}

Read Bearer stats Command
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. UL/DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}    ${dir}   ${pdu_id}   ${qfi_id}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=${dir}
    ${bearer_stat}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
	${rcv_bytes}     Get Regexp Matches    ${bearer_stat}    Bytes received +(\\d+)    1
    ${sent_byts}     Get Regexp Matches    ${bearer_stat}    Bytes sent +(\\d+)    1
    Should be equal     ${rcv_bytes[0]}    ${sent_byts[0]}      receive bytes equal to sent bytes
    [Return]    ${rcv_bytes[0]}	        ${sent_byts[0]}

Get Received Sent Bytes New
   [Arguments]    ${st_ue_id}    ${en_ue_id}    ${qos_profile}      ${dir}
   ${ue_sent_recv_qos_wise}         Create Dictionary
   FOR     ${x}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
        ${pdu_id}=   Set Variable If      '2' in ${qos_profile}[${x}] or '3' in ${qos_profile}[${x}]   2   1
        ${len}=     Get Length      ${qos_profile}[${x}]

        ${Ue_tp}=    Get Bearer Stats New     ${x}    ${len}      ${pdu_id}     ${dir}	${qos_profile}
        Set To Dictionary	${ue_sent_recv_qos_wise} 	${x}	${Ue_tp}
        ${Ue_tp}         Create List  #Empty the list
    END
    [Return]    ${ue_sent_recv_qos_wise}

Get Bearer Stats New
    [Arguments]    ${ue_id}     ${len}        ${pdu_id}   ${dir}	${qos_profile}
	${qoslist_ue}=      Set Variable    ${qos_profile}[${ue_id}]
    ${sent_rcv}         Create List
    ${idx}=     Set Variable    ${1}
    FOR     ${ue_qfi}    IN RANGE    ${len}
		${pdu_id}=   Set Variable If    '2' == '${qoslist_ue[${ue_qfi}]}' or '3' == '${qoslist_ue[${ue_qfi}]}' or '4' == '${qoslist_ue[${ue_qfi}]}'
		...	    2   1
		#[1,2,3]
        ${t_idx}=    utility.get_qfi    ${qoslist_ue}   ${ue_qfi}   ${idx}
        ${reading}=    Read Bearer stats Command New    ${ue_id}    ${dir}    ${pdu_id}      ${t_idx}
        Append To List  ${sent_rcv}     ${reading}
        Continue For Loop If    '2' == '${qoslist_ue[${ue_qfi}]}' or '3' == '${qoslist_ue[${ue_qfi}]}' or '4' == '${qoslist_ue[${ue_qfi}]}'
        ${idx}=     Evaluate    ${idx}+${1}
    END
    [Return]    ${sent_rcv}

Read Bearer stats Command New
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. UL/DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}    ${dir}   ${pdu_id}   ${qfi_id}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=${dir}
    ${bearer_stat}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
	${rcv_bytes}     Get Regexp Matches    ${bearer_stat}    Bytes received +(\\d+)    1
    ${sent_byts}     Get Regexp Matches    ${bearer_stat}    Bytes sent +(\\d+)    1
    ${ratio_rcv_sent}    Evaluate    ${rcv_bytes[0]}/${sent_byts[0]}
    Should be true     0.99<=${ratio_rcv_sent}<=1     #receive bytes equal to sent bytes
    [Return]    ${rcv_bytes[0]}	        ${sent_byts[0]}

Get Time Diff
    [Arguments]    ${ue_time2}      ${ue_time1}
    ${ue_list}=     Get Dictionary Keys     ${ue_time1}
    ${ue_time_dev}=     Create Dictionary
    FOR     ${ue_id}    IN      @{ue_list}
        ${diff}    Get Delta Time in list   ${ue_time2}[${ue_id}]       ${ue_time1}[${ue_id}]
        Set To Dictionary	    ${ue_time_dev}      ${ue_id}    ${diff}
    END
    [Return]     ${ue_time_dev}

Get Delta Time in list
    [Arguments]    ${time2_list}      ${time1_list}
    ${length}=     Get Length  ${time2_list}
    ${delta_list}=     Create List
    FOR    ${idx}   IN RANGE    ${length}
        ${diff} =	DateTime.Subtract Date From Date   ${time2_list[${idx}]}     ${time1_list[${idx}]}
        Append To List  ${delta_list}     ${diff}
    END
    [Return]      ${delta_list}

Set fixed cqi bler for single UE
    [Arguments]  ${ue_id}    ${dirct}
    # For DL BLER
    Run Keyword if  '${dirct}' == 'dl'    wtsrunner.bler_testmode_nr    profile_id=40    target_mcs=3
    ...    num_dl_pkts=10000    num_harq_nack=500
    Run Keyword if  '${dirct}' == 'dl'    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=bler    action=activate    profile_id=40
    # Fr UL SINR
    Run Keyword if  '${dirct}' == 'ul'
    ...    wtsrunner.ul_sinr_testmode_nr    profile_id=3    sinr_target_srs=-250    sinr_target_pusch=-250
    ...    sinr_target_pucch=-250    sinr_target_preamble=-250
    Run Keyword if  '${dirct}' == 'ul'
    ...    wtsrunner.ue_testmode_set_nr  id=${ue_id}  testmode=ul_sinr    action=activate    profile_id=3


MultiUE Register should be Successful with Fetch Bearer ID and cprt
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    ${ue_to_bearer_list}=    Create Dictionary
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    Start CPRT Trace Capturing
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/regst.txt	    ${output}
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
    Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UEs_Attach_UE${ue_idx}.pcap
    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}     ${ue_to_bearer_list}


#DSS Keywords
Enable 8379 With DSS
    [Arguments]    ${prb_list}    ${ALLOC_SUBFRAME}    ${min_dss_ratio}    ${max_dss_ratio}
    Setup XP LINK    2    1
    Set LTE NR DSS Mode
    Setup DSS Link    2    1
    Setup gbrsupport Capab in CRM
    Set DL UL RESOURCE Cell Reservation    2    1    ${min_dss_ratio}    ${max_dss_ratio}
    Cell Resource Allocation    2    1    ${prb_list}    ${ALLOC_SUBFRAME}

Suite setup 8379_dss
    Change IPHY File Value
    Add RD Parameters To GNB Swconfig File    ${RD_dss}


Change IPHY File Value
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
    Modify Text File    ${file_path}    ${OLD_PARAS_IPHY}    ${NEW_PARAS_IPHY}
    Send IPHY XML To Airphone    ${file_path}

Setup XP LINK
    [Arguments]    ${enb_id}    ${target_id}
	builtin.Log    ${enb_id}
	builtin.Log    ${target_id}
    ${pattern}=    Set Variable    ENB-2: XpAP Link with GNB-1 .* is up
    ${result}=     execute_command.setup_xp_link    2    1    ${pattern}
    Should contain    ${result}    Pass

Set LTE NR DSS Mode
    [Documentation]    This keyword is for setting LTE NR DSS MODE.
    Log To Console   \nSet LTE NR DSS Mode...\n
    wtsrunner.enb_cell_param   id=1   enb=2   lte_nr_dss_mode=DL_CRS_TDM_UL_FDM   antenna_ports_num=2


Setup DSS Link
    [Arguments]    ${enb_id}    ${target_id}
    builtin.Log    ${enb_id}
	builtin.Log    ${target_id}
    ${pattern}=    Set Variable    ENB-2: Cell 1: EN DSS UL Cell Subcarrier Resource Coordination success on remote NE
    ${result}=     execute_command.setup_dss_link   2    1    ${pattern}
    Should contain    ${result}    Pass

Setup gbrsupport Capab in CRM
    [Documentation]    This keyword is for setting gbrload capability in ENDLCRMSF INFO IE
    Log To Console   \nSetting up gbrload capability in CRM...\n
    wtsrunner.enb_cell_dss_param   id=1   enb=2   dl_crm_sf_capabilities=gbr_support

Set DL UL RESOURCE Cell Reservation
    [Arguments]    ${enb_id}    ${target_id}    ${min_dss_ratio}    ${max_dss_ratio}
	builtin.Log    ${enb_id}
	builtin.Log    ${target_id}
    ${pattern}=    Set Variable    ENB-2: Cell 1: Update Indication : EN DSS UL Cell Subcarrier Resource Coordination: both NEs synchronized
    ${result}=     execute_command.set_dl_ul_cell_reservation   2    1    ${min_dss_ratio}    ${max_dss_ratio}    ${pattern}
    Should contain    ${result}    Pass


Cell Resource Allocation
    [Arguments]    ${enb_id}    ${target_id}    ${prb_list}    ${ALLOC_SUBFRAME}
	builtin.Log    ${enb_id}
	builtin.Log    ${target_id}
    ${pattern}=    Set Variable    Received EN DSS UL Subcarrier Resource Allocation Response SequenceNumber
    ${result}=     execute_command.cell_resource_allocation   2    1    ${prb_list}    ${ALLOC_SUBFRAME}    ${pattern}
    Should contain    ${result}    Pass


# Below Kewords are almost same with minor changes to avoid chking nongbr

Verify data transfer and get tp gbr_nongbr
     [Arguments]    ${st_ue_id}     ${en_ue_id}    ${duration}    ${Dir}  ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...   ${qos_profile_speed_dl}    ${qos_profile}     ${gbr_chk}=-1       ${skipp}=-1
	builtin.Log    ${trf_id}

    [Documentation]    This keyword is used to start the data transfer in UL and DL
    ${tp_ue_dir_ul}=   Run Keyword If  '${Dir}' == 'ul'
    ...    Calculate Throughput gbr_nongbr    ${st_ue_id}    ${en_ue_id}    ${qos_profile}    ${duration}    ${qos_profile_speed_ul}
    ...    ${qos_profile_unit}    ${Dir}    gbr_chk=${gbr_chk}      skipp=${skipp}

     ${tp_ue_dir_dl}=   Run Keyword If  '${Dir}' == 'dl'
    ...    Calculate Throughput gbr_nongbr   ${st_ue_id}    ${en_ue_id}    ${qos_profile}    ${duration}    ${qos_profile_speed_dl}
    ...    ${qos_profile_unit}    ${Dir}    gbr_chk=${gbr_chk}      skipp=${skipp}

    ${tp_ue_dl}=    Run Keyword If  '${Dir}' == 'both'    Calculate Throughput gbr_nongbr    ${st_ue_id}    ${en_ue_id}
    ...    ${qos_profile}    ${duration}     ${qos_profile_speed_dl}    ${qos_profile_unit}    dl    gbr_chk=${gbr_chk}    skipp=${skipp}
    ${tp_ue_ul}=     Run Keyword If  '${Dir}' == 'both'    Calculate Throughput gbr_nongbr    ${st_ue_id}    ${en_ue_id}
    ...    ${qos_profile}    ${duration}     ${qos_profile_speed_ul}    ${qos_profile_unit}    ul    gbr_chk=${gbr_chk}    skipp=${skipp}

    #Collect TTI Trace   ${ttitrace_streaming}
    Return From Keyword If    '${Dir}' == 'dl'     ${tp_ue_dir_dl}
    Return From Keyword If    '${Dir}' == 'ul'     ${tp_ue_dir_ul}

    [Return]    ${tp_ue_ul}     ${tp_ue_dl}

Calculate Throughput gbr_nongbr
   [Arguments]    ${st_ue_id}    ${en_ue_id}    ${qos_profile}    ${duration}      ${qos_profile_speed}    ${qos_profile_unit}
   ...    ${dir}      ${gbr_chk}=-1     ${skipp}=-1

   ${ue_tp_qos_wise}         Create Dictionary
   FOR     ${x}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
        ${pdu_id}=   Set Variable If      '2' in ${qos_profile}[${x}] or '3' in ${qos_profile}[${x}]   2   1
        ${len}=     Get Length      ${qos_profile}[${x}]
        #[Arguments]    ${ue_id}     ${len}   &{qos_profile_speed}    &{qos_profile_unit}    ${pdu_id}
        ${Ue_tp}=      Fetch Throughput gbr_nongbr    ${x}    ${len}    ${duration}    ${pdu_id}    ${qos_profile_speed}
        ...    ${qos_profile_unit}    ${dir}     ${qos_profile}     gbr_chk=${gbr_chk}       skipp=${skipp}
        Set To Dictionary	${ue_tp_qos_wise} 	${x}	${Ue_tp}
        ${Ue_tp}         Create List  #Empty the list
    END
    [Return]    ${ue_tp_qos_wise}


Fetch Throughput gbr_nongbr
    [Arguments]    ${ue_id}     ${len}      ${duration}    ${pdu_id}    ${qos_profile_speed}    ${qos_profile_unit}    ${dir}
    ...    ${qos_profile}   ${gbr_chk}=-1       ${skipp}=-1

	${qoslist_ue}=      Set Variable    ${qos_profile}[${ue_id}]
    ${non_gbr_Ue_dtp}         Create List
    ${idx}=     Set Variable    ${1}
    ${gbr_qfi_list}=        utility.get_gbr_list_cfg    ${wts_cfg_file}
    FOR     ${ue_qfi}    IN RANGE    ${len}
		${pdu_id}=   Set Variable If    '2' == '${qoslist_ue[${ue_qfi}]}' or '3' == '${qoslist_ue[${ue_qfi}]}' or '4' == '${qoslist_ue[${ue_qfi}]}'
		...	    2   1
		#[1,2,3]
        ${t_idx}=    utility.get_qfi    ${qoslist_ue}   ${ue_qfi}   ${idx}
        ${gbr_chk_need}=    Run Keyword If  '${gbr_chk}' != '-1'    Check Gbr Qfi     ${qoslist_ue[${ue_qfi}]}    ${gbr_qfi_list}
        ${gbr_chk_need}=      Set Variable If      '${gbr_chk_need}' == 'None'      -1        ${gbr_chk_need}
        ${gbr_chk_need}=      Set Variable If      '${skipp}' != '-1'      1        ${gbr_chk_need}
        ${tp}=    Validate Traffic For SA updated gbr_nongbr    ${ue_id}    ${qos_profile_speed}[${ue_id}][${ue_qfi}]
        ...       ${qos_profile_unit}[${ue_id}][${ue_qfi}]     ${duration}    ${dir}    ${pdu_id}      ${t_idx}
        ...       gbr_chk=${gbr_chk_need}
        Append To List  ${non_gbr_Ue_dtp}     ${tp}
        Continue For Loop If    '2' == '${qoslist_ue[${ue_qfi}]}' or '3' == '${qoslist_ue[${ue_qfi}]}' or '4' == '${qoslist_ue[${ue_qfi}]}'
        ${idx}=     Evaluate    ${idx}+${1}
    END
    [Return]    ${non_gbr_Ue_dtp}

Check Gbr Qfi
    [Arguments]    ${t_idx}     ${gbr_qfi_list}
    ${len}=     Get Length      ${gbr_qfi_list}
    FOR     ${idx}    IN RANGE    ${len}
#        Return From Keyword If  '-1' != '${gbr_qfi_list[${idx}]}'   1
        Return From Keyword If  ${t_idx} == ${gbr_qfi_list[${idx}]}   -1
    END

    [Return]   1

Validate Traffic For SA updated gbr_nongbr
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. UL/DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${rate}    ${data_unit}    ${call_dur}    ${dir}   ${pdu_id}=${Pdu_session_ID}    ${qfi_id}=${QFI_ID}
    ...            ${gbr_chk}=-1

    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=${dir}
    ${bearer_stat}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    ${tp}=      Check Average Rate Mod gbr_nongbr      ${bearer_stat}    ${dir}    ${rate}    ${data_unit}    ${call_dur}
    ...     ${gbr_chk}

    [Return]    ${tp}

Check Average Rate Mod gbr_nongbr
    [Arguments]    ${bearer_stat}    ${dir}    ${mbps}      ${data_rate}    ${call_dur}
    ...    ${gbr_chk}=-1

    ${speed}         Set variable if      '${data_rate}' == 'mbps'      ${1048576}      ${1024}
    ${rcv_bytes}     Get Regexp Matches    ${bearer_stat}    Bytes received +(\\d+)    1
    ${sent_byts}     Get Regexp Matches    ${bearer_stat}    Bytes sent +(\\d+)    1
    Run Keyword If  '${gbr_chk}' == '-1'
    ...         Should be equal     ${rcv_bytes[0]}    ${sent_byts[0]}      receive bytes equal to sent bytes
    #Uncomment above code as well as differenctiate UL and DL for UL bytes sent for DL bytes recv


    ${mbps}=   Set Variable If     'amr' in '${mbps}' or 'g7' in '${mbps}' or 'custom' in '${mbps}'    ${vonr_codec_rate}[${mbps}]     ${mbps}
    ${rcv_bits}       Evaluate      ((float(${rcv_bytes[0]})*8)/ ${call_dur})
    ${result}         Evaluate    (${mbps} * ${speed} * 1.1) > ${rcv_bits} > (${mbps} * ${speed} * 0.9)
    Run Keyword if    ${result}    Log to Console    ${dir} Average data rate: ${rcv_bits}
    ...               ELSE    BuiltIn.Log     ${dir} Average data rate: ${rcv_bits}    level=ERROR

    Run Keyword If  '${gbr_chk}' == '-1'
    ...    Run Keyword and Continue on Failure
    ...    Should Be True    ${result}    msg=${dir} Average data rate failed!
    ${tot_bps}=    Evaluate     float(${rcv_bits}/${1024})
    #${diff}=       Evaluate     ${sent_byts}-${rcv_bytes}
    [Return]    ${tot_bps}

MultiUE Register should be Successful with Fetch crnti
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    ${crnti_list}       Create List
    ${ue_to_bearer_list}=    Create Dictionary
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/regst.txt	    ${output}
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk '{print $9}'
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
    [Return]      ${crnti_list}
