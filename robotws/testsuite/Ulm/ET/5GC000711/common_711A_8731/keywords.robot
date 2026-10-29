*** Settings ***
Documentation   This is a keyword file for 5GC000711-A CB008731
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        ../../../resources/Common/reporting.robot

*** Variables ***

${WIRESHARK_RUNNING}     false

*** Keywords ***

Perform Preconditions Of Test Scenario 711A 8731
    [Documentation]    [PRIVATE]    preconditions for 711A CB8731
    ...       :Autor: Sylvia Schneider
    Create A Test Scenario Folder


Perform Postconditions Of Test Scenario 711A 8731 trace
    [Documentation]    [PRIVATE]    postconditions for 711A CB8731 with emil trace
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure   Set SCOUT TC ID for Reporting
    Run Keyword And Continue On Failure   Stop Wireshark Trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    Run Keyword And Continue On Failure   End Dcap Tracing And Collect Traces
    Run Keyword And Continue On Failure   Teardown Egate Connection For Airphone
    Run Keyword And Continue On Failure   Teardown Edaemon Connection For Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    Collect Snapshot And Sos Report Data     ${resultDir}


Prepare TL 711A
    [Documentation]    [PRIVATE]    Prepare TL 711A
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${wts_file}      ${tc}
    Load Wts File    ${wts_file}
    Start Wireshark Trace
    Bring Airphone TL To On Air Status
    Stop Wireshark Trace For Setup
    Check Wts In Active State
    Run Keyword     Prepare Counters And Expected Values ${tc}


Set Sw Release Version
    [Documentation]    [PRIVATE]    set sw release version from gnb sw version
    ...       :Autor: Sylvia Schneider
    @{gnb_sw_version_parts}   Split String    ${gnb_swVersion}    _
    Set Suite Variable    ${release}   ${gnb_sw_version_parts}[0]


Check All Radio Units Online
    [Documentation]    [PRIVATE]   check that all radio units are online
    ...     :Autor: Sylvia Schneider
    Log To Console    Waiting until all RUs are online
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Wait Until Keyword Succeeds
    ...    10min   20sec
    ...    Verify All Radios Are Online    connection=${oam_alias}
    Log To Console    RUs ready
    [Teardown]     connect.Teardown OAM http session    node_type=gnb  node_id=${0}


Suite Teardown 711A 8731
    [Documentation]    [PRIVATE]    suite teardown for 711A CB8731
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure   Stop Wireshark Trace      wireshark_store=${resultBaseDir}/wireshark_suite_teardown.pcap
    IF    '${SUITE STATUS}'=='FAIL' and '${logs_collected}'=='False'    Collect Snapshot And Sos Report Data   ${resultBaseDir}
    Reload Stored WTS Config


Get version mcc mnc From gNB SCF
    [Documentation]    [PRIVATE]    get values from SCF for update commissioning
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${current_SCF_gnb}
    ${parsed_SCF}    Parse XML    ${current_SCF_gnb}
    ${version}    Get Element Attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="${bts_distName}"]
    Set To Dictionary    ${SCF}   version   ${version}
    Log To Console    variable SCF.version contains ${SCF.version}
    ${MNL_version}    Get Element Attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="MRBTS-1/MNL-1"]
    Set To Dictionary    ${SCF}   MNL_version   ${MNL_version}
    Log To Console    variable SCF.MNL_version contains ${SCF.MNL_version}
    ${NRPMRNL_version}    Get Element Attribute    ${parsed_SCF}    version     xpath=.//managedObject[@class="com.nokia.srbts.nrbts:NRPMRNL"]
    Set To Dictionary    ${SCF}   NRPMRNL_version   ${NRPMRNL_version}
    Log To Console    variable SCF.NRPMRNL_version contains ${SCF.NRPMRNL_version}
    ${NRPMRNL_distName}    Get Element Attribute    ${parsed_SCF}    distName     xpath=.//managedObject[@class="com.nokia.srbts.nrbts:NRPMRNL"]
    Set To Dictionary    ${SCF}   NRPMRNL_distName   ${NRPMRNL_distName}
    Log To Console    variable SCF.NRPMRNL_distName contains ${SCF.NRPMRNL_distName}
    ${mcc}    Get Element Text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mcc"]
    Set To Dictionary    ${SCF}   mcc   ${mcc}
    Log To Console    variable SCF.mcc contains ${SCF.mcc}
    ${mnc}    Get Element Text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mnc"]
    Set To Dictionary    ${SCF}   mnc   ${mnc}
    Log To Console    variable SCF.mnc contains ${SCF.mnc}


Start Wireshark Trace
    [Documentation]    [PRIVATE]    start wireshark trace
    ...       :Autor: Sylvia Schneider
    Start Tcpdump On TestPc
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    Sleep     1s
    Set Suite Variable      ${WIRESHARK_RUNNING}    true


Stop Wireshark Trace
    [Documentation]    [PRIVATE]    stop wireshark trace
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_store}=${resultDir}/wireshark.pcap
    IF    '${WIRESHARK_RUNNING}'=='false'   RETURN
    Sleep     2s
    @{result_place}    Split String     ${wireshark_store}    /
    ${tcpdump_dir}     Remove String    ${wireshark_store}    /${result_place}[-1]
    ${tcpdump_file}    Stop Tcpdump On TestPc
    ...  collector=dump_testpc
    ...  target_dir=${tcpdump_dir}
    Sleep     2s
    Move File    ${tcpdump_file}    ${wireshark_store}
    Set Suite Variable      ${WIRESHARK_RUNNING}    false


Stop Wireshark Trace For Setup
    [Documentation]    [PRIVATE]    stop wireshark trace for setup
    ...       :Autor: Sylvia Schneider
    Stop Wireshark Trace            wireshark_store=${resultDir}/wireshark_startTL.pcap


Register UE And Start PDU Session
    [Documentation]    [PRIVATE]    register UE, start PDU
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1
    Register UE           ${ue_id}
    Start PDU Session     ${ue_id}


Register UE
    [Documentation]    [PRIVATE]    register UE
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    Log To Console    execute on wts: ue_register id=${UE_id} nwslice=all
    Log To Console    check on wts: "REGISTRATION COMPLETE from UE"
    Sleep     2s
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_register id=${UE_id} nwslice=all
    ...    return_output=True
    ...    pass_regexp=REGISTRATION COMPLETE from UE
    ...    alias=ap_egate


Start PDU Session
    [Documentation]    [PRIVATE]    start PDU
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1    ${check}=Initial Context Setup Successful
    ${cmd}    Set Variable  ue_pdu_session_setup pdu=1 ue=${UE_id} gw=${UE_id}
    Log To Console    execute on wts:${cmd}
    Log To Console    check on wts: "${check}"
    Sleep     2s
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate


Release UE
    [Documentation]    [PRIVATE]    stop PDU, deregister UE
    ...       :Autor: Sylvia Schneider
    FOR   ${id}  IN   @{UE}
      Run Keyword And Ignore Error    UE PDU Session Release   ue_id=${id}   pdu=1
      Run Keyword And Ignore Error    UE Deregister            ue_id=${id}
    END


smf param reset
    [Documentation]    [PRIVATE]    smf param reset
    ...       :Autor: Sylvia Schneider
    ${cmd}   Set Variable    smf_param id=1 reset
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.Execute Egate Command    cmd=${cmd}
    ...    alias=ap_egate


smf param additional_qosflows_to_activate
    [Documentation]    [PRIVATE]    smf param additional_qosflows_to_activate
    ...       :Autor: Sylvia Schneider
    ${cmd}   Set Variable    smf_param id=1 additional_qosflows_to_activate=4
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.Execute Egate Command    cmd=${cmd}
    ...    alias=ap_egate


Trigger Handover To LTE
    [Documentation]    [PRIVATE]    trigger handover to LTE
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1    ${A2_meas_id}=1   ${B2_meas_id}=3   ${check}=Successful handover from EXT_ENB-2.1 to ENB-4.1
    Send A2      ${ue_id}     ${A2_meas_id}
    Send B2      ${ue_id}     ${B2_meas_id}   ${check}


Send A2
    [Documentation]    [PRIVATE]    send A2
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}    ${A2_meas_id}
     Log To Console
    ...    execute on wts: ue_measurement_send_nr id=${ue_id} meas_id=${A2_meas_id} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    Sleep     2s
    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${A2_meas_id} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ...    alias=ap_egate


Send A2 And Check
    [Documentation]    [PRIVATE]    send A2 and check
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}    ${A2_meas_id}
    ${cmd}   Set Variable     ue_measurement_send_nr id=${ue_id} meas_id=${A2_meas_id} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ${check}   Set Variable   rrcReconfigurationComplete
    Log To Console  execute on wts: ${cmd}
    Log To Console  check on wts: "${check}"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_A2.txt    ${output_egate}
    Sleep     2s


Send B2
    [Documentation]    [PRIVATE]    send B2
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}    ${B2_meas_id}   ${check}
    ${cmd_part1}   Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${B2_meas_id} event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ${cmd_part2}   Set Variable    phycell_id=11 nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    ${cmd}         Catenate    ${cmd_part1}   ${cmd_part2}
    Log To Console    execute on wts: ${cmd}
    Log To Console
    ...   check on wts: "${check}"
    Sleep     2s
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${cmd}
    ...    pass_regexp=${check}
    ...    alias=ap_egate


Trigger Handover To 5G
    [Documentation]    [PRIVATE]    trigger handover to 5G
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1    ${check}=Inter-eNB handover from ENB-4.1 to EXT_ENB-2.1 performed   ${target_cell}=1   ${plmn}=311:489
    ${cmd}  Set Variable   gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=${target_cell} plmn=${plmn}
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: "${check}"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Sleep     2s   wait for all data sent
    Create File    ${resultDir}/egate_handover_5G_ue${ue_id}.txt    ${output_egate}


Trigger Handover To 5G Which Is Cancelled And Check
    [Documentation]    [PRIVATE]    trigger handover to 5G which is cancelled
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${cause}   ${target_cell}=1    ${plmn}=311:489
    ${wts_cmd}  Set Variable   gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=${target_cell} plmn=${plmn}
    Log To Console    execute on wts: ${wts_cmd}
    Log To Console
    ...   check on wts: "${cause}"
    Sleep     2s
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${wts_cmd}
    ...    pass_regexp=${cause}
    ...    alias=ap_egate


Trigger Handover To 5G Which Fails
    [Documentation]    [PRIVATE]    trigger handover to 5G which fails
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${cause}
    ${wts_cmd}  Set Variable   gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=1 plmn=311:489
    Log To Console    execute on wts: ${wts_cmd}
    Log To Console
    ...   check on wts: "Handover Preparation Failure Sent for Amf UE NGAP ID [0-9]* with cause RAN ${cause}"
    Sleep     2s
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${wts_cmd}
    ...    pass_regexp=Handover Preparation Failure Sent for Amf UE NGAP ID [0-9]* with cause RAN ${cause}
    ...    alias=ap_egate


Trigger Inter gnb Handover
    [Documentation]    [PRIVATE]    trigger inter gnb handover
    ...       :Autor: Sylvia Schneider
    ${wts_cmd}  Set Variable   ue_measurement_send_nr event=A3 srsrp_nr=50 phycell_id=48 nrsrp_nr=70 meas_id=2 id=1
    Log To Console    execute on wts: ${wts_cmd}
    Log To Console
    ...   check on wts: "Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed"
    Sleep     2s
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${wts_cmd}
    ...    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    ...    alias=ap_egate


Trigger Inter gnb Handover Which Fails
    [Documentation]    [PRIVATE]    trigger inter gnb handover which fails
    ...       :Autor: Sylvia Schneider
    ${wts_cmd}  Set Variable   ue_measurement_send_nr event=A3 srsrp_nr=50 phycell_id=49 nrsrp_nr=70 meas_id=2 id=1
    Log To Console    execute on wts: ${wts_cmd}
    Sleep     2s
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${wts_cmd}
    ...    alias=ap_egate


amf override_ie
    [Documentation]    [PRIVATE]    amf override_ie
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}    ${nwslice}
    ${wts_cmd}  Set Variable
    ...   amf_ue_ng_handover_request_param id=1 ue=${ue_id} action=override_ie pdu=1 nwslice=0x01:${nwslice} allowed_nwslice=0x01:0xd143a5
    Log To Console    execute on wts: ${wts_cmd}
    Sleep     2s
    ute_wtssim.Execute Egate Command    cmd=${wts_cmd}
    ...    alias=ap_egate


amf reset_ie
    [Documentation]    [PRIVATE]    amf reset_ie
    ...       :Autor: Bernhard Kukla
    [Arguments]     ${ue_id}
    Log To Console    execute on wts: amf_ue_ng_handover_request_ack_param id=1 ue=${ue_id} reset
    Sleep     2s
    ute_wtssim.Execute Egate Command    cmd=amf_ue_ng_handover_request_ack_param id=1 ue=${ue_id} reset
    ...    alias=ap_egate


amf ng_handover_request
    [Documentation]    [PRIVATE]    amf ignore ng_handover_request or send_alternate_response
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}     ${action}
    ${params}   IF   "${action}"=="ignore"            Set Variable   ignore
    ...         ELSE IF   "${action}"=="dl_nas"            Set Variable   send_alternate_response msg=ng_dl_nas_transport
    ...         ELSE IF   "${action}"=="pdu_setup"         Set Variable   send_alternate_response msg=ng_pdu_session_setup
    ...         ELSE IF   "${action}"=="pdu_release"       Set Variable   send_alternate_response msg=ng_pdu_session_release
    ...         ELSE IF   "${action}"=="pdu_modification"  Set Variable   send_alternate_response msg=ng_pdu_session_modification
    ...         ELSE   Set Variable   send_alternate_response msg=ng_ue_ctx_release_cmd cause=RN_handover_cancelled
    Log To Console    execute on wts: amf_ue_ng_handover_request_ack_param id=1 ue=${ue_id} action=${params}
    Sleep     2s
    ute_wtssim.Execute Egate Command    cmd=amf_ue_ng_handover_request_ack_param id=1 ue=${ue_id} action=${params}
    ...    alias=ap_egate


amf ng_handover_request location_request
    [Documentation]    [PRIVATE]    amf ng_handover_request location_request
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}     ${action}
    ${params}   IF   "${action}"=="change cell"            Set Variable   change-of-serving-cell
    ...         ELSE   Set Variable   ue-presence-in-area-of-interest object_id=1 location_reporting_reference_id=1
    Log To Console    execute on wts: amf_ue_ng_handover_request_param id=1 ue=${ue_id} location_request=on event_type=${params}
    Sleep     2s
    ute_wtssim.Execute Egate Command    cmd=amf_ue_ng_handover_request_param id=1 ue=${ue_id} location_request=on event_type=${params}
    ...    alias=ap_egate


amf dl_nas_transport indexToRFSP
    [Documentation]    [PRIVATE]    set indexToRFSP-NAS in wts
    ...       :Autor: Sylvia Schneider
    Log To Console    execute on wts: amf_dl_nas_transport_param id=1 indexToRFSP=12
    Sleep     2s
    ute_wtssim.Execute Egate Command     cmd=amf_dl_nas_transport_param id=1 indexToRFSP=12    alias=ap_egate
    Log To Console    execute on wts: ue_send_dl_nas_transport id=1
    Sleep     2s
    ute_wtssim.Execute Egate Command     cmd=ue_send_dl_nas_transport id=1    alias=ap_egate


amf mobility_restriction_list
    [Documentation]    [PRIVATE]    set mobility_restriction_list in wts
    ...       :Autor: Sylvia Schneider
    ${cmd1}    Set Variable  amf_mobility_restriction_list_param id=1 equiv_plmn=311:490 fa_plmn=311:491 forbidden_tacs=1,2 sa_plmn=311:489
    ${cmd2}    Set Variable  allowed_tacs=100,200 not_allowed_tacs=788 restricted_plmn=311:492 restricted_rat=both
    ${cmd}     Catenate     ${cmd1}     ${cmd2}
    Log To Console    execute on wts: ${cmd}
    Sleep     2s
    ute_wtssim.Execute Egate Command     cmd=${cmd}    alias=ap_egate
    Log To Console    execute on wts: amf_ue_ng_handover_request_param id=1 ue=1 mobility_restriction_list_id=1
    Sleep     2s
    ute_wtssim.Execute Egate Command     cmd=amf_ue_ng_handover_request_param id=1 ue=1 mobility_restriction_list_id=1    alias=ap_egate


amf voice_fallback
    [Documentation]    [PRIVATE]    amf voice_fallback
    ...       :Autor: Sylvia Schneider
    Log To Console    execute on wts: amf_param id=1 voice_fallback=on
    Sleep     2s
    ute_wtssim.Execute Egate Command    cmd=amf_param id=1 voice_fallback=on
    ...    alias=ap_egate


Send Rrc Reconfiguration Reestablish
    [Documentation]    [PRIVATE]    send rrc reconfiguration reestablish
    ...       :Autor: Sylvia Schneider
    Log To Console    execute on wts: ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish
    Sleep     2s
    ute_wtssim.Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish
    ...    alias=ap_egate


area of interest configuration
    [Documentation]    [PRIVATE]    send area of interest configuration
    ...       :Autor: Sylvia Schneider

    ${cmd1}   Set Variable    area_of_interest_configuration object_id=1 plmn_ran_node_id=114:121 globalrannodeid=34 plmn_tai=311:490
    ${cmd2}   Set Variable    taclist=12,21 plmn_cellid=311:489 nrcellidentitylist=16385,16386,16387
    ${cmd}    Catenate        ${cmd1}     ${cmd2}

    Log To Console    execute on wts: ${cmd}
    Sleep     2s
    ute_wtssim.Execute Egate Command    cmd=${cmd}
    ...    alias=ap_egate


Modify Ue Pdu Session Del qosflows
    [Documentation]    [PRIVATE]    modify ue pdu session del qosflows
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1
    Log To Console    execute on wts: ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=2 by=amf
    Log To Console
    ...   check on wts: "Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully"
    Sleep     2s
    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=2 by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully
    ...    alias=ap_egate


Modify Ue Pdu Session
    [Documentation]    [PRIVATE]    modify ue pdu session
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}    ${qosflows_to_add}=2
    Log To Console    execute on wts: ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qosflows_to_add} by=amf
    Log To Console
    ...   check on wts: "Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully"
    Sleep     2s
    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qosflows_to_add} by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully
    ...    alias=ap_egate


Modify Ue Pdu Session Voice Fallback
    [Documentation]    [PRIVATE]    modify ue pdu session for voice fallback
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}
    Log To Console    execute on wts: ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    Log To Console
    ...   check on wts: "Redirected carrier info is present in RRC Release"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ...    return_output=True
    ...    pass_regexp=Redirected carrier info is present in RRC Release
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_pdu_modify.txt    ${output_egate}


qosflow_modify And nr_rrc_setup
    [Documentation]    [PRIVATE]    qosflow_modify and nr_rrc_setup
    ...       :Autor: Sylvia Schneider
    Log To Console    execute on wts: qosflow_modify qos_flow=1 priority=1
    Sleep     2s
    ute_wtssim.Execute Egate Command    cmd=qosflow_modify qos_flow=1 priority=1
    ...    alias=ap_egate
    Log To Console    execute on wts: qosflow_modify qos_flow=2 priority=1
    Sleep     2s
    ute_wtssim.Execute Egate Command    cmd=qosflow_modify qos_flow=2 priority=1
    ...    alias=ap_egate
    Log To Console    execute on wts: ue_nr_rrc_setup_param id=3 establishment_cause=emergency
    Sleep     2s
    ute_wtssim.Execute Egate Command    cmd=ue_nr_rrc_setup_param id=3 establishment_cause=emergency
    ...    alias=ap_egate


qosflow_modify And nr_rrc_setup High Priority Access
    [Documentation]    [PRIVATE]    qosflow_modify and nr_rrc_setup high priority access
    ...       :Autor: Sylvia Schneider
    Log To Console    execute on wts: qosflow_modify qos_flow=1 priority=2
    Sleep     2s
    ute_wtssim.Execute Egate Command    cmd=qosflow_modify qos_flow=1 priority=2
    ...    alias=ap_egate
    Log To Console    execute on wts: qosflow_modify qos_flow=2 priority=2
    Sleep     2s
    ute_wtssim.Execute Egate Command    cmd=qosflow_modify qos_flow=2 priority=2
    ...    alias=ap_egate
    Log To Console    execute on wts: ue_nr_rrc_setup_param id=3 establishment_cause=highPriorityAccess
    Sleep     2s
    ute_wtssim.Execute Egate Command    cmd=ue_nr_rrc_setup_param id=3 establishment_cause=highPriorityAccess
    ...    alias=ap_egate


Send A1 For Scell Addition
    [Documentation]    [PRIVATE]    send A1 for Scell addition
    ...       :Autor: Sylvia Schneider
    ${cmd}   Set Variable    ue_measurement_send_nr id=1 meas_id=2 event=A1 srsrp_nr=70 ssinr_nr=59 srsrq_nr=70
    Log To Console    execute on wts: ${cmd}
    Log To Console
    ...   check on wts: "SCellIndex 1 activated successfully at airphone"
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=SCellIndex 1 activated successfully at airphone
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_scell_activate.txt    ${output_egate}


Send A1
    [Documentation]    [PRIVATE]    send A1
    ...       :Autor: Sylvia Schneider
    ${cmd}   Set Variable    ue_measurement_send_nr id=1 meas_id=2 event=A1 srsrp_nr=70 srsrq_nr=60 srs_result=0:11:11:0
    Log To Console   execute on wts: ${cmd}
    Log To Console   check on wts: "measId 2" present
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=measId 2
    ...    alias=ap_egate
    Create File    ${resultDir}/A1_t6.txt    ${output_egate}


Send A4 With meas_id ${meas_id}
    [Documentation]    [PRIVATE]    send A4
    ...       :Autor: Sylvia Schneider
    ${cmd}   Set Variable    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A4 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=40 nrsrq_nr=30
    Log To Console   execute on wts: ${cmd}
    Log To Console
    ...   check on wts: "Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed"
    Sleep     2s
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${cmd}
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    ...    alias=ap_egate


Deregister UE
    [Documentation]    [PRIVATE]    deregister UE
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1
    Log To Console    execute on wts: ue_deregister id=${ue_id} ue_deregister_type=switch_off
    Sleep     2s
    ute_wtssim.Execute Egate Command    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
    ...    alias=ap_egate


Set Sib Period
    [Documentation]    [PRIVATE]    set sib period
    ...       :Autor: Sylvia Schneider
    FOR   ${sib}   IN   sib1   sib2   sib5
       ${cmd}   Set Variable   gnb_param id=3 ${sib}_period=40
       Log To Console    execute on wts: ${cmd}
       ute_wtssim.Execute Egate Command    cmd=${cmd}    alias=ap_egate
       Sleep     1s
    END


Ue Change Location
    [Documentation]    [PRIVATE]    ue change location
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${cell}

    ${cmd}   Set Variable   ue_change_location id=${ue_id} enb=3 cell=${cell}
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.Execute Egate Command    cmd=${cmd}    alias=ap_egate


Change Location
    [Documentation]    [PRIVATE]    change location
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}   ${enb}   ${cell}

    ${cmd}   Set Variable   ue_change_location id=${ue_id} enb=${enb} cell=${cell}
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.Execute Egate Command    cmd=${cmd}    alias=ap_egate


Change Ue Capabilities
    [Documentation]    [PRIVATE]    change ue capabilities
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1   ${ue_nr_capabilities}=${new_ue1_cap}
    ${cmd}   Set Variable   ue_param id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.Execute Egate Command    cmd=${cmd}    alias=ap_egate


Display Measurements Of UE
    [Documentation]    [PRIVATE]    display measurements of UE
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}  ${log}=${EMPTY}
    ${cmd}     Set Variable    ue_meas_disp id=${ue_id}
    Log To Console   execute on wts: ${cmd}
    Sleep     2s
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/disp_meas_UE${ue_id}${log}.txt    ${output_egate}


Verify Egate Log Pdu Modify
    [Documentation]    [PRIVATE]    verify in egate log content of pdu modify
    ...       :Autor: Sylvia Schneider
    ${contents}    Get File           ${resultDir}/egate_log_pdu_modify.txt

    Log To Console    verify presence of "Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully"
    Run Keyword And Continue On Failure   Should Match Regexp
    ...   ${contents}
    ...   Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully
    ...   Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]* handled successfully not present
    Log To Console    verify presence of "redirectedCarrierInfo eutra"
    Run Keyword And Continue On Failure   Should Match Regexp
    ...   ${contents}
    ...   redirectedCarrierInfo eutra
    ...   redirectedCarrierInfo eutra not present
    Log To Console    verify presence of "eutraFrequency 1350"
    Run Keyword And Continue On Failure   Should Match Regexp
    ...   ${contents}
    ...   eutraFrequency 1350
    ...   eutraFrequency 1350 not present


Verify Egate Log Handover 5G
    [Documentation]    [PRIVATE]    verify in egate log content of handover 5G
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${ue_id}=1
    ${contents}    Get File           ${resultDir}/egate_handover_5G_ue${ue_id}.txt

    Log To Console    verify presence of "Inter-eNB handover from ENB-4.1 to EXT_ENB-2.1 performed" for ue_id=${ue_id}
    Run Keyword And Continue On Failure   Should Match Regexp
    ...   ${contents}
    ...   Inter-eNB handover from ENB-4.1 to EXT_ENB-2.1 performed
    ...   Inter-eNB handover from ENB-4.1 to EXT_ENB-2.1 performed not present
