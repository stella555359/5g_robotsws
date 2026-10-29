*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...      - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...      - Michał Szymakowski <michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     Collections
Library     ta_pcmd
Library     ../../../../sim_resources/Krk_regression/rrm_resources/PCMD/verifier_msg_for_pcmd.py
Library     ../../../../sim_resources/Krk_regression/rrm_resources/Python/utilities.py

*** Variables ***
${CuUeSetupRecord}=
...         ${CURDIR}/record_yamls/ueSetupTraceRecord_with_guami.yaml
${CuUeSetupRecord_no_guami}=
...         ${CURDIR}/record_yamls/ueSetupTraceRecord_no_guami.yaml
${CuUeSetupRecord_guami_amf2}=
...         ${CURDIR}/record_yamls/ueSetupTraceRecord_with_guami_amf2.yaml
${CuUeSetupRecord_guami_failed_handover}=
...         ${CURDIR}/record_yamls/ueSetupTraceRecord_with_guami_no_amfUeNgapId.yaml
${CuUeSetupRecord_no_amfUeNgapId}=
...         ${CURDIR}/record_yamls/ueSetupTraceRecord_with_guami_amf2_no_amfUeNgapId.yaml
${pduSessionResourceInfoRecord_setup_single}=
...         ${CURDIR}/record_yamls/pduSessionResourceInfoRecord_setup_single.yaml
${pduSessionResourceInfoRecord_setup_single_GBR}=
...         ${CURDIR}/record_yamls/pduSessionResourceInfoRecord_setup_single_GBR.yaml
${pduSessionResourceInfoRecord_setup_1_session_2_flows}=
...         ${CURDIR}/record_yamls/pduSessionResourceInfoRecord_setup_1_session_2_flows.yaml
${pduSessionResourceInfoRecord_setup_1_session_1_GBR_1_nonGBR}=
...         ${CURDIR}/record_yamls/pduSessionResourceInfoRecord_setup_1_session_1_GBR_1_nonGBR_setup.yaml
${pduSessionResourceInfoRecord_setup_2_session_2_flows}=
...         ${CURDIR}/record_yamls/pduSessionResourceInfoRecord_setup_2_sessions_2_flows.yaml
${pduSessionResourceInfoRecord_setup_2_session_3_flows}=
...         ${CURDIR}/record_yamls/pduSessionResourceInfoRecord_setup_2_sessions_3_flows.yaml
${pduSessionResourceInfoRecord_setup_1_setup_1_setup_1_release}=
...         ${CURDIR}/record_yamls/pduSessionResourceInfoRecord_setup_1_session_1_flow_setup_1_release.yaml
${pduSessionResourceInfoRecord_setup_2_GBR_setup_1_release}=
...         ${CURDIR}/record_yamls/pduSessionResourceInfoRecord_setup_1_session_2_GBR_flows_setup_1_release.yaml
${pduSessionResourceInfoRecord_release_single}=
...         ${CURDIR}/record_yamls/pduSessionResourceInfoRecord_release_single.yaml
${pduSessionResourceInfoRecord_release_2_sessions}=
...         ${CURDIR}/record_yamls/pduSessionResourceInfoRecord_release_2_sessions.yaml
${pduSessionResourceInfoRecord_release_single_qos_flow}=
...         ${CURDIR}/record_yamls/pduSessionResourceInfoRecord_release_single_qos_flow.yaml
${pduSessionResourceInfoRecord_release_2_qos_flows}=
...         ${CURDIR}/record_yamls/pduSessionResourceInfoRecord_release_2_qos_flows.yaml
${pduSessionResourceInfoRecord_setup_1_session_1_GBR_setup_1_session_1_nonGBR}=
...         ${CURDIR}/record_yamls/pduSessionResourceInfoRecord_setup_1_session_1_GBR_1_session_1_nonGBR.yaml
${pduSessionResourceInfoRecord_setup_1_session_1_flow_release_1_session_1_flow}=
...         ${CURDIR}/record_yamls/pduSessionResourceInfoRecord_setup_1_session_1_flow_release_1_session_1_flow.yaml
${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}=
...         ${CURDIR}/record_yamls/pduSessionResourceInfoRecord_ho_1_session_1_GBR_1_nonGBR_setup_1_session_release.yaml
${pduSessionResourceInfoRecord_setup_2_sessions_1_setup_1_release}=
...         ${CURDIR}/record_yamls/pduSessionResourceInfoRecord_setup_2_sessions_1_setup_1_release.yaml

${record_present_timeout}       10
${no_record_timeout}            10

*** Keywords ***
############## test C1 ##########################################
Verify CuUeSetupTraceRecord in testC1
    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=success
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    ...     message_name=DownlinkNASTransport
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord_no_guami}

    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=success
    ...     yaml_path=${CuUeSetupRecord}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord}
    ...     message_name=InitialContextSetupResponse
    ...     skip_value_removal=${TRUE}      # must be left for next record during PDU session addition
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord}

    Wait for PCMD records
    ...     record_num=2
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${record_present_timeout}
    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=3
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${no_record_timeout}
    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=0               # already waited in first record

    Perform Records Verification

Verify PduSessionResourceInfoTraceRecord in testC1
    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=success
    ...     yaml_path=${CuUeSetupRecord}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord}
    ...     message_name=InitialContextSetupResponse
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord}

    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceSetupReq
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=setupPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=setupQosFlows
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set_variable_from_message_for_record_yaml   yaml_path=${pduSessionResourceInfoRecord_setup_single}
    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=0

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${no_record_timeout}
    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=0               # already waited in first record

    Perform Records Verification

############## test C2 ##########################################
Verify first ${records} PCMD records in testC2
    Log to console    Verifying ${records}
    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=success
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    ...     message_name=DownlinkNASTransport
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord_no_guami}

    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=success
    ...     yaml_path=${CuUeSetupRecord}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord}
    ...     message_name=InitialContextSetupResponse
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord}

    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=setupPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=initialCtxSetup
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=setupQosFlows
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=InitialContextSetupRequest
    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}

    Wait for PCMD records
    ...     record_num=2
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${record_present_timeout}
    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=3
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${no_record_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=0

    Perform Records Verification

Verify second ${records} PCMD records in testC2
    Log to console    Verifying ${records}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceSetupReq
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=setupPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=setupQosFlows
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=PDUSessionResourceSetupRequest
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}
    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}
    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=1
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=0
    Perform Records Verification

Verify third ${records} PCMD records in testC2
    Log to console    Verifying ${records}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceModifyOperation
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=modifiedPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=setupQosFlows
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=PDUSessionResourceModifyRequest
    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=PDUSessionResourceSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=PDUSessionResourceSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=PDUSessionResourceSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=PDUSessionResourceSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}
    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}
    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=1
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=0
    Perform Records Verification

Verify fourth ${records} PCMD records in testC2
    Log to console    Verifying ${records}
    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=success
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    ...     message_name=DownlinkNASTransport
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord_no_guami}

    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=success
    ...     yaml_path=${CuUeSetupRecord}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord}
    ...     message_name=InitialContextSetupResponse
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord}

    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=initialCtxSetup
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_3_flows}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_3_flows}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=setupPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_3_flows}
    ${setupQosFlows}=    create_list_of_the_same_elements      element=setupQosFlows        list_length=2
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=${setupQosFlows}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_3_flows}

    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_3_flows}
    ...     message_name=InitialContextSetupRequest

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_3_flows}

    Wait for PCMD records
    ...     record_num=2
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${record_present_timeout}
    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=0

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=3
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${no_record_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=0

    Perform Records Verification

############## test C3 ##########################################
Verify ${records} PCMD records in testC3
    Log to console    Verifying ${records}
    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=success
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    ...     message_name=DownlinkNASTransport
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord_no_guami}

    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=miscFailure
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=failedToSetupPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=initialCtxSetup
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=failedToSetupQosFlows
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=InitialContextSetupRequest
    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${record_present_timeout}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=0

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${no_record_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=0

    Perform Records Verification

############## test C4 ##########################################
Verify ${records} PCMD records in testC4
    Log to console    Verifying ${records}
    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=success
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    ...     message_name=DownlinkNASTransport
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord_no_guami}

    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=miscFailure
    ...     yaml_path=${CuUeSetupRecord}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord}
    ...     message_name=InitialContextSetupFailure
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord}

    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=miscFailure
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=failedToSetupPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=initialCtxSetup
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=failedToSetupQosFlows
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=InitialContextSetupRequest
    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}

    Wait for PCMD records
    ...     record_num=2
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${record_present_timeout}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=0

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=3
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${no_record_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=0

    Perform Records Verification

############## test C5 ##########################################
Verify ${records} PCMD records in testC5
    Log to console    Verifying ${records}
    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=success
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    ...     message_name=DownlinkNASTransport
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord_no_guami}

    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=success
    ...     yaml_path=${CuUeSetupRecord}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord}
    ...     message_name=InitialContextSetupResponse
    ...     skip_value_removal=${TRUE}
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord}

    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=success
    ...     yaml_path=${CuUeSetupRecord}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord}
    ...     message_name=InitialContextSetupResponse
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord}

    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceSetupReq
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=setupPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}
    ${setupQosFlows}=    create_list_of_the_same_elements      element=setupQosFlows        list_length=2
#    ${setupQosFlows}=    Evaluate        ['setupQosFlows']*2

    set variable for record yaml
    ...     variable=QosFlows
    ...     value=${setupQosFlows}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}
    ...     message_name=PDUSessionResourceSetupRequest
    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    Wait for PCMD records
    ...     record_num=3
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${record_present_timeout}
    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=4
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${no_record_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=0

    Perform Records Verification

############## test C6 ##########################################
Verify ${records} PCMD records in testC6
    Log to console    Verifying ${records}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceSetupReq
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=miscFailure
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=failedToSetupPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=failedToSetupQosFlows
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=PDUSessionResourceSetupRequest
    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Sleep    10

    Perform Records Verification

############## test C7 ##########################################
Verify first and second PduSessionResourceInfoTraceRecord in testC7
    Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

Verify third PduSessionResourceInfoTraceRecord in testC7
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceReleaseOperation
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=releasedPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single}

    set_variable_from_single_message_for_record_yaml
    ...   yaml_path=${pduSessionResourceInfoRecord_release_single}
    ...   message_name=PDUSessionResourceReleaseCommand

    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single}
    ...     message_name=PDUSessionResourceSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single}
    ...     message_name=PDUSessionResourceSetupRequest
    ...     field_name=sD

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}

    Perform Records Verification

Verify fourth ${record} in testC7
    Log to console    Verifying ${record}
    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}

############## test C8 ##########################################
Verify 3 PduSessionResourceInfoTraceRecords in testC8
     Wait for PCMD records
    ...     record_num=3
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

Verify PduSessionResourceInfoTraceRecord in testC8
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_sessions}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceReleaseOperation
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_sessions}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=releasedPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_sessions}

    ${pduSessionIds}=       Create list       1       3
    set variable for record yaml
    ...     variable=pduSessionId
    ...     value=${pduSessionIds}
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_sessions}

    ${ssT}=    get_variable_from_single_message_for_single_field
    ...     message_name=PDUSessionResourceSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    ${ssT_list}=    create_list_of_the_same_elements      element=${ssT}[0]        list_length=2
    set variable for record yaml
    ...     variable=sst
    ...     value=${ssT_list}
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_sessions}

    ${sD}=    get_variable_from_single_message_for_single_field
    ...     message_name=PDUSessionResourceSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}   # list with single elem received due to save_pcmd_many_selected_values used
    ${sD_list}=    create_list_of_the_same_elements      element=${sD}[0]        list_length=2
    set variable for record yaml
    ...     variable=sd
    ...     value=${sD_list}
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_sessions}

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_sessions}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}

    Perform Records Verification

############### from 5GC001756-EA_PDU_modify_release_keywords.robot ###################
############## test EA1 ##########################################
Verify first ${records} in test EA1 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

Verify second ${records} in test EA1 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=miscFailure
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceModifyOperation
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=failedToModifyPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=failedToSetupQosFlows
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}

    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=PDUSessionResourceModifyRequest

    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}

    Perform Records Verification

Verify third ${records} in test EA1 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

Verify fourth ${records} in test EA1 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceModifyOperation
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=modifiedPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=setupQosFlows
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}

    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=PDUSessionResourceModifyRequest

    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}

    Perform Records Verification

Verify fifth ${records} in test EA1 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single_qos_flow}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceModifyOperation
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single_qos_flow}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=modifiedPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single_qos_flow}
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=releasedQosFlows
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single_qos_flow}

    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single_qos_flow}
    ...     message_name=PDUSessionResourceModifyRequest

    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single_qos_flow}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single_qos_flow}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single_qos_flow}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single_qos_flow}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single_qos_flow}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}

    Perform Records Verification

Verify sixth ${records} in test EA1 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceReleaseOperation
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=releasedPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single}

    set_variable_from_single_message_for_record_yaml
    ...   yaml_path=${pduSessionResourceInfoRecord_release_single}
    ...   message_name=PDUSessionResourceReleaseCommand

    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sD

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_release_single}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}

    Perform Records Verification

############## test EA2 ##########################################
Verify first ${records} in test EA2 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

Verify second ${records} in test EA2 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceModifyOperation
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=modifiedPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=setupQosFlows
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}

    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    ...     message_name=PDUSessionResourceModifyRequest

    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}

    Perform Records Verification

Verify third ${records} in test EA2 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceModifyOperation
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=modifiedPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=modifiedQosFlows
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}

    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    ...     message_name=PDUSessionResourceModifyRequest

    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}

    Perform Records Verification

Verify fourth ${records} in test EA2 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=miscFailure
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceModifyOperation
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=failedToModifyPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=failedToSetupQosFlows
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}

    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    ...     message_name=PDUSessionResourceModifyRequest

    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}

    Perform Records Verification

############## test EA3 ##########################################
Verify first ${records} in test EA3 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

Verify second ${records} in test EA3 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceModifyOperation
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=modifiedPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows}
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=setupQosFlows
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows}

    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows}
    ...     message_name=PDUSessionResourceModifyRequest

    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}

    Perform Records Verification

Verify third ${records} in test EA3 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_qos_flows}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceModifyOperation
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_qos_flows}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=modifiedPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_qos_flows}
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=releasedQosFlows
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_qos_flows}

    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_qos_flows}
    ...     message_name=PDUSessionResourceModifyRequest

    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_qos_flows}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_qos_flows}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_qos_flows}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_qos_flows}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_qos_flows}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}

    Perform Records Verification

Verify fourth ${records} in test EA3 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceModifyOperation
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=modifiedPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=setupQosFlows
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}

    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=PDUSessionResourceModifyRequest

    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}

    Perform Records Verification

Verify fifth ${records} in test EA3 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_GBR_setup_1_release}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceModifyOperation
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_GBR_setup_1_release}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=modifiedPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_GBR_setup_1_release}

    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_GBR_setup_1_release}
    ...     message_name=PDUSessionResourceModifyRequest

    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_GBR_setup_1_release}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_GBR_setup_1_release}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_GBR_setup_1_release}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_GBR_setup_1_release}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_GBR_setup_1_release}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}

    Perform Records Verification

Verify sixth ${records} in test EA3 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_qos_flows}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceModifyOperation
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_qos_flows}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=modifiedPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_qos_flows}
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=releasedQosFlows
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_qos_flows}

    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_qos_flows}
    ...     message_name=PDUSessionResourceModifyRequest

    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_qos_flows}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_qos_flows}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_qos_flows}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_qos_flows}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_release_2_qos_flows}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}

    Perform Records Verification

Verify seventh ${records} in test EA3 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_GBR_1_nonGBR}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceModifyOperation
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_GBR_1_nonGBR}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=modifiedPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_GBR_1_nonGBR}

    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_GBR_1_nonGBR}
    ...     message_name=PDUSessionResourceModifyRequest

    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_GBR_1_nonGBR}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_GBR_1_nonGBR}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_GBR_1_nonGBR}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_GBR_1_nonGBR}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_GBR_1_nonGBR}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}

    Perform Records Verification

Verify eighth ${records} in test EA3 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_setup_1_setup_1_release}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceModifyOperation
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_setup_1_setup_1_release}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=modifiedPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_setup_1_setup_1_release}
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=failedToSetupQosFlows
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_setup_1_setup_1_release}

    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_setup_1_setup_1_release}
    ...     message_name=PDUSessionResourceModifyRequest

    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_setup_1_setup_1_release}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_setup_1_setup_1_release}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_setup_1_setup_1_release}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_setup_1_setup_1_release}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_setup_1_setup_1_release}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}

    Perform Records Verification

################# test EA4    ##################
Verify first ${records} in test EA4 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

Verify second ${records} in test EA4 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

Verify third ${records} in test EA4 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceModifyOperation
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_GBR_setup_1_session_1_nonGBR}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_GBR_setup_1_session_1_nonGBR}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=modifiedPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_GBR_setup_1_session_1_nonGBR}
    ${setupQosFlows}=    create_list_of_the_same_elements      element=setupQosFlows        list_length=2
#    ${setupQosFlows}=    Evaluate        ['setupQosFlows']*2

    set variable for record yaml
    ...     variable=QosFlows
    ...     value=${setupQosFlows}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_GBR_setup_1_session_1_nonGBR}

    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_GBR_setup_1_session_1_nonGBR}
    ...     message_name=PDUSessionResourceModifyRequest

    ${ssT}=    get_variable_from_single_message_for_single_field
    ...     message_name=PDUSessionResourceSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    ${ssT_list}=    create_list_of_the_same_elements      element=${ssT}[0]        list_length=2
    set variable for record yaml
    ...     variable=sst
    ...     value=${ssT_list}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_GBR_setup_1_session_1_nonGBR}

    ${sD}=    get_variable_from_single_message_for_single_field
    ...     message_name=PDUSessionResourceSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}   # list with single elem received due to save_pcmd_many_selected_values used
    ${sD_list}=    create_list_of_the_same_elements      element=${sD}[0]        list_length=2
    set variable for record yaml
    ...     variable=sd
    ...     value=${sD_list}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_GBR_setup_1_session_1_nonGBR}

    ${aggBitrateDL}=    get_variable_from_single_message_for_single_field
    ...     message_name=PDUSessionResourceSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    ${aggBitrateDL_list}=    create_list_of_the_same_elements      element=${aggBitrateDL}[0]        list_length=2
    set variable for record yaml
    ...     variable=dlBitRate
    ...     value=${aggBitrateDL_list}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_GBR_setup_1_session_1_nonGBR}

    ${aggBitrateUL}=    get_variable_from_single_message_for_single_field
    ...     message_name=PDUSessionResourceSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    ${aggBitrateUL_list}=    create_list_of_the_same_elements      element=${aggBitrateUL}[0]        list_length=2
    set variable for record yaml
    ...     variable=ulBitRate
    ...     value=${aggBitrateUL_list}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_GBR_setup_1_session_1_nonGBR}

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_GBR_setup_1_session_1_nonGBR}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=0

    Perform Records Verification

Verify fourth ${records} in test EA4 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceModifyOperation
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_flow_release_1_session_1_flow}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_flow_release_1_session_1_flow}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=modifiedPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_flow_release_1_session_1_flow}

    ${setupQosFlows}=    Evaluate        ['setupQosFlows', 'releasedQosFlows']
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=${setupQosFlows}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_flow_release_1_session_1_flow}

    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_flow_release_1_session_1_flow}
    ...     message_name=PDUSessionResourceModifyRequest

     ${ssT}=    get_variable_from_single_message_for_single_field
    ...     message_name=PDUSessionResourceSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    ${ssT_list}=    create_list_of_the_same_elements      element=${ssT}[0]        list_length=2
    set variable for record yaml
    ...     variable=sst
    ...     value=${ssT_list}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_flow_release_1_session_1_flow}

    ${sD}=    get_variable_from_single_message_for_single_field
    ...     message_name=PDUSessionResourceSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}   # list with single elem received due to save_pcmd_many_selected_values used
    ${sD_list}=    create_list_of_the_same_elements      element=${sD}[0]        list_length=2
    set variable for record yaml
    ...     variable=sd
    ...     value=${sD_list}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_flow_release_1_session_1_flow}

    ${aggBitrateDL}=    get_variable_from_single_message_for_single_field
    ...     message_name=PDUSessionResourceSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    ${aggBitrateDL_list}=    create_list_of_the_same_elements      element=${aggBitrateDL}[0]        list_length=2
    set variable for record yaml
    ...     variable=dlBitRate
    ...     value=${aggBitrateDL_list}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_flow_release_1_session_1_flow}

    ${aggBitrateUL}=    get_variable_from_single_message_for_single_field
    ...     message_name=PDUSessionResourceSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    ${aggBitrateUL_list}=    create_list_of_the_same_elements      element=${aggBitrateUL}[0]        list_length=2
    set variable for record yaml
    ...     variable=ulBitRate
    ...     value=${aggBitrateUL_list}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_flow_release_1_session_1_flow}

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_1_flow_release_1_session_1_flow}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=0

    Perform Records Verification

################# test EA5    ##################
Verify first ${records} in test EA5 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

Verify second ${records} in test EA5 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=pduSessionResourceModifyOperation
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=modifiedPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=setupQosFlows
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}

    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    ...     message_name=PDUSessionResourceModifyRequest

    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml       # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record
    set_variable_from_single_message_for_single_field_in_yaml        # taken from different message
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}
    ...     message_name=InitialContextSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}          # important , needed for pdu session modify record

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_single_GBR}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}

    Perform Records Verification

Verify third ${records} in test EA5 during ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

################# test intra-GNB HO EA1    ##################
Verify First ${records} In intra-gNB HO Test EA1 During ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

Verify Second ${records} In intra-gNB HO Test EA1 During ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

Set values based on previous NGAP messages in intra-gNB HO Test EA1 record
    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=success
    ...     yaml_path=${CuUeSetupRecord}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord}
    ...     message_name=InitialContextSetupResponse
    ...     skip_value_removal=${TRUE}      # must be left for next record during PDU session addition
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord}

    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=handover
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=setupPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    ${setupQosFlows}=    create_list_of_the_same_elements      element=setupQosFlows        list_length=2
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=${setupQosFlows}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    @{sst}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=sst
    ...     value=${sst}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    @{sd}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=sd
    ...     value=${sd}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    @{dlBitRate}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=dlBitRate
    ...     value=${dlBitRate}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    @{ulBitRate}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=ulBitRate
    ...     value=${ulBitRate}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    @{pduSessionId}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest  # order matters
    ...     field_name=pDUSessionID
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=pduSessionId
    ...     value=${pduSessionId}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    @{qfi}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest  # order matters
    ...     field_name=qosFlowIdentifier
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=qfi
    ...     value=${qfi}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    @{fiveQi}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest  # order matters
    ...     field_name=fiveQI
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=fiveQi
    ...     value=${fiveQi}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    @{priorityLevel}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest  # order matters
    ...     field_name=priorityLevelARP
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=priorityLevel
    ...     value=${priorityLevel}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    ${preemptionCapability}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest  # order matters
    ...     field_name=pre-emptionCapability
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     preemptionCapability
    ...     value=${preemptionCapability}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    ${preemptionVulnerability}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest  # order matters
    ...     field_name=pre-emptionVulnerability
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=preemptionVulnerability
    ...     value=${preemptionVulnerability}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

Verify third ${records} In intra-gNB HO Test EA1 During ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    Set values based on previous NGAP messages in intra-gNB HO Test EA1 record

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${no_record_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=0

    Perform Records Verification

################# test intra-GNB HO EA2    ##################
Verify First ${records} In intra-gNB HO Test EA2 During ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

Verify Second ${records} In intra-gNB HO Test EA2 During ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

Set values based on previous NGAP messages in intra-gNB HO Test EA2 record

    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=miscFailure
    ...     yaml_path=${CuUeSetupRecord}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord}
    ...     message_name=InitialContextSetupResponse
    ...     skip_value_removal=${TRUE}      # must be left for next record during PDU session addition
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord}

    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=miscFailure
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=handover
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=failedToSetupPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    ${setupQosFlows}=    create_list_of_the_same_elements      element=failedToSetupQosFlows        list_length=2
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=${setupQosFlows}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    @{sst}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=sst
    ...     value=${sst}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    @{sd}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=sd
    ...     value=${sd}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    @{dlBitRate}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=dlBitRate
    ...     value=${dlBitRate}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    @{ulBitRate}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=ulBitRate
    ...     value=${ulBitRate}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    @{pduSessionId}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest  # order matters
    ...     field_name=pDUSessionID
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=pduSessionId
    ...     value=${pduSessionId}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    @{qfi}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest  # order matters
    ...     field_name=qosFlowIdentifier
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=qfi
    ...     value=${qfi}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    @{fiveQi}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest  # order matters
    ...     field_name=fiveQI
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=fiveQi
    ...     value=${fiveQi}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    @{priorityLevel}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest  # order matters
    ...     field_name=priorityLevelARP
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=priorityLevel
    ...     value=${priorityLevel}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    ${preemptionCapability}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest  # order matters
    ...     field_name=pre-emptionCapability
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     preemptionCapability
    ...     value=${preemptionCapability}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    ${preemptionVulnerability}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest  # order matters
    ...     field_name=pre-emptionVulnerability
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=preemptionVulnerability
    ...     value=${preemptionVulnerability}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

Verify third ${records} In intra-gNB HO Test EA2 During ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    Set values based on previous NGAP messages in intra-gNB HO Test EA2 record

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${no_record_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=0

    Perform Records Verification

################# test intra-GNB partial HO EA3    ##################
Verify First ${records} In intra-gNB HO Test EA3 During ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

Verify Second ${records} In intra-gNB HO Test EA3 During ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

Verify Third ${records} In intra-gNB HO Test EA3 During ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

Verify Fourth ${records} In intra-gNB HO Test EA3 During ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=success
    ...     yaml_path=${CuUeSetupRecord}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord}
    ...     message_name=InitialContextSetupResponse
    ...     skip_value_removal=${TRUE}      # must be left for next record during PDU session addition
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord}

    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=handover
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}

    @{sst}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=sst
    ...     value=${sst}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}

    @{sd}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=sd
    ...     value=${sd}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}

    @{dlBitRate}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=dlBitRate
    ...     value=${dlBitRate}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}

    @{ulBitRate}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=ulBitRate
    ...     value=${ulBitRate}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}

    @{priorityLevel}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceModifyRequest,PDUSessionResourceSetupRequest  # order matters
    ...     field_name=priorityLevelARP
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=priorityLevel
    ...     value=${priorityLevel}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}

    ${preemptionCapability}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceModifyRequest,PDUSessionResourceSetupRequest  # order matters
    ...     field_name=pre-emptionCapability
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     preemptionCapability
    ...     value=${preemptionCapability}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}

    ${preemptionVulnerability}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceModifyRequest,PDUSessionResourceSetupRequest  # order matters
    ...     field_name=pre-emptionVulnerability
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=preemptionVulnerability
    ...     value=${preemptionVulnerability}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}

    set_variable_from_single_message_for_single_field_in_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}
    ...     message_name=PDUSessionResourceModifyRequest
    ...     field_name=maximumFlowBitRateDL
    ...     skip_value_removal=${TRUE}

    set_variable_from_single_message_for_single_field_in_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}
    ...     message_name=PDUSessionResourceModifyRequest
    ...     field_name=maximumFlowBitRateUL
    ...     skip_value_removal=${TRUE}

    set_variable_from_single_message_for_single_field_in_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}
    ...     message_name=PDUSessionResourceModifyRequest
    ...     field_name=guaranteedFlowBitRateDL
    ...     skip_value_removal=${TRUE}

    set_variable_from_single_message_for_single_field_in_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}
    ...     message_name=PDUSessionResourceModifyRequest
    ...     field_name=guaranteedFlowBitRateUL
    ...     skip_value_removal=${TRUE}

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${no_record_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=0

    Perform Records Verification

################# test inter-GNB HO EA1    ##################
Verify ${records} In inter-gNB HO Test EA1 During ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=success
    ...     yaml_path=${CuUeSetupRecord}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord}
    ...     message_name=PathSwitchRequestAcknowledge
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord}

    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=setupPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=handover
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}
    ${setupQosFlows}=    create_list_of_the_same_elements      element=setupQosFlows        list_length=2
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=${setupQosFlows}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}
    ...     message_name=HandoverRequest
    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${record_present_timeout}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${no_record_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}

    Perform Records Verification

################# test inter-GNB HO EA2    ##################
Verify ${records} In inter-gNB HO Test EA2 During ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=miscFailure
    ...     yaml_path=${CuUeSetupRecord_guami_failed_handover}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord_guami_failed_handover}
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord_guami_failed_handover}

    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=miscFailure
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}
    set variable for record yaml
    ...     variable=PduSessionResources
    ...     value=failedToSetupPduSessionResources
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=handover
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    ${setupQosFlows}=    create_list_of_the_same_elements      element=failedToSetupQosFlows        list_length=2
    set variable for record yaml
    ...     variable=QosFlows
    ...     value=${setupQosFlows}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}
    ...     message_name=HandoverRequest
    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_session_2_flows}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${record_present_timeout}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${no_record_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${no_record_timeout}

    Perform Records Verification

################# test inter-GNB HO EA3    ##################
Verify that gNB-CU doesn't report CuUeSetupTraceRecord In intra-gNB HO Test EA3
    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=10

################# test inter-GNB HO EA4    ##################
Verify ${records} In inter-gNB HO Test EA4 During ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_sessions_1_setup_1_release}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=handover
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_sessions_1_setup_1_release}

    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_sessions_1_setup_1_release}
    ...     message_name=HandoverRequest

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_2_sessions_1_setup_1_release}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=10

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=10

     Perform Records Verification

################# test AMF reselection success    ##################
Verify ${records} In AMF reselection Test EA1 During ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=success
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord_no_guami}
    ...     message_name=UplinkNASTransport
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord_no_guami}

    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=success
    ...     yaml_path=${CuUeSetupRecord_guami_amf2}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord_guami_amf2}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord_guami_amf2}
    ...     message_name=UEContextModificationResponse
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord_guami_amf2}

    Wait for PCMD records
    ...     record_num=2
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=10

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=3
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=20

     Perform Records Verification

################# test AMF reselection failure    ##################
Verify ${records} In AMF reselection Test EA2 ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=miscFailure
    ...     yaml_path=${CuUeSetupRecord_no_amfUeNgapId}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord_no_amfUeNgapId}

    ${ranUeId}=    get_variable_from_single_message_for_single_field
    ...     message_name=InitialContextSetupResponse
    ...     field_name=RAN-UE-NGAP-ID
    ...     skip_value_removal=${TRUE}

    set variable for record yaml
    ...     variable=ran-ue-ngap-Id
    ...     value=${ranUeId}
    ...     yaml_path=${CuUeSetupRecord_no_amfUeNgapId}

    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord_no_amfUeNgapId}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=10

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=20

     Perform Records Verification

################# test inter-GNB partial HO   ##################
Verify Fourth ${records} inter-gNB HO partial failure Test During ${procedure}
    Log to console    Verifying ${records} in ${procedure}
    set variable for record yaml
    ...     variable=ueSetupResult
    ...     value=success
    ...     yaml_path=${CuUeSetupRecord}
    set variable for record yaml
    ...     variable=ueSetupTrigger
    ...     value=other
    ...     yaml_path=${CuUeSetupRecord}
    set_variable_from_single_message_for_record_yaml
    ...     yaml_path=${CuUeSetupRecord}
    ...     message_name=InitialContextSetupResponse
    ...     skip_value_removal=${TRUE}      # must be left for next record during PDU session addition
    Add record for verification
    ...     record_name_with_alias=CuUeSetupTraceRecord
    ...     yaml_path=${CuUeSetupRecord}

    set variable for record yaml
    ...     variable=pduSessionResourceInfoResult
    ...     value=success
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}
    set variable for record yaml
    ...     variable=pduSessionResourceInfoTrigger
    ...     value=handover
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}

    @{sst}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest
    ...     field_name=sST
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=sst
    ...     value=${sst}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}

    @{sd}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest
    ...     field_name=sD
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=sd
    ...     value=${sd}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}

    @{dlBitRate}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateDL
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=dlBitRate
    ...     value=${dlBitRate}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}

    @{ulBitRate}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceSetupRequest
    ...     field_name=pDUSessionAggregateMaximumBitRateUL
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=ulBitRate
    ...     value=${ulBitRate}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}

    @{priorityLevel}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceModifyRequest,PDUSessionResourceSetupRequest  # order matters
    ...     field_name=priorityLevelARP
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=priorityLevel
    ...     value=${priorityLevel}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}

    ${preemptionCapability}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceModifyRequest,PDUSessionResourceSetupRequest  # order matters
    ...     field_name=pre-emptionCapability
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     preemptionCapability
    ...     value=${preemptionCapability}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}

    ${preemptionVulnerability}=    get_variable_from_messages_for_single_field
    ...     messages=InitialContextSetupRequest,PDUSessionResourceModifyRequest,PDUSessionResourceSetupRequest  # order matters
    ...     field_name=pre-emptionVulnerability
    ...     skip_value_removal=${TRUE}      # list with single elem received due to save_pcmd_many_selected_values used
    set variable for record yaml
    ...     variable=preemptionVulnerability
    ...     value=${preemptionVulnerability}
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}

    set_variable_from_single_message_for_single_field_in_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}
    ...     message_name=PDUSessionResourceModifyRequest
    ...     field_name=maximumFlowBitRateDL
    ...     skip_value_removal=${TRUE}

    set_variable_from_single_message_for_single_field_in_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}
    ...     message_name=PDUSessionResourceModifyRequest
    ...     field_name=maximumFlowBitRateUL
    ...     skip_value_removal=${TRUE}

    set_variable_from_single_message_for_single_field_in_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}
    ...     message_name=PDUSessionResourceModifyRequest
    ...     field_name=guaranteedFlowBitRateDL
    ...     skip_value_removal=${TRUE}

    set_variable_from_single_message_for_single_field_in_yaml
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}
    ...     message_name=PDUSessionResourceModifyRequest
    ...     field_name=guaranteedFlowBitRateUL
    ...     skip_value_removal=${TRUE}

    Add record for verification
    ...     record_name_with_alias=PduSessionResourceInfoTraceRecord
    ...     yaml_path=${pduSessionResourceInfoRecord_setup_1_session_2_flows_release_1_session_1_flow}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=${record_present_timeout}

    Wait for PCMD records
    ...     record_num=1
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${record_present_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=CuUeSetupTraceRecord
    ...     timeout=${no_record_timeout}

    Run keyword and expect error
    ...     *Waiting for record*
    ...     Wait for PCMD records
    ...     record_num=2
    ...     record_name=PduSessionResourceInfoTraceRecord
    ...     timeout=0

    Perform Records Verification
