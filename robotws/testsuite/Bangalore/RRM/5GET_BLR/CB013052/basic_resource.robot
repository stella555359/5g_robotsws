*** Settings ***
Documentation    :copyright: Nokia
...              :authors: XXX
...              :contact: XXX

Variables    ta5g_global_var
Resource          ./../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser

Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Library        ../resources/NPS/SWENG/python_libs/luashark_tools.py
Resource       ../resources/NPS/SWENG/robot/PacketSearch.robot
Resource       ../resources/robot/Setup_Env.robot
Resource       ../resources/robot/common_log_collection.robot
Resource        ../resources/ECEcommon/common_file_operation.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Library        luashark_tools.analyzer       WITH NAME       analyzer
Library        taf.sbts.oam.coam.admin                   WITH NAME   ute_adm
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library        taf.transport.ssh                 WITH NAME    csn
Library           XML    use_lxml=True    WITH NAME    Myxml
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library         ./python/basic.py
Library         ./python/utility.py
Resource         ../resources/robot/common_log_collection.robot




*** Variables ***
${SLICE_FALLBACK_SUC}      M55138C03540
${SA_NGBR_DRB_REQ_SLICE}    M55149C00002
${SA_NGBR_DRB_SUCC_SLICE}    M55149C00003
${SA_NGBR_DRB_CU_SUCC_SLICE}    M55149C00020
${SA_GBR_DRB_CU_SUCC_SLICE}    M55149C01003
${SA_GBR_DRB_REQ_SLICE}     M55149C01001
${SA_GBR_DRB_SUCC_SLICE}    M55149C01002
${NG_FLOW_SETUP_FAIL_WRONG_MSG}    M55125C09012
${NRRCC_RRC_STPREQ_EMERGENCY}    M55124C01004
${NRRCC_RRC_STPSUCC_EMERGENCY}    M55124C04001
${NG_FLOW_I_HO_SUC_SLI_FBK_PMQAP}    M55163C03008
${NG_FLOW_STP_SUC_SLI_FBK_PMQAP}     M55163C03007
${NRRCC_RRC_RESUME_REQUEST1}       M55124C00007
${NRRCC_RRC_RESUME_SUCC}            M55124C00010
${SUCC_OG_INTER_GNB_HO_SLICE}     M55149C00009

*** Keywords ***

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

MultiUE Register should be Successful custom
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}     ${ics_wo_pdu}=${-1}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    Run Keyword If    ${ics_wo_pdu}==${1}    wtsrunner.amf_param  id=1  full_nas_auth=on  nia=null+zuc  nea=null+zuc  send_ics_registration=on
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    Start Log    cprt
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/regst.txt	    ${output}

    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
    Append To List  ${crnti_list}   ${crnti_string}
    BuiltIn.Log     ${crnti_string}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal

    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}[${ue_idx}]    gw=${ue_idx}
    ${Initial_context_setup_pattern}    setvariable if    ${ics_wo_pdu}==${1}
    ...      Pdu Session Resource Setup Response Message with RAN UE NGAP ID    ${Initial_context_setup_pattern}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}

    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    ${cprt_log}     Stop Log  cprt  test_scenario=UE_${ue_idx}
    END
    set test variable    ${cprt_log}    ${cprt_log}
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}



UE Register should be Successful custom
    [Arguments]    ${ue_id}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant

    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Log to Console    ---> ${UE_register_complete_pattern}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}

    [Return]      ${output}

UE Make PDU session
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}     ${ics_wo_pdu}=${-1}   ${neg}=${-1}

    ${Initial_context_setup_pattern}    setvariable if    ${ics_wo_pdu}==${1}
    ...      Pdu Session Resource Setup Response Message with RAN UE NGAP ID    ${Initial_context_setup_pattern}
    ${gw_id}     Evaluate    ${ue_id}+${pdu_id}
    ${gw_id}     Set variable if    ${1}==${pdu_id}   ${pdu_id}    ${gw_id}
    Start Log    cprt
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}[${ue_id}]    gw=${gw_id}
    sleep     5s
    ${cprt_log}     Stop Log  cprt  test_scenario=UE_${ue_id}_${pdu_id}
    ${Initial_context_setup_pattern}     set variable if    ${neg}!=${-1}    slice not supported     ${Initial_context_setup_pattern}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    set test variable  ${cprt_log}     ${cprt_log}
UE Make PDU session wo validation
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}     ${ics_wo_pdu}=${-1}

    ${Initial_context_setup_pattern}    setvariable if    ${ics_wo_pdu}==${1}
    ...      Pdu Session Resource Setup Response Message with RAN UE NGAP ID    ${Initial_context_setup_pattern}
    #Start Log    cprt
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}[${ue_id}]    gw=${ue_id}
    #${cprt_log}     Stop Log  cprt  test_scenario=UE_${ue_id}_${pdu_id}
    #Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}


Verify message
    #Verify message
    #ngap.InitialContextSetupRequest_element
    #ngap.sST
    #ngap.sD

    [Arguments]    ${file_name}    ${msg_name}   ${parametr}    ${ue}
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${file_name}    ${msg_name}
#    ${pdmlFile}     Set variable    ${file_name}
    ${sst}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${msg_name}
    ...                                                path=${parametr}.sST$
    ...                                                kind=value
    ...                                                endPacket=${1}

    ${sd}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${msg_name}
    ...                                                path=${parametr}.sD$
    ...                                                kind=value
    ...                                                endPacket=${1}


    ${sst_list}            Set variable    ${SST_CFG}
    ${sd_list}             Set variable      ${ue_info}[${ue}]
    ${lngth}     Get Length      ${sd_list}
    ${v_sd}    Get Slice From List    ${sd}     ${0}    ${lngth}
    ${v_sst}     Get Slice From List    ${sst}     ${0}    ${lngth}

    ${rc}    compare_eq    ${v_sd}    ${sd_list}
    Should Contain      ${rc}     Pass
    ${rc}    compare_eq    ${v_sst}    ${sst_list}
    Should Contain      ${rc}     Pass









Fetch filtered PDML file from pcap
    [Arguments]                     ${pcapFile}       ${filterExp}=None        ${filterName}=None
    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
#    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
#    ...                             filterName=${filterName}        filterExp=${filterExp}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFile}
    [Return]    ${pdmlFile}

Get UE_ID
    [Arguments]     ${curr_list}
    ${dict}     Create Dictionary
    ${x}        Set Variable        ${0}
    ${ue_count}     Get Length  ${curr_list}
    Set Global Variable     ${ue_count}
    FOR	    ${idx}   IN RANGE    1	  ${ue_count}+1
    ${curr_id}=    Split String    ${curr_list[${x}]}     :
    ${id}=    Remove String    ${curr_id}[${1}]    ${SPACE}
    Set To Dictionary       ${dict}     ${idx}      ${id}
    ${x}=     Evaluate    ${x}+${1}
    END
    [Return]    ${dict}

Fetch UE ID from pcap
    [Arguments]       ${pcap_file}        ${filter_exp}        ${IE_path}
    ${packet}        set variable                  ${filter_exp}
    ${pdmlFile}=   Fetch filtered PDML file from pcap       ${pcap_file}         ${packet}       filterName=${packet}
    Log to Console       Fetch ${IE_path} from pcap logs
    ${UE_ID}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=${IE_path}
    ...                                                endPacket=-${1}
    Should Not Be Empty         ${UE_ID}
    ${UE_ID_list}       Get UE_ID      ${UE_ID}
    Log to Console      ${UE_ID_list}
    [Return]    ${UE_ID_list}

Verify pcap messages
	[Arguments]         ${pcap_file}        ${pduslicediff}
	${UE_ID_list}       Fetch UE ID from pcap      ${pcap_file}	     f1ap.UEContextSetupRequest_element    f1ap.GNB_DU_UE_F1AP_ID
	FOR     ${idx}   IN RANGE    1    ${ue_count}+1
    ${value}    Get From Dictionary    ${UE_ID_list}    ${idx}
	${packet}        set variable		f1ap.GNB_DU_UE_F1AP_ID == ${value}
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=${packet}       filterName=UE_${idx}
    ${slice_df}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=f1ap.UEContextSetupRequest_element$
    ...                                                path=f1ap.sD
    ...                                                endPacket=-${1}
    ...                                                kind=show
    Should Contain      ${pduslicediff}     ${slice_df}[0]
    END
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

Verify Counters modi
    [Arguments]  ${counters}    ${moc}    ${slices}=None
     ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
     ${counter_ids}=   Get Dictionary Keys    ${counters}
     ${counter_val}    Create Dictionary
     FOR   ${counter_id}  IN  @{counter_ids}
        ${e_value} =	Get From Dictionary	${counters}    ${counter_id}
        ${val}     Validate PM Counters_pcell_scell   ${PM_dir_1}    ${counter_id}    ${e_value}   ${moc}
        ${counter_val}    Run Keyword If     ${slices}!=None     update_slice_value    ${val}
     END

     [Return]    ${counter_val}


Get Total value of counter and compare
    [Arguments]   ${pm_files_location}     ${pi_id}    ${expected_value}    ${moc}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=PM*
    ${rc}       basic.get_total_cmp      ${PM_report_dict_list}     ${expected_value}    ${moc}
    Should Contain  ${rc}  PASS
    ${rest}	     ${val}     Split String From Right	    ${rc}    '#'

    [Return]    ${val}


Validate PM Counters_pcell_scell
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
#    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
#    ...  pi_id=${PM_counter}    moc=${moc}
    ${val}    Get Total value of counter and compare   ${PM_dir}   ${PM_counter}   ${expected_value}    ${moc}
    [Return]    ${val}

Compare counters
    [Arguments]     ${slices}     ${counter_ctg1}     ${counter_ctg2}
    FOR    ${slice}    IN    @{slices}
        Return From Keyword If     ${counter_ctg1}[${slice}] != ${counter_ctg2}[${slice}]     Fail
    END
    [Return]    Pass
Make emergency call
    [Arguments]    ${ue_id}    ${pdu_id}    ${ics_wo_pdu}=${-1}
    ${Initial_context_setup_pattern}    setvariable if    ${ics_wo_pdu}==${1}
    ...      Pdu Session Resource Setup Response Message with RAN UE NGAP ID    ${Initial_context_setup_pattern}
    wtsrunner.ue_param    id=${ue_id}    nr_usage_setting=voice_centric
#amf_param id=1 ims_voice_3gpp=On
    wtsrunner.ue_nr_rrc_setup_param    id=${ue_id}  establishment_cause=emergency
    wtsrunner.qosflow_modify    qos_flow=2    priority=1
    wtsrunner.qosflow_modify    qos_flow=3    priority=1
    wtsrunner.smf_param     id=1     additional_qosflows_to_activate=3
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_register    id=${ue_id}    registration_type=EmergencyRegistration
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    ${gw_id}     Evaluate    ${ue_id}+${pdu_id}
    ${gw_id}     Set variable if    ${1}==${pdu_id}   ${pdu_id}    ${gw_id}
    wtsrunner.ue_pdu_session_setup  ue=${ue_id}  pdu=${pdu_id}  nwslice=${nwslice_ID}[${ue_id}]  gw=${gw_id}  request_type=initial-emergency-request
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}

Verify message custom
    [Arguments]    ${file_name}  ${msg_name}  ${parametr}   ${expected_sd}    ${expected_sst}  ${ic}=${-1}  ${sd2}=${-1}  ${sd3}=${-1}  ${sd4}=${-1}
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${file_name}    ${msg_name}
#    ${pdmlFile}     Set variable    ${file_name}
    ${sstp}    Set Variable if    ${ic}==${1}    sst     sST
    ${sdp}    Set Variable if    ${ic}==${1}    sd     sD
    ${sst}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${msg_name}
    ...                                                path=${parametr}.${sstp}$
    ...                                                kind=value
    ...                                                endPacket=${10}

    ${sd}      analyzer.get_shownames        pdmlFile=${pdmlFile}
    ...                                                packetName=${msg_name}
    ...                                                path=${parametr}.${sdp}$
    ...                                                kind=value
    ...                                                endPacket=${10}
    Should Contain          ${sd}[0]    ${expected_sd}
    Should Contain          ${sst}[0]    ${expected_sst}
    Run Keyword If    ${sd2}!=${-1}     Should Contain          ${sd}[1]    f
    Run Keyword If    ${sd3}!=${-1}     Should Contain          ${sd}[2]    f
    Run Keyword If    ${sd4}!=${-1}     Should Contain          ${sd}[3]    f

Make emergency call vonr
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi5}=2  ${qfi1}=3   ${priority}=1    ${ics_wo_pdu}=${-1}
    ${Initial_context_setup_pattern}    setvariable if    ${ics_wo_pdu}==${1}
    ...      Pdu Session Resource Setup Response Message with RAN UE NGAP ID    ${Initial_context_setup_pattern}
    wtsrunner.ue_param    id=${ue_id}    nr_usage_setting=voice_centric
#amf_param id=1 ims_voice_3gpp=On
    wtsrunner.ue_nr_rrc_setup_param    id=${ue_id}  establishment_cause=emergency
    wtsrunner.qosflow_modify    qos_flow=${qfi5}    priority=1
    wtsrunner.qosflow_modify    qos_flow=${qfi1}    priority=1
    wtsrunner.smf_param     id=1     additional_qosflows_to_activate=3
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_register    id=${ue_id}    registration_type=EmergencyRegistration
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    ${gw_id}     Evaluate    ${ue_id}+${pdu_id}
    ${gw_id}     Set variable if    ${1}==${pdu_id}   ${pdu_id}    ${gw_id}
    wtsrunner.ue_pdu_session_setup    ue=${ue_id}    pdu=${pdu_id}    nwslice=${nwslice_ID}[${ue_id}]    gw=${gw_id}
    ...     request_type=initial-emergency-request
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}

Perform Precondition of Test Scenario
    ute_wtssim.execute_egate_command   cmd=ue_gnb_ho_param id=1 gnb=2
    ute_wtssim.execute_egate_command   cmd=ue_gnb_ho_param id=1 gnb=3

Configure ReestablishmentInfo For NG Handover
    ...  ute_wtssim.execute_egate_command   cmd=ue_gnb_ho_param id=1 gnb=2 reestab_info=1:valid  reestab_ncell_info=2:valid

ue location change custom
    ${location}     SET VARIABLE    ue_change_location id=1 enb=3 cell=3
#    ute_wtssim.execute_egate_command    cmd=${location}
    ${reg2}     Set Variable    UE-1\[OFF\]: location updated to eNB-3 cell 3
    ${output2}	ute_wtssim.Execute Egate Command And Wait For Data    ${location}    pass_regex=${reg2}   timeout=10
    log to console      ${output2}

Configure mrl1
    ${msr}     SET VARIABLE      amf_mobility_restriction_list_param id=1 sa_plmn=311:489
    ute_wtssim.execute_egate_command        ${msr}

Trigger NGHO from simulator to real
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    ute_wtssim.execute_egate_command    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${msr}      SET VARIABLE    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=1 phycell_id=${phycell_id} nrsrp_nr=30
    ute_wtssim.Execute Egate Command And Wait For Data      ${msr}     pass_regexp=${XnHo_success}      timeout=30s

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

Set security configuration
  [Arguments]   ${gnb_id}=2   ${ue_id}=1

    Log To Console  include security configuration
    Execute Egate Command  cmd=ue_gnb_ho_param id=${ue_id} gnb=${gnb_id} include_security_config=on

Set UE RRC Reestablishment During RRCReconfiguration
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1  ${cause}=otherFailure  ${crnti}=source  ${action}=reestablish  ${nth}=1
    ...  ${num_reest_reqs}=1
    Log to console
    ...  Set UE RRC Reestablishment During RRCReconf UE: ${ue_id}, gNB: ${gnb_id}, Cell: ${cell_id}, Cause: ${cause}, CRNTI: ${crnti}, nth: 1

    ${cmd}  Catenate  ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=${action} gnb=${gnb_id}
    ...  cell=${cell_id} cause=${cause} crnti=${crnti} nth=${nth} num_reestablishment_reqs=${num_reest_reqs}

    Execute egate command  cmd=${cmd}


