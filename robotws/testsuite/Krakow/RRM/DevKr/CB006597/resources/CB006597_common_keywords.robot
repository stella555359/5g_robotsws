*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
Resource    CB006597-verify_counters.robot
Resource    ../../../resources/Robot/common_settings.robot
Library     ta_measurements
Resource    ../../resources/verifiers.robot
Resource    ${CURDIR}/CB006597-verify_counters.robot
Resource    ../../resources/yaml_config_paths.robot
Library     ../../../resources/Python/floating_counters.py
Library     ../../../resources/Python/utilities.py
Library     ../../resources/python/mock_stop_egate.py

*** Variables ***
${feature_activation_yaml}=  ${CURDIR}/../config/yaml_config/feature_activation.yaml
${feature_deactivation_yaml}=  ${CURDIR}/../config/yaml_config/feature_deactivation.yaml

*** Keywords ***
Run Setup
    Log To Console    Setup started
    Setup emss      bts_id=1
    ${run_update}    get variable value      ${configure}    "True"     # do not ever change that line!
    Run Keyword if  ${run_update} == "True"
    ...    Run keywords
    ...    reach onair with retries    lua_cfg=${LUA_CFG}
    ...    AND    Log To Console    After Reach OnAir
    ...    AND    Do not stop egate and daemon
    Run Keyword if  ${run_update} != "True"
    ...    Setup egate  egate_port=20000  alias=default
    Configure    ${disable_ciphering_yaml_path}
    Setup devices aliases

Setup devices aliases
    Create ues alias
    ...   alias=UE
    ...   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.31
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Verify that in ${message} for ${ue_alias} ${field} is set to ${value}
    ${flow_alias_rrc}=     Get flow name
    ...     ${message}
    ...     device=${ue_alias}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     ${field} contains ('${value}')
    ...     message_alias=${message}
    ...     flow_alias=${flow_alias_rrc}

Verify that in ${message} for ${ue_alias} ${field} is not present
    ${flow_alias_rrc}=     Get flow name
    ...     ${message}
    ...     device=${ue_alias}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     ${field} is not present
    ...     message_alias=${message}
    ...     flow_alias=${flow_alias_rrc}

Verify that in uERadioCapabilityInfoIndication for UE_1 releasePreference-r16 is set to supported
    ${flow_alias_ue_cap}=     Get flow name
    ...     procedure=uERadioCapabilityInfoIndication
    ...     protocol=NGAP
    ...     device=AMF1
    Verify That Message Fulfills Query
    ...     (powSav-Parameters-r16 contains (powSav-ParametersCommon-r16 contains (releasePreference-r16 contains ('supported'))))
    ...     message_alias=UERadioCapabilityInfoIndication
    ...     flow_alias=${flow_alias_ue_cap}

Verify that in uERadioCapabilityInfoIndication for UE_11 releasePreference-r16 is not present
    ${flow_alias_ue_cap}=     Get flow name
    ...     procedure=uERadioCapabilityInfoIndication
    ...     protocol=NGAP
    ...     device=AMF1
    Verify That Message Fulfills Query
    ...     releasePreference-r16 is not present
    ...     message_alias=UERadioCapabilityInfoIndication
    ...     flow_alias=${flow_alias_ue_cap}

Trigger UE${ue_id:\d+} to send UAI with RRC preferred state of ${UAI_session_type}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UEAssistanceInformation
    Execute egate command   cmd=ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=${UAI_session_type}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UEAssistanceInformation

Try to trigger UE${ue_id:\d+} to send UAI with RRC preferred state of ${UAI_session_type} and fail
    EXPECT FLOW[timeout=3]: UE_${ue_id} NR-RRC UEAssistanceInformation
    Execute egate command   cmd=ue_assistance_send_nr ue_id=${ue_id} state=${UAI_session_type}
    FAIL FLOW[timeout=3]: UE_${ue_id} NR-RRC UEAssistanceInformation

Attach UE${ue_id:\d+} with one PDU session without traffic to real gNB then HO to sim gNB${gnb_id} with 1 nonGBR and 1 GBR 5QI${5qi_id:\d+} QoS flow
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=2 cell=1
    Set up inter gNB Handover for UE${ue_id}
    start_observing_measurements      UE_${ue_id}       technology=5G
    Attach UE${ue_id} to gNB2 cell1 with ICS without PDU session
    Add to UE${ue_id} initial PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi_id} QoS flow

    Execute egate command   cmd=meas_cfg_ue_disp id=${ue_id}
    ${meas_id}=     Get measId matching reportConfig with eventA5 for UE${ue_id}
    UE${ue_id} triggers Inter-gNB Handover from real gNB2 to simulated gNB3 by sending A5 measurement id=${meas_id}

Add to UE${ue_id:\d+} ${session_type:(initial|second|third)} PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi_id:\d+} QoS flow
    Execute egate command  cmd=smf_param id=1 additional_qosflows_to_activate=${5qi_id}

    Add to UE${ue_id} ${session_type} PDU session after ICS

    Execute egate command  cmd=smf_param id=1 reset

    Verify in NGAP that QoS flows for 5QIs [5,${5qi_id}] were successfully added to new PDU session
    Verify in RRCReconfiguration that UE${ue_id} 2 DRBs were added

Verify in NGAP that QoS flows for 5QIs [${5qis}] were successfully added to new PDU session
    @{5qis_to_add_list}=    Split To List    ${5qis}
    ${5qis_to_add_tuple}=   Split To Integers Tuple    ${5qis}
    ${length_of_5qis_to_add_list}=  Get length    ${5qis_to_add_list}

    ${flow}=    Get flow name
    ...     procedure=pDUSessionResourceSetup
    ...     device=AMF1

    Run Keyword If    ${length_of_5qis_to_add_list} > 0
    ...     Verify That Message Fulfills Query
    ...     ( (length(QosFlowSetupRequestList) eq ${length_of_5qis_to_add_list})
    ...       and
    ...       (fiveQI contains ${5qis_to_add_tuple}) )
    ...     message_alias=PDUSessionResourceSetupRequest
    ...     flow_alias=${flow}

    Run Keyword If    ${length_of_5qis_to_add_list} == 0
    ...     Verify That Message Fulfills Query
    ...     (QosFlowSetupRequestList is not present)
    ...     message_alias=PDUSessionResourceSetupRequest
    ...     flow_alias=${flow}

    Verify That Message Fulfills Query
    ...     (PDUSessionResourceFailedToModifyListModRes is not present)
    ...     message_alias=PDUSessionResourceSetupResponse
    ...     flow_alias=${flow}

    Run Keyword If    ${length_of_5qis_to_add_list} > 0
    ...     Verify That Message Fulfills Query
    ...     (length(associatedQosFlowList) eq ${length_of_5qis_to_add_list})
    ...     message_alias=PDUSessionResourceSetupResponse
    ...     flow_alias=${flow}

    Run Keyword If    ${length_of_5qis_to_add_list} == 0
    ...     Verify That Message Fulfills Query
    ...     (associatedQosFlowList is not present)
    ...     message_alias=PDUSessionResourceSetupResponse
    ...     flow_alias=${flow}


Perform intra-gNB handover from cell${src_cell} to cell${tgt_cell} for UE${ue_id:\d+}
    EXPECT FLOW: UE_${ue_id} NR-RRC MeasurementReport triggering intra-gNB HO
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfiguration with target cell configuration
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    UE${ue_id} triggers Intra-gNB Handover from gNB2 cell${src_cell} to cell${tgt_cell} by sending A3 measurement

    PASS FLOW: UE_${ue_id} NR-RRC MeasurementReport triggering intra-gNB HO
    PASS FLOW: UE_${ue_id} NR-RRC RRCReconfiguration with target cell configuration
    PASS FLOW: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify that in RRCReconfiguration for UE_${ue_id:\d+} releasePreference parameters are present
    Verify that in RRCReconfiguration for UE_${ue_id} releasePreferenceConfig-r16 is set to setup
    Verify that in RRCReconfiguration for UE_${ue_id} releasePreferenceProhibitTimer-r16 is set to s0
    Verify that in RRCReconfiguration for UE_${ue_id} connectedReporting is set to true

Verify that in RRCReconfiguration for UE_${ue_id:\d+} releasePreference parameters are not present
    Verify that in RRCReconfiguration for UE_${ue_id} releasePreferenceConfig-r16 is not present
    Verify that in RRCReconfiguration for UE_${ue_id} releasePreferenceProhibitTimer-r16 is not present
    Verify that in RRCReconfiguration for UE_${ue_id} connectedReporting is not present

Fail to trigger UE${ue_id} to send UAI with RRC preferred state of ${UAI_session_type}
    EXPECT FLOW[timeout=3]: UE_${ue_id} NR-RRC UEAssistanceInformation
    Execute egate command   cmd=ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=${UAI_session_type}
    FAIL FLOW[timeout=3]: UE_${ue_id} NR-RRC UEAssistanceInformation

Set sim gNB to support ReleasePreference-r16
    Execute egate command  cmd=xn_handover_gnb_preparation_param id=3 ReleasePreferenceConfig=setup

Trigger reestablishment for UE${ue_id}
    Execute egate command  cmd=ue_rrc_reestablish id=${ue_id} gnb=2 cell=1
