*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Samik Sarkar
...              :contact: samik.sarkar@nokia.com

Variables    ta5g_global_var

Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../../resources/robot/TTI_Traces.robot
Resource         ../../resources/NPS/SWENG/robot/PacketSearch.robot
Resource         ../../resources/robot/Setup_Env.robot
Resource         ../../resources/robot/Airphone.robot
Resource         ../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../resources/robot/PM_Counters.robot
#Resource         ../resources/ECEcommon/common_setup_teardown.robot
#Resource         ../../CB008379/resources/common/common_setup_teardown.robot
#Resource       ../resources/robot/common_log_collection.robot
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          luashark_tools.analyzer       WITH NAME       analyzer
Library          taf.sbts.oam.coam.admin                 WITH NAME   ute_adm
Library          Collections
Library          OperatingSystem
Library          ta5g_tshark
Library          ta5g_commissioning
Library          taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library          taf.transport.ssh                 WITH NAME    csn
Library          String
#Library          ../../CB008379/resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library          ../../resources/NPS/SWENG/python_libs/luashark_tools.py
Library          ../../resources/python/BIP_Capture.py
Library          ../../resources/python/CPRT_Capture.py
#Library          ././resources/python/PM_Counter_Verify.py    WITH NAME     pm_analyzer
Library          ../../CB008379/resources/python/execute_command.py
Library          ../../CB008379/resources/python/increase_buffer_size.py
Library         ../../CB008379/resources/python/utility.py
Library         ../../CB008379/resources/python/tti_trace_utility.py
Library          DateTime
Library          ../../CB008379/resources/python/l1b_tag_gnb.py

*** Variables ***
&{GNB_ASIK}                ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${BIP_SCRIPT_PATH}         /home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/resources/NPS/SWENG/config/script/
${port}                    22
# #  Add your vonr codec speed
&{vonr_codec_rate}         amr_wb_18_25=18.6      amr_wb_23_85=21.4
@{gbr_qfi_list_cfg}        3	4	5 	6	7	8	9	10	11	12	13	14	15
&{profiles_mapping}     null=NIA0   snow3g=NIA1   aes=NIA2    zuc=NIA3
#   Add your vonr codec speed

*** Keywords ***
## Delta Commissioning
Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Increase Buffer Size for VM and IPHY
    increase_buffer_size.increase_buffer_size     ${AP_ASIK.ip}      ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}

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
        Run Keyword if  ${len} >0   Add PDU session     ${ue_id}      ${pdu_id}      ${gw_id}     ${QOS_strng}
        ...    ue_to_bearer_list=${ue_to_bearer_list}
    END
    log to console      ${gfbr_mfbr_profile}
Create Modify PDU session New
    [Arguments]     ${st_ue_id}     ${en_ue_id}    ${qos_profile}   ${pdu_id}     ${gfbr_mfbr_profile}=-1
         ...        ${num_ues}=${en_ue_id}          ${ue_to_bearer_list}=${bearer_list}
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
    log to console      ${gfbr_mfbr_profile}
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
    log to console      ${gfbr_mfbr_profile}
Modified UE PDU Addition should be Successful
    [Arguments]    ${ue_id}     ${pdu_id}     ${nw_id}    ${gw_id}
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    ${RAN_UE_NGAP_ID}=      Evaluate    ${ue_id}-${1}
    ${pdu_addition_pattern}=    Set Variable    Pdu Session Resource Setup Response Message with RAN UE NGAP ID ${RAN_UE_NGAP_ID} handled
    ${output}=      Read WTS Output For Pattern And Print matching Lines    ${pdu_addition_pattern}    ${Timeout_SA}
    ${str_len}=     Get Length     ${output}
    Should Not Be Equal     ${str_len}      ${0}
    BuiltIn.Log                ue_pdu_addition_is_ok

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

Add PDU session
     [Arguments]     ${ue_id}      ${pdu_id}      ${gw_id}     ${Q_O_ADD}      ${ue_to_bearer_list}=${bearer_list}
     [Documentation]    This keyword starts the ADD PDU  session and modification
        Run Keyword If   ${pdu_id} == 2
        ...     Modified UE PDU Addition should be Successful       ${ue_id}     ${pdu_id}     1   ${gw_id}
       ${x}=   Run Keyword If    ${pdu_id} != ${2}  execute_command.modify_pdu_session_verify     ${ue_id}    ${pdu_id}
       ...     qosflows_to_add=${Q_O_ADD}   ue_to_bearer_list=${ue_to_bearer_list}
        ...    ELSE
        ...    VONR GBR NON GBR Add PDU session    ${ue_id}    ${pdu_id}    ${Q_O_ADD}      ue_to_bearer_list=${ue_to_bearer_list}
        Should Contain    ${x}   Pass

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
    log to console      ${gfbr_mfbr_profile}
VONR GBR NON GBR Add PDU session
    [Arguments]    ${ue_id}    ${pdu_id}    ${Q_O_ADD}      ${ue_to_bearer_list}=${bearer_list}

      ${x}=		execute_command.modify_pdu_session_verify    ${ue_id}    ${pdu_id}   qosflows_to_add=${Q_O_ADD}
      ...   ue_to_bearer_list=${ue_to_bearer_list}
      Should Contain    ${x}   Pass
      [Return]      ${x}


#Modify it run on QOS basis per ue
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
    log to console      ${trf_id}


Verify data transfer and get tp
     [Arguments]    ${st_ue_id}     ${en_ue_id}    ${duration}    ${Dir}  ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...   ${qos_profile_speed_dl}    ${qos_profile}

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
    log to console      ${trf_id}

Start and Stop TTI TRACE
    [Arguments]    ${duration}=${3}
    Start Ttitrace With Streaming Mode
    sleep    ${duration}s
    Stop Ttitrace

Collect TTI Trace
    [Arguments]    ${ttitrace_path}
    ${new_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}/
    Convert Ttitrace From Pcap To Excelcsv        ${new_path}
    Convert Tti To Csv Mode          ${new_path}
    [Return]        ${new_path}

Convert Tti To Csv Mode
    [Arguments]         ${path}
    Format Tti In Stream Mode         ${path}/output_dl.csv     ${path}/output_dl_formated.csv
    Format Tti In Stream Mode         ${path}/output_ul.csv     ${path}/output_ul_formated.csv

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
        wtsrunner.bearer_stats_clear     ue=${UE_ID}    pdu=${1}
        ${output}    Read WTS Output Until Pattern Matches    .*UE${UE_ID}: Clearing Internal traffic*.     ${Timeout_SA}
        wtsrunner.bearer_stats_clear     ue=${UE_ID}    pdu=${2}
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
    [Arguments]    ${pi_list}
    @{counter_val} =  Create List
    @{moc_values}=  Create List    MRBTS-1/NRBTS-1/NRCELL-1
    FOR    ${counter}    IN    @{pi_list}
        ${actual_pm_values}=    Get PM counter value modified    pm_files_location=${OUTPUT_DIR}/PMC/gnb_pm_counters
        ...    moc=${moc_values}    pi_id=${counter}
        Append To List    ${counter_val}    ${actual_pm_values}
    END
    [Return]    ${counter_val}

Validate PM Counters
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}     ${cellid}=1
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}      moc=MRBTS-1/NRBTS-1/NRCELL-${cellid}

Get Paging counters and validate
    [Arguments]     ${NRPAG_RAN_PAGING_SUCC_SENT}            ${NRRCC_RRC_RESUME_REQUEST1}           ${RA_MSG3_CCCH1_RECEP}
    ...          ${value_expected}      ${cellid}=1
    CB008225_basic_keywords.Collect PM Counters
    Validate PM Counters       ${pm_counters_dir}          ${NRPAG_RAN_PAGING_SUCC_SENT}           ${value_expected}        ${cellid}
    Validate PM Counters       ${pm_counters_dir}          ${NRRCC_RRC_RESUME_REQUEST1}            ${value_expected}        ${cellid}
    Validate PM Counters       ${pm_counters_dir}          ${RA_MSG3_CCCH1_RECEP}                  ${value_expected}        ${cellid}
    Log To Console      Counter Value Verified

Get Resume counters and validate
    [Arguments]            ${NRRCC_RRC_RESUME_REQUEST1}      ${NRRCC_RRC_RESUME_SUCC}          ${RA_MSG3_CCCH1_RECEP}
    ...          ${DL_DELAY_PAGING_RRC_INCT_CON}       ${value_expected}
    CB008225_basic_keywords.Collect PM Counters
    Validate PM Counters       ${pm_counters_dir}          ${NRRCC_RRC_RESUME_SUCC}               ${value_expected}
    Validate PM Counters       ${pm_counters_dir}          ${NRRCC_RRC_RESUME_REQUEST1}          ${value_expected}
    Validate PM Counters       ${pm_counters_dir}          ${RA_MSG3_CCCH1_RECEP}                 ${value_expected}
    PM_Counters.Check PM counter value bigger than    expected_value=0   pm_files_location=${pm_counters_dir}
    ...  pi_id=${DL_DELAY_PAGING_RRC_INCT_CON}       moc=MRBTS-1/NRBTS-1/NRCELL-1
    Log To Console      Counter Value Verified

Get Fallback counters and validate
    [Arguments]     ${NRRCC_RRC_RESUME_REQUEST1}         ${NRRCC_RRC_RESUME_FALLBACK_ATT}         ${NRRCC_RRC_RESUME_FALLBACK_SUCC}
    ...         ${RA_MSG3_CCCH1_RECEP}          ${value_expected}
    CB008225_basic_keywords.Collect PM Counters
    Validate PM Counters       ${pm_counters_dir}          ${NRRCC_RRC_RESUME_REQUEST1}           ${value_expected}
    Validate PM Counters       ${pm_counters_dir}          ${NRRCC_RRC_RESUME_FALLBACK_ATT}        ${value_expected}
    Validate PM Counters       ${pm_counters_dir}          ${NRRCC_RRC_RESUME_FALLBACK_SUCC}        ${value_expected}
    Validate PM Counters       ${pm_counters_dir}          ${RA_MSG3_CCCH1_RECEP}          ${value_expected}
    Log To Console      Counter Value Verified

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

MultiUE Register should be Successful with Fetch Bearer ID
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
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
    ${pattern}=    Set Variable    ENB-2: XpAP Link with GNB-1 .* is up
    ${result}=     execute_command.setup_xp_link    2    1    ${pattern}
    Should contain    ${result}    Pass
    log to console      ${enb_id}
    log to console      ${target_id}
Set LTE NR DSS Mode
    [Documentation]    This keyword is for setting LTE NR DSS MODE.
    Log To Console   \nSet LTE NR DSS Mode...\n
    wtsrunner.enb_cell_param   id=1   enb=2   lte_nr_dss_mode=DL_CRS_TDM_UL_FDM   antenna_ports_num=2


Setup DSS Link
    [Arguments]    ${enb_id}    ${target_id}
    ${pattern}=    Set Variable    ENB-2: Cell 1: EN DSS UL Cell Subcarrier Resource Coordination success on remote NE
    ${result}=     execute_command.setup_dss_link   2    1    ${pattern}
    Should contain    ${result}    Pass
    log to console      ${enb_id}
    log to console      ${target_id}
Setup gbrsupport Capab in CRM
    [Documentation]    This keyword is for setting gbrload capability in ENDLCRMSF INFO IE
    Log To Console   \nSetting up gbrload capability in CRM...\n
    wtsrunner.enb_cell_dss_param   id=1   enb=2   dl_crm_sf_capabilities=gbr_support

Set DL UL RESOURCE Cell Reservation
    [Arguments]    ${enb_id}    ${target_id}    ${min_dss_ratio}    ${max_dss_ratio}
    ${pattern}=    Set Variable    ENB-2: Cell 1: Update Indication : EN DSS UL Cell Subcarrier Resource Coordination: both NEs synchronized
    ${result}=     execute_command.set_dl_ul_cell_reservation   2    1    ${min_dss_ratio}    ${max_dss_ratio}    ${pattern}
    Should contain    ${result}    Pass
    log to console      ${enb_id}
    log to console      ${target_id}

Cell Resource Allocation
    [Arguments]    ${enb_id}    ${target_id}    ${prb_list}    ${ALLOC_SUBFRAME}
    ${pattern}=    Set Variable    Received EN DSS UL Subcarrier Resource Allocation Response SequenceNumber
    ${result}=     execute_command.cell_resource_allocation   2    1    ${prb_list}    ${ALLOC_SUBFRAME}    ${pattern}
    Should contain    ${result}    Pass
    log to console      ${enb_id}
    log to console      ${target_id}
# Below Kewords are almost same with minor changes to avoid chking nongbr

Verify data transfer and get tp gbr_nongbr
     [Arguments]    ${st_ue_id}     ${en_ue_id}    ${duration}    ${Dir}  ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...   ${qos_profile_speed_dl}    ${qos_profile}     ${gbr_chk}=-1       ${skipp}=-1

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
    log to console      ${trf_id}
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
    ${gbr_qfi_list}=        utility.get_gbr_list_cfg    ${wts_cfg_file_2}
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
    ${tp}      Run Keyword and Ignore Error      Check Average Rate Mod gbr_nongbr      ${bearer_stat}    ${dir}    ${rate}
    ...         ${data_unit}    ${call_dur}     ${gbr_chk}

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
    ...    Run Keyword And Continue On Failure
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

Enable Max integrity dat rate
    [Arguments]     ${msg}      ${int_prot}     ${conf_prot}
    wtsrunner.smf_param     id=1    security_indication=${msg}:${int_prot}:${conf_prot}  max_data_rate=69kbps
    ...     max_ip_data_rate_dl=maximum_UE_rate

Verify Bearer_context_setup_req
    [Arguments]     ${pcap}     ${ue_id}
    ${pdmlFile}=   Get filtered PDML file from pcap    ${pcap}    e1ap.BearerContextSetupRequest_element
    ${packet}        set variable                  e1ap.System_BearerContextSetupRequest

    ${ip_ind}      analyzer.get_unique_showname        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.integrityProtectionIndication$
    ...                                                endPacket=${1}


    ${selected_algo}      analyzer.get_unique_showname        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.integrityProtectionAlgorithm$
    ...                                                endPacket=${1}
    ${ip_req}   Get From Dictionary     ${ip_ie}    ${ue_id}
    #   Below logic will be apply when the UE has only one profile and for multiple profile this code can't be used
    ${ip_ue_profile}    Get From Dictionary     ${ue_profile}       ${ue_id}

    ${up_ip_profiles_id}    Get From Dictionary     ${profiles_mapping}     ${ip_ue_profile}


    Should Contain         ${ip_ind}    ${ip_req}
    Should Contain         ${selected_algo}    ${up_ip_profiles_id}
    ${ue_dl_max_rate}         Get From Dictionary      ${max_ip_rate_dl}    ${ue_id}
    ${fp}=     Run Keyword if   '${ue_dl_max_rate}'=='bitrate64kbs'  Get filtered PDML file from pcap  ${pcap}  e1ap.BitRate == 65536

Check Integrity failure count
    wtsrunner.uec_stats  id=1  format=long   enb=2  type=cell_data_pdcp  cell=1
    ${uec_stats_op}      wtsrunner.read_wtsemu_output_until    expected=Delivery Indication  timeout=30
    Create File	    ${OUTPUT_DIR}/uec.txt	    ${uec_stats_op}
    ${count}=       Run   cat ${OUTPUT_DIR}/uec.txt|grep -i "Integrity Verfication Errors"|awk '{print $6}'
    BuiltIn.Should Be Equal   ${count}    0
    ${rc}   ${content}    OperatingSystem.Run And Return Rc And Output
    ...      cat ${LOG_PATH}/enb/default_syslog_enbNone.log |grep -i "MAC-I verification failed"
    BuiltIn.Should Be Equal         "${content}"   "${EMPTY}"

MultiUE Register should be Successful Custom
    [Arguments]    ${start_ue_id}   ${end_ue_id}   ${msg}    ${ip_ie}      ${max_ip_rate}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    ...     ${ho}=${-1}

    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti

    ${crnti_list}       Create List
    ${ue_to_bearer_list}=    Create Dictionary
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1

    ${capture_cprt}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}
    Run Keyword If  '${max_ip_rate[${ue_idx}]}' == 'bitrate64kbs'     Enable 64kbps integrity dat rate    ${msg}
    ...      ${ip_ie[${ue_idx}]}    ${ip_ie[${ue_idx}]}
    Run Keyword If  '${max_ip_rate[${ue_idx}]}' == 'maximum-UE-rate'     Enable Max integrity dat rate    ${msg}
    ...      ${ip_ie[${ue_idx}]}    ${ip_ie[${ue_idx}]}
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

    ${output}=      Run Keyword If  ${ho} != ${-1}  Read WTS Output For Pattern And Print matching Lines    ${PDU_session_resource_setup_response}
    ...    ${Timeout_SA}
    ${output1}=      Run Keyword If  ${ho} == ${-1}  Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}
    ...    ${Timeout_SA}

    ${bearer_list}       Create List
    Run Keyword If  ${ho} != ${-1}  Create File	    ${OUTPUT_DIR}/bearer.txt	    ${output}
    Run Keyword If  ${ho} == ${-1}  Create File	    ${OUTPUT_DIR}/bearer.txt	    ${output1}
    ${bearer_id}=    Run     cat ${OUTPUT_DIR}/bearer.txt |grep -i "servedRadioBearer drb-Identity" |awk '{print $4}'|sed 's/,//g'
    Append To List	   ${bearer_list}        ${bearer_id}
    Set To Dictionary	${ue_to_bearer_list} 	${ue_idx}	    ${bearer_list}
    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}

    Stop CPRT capture  ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UE_${ue_idx}.pcap
    ${ip_req}   Get From Dictionary     ${ip_ie}    ${ue_idx}
    Run Keyword If  ${ho} == ${-1}  Verify Initial_context_setup_req    ${ip_ie[${ue_idx}]}   ${max_ip_rate[${ue_idx}]}
    ...    ${LOG_PATH}/NODECPRT_GNB_UE_${ue_idx}.pcap   ${max_ip_rate_dl[${ue_idx}]}
    Run Keyword If  ${ho} == ${-1}  Verify Bearer_context_setup_req     ${LOG_PATH}/NODECPRT_GNB_UE_${ue_idx}.pcap      ${ue_idx}
    Run Keyword If  ${ho} == ${-1} and '${ip_req}'!='required'    Verify Bearer_context_setup_res     ${LOG_PATH}/NODECPRT_GNB_UE_${ue_idx}.pcap
    ...      ${ue_idx}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}     ${ue_to_bearer_list}


Get filtered PDML file from pcap
    [Arguments]                     ${pcapFile}       ${filterExp}=None
    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
    ...                             filterName=${filterExp}         filterExp=${filterExp}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}
    [Return]    ${pdmlFile}

Verify Bearer_context_setup_res
    [Arguments]     ${pcap}     ${ue_id}
    ${pdmlFile}=    Get filtered PDML file from pcap    ${pcap}    e1ap.BearerContextSetupResponse_element
    ${packet}        set variable                  e1ap.System_BearerContextSetupResponse

    ${ip_res_act}      analyzer.get_unique_showname        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.integrityProtectionResult$
    ...                                                endPacket=${1}
    ${ip_res_exp}   Get From Dictionary     ${ip_result}    ${ue_id}

    Should Contain         ${ip_res_act}    ${ip_res_exp}

Enable 64kbps integrity dat rate
    [Arguments]     ${msg}      ${int_prot}     ${conf_prot}
     wtsrunner.smf_param    id=1   security_indication=${msg}:${int_prot}:${conf_prot}  max_data_rate=64kbps
    ...     max_ip_data_rate_dl=bitrate64kbs
#Setting only UL RATE and gnodeB CP will consider this UL data rate for DL data rate

Create Modify PDU session_ho
    [Arguments]     ${st_ue_id}     ${en_ue_id}    ${qos_profile}   ${pdu_id}     ${gfbr_mfbr_profile}=-1
         ...        ${num_ues}=${en_ue_id}          ${ue_to_bearer_list}=${bearer_list}   ${ho}=${-1}
    [Documentation]    This keyword is wrepar for the ADD PDU  session and modification
    FOR     ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
        ${QOS_prof}=      Set Variable  ${qos_profile}[${ue_id}][1:]
        ${len}=     Get Length  ${QOS_prof}
        ${QOS_strng}=    Run Keyword If  ${len} >0   Evaluate    ",".join(${QOS_prof})  #Got the QOS string
        ${pdu_id}=   Set Variable If      '2' in ${QOS_prof} or '3' in ${QOS_prof} or '4' in ${QOS_prof}   2   1

        ${gw_id}=       Evaluate    ${ue_id}+${num_ues}
        ${capture_cprt}     Capture CPRT Set Upon Config
        Set test variable    ${CaptureCPRT}    ${capture_cprt}
        Run Keyword if  ${len} >0       Set CPRT capture    ${CaptureCPRT}


        Run Keyword if  ${len} >0   Add PDU session_ho     ${ue_id}      ${pdu_id}      ${gw_id}     ${QOS_strng}
        ...    ue_to_bearer_list=${ue_to_bearer_list}    ho=${ho}

        Run Keyword if  ${len} >0     Stop CPRT capture  ${CaptureCPRT}

        Run Keyword if  ${len} >0     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UE_${ue_id}_PDU.pcap
        Run Keyword if  ${pdu_id}==2 and ${ho} == ${-1}  Verify PDU Session Request      ${LOG_PATH}/NODECPRT_GNB_UE_${ue_id}_PDU.pcap   ${ue_id}
    END
    log to console      ${gfbr_mfbr_profile}

Add PDU session_ho
     [Arguments]     ${ue_id}      ${pdu_id}      ${gw_id}     ${Q_O_ADD}      ${ue_to_bearer_list}=${bearer_list}    ${ho}=${-1}
     [Documentation]    This keyword starts the ADD PDU  session and modification
        Run Keyword If   ${pdu_id} == 2
        ...     Modified UE PDU Addition should be Successful_ho       ${ue_id}     ${pdu_id}     1   ${gw_id}    ho=${ho}
       ${x}=   Run Keyword If    ${pdu_id} != ${2}  execute_command.modify_pdu_session_verify     ${ue_id}    ${pdu_id}
       ...     qosflows_to_add=${Q_O_ADD}   ue_to_bearer_list=${ue_to_bearer_list}
        ...    ELSE
        ...    VONR GBR NON GBR Add PDU session    ${ue_id}    ${pdu_id}    ${Q_O_ADD}      ue_to_bearer_list=${ue_to_bearer_list}
        Should Contain    ${x}   Pass

Verify Initial_context_setup_req
     [Arguments]    ${ip_req}       ${ul_bitrate}       ${pcap_file}     ${dl_bitrate}=${-1}
     ${pdmlFile}=   Get filtered PDML file from pcap    ${pcap_file}    ngap.PDUSessionResourceSetupItemCxtReq_element
     ${packet}        set variable                  ngap.PDUSessionResourceSetupItemCxtReq_element

    ${ip_ind}      analyzer.get_unique_showname        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.integrityProtectionIndication$
    ...                                                endPacket=${1}

    ${bit_rate_ul}    analyzer.get_unique_showname     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.maximumIntegrityProtectedDataRate_UL$
    ...                                                endPacket=${1}

    ${bit_rate_dl}    Run Keyword If    '${dl_bitrate}' != '${-1}'  analyzer.get_unique_showname     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.MaximumIntegrityProtectedDataRate$
    ...                                                endPacket=${1}

    Should Contain         ${ip_ind}    ${ip_req}
    Should Contain         ${bit_rate_ul}    ${ul_bitrate}
    Run Keyword If    '${dl_bitrate}' != '${-1}'    Should Contain         ${bit_rate_dl}    ${dl_bitrate}

Modified UE PDU Addition should be Successful_ho
    [Arguments]    ${ue_id}     ${pdu_id}     ${nw_id}    ${gw_id}   ${ho}=${-1}
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    ${RAN_UE_NGAP_ID}=      Evaluate    ${ue_id}-${1}
    ${RAN_UE_NGAP_ID_HO}=   Evaluate    ${ue_id}+${1}
    ${RAN_UE_NGAP_ID}   set variable if   ${ho}== ${1}     ${RAN_UE_NGAP_ID_HO}    ${RAN_UE_NGAP_ID}
    ${pdu_addition_pattern}=    Set Variable    Pdu Session Resource Setup Response Message with RAN UE NGAP ID ${RAN_UE_NGAP_ID} handled
    ${output}=      Read WTS Output For Pattern And Print matching Lines    ${pdu_addition_pattern}    ${Timeout_SA}
    ${str_len}=     Get Length     ${output}
    Should Not Be Equal     ${str_len}      ${0}
    BuiltIn.Log                ue_pdu_addition_is_ok

Set CPRT capture
    [Arguments]         ${capture_var_cprt}
    Capture init		${capture_var_cprt}
	Capture start		${capture_var_cprt}

Stop CPRT capture
    [Arguments]         ${capture_var_cprt}
    Capture stop		${capture_var_cprt}
Verify PDU Session Request
    [Arguments]     ${pcap}     ${ue_id}
    #[Arguments]    ${ip_req}       ${ul_bitrate}       ${pcap_file}     ${dl_bitrate}=${-1}
    ${pdmlFile}=   Get filtered PDML file from pcap    ${pcap}    ngap.NGAP_PDU==0
    ${packet}        set variable                  ngap.NGAP_PDU

    ${bit_rate_ul}      analyzer.get_unique_showname        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nas_5gs.sm.int_prot_max_data_rate_ul$
    ...                                                endPacket=${1}

    ${bit_rate_dl}      analyzer.get_unique_showname        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=nas_5gs.sm.int_prot_max_data_rate_dl$
    ...                                                endPacket=${1}

    Log To Console  IP_UE_IS${ip_ie[${ue_id}]}
    ${pdmlFile}=   Get filtered PDML file from pcap    ${pcap}    e1ap.procedureCode == 9&&e1ap.integrityProtectionIndication
    ${packet}        set variable                  e1ap.BearerContextModificationRequest_element
    ${ip_ind}           analyzer.get_unique_showname        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.integrityProtectionIndication$
    ...                                                endPacket=${1}

    ${ip_req}   Get From Dictionary     ${ip_ie}    ${ue_id}
    ${ul_bitrate}   Get From Dictionary     ${max_ip_rate}    ${ue_id}
    ${dl_bitrate}   Get From Dictionary     ${max_ip_rate_dl}    ${ue_id}

    ${ul_bitrate}   Set Variable If    "${ul_bitrate}"=="bitrate64kbs"    64 kbps    ${ul_bitrate}
    ${dl_bitrate}   Set Variable If    "${dl_bitrate}"=="bitrate64kbs"    64 kbps    ${dl_bitrate}
    Should Contain         ${ip_ind}    ${ip_req}
