*** Settings ***
Variables    ta5g_global_var

Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Library        ../resources/NPS/SWENG/python_libs/luashark_tools.py
Resource       ../resources/NPS/SWENG/robot/PacketSearch.robot
Resource       ../resources/robot/Setup_Env.robot
Resource       ../resources/robot/common_log_collection.robot
Resource        ../resources/ECEcommon/common_file_operation.robot
Resource         ../resources/robot/Airphone.robot
#Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/wts_sim_keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/robot/TTI_Traces.robot
Resource         ../resources/robot/Iperf_Traffic.robot
Library          ../resources/python/ssh_command.py
Library        luashark_tools.analyzer       WITH NAME       analyzer
Library        ute_admin                         WITH NAME   ute_adm
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library        taf.transport.ssh                 WITH NAME    csn
Library           XML    use_lxml=True    WITH NAME    Myxml
Library          ../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          DateTime
Library          taf.transport.ssh           WITH NAME    taf_ssh
#Library          taf.wts.runner              WITH NAME    wtsrunner
Library          ta_a2a

*** Variables ***
&{GNB_ASIK}                ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${port}                    22

${pdu_mod_with_5qi-5}     Added QosFlow with QFI:2 fiveQI:5
${pdu_mod_with_5qi-1}     Added QosFlow with QFI:3 fiveQI:1

#${SA_UE_CAP_TDD_wo_VONR}    SEPARATOR=
#...                         E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C03AA36146B04050D012CB28986801EB
#...                         608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B1335820
#...                         28680965944C3400F5B0404041C3BC70E418700040C9E3EAE003FE003800FF8002C4003B70000800000007000080
#...                         00000002A8D89BAC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB8
#...                         00040000000380004000000001546C4ED6080A1A025965130D003D6C10101070EF1C39061C00103278FAA8000028
#...                         00000B1000EDC000200000001C00020000000000108389A00000000404D1700007008089EC2F0036003C00301C14
#...                         01E0C026007800683E0000000000000E54D000100000965950034AAA85800E001600000008010023562800020406
#...                         080A0C0E10162022242632424A4C4E508C94C2C0E030003010

${SA_UE_CAP_TDD_wo_LTE}     SEPARATOR=
...                         E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C03AA36146B04050D012CB28986801EB6
...                         08080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13358202
...                         8680965944C3400F5B0404041C3BC70E418700040C9E3EAE003FE003800FF8002C4003B700008000000070000800
...                         0000002A8D89BAC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB80
...                         0040000000380004000000001546C4ED6080A1A025965130D003D6C10101070EF1C39061C00103278FAA80000280
...                         0000B1000EDC000200000001C00020000000000108389A00000000404D1700007008089EC2F0036003C00301C140
...                         1E0C026007800683E0000000000000E54D000100000965950034AAA85800E001600000008010023D6000094C2C0E030003014

${SA_UE_CAP_TDD_VONR}       SEPARATOR=
...                         E1A0FFFF074E5A031E00038420007824C1900010F09003100D00980C0301C03AA36146B04050D012CB28986801EB
...                         608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B1335820
...                         28680965944C3400F5B0404041C3BC70E418700040C9E3EAE003FE003800FF8002C4003B70000800000007000080
...                         00000002A8D89BAC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB8
...                         00040000000380004000000001546C4ED6080A1A025965130D003D6C10101070EF1C39061C00103278FAA8000028
...                         00000B1000EDC000200000001C00020000000000108389A00000000404D1700007008089EC2F0036003C00301C14
...                         01E0C026007800683E0000000000000E54D000100000965950034AAA85800E001600000008010023562800020406
...                         080A0C0E10162022242632424A4C4E508C96C0F0380C000C0340

${SA_UE_CAP_TDD_wo_VONR}    SEPARATOR=
...                         E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C03AA36146B04050D012CB28986801EB
...                         608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B1335820
...                         28680965944C3400F5B0404041C3BC70E418700040C9E3EAE003FE003800FF8002C4003B70000800000007000080
...                         00000002A8D89BAC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB8
...                         00040000000380004000000001546C4ED6080A1A025965130D003D6C10101070EF1C39061C00103278FAA8000028
...                         00000B1000EDC000200000001C00020000000000108389A00000000404D1700007008089EC2F0036003C00301C14
...                         01E0C026007800683E0000000000000E54D000100000965950034AAA85800E001600000008010023562800020406
...                         080A0C0E10162022242632424A4C4E508C9400

${SA_UE_CAP_FDD_wo_IRAT_VoNR}    SEPARATOR=
...                         E1A01000014F5E0302C002074001208367130F8509009B0083FF30C7942C0E09804062280C0298C00283E236B0C6
...                         D1D262A08FE5949328340105B260901831E31FF9863CA160703878099D87619D876008006000000000E230000000
...                         0210602372687C0390400000290400000A90400001292500001A6017036F236B7480282000012CA4A080000CB292
...                         82000052CA4A080001CB29282000092CA4A480002A9652501340EAE91D5D0AA9A55515DA816007801A0100800000
...                         00000200400840

${SA_UE_CAP_FDD_wo_IRAT_with_VoNR}    SEPARATOR=
...                         E1A01000014F5E0302C0020840009041B38987C284804D8041FF9863CA160704C060188A0300A63000A0F88DAC31
...                         B47498A823F96524CA0D00416C9824060C78C7FE618F28581C0E1E026761D86761D802001800000000388C000000
...                         00841808DC9A1F00E41000000A41000002A41000004A494000069805C0DBC8DADD200A0800004B29282000032CA4
...                         A0800014B29282000072CA4A0800024B292920000AA5949404D03ABA475742AA69554576A05801E0068040200000
...                         00000080100214C3C0E03000300D

${SA_UE_CAP_FDD_with_IRAT_VoNR}    SEPARATOR=
...                         E1A01000014F5E0302C0020840009041B38987C284804D8041FF9863CA160704C060188A0300A63000A0F88DAC31
...                         B47498A823F96524CA0D00416C9824060C78C7FE618F28581C0E1E026761D86761D802001800000000388C000000
...                         00841808DC9A1F00E41000000A41000002A41000004A494000069805C0DBC8DADD200A0800004B29282000032CA4
...                         A0800014B29282000072CA4A0800024B292920000AA5949404D03ABA475742AA69554576A05801E0068040200000
...                         0000008010023562800020406080A0C0E10162022242632424A4C4E508C94C3C0E03000300D0

*** Keywords ***
Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Generalised MultiUE Register should be Successful
    [Documentation]
    ...        This KW supports Emergency call with PDU Establishment and interan & external traffic.
    ...        5QI-5 is made default for Emergency Call, During Emergency Call 5QI-1 will also be
    ...        added to during PDU session creation

    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    ...     ${trf_type}=internal    ${eme_with_pdu_est}=False
    ${crnti_list}       Create List
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    Start log       cprt
    ${trf_type}     Set Variable If     ${eme_with_pdu_est}!='False'    initial-emergencyrequest    initial-request
    ${registration_type}    Set Variable If     ${eme_with_pdu_est}!='False'    EmergencyRegistration   InitialRegistration
    Run Keyword if    ${eme_with_pdu_est}!='False'
    ...     Enable Emergency related Parameter  ${ue_idx}

	${ue_reg_cmd}	SET VARIABLE	ue_register id=${ue_idx} registration_type=${registration_type}
	${output}		ute_wtssim.Execute Egate Command And Wait For Data  ${ue_reg_cmd}   pass_regexp=${UE_reg_complete_pattern}
    ...      timeout=${EGATE_COMMAND_TIMEOUT}
	Create File     ${OUTPUT_DIR}/regst.txt     ${output}
	${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
	BuiltIn.Log     ${crnti_value}
	Log to Console             ue${ue_idx}_register_is_ok with ${crnti_value}
	Append To List  ${crnti_list}   ${crnti_value}
	${request_type}     Set Variable If     ${eme_with_pdu_est}!='False'    initial-emergency-request    initial-request
	${set_pdu_param_cmd}	Set Variable	set_pdu_param ue=${ue_idx} pdu=${pdu_id} trf_type=${trf_type}
    ${pdu_setup_cmd}	Set Variable	ue_pdu_session_setup pdu=${pdu_id} ue=${ue_idx} nwslice=${nw_id} gw=${ue_idx} request_type=${request_type}
	ute_wtssim.Execute Egate Command    ${set_pdu_param_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
#	ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd}
#	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=${EGATE_COMMAND_TIMEOUT}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_value} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    ${path_cprt}     Stop log    cprt   test_scenario=UE_${ue_idx}/cprt_PduSessionSetup
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    log to console      ${path_cprt}
    [Return]      ${crnti_list}

Enable Emergency related Parameter
    [Arguments]    ${ue_id}

    ${a}    Set Variable    ue_param id=${ue_id} nr_usage_setting=voice_centric
    ${b}    Set Variable    amf_param id=1 ims_voice_3gpp=On
    ${c}    Set Variable    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    ${d}    Set Variable    qosflow_modify qos_flow=1 priority=1
    ${e}    Set Variable    qosflow_modify qos_flow=2 priority=1
    ${f}    Set Variable    smf_param id=1 additional_qosflows_to_activate=2
    ute_wtssim.Execute Egate Command    ${a}    timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command    ${b}    timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command    ${c}    timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command    ${d}    timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command    ${e}    timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command    ${f}    timeout=${EGATE_COMMAND_TIMEOUT}

Verify Request Type in PDU Setup for Emergency
    [Arguments]  ${start_ue_id}   ${end_ue_id}     ${request_type}
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    ${cprt_log}      Set Variable    ${LOG_PATH}/${TEST_NAME}/gNB/cprt/UE_${ue_idx}/cprt_PduSessionSetup/NODECPRT_GNB.pcap
    ${pdmlFile}    analyzer.pcap_to_pdml    ${cprt_log}         ngap
    ${req_type}    analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                        packetName=nas_5gs.mm.req_type
    ...                                        path=.*req_type$
    ...                                        endPacket=1
    Should BE Equal    ${req_type}  ${request_type}
    END

Generalised MultiUE Register should be Successful VoNR Suported
    [Documentation]
    ...        This KW is meant to support VONR QFI addition based on user requirement. By
    ...        By default VoNR support will be Off. To Enable VoNR, one of 3 values need to give
    ...        1.   during InitialContextSetup with 5QI1 and 5QI-5
    ...        2.   pdusessionModify with 5QI1 and 5QI-5 on PDU-1
    ...        3.   pdusessionEstablishment with 5QI1 and 5QI-5 on PDU-2

    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    ...     ${trf_type}=internal    ${vonr_supp}=False    ${isEpsFb}=False    ${iseme}=False    ${start_gw}=${1}
    ...     ${ue_cap}=None
    ${crnti_list}       Create List
    ${gw}   Set Variable    ${start_gw}

    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    #Command Variable Definition
    ${cmd1}     Set Variable    smf_param id=1 additional_qosflows_to_activate=2,3
    ${cmd2}     Set Variable    ue_pdu_session_modify ue=${ue_idx} pdu=1 qosflows_to_add=2 by=ue
    ${cmd3}     Set Variable    ue_pdu_session_modify ue=${ue_idx} pdu=1 qosflows_to_add=3 by=ue
    ${cmd4}     Set Variable    set_pdu_param ue=${ue_idx} pdu=2 trf_type=${trf_type}
    ${cmd5}     Set Variable    smf_param id=1 reset

    ${efb1}     Set Variable    amf_param id=1 send_ics_registration=off
    ${efb2}     Set Variable    amf_ue_ics_param id=1 outer_NAS_PDU_type=configuration_update_command
    ${efb3}     Set Variable    amf_param id=1 voice_fallback=off
    ${efb4}     Set Variable    amf_param id=1 voice_fallback=on

    Start log       cprt
    Run Keyword if    ${isEpsFb}==1    Run Keywords
    ...    ute_wtssim.Execute Egate Command  ${cmd5}  timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    ute_wtssim.Execute Egate Command  ${efb3}  timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    ute_wtssim.Execute Egate Command  ${efb1}  timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    ute_wtssim.Execute Egate Command  ${efb2}  timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    ute_wtssim.Execute Egate Command  ${cmd1}  timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    ute_wtssim.Execute Egate Command  ${efb4}  timeout=${EGATE_COMMAND_TIMEOUT}
    ...    ELSE IF    ${isEpsFb}==2 or ${isEpsFb}==3    Run Keywords
    ...    ute_wtssim.Execute Egate Command  ${cmd5}  timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    ute_wtssim.Execute Egate Command  ${efb3}  timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    ute_wtssim.Execute Egate Command  ${efb4}  timeout=${EGATE_COMMAND_TIMEOUT}

    ${rrc_rel}  Set Variable    UE${ue_idx}: Redirected carrier info is present in RRC Release
    ${rrc_state}  Set Variable    UE${ue_idx}: IS IDLE
    ${pattern1}    Set Variable if  ${isEpsFb}==1 and ${vonr_supp}==1   (\?\:${rrc_rel}|${rrc_state})
    ...    (\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})

    ${pattern2}    Set Variable if  ${isEpsFb}==2 and ${vonr_supp}==2   (\?\:${rrc_rel}|${rrc_state})
    ...    ${pdu_mod_with_5qi-1}

    ${pattern3}    Set Variable if  ${isEpsFb}==3 and ${vonr_supp}==3   (\?\:${rrc_rel}|${rrc_state})
    ...    (\?\:Setup QosFlow with QFI|PDUSessionId:2)

    Run Keyword if  ${vonr_supp}==1
    ...    ute_wtssim.Execute Egate Command  ${cmd1}  timeout=${EGATE_COMMAND_TIMEOUT}
	${ue_reg_cmd}	SET VARIABLE if     '${ue_cap}'=='None' 	ue_register id=${ue_idx}
	...     ue_register id=${ue_idx} ue_nr_capabilities=${ue_cap}
	${output}		ute_wtssim.Execute Egate Command And Wait For Data  ${ue_reg_cmd}   pass_regexp=${UE_reg_complete_pattern}
    ...      timeout=${EGATE_COMMAND_TIMEOUT}
	Create File     ${OUTPUT_DIR}/regst.txt     ${output}
	${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
	BuiltIn.Log     ${crnti_value}
	Log to Console             ue${ue_idx}_register_is_ok with ${crnti_value}
	Append To List  ${crnti_list}   ${crnti_value}

	${set_pdu_param_cmd}	Set Variable	set_pdu_param ue=${ue_idx} pdu=${pdu_id} trf_type=${trf_type}
    ${pdu_setup_cmd}	Set Variable	ue_pdu_session_setup pdu=${pdu_id} ue=${ue_idx} nwslice=${nw_id} gw=${gw}
	ute_wtssim.Execute Egate Command    ${set_pdu_param_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
	ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd}
	...		pass_regexp=${pattern1}      timeout=${EGATE_COMMAND_TIMEOUT}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_value} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    Run Keyword if  ${vonr_supp}==1
    ...    ute_wtssim.Execute Egate Command    ${cmd5}    timeout=${EGATE_COMMAND_TIMEOUT}
    #Update GW
    ${gw}   Evaluate    ${gw}+${1}

    Run Keyword if  ${vonr_supp}==2
    ...    Run Keywords
    ...    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd2}
    ...    pass_regexp=${pdu_mod_with_5qi-5}     timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd3}
    ...    pass_regexp=${pattern2}      timeout=${EGATE_COMMAND_TIMEOUT}

    ${cmd6}     Set Variable if  '${vonr_supp}'=='3'    ue_pdu_session_setup pdu=2 ue=${ue_idx} nwslice=1 gw=${gw}
    ${output3}   Run Keyword if  '${vonr_supp}'=='3'
    ...    Run Keywords
    ...    ute_wtssim.Execute Egate Command    ${cmd5}    timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    ute_wtssim.Execute Egate Command    ${cmd1}    timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    ute_wtssim.Execute Egate Command    ${cmd4}    timeout=${EGATE_COMMAND_TIMEOUT}
    ...    AND
    ...    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd6}
    ...    pass_regexp=${pattern3}       timeout=${EGATE_COMMAND_TIMEOUT}

    ${gw1}  Evaluate    ${gw}+${1}
    ${gw}     Set Variable if  '${vonr_supp}'=='3'    ${gw1}    ${gw}
    ${path_cprt}     Stop log    cprt   test_scenario=UE_${ue_idx}/cprt_PduSessionSetup
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    log to console      ${path_cprt}
#    ${next_gw}      Evaluate    ${gw}+${1}
    [Return]      ${crnti_list}    ${gw}

Validation of FallBack
    [Arguments]    ${start_ue_id}	 ${end_ue_id}    ${FB_type}   ${check_rrc_rel}=False

    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1

    ${FALLBACK_RESPONSE}    Set Variable if
    ...    ${FB_type}==1   ngap.InitialContextSetupResponse_element
    ...    ${FB_type}==2   ngap.PDUSessionResourceModifyResponse_element
    ...    ${FB_type}==3   ngap.PDUSessionResourceSetupResponse_element

    ${RRC_RELEASE_WITH_EUTRA_FREQUENCY}    Set Variable if
    ...     '${check_rrc_rel}'!='False'     nr-rrc.eutraFrequency

    ${UE_CONTEXT_RELEASE_REQUEST_FALLBACK}  Set Variable    ngap.UEContextReleaseRequest_element

    ${cprt_log}      Set Variable    ${LOG_PATH}/${TEST_NAME}/gNB/cprt/UE_${ue_idx}/cprt_PduSessionSetup/NODECPRT_GNB.pcap

    ${pdmlFile}    analyzer.pcap_to_pdml    ${cprt_log}         ${FALLBACK_RESPONSE}
    ${fb_resp}    analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                        packetName=${FALLBACK_RESPONSE}
    ...                                        path=.*radioNetwork$
    ...                                        endPacket=1
    Should BE Equal    ${fb_resp}   36

    ${pdmlFile_eutra_freq}   Run Keyword if  '${check_rrc_rel}'!='False'
    ...     analyzer.pcap_to_pdml    ${cprt_log}         ${RRC_RELEASE_WITH_EUTRA_FREQUENCY}
    ${eutra_freq}   Run Keyword if  '${check_rrc_rel}'!='False'
    ...     analyzer.get_unique            pdmlFile=${pdmlFile_eutra_freq}
    ...                                    packetName=${RRC_RELEASE_WITH_EUTRA_FREQUENCY}
    ...                                    path=.*eutraFrequency$
    ...                                    endPacket=1
    Run Keyword if  '${check_rrc_rel}'!='False'
    ...     Should BE Equal    ${eutra_freq}   68586

    ${pdml_ue_con_rel}    analyzer.pcap_to_pdml    ${cprt_log}         ${UE_CONTEXT_RELEASE_REQUEST_FALLBACK}
    ${ue_con_rel}    analyzer.get_unique       pdmlFile=${pdml_ue_con_rel}
    ...                                        packetName=${UE_CONTEXT_RELEASE_REQUEST_FALLBACK}
    ...                                        path=.*radioNetwork$
    ...                                        endPacket=1
    Should BE Equal    ${ue_con_rel}   41

    END



