*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS ==
...      - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...      - Michal Szymakowski <michal.szymakowski@nokia.com>
...      - Maciej Pikula <maciej.pikula@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     ./CplaneOverloadSetter.py
Library     ./SgNBModification_verifiers.py
Library     ./pcmd_verify.py
Resource    ../../../resources/Robot/common_settings.robot
Library     ../../../resources/Python/utilities.py
Library     taf.ul.ue.sim.env_setup

Library     ta_emss

*** Variables ***
${pm_counters_five_minutes_interval}=       ${CURDIR}/../config/SBTS21B/delta_set_collecting_counters_to_five_minutes.json

${delta_281_NSAMeasReject_on}=              ${CURDIR}/../config/yaml/delta_281_NSAMeasReject_on.yaml
${delta_281_ovlNsaAddRej_enabled}=          ${CURDIR}/../config/yaml/delta_281_ovlNsaAddRej_enabled.yaml
${delta_281_ovlNsaLteHoRej_enabled}=        ${CURDIR}/../config/yaml/delta_281_ovlNsaLteHoRej_enabled.yaml
${delta_281_SgNBAddRejection_off}=          ${CURDIR}/../config/yaml/delta_281_SgNBAddRejection_off.yaml
${delta_281_SgNBAddRejection_on}=           ${CURDIR}/../config/yaml/delta_281_SgNBAddRejection_on.yaml
${delta_281_SgNBAddRejection_ovl_all_off}=  ${CURDIR}/../config/yaml/delta_281_SgNBAddRejection_ovl_all_off.yaml
${delta_281_SgNBModification_B3}=           ${CURDIR}/../config/yaml/delta_281_SgNBModification_B3.yaml
${delta_281_SgNBModification_ho_rejected_in_ovl_state_B4}=  ${CURDIR}/../config/yaml/delta_281_SgNBModification_ho_rejected_in_ovl_state_B4.yaml

*** Keywords ***
Prepare TL with config files
    ${scfc_filepath}       Get Variable Value    ${SCFC}
    ${ap_xml_filepath}     Get Variable Value    ${AP_XML}
    Run keyword and ignore error      get_lua_for_topology
    ${lua_filepath}=      get variable value          ${LUA}        ${LUA_CFG}

    Run keyword if    '${scfc_filepath}'!='None'
    ...                Add gNB configuration    scfc=${scfc_filepath}
    Run keyword if    '${ap_xml_filepath}'!='None'
    ...                Add simulator    sim_type=airphone    config=${ap_xml_filepath}
    Run keyword if    '${lua_filepath}'!='None'
    ...                Add 5GC    config=${lua_filepath}    edaemon_ports=10000
    ${run_update}    get variable value      ${configure}    "True"     # do not ever change that line!
    Run Keyword if  ${run_update} != ${False}
    ...    Configure environment    rmod_detection_timeout=420s
    Setup egate  egate_port=20000  alias=default     save_egate=${True}


Prepare test suite for NSA CPLANE Overload Testing
    Run Keywords
    ...  Teardown emss   bts_id=1
    ...  AND   Prepare TL with config files
    ...  AND  Setup emss   bts_id=1
    ...  AND  Send Delta Commissioning  input_filepath=${pm_counters_five_minutes_interval}


Prepare test environment B1
    Create ues alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Enable internal mirroring for alias  gNB2
    Create ENB device with alias 'eNB' identified by ip=10.0.1.21
    UE1 attach to sim_eNB
    UE2 attach to sim_eNB
    UE3 attach to sim_eNB
    Configure    ${delta_281_SgNBAddRejection_on}
    Enable 281 FAF on gNB
    Wait For Next Full Pm Interval

Prepare test environment B2
    Enable 281 FAF on gNB
    Set gNB parameter ovlNsaMeasDiscard to TRUE
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Enable internal mirroring for alias  gNB2
    Create ENB device with alias 'eNB' identified by ip=10.0.1.21
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.31
    Create ues alias    alias=UE   id_type=wts_5g

    Wait For Next Full Pm Interval
    UE1 and UE2 attach to eNB with SCG establishment

Prepare test environment B3
    Create ues alias    alias=UE1   id_type=wts_5g
    Create ues alias    alias=UE2   id_type=wts_5g
    Create ues alias    alias=UE3   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    enable internal mirroring for alias  gNB2
    Create ENB device with alias 'eNB1' identified by ip=10.0.1.21
    Create ENB device with alias 'eNB2' identified by ip=10.0.1.22
    Configure cells to support ENDC
    Wait For Next Full Pm Interval
    Configure    ${delta_281_SgNBModification_B3}

Prepare test environment B4
    Create ues alias    alias=UE1   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    enable internal mirroring for alias  gNB2
    Create ENB device with alias 'eNB1' identified by ip=10.0.1.21
    Create ENB device with alias 'eNB2' identified by ip=10.0.1.22
    Configure cells to support ENDC
    Run keyword if  "${platform}" != "ABIN"
    ...   Configure    ${delta_281_SgNBModification_ho_rejected_in_ovl_state_B4}

Teardown test environment B4
    Configure    ${delta_281_SgNBAddRejection_ovl_all_off}

UE1 and UE2 attach to eNB with SCG establishment
    UE1 attach to sim_eNB
    UE2 attach to sim_eNB
    eNB triggers SCG establishment for UE1 with NRCELL_1 on gNB2 with measurement activation
    eNB triggers SCG establishment for UE2 with NRCELL_1 on gNB2 with measurement activation
    Verify that SCG establishment for UE1 with NRCELL_1 on gNB2 succeed
    Verify that SCG establishment for UE2 with NRCELL_1 on gNB2 succeed

UE3 and UE4 attach to eNB with SCG establishment and SRB3 activation
    UE3 attach to sim_eNB
    UE4 attach to sim_eNB
    eNB triggers SCG establishment for UE3 with NRCELL_1 on gNB2 with measurement activation
    eNB triggers SCG establishment for UE4 with NRCELL_1 on gNB2 with measurement activation
    Verify that SCG establishment for UE3 with NRCELL_1 on gNB2 succeed
    Verify that SCG establishment for UE4 with NRCELL_1 on gNB2 succeed
    Verify SRB3 activation during SgNBAddition for UE3
    Verify SRB3 activation during SgNBAddition for UE4

UE${ue_id:\d+} attach to sim_eNB
    Execute egate command  cmd=ue_change_location id=${ue_id} enb=1 cell=1
    Execute egate command  cmd=attach_ue id=${ue_id}   pass_regexp=UE${ue_id}: === UE IS ACTIVE

Enable 281 FAF on gNB
    Perform Parameter Commissioning    parameter=gnbOvlProtMode  value=classical

Disable 281 FAF on gNB
    Perform Parameter Commissioning    parameter=gnbOvlProtMode   value=disabled

Set gNB parameter srb3SupportEnbled to TRUE
    Perform Parameter Commissioning    parameter=srb3SupportEnabled  value=true

Set gNB parameter srb3SupportEnbled to FALSE
    Perform Parameter Commissioning    parameter=srb3SupportEnabled   value=false

Set gNB parameter ovlNsaMeasDiscard to TRUE
    Configure    ${delta_281_NSAMeasReject_on}

Set gNB parameter ovlNsaAddRej to FALSE
    Configure    ${delta_281_SgNBAddRejection_off}

Set gNB parameter ovlNsaAddRej to ENABLED
    Configure    ${delta_281_ovlNsaAddRej_enabled}

Set gNB parameter ovlNsaLteHoRej to ENABLED
    Configure    ${delta_281_ovlNsaLteHoRej_enabled}

Set gNB parameter actCuOvlProt to FALSE
    Disable 281 FAF on gNB

Set gNB parameter gnbOvlProtMode to DISABLED
    Perform Parameter Commissioning    parameter=gnbOvlProtMode   value=disabled

Cleanup after test B1
    Perform CPLANE OVL deactivation via R&D mechanism
    Detach UE1
    Detach UE2
    Detach UE3
    Disable 281 FAF on gNB

Perform CPLANE OVL activation via R&D mechanism
    Set Overload High Threshold to 0
    Sleep  5

Perform CPLANE OVL deactivation via R&D mechanism
    Set Overload High Threshold to 20
    Sleep  5

Set gNB parameter ovlNsaLteHoRej to TRUE
    Perform Parameter Commissioning    parameter=ovlNsaLteHoRej:enabled
    Sleep  5

eNB triggers SCG establishment for UE${ue_id:\d+} with NRCELL_1 on gNB${gnb_id:\d+}
    Expect ENDC flow for UE${ue_id} with gNB${gnb_id}
    Execute egate command  cmd=ue_dc_enb_start ue=${ue_id} target_gnb=${gnb_id} target_cells=${1} bearer=2 type=split_scg
    Sleep  3

eNB triggers SCG establishment for UE${ue_id:\d+} with NRCELL_1 on gNB${gnb_id:\d+} with measurement activation
    Expect ENDC flow for UE${ue_id} with gNB${gnb_id} and eventA3 activation
    Execute egate command  cmd=ue_dc_enb_start ue=${ue_id} target_gnb=${gnb_id} target_cells=${1} bearer=2 type=split_scg
    Sleep  3

eNB triggers SCG establishment for UE${ue_id} with NRCELL_1 during Overload on gNB${gnb_id}
    Expect message flow
    ...    gNB${gNB_id}:X2AP_SgNBAdditionRequest as addReq
    ...    gNB${gNB_id}:X2AP_SgNBAdditionRequestReject as addReject
    ...    alias=EN-DC_reject_UE_${ue_id}
    ...    overall_timeout=30

    Execute egate command  cmd=ue_dc_enb_start ue=${ue_id} target_gnb=${gnb_id} target_cells=${1} bearer=2 type=split_scg

Expect ENDC flow for UE${ue_id:\d+} with gNB${gnb_id:\d+}
    Expect message flow
    ...    gNB${gNB_id}:X2AP_SgNBAdditionRequest as addReq
    ...    gNB${gnb_id}:X2AP_SgNBAdditionRequestAcknowledge (SgNBtoMeNBContainer is present) as addResp
    ...    gNB${gNB_id}:X2AP_SgNBReconfigurationComplete as ReconfCmp
    ...    gNB${gNB_id}:X2AP_SNStatusTransfer
    ...    alias=EN-DC_UE_${ue_id}
    ...    overall_timeout=30

Expect ENDC flow for UE${ue_id:\d+} with gNB${gnb_id:\d+} and eventA${event_id:\d+} activation
    Expect message flow
    ...    gNB${gNB_id}:X2AP_SgNBAdditionRequest as addReq
    ...    gNB${gnb_id}:X2AP_SgNBAdditionRequestAcknowledge (eventA${event_id} is present) as addResp
    ...    gNB${gNB_id}:X2AP_SgNBReconfigurationComplete as ReconfCmp
    ...    gNB${gNB_id}:X2AP_SNStatusTransfer
    ...    alias=EN-DC_UE_${ue_id}
    ...    overall_timeout=30

Verify that SCG establishment for UE${ue_id:\d+} with NRCELL_1 on gNB${gnb_id} succeed
    Flow occurred as expected   alias=EN-DC_UE_${ue_id}

Verify that gNB2 sends X2AP:SgNBAdditionRequestReject with cause: Control Processing Overload
    Flow occurred as expected   alias=EN-DC_reject_UE_2
    Verify SgNBAddition is rejected with expected cause

Verify SgNBAddition is rejected with expected cause
    Verify that message fulfills query
    ...     (Cause contains (misc eq 'control-processing-overload'))
    ...     message_alias=addReject
    ...     flow_alias=EN-DC_reject_UE_2

Verify SgNBModification is rejected with expected cause for UE${ue_id}
    Verify that message fulfills query
    ...     (Cause contains (misc eq 'control-processing-overload'))
    ...     message_alias=modReqRej
    ...     flow_alias=sgnb_add_split_bearer_mod_req_reject_UE_${ue_id}

Verify that countermeasures are not active and SCG establishment for UE3 with gNB2 succeed
    Verify that SCG establishment for UE3 with NRCELL_1 on gNB$2 succeed

Verify SRB3 activation during SgNBAddition for UE${ue_id}
    Verify that message fulfills query
    ...     (srb-ToAddModList is present)
    ...     message_alias=addResp
    ...     flow_alias=EN-DC_UE_${ue_id}

Wait until ABIL recovery ends with success
    Sleep  120s

UE${ue_id:\d+} sends A3 measResult for nr_cell_1 from gNB_tgt with value above offset defined for PSCell
    ${SW_RELEASE}   Get gNB SW release
    ${pci}=  Set Variable If  '${SW_RELEASE}' == 'SBTS22R1'  51   52
    Execute egate command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${pci} nrsrp_nr=120 nrsrq_nr=120

UE1 send A3 measResult for PSCell with value below defined threshold via SRB3
    ${SW_RELEASE}   Get gNB SW release
    ${pci}=  Set Variable If  '${SW_RELEASE}' == 'SBTS22R1'  51   52
    Execute egate command
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${pci} nrsrp_nr=10 nrsrq_nr=10

Expect UE${ue_id:\d+} inter_gNB HO from gNB${gnb_id:\d+} to gNB_tgt
    Expect message flow
    ...    gNB${gnb_id}:X2AP_SgNBChangeRequired
    ...    eNB:X2AP_SgNBChangeConfirm
    ...    gNB${gNB_id}:X2AP_SNStatusTransfer
    ...    alias=gNB_HO_UE_${ue_id}
    ...    overall_timeout=30

Verify that inter-gNB intra-frequency handover execution for UE${ue_id:\d+} succeed
    Flow occurred as expected   alias=gNB_HO_UE_${ue_id}

Expect Measurement Report ignoring for UE${ue_id:\d+}
    Expect Measurement Report for UE${ue_id}

    Expect message will not occur
    ...                 gNB2:X2AP_SgNBChangeRequired
    ...                 alias=no_gNB_HO_UE_${ue_id}
    ...                 overall_timeout=30

    Expect message will not occur
    ...                 gNB2:X2AP_SgNBModificationRequired
    ...                 alias=no_gNB_mod_UE_${ue_id}
    ...                 overall_timeout=30

    Expect message will not occur
    ...                 gNB2:F1AP_UEContextModificationRequest
    ...                 alias=no_F1AP_modify_UE_${ue_id}
    ...                 overall_timeout=30

Expect Measurement Report ignoring recieved via SRB3 for UE${ue_id:\d+}
    Expect message will not occur
    ...                 gNB2:X2AP_SgNBChangeRequired
    ...                 alias=no_gNB_HO_UE_${ue_id}
    ...                 overall_timeout=30

    Expect message will not occur
    ...                 gNB2:X2AP_SgNBModificationRequired
    ...                 alias=no_gNB_mod_UE_${ue_id}
    ...                 overall_timeout=30

    Expect message will not occur
    ...                 gNB2:F1AP_UEContextModificationRequest
    ...                 alias=no_F1AP_modify_UE_${ue_id}
    ...                 overall_timeout=30

    Expect Measurement Report via SRB3 for UE${ue_id}

Expect Measurement Report for UE${ue_id:\d+}
    Expect message flow
    ...    eNB:X2AP_RRCTransfer
    ...    alias=A3_meas_UE_${ue_id}
    ...    overall_timeout=30

Expect Measurement Report via SRB3 for UE${ue_id:\d+}
    Expect message flow
    ...    UE_${ue_id}:NR-RRC_MeasurementReport as NRRRCMeas
    ...    alias=A3_meas_UE_${ue_id}
    ...    overall_timeout=30

Verify that gNB2 ignores Meas Report and does NOT send F1AP:UEContextModificationRequest for UE${ue_id:\d+}
    Verify measurement send via SRB3 from UE${ue_id}
    Flow not occurred for message   alias=no_F1AP_modify_UE_${ue_id}

Verify measurement send via SRB3 from UE${ue_id:\d+}
    Flow occurred as expected   alias=A3_meas_UE_${ue_id}

Verify that gNB2 ignores Meas Report and does NOT send X2AP:SgNBChangeRequired for UE${ue_id:\d+}
    Flow occurred as expected   alias=A3_meas_UE_${ue_id}
    Flow not occurred for message   alias=no_gNB_HO_UE_${ue_id}

Verify that gNB2 ignores Meas Report and does NOT send X2AP:SgNBModificationRequired for UE${ue_id:\d+}
    Flow occurred as expected   alias=A3_meas_UE_${ue_id}
    Flow not occurred for message   alias=no_gNB_mod_UE_${ue_id}

Expect UE${ue_id:\d+} ENDC connection release
    Expect message flow
    ...    eNB:X2AP_SgNBReleaseRequest
    ...    eNB:X2AP_SgNBReleaseRequestAcknowledge
    ...    eNB:X2AP_UEContextRelease
    ...    alias=detach_UE_${ue_id}
    ...    overall_timeout=30

UE1 and UE2 triggers detach procedure from eNB
    Expect UE1 ENDC connection release
    Expect UE2 ENDC connection release
    Detach UE1 and UE2

Verify that SCG release performed for UE1 and UE2
    Flow occurred as expected   alias=detach_UE_1
    Flow occurred as expected   alias=detach_UE_2

Detach UE${ue_id:\d+}
    Execute egate command  cmd=detach_ue id=${ue_id}

Detach UE1 and UE2
    Detach UE1
    Detach UE2

Detach UE3 and UE4
    Detach UE3
    Detach UE4

UE${ue_id:\d+} triggers intra-eNB handover
    Expect message flow
    ...    eNB1:X2AP_SgNBModificationRequest as modReqintraHo
    ...    alias=intra-eNB_sgnb_mod_req_UE_${ue_id}
    ...    overall_timeout=30

    Expect message flow
    ...    gNB2:X2AP_SgNBModificationRequestAcknowledge as modResp
    ...    alias=intra-eNB_sgnb_mod_req_ack_UE_${ue_id}
    ...    overall_timeout=30

    Expect message flow
    ...    eNB1:X2AP_SgNBReconfigurationComplete as recCompl
    ...    alias=intra-eNB_sgnb_rec_compl_UE_${ue_id}
    ...    overall_timeout=30

    Execute egate command   cmd=ue_ho id=${ue_id} enb=1 cell=2

UE${ue_id:\d+} triggers intra eNB handover
    Expect message flow
    ...    eNB1:X2AP_SgNBModificationRequest as modReqintraHo2
    ...    alias=intra-eNB_ho_sgnb_mod_req_UE_${ue_id}
    ...    overall_timeout=10

    Expect message flow
    ...    gNB2:X2AP_SgNBModificationRequestReject as modReqRej2
    ...    alias=intra-eNB_sgnb_mod_req_rej_UE_${ue_id}
    ...    overall_timeout=10

    Expect message flow
    ...    eNB1:X2AP_SgNBReleaseRequest
    ...    alias=intra-eNB_sgnb_rel_req_UE_${ue_id}
    ...    overall_timeout=10

    Expect message flow
    ...    gNB2:X2AP_SgNBReleaseRequestAcknowledge
    ...    alias=intra-eNB_sgnb_rel_req_ack_UE_${ue_id}
    ...    overall_timeout=10

    Expect message flow
    ...    eNB1:X2AP_UEContextRelease
    ...    alias=intra-eNB_context_release_${ue_id}
    ...    overall_timeout=10

    Execute egate command   cmd=ue_ho id=${ue_id} enb=1 cell=2

Verify that eNB_${enb_id} sends X2AP:SgNBModificationRequest with new SgNB Security Key for UE${ue_id}
    Flow occurred as expected   alias=intra-eNB_ho_sgnb_mod_req_UE_${ue_id}
    verify_security_key_change
    ...     flow_alias_first=intra-eNB_sgnb_mod_req_UE_${ue_id}
    ...     message_alias_first=modReqintraHo
    ...     flow_alias_second=intra-eNB_ho_sgnb_mod_req_UE_${ue_id}
    ...     message_alias_second=modReqintraHo2

Verify that eNB_${enb_id} sends X2AP:SgNBModificationRequest for UE${ue_id}
    Flow occurred as expected   alias=intra-eNB_ho_sgnb_mod_req_UE_${ue_id}
    verify_security_key_change
    ...     flow_alias_first=EN-DC_UE_${ue_id}
    ...     message_alias_first=addReq
    ...     flow_alias_second=intra-eNB_ho_sgnb_mod_req_UE_${ue_id}
    ...     message_alias_second=modReqintraHo2

UE${ue_id:\d+} triggers inter-eNB handover from eNB_${enb_src} to eNB_${enb_tgt}
    Expect message flow
    ...    eNB${enb_tgt}:X2AP_SgNBAdditionRequest as addReqeNB2
    ...    alias=inter-eNB${enb_tgt}_sgnb_req_UE_${ue_id}
    ...    overall_timeout=10

    Expect message flow
    ...    gNB2:X2AP_SgNBAdditionRequestAcknowledge as addReqAckeNB2
    ...    alias=inter-eNB${enb_tgt}_sgnb_req_ack_UE_${ue_id}
    ...    overall_timeout=10

    Expect message flow
    ...    eNB${enb_src}:X2AP_SgNBReleaseRequest
    ...    alias=inter-eNB${enb_src}_sgnb_rel_req_UE_${ue_id}
    ...    overall_timeout=10

    Expect message flow
    ...    gNB2:X2AP_SgNBReleaseRequestAcknowledge
    ...    alias=inter-eNB${enb_src}_sgnb_rel_req_ack_UE_${ue_id}
    ...    overall_timeout=10

    Expect message flow
    ...    eNB${enb_tgt}:X2AP_SgNBReconfigurationComplete as reconfComplete
    ...    alias=inter-eNB${enb_tgt}_sgnb_rec_compl_UE_${ue_id}
    ...    overall_timeout=10

    Run keyword if    "${enb_src}" == "1"    Execute egate command    cmd=ue_ho id=${ue_id} enb=4 cell=1
    ...    ELSE    Execute egate command    cmd=ue_ho id=${ue_id} enb=1 cell=1

    Execute egate command   cmd=ue_ho id=${ue_id} enb=4 cell=1

UE${ue_id:\d+} triggers inter eNB handover from eNB_${enb_src} to eNB_${enb_tgt}
    Expect message flow
    ...    eNB${enb_tgt}:X2AP_SgNBAdditionRequest as addReqeNBinterHo
    ...    alias=inter-eNB${enb_tgt}_sgnb_add_req_4_UE_${ue_id}
    ...    overall_timeout=10

    Expect message flow
    ...    gNB2:X2AP_SgNBAdditionRequestReject as addReqRejinterHo
    ...    alias=inter-eNB_sgnb_req_rej_4_UE_${ue_id}
    ...    overall_timeout=10

    Execute egate command   cmd=ue_ho id=${ue_id} enb=${enb_tgt} cell=1

eNB_${enb_id} triggers SgNBModificationRequest to add additional split bearer for UE${ue_id}
    Expect message flow
    ...    eNB1:X2AP_SgNBModificationRequest (length(drb-ToAddModList) eq 1)
    ...    alias=sgnb_add_split_bearer_mod_req_UE_${ue_id}
    ...    overall_timeout=10

    Expect message flow
    ...    gNB2:X2AP_SgNBModificationRequestAcknowledge
    ...    alias=sgnb_add_split_bearer_mod_req_ack_UE_${ue_id}
    ...    overall_timeout=10

    Expect message flow
    ...    eNB1:X2AP_SgNBReconfigurationComplete
    ...    alias=sgnb_add_split_bearer_rrc_UE_${ue_id}
    ...    overall_timeout=10

    Execute egate command   cmd=ue_dc_modify_enb bearer_to_add=3 ue=${ue_id} by=enb cause=RN_resource_optimisation
    Flow occurred as expected   alias=sgnb_add_split_bearer_mod_req_UE_${ue_id}

eNB_${enb_id} triggers SgNBModificationRequest to release additional split bearer for UE${ue_id:\d+}
    Expect message flow
    ...    eNB1:X2AP_SgNBModificationRequest
    ...    alias=sgnb_release_split_bearer_mod_req_UE_${ue_id}
    ...    overall_timeout=10

    Expect message flow
    ...    gNB2:X2AP_SgNBModificationRequestAcknowledge
    ...    alias=sgnb_release_split_bearer_mod_req_ack_UE_${ue_id}
    ...    overall_timeout=10

    Expect message flow
    ...    eNB1:X2AP_SgNBReconfigurationComplete
    ...    alias=sgnb_release_split_bearer_rrc_UE_${ue_id}
    ...    overall_timeout=10

    Execute egate command   cmd=ue_dc_modify_enb bearer_to_release=3 ue=${ue_id} by=enb cause=RN_resource_optimisation
    Flow occurred as expected   alias=sgnb_release_split_bearer_mod_req_UE_${ue_id}

eNB_${enb_id} triggers SgNBModificationRequest for UE${ue_id:\d+} when cplane ovl is activate
    Expect message flow
    ...    eNB1:X2AP_SgNBModificationRequest (length(drb-ToAddModList) eq 1)
    ...    alias=sgnb_add_split_bearer_ovl_mod_req_UE_${ue_id}
    ...    overall_timeout=10

    Expect message flow
    ...    gNB2:X2AP_SgNBModificationRequestReject as modReqRej
    ...    alias=sgnb_add_split_bearer_mod_req_reject_UE_${ue_id}
    ...    overall_timeout=10

    Execute egate command   cmd=ue_dc_modify_enb bearer_to_add=3 ue=${ue_id} by=enb cause=RN_resource_optimisation
    Flow occurred as expected   alias=sgnb_add_split_bearer_ovl_mod_req_UE_${ue_id}

Verify that new SgNB Security Key IE is occurred in SgNBModificationRequest message for UE_${ue_id}
    log to console  	Verify new SgNB Security Key IE value
    verify_security_key_change
    ...     flow_alias_first=EN-DC_UE_${ue_id}
    ...     message_alias_first=addReq
    ...     flow_alias_second=intra-eNB_sgnb_mod_req_UE_${ue_id}
    ...     message_alias_second=modReqintraHo

Verify that gNB after requesting split bearer sends X2AP:SgNBModificationRequestReject with cause: Control Processing Overload for UE${ue_id:\d+}
    Flow occurred as expected   alias=sgnb_add_split_bearer_mod_req_reject_UE_${ue_id}
    Verify that message fulfills query
    ...     (Cause contains (misc eq 'control-processing-overload'))
    ...     message_alias=modReqRej
    ...     flow_alias=sgnb_add_split_bearer_mod_req_reject_UE_${ue_id}

Verify that gNB after intra-enb handover sends X2AP:SgNBModificationRequestReject with cause: Control Processing Overload for UE${ue_id:\d+}
    Flow occurred as expected   alias=intra-eNB_sgnb_mod_req_rej_UE_${ue_id}
    Verify that message fulfills query
    ...     (Cause contains (misc eq 'control-processing-overload'))
    ...     message_alias=modReqRej2
    ...     flow_alias=intra-eNB_sgnb_mod_req_rej_UE_${ue_id}

Verify that eNB_${enb_src} sends X2AP:SgNBModificationRequest with SCG Configuration Query after inter eNB handover procedure for UE${ue_id:\d+}
    Flow occurred as expected   alias=inter-eNB${enb_src}_sgnb_mod_req_3_UE_${ue_id}

Verify that gNB sends X2AP:SgNBModificationRequestAcknowledge after inter eNB handover procedure for UE${ue_id:\d+}
    Flow occurred as expected   alias=inter-eNB${enb_src}_sgnb_mod_req_ack_3_UE_${ue_id}

Verify that eNB_${enb_tgt} sends X2AP:SgNBAdditionRequest after inter eNB handover procedure for UE${ue_id:\d+}
    Flow occurred as expected   alias=inter-eNB${enb_tgt}_sgnb_add_req_4_UE_${ue_id}

Verify that gNB sends X2AP:SgNBAdditionRequestReject after inter eNB handover procedure for UE${ue_id:\d+} with cause: Control Processing Overload
    Flow occurred as expected   alias=inter-eNB_sgnb_req_rej_4_UE_${ue_id}
    Verify that message fulfills query
    ...     (Cause contains (misc eq 'control-processing-overload'))
    ...     message_alias=addReqRejinterHo
    ...     flow_alias=inter-eNB_sgnb_req_rej_4_UE_${ue_id}

Trigger SgNB Modification Procedure from eNB for SCG Configuration Change for UE${ue_id:\d+}
    Expect message flow
    ...    eNB1:X2AP_SgNBModificationRequest as modReqScg
    ...    alias=scg_sgnb_mod_req_UE_${ue_id}
    ...    overall_timeout=10

    Expect message flow
    ...    gNB2:X2AP_SgNBModificationRequestAcknowledge as modReqAckScg
    ...    alias=scg_sgnb_mod_req_ack_UE_${ue_id}
    ...    overall_timeout=10

    Execute egate command  cmd=enb_ue_dc_modify ue=${ue_id} by=enb cause=RN_mCG_Mobility

Verify that eNB sends X2AP:SgNBModificationRequest after SCG Configuration Change for UE${ue_id:\d+}
    Flow occurred as expected   alias=scg_sgnb_mod_req_UE_${ue_id}

Verify that gNB sends X2AP:SgNBModificationRequestAcknowledge after SCG Configuration Change for UE${ue_id:\d+}
    Flow occurred as expected   alias=scg_sgnb_mod_req_ack_UE_${ue_id}

Verify that eNB sends X2AP:SgNBModificationRequest with new SgNB Security Key IE for UE${ue_id:\d+}
    Flow occurred as expected   alias=intra-eNB_sgnb_mod_req_UE_${ue_id}
    Verify that new SgNB Security Key IE is occurred in SgNBModificationRequest message for UE_1

Verify that gNB sends X2AP:SgNBModificationRequestAcknowledge after intra-eNB handover procedure for UE${ue_id:\d+}
    Flow occurred as expected   alias=intra-eNB_sgnb_mod_req_ack_UE_${ue_id}

Verify that eNB sends X2AP:SgNBReconfigurationComplete after intra-eNB handover procedure for UE${ue_id:\d+}
    Flow occurred as expected   alias=intra-eNB_sgnb_rec_compl_UE_${ue_id}

Verify that eNB_${enb_src} sends X2AP:SgNBReleaseRequest after inter-eNB handover procedure for UE${ue_id:\d+}
    Flow occurred as expected   alias=inter-eNB${enb_src}_sgnb_rel_req_UE_${ue_id}

Verify that gNB sends X2AP:SgNBReleaseRequestAcknowledge to eNB_${enb_src} after inter-eNB handover procedure for UE${ue_id:\d+}
    Flow occurred as expected   alias=inter-eNB${enb_src}_sgnb_rel_req_ack_UE_${ue_id}

Verify that eNB_${enb_id} sends X2AP:SgNBAdditionRequest after inter-eNB handover procedure for UE${ue_id:\d+}
    Flow occurred as expected   alias=inter-eNB${enb_id}_sgnb_req_UE_${ue_id}

Verify that gNB sends X2AP:SgNBAdditionRequestAcknowledge to eNB_${enb_target} after inter-eNB handover procedure for UE${ue_id:\d+}
    Flow occurred as expected   alias=inter-eNB2_sgnb_req_ack_UE_1

Verify that eNB_${enb_id} sends X2AP:SgNBReconfigurationComplete after inter-eNB handover procedure for UE${ue_id:\d+}
    Flow occurred as expected   alias=inter-eNB${enb_id}_sgnb_rec_compl_UE_${ue_id}

Verify that gNB sends X2AP:SgNBModificationRequestAcknowledge after add additional split bearer for UE${ue_id:\d+}
    Flow occurred as expected   alias=sgnb_add_split_bearer_mod_req_ack_UE_${ue_id}

Verify that eNB_${enb_id} sends X2AP:SgNBReconfigurationComplete after add additional split bearer for UE${ue_id:\d+}
    Flow occurred as expected   alias=sgnb_add_split_bearer_rrc_UE_${ue_id}

Verify that gNB sends X2AP:SgNBModificationRequestAcknowledge after release of additional split bearer for UE${ue_id:\d+}
    Flow occurred as expected   alias=sgnb_release_split_bearer_mod_req_UE_${ue_id}

Verify that eNB_${enb_id} sends X2AP:SgNBReconfigurationComplete after release of additional split bearer for UE${ue_id:\d+}
    Flow occurred as expected   alias=sgnb_release_split_bearer_rrc_UE_${ue_id}

Verify that eNB_1 sends X2AP:SgNBReleaseRequest after intra eNB handover procedure for UE${ue_id:\d+}
    Flow occurred as expected   alias=intra-eNB_sgnb_rel_req_UE_${ue_id}

Verify that gNB sends X2AP:SgNBReleaseRequestAcknowledge to eNB_1 after intra eNB handover procedure for UE${ue_id:\d+}
    Flow occurred as expected   alias=intra-eNB_sgnb_rel_req_ack_UE_${ue_id}

Verify that eNB_1 sends X2AP:UEContextRelease after intra eNB handover procedure for UE${ue_id:\d+}
    Flow occurred as expected   alias=intra-eNB_context_release_${ue_id}

Configure cells to support ENDC
    Execute egate command   cmd=enb_cell_param enb=1 id=1 allow_endc=on
    Execute egate command   cmd=enb_cell_param enb=1 id=2 allow_endc=on
    Execute egate command   cmd=enb_cell_param enb=4 id=1 allow_endc=on
