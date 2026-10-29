*** Settings ***
Documentation

Library     ta5g_cell_operations
Resource    ../../../resources/Robot/common_settings.robot
Library     ../../resources/former_devkr/python/mock_stop_egate.py
Library     taf.sbts.oam.coam.admin      WITH NAME    coam
Library     taf.ul.ue.sim.env_setup
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

*** Variables ***
${ADMIN_CONNECTION}=  admin_connection

*** Keywords ***
Run Setup
    ${run_update}    get variable value      ${configure}    "True"     # do not ever change that line!
    Run Keyword if  ${run_update} != ${False}
    ...    Prepare TL with config files
    Setup egate  egate_port=20000  alias=default    save_egate=True
    Reliable emss setup         bts_id=1
    Setup devices aliases
    Setup connection to admin  ${ADMIN_CONNECTION}

Prepare TL with config files
    Add gNB configuration    scfc=${SCFC}    #rad_params=${RAD_PARAMS}
    Add simulator    sim_type=airphone    config=${AP_XML}
    Add 5GC    config=${LUA_CFG}    edaemon_ports=10000
    Configure environment    rmod_detection_timeout=420s

Setup devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create ENB device with alias 'eNB1' identified by ip=10.0.1.21
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.30
    Create GNB device with alias 'gNB3_XN' identified by ip=10.0.1.31
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Common Teardown
    Run Keyword And Ignore Error    Detach NSA UE and kill if failed    ue_id=${NSA_UE_id}
    Run Keyword And Ignore Error    Detach SA UE and kill if failed    ue_id=${SA_UE_id}
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Choose NRRFSP PROFILE by rfsp value
    [Arguments]    ${ue_id}    ${IndexToRFSP_value}
    Execute egate command    cmd=ue_amf_ics_param id=${ue_id} indexToRFSP=${IndexToRFSP_value}

Choose NRSPID PROFILE by spid value
    [Arguments]    ${ue_id}    ${spid_value}
    Execute egate command    cmd=ue_enb_param id=${ue_id} spid=${spid_value}

Attach UE and Verify RFSP inactivitytimer in BearerContextSetup
    [Arguments]    ${ue_id}    ${cell_id}    ${IndexToRFSP_value}    ${inactivity_timer_value}    ${notification_level}
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    Attach UE${ue_id} to gNB2 CELL${cell_id} with ICS during PDU session setup
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    Verify IndexToRFSP in InitialContextSetup    IndexToRFSP_value=${IndexToRFSP_value}
    Verify inactivitytimer in BearerContextSetup    notification_level=${notification_level}
    ...                                             inactivity_timer_value=${inactivity_timer_value}

Attach UE and Verify SPID inactivitytimer in BearerContextSetup
    [Arguments]    ${ue_id}    ${cell_id}    ${spid_value}    ${inactivity_timer_value}    ${notification_level}
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 X2AP sgNBAdditionPreparation
    Attach UE${ue_id} to simulated eNB1 CELL-1
    Start DC on UE    ue_id=${ue_id}    cell_id=${cell_id}
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 X2AP sgNBAdditionPreparation
    Verify SubscriberProfileIDforRFP in SgNBAddition    spid_value=${spid_value}
    Verify inactivitytimer in BearerContextSetup    notification_level=${notification_level}
    ...                                             inactivity_timer_value=${inactivity_timer_value}

Handover UE and Verify SPID inactivitytimer in BearerContextSetup
    [Arguments]    ${ue_id}    ${cell_id}    ${spid_value}    ${inactivity_timer_value}    ${notification_level}
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 X2AP sgNBAdditionPreparation
    Attach UE${ue_id} to simulated eNB1 CELL-1
    Start DC on UE    ue_id=${ue_id}    cell_id=${cell_id}
    Handover UE${ue_id} from simulated eNB1 CELL-1 to CELL-2
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 X2AP sgNBAdditionPreparation
    Verify SubscriberProfileIDforRFP in SgNBAddition    spid_value=${spid_value}
    Verify inactivitytimer in BearerContextSetup    notification_level=${notification_level}
    ...                                             inactivity_timer_value=${inactivity_timer_value}

Attach UE and Verify RFSP inactivitytimer in BearerContextModification
    [Arguments]    ${ue_id}    ${cell_id}    ${IndexToRFSP_value}    ${inactivity_timer_value}    ${notification_level}
    ...            ${new_inactivity_timer_value}    ${profile_id}
    Attach UE and Verify RFSP inactivitytimer in BearerContextSetup
    ...    ue_id=${ue_id}
    ...    cell_id=${cell_id}
    ...    IndexToRFSP_value=${IndexToRFSP_value}
    ...    inactivity_timer_value=${inactivity_timer_value}
    ...    notification_level=${notification_level}
    Execute egate command    cmd=trf_data_start ue=${ue_id} protocol=udp mbps=10 id=2 dir=dl
    Change rfspInactivityTimer value    profile_id=${profile_id}    value=${new_inactivity_timer_value}
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Modify PDU Session on UE    ue_id=${ue_id}
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Verify inactivitytimer in BearerContextModification    notification_level=${notification_level}
    ...                                                    inactivity_timer_value=${new_inactivity_timer_value}
    [Teardown]    Change rfspInactivityTimer value    profile_id=${profile_id}    value=${inactivity_timer_value}

Attach UE and Verify SPID inactivitytimer in BearerContextModification
    [Arguments]    ${ue_id}    ${cell_id}    ${spid_value}    ${inactivity_timer_value}    ${notification_level}
    ...            ${new_inactivity_timer_value}    ${profile_id}
    Attach UE and Verify SPID inactivitytimer in BearerContextSetup
    ...    ue_id=${ue_id}
    ...    cell_id=${cell_id}
    ...    spid_value=${spid_value}
    ...    inactivity_timer_value=${inactivity_timer_value}
    ...    notification_level=${notification_level}
    Execute egate command    cmd=trf_data_start ue=${ue_id} protocol=udp mbps=10 id=2 dir=dl
    Change spidInactivityTimer value    profile_id=${profile_id}    value=${new_inactivity_timer_value}
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Modify DC on UE    ue_id=${ue_id}
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Verify inactivitytimer in BearerContextModification    notification_level=${notification_level}
    ...                                                    inactivity_timer_value=${new_inactivity_timer_value}
    [Teardown]    Change spidInactivityTimer value    profile_id=${profile_id}    value=${inactivity_timer_value}

Verify inactivitytimer in BearerContextSetup
    [Arguments]    ${notification_level}    ${inactivity_timer_value}
    Run Keyword If    '${notification_level}' == 'drb'
    ...    Verify DRB inactivitytimer in BearerContextSetup    drb_inactivity_timer_value=${inactivity_timer_value}
    ...    ELSE IF    '${notification_level}' == 'ue'
    ...    Verify UE inactivitytimer in BearerContextSetup    ue_inactivity_timer_value=${inactivity_timer_value}
    ...    ELSE    FAIL    msg=Unknown notification level, please use either 'drb' or 'ue'

Verify inactivitytimer in BearerContextModification
    [Arguments]    ${notification_level}    ${inactivity_timer_value}
    Run Keyword If    '${notification_level}' == 'drb'
    ...    Verify DRB inactivitytimer modification in BearerContextModification
    ...    drb_inactivity_timer_value=${inactivity_timer_value}
    ...    ELSE IF    '${notification_level}' == 'ue'
    ...    Verify UE inactivitytimer is not present in BearerContextModification
    ...    ELSE    FAIL    msg=Unknown notification level, please use either 'drb' or 'ue'

Handover UE${ue_id} from simulated eNB1 CELL-1 to CELL-2
    execute egate command and wait for data    cmd=ue_ho id=${ue_id} enb=1 cell=2
    ...    pass_regexp=UE${ue_id}: Intra-eNB handover from ENB-1.1 to ENB-1.2 performed

Detach SA UE
    [Arguments]    ${ue_id}
    Execute egate command    cmd=ue_deregister id=${ue_id} by=amf

Detach NSA UE
    [Arguments]    ${ue_id}
    Execute egate command    cmd=detach_ue id=${ue_id}

Verify IndexToRFSP in InitialContextSetup
    [Arguments]    ${IndexToRFSP_value}
    ${flow}=    Get flow name
    ...     procedure=initialContextSetup
    ...     device=AMF1
    ...     protocol=NGAP

    Verify That Message Fulfills Query
    ...     IndexToRFSP eq ${IndexToRFSP_value}
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow}

Verify SubscriberProfileIDforRFP in SgNBAddition
    [Arguments]    ${spid_value}
    ${flow}=    Get flow name
    ...     procedure=sgNBAdditionPreparation
    ...     device=gNB2
    ...     protocol=X2AP

    Verify That Message Fulfills Query
    ...     SubscriberProfileIDforRFP eq ${spid_value}
    ...     message_alias=SgNBAdditionRequest
    ...     flow_alias=${flow}

Verify DRB inactivitytimer in BearerContextSetup
    [Arguments]    ${drb_inactivity_timer_value}
    ${flow}=    Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB2
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     dRB-Inactivity-Timer eq ${drb_inactivity_timer_value}
    ...     message_alias=BearerContextSetupRequest
    ...     flow_alias=${flow}

Verify UE inactivitytimer in BearerContextSetup
    [Arguments]    ${ue_inactivity_timer_value}=100
    ${flow}=    Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB2
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     Inactivity-Timer eq ${ue_inactivity_timer_value}
    ...     message_alias=BearerContextSetupRequest
    ...     flow_alias=${flow}

Verify DRB inactivitytimer modification in BearerContextModification
    [Arguments]    ${drb_inactivity_timer_value}
    ${flow}=    Get flow name
    ...     procedure=bearerContextModification
    ...     device=gNB2
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     dRB-Inactivity-Timer eq ${drb_inactivity_timer_value}
    ...     message_alias=BearerContextModificationRequest
    ...     flow_alias=${flow}

Verify UE inactivitytimer is not present in BearerContextModification
    ${flow}=    Get flow name
    ...     procedure=bearerContextModification
    ...     device=gNB2
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     Inactivity-Timer is not present
    ...     message_alias=BearerContextModificationRequest
    ...     flow_alias=${flow}

Verify bearer context inactivity notification after InactivityTimer expires
    [Arguments]    ${timeout}
    Sleep    2s
    EXPECT FLOW[timeout=${timeout}]: gNB2 E1AP bearerContextInactivityNotification
    PASS FLOW[timeout=${timeout}]: gNB2 E1AP bearerContextInactivityNotification

Verify UE context release after srbInactivityTimerSA expires
    [Arguments]    ${timeout}
    Sleep    2s
    EXPECT FLOW[timeout=${timeout}]: AMF1 NGAP uEContextReleaseRequest
    PASS FLOW[timeout=${timeout}]: AMF1 NGAP uEContextReleaseRequest

Change activitynotificationlevelSA value
    [Arguments]    ${value}
    Configure  [{'MOC': 'NRBTS', 'ID': '1', 'activitynotificationlevelSA': '${value}'}]

Change nsaActivityNotificationLevel value
    [Arguments]    ${value}
    Configure  [{'MOC': 'NRBTS', 'ID': '1', 'nsaActivityNotificationLevel': '${value}'}]

Change rfspInactivityTimer value
    [Arguments]    ${profile_id}    ${value}
    Configure  [{'MOC': 'NRRFSP_PROFILE', 'ID': '${profile_id}', 'rfspInactivityTimer': '${value}'}]

Change spidInactivityTimer value
    [Arguments]    ${profile_id}    ${value}
    Configure  [{'MOC': 'NRSPID_PROFILE', 'ID': '${profile_id}', 'spidInactivityTimer': '${value}'}]

Start DC on UE
    [Arguments]    ${ue_id}    ${cell_id}
    Execute egate command   cmd=ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg

Start PDU Session on UE
    [Arguments]    ${ue_id}
    Execute egate command   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=1 nwslice=1

Modify DC on UE
    [Arguments]    ${ue_id}
    Execute egate command
    ...    cmd=ue_dc_enb_modify ue=${ue_id} bearer_to_add=3 by=enb cause=RN_action_desirable_for_radio_reasons

Modify PDU Session on UE
    [Arguments]    ${ue_id}
    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=7

Remove PDU session from UE
    [Arguments]    ${ue_id}
    Execute egate command   cmd=ue_pdu_session_release ue=${ue_id}  pdu=1  by=amf

Detach SA UE and kill if failed
    [Arguments]    ${ue_id}
    ${status}=     Run Keyword And Return Status
    ...  Execute egate command
    ...  cmd=ue_deregister id=${ue_id} by=amf
    ...  pass_regexp=UE${ue_id}: detached
    Run Keyword If      ${status} != ${TRUE}    Execute egate command  cmd=ue_kill id=${ue_id}

Detach NSA UE and kill if failed
    [Arguments]    ${ue_id}
    ${status}=     Run Keyword And Return Status
    ...  Execute egate command
    ...  cmd=detach_ue id=${ue_id}
    ...  pass_regexp=UE${ue_id}: detached
    Run Keyword If      ${status} != ${TRUE}    Execute egate command  cmd=ue_kill id=${ue_id}
    Sleep    2
