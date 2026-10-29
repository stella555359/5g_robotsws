*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 2DU
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    team-DevHZ5_SG1    owner-tom.li    release-5G23R3
...    CLOUD_5GC_dRNIC_2vDU_P_AP_LOO_DC    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    master_vDU
Resource    ../../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2du/4cells_du1_2T_du2_2T

@{PARAMS_IN_SCF_CU}    @{HO}    @{NRREL}    @{A3_event}    @{SRB3}    @{rrcReestabTypeSAEqualSameGNB}
@{PARAMS_IN_SCF_DU1}    @{DU_NRREL}    @{SSB}
@{PARAMS_IN_SCF_DU2}    @{DU_NRREL}    @{SSB}

@{HO}
...    NRBTS-1:actIntraFreqIntraGnbMobilityNSA=true

@{NRREL}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

@{A3_event}
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:sMeasConfigSsbRsrp=1

@{SRB3}
...    NRBTS-1:srb3SupportEnabled=true
...    NRBTS-1:cipherPrefL:nea0=1
...    NRBTS-1:cipherPrefL:nea1_128=3
...    NRBTS-1:cipherPrefL:nea2_128=4
...    NRBTS-1:cipherPrefL:nea3_128=2
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9

@{SSB}
...    NRCELL:cbraPreamblesPerSsb=n60
...    NRCELL:rsrpThresholdSSB=11

@{DU_NRREL}
...    NRCELL/NRREL-1

${ue_id}    31

@{rrcReestabTypeSAEqualSameGNB}
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:tRLFindForDUSA=2000ms
...    NRBTS:tWaitingRlRecoverSA=5000ms

${wait_oldresource_release}    8s

*** Test Cases ***
CB008926-SR-A-B4_ET_01_07_NG link reset without RAN NGAP ID can be handled correctly in AiC
    [Tags]
    set parameters before case
    ${AMF_UE_NGAP_ID_UE}    ${RAN_UE_NGAP_ID_UE}    Register For Normal Call and create PDU Successfully    ue_id=1    cell_id=1
    ${AMF_UE_NGAP_ID_UE_2}    ${RAN_UE_NGAP_ID_UE_2}    Register For Normal Call and create PDU Successfully    ue_id=2    cell_id=1
    Set Test Variable    \${AMF_UE_NGAP_ID_UE}    ${AMF_UE_NGAP_ID_UE}
    Set Test Variable    \${RAN_UE_NGAP_ID_UE}    ${RAN_UE_NGAP_ID_UE}
    trigger nglinkreset for UE1
    Release Ues    ue_type=all
    Check WireShark Log Aic    ${CURDIR}${/}A2A_A-B4-07${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008926-SR-B-B1_ET_01_01_UE RRC reestablishment sucessful on original cell in AiC
    [Tags]
    set parameters before case
    Register For Normal Call and create PDU Successfully    ue_id=1    cell_id=1
    Register For Normal Call and create PDU Successfully    ue_id=2    cell_id=2
    trigger Reestablishment
    Release Ues    ue_type=all

CB008926-SR-B-B1_ET_01_03_UE RRC reestablishment with invalid short-mac in AiC
    [Tags]
    set parameters before case
    Register For Normal Call and create PDU Successfully    ue_id=1    cell_id=1
    Register For Normal Call and create PDU Successfully    ue_id=2    cell_id=2
    trigger reestablishment with invalid short-mac
    sleep    ${wait_oldresource_release}
    Release Ues    ue_type=all

CB008926-SR-B-B4_ET_01_01_PDU modification can be done after UE RRC reestablishment in AiC
    [Tags]
    set parameters before case
    Register For Normal Call and create PDU Successfully    ue_id=1    cell_id=1
    Register For Normal Call and create PDU Successfully    ue_id=2    cell_id=1
    trigger reestablishment before PDU modification
    trigger PDU modification after reestablishment
    sleep    ${wait_oldresource_release}
    Release Ues    ue_type=all

*** Keywords ***
Modify Cfg Aic
    Update Cfg Aic    set_qosflow id=2 5qi=5
    Update Cfg Aic    set_qosflow id=3 5qi=1

set parameters before case
    Execute Egate Command    trace_sim amf=1 on

Register For Normal Call and create PDU Successfully
    [Arguments]    ${ue_id}    ${cell_id}
    [return]    ${AMF_UE_NGAP_ID_UE}    ${RAN_UE_NGAP_ID_UE}
    Register For Normal Call Successfully    ${ue_id}    ${cell_id}
    ${AMF_UE_NGAP_ID_UE}    ${RAN_UE_NGAP_ID_UE}    UE PDU Session Setup    ${ue_id}    ${ue_id}

Register For Normal Call Successfully
    [Arguments]    ${ue_id}    ${cell_id}    ${enb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
    UE Register To GNB    ${ue_id}

UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${gw_id}=1
    [return]    ${AMF_UE_NGAP_ID_UE[0]}    ${RAN_UE_NGAP_ID_UE[0]}
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${gw_id}    QoS Routing Table
    ${AMF_UE_NGAP_ID_UE}    Get Regexp Matches    ${ret1}    value AMF-UE-NGAP-ID : (\\d+)    1
    ${RAN_UE_NGAP_ID_UE}    Get Regexp Matches    ${ret1}    value RAN-UE-NGAP-ID : (\\d+)    1

Modify UE Establishemnt Cause
    [Arguments]    ${ue_id}    ${cause}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${cause}

UE Register To GNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg

trigger nglinkreset for UE1
    Execute Egate Command    link_ng_reset by=amf:1 ue=1 ue_ngap_id_type=amf    pass_regexp=NgLink::OnReceiveNgResetAcknowledge

trigger Reestablishment
    ${expect_output}    Create List
    ...    UE1: NR RRC Reestablishment suc
    ...    message c1 : rrcReconfigurationComplete
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=1 gnb=2 cell=1 cause=otherFailure
    ...    pass_regexp=${expect_output}

trigger reestablishment with invalid short-mac
    ${expect_output}    Create List
    ...    rrcSetupComplete
    ...    QoS Routing Table
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=1 gnb=2 cell=1 cause=otherFailure action=invalid_short_mac_i
    ...    pass_regexp=${expect_output}
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=2 gnb=2 cell=1 cause=otherFailure action=invalid_short_mac_i
    ...    pass_regexp=${expect_output}

trigger reestablishment before PDU modification
    ${expect_output}    Create List
    ...    UE1: NR RRC Reestablishment suc
    ...    message c1 : rrcReconfigurationComplete
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=1 gnb=2 cell=1 cause=otherFailure
    ...    pass_regexp=${expect_output}
    ${expect_output}    Create List
    ...    rrcSetupComplete
    ...    QoS Routing Table
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=1 gnb=2 cell=2 cause=otherFailure
    ...    pass_regexp=${expect_output}

trigger PDU modification after reestablishment
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf    pass_regexp=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=2 pdu=1 qosflows_to_add=2 by=amf    pass_regexp=QoS Routing Table
