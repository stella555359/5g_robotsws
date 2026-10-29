*** Settings ***
Documentation    :copyright: Nokia
...              :authors: XXX
...              :contact: XXX

Variables    ta5g_global_var
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource          ../resources/robot/TTI_Traces.robot
Resource        ../resources/NPS/SWENG/robot/PacketSearch.robot
Resource       ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource       ../resources/robot/common_log_collection.robot
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
${PDU_SES_STP_ATT_UPIP_PREF}           M55122C00003
${PDU_SES_STP_ATT_UPIP_REQD}           M55122C00004
${PDU_SES_STP_SUC_UPIP_ACT_PREF}       M55122C00005
${PDU_SES_STP_SUC_UPIP_NACT_PREF}      M55122C00006
${PDU_SES_STP_SUC_UPIP_ACT_REQ}        M55122C00007
${NNGCC_PDU_SES_STP_UPIP_FAIL}         M55125C00002
${NG_FLOW_SETUP_FAIL_UPIP}             M55125C00032
${NG_FLOW_SETUP_FAIL_UPIP_5QI1}        M55125C00033
${NG_FLOW_SETUP_FAIL_UPIP_PMQAP}       M55163C00017

*** Keywords ***
## Delta Commissioning
#Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
#    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Increase Buffer Size for VM and IPHY
    increase_buffer_size.increase_buffer_size    ${AP_ASIK.ip}    ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}

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
    [Arguments]     ${msg}      ${int_prot}     ${conf_prot}
    wtsrunner.smf_param    id=1   security_indication=${msg}:${int_prot}:${conf_prot}  max_data_rate=64kbps



Disable integrity Prot
    [Arguments]     ${msg}
    wtsrunner.smf_param    id=1    security_indication=${msg}:not_needed:preferred   max_data_rate=64kbps
    log to console      ${msg}

MultiUE Register should be Successful Custom
    [Arguments]    ${start_ue_id}   ${end_ue_id}   ${msg}    ${ip_ie}      ${max_ip_rate}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    ...     ${ho}=${-1}    ${only_ul}=${-1}   ${ics_only}=${-1}  ${negtive}=${-1}

    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti

    ${crnti_list}       Create List
    ${ue_to_bearer_list}=    Create Dictionary
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1

    Start Log    cprt

    Run Keyword If  '${max_ip_rate[${ue_idx}]}' == 'bitrate64kbs'     Enable 64kbps integrity dat rate    ${msg}
    ...      ${ip_ie[${ue_idx}]}    required
    Run Keyword If  '${max_ip_rate[${ue_idx}]}' == 'maximum-UE-rate'     Enable Max integrity dat rate    ${msg}
    ...      ${ip_ie[${ue_idx}]}    required
    Run Keyword If   ${only_ul} == ${1}    Enable Initigrity date rate for ul    ${msg}  ${ip_ie[${ue_idx}]}    required
    Run Keyword If   ${ics_only}==${1}   wtsrunner.amf_param   id=1  full_nas_auth=on  nia=null+zuc+aes+snow3g
    ...              nea=null+zuc+aes+snow3g  send_ics_registration=on
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

    ${output}=      Run Keyword If  ${ho} != ${-1} or ${ics_only}==${1}  Read WTS Output For Pattern And Print matching Lines
    ...       ${PDU_session_resource_setup_response}     ${Timeout_SA}
    ${output1}=      Run Keyword If  ${ho} == ${-1} and ${ics_only}==${-1}   Read WTS Output For Pattern And Print matching Lines
    ...            ${Initial_context_setup_pattern}    ${Timeout_SA}

    ${bearer_list}       Create List
    Run Keyword If  ${ho} != ${-1} or ${ics_only}!=${-1}   Create File	    ${OUTPUT_DIR}/bearer.txt	    ${output}
    Run Keyword If  ${ho} == ${-1} and ${ics_only}==${-1}   Create File	    ${OUTPUT_DIR}/bearer.txt	    ${output1}
    ${bearer_id}=    Run     cat ${OUTPUT_DIR}/bearer.txt |grep -i "servedRadioBearer drb-Identity" |awk '{print $4}'|sed 's/,//g'
    Append To List	   ${bearer_list}        ${bearer_id}
    Set To Dictionary	${ue_to_bearer_list} 	${ue_idx}	    ${bearer_list}
    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    sleep  1s
    ${cprt_log}     Stop Log  cprt  test_scenario=UE_${ue_idx}
    #Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UE_${ue_idx}.pcap
    ${ip_req}   Get From Dictionary     ${ip_ie}    ${ue_idx}


    Run Keyword If  ${ho} == ${-1} and ${only_ul}==${-1} and ${ics_only}==${-1}  Verify Initial_context_setup_req    ${ip_ie[${ue_idx}]}
    ...   ${max_ip_rate[${ue_idx}]}   ${cprt_log}[cprt]/NODECPRT_GNB.pcap   ${max_ip_rate_dl[${ue_idx}]}
    Run Keyword If  ${ho} == ${1} and ${only_ul}==${1}  Verify Initial_context_setup_req    ${ip_ie[${ue_idx}]}   ${max_ip_rate[${ue_idx}]}
    ...    ${cprt_log}[cprt]/NODECPRT_GNB.pcap
    Run Keyword If  ${ics_only}==${1}   Verify pduse_ssion_resourc_setupreq    ${ip_ie[${ue_idx}]}   ${max_ip_rate[${ue_idx}]}
    ...          ${cprt_log}[cprt]/NODECPRT_GNB.pcap
    Run Keyword If  ${ics_only}==${1}   Verify pduse_ssion_resourc_setup_resp   ${cprt_log}[cprt]/NODECPRT_GNB.pcap    ${ue_idx}

    Run Keyword If  ${ho} == ${-1}  Verify Bearer_context_setup_req     ${cprt_log}[cprt]/NODECPRT_GNB.pcap      ${ue_idx}
    Run Keyword If  ${ho} == ${-1} and '${ip_req}'!='required'    Verify Bearer_context_setup_res     ${cprt_log}[cprt]/NODECPRT_GNB.pcap
    ...      ${ue_idx}
    # To skip the check of as algo in  case of HO we need to set the $ics to 1 so that it will skipp it
    ${tmp}     Set Variable if  ${ho}==${1}  ${1}   ${ics_only}

    Run Keyword if   '${ip_ie[${ue_idx}]}'=='preferred' or '${ip_ie[${ue_idx}]}'=='required'    Verify PDCP Algo in RRC SEC COMMAND   ${ue_idx}
    ...              ics=${tmp}   negtive=${negtive}

    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}     ${ue_to_bearer_list}
    log to console      ${msg}
    log to console      ${ip_ie}
    log to console      ${max_ip_rate}
    log to console      ${only_ul}
    log to console      ${negtive}

Verify PDCP Algo in RRC SEC COMMAND
    [Arguments]    ${ue_idx}    ${ics}=${-1}   ${file}=${OUTPUT_DIR}/bearer.txt  ${negtive}=${-1}
    ${ip_ue_profile}        Get From Dictionary     ${ue_profile}       ${ue_idx}
    ${up_ip_profiles_id}    Get From Dictionary     ${profiles_mapping}     ${ip_ue_profile}
    ${pdcp_conf}   Run  cat ${file}|grep -i 'integrityProtection enabled'
    ${seccommand}   Run   cat ${file}|grep -i 'integrityProtAlgorithm ${up_ip_profiles_id}'

    ${ip_req}   Get From Dictionary     ${ip_ie}    ${ue_idx}
    Run Keyword if  '${ip_req}' != 'not-needed' and ${negtive}==${-1}  Should Contain   ${pdcp_conf}   integrityProtection enabled
    ...    ignore_case=True
    Run Keyword if  '${ip_req}' == 'not-needed' or ${negtive}==${1}  Should not Contain   ${pdcp_conf}   integrityProtection enabled
    ...    ignore_case=True
    Run Keyword if  ${ics}==${-1}  Should Contain   ${seccommand}   ${up_ip_profiles_id}  ignore_case=True
    ${count}   Run  cat ${file}|grep -i 'integrityProtection enabled'|wc -l
    [Return]     ${count}
    log to console      ${ip_ie}
    log to console      ${negtive}
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

#Download MCShark To UTE
#    ${wireshark_version}    Run    ls /usr/lib/x86_64-linux-gnu/wireshark/plugins
#    set suite variable     ${wireshark_version}
#    ${sw_version}    Get MCShark Version
#    ${cmd}    Set Variable    wget -r -np -nH https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/${sw_version}/
#    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ${cmd}
#    ${MCShark}    Run    ls ${EXECDIR}/artifactory/mcshark-local/${sw_version}/mcshark-${wireshark_version}*buster.so
#    set suite variable     ${MCShark}
#    ${is_MCShark_exist}    Run keyword and return status    Should not contain    ${MCShark}    No such file or directory
#    Run keyword if   ${is_MCShark_exist}==${True}   Download MCShark If Have
#    ...  ELSE         log to console    This version mcshark donot exit and use last version mcshark

#Download MCShark If Have
#    Run    sudo rm /usr/lib/x86_64-linux-gnu/wireshark/plugins/${wireshark_version}/epan/mcshark-*buster.so
#    Run    sudo cp ${MCShark} /usr/lib/x86_64-linux-gnu/wireshark/plugins/${wireshark_version}/epan/
#    log to console    download mcshark successfully to UTE

Get filtered PDML file from pcap
    [Arguments]                     ${pcapFile}       ${filterExp}=None
    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
    ...                             filterName=${filterExp}         filterExp=${filterExp}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}
    [Return]    ${pdmlFile}

Verify pduse_ssion_resourc_setupreq
     [Arguments]    ${ip_req}       ${ul_bitrate}       ${pcap_file}     ${dl_bitrate}=${-1}
     ${pdmlFile}=   Get filtered PDML file from pcap    ${pcap_file}    ngap.PDUSessionResourceSetupListSUReq
     ${packet}        set variable                  ngap.PDUSessionResourceSetupListSUReq

    ${ip_ind}      analyzer.get_unique_showname        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.integrityProtectionIndication$
    ...                                                endPacket=${1}

    ${bit_rate_ul}    Run Keyword if   '${ip_req}'!= 'not-needed'  analyzer.get_unique_showname     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.maximumIntegrityProtectedDataRate_UL$
    ...                                                endPacket=${1}

    ${bit_rate_dl}    Run Keyword If    '${dl_bitrate}' != '${-1}'  analyzer.get_unique_showname     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.MaximumIntegrityProtectedDataRate$
    ...                                                endPacket=${1}

    Should Contain         ${ip_ind}    ${ip_req}
    Run Keyword if   '${ip_req}'!= 'not-needed'    Should Contain         ${bit_rate_ul}    ${ul_bitrate}
    Run Keyword If    '${dl_bitrate}' != '${-1}' and '${ip_req}'!= 'not-needed'    Should Contain         ${bit_rate_dl}    ${dl_bitrate}

Verify pduse_ssion_resourc_setup_resp
    [Arguments]     ${pcap}     ${ue_id}
    ${pdmlFile}=    Get filtered PDML file from pcap    ${pcap}    ngap.PDUSessionResourceSetupListSURes
    ${packet}        set variable                  ngap.PDUSessionResourceSetupListSURes
    ${ip_req}   Get From Dictionary     ${ip_ie}    ${ue_id}
    ${ip_res_act}      Run Keyword if   '${ip_req}'!= 'required'   analyzer.get_unique_showname        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.integrityProtectionResult$
    ...                                                endPacket=${1}
    ${ip_res_exp}   Get From Dictionary     ${ip_result}    ${ue_id}

    Run Keyword if   '${ip_req}'!= 'required'    Should Contain         ${ip_res_act}    ${ip_res_exp}
    log to console  ${ip_ie}
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



Verify Initial_context_setup_failure
     ${pdmlFile}=   Get filtered PDML file from pcap    ${CaptureCPRT.path}    ngap.PDUSessionResourceFailedToSetupItemCxtFail_element
     ${packet}        set variable                 ngap.PDUSessionResourceFailedToSetupItemCxtFail_element

    ${fail_code}      analyzer.get_unique_showname        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.radioNetwork$
    ...                                                endPacket=${1}
    Should Contain         ${fail_code}    up-integrity-protection-not-possible



Verify Bearer_context_modification_req
    [Arguments]     ${pcap}     ${ue_id}    ${pdu_id}
    ${pdmlFile}=   Get filtered PDML file from pcap    ${pcap}    e1ap.integrityProtectionIndication
    ${packet}        set variable                  e1ap.integrityProtectionIndication

    ${ip_ind}      analyzer.get_unique_showname        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.integrityProtectionIndication$
    ...                                                endPacket=${1}

    ${ip_req}   Get From Dictionary     ${ip_ie}    ${ue_id}

    ${selected_algo}      Run Keyword if   '${ip_req}'!= 'not-needed' and ${pdu_id} == ${1}  analyzer.get_unique_showname
    ...                                                pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.integrityProtectionAlgorithm$
    ...                                                endPacket=${1}

    #   Below logic will be apply when the UE has only one profile and for multiple profile this code can't be used
    ${ip_ue_profile}    Get From Dictionary     ${ue_profile}       ${ue_id}

    ${up_ip_profiles_id}    Get From Dictionary     ${profiles_mapping}     ${ip_ue_profile}

    Should Contain         ${ip_ind}    ${ip_req}
    Run Keyword if   '${ip_req}'!= 'not-needed' and ${pdu_id} == ${1}   Should Contain         ${selected_algo}    ${up_ip_profiles_id}
    ${ue_dl_max_rate}         Run Keyword if   '${ip_req}'!= 'not-needed'    Get From Dictionary      ${max_ip_rate_dl}    ${ue_id}
    ${fp}=     Run Keyword if   '${ip_req}'!= 'not-needed' and '${ue_dl_max_rate}'=='bitrate64kbs'     Get filtered PDML file from pcap  ${pcap}
    ...                         e1ap.BitRate == 65536
    log to console      ${pdu_id}

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


Verify Bearer_context_setup_req_ho
    [Arguments]     ${pcap}     ${ue_id}
    ${pdmlFile}=   Get filtered PDML file from pcap    ${pcap}    e1ap.BearerContextSetupRequest_element
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


    ${ip_ue_profile}    Get From Dictionary     ${ue_profile}       ${ue_id}

    ${up_ip_profiles_id}    Get From Dictionary     ${profiles_mapping}     ${ip_ue_profile}

    FOR     ${ipind}    IN     @{ip_ind}
        Should Contain         ${ipind}    ${ip_req}
    END
    Should Contain         ${selected_algo}    ${up_ip_profiles_id}
    ${ue_dl_max_rate}         Get From Dictionary      ${max_ip_rate_dl}    ${ue_id}
    ${fp}=     Run Keyword if   '${ue_dl_max_rate}'=='bitrate64kbs'  Get filtered PDML file from pcap  ${pcap}  e1ap.BitRate == 65536




Verify Bearer_context_setup_res_ho
    [Arguments]     ${pcap}     ${ue_id}
    ${pdmlFile}=    Get filtered PDML file from pcap    ${pcap}    e1ap.BearerContextSetupResponse_element
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
    ${pdmlFile}=    Get filtered PDML file from pcap    ${pcap}    e1ap.integrityProtectionResult
    ${packet}        set variable                  e1ap.integrityProtectionResult

    ${ip_res_act}      analyzer.get_unique_showname        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.integrityProtectionResult$
    ...                                                endPacket=${1}
    ${ip_res_exp}   Get From Dictionary     ${ip_result}    ${ue_id}

    Should Contain         ${ip_res_act}    ${ip_res_exp}


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



Create Modify PDU session
    [Arguments]     ${st_ue_id}     ${en_ue_id}    ${qos_profile}   ${pdu_id}     ${gfbr_mfbr_profile}=-1
         ...        ${num_ues}=${en_ue_id}          ${ue_to_bearer_list}=${bearer_list}   ${ho}=${-1}
    [Documentation]    This keyword is wrepar for the ADD PDU  session and modification
    FOR     ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
        ${QOS_prof}=      Set Variable  ${qos_profile}[${ue_id}][1:]
        ${len}=     Get Length  ${QOS_prof}
        ${QOS_strng}=    Run Keyword If  ${len} >0   Evaluate    ",".join(${QOS_prof})  #Got the QOS string
        ${pdu_id}=   Set Variable If      '2' in ${QOS_prof} or '3' in ${QOS_prof} or '4' in ${QOS_prof}   2   1

        ${gw_id}=       Evaluate    ${ue_id}+${num_ues}
        Start Log    cprt



        Run Keyword if  ${len} >0   Add PDU session     ${ue_id}      ${pdu_id}      ${gw_id}     ${QOS_strng}
        ...    ue_to_bearer_list=${ue_to_bearer_list}    ho=${ho}

        ${cprt_log}   Run Keyword if  ${len} >0          Stop Log  cprt  test_scenario=UE_PDU_${ue_id}


        Run Keyword if  ${pdu_id}==2 and ${ho} == ${-1}  Verify PDU Session Request      ${cprt_log}[cprt]/NODECPRT_GNB.pcap   ${ue_id}
    END
    log to console      ${gfbr_mfbr_profile}
    log to console      ${ho}
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
    log to console      ${ho}
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
    log to console      ${trf_id}

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
    ${expected_str}=       Set Variable If   '${dir}' == 'dl'    Started Downlink*    Started Uplink*
    ${expected_trf}=       Set Variable If   '${dir}' == 'dl'    DL TRF:    UL TRF:   # U is in new Line
    ${t_idx}=       Set Variable If      '${Q_id}' == '2' or '${Q_id}' == '3' or '${Q_id}' == '4'   ${Q_id}     ${idx}
    ${unit}     Set variable if    '${Traffic_rate[${unit_idx}]}' == 'mbps'      ${1048576}      ${1024}
    ${spd}=   Run Keyword If  'amr' in '${data_rate[${unit_idx}]}' or 'g7' in '${data_rate[${unit_idx}]}' or 'custom' in '${data_rate[${unit_idx}]}'
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
    log to console      ${trf_id}
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


    Return From Keyword If    '${Dir}' == 'dl'     ${tp_ue_dir_dl}
    Return From Keyword If    '${Dir}' == 'ul'     ${tp_ue_dir_ul}

    [Return]        ${tp_ue_dl}
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
Check Integrity failure count
    wtsrunner.uec_stats  id=1  format=long   enb=2  type=cell_data_pdcp  cell=1
    ${uec_stats_op}      wtsrunner.read_wtsemu_output_until    expected=Delivery Indication  timeout=30
    Create File	    ${OUTPUT_DIR}/uec.txt	    ${uec_stats_op}
    ${count}=       Run   cat ${OUTPUT_DIR}/uec.txt|grep -i "Integrity Verfication Errors"|awk '{print $6}'
    BuiltIn.Should Be Equal   ${count}    0
    ${rc}   ${content}    OperatingSystem.Run And Return Rc And Output
    ...      cat ${LOG_PATH}/enb/default_syslog_enbNone.log |grep -i "MAC-I verification failed"
    BuiltIn.Should Be Equal         "${content}"   "${EMPTY}"

Custom MultiUE PDU Modfication should be Successful
    [Arguments]     ${start_ue_id}    ${end_ue_id}     ${qosflows}    ${op}=qosflows_to_add      ${pdu_id}=${Pdu_session_ID}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Start Log    cprt
    Run Keyword if  '${op}'=='qosflows_to_add'  wtsrunner.ue_pdu_session_modify      ue=${ue_idx}       pdu=${pdu_id}
    ...         qosflows_to_add=${qosflows}   by=amf
    ${output}    Run Keyword if  '${op}'=='qosflows_to_add'   Read WTS Output Until Pattern Matches    rrcReconfigurationComplete     ${Timeout_SA}
    ${output}    Run Keyword if  '${op}'=='qosflows_to_add'   Read WTS Output Until Pattern Matches    rrcReconfigurationComplete     ${Timeout_SA}
    Run Keyword if  '${op}'=='qosflows_to_del'  wtsrunner.ue_pdu_session_modify      ue=${ue_idx}       pdu=${pdu_id}
    ...         qosflows_to_del=${qosflows}    by=amf
    ${output1}  Run Keyword if  '${op}'=='qosflows_to_del'    Read WTS Output Until Pattern Matches    rrcReconfigurationComplete     ${Timeout_SA}
    ${output}  Set Variable if   '${op}'=='qosflows_to_del'     ${output1}    ${output}
    Create File	    ${OUTPUT_DIR}/bearer_${ue_idx}.txt	    ${output}
    Print Matching Lines from Output File    ${output}    ${Pdu_session_mod_patten}
    BuiltIn.Log               ue=${ue_idx} qosflow=${qosflows} added
	Log to Console            ue=${ue_idx} qosflow=${qosflows} added
	${cprt_log}     Stop Log  cprt  test_scenario=UE_${ue_idx}${op}
    END
    BuiltIn.Log       All_ue_added_an_extra_qosflow_successfully
	Log to Console    All_ue_added_an_extra_qosflow_successfully

Reset Bearer Stats
    [Arguments]     ${st_ue_id}    ${en_ue_id}
    FOR   ${UE_ID}  IN RANGE      ${st_ue_id}    ${en_ue_id}+${1}
        Run Keyword And Continue on Failure    wtsrunner.bearer_stats_clear     ue=${UE_ID}    pdu=${1}
        Run Keyword And Continue on Failure    wtsrunner.bearer_stats_clear     ue=${UE_ID}    pdu=${2}
    END
Custom MultiUE PDU Addition should be Successful
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}     ${nw_id}

    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${pattern}     Set Variable    PDU SESSION ID-${pdu_id} setup/reestablishment complete
    Start Log    cprt
    ${gyw}=    Evaluate    int(${end_ue_id}) + int(${ue_idx})
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${gyw}
    ${output}   Read WTS Output For Pattern And Print matching Lines    ${pattern}    ${Timeout_SA}
    BuiltIn.Log          ue=${ue_idx} pdu=${pdu_id} added with pdu_gateway id=${gyw} successfully
	Log to Console       ue=${ue_idx} pdu=${pdu_id} added with pdu_gateway id=${gyw} successfully
	sleep   3s
	${cprt_log}     Stop Log  cprt  test_scenario=UE_${ue_idx}_${pdu_id}_pdu_addition


   ${ip_req}   Get From Dictionary     ${ip_ie}    ${ue_idx}
   Verify pduse_ssion_resourc_setupreq    ${ip_ie[${ue_idx}]}   ${max_ip_rate[${ue_idx}]}   ${cprt_log}[cprt]/NODECPRT_GNB.pcap
   Verify pduse_ssion_resourc_setup_resp   ${cprt_log}[cprt]/NODECPRT_GNB.pcap    ${ue_idx}

    Verify Bearer_context_modification_req     ${cprt_log}[cprt]/NODECPRT_GNB.pcap      ${ue_idx}  ${pdu_id}
    Run Keyword If  '${ip_req}'!='required' and '${ip_req}'!='not-needed'   Verify Bearer_context_setup_res     ${cprt_log}[cprt]/NODECPRT_GNB.pcap
    ...      ${ue_idx}

    Create File	    ${OUTPUT_DIR}/bearer_pdu_${pdu_id}_ue_${ue_idx}.txt	    ${output}
    Run Keyword if   '${ip_ie[${ue_idx}]}'=='preferred' or '${ip_ie[${ue_idx}]}'=='required'    Verify PDCP Algo in RRC SEC COMMAND   ${ue_idx}
    ...       ics=${1}   file=${OUTPUT_DIR}/bearer_pdu_${pdu_id}_ue_${ue_idx}.txt


#    Verify PDCP Algo in RRC SEC COMMAND   ${1}   ics=${1}  file=${OUTPUT_DIR}/bearer_pdu_${pdu_id}_ue_${ue_idx}.txt
	END
	BuiltIn.Log       All_ue_added_their_pdu_successfuly
	Log to Console    All_ue_added_their_pdu_successfuly

MultiUE register Multi PDU should be Successful
    [Arguments]    ${start_ue_id}   ${end_ue_id}   ${msg}    ${ip_ie}      ${max_ip_rate}    ${pdu_profile}   ${pdu_id}=${Pdu_session_ID}
    ...      ${nw_id}=${nwslice_ID}   ${ho}=${-1}    ${only_ul}=${-1}   ${ics_only}=${-1}

    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    Run Keyword If  ${ics_only}==${-1}    wtsrunner.amf_param  id=1  full_nas_auth=on  nia=null+zuc  nea=null+zuc  send_ics_registration=off
    Run Keyword If  ${ics_only}==${1}    wtsrunner.amf_param  id=1  full_nas_auth=on  nia=null+zuc  nea=null+zuc  send_ics_registration=on
    ${crnti_list}       Create List
    ${ue_to_bearer_list}=    Create Dictionary
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    Start Log    cprt

    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/regst.txt	    ${output}
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk '{print $9}'
    Append To List  ${crnti_list}   ${crnti_string}
    BuiltIn.Log     ${crnti_string}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    Make Multi PDU Session  ${ue_idx}   ${pdu_profile}  ${nw_id}  ${ics_only}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}     ${ue_to_bearer_list}
    log to console      ${msg}
    log to console      ${ip_ie}
    log to console      ${max_ip_rate}
    log to console      ${pdu_id}
    log to console      ${ho}
    log to console      ${only_ul}
Make Multi PDU Session
    [Arguments]   ${ue_idx}  ${pdu_profile}  ${nw_id}  ${ics_only}


    wtsrunner.amf_ue_pdu_setup_param  id=1   ue=${ue_idx}   action=delay_till_next_pdu_setup
    wtsrunner.smf_param  id=1  security_indication=pdu_session_setup:${pdu_profile[${0}]}:preferred   max_data_rate=64
    ...     max_ip_data_rate_dl=bitrate64kbs
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${1}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${1}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}
    wtsrunner.smf_param  id=1  security_indication=pdu_session_setup:${pdu_profile}[${1}]:preferred   max_data_rate=64
    ...     max_ip_data_rate_dl=bitrate64kbs
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${2}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${2}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}

    ${pattern}     Set Variable    PDU SESSION ID-${2} setup/reestablishment complete
    ${output}=     Read WTS Output For Pattern And Print matching Lines    ${pattern}
    ...    ${Timeout_SA}
    sleep   3s
    ${cprt_log}     Stop Log  cprt  test_scenario=UE_${ue_idx}
    Create File	    ${OUTPUT_DIR}/multi_pdu_${ue_idx}	    ${output}
    #Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UE_${ue_idx}.pcap
    ${ip_req}   Get From Dictionary     ${ip_ie}    ${ue_idx}


   Run Keyword If  ${ics_only}==${-1}   Verify Initial_context_setup_req_multi_pdu   ${ip_ie[${ue_idx}]}   ${max_ip_rate[${ue_idx}]}
    ...    ${cprt_log}[cprt]/NODECPRT_GNB.pcap   ${max_ip_rate_dl[${ue_idx}]}

    Run Keyword If  ${ics_only}==${1}   Verify_mulit_pdu_session_resourc_setupreq    ${ip_ie[${ue_idx}]}   ${max_ip_rate[${ue_idx}]}
    ...     ${cprt_log}[cprt]/NODECPRT_GNB.pcap
    Run Keyword If  ${ics_only}==${1}   Verify_multi_pdu_session_resourc_setup_resp  ${cprt_log}[cprt]/NODECPRT_GNB.pcap    ${ue_idx}

    Verify_multipdu_Bearer_context_setup_req    ${cprt_log}[cprt]/NODECPRT_GNB.pcap      ${ue_idx}
    Verify_multipdu_Bearer_context_setup_res     ${cprt_log}[cprt]/NODECPRT_GNB.pcap
    ...      ${ue_idx}
    ${count}  Run Keyword if  '${ip_ie[${ue_idx}]}'=='preferred' or '${ip_ie[${ue_idx}]}'=='required'  Verify PDCP Algo in RRC SEC COMMAND
    ...     ${ue_idx}   ics=${ics_only}   file=${OUTPUT_DIR}/multi_pdu_${ue_idx}
    Should Be Equal  '${count}'  '${2}'

Verify_multipdu_Bearer_context_setup_res
    [Arguments]     ${pcap}     ${ue_id}
    ${pdmlFile}=    Get filtered PDML file from pcap    ${pcap}    e1ap.integrityProtectionResult
    ${packet}        set variable                  e1ap.integrityProtectionResult

    ${ip_res_act}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.integrityProtectionResult$
    ...                                                endPacket=${1}
    ${ip_res_exp}   Get From Dictionary     ${ip_result}    ${ue_id}

    Should Contain         ${ip_res_act}[${0}]    ${ip_res_exp}
    Should Contain         ${ip_res_act}[${1}]    ${ip_res_exp}

Verify_multipdu_Bearer_context_setup_req
    [Arguments]     ${pcap}     ${ue_id}
    ${pdmlFile}=   Get filtered PDML file from pcap    ${pcap}    e1ap.BearerContextSetupRequest_element
    ${packet}        set variable                  e1ap.System_BearerContextSetupRequest

    ${ip_ind}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.integrityProtectionIndication$
    ...                                                endPacket=${1}


    ${selected_algo}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.integrityProtectionAlgorithm$
    ...                                                endPacket=${1}
    ${ip_req}   Get From Dictionary     ${ip_ie}    ${ue_id}
    #   Below logic will be apply when the UE has only one profile and for multiple profile this code can't be used
    ${ip_ue_profile}    Get From Dictionary     ${ue_profile}       ${ue_id}

    ${up_ip_profiles_id}    Get From Dictionary     ${profiles_mapping}     ${ip_ue_profile}


    Should Contain         ${ip_ind}[${0}]    ${ip_req}
    Should Contain         ${selected_algo}[${0}]    ${up_ip_profiles_id}
    Should Contain         ${ip_ind}[${1}]    ${ip_req}
#    Should Contain         ${selected_algo}[${1}]    ${up_ip_profiles_id}
    ${ue_dl_max_rate}         Get From Dictionary      ${max_ip_rate_dl}    ${ue_id}
    ${fp}=     Run Keyword if   '${ue_dl_max_rate}'=='bitrate64kbs'  Get filtered PDML file from pcap  ${pcap}  e1ap.BitRate == 65536

Verify_mulit_pdu_session_resourc_setupreq
     [Arguments]    ${ip_req}       ${ul_bitrate}       ${pcap_file}     ${dl_bitrate}=${-1}
     ${pdmlFile}=   Get filtered PDML file from pcap    ${pcap_file}    ngap.PDUSessionResourceSetupListSUReq
     ${packet}        set variable                  ngap.PDUSessionResourceSetupListSUReq

    ${ip_ind}      analyzer.get_shownames         pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.integrityProtectionIndication$
    ...                                                endPacket=${1}

    ${bit_rate_ul}    Run Keyword if   '${ip_req}'!= 'not-needed'  analyzer.get_shownames      pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.maximumIntegrityProtectedDataRate_UL$
    ...                                                endPacket=${1}

    ${bit_rate_dl}    Run Keyword If    '${dl_bitrate}' != '${-1}'  analyzer.get_shownames      pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.MaximumIntegrityProtectedDataRate$
    ...                                                endPacket=${1}

    Should Contain         ${ip_ind}[${0}]    ${ip_req}
    Should Contain         ${ip_ind}[${1}]    ${ip_req}

    Run Keyword if   '${ip_req}'!= 'not-needed'    Should Contain         ${bit_rate_ul}[${0}]    ${ul_bitrate}
    Run Keyword If    '${dl_bitrate}' != '${-1}' and '${ip_req}'!= 'not-needed'    Should Contain         ${bit_rate_dl}[${0}]     ${dl_bitrate}
    Run Keyword if   '${ip_req}'!= 'not-needed'    Should Contain         ${bit_rate_ul}[${1}]     ${ul_bitrate}
    Run Keyword If    '${dl_bitrate}' != '${-1}' and '${ip_req}'!= 'not-needed'    Should Contain         ${bit_rate_dl}[${1}]     ${dl_bitrate}

Verify_multi_pdu_session_resourc_setup_resp
    [Arguments]     ${pcap}     ${ue_id}
    ${pdmlFile}=    Get filtered PDML file from pcap    ${pcap}    ngap.PDUSessionResourceSetupListSURes
    ${packet}        set variable                  ngap.PDUSessionResourceSetupListSURes
    ${ip_req}   Get From Dictionary     ${ip_ie}    ${ue_id}
    ${ip_res_act}      Run Keyword if   '${ip_req}'!= 'required'   analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.integrityProtectionResult$
    ...                                                endPacket=${1}
    ${ip_res_exp}   Get From Dictionary     ${ip_result}    ${ue_id}

    Run Keyword if   '${ip_req}'!= 'required'    Should Contain         ${ip_res_act}[${0}]    ${ip_res_exp}
    Run Keyword if   '${ip_req}'!= 'required'    Should Contain         ${ip_res_act}[${1}]    ${ip_res_exp}

Verify Initial_context_setup_req_multi_pdu
     [Arguments]    ${ip_req}       ${ul_bitrate}       ${pcap_file}     ${dl_bitrate}=${-1}
     ${pdmlFile}=   Get filtered PDML file from pcap    ${pcap_file}    ngap.PDUSessionResourceSetupItemCxtReq_element
     ${packet}        set variable                  ngap.PDUSessionResourceSetupItemCxtReq_element

    ${ip_ind}      analyzer.get_shownames         pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.integrityProtectionIndication$
    ...                                                endPacket=${1}

    ${bit_rate_ul}    analyzer.get_shownames      pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.maximumIntegrityProtectedDataRate_UL$
    ...                                                endPacket=${1}

    ${bit_rate_dl}    Run Keyword If    '${dl_bitrate}' != '${-1}'  analyzer.get_shownames      pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.MaximumIntegrityProtectedDataRate$
    ...                                                endPacket=${1}


    Should Contain         ${ip_ind}[${0}]    ${ip_req}
    Should Contain         ${ip_ind}[${1}]    ${ip_req}
    Should Contain         ${bit_rate_ul}[${0}]    ${ul_bitrate}
    Should Contain         ${bit_rate_ul}[${1}]    ${ul_bitrate}

    Run Keyword If    '${dl_bitrate}' != '${-1}'    Should Contain         ${bit_rate_dl}[0]    ${dl_bitrate}
    Run Keyword If    '${dl_bitrate}' != '${-1}'    Should Contain         ${bit_rate_dl}[1]    ${dl_bitrate}


Online NIDD parameter change
     [Documentation]    This Keyword used to update NIDD parameter(one at a time)
     ...                and returns the result
     ...        [Arguments]    parameter        :  Parameter names to parsed
     ...                       paramDst         :  Dist name should be parsed
     ...                       paramValue       :  Value for the parameter to be assigned should be parsed
     ...                       operation        :  Deffault Value given as update, and can be parsed other operation if required
     ...                       should_activate  :  Deffault Value is True if you want to set this False then parse the parameter as False
     ...                       skip_parameter_relation_errors : Default Value is True if you want to set  False then parse the parameter as False
     [Arguments]        ${paramName}='None'                 ${paramValue}='None'              ${timeout}=300
     ...                ${paramDst}='None'                  ${operation}=update
     ...                ${should_activate}=${True}          ${skip_parameter_relation_errors}=${True}
    admin.perform_parameter_recommissioning          parameter=${paramName}
     ...        value=${paramValue}             operation=${operation}                         dist_name=${paramDst}
     ...        skip_parameter_relation_errors=${skip_parameter_relation_errors}
     ...        should_activate=${should_activate}
    log to console      ${timeout}
Modify NIDD parameters
    [Documentation]     This Keyword modify NIDD parameter as per the requirement of the feature CB008246
    [Arguments]        ${paramDst}='None'                  ${operation}=update
     ...                ${paramName}='None'                 ${paramValue}='None'
    Log to Console      Modifying NIDD parameters
    admin.Setup admin
    Online NIDD parameter change    paramDst=${paramDst}        operation=${operation}
    ...          paramName=${paramName}         paramValue=${paramValue}
    sleep               60s
    [Teardown]          admin.Teardown admin

trigger handover to LTE
    [Documentation]    [PRIVATE]    trigger handover to LTE
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1    ${A2_meas_id}=1   ${B2_meas_id}=3


    wtsrunner.ue_measurement_send_nr  id=1  meas_id=1  event=A2  srsrp_nr=11  srsrq_nr=11  srs_result=0:11:11:0  phycell_id=50  nrsrp_nr=30
    ...    nrsrq_nr=30  rs_type=ssb  index=0  nrs_result=30:30:0

    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=criticalExtensions rrcReconfigurationComplete   timeout=15
    wtsrunner.ue_measurement_send_nr  id=1  meas_id=3  event=B2  srsrp_nr=11  srsrq_nr=11  srs_result=0:11:11:0  phycell_id=11
    ...   nrsrp_nr=30  nrsrq_nr=30   rs_type=ssb  index=0  nrs_result=30:30:0
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=Successful handover from EXT_ENB-2.1 to ENB-4.1   timeout=15
    log to console      ${ue_id}
    log to console      ${A2_meas_id}
    log to console      ${B2_meas_id}
    log to console      ${negtive}


trigger handover to 5G
    [Documentation]    [PRIVATE]    trigger handover to 5G
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=${1}    ${negtive}=${-1}
    wtsrunner.gnb_trigger_inter_rat_handover_to_5g   ue=1  target_gnb=2   target_cell=1   plmn=311:489
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=criticalExtensions rrcReconfigurationComplete   timeout=15
    Create File	    ${OUTPUT_DIR}/ho_${ue_id}.txt	    ${output}
    Verify PDCP Algo in RRC SEC COMMAND   ${ue_id}  ics=${1}  file=${OUTPUT_DIR}/ho_${ue_id}.txt    negtive=${negtive}
    log to console      ${negtive}
Verify_path_swicth_request
    [Arguments]     ${pcap}     ${ue_id}
    ${pdmlFile}=    Get filtered PDML file from pcap    ${pcap}    ngap.PathSwitchRequest_element
    ${packet}        set variable                  ngap.PathSwitchRequest_element

    ${ip_res_act}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.integrityProtectionResult$
    ...                                                endPacket=${1}
    ${ip_ind}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.integrityProtectionIndication$
    ...                                                endPacket=${1}



    ${ip_req}   Get From Dictionary     ${ip_ie}    ${ue_id}
    ${ip_res_exp}   Get From Dictionary     ${ip_result}    ${ue_id}

    FOR   ${ip_res}    IN      @{ip_res_act}
        Should Contain         ${ip_res}    ${ip_res_exp}
    END
    FOR     ${ipind}    IN     @{ip_ind}
        Should Contain         ${ipind}    ${ip_req}
    END
    log to console      ${ue_id}

HO SA A3 UE measurements Custom
    [Arguments]    ${ue_id}=${1}  ${negtive}=${-1}
    wtsrunner.ue_history_information_list_add_ngran     id=${ue_id}     gnb_id=3    cell_type=medium    nrcgi=311:489|0x03  time_ue_stayed_in_cell=100
    wtsrunner.ue_history_information_list   id=${ue_id} action=commit
    wtsrunner.ue_enb_param     id=${ue_id} ue_history_list=1
    wtsrunner.upf_param   id=${ue_id} end_markers_delay=10s
    wtsrunner.ue_measurement_send_nr       id=${ue_id}  meas_id=1 event=A3 srsrp_nr=19 phycell_id=50 nrsrp_nr=100
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=criticalExtensions rrcReconfigurationComplete   timeout=15
    Create File	    ${OUTPUT_DIR}/ho_${ue_id}.txt	    ${output}
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}

    Verify PDCP Algo in RRC SEC COMMAND   ${ue_id}  ics=${1}  file=${OUTPUT_DIR}/ho_${ue_id}.txt    negtive=${negtive}
    Log to Console    ${output}
    log to console      ${ue_id}
    log to console      ${negtive}
#Modify IPHY File And Send to Airphone Custom
#    [Arguments]    ${iphy_path}
#    ${RRU_type_list}    Get RRU Type From Local IPHY XML Custom   ${iphy_path}
#    FOR    ${RRU_type}    IN    @{RRU_type_list}
#        ${RRU_Version}    Get RRU Version From TargetBD File Custom    ${RRU_type}    ${OUTPUT_DIR}
#        Modify RRU Version Of IPHY XML Custom    ${iphy_path}    ${RRU_type[0]}    ${RRU_Version}
#    END
#    Send IPHY XML To Airphone custom    ${iphy_path}
#
#Get RRU Type From Local IPHY XML Custom
#    [Arguments]    ${iphy_path}
#    ${content}=    OperatingSystem.Get File    path=${iphy_path}
#    ${x}  Set Variable  <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?(?P<Ecpri_tag>[\\w]+)>\\n\\s+(?=<\\/RE>)
#    @{RRU_type_for_version}    String.Get Regexp Matches    ${content}    ${x}    RRU_type    Ecpri_tag
#    @{RRU_type_list}    String.Get Regexp Matches    ${content}    ${x}    RRU_type
#    Set Suite Variable    ${RRU_TYPE_LIST}    ${RRU_type_list}
#    Set Suite Variable    @{RRU_TYPE}    ${RRU_type_list}[0]
#    Log To Console   RRU Type List from local iphy.xml: ${RRU_type_list}
#     Log To Console    RRU Type from local iphy.xml: ${RRU_TYPE}
#    [Return]    @{RRU_type_for_version}
#
#Get RRU Version From TargetBD File Custom
#    [Arguments]    ${RRU_type}    ${save_dir}
#    ${RRU_type}=    Set Variable If    "${RRU_type[0]}"=="AAHF"    AAHF_C1
#    ...    "${RRU_type[0]}"=="AEUB"    ${RRU_type[0]}
#    ...    "${RRU_type[0]}"=="AEHC"    ${RRU_type[0]}
#    ...    "${RRU_type[0]}"=="AEUD"    ${RRU_type[0]}
#    ...    "${RRU_type[0]}"=="AWEUA"    ${RRU_type[0]}
#    ...    "${RRU_type[0]}"=="AHLOA"    ${RRU_type[0]}
#    ...    "${RRU_type[1]}"=="ecpri"    ${RRU_type[0]}_E1
#    ...    ${RRU_type[0]}
#    OperatingSystem.Run
#    ...    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/TargetBD*.xml ${save_dir}/TargetBD.xml
#    OperatingSystem.Should Exist    ${save_dir}/TargetBD.xml
#    ${content}=    OperatingSystem.Get File    path=${save_dir}/TargetBD.xml
#    ${check_point_regexp}    Set Variable    resourceBuildKey="LTX_${RRU_type}".*resourceSWVersion="(?P<RRU_Version>.*)"
#    @{RRU_Version}    String.Get Regexp Matches    ${content}    ${check_point_regexp}    RRU_Version
#    [Return]    ${RRU_Version}[0]
#
#Modify RRU Version Of IPHY XML Custom
#    [Arguments]    ${iphy_path}    ${RRU_type}    ${RRU_Version}
#    ${content}    OperatingSystem.Get File    path=${iphy_path}
#    ${bldVersion}=    String.Get Regexp Matches    ${content}
#    ...    <cardName>${RRU_type}<\/cardName>[\\s\\S]*?<bldVersion>(?P<bldVersion>.*)<\/bldVersion>
#    ...    bldVersion
#    Log Many    ${bldVersion[0]}    ${RRU_Version}
#    ${new_content}    String.Replace String    ${content}    ${bldVersion[0]}    ${RRU_Version}
#    Log To Console    ${new_content}
#    OperatingSystem.Create File    path=${iphy_path}    content=${new_content}
#
#
#Send IPHY XML To Airphone custom
#    [Arguments]    ${iphy_path}
#    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
#    ...
#    ...    Examples:
#    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
#    ${rc}    OperatingSystem.Run And Return Rc
#    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} rm -f /ffs/run/simmode/*.xml
#    Should Be Equal As Integers    ${rc}    0
#    ${rc}    OperatingSystem.Run And Return Rc
#    ...    sshpass -p ${AP_ASIK.password} scp ${iphy_path} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/iphy_modify.xml
#    Should Be Equal As Integers    ${rc}    0
#    ${soft_link}=    Set Variable    ln -fs /ffs/run/simmode/iphy_modify.xml /ffs/run/simmode/iphy.xml
#    ${rc}    OperatingSystem.Run And Return Rc
#    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} ${soft_link}
#    Should Be Equal As Integers    ${rc}    0


MultiUE Register should be Successful upd
    [Arguments]    ${start_ue_id}   ${end_ue_id}   ${msg}    ${ip_ie}      ${max_ip_rate}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    ...     ${ho}=${-1}    ${only_ul}=${-1}   ${ics_only}=${-1}  ${negtive}=${-1}

    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti


    ${ue_to_bearer_list}=    Create Dictionary
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    Run Keyword If  '${max_ip_rate[${ue_idx}]}' == 'bitrate64kbs'     Enable 64kbps integrity dat rate    ${msg}
    ...      ${ip_ie[${ue_idx}]}    required
    Run Keyword If  '${max_ip_rate[${ue_idx}]}' == 'maximum-UE-rate'     Enable Max integrity dat rate    ${msg}
    ...      ${ip_ie[${ue_idx}]}    required
    Run Keyword If   ${only_ul} == ${1}    Enable Initigrity date rate for ul    ${msg}  ${ip_ie[${ue_idx}]}    required
    Run Keyword If   ${ics_only}==${1}   wtsrunner.amf_param   id=1  full_nas_auth=on  nia=null+zuc+aes+snow3g
    ...              nea=null+zuc+aes+snow3g  send_ics_registration=on
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/regst.txt	    ${output}

    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}

    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}

    ${output}=      Run Keyword If  ${ho} != ${-1} or ${ics_only}==${1}  Read WTS Output For Pattern And Print matching Lines
    ...       RAN encryption and or integrity protection algorithms not supported     ${Timeout_SA}
    ${output1}=      Run Keyword If  ${ho} == ${-1} and ${ics_only}==${-1}   Read WTS Output For Pattern And Print matching Lines
    ...            RAN encryption and or integrity protection algorithms not supported    ${Timeout_SA}

    END

    [Return]
    log to console      ${msg}
    log to console      ${max_ip_rate}
    log to console      ${ho}
    log to console      ${only_ul}
    log to console      ${negtive}
Validate PM Counters_pcell_scell
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
#    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
#    ...  pi_id=${PM_counter}    moc=${moc}
    Get Total value of counter and compare   ${PM_dir}   ${PM_counter}   ${expected_value}
    log to console      ${moc}

Verify Counters upip
    [Arguments]  ${counters}
     ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
     ${counter_ids}=   Get Dictionary Keys    ${counters}
     FOR   ${counter_id}  IN  @{counter_ids}
        ${e_value} =	Get From Dictionary	${counters}    ${counter_id}
        Validate PM Counters_pcell_scell   ${PM_dir_1}   ${counter_id}  ${e_value}   NRCELL-1
     END

Trigger A3 RsrpAndRsrq Measurement for intragnb HO
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}=50
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ...   nrsrp_nr=30    nrsrq_nr=20
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}
    log to console      ${ue_id}
Get Total value of counter and compare
    [Arguments]   ${pm_files_location}     ${pi_id}    ${expected_value}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=PM*
    ${rc}       utility.get_total_cmp      ${PM_report_dict_list}     ${expected_value}
    Should Contain  ${rc}  PASS

 Configure UTE ETH3 IPs_CNI
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
    OperatingSystem.Run     sudo ip addr add 10.0.1.3/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.4/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.5/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.6/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.7/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.121/24 dev eth3
