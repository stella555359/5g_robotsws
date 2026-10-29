*** Settings ***
Force Tags      CLOUD_5G_O_H_AP_LOO    OPTION_RELATED_ARTIFACTS_5G   VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

...             SBTS00   CONFIGURED   5G_RAN   RAN_5G   RAN_5G_FDD   5G_RAN_FDD   CRT

Documentation   :copyright: Nokia
...              :author: Meghana
...              :contact: meghana.s@nokia.com
...         The aim of the CB009842 feature is to enhance UL NR E-CID positioning method
...         to provide the Timing advanced (Tadv) measurments to help improving UE positioning accuracy.
...         Tadv can be provided to LMF in addition to the SS-RSRP/RSRQ measurements introduced by CB008281 feature.
...         Successful E-CID measurement reporting for NR-TADV measurement quality after, UE is Inactive mode and
...         moving make RLF failure in TDD

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner


Resource         testsuite/Bangalore/RRM/5GET_BLR/CB008225/resources/CB008225_resource.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../CB008541/resources/CB008541_Keywords.robot

Suite Setup         Run keywords    Prepare TL with all config files
...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     sleep    30s
#...                 AND   5GC000937_Keywords.Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     WTS_Runner_Keywords.Start WTS Using WTS_Runner      ${wts_cfg_file}
...					AND		sleep	60s

Test Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
...                 AND     Link SCOUT SCF to Configuration ID for Reporting



*** Variables ***
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${wts_cfg_file}     ${CURDIR}/config/ASOH_basic.cfg
${BTS_ADDRESS}    192.168.255.1
${BTS_PORT}       443
${USE_SSL}        True
${SCF_Path}    SCF_DU_Setup.xml
${SCFC}=        ${CURDIR}/config/SCF/ASOH_Configuration_scf_MRBTS-1_2_16_UTE5GCLASSICAL1622_20240625-1317.xml
${AP_XML}=      ${CURDIR}/config/SCF/ASOH_iphy.xml
#${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
#${TRF_ID}    1
${TRF_ID2}    2

##${nwslice_ID}   1
#${gw_ID}     1
#${Pdu_session_ID}       1
#${QFI_ID}    1

${TEST_NAME}        test_case

${start_ue_id}      ${51}
${end_ue_id}      ${51}
${delta}       30
${tp_duration}      40
${inactivity_timer}      60


@{QOS_Prof1}               1     #5QI 6
@{QOS_Prof1_speed_dl}      1
@{QOS_Prof1_speed_ul}      1
@{QOS_Prof1_unit}          mbps

${duration}      60
${trf_id}      ${1}
${UE_ID}      51

*** Test Cases ***
[1]CB009842_10_Successful_E-CID_Measurement_Reporting_for_NR-TADV_Measurement_Quantity_after_UE_is_INACTIVE_mode_&_moving_make_RLF_failure_in_the_FDD
    [Tags]    QC_349712      QCD_MN_RAN    QCP_RAN_ET
    set test variable      ${LOG_PATH}
#    Verify RRCInactive_IE from SIB1     ${LOG_PATH}/NODECPRT_GNB_cellsetup.pcap
    log to console   UE attach trigerring now...
    ${qos_profile}               Create Dictionary   ${51}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${51}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${51}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${51}=${QOS_Prof1_unit}
    ${cnai}                  Create Dictionary           ${51}=on
    ${state}                  Create Dictionary          ${51}=inactive
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log    btslog    cprt    biptaf
    wtsrunner.ue_ta_nr  profile_id=51    ue_p_delay_initial=100
    wtsrunner.ue_testmode_set_nr    id=51    testmode=ta    action=activate    profile_id=51
    ${ue_to_bearer_list}=      MultiUE Register should be Successful with CNAI     ${start_ue_id}    ${end_ue_id}      cnai=${cnai}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    wtsrunner.lmf_send_ecid_meas_req    id=1    ue=51    nrppa_transaction_id=1    lmf_ue_measurement_id=1
    ...     report_characteristics=OnDemand     meas_qty=NR_Timing_Advance
     sleep   ${delta}s
    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp        ${start_ue_id}    ${end_ue_id}      ${qos_profile}
    ...    state=${state}
    sleep   60s
    ${scen1}    Stop Log    btslog    cprt    biptaf    test_scenario=scen1

    log to console   checking for TA value...
    CheckTAValue    ${scen1}[cprt]/NODECPRT_GNB.pcap      112

    Sleep till inactivity timer expiry
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State       ${start_ue_id}    ${end_ue_id}        state=${state}
    ${inactivity_timer_cal}        Verify Inactivity Timer         ${start_ue_id}       ${end_ue_id}            ${state}
         ...      ${inactivity_start}        ${inactivity_stop}        ${delta}        ${inactivity_timer}

#    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
#    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    Start Log    cprt      biptaf
    wtsrunner.lmf_send_ecid_meas_req    id=1    ue=51    nrppa_transaction_id=1    lmf_ue_measurement_id=1
    ...     report_characteristics=OnDemand     meas_qty=NR_Timing_Advance
    sleep   60s
    ${attach}    Stop Log    btslog    cprt    biptaf    test_scenario=attach
    log to console   checking for TA value...
    CheckTAValue    ${attach}[cprt]/NODECPRT_GNB.pcap      112
    sleep    20s
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    Start Log    cprt      biptaf
    wtsrunner.ue_ta_nr     profile_id=51     ue_p_delay_initial=50
    wtsrunner.ue_rrc_reestablish     id=51     gnb=2     cell=3     cause=reconfigurationFailure
    sleep    10s
    wtsrunner.lmf_send_ecid_meas_req    id=1    ue=51    nrppa_transaction_id=1    lmf_ue_measurement_id=1
    ...     report_characteristics=OnDemand     meas_qty=NR_Timing_Advance
    ${delay}    Stop Log    btslog    cprt    biptaf    test_scenario=delay
    log to console   checking for TA value...
    CheckTAValue    ${delay}[cprt]/NODECPRT_GNB.pcap     64

     Stop Data Traffic for SA     ue_id=51
     UE Deregister should be Successful    ue_id=51


*** Keywords ***

CheckTAValue
    [Arguments]    ${file_path}    ${value}
    ${pdmlFile} =    Get filtered PDML file from pcap   pcapFile=${file_path}    filterExp=nrppa.NR_TADV
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...          field_name=nrppa.MeasuredResultsValue   attrib_name=show     attrib_value=5
    ${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=nrppa.NR_TADV  attrib_name=showname
    should be equal    ${attrib_values}[0]    NR-TADV: ${value}

Trigger RLF failure and Verify TAdv
    Start Log    cprt      biptaf
#    wtsrunner.ue_ta_nr    profile_id=51     ue_p_delay_initial=50
    wtsrunner.ue_rrc_reestablish     id=51    gnb=2    cell=3    cause=reconfigurationFailure
    wtsrunner.lmf_send_ecid_meas_req    id=1    ue=51    nrppa_transaction_id=1    lmf_ue_measurement_id=1
    ...     report_characteristics=OnDemand     meas_qty=NR_Timing_Advance
    ${delay}    Stop Log    cprt   biptaf      test_scenario=delay
    log to console   checking for TA value...
    CheckTAValue    ${delay}[cprt]/NODECPRT_GNB.pcap      136

MultiUE Register should be Successful with CNAI
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}       ${cnai}=${EMPTY}
	...		${subscriber_trace}=False
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    ${ue_to_bearer_list}=    Create Dictionary
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Run Keyword If  '${cnai[${ue_idx}]}' == 'on'       Set Core Network Assistance info    ${ue_idx}
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File     ${OUTPUT_DIR}/regst.txt     ${output}
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk '{print $9}'
    Append To List  ${crnti_list}   ${crnti_string}
    BuiltIn.Log     ${crnti_string}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
	Run Keyword if		'${subscriber_trace}'=='True'			Start Subscriber Trace
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}
    ${output}=  Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    ${bearer_list}       Create List
    Create File     ${OUTPUT_DIR}/bearer.txt        ${output}
    ${bearer_id}=    Run     cat ${OUTPUT_DIR}/bearer.txt |grep -i "servedRadioBearer drb-Identity" |awk '{print $4}'|sed 's/,//g'
    Append To List     ${bearer_list}        ${bearer_id}
    Set To Dictionary   ${ue_to_bearer_list}    ${ue_idx}       ${bearer_list}
    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}         ${ue_to_bearer_list}


Set Core Network Assistance info
    [Arguments]    ${ue_idx}
    Log to Console     Setting Core Network Assistance Info
    wtsrunner.amf_ue_ics_param       id=1         ue=${ue_idx}
    ...     trace_activation=on    trace_plmn=311:489     trace_ref_id=1     trace_rec_session_ref_id=1
    ...     trace_depth=minimum     ifaces_to_trace=NG-C     tce_ip=10.0.1.1
    ...     core_network_assistance_info=on     ue_identity_index_value=1     ue_specific_drx=64
    ...     periodic_registration_update_timer=1:1min       plmn_id=311:489     tac_id=200

Stop MultiUE Data Traffic for SA with timestamp
    [Arguments]    ${start_ue_id}   ${end_ue_id}     ${qos_profile}      ${state}=${EMPTY}
    [Documentation]    This keyword stops the Data Traffic for the SA variant
    ${data_stop_time}        Create Dictionary
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
	Run Keyword If  '${state[${ue_idx}]}' == 'active'       Continue For Loop
    Log to Console    \nStopping Data Traffic...
    ${idx}     Set Variable    ${qos_profile[${ue_idx}]}
    ${output}      ${time}        Stop Data Traffic QFIwise        ${ue_idx}       qfi_id=${idx}
    ...        pdu=${Pdu_session_ID}      trfid=${trf_id}
    Set To Dictionary       ${data_stop_time}     ${ue_idx}      ${time[${2}]}
    Log to Console    ${output}
    sleep   1s
	END
	[Return]    ${data_stop_time}


