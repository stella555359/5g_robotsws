*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...      - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...      - Michał Szymakowski <michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...      I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com


Resource    ../../../../sim_resources/Krk_regression/rrm_resources/Robot/common_settings.robot
Library     ../../../../sim_resources/Krk_regression/rrm_resources/PCMD/verifier_msg_for_pcmd.py
Library     mock_stop_egate.py
Library     ta5g_egate    WITH NAME    egate
Library     ./test_setup_resources.py    WITH NAME    test_setup
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.config.scf     WITH NAME  scf
Library     ta5g_testline_management
Library     ta5g_commissioning

*** Variables ***
${common_verifier}=     save_pcmd_many_selected_values
${yaml_disable_ciphering}=                  ${CURDIR}/../config/yaml_config/cipherPrefL_config.yaml
${yaml_sib_config}=                         ${CURDIR}/../config/yaml_config/sib_config.yaml
${yaml_enable_pcmd}=                        ${CURDIR}/../config/yaml_config/pcmd_enable_DU_CU.yaml
${yaml_enable_intraho}=                     ${CURDIR}/../config/yaml_config/intra_gnb_ho.yaml
${yaml_enable_interho}=                     ${CURDIR}/../config/yaml_config/inter_gnb_ho.yaml
${yaml_enable_intraho_partial}=             ${CURDIR}/../config/yaml_config/intra_gnb_emergency_with_partial.yaml
${yaml_enable_multiple_amfs}=               ${CURDIR}/../config/yaml_config/amf_reselection.yaml
${yaml_enable_5QI2}=                        ${CURDIR}/../config/yaml_config/5QI2.yaml
${yaml_enable_5QI1}=                        ${CURDIR}/../config/yaml_config/5QI1.yaml
&{session_name_to_pdu}=     initial=1       first=1      second=2      third=3      fourth=4
${timeout}=     16


@{yaml_paths_to_configure}=     ${yaml_sib_config}
...                             ${yaml_enable_pcmd}


*** Keywords ***
Add to UE${ue_id} PDU${pdu_id} session QoS flows with 5QI from list [${qos_add}] and delete QoS flows with 5QI from list [${qos_del}]
    @{qos_to_add_list}=   Evaluate  re.findall('\\d+','${qos_add}')  modules=re
    @{qos_to_del_list}=   Evaluate  re.findall('\\d+','${qos_del}')  modules=re
    ${length_of_qos_to_add_list}=  get length    ${qos_to_add_list}
    ${length_of_qos_to_del_list}=  get length    ${qos_to_del_list}

    Run Keyword If    ${length_of_qos_to_add_list} > 0 and ${length_of_qos_to_del_list} > 0
    ...  Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_add} qosflows_to_del=${qos_del}

    Run Keyword If    ${length_of_qos_to_add_list} > 0 and ${length_of_qos_to_del_list} == 0
    ...  Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_add}

    Run Keyword If    ${length_of_qos_to_add_list} == 0 and ${length_of_qos_to_del_list} > 0
    ...  Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=${qos_del}
    Sleep  2

Add to UE${ue_id:\d+} ${session_type:(initial|second|third)} PDU session with one QoS flow
    ${pdu_id}       Get From Dictionary         ${session_name_to_pdu}         ${session_type}
    Sleep  2

    Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} gw=${pdu_id} nwslice=1
    ...     pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session

Attach UE${ue_id} without PDU session to gNB2 cell1
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=2 cell=1
    Execute egate command   cmd=ue_register id=${ue_id}
    Sleep  1

Attach UE for AP restore verification
    EXPECT FLOW[timeout=15]: AMF1 NGAP initialContextSetup
    EXPECT FLOW[timeout=15]: UE_1 NR-RRC RRCReconfiguration
    Attach UE1 to cell1 gNB2
    PASS FLOW[timeout=15]: AMF1 NGAP initialContextSetup
    PASS FLOW[timeout=15]: UE_1 NR-RRC RRCReconfiguration

Detach UE For AP Restore Verification
    Run keyword and ignore error
    ...     Execute egate command   cmd=deregister_ue id=1 by=amf
    Sleep     5
    Run keyword and ignore error
    ...     Execute egate command    cmd=ue_kill id=1

Attach UE${ue_id} with single PDU session in ICS
    EXPECT FLOW: AMF1 NGAP initialContextSetup optimized version with 1 PDU Sessions
    EXPECT FLOW[timeout=15]: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    EXPECT FLOW[timeout=15]: UE_${ue_id} NR-RRC UECapabilityEnquiry in optimized ICS procedure
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfiguration

    Attach UE${ue_id} to cell1 gNB2

    PASS FLOW: AMF1 NGAP initialContextSetup optimized version with 1 PDU Sessions
    FAIL FLOW[timeout=15]: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    FAIL FLOW[timeout=15]: UE_${ue_id} NR-RRC UECapabilityEnquiry in optimized ICS procedure
    PASS FLOW: UE_${ue_id} NR-RRC RRCReconfiguration

Attach UE${ue_id} with multiple PDU sessions in ICS
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCSetupRequest
    ...     UE_${ue_id}:NR-RRC_RRCSetup
    ...     alias=UE${ue_id}_RRC_attach  overall_timeout=15

    Expect Message Flow
    ...     AMF1:NGAP_InitialUEMessage
    ...     AMF1:NGAP_InitialContextSetupRequest as InitialContextSetupRequest
    ...     AMF1:NGAP_InitialContextSetupResponse as InitialContextSetupResponse
    ...     alias=UE${ue_id}_NGAP_ICS    overall_timeout=15

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration
    ...     alias=UE${ue_id}_NR-RRC_Reconf  overall_timeout=10

    Expect Message Flow
    ...     AMF1:NGAP_UERadioCapabilityInfoIndication
    ...     alias=UE${ue_id}_NGAP_UERadioCapabilityInfoIndication  overall_timeout=10

    Attach UE${ue_id} with multiple PDU sessions to gNB2 cell1

Attach UE${ue_id} to cell${cell_id} gNB${gnb_id}
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Execute egate command   cmd=ue_register id=${ue_id}
    Sleep  2
    Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${ue_id} nwslice=1
    Sleep  2

Attach UE${ue_id} with multiple PDU sessions to gNB${gnb_id} cell${cell_id}
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Execute egate command   cmd=ue_register id=${ue_id}
    Sleep  2
    Execute egate command   cmd=ue_pdu_session_setup pdu=1 ue=1 gw=1 nwslice=1
    Sleep  3
    Execute egate command   cmd=ue_pdu_session_setup pdu=2 ue=2 gw=2 nwslice=1
    Sleep  5

Configure cells to support EN-DC
    execute egate command   cmd=enb_cell_param enb=1 id=1 allow_endc=on
    execute egate command   cmd=enb_cell_param enb=1 id=2 allow_endc=on
    execute egate command   cmd=enb_cell_param enb=4 id=1 allow_endc=on

Configure PCMD reporting on gNB
    Configure   ${CURDIR}/../config/yaml_config/sib_config.yaml  name=config_sib   bts_id=1
    Configure   ${CURDIR}/../config/yaml_config/cipherPrefL_config.yaml  name=config_ciphering   bts_id=1
    Configure   ${CURDIR}/../config/yaml_config/pcmd_enable_DU_CU.yaml   name=config_PCMD   bts_id=1
    Configure   ${CURDIR}/../config/yaml_config/SNSSAI_config.yaml   name=config_second_SNSSAI   bts_id=1

Detach UE${ue_id:\d+}
    Execute egate command   cmd=deregister_ue id=${ue_id} by=amf

Detach idle UE${ue_id:\d+}
    Execute egate command   cmd=deregister_ue id=${ue_id}

Kill UE${ue_id:\d+}
    Execute egate command   cmd=ue_kill id=${ue_id}

Perform command to drop RRC: Reconfiguration Complete message
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=1 if_contains=any nth=1 action=drop
    Sleep  5

Perform command to configures path switch acknowledgement parameter of a specific AMF
    Execute egate command   cmd=amf_ue_path_switch_param id=1 action=release_pdus pdus=2 cause=RN_CauseRadioNetwork_unspecified
    Sleep  5

Set command to perform reestablishment with reconfigurationFailure cause
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=1 if_contains=any gnb=2 cell=1 action=reestablish cause=reconfigurationFailure
    Sleep  5

Set command for UE_${ue_id} to perform reestablishment with reconfigurationFailure
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any gnb=2 cell=1 action=reestablish cause=reconfigurationFailure
    Sleep  5

Perform command to initiate UE${ue_id} reauthentication
    Execute egate command   cmd=ue_reauth id=${ue_id} nr_sec_cap=null|zuc
    Sleep  2

Remove PDU session for UE${ue_id}
    Execute egate command   cmd=ue_pdu_session_release ue=${ue_id} pdu=1

Run setup for partial HO with gnb reset
    Configure       ${yaml_enable_intraho_partial}
    Sleep   60
    Check Radios Availability

Run Setup
    [Arguments]         ${vonr}=${False}        ${f1ap}=${False}      ${intra_gnb_ho}=${False}      ${inter_gnb_ho}=${False}
    ...                 ${partial_handover}=${False}     ${multiple_amfs}=${False}
    Log To Console    Setup started
    test_setup.Move And Create Empty Telemetry File    path=/opt/iphy/latest
    Find SCFC and send delta commissioning    scfc_filename=delta_setup.json
    Setup emss        bts_id=1
    Log To Console    EMSSIM started
    ${run_update}    Get variable value      ${configure}    "True"
    Run Keyword if  ${run_update} == "True"
    ...         Reach onAir state
    ...         vonr=${vonr}
    ...         intra_gnb_ho=${intra_gnb_ho}
    ...         inter_gnb_ho=${inter_gnb_ho}
    ...         partial_handover=${partial_handover}
    ...         multiple_amfs=${multiple_amfs}
    Setup devices aliases
    Run Keyword if  ${f1ap} != ${False}
    ...         Enable internal mirroring for alias  gNB2
    Setup egate  egate_port=20000  alias=default
    Do not stop egate and daemon

Reach onAir state
    [Arguments]         ${vonr}=${False}         ${intra_gnb_ho}=${False}    ${inter_gnb_ho}=${False}       ${partial_handover}=${False}
    ...                 ${multiple_amfs}=${False}
    Run Keyword if  ${vonr} == ${True}
    ...     append to list      ${yaml_paths_to_configure}      ${yaml_enable_5QI1}     ${yaml_enable_5QI2}
    Run Keyword if  ${intra_gnb_ho} == ${True}
    ...     append to list      ${yaml_paths_to_configure}     ${yaml_enable_intraho}
    Run Keyword if  ${inter_gnb_ho} == ${True}
    ...     append to list      ${yaml_paths_to_configure}     ${yaml_enable_interho}
    Run Keyword if  ${multiple_amfs} == ${True}
    ...     append to list      ${yaml_paths_to_configure}     ${yaml_enable_multiple_amfs}
    Configure       ${yaml_paths_to_configure}
    Discover bts      bts_id=1
    Run Keyword if  ${partial_handover} == ${True}
    ...     Run Setup For Partial HO With Gnb Reset
    test_setup.Setup Wts And Check Onair    lua_cfg=${LUA_CFG}

Setup devices aliases
    create ues alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.30
    Create GNB device with alias 'gNB3_XN' identified by ip=10.0.1.31
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1
    Create AMF device with alias 'AMF2' identified by ip=10.0.1.11

Set expected call flow for UE${ue_id} QoS flow release within existed PDU session
    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceModifyRequest (save_pcmd_many_selected_values) as PDUSessionResourceModifyRequestRelease
    ...     AMF1:NGAP_PDUSessionResourceModifyResponse as PDUSessionResourceModifyResponseRelease
    ...     alias=UE${ue_id}_NGAP_qos_flow_release_succ  overall_timeout=10

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfigurationRelease
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_reconfiguration_release_qos  overall_timeout=15

    Set flow
    ...     NR-RRC_RRCReconfiguration
    ...     NR-RRC_RRCReconfigurationComplete
    ...     device=UE_${ue_id}

Simultaneously add one QoS Flow for more than one PDU sessions for UE
    Run command    ue_pdu_session_modify    raw_cmd_params=ue=1 pdu=1 qosflows_to_add=1 pdu=2 qosflows_to_add=9 by=amf

Simultaneously add and delete QoS Flows for more than one PDU sessions for UE
    Run command    ue_pdu_session_modify    raw_cmd_params=ue=1 pdu=1 qosflows_to_add=9 pdu=2 qosflows_to_del=9 by=amf

Trigger UE${ue_id:\d+} idle mode exit
    Sleep  5
    Run command    ue_im_exit  id=${ue_id}

Trigger UE${ue_id:\d+} to enter idle mode
    Sleep  5
    Run command    ue_im_entry  id=${ue_id}  by=ue

Trigger release ${session_type:(initial|first|second|third|fourth)} PDU session for UE${ue_id:\d+}
    ${pdu_id}       Get From Dictionary         ${session_name_to_pdu}         ${session_type}
    Run command    ue_pdu_session_release  ue=${ue_id}  pdu=${pdu_id}  by=amf

Trigger release of multiple PDU sessions ${multiple_session_types} for UE${ue_id:\d+}
    ${pdu_ids}=      demap_string_with_given_mapping
    ...         string=${multiple_session_types}
    ...         mapping=${session_name_to_pdu}
    ...         return_as_string=${True}
    Run command    ue_pdu_session_release  ue=${ue_id}  pdu=${pdu_ids}  by=amf

Verify that PDU session was successfully released for UE${ue_id}
    Flow Occurred As Expected  alias=UE${ue_id}_NGAP_pdu_remove_succ
    Flow Occurred As Expected  alias=UE${ue_id}_RRC_reconfiguration_remove_pdu

    Verify That Message Fulfills Query
    ...     (length(PDUSessionResourceToReleaseListRelCmd) eq 1)
    ...     message_alias=PDUSessionResourceReleaseRequest
    ...     flow_alias=UE${ue_id}_NGAP_pdu_remove_succ

    Verify That Message Fulfills Query
    ...     (length(drb-ToReleaseList) eq 1)
    ...     message_alias=RRCReconfigurationPDUSessionRelease
    ...     flow_alias=UE${ue_id}_RRC_reconfiguration_remove_pdu

    Verify That Message Fulfills Query
    ...     (length(PDUSessionResourceReleasedListRelRes) eq 1)
    ...     message_alias=PDUSessionResourceReleaseResponse
    ...     flow_alias=UE${ue_id}_NGAP_pdu_remove_succ

Verify that QoS flow was successfully removed from single PDU session for UE${ue_id}
    Flow Occurred As Expected  alias=UE${ue_id}_NGAP_qos_flow_release_succ
    Flow Occurred As Expected  alias=UE${ue_id}_RRC_reconfiguration_release_qos

    Verify That Message Fulfills Query
    ...     (length(QosFlowListWithCause) eq 1)
    ...     message_alias=PDUSessionResourceModifyRequestRelease
    ...     flow_alias=UE${ue_id}_NGAP_qos_flow_release_succ

    Verify That Message Fulfills Query
    ...     (length(drb-ToReleaseList) eq 1)
    ...     message_alias=RRCReconfigurationRelease
    ...     flow_alias=UE${ue_id}_RRC_reconfiguration_release_qos

    Verify That Message Fulfills Query
    ...     (length(PDUSessionResourceModifyListModRes) eq 1)
    ...     message_alias=PDUSessionResourceModifyResponseRelease
    ...     flow_alias=UE${ue_id}_NGAP_qos_flow_release_succ

Verify that NGAP InitialContextSetupResponse contains ${pdu_num} PDU session(s) on ${list_name} for UE
    ${flow}=      Get Flow Name
    ...     procedure=initialContextSetup
    ...     verifier=save_pcmd_many_selected_values
    ...     device=AMF1
    Verify That Message Fulfills Query
    ...     (length(${list_name}) eq ${pdu_num})
    ...     message_alias=InitialContextSetupResponse
    ...     flow_alias=${flow}

Verify that NR-RRC RRCReconfiguration contains ${drb_num} bearer(s) on drb-ToAddModList for UE${ue_id}
    Verify That Message Fulfills Query
    ...     (length(drb-ToAddModList) eq ${drb_num})
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=UE${ue_id}_RRC_attach

Verify that PDU session was added successfully
    Flow Occurred As Expected  alias=UE1_NGAP_PDU_Session_Add
    Flow Occurred As Expected  alias=UE1_RRC_DRB_Add

Verify 2 PDU sessions was successfully added
    Flow Occurred As Expected  alias=UE1_NGAP_PDU_Session_Add
    Flow Occurred As Expected  alias=UE1_RRC_DRB_Add

    Verify That Message Fulfills Query
    ...     (length(PDUSessionResourceSetupListSUReq) eq 2)
    ...     message_alias=PDUSessionResourceSetupRequest
    ...     flow_alias=UE1_NGAP_PDU_Session_Add

    Verify That Message Fulfills Query
    ...     (length(drb-ToAddModList) eq 2)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=UE1_RRC_DRB_Add

Verify that PDU session is released successfully
    Flow Occurred As Expected  alias=UE1_NGAP_PDU_Session_Release
    Flow Occurred As Expected  alias=UE1_RRC_DRB_Release

Verify that UE${ue_id:\d+} attach with ${num:\d+} PDU session was completed successfully
    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupRequest
    ...     list_name=PDUSessionResourceSetupListCxtReq
    ...     element_num=${num}

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupResponse
    ...     list_name=PDUSessionResourceSetupListCxtRes
    ...     element_num=${num}

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupRequest
    ...     list_name=QosFlowSetupRequestList
    ...     element_num=${num}

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupResponse
    ...     list_name=associatedQosFlowList
    ...     element_num=${num}

    Verify in RRCReconfiguration that UE${ue_id} ${num} DRBs were added

Restore AP to usability
    Execute egate command
    ...     cmd=reset
    Sleep    10
    Wait For Object Attribute Value
    ...     object_name=SERVEDAMF-1
    ...     attribute_name=ngLinkStatus
    ...     value=Inactive
    Wait For Object Attribute Value
    ...     object_name=NRCELL-1
    ...     attribute_name=operationalState
    ...     value=disabled
    Execute egate command
    ...     cmd=cfg file=${LUA_CFG}
    Sleep    10
    Wait For Object Attribute Value
    ...     object_name=SERVEDAMF-1
    ...     attribute_name=ngLinkStatus
    ...     value=Active
    wait_for_all_cells_to_be_enabled
    ta5g_egate.Wait For Mib Reception
    ta5g_egate.Wait For Sib1 Reception
    Detach UE For AP Restore Verification
    Sleep       10

    Attach UE for AP restore verification
    Detach UE For AP Restore Verification
    Attach UE for AP restore verification
    Detach UE For AP Restore Verification

Restore AP by reset
    Execute egate command
    ...     cmd=reset
    call_testline_console_reboot
    Log to console      TL reboot
    Sleep       60
    wait_for_all_cells_to_be_configured     timeout=300
    Sleep       10
    Execute egate command
    ...     cmd=cfg file=${LUA_CFG}
    wait_for_all_cells_to_be_enabled
    ta5g_egate.Wait For Mib Reception
    ta5g_egate.Wait For Sib1 Reception
    Sleep       10

Change Serial Number And Product Code For Vdu Scf
    [Arguments]    ${vdu_new_plan}    ${target_distname}    ${vdu_path}
    ${vdu_default_scf_path}=    test_setup.Get Vdu Current Plan File
    ...     vdu_path=${vdu_path}
    test_setup.Change Serial Number And Product Code From Default Scf
    ...     vdu_default_scf_path=${vdu_default_scf_path}
    ...     vdu_new_plan=${vdu_new_plan}
    ...     target_distname=${target_distname}

Perform Commissioning And Check Availability Of Rmods
    [Arguments]    ${scf_vcu}    ${scf_vdu}
    ta5g_commissioning.Perform Commissioning Vcu Aic      path_to_plan_file=${scf_vcu}
    ta5g_commissioning.Send Full Commissioning Vdu Aic    input_filepath=${scf_vdu}    vdu=1
    ${vdu_rmods_online}=    test_setup.Get Vdu Rmods Status
    Should Be True    ${vdu_rmods_online}

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:GNB3_NG_ADDR    ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_XN_ADDR    ip_with_mask=10.0.1.4/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_NG_ADDR    ip_with_mask=10.0.1.3/24
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_XN_ADDR    ip_with_mask=10.0.1.4/24

