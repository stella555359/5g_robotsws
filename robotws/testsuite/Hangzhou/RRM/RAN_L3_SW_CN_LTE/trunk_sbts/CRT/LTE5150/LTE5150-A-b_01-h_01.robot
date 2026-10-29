*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CRT    team-SG4
...               CLOUD_R4LAPO_CUS    release-xL19B    owner-kang.xiang
Resource          ../../../resources/DevHZ5_resource.robot
*** Variables ***
@{PARAMS_IN_VENDOR}
...    LNBTS:reportTimerEndcA5=5000ms
@{PARAMS_IN_SCF}
...    LNBTS-1:actLteNrDualConnectivity=false
...    LNBTS-1:actDynTrigLteNrDualConnectivity=false
...    LNBTS-1:actIfHo=enabled
...    LNBTS-1:actSelMobPrf=false
...    LNBTS-1/MODPR-0:autoAdapt=false
...    LNBTS-1:actMultBearers=true
...    LNBTS-1/LNBTS_FDD-0:actConvVoice=true
...    LNCEL/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL/LNCEL_FDD-0:maxNumActDrb=265
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1700
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19700
...    LNCEL-1:threshold1=75
...    LNCEL-2:threshold1=76
...    LNCEL-3:threshold1=77
...    @{LTE5150_param}
...    @{PARAMS_FOR_CELL_CONFIG}
@{LTE5150_param}
...    LNBTS-1:actEndcHo=enabled
...    LNBTS-1/MODPR:freqLayEndcHoList:freqLayer=1700
...    LNBTS-1/MODPR-0:freqLayEndcHoList:freqLayer=1700
...    LNCEL-1/LNHOIF-1:thresholdRsrpEndcFilt=-100
...    LNCEL-1/LNHOIF-1:thresholdRsrqEndcFilt=-150
...    LNCEL-1:moPrMappingList:moPrId=1|spid=1
...    LNCEL-2:moPrMappingList:moPrId=1|spid=1
@{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1700
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19700
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1800
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19800
@{delta_for_case_A_b_01}
...    LNBTS-1:actSelMobPrf=true
...    LNBTS-1:actEndcHo=disabled
...    LNBTS-1/MODPR-0:freqLayEndcHoList:freqLayer=1700
...    LNCEL-1/LNHOIF-1:thresholdRsrpEndcFilt=-100
...    LNCEL-1/LNHOIF-1:thresholdRsrqEndcFilt=-150
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1700
...    delete:LNCEL-1/LNHOIF-2
...    delete:LNCEL-2/LNHOIF-1
...    delete:LNCEL-2/LNHOIF-2
...    delete:LNCEL-3/LNHOIF-1
...    delete:LNCEL-3/LNHOIF-2
@{delta_enable_LTE5150}
...    LNBTS-1:actEndcHo=enabled
@{delta_disable_LTE5150}
...    LNBTS-1:actEndcHo=disabled
@{Recovery_A_b}
...    LNBTS-1:actSelMobPrf=false
...    LNCEL/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNBTS-1:actEndcHo=enabled
@{delta_for_case_A_h_01}
...    @{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1700
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=1700
...    LNCEL/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNBTS-1/MODPR-0:freqLayEndcHoList:freqLayer=1700
...    LNBTS-1/MOPR-1:freqLayEndcHoList:freqLayer=1700
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=1400
...    LNCEL-2/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-2/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNCEL-2/LNHOIF-1:measurementBandwidth=mbw6
...    LNBTS-1/MODPR-0:freqLayListLte=1500
...    LNCEL-1/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=1500
...    LNCEL-1/LNHOIF-2:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-2:thresholdRsrqEndcFilt=-120
...    LNCEL-1/LNHOW-1:utraCarrierFreq=1600
...    LNCEL-1/LNRELW-1:utranLbAllowed=true
...    LNBTS-1:actSelMobPrf=true
...    LNCEL-1:moPrMappingList:moPrId=1|spid=1
@{delta_for_cell2}
...    LNBTS-1/MODPR-0:freqLayEndcHoList:freqLayer=1400
...    LNBTS-1/MOPR-1:freqLayEndcHoList:freqLayer=1400
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=1400
...    LNCEL-2/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-2/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNCEL-2/LNHOIF-1:measurementBandwidth=mbw6
@{delta_for_cell3}
...    LNCEL-3/LNHOIF-1:eutraCarrierInfo=1400
...    LNCEL-3/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-3/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNCEL-3/LNHOIF-1:measurementBandwidth=mbw6
...    LNCEL-3/LNREL-388:handoverAllowed=onlyS1
...    LNCEL-3/LNREL-388:removeAllowed=false
...    LNCEL-3/LNREL-388:ecgiAdjEnbId=2
...    LNCEL-3/LNREL-388:ecgiLcrId=21
...    LNCEL-3/LNREL-388:ecgiPlmnId:mcc=262
...    LNCEL-3/LNREL-388:ecgiPlmnId:mnc=3
...    LNCEL-3/LNREL-388:ecgiPlmnId:mncLength=2
${ue_eutra_capabilities_wo_gap}
...    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFB
...    FFEC800801C364000000017BA000000080952A0E2740400000820001080002180004400008A000118000238000480000920001280002580004
...    C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003A7400000003A
...    00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A0000000141000000F3A0000000000000000000000000000000000000000000000000000000000020238
...    8425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C2800033C000001800000080
${ue_eutra_capabilities_w_gap}
...    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E900000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFB
...    FFEC800801C364000000017BA000000080952A0E2740400000820001080002180004400008A000118000238000480000920001280002580004
...    C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003A7400000003A
...    00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A0000000141000000F3A0000000000000000000000000000000000000000000000000000000000020238
...    8425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C2800033C000001800000080
${ue_nr_capabilities}    0000000001010000000060100581007018000000
${ue_eutra_nr_capabilities}    0108040160401C06000000000400020101002004
@{PM_COUNTERS}
...    LNCEL-1:${IEF_ENDC_CAP_HO_PREP}=1
...    LNCEL-1:${IEF_ENDC_CAP_HO_EXE_ATT}=1
...    LNCEL-1:${IEF_ENDC_CAP_HO_EXE_SUCC}=1
...    LNCEL-2:${IEF_ENDC_CAP_HO_PREP}=1
...    LNCEL-2:${IEF_ENDC_CAP_HO_EXE_ATT}=1
...    LNCEL-2:${IEF_ENDC_CAP_HO_EXE_SUCC}=1
...    LNCEL-3:${IEF_ENDC_CAP_HO_PREP}=1
...    LNCEL-3:${IEF_ENDC_CAP_HO_EXE_ATT}=1
...    LNCEL-3:${IEF_ENDC_CAP_HO_EXE_SUCC}=1
${IEF_ENDC_CAP_HO_PREP}    M8080C53
${IEF_ENDC_CAP_HO_EXE_ATT}    M8080C54
${IEF_ENDC_CAP_HO_EXE_SUCC}    M8080C55
${wait_x2_setup}    60s

*** Test Cases ***
LTE5150-A-b_01_01_EN-DC capable based HO activation and deactivation
    [Tags]
    [Setup]    Delta Commission And Test Setup    ${delta_for_case_A_b_01}
    ENDC capable UE Attach to eNB1 Cell1 without A5    ue_id=1    cell_id=1
    Online commission    ${delta_enable_LTE5150}
    ENDC capable UE Attach to eNB1 Cell1 with A5    ue_id=2    cell_id=1
    ENDC capable UE Attach to eNB1 Cell1 with A5    ue_id=3    cell_id=1
    Online commission    ${delta_disable_LTE5150}
    ENDC capable UE Attach to eNB1 Cell1 without A5    ue_id=4    cell_id=1
    [Teardown]    Recover Env And Test Teardown    ${Recovery_A_b}

LTE5150-A-h_01_01_ET_Counters update during EN-DC capability based HO successfully
    [Tags]
    [Setup]    Delta Commission And Test Setup    ${delta_for_case_A_h_01}
    clear counter files
    UE Attach to eNB1 with config    uecapability_for_LTE5150=${ue_eutra_capabilities_wo_gap}    ue_id=5    cell_id=1
    Report A5 Trigger UE intra-eNB handover    ue_id=5    PCI=2    tgt_pci=2
    OnlineParamChange    ${delta_for_cell2}
    UE Attach to eNB1 with config    uecapability_for_LTE5150=${ue_eutra_capabilities_wo_gap}    ue_id=6    cell_id=2
    Report A5 Trigger UE inter-eNB handover    ue_id=6    PCI=9    tgt_pci=9
    OnlineParamChange    ${delta_for_cell3}
    UE Attach to eNB1 with config    uecapability_for_LTE5150=${ue_eutra_capabilities_wo_gap}    ue_id=7    cell_id=3
    Report A5 Trigger UE S1 handover    ue_id=7    PCI=9    tgt_pci=9
    check counters    ${PM_COUNTERS}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=20    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus
    Create CELL alias    alias=CELL_2    cell_id=2    cell_type=cus

Perform Steps After Onair
    sleep    ${wait_x2_setup}
    @{LNADJGNB}    Create List    LNADJ:cPlaneIpAddr=10.0.1.31    LNADJ:x2LinkStatus=available
    Object Should Exist    ${LNADJGNB}

Modify Yaml
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1: 10.0.1.31
    ...    cells:
    ...        - {'id': 21, technology: lte, duplex_mode: FDD, tac: 33, pci: '3:0', eci: '0x0000215', earfcn: '1400:19400', bw: 20}
    ...        - {'id': 22, technology: lte, duplex_mode: FDD, tac: 33, pci: '3:1', eci: '0x0000216', earfcn: '1700:19700', bw: 20}
    ...        - {'id': 23, technology: lte, duplex_mode: FDD, tac: 33, pci: '3:2', eci: '0x0000217', earfcn: '1400:19400', bw: 20}

Recover Env And Test Teardown
    [Arguments]    ${case_recovery_param}=${EMPTY}
    Delta Commission Parameters    ${case_recovery_param}
    Common Test Teardown And Stop Capture Logs

Delta Commission And Test Setup
    [Arguments]    ${setup_case_param}
    Set UE parameters for ENDC capability
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    ${setup_case_param}
    Cells Should Be OnAir

Set UE parameters for ENDC capability
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Execute Egate Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Egate Command    ue_param id=${ue_id} nr_supported_bands=7
    Execute Egate Command    ue_enb_param id=${ue_id} spid=1

ENDC capable UE Attach to eNB1 Cell1 without A5
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Set UE parameters for ENDC capability    ue_id=${ue_id}
    ${no_a5_query}    catenate
    ...    reportConfigToAddModList contains (reportConfigEUTRA contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97))))
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${no_a5_query})
    ...    alias=attach_no_a5_flow    overall_timeout=2
    ${cmd}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities_wo_gap}
    ...    ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} cell=${cell_id}
    Execute Uex Command    ${cmd}
    Flow Not Occurred For Message    alias=attach_no_a5_flow

Online commission
    [Arguments]    ${Online_param}
    Delta Commission Parameters    ${Online_param}
    cells should be onair

ENDC capable UE Attach to eNB1 Cell1 with A5
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${earfcn}=1700
    Set UE parameters for ENDC capability    ue_id=${ue_id}
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration as a5_active
    ...    alias=attach_a5_flow    overall_timeout=20
    ${cmd}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities_wo_gap}
    ...    ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} cell=${cell_id}
    Execute Uex Command    ${cmd}
    Flow Occurred As Expected    alias=attach_a5_flow
    verify that message fulfills query
    ...  (
    ...    rrcConnectionReconfiguration  contains (
    ...        measObjectToAddModList  contains (measObjectEUTRA contains (carrierFreq eq ${earfcn})) and
    ...        reportConfigToAddModList contains (reportConfigEUTRA contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97)))) and
    ...        measIdToAddModList contains ((measId eq 3) and (measObjectId eq 2) and (reportConfigId eq 5))
    ...        )
    ...  )
    ...    message_alias=a5_active
    ...    flow_alias=attach_a5_flow


UE Attach to eNB1 with config
    [Arguments]    ${uecapability_for_LTE5150}    ${ue_id}=10    ${cell_id}=1
    ${V_1}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${uecapability_for_LTE5150} ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=${cell_id}
    Execute Uex Command    ${V_1}

Report A5 Trigger UE intra-eNB handover
    [Arguments]    ${ue_id}=2    ${PCI}=9    ${tgt_pci}=2
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq ${tgt_pci}))
    ...    alias=intra_eNB_HO_flow    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A5 srsrp=60 srsrq=15 phycell_id=${PCI} nrsrp=90 nrsrq=34
    Flow Occurred As Expected    alias=intra_eNB_HO_flow

Report A5 Trigger UE inter-eNB handover
    [Arguments]    ${ue_id}=2    ${PCI}=9    ${tgt_pci}=2
    Expect Message Flow
    ...    ENB_1:X2AP_HandoverRequest
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq ${tgt_pci}))
    ...    alias=inter_eNB_HO_flow    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A5 srsrp=60 srsrq=15 phycell_id=${PCI} nrsrp=90 nrsrq=34
    Flow Occurred As Expected    alias=inter_eNB_HO_flow

Report A5 Trigger UE S1 handover
    [Arguments]    ${ue_id}=2    ${PCI}=9    ${tgt_pci}=2
    Expect Message Flow
    ...    MME_1:S1AP_HandoverRequired (Cause contains (radioNetwork eq "resource-optimisation-handover"))
    ...    MME_1:S1AP_HandoverCommand
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq ${tgt_pci}))
    ...    alias=inter_eNB_S1_HO_flow    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A5 srsrp=60 srsrq=15 phycell_id=${PCI} nrsrp=90 nrsrq=34
    Flow Occurred As Expected    alias=inter_eNB_S1_HO_flow


OnlineParamChange
    [Arguments]    ${delta_para}=${EMPTY}
    Delta Commission Parameters    ${delta_para}
    Cells Should Be OnAir

