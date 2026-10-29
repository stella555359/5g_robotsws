*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...       - Paulina Jedras <paulina.jedras@nokia.com>
...       - Malgorzata Konior <malgorzata.konior@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource     testsuite/Wroclaw/RRM/WRO_2/CB008954/resources/Robot/common_settings.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/CB008954/resources/verifiers.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/CB008954/resources/yaml_config_paths.robot
Resource     CB008954_setups_and_teardowns.robot
Library      testsuite/Wroclaw/RRM/WRO_2/CB008954/resources/python/mock_stop_egate.py
Library      taf.ul.ue.sim.env_setup
Library      alarms_verifiers.py
Library      CB008954_counters.py
Library      taf.ul.hanging_resources.listener  ${False}
Library      taf.ul.ettf.setups
Library      ta5g_testline_management

*** Variables ***
&{5QI_TO_EGATE_QOS_FLOW_ID}=  2=2    3=3    6=1
&{bwp_profiles_names}    small=1    second=2    large=3
${cell_id_freq}=
*** Keywords ***
Run Setup
    Log To Console    Setup started
    ${run_update}    get variable value      ${configure}    "True"   # do not ever change that line!
    Run Keyword if  ${run_update} != ${False}
    ...    Prepare TL with config files
    Setup devices aliases
    Reliable emss setup         bts_id=1
    Enable internal mirroring for alias    gNB2
    Calculate BWP fields in RRCReconfiguration for all NRCELLs

Setup devices aliases
    Create Ues alias    alias=UE  id_type=wts_5g
    Create ENB device with alias 'eNB1' identified by ip=10.0.1.21
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.31
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Prepare TL with config files
     Log To Console    Configure ENV with SCFC/AP.xml/LUA
     Update And Put Iphy Xml    input_filepath=${AP_XML}
     With Gnb Configuration    commissioning=${SCFC}
     With Simulator Configuration    config=${LUA_CFG}
     Log To Console    After Configure ENV
     Check no NRCELL related errors in ADMIN
     Activate RTPM counters

Activate RTPM counters
    RTPM activate
    ${nrRTPMMeasurementsList}  catenate  SEPARATOR=
    ...    [55139 Standalone (SA) Distributed unit (DU) Radio admission control measurement,
    ...    55115 Distributed unit (DU) Radio admission control measurement,
    ...    55166 NR RRC Interface Report per CELL for DU,
    ...    55308 NR Cell Utilization,
    ...    55167 NR Carrier Aggregation Distributed Unit (gNB-DU) CP,
    ...    55125 NR NGAP Interface Report per CELL]

    Configure  [{'MOC': 'NRPMRNL', 'ID': '1', 'nrRTPMMeasurementsList': '${nrRTPMMeasurementsList}'}]

Collect RD counters
    ${pm_counters_filepath_temp}=    get_next_unpacked_raw_rd_counters_file
    Set Test Variable    ${pm_counters_filepath}    ${pm_counters_filepath_temp}

Calculate BWP fields in RRCReconfiguration for all NRCELLs
    FOR    ${cell_bwp}    IN    @{NRCELL_BWP}
        Calculate BWP fields in RRC    &{cell_bwp}
    END

Check no NRCELL related errors in ADMIN
    Log to console  Checking Cell related alarms
    Wait until keyword succeeds  60 sec  10 sec
    ...    Verify that 7516 alarm with Incorrect Cell Parameter Configuration fault was not raised

Verify that 7516 alarm with Incorrect Cell Parameter Configuration fault was not raised
    ${result}  Verify that alarm 7516 with Incorrect cell parameter configuration fault is not active
    Return From Keyword If  '${result}'=='True'  Alarm 7516 was not found
    Fail  Alarm 7516 found

Attach UE${ue_id:\d+} to NRCELL-${nr_cell_id:\d+}
    Attach UE${ue_id} to gNB2 cell${nr_cell_id} with ICS during PDU session setup

Verify that SgNB Addition with NRCELL-1 is rejected for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 X2AP sgNBAdditionPreparationFailure
    Execute egate command  cmd=ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...                    pass_regexp=UE${ue_id}: Sending SgNB Addition Request
    PASS FLOW[timeout=10]: gNB2 X2AP sgNBAdditionPreparationFailure

Perform reestablishment for UE${ue_id:\d+} to gNB${gnb_id:\d+} NRCELL-${nr_cell_id:\d+}
    Trigger reestablishment for UE${ue_id} to gNB${gnb_id} NRCELL-${nr_cell_id}
    PASS FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReestablishment
    PASS FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    PASS FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Trigger reestablishment for UE${ue_id:\d+} to gNB${gnb_id:\d+} NRCELL-${nr_cell_id:\d+}
    EXPECT FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReestablishment
    EXPECT FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    EXPECT FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    Execute egate command  cmd=ue_rrc_reestablish id=${ue_id} gnb=${gnb_id} cell=${nr_cell_id}

Verify that UE${ue_id:\d+} reestablishment in NRCELL-2 was rejected
    PASS FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    FAIL FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReestablishment
    FAIL FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    FAIL FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReconfiguration
    FAIL FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Perform inter-gNB inter-freq HO for UE${ue_id:\d+} to gNB${gnb_id:\d+} NRADJNRCELL-${cell_id:\d+}
    Trigger UE${ue_id} to send A2 measurement and wait for next measurements configuration
    Trigger UE${ue_id} to send A5 measurement and verify inter-gNB HO to gNB${gnb_id} NRADJNRCELL-${cell_id}

Perform inter-gNB intra-freq HO for UE${ue_id:\d+} to gNB${gnb_id:\d+} NRADJNRCELL-${cell_id:\d+}
    Trigger UE${ue_id} to send A5 measurement and verify inter-gNB HO to gNB${gnb_id} NRADJNRCELL-${cell_id}

Perform intra-gNB inter-freq HO for UE${ue_id:\d+} to gNB2 NRCELL-${cell_id:\d+}
    Trigger UE${ue_id} to send A2 measurement and wait for next measurements configuration

    EXPECT FLOW: UE_${ue_id} NR-RRC MeasurementReport
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    ${physcellid}=    get enb parameter value    NRCELL-${cell_id}    physCellId
    ${cell_id_freq}=    get enb parameter value    NRCELL-${cell_id}    arfcnSsbPbch
    ${ue_measurements_in_egate}=    execute egate command and wait for data    cmd=ue_meas_cfg_disp id=${ue_id}
    ${meas_id}=  Wait until keyword succeeds    10s    2s
    ...    Get measId matching reportConfig with eventA5 and measObjectId with ${cell_id_freq} for UE${ue_id}
    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A5 srsrp_nr=0 phycell_id=${physcellid} nrsrp_nr=127
    Wait for next measurement  UE_${ue_id}
    PASS FLOW: UE_${ue_id} NR-RRC MeasurementReport
    PASS FLOW: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Perform inter-gNB intra-freq HO for UE${ue_id:\d+} to gNB${gnb_id:\d+} NRCELL-${cell_id:\d+}
    EXPECT FLOW: gNB${gnb_id} XNAP handoverPreparation
    EXPECT FLOW: gNB${gnb_id} XNAP sNStatusTransfer
    EXPECT FLOW: AMF1 NGAP pathSwitchRequest
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    ${physcellid}=    get enb parameter value    NRCELL-${cell_id}    physCellId
    ${cell_id_freq}=    get enb parameter value    NRCELL-${cell_id}    arfcnSsbPbch
    ${ue_measurements_in_egate}=    execute egate command and wait for data    cmd=ue_meas_cfg_disp id=${ue_id}
    Execute egate command   cmd=ue_ho_nr ue_id=${ue_id} meas_type=A5 tgt_phycell_id=${physcellid} tgt_cell_ssb_frequency=${cell_id_freq}
    ...     pass_regexp=UE${ue_id}: Inter-eNB handover from ENB-3.* to EXT_ENB-2.${cell_id} performed
    PASS FLOW: gNB${gnb_id} XNAP handoverPreparation
    PASS FLOW: gNB${gnb_id} XNAP sNStatusTransfer
    PASS FLOW: AMF1 NGAP pathSwitchRequest
    PASS FLOW: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Perform inter-gNB inter-freq HO for UE${ue_id:\d+} to gNB${gnb_id:\d+} NRCELL-${cell_id:\d+}
    EXPECT FLOW: gNB${gnb_id} XNAP handoverPreparation
    EXPECT FLOW: gNB${gnb_id} XNAP sNStatusTransfer
    EXPECT FLOW: AMF1 NGAP pathSwitchRequest
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    ${physcellid}=    get enb parameter value    NRCELL-${cell_id}    physCellId
    ${cell_id_freq}=    get enb parameter value    NRCELL-${cell_id}    arfcnSsbPbch
    ${ue_measurements_in_egate}=    execute egate command and wait for data    cmd=ue_meas_cfg_disp id=${ue_id}
    Execute egate command   cmd=ue_ho_nr ue_id=${ue_id} meas_type=A5 tgt_phycell_id=${physcellid} tgt_cell_ssb_frequency=${cell_id_freq}
    ...     pass_regexp=UE${ue_id}: Inter-eNB handover from ENB-3.* to EXT_ENB-2.${cell_id} performed
    PASS FLOW: gNB${gnb_id} XNAP handoverPreparation
    PASS FLOW: gNB${gnb_id} XNAP sNStatusTransfer
    PASS FLOW: AMF1 NGAP pathSwitchRequest
    PASS FLOW: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Trigger UE${ue_id:\d+} to send A2 measurement and wait for next measurements configuration
    EXPECT FLOW: UE_${ue_id} NR-RRC MeasurementReport
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    ${ue_measurements_in_egate}=    execute egate command and wait for data    cmd=ue_meas_cfg_disp id=${ue_id}
    ${meas_id}=  Wait until keyword succeeds    10s    2s
    ...    Get measId matching reportConfig with eventA2 for UE${ue_id}
    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=0
    Wait for next measurement  UE_${ue_id}
    PASS FLOW: UE_${ue_id} NR-RRC MeasurementReport
    PASS FLOW: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Trigger UE${ue_id:\d+} to send A5 measurement and verify inter-gNB HO to gNB${gnb_id:\d+} NRADJNRCELL-${cell_id:\d+}
    EXPECT FLOW: gNB${gnb_id} XNAP handoverPreparation
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW: gNB${gnb_id} XNAP uEContextRelease
    ${physcellid}=    get enb parameter value    NRADJNRCELL-${cell_id}    physCellId
    ${cell_id_freq}=    get enb parameter value    NRADJNRCELL-${cell_id}    ssbFrequency
    Sleep  5
    ${ue_measurements_in_egate}=    execute egate command and wait for data    cmd=ue_meas_cfg_disp id=${ue_id}
    ${meas_id}=  Wait until keyword succeeds    10s    2s
    ...    Get measId matching reportConfig with eventA5 and measObjectId with ${cell_id_freq} for UE${ue_id}
    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A5 srsrp_nr=0 phycell_id=${physcellid} nrsrp_nr=127
    ...     pass_regexp=UE${ue_id}: Inter-eNB handover from EXT_ENB-2.* to ENB-3.* performed
    Wait for next measurement  UE_${ue_id}
    PASS FLOW: gNB${gnb_id} XNAP handoverPreparation
    PASS FLOW: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW: gNB${gnb_id} XNAP uEContextRelease

Get measId matching reportConfig with ${event_id} and measObjectId with ${freq} for UE${ue_id:\d+}
    get_active_measurements     UE_${ue_id}         enable_logging=${True}
    ${report_id}=    Get reportConfigId field value from reportConfig with (${event_id} is present) for UE_${ue_id}
    ${meas_object_id}=    Get measObjectId field value from measObject with (ssbFrequency eq ${freq}) for UE_${ue_id}
    ${meas_id}=   Get measId field value from measId with ((reportConfigId eq ${report_id}) and (measObjectId eq ${meas_object_id})) for UE_${ue_id}
    [Return]        ${meas_id}

Trigger UE${ue_id:\d+} to send A1 measurement and wait for UE RRC Reconfiguration
    EXPECT FLOW: UE_${ue_id} NR-RRC MeasurementReport
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfiguration

    ${meas_id}=  Wait until keyword succeeds    10s    2s
    ...    Get measId matching reportConfig with eventA1 for UE${ue_id}

    Execute egate command
    ...     cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=120
    PASS FLOW: UE_${ue_id} NR-RRC MeasurementReport
    PASS FLOW: UE_${ue_id} NR-RRC RRCReconfiguration

Verify ${check_type:basic|full} additional fields for CB008954 requirements for UE${ue_id:\d+}

    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     spCellConfigDedicated contains (
    ...         downlinkBWP-ToAddModList contains (
    ...             bwp-Dedicated contains (
    ...                 nrofCandidates is present
    ...             )
    ...         )
    ...     )
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

    Run Keyword if  "${check_type}" != "basic"
    ...    Verify That Message Fulfills Query
    ...        spCellConfigDedicated contains (
    ...            downlinkBWP-ToAddModList contains (
    ...                bwp-Dedicated contains (
    ...                    controlResourceSetToAddModList contains (
    ...                        ((((controlResourceSetId is present)
    ...                        and
    ...                        (frequencyDomainResources is present))
    ...                        and
    ...                        (duration is present))
    ...                        and
    ...                        (cce-REG-MappingType contains (nonInterleaved is present)))
    ...                        and
    ...                        (precoderGranularity eq 'sameAsREG-bundle')
    ...                    )
    ...                )
    ...            )
    ...        )
    ...        message_alias=RRCReconfiguration
    ...        flow_alias=${flow_alias_rrc}

Attach UEs with traffic until first UE is rejected due to admission control
    [Arguments]    ${ue_first}    ${ue_last}    ${cell_id}    ${bwp}    ${5qi_id}    ${traffic_dir}    ${traffic_rate}
    ...            ${gfbr_dl_rate}=5    ${gfbr_ul_rate}=5
    Set test variable    ${attached_ues}      0
    Set test variable    ${ue_was_rejected}    ${FALSE}
    ${qos_flow_id}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi_id}

    FOR    ${ue}    IN RANGE    ${ue_first}    ${ue_last}+1
        ${ue_id}=    Convert To String  ${ue}
        Attach UE${ue_id} without ICS to gNB2 cell${cell_id}

        EXPECT FLOW[timeout=5]: AMF1 NGAP initialContextSetup
        EXPECT FLOW[timeout=5]: AMF1 NGAP initialContextSetupFailure
        EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfiguration

        Execute egate command    cmd=qosflow_modify qos_flow=${qos_flow_id} gfbr_dl=${gfbr_dl_rate}000 gfbr_ul=${gfbr_ul_rate}000

        Run Keyword If    ${qos_flow_id}==1
        ...    Try to add to UE${ue_id} PDU session with 1 non-GBR and no GBR bearer
        ...    ELSE
        ...    Try to add to UE${ue_id} PDU session with 1 non-GBR and 1 GBR 5QI${5qi_id} bearer

        ${status}=     Run Keyword And Return Status
        ...    Verify if UE${ue_id} attach was not accepted due to admission control reason
        Run Keyword If  ${status} == ${TRUE}
        ...    Set Test Variable  ${ue_was_rejected}  ${TRUE}
        Exit For Loop if   ${status} == ${TRUE}

        Verify if UE${ue_id} attach was accepted by admission control
        Verify that UE${ue_id} is configured with ${bwp} BWP profile after ICS to NRCELL-${cell_id}
        ${attached_ues}=    Evaluate    ${attached_ues} + 1

        Run Keyword If    ${qos_flow_id}==1
        ...    CB008954_common_keywords.Run ${traffic_rate}Mbps ${traffic_dir} traffic on UE${ue_id} PDU1 QFI1 and wait 10 seconds
        ...    ELSE
        ...    CB008954_common_keywords.Run ${traffic_rate}Mbps ${traffic_dir} traffic on UE${ue_id} PDU1 QFI2 and wait 10 seconds
    END
    Run Keyword If    ${ue_was_rejected}==${FALSE}
    ...    Fail    All UEs were accepted by admission control, TC can not be continued. You should increase range of attached UEs.
    Run Keyword If    ${attached_ues}==${0}
    ...    Fail    Any UE was accepted by admission control, TC can not be continued.

    Set Test Variable    ${succ_ue_bwp${bwp_profiles_names}[${bwp}]}    ${attached_ues}
    ${ues_requested_to_attach}=   Evaluate    ${attached_ues} + ${1}
    Set Test Variable    ${req_ue_bwp${bwp_profiles_names}[${bwp}]}    ${ues_requested_to_attach}

Verify if UE${ue_id:\d+} attach was accepted by admission control
    PASS FLOW[timeout=5]: AMF1 NGAP initialContextSetup
    PASS FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfiguration
    ${current_gw_id}     Evaluate  ${current_gw_id} + 1
    Set Test Variable    ${current_gw_id}

Verify if UE${ue_id:\d+} attach was not accepted due to admission control reason
    PASS FLOW[timeout=5]: AMF1 NGAP initialContextSetupFailure
    FAIL FLOW[timeout=5]: AMF1 NGAP initialContextSetup
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfiguration

    ${flow_alias}=  get flow name
    ...     procedure=initialContextSetupFailure
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     Cause contains (radioNetwork eq "radio-resources-not-available")
    ...     message_alias=InitialContextSetupFailure
    ...     flow_alias=${flow_alias}

Try to add to UE${ue_id:\d+} PDU session with 1 non-GBR and 1 GBR 5QI${5qi_id:\d+} bearer
    ${qos_flow_id}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi_id}
    Execute egate command    cmd=smf_param id=1 additional_qosflows_to_activate=${qos_flow_id}
    Try to add initial PDU session for UE${ue_id}
    Execute egate command    cmd=smf_param id=1 reset

Try to add to UE${ue_id:\d+} PDU session with 1 non-GBR and no GBR bearer
    Try to add initial PDU session for UE${ue_id}

Try to add initial PDU session for UE${ue_id:\d+}
    ${pdu_id}    Get From Dictionary    ${session_name_to_pdu}   initial
    Execute egate command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} gw=${current_gw_id} nwslice=1
    ...     pass_regexp=AMF-1: PDU Session Establishment Request with PDU Session ID 1 handled successfully

Try to attach UE${ue_id} to NRCELL-${cell_id:\d+} small BWP with 5QI-${5qi_id} bearer and verify that it is rejected due to admission control
    ${qos_flow_id}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi_id}
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCSetupRequest
    EXPECT FLOW: AMF1 NGAP initialContextSetupFailure
    EXPECT FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCRelease

    Execute egate command  cmd=smf_param id=1 additional_qosflows_to_activate=${qos_flow_id}
    Attach UE${ue_id} without ICS to gNB2 cell${cell_id}
    ${pdu_id}    Get From Dictionary    ${session_name_to_pdu}   initial
    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} gw=${current_gw_id} nwslice=1
    ...     pass_regexp=Received Initial Context Setup Failure from GNB
    Execute egate command  cmd=smf_param id=1 reset

    PASS FLOW: UE_${ue_id} NR-RRC RRCSetupRequest
    PASS FLOW: AMF1 NGAP initialContextSetupFailure
    PASS FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    PASS FLOW: UE_${ue_id} NR-RRC RRCRelease

Try to attach UE${ue_id} to NRCELL-${cell_id:\d+} second BWP with 5QI-${5qi_id} bearer and verify that it is rejected due to admission control
    ${qos_flow_id}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi_id}
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCSetupRequest
    EXPECT FLOW: AMF1 NGAP initialContextSetupFailure
    EXPECT FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCRelease

    Execute egate command  cmd=smf_param id=1 additional_qosflows_to_activate=${qos_flow_id}
    Attach UE${ue_id} without ICS to gNB2 cell${cell_id}
    ${pdu_id}    Get From Dictionary    ${session_name_to_pdu}   initial
    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} gw=${current_gw_id} nwslice=1
    ...     pass_regexp=Received Initial Context Setup Failure from GNB
    Execute egate command  cmd=smf_param id=1 reset

    PASS FLOW: UE_${ue_id} NR-RRC RRCSetupRequest
    PASS FLOW: AMF1 NGAP initialContextSetupFailure
    PASS FLOW: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    PASS FLOW: UE_${ue_id} NR-RRC RRCRelease

Attach UE${ue_id:\d+} to gNB${gnb_id:\d+} NRCELL-${cell_id:\d+} with 1 non-GBR and 1 GBR 5QI${5qi_id} bearer
    ${qos_flow_id}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi_id}
    Execute egate command  cmd=smf_param id=1 additional_qosflows_to_activate=${qos_flow_id}
    Attach UE${ue_id} to gNB${gnb_id} cell${cell_id} with ICS during PDU session setup
    Execute egate command  cmd=smf_param id=1 reset

Run ${rate}Mbps ${direction:UL|DL|UL and DL} traffic on UEs[${ue_first:\d+}-${ue_last:\d+}] PDU1 QFI${qfi_id:\d+} and wait ${seconds:\d+} seconds
    FOR    ${ue}    IN RANGE    ${ue_first}    ${ue_last}+1
        Run Keyword And Continue On Failure
        ...    Run ${rate}Mbps ${direction} traffic on UE${ue} PDU1 QFI${qfi_id} and wait 0 seconds
    END
    Sleep    ${seconds}

Verify ${rate}Mbps ${direction:UL|DL|UL and DL} traffic on UEs[${ue_first:\d+}-${ue_last:\d+}] PDU1 QFI${qfi_id:\d+}
    FOR    ${ue}    IN RANGE    ${ue_first}    ${ue_last}+1
        Run Keyword And Continue On Failure
        ...    Verify ${rate}Mbps ${direction} traffic on UE${ue} PDU1 QFI${qfi_id}
    END

Attach UE${ue_id:\d+} to gNB2 NRCELL-${cell_id:\d+} ${bwp_type} dedicated BWP profile and verify that PS-BWP is configured
    Attach UE${ue_id} to NRCELL-${cell_id}
    Verify that UE${ue_id} is configured with ${bwp_type} BWP profile after ICS to NRCELL-${cell_id}
    Beamforming (2 beams): Verify that UE${ue_id} is configured with PS-BWP after ICS

Attach UE${ue_id:\d+} to gNB2 NRCELL-${cell_id:\d+} ${bwp_type} dedicated BWP profile and verify that PS-BWP is NOT configured
    Attach UE${ue_id} to NRCELL-${cell_id}
    Verify that UE${ue_id} is configured with ${bwp_type} BWP profile after ICS to NRCELL-${cell_id}
    Verify that UE${ue_id} is not configured with PS-BWP after ICS

Verify, that UE${ue_id:\d+} is switched: to dedicated BWP when traffic is started, to PS BWP when traffic is stopped
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=30    pass_regexp=Bwp Switched from bwpId 2 to 1
    sleep    10
    Verify 30Mbps DL traffic on UE${ue_id} PDU1 QFI1
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl             pass_regexp=Bwp Switched from bwpId 1 to 2

Verify, that UE${ue_id:\d+} is NOT switched: to dedicated BWP when traffic is started, to PS BWP when traffic is stopped
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=30    fail_regexp=Bwp Switched from bwpId 2 to 1
    Sleep    10
    Verify 30Mbps DL traffic on UE${ue_id} PDU1 QFI1
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl             fail_regexp=Bwp Switched from bwpId 1 to 2

Modify PS-BWP on NRCELL-1 to 40Mhz (size of small BWP1), on NRCELL-2 to 60Mhz (size of second BWP2)
    ${ps_bwp_size}  catenate    {'MOC': 'BWP_PROFILE', 'ID': '71', 'locationAndBandwidthDl': [{'cRbSizeDl': 'n106'}]},
    ...                         {'MOC': 'BWP_PROFILE', 'ID': '70', 'locationAndBandwidthDl': [{'cRbSizeDl': 'n162'}]}
    Configure  [${ps_bwp_size}]

Restore PS-BWP on NRCELL-1 to 20Mhz, on NRCELL-2 to 50Mhz
    ${ps_bwp_size}  catenate    {'MOC': 'BWP_PROFILE', 'ID': '71', 'locationAndBandwidthDl': [{'cRbSizeDl': 'n51'}]},
    ...                         {'MOC': 'BWP_PROFILE', 'ID': '70', 'locationAndBandwidthDl': [{'cRbSizeDl': 'n133'}]},
    Configure  [${ps_bwp_size}]

Attach UE${ue_id:\d+} to NRCELL-${cell_id:\d+} with ${bwp_type} BWP (UeConnectionEstablishmentMode = useInitialBwp, actSmallestRRCSetup = False)
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCSetup
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfiguration
    Attach UE${ue_id} without ICS to gNB2 cell${cell_id}
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW: UE_${ue_id} NR-RRC RRCSetup

    ${flow}=     Get Flow Name    RRCSetup    device=UE_${ue_id}    protocol=NR-RRC
    Verify That Message Fulfills Query
    ...     (firstActiveDownlinkBWP-Id eq 0) and (firstActiveUplinkBWP-Id eq 0)
    ...     and
    ...     (initialDownlinkBWP contains (setup is present)) and (initialUplinkBWP contains (setup is present))
    ...     message_alias=RRCSetup
    ...     flow_alias=${flow}

    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    Add to UE${ue_id} initial PDU session with ICS
    PASS FLOW: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    ${flow}=     Get Flow Name    RRCReconfiguration    device=UE_${ue_id}    protocol=NR-RRC
    Verify That Message Fulfills Query
    ...     (firstActiveDownlinkBWP-Id eq 1) and (firstActiveUplinkBWP-Id eq 1)
    ...     and
    ...     (initialDownlinkBWP contains (release is present)) and (initialUplinkBWP contains (release is present))
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow}

    Verify that UE${ue_id} is configured with ${bwp_type} BWP profile after ICS to NRCELL-${cell_id}

Attach UE${ue_id:\d+} to NRCELL-${cell_id:\d+} with ${bwp_type} BWP (UeConnectionEstablishmentMode = useInitialBwp, actSmallestRRCSetup = True)
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCSetup
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfiguration
    Attach UE${ue_id} without ICS to gNB2 cell${cell_id}
    PASS FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW: UE_${ue_id} NR-RRC RRCSetup

    ${flow}=     Get Flow Name    RRCSetup    device=UE_${ue_id}    protocol=NR-RRC
    Verify That Message Fulfills Query
    ...     (firstActiveDownlinkBWP-Id eq 0) and (firstActiveUplinkBWP-Id eq 0)
    ...     and
    ...     (initialDownlinkBWP is not present) and (initialUplinkkBWP is not present)
    ...     message_alias=RRCSetup
    ...     flow_alias=${flow}

    ${flow}=     Get Flow Name    RRCReconfiguration    device=UE_${ue_id}    protocol=NR-RRC
    Verify That Message Fulfills Query
    ...     (firstActiveDownlinkBWP-Id eq 0) and (firstActiveUplinkBWP-Id eq 0)
    ...     and
    ...     (initialDownlinkBWP contains (setup is present)) and (initialUplinkBWP contains (setup is present))
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow}

    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    Add to UE${ue_id} initial PDU session with ICS
    PASS FLOW: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    ${flow}=     Get Flow Name    RRCReconfiguration    device=UE_${ue_id}    protocol=NR-RRC
    Verify That Message Fulfills Query
    ...     (firstActiveDownlinkBWP-Id eq 1) and (firstActiveUplinkBWP-Id eq 1)
    ...     and
    ...     (initialDownlinkBWP contains (release is present)) and (initialUplinkBWP contains (release is present))
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow}

    Verify that UE${ue_id} is configured with ${bwp_type} BWP profile after ICS to NRCELL-${cell_id}

Attach UEs with traffic until first UE is not configured with ulcg2
    [Arguments]    ${ue_first}    ${ue_last}    ${cell_id}    ${traffic_type}    ${traffic_rate}=20
    Set test variable    ${attached_ues}      0
    Set test variable    ${ue_was_rejected}    ${FALSE}
    FOR    ${ue}    IN RANGE    ${ue_first}    ${ue_last}+1
        ${ue_id}=    Convert To String  ${ue}
        Attach UE${ue_id} to NRCELL-${cell_id}
        Verify that UE${ue_id} is configured with large BWP profile after ICS to NRCELL-${cell_id}

        ${status}=     Run Keyword And Return Status
        ...    Verify if UE${ue_id} is configured with ulcg2
        Run Keyword If  ${status} == ${FALSE}
        ...    Set Test Variable  ${ue_was_rejected}  ${TRUE}
        Exit For Loop if   ${status} == ${FALSE}

        ${attached_ues}=    Evaluate    ${attached_ues} + 1

        Run ${traffic_rate}Mbps ${traffic_type} traffic on UE${ue_id} PDU1 QFI1 and wait 10 seconds
    END
    Run Keyword If    ${ue_was_rejected}==${FALSE}
    ...    Fail    All UEs were accepted by admission control, TC can not be continued. You should increase range of attached UEs.
    [Return]    ${attached_ues}

Attach UEs with non-GBR ULCG2 traffic until first UE is not configured with uplink configured grant
    [Arguments]    ${ue_first}    ${ue_last}    ${cell_id}    ${bwp}    ${traffic_rate}=5
    Set test variable    ${ues_with_ulcg2}      0
    Set test variable    ${ue_without_ulcg2}    ${FALSE}
    FOR    ${ue}    IN RANGE    ${ue_first}    ${ue_last}+1
        ${ue_id}=    Convert To String  ${ue}
        Attach UE${ue_id} to NRCELL-${cell_id}

        ${status}=     Run Keyword And Return Status
        ...    Verify if UE${ue_id} is configured with uplink configured grant
        Run Keyword If  ${status} == ${FALSE}
        ...    Set Test Variable  ${ue_without_ulcg2}  ${TRUE}
        Exit For Loop if   ${status} == ${FALSE}

        ${ues_with_ulcg2}=    Evaluate    ${ues_with_ulcg2} + 1

       CB008954_common_keywords.Run ${traffic_rate}Mbps UL traffic on UE${ue_id} PDU1 QFI1 and wait 5 seconds
    END

    Run Keyword If    ${ues_with_ulcg2}==${0}
    ...    Fail    Any UE was configured with uplink configured grant. TC can not be continued
    Run Keyword If    ${ue_without_ulcg2}==${FALSE}
    ...    Fail    All UEs were accepted for uplink configured grant. TC can not be continued. You should increase range of attached UEs.

    Set Test Variable    ${succ_ulcg2_ue_bwp${bwp_profiles_names}[${bwp}]}    ${ues_with_ulcg2}
    ${ues_requested_to_attach}=   Evaluate    ${ues_with_ulcg2} + ${1}
    Set Test Variable    ${req_ulcg2_ue_bwp${bwp_profiles_names}[${bwp}]}    ${ues_requested_to_attach}

Verify if UE${ue_id} is configured with uplink configured grant
    ${flow}=     Get Flow Name    RRCReconfiguration    device=UE_${ue_id}    protocol=NR-RRC
    Verify That Message Fulfills Query
    ...     configuredGrantConfig is present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow}

Verify UL traffic on UEs with uplink configured grant
    Set test variable    ${traffic_value}      0
    FOR    ${ue}    IN RANGE    1   ${succ_ulcg2_ue_bwp3}+1
        ${new_traffic}=     Run Keyword
        ...    Return UL traffic rate on PDU-1 QFI-1 for UE${ue}
        ${traffic_value}=    Evaluate    ${traffic_value} + ${new_traffic}
    END
    Should Be True   ${traffic_value}  > ${0}

Verify UL traffic on UEs with GBR bearers
    Set test variable    ${traffic_value}      0
    FOR    ${ue}    IN RANGE    41   41+${succ_ue_bwp1}
        ${new_traffic}=     Run Keyword
        ...    Return UL traffic rate on PDU-1 QFI-2 for UE${ue}
        ${traffic_value}=    Evaluate    ${traffic_value} + ${new_traffic}
    END
    FOR    ${ue}    IN RANGE    31   31+${succ_ue_bwp2}
        ${new_traffic}=     Run Keyword
        ...    Return UL traffic rate on PDU-1 QFI-2 for UE${ue}
        ${traffic_value}=    Evaluate    ${traffic_value} + ${new_traffic}
    END
    Should Be True   ${traffic_value}  > ${0}

Save number of attached UEs for counters
    Set test variable    ${preemptable_ues}      ${succ_ue_bwp2}
    ${preemptable_ues_flows}=    Evaluate    ${succ_ue_bwp2} * 2
    Set test variable    ${preemptable_ues_flows}      ${preemptable_ues_flows}

Attach UE${ue_id:\d+} to NRCELL-${cell_id:\d+} and expect it to fail due to missing RRC Reconfiguration Complete message
    Execute egate command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=drop

    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup
    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

    Execute egate command   cmd=amf_param id=1 empty_pdu_session_list=on send_ics_registration=on
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute egate command
    ...  cmd=ue_register id=${ue_id}
    ...  pass_regexp=Received REGISTRATION COMPLETE
    Execute egate command  cmd=amf_param id=1 empty_pdu_session_list=off send_ics_registration=off

    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup
    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    PASS FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

Trigger RRC Reestablishment for UE${ue_id:\d+} to NRCELL-${cell_id:\d+} and expect it to fail due to missing RRC Reconfiguration Complete message
    Execute egate command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=drop

    Trigger reestablishment for UE${ue_id} to gNB2 NRCELL-${cell_id}
    PASS FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReestablishment
    PASS FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    PASS FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReconfiguration
    FAIL FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Trigger intra-gNB inter-freq HO for UE${ue_id:\d+} to gNB2 NRCELL-${cell_id:\d+} and expect it to fail due to missing RRC message
    Trigger UE${ue_id} to send A2 measurement and wait for next measurements configuration

    Execute egate command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=drop

    EXPECT FLOW: UE_${ue_id} NR-RRC MeasurementReport
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    ${physcellid}=    get enb parameter value    NRCELL-${cell_id}    physCellId
#    ${cell_id_freq}=    get enb parameter value    NRCELL-${cell_id}    arfcnSsbPbch
    ${ue_measurements_in_egate}=    execute egate command and wait for data    cmd=ue_meas_cfg_disp id=${ue_id}
    ${meas_id}=  Wait until keyword succeeds    10s    2s
    ...    Get measId matching reportConfig with eventA5 and measObjectId with 390050 for UE${ue_id}
    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A5 srsrp_nr=0 phycell_id=${physcellid} nrsrp_nr=127
    Wait for next measurement  UE_${ue_id}
    PASS FLOW: UE_${ue_id} NR-RRC MeasurementReport
    PASS FLOW: UE_${ue_id} NR-RRC RRCReconfiguration
    FAIL FLOW: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify that counters ${counters} for NRCELLs [1,2,3,4] are equal [${c1_val}], [${c2_val}], [${c3_val}], [${c4_val}]
    Verify that counters ${counters} are equal [${c1_val}] in NRCELL-1 in gNB2
    Verify that counters ${counters} are equal [${c2_val}] in NRCELL-2 in gNB2
    Verify that counters ${counters} are equal [${c3_val}] in NRCELL-3 in gNB2
    Verify that counters ${counters} are equal [${c4_val}] in NRCELL-4 in gNB2

Trigger UE${ue_id:\d+} to send A1 measurement above ${technology:FDD|TDD} SCell addition threshold
    &{scell_addition_thresholds}=   Create Dictionary   FDD=31    TDD=61

    EXPECT FLOW: UE_${ue_id} NR-RRC MeasurementReport
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfiguration

    ${meas_id}=  Wait until keyword succeeds    10s    2s
    ...    Get measId matching reportConfig with eventA1 for UE${ue_id}

    Execute egate command
    ...     cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${scell_addition_thresholds}[${technology}]
    PASS FLOW: UE_${ue_id} NR-RRC MeasurementReport
    PASS FLOW: UE_${ue_id} NR-RRC RRCReconfiguration

Trigger UE${ue_id:\d+} SCell release due to poor radio link conditions
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    ${meas_id}=  Wait until keyword succeeds    10s    2s
    ...    Get measId matching reportConfig with eventA2 for UE${ue_id}

    Execute egate command
    ...     cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=2 scell_rsrp=4
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

Verify that UE${ue_id:\d+} SCell was released
    verify that message fulfills query  (
    ...                                   measIdToRemoveList is present
    ...                                 )
    ...    message_alias=RRCReconfiguration
    ...    flow_alias=UE_${ue_id}_NR-RRC_RRCReconfiguration

Run ${traffic_rate:\d+}Mbps ${direction:(UL|DL)} traffic on UE${ue_id:\d+} PDU${pdu_id:\d+} QFI${qfi_id:\d+} and wait ${seconds:\d+} seconds
    ${dir_param}    Convert To Lowercase    ${direction}
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${dir_param} mbps=${traffic_rate}
    ...  pass_regexp=Started .* Internal traffic
    BuiltIn.Sleep    ${seconds}

Run ${traffic_rate:\d+}Mbps ${direction:(UL|DL)} traffic on split bearer for UE${ue_id:\d+} and wait ${seconds:\d+} seconds
    ${dir_param}    Convert To Lowercase    ${direction}
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} id=${SPLIT_BEARER_ID} dir=${dir_param} mbps=${traffic_rate}
    ...  pass_regexp=UE ${ue_id}: UDP ${direction} TRF
    BuiltIn.Sleep    ${seconds}

Run ${traffic_rate:\d+}Mbps UL and DL traffic on split bearer for UE${ue_id:\d+} and wait ${seconds:\d+} seconds
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} id=${SPLIT_BEARER_ID} dir=ul mbps=${traffic_rate}
    ...  pass_regexp=UE ${ue_id}: UDP UL TRF
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} id=${SPLIT_BEARER_ID} dir=dl mbps=${traffic_rate}
    ...  pass_regexp=UE ${ue_id}: UDP DL TRF
    BuiltIn.Sleep    ${seconds}

Run ${traffic_rate:\d+}Mbps UL and DL traffic on UE${ue_id:\d+} PDU${pdu_id:\d+} QFI${qfi_id:\d+} and wait ${seconds:\d+} seconds
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=${traffic_rate}
    ...  pass_regexp=Started Uplink Internal traffic
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=${traffic_rate}
    ...  pass_regexp=Started Downlink Internal traffic
    BuiltIn.Sleep    ${seconds}
