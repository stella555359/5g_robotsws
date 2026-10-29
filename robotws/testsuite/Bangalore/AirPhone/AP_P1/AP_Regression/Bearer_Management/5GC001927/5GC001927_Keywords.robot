*** Settings ***
Documentation     Keywords for 5GC001927 feature
Resource          ../../../Resources/robot/log.robot
Resource          ../../../Resources/robot/ute_setup.robot
Resource          ../../../Resources/robot/wts.robot
Resource          ../../../Resources/robot/gnb.robot
Library           ../../../Resources/Python/pdml_analyser.py
Resource          ../../../Resources/Variables/Common_Variables.robot
Library           ../../../Resources/Python/DeltaStore.py    WITH NAME    delta_store
Resource          ../../../Resources/robot/suite_common_keywords.robot

*** Variables ***
${TRAFFIC_DURATION}           10s
${timeout}                    25s

*** Keywords ***
Stop Pcap And Convert And Store PDML
    ${pdml_file}=   Stop pcap and convert X2AP to pdml
    Set Test Variable   ${pdml_file}

Verify Message Sequence for SgNBModification Before Cases
    ${message_sequence}=    Catenate    SgNBModificationRequest    SgNBModificationRequest    SgNBModificationRequestAcknowledge
    ...    SgNBReconfigurationComplete
    Stop Pcap And Convert And Store PDML
    Verify Message Sequence In X2 Trace    messages=${message_sequence}
    Verify Message Sequence Not In X2 Trace    messages=SgNBModificationReject
    Verify Message Sequence Not In X2 Trace    messages=ErrorIndication

Verify Message Sequence for SgNBModification After Cases
    ${message_sequence}=    Catenate    SgNBModificationRequest    SgNBModificationRequestAcknowledge    SgNBModificationRequest
    ...    SgNBReconfigurationComplete    SgNBModificationRequestAcknowledge    SgNBReconfigurationComplete
    Stop Pcap And Convert And Store PDML
    Verify Message Sequence In X2 Trace    messages=${message_sequence}
    Verify Message Sequence Not In X2 Trace    messages=SgNBModificationReject
    Verify Message Sequence Not In X2 Trace    messages=ErrorIndication

Verify Message Sequence In X2 Trace
    [Arguments]    ${messages}=none
    Verify Message Sequence In PDML File    pdml_file=${pdml_file}    messages=${messages}

Verify Message Sequence Not In X2 Trace
    [Arguments]    ${messages}=none
    Verify Message Sequence Not In PDML File    pdml_file=${pdml_file}    messages=${messages}

Bearer Stats from
    [Arguments]    ${ue_id}=1    ${bearer}=2
    Get UE bearers    ue_id=${ue_id}
    Get Bearer Stats    ue_id=${ue_id}    bearer=${bearer}    dir=dl    dc_cell_group=mcg
    Get Bearer Stats    ue_id=${ue_id}    bearer=${bearer}    dir=ul    dc_cell_group=mcg
    Get Bearer Stats    ue_id=${ue_id}    bearer=${bearer}    dir=dl    dc_cell_group=scg
    Get Bearer Stats    ue_id=${ue_id}    bearer=${bearer}    dir=ul    dc_cell_group=scg

Activate Failure Scenario
    [Arguments]    ${ue}=1    ${enb}=1    ${rrc_delay}=0    ${menb_failure_scenario}=no_menb_failure_scenario
    ...    ${menb_forced_scenario}=none    ${abnormal_scenario}=disable
    Modify ENB Sim Parameters Online    enb=${enb}    x2_sctp_nodelay=on
    Modify ENB dual Connectivity Parameters    enb=${enb}    drb_change=on
    Trigger MENB Failure Scenario    enb=${enb}    menb_failure_scenario=${menb_failure_scenario}
    Trigger MENB Forced Scenario    ue=${ue}    menb_forced_scenario=${menb_forced_scenario}
    Trigger Abnormal Scenario    ue=${ue}    abnormal_scenario=${abnormal_scenario}
    Configure RRC Reconfig Param Rules    ue=${ue}    rrc_delay=${rrc_delay}

Verify Traffic On 5G only
    [Arguments]    ${ue}=1    ${kbps}=${DEFAULT_DATA_RATE}    ${bearer_start}=2    ${bearer_stop}=None
    Get UE bearers    ue_id=${ue}
    ${bearer_stop}    Set Variable If    "${bearer_stop}"=="None"    ${bearer_start}    ${bearer_stop}
    ${limit}=    Get Throughput Limit    ${kbps}
    FOR    ${b}    IN RANGE    ${bearer_start}    ${bearer_stop}+1
        Verify if average DL is correct    bearer=${b}    ue_id=${ue}    limit=${limit}    dc_cell_group=scg
        Verify if average UL is correct    bearer=${b}    ue_id=${ue}    limit=${limit}    dc_cell_group=all
        Verify Packet Loss    bearer=${b}    ue=${ue}    direction=dl    dc_cell_group=scg
        Verify Packet Loss    bearer=${b}    ue=${ue}    direction=ul    dc_cell_group=mcg
    END

Sgnb Addition And Wait For Data Transfer
    [Arguments]    ${ue_id}    ${bearer}    ${target_gnb}    ${target_cells}
    SGNB Addition For Bearer    ue_id=${ue_id}    bearer=${bearer}    target_gnb=${target_gnb}    target_cells=${target_cells}
    Sleep    ${TRAFFIC_DURATION}

Sgnb Modification And Wait For Data Transfer
    [Arguments]    ${ue_id}    ${bearer}    ${modification}=bearer_to_add    ${pass_regexp}=Successfully reconfigured dual connectivity
    Run Keyword If    "${modification}"=="bearer_to_add"
    ...    Modify ENDC Add Bearer    ue_id=${ue_id}    bearer=${bearer}    cause=MISC_CauseMisc_unspecified    pass_regexp=${pass_regexp}
    ...    ELSE    Modify ENDC Release Bearer    ue_id=${ue_id}    bearer=${bearer}    cause=MISC_CauseMisc_unspecified
    Sleep    ${TRAFFIC_DURATION}
