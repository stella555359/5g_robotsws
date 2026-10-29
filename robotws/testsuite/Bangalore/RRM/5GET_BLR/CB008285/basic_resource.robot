*** Settings ***
Documentation    :copyright: Nokia
...              :authors: XXX
...              :contact: XXX

Variables    ta5g_global_var
#Resource         ../../5GC000937/resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource          ../resources/robot/TTI_Traces.robot
Resource        ../resources/NPS/SWENG/robot/PacketSearch.robot
Resource       ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
#Resource         ../resources/ECEcommon/common_setup_teardown.robot

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          luashark_tools.analyzer       WITH NAME       analyzer
#Library          ute_admin                         WITH NAME   ute_adm
Library          Collections
Library          OperatingSystem
Library          ta5g_tshark
Library          ta5g_commissioning
Library          taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library          taf.transport.ssh                 WITH NAME    csn
Library          String
Library          ../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library          ../resources/NPS/SWENG/python_libs/luashark_tools.py
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ./python/update_delta_and_create.py

Library          DateTime
Library          ./python/increase_buffer_size.py
Library          ./python/execute_command.py
Library          ./python/utility.py
*** Variables ***
&{GNB_ASIK}                ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${BIP_SCRIPT_PATH}         /home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/resources/NPS/SWENG/config/script/
${port}                    22
#   Add your vonr codec speed
&{vonr_codec_rate}         amr_wb_18_25=18.6      amr_wb_23_85=21.4
@{gbr_qfi_list_cfg}        3	4	5 	6	7	8	9	10	11	12	13	14	15
&{profiles_mapping}     null=NIA0   snow3g=NIA1   aes=NIA2    zuc=NIA3

*** Keywords ***
## Delta Commissioning
Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Increase Buffer Size for VM and IPHY
    increase_buffer_size.increase_buffer_size    ${AP_ASIK.ip}    ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}


Start and Stop TTI TRACE
    [Arguments]    ${duration}=${3}
    Start Ttitrace With Streaming Mode_3
    sleep    ${duration}s
    Stop Ttitrace

Collect TTI Trace
    [Arguments]    ${ttitrace_path}
    Convert Ttitrace From Pcap To Excelcsv        ${LOG_PATH}/${ttitrace_path}/
    Convert Tti To Csv Mode          ${LOG_PATH}/${ttitrace_path}

Convert Tti To Csv Mode
    [Arguments]         ${path}
    Format Tti In Stream Mode         ${path}/output_dl.csv     ${path}/output_dl_formated.csv
    Format Tti In Stream Mode         ${path}/output_ul.csv     ${path}/output_ul_formated.csv


Enable Max integrity dat rate
    [Arguments]     ${msg}      ${int_prot}     ${conf_prot}
    wtsrunner.smf_param     id=1    security_indication=${msg}:${int_prot}:${conf_prot}  max_data_rate=69kbps
    ...     max_ip_data_rate_dl=maximum_UE_rate

Enable 64kbps integrity dat rate
    [Arguments]     ${msg}      ${int_prot}     ${conf_prot}
     wtsrunner.smf_param    id=1   security_indication=${msg}:${int_prot}:${conf_prot}  max_data_rate=64kbps
    ...     max_ip_data_rate_dl=bitrate64kbs
#Setting only UL RATE and gnodeB CP will consider this UL data rate for DL data rate
Enable Initigrity date rate for ul
    [Arguments]     ${msg}      ${int_prot}     ${conf_prot}  ${data_rate}
    wtsrunner.smf_param    id=1   security_indication=${msg}:${int_prot}:${conf_prot}  max_data_rate=${data_rate}



Disable integrity Prot
    [Arguments]     ${msg}
    wtsrunner.smf_param    id=1    security_indication=${msg}:not_needed:not_needed


MultiUE Register should be Successful Custom
    [Arguments]    ${start_ue_id}   ${end_ue_id}   ${msg}    ${ip_ie}      ${max_ip_rate}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    ...     ${ho}=${-1}

    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti

    ${crnti_list}       Create List
    ${ue_to_bearer_list}=    Create Dictionary
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1

#    ${capture_cprt}     Capture CPRT Set Upon Config
#    Set test variable    ${CaptureCPRT}    ${capture_cprt}
#    basic_resource.Set CPRT capture    ${CaptureCPRT}
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

#    basic_resource.Stop CPRT capture  ${CaptureCPRT}
#    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UE_${ue_idx}.pcap
#    ${ip_req}   Get From Dictionary     ${ip_ie}    ${ue_idx}
#    Run Keyword If  ${ho} == ${-1}  Verify Initial_context_setup_req    ${ip_ie[${ue_idx}]}   ${max_ip_rate[${ue_idx}]}
#    ...    ${LOG_PATH}/NODECPRT_GNB_UE_${ue_idx}.pcap   ${max_ip_rate_dl[${ue_idx}]}
#    Run Keyword If  ${ho} == ${-1} and '${ip_req}'!='required'    Verify Bearer_context_setup_res     ${LOG_PATH}/NODECPRT_GNB_UE_${ue_idx}.pcap
#    ...      ${ue_idx}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}     ${ue_to_bearer_list}

Set CPRT capture
    [Arguments]         ${capture_var_cprt}
    Capture init		${capture_var_cprt}
	Capture start		${capture_var_cprt}

Stop CPRT capture
    [Arguments]         ${capture_var_cprt}
    Capture stop		${capture_var_cprt}



Get MCShark Version
    ${aliasGNB}                     OAM Connect                             ${AIRSCALE_GNB.oam}
    ${sw_version}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}
    ${list_version}    Split String    ${sw_version}    _
    ${first}    ${rest}    Split String    ${sw_version}    _    1
    ${new_version}    Set Variable If    "${list_version}[2]"=="9999"
    ...    SBTS00_${rest}      ${sw_version}
    ${list_version}    Split String    ${new_version}    _
    ${rest}    ${last}    Split String From Right    ${new_version}    _    1
    ${latest_version}    Set Variable If    "${list_version}[0]"!="SBTS00" and "${list_version}[-1]"!="000000"
    ...    ${rest}_000000      ${new_version}
    [Return]    ${latest_version}

Download MCShark To UTE
    ${wireshark_version}    Run    ls /usr/lib/x86_64-linux-gnu/wireshark/plugins
    set suite variable     ${wireshark_version}
    ${sw_version}    Get MCShark Version
    ${cmd}    Set Variable    wget -r -np -nH https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/${sw_version}/
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${MCShark}    Run    ls ${EXECDIR}/artifactory/mcshark-local/${sw_version}/mcshark-${wireshark_version}*buster.so
    set suite variable     ${MCShark}
    ${is_MCShark_exist}    Run keyword and return status    Should not contain    ${MCShark}    No such file or directory
    Run keyword if   ${is_MCShark_exist}==${True}   Download MCShark If Have
    ...  ELSE         log to console    This version mcshark donot exit and use last version mcshark

Download MCShark If Have
    Run    sudo rm /usr/lib/x86_64-linux-gnu/wireshark/plugins/${wireshark_version}/epan/mcshark-*buster.so
    Run    sudo cp ${MCShark} /usr/lib/x86_64-linux-gnu/wireshark/plugins/${wireshark_version}/epan/

    log to console    download mcshark successfully to UTE

Get filtered PDML file from pcap
    [Arguments]                     ${pcapFile}       ${filterExp}=None
    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
    ...                             filterName=${filterExp}         filterExp=${filterExp}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}
    [Return]    ${pdmlFile}


Verify Initial_context_setup_req
     [Arguments]    ${ip_req}       ${ul_bitrate}       ${pcap_file}     ${dl_bitrate}=${-1}
     ${pdmlFile}=   basic_resource.Get filtered PDML file from pcap    ${pcap_file}    ngap.PDUSessionResourceSetupItemCxtReq_element
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



Verify Initial_context_setup_failure
     ${pdmlFile}=   Get filtered PDML file from pcap    ${CaptureCPRT.path}    ngap.PDUSessionResourceFailedToSetupItemCxtFail_element
     ${packet}        set variable                 ngap.PDUSessionResourceFailedToSetupItemCxtFail_element

    ${fail_code}      analyzer.get_unique_showname        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.radioNetwork$
    ...                                                endPacket=${1}
    Should Contain         ${fail_code}    up-integrity-protection-not-possible


Verify Bearer_context_setup_req
    [Arguments]     ${pcap}     ${ue_id}
    ${pdmlFile}=   basic_resource.Get filtered PDML file from pcap    ${pcap}    e1ap.BearerContextSetupRequest_element
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
    ${fp}=     Run Keyword if   '${ue_dl_max_rate}'=='bitrate64kbs'  basic_resource.Get filtered PDML file from pcap  ${pcap}  e1ap.BitRate == 65536


Verify Bearer_context_setup_req_ho
    [Arguments]     ${pcap}     ${ue_id}
    ${pdmlFile}=   basic_resource.Get filtered PDML file from pcap    ${pcap}    e1ap.BearerContextSetupRequest_element
    ${packet}        set variable                  e1ap.System_BearerContextSetupRequest

    ${ip_ind}      analyzer.get_shownames        pdmlFile=${pdmlFile}
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

    FOR     ${ipind}    IN     @{ip_ind}
        Should Contain         ${ipind}    ${ip_req}
    END
    Should Contain         ${selected_algo}    ${up_ip_profiles_id}
    ${ue_dl_max_rate}         Get From Dictionary      ${max_ip_rate_dl}    ${ue_id}
    ${fp}=     Run Keyword if   '${ue_dl_max_rate}'=='bitrate64kbs'  basic_resource.Get filtered PDML file from pcap  ${pcap}  e1ap.BitRate == 65536




Verify Bearer_context_setup_res_ho
    [Arguments]     ${pcap}     ${ue_id}
    ${pdmlFile}=    basic_resource.Get filtered PDML file from pcap    ${pcap}    e1ap.BearerContextSetupResponse_element
    ${packet}        set variable                  e1ap.System_BearerContextSetupResponse

    ${ip_res_act}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.integrityProtectionResult$
    ...                                                endPacket=${1}
    ${ip_res_exp}   Get From Dictionary     ${ip_result}    ${ue_id}
    FOR   ${ip_res}    IN      @{ip_res_act}
        Should Contain         ${ip_res}    ${ip_res_exp}
    END

Verify Bearer_context_setup_res
    [Arguments]     ${pcap}     ${ue_id}
    ${pdmlFile}=    basic_resource.Get filtered PDML file from pcap    ${pcap}    e1ap.BearerContextSetupResponse_element
    ${packet}        set variable                  e1ap.System_BearerContextSetupResponse

    ${ip_res_act}      analyzer.get_unique_showname        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.integrityProtectionResult$
    ...                                                endPacket=${1}
    ${ip_res_exp}   Get From Dictionary     ${ip_result}    ${ue_id}

    Should Contain         ${ip_res_act}    ${ip_res_exp}


Verify PDU Session Request
    [Arguments]     ${pcap}     ${ue_id}
    #[Arguments]    ${ip_req}       ${ul_bitrate}       ${pcap_file}     ${dl_bitrate}=${-1}
    ${pdmlFile}=   basic_resource.Get filtered PDML file from pcap    ${pcap}    ngap.NGAP_PDU==0
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
    ${pdmlFile}=   basic_resource.Get filtered PDML file from pcap    ${pcap}    e1ap.procedureCode == 9&&e1ap.integrityProtectionIndication
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
#    Should Contain         ${bit_rate_ul}    ${ul_bitrate}
#    Should Contain         ${bit_rate_dl}    ${dl_bitrate}
#    Run Keyword If    '${dl_bitrate}' != '${-1}'    Should Contain         ${bit_rate_dl}    ${dl_bitrate}



Create Modify PDU session
    [Arguments]     ${st_ue_id}     ${en_ue_id}    ${qos_profile}   ${pdu_id}     ${gfbr_mfbr_profile}=-1
         ...        ${num_ues}=${en_ue_id}          ${ue_to_bearer_list}=${bearer_list}   ${ho}=${-1}
    [Documentation]    This keyword is wrepar for the ADD PDU  session and modification
    Builtin.Log   ${gfbr_mfbr_profile}
    FOR     ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
        ${QOS_prof}=      Set Variable  ${qos_profile}[${ue_id}][1:]
        ${len}=     Get Length  ${QOS_prof}
        ${QOS_strng}=    Run Keyword If  ${len} >0   Evaluate    ",".join(${QOS_prof})  #Got the QOS string
        ${pdu_id}=   Set Variable If      '2' in ${QOS_prof} or '3' in ${QOS_prof} or '4' in ${QOS_prof}   2   1

        ${gw_id}=       Evaluate    ${ue_id}+${num_ues}
        ${capture_cprt}     Capture CPRT Set Upon Config
        Set test variable    ${CaptureCPRT}    ${capture_cprt}
        Run Keyword if  ${len} >0       basic_resource.Set CPRT capture    ${CaptureCPRT}


        Run Keyword if  ${len} >0   Add PDU session     ${ue_id}      ${pdu_id}      ${gw_id}     ${QOS_strng}
        ...    ue_to_bearer_list=${ue_to_bearer_list}    ho=${ho}

        Run Keyword if  ${len} >0     basic_resource.Stop CPRT capture  ${CaptureCPRT}

        Run Keyword if  ${len} >0     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UE_${ue_id}_PDU.pcap
        Run Keyword if  ${pdu_id}==2 and ${ho} == ${-1}  Verify PDU Session Request      ${LOG_PATH}/NODECPRT_GNB_UE_${ue_id}_PDU.pcap   ${ue_id}
    END

Add PDU session
     [Arguments]     ${ue_id}      ${pdu_id}      ${gw_id}     ${Q_O_ADD}      ${ue_to_bearer_list}=${bearer_list}    ${ho}=${-1}
     [Documentation]    This keyword starts the ADD PDU  session and modification
        Run Keyword If   ${pdu_id} == 2
        ...     Modified UE PDU Addition should be Successful       ${ue_id}     ${pdu_id}     1   ${gw_id}    ho=${ho}
       ${x}=   Run Keyword If    ${pdu_id} != ${2}  execute_command.modify_pdu_session_verify     ${ue_id}    ${pdu_id}
       ...     qosflows_to_add=${Q_O_ADD}   ue_to_bearer_list=${ue_to_bearer_list}
        ...    ELSE
        ...    VONR GBR NON GBR Add PDU session    ${ue_id}    ${pdu_id}    ${Q_O_ADD}      ue_to_bearer_list=${ue_to_bearer_list}
        Should Contain    ${x}   Pass


Modified UE PDU Addition should be Successful
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

VONR GBR NON GBR Add PDU session
    [Arguments]    ${ue_id}    ${pdu_id}    ${Q_O_ADD}      ${ue_to_bearer_list}=${bearer_list}

      ${x}=		execute_command.modify_pdu_session_verify    ${ue_id}    ${pdu_id}   qosflows_to_add=${Q_O_ADD}
      ...   ue_to_bearer_list=${ue_to_bearer_list}
      Should Contain    ${x}   Pass
      [Return]      ${x}

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

Verify data transfer and get tp gbr_nongbr
     [Arguments]    ${st_ue_id}     ${en_ue_id}    ${duration}    ${Dir}  ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...   ${qos_profile_speed_dl}    ${qos_profile}     ${gbr_chk}=-1       ${skipp}=-1

    [Documentation]    This keyword is used to start the data transfer in UL and DL
    Builtin.Log   ${trf_id}
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
    ${gbr_qfi_list}=        utility.get_gbr_list_cfg    ${wts_cfg_file_BTC2}
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
Check Integrity failure count
    wtsrunner.uec_stats  id=1  format=long   enb=2  type=cell_data_pdcp  cell=1
    ${uec_stats_op}      wtsrunner.read_wtsemu_output_until    expected=Delivery Indication  timeout=30
    Create File	    ${OUTPUT_DIR}/uec.txt	    ${uec_stats_op}
    ${count}=       Run   cat ${OUTPUT_DIR}/uec.txt|grep -i "Integrity Verfication Errors"|awk '{print $6}'
    BuiltIn.Should Be Equal   ${count}    0
    ${rc}   ${content}    OperatingSystem.Run And Return Rc And Output
    ...      cat ${LOG_PATH}/enb/default_syslog_enbNone.log |grep -i "MAC-I verification failed"
    BuiltIn.Should Be Equal         "${content}"   "${EMPTY}"



