*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Konrad Bem <konrad.bem@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../resources/KRK/Robot/common_settings.robot
Resource    ./CB010544_msg_verifiers.robot
Library     ../../resources/KRK/Python/traffic_verify.py

Library     ta5g_cell_operations
Library      ../../resources/KRK/Python/mock_stop_egate.py
Library     taf.sbts.oam.coam.admin      WITH NAME    coam
Library     taf.ul.ue.sim.env_setup
Library     rrc_reconf_searchspacetoaddmodlist_verifier.py

*** Variables ***
${ADMIN_CONNECTION}=  admin_connection

*** Keywords ***
Run Setup
    [Arguments]    ${ute_ca}=${False}    ${internal_mirroring}=${False}

    Log To Console    Setup started
    Run Keyword if  ${ute_ca} != ${False}
    ...    Prepare TL with config files

    ${run_update}    get variable value      ${configure}    "True"     # do not ever change that line!
    Run Keyword if  ${run_update} != ${False}
    ...    Reach onAir state
    Run Keyword if  ${rtpm} != ${False}
    ...    Activate RTPM counters

    Setup egate  egate_port=20000  alias=default
    Setup devices aliases
    Reliable emss setup         bts_id=1
    Setup connection to admin  ${ADMIN_CONNECTION}

    Run Keyword if  ${internal_mirroring} != ${False}
    ...    Enable internal mirroring for alias  gNB2

Reach onAir state
    Add 5GC    config=${LUA_CFG}    edaemon_ports=10000
    Configure environment    rmod_detection_timeout=420s
    Log To Console    After Reach OnAir
    Do not stop egate and daemon

Prepare TL with config files
     Log To Console    Configure ENV with SCFC/AP.xml/LUA
     Add gNB configuration    scfc=${SCF}
     Add simulator    sim_type=airphone    config=${AP_XML}
     Configure environment    rmod_detection_timeout=420s
     Log To Console    After Configure ENV

Setup devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create ENB device with alias 'eNB1' identified by ip=10.0.1.21
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.30
    Create GNB device with alias 'gNB3_XN' identified by ip=10.0.1.31
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Activate RTPM counters
    RTPM activate
    Configure  [{'MOC': 'NRPMRNL', 'ID': '1', 'nrRTPMMeasurementsList': '[55305 NR Beamforming,55351 NR Dynamic BWP]'}]

Run Suite Teardown
    Teardown connection to admin

Wait for ${time}s ${rest_of_kw_name}
    sleep  ${time}
    log to console  ${rest_of_kw_name}

Block NRCELL-${cell_id:\d+}
    coam.block_cell   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=${100}  connection=${ADMIN_CONNECTION}
    sleep   3

Unblock NRCELL-${cell_id:\d+}
    coam.unblock_cell   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=${100}  connection=${ADMIN_CONNECTION}
    sleep   3

Lock NRCELL-${cell_id:\d+}
    coam.lock   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=${100}  connection=${ADMIN_CONNECTION}

Unlock NRCELL-${cell_id:\d+}
    coam.unlock   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=${100}  connection=${ADMIN_CONNECTION}

Reset NRCELL-${cell_id:\d+}
    coam.reset_cell    cell_id=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=${100}  connection=${ADMIN_CONNECTION}

Reset RMOD-${rmod_id:\d+}
    coam.reset_unit    dist_name=MRBTS-1/EQM-1/APEQM-1/RMOD-${rmod_id}    force_radio_reset=${True}
    ...    timeout=${300}    connection=${ADMIN_CONNECTION}

Reset RAT-${rat_type:NR|LTE|WCDMA|GSM}
    coam.rat_reset    rat_type=${rat_type}  timeout=${300}  connection=${ADMIN_CONNECTION}

Reset gNb
    coam.reset_site    timeout=${300}  connection=${ADMIN_CONNECTION}

Run ${traffic_rate:\d+}kbps ${direction:(UL|DL)} traffic on UE${ue_id:\d+} PDU${pdu_id:\d+} QFI${qfi_id:\d+} and wait ${seconds:\d+} seconds
    ${dir_param}    Convert To Lowercase    ${direction}
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${dir_param} kbps=${traffic_rate}
    ...  pass_regexp=Started .* Internal traffic
    Sleep  ${seconds}

Run small ${direction:(UL|DL)} traffic on UE${ue_id:\d+} and wait ${seconds:\d+} seconds and verify change to PS-BWP
    ${dir_param}    Convert To Lowercase    ${direction}
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=${dir_param} kbps=100
    ...  pass_regexp=Started .* Internal traffic (.|\n)* Bwp Switched from bwpId 1 to 2
    Sleep  ${seconds}

Run bigger ${direction:(UL|DL)} traffic on UE${ue_id:\d+} and wait ${seconds:\d+} seconds and verify change to dedicated BWP
    ${dir_param}    Convert To Lowercase    ${direction}
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=${dir_param} mbps=5
    ...  pass_regexp=Started .* Internal traffic (.|\n)* Bwp Switched from bwpId 2 to 1
    Sleep  ${seconds}

Run ${direction:(UL|DL)} traffic to switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE${ue_id:\d+}
    Run bigger ${direction} traffic on UE${ue_id} and wait 0 seconds and verify change to dedicated BWP
    Run small ${direction} traffic on UE${ue_id} and wait 5 seconds and verify change to PS-BWP
    Wait Until Keyword Succeeds    10s    2s    Verify 100kbps ${direction} traffic on PDU-1 QFI-1 for UE${ue_id}

Run ${direction:(UL|DL)} traffic to switch to PS-BWP then run bigger traffic to switch to dedicated for UE${ue_id:\d+}
    Run small ${direction} traffic on UE${ue_id} and wait 0 seconds and verify change to PS-BWP
    Run bigger ${direction} traffic on UE${ue_id} and wait 5 seconds and verify change to dedicated BWP
    Wait Until Keyword Succeeds    10s    2s    Verify 5Mbps ${direction} traffic on PDU-1 QFI-1 for UE${ue_id}

Run ${direction:(UL|DL)} small traffic then run bigger traffic to switch to dedicated for UE${ue_id:\d+}
    ${dir_param}    Convert To Lowercase    ${direction}
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=${dir_param} kbps=100
    Run bigger ${direction} traffic on UE${ue_id} and wait 5 seconds and verify change to dedicated BWP
    Wait Until Keyword Succeeds    10s    2s    Verify 5Mbps ${direction} traffic on PDU-1 QFI-1 for UE${ue_id}

Run ${traffic_rate:\d+}kbps UL and DL traffic on UE${ue_id:\d+} PDU${pdu_id:\d+} QFI${qfi_id:\d+} and wait ${seconds:\d+} seconds
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul kbps=${traffic_rate}
    ...  pass_regexp=Started Uplink Internal traffic
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl kbps=${traffic_rate}
    ...  pass_regexp=Started Downlink Internal traffic
    Sleep  ${seconds}
    log to console  ${traffic_rate:\d+}

Stop ${traffic_rate:\d+}kbps ${direction:(UL|DL)} traffic on UE${ue_id:\d+} PDU${pdu_id:\d+} QFI${qfi_id:\d+}
    ${dir_param}    Convert To Lowercase    ${direction}
    Execute egate command
    ...  cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${dir_param}
    ...  pass_regexp=Stop.* Internal traffic on Ue
    log to console  ${traffic_rate:\d+}

Verify ${traffic_rate:\d+}kbps ${direction:(UL|DL)} traffic on PDU-${pdu_id:\d+} QFI-${qfi_id:\d+} for UE${ue_id:\d+}
    ${traffic_rate_in_kbps}=    Evaluate    ${traffic_rate} * 1000
    traffic_verify.verify_qfi_traffic    ${traffic_rate_in_kbps}    ${ue_id}    ${pdu_id}    ${qfi_id}    ${direction}

Verify ${traffic_rate:\d+}kbps UL and DL traffic on PDU-${pdu_id:\d+} QFI-${qfi_id:\d+} for UE${ue_id:\d+}
    ${traffic_rate_in_kbps}=    Evaluate    ${traffic_rate} * 1000
    traffic_verify.verify_qfi_traffic    ${traffic_rate_in_kbps}    ${ue_id}    ${pdu_id}    ${qfi_id}    ul
    traffic_verify.verify_qfi_traffic    ${traffic_rate_in_kbps}    ${ue_id}    ${pdu_id}    ${qfi_id}    dl

Attach UE${ue_id:\d+} to simulated gNB${enb_id:\d+} CELL-${cell_id:\d+} with inter gNB Handover setup and PDU session set
    Set up inter gNB Handover for UE${ue_id}

    Execute egate command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute egate command    cmd=ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute egate command    cmd=ue_register id=${ue_id}
    ...  pass_regexp=Received REGISTRATION COMPLETE
    Execute egate command    cmd=ue_pdu_session_setup pdu=1 ue=${ue_id}
    ...    pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=1 using PDU Gateway ID=
    sleep    3

UE${ue_id:\d+} triggers successful XN HO from simulated gNB3 CELL-${src} to real gNB2 NRCELL-${trg} with meas_id=${meas_id}
    EXPECT FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 XNAP sNStatusTransfer
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: AMF1 NGAP pathSwitchRequest
    log to console  ${trg}
    UE${ue_id} triggers Inter-gNB Handover from simulated gNB3 to real gNB2 by sending A3 measurement id=${meas_id}

    PASS FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 XNAP sNStatusTransfer
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    PASS FLOW[timeout=10]: AMF1 NGAP pathSwitchRequest
    log to console  ${src}

UE${ue_id:\d+} triggers successful XN HO with RRC Reestablishment from simulated gNB3 CELL-1 to real gNB2 NRCELL-1
    EXPECT FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 XNAP sNStatusTransfer
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: AMF1 NGAP pathSwitchRequest
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup

    Execute egate command
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish gnb=2 cell=1 cause=handoverFailure crnti=source
    ...    nth=1 num_reestablishment_reqs=1
    Sleep  1
    Execute egate command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=18 phycell_id=50 nrsrp_nr=85
    Sleep  1

    PASS FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 XNAP sNStatusTransfer
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    PASS FLOW[timeout=10]: AMF1 NGAP pathSwitchRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup


UE${ue_id:\d+} triggers successful NG HO with RRC Reestablishment from simulated gNB3 CELL-1 to real gNB2 NRCELL-1
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverPreparation
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverResourceAllocation
    EXPECT FLOW[timeout=10]: AMF1 NGAP uplinkRANStatusTransfer
    EXPECT FLOW[timeout=10]: AMF1 NGAP downlinkRANStatusTransfer
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverNotification
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup

    Execute egate command
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish gnb=2 cell=1 cause=handoverFailure crnti=source
    ...    nth=1 num_reestablishment_reqs=1
    Sleep  1
    Execute egate command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=18 phycell_id=50 nrsrp_nr=85
    Sleep  1

    PASS FLOW[timeout=10]: AMF1 NGAP handoverPreparation
    PASS FLOW[timeout=10]: AMF1 NGAP handoverResourceAllocation
    PASS FLOW[timeout=10]: AMF1 NGAP uplinkRANStatusTransfer
    PASS FLOW[timeout=10]: AMF1 NGAP downlinkRANStatusTransfer
    PASS FLOW[timeout=10]: AMF1 NGAP handoverNotification
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup


Wait ${timeout}s for cells [${cells_ids}] ${cellState} change to ${expected_states}
    [Documentation]
    ...  Possible cellState values to check in file:
    ...  testsuite/Krakow/RRM/resources/Python/admin_cli.py
    ...  For example: energySavingState | availabilityStatus | operationalState | administrativeState

    Wait Until Keyword Succeeds  ${timeout}s  5s
    ...  Check for cells [${cells_ids}] if ${cellState} equals ${expected_states}

Activate CB010544 feature flag in NRCELL-${cell_id}
    Set NRCELL-${cell_id}.actInitialBWPFlexibility to True
    Wait 30s for cells [${cell_id}] operationalState change to [enabled]

Deactivate CB010544 feature flag in NRCELL-${cell_id}
    Set NRCELL-${cell_id}.actInitialBWPFlexibility to False
    Wait 30s for cells [${cell_id}] operationalState change to [enabled]

Set ${MO}-${MO_id}.${parameter} to ${value}
    Configure  {'MOC': '${MO}', 'ID': '${MO_id}', '${parameter}': '${value}'}

Change ${MO1}-${MO_id1}.${parameter1} to ${value1} and ${MO2}-${MO_id2}.${parameter2} to ${value2}
    ${config}    Catenate    [{'MOC': '${MO1}', 'ID': '${MO_id1}', '${parameter1}': '${value1}'},
    ...                       {'MOC': '${MO2}', 'ID': '${MO_id2}', '${parameter2}': '${value2}'}]
    Configure    ${config}

Attach UE${ue_id} to gNB2 NRCELL-${cell_id} and verify that UE is configured with PS-BWP with RACH setup in PS-BWP
    #Attach UE from lib
    Attach UE${ue_id} to gNB2 CELL${cell_id} with ICS during PDU session setup
    #Verify PS-BWP and RACH is present
    Verify that UE${ue_id} is configured with PS-BWP after ICS
    Verify that RACH config setup is present in PS-BWP for UE${ue_id}
    Wait for 5s to stabilize AP

Attach UE${ue_id} to gNB2 NRCELL-${cell_id} and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP
    #Attach UE from lib
    Attach UE${ue_id} to gNB2 CELL${cell_id} with ICS during PDU session setup
    #Verify PS-BWP and RACH is not present
    Verify that UE${ue_id} is configured with PS-BWP after ICS
    Verify that RACH config is not present in PS-BWP for UE${ue_id}
    Wait for 5s to stabilize AP

Attach UE${ue_id:\d+} to gNB2 cell${cell_id:\d+} with ICS during PDU session setup and SCell configuration
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: UE_${ue_id} NR-RRC RRCSetup
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP initialContextSetup
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP uERadioCapabilityInfoIndication
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: UE_${ue_id} NR-RRC UECapabilityInformation

    Run keyword and continue on failure
    ...     Attach UE${ue_id} without ICS to gNB2 cell${cell_id}

    #Add PDU session part
    EXPECT FLOW[timeout=3]: AMF1 NGAP pDUSessionResourceSetup - messages not occur due to ICS with PDU session setup
    # Catchin 2*RRCReconfiguration, RRCReconfiguration_1 is for PCell and RRCReconfiguration_2 is for SCell
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration

    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Run keyword and continue on failure
    ...     Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=1 ue=${ue_id}
    ...     pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=1 using PDU Gateway ID

    FAIL FLOW[timeout=3]: AMF1 NGAP pDUSessionResourceSetup - messages not occur due to ICS with PDU session setup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    #End PDU session part

    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: UE_${ue_id} NR-RRC RRCSetup
    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP initialContextSetup
    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: UE_${ue_id} NR-RRC UECapabilityInformation


Attach UE${ue_id} to gNB2 NRCELL-${cell_id} and verify that UE is configured with PS-BWP without RACH and SCell configuration with small BWP
    #Attach UE from lib with 2*RRC Reconfiguration for SCell configuration
    Attach UE${ue_id} to gNB2 cell${cell_id} with ICS during PDU session setup and SCell configuration
    #Verify PS-BWP and RACH is not present in PCell
    Verify that UE${ue_id} is configured with PS-BWP after ICS in PCell
    Verify that RACH config is not present in PS-BWP for UE${ue_id} in PCell
    #Verify SCell addition and small BWP in SCell
    Verify in 2 out of 2 RRCReconfiguration that UE${ue_id} is configured with SCell NRCELL-2 small BWP
    Wait for 5s to stabilize AP

Beamforming (${number_of_beams:\d+} beams): Attach UE${ue_id} to gNB2 NRCELL-${cell_id} and verify that UE is configured with PS-BWP without RACH
    #Attach UE from lib
    Attach UE${ue_id} to gNB2 CELL${cell_id} with ICS during PDU session setup
    #Verify PS-BWP and RACH is not present
    Beamforming (${number_of_beams} beams): Verify that UE${ue_id} is configured with PS-BWP after ICS
    Verify that RACH config is not present in PS-BWP for UE${ue_id}
    Wait for 5s to stabilize AP

Beamforming (${number_of_beams:\d+} beams): Attach UE${ue_id} to gNB2 NRCELL-${cell_id} and verify that UE is configured with PS-BWP with RACH
    #Attach UE from lib
    Attach UE${ue_id} to gNB2 CELL${cell_id} with ICS during PDU session setup
    #Verify PS-BWP and RACH is not present
    Beamforming (${number_of_beams} beams): Verify that UE${ue_id} is configured with PS-BWP after ICS
    Verify that RACH config setup is present in PS-BWP for UE${ue_id}
    Wait for 5s to stabilize AP

Beamforming (${number_of_beams:\d+} beams): Attach UE${ue_id} to gNB2 NRCELL-${cell_id} and verify that UE is configured only with large BWP
    #Attach UE from lib
    Attach UE${ue_id} to gNB2 CELL${cell_id} with ICS during PDU session setup
    #Verify large PS-BWP
    Beamforming (${number_of_beams} beams): Verify that UE${ue_id} is configured only with large BWP after ICS
    Wait for 5s to stabilize AP

Attach UE${ue_id} to gNB2 NRCELL-${cell_id} and verify that UE is configured only with large BWP
    #Attach UE from lib
    Attach UE${ue_id} to gNB2 CELL${cell_id} with ICS during PDU session setup
    #Verify large PS-BWP
    Verify that UE${ue_id} is configured only with large BWP after ICS
    Wait for 5s to stabilize AP

Perform intra-frequency intra-gNB HO from gNB${gnb_id} cell${src_cell} to cell${tgt_cell} for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport triggering intra-gNB HO
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: gNB${gnb_id} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: gNB${gnb_id} F1AP uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration with target cell configuration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    Run keyword and continue on failure
    ...     UE${ue_id} triggers Intra-gNB Handover from gNB2 cell${src_cell} to cell${tgt_cell} by sending A3 measurement

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport triggering intra-gNB HO
    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: gNB${gnb_id} E1AP 2*bearerContextModification
    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: gNB${gnb_id} F1AP uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration with target cell configuration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Perform intra-gNB HO from gNB2 cell${src} to cell${trg} for UE${ue_id} and verify that UE is configured with PS-BWP with RACH setup in PS-BWP
    #Intra HO UE from lib
    Perform intra-frequency intra-gNB HO from gNB2 cell${src} to cell${trg} for UE${ue_id}
    #Verify PS-BWP and RACH is present
    #Verify that UE${ue_id} is configured with PS-BWP after ICS
    Verify that UE${ue_id} is configured with PS-BWP after intra GNB HO
    #Verify that RACH setup is present
    Verify that RACH config setup is present in PS-BWP for UE${ue_id}

Perform intra-gNB HO from gNB2 cell${src} to cell${trg} for UE${ue_id} and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP
    #Intra HO UE from lib
    Perform intra-frequency intra-gNB HO from gNB2 cell${src} to cell${trg} for UE${ue_id}
    #Verify PS-BWP and RACH is present
    #Verify that UE${ue_id} is configured with PS-BWP after ICS
    Verify that UE${ue_id} is configured with PS-BWP after intra GNB HO
    #Verify that RACH is not present
    Verify that RACH config is not present in PS-BWP for UE${ue_id}

Perform intra-gNB HO from gNB2 cell${src} to cell${trg} for UE${ue_id} and verify that UE is configured with PS-BWP with RACH release in PS-BWP
    #Intra HO UE from lib
    Perform intra-frequency intra-gNB HO from gNB2 cell${src} to cell${trg} for UE${ue_id}
    #Verify PS-BWP and RACH is present
    Verify that UE${ue_id} is configured with PS-BWP after intra GNB HO
    #Verify that RACH release is present
    Verify that RACH config release is present in PS-BWP for UE${ue_id}
    Verify that RACH config setup is present in UEContextModificationRequest and release in UEContextModificationResponse for UE${ue_id}

Perform intra-gNB HO from gNB2 cell${src} to cell${trg} for UE${ue_id} and verify that UE is configured only with large BWP
    #Intra HO UE from lib
    Perform intra-frequency intra-gNB HO from gNB2 cell${src} to cell${trg} for UE${ue_id}
    #Verify large PS-BWP
    Verify that UE${ue_id} is configured only with large BWP after intra gNB HO

Perform XN HO from gNB3 cell${src} to gNB2 cell${trg} for UE${ue_id} and verify that UE is configured with PS-BWP with RACH setup in PS-BWP
    #XN HO UE from lib
    UE${ue_id} triggers successful XN HO from simulated gNB3 CELL-${src} to real gNB2 NRCELL-${trg} with meas_id=3
    #Verify PS-BWP and RACH is present
    Verify that UE${ue_id} is configured with PS-BWP after inter GNB HO
    #Verify that RACH setup is present
    Verify that RACH config setup is present in PS-BWP for UE${ue_id} after inter gNB HO

Perform XN HO from gNB3 cell${src} to gNB2 cell${trg} for UE${ue_id} and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP
    #XN HO UE from lib
    UE${ue_id} triggers successful XN HO from simulated gNB3 CELL-${src} to real gNB2 NRCELL-${trg} with meas_id=3
    #Verify PS-BWP and RACH is not present
    Verify that UE${ue_id} is configured with PS-BWP after inter GNB HO
    #Verify that RACH is not present
    Verify that RACH config is not present in PS-BWP for UE${ue_id} after inter gNB HO

Perform XN HO from gNB3 cell${src} to gNB2 cell${trg} for UE${ue_id} and verify that UE is configured only with large BWP
    #XN HO UE from lib
    UE${ue_id} triggers successful XN HO from simulated gNB3 CELL-${src} to real gNB2 NRCELL-${trg} with meas_id=3
    #Verify large PS-BWP
    Verify that UE${ue_id} is configured only with large BWP after inter GNB HO

Prepare RRC Reestablishment during ${ho_type:(XN|NG)} HO for UE${ue_id} on egate
    Execute egate command
    ...    cmd=gnb_param id=3 ciphering_algorithm=nea0 integrityprotection_algorithm=nia2 srb1_rlc_sn_field_size=size_12

    Sleep    3

    Run Keyword if    '${ho_type}' == 'XN'
    ...    Run keywords
    ...    Execute egate command
    ...      cmd=gnb_xn_handover_preparation_param id=3 include_security_config=true sec_config_nea=nea0 sec_config_nia=nia2 reestab_info=1:valid
    ...    AND    Sleep    3
    ...    AND    Execute egate command
    ...      cmd=gnb_param id=3 sa_ho=xn_based

    Run Keyword if    '${ho_type}' == 'NG'
    ...    Run keywords
    ...    Execute egate command
    ...      cmd=gnb_param id=3 sa_ho=ng_based
    ...    AND    Sleep    3
    ...    AND    Execute egate command
    ...      cmd=ue_gnb_ho_param gnb=3 id=${ue_id} include_security_config=on sec_config_nea=nea0 sec_config_nia=nia2 reestab_info=1:valid

    Sleep    3

Perform RRC Reestablishment during ${ho_type:(XN|NG)} HO for UE${ue_id} and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP
    #XN/NG HO
    Run Keyword if    '${ho_type}' == 'XN'
    ...    UE${ue_id} triggers successful XN HO with RRC Reestablishment from simulated gNB3 CELL-1 to real gNB2 NRCELL-1

    Run Keyword if    '${ho_type}' == 'NG'
    ...    UE${ue_id} triggers successful NG HO with RRC Reestablishment from simulated gNB3 CELL-1 to real gNB2 NRCELL-1

    #Verify PS-BWP and RACH is not present
    Verify that UE${ue_id} is configured with PS-BWP after inter GNB HO
    #Verify searchSpacesToAddModList are present in RRC Reconfiguration
    Verify that UE${ue_id} is configured with searchSpacesToAddModList in RRC RRCReconfiguration
    #Verify that RACH is not present
    Verify that RACH config is not present in PS-BWP for UE${ue_id} after inter gNB HO

Verify that UE${ue_id:\d+} is configured with searchSpacesToAddModList in RRC RRCReconfiguration
    ${flow}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    check_search_spaces_to_add_mod_list_elements_bwp_dedicated_2elements    flow_alias=${flow}    message_alias=RRCReconfiguration

Set Beam Control Testmode profiles for BFR on egate
    Execute egate command
    ...    cmd=beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 csirs_bestbeam=2 csirs_rsrp_best=-44 csirs_rsrp_avg=-50
    Execute egate command
    ...    cmd=beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0 csirs_bestbeam=5 csirs_rsrp_best=-45 csirs_rsrp_avg=-120
    sleep    3

Set Beam Control Testmode profiles for BFR retrigger on egate
    Execute egate command
    ...    cmd=beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    ${cmd}    Catenate    beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,2 ssbeam_bestbeam=2 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
    ...    bfr_post_action=ignore_bfr_contention_resolution_ul_grant_retrigger_bfr num_of_cr_ul_grants_to_ignore=1
    Execute egate command
    ...    cmd=${cmd}

Activate Beam Control Testmode on egate for UE${ue_id}
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0
    sleep    3

Trigger Beam Failure Recovery on egate for UE${ue_id} and expect RRC Reconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextModificationRequired
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment

    ${regexp}    Catenate    Current Active BWP Id 2, Rach Config Common is missing Switching to InitialBwpId for BFR and
    ...    ueInCommonInitialBwp set to 1(.|\\n)* Bwp Switched from bwpId 1 to 2

    Execute Egate command
    ...    cmd=ue_testmode_set_nr id=${ue_id} scell=0 testmode=beam_control beamaction=recovery profile_id=2 action=activate
    ...    pass_regexp=${regexp}
    Sleep   5s

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextModificationRequired
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment

Trigger Beam Failure Recovery on egate for UE${ue_id} ${option:with|without} PS BWP and without RRC Reconfiguration
    ${regexp_bwp_1}    Set Variable    <CONTEXT SETUP> \\[UeId:.*,BwpId:1, pcid:.*, scellIdx:0] configure_0_1
    ${regexp_bwp_1_2}    Catenate    <CONTEXT SETUP> \\[UeId:.*,BwpId:1, pcid:.*, scellIdx:0] configure_0_1 (.|\\n)*
    ...    <CONTEXT SETUP> \\[UeId:.*,BwpId:2, pcid:.*, scellIdx:0] configure_0_1

    ${regexp}    Set Variable If    '${option}' == 'with'
    ...    ${regexp_bwp_1_2}
    ...    ${regexp_bwp_1}

    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment

    Execute Egate command
    ...    cmd=ue_testmode_set_nr id=${ue_id} scell=0 testmode=beam_control beamaction=recovery profile_id=2 action=activate
    ...    pass_regexp=${regexp}
    Sleep   5s

    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment

Set ${ho_type:(XN|NG)} based handover for simulated gNB${gnb_id:\d+}
    Execute egate command    cmd=gnb_param id=${gnb_id} sa_ho=${ho_type}

Set indirect data forwarding for AMF${amf_id:\d+} to ${value:off|on}
    Execute egate command    cmd=amf_param id=${amf_id} intra5gs_data_forwarding=${value}

Set msg1FrequencyStart value to ${msg1_values:\d+} for NRCELL-${cell_id:\d+} and wait for cell to be enabled and not degraded
    Configure  {'MOC': 'NRCELL', 'ID': '${cell_id}', 'msg1FrequencyStart': '${msg1_values}'}
    Wait 30s for cells [${cell_id}] operationalState change to [enabled]
    Wait 30s for cells [${cell_id}] availabilityStatus change to [-]

Trigger RRC Reestablishment for UE${ue_id:\d+} on gNB${gnb_id:\d+} NRCELL-${cell_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease

    Execute egate command    cmd=ue_rrc_reestablish id=${ue_id} gnb=${gnb_id} cell=${cell_id} cause=otherFailure
    Sleep    2s

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease

Trigger RRC Reestablishment for UE${ue_id:\d+} on gNB2 NRCELL-${cell_id:\d+} and verify that UE is configured with PS-BWP and RACH is not present
    Trigger RRC Reestablishment for UE${ue_id} on gNB2 NRCELL-1
    Verify that RACH config is not present in PS-BWP for UE${ue_id}
    log to console  ${cell_id:\d+}

Setup CoreNetworkAssistanceInformationForInactive to be included in InitialContextSetupRequest
    ${command}    Catenate    amf_ue_ics_param id=1 core_network_assistance_info=yes
    ...                       ue_identity_index_value=1 ue_specific_drx=64 periodic_registration_update_timer=1:10min
    ...                       plmn_id=311:489 tac_id=200
    Execute egate command    cmd=${command}

Wait until UE${ue_id:\d+} goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    EXPECT FLOW[timeout=30]: UE_${ue_id} NR-RRC RRCRelease

    PASS FLOW[timeout=30]: UE_${ue_id} NR-RRC RRCRelease

    ${rrc_release}=     Get Flow Name
    ...     RRCRelease
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (suspendConfig is present) and (ran-NotificationAreaInfo is present)
    ...     message_alias=RRCRelease
    ...     flow_alias=${rrc_release}

Trigger RRCResume procedure for UE${ue_id:\d+} by running 100kbps DL traffic towards NRCELL-${cell_id:\d+} and verify change to PS-BWP
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResumeRequest1
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResume
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResumeComplete
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetupRequest
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl kbps=100
    ...  pass_regexp=Bwp Switched from bwpId 1 to 2
    Sleep  5
    log to console  ${cell_id:\d+}

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResumeRequest1
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResume
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResumeComplete
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetupRequest
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease

    ${flow}=     Get Flow Name
    ...     RRCResume
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    verify_rach_config_ps_bwp    flow_alias=${flow}    message_alias=RRCResume    rach_should_be_present=False

Test msg1FreequencyStart value ${msg1_value} in interaction with RRC Reestablishment and RRC Inactive
    Log to console  Testing with value of msg1FrequencyStart set to: ${msg1_value}
    Set msg1FrequencyStart value to ${msg1_value} for NRCELL-1 and wait for cell to be enabled and not degraded

    #Part 1
    Log to console    Part 1: RRC Reestablishment
    Attach UE1 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP
    Run 100kbps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds

    Trigger RRC Reestablishment for UE1 on gNB2 NRCELL-1 and verify that UE is configured with PS-BWP and RACH is not present
    Wait Until Keyword Succeeds    10s    2s    Verify 100kbps UL and DL traffic on PDU-1 QFI-1 for UE1
    Sleep    3

    #Part 2
    Log to console    Part 2: RRC Inactive
    Attach UE2 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP

    Wait until UE2 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    Verify that UE2 state is INACTIVE on Egate

    Trigger RRCResume procedure for UE2 by running 100kbps DL traffic towards NRCELL-1 and verify change to PS-BWP
    Verify that UE2 state is ACTIVE on Egate
    Wait Until Keyword Succeeds    10s    2s    Verify 100kbps DL traffic on PDU-1 QFI-1 for UE2
    Sleep    3

    Trigger UEs from 1 to 2 to send deregister request
