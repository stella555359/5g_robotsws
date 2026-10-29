*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Malgorzata Konior  <malgorzata.konior@nokia.com>
...      -
...      -
...      == MAINTAINER ==
...

Resource     ../../resources/KRK/Robot/common_settings.robot
Resource     ../../resources/KRK/Robot/verifiers.robot
#Resource     ../../resources/yaml_config_paths.robot
Library      ../../resources/KRK/Python/utilities.py
Library      ../../resources/KRK/Python/mock_stop_egate.py
Library      taf.ul.ue.sim.env_setup

*** Variables ***
${rb_scs15_bw5}=  25
${rb_scs15_bw10}=  52
${rb_scs15_bw15}=  79
${rb_scs15_bw20}=  106
${rb_scs15_bw25}=  133
${rb_scs15_bw30}=  160
${rb_scs15_bw40}=  216
${rb_scs15_bw50}=  270

${loc_and_bw_scs15_bw5}=  6600
${loc_and_bw_scs15_bw10}=  14025
${loc_and_bw_scs15_bw15}=  21450
${loc_and_bw_scs15_bw20}=  28875
${loc_and_bw_scs15_bw25}=  36300
${loc_and_bw_scs15_bw30}=  32174
${loc_and_bw_scs15_bw40}=  16774
${loc_and_bw_scs15_bw50}=  1924

${rb_scs30_bw5}=  11
${rb_scs30_bw10}=  24
${rb_scs30_bw15}=  38
${rb_scs30_bw20}=  51
${rb_scs30_bw25}=  65
${rb_scs30_bw30}=  78
${rb_scs30_bw40}=  106
${rb_scs30_bw50}=  133
${rb_scs30_bw60}=  162
${rb_scs30_bw70}=  189
${rb_scs30_bw80}=  217
${rb_scs30_bw90}=  245
${rb_scs30_bw100}=  273

${loc_and_bw_scs30_bw5}=  2750
${loc_and_bw_scs30_bw10}=  6325
${loc_and_bw_scs30_bw15}=  10175
${loc_and_bw_scs30_bw20}=  13750
${loc_and_bw_scs30_bw25}=  17600
${loc_and_bw_scs30_bw30}=  21175
${loc_and_bw_scs30_bw40}=  28875
${loc_and_bw_scs30_bw50}=  36300
${loc_and_bw_scs30_bw60}=  31624
${loc_and_bw_scs30_bw70}=  24199
${loc_and_bw_scs30_bw80}=  16499
${loc_and_bw_scs30_bw90}=  8799
${loc_and_bw_scs30_bw100}=  1099

*** Keywords ***
Prepare test suite
    [Arguments]    ${ute_ca}=${False}

    Run Keyword if  ${ute_ca} != ${False}
    ...    Prepare Full TL with config files

    Add 5GC    config=${LUA_CFG}    edaemon_ports=10000
    Configure environment    rmod_detection_timeout=420s
    Setup egate  egate_port=20000  alias=default
    Setup all devices aliases
    Reliable emss setup         bts_id=1

Setup all devices aliases
    Create Ues alias    alias=UE  id_type=wts_5g
    Create ENB device with alias 'eNB1' identified by ip=10.0.1.21
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Run VRAN setup
    [Arguments]   ${VRAN_CU_setup}    ${VRAN_DU_setup}    ${iphy_xml}
    Log To Console    Setup started
    Setup VRAN devices aliases
    Setup VRAN libraries
    Send CU delta commissioning   input_filepath=${VRAN_CU_setup}
    Send DU delta commissioning   input_filepath=${VRAN_DU_setup}
#    Setup egate  egate_port=20000  alias=default
    VRAN Upload AirPhone XML And Reboot    ${iphy_xml}
    Reach OnAir in VRAN with retries   lua_cfg=${LUA_CFG}

Prepare Full TL with config files
     Log To Console    Configure ENV with SCFC/AP.xml/LUA
     Add gNB configuration    scfc=${SCFC}
     Add simulator    sim_type=airphone    config=${AP_XML}
     Configure environment    rmod_detection_timeout=420s
     Log To Console    After Configure ENV

Prepare test environment B001
    Wait until PM counters file is ready and saved

Cleanup after test B001
    Deregister UE5

Configure cells to support ENDC
    Execute egate command   cmd=enb_cell_param enb=1 id=1 allow_endc=on

Attach UE${ue_id:\d+} to NRCELL-${cell_id:\d+}
    Expect RRC setup messages flow for UE${ue_id} during UE Attach prcedure
    Expect NGAP messages flow for UE${ue_id} during UE Attach prcedure
    Expect RRC Reconfiguration flow with PCell configuration for UE${ue_id}
    Expect RRC Reconfiguration flow with sCellToAddModList for UE${ue_id}
    sleep  2s

    Execute egate command  cmd=ue_location_change id=${ue_id} enb=2 cell=${cell_id}
    Execute egate command
    ...    cmd=ue_register id=${ue_id}
    ...    pass_regexp=UE${ue_id}: UE performed Registration type INITIAL_REGISTRATION
    sleep  2s
    Execute egate command
    ...    cmd=set_pdu_param ue=${ue_id} pdu=${ue_id} trf_type=internal
    sleep  2s
    Execute egate command
    ...   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${ue_id} nwslice=1
    ...   pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session

Expect NGAP messages flow for UE${ue_id:\d+} during UE Attach prcedure
    Expect Message Flow
    ...     AMF1:NGAP_InitialUEMessage as InitalMessage
    ...     AMF1:NGAP_InitialContextSetupRequest as ICS_Req
    ...     AMF1:NGAP_InitialContextSetupResponse
    ...     alias=UE${ue_id}_NGAP_attach
    ...     overall_timeout=30

Expect RRC setup messages flow for UE${ue_id:\d+} during UE Attach prcedure
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCSetupRequest as RRCSetup
    ...     UE_${ue_id}:NR-RRC_RRCSetup
    ...     UE_${ue_id}:NR-RRC_RRCSetupComplete
    ...     alias=UE${ue_id}_RRC_attach
    ...     overall_timeout=30

Expect RRC Reconfiguration flow with sCellToAddModList for UE${ue_id:\d+}
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration (sCellToAddModList is present) as RRCReconfScellAdd
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_Reconfiguration_SCell_Add
    ...     overall_timeout=30

Expect RRC Reconfiguration flow with sCellToReleaseList for UE${ue_id:\d+}
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration (sCellToReleaseList is present) as RRCReconfScellAdd
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_Reconfiguration_SCell_Release
    ...     overall_timeout=30

Expect RRC Reconfiguration flow with PCell configuration for UE${ue_id:\d+}
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration (spCellConfigDedicated is present) as PCellConfiguration
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_Reconfiguration_PCell
    ...     overall_timeout=30

Verify that Initial Context Setup with NRCELL-${cell_id:\d+} with ${bwp:(small|large)} BWP profile was successful for UE${ue_id:\d+}
    Flow occurred as expected   alias=UE${ue_id}_RRC_attach
    Flow occurred as expected   alias=UE${ue_id}_NGAP_attach

    Verify that NRCELL-${cell_id} with ${bwp} BWP is configured as PCell for UE${ue_id}

Verify that Initial Context Setup with NRCELL-${cell_id:\d+} with only one BWP profile was successful for UE${ue_id:\d+}
    Log to console   ${cell_id}
    Flow occurred as expected   alias=UE${ue_id}_RRC_attach
    Flow occurred as expected   alias=UE${ue_id}_NGAP_attach
    Flow occurred as expected   alias=UE${ue_id}_RRC_Reconfiguration_PCell

Verify that NRCELL-${cell_id:\d+} with ${bwp:(small|large)} BWP is configured as PCell for UE${ue_id:\d+}
    Flow occurred as expected   alias=UE${ue_id}_RRC_Reconfiguration_PCell
    verify that message fulfills query  (
    ...                                   spCellConfigDedicated contains (
    ...                                      downlinkBWP-ToAddModList contains (
    ...                                         locationAndBandwidth eq ${NRCELL_${cell_id}_${bwp}_bwp}[1]
    ...                                         )
    ...                                     )
    ...                                 )
    ...    message_alias=PCellConfiguration
    ...    flow_alias=UE${ue_id}_RRC_Reconfiguration_PCell

Verify that after HO NRCELL-${cell_id:\d+} with ${bwp:(small|large)} BWP is configured as PCell for UE${ue_id:\d+}
    Flow occurred as expected   alias=UE${ue_id}_RRC_Reconfiguration_PCell
    verify that message fulfills query  (
    ...                                   (downlinkChannelBW-PerSCS-List contains (
    ...                                         carrierBandwidth eq ${NRCELL_${cell_id}_${bwp}_bwp}[0]
    ...                                         )
    ...                                     )
    ...                              and  (uplinkChannelBW-PerSCS-List contains (
    ...                                         carrierBandwidth eq ${NRCELL_${cell_id}_${bwp}_bwp}[0]
    ...                                         )
    ...                                     )
    ...                                 )
    ...    message_alias=PCellConfiguration
    ...    flow_alias=UE${ue_id}_RRC_Reconfiguration_PCell

Verify that Scell Addition of NRCELL-${cell_id:\d+} with ${bwp:(small|large)} BWP profile is completed for UE${ue_id:\d+}
    Flow occurred as expected   alias=UE${ue_id}_RRC_Reconfiguration_SCell_Add
    verify that message fulfills query
    ...                                    (sCellToAddModList contains (
    ...                                    (
    ...                                       sCellConfigDedicated contains (
    ...                                          locationAndBandwidth eq ${NRCELL_${cell_id}_${bwp}_bwp}[1]
    ...                                         )
    ...                                     )
    ...                                 and (
    ...                                       downlinkConfigCommon contains (
    ...                                          carrierBandwidth eq ${NRCELL_${cell_id}_${bwp}_bwp}[0]
    ...                                         )
    ...                                     )
    ...                                   ))
    ...    message_alias=RRCReconfScellAdd
    ...    flow_alias=UE${ue_id}_RRC_Reconfiguration_SCell_Add

Deregister UE${ue_id:\d+}
    Execute egate command
    ...    cmd=ue_deregister id=${UE_ID} ue_deregister_type=switch_off
    ...    pass_regexp=UE${UE_ID}: detached
    Sleep  2s

Setup X2 link between enb${enb_id:\d+} and gNB${gnb_id:\d+}
    Execute egate command  cmd=enb_endc_param id=1 serving_cell_index_range_scg=8:14
    Expect message flow
    ...    eNB1:X2AP_ENDCX2SetupRequest
    ...    eNB1:X2AP_ENDCX2SetupResponse
    ...    alias=EN-DC_X2_setup
    ...    overall_timeout=30
    Execute egate command  cmd=enb_x2_link_up enb=${enb_id} target=${gnb_id}
    Flow occurred as expected   alias=EN-DC_X2_setup

Prepare test environment B002
    Setup X2 link between enb1 and gNB2
    Wait until PM counters file is ready and saved

Prepare VRAN test environment B002
    Setup X2 link between enb1 and gNB2
    Wait until DU PM counters file is ready and saved

Expect ENDC flow for UE${ue_id:\d+} with gNB${gnb_id:\d+}
    Log to console   ${gnb_id}
    Expect message flow
    ...    eNB1:X2AP_SgNBAdditionRequest as addReq
    ...    eNB1:X2AP_SgNBAdditionRequestAcknowledge as SgnbAddAck
    ...    eNB1:X2AP_SgNBReconfigurationComplete as ReconfCmp
    ...    eNB1:X2AP_SNStatusTransfer
    ...    alias=UE_${ue_id}_EN-DC
    ...    overall_timeout=30

Verify that blind SgNB Addition of gNB${gnb_id:\d+} NRCELL-${cell_id:\d+} is successfully completed for UE${ue_id:\d+}
    Expect ENDC flow for UE${ue_id} with gNB${gnb_id}
    sleep  3
    Execute egate command  cmd=ue_dc_enb_start ue=${ue_id} target_gnb=${gnb_id} target_cells=${cell_id} bearer=2 type=split_scg
    Flow occurred as expected   alias=UE_${ue_id}_EN-DC
    sleep  10

Verify that UE${ue_id:\d+} connects to NRCELL-${cell_id:\d+} PSCell with ${bwp:(small|large)} BWP profile
    verify that message fulfills query  ( spCellConfig contains (
    ...                                   (spCellConfigDedicated contains (
    ...                                        (downlinkBWP-ToAddModList contains (locationAndBandwidth eq ${NRCELL_${cell_id}_${bwp}_bwp}[1]))
    ...                                         and
    ...                                        (uplinkBWP-ToAddModList contains (locationAndBandwidth eq ${NRCELL_${cell_id}_${bwp}_bwp}[1]))
    ...                                    ))
    ...                                   and
    ...                                   (spCellConfigCommon contains (
    ...                                        (downlinkConfigCommon contains (carrierBandwidth eq ${NRCELL_${cell_id}_${bwp}_bwp}[0]))
    ...                                        and
    ...                                        (uplinkConfigCommon contains (carrierBandwidth eq ${NRCELL_${cell_id}_${bwp}_bwp}[0]))
    ...                                    ))
    ...                                 ))
    ...    message_alias=SgnbAddAck
    ...    flow_alias=UE_${ue_id}_EN-DC

Verify that NRCELL-${cell_id:\d+} SCell is configured with ${bwp:(small|large)} BWP profile for UE${ue_id:\d+}
    verify that message fulfills query
    ...                                    (sCellToAddModList contains (
    ...                                    (
    ...                                       sCellConfigDedicated contains (
    ...                                          locationAndBandwidth eq ${NRCELL_${cell_id}_${bwp}_bwp}[1]
    ...                                         )
    ...                                     )
    ...                                 and (
    ...                                       downlinkConfigCommon contains (
    ...                                          carrierBandwidth eq ${NRCELL_${cell_id}_${bwp}_bwp}[0]
    ...                                         )
    ...                                     )
    ...                                   ))
    ...    message_alias=SgnbAddAck
    ...    flow_alias=UE_${ue_id}_EN-DC

Verify that ${counter_id} ${counter_name} counter is equal ${value:\d+} in NRCELL-${cell_id:\d+} in gNB2
    Verify Last Counters In File
    ...    ${counter_id}
    ...    ${value}
    ...    ${counter_name}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    ...    file_path=${PM_COUNTERS}

Cleanup after test B002
    Detach UE1 from sim eNB
    Detach UE2 from sim eNB

Detach UE${ue_id:\d+} from sim eNB
    Execute egate command  cmd=detach_ue id=${ue_id}

Prepare test environment B101
    Wait until PM counters file is ready and saved
    Execute egate command
    ...    cmd=ue_history_information_list_add_ngran id=5 gnb_id=3 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command  cmd=ue_history_information_list id=5 action=commit
    Execute egate command  cmd=ue_enb_param id=5 ue_history_list=5
    Execute egate command  cmd=ue_history_information_list id=5

Cleanup after test B101
    Deregister UE5
    Execute egate command   cmd=ue_history_information_list id=5 action=reset


Attach UE${ue_id:\d+} to simulated gNB${gnb_id:\d+} NRCELL-${cell_id:\d+}
    Execute egate command  cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Execute egate command  cmd=ue_register id=${ue_id}
    sleep  2s
    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=${ue_id} trf_type=internal
    sleep  2s
    Execute egate command  cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${ue_id} nwslice=1
    sleep  5

Trigger Inter-gNB HO to gnb${gnb_id:\d+} NRCELL-${cell_id:\d+} for UE${ue_id:\d+}
    Expect Inter-gNB HO for UE5

    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=3
    sleep  2
    Execute egate command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=19 event=A5 srsrp_nr=18 phycell_id=${gnb${gnb_id}_cell_${cell_id}_phycell_id} nrsrp_nr=127

Verify that HO to NRCELL-${cell_id:\d+} was successful for UE${ue_id:\d+}
    Flow occurred as expected   alias=UE${ue_id}_XNAP_Handover
    Log to console   ${cell_id}

Trigger Intra-gNB HO to gNB${gnb_id:\d+} NRCELL-${cell_id:\d+} for UE${ue_id:\d+}
    execute egate command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=8 event=A5 srsrp_nr=18 phycell_id=${gnb${gnb_id}_cell_${cell_id}_phycell_id} nrsrp_nr=127

Prepare test environment B102
    Wait until PM counters file is ready and saved
    Setup X2 link between enb1 and gNB2
    Execute egate command   cmd=enb_cell_param enb=1 id=1 allow_endc=on
    Execute egate command   cmd=enb_cell_param enb=1 id=2 allow_endc=on
    Execute egate command   cmd=ue_enb_endc_param id=1 candidate_cells_mn_hex_for_menb_ho=09096f2821a8

Cleanup after test B102
    Detach UE1 from sim eNB

Expect Inter-gNB HO for UE${ue_id}
    Expect Message Flow
    ...     gNB2:XNAP_HandoverRequest
    ...     gNB2:XNAP_HandoverRequestAcknowledge
    ...     alias=UE${ue_id}_XNAP_Handover   overall_timeout=15

Trigger Inter-MeNB HO to eNB${enb_id:\d+} CELL-${cell_id:\d+} for UE${ue_id:\d+} to trigger SgNBModification with NRCELL-3 as PSCell Candidate
    Expect SgNBModification flow for UE${ue_id} with eNB${enb_id}
    Execute egate command   cmd=ue_enb_endc_param id=${ue_id} candidate_cells_mn_hex_for_menb_ho=09096f2821a8
    Execute egate command   cmd=ue_ho id=${ue_id} enb=${enb_id} cell=${cell_id}

Verify that ${counter_id} ${counter_name} counter is in range ${range_low_bound} - ${range_high_bound} in NRCELL-${cell_id:\d+} in gNB2
    ${range_low_bound}=   Evaluate    ${range_low_bound} - ${1}
    ${range_high_bound}=   Evaluate    ${range_high_bound} + ${1}

    Verify Last Counters In File
    ...    ${counter_id}  > ${range_low_bound}  ${counter_name}
    ...    ${counter_id}  < ${range_high_bound}  ${counter_name}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    ...    file_path=${PM_COUNTERS}

Verify that no SCell is configured for UE${ue_id:\d+}
    verify that message fulfills query  (sCellToAddModList is not present)
    ...    message_alias=SgnbAddAck
    ...    flow_alias=UE_${ue_id}_EN-DC

Expect SgNBModification flow for UE${ue_id:\d+} with eNB${enb_id:\d+}
    Expect message flow
    ...    eNB${enb_id}:X2AP_SgNBModificationRequest as SgnbModReq
    ...    eNB${enb_id}:X2AP_SgNBModificationRequestAcknowledge as SgnbModReqAck
    ...    eNB${enb_id}:X2AP_SgNBReconfigurationComplete
    ...    alias=UE${ue_id}_SgNBModification  overall_timeout=30

Verify that SgNB sends SgNBModificationRequestAcknowledge for UE${ue_id:\d+}
    Flow occurred as expected   alias=UE${ue_id}_SgNBModification

Verify that PSCellChange is triggered for UE${ue_id:\d+}, new PScell is NRCELL-${cell_id:\d+} with ${bwp:(small|large)} BWP profile
    verify that message fulfills query  ( spCellConfig contains (
    ...                                   (spCellConfigDedicated contains (
    ...                                        (downlinkBWP-ToAddModList contains (locationAndBandwidth eq ${NRCELL_${cell_id}_${bwp}_bwp}[1]))
    ...                                         and
    ...                                        (uplinkBWP-ToAddModList contains (locationAndBandwidth eq ${NRCELL_${cell_id}_${bwp}_bwp}[1]))
    ...                                    ))
    ...                                   and
    ...                                   (spCellConfigCommon contains (
    ...                                        (downlinkConfigCommon contains (carrierBandwidth eq ${NRCELL_${cell_id}_${bwp}_bwp}[0]))
    ...                                        and
    ...                                        (uplinkConfigCommon contains (carrierBandwidth eq ${NRCELL_${cell_id}_${bwp}_bwp}[0]))
    ...                                    ))
    ...                                 ))
    ...    message_alias=SgnbModReqAck
    ...    flow_alias=UE${ue_id}_SgNBModification

Verify that after PSCellChange NRCELL-${cell_id:\d+} SCell is configured with ${bwp:(small|large)} BWP profile for UE${ue_id:\d+}
    verify that message fulfills query
    ...                                    (sCellToAddModList contains (
    ...                                    (
    ...                                       sCellConfigDedicated contains (
    ...                                          locationAndBandwidth eq ${NRCELL_${cell_id}_${bwp}_bwp}[1]
    ...                                         )
    ...                                     )
    ...                                 and (
    ...                                       downlinkConfigCommon contains (
    ...                                          carrierBandwidth eq ${NRCELL_${cell_id}_${bwp}_bwp}[0]
    ...                                         )
    ...                                     )
    ...                                   ))
    ...    message_alias=SgnbModReqAck
    ...    flow_alias=UE${ue_id}_SgNBModification


Verify that Scells NRCELL-1, NRCELL-2 are released for UE${ue_id:\d+}
    Flow occurred as expected   alias=UE${ue_id}_RRC_Reconfiguration_SCell_Release

Verify that Scell NRCELL-${cell_id:\d+} is not configured for UE${ue_id:\d+}
    Flow occurred as expected   alias=UE${ue_id}_RRC_Reconfiguration_SCell_Add
    verify that message fulfills query  (physCellId ne 5${cell_id})
    ...    message_alias=RRCReconfScellAdd
    ...    flow_alias=UE${ue_id}_RRC_Reconfiguration_SCell_Add

Wait ${seconds:\d+}s for noticeable counters incrementation
    sleep  ${seconds}

Verify that A1 measurement was installed for UE${ue_id}
     verify that message fulfills query  (
    ...                                   eventId contains ("eventA1")
    ...                                 )
    ...    message_alias=PCellConfiguration
    ...    flow_alias=UE${ue_id}_RRC_Reconfiguration_PCell

Expect A1 measurement for UE${ue_id}
    Expect Message Flow
    ...    UE_${ue_id}:NR-RRC_MeasurementReport
    ...    alias=A1_meas_UE_${ue_id}
    ...    overall_timeout=30

Verify that A1 measurement was sent for UE${ue_id}
    Flow occurred as expected  alias=A1_meas_UE_${ue_id}

Set NRCELL-${cell_id} ${parameter} to ${value}
    Perform Parameter Commissioning
    ...    dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    ...    parameter=${parameter}
    ...    value=${value}

Cleanup after test B301
    Detach and kill UEs from 1 to 6
    ${default_bcs_settings}  catenate      {'MOC':'NRCELL', 'ID':'1', 'allowUnsuppBcOrBcs':'[accept unknown BCSs]'},
    ...                    {'MOC':'NRBTS', 'ID':'1', 'rejectSuppBcs':'none', 'actBcsCheck':'enabled_FR1'}
    Configure  [${default_bcs_settings}]
    Discover bts    bts_id=1

Set gNB to perform complete BCS check and reject BCS4 for NRCELL-1
    Configure  [{'MOC':'NRCELL', 'ID':'1', 'allowUnsuppBcOrBcs':'[complete BCS check]'}, {'MOC':'NRBTS', 'ID':'1', 'rejectSuppBcs':'BCS4'}]
    Discover bts    bts_id=1

Set VRAN gNB to perform complete BCS check and reject BCS4 for NRCELL-1
    vcu.Connect to  host=${vCU_admin}  port=443  username=Nemuadmin  password=Nokia@123  secure=True
    Send CU delta commissioning   input_filepath=${CURDIR}/../config/VRAN/CU_complete_BCS_check_reject_BCS4.json
    Send DU delta commissioning   input_filepath=${CURDIR}/../config/VRAN/DU_complete_BCS_check_reject_BCS4.json

Set NRBTS-1 ${parameter} to ${value}
    Perform Parameter Commissioning    parameter=${parameter}  value=${value}

Run test setup
    Log To Console    Setup started
    Check radios availability
    Sleep  1
    Reach Onair    lua_cfg=${LUA_CFG}
    Setup devices aliases
