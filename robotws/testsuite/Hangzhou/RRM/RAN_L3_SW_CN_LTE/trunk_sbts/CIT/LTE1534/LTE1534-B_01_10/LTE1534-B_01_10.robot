*** Setting ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_TDD    RAN_4G    RAN_4G_TDD    CIT
...               CLOUD_R4LAPO_CUS    owner-wenying.lu@nokia.com    owner-eric.jiang    release-legacy    team-RT1
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${UE_EUTRA_CAPABILITIES}    C99FF4096081C0FFFFFFFFE0010000
@{PARAMS_IN_SCF}
...    LNBTS:actFlexScellSelect=false
...    LNBTS:actDLCAggr=false
...    LNBTS:actULCAggr=false
...    LNBTS/MFBIPR-1:addFreqBandInd=38
...    LNBTS/MFBIPR-1:eutraCarrierFreq=40540
...    LNBTS:actMFBI=true
...    LNBTS:actAdvScellMeas=false
...    LNBTS/MFBIPR-2:addFreqBandInd=38
...    LNBTS/MFBIPR-2:eutraCarrierFreq=40740
...    LNBTS:actIfHo=enabled
...    LNCEL-1/LNCEL_TDD-0:earfcn=40540
...    LNCEL-2/LNCEL_TDD-0:earfcn=40740
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=40740
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=40540
...    LNCEL-1/LNREL-1:ecgiLcrId=2
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-1:ecgiLcrId=1
...    LNCEL-2/LNREL-1:ecgiAdjEnbId=1
...    delete:MOPR.*
...    delete:MODPR.*
...    delete:LNCEL-1:moPrMappingList
...    delete:LNCEL-2:moPrMappingList
...    delete:LNCEL-3:moPrMappingList
...    LNCEL-1:threshold2InterFreq=60
...    LNCEL-1:threshold2a=70
...    LNCEL-2:threshold2InterFreq=60
...    LNCEL-2:threshold2a=72
...    LNCEL-1:inactivityTimer=2000
...    LNCEL-2:inactivityTimer=2000

*** Test Cases ***
LTE1534-B_01_10_Inter Frequency with mapped band Intra eNB Handover
    [Tags]
    UE1 attach to eNB1 Cell1
    Start UL DL Udp Traffic
    Trigger HO Cell1 to Cell2 to Cell1
    Stop UL DL Udp Traffic

*** Keywords ***      Action
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs    ue_count=1
    Create UE Alias    alias=UE_1    ue_id=1    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

UE1 attach to eNB1 Cell1
    [Arguments]    ${ue_eutra_capabilities}=${UE_EUTRA_CAPABILITIES}
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionRequest (rrcConnectionRequest contains (establishmentCause eq "mo-Signalling"))
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupListCtxtSUReq contains (e-RAB-ID eq 5 and qCI eq 8))
    ...    MME_1:S1AP_UECapabilityInfoIndication
    ...    alias=UE1_Attach   overall_timeout=20
    Execute Uex Command    ue_param id=1 ue_eutra_capabilities=${ue_eutra_capabilities}
    Execute Uex Command    ue_attach id=1 enb=1 cell=1
    Flow Occurred As Expected    alias=UE1_Attach

Start UL DL Udp Traffic
    Execute Uex Command    trf_data_start ue=1 qci=8 dir=dl protocol=udp Mbps=30 qci=8 duration=600 trf_id=1
    Execute Uex Command    trf_data_start ue=1 qci=8 dir=dl protocol=udp Mbps=30 qci=8 duration=600 trf_id=2
    Execute Uex Command    trf_data_start ue=1 qci=8 dir=ul protocol=udp Mbps=20 qci=8 duration=600 trf_id=3
    Sleep    30s

Trigger HO Cell1 to Cell2 to Cell1
    ${message1}=    catenate
    ...    RRC_RRCConnectionReconfiguration (
    ...    measConfig contains (
    ...    measObjectToAddModList contains (measObjectId eq 2 and carrierFreq eq 38100) and
    ...    reportConfigToAddModList contains (reportConfigId eq 6 and eventA3 contains (reportOnLeave eq "FALSE"))
    ...    ))
    Expect Message Flow
    ...    UE_1:${message1}
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=Flow1   overall_timeout=20
    Execute Uex Command    get_ue_meas_config id=1
    ${ret}=    Execute Uex Command    ue_measurement_send id=1 event=A2 phycell_id=2 srsrp=50 nrsrp=69 nrsrq=34    # A2
    Flow Occurred As Expected    alias=Flow1
    ${message2_1}=    catenate
    ...    RRC_RRCConnectionReconfiguration (
    ...    mobilityControlInfo contains (targetPhysCellId eq 2 and carrierFreq contains (dl-CarrierFreq eq 38100)))
    ${message2_2}=    catenate
    ...    RRC_RRCConnectionReconfiguration (measConfig contains (measObjectToAddModList contains (measObjectId eq 2 and carrierFreq eq 38100)))
    Expect Message Flow
    ...    UE_1:${message2_1}
    ...    UE_1:${message2_2}
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=Flow2   overall_timeout=20
    Execute Uex Command    get_ue_meas_config id=1
    ${ret}=    Execute Uex Command    ue_measurement_send id=1 event=A3 phycell_id=2 srsrp=50 nrsrp=69 nrsrq=34    # A3
    Sleep    3s
    Flow Occurred As Expected    alias=Flow2
    ${message3}=    catenate
    ...    RRC_RRCConnectionReconfiguration (measConfig contains (measObjectToAddModList contains (measObjectId eq 1 and carrierFreq eq 37900) and
    ...    measIdToRemoveList contains (7) and measIdToAddModList contains (measId eq 14 and measObjectId eq 1 and reportConfigId eq 6)))
    Expect Message Flow
    ...    UE_1:${message3}
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=Flow3   overall_timeout=20
    Execute Uex Command    get_ue_meas_config id=1
    ${ret}=    Execute Uex Command    ue_measurement_send id=1 event=A2 phycell_id=1 srsrp=50 nrsrp=69 nrsrq=34    # A2
    Flow Occurred As Expected    alias=Flow3
    ${message4_1}=    catenate
    ...    RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 1 and carrierFreq contains (dl-CarrierFreq eq 37900)))
    ${message4_2}=    catenate
    ...    RRC_RRCConnectionReconfiguration (measConfig contains (measObjectToAddModList contains (measObjectId eq 1 and carrierFreq eq 37900)))
    Expect Message Flow
    ...    UE_1:${message4_1}
    ...    UE_1:${message4_2}
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=Flow4   overall_timeout=20
    Execute Uex Command    get_ue_meas_config id=1
    ${ret}=    Execute Uex Command    ue_measurement_send id=1 event=A3 phycell_id=1 srsrp=50 nrsrp=69 nrsrq=34    # A3
    Sleep    3s
    Flow Occurred As Expected    alias=Flow4

Stop UL DL Udp Traffic
    Execute Uex Command    trf_data_stop ue=1 qci=8 dir=dl_and_ul
