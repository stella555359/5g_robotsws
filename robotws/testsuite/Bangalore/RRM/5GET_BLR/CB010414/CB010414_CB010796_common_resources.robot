*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Ragunath Seenan
...              :contact: ragunath.seenan@nokia.com

Variables    ta5g_global_var

Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Iperf_Traffic.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../resources/robot/TTI_Traces.robot
Resource         ../resources/NPS/SWENG/robot/PacketSearch.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/RD_Counters.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/ECEcommon/common_setup_teardown.robot

Library          BuiltIn
Library          DateTime
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          luashark_tools.analyzer       WITH NAME       analyzer
Library          ute_admin                         WITH NAME   ute_adm
Library          Collections
Library          OperatingSystem
Library          ta5g_tshark
Library          ta5g_commissioning
Library          taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library          taf.transport.ssh                 WITH NAME    csn
Library          String
Library          SSHLibrary
Library          ../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library          ../resources/NPS/SWENG/python_libs/luashark_tools.py
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ./python/execute_command.py
Library          ./python/utility.py
#Library          ./python/avg_ue_stats.py
Library          ./python/read_csv.py

*** Variables ***
${ap_host}                 192.168.200.1
${username}                toor4nsn
${password}                oZPS0POrRieRtu
${oamTermCmd}              /opt/UE_APP-OAM/service/OamTerm/oamTerm.py
${port}                    22


*** Keywords ***
Add RadParam to swconfig
    [Documentation]    This keyword will append the flags to swconfig.txt file.
    ...      Usage: Add RadParam to swconfig     "0x58057f=50"    "0x58057a=50"      IP=192.168.255.129
    [Arguments]    @{flag_list}     ${IP}
    Log To Console  Adding GNB RadParam to swconfig...
    SSHLibrary.open connection    ${IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_original.txt
    FOR    ${flag}    IN    @{flag_list}
        SSHLibrary.execute command    echo "${flag}" >> /ffs/run/swconfig.txt
    END
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection

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

## Delta Commissioning
Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Read Cellsetup msg
#    ${bts_log}      Set Variable  ${log_path_1}[btslog]/gnb_syslog.log
    ${cprt_log}      Set Variable  ${cprt_log_1}[cprt]/NODECPRT_GNB.pcap
    ${pdmlFile}    analyzer.pcap_to_pdml    ${cprt_log}         itf_l2_ps_cell_cellsetupreq
    ${CellSetupParam}    Create Dictionary    PsCell_CellReconfigurationReq     PsCell_CellSetupReq
    ${moc_list}=    Get Dictionary Keys    ${CellSetupParam}
    FOR    ${item}   IN    @{moc_list}
    ${var}      analyzer.get_shownames         pdmlFile=${pdmlFile}
    ...                                        packetName=itf_l2_ps_cell_cellsetupreq
    ...                                        kind=show
    ...                                        path=.*${item}$
    ...                                        endPacket=1
    ${var}      convert to integer     ${var[${-1}]}
    log to console    ${item}-${var}
    Set To Dictionary   ${CellSetupParam}    ${item}=${var}
    END

Modify NIDD parameters
    [Documentation]     This Keyword modify NIDD parameter as per the requirement of the feature CB005788
    [Arguments]        ${paramDst}='None'                  ${operation}=update
     ...                ${paramName}='None'                 ${paramValue}='None'
    Log to Console      Modifying NIDD parameters
    admin.Setup admin
    Online NIDD parameter change    paramDst=${paramDst}        operation=${operation}
    ...          paramName=${paramName}         paramValue=${paramValue}
    sleep               60s
    [Teardown]          admin.Teardown admin

Online NIDD parameter change
     [Documentation]    This Keyword used to update NIDD parameter(one at a time)
     ...                and returns the result
     ...        [Arguments]    parameter        :  Parameter names to parsed
     ...                       paramDst         :  Dist name should be parsed
     ...                       paramValue       :  Value for the parameter to be assigned should be parsed
     ...                       operation        :  Deffault Value given as update, and can be parsed other operation if required
     ...                       should_activate  :  Deffault Value is True if you want to set this False then parse the parameter as False
     ...                       skip_parameter_relation_errors : Default Value is True if you want to set this False then parse the parameter as False
     [Arguments]        ${paramName}='None'                 ${paramValue}='None'              ${timeout}=300
     ...                ${paramDst}='None'                  ${operation}=update
     ...                ${should_activate}=${True}          ${skip_parameter_relation_errors}=${True}
    admin.perform_parameter_recommissioning          parameter=${paramName}
     ...        value=${paramValue}             operation=${operation}                         dist_name=${paramDst}
     ...        skip_parameter_relation_errors=${skip_parameter_relation_errors}
     ...        should_activate=${should_activate}
    Builtin.Log     ${timeout}

AP AaShell oamTerm
    [Documentation]    This keyword will Run directly Aashell as a shell terminal with the command
    ...      Usage: Argument to be passed by declaring variable with Action and  its arguments
    ...             Example: ${triger_alarm}    trigger_rf_fault    0    1936    module    MAJ
    ...                      AP AaShell oamTerm    ${triger_alarm}
    [Arguments]    ${options}
    SSHLibrary.Open Connection     host=${ap_host}
    SSHLibrary.Login               username=${username}    password=${password}
    ${stdout}    SSHLibrary.Execute Command    command=${oamTermCmd} ${options}
    SSHLibrary.Close All Connections
    [Return]    ${stdout}

Slot Muting
    [Documentation]    This keyword will trigger or Start/Stop Slot/Symbol Muting/Blanking on Hot RU
    [Arguments]    ${mutingParam}    ${mutingExp}
    Log to Console     Set RF TEMP RATING
    ${mutingOut}    AP AaShell oamTerm    ${mutingParam}
    Sleep    3s
    Should Contain    ${mutingOut}     ${mutingExp}
    [Return]    ${mutingOut}

Configure ETH And Load CFG
    [Arguments]    ${wts_cfg_file}
    Configure UTE ETH3 IPs
    Log To console     loading cfg file
    Check Cell On Air      ${wts_cfg_file}

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
#    wtsrunner.read_wtsemu_output_until_re    expected=Airphone: Cell Setup completed     timeout=240
    wtsrunner.read_wtsemu_output_until_re    expected=UEC-1: eNB 2 cell 1: SystemInformationBlockType4-NR updated     timeout=240

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
    Builtin.Log     ${gfbr_mfbr_profile}

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

VONR GBR NON GBR Add PDU session
    [Arguments]    ${ue_id}    ${pdu_id}    ${Q_O_ADD}      ${ue_to_bearer_list}=${bearer_list}
      ${x}=		execute_command.modify_pdu_session_verify    ${ue_id}    ${pdu_id}   qosflows_to_add=${Q_O_ADD}
      ...   ue_to_bearer_list=${ue_to_bearer_list}
      Should Contain    ${x}   Pass
      [Return]      ${x}

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

Trigger MultiUE VoNR UL Traffic with multiple trfids
    [Arguments]    ${start_ue_id}    ${end_ue_id}     ${pdu_id}=1     ${num_trf_id}=1
	...     ${qfi_id}=1   ${rtp_codec}=custom
    [Documentation]    This keyword starts the VoNR UL Traffic for the SA variant having some rtp codec
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning VoNR UL Traffic for ue=${ue_idx} with ${rtp_codec}...
    Start ul traffic with multiple trfids    ${ue_idx}    ${pdu_id}   ${qfi_id}    ${num_trf_id}    ${rtp_codec}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*      timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ue=${ue_idx} ${output} VoNR_UL_traffic_data_is_started_successfully
    BuiltIn.Log       ue=${ue_idx} VoNR_UL_traffic_data_is_started_successfully
	END
	sleep       10s
	BuiltIn.Log       All_ue_started_UL_VoNR_traff_succesfully
	Log to Console    All_ue_started_UL_VoNR_traff_succesfully

MultiUE Register should be Successful with Fetch Bearer ID
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    ${ue_to_bearer_list}=    Create Dictionary
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    wtsrunner.ue_register   id=${ue_id}
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
    Builtin.Log     ${duration}
    Builtin.Log     ${trf_id}


Register UE and establish Emergency Call
    [Arguments]    ${UE_ID}    ${duration}=${3}
    log to console   UE1 attach trigerring now...
    Builtin.Log     ${duration}
    wtsrunner.ue_nr_rrc_setup_param     id=${UE_ID}   establishment_cause=emergency
    Qosflow_modify Priority    2    1
    Qosflow_modify Priority    3    1
    Sleep    2s    reason=wait command finish
    UE Register should be Successful Vonr     ${UE_ID}   ${Pdu_session_ID1}    ${nwslice_ID}   ${gw_ID1}
    Sleep    2s    reason=wait command finish
    Trigger DL Traffic for SA Vonr     ${UE_ID}   1   ${Pdu_session_ID1}   ${TRF_ID1}   ${QFI_ID1}
    Trigger UL Traffic for SA Vonr     ${UE_ID}   1   ${Pdu_session_ID1}   ${TRF_ID1}   ${QFI_ID1}
    Sleep    2s    reason=wait command finish
    UE PDU Modfication should be Successful     ${UE_ID}    ${Pdu_session_ID1}    ${Q_O_ADD3}
    Sleep    2s    reason=wait command finish
    Trigger VoNR DL Traffic for SA     ${UE_ID}    ${Pdu_session_ID1}   ${TRF_ID1}   ${QFI_ID2}   rtp_codec=custom
    Trigger VoNR UL Traffic for SA     ${UE_ID}    ${Pdu_session_ID1}   ${TRF_ID1}   ${QFI_ID2}   rtp_codec=custom
    Sleep    2s    reason=wait to trigger DL and UL data succesfully



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

Trigger DL Traffic for SA Vonr
    [Arguments]    ${ue_id}      ${dl_rate}     ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}      ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    #Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=dl  trf_id=${trf_id}   protocol=udp   ack_mode=off  cl_trf_stats=on
    ...    mbps=${dl_rate}   ack_mode=off  cl_trf_stats=on
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully
    Builtin.Log     ${trf_id}

Trigger UL Traffic for SA Vonr
    [Arguments]    ${ue_id}     ${ul_rate}       ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}      ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the UL Traffic for the SA variant
   # Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=ul  trf_id=${trf_id}   protocol=udp   ack_mode=off  cl_trf_stats=on
    ...   mbps=${ul_rate}    ack_mode=off  cl_trf_stats=on
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    UL_traffic_data_is_started_successfully
    Builtin.Log     ${trf_id}

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
    ${m}=     utility.check_op       ${output}
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

#nonGBR traffic flow
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
    Builtin.Log     ${duration}
    Builtin.Log     ${trf_id}

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
    Builtin.Log     ${duration}


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
    Builtin.Log     ${duration}

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

Get filtered PDML file from pcap
    [Arguments]                     ${pcapFile}       ${filterExp}=None
    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
    ...                             filterName=${filterExp}         filterExp=${filterExp}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}
    [Return]    ${pdmlFile}

Verify allowGbrForRfCooling In CellSetupReq
    [Arguments]      ${logpath}       ${filter_req}     ${allowgbr_value}
    [Documentation]      this KW Verifies the allowGbrForRfCooling In CellSetupReq captured in CPRT logs
    log to console       Verifying allowGbrForRfCooling In CellSetupReq captured in CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${allowGBR}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=.*allowGBRMutingForRfCooling$
    ...                                                endPacket=${1}
    Should Contain    ${allowGBR}    ${allowgbr_value}

Verify allowGbrForRfCooling In CellReconfigureReq
    [Arguments]      ${logpath}       ${filter_req}     ${allowgbr_value}
    [Documentation]      this KW Verifies the allowGbrForRfCooling In CellSetupReq captured in CPRT logs
    log to console       Verifying allowGbrForRfCooling In CellSetupReq captured in CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${allowGBR}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellreconfigurationreq
    ...                                                path=.*allowGBRMutingForRfCooling$
    ...                                                endPacket=${1}
    Should Contain    ${allowGBR}    ${allowgbr_value}

Check RD counter value
    [Arguments]    ${PM_dir}   ${PM_counter}   ${moc}=NRCELL-1
    ${pi_value}=   Get RD counter value   pm_files_location=${PM_dir}   pi_id=${PM_counter}    moc=NRCELL-1
    ${pi_value}=   convert to integer    ${pi_value}
    [Return]    ${pi_value}
    Builtin.Log     ${moc}

Check RMOD RD counter value
    [Arguments]    ${PM_dir}   ${PM_counter}   ${moc}=RMOD-1
    ${pi_value}=   Get RD counter value   pm_files_location=${PM_dir}   pi_id=${PM_counter}    moc=RMOD-1
    ${pi_value}=   convert to integer    ${pi_value}
    [Return]    ${pi_value}
    Builtin.Log     ${moc}

Validate NR CELL RF COOL MODE0 SAMPLES
    [Arguments]    ${PM_dir1}
    Log to Console     verifying counter M55601C00016 NR_CELL_RF_COOL_MODE0_SAMPLES
    Set Suite variable   ${PM_dir1}
    ${NR_CELL_RF_COOL_MODE0_SAMPLES}    Check RD counter value   ${PM_dir1}    PM_counter=NR_CELL_RF_COOL_MODE0_SAMPLES
    RD_Counters.Check RD counter value equal or bigger than   expected_value=800   pm_files_location=${PM_dir1}
    ...  pi_id=NR_CELL_RF_COOL_MODE0_SAMPLES   moc=NRCELL-1

Validate NR CELL RF COOL MODE0 STATE CHANGE
    [Arguments]    ${PM_dir1}
    Log to Console     verifying counter M55601C00017 NR_CELL_RF_COOL_MODE0_CHNG_TO
    Set Suite variable   ${PM_dir1}
    ${NR_CELL_RF_COOL_MODE0_CHNG_TO}    Check RD counter value   ${PM_dir1}    PM_counter=NR_CELL_RF_COOL_MODE0_CHNG_TO
    RD_Counters.Check RD counter value equal   expected_value=1   pm_files_location=${PM_dir1}
    ...  pi_id=NR_CELL_RF_COOL_MODE0_CHNG_TO   moc=NRCELL-1

Validate NR CELL RF COOL MODE1 SAMPLES
    [Arguments]    ${PM_dir1}
    Log to Console     verifying counter M55601C00020 NR_CELL_RF_COOL_MODE1_SAMPLES
    Set Suite variable   ${PM_dir1}
    ${NR_CELL_RF_COOL_MODE1_SAMPLES}    Check RD counter value   ${PM_dir1}    PM_counter=NR_CELL_RF_COOL_MODE1_SAMPLES
    RD_Counters.Check RD counter value equal or bigger than   expected_value=20   pm_files_location=${PM_dir1}
    ...  pi_id=NR_CELL_RF_COOL_MODE1_SAMPLES   moc=NRCELL-1

Validate NR CELL RF COOL MODE1 STATE CHANGE
    [Arguments]    ${PM_dir1}
    Log to Console     verifying counter M55601C00021 NR_CELL_RF_COOL_MODE1_CHNG_TO
    Set Suite variable   ${PM_dir1}
    ${NR_CELL_RF_COOL_MODE1_CHNG_TO}    Check RD counter value   ${PM_dir1}    PM_counter=NR_CELL_RF_COOL_MODE1_CHNG_TO
    RD_Counters.Check RD counter value equal   expected_value=4   pm_files_location=${PM_dir1}
    ...  pi_id=NR_CELL_RF_COOL_MODE1_CHNG_TO   moc=NRCELL-1

Validate NR CELL RF COOL MODE2 SAMPLES
    [Arguments]    ${PM_dir1}
    Log to Console     verifying counter M55601C00018 NR_CELL_RF_COOL_MODE2_SAMPLES
    Set Suite variable   ${PM_dir1}
    ${NR_CELL_RF_COOL_MODE2_SAMPLES}    Check RD counter value   ${PM_dir1}    PM_counter=NR_CELL_RF_COOL_MODE2_SAMPLES
    RD_Counters.Check RD counter value equal or bigger than   expected_value=22   pm_files_location=${PM_dir1}
    ...  pi_id=NR_CELL_RF_COOL_MODE2_SAMPLES   moc=NRCELL-1

Validate NR CELL RF COOL MODE2 STATE CHANGE
    [Arguments]    ${PM_dir1}
    Log to Console     verifying counter M55601C00019 NR_CELL_RF_COOL_MODE2_CHNG_TO
    Set Suite variable   ${PM_dir1}
    ${NR_CELL_RF_COOL_MODE2_CHNG_TO}    Check RD counter value   ${PM_dir1}    PM_counter=NR_CELL_RF_COOL_MODE2_CHNG_TO
    RD_Counters.Check RD counter value equal   expected_value=4   pm_files_location=${PM_dir1}
    ...  pi_id=NR_CELL_RF_COOL_MODE2_CHNG_TO   moc=NRCELL-1

Validate NR CELL RF COOL MODE3 SAMPLES
    [Arguments]    ${PM_dir1}
    Log to Console     verifying counter M55601C00022 NR_CELL_RF_COOL_MODE3_SAMPLES
    Set Suite variable   ${PM_dir1}
    ${NR_CELL_RF_COOL_MODE3_SAMPLES}    Check RD counter value   ${PM_dir1}    PM_counter=NR_CELL_RF_COOL_MODE3_SAMPLES
    RD_Counters.Check RD counter value equal or bigger than   expected_value=4   pm_files_location=${PM_dir1}
    ...  pi_id=NR_CELL_RF_COOL_MODE3_SAMPLES   moc=NRCELL-1

Validate NR CELL RF COOL MODE3 STATE CHANGE
    [Arguments]    ${PM_dir1}
    Log to Console     verifying counter M55601C00023 NR_CELL_RF_COOL_MODE3_CHNG_TO
    Set Suite variable   ${PM_dir1}
    ${NR_CELL_RF_COOL_MODE3_CHNG_TO}    Check RD counter value   ${PM_dir1}    PM_counter=NR_CELL_RF_COOL_MODE3_CHNG_TO
    RD_Counters.Check RD counter value equal   expected_value=1   pm_files_location=${PM_dir1}
    ...  pi_id=NR_CELL_RF_COOL_MODE3_CHNG_TO   moc=NRCELL-1

Validate NR RMOD RF TEMP HIGH SAMPLES
    [Arguments]    ${PM_dir1}
    Log to Console     verifying counter M40008C4 NR_RMOD_TEMP_HIGH_SAMPLES
    Set Suite variable   ${PM_dir1}
    ${NR_RMOD_TEMP_HIGH_SAMPLES}    Check RMOD RD counter value    ${PM_dir1}    PM_counter=NR_RMOD_TEMP_HIGH_SAMPLES
    RD_Counters.Check RD counter value equal or bigger than   expected_value=20   pm_files_location=${PM_dir1}
    ...  pi_id=NR_RMOD_TEMP_HIGH_SAMPLES   moc=RMOD-1

Validate NR RMOD RF TEMP INCREASED SAMPLES
    [Arguments]    ${PM_dir1}
    Log to Console     verifying counter M40008C3 NR_RMOD_TEMP_INCREASED_SAMPLES
    Set Suite variable   ${PM_dir1}
    ${NR_RMOD_TEMP_INCREASED_SAMPLES}    Check RMOD RD counter value   ${PM_dir1}    PM_counter=NR_RMOD_TEMP_INCREASED_SAMPLES
    RD_Counters.Check RD counter value equal or bigger than   expected_value=7   pm_files_location=${PM_dir1}
    ...  pi_id=NR_RMOD_TEMP_INCREASED_SAMPLES   moc=RMOD-1

Validate NR RMOD RF TEMP NORMAL SAMPLES
    [Arguments]    ${PM_dir1}
    Log to Console     verifying counter M40008C2 NR_RMOD_TEMP_NORMAL_SAMPLES
    Set Suite variable   ${PM_dir1}
    ${NR_RMOD_TEMP_NORMAL_SAMPLES}    Check RMOD RD counter value   ${PM_dir1}    PM_counter=NR_RMOD_TEMP_NORMAL_SAMPLES
    RD_Counters.Check RD counter value equal or bigger than   expected_value=860   pm_files_location=${PM_dir1}
    ...  pi_id=NR_RMOD_TEMP_NORMAL_SAMPLES   moc=RMOD-1

Collect and Store PM Counter Files
    [Arguments]      ${alias}
    Log to Console     Collecting PM Files
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=${alias}
    [Return]    ${PM_dir1}

Verify rfCooling rfUnitShare tgtMutingRatio in SlotBlankingReq
    [Arguments]      ${logpath}       ${filter_req}     ${sbr_value}     ${rf_value}     ${tmr_value}
    [Documentation]      this KW Verifies the rfCoolingMode and Target Muting ratio  captured in CPRT logs
    log to console       Validating Slot Blanking Request in CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${sbr}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_slotblankingreq
    ...                                                path=.*rfCoolingMode$
    ...                                                endPacket=${1}
    ${rf}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_slotblankingreq
    ...                                                path=.*rfUnitSharedWithAnotherCell_item$
    ...                                                endPacket=${1}
    ${tmr}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_slotblankingreq
    ...                                                path=.*tgtMutingRatio_item$
    ...                                                endPacket=${1}
    Should Contain    ${sbr}    ${sbr_value}
    Should Contain    ${rf}    ${rf_value}
    Should Contain    ${tmr}    ${tmr_value}

Modify IPHY File And Send to Airphone Custom
    [Arguments]    ${iphy_path}    ${frag}=${-1}
    ${RRU_type_list}    Get RRU Type From Local IPHY XML Custom   ${iphy_path}    ${frag}
    FOR    ${RRU_type}    IN    @{RRU_type_list}
        ${RRU_Version}    Get RRU Version From TargetBD File Custom    ${RRU_type}    ${OUTPUT_DIR}
        Modify RRU Version Of IPHY XML Custom    ${iphy_path}    ${RRU_type[0]}    ${RRU_Version}
    END
    Send IPHY XML To Airphone custom    ${iphy_path}


Get RRU Type From Local IPHY XML Custom
    [Arguments]    ${iphy_path}    ${frag}=${-1}
    ${content}=    OperatingSystem.Get File    path=${iphy_path}
    ${x}  Set Variable      <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?(?P<Ecpri_tag>[\\w]+)>\\n\\s+(?=<\\/RE>)
    ${f1}   Set Variable
    ...     <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?(?P<Ecpri_tag>[\\w]+)>\\n\\s+(?=<fragmentationCapabilities>)
    ${x}    set variable if    ${frag}==${1}     ${f1}     ${x}
    @{RRU_type_for_version}    String.Get Regexp Matches    ${content}    ${x}    RRU_type    Ecpri_tag
    @{RRU_type_list}    String.Get Regexp Matches    ${content}    ${x}    RRU_type
    Set Suite Variable    ${RRU_TYPE_LIST}    ${RRU_type_list}
    Set Suite Variable    ${RRU_TYPE}    ${RRU_type_list[0]}
    Log To Console   RRU Type List from local iphy.xml: ${RRU_type_list}
     Log To Console    RRU Type from local iphy.xml: ${RRU_TYPE}
    [Return]    @{RRU_type_for_version}

Get RRU Version From TargetBD File Custom
    [Arguments]    ${RRU_type}    ${save_dir}
    ${RRU_type}=    Set Variable If    "${RRU_type[0]}"=="AAHF"    AAHF_C1
    ...    "${RRU_type[0]}"=="AEUB"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEQE"    ${RRU_type[0]}_E1
    ...    "${RRU_type[0]}"=="AHLOA"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEHC"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEUD"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AWEUA"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AHFII"    ${RRU_type[0]}
    ...    "${RRU_type[1]}"=="ecpri"    ${RRU_type[0]}_E1
    ...    ${RRU_type[0]}
    OperatingSystem.Run
    ...    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/TargetBD*.xml ${save_dir}/TargetBD.xml
    OperatingSystem.Should Exist    ${save_dir}/TargetBD.xml
    ${content}=    OperatingSystem.Get File    path=${save_dir}/TargetBD.xml
    ${check_point_regexp}    Set Variable    resourceBuildKey="LTX_${RRU_type}".*resourceSWVersion="(?P<RRU_Version>.*)"
    @{RRU_Version}    String.Get Regexp Matches    ${content}    ${check_point_regexp}    RRU_Version
    [Return]    @{RRU_Version}[0]


Modify RRU Version Of IPHY XML Custom
    [Arguments]    ${iphy_path}    ${RRU_type}    ${RRU_Version}
    ${content}    OperatingSystem.Get File    path=${iphy_path}
    ${bldVersion}=    String.Get Regexp Matches    ${content}
    ...    <cardName>${RRU_type}<\/cardName>[\\s\\S]*?<bldVersion>(?P<bldVersion>.*)<\/bldVersion>
    ...    bldVersion
    Log Many    ${bldVersion[0]}    ${RRU_Version}
    ${new_content}    String.Replace String    ${content}    ${bldVersion[0]}    ${RRU_Version}
    Log To Console    ${new_content}
    OperatingSystem.Create File    path=${iphy_path}    content=${new_content}

Send IPHY XML To Airphone custom
    [Arguments]    ${iphy_path}
    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
    ...
    ...    Examples:
    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} rm -rf /ffs/run/simmode/*
    Should Be Equal As Integers    ${rc}    0
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} scp ${iphy_path} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/iphy_modify.xml
    Should Be Equal As Integers    ${rc}    0
    ${soft_link}=    Set Variable    ln -fs /ffs/run/simmode/iphy_modify.xml /ffs/run/simmode/iphy.xml
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} ${soft_link}
    Should Be Equal As Integers    ${rc}    0

Trigger MultiUE VoNR DL Traffic with multiple trfids
    [Arguments]    ${start_ue_id}    ${end_ue_id}     ${pdu_id}=1     ${num_trf_id}=1
	...     ${qfi_id}=1   ${rtp_codec}=custom
    [Documentation]    This keyword starts the VoNR DL Traffic for the SA variant having some rtp codec
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning VoNR DL Traffic for ue=${ue_idx} with ${rtp_codec}...
    Start dl traffic with multiple trfids    ${ue_idx}    ${pdu_id}   ${qfi_id}    ${num_trf_id}    ${rtp_codec}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic Receiver*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ue=${ue_idx} ${output} VoNR_DL_traffic_data_is_started_successfully
    BuiltIn.Log       ue=${ue_idx} VoNR_DL_traffic_data_is_started_successfully
	END
	sleep       10s
	BuiltIn.Log       All_ue_started_DL_VoNR_traff_succesfully
	Log to Console    All_ue_started_DL_VoNR_traff_succesfully

Start dl traffic with multiple trfids
    [Arguments]    ${ue_idx}    ${pdu_id}    ${qfi_id}    ${num_trf_id}    ${rtp_codec}
    FOR     ${traffic_id}   IN RANGE    ${1}    ${num_trf_id}+1
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=dl    trf_id=${traffic_id}    rtp_codec=${rtp_codec}
    ...     rtp_ps=900 period_ms=10 rtp_voice_silence=200:1 rtp_send_silence_period=10 rtp_silence_ps=900
    END

Start ul traffic with multiple trfids
    [Arguments]    ${ue_idx}    ${pdu_id}    ${qfi_id}    ${num_trf_id}    ${rtp_codec}
    FOR     ${traffic_id}   IN RANGE    ${1}    ${num_trf_id}+1
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=ul    trf_id=${traffic_id}    rtp_codec=${rtp_codec}
    ...     rtp_ps=900 period_ms=10 rtp_voice_silence=200:1 rtp_send_silence_period=10 rtp_silence_ps=900
    END


Verify slotMutedForRfCooling for nonUeSpecificPriorityInSlot
    [Arguments]    ${csvFile}
    Log to Console     Verifying nonUeSpecificPriorityInSlot in ttitrace
    ${result}=    check_nonUeSpecificPriority    ${csvFile}
    Should Contain    ${result}    True
    [Return]      ${result}

Verify targetMutingRatio for blankedSlots in ttitrace
    [Arguments]    ${csvFile}     ${tmr}
    Log to Console     Verifying targetMutingRatio in ttitrace
    ${result}=    check_targetMutingRatio    ${csvFile}    ${tmr}
    Should Contain    ${result}    True
    [Return]      ${result}

Verify SlotBlankingReq Event in sherpa
    [Arguments]    ${csvFile}
    Log to Console     Verifying PsCell_SlotBlankingReq and TG Muting Ratio in sherpa
    ${Pscell_slotmuting}=    Run    command=cat ${csvFile} | grep -F 'PsCell_SlotBlankingReq(54)' | awk -F ";" '{print $10}'| awk -F " " '{print $2}'
    ${TG_muting_ratio}=    Run    command=cat ${csvFile} | grep -F 'TG Muting Ratio' | awk -F "," '{print $2}' | awk -F "=" '{print $2}'
    Should Contain    ${Pscell_slotmuting}    PsCell_SlotBlankingReq
    Should Contain    ${TG_muting_ratio}   17
    [Return]      ${Pscell_slotmuting}     ${TG_muting_ratio}

