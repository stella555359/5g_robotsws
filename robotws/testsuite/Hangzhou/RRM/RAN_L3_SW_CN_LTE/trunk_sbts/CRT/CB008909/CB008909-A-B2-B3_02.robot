*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CRT    team-DevHZ5_SG4
...               CLOUD_R4LAPO_CUS    release-SBTS23R3    owner-rebecca.zhong
Resource          ../../../resources/DevHZ5_resource.robot
*** Variables ***
@{PARAMS_IN_SCF}
...    @{Feature_flag}
...    @{MFBI}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=650
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=18650
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=2000
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=20000
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=5100
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=23100
...    LNBTS:actMultBearers=true
...    LNBTS:actMultGbrBearers=true
...    LNBTS:actIfHo=enabled
@{MFBI}
...    LNBTS:actMFBI=true
...    LNBTS/MFBIPR-0:addFreqBandInd=66
...    LNBTS/MFBIPR-0:addSpectrEmissReq=2
...    LNBTS/MFBIPR-0:eutraCarrierFreq=2000
...    LNBTS/MFBIPR-0:freqBandIndPrio=broadcasted
@{Feature_flag}
...    LNCEL:actServBasedHoQciX=true
...    LNBTS:reportTimerSBHoQciXA5=5000ms
...    LNBTS:qciTab2:servBasedHoAllowed=forbidden
...    LNBTS:qciTab3:servBasedHoAllowed=forbidden
...    LNBTS:qciTab4:servBasedHoAllowed=allowed
...    LNBTS:qciTab5:servBasedHoAllowed=forbidden
...    LNBTS:qciTab6:servBasedHoAllowed=forbidden
...    LNBTS:qciTab7:servBasedHoAllowed=forbidden
...    LNBTS:qciTab8:servBasedHoAllowed=allowed
...    LNBTS:qciTab9:servBasedHoAllowed=forbidden
...    LNBTS:qciTab65:servBasedHoAllowed=forbidden
...    LNBTS:qciTab66:servBasedHoAllowed=forbidden
...    LNBTS:qciTab69:servBasedHoAllowed=forbidden
...    LNBTS:qciTab70:servBasedHoAllowed=forbidden
...    LNBTS:qciTabOperator:servBasedHoAllowed=forbidden
...    LNCEL-1/LNHOIF-1:thresholdRsrpSBHoQciXFilter=-98
...    LNCEL-1/LNHOIF-1:thresholdRsrqSBHoQciXFilter=-120
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=2000
...    LNCEL-1/LNHOIF-1:measurementBandwidth=mbw100
...    LNBTS:actSelMobPrf=true
...    LNBTS:moProfileSelect=spid
...    LNBTS/MOPR-1:freqLayListServBasedHoQciX=2000
...    LNCEL-1:moPrMappingList:moPrId=1|spid=1
...    LNCEL-2:moPrMappingList:moPrId=1|spid=1
...    LNCEL-3:moPrMappingList:moPrId=1|spid=1
...    LNBTS/MODPR-0:autoAdapt=false
${ue_eutra_capabilities}
...    SEPARATOR=
...    C99808204CBF050B85E170BC2E177F0FFEBA80100CD1003844800000002D088085C4040208000590000FE00050B85E170BC2E17282000001A08000004040

*** Test Cases ***
CB008909-SR-A-B2-B3_ET_02_01_QCIx-SBHO A5 Measurement Setup on mapped Frequency Band
    [Documentation]    This case verifies QCIx-SBHO A5 Measurement Setup on mapped Frequency Band
    ...    step1: Attach UE-1 to Cell-1 with QCI-8,Attach successfully and QCIx SBHO eA5 measurements configure with mapped eafcn
    ...    step1: UE-1 report QCIx SBHO eA5 trigger QCIx SBHO
    ...    step1: Attach UE-2 to Cell-1 with QCI-5, and ERAB setup request with QCI-4,
    ...    Attach and setup eRAB successfully and QCIx SBHO eA5 measurements configure with mapped eafcn
    ...    step1: UE-2 report QCIx SBHO eA5 trigger QCIx SBHO
    [Tags]
    UE Attach to eNB1 Cell1 with QCIx_SBHO eA5    ${ue_eutra_capabilities}    ue_id=1    cell_id=1    earfcn=66486
    report eA5 measurement report    ue_id=1    pci=2    earfcn=66486
    UE Attach to eNB1 Cell1 without QCIx_SBHO eA5    ${ue_eutra_capabilities}    ue_id=2    cell_id=1
    Add one GBR QCIx bearer with QCIx_SBHO eA5    ue_id=2    qci=4    earfcn=66486
    report eA5 measurement report    ue_id=2    pci=2    earfcn=66486

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD_band2band4band12    ue_count=100
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts

Modify Yaml
    # modify UE4 bearer
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 5, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 320, mbr_ul: 32, mbr_dl: 320, preemption: off, vulnerability: off, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...     - {qci: 5, default: on, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 320, mbr_ul: 32, mbr_dl: 320, preemption: off, vulnerability: off, pdn: 1}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_3


Online parameter change
    [Arguments]    ${PARAM}
    Delta Commission Parameters    ${PARAM}
    Cells Should Be OnAir

UE Attach to eNB1 Cell1 with QCIx_SBHO eA5
    [Arguments]    ${ue_eutra_capabilities}    ${ue_id}=1    ${cell_id}=1    ${earfcn}=66486
    Set UE parameters before attach    ue_id=${ue_id}
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration as a5_active
    ...    alias=attach_a5_flow    overall_timeout=2
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Flow Occurred As Expected    alias=attach_a5_flow
    verify that message fulfills query
    ...    (
    ...      rrcConnectionReconfiguration  contains (
    ...        reportConfigToAddModList contains (reportConfigEUTRA contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97)))) and
    ...        measIdToAddModList contains ((measId eq 3) and (measObjectId eq 2) and (reportConfigId eq 5)) and
    ...        measObjectToAddModList-v9e0 contains (measObjectEUTRA-v9e0 contains (carrierFreq-v9e0 eq ${earfcn}))
    ...         )
    ...    )
    ...    message_alias=a5_active
    ...    flow_alias=attach_a5_flow

UE Attach to eNB1 Cell1 without QCIx_SBHO eA5
    [Arguments]    ${ue_eutra_capabilities}    ${ue_id}=1    ${cell_id}=1
    Set UE parameters before attach    ue_id=${ue_id}
    ${no_a5_query}    catenate
    ...    reportConfigToAddModList contains (reportConfigEUTRA contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97))))
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${no_a5_query})
    ...    alias=attach_no_a5_flow    overall_timeout=2
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Flow Not Occurred For Message    alias=attach_no_a5_flow

Add one GBR QCIx bearer with QCIx_SBHO eA5
    [Arguments]    ${ue_id}=1    ${qci}=2    ${earfcn}=66486
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration as a5_active1
    ...    alias=GBR_a5_flow    overall_timeout=2
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci} mbr_ul=32 mbr_dl=320 gbr_ul=32 gbr_dl=320
    Flow Occurred As Expected    alias=GBR_a5_flow
    verify that message has fields
    ...    measObjectToAddModList..measObjectId eq 2
    ...    reportConfigToAddModList..reportConfigEUTRA..triggerType..event..eventId..eventA5..a5-Threshold1..threshold-RSRP eq 97
    ...    measIdToAddModList..measId eq 3
    ...    measIdToAddModList..measObjectId eq 2
    ...    measIdToAddModList..reportConfigId eq 5
    ...    measObjectToAddModList-v9e0..measObjectEUTRA-v9e0..carrierFreq-v9e0 eq ${earfcn}
    ...    message_alias=a5_active1
    ...    flow_alias=GBR_a5_flow

report eA5 measurement report
    [Arguments]    ${ue_id}=1    ${pci}=2    ${earfcn}=66486
    Expect Message Flow
    ...    UE_${ue_id}:RRC_MeasurementReport (measId eq 3)
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq ${pci}))
    ...    alias=intra_enb_ho_flow    overall_timeout=30
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A5 srsrp=60 srsrq=15 phycell_id=${pci} nrsrp=43 nrsrq=16 earfcn=${earfcn}
    Flow Occurred As Expected    alias=intra_enb_ho_flow


Set UE parameters before attach
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_mme_param id=${ue_id} spid=1
    Execute Egate Command    enb_timer T_DC_Overall=5000ms
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
