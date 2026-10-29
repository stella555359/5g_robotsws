*** Settings ***
Resource    ../../../resources/Robot/common_settings.robot
Resource    ../../resources/yaml_config_paths.robot
Resource    ./CB006999-B_PCMD_records.robot

Library     ../../../resources/Python/utilities.py
Library     ./CB006999-B_UE_TNLA_BRR.py
Library     ./CB006999_keywords.py
Library     ./CB006999_alarms_verifiers.py
Library     ./pcmd_verify.py
Library     ./amfId_verifier.py

*** Variables ***
${AMF1_GUAMI1}   311:489|1:2:1
${AMF1_GUAMI2}   311:489|1:2:2
${AMF2_GUAMI1}   311:489|1:2:3
${AMF2_GUAMI2}   311:489|1:2:4
${AMF3_GUAMI1}   311:489|1:2:4

${AMF1_backups}   2,3
${AMF2_backups}   1
${AMF3_backups}   1

${cause_notCompatible}       "message-not-compatible-with-receiver-state"
${cause_unknown_UE_ID}       "unknown-local-UE-NGAP-ID"
${cause_inconsistent_UE_ID}  "inconsistent-remote-UE-NGAP-ID"
${cause_abstract_sytax_err}  "abstract-syntax-error-reject"

${missing_UnavailableGUAMIList}  00014008000001FFFF000100
${ACU_rest}  00000040000003000100060180414D46310060001B01401341980100810180414D4632401341980100820180414D4633005000100013419800011008D143A51008D143A6

# NG HO failure case
${action_ho_fail}       ho_preparation_failure_with_send_concurrent_msg
${cause_interaction}    RN_interaction_with_other_procedure

${basic_config_yaml_path}=        ${CURDIR}/../config/yaml_config/basic_enabler_3AMFs.yaml
${pcmd_config_yaml_path}=         ${CURDIR}/../config/yaml_config/pcmd_enable_DU_CU.yaml

*** Keywords ***
Create all devices aliases
    Create UEs alias  alias=UE  id_type=wts_5g
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.11
    Create AMF device with alias 'AMF2' identified by ip=10.0.1.12
    Create AMF device with alias 'AMF3' identified by ip=10.0.1.13
    Create gNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.30
    Create GNB device with alias 'gNB3_XN' identified by ip=10.0.1.31

Create CB006999 VRAN devices aliases
    Create UEs alias  alias=UE  id_type=wts_5g
    Create AMF device with alias 'AMF1' identified by ip=10.0.11.11
    Create AMF device with alias 'AMF2' identified by ip=10.0.11.12
    Create AMF device with alias 'AMF3' identified by ip=10.0.11.13
    Create gNB device with alias 'gNB2' identified by ip=10.0.11.10

Configure CB006999 basic params via yaml
    [Arguments]      ${pcmd_config}=${False}    ${inter_gnb_ho}=${False}
    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${basic_config_yaml_path}
    Run Keyword if  ${pcmd_config} != ${False}
    ...     append to list      ${yaml_paths_to_configure}      ${pcmd_config_yaml_path}
    Run Keyword if  ${inter_gnb_ho} != ${False}
    ...     Run keywords
    ...     append to list      ${yaml_paths_to_configure}      ${gNBSim_path}
    ...     AND    append to list      ${yaml_paths_to_configure}      ${inter_gNB_handover}
    Configure       ${yaml_paths_to_configure}

Lock NGAP link to AMF${amf_id}
    Edit object attributes  SERVEDAMF-${amf_id}  administrativestate=Locked

Unlock NGAP link to AMF${amf_id}
    Edit object attributes  SERVEDAMF-${amf_id}  administrativestate=Unlocked

Cleanup Backup AMF Name from SERVEDAMF-${amf_id}
# info: change of implementation of AP commands:
    Execute egate command   cmd=amf_ng_setup_param id=${amf_id} include_backup_amf_name=off
    Expect message flow
    ...    AMF${amf_id}:NGAP_NGSetupRequest
    ...    AMF${amf_id}:NGAP_NGSetupResponse
    ...    alias=AMF${amf_id}_NG_setup    overall_timeout=30
    Execute egate command   cmd=link_drop link=ng by=amf:${amf_id} to=gnb:2

    Verify that NG link to AMF-${amf_id} recovered
    discover bts   bts_id=1

    Verify SERVEDAMF-1:GUAMI_index-1:guamiStatus is set to available
    Verify SERVEDAMF-1:GUAMI_index-2:guamiStatus is set to available
    Verify SERVEDAMF-1:GUAMI_index-1.backupAmfName is set to None
    Verify SERVEDAMF-1:GUAMI_index-2.backupAmfName is set to None

Restore AMF${amf_id} GUAMIs
     Execute egate command   cmd=amf_restore_guamis id=${amf_id} guami_index=all

Restore GUAMIs on AMF1 and set GUAMI1 backupAMF to AMF2 by sending NGAP: AMF CONFIGURATION UPDATE
    Restore AMF1 GUAMIs
    Sleep  2
    Execute egate command   cmd=amf_config_update id=1 amfi=1:2:1,1:2:2 plmn=311:489 relative_capacity=1
    Sleep  2
    Execute egate command   cmd=send_hex source=amf:1 target=gnb:2 hex=0000001C0000010060001501401341980100810180414D463200134198010082

Restore test suite settings on AMF1
    Restore AMF1 GUAMIs
    Sleep  2
    Execute egate command  cmd=send_hex source=amf:1 target=gnb:2 hex=${ACU_rest}
    Sleep  2

    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=available
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF3, guamiStatus=available

Restore backup AMFs on AMF1 and verify NG links up
    Restore test suite settings on AMF1
    Verify that NG link to AMF-1 is established
    Verify that NG link to AMF-2 is established
    Verify that NG link to AMF-3 is established

Verify that NG link to AMF-${amf_id} is established
    Object Attributes Should Be   SERVEDAMF-${amf_id}   ngLinkStatus=ACTIVE

Verify that NG link to AMF-${amf_id} recovered
    Flow occurred as expected    alias=AMF${amf_id}_NG_setup

Set Planned AMF Removal Timer to ${timer_duration} seconds in gNB
    edit object attributes  NRBTS-1  amfplannedremovaltimer=${timer_duration}

Verify that amfplannedremovaltimer is set to ${timer_duration}
    Sleep    5
    object attributes should be   NRBTS-1  amfplannedremovaltimer=${timer_duration}

Set Planned AMF Removal feature flag to ${boolean}
    ${actual}=    Get object attributes    NRBTS-1    actAmfPlannedRemoval   enb_id=1
    Run keyword if   ${actual['actamfplannedremoval']}!=${boolean}
    ...  Edit object attributes
    ...     object_name=NRBTS-1
    ...     actAmfPlannedRemoval=${boolean}
    ...     bts_id=1

Try to send NGAP: UPLINK NAS TRANSPORT from UE${ue_id} to AMF${amf_id}
    Try to send PDU Session Modification Request from UE${ue_id} PDU1 to AMF${amf_id}

Send AMF Configuration Update from AMF${amf_id} with GUAMI${guami_value_1} and GUAMI${guami_value_2} on ServedGUAMIList
    Expect message flow
    ...    AMF${amf_id}:NGAP_AMFConfigurationUpdate (gUAMI contains (aMFRegionID eq '0b00000001'))
    ...    AMF${amf_id}:NGAP_AMFConfigurationUpdateAcknowledge
    ...    alias=amf${amf_id}_config_update    overall_timeout=10

    Execute egate command    cmd=amf_config_update id=${amf_id} amfi=1:2:${guami_value_1},1:2:${guami_value_2}
    Flow occurred as expected    alias=amf${amf_id}_config_update

Send ASI from AMF${amf_id} with one GUAMI:${guami1} backupAMF:${bkp1} timerApproach:${ta1}
    ${bkp1}=    Set variable if    '${bkp1}'=='None'    0    ${bkp1}

    Expect message flow
    ...    AMF${amf_id}:NGAP_AMFStatusIndication as ASI
    ...    alias=AMF${amf_id}_status_indication_partial    overall_timeout=10
    ${epcsim_backup_index}=    Set variable if    ${bkp1}!=0    ${${bkp1}-1}
    ...                                            ${bkp1}==0    ${bkp1}
    Execute egate command
    ...  cmd=send_amf_status_indication id=${amf_id} guami_index=${guami1} backup_amf_index=${epcsim_backup_index} timer_guami_removal=${ta1}
    Flow occurred as expected    alias=AMF${amf_id}_status_indication_partial
    Verify AMFStatusIndication payload with partial GUAMI
    ...  flow_alias=AMF${amf_id}_status_indication_partial
    ...  message_alias=ASI
    ...  backup=${bkp1}
    ...  timer_approach=${ta1}

Send ASI from AMF${amf_id} with two GUAMI:${guami1} backupAMF:${bkp1} timerApproach:${ta1} GUAMI:${guami2} backupAMF:${bkp2} timerApproach:${ta2}
    ${bkp1}=    Set variable if    '${bkp1}'=='None'    0    ${bkp1}
    ${bkp2}=    Set variable if    '${bkp2}'=='None'    0    ${bkp2}

    ${epcsim_backup1_index}=    Set variable if    ${bkp1}!=0    ${${bkp1}-1}
    ...                                            ${bkp1}==0    ${bkp1}
    ${epcsim_backup2_index}=    Set variable if    ${bkp2}!=0    ${${bkp2}-1}
    ...                                            ${bkp2}==0    ${bkp2}

    ${send_asi_cmd}=  Catenate  send_amf_status_indication id=${amf_id}
    ...  guami_index=${guami1} backup_amf_index=${epcsim_backup1_index} timer_guami_removal=${ta1}
    ...  guami_index=${guami2} backup_amf_index=${epcsim_backup2_index} timer_guami_removal=${ta2}

    Expect message flow
    ...    AMF${amf_id}:NGAP_AMFStatusIndication as ASI
    ...    alias=AMF${amf_id}_status_indication_full    overall_timeout=10
    Execute egate command  cmd=${send_asi_cmd}
    Flow occurred as expected    alias=AMF${amf_id}_status_indication_full
    Verify AMFStatusIndication payload with full GUAMI
    ...  flow_alias=AMF${amf_id}_status_indication_full
    ...  message_alias=ASI
    ...  bkp1=${bkp1}
    ...  ta1=${ta1}
    ...  bkp2=${bkp2}
    ...  ta2=${ta2}

Send ASI with redirection to other AMF${redirect_amf_id} from AMF${amf_id} with one GUAMI:${gu1} backupAMF:${bkp1} timerApproach:${ta1}
    ${bkp1}=    Set variable if    '${bkp1}'=='None'    0    ${bkp1}

    ${bkp1_idx}=    Set variable if    ${bkp1}!=0    ${${bkp1}-1}
    ...                                            ${bkp1}==0    ${bkp1}
    ${redirect_amf_idx}=    Set variable if    ${redirect_amf_id}!=0    ${${redirect_amf_id}-1}
    ...                                            ${redirect_amf_id}==0    ${redirect_amf_id}

    Expect message flow
    ...    AMF${amf_id}:NGAP_AMFStatusIndication as ASI
    ...    alias=AMF${amf_id}_status_indication_partial    overall_timeout=10

    Execute egate command
    ...  cmd=send_amf_status_indication id=1 guami_index=1 backup_amf_index=1 timer_guami_removal=on action=redirect_other_amf redirect_amf_index=2
    Flow occurred as expected    alias=AMF${amf_id}_status_indication_partial

    Verify AMFStatusIndication payload with partial GUAMI
    ...  flow_alias=AMF${amf_id}_status_indication_partial
    ...  message_alias=ASI
    ...  backup=${bkp1}
    ...  timer_approach=${ta1}

Send UE TNLA BRR for UE${ue_id} from AMF${amf_id} with both invalid UE NGAP ID
    Expect NGAP: ERROR INDICATION sent to AMF1 after UE TNLA BRR with cause=${cause_unknown_UE_ID}
    Execute egate command  cmd=send_hex source=amf:${amf_id} target=gnb:2 hex=002D400F000002000A00020064005500020064
    Verify gNB sends NGAP: ERROR INDICATION after UE TNLA BRR

Send UE TNLA BRR for UE${ue_id} from AMF${amf_id} with valid AMF UE NGAP ID and invalid RAN UE NGAP ID
    Expect NGAP: ERROR INDICATION sent to AMF1 after UE TNLA BRR with cause=${cause_unknown_UE_ID}
    Execute egate command  cmd=send_ue_tnla_binding_release ue=${ue_id} id=${amf_id} action=include_invalid_ran_id invalid_ran_ue_id=1000
    Verify gNB sends NGAP: ERROR INDICATION after UE TNLA BRR

Send UE TNLA BRR for UE${ue_id} from AMF${amf_id} with valid RAN UE NGAP ID and invalid AMF UE NGAP ID
    Expect NGAP: ERROR INDICATION sent to AMF1 after UE TNLA BRR with cause=${cause_inconsistent_UE_ID}
    Expect UE${ue_id} is released by gNB
    Execute egate command  cmd=send_ue_tnla_binding_release ue=${ue_id} id=${amf_id} action=include_invalid_amf_id invalid_amf_ue_id=1000
    Verify gNB sends NGAP: ERROR INDICATION after UE TNLA BRR
    Verify UE${ue_id} is released by gNB

Send UE TNLA BRR for UE${ue_id} from AMF${amf_id} with both valid UE NGAP ID
    Expect UE TNLA BRR is sent from AMF${amf_id}
    Execute egate command    cmd=send_ue_tnla_binding_release id=${amf_id} ue=${ue_id}
    Verify UE TNLA BRR is sent from AMF${amf_id}

Trigger UE${ue_id} to send PDU Session Modification for PDU${pdu_id}
    Execute egate command    cmd=ue_pdu_session_modify pdu=${pdu_id} qosflows_to_add=2 ue=${ue_id}

Try to send PDU Session Modification Request from UE${ue_id} PDU${pdu_id} to AMF${amf_id}
    Expect message will not occur
    ...    AMF${amf_id}:NGAP_PDUSessionResourceModifyRequest
    ...    alias=UE${ue_id}_PDU${pdu_id}_session_modify_did_not_occur
    ...    overall_timeout=10

    Execute egate command    cmd=ue_pdu_session_modify pdu=${pdu_id} qosflows_to_add=2 ue=${ue_id}
    Flow not occurred for message    alias=UE${ue_id}_PDU${pdu_id}_session_modify_did_not_occur

Attach UE-${ue_id} to AMF${amf_id}:GUAMI:${guami}
    Log  UE${ue_id} send to AMF:${AMF${amf_id}_GUAMI${guami}}
    Execute egate command    cmd=ue_nr_rrc_setup_param id=${ue_id} registered_amf=${AMF${amf_id}_GUAMI${guami}}
    Execute egate command    cmd=amf_registration_param id=${amf_id} guami_index=${guami}
    Sleep  1
    Attach UE
    ...  ue_id=${ue_id}
    ...  pass_regexp=UE${ue_id}: UE performed UNKNOWN_ATTACH_TYPE


Attach UE${ue_id} to AMF${amf_id}:GUAMI:${guami} and run traffic on PDU ${pdu_id}
    Attach UE-${ue_id} to AMF${amf_id}:GUAMI:${guami}
    Expect that UE-${ue_id} is attached to AMF${amf_id}
    Connect UE-${ue_id} PDU session ${pdu_id} with QOS flow
    Verify that UE-${ue_id} is attached to AMF${amf_id}
    Run 20MBps UL and DL traffic on UE${ue_id} PDU${pdu_id} QFI1 and wait 5 seconds

Attach UE${ue_id} to AMF${amf_id}:GUAMI:${guami} without starting traffic
    Attach UE-${ue_id} to AMF${amf_id}:GUAMI:${guami}
    Expect that UE-${ue_id} is attached to AMF${amf_id}
    Connect UE-${ue_id} PDU session ${ue_id} with QOS flow
    Verify that UE-${ue_id} is attached to AMF${amf_id}

Attach UE:${ue_id} to AMF${amf_id}:GUAMI:${guami} with delayed NR-RRC response
    Attach UE-${ue_id} to AMF${amf_id}:GUAMI:${guami}
    Expect that UE${ue_id} ends ICS procedure with old AMF${amf_id} while AMF sent ASI
    Setup delay before sending NR-RRC: RRC Reconfiguration Complete from UE${ue_id}
    Connect UE-${ue_id} PDU session ${ue_id} with QOS flow

Expect that UE-${ue_id} is attached to AMF${amf_id}
    Expect message flow
    ...     AMF${amf_id}:NGAP_InitialContextSetupRequest
    ...     AMF${amf_id}:NGAP_InitialContextSetupResponse (Get AMF and RAN UE NGAP ID) as ICSResp
    ...     alias=UE${ue_id}_ICS_from_AMF${amf_id}
    ...     overall_timeout=10
    Sleep  2

Expect that UE${ue_id} ends ICS procedure with old AMF${amf_id} while AMF sent ASI
    Expect message flow
    ...     AMF${amf_id}:NGAP_InitialContextSetupRequest
    ...     AMF${amf_id}:NGAP_AMFStatusIndication
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     AMF${amf_id}:NGAP_InitialContextSetupResponse (Get AMF and RAN UE NGAP ID) as ICSResp
    ...     alias=UE${ue_id}_ASI_received_during_ICS_from_AMF${amf_id}
    ...     overall_timeout=10
    Sleep  2

Expect that UE${ue_id} ends PDU session setup procedure with old AMF${amf_id} while AMF sent UE TNLA BRR
    Expect message flow
    ...     AMF${amf_id}:NGAP_PDUSessionResourceSetupRequest
    ...     AMF${amf_id}:NGAP_UETNLABindingReleaseRequest
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     AMF${amf_id}:NGAP_PDUSessionResourceSetupResponse
    ...     alias=UE${ue_id}_TNLA_received_during_PDU_setup_from_AMF${amf_id}
    ...     overall_timeout=10
    Sleep  2

Expect that gNB performs selection to AMF${amf_id} for UE-${ue_id}
    Expect message flow
    ...     AMF${amf_id}:NGAP_InitialContextSetupRequest
    ...     AMF${amf_id}:NGAP_InitialContextSetupResponse (Get AMF and RAN UE NGAP ID) as ICSResp
    ...     AMF${amf_id}:NGAP_UEContextModificationRequest
    ...     AMF${amf_id}:NGAP_UEContextModificationResponse
    ...     alias=UE${ue_id}_ICS_ctx_modified_from_AMF${amf_id}
    ...     overall_timeout=10
    Sleep  2

Expect that UE-${ue_id} is not attached to AMF${amf_id}
    Expect message will not occur
    ...     AMF${amf_id}:NGAP_InitialContextSetupRequest
    ...     alias=UE${ue_id}_ICS_not_from_AMF${amf_id}
    ...     overall_timeout=10
    Sleep  2

Expect that UE-${ue_id} uses AMF${amf_id} after NGAP: UPLINK NAS TRANSPORT
    Expect message flow
    ...     AMF${amf_id}:NGAP_UplinkNASTransport
    ...     alias=UE${ue_id}_uses_AMF${amf_id}_after_UL_NAS_Transport
    ...     overall_timeout=10

Setup delay before sending NR-RRC: RRC Reconfiguration Complete from UE${ue_id}
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=2s
    Sleep  1

Restore default behavior while sending NR-RRC: RRC Reconfiguration Complete from UE${ue_id}
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=none
    Sleep  1

Connect UE-${ue_id} PDU session ${pdu_id} with QOS Flow
    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute egate command  cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${pdu_id}
    Sleep  2

Verify that UE-${ue_id} is attached to AMF${amf_id}
    Flow occurred as expected    alias=UE${ue_id}_ICS_from_AMF${amf_id}
    Sleep  2

Verify that UE${ue_id} ended ICS procedure with old AMF${amf_id} while AMF sent ASI
    Flow occurred as expected    alias=UE${ue_id}_ASI_received_during_ICS_from_AMF${amf_id}
    Sleep  2

Verify that UE${ue_id} ended PDU session setup procedure with old AMF${amf_id} while AMF sent UE TNLA BRR
    Flow occurred as expected    alias=UE${ue_id}_TNLA_received_during_PDU_setup_from_AMF${amf_id}
    Sleep  2

Verify that gNB performed selection to AMF${amf_id} for UE-${ue_id}
    Flow occurred as expected    alias=UE${ue_id}_ICS_ctx_modified_from_AMF${amf_id}
    Sleep  2

Verify that UE-${ue_id} is not attached to AMF${amf_id}
    Flow not occurred for message    alias=UE${ue_id}_ICS_not_from_AMF${amf_id}
    Sleep  2

Verify that UE-${ue_id} uses AMF${amf_id} after NGAP: UPLINK NAS TRANSPORT
    Flow occurred as expected    alias=UE${ue_id}_uses_AMF${amf_id}_after_UL_NAS_Transport

Wait until UE${ue_id} is going IDLE
    Expect message flow
    ...     AMF1:NGAP_UEContextReleaseRequest
    ...     AMF1:NGAP_UEContextReleaseCommand
    ...     UE_${ue_id}:NR-RRC_RRCRelease
    ...     AMF1:NGAP_UEContextReleaseComplete
    ...     alias=UE${ue_id}_idle
    ...     overall_timeout=30
    Flow occurred as expected    alias=UE${ue_id}_idle

Trigger UE${ue_id} IDLE mode exit
    Log to console  Trigger UE${ue_id} IDLE mode exit
    Execute egate command  cmd=ue_nr_rrc_setup_param id=${ue_id} if_contains=any action=none
    Execute egate command  cmd=ue_im_exit id=${ue_id}
    Sleep  1

Expect UE${ue_id} is not released
    Expect message will not occur
    ...     UE_${ue_id}:NR-RRC_RRCRelease
    ...     alias=UE${ue_id}_not_released
    ...     overall_timeout=25

Expect UE${ue_id} is released by gNB
    Expect message flow
    ...     UE_${ue_id}:NR-RRC_RRCRelease
    ...     alias=UE${ue_id}_released
    ...     overall_timeout=25

Expect gNB does not send NGAP: ERROR INDICATION after Planned AMF Removal feature enabling
    Expect message will not occur
    ...     AMF1:NGAP_ErrorIndication
    ...     alias=ErrorIndication_not_expected    overall_timeout=10

Expect gNB does not send NGAP: ERROR INDICATION after TBRR to AMF${amf_id}
    Expect no NGAP: ERROR INDICATION to AMF${amf_id}

Expect NGAP: ERROR INDICATION sent after ASI with cause=${cause}
    Expect message flow
    ...     AMF1:NGAP_AMFStatusIndication
    ...     AMF1:NGAP_ErrorIndication (Cause contains (protocol eq ${cause})) as errorIndication
    ...     alias=ErrorIndication_expected
    ...     overall_timeout=10

Expect NGAP: ERROR INDICATION sent to AMF${amf_id} after UE TNLA BRR with cause=${cause}
    Expect message flow
    ...     AMF${amf_id}:NGAP_UETNLABindingReleaseRequest
    ...     AMF${amf_id}:NGAP_ErrorIndication (Cause contains (radioNetwork eq ${cause})) as errorIndication
    ...     alias=ErrorIndication_expected
    ...     overall_timeout=10

Expect no NGAP: ERROR INDICATION to AMF${amf_id}
    Expect message will not occur
    ...     AMF${amf_id}:NGAP_ErrorIndication
    ...     alias=ErrorIndication_not_expected_for_AMF${amf_id}    overall_timeout=20

Expect UE TNLA BRR is sent from AMF${amf_id}
    Expect message flow
    ...  AMF${amf_id}:NGAP_UETNLABindingReleaseRequest
    ...  alias=AMF${amf_id}_valid_UE_TNLA_BRR    overall_timeout=10

Verify UE${ue_id} is not released
    Flow not occurred for message    alias=UE${ue_id}_not_released

Verify UE${ue_id} is released by gNB
     Flow occurred as expected    alias=UE${ue_id}_released

Verify gNB sends NGAP: ERROR INDICATION after ${msg:ASI|UE TNLA BRR}
    Flow occurred as expected    alias=ErrorIndication_expected

Verify gNB does not send NGAP: ERROR INDICATION after Planned AMF Removal feature enabling
    Flow not occurred for message    alias=ErrorIndication_not_expected

Verify gNB does not send NGAP: ERROR INDICATION to AMF${amf_id}
     Flow not occurred for message    alias=ErrorIndication_not_expected_for_AMF${amf_id}

Verify UE TNLA BRR is sent from AMF${amf_id}
    Flow occurred as expected    alias=AMF${amf_id}_valid_UE_TNLA_BRR

Verify that UE TNLA BRR is traced with TCE
    Sleep  4
    Verify if NGAP message is traced    UETNLABindingReleaseRequest

Verify that NGAP: Initial Context Setup Request is traced with TCE
    Sleep  4
    Verify if NGAP message is traced    InitialContextSetupRequest

Verify that PDU Session Modification sent to AMF${amf_id} is traced with TCE
    Sleep  4
    Verify if NGAP message is traced    PDUSessionResourceModifyResponse

Verify SERVEDAMF-${amf_id}:GUAMI_index-${guami_idx:[12]} is correctly updated: backupAmfName=${bkp_name}, guamiStatus=${guami_status}
    Verify SERVEDAMF-${amf_id}:GUAMI_index-${guami_idx}.backupAmfName is set to ${bkp_name}
    Sleep  5
    Verify SERVEDAMF-${amf_id}:GUAMI_index-${guami_idx}:guamiStatus is set to ${guami_status}

Verify SERVEDAMF-${amf_id}:GUAMI_index-${guami_idx:[12]}.backupAmfName is set to ${bkp_name}
    ${emss_guami_index}=  Evaluate   ${guami_idx}-1
    run keyword if  '${bkp_name}'=='None'
    ...  Verify that backupAMFName is not configured in SERVEDAMF-${amf_id}:GUAMI_index-${guami_idx}
    ...  ELSE  Wait for object attribute value    SERVEDAMF-${amf_id}    guami.backupAmfName[${emss_guami_index}]   value=${bkp_name}    timeout=60

Verify SERVEDAMF-${amf_id}:GUAMI_index-${guami_idx:[12]}:guamiStatus is set to ${guami_status}
    discover bts  bts_id=1
    ${emss_guami_index}=  Evaluate   ${guami_idx}-1
    Wait for object attribute value    SERVEDAMF-${amf_id}    guami.guamiStatus[${emss_guami_index}]   value=${guami_status}    timeout=60

Verify that backupAMFName is not configured in SERVEDAMF-${amf_id}:GUAMI_index-${guami_idx}
    ${emss_guami_index}=  Evaluate   ${guami_idx}-1
    ${is_exist}=  check if attribute exists  SERVEDAMF-${amf_id}  guami[${${emss_guami_index}}].backupAmfName
    should be equal   ${is_exist}  ${0}

Verify SERVEDAMF-${amf_id}:GUAMI_index-${guami_idx:[12]} points to GUAMI3
    ${emss_guami_index}=  Evaluate   ${guami_idx}-1
    Object attributes should be    SERVEDAMF-${amf_id}    guami.amfPointer[${${emss_guami_index}}]=3
    Object attributes should be    SERVEDAMF-${amf_id}    guami.amfRegionID[${${emss_guami_index}}]=1
    Object attributes should be    SERVEDAMF-${amf_id}    guami.amfSetID[${${emss_guami_index}}]=2

Verify that alarm with NG AMF Status Indication fault and fault ID=${fault_id} is raised for AMF${amf_id}
    ute_admin.Assert alarm active   faultId=${fault_id}, severity=Warning, alarmId=7115  timeout=40s
    Verify that alarm ${fault_id} with NG AMF Status Indication fault is active for AMF${amf_id}

Verify PM counters for AMF selection are incremented successfully: attempts:${att}, fails:${fail}, successes:${succ}
    Verify counter value on NRCELL-1 for M55155C00001 - AMF_SELECTION_ATT equals ${att}
    Verify counter value on NRCELL-1 for M55155C00002 - AMF_SELECTION_FAIL equals ${fail}
    Verify counter value on NRCELL-1 for M55155C00003 - AMF_SELECTION_SUCC equals ${succ}

Verify VRAN PM counters for AMF selection are incremented successfully: attempts:${att}, fails:${fail}, successes:${succ}
    Verify CU counter value on NRCELL-1 for M55155C00001 - AMF_SELECTION_ATT equals ${att}
    Verify CU counter value on NRCELL-1 for M55155C00002 - AMF_SELECTION_FAIL equals ${fail}
    Verify CU counter value on NRCELL-1 for M55155C00003 - AMF_SELECTION_SUCC equals ${succ}

Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:${att}, fails:${fail}, successes:${succ}
    Verify counter value on NRCELL-1 for M55155C00004 - AMF_RESELECTION_GNB_ATT equals ${att}
    Verify counter value on NRCELL-1 for M55155C00005 - AMF_RESELECTION_GNB_FAIL equals ${fail}
    Verify counter value on NRCELL-1 for M55155C00006 - AMF_RESELECTION_GNB_SUCC equals ${succ}

Verify VRAN PM counters for gNB initiated AMF reselection are incremented successfully: attempts:${att}, fails:${fail}, successes:${succ}
    Verify CU counter value on NRCELL-1 for M55155C00004 - AMF_RESELECTION_GNB_ATT equals ${att}
    Verify CU counter value on NRCELL-1 for M55155C00005 - AMF_RESELECTION_GNB_FAIL equals ${fail}
    Verify CU counter value on NRCELL-1 for M55155C00006 - AMF_RESELECTION_GNB_SUCC equals ${succ}

Verify PM counters for 5GC initiated AMF reselection are incremented successfully: received:${rcv}, refused:${ref}
    Verify counter value on NRCELL-1 for M55155C00007 - AMF_RESELECTION_5GC_RCV equals ${rcv}
    Verify counter value on NRCELL-1 for M55155C00008 - AMF_RESELECTION_5GC_REF equals ${ref}

Verify VRAN PM counters for 5GC initiated AMF reselection are incremented successfully: received:${rcv}, refused:${ref}
    Verify CU counter value on NRCELL-1 for M55155C00007 - AMF_RESELECTION_5GC_RCV equals ${rcv}
    Verify CU counter value on NRCELL-1 for M55155C00008 - AMF_RESELECTION_5GC_REF equals ${ref}

Verify PM counters for ErrorIndication are incremented successfully: count: ${count}
    Verify counter value on NRBTS-1 for M55119C00021 - NG_CU_ERROR_IND_SENT equals ${count}

Detach UE${ue_id}
    Execute egate command  cmd=ue_pdu_session_release ue=${ue_id} pdu=${ue_id} by=ue
    Sleep  2
    Execute egate command  cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
    Sleep  2
    Execute egate command  cmd=ue_kill id=${ue_id}

Restore AMF${amf_id} guamiStatus and backupAMFs
    Update AMF${amf_id} config to restore guamiStatus available
    TEMPORARY BYPASS: Reset NG link between AMF${amf_id} and gNB
    Verify that NG link to AMF-${amf_id} recovered

Update AMF${amf_id} config to restore guamiStatus available
    Execute egate command    cmd=amf_config_update id=${amf_id} relative_capacity=1
    Sleep  2

Set relative capacity to ${rel_cap_val} for AMF${amf_id}
    Expect message flow
    ...    AMF${amf_id}:NGAP_AMFConfigurationUpdate
    ...    AMF${amf_id}:NGAP_AMFConfigurationUpdateAcknowledge
    ...    alias=AMF${amf_id}_ACU_with_rel_cap    overall_timeout=10

    Execute egate command    cmd=amf_config_update id=${amf_id} relative_capacity=${rel_cap_val}

    Flow occurred as expected    alias=AMF${amf_id}_ACU_with_rel_cap
    Wait for object attribute value    SERVEDAMF-${amf_id}     relativeAMFcapacity    value=${rel_cap_val}   timeout=60

    Sleep  2

Reset NG links
    TEMPORARY BYPASS: Reset NG link between AMF1 and gNB
    TEMPORARY BYPASS: Reset NG link between AMF2 and gNB
    Verify that NG link to AMF-1 recovered  # AMF1 has to recover before AMF3 reset to prevent occasional WTS crash
    TEMPORARY BYPASS: Reset NG link between AMF3 and gNB
    Verify that NG link to AMF-2 recovered
    Verify that NG link to AMF-3 recovered

Wait until alarm with fault ID=7325 disappears
    ute_admin.Assert alarm inactive   faultId=7325, severity=Warning, alarmId=7115  timeout=30s

TEMPORARY BYPASS: Reset NG link between AMF${amf_id} and gNB
    Expect message flow
    ...    AMF${amf_id}:NGAP_NGSetupRequest
    ...    AMF${amf_id}:NGAP_NGSetupResponse as ngSetupResp
    ...    alias=AMF${amf_id}_NG_setup    overall_timeout=120
    Execute egate command    cmd=link_drop link=ng msg_type=shutdown to=gnb:2 by=amf:${amf_id}

Verify that NGSetupResponse from AMF${amf_id} includes UERetentionInformation
    Verify that message fulfills query
    ...  (UERetentionInformation eq "ues-retained")
    ...  message_alias=ngSetupResp
    ...  flow_alias=AMF${amf_id}_NG_setup

Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-${amf_id}
    Expect message will not occur
    ...    AMF${amf_id}:NGAP_UplinkNASTransport
    ...    alias=gNB_sends_ngap_ul_nas_transport_to_AMF${amf_id}_not_expected
    ...    overall_timeout=10

Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-${amf_id}
    Flow not occurred for message    alias=gNB_sends_ngap_ul_nas_transport_to_AMF${amf_id}_not_expected

Expect that UE${ue_id} sends NR-RRC: UL INFORMATION TRANSFER to gNB
    Expect message flow
    ...    UE_${ue_id}:NR-RRC_ULInformationTransfer
    ...    alias=UE${ue_id}_sends_nr_rrc_ul_information_transfer_to_gNB
    ...    overall_timeout=10

Expect that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF${amf_id}
    Expect message flow
    ...    AMF${amf_id}:NGAP_UplinkNASTransport
    ...    alias=gNB_sends_ngap_uplink_nas_transport_to_AMF${amf_id}
    ...    overall_timeout=10

Expect that AMF${amf_id} generates newGUAMI for UE
    Expect message flow
    ...    AMF${amf_id}:NGAP_UEContextModificationRequest (GUAMI is present)
    ...    AMF${amf_id}:NGAP_UEContextModificationResponse
    ...    alias=AMF${amf_id}_UECtxModification_guami_procedure
    ...    overall_timeout=10

Verify that AMF${amf_id} allocates newGUAMI
    flow occurred as expected   alias=AMF${amf_id}_UECtxModification_guami_procedure

Expect that AMF${amf_id} sends PDU Session Resource Modify Request
    Expect message flow
    ...    AMF${amf_id}:NGAP_PDUSessionResourceModifyRequest
    ...    AMF${amf_id}:NGAP_PDUSessionResourceModifyResponse
    ...    alias=AMF${amf_id}_sends_pdu_session_resource_modify_request
    ...    overall_timeout=10

Verify that UE${ue_id} sends NR-RRC: UL INFORMATION TRANSFER to gNB
    Flow occurred as expected    alias=UE${ue_id}_sends_nr_rrc_ul_information_transfer_to_gNB

Verify that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF${amf_id}
    Flow occurred as expected    alias=gNB_sends_ngap_uplink_nas_transport_to_AMF${amf_id}

Verify that AMF${amf_id} sends PDU Session Resource Modify Request
    Flow occurred as expected    alias=AMF${amf_id}_sends_pdu_session_resource_modify_request

Expect that after PDU Session Modification Request from UE${ue_id} gNB does not perform AMF reselection and AMF${amf_id} is selected
    Expect that UE${ue_id} sends NR-RRC: UL INFORMATION TRANSFER to gNB
    Expect that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF${amf_id}
    Expect that AMF${amf_id} sends PDU Session Resource Modify Request

Verify that after PDU Session Modification Request from UE${ue_id} gNB does not perform AMF reselection and AMF${amf_id} is selected
    Verify that UE${ue_id} sends NR-RRC: UL INFORMATION TRANSFER to gNB
    Verify that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF${amf_id}
    Verify that AMF${amf_id} sends PDU Session Resource Modify Request

Expect that after PDU Session Modification Request from UE${ue_id} gNB performs AMF reselection and AMF${amf_id} is selected
    Expect that UE${ue_id} sends NR-RRC: UL INFORMATION TRANSFER to gNB
    Expect that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF${amf_id}
    Expect that AMF${amf_id} sends PDU Session Resource Modify Request

Verify that after PDU Session Modification Request from UE${ue_id} gNB performs AMF reselection and AMF${amf_id} is selected
    Verify that UE${ue_id} sends NR-RRC: UL INFORMATION TRANSFER to gNB
    Verify that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF${amf_id}
    Verify that AMF${amf_id} sends PDU Session Resource Modify Request

Send ASI from AMF${amf_id} with unknown GUAMI backupAMF:${bkp1} timerApproach:${ta1}
    ${bkp1}=    Set variable if    '${bkp1}'=='None'    0    ${bkp1}

    ${epcsim_backup1_index}=    Set variable if    ${bkp1}!=0    ${${bkp1}-1}
    ...                                            ${bkp1}==0    ${bkp1}
    ${send_asi_cmd}=  Catenate  send_amf_status_indication id=${amf_id}
    ...  guami_index=1 timer_guami_removal=${ta1} backup_amf_index=${epcsim_backup1_index} action=include_unknown_guami
    ...  unknown_guami_plmn=314:492 unknown_guami_amfi=3:1:4

    Expect message flow
    ...    AMF${amf_id}:NGAP_AMFStatusIndication as ASI
    ...    alias=AMF${amf_id}_status_indication_part    overall_timeout=10
    Execute egate command  cmd=${send_asi_cmd}
    Flow occurred as expected    alias=AMF${amf_id}_status_indication_part

    Verify AMFStatusIndication payload with partial GUAMI
    ...  flow_alias=AMF${amf_id}_status_indication_part
    ...  message_alias=ASI
    ...  backup=${bkp1}
    ...  timer_approach=${ta1}

Send ASI from AMF${amf_id} with missing UnavailableGUAMIList
    Expect message flow
    ...    AMF${amf_id}:NGAP_AMFStatusIndication as ASI
    ...    alias=AMF${amf_id}_status_indication_empty    overall_timeout=10
    Execute egate command    cmd=send_hex source=amf:${amf_id} target=gnb:2 hex=${missing_UnavailableGUAMIList}
    Flow occurred as expected    alias=AMF${amf_id}_status_indication_empty

Wait until amfPlannedRemovalTimer expiration
    ${timer_duration}=    Get object attributes  NRBTS-1  amfplannedremovaltimer
    ${timer_duration}=    Convert To Integer    ${timer_duration}[amfplannedremovaltimer]
    Log to console  Wait ${timer_duration}s until amfPlannedRemovalTimer expiration
    Sleep    ${timer_duration}

Expect that after PDU Session Modification Request from UE${ue_id} gNB does not perform AMF reselection for AMF${amf_id}
    Expect message will not occur
    ...     AMF${amf_id}:NGAP_UplinkNASTransport
    ...     alias=UE${ue_id}_NOT_uses_AMF${amf_id}_after_UL_NAS_Transport
    ...     overall_timeout=10

Verify that after PDU Session Modification Request from UE${ue_id} gNB does not perform AMF reselection for AMF${amf_id}
    Flow not occurred for message    alias=UE${ue_id}_NOT_uses_AMF${amf_id}_after_UL_NAS_Transport

Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to all AMFs
    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-2
    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-3

Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to all AMFs
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-2
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-3

Expect that UE Context Modification was sent from new AMF${amf_id} for UE${ue_id}
    Expect message flow
    ...    AMF${amf_id}:NGAP_UEContextModificationRequest as CtxModReq
    ...    AMF${amf_id}:NGAP_UEContextModificationResponse
    ...    alias=AMF${amf_id}-UE${ue_id}_ContextModificationResponse
    ...    overall_timeout=10
    Sleep  1

Expect that UE Context Modification was sent from AMF${amf_id} for UE${ue_id} with aMFPointer equal to ${amfpointer}
    ${payload_amfpointer_bin}   Convert to binary    ${amfpointer}    prefix=0b   length=6
    Expect message flow
    ...    AMF${amf_id}:NGAP_UEContextModificationRequest (aMFPointer eq "${payload_amfpointer_bin}") as CtxModReq
    ...    AMF${amf_id}:NGAP_UEContextModificationResponse
    ...    alias=AMF${amf_id}-UE${ue_id}-aMFPointer${amfpointer}_ContextModificationResponse
    ...    overall_timeout=10

Send NGAP: UE Context Modification Request from old AMF${amf_id} for UE${ue_id}
    Execute egate command    cmd=amf_ue_relocate id=${amf_id} ue=${ue_id} action=relocate_ue_other_guami
    Sleep  1

Send NGAP: UE Context Modification Request from new AMF${new_amf_id} for UE${ue_id} currently using AMF${old_amf_id}
    ${new_amf_index}=    Set variable if    ${new_amf_id}!=0    ${${new_amf_id}-1}
    ...                                     ${new_amf_id}==0    ${new_amf_id}

    Execute egate command    cmd=amf_ue_relocate id=${old_amf_id} ue=${ue_id} action=relocate_ue_other_amf redirect_amf_index=${new_amf_index}
    Sleep  1

Verify that UE Context Modification was sent from new AMF${amf_id} for UE${ue_id}
    Flow occurred as expected    alias=AMF${amf_id}-UE${ue_id}_ContextModificationResponse
    Sleep  1

Verify that UE Context Modification was sent from AMF${amf_id} for UE${ue_id} with aMFPointer equal to ${amfpointer}
    Flow occurred as expected    alias=AMF${amf_id}-UE${ue_id}-aMFPointer${amfpointer}_ContextModificationResponse

Set Support Guami Unavailability to ${state} for AMF${amf_id}
    Execute egate command    cmd=amf_param id=${amf_id} support_guami_unavailability=${state}
    Sleep  1

Expect that UE Context Modification was sent from AMF${amf_id} with UE${ue_id} with aMFPointer equal to ${amfpointer} in payload
    ${payload_amfpointer_bin}   Convert to binary    ${amfpointer}    prefix=0b   length=6
    Expect message flow
    ...    AMF${amf_id}:NGAP_UEContextModificationRequest (aMFPointer eq "${payload_amfpointer_bin}") as CtxModReq
    ...    AMF${amf_id}:NGAP_UEContextModificationResponse (save_pcmd_many_selected_values)
    ...    alias=AMF${amf_id}-UE${ue_id}-aMFPointer${amfpointer}_ContextModificationResponse
    ...    overall_timeout=10

Verify that UE Context Modification was sent from AMF${amf_id} with UE${ue_id} with aMFPointer equal to ${amfpointer} in payload
    Flow occurred as expected    alias=AMF${amf_id}-UE${ue_id}-aMFPointer${amfpointer}_ContextModificationResponse

Expect that after PDU Session Modification Request from UE${ue_id} gNB performs AMF reselection - AMF${amf_id} with GUAMI${amfpointer} is selected
    ${payload_amfpointer_bin}   Convert to binary    ${amfpointer}    prefix=0b   length=6
    Expect message flow
    ...    AMF${amf_id}:NGAP_UEContextModificationRequest
    ...    AMF${amf_id}:NGAP_UEContextModificationResponse
    ...    AMF${amf_id}:NGAP_UEContextModificationRequest (aMFPointer eq "${payload_amfpointer_bin}") as CtxModReq
    ...    AMF${amf_id}:NGAP_UEContextModificationResponse
    ...    alias=AMF${amf_id}-UE${ue_id}-aMFPointer${amfpointer}_ContextModificationResponse
    ...    overall_timeout=10

Verify that after PDU Session Modification Request from UE${ue_id} gNB performs AMF reselection - AMF${amf_id} with GUAMI${amfpointer} is selected
    Flow occurred as expected    alias=AMF${amf_id}-UE${ue_id}-aMFPointer${amfpointer}_ContextModificationResponse

Expect that UE${ue_id} is released by gNB
    Expect message flow
    ...     UE_${ue_id}:NR-RRC_RRCSetupRequest
    ...     UE_${ue_id}:NR-RRC_RRCSetup
    ...     UE_${ue_id}:NR-RRC_RRCSetupComplete (ng-5G-S-TMSI-Part2 is present)
    ...     UE_${ue_id}:NR-RRC_RRCRelease
    ...     alias=UE${ue_id}_released
    ...     overall_timeout=25

Verify that UE${ue_id} is released by gNB
    Flow occurred as expected    alias=UE${ue_id}_released

Expect that AMF${amf_id} starts PDU Session Modification procedure without UEContextModification
    Expect message will not occur
    ...    AMF${amf_id}:NGAP_UEContextModificationRequest
    ...    alias=AMF${amf_id}_not_UEContextModification
    ...    overall_timeout=20
    Expect message flow
    ...    AMF${amf_id}:NGAP_PDUSessionResourceModifyRequest
    ...    AMF${amf_id}:NGAP_PDUSessionResourceModifyResponse
    ...    alias=AMF${amf_id}_starts_pdu_session_modification_procedure_without_UEContextMod
    ...    overall_timeout=10

Verify that AMF${amf_id} starts PDU Session Modification procedure without UEContextModification
    Flow not occurred for message    alias=AMF${amf_id}_not_UEContextModification
    Flow occurred as expected    alias=AMF${amf_id}_starts_pdu_session_modification_procedure_without_UEContextMod

Set target GUAMI to GUAMI${guami} for relocation to other AMF after PDU Session Modification
    Execute egate command    cmd=amf_ue_relocate id=1 ue=1 action=relocate_ue_other_amf redirect_amf_index=${guami}

Trigger UE${ue_id} to send PDU Session Modification to start reselection triggerd by core- for PDU${pdu_id}
    Execute egate command    cmd=ue_pdu_session_modify pdu=${pdu_id} qosflows_to_add=2 ue=${ue_id} by=amf validation=on

Trigger AMF${amf_id} to send NGAP: PDU SESSION RESOURCE MODIFY REQUEST for UE${ue_id} and PDU${pdu_id}
    Execute egate command    cmd=ue_pdu_session_modify pdu=${pdu_id} qosflows_to_add=2 ue=${ue_id} by=amf validation=on

Set up HO for UE${ue_id}
    ${list_id}=   Set variable   ${ue_id}
    Execute egate command
    ...   cmd=ue_history_information_list_add_ngran id=${list_id} gnb_id=3 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command
    ...   cmd=ue_history_information_list_add_ngran id=${list_id} gnb_id=2 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command   cmd=ue_history_information_list id=${list_id} action=commit
    Execute egate command   cmd=ue_enb_param id=${ue_id} ue_history_list=${list_id}

Setup NG HO on gNB
#    ${SW_RELEASE}    Get gNB SW release
#    Run keyword if      '${SW_RELEASE}' == 'SBTS22R2'
#    ...  Edit object attributes
#    ...     object_name=NRREL-1-1
#    ...     handoverAllowedSA=onlyNG
#    ...     bts_id=1

    Edit object attributes
    ...     object_name=NRREL-1-1
    ...     handoverAllowedSA=XnHoNotAllowed
    ...     bts_id=1


    ${actual}=    Get object attributes    NRBTS-1    actIntraNrNgHo   enb_id=1
    Run keyword if   "${actual['actintranrngho']}"!="sourceAndTarget"
    ...  Edit object attributes
    ...     object_name=NRBTS-1
    ...     actIntraNrNgHo=sourceAndTarget
    ...     bts_id=1

Setup ${msg:amf_status_indication|ue_tnla_binding_release_request} interaction sent after Handover Required
    Run keyword if      '${msg}' == 'amf_status_indication'
    ...  Execute egate command
    ...  cmd=amf_ue_ng_handover_param id=1 action=${action_ho_fail} msg=${msg} timer_guami_removal=on backup_amf_index=1 cause=${cause_interaction}

    Run keyword if      '${msg}' == 'ue_tnla_binding_release_request'
    ...  Execute egate command
    ...  cmd=amf_ue_ng_handover_param id=1 action=${action_ho_fail} msg=${msg} cause=${cause_interaction}

Setup ${msg:amf_status_indication|ue_tnla_binding_release_request} interaction sent after Handover Required with no response
    Run keyword if      '${msg}' == 'amf_status_indication'
    ...  Execute egate command
    ...  cmd=amf_ue_ng_handover_param id=1 action=no_response_with_send_concurrent_msg msg=${msg} timer_guami_removal=on backup_amf_index=1

    Run keyword if      '${msg}' == 'ue_tnla_binding_release_request'
    ...  Execute egate command
    ...  cmd=amf_ue_ng_handover_param id=1 action=no_response_with_send_concurrent_msg msg=${msg}

Setup ${msg:amf_status_indication} interaction sent before Handover Required
    Execute egate command     cmd=amf_ue_ng_handover_param id=3 action=ho_preparation_failure cause=RN_interaction_with_other_procedure
    Sleep  2

Trigger failure NG HO from real to sim gNB for UE${ue_id} while AMF${amf_id} sent concurrent ${msg:AMFStatusIndication|UETNLABindingReleaseRequest}
    Expect Message Flow
    ...     AMF${amf_id}:NGAP_HandoverRequired
    ...     AMF${amf_id}:NGAP_${msg} as ${msg}
    ...     AMF${amf_id}:NGAP_HandoverPreparationFailure
    ...     alias=UE${ue_id}_NG_HO_fail
    ...     overall_timeout=10
    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=19 srsrq_nr=10 phycell_id=52 nrsrp_nr=85 nrsrq_nr=31
    Flow occurred as expected  alias=UE${ue_id}_NG_HO_fail

    Run keyword if      '${msg}' == 'AMFStatusIndication'
    ...  Verify AMFStatusIndication payload with partial GUAMI
    ...  flow_alias=UE${ue_id}_NG_HO_fail
    ...  message_alias=${msg}
    ...  backup=1
    ...  timer_approach=on

Trigger failure NG HO from real to sim gNB with AMF${amf_id}:GUAMI${amfpointer} for UE${ue_id} then 5GCore redirects message to new AMF${new_amf_id}
    Expect Message Flow
    ...     AMF${amf_id}:NGAP_HandoverRequired
    ...     AMF${new_amf_id}:NGAP_HandoverPreparationFailure
    ...     alias=UE${ue_id}_NG_HO_fail
    ...     overall_timeout=10
    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=19 srsrq_nr=10 phycell_id=52 nrsrp_nr=85 nrsrq_nr=31
    Flow occurred as expected  alias=UE${ue_id}_NG_HO_fail

Trigger successful NG HO from real_gNB to simulated_gNB for UE${ue_id} with backup AMF${amf_id}
    Expect Message Flow
    ...     AMF${amf_id}:NGAP_HandoverRequired
    ...     AMF${amf_id}:NGAP_HandoverCommand
    ...     AMF${amf_id}:NGAP_HandoverNotify
    ...     alias=UE${ue_id}_NG_HO_success
    ...     overall_timeout=10
    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=19 srsrq_nr=10 phycell_id=52 nrsrp_nr=85 nrsrq_nr=31
    Flow occurred as expected  alias=UE${ue_id}_NG_HO_success

Trigger failure NG HO with no response from real to sim gNB for UE${ue_id} while AMF${amf_id} sent concurrent ${msg}
    Expect Message Flow
    ...     AMF${amf_id}:NGAP_HandoverRequired
    ...     AMF${amf_id}:NGAP_${msg} as ${msg}
    ...     AMF${amf_id}:NGAP_HandoverCancel
    ...     AMF${amf_id}:NGAP_HandoverCancelAcknowledge
    ...     alias=UE${ue_id}_NG_HO_fail_no_response
    ...     overall_timeout=10
    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=19 srsrq_nr=10 phycell_id=52 nrsrp_nr=85 nrsrq_nr=31
    Flow occurred as expected  alias=UE${ue_id}_NG_HO_fail_no_response

Expect that handover from ${src_id}_gNB to ${tgt_id}_gNB with AMF${amf_id}:GUAMI${amfptr} for UE${ue} ends with HandoverRequestAcknowledge
    ${payload_amfpointer_bin}   Convert to binary    ${amfptr}    prefix=0b   length=6
    Expect Message Flow
    ...     gNB3_XN:XNAP_HandoverRequest (amf-pointer eq "${payload_amfpointer_bin}") as HO_Req
    ...     gNB3_XN:XNAP_HandoverRequestAcknowledge as HO_Ack
    ...     alias=UE${ue}_Handover
    ...     overall_timeout=30

Expect that handover from ${src_id}_gNB to ${tgt_id}_gNB with AMF${amf_id}:GUAMI${amfptr} for UE${ue} ends with HandoverPreparationFailure
    ${payload_amfpointer_bin}   Convert to binary    ${amfptr}    prefix=0b   length=6
    Expect Message Flow
    ...     gNB3_XN:XNAP_HandoverRequest (amf-pointer eq "${payload_amfpointer_bin}") as HO_Req
    ...     gNB3_XN:XNAP_HandoverPreparationFailure as HO_Failure
    ...     alias=UE${ue}_Handover
    ...     overall_timeout=30

Expect that NGAP_PathSwitchRequest is sent to AMF${amf_id} for UE${ue}
    Expect Message Flow
    ...     AMF2:NGAP_PathSwitchRequest as PathSwitchReq
    ...     AMF2:NGAP_PathSwitchRequestAcknowledge as PathSwitchReqAck
    ...     alias=UE${ue}_PathSwitch
    ...     overall_timeout=30

Trigger XN HO from sim_gNB to real_gNB with AMF${amf_id}:GUAMI${amfpointer} for UE${ue_id}
    Execute egate command   cmd=ue_measurement_send_nr id=${ue_id} meas_id=5 event=A5 srsrp_nr=19 srsrq_nr=10 phycell_id=50 nrsrp_nr=85 nrsrq_nr=31

Trigger XN HO from real_gNB to sim_gNB with AMF${amf_id}:GUAMI${amfpointer} for UE${ue_id}
    Execute egate command
    ...   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=19 srsrq_nr=10 phycell_id=52 nrsrp_nr=85 nrsrq_nr=31
    ...   pass_regexp=UE1: Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed

Verify that NGAP_PathSwitchRequest is sent to AMF${amf_id} for UE${ue}
    Flow occurred as expected    alias=UE${ue}_PathSwitch

Verify that ${src:real|simulated}_gNB sends XNAP: ${msg:Handover Request Acknowledge|Handover Request} to ${tgt:real|simulated}_gNB for UE${ue_id}
    Flow occurred as expected    alias=UE${ue_id}_Handover

Verify that real_gNB sends XNAP: Handover Preparation Failure with cause: transport resource unavailable for UE${ue_id}
    Verify that message has field set to value
    ...   flow_alias=UE${ue_id}_Handover
    ...   message_alias=HO_Failure
    ...   field_name=transport
    ...   value=transport-resource-unavailable

Locate UE${ue_id} at real_gNB
    Execute egate command    cmd=ue_change_location id=${ue_id} enb=2 cell=1

Send NGAP: DOWNLINK NAS TRANSPORT from AMF${amf_id} for UE${ue_id} to gNB
    Expect that NGAP: DOWNLINK NAS TRANSPORT is sent from AMF${amf_id} for UE${ue_id}
    Expect that NGAP: UE CONTEXT MODIFICATION REQUEST is not sent from AMF${amf_id}

    ${amf_index}=    Evaluate    ${amf_id}-1
    Execute egate command    cmd=amf_ue_relocate id=1 ue=${ue_id} action=relocate_ue_other_amf redirect_amf_index=${amf_index}

Expect that NGAP: DOWNLINK NAS TRANSPORT is sent from AMF${amf_id} for UE${ue_id}
    Expect message flow
    ...    AMF${amf_id}:NGAP_DownlinkNASTransport (save_pcmd_many_selected_values)
    ...    alias=AMF${amf_id}_UE${ue_id}_NGAP_DownlinkNASTransport
    ...    overall_timeout=10

Expect that NGAP: UE CONTEXT MODIFICATION REQUEST is not sent from AMF${amf_id}
    Expect message will not occur
    ...    AMF${amf_id}:NGAP_UEContextModificationRequest
    ...    alias=AMF${amf_id}_UECtxModification_not_sent
    ...    overall_timeout=10

Verify that NGAP: DOWNLINK NAS TRANSPORT is sent from AMF${amf_id} for UE${ue_id}
    Flow occurred as expected    alias=AMF${amf_id}_UE${ue_id}_NGAP_DownlinkNASTransport

Verify that NGAP: UE CONTEXT MODIFICATION REQUEST is not sent from AMF${amf_id}
    Flow not occurred for message    alias=AMF${amf_id}_UECtxModification_not_sent

Expect that UEContextRelease procedure is made with AMF${amf_id} for UE${ue_id}
    Expect message flow
    ...     AMF${amf_id}:NGAP_UEContextReleaseRequest
    ...     AMF${amf_id}:NGAP_UEContextReleaseCommand
    ...     alias=UE${ue_id}_idle_with_AMF${amf_id}
    ...     overall_timeout=60

Verify that UEContextRelease procedure is made with AMF${amf_id} for UE${ue_id}
    Flow occurred as expected    alias=UE${ue_id}_idle_with_AMF${amf_id}

Lock AMF${amf_id}:GUAMI${guami} with ASI from being used in AMF reselection
    Send ASI from AMF${amf_id} with one GUAMI:${guami} backupAMF:None timerApproach:off

Verify if NewGUAMI applied in UE1 and gNB performs AMF reselection due to new UPLINK NAS message
    Expect that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF1
    Execute egate command    cmd=amf_param ignore_ng=on id=1
    Connect UE-1 PDU session 3 with QOS flow
    Verify that gNB sends NGAP: UPLINK NAS TRANSPORT to AMF1
    Execute egate command    cmd=amf_param ignore_ng=off id=1

Send ASI from AMF${amf_id} with one GUAMI:${guami1} and redirection to other GUAMI
    Expect message flow
    ...    AMF${amf_id}:NGAP_AMFStatusIndication as ASI
    ...    alias=AMF${amf_id}_status_indication_partial    overall_timeout=10

    Execute egate command
    ...  cmd=send_amf_status_indication id=${amf_id} guami_index=${guami1} backup_amf_index=0 timer_guami_removal=on action=redirect_other_guami

    Flow occurred as expected    alias=AMF${amf_id}_status_indication_partial

    Verify AMFStatusIndication payload with partial GUAMI
    ...  flow_alias=AMF${amf_id}_status_indication_partial
    ...  message_alias=ASI
    ...  backup=0
    ...  timer_approach=on

Expect that UE Context Modification was sent from AMF${amf_id} with UE${ue_id} with NewAMF
    Expect message flow
    ...    AMF${amf_id}:NGAP_UEContextModificationRequest as Ctx
    ...    AMF${amf_id}:NGAP_UEContextModificationResponse
    ...    alias=AMF${amf_id}_UEContextModification_with_NewAMF
    ...    overall_timeout=10

Verify that UE Context Modification was sent from AMF${amf_id} with UE${ue_id} with NewAMF
    Flow occurred as expected    alias=AMF${amf_id}_UEContextModification_with_NewAMF
    verify_if_amf_id_changed
    ...     flow_alias=AMF${amf_id}_UEContextModification_with_NewAMF
    ...     message_alias=Ctx

Setup successful amf_status_indication interaction sent after Handover Required
    Execute egate command
    ...  cmd=amf_ue_ng_handover_param id=1 action=send_concurrent_msg msg=amf_status_indication timer_guami_removal=off backup_amf_index=1

Trigger successful NG HO from real_gNB to simulated_gNB for UE${ue_id} without reselection while AMF${amf_id} sent concurrent AMFStatusIndication
    Expect Message Flow
    ...     AMF${amf_id}:NGAP_HandoverRequired
    ...     AMF${amf_id}:NGAP_AMFStatusIndication
    ...     AMF${amf_id}:NGAP_HandoverCommand
    ...     AMF${amf_id}:NGAP_UEContextReleaseCommand
    ...     AMF${amf_id}:NGAP_UEContextReleaseComplete
    ...     alias=UE${ue_id}_NG_HO_success_without_reselection
    ...     overall_timeout=10
    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=19 srsrq_nr=10 phycell_id=52 nrsrp_nr=85 nrsrq_nr=31
    Flow occurred as expected  alias=UE${ue_id}_NG_HO_success_without_reselection
