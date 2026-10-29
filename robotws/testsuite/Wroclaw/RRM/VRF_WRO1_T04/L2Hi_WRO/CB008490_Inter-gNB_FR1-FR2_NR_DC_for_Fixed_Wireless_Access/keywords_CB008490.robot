*** Settings ***
Library     ta_messaging
Library     ta_messaging/robot_flow_framework/expect_keyword_listener.py
Resource    ta_messaging/flow.robot
Library     keywords_CB008490.py
Library     syslog_collector.py
Library     ../5GC000774_ROHC/keywords_ROHC.py
Library     ../CB008717_Intra-gNB_FR1-FR2/keywords_CB008717.py
Resource    ../CB008717_Intra-gNB_FR1-FR2/keywords_CB008717.robot
Library     taf.ul.ue.sim.env_setup
Library     taf.ul.ettf.setups
Library     taf.collectors.core   WITH NAME   core
Library     taf.collectors.btslog  WITH NAME   btslog
Library     taf.ccs.aashell   WITH NAME    cli
Library     taf.sbts.oam.coam.admin    WITH NAME    coam

Documentation
...    This file contains general keywords used for testing Feature CB008490.

*** Variables ***
@{REMOTE_HOSTS}=        None
${server_cmd_options_tcp}=    -p 7070 -i 1 -B 10.0.2.1
${client_cmd_options_dl_tcp}=    -c 1.2.4.2 -p 7070 -M 1360 -i 1 -t 3600 -B 10.0.2.1 -w 50M
${iperf_service}=    iperf_service
${iperf_ue_service}=    iperf_ue_1_dl

*** Keywords ***
Prepare Test Environement for Real MN With SN And Reach Onair
    [Arguments]        ${iphy}    ${MN_scf}    ${SN_scf}    ${cfg_filepath}
    Enable Syslog Info Level Prints
    Update Scf And Ap With Real MN And SN    ${iphy}    ${MN_scf}    ${SN_scf}
    Reach Onair    lua_cfg=${cfg_filepath}   remote_hosts=${REMOTE_HOSTS}
    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    Start Collecting Syslog From Gnbs
    Set Internal Traffic Type To UEs

Common Test Teardown CB008490
    Stop Collecting Syslog And Download Files
    Send Configuration ID To Scout
    Stop Default Processes And Gather Logs And Compress Logs
    Check For An Unexpected Alarm

Prepare Test Environement for SimMN And Reach Onair
    Configure VM Interfaces For SimMN
    Update And Put Iphy Xml         input_filepath=${CURDIR}/config/iphy_1c_nrdc_n257_simMN.xml
    Fix And Send Full Commissioning With Given Scf Filepath   scfc_filepath=${CURDIR}/config/SBTS25R3/full_scf_gnb3_SN_nrdc_n257.xml
    Wait for gNB Configured state
    Reach Onair    lua_cfg=${EPCSIM_CFG_PATH_SIM_MN_NRDC_TDD}
    Setup Devices Aliases For SimMN
    Set Internal Traffic Type To UEs
    Wait For Next Full Pm Interval

Prepare Test Environement for SimSN And Reach Onair
    Configure VM Interfaces For SimSN
    Update And Put Iphy Xml         input_filepath=${CURDIR}/config/iphy_1c_nrdc_n78_simSN.xml
    Fix And Send Full Commissioning With Given Scf Filepath   scfc_filepath=${CURDIR}/config/SBTS25R3/full_scf_MN_n78A_AEQE.xml
    Wait for gNB Configured state
    Reach Onair    lua_cfg=${EPCSIM_CFG_PATH_SIM_SN_NRDC_TDD}
    Setup devices aliases simSN
    Set Internal Traffic Type To UEs
    Wait For Next Full Pm Interval

Configure VM Interfaces For SimSN
    Start Vm Ethernet Interface    if_name=eth3:xn    ip_with_mask=10.0.1.7/24
    Start Vm Ethernet Interface    if_name=eth3:ng    ip_with_mask=10.0.1.6/24

Setup devices aliases simSN
    Create UEs alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.6
    Enable internal mirroring for alias  gNB2
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Update Scf And Ap With Real MN And SN
    [Arguments]    ${iphy}    ${MN_scf}    ${SN_scf}
    Update And Put Iphy Xml         input_filepath=${CURDIR}/config/${iphy}
    Fix And Send Full Commissioning With Given Scf Filepath   scfc_filepath=${CURDIR}/config/SBTS25R3/${MN_scf}
    Fix And Send Full Commissioning With Given Scf Filepath   scfc_filepath=${CURDIR}/config/SBTS25R3/${SN_scf}
    ...                                             remote_host=${REMOTE_HOST_1_IP}

Update Scf And Ap For 8CC
    Update And Put Iphy Xml         input_filepath=${CURDIR}/config/iphy_MN_AEQE_SN_AWEUB_8CC.xml
    Find Scfc And Fix And Send Full Commissioning   scfc_filename=full_scf_gnb2_MN_8CC.xml
    Find Scfc And Fix And Send Full Commissioning   scfc_filename=full_scf_gnb3_SN_8CC.xml
    ...                                             remote_host=${REMOTE_HOST_1_IP}

Enable Pdcp Pdu Duplication On Gnb3
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-3_NRDRB-11_actXxDuplicateTx.json
    ...    remote_host=${REMOTE_HOST_1_IP}

Enable Xn Counters
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-3_enable_Xn_counters.json


Trigger Max Rlc Retx
      [Arguments]    ${ue_id}=1
      Execute Egate Command And Wait For Data    cmd=ue_dc_rlf ue=${ue_id} failure_type=rlc_max_num_retx

Set DlPreferredPathNrDc To Secondary On Gnb3
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-3_NRDRB-11_dlPreferredPathNrDc_Secondary.json
    ...    remote_host=${REMOTE_HOST_1_IP}

Set ActDlTxResumeOnPdcpStatRep To True
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-3_NRDRB-all_actDlTxResumeOnPdcpStatRep_true.json
    ...    remote_host=${REMOTE_HOST_1_IP}

Register Nrdc Ue With Default Pdu Session
    [Arguments]    ${ue_id}=1     ${pdu_id}=1    ${gw}=1    ${session_type}=ipv4
    Execute Egate Command And Wait For Data    cmd=ue_register id=${ue_id}
    ...                      pass_regexp=UE${ue_id}: UE performed Registration type INITIAL_REGISTRATION
    ...                      timeout=10
    Execute Egate Command    cmd=amf_ue_ics_param id=1 ue=${ue_id} indexToRFSP=1 include_ue_capabilities=yes ue_capabilities=auto
    Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gw} session_type=${session_type}
    ...                      pass_regexp=UE-${ue_id} PDU SESSION ID-${pdu_id} setup/reestablishment complete
    ...                      timeout=10

Register Multi Nrdc Ues With Default Pdu Session
     FOR    ${index}    IN RANGE    1    5
        Set Internal Traffic Type To UEs    ue_id=${index}
        Register Nrdc Ue With Default Pdu Session    ue_id=${index}     pdu_id=1    gw=${index}
        Send A4 Measurement And Trigger Pscell Addition    ue_id=${index}
        Log    ${index}
        Sleep    3s
     END

Send A4 Measurement And Trigger Pscell Addition
    [Arguments]    ${ue_id}=1
#    Set expected messages flows for SNodeAddition
    Send A4 Measurement    ue_id=${ue_id}
#    Verify expected messages flows for SNodeAddition

Set RD For Mcs
    [Arguments]    ${rd_value}=0x20
    &{hop}=     Create Dictionary    host=${REMOTE_HOST_1_IP}    user=ute
    &{hops}=    Create Dictionary    proxy=${hop}
    cli.create_aashell_cli    name=ash_gnb1
    cli.setup    ash_gnb1
    cli.execute_aashell_command    name=ash_gnb1    command=rad -mpw ${rdSupportedDl64QamMcs} ${rd_value}
    cli.Teardown   ash_gnb1

    cli.create_aashell_cli    name=ash_gnb2    hops=${hops}
    cli.setup    ash_gnb2
    cli.execute_aashell_command    name=ash_gnb2    command=rad -mpw ${rdSupportedDl64QamMcs} ${rd_value}
    cli.Teardown   ash_gnb2

Start Udp Traffic In DL For 4 Ues
    [Arguments]    ${mbps}=30    ${traffic_duration}=2m
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=${mbps} trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=1 dir=dl mbps=${mbps} trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl mbps=${mbps} trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=1 qfi=1 dir=dl mbps=${mbps} trf_id=1
    Sleep    ${traffic_duration}

Start IP Traffic Capturing
    [Arguments]    ${connection}
    log to console            Start IP Traffic Capturing
    Connect with runtime release     ${connection}
    coam.start_ip_capture_file  measurement_point=NE_Terminated    uplane_capturing=True    connection=${connection}


Stop IP Traffic Capturing
    [Arguments]    ${connection}    ${target_file_name}    ${csv_filename}    ${filter}    ${columns}
    log to console            Stop IP Traffic Capturing
    coam.stop_ip_capture_file      connection=${connection}
    coam.generate_ip_capture_file  connection=${connection}
    coam.download_ip_capture_file  connection=${connection}  target_file_name=${target_file_name}
    coam.teardown             ${connection}
    Convert Tshark Pcap To Csv
    ...  pcap_path=${target_file_name}
    ...  filter=${filter}
    ...  columns=${columns}
    ...  csv_log_name=${csv_filename}

Connect with runtime release
    [Arguments]      ${alias}=admin_api
    coam.connect to  name=${alias}
    ${release}=   Wait Until Keyword Succeeds   5 min   1 min   Get Software release name   ${alias}
    coam.teardown    connection=${alias}
    coam.connect_to  name=${alias}             release=${release}

Get Software release name
    [Arguments]   ${alias}
    ${release}       coam.Get sw release name  connection=${alias}
    Should not be empty   ${release}
    [Return]   ${release}

Convert Tshark Pcap To Csv
    [Arguments]    ${pcap_path}    ${filter}    ${columns}    ${dir_path}=${OUTPUT_DIR}    ${csv_log_name}=PCAP_Logs.csv

    Log to console    Filter and Converting Tshark Pcap to csv...

    ${cmd}      catenate    tshark
    ...         -r ${pcap_path}
    ...         -Y "${filter}"
    ...         -T fields -e ${columns}
    ...         -E header=y -E separator=";", -E occurrence=a > ${dir_path}/${csv_log_name}
    ${rc}    OperatingSystem.Run And Return RC    ${cmd}

    Log to console    ...conversion done

    [Return]    ${dir_path}${csv_log_name}

Setup multigNB devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.3
    Enable internal mirroring for alias  gNB2
    Enable internal mirroring for alias  gNB3
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Set expected messages flows for SNodeAddition
    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected not failed messages flows for SNodeAddition for UE1, MN gNB2
    Set expected not failed messages flows for SNodeAddition for SN gNB3

Verify expected messages flows for SNodeAddition
#    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for SN gNB3

Set expected messages flows for SNodeAddition for SN gNB${sn_gnb_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeAdditionPreparation
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP xnUAddressIndication
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeReconfigurationCompletion
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNStatusTransfer
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextInactivityNotification

Verify expected messages flows for SNodeAddition for SN gNB${sn_gnb_id:\d+}
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeAdditionPreparation
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP xnUAddressIndication
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeReconfigurationCompletion
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNStatusTransfer
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextInactivityNotification

Set expected messages flows for SNodeAddition for UE${ue_id:\d+}, MN gNB${mn_gnb_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP 2*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} NGAP pDUSessionResourceModifyIndication

Verify expected messages flows for SNodeAddition for UE${ue_id:\d+}, MN gNB${mn_gnb_id:\d+}
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} E1AP 2*bearerContextModification
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP 2*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} NGAP pDUSessionResourceModifyIndication

Set expected not failed messages flows for SNodeAddition for UE${ue_id:\d+}, MN gNB${mn_gnb_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextModificationFailure
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP errorIndication
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextModificationFailure
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP errorIndication
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP errorIndication
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease

Verify expected not failed messages flows for SNodeAddition for UE${ue_id:\d+}, MN gNB${mn_gnb_id:\d+}
    FAIL FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextModificationFailure
    FAIL FLOW[timeout=10]: gNB${mn_gnb_id} E1AP errorIndication
    FAIL FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextModificationFailure
    FAIL FLOW[timeout=10]: gNB${mn_gnb_id} F1AP errorIndication
    FAIL FLOW[timeout=10]: gNB${mn_gnb_id} XNAP errorIndication
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease

Set expected not failed messages flows for SNodeAddition for SN gNB${sn_gnb_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeAdditionPreparationFailure
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextSetupFailure
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextSetupFailure
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModificationFailure
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP errorIndication
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP errorIndication
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP errorIndication

Verify expected not failed messages flows for SNodeAddition for SN gNB${sn_gnb_id:\d+}
    FAIL FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeAdditionPreparationFailure
    FAIL FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextSetupFailure
    FAIL FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextSetupFailure
    FAIL FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModificationFailure
    FAIL FLOW[timeout=10]: gNB${sn_gnb_id} E1AP errorIndication
    FAIL FLOW[timeout=10]: gNB${sn_gnb_id} F1AP errorIndication
    FAIL FLOW[timeout=10]: gNB${sn_gnb_id} XNAP errorIndication

Set Expected Message Flow For UE Context Release Due To HFN For UE1
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModificationRequired
    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Expect message flow
    ...    gNB2:F1AP_UEContextReleaseCommand (radioNetwork eq 'action-desirable-for-radio-reasons') as UEContextReleaseCommandMNContext
    ...    alias=F1apUeContextReleaseMNContext
    ...    overall_timeout=10
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextRelease

Verify Expected Message Flow For UE Context Release Due To HFN For UE1
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModificationRequired
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Flow occurred as expected       alias=F1apUeContextReleaseMNContext
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextRelease

Set expected message flow for A4 meas inter-gNB PSCell Addition For UE${ue_id:\d+} GNB${gnb_id:\d+} during SN-initiated SNodeMod procedure
    EXPECT FLOW[timeout=60]: gNB${gnb_id} F1AP uEContextModificationRequired
    EXPECT FLOW[timeout=60]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

Verify expected message flow for A4 meas inter-gNB PSCell Addition For UE${ue_id:\d+} GNB${gnb_id:\d+} during SN-initiated SNodeMod procedure
    PASS FLOW[timeout=60]: gNB${gnb_id} F1AP uEContextModificationRequired
    PASS FLOW[timeout=60]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=60]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease

Configure VM Interfaces For SimMN
    Start Vm Ethernet Interface    if_name=eth3:xn    ip_with_mask=10.0.1.2/24
    Start Vm Ethernet Interface    if_name=eth3:ng    ip_with_mask=10.0.1.8/24

Prepare SimMN gNB
    ${prepare_command}=    Catenate
    ...                    gnb_nrdc_param id=2 enable_dl_data_forwarding=off t_reordering=100 serving_cell_index_range_scg_nrdc=1:31
    ...                    direct_bearer_sn_addition_error=off include_candidate_cell_info_list_mn=on include_reestablish_pdcp=on
    ...                    include_data_fwd_info_from_source=on ue_sec_algo_first_bit_reserved=on allowed_bc_list_mrdc=1:1
    ...                    include_cgi_in_candidate_cell_info=off
    Execute Egate Command
    ...    cmd=${prepare_command}

UE Sends A4 Measurement For Inter-gNB NR-DC With Simulated MN GNB
    Prepare SimMN gNB
    Sleep    3s
    Execute Egate Command    cmd=ue_meas_param id=1 nr_neigh_cell=non_cfgd:52 nr_rsrp=127
    Execute Egate Command    cmd=gnb_ue_nrdc_start ue=1 target_gnb=3 target_cells=3 target_pdu_id_list=1
    Sleep    5s

Setup Devices Aliases For SimMN
    Create UEs alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.3
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1
    Enable internal mirroring for alias  gNB3

Verify Message In Syslog
    [Arguments]    ${syslog_file_path}    ${message}
    log to console     Verifying message in syslog
    ${syslog_message} =  run   command=sudo cat ${syslog_file_path} | grep -i "${message}"
    Log to Console    ${syslog_message}
    Should contain    ${syslog_message}     ${message}
    Log to Console    ${message} verified in syslog

Trigger Beamgroup Active
    Execute egate command   cmd=beam_control_testmode_nr profile_id=1 beamType=Analog
    ...    ueBeamIndexInitial=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31 ssbeam_bestbeam=0
    ...    ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    Execute egate command   cmd=beam_control_testmode_nr profile_id=2 beamType=Analog
    ...    ueBeamIndexInitial=8,1,2,3,4,5,6,7,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31 ssbeam_bestbeam=8
    ...    ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
    Execute egate command   cmd=beam_control_testmode_nr profile_id=3 beamType=Analog ueBeamIndexInitial=16,17,18,19,20,21,22,23 ssbeam_bestbeam=23
    ...    ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125
    Execute egate command   cmd=beam_control_testmode_nr profile_id=4 beamType=Analog ueBeamIndexInitial=3,0,1,2,4,5,6,7 ssbeam_bestbeam=3
    ...    ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120
    Execute egate command   cmd=beam_control_testmode_nr profile_id=5 beamType=Analog ueBeamIndexInitial=4,0,1,2,3,5,6,7 ssbeam_bestbeam=4
    ...    ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139
    Execute egate command   cmd=beam_control_testmode_nr profile_id=6 beamType=Analog ueBeamIndexInitial=5,0,1,2,3,4,6,7 ssbeam_bestbeam=5
    ...    ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70
    Execute egate command   cmd=beam_control_testmode_nr profile_id=7 beamType=Analog ueBeamIndexInitial=6,0,1,2,3,4,5,7 ssbeam_bestbeam=6
    ...    ssbeam_rsrp_best=-46 ssbeam_rsrp_avg=-100
    Execute egate command   cmd=beam_control_testmode_nr profile_id=8 beamType=Analog ueBeamIndexInitial=7,0,1,2,3,4,5,6 ssbeam_bestbeam=7
    ...    ssbeam_rsrp_best=-48 ssbeam_rsrp_avg=-100
    sleep    8s    Wait for beam choose
    Execute egate command   cmd=ue_testmode_set_nr id=1 testmode=beam_control action=activate profile_id=1 beamaction=attach

UE Beamgroup Change
    [Arguments]    ${ue_id}=1
    Beam Testmod Set    ue_id=${ue_id}    profile_id=2    Initial=8    bestbeam=8   beamaction=switch
    sleep    8s    Wait for beam switch finished
    Beam Testmod Set    ue_id=${ue_id}    profile_id=3    Initial=16    bestbeam=23    beamaction=switch
    sleep    10s    Wait for beam switch finished

Beam Testmod Set
    [Arguments]    ${ue_id}=1    ${profile_id}=1    ${Initial}=0    ${bestbeam}=0    ${beamaction}=attach
    ${cmd}    catenate    beam_control_testmode_nr profile_id=${profile_id} beamType=Analog ueBeamIndexInitial=${Initial} ssbeam_bestbeam=${bestbeam}
    ...    ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    Execute Egate Command    ${cmd}
    Execute egate command   cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control profile_id=${profile_id}
    ...    action=activate beamaction=${beamaction}

Trigger Beamgroup Deactive
    [Arguments]    ${ue_id}=1
    Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control profile_id=1 action=deactivate
    Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control profile_id=2 action=deactivate
    Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control profile_id=3 action=deactivate

Check Data Traffic On Mcg
    Verify Ue Throughput    ue_id=1    type=pdsch cell_group=MCG   expected_tput=30
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=MCG type=pdsch
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=SCG type=pdsch scell=1
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pusch

Check Data Traffic Before PSCell Addition
    [Arguments]    ${traffic_duration_sec}=2m
    Sleep    ${traffic_duration_sec}
    Check Data Traffic On Mcg

Check Data Traffic After PSCell Addition
    [Arguments]    ${traffic_duration_sec}=10m
    Sleep    ${traffic_duration_sec}
    Check Data Traffic On Mcg
    Check Data Traffic On Scg Leg    expected_tput=80

Check Data Traffic On Scg Leg
    [Arguments]    ${ue_id}=1    ${traffic_duration_sec}=1m    ${expected_throughput}=100
    Sleep    ${traffic_duration_sec}
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=${ue_id} cell_group=SCG type=pdsch scell=1
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=${ue_id} cell_group=SCG type=pusch scell=1
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=${ue_id} pdu=1 qfi=1 dir=dl
    Expected Throughput For Qfi Should Be Reached    ue_id=${ue_id}    pdu_id=1    qfi_id=1
    ...    expected_throughput=${expected_throughput}    unit=mbps    margin=0.2    direction=dl

Check Data Traffic On Mcg And Scg Leg
    [Arguments]    ${ue_id}=1    ${traffic_duration_sec}=1m    ${expected_throughput}=100
    Sleep    ${traffic_duration_sec}
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=${ue_id} cell_group=MCG type=pdsch
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=${ue_id} cell_group=SCG type=pdsch scell=1
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=${ue_id} pdu=1 qfi=1 dir=dl
    Expected Throughput For Qfi Should Be Reached    ue_id=${ue_id}    pdu_id=1    qfi_id=1
    ...    expected_throughput=${expected_throughput}    unit=mbps    margin=0.2    direction=dl

Check Data Traffic On Mcg For Mue
    FOR    ${index}    IN RANGE    1    5
        Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=${index}
        ...    pdu_id=1    qfi_id=1    expected_throughput=10    unit=mbps
        ...    margin=0.1    direction=dl   optional_params=dc_cell_group=mcg
     END

Check Data Traffic On Scg For Mue
    FOR    ${index}    IN RANGE    1    5
        Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=${index}
        ...    pdu_id=1    qfi_id=1    expected_throughput=20    unit=mbps
        ...    margin=0.1    direction=dl   optional_params=dc_cell_group=scg
     END

Set UE UL Data Distribution
    [Arguments]    ${scg_ul_dist_percent}=0
    Execute Egate Command    cmd=uec_param id=1 scg_ul_dist_percent=${scg_ul_dist_percent}

Start Dl Tcp Traffic
    Execute Egate Command    cmd=sim_debug_log level=6
    Prepare Iperf Environment And Start Traffic    server_cmd_options=${server_cmd_options_tcp}
    ...    iperf_service=${iperf_service}    client_cmd_options=${client_cmd_options_dl_tcp}
    ...    iperf_ue_service=${iperf_ue_1_dl}

Start Udp Traffic 300Mbps In DL
    [Arguments]    ${traffic_duration}=1s
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=2
    Sleep    ${traffic_duration}

Start Traffic 450Mbps In DL
    [Arguments]    ${traffic_duration}=1s
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=3
    Sleep    ${traffic_duration}

Start Udp Traffic 110Mbps In DL And UL
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=110
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=110

Verify BeamGroup Change In Syslog
    [Arguments]    ${syslog_path}    ${beam_change_message}
    Verify Message In Syslog    ${syslog_path}    ${beam_change_message}