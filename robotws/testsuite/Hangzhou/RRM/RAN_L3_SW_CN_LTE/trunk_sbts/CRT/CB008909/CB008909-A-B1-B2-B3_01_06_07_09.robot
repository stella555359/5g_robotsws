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
...    @{LTE_IF_Neighbor_Param}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19600
...    LNBTS:actMultBearers=true
...    LNBTS:actMultGbrBearers=true
...    LNBTS:actIfHo=enabled
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
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1600
...    LNCEL-1/LNHOIF-1:measurementBandwidth=mbw100
...    LNBTS:actSelMobPrf=true
...    LNBTS:moProfileSelect=spid
...    LNBTS/MOPR-1:freqLayListServBasedHoQciX=1600
...    LNCEL-1:moPrMappingList:moPrId=1|spid=1
...    LNCEL-2:moPrMappingList:moPrId=1|spid=1
...    LNCEL-3:moPrMappingList:moPrId=1|spid=1
...    LNBTS/MODPR-0:autoAdapt=false
@{LTE_IF_Neighbor_Param}
...    LNBTS/LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNBTS/LNADJ-1:adjEnbId=3
...    LNBTS/LNADJ-1:cPlaneIpAddr=10.0.1.4
...    LNBTS/LNADJ-1/LNADJL-1:fDlEarfcn=38000
...    LNBTS/LNADJ-1/LNADJL-1:phyCellId=30
...    LNBTS/LNADJ-1/LNADJL-1:tac=33
...    LNCEL-1/LNREL-3:ecgiAdjEnbId=3
...    LNCEL-1/LNREL-3:ecgiLcrId=1
...    LNCEL-1/LNREL-3:handoverAllowed=allowed
...    LNCEL-1/LNREL-3:removeAllowed=false
...    LNCEL-1/LNREL-3:cellIndOffNeigh=0dB
@{Feature_flag_disable}
...    LNCEL:actServBasedHoQciX=false
@{Feature_flag_enable}
...    LNCEL:actServBasedHoQciX=true
@{No_MOPR_freqLayListServBasedHoQciX_Configured}
...    delete:MOPR.*
...    delete:LNCEL-1:moPrMappingList
...    delete:LNCEL-2:moPrMappingList
...    delete:LNCEL-3:moPrMappingList
...    LNBTS/MODPR-0:freqLayListServBasedHoQciX=1600
...    LNBTS/MODPR-0:autoAdapt=true
@{MODPR_autoadapt_FALSE}
...    LNBTS/MODPR-0:autoAdapt=false
@{delete_MODPR_freqLayListServBasedHoQciX}
...    delete:LNBTS/MODPR-0:freqLayListServBasedHoQciX
@{add_MODPR_freqLayListServBasedHoQciX}
...    LNBTS/MODPR-0:freqLayListServBasedHoQciX=1600
@{Parameter_recovery_06_02}
...    delete:MODPR:freqLayListServBasedHoQciX
...    LNBTS/MOPR-1:freqLayListServBasedHoQciX=1600
...    LNCEL-1:moPrMappingList:moPrId=1|spid=1
...    LNCEL-2:moPrMappingList:moPrId=1|spid=1
...    LNCEL-3:moPrMappingList:moPrId=1|spid=1
...    LNBTS/MODPR-0:autoAdapt=false
@{Prefer_Carrier_TDD_BAND38}
...    LNBTS/MOPR-1:freqLayListServBasedHoQciX=38000
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=38000
@{Parameter_recovery_07_02}
...    LNBTS/MOPR-1:freqLayListServBasedHoQciX=1600
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1600
@{Parameter_09_02}
...    LNBTS:actERabModify=true
...    LNBTS:actERabModifyNonGbrToSig=true
...    LNBTS:qciTab5:pdcpProfIdx=2
...    LNBTS:qciTab8:pdcpProfIdx=2
...    LNBTS:qciTab9:pdcpProfIdx=2
...    LNBTS:qciTab5:rlcProfIdx=1
...    LNBTS:qciTab8:rlcProfIdx=1
...    LNBTS:qciTab9:rlcProfIdx=1
...    LNBTS:qciTab5:lcgid=3
...    LNBTS:qciTab8:lcgid=3
...    LNBTS:qciTab9:lcgid=3
@{Parameter_recovery_09_02}
...    LNBTS:actERabModifyNonGbrToSig=false
...    LNBTS:qciTab5:pdcpProfIdx=1
...    LNBTS:qciTab8:pdcpProfIdx=2
...    LNBTS:qciTab9:pdcpProfIdx=2
...    LNBTS:qciTab5:rlcProfIdx=1
...    LNBTS:qciTab8:rlcProfIdx=1
...    LNBTS:qciTab9:rlcProfIdx=2
...    LNBTS:qciTab5:lcgid=2
...    LNBTS:qciTab8:lcgid=3
...    LNBTS:qciTab9:lcgid=3
${ue_eutra_capabilities}
...    SEPARATOR=
...    D5BFF004094182248102008020FC1BB1341014A82181F8800183840000340001E500001080007400004074008060C100401001F5F20000164080304A601801955410001000
${ue_eutra_capabilities_unsupport_band38}
...    SEPARATOR=
...    D5BFF004094182248102008020FC1BB13C1014A82181F8800183840000340001E500001080007400004074008060C100401001F5F20000164080304A601801955410001000
${ue_eutra_capabilities_band38}
...    SEPARATOR=
...    D5BFF00509418224928204010041F83762782029504303F1000307080000680003CA0000210000E8000080E80100C18200802003EBE400002C81006094C030032AA8200020
#support to TDD
${ue_eutra_capabilities_unsupport_FGI}
...    SEPARATOR=
...    D5BFF00509418224928204010041F80762682029504303F1000307080000680003CA0000210000E8000080E80100C18200802003EBE400002C81006094C030032AA8200020
#FGI13/14 set to 0
${reportTimerSBHoQciXA5}     5s
*** Test Cases ***
CB008909-SR-A-B1-B2-B3_ET_01_01_QCIx SBHO Activation and Deactivation
    [Documentation]    This case verifies when ue capability support and CB008909 enabled,QCIx SBHO Activation and Deactivation
    ...    step1: Online configure Feature_flag_disable
    ...    step2: Attach UE-1 to Cell-1 with QCIx bearer QCI-8
    ...    step3-4: Attach UE-2 to Cell-1 with QCI-5, and ERAB setup request with QCIx bearer QCI-4
    ...    step5: Set LNCEL-1:actServBasedHoQciX=true
    ...    step6: Attach UE-3 to Cell-1 QCIx bearer with QCI-8
    ...    step7: UE-3 report QCIx SBHO eA5 for Cell-3 with RSRP>-98dbm
    ...    step8: Attach UE-4 to Cell-1 with QCI-5, and ERAB setup request with QCIx bearer QCI-4
    ...    step9: UE-4 report QCIx SBHO eA5 Cell-3 with RSRP<-98dbm and No QCIx SBHO
    [Tags]
    Online parameter change    ${Feature_flag_disable}
    UE Attach to eNB1 Cell1 without QCIx_SBHO eA5    ${ue_eutra_capabilities}    ue_id=1    cell_id=1
    UE Attach to eNB1 Cell1 without QCIx_SBHO eA5    ${ue_eutra_capabilities}    ue_id=2    cell_id=1
    Add one GBR QCIx bearer without QCIx_SBHO eA5    ue_id=2    qci=4
    Online parameter change    ${Feature_flag_enable}
    UE Attach to eNB1 Cell1 with QCIx_SBHO eA5    ${ue_eutra_capabilities}    ue_id=3    cell_id=1    earfcn=1600
    report eA5 measurement report    ue_id=3    pci=3    earfcn=1600
    UE Attach to eNB1 Cell1 without QCIx_SBHO eA5    ${ue_eutra_capabilities}    ue_id=4    cell_id=1
    Add one GBR QCIx bearer with QCIx_SBHO eA5    ue_id=4    qci=4    earfcn=1600
    report eA5 measurement report RSRP lower than threshold    ue_id=4    pci=3    earfcn=1600
    [Teardown]     Restore Env and Capture Logs    ${Feature_flag_enable}

CB008909-SR-A-B2-B3_ET_06_02_No QCIx-SBHO A5 Measurement Setup when No freqLayListServBasedHoQciX Configured
    [Documentation]    This case verifies No QCIx-SBHO A5 Measurement Setup when No freqLayListServBasedHoQciX Configured
    ...    step1: Online configure No_MOPR_freqLayListServBasedHoQciX_Configured
    ...    step2: Attach UE-5 to Cell-1 with QCIx bearer QCI-8,no eA5 due to No_MOPR_freqLayListServBasedHoQciX_Configured
    ...    step3: Online configure LNBTS/MODPR-1:autoAdapt=false,
    ...    step4: ERAB setup request with QCI-6,QCIx SBHO eA5 measurements configure due to QCIx already exist(qci8)
    ...    step5: Online Delete LNBTS/MODPR-1:freqLayListServBasedHoQciX=1600
    ...    step6-7: Attach UE-6 to Cell-1 with QCI-5, and ERAB setup request with QCIx bearer QCI-4
    ...    step8: Online configure LNBTS/MODPR-1:freqLayListServBasedHoQciX=1600,
    ...    step9: UE-6 ERAB setup request with QCIx bearer QCI-8
    [Tags]
    Online parameter change    ${No_MOPR_freqLayListServBasedHoQciX_Configured}
    UE Attach to eNB1 Cell1 without QCIx_SBHO eA5    ${ue_eutra_capabilities}    ue_id=5    cell_id=1
    Online parameter change    ${MODPR_autoadapt_FALSE}
    Add one NON_GBR QCIx bearer with QCIx_SBHO eA5    ue_id=5    qci=6    earfcn=1600
    report eA5 measurement report    ue_id=5    pci=3    earfcn=1600
    Online parameter change    ${delete_MODPR_freqLayListServBasedHoQciX}
    UE Attach to eNB1 Cell1 without QCIx_SBHO eA5    ${ue_eutra_capabilities}    ue_id=6    cell_id=1
    Add one GBR QCIx bearer without QCIx_SBHO eA5    ue_id=6    qci=4
    Online parameter change    ${add_MODPR_freqLayListServBasedHoQciX}
    Add one NON_GBR QCIx bearer with QCIx_SBHO eA5    ue_id=6    qci=8    earfcn=1600
    report eA5 measurement report    ue_id=6    pci=3    earfcn=1600
    [Teardown]     Restore Env and Capture Logs    ${Parameter_recovery_06_02}

CB008909-SR-A-B2-B3_ET_07_02_No QCIx-SBHO A5 Measurement Setup due to UE Capabilities
    [Documentation]    This case verifies No QCIx-SBHO A5 Measurement Setup when No freqLayListServBasedHoQciX Configured
    ...    step1: Attach UE-7 to Cell-1 with QCI-8,UE capability FGI bit 13/14 are set to 0
    ...    step2-3: Attach UE-8 to Cell-1 with QCI-5, and ERAB setup request with QCI-4,UE capability FGI bit 13/14 are set to 0
    ...    step4: Attach UE-9 to Cell-1 with QCI-8,UE capability does not support band38
    ...    step5-6: Attach UE-10 to Cell-1 with QCI-5, and ERAB setup request with QCI-4,UE capability does not support band38
    ...    step7: Attach UE-11 to Cell-1 with QCI-8,UE capability FGI bit 13/14 are set to 1 and support band38
    ...    step8-9: Attach UE-12 to Cell-1 with QCI-5, and ERAB setup request with QCIx bearer QCI-4 ,
    ...    UE capability FGI bit 13/14 are set to 1 and support band38
    [Tags]
    Online parameter change    ${Prefer_Carrier_TDD_BAND38}
    UE Attach to eNB1 Cell1 without QCIx_SBHO eA5    ${ue_eutra_capabilities_unsupport_band38}    ue_id=7    cell_id=1
    UE Attach to eNB1 Cell1 without QCIx_SBHO eA5    ${ue_eutra_capabilities_unsupport_band38}    ue_id=8    cell_id=1
    Add one GBR QCIx bearer without QCIx_SBHO eA5    ue_id=8    qci=4
    UE Attach to eNB1 Cell1 without QCIx_SBHO eA5    ${ue_eutra_capabilities_unsupport_FGI}    ue_id=9    cell_id=1
    UE Attach to eNB1 Cell1 without QCIx_SBHO eA5    ${ue_eutra_capabilities_unsupport_FGI}    ue_id=10    cell_id=1
    Add one GBR QCIx bearer without QCIx_SBHO eA5    ue_id=10    qci=4
    UE Attach to eNB1 Cell1 with QCIx_SBHO eA5    ${ue_eutra_capabilities_band38}    ue_id=11    cell_id=1    earfcn=38000
    report eA5 measurement report to trigger inter-eNB HO    ue_id=11    pci=30    earfcn=38000
    UE Attach to eNB1 Cell1 without QCIx_SBHO eA5    ${ue_eutra_capabilities_band38}    ue_id=12    cell_id=1
    Add one GBR QCIx bearer with QCIx_SBHO eA5    ue_id=12    qci=4    earfcn=38000
    report eA5 measurement report to trigger inter-eNB HO    ue_id=12    pci=30    earfcn=38000
    [Teardown]     Restore Env and Capture Logs    ${Parameter_recovery_07_02}

CB008909-SR-A-B3_ET_09_02_No QCIx-SBHO A5 Measurement change after QCIx Bearer Release or QCIx Bearer Modification
    [Documentation]    This case verifies No QCIx-SBHO A5 Measurement change after QCIx Bearer Release or QCIx Bearer Modification
    ...    step1: Attach UE-13 to Cell-1 with QCIx bearer QCI-8
    ...    step2: E-RAB modify from QCI-8 to QCI-5 before reportTimerSBHoQciXA5 expired,No QCIx SBHO eA5 deactivation
    ...    step3: After reportTimerSBHoQciXA5(5s) expired,ERAB setup request with QCIx bearer QCI-4,No QCIx SBHO eA5 configured
    ...    step4: Attach UE-14 to Cell-1 with QCI-5, and ERAB setup request with QCI-9 and QCIx bearer QCI-4
    ...    step4: UE-14 E-RAB release request with QCI-4,No QCIx SBHO eA5 measurements deactivation
    ...    step5: Attach UE-15 to Cell-1 with QCI-9,E-RAB modify from QCI-9 to QCIx bearer QCI-8,No QCIx SBHO eA5 measurements configure
    ...    step6: ERAB setup request with QCI-6,QCIx SBHO eA5 measurements configure.
    [Tags]
    Online parameter change    ${Parameter_09_02}
    UE Attach to eNB1 Cell1 with QCIx_SBHO eA5 and modify bearer
    ...    ue_id=13    cell_id=1    bearer_id=1    qci=5    earfcn=1600
    Add one GBR QCIx bearer without QCIx_SBHO eA5    ue_id=13    qci=4
    UE Attach to eNB1 Cell1 without QCIx_SBHO eA5    ${ue_eutra_capabilities}    ue_id=14    cell_id=1
    Add one NON_GBR QCIx bearer without QCIx_SBHO eA5    ue_id=14    qci=9
    Add one GBR QCIx bearer with QCIx_SBHO eA5    ue_id=14    qci=4    earfcn=1600
    Release one bearer no QCIx_SBHO eA5 deactivated    ue_id=14    qci=4     #no A5 deactive
    UE Attach to eNB1 Cell1 without QCIx_SBHO eA5 and modify bearer    ue_id=15    cell_id=1    bearer_id=1    qci=8
    Add one NON_GBR QCIx bearer with QCIx_SBHO eA5    ue_id=15    qci=6    earfcn=1600
    report eA5 measurement report    ue_id=15    pci=3    earfcn=1600
    [Teardown]     Restore Env and Capture Logs    ${Parameter_recovery_09_02}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=15    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts

Restore Env and Capture Logs
    [Arguments]    ${PARAM}
    Online parameter change    ${PARAM}
    Common Test Teardown And Stop Capture Logs

Perform Steps After Onair
    @{lnadj}    Create List    LNADJ:cPlaneIpAddr=10.0.1.4    LNADJ:x2LinkStatus=available
    Object Should Exist    ${lnadj}

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 5, default: on, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 320, mbr_ul: 32, mbr_dl: 320, preemption: off, vulnerability: off, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...     - {qci: 5, default: on, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 320, mbr_ul: 32, mbr_dl: 320, preemption: off, vulnerability: off, pdn: 1}
    ...     - {qci: 9, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_4:
    ...     - {qci: 9, default: on, pdn: 1}
    ...     - {qci: 6, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/4    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/6    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/8    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/10    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/12    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/14    bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/15    bearer: bearer_set_4
    # add sim enb2
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.3
    ...      x2: 10.0.1.3
    ...      cells:
    ...        - {id: 21, technology: lte, tac: 33, pci: '3:0', earfcn: '1400:19400', bw: 20}
    ...        - {id: 22, technology: lte, tac: 33, pci: '3:1', earfcn: '5920:23920', bw: 20}
    ...        - {id: 23, technology: lte, tac: 33, pci: '3:2', earfcn: '8770:26770', bw: 20}
    Add Yaml    BASE_STATIONS
    ...    - id: 3
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.4
    ...      x2: 10.0.1.4
    ...      cells:
    ...        - {'id': 31, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '10:0', eci: '0x000031F', earfcn: '38000:38000', bw: 20}
    ...        - {'id': 32, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '10:1', eci: '0x0000320', earfcn: '38000:38000', bw: 20}
    ...        - {'id': 33, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '10:2', eci: '0x0000321', earfcn: '38000:38000', bw: 20}

Online parameter change
    [Arguments]    ${PARAM}
    Delta Commission Parameters    ${PARAM}
    Cells Should Be OnAir

UE Attach to eNB1 Cell1 without QCIx_SBHO eA5
    [Arguments]    ${ue_eutra_capabilities}    ${ue_id}=1    ${cell_id}=1
    Set UE parameters before attach    ue_id=${ue_id}
    ${no_a5_query}    catenate
    ...    reportConfigToAddModList contains (reportConfigEUTRA contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97))))
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${no_a5_query})
    ...    alias=attach_no_a5_flow    overall_timeout=2
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Flow Not Occurred For Message    alias=attach_no_a5_flow


UE Attach to eNB1 Cell1 with QCIx_SBHO eA5
    [Arguments]    ${ue_eutra_capabilities}    ${ue_id}=1    ${cell_id}=1    ${earfcn}=1600
    Set UE parameters before attach    ue_id=${ue_id}
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration as a5_active
    ...    alias=attach_a5_flow    overall_timeout=2
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
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

UE Attach to eNB1 Cell1 with QCIx_SBHO eA5 and modify bearer
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${bearer_id}=1    ${qci}=8     ${earfcn}=1600
    UE Attach to eNB1 Cell1 with QCIx_SBHO eA5    ${ue_eutra_capabilities}    ue_id=${ue_id}    cell_id=${cell_id}    earfcn=${earfcn}
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measConfig contains (measIdToRemoveList is present))
    ...    alias=mod_bearer_noa5_deact_flow    overall_timeout=2
    Execute Egate Command    bearer_mod ue=${ue_id} id=${bearer_id} qci=${qci}
    Flow Not Occurred For Message    alias=mod_bearer_noa5_deact_flow
    sleep    ${reportTimerSBHoQciXA5}

UE Attach to eNB1 Cell1 without QCIx_SBHO eA5 and modify bearer
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${bearer_id}=1    ${qci}=8
    UE Attach to eNB1 Cell1 without QCIx_SBHO eA5    ${ue_eutra_capabilities}    ue_id=${ue_id}    cell_id=${cell_id}
    ${no_a5_query}    catenate
    ...    reportConfigToAddModList contains (reportConfigEUTRA contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97))))
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${no_a5_query})
    ...    alias=mod_bearer_no_a5_flow    overall_timeout=2
    Execute Egate Command    bearer_mod ue=${ue_id} id=${bearer_id} qci=${qci}
    sleep    ${reportTimerSBHoQciXA5}
    Flow Not Occurred For Message    alias=mod_bearer_no_a5_flow

Add one GBR QCIx bearer without QCIx_SBHO eA5
    [Arguments]    ${ue_id}=1    ${qci}=2
    ${no_a5_query}    catenate
    ...    reportConfigToAddModList contains (reportConfigEUTRA contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97))))
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${no_a5_query})
    ...    alias=add_GBR_no_a5_flow    overall_timeout=2
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci} mbr_ul=32 mbr_dl=320 gbr_ul=32 gbr_dl=320
    Flow Not Occurred For Message    alias=add_GBR_no_a5_flow

Add one GBR QCIx bearer with QCIx_SBHO eA5
    [Arguments]    ${ue_id}=1    ${qci}=2    ${earfcn}=1600
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration as a5_active
    ...    alias=GBR_a5_flow    overall_timeout=2
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci} mbr_ul=32 mbr_dl=320 gbr_ul=32 gbr_dl=320
    Flow Occurred As Expected    alias=GBR_a5_flow
    verify that message has fields
    ...    measObjectToAddModList..measObjectId eq 2
    ...    measObjectToAddModList..measObjectEUTRA..carrierFreq eq ${earfcn}
    ...    reportConfigToAddModList..reportConfigEUTRA..triggerType..event..eventId..eventA5..a5-Threshold1..threshold-RSRP eq 97
    ...    measIdToAddModList..measId eq 3
    ...    measIdToAddModList..measObjectId eq 2
    ...    measIdToAddModList..reportConfigId eq 5
    ...    message_alias=a5_active
    ...    flow_alias=GBR_a5_flow

Add one NON_GBR QCIx bearer without QCIx_SBHO eA5
    [Arguments]    ${ue_id}=1    ${qci}=2
    ${no_a5_query}    catenate
    ...    reportConfigToAddModList contains (reportConfigEUTRA contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97))))
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${no_a5_query})
    ...    alias=add_NBR_no_a5_flow    overall_timeout=2
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci}
    Flow Not Occurred For Message    alias=add_NBR_no_a5_flow

Add one NON_GBR QCIx bearer with QCIx_SBHO eA5
    [Arguments]    ${ue_id}=1    ${qci}=2        ${earfcn}=1600
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration as a5_active
    ...    alias=NBR_a5_flow    overall_timeout=2
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=NBR_a5_flow
    verify that message has fields
    ...    measObjectToAddModList..measObjectId eq 2
    ...    measObjectToAddModList..measObjectEUTRA..carrierFreq eq ${earfcn}
    ...    reportConfigToAddModList..reportConfigEUTRA..triggerType..event..eventId..eventA5..a5-Threshold1..threshold-RSRP eq 97
    ...    measIdToAddModList..measId eq 3
    ...    measIdToAddModList..measObjectId eq 2
    ...    measIdToAddModList..reportConfigId eq 5
    ...    message_alias=a5_active
    ...    flow_alias=NBR_a5_flow

Release one bearer no QCIx_SBHO eA5 deactivated
    [Arguments]    ${ue_id}=1    ${qci}=2
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measConfig contains (measIdToRemoveList is present))
    ...    alias=rel_bearer_no_a5_flow    overall_timeout=2
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci}
    Flow Not Occurred For Message    alias=rel_bearer_no_a5_flow

report eA5 measurement report
    [Arguments]    ${ue_id}=1    ${pci}=2    ${earfcn}=1600
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_MeasurementReport (measId eq 3)
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq ${pci}))
    ...    alias=intra_enb_ho_flow    overall_timeout=2
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A5 srsrp=60 srsrq=15 phycell_id=${pci} nrsrp=43 nrsrq=16 earfcn=${earfcn}
    Flow Occurred As Expected    alias=intra_enb_ho_flow

report eA5 measurement report to trigger inter-eNB HO
    [Arguments]    ${ue_id}=1    ${pci}=2    ${earfcn}=1600
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_MeasurementReport (measId eq 3)
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq ${pci}))
    ...    alias=inter_enb_ho_flow    overall_timeout=2
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A5 srsrp=60 srsrq=15 phycell_id=${pci} nrsrp=43 nrsrq=16 earfcn=${earfcn}
    Flow Occurred As Expected    alias=inter_enb_ho_flow

report eA5 measurement report RSRP lower than threshold
    [Arguments]    ${ue_id}=1    ${pci}=2    ${earfcn}=1600
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq ${pci}))
    ...    alias=no_handover_flow    overall_timeout=2
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A5 srsrp=60 srsrq=15 phycell_id=${pci} nrsrp=40 nrsrq=16 earfcn=${earfcn}
    Flow Not Occurred For Message    alias=no_handover_flow

Set UE parameters before attach
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_mme_param id=${ue_id} spid=1
    Execute Egate Command    enb_timer T_DC_Overall=5000ms
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
