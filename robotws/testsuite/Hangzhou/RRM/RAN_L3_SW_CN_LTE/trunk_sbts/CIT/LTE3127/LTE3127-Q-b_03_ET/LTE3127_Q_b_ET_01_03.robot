*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_TDD    RAN_4G    RAN_4G_TDD    CIT
...               CLOUD_R4LAPO_CUS    owner-chenghong.li@nokia.com    owner-eric.jiang    release-TL18    DevHZ5FT2
Default Tags
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{Related_Feature_Switch}
...    @{LTE_IF_Neighbor_Param}
...    @{GERAN_Neighbor_Param}
@{Related_Feature_Switch}
...    LNBTS:actMultBearers=true
...    LNBTS/LNBTS_TDD-0:actConvVoice=true
...    LNBTS:actIfHo=enabled
...    LNBTS:actHOtoWcdma=false
...    LNBTS:actHoFromUtran=true
...    LNBTS:actRedirect=disabled
...    LNBTS:acteNACCtoGSM=false
...    LNBTS/LNBTS_TDD-0:actSrvccToWcdma=false
...    LNBTS/LNBTS_TDD-0:preventPsHOtoWcdma=None
...    LNBTS/LNBTS_TDD-0:actSrvccToGsm=true
...    LNCEL-1:actGsmSrvccMeasOpt=true
...    LNBTS:actServBasedMobThr=true
...    LNBTS:actSelMobPrf=false
...    LNBTS/LNBTS_TDD-0:actInterFreqServiceBasedHo=false
...    delete:LNCEL-1:moPrMappingList
...    delete:MODPR.*
...    delete:MOPR.*
@{LTE_IF_Neighbor_Param}
...    LNBTS/LNADJ-1:cPlaneIpAddr=1.1.1.1
...    LNBTS/LNADJ-1:adjEnbId=11
...    LNBTS/LNADJ-1/LNADJL-1:ecgiLcrId=11
...    LNBTS/LNADJ-1/LNADJL-1:phyCellId=11
...    LNBTS/LNADJ-1/LNADJL-1:fDlEarfcn=40940
...    LNBTS/LNADJ-1/LNADJL-1:tac=666
...    LNCEL-1/LNREL-1:handoverAllowed=allowed
...    LNCEL-1/LNREL-1:ecgiLcrId=2
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=40940
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreq=6
...    LNCEL-1/LNHOIF-1:threshold3InterFreq=23
...    LNCEL-1/LNHOIF-1:threshold3aInterFreq=25
...    LNCEL-1/LNCEL_TDD-0:earfcn=40742
@{GERAN_Neighbor_Param}
...    LNBTS/LNADJG-1:arfcnValueGeran=512
...    LNBTS/LNADJG-1:bandIndicatorGeran=dcs1800
...    LNBTS/LNADJG-1:basestationColourCode=0
...    LNBTS/LNADJG-1:gTargetCi=0
...    LNBTS/LNADJG-1:dtm=false
...    LNBTS/LNADJG-1:gTargetLac=0
...    LNBTS/LNADJG-1:mcc=262
...    LNBTS/LNADJG-1:mnc=3
...    LNBTS/LNADJG-1:mncLength=2
...    LNBTS/LNADJG-1:networkColourCode=0
...    LNBTS/LNADJG-1:networkControlOrder=NC0
...    LNCEL-1/LNHOG-1:b2Threshold1GERANQci1=50
...    LNCEL-1/LNHOG-1:b2Threshold2RssiGERANQci1=20
...    LNCEL-1/LNHOG-1:arfcnValueListGERAN=512
...    LNCEL-1/LNHOG-1:bandIndicatorGERAN=dcs1800
...    LNCEL-1/LNRELG-1:eNACCAllowed=allowed
...    LNCEL-1/LNRELG-1:srvccAllowed=allowed
...    LNCEL-1/LNRELG-1:ci=0
...    LNCEL-1/LNRELG-1:lac=0
...    LNCEL-1/LNRELG-1:plmnId:mcc=262
...    LNCEL-1/LNRELG-1:plmnId:mnc=3
...    LNCEL-1/LNRELG-1:plmnId:mncLength=2
@{OnlineChangeList_Q-b_03}
...    LNCEL-1:threshold2InterFreq=60
...    LNCEL-1:threshold2GERAN=55
...    LNCEL-1:threshold2InterFreqQci1=55
...    LNCEL-1:threshold2GERANQci1=45
...    LNCEL-1:threshold2aQci1=70
...    LNCEL-1:threshold2a=72
...    delete:LNCEL-1:threshold2aHpue
@{OnlineChangeList_Q-b_03_01}
...    LNCEL-1:actGsmSrvccMeasOpt=false
${ue_eutra_capabilities}    D1BFF044033E6CBA2204F84F84F84F84FFFFFFFFFFC0401040104010401052A83800

*** Test Cases ***
LTE3127_Q_b_ET_01_03_Adding SRVCC GSM measurements to ongoing inter-frequency A3 A5
    [Tags]
    Precondition Setting    Online_param=${OnlineChangeList_Q-b_03}
    Step1:UE1 Attach With QCI1 Bearer
    Step2:Adjust Serving Cell Signal Level To Be Below InterFreq A2-threshold2InterFreqQci1 Level
    Step3:Continute Adjust Serving Cell Signal Level To Below Thethreshold2GERANQci1 Level
    Step4:Adjust Serving Cell Signal Level Better Than Threshold2aQci1 To Trigger A1 Measurement Report
    Step5:Disable LTE3127 Online
    Step6:UE2 Attach With QCI1 Bearer
    Step7:Adjust Serving Cell Signal Level To Be Below InterFreq A2-threshold2InterFreqQci1 Level
    Step8:Continute Adjust Serving Cell Signal Level To Below Thethreshold2GERANQci1 Level
    Step9:All UEs Detach

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs    ue_count=2
    Create UE Alias    alias=UE_1    ue_id=1    id_type=cus
    Create UE Alias    alias=UE_2    ue_id=2    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    Add Yaml    UEs/bearer_sets/bearer_set_2
    ...    - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...    - {qci: 1, preprovisioned: on, default: off, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25, filter: 1, precedence: 1, pdn: 1}
    ...    - {qci: 2, gbr_ul: 144, gbr_dl: 144, mbr_ul: 144, mbr_dl: 144, pdn: 1}
    ...    - {qci: 3, gbr_ul: 64, gbr_dl: 128, mbr_ul: 64, mbr_dl: 128, pdn: 1}
    ...    - {qci: 4, gbr_ul: 32, gbr_dl: 330, mbr_ul: 32, mbr_dl: 320, pdn: 1}
    ...    - {qci: 5, pdn: 1}
    ...    - {qci: 6, pdn: 1}
    ...    - {qci: 7, pdn: 1}
    ...    - {qci: 9, pdn: 1}
    ...    - {qci: 8, default: on, pdn: 2, trf_type: external}
    ...    - {qci: 6, pdn: 2}
    ...    - {qci: 7, pdn: 2}
    ...    - {qci: 9, pdn: 2}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_2

Precondition Setting
    [Arguments]    ${Online_param}=${EMPTY}
    Delta Commission Parameters    ${Online_param}

Step1:UE1 Attach With QCI1 Bearer
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionRequest (rrcConnectionRequest contains (establishmentCause eq "mo-Signalling"))
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupListCtxtSUReq contains (e-RAB-ID eq 5 and qCI eq 8, e-RAB-ID eq 6 and qCI eq 1))
    ...    MME_1:S1AP_UECapabilityInfoIndication
    ...    alias=UE1_Attach   overall_timeout=20
    Execute Uex Command    ue_param id=1 csfb_rat=utran_geran voice_domain_preference=cs_preferred srvcc=on
    Execute Egate Command    ue_mme_param id=1 srvcc_operation_possible=yes
    Execute Uex Command    ue_param id=1 ue_eutra_capabilities=${ue_eutra_capabilities}
    Execute Uex Command    ue_attach id=1 enb=1 cell=1
    Flow Occurred As Expected    alias=UE1_Attach

Step2:Adjust Serving Cell Signal Level To Be Below InterFreq A2-threshold2InterFreqQci1 Level
    ${message}=    catenate
    ...    RRC_RRCConnectionReconfiguration (measConfig contains (
    ...    measObjectToAddModList contains (measObjectId eq 2 and carrierFreq eq 40940) and
    ...    reportConfigToAddModList contains ((reportConfigId eq 6 and eventA3 contains (reportOnLeave eq "FALSE")),
    ...    (reportConfigId eq 7 and eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 20) and
    ...    a5-Threshold2 contains (threshold-RSRP eq 30)))) and
    ...    measIdToAddModList contains ((measId eq 14 and measObjectId eq 2 and reportConfigId eq 6),
    ...    (measId eq 15 and measObjectId eq 2 and reportConfigId eq 7))
    ...    ))
    Expect Message Flow
    ...    UE_1:${message}
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=Flow1   overall_timeout=20
    Execute Uex Command    ue_measurement_send id=1 event=A2 srsrp=53
    Flow Occurred As Expected    alias=Flow1

Step3:Continute Adjust Serving Cell Signal Level To Below Thethreshold2GERANQci1 Level
    ${message}=    catenate
    ...    RRC_RRCConnectionReconfiguration (measConfig contains (
    ...    measObjectToAddModList contains (measObjectId eq 3 and measObjectGERAN contains (
    ...    carrierFreqs contains (startingARFCN eq 512 and bandIndicator eq "dcs1800"))) and
    ...    reportConfigToAddModList contains (reportConfigId eq 8 and eventB2 contains (
    ...    b2-Threshold1 contains (threshold-RSRP eq 50) and b2-Threshold2 contains (b2-Threshold2GERAN eq 20))) and
    ...    measIdToAddModList contains (measId eq 14 and measObjectId eq 3 and reportConfigId eq 8) and
    ...    measIdToRemoveList contains (8, 14, 15)
    ...    ))
    Expect Message Flow
    ...    UE_1:${message}
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=Flow2   overall_timeout=20
    Execute Uex Command    ue_measurement_send id=1 event=A2 srsrp=43
    Flow Occurred As Expected    alias=Flow2

Step4:Adjust Serving Cell Signal Level Better Than Threshold2aQci1 To Trigger A1 Measurement Report
    ${message}=    catenate
    ...    RRC_RRCConnectionReconfiguration (measConfig contains (
    ...    measIdToAddModList contains (measId eq 7 and measObjectId eq 1 and reportConfigId eq 3) and
    ...    measIdToRemoveList contains (5, 14) and
    ...    measGapConfig contains (release is present)
    ...    ))
    Expect Message Flow
    ...    UE_1:${message}
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=Flow3   overall_timeout=20
    Execute Uex Command    ue_measurement_send id=1 event=A1 srsrp=72
    Flow Occurred As Expected    alias=Flow3

Step5:Disable LTE3127 Online
    Delta Commission Parameters    ${OnlineChangeList_Q-b_03_01}

Step6:UE2 Attach With QCI1 Bearer
    Expect Message Flow
    ...    UE_2:RRC_RRCConnectionRequest (rrcConnectionRequest contains (establishmentCause eq "mo-Signalling"))
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupListCtxtSUReq contains (e-RAB-ID eq 5 and qCI eq 8, e-RAB-ID eq 6 and qCI eq 1))
    ...    MME_1:S1AP_UECapabilityInfoIndication
    ...    alias=UE2_Attach   overall_timeout=20
    Execute Uex Command    ue_param id=2 csfb_rat=utran_geran voice_domain_preference=cs_preferred srvcc=on
    Execute Egate Command    ue_mme_param id=2 srvcc_operation_possible=yes
    Execute Uex Command    ue_param id=2 ue_eutra_capabilities=${ue_eutra_capabilities}
    Execute Uex Command    ue_attach id=2 enb=1 cell=1
    Flow Occurred As Expected    alias=UE2_Attach

Step7:Adjust Serving Cell Signal Level To Be Below InterFreq A2-threshold2InterFreqQci1 Level
    ${message}=    catenate
    ...    RRC_RRCConnectionReconfiguration (measConfig contains (
    ...    measObjectToAddModList contains (measObjectId eq 2 and carrierFreq eq 40940) and
    ...    reportConfigToAddModList contains ((reportConfigId eq 6 and eventA3 contains (reportOnLeave eq "FALSE")),
    ...    (reportConfigId eq 7 and eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 20) and
    ...    a5-Threshold2 contains (threshold-RSRP eq 30)))) and
    ...    measIdToAddModList contains ((measId eq 14 and measObjectId eq 2 and reportConfigId eq 6),
    ...    (measId eq 15 and measObjectId eq 2 and reportConfigId eq 7))
    ...    ))
    Expect Message Flow
    ...    UE_2:${message}
    ...    UE_2:RRC_RRCConnectionReconfigurationComplete
    ...    alias=Flow4   overall_timeout=20
    Execute Uex Command    ue_measurement_send id=2 event=A2 srsrp=53
    Flow Occurred As Expected    alias=Flow4

Step8:Continute Adjust Serving Cell Signal Level To Below Thethreshold2GERANQci1 Level
    ${message}=    catenate
    ...    RRC_RRCConnectionReconfiguration (measConfig contains (
    ...    measObjectToAddModList contains (measObjectId eq 3 and measObjectGERAN contains (
    ...    carrierFreqs contains (startingARFCN eq 512 and bandIndicator eq "dcs1800"))) and
    ...    reportConfigToAddModList contains (reportConfigId eq 8 and reportConfigInterRAT contains (eventB2 contains (
    ...    b2-Threshold1 contains (threshold-RSRP eq 50) and b2-Threshold2 contains (b2-Threshold2GERAN eq 20)))) and
    ...    measIdToAddModList contains (measId eq 16 and measObjectId eq 3 and reportConfigId eq 8) and
    ...    measIdToRemoveList contains (8)
    ...    ))
    Expect Message Flow
    ...    UE_2:${message}
    ...    UE_2:RRC_RRCConnectionReconfigurationComplete
    ...    alias=Flow5   overall_timeout=20
    Execute Uex Command    ue_measurement_send id=2 event=A2 srsrp=43
    Flow Occurred As Expected    alias=Flow5

Step9:All UEs Detach
    sleep    2s
    Execute Uex Command    ue_detach id=1
    Execute Uex Command    ue_detach id=2
