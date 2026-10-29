*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    pdu_session.robot
Resource    verify-InitialContextSetup.robot
Resource    handover.robot

*** Variables ***
${FAIL_FLOW_TIMEOUT}=       10

*** Keywords ***
Attach UE${ue_id:\d+} without ICS to gNB${gnb_id:\d+} cell${cell_id:\d+}
    Execute egate command   cmd=amf_param id=1 empty_pdu_session_list=on send_ics_registration=off
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Execute egate command
    ...  cmd=ue_register id=${ue_id}
    ...  pass_regexp=Received REGISTRATION COMPLETE

Attach UE${ue_id:\d+} with ICS to gNB${gnb_id:\d+} cell${cell_id:\d+}
    Execute egate command   cmd=amf_param id=1 empty_pdu_session_list=on send_ics_registration=on
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Execute egate command
    ...  cmd=ue_register id=${ue_id}
    ...  pass_regexp=Received REGISTRATION COMPLETE
    Execute egate command  cmd=amf_param id=1 empty_pdu_session_list=off send_ics_registration=off

Attach UE${ue_id:\d+} to gNB${gnb_id:\d+} cell${cell_id:\d+} with ICS during PDU session setup
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: UE_${ue_id} NR-RRC RRCSetup
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP initialContextSetup
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP uERadioCapabilityInfoIndication
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: UE_${ue_id} NR-RRC UECapabilityInformation

    Run keyword and continue on failure
    ...     Attach UE${ue_id} without ICS to gNB${gnb_id} cell${cell_id}
    Run keyword and continue on failure
    ...     Add to UE${ue_id} initial PDU session with ICS

    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: UE_${ue_id} NR-RRC RRCSetup
    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP initialContextSetup
    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: UE_${ue_id} NR-RRC UECapabilityInformation

Attach UE${ue_id:\d+} to gNB${gnb_id:\d+} cell${cell_id:\d+} with ICS and PDU session setup after ICS
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP initialContextSetup
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP uERadioCapabilityInfoIndication

    Run keyword and continue on failure
    ...     Attach UE${ue_id} with ICS to gNB${gnb_id} cell${cell_id}
    Run keyword and continue on failure
    ...     Add to UE${ue_id} initial PDU session after ICS

    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP initialContextSetup
    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP uERadioCapabilityInfoIndication

Attach UE${ue_id:\d+} to gNB${gnb_id:\d+} cell${cell_id:\d+} with ICS without PDU session
    EXPECT FLOW: AMF1 NGAP downlinkNASTransport with first UE IDs pair
    EXPECT FLOW: AMF1 NGAP initialContextSetup not optimized version with 0 PDU Sessions
    EXPECT FLOW: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    EXPECT FLOW: UE_${ue_id} NR-RRC UECapabilityEnquiry in optimized ICS procedure
    EXPECT FLOW: UE_${ue_id} NR-RRC UECapabilityInformation in optimized ICS procedure

    Run keyword and continue on failure
    ...     Attach UE${ue_id} with ICS to gNB${gnb_id} cell${cell_id}

    PASS FLOW: AMF1 NGAP downlinkNASTransport with first UE IDs pair
    PASS FLOW: AMF1 NGAP initialContextSetup not optimized version with 0 PDU Sessions
    PASS FLOW: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    PASS FLOW: UE_${ue_id} NR-RRC UECapabilityEnquiry in optimized ICS procedure
    PASS FLOW: UE_${ue_id} NR-RRC UECapabilityInformation in optimized ICS procedure
    Verify that AMF1 NGAP InitialContextSetup does not contain any PDU session

Attach UE${ue_id:\d+} to gNB${gnb_id:\d+} cell${cell_id:\d+} with ICS without PDU session without UECapabilityEnquiry
    EXPECT FLOW: AMF1 NGAP downlinkNASTransport with first UE IDs pair
    EXPECT FLOW: AMF1 NGAP initialContextSetup not optimized version with 0 PDU Sessions
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: UE_${ue_id} NR-RRC UECapabilityEnquiry in optimized ICS procedure
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: UE_${ue_id} NR-RRC UECapabilityInformation in optimized ICS procedure

    Run keyword and continue on failure
    ...     Attach UE${ue_id} with ICS to gNB${gnb_id} cell${cell_id}

    PASS FLOW: AMF1 NGAP downlinkNASTransport with first UE IDs pair
    PASS FLOW: AMF1 NGAP initialContextSetup not optimized version with 0 PDU Sessions
    FAIL FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    FAIL FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: UE_${ue_id} NR-RRC UECapabilityEnquiry in optimized ICS procedure
    FAIL FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: UE_${ue_id} NR-RRC UECapabilityInformation in optimized ICS procedure
    Verify that AMF1 NGAP InitialContextSetup does not contain any PDU session

Attach UE${ue_id:\d+} to gNB${gnb_id:\d+} cell${cell_id:\d+} without ICS without PDU session
    EXPECT FLOW: AMF1 NGAP downlinkNASTransport with first UE IDs pair
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP initialContextSetup not optimized version with 0 PDU Sessions

    Run keyword and continue on failure
    ...     Attach UE${ue_id} without ICS to gNB${gnb_id} cell${cell_id}

    PASS FLOW: AMF1 NGAP downlinkNASTransport with first UE IDs pair
    FAIL FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP initialContextSetup not optimized version with 0 PDU Sessions

Attach UEs[${ue_ids}] to gNB${gnb_id:\d+} cell${cell_id:\d+} with ICS during PDU session setup
    @{ue_list}=   Split To List   ${ue_ids}
    FOR   ${ue}   IN   @{ue_list}
        Attach UE${ue} to gNB${gnb_id} cell${cell_id} with ICS during PDU session setup
    END

Detach and kill UE${ue_id:\d+}
#    Execute egate command
#    ...  cmd=ue_pdu_session_release ue=${ue_id} pdu=${ue_id} by=ue
#    ...  pass_regexp=Successfully released PDU Session with ID
#    Execute egate command
#    ...  cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
#    ...  pass_regexp=UE${ue_id}: detached
    Execute egate command  cmd=ue_kill id=${ue_id}
    Sleep  3

Deregister UE${ue_id:\d+} and kill if failed
#    Execute egate command
#    ...  cmd=ue_pdu_session_release ue=${ue_id} pdu=${ue_id} by=ue
#    ...  pass_regexp=Successfully released PDU Session with ID
    ${success}=     Run Keyword And Return Status
    ...  Execute egate command
    ...  cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
    ...  pass_regexp=UE${ue_id}: detached
    Sleep  1
    Run Keyword If      ${success} != ${TRUE}
    ...     Run keywords
    ...     Execute egate command  cmd=ue_kill id=${ue_id}
    ...     AND         Log to console      UE${ue_id} must be killed
    Sleep  3

Trigger UE${ue_id:\d+} to send deregister request
    Execute egate command
    ...  cmd=ue_deregister ue_deregister_type=switch_off by=ue id=${ue_id}
    ...  pass_regexp=UE${ue_id}: detached
    Sleep  1

Trigger UEs from ${first_ue:\d+} to ${last_ue:\d+} to send deregister request
    Execute egate command
    ...  cmd=ue_deregister ue_deregister_type=switch_off by=ue id=${first_ue}-${last_ue}
    Log to console      UEs ${first_ue}-${last_ue} deregistered
    Sleep  1

Attach UE${ue_id:\d+} to gNB${gnb_id:\d+} cell${cell_id:\d+} with ICS containing ueRadioCapability without PDU session
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP initialContextSetup

    Run keyword and continue on failure
    ...     Attach UE${ue_id} with ICS to gNB${gnb_id} cell${cell_id}

    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: AMF1 NGAP initialContextSetup
    Verify that AMF1 NGAP InitialContextSetup does contain UERadioCapability

Detach and kill UEs from ${first_ue:\d+} to ${last_ue:\d+}
    Execute egate command  cmd=ue_kill id=${first_ue}-${last_ue}
    Log to console      UEs killed, but AP cleaning may be still in progress, do not re-attach immediately
    sleep   3

Activate UE${ue_id:\d+} on gNBSim and setup PDU session
    Set up inter gNB Handover for UE${ue_id}
    Execute egate command  cmd=ue_change_location id=${ue_id} enb=3 cell=1
    Execute egate command  cmd=ue_register id=${ue_id}
    ...  pass_regexp=UE${ue_id}: UE performed Registration type INITIAL_REGISTRATION
    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute egate command  cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    ...  pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=1 using PDU Gateway ID

Attach UE${ue_id:\d+} to simulated eNB1 CELL-1
    Execute egate command    cmd=ue_change_location id=${ue_id} enb=1 cell=1
    Execute egate command    cmd=attach_ue id=${ue_id}    pass_regexp=UE${ue_id}: === UE IS ACTIVE

Trigger SgnbAddition procedure for UE${ue_id:\d+} with NRCELL_${nr_cell_id:\d+} on gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: gNB${gnb_id} X2AP sgNBAdditionPreparation
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: gNB${gnb_id} E1AP bearerContextSetup
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: gNB${gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: gNB${gnb_id} X2AP sgNBReconfigurationCompletion
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: gNB${gnb_id} X2AP snStatusTransfer

    Execute egate command
    ...  cmd=ue_dc_enb_start ue=${ue_id} target_gnb=${gnb_id} target_cells=${nr_cell_id} bearer=2 type=split_scg
    ...  pass_regexp=UE${ue_id}: Proxy.*eNB ${gnb_id} cell ${nr_cell_id}.*reported successful RA

    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: gNB${gnb_id} X2AP sgNBAdditionPreparation
    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: gNB${gnb_id} E1AP bearerContextSetup
    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: gNB${gnb_id} X2AP sgNBReconfigurationCompletion
    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: gNB${gnb_id} X2AP snStatusTransfer

Trigger SgnbAddition procedure without message flows for UE${ue_id:\d+} with NRCELL_${nr_cell_id:\d+} on gNB${gnb_id:\d+}
    Execute egate command
    ...  cmd=ue_dc_enb_start ue=${ue_id} target_gnb=${gnb_id} target_cells=${nr_cell_id} bearer=2 type=split_scg
    ...  pass_regexp=UE${ue_id}: Proxy.*eNB ${gnb_id} cell ${nr_cell_id}.*reported successful RA
    Sleep    1

Trigger SgNB Change procedure for UE${ue_id:\d+} from gNB${source:\d+} to gNB${target:\d+}
    EXPECT FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: eNB1 X2AP sgNBChange

    Execute egate command
    ...  cmd=dc_gnb_ue_change ue=${ue_id} gnb=${target} target_sgnb_cells=1 cause=RN_sCG_Mobility
    ...  pass_regexp=UE${ue_id}: === Inter Sgnb Handover is successful ===

    PASS FLOW[timeout=${FAIL_FLOW_TIMEOUT}]: eNB1 X2AP sgNBChange

Wait for UE${ue_id:\d+} to enter IDLE state
    EXPECT FLOW[timeout=60]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease due to inactivity
    PASS FLOW[timeout=60]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease due to inactivity
    Verify that AMF1 UEContextReleaseRequest contains cause=user-inactivity

Verify that UE${ue_id:\d+} state is ${ue_state:ACTIVE|INACTIVE|IDLE|OFF} on Egate
    Execute egate command
    ...  cmd=ue_disp id=${ue_id}
    ...  pass_regexp=state.*${ue_state}
