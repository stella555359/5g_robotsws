*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               release-SBTS23R3    team-CN3ET    owner-pei.han
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${UTE_WIRESHARK_FLAG}    ${True}
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CELL_CONFIG}
...    @{PARAMS_FOR_CB008909}
...    @{PARAMS_FOR_Related}
...    @{Neighbor_eNB_Releated}
@{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1800
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19800
@{PARAMS_FOR_CB008909}
...    LNBTS:actIfHo=enabled
...    LNBTS/MODPR-0:freqLayListLte=38000
...    LNBTS/MODPR-0:autoAdapt=false
...    LNCEL:actServBasedHoQciX=true
...    LNBTS:reportTimerSBHoQciXA5=5000ms
...    LNBTS:qciTab2:servBasedHoAllowed=forbidden
...    LNBTS:qciTab3:servBasedHoAllowed=forbidden
...    LNBTS:qciTab4:servBasedHoAllowed=allowed
...    LNBTS:qciTab5:servBasedHoAllowed=forbidden
...    LNBTS:qciTab6:servBasedHoAllowed=forbidden
...    LNBTS:qciTab65:servBasedHoAllowed=forbidden
...    LNBTS:qciTab66:servBasedHoAllowed=forbidden
...    LNBTS:qciTab69:servBasedHoAllowed=forbidden
...    LNBTS:qciTab7:servBasedHoAllowed=forbidden
...    LNBTS:qciTab70:servBasedHoAllowed=forbidden
...    LNBTS:qciTab8:servBasedHoAllowed=allowed
...    LNBTS:qciTab9:servBasedHoAllowed=forbidden
...    LNBTS:qciTabOperator:servBasedHoAllowed=forbidden
...    LNBTS/MOPR-1:freqLayListServBasedHoQciX=1600
...    LNBTS/MODPR-0:freqLayListServBasedHoQciX=1800,38000
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1600
...    LNCEL-1/LNHOIF-1:measurementBandwidth=mbw100
...    LNCEL-1/LNHOIF-1:thresholdRsrpSBHoQciXFilter=-98
...    LNCEL-1/LNHOIF-1:thresholdRsrqSBHoQciXFilter=-120
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=1800
...    LNCEL-1/LNHOIF-2:measurementBandwidth=mbw100
...    LNCEL-1/LNHOIF-2:thresholdRsrpSBHoQciXFilter=-98
...    LNCEL-1/LNHOIF-2:thresholdRsrqSBHoQciXFilter=-120
...    LNCEL-1/LNHOIF-3:eutraCarrierInfo=38000
...    LNCEL-1/LNHOIF-3:measurementBandwidth=mbw100
...    LNCEL-1/LNHOIF-3:thresholdRsrpSBHoQciXFilter=-98
...    LNCEL-1/LNHOIF-3:thresholdRsrqSBHoQciXFilter=-120
@{PARAMS_FOR_Related}
...    LNBTS:actMultBearers=true
...    LNBTS:actMultGbrBearers=true
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNBTS:actRedirect=disabled
...    LNBTS:actSelMobPrf=true
...    LNBTS:rrcGuardTimer=100
...    LNBTS:tX2RelocPrep=10000
@{Neighbor_eNB_Releated}
...    LNBTS/LNADJ-255:adjEnbId=2
...    LNBTS/LNADJ-255:cPlaneIpAddr=10.0.1.4
...    LNBTS/LNADJ-255:cPlaneIpAddrCtrl=oamControlled
...    LNBTS/LNADJ-255:plmnId:mnc=3
...    LNBTS/LNADJ-255:plmnId:mcc=262
...    LNBTS/LNADJ-255:plmnId:mncLength=2
...    LNBTS/LNADJ-254:adjEnbId=3
...    LNBTS/LNADJ-254:cPlaneIpAddr=10.0.1.3
...    LNBTS/LNADJ-254:cPlaneIpAddrCtrl=oamControlled
...    LNBTS/LNADJ-254:plmnId:mnc=3
...    LNBTS/LNADJ-254:plmnId:mcc=262
...    LNBTS/LNADJ-254:plmnId:mncLength=2
${ue_eutra_capabilities}
...    SEPARATOR=
...    DD980030842550021F8D1DFFFFFFFA384008804C000000141B88CFF46EC4D2F0C808BDF837626AC0400968755461406061000208190000820
...    728002081D000082FC5800019807060000100084D0007CE3C0004080C10181C2C4C6C707507EFF896B4C03217F9BD4000C01B40
${reportTimerSBHoQciXA5}     5s

*** Test Cases ***
CB008909-SR-A-B7_ET_28_01_Deactivate QCIx SBHO measurements after supervision timer Expires
    [Documentation]    This case verifies QCIx SBHO measurements deactivate after supervision timer Expires
    [Tags]
    UE Attach without QCIx SBHO eA5    ${ue_eutra_capabilities}    ue_id=3    cell_id=1
    Add one GBR QCIx bearer with QCIx_SBHO eA5    ue_id=3    qci=4
    Wait for reportTimerSBHoQciXA5 Expired    ue_id=3
    Relese bearer    ue_id=3    qci=4
    Add Another non-GBR QCIx bearer with QCIx_SBHO eA5    ue_id=3    qci=8

CB008909-SR-A-B7_ET_35_01_Handling Coverage Based HO Trigger when Preparing QCIx SBHO
    [Documentation]    This case verifies eNB buffer coverage-based mobility when A2 event reported
    ...    after QCIx SBHO handover preparation was started.
    [Tags]
    Set parameters before attach
    UE Attach with QCIx SBHO eA5    ${ue_eutra_capabilities}    ue_id=1    cell_id=1
    Buffer Coverage Based HO Trigger when Preparing QCIx SBHO

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,s1 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create UE Alias    UE_4    ue_id=4    id_type=cus
    Create UE Alias    UE_5    ue_id=5    id_type=cus
    Create UE Alias    UE_6    ue_id=6    id_type=cus
    Create UE Alias    UE_7    ue_id=7    id_type=cus
    Create UE Alias    UE_8    ue_id=8    id_type=cus
    Create UE Alias    UE_9    ue_id=9    id_type=cus
    Create UE Alias    UE_10    ue_id=10    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts

Perform Steps After Onair
    @{lnadj_1}    Create List    LNADJ:cPlaneIpAddr=10.0.1.3    LNADJ:x2LinkStatus=available
    Object Should Exist    ${lnadj_1}
    @{lnadj_2}    Create List    LNADJ:cPlaneIpAddr=10.0.1.4    LNADJ:x2LinkStatus=available
    Object Should Exist    ${lnadj_2}

Modify Yaml
    # modify UE bearer
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 320, mbr_ul: 32, mbr_dl: 320, preemption: off, vulnerability: off, pdn: 1}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 5, pdn: 1}
    ...     - {qci: 6, pdn: 1}
    ...     - {qci: 7, pdn: 1}
    ...     - {qci: 9, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...     - {qci: 5, default: on, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 320, mbr_ul: 32, mbr_dl: 320, preemption: off, vulnerability: off, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 6, pdn: 1}
    ...     - {qci: 7, pdn: 1}
    ...     - {qci: 9, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_4:
    ...     - {qci: 5, default: on, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 320, mbr_ul: 32, mbr_dl: 320, preemption: off, vulnerability: off, pdn: 1}
    ...     - {qci: 8, preprovisioned: on, filter: 3, precedence: 3, pdn: 1}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, preprovisioned: on, filter: 2, precedence: 2}
    ...     - {qci: 6, pdn: 1}
    ...     - {qci: 7, pdn: 1}
    ...     - {qci: 9, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_5:
    ...     - {qci: 5, default: on, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 320, mbr_ul: 32, mbr_dl: 320, preemption: off, vulnerability: off, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, preprovisioned: on, filter: 2, precedence: 2}
    ...     - {qci: 6, pdn: 1}
    ...     - {qci: 7, pdn: 1}
    ...     - {qci: 9, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_6:
    ...     - {qci: 9, default: on, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 320, mbr_ul: 32, mbr_dl: 320, preemption: off, vulnerability: off, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 5, pdn: 1}
    ...     - {qci: 6, pdn: 1}

    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/3    bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/4    bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/5    bearer: bearer_set_4
    Update Yaml    UEs/UE_sets/6    bearer: bearer_set_4
    Update Yaml    UEs/UE_sets/7    bearer: bearer_set_5
    Update Yaml    UEs/UE_sets/8    bearer: bearer_set_5
    Update Yaml    UEs/UE_sets/9    bearer: bearer_set_6
    Update Yaml    UEs/UE_sets/10    bearer: bearer_set_6
    # add sim enb2
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.3
    ...      cells:
    ...        - {id: 21, technology: lte, tac: 33, pci: '7:0', earfcn: '1400:19400', bw: 20}
    ...        - {id: 22, technology: lte, tac: 33, pci: '7:1', earfcn: '1600:19600', bw: 20}
    ...        - {id: 23, technology: lte, tac: 33, pci: '7:2', earfcn: '1800:19800', bw: 20}
    Add Yaml    BASE_STATIONS
    ...    - id: 3
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.4
    ...      cells:
    ...        - {'id': 31, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '10:1', eci: '0x000031F', earfcn: '38000:38000', bw: 20}
    ...        - {'id': 32, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '10:2', eci: '0x0000320', earfcn: '40540:40540', bw: 20}
    ...        - {'id': 33, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '11:0', eci: '0x0000321', earfcn: '40740:40740', bw: 20}

UE Attach with QCIx SBHO eA5
    [Arguments]    ${ue_eutra_capabilities}    ${ue_id}=1    ${cell_id}=1
    ${measObjectToAddModList}    catenate
    ...    measObjectToAddModList contains (measObjectId eq 2 and carrierFreq eq 1800, measObjectId eq 3 and carrierFreq eq 38000)
    ${reportConfigToAddModList}    catenate
    ...    reportConfigToAddModList contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97) and
    ...    a5-Threshold2 contains (threshold-RSRP eq 0)))
    ${measIdToAddModList}    catenate
    ...    measIdToAddModList contains (measId eq 3 and measObjectId eq 2 and reportConfigId eq 4, measId eq 4 and
    ...    measObjectId eq 3 and reportConfigId eq 4)
    ${Expect_Message_Flow}    catenate
    ...    (${measObjectToAddModList}) and (${reportConfigToAddModList}) and (${measIdToAddModList}) and
    ...    (s-Measure eq 0) and (measGapConfig contains (gapOffset is present))
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${Expect_Message_Flow})
    ...    alias=a5_activate_flow  overall_timeout=2
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Flow Occurred As Expected    alias=a5_activate_flow

UE Attach without QCIx SBHO eA5
    [Arguments]    ${ue_eutra_capabilities}    ${ue_id}=1    ${cell_id}=1
    ${no_a5_query}    catenate
    ...    reportConfigToAddModList contains (reportConfigEUTRA contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97))))
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${no_a5_query})
    ...    alias=attach_no_a5_flow  overall_timeout=2
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Flow Not Occurred For Message    alias=attach_no_a5_flow

Add one GBR QCIx bearer with QCIx_SBHO eA5
    [Arguments]    ${ue_id}=1    ${qci}=4
    ${measObjectToAddModList}    catenate
    ...    measObjectToAddModList contains (measObjectId eq 2 and carrierFreq eq 1800, measObjectId eq 3 and carrierFreq eq 38000)
    ${reportConfigToAddModList}    catenate
    ...    reportConfigToAddModList contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97) and
    ...    a5-Threshold2 contains (threshold-RSRP eq 0)))
    ${measIdToAddModList}    catenate
    ...    measIdToAddModList contains (measId eq 3 and measObjectId eq 2 and reportConfigId eq 4, measId eq 4 and
    ...    measObjectId eq 3 and reportConfigId eq 4)
    ${Expect_Message_Flow}    catenate
    ...    (${measObjectToAddModList}) and (${reportConfigToAddModList}) and (${measIdToAddModList}) and
    ...    (s-Measure eq 0) and (measGapConfig contains (gapOffset is present))
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${Expect_Message_Flow})
    ...    alias=a5_activate_flow  overall_timeout=3
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci} mbr_ul=32 mbr_dl=320 gbr_ul=32 gbr_dl=320
    Flow Occurred As Expected    alias=a5_activate_flow

Add Another non-GBR QCIx bearer with QCIx_SBHO eA5
    [Arguments]    ${ue_id}=1    ${qci}=8
    ${measIdToAddModList}    catenate
    ...    measIdToAddModList contains (measId eq 3 and measObjectId eq 2 and reportConfigId eq 4, measId eq 4 and
    ...    measObjectId eq 3 and reportConfigId eq 4)
    ${Expect_Message_Flow}    catenate
    ...    (${measIdToAddModList}) and (s-Measure eq 0) and (measGapConfig contains (gapOffset is present))
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${Expect_Message_Flow})
    ...    alias=a5_activate_flow  overall_timeout=3
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=a5_activate_flow

Wait for reportTimerSBHoQciXA5 Expired
    [Arguments]    ${ue_id}=1
    ${Expect_Message_Flow}    catenate
    ...    measConfig contains (measIdToRemoveList contains (3, 4) and measGapConfig contains (release is present) and s-Measure eq 75)
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${Expect_Message_Flow})
    ...    alias=a5_deactivate_flow  overall_timeout=5
    Sleep    ${reportTimerSBHoQciXA5}
    Flow Occurred As Expected    alias=a5_deactivate_flow

Relese bearer
    [Arguments]    ${ue_id}=1    ${qci}=4
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (drb-ToReleaseList is present)
    ...    alias=bearer_release_flow  overall_timeout=5
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=bearer_release_flow

Buffer Coverage Based HO Trigger when Preparing QCIx SBHO
    [Arguments]    ${ue_id}=1    ${pci}=31    ${earfcn}=38000
    ${RRCConnectionReconfiguration_Expect}    catenate
    ...    reportConfigToAddModList contains ("eventA1","eventA3","eventA5") and measIdToRemoveList contains (3, 4) and s-Measure eq 75
    Expect Message Flow
    ...    ENB_1:X2AP_HandoverRequest (Cause contains (radioNetwork eq "resource-optimisation-handover"))
    ...    ENB_1:X2AP_HandoverPreparationFailure
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${RRCConnectionReconfiguration_Expect})
    ...    alias=buffer_Coverage_HO  overall_timeout=10
    Execute Uex Command
    ...    ue_measurement_send id=${ue_id} event=A5 srsrp=60 srsrq=15 phycell_id=${pci} nrsrp=65 nrsrq=16 earfcn=${earfcn}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=30 srsrq=15
    Flow Occurred As Expected    alias=buffer_Coverage_HO

Set parameters before attach
    [Arguments]    ${ue_id}=1
    Execute Egate Command    mme_timer T_S1APInitialContextSetup=15000
    Execute Egate Command    enb_param id=3 x2_ho_prep_failure_delay=3000 x2_force_reject_ho_req_with_cause=MISC_CauseMisc_unspecified

