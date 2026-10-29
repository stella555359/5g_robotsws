*** Settings ***

Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...               RAN_5G_TDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation    :copyright: Nokia
...              :authors: Prasanta kumar Nayak, Padmashree b
...              :contact: prasanta.kumar_nayak@nokia.com, padmashree.b@nokia.com
...              :5G_RAN_USR_RRM_25479 ; OM_GEN_SFS_TRACEMGMNT.4881
...              This TC verifies the incoming XN handover sceanrios and outgoing HO scenario with Slice switch to
...              default slice
...              +++ PCMD validation added along with XN handover scenario to verify trace messages

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Resource         ../CB008541/resources/CB008541_Keywords.robot
#Resource         85011_CNI_keywords.resource
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/wts_sim_keywords.robot
Resource         ./basic_resource.robot
Suite Setup         Run keywords     Prepare TL with all config files
...                 AND    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND    Add routes
#...            	     AND     Update_tce_ip_in_delta_file     ${scf_file_path}/SBTS24R3/${scffile_name}
#...                  AND     Update_tce_ip_in_delta_file     ${scf_file_path}/SBTS25R1/${scffile_name}
#...                 AND     Perform SCF Delta Commissioning with Delta_config_PCMD.json
#...                 AND     Perform SCF Delta Commissioning with Delta_additional_plmn.json
#...                 AND     Initiate Dcap
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   300s    reason=wait for RMOD to comeup
...                 AND    Start wts application and load CFG      ${wts_cfg_file}
...                 AND    sleep  60s   reason=wait for mib sib
#...                 AND     DCAP Connect To gNB

Suite Teardown      Run Keywords    Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Teardown    Run Keywords       Link SCOUT SCF to Configuration ID for Reporting
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport
#...                 AND     DCAP Disconnect To gNB


Test Setup       Start_capture_testcase_default_logging

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/slice_basic_setup_multi_ue_Xn_HO.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${scffile_name}     Delta_config_PCMD.json
${scf_file_path}    ${CURDIR}/config/
${WTS_DIR}          /opt/iphy/latest
${UE_ID1}        1
${UE_ID2}        2
${UE_ID3}        3
#${nwslice_ID}   1
&{nwslice_ID}   ${1}=1    ${2}=2     ${3}=3     ${4}=14     ${5}=15    ${6}=16
${gw_ID1}     1
${gw_ID2}     2
${gw_ID3}     3
${Pdu_session_ID1}       1
${Pdu_session_ID2}       2
${QFI_ID1}     1
${QFI_ID2}    2
${QFI_ID3}    3
${TRF_ID1}    1
${TRF_ID2}    2
${Q_O_ADD1}    1
${Q_O_ADD2}    2
${Q_O_ADD3}    3
${Q_O_ADD4}    4
${SCFC}=              ${CURDIR}/config/SBTS24R3/slice_xnho.xml
${AP_XML}=            ${CURDIR}/config/xnho_iphy.xml
${epc_log_path}    /tmp/
${XnHo_success}     rrcReconfigurationComplete
*** Test Cases ***
[1][1.0] CNI121217_CB013052-A_B3_TC7_Graceful_handling_during_Inter-gNB_Xn_based_handover_for_SA
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log     cprt
    Configure mrl
    configure mrl override     311:489
#    Start_Dcap_Ipcapture
    wts_sim_keywords.MultiUE Register should be Successful And Fetch RNTI with RAT1    1    1    pdu_id=1    nw_id=1
    Sleep    2s
    ${path1}    Stop Log      cprt      test_scenario=ue_register
    set test variable    ${path1}    ${path1}
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps     dl_rate=5     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    1    Traffic_rate=mbps     ul_rate=5      pdu_id=1    trf_id=1       qfi_id=1
    Sleep    10s
    Start Log    cprt
    Make emergency call    ${4}    ${1}
    Trigger VONR custom data    ${4}    ul    1    1    2    kbps   25.1    custom
    Trigger VONR custom data    ${4}    dl    1    1    2    kbps   25.1    custom
    sleep    60s
    validate traffic for ue1 and ue4

    Trigger XnHO from real to simulator     4       1       52      311:489|0x01
    ${cprt_log}     Stop Log  cprt  test_scenario=UE_${4}_${1}_eme_ho_real_to_sim
    set test variable    ${cprt_log}    ${cprt_log}
    Start Log     cprt
    Trigger XnHO from simulator to real     4       2       50      311:489|0x01
    ${path2}    Stop Log      cprt      test_scenario=UE_${4}_${1}_eme_ho_sim_to_real
    set test variable    ${path2}    ${path2}
    setup 2 pdu session with supported slice id for ue1 and send data
    Start Log     cprt
    Trigger XnHO from real to simulator     1       1       52      311:489|0x01
    ${path3}    Stop Log      cprt      test_scenario=ho_real_to_sim
    set test variable    ${path3}    ${path3}
    sleep   5s
    Start Log     cprt
    Trigger XnHO from simulator to real     1       2       50      311:489|0x01
    ${path4}    Stop Log      cprt      test_scenario=ho_sim_to_real
    set test variable    ${path4}    ${path4}
    sleep     60s
    validate traffic for ue1 and ue4

    configure mrl override     311:490
    Start Log     cprt
    wts_sim_keywords.MultiUE Register should be Successful And Fetch RNTI with RAT1    2    2    pdu_id=1    nw_id=2
    Sleep    2s
    ${path5}    Stop Log      cprt      test_scenario=ue_register_2
    set test variable    ${path5}    ${path5}
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    2    2    Traffic_rate=mbps     dl_rate=5     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    2    2    Traffic_rate=mbps     ul_rate=5      pdu_id=1    trf_id=1       qfi_id=1
    Sleep    10s
    Start Log     cprt
    setup 3 pdu session with unsupported slice id for ue2 and send data
    ${path8}    Stop Log      cprt      test_scenario=ue_2_pdu_2
    set test variable    ${path8}    ${path8}
    Make emergency call    ${5}    ${1}
    Trigger VONR custom data    ${5}    ul    1    1    2    kbps   25.1    custom
    Trigger VONR custom data    ${5}    dl    1    1    2    kbps   25.1    custom
    sleep    60s
    validate traffic for ue2 and ue5
    Start Log     cprt
    Trigger XnHO from real to simulator     5       1       52      311:490|0x01
    ${path6}    Stop Log      cprt      test_scenario=ue_5_1_eme_ho_real_to_sim
    set test variable    ${path6}    ${path6}
    Start Log     cprt
    Trigger XnHO from simulator to real     5       2       50      311:490|0x01
    ${path7}    Stop Log      cprt      test_scenario=ho_sim_to_real_2
    set test variable    ${path7}    ${path7}
    Start Log     cprt
    Trigger XnHO from real to simulator     2       1       52      311:490|0x01
    ${path9}    Stop Log      cprt      test_scenario=ho_real_to_sim_2
    set test variable    ${path9}    ${path9}
    sleep   5s
    Start Log     cprt
    Trigger XnHO from simulator to real     2       2       50      311:490|0x01
    ${path10}    Stop Log      cprt      test_scenario=ho_sim_to_real_2
    set test variable    ${path10}    ${path10}
    sleep    60s
    validate traffic for ue2 and ue5
    configure mrl override     311:491
    Start Log     cprt
    wts_sim_keywords.MultiUE Register should be Successful And Fetch RNTI with RAT1    3    3    pdu_id=1    nw_id=3
    Sleep    2s
    ${path11}    Stop Log      cprt      test_scenario=ue_register_3
    set test variable    ${path11}    ${path11}
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5      pdu_id=1    trf_id=1       qfi_id=1
    Sleep    10s
    Start Log     cprt
    setup 1 pdu session with supported and 3 with unsupported slice id for ue3 and send data
    ${path12}    Stop Log      cprt      test_scenario=ue3_pdu3
    Start Log     cprt

    Trigger XnHO from real to simulator     3       1       52      311:490|0x01
    ${path13}    Stop Log      cprt      test_scenario=ho_real_to_sim_3
    sleep   5s
    Start Log     cprt
    Trigger XnHO from simulator to real     3       2       50      311:490|0x01
    ${path14}    Stop Log      cprt      test_scenario=ho_sim_to_real_3
    sleep    60s
    validate traffic for ue3

    Make emergency call    ${6}    ${1}
    Trigger VONR custom data    ${6}    ul    1    1    2    kbps   25.1    custom
    Trigger VONR custom data    ${6}    dl    1    1    2    kbps   25.1    custom
    sleep     60s
    wts_sim_keywords.Validate DL Traffic For SA    ${6}    0.025    1    2
    wts_sim_keywords.Validate UL Traffic For SA    ${6}    0.025    1    2
    Start Log     cprt
    Trigger XnHO from real to simulator     6       1       52      311:490|0x01
    ${path15}    Stop Log      cprt      test_scenario=ho_real_to_sim_3
    sleep   5s
    Start Log     cprt
    Trigger XnHO from simulator to real     6       2       50      311:490|0x01
    ${path16}    Stop Log      cprt      test_scenario=ho_sim_to_real_3
#    Stop_and_Collect_Dcap_IpCapture			${LOG_PATH}
    wts_sim_keywords.Validate DL Traffic For SA    ${6}    0.025    1    2
    wts_sim_keywords.Validate UL Traffic For SA    ${6}    0.025    1    2
    verify pcap messages from log
#    verify_pcmd_traces_on_tce     pcap_filepath=${LOG_PATH}     pcap_file=ipCapture.pcap  pdml_file=ipCapture_pcmd.pdml
    ${Counters}    Create Dictionary     ${SLICE_FALLBACK_SUC}=${18}
    ...     ${NRRCC_RRC_STPREQ_EMERGENCY}=${3}    ${NRRCC_RRC_STPSUCC_EMERGENCY}=${3}    ${NG_FLOW_I_HO_SUC_SLI_FBK_PMQAP}=${12}
    ...     ${NG_FLOW_STP_SUC_SLI_FBK_PMQAP}=${12}
    Wait until the next Measurement Period starts
    sleep    300s
    Verify Counters modi   ${Counters}    NRCELL-1


*** Keywords ***
verify pcap messages from log
    Verify message custom    ${path1}[cprt]//NODECPRT_GNB.pcap    e1ap.nG_RAN_BearerContextSetupRequest      e1ap    d143a5    1
    Verify message custom    ${cprt_log}[cprt]/NODECPRT_GNB.pcap    e1ap.nG_RAN_BearerContextSetupRequest      e1ap    d143a5    1
    Verify message custom    ${path2}[cprt]/NODECPRT_GNB.pcap    e1ap.nG_RAN_BearerContextSetupRequest      e1ap    d143a5    1
    Verify message custom    ${path3}[cprt]/NODECPRT_GNB.pcap     xnap.HandoverRequest_element      xnap    d143a5    1    ic=${1}
    Verify message custom    ${path4}[cprt]/NODECPRT_GNB.pcap    xnap.HandoverRequest_element      xnap    d143a5    1    ic=${1}
    Verify message custom    ${path5}[cprt]/NODECPRT_GNB.pcap    e1ap.nG_RAN_BearerContextSetupRequest      e1ap    2    1
    Verify message custom    ${path8}[cprt]/NODECPRT_GNB.pcap    e1ap.sD      e1ap    2    1
    Verify message custom    ${path6}[cprt]/NODECPRT_GNB.pcap    xnap.HandoverRequest_element      xnap    f    1    ic=${1}
    Verify message custom    ${path7}[cprt]/NODECPRT_GNB.pcap    xnap.HandoverRequest_element      xnap    2    1    ic=${1}    sd2=${1}
    ...    sd3=${1}    sd4=${1}
    Verify message custom    ${path9}[cprt]/NODECPRT_GNB.pcap    xnap.HandoverRequest_element      xnap    2    1    ic=${1}    sd2=${1}
    ...    sd3=${1}    sd4=${1}
    Verify message custom    ${path10}[cprt]/NODECPRT_GNB.pcap    xnap.HandoverRequest_element      xnap    2    1    ic=${1}    sd2=${1}
    ...    sd3=${1}    sd4=${1}
    Verify message custom    ${path11}[cprt]/NODECPRT_GNB.pcap    e1ap.sD      e1ap    3    1

validate traffic for ue3
    wts_sim_keywords.Validate DL Traffic For SA    ${3}    5    1    1
    wts_sim_keywords.Validate UL Traffic For SA    ${3}    5    1    1
    wts_sim_keywords.Validate DL Traffic For SA    ${3}    5    2    1
    wts_sim_keywords.Validate UL Traffic For SA    ${3}    5    2    1
    wts_sim_keywords.Validate DL Traffic For SA    ${3}    5    3    1
    wts_sim_keywords.Validate UL Traffic For SA    ${3}    5    3    1
    wts_sim_keywords.Validate DL Traffic For SA    ${3}    5    4    1
    wts_sim_keywords.Validate UL Traffic For SA    ${3}    5    4    1
    wts_sim_keywords.Validate DL Traffic For SA    ${3}    5    5    1
    wts_sim_keywords.Validate UL Traffic For SA    ${3}    5    5    1

validate traffic for ue2 and ue5
    wts_sim_keywords.Validate DL Traffic For SA    ${2}    5    1    1
    wts_sim_keywords.Validate UL Traffic For SA    ${2}    5    1    1
    wts_sim_keywords.Validate DL Traffic For SA    ${2}    5    2    1
    wts_sim_keywords.Validate UL Traffic For SA    ${2}    5    2    1
    wts_sim_keywords.Validate DL Traffic For SA    ${2}    5    3    1
    wts_sim_keywords.Validate UL Traffic For SA    ${2}    5    3    1
    wts_sim_keywords.Validate DL Traffic For SA    ${2}    5    4    1
    wts_sim_keywords.Validate UL Traffic For SA    ${2}    5    4    1
    wts_sim_keywords.Validate DL Traffic For SA    ${5}    0.025    1    2
    wts_sim_keywords.Validate UL Traffic For SA    ${5}    0.025    1    2
validate traffic for ue1 and ue4
    wts_sim_keywords.Validate DL Traffic For SA    ${1}    5    1    1
    wts_sim_keywords.Validate UL Traffic For SA    ${1}    5    1    1
    wts_sim_keywords.Validate DL Traffic For SA    ${4}    0.0251    1    2
    wts_sim_keywords.Validate UL Traffic For SA    ${4}    0.0251    1    2
Verify message all_files
    [Arguments]     ${file_list}
    FOR    ${file}  IN RANGE    @{file_list}
        Verify message custom     ${file}[cprt]/NODECPRT_GNB.pcap    e1ap.nG_RAN_BearerContextSetupRequest      e1ap
    END
Make emergency call
    [Arguments]    ${ue_id}    ${pdu_id}    ${ics_wo_pdu}=${-1}
    ${Initial_context_setup_pattern}    setvariable if    ${ics_wo_pdu}==${1}
    ...      Pdu Session Resource Setup Response Message with RAN UE NGAP ID    ${Initial_context_setup_pattern}
    ute_wtssim.execute_egate_command    cmd=ue_param id=${ue_id} nr_usage_setting=voice_centric
    ute_wtssim.execute_egate_command    cmd=amf_param id=1 ims_voice_3gpp=On
    ute_wtssim.execute_egate_command    cmd=ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    ute_wtssim.execute_egate_command    cmd=qosflow_modify qos_flow=1 priority=1
    ute_wtssim.execute_egate_command    cmd=qosflow_modify qos_flow=2 priority=1
    ute_wtssim.execute_egate_command    cmd=smf_param id=1 additional_qosflows_to_activate=2
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${cmd}        Set variable    ue_register id=${ue_id} registration_type=EmergencyRegistration
    ${output}  ute_wtssim.Execute Egate Command And Wait For Data  ${cmd}
	...		pass_regexp=(\?\:${UE_register_complete_pattern})        timeout=10s
#    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    ${gw_id}     Evaluate    ${ue_id}+${pdu_id}
    ${gw_id}     Set variable if    ${1}==${pdu_id}   ${pdu_id}    ${gw_id}

#    ute_wtssim.execute_egate_command     cmd=u
#    ...
#    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    ${tmp_var}    set variable     request_type=initial-emergency-request
    ${pdu_setup_cmd2}	SET VARIABLE	ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice_ID}[${ue_id}] gw=${gw_id} ${tmp_var}

    ${output2}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd2}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s

	ute_wtssim.execute_egate_command    cmd=smf_param id=1 reset



setup 2 pdu session with supported slice id for ue1 and send data
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=1 pdu=2 trf_type=internal
     ${pdu_setup_cmd1}	SET VARIABLE	ue_pdu_session_setup pdu=2 gw=4 ue=1 nwslice=1
    ${output1}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd1}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=1 pdu=3 trf_type=internal
    ${pdu_setup_cmd2}	SET VARIABLE	ue_pdu_session_setup pdu=3 gw=5 ue=1 nwslice=1
    ${output2}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd2}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps     dl_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    1    Traffic_rate=mbps     ul_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps     dl_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    1    Traffic_rate=mbps     ul_rate=5     pdu_id=3    trf_id=1       qfi_id=1
setup 3 pdu session with unsupported slice id for ue2 and send data
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=2 pdu=2 trf_type=internal
     ${pdu_setup_cmd1}	SET VARIABLE	ue_pdu_session_setup pdu=2 gw=6 ue=2 nwslice=15
    ${output1}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd1}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=2 pdu=3 trf_type=internal
    ${pdu_setup_cmd2}	SET VARIABLE	ue_pdu_session_setup pdu=3 gw=7 ue=2 nwslice=15
    ${output2}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd2}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=2 pdu=4 trf_type=internal
      ${pdu_setup_cmd3}	SET VARIABLE	ue_pdu_session_setup pdu=4 gw=8 ue=2 nwslice=15
    ${output3}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd3}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    2    2    Traffic_rate=mbps     dl_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    2    2    Traffic_rate=mbps     ul_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    2    2    Traffic_rate=mbps     dl_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    2    2    Traffic_rate=mbps     ul_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    2    2    Traffic_rate=mbps     dl_rate=5     pdu_id=4    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    2    2    Traffic_rate=mbps     ul_rate=5     pdu_id=4    trf_id=1       qfi_id=1
setup 1 pdu session with supported and 3 with unsupported slice id for ue3 and send data
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=3 pdu=2 trf_type=internal
    ${pdu_setup_cmd1}	SET VARIABLE	ue_pdu_session_setup pdu=2 gw=9 ue=3 nwslice=16
    ${output1}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd1}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=3 pdu=3 trf_type=internal
    ${pdu_setup_cmd2}	SET VARIABLE	ue_pdu_session_setup pdu=3 gw=10 ue=3 nwslice=16
    ${output2}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd2}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=3 pdu=4 trf_type=internal
    ${pdu_setup_cmd3}	SET VARIABLE	ue_pdu_session_setup pdu=4 gw=11 ue=3 nwslice=16
    ${output3}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd3}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=3 pdu=5 trf_type=internal
    ${pdu_setup_cmd4}	SET VARIABLE	ue_pdu_session_setup pdu=5 gw=12 ue=3 nwslice=6
    ${output4}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd4}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=4    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=4    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=5    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=5    trf_id=1       qfi_id=1
Trigger XnHO from real to simulator
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}     ${nrcgi}
    ${history}     SET VARIABLE    ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=medium nrcgi=${nrcgi} time_ue_stayed_in_cell=100
    ute_wtssim.execute_egate_command    ${history}
    ute_wtssim.execute_egate_command    cmd=ue_history_information_list action=commit id=1
    ute_wtssim.execute_egate_command    cmd=ue_enb_param id=${ue_id} ue_history_list=1
    ute_wtssim.execute_egate_command    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${tmp2}    set variable    nrsrp_nr=30 nrsrq_nr=20
    ${msr}      SET VARIABLE    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=1 srsrq_nr=1 phycell_id=${phycell_id} ${tmp2}
    ute_wtssim.Execute Egate Command And Wait For Data      ${msr}     pass_regexp=${XnHo_success}      timeout=30s
Configure mrl
    ${reset}    SET VARIABLE    amf_mobility_restriction_list_param reset id=1
    ute_wtssim.execute_egate_command    ${reset}
    ${msr}     SET VARIABLE      amf_mobility_restriction_list_param id=1 sa_plmn=311:489 sa_plmn=311:490 sa_plmn=311:491
    ute_wtssim.execute_egate_command        ${msr}
    ${set_mrl}      SET VARIABLE      amf_ue_ics_param id=1 ue=all mobility_restriction_list_id=1
    ${cmd1}     SET VARIABLE    trace_activation=on trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=1 trace_depth=minimum
	${cmd2}		SET VARIABLE	ifaces_to_trace=E1,F1-C,Uu,Xn-C,NG-C tce_ip=10.0.1.1 core_network_assistance_info=on ue_identity_index_value=1
	${cmd3}		SET VARIABLE	ue_specific_drx=64 periodic_registration_update_timer=1:1min plmn_id=311:489 tac_id=200
    ute_wtssim.execute_egate_command    ${set_mrl} ${cmd1} ${cmd2} ${cmd3}
configure mrl override
    [Arguments]     ${plmn}
    ute_wtssim.execute_egate_command        cmd=gnb_param id=3 ignore_MRL_during_HO=on mrl_override_serving_plmn=${plmn}
Trigger XnHO from simulator to real
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}     ${nrcgi}

    ${history}     SET VARIABLE      ue_history_information_list_add_ngran id=2 gnb_id=2 cell_type=medium nrcgi=${nrcgi} time_ue_stayed_in_cell=100
    ute_wtssim.execute_egate_command    ${history}
    ute_wtssim.execute_egate_command    cmd=ue_history_information_list action=commit id=2
    ute_wtssim.execute_egate_command    cmd=ue_enb_param id=${ue_id} ue_history_list=2
    ute_wtssim.execute_egate_command    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${tmp2}    set variable    nrsrp_nr=30 nrsrq_nr=20
    ${msr}      SET VARIABLE    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=1 srsrq_nr=1 phycell_id=${phycell_id} ${tmp2}
    ute_wtssim.Execute Egate Command And Wait For Data      ${msr}     pass_regexp=${XnHo_success}      timeout=30s

Add routes
    [Documentation]    This keyword is to configure VM interfaces..
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.99/24 dev eth3
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.3/24 dev eth3
    Run    sudo ip addr add 10.0.1.4/24 dev eth3
    Run    sudo ip addr add 10.0.1.61/24 dev eth3
    Run    sudo ip addr add 10.0.1.62/24 dev eth3
    Run    sudo ip addr add 10.0.1.138/24 dev eth3
    Run    sudo ip addr add 10.0.1.139/24 dev eth3
    Run    sudo ip addr add 10.0.1.140/24 dev eth3
    Run    sudo ip addr add 10.0.1.141/24 dev eth3
Trigger VONR custom data
	[Arguments]    ${ue_id}     ${dir}		${pdu_id}     ${trf_id}		${qfi}		${Traffic_unit}		${traffic_rate}		${rtp_codec}
    [Documentation]    This keyword starts the vonr data
    Log to Console    \nRunning Traffic
	${data_cmd}	SET VARIABLE	trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=${dir} trf_id=${trf_id} rtp_codec=${rtp_codec}
    ute_wtssim.Execute Egate Command And Wait For Data		${data_cmd}		timeout=${EGATE_COMMAND_TIMEOUT}

Update_tce_ip_in_delta_file
    [Arguments]     ${file_path}
    ${command}     Set Variable     sudo ifconfig eth0|awk -F "[ :]+" 'NR==2 {print $3}'
    ${eth0_ip}      Run     ${command}
    ${content}=    OperatingSystem.Get File    path=${file_path}
    ${content}=    String.Replace String Using Regexp    string=${content}    pattern=TCE_VM_IP    replace_with=${eth0_ip}
	Set Global Variable			${eth0_ip}		${eth0_ip}
    OperatingSystem.Create File    path=${file_path}    content=${content}

Verify_pcmd_traces_on_tce
    [Arguments]    ${pcap_filepath}     ${pcap_file}    ${pdml_file}
    Extract_trace_message_from_pcap_on_tce_port     pcap_filepath=${pcap_filepath}    pcap_file=${pcap_file}    pdml_file=${pdml_file}
	...		filter="nsetapx.data == 0"
    ${attrib_value}    analyzer.get_shownames        pdmlFile=${pcap_filepath}/${pdmlFile}
    ...                                                packetName=nsetapx.pduSessionResourceInfoRecord
    ...                                                path=nsetapx.result
    ...                                                endPacket=-${1}
    Should contain Match      ${attrib_value}     *defaultSnssaiFallback*
    Should Contain X Times      ${attrib_value}     result: defaultSnssaiFallback (3)   18

Extract_trace_message_from_pcap_on_tce_port
    [Arguments]    ${pcap_filepath}     ${filter}   ${pcap_file}    ${pdml_file}
    ${options}  Set variable  -o ntrstr.defragment:TRUE -o ntrstr.port:49148
    ${result}    Run    tshark ${options} -Y ${filter} -r ${pcap_filepath}/${pcap_file} -T pdml > ${pcap_filepath}/${pdml_file}
