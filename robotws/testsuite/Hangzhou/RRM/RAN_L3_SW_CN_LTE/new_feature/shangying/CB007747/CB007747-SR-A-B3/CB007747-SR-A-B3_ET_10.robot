*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    no_CRT    CLOUD_R4LAPO_CUS    team-SG1
...               owner-feng.2.chen,ying.shang    release-SBTS22R3
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{x2link}
...    @{LTE4088}
...    @{LTE4193_disable}
...    @{add_moPrMapList}
...    @{7747_config}
...    @{link_speed}
...    @{deal_relation_error}
@{link_speed}
...    MRBTS-1/EQM-1/HWTOP-1/CABLINK-3:linkSpeed=Auto
...    MRBTS-1/EQM-1/HWTOP-1/CABLINK-2:linkSpeed=Auto
...    MRBTS-1/EQM-1/HWTOP-1/CABLINK-1:linkSpeed=Auto
@{x2link}
...    LNBTS/LNADJGNB-1:adjGnbId=7
...    LNBTS/LNADJGNB-1:adjGnbIdLength=22
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.47
...    LNBTS/LNADJGNB-2:adjGnbId=8
...    LNBTS/LNADJGNB-2:adjGnbIdLength=22
...    LNBTS/LNADJGNB-2:administrativeState=unlocked
...    LNBTS/LNADJGNB-2:cPlaneIpAddr=10.0.1.48
...    LNBTS/LNADJGNB-3:adjGnbId=9
...    LNBTS/LNADJGNB-3:adjGnbIdLength=22
...    LNBTS/LNADJGNB-3:administrativeState=unlocked
...    LNBTS/LNADJGNB-3:cPlaneIpAddr=10.0.1.49
...    LNCEL/LNRELGNBCELL-0:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-0:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-0:nrCellId=115969
...    LNCEL/LNRELGNBCELL-0:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-0:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-0:nrCgiPlmnId:mncLength=2
...    LNCEL/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-1:nrCellId=115970
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-2:nrCellId=132355
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
...    LNCEL/LNRELGNBCELL-3:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-3:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-3:nrCellId=148740
...    LNCEL/LNRELGNBCELL-3:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-3:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-3:nrCgiPlmnId:mncLength=2
@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:nrRestrictionOverride=disabled
...    LNCEL:defaultLnRelGnbCellId=0
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNBTS:tLteNrDualConnectPrep=5000
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
@{LTE4193_disable}
...    LNBTS:actDynTrigLteNrDualConnectivity=false
...    LNCEL/LNCEL_TDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchAddAUeRrHo=10
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchAddAUeTcHo=15
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrc=10
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchSrPeriodUpperLimit=40
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:actLbPucchReg=true
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:lbPucchRPrId=1
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:selectPrachRegion=None
...    LNBTS/LBPUCCHRPR-1:countdownPucchCompr=60min
...    LNBTS/LBPUCCHRPR-1:countdownPucchExp=1min
...    LNBTS/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...    LNBTS/LBPUCCHRPR-1:rrcConnectedUpperThresh=80
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN2036667}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=258
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=120kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=0
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
@{add_moPrMapList}
...    LNBTS-1:actSelMobPrf=true
...    LNBTS-1/MODPR-0:autoAdapt=false
...    LNBTS-1:moProfileSelect=spid
...    LNCEL-1:moPrMappingList:spid=2|moPrId=1
...    LNCEL-1:moPrMappingList:spidLast=100|moPrId=1
...    LNCEL-1:moPrMappingList:mcc=262|moPrId=1
...    LNCEL-1:moPrMappingList:mnc=3|moPrId=1
...    LNCEL-1:moPrMappingList:mncLength=2|moPrId=1
...    LNCEL-1:moPrMappingList:spid=120|moPrId=2
...    LNCEL-1:moPrMappingList:spidLast=200|moPrId=2
...    LNCEL-1:moPrMappingList:mcc=262|moPrId=2
...    LNCEL-1:moPrMappingList:mnc=3|moPrId=2
...    LNCEL-1:moPrMappingList:mncLength=2|moPrId=2
...    LNCEL-1:moPrMappingList:spid=201|moPrId=3
...    LNCEL-1:moPrMappingList:spidLast=256|moPrId=3
...    LNCEL-1:moPrMappingList:mcc=262|moPrId=3
...    LNCEL-1:moPrMappingList:mnc=3|moPrId=3
...    LNCEL-1:moPrMappingList:mncLength=2|moPrId=3
@{deal_relation_error}
...    LNBTS-1:actTransmittedBelowGap=false
${F1}    524032
${F2}    188512
${F3}    2079200
${F5}    2079500
@{7747_config}
...    LNBTS-1:actNrFreqFilterForEnDc=false
...    LNBTS-1:blockEndcHoRetryAtHoFromTrg=no blocking
...    MODPR-0:allowEnDc=all_freq_layers
...    MOPR-1:allowEnDc=all_freq_layers
...    MOPR-2:allowEnDc=all_freq_layers
...    MOPR-3:allowEnDc=all_freq_layers
...    MOPR-1:freqLayListEnDc:carrierFreqNrCell=${F1}|carrierFreqNrCell=${F1}
...    MOPR-1:freqLayListEnDc:carrierFreqNrCell=${F2}|carrierFreqNrCell=${F2}
...    MOPR-2:freqLayListEnDc:carrierFreqNrCell=${F5}|carrierFreqNrCell=${F5}
...    MOPR-2:freqLayListEnDc:carrierFreqNrCell=${F1}|carrierFreqNrCell=${F1}
...    MOPR-3:freqLayListEnDc:carrierFreqNrCell=${F5}|carrierFreqNrCell=${F5}
...    MODPR-0:freqLayListEnDc:carrierFreqNrCell=${F1}|carrierFreqNrCell=${F1}
@{case10_delta1}
...    LNBTS-1:actNrFreqFilterForEnDc=true
...    LNBTS-1:blockEndcHoRetryAtHoFromTrg=no blocking
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNCEL-2:defaultLnRelGnbCellId=2
...    MODPR-0:allowEnDc=dedicated_freq_layers
...    MOPR-1:allowEnDc=EN-DC disabled
...    MOPR-2:allowEnDc=dedicated_freq_layers
...    MOPR-3:allowEnDc=all_freq_layers
...    MOPR-1:freqLayListEnDc:carrierFreqNrCell=${F2}|carrierFreqNrCell=${F2}
...    MOPR-1:freqLayListEnDc:carrierFreqNrCell=${F1}|carrierFreqNrCell=${F1}
...    MOPR-2:freqLayListEnDc:carrierFreqNrCell=${F5}|carrierFreqNrCell=${F5}
...    MOPR-2:freqLayListEnDc:carrierFreqNrCell=${F1}|carrierFreqNrCell=${F1}
...    MOPR-3:freqLayListEnDc:carrierFreqNrCell=${F5}|carrierFreqNrCell=${F5}
...    MODPR-0:freqLayListEnDc:carrierFreqNrCell=${F2}|carrierFreqNrCell=${F2}
@{case10_delta2}
...    LNCEL-1:defaultLnRelGnbCellId=2
...    delete:MOPR-2:freqLayListEnDc:carrierFreqNrCell=${F5}|carrierFreqNrCell=${F5}
...    delete:MOPR-2:freqLayListEnDc:carrierFreqNrCell=${F1}|carrierFreqNrCell=${F1}
...    MOPR-2:freqLayListEnDc:carrierFreqNrCell=${F2}|carrierFreqNrCell=${F2}
${ue_nr_capabilities}    0000000001010040000060000038000400040160401C06000000
${ue_eutra_nr_capabilities}    SEPARATOR=
...    01080C0364A008081010701800000006C94010102020E0380000000D81003060064A01D00000000000C000201000080400020101002004
${ue_eutra_capabilities}    SEPARATOR=
...    DE1809D9408206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D0
...    0000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D
...    00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D
...    00000001BFBFFEC800801C364000000017BA000000080952A0E2740400003840000210002C20000108008400010C0002200004500008C00
...    011C0002400004900009400012C0002600004D0000A0000144000290000530000A80001540002B0000570000B00001640002D00005B0000
...    BA0001780003680007F001D3A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D000
...    00000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D000
...    00000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000A080000079D000000000000000000000
...    000000000000000000000000000000000000001011C42129A061CFFFFFFFFFFFFFFFA020A8001802297000020000104B1A0100C03A00F0
...    00000600000020
@{SharedPlmnList}    262:03
${gnb7_cell1}    SEPARATOR=
...    {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x501', nr_arfcn: '507000:531000', shared_plmn: ${SharedPlmnList}}

${gnb7_cell2}    SEPARATOR=
...    {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x502', nr_arfcn: '500000:524000', shared_plmn: ${SharedPlmnList}}

${gnb8_cell1}    SEPARATOR=
...    {id: 81, technology: nr , tac: 33, pci: '1:0', nrci: '0x503', nr_arfcn: '179500:188500', shared_plmn: ${SharedPlmnList}}

${gnb9_cell1}    SEPARATOR=
...    {id: 91, technology: nr , tac: 33, pci: '1:1', nrci: '0x504', nr_arfcn: '2079166:2079166', shared_plmn: ${SharedPlmnList},
...    sysinfo_FBI: '261', mapped_MFBI: '257'}

*** Test Cases ***
CB007747-SR-A-B3_ET_10_01_ENDC blind addtion sucessfully after filtered by actNrFreqFilterForEnDc
    [Documentation]
    ...    LNCEL-1:defaultLnRelGnbCellId=1 ->F1
    ...    LNCEL-2:defaultLnRelGnbCellId=2 ->F2
    ...    MOPR-1:allowEnDc=0 (disable)
    ...    MOPR-1:freqLayListEnDc={F1, F2}
    ...    MOPR-2:allowEnDc=1 (selected_NR_Layers)
    ...    MOPR-2:freqLayListEnDc={F1, F5}
    ...    MOPR-3:allowEnDc=2 (all_NR_Layers)
    ...    MOPR-3:freqLayListEnDc={F3} (F5 in fact)
    ...    MODPR-0:allowEnDc=1 (selected_NR_Layers)
    ...    MODPR-0:freqLayListEnDc={F2}
    ...    UE1, UE6, UE11
    ...    ue_mme_param id=1 spid=1 -> MOPR-1
    ...    UE2, UE7, UE12
    ...    ue_mme_param id=1 spid=150 -> MOPR-2
    ...    UE3, UE8, UE13
    ...    ue_mme_param id=1 spid=230 -> MOPR-3
    ...    UE4, UE9, UE14, UE24
    ...    ue_mme_param id=1 spid=110 -> MODPR-0
    ...    UE5, UE10, UE15, UE25
    ...    No spid assigned -> MODPR-0
    ...    step1: attach UE1 to cell-1 and check no ENDC setup for F1
    ...    step2: attach UE2 to cell-1 and check ENDC setup for F1
    ...    step3: attach UE3 to cell-1 and check ENDC setup for F1
    ...    step4: attach UE24 to cell-2 and check ENDC setup for F2 after ENDC bear
    ...    step5: attach UE25 to cell-2 and check ENDC setup for F2 after ENDC bear
    ...    step6: online change
    ...           Online modify allowEnDc for MOPR-1:
    ...           MOPR-2:allowEnDc= dedicated_freq_layers
    ...           MOPR-2:freqLayListEnDc={F1, F5} -> {F2}
    ...    step7: attach UE2 to cell-1 and check ENDC setup for F2
    [Tags]    QC_xxxxxx
    Set UE Parameters Before Attach
    OnlineParamChange    ${case10_delta1}
    Attach UE to Cell-1 and check ENDC not established for F1    ue_id=1
    Attach UE to Cell-1 and ENDC setup with F1     ue_id=2
    Attach UE to Cell-1 and ENDC setup with F1    ue_id=3
    Attach UE to Cell-2 and ENDC setup with F2 after add bearer    ue_id=24
    Attach UE to Cell-2 and ENDC setup with F2 after add bearer    ue_id=25
    OnlineParamChange    ${case10_delta2}
    Attach UE to Cell-2 and ENDC setup with F2    ue_id=12
    Release all UEs

*** Keywords ***

Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_ABIO
    Execute Egate Command    trace_sim on mme=1 protocol=s1
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create Enb Alias    eNB_1    enb_id=1    id_type=wts
    Create Enb Alias    gNB_7    enb_id=7    id_type=wts
    Create Enb Alias    gNB_8    enb_id=8    id_type=wts

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 6, default: on, pdn: 1, trf_type: external}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 2, gbr_ul: 144, gbr_dl: 144, mbr_ul: 144, mbr_dl: 144, pdn: 1}
    ...     - {qci: 3, gbr_ul: 64, gbr_dl: 128, mbr_ul: 64, mbr_dl: 128, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 330, mbr_ul: 32, mbr_dl: 320, pdn: 1}
    ...     - {qci: 5, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    ...     - {qci: 7, pdn: 1}
    ...     - {qci: 9, pdn: 1}
    ...     - {qci: 8, default: on, pdn: 2, trf_type: external}
    ...     - {qci: 6, pdn: 2}
    ...     - {qci: 7, pdn: 2}
    ...     - {qci: 9, pdn: 2}
    FOR    ${ue_set_id}     IN RANGE    1    20
        Update Yaml    UEs/UE_sets/${ue_set_id}    bearer: 'bearer_set_1'    release: '15'    nea: 'null'    nia: 'null'
    END
    FOR    ${ue_set_id}     IN RANGE    21    31
        Update Yaml    UEs/UE_sets/${ue_set_id}    bearer: 'bearer_set_2'    release: '15'    nea: 'null'    nia: 'null'
    END
    Add Yaml    BASE_STATIONS
    ...      - id: 7
    ...        gnb_id: '0x00007'
    ...        type: simulated
    ...        plmn: '262:03'
    ...        s1u: 10.0.1.47
    ...        x2: 10.0.1.47
    ...        cells:
    ...          - ${gnb7_cell1}
    ...          - ${gnb7_cell2}
    Add Yaml    BASE_STATIONS
    ...      - id: 8
    ...        gnb_id: '0x00008'
    ...        type: simulated
    ...        plmn: '262:03'
    ...        s1u: 10.0.1.48
    ...        x2: 10.0.1.48
    ...        cells:
    ...          - ${gnb8_cell1}
    Add Yaml    BASE_STATIONS
    ...      - id: 9
    ...        gnb_id: '0x00009'
    ...        type: simulated
    ...        plmn: '262:03'
    ...        s1u: 10.0.1.49
    ...        x2: 10.0.1.49
    ...        cells:
    ...          - ${gnb9_cell1}

Set UE Parameters Before Attach
    FOR    ${ue_id}    IN RANGE    1    30
        Execute Uex Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
        Execute Uex Command    ue_param id=${ue_id} nr_supported_bands=7,8,257
    END
    Execute Egate Command    ue_mme_param id=1,6,11,16,21,26 spid=20
    Execute Egate Command    ue_mme_param id=2,7,12,17,22,27 spid=150
    Execute Egate Command    ue_mme_param id=3,8,13,18,23,28 spid=230
    Execute Egate Command    ue_mme_param id=4,9,14,19,24,29 spid=110
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    Execute Egate Command    enb_timer T_DC_Overall=5000ms
    Execute Egate Command
    ...    gnb_endc_param id=7 include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true scg_dl_dist_percent=0
    Execute Egate Command
    ...    gnb_endc_param id=8 include_reestablish_pdcp=on selected_band_combination_nr=2:1 use_nr_ran_cont=true scg_dl_dist_percent=0
    Execute Egate Command
    ...    gnb_endc_param id=9 include_reestablish_pdcp=on selected_band_combination_nr=3:1 use_nr_ran_cont=true scg_dl_dist_percent=0

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Attach UE to Cell-1 and ENDC setup with F1
    [Arguments]    ${ue_id}
    Expect message flow
    ...    gNB_7:X2AP_SgNBAdditionRequest
    ...    gNB_7:X2AP_SgNBAdditionRequestAcknowledge
    ...    gNB_7:X2AP_SgNBReconfigurationComplete
    ...    gNB_7:X2AP_SNStatusTransfer
    ...    alias=ENDC_setup_with_gNB7    overall_timeout=20
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} \ ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} \
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} cell=1
    Execute Uex Command    ${V_1}
    Flow Occurred As Expected    alias=ENDC_setup_with_gNB7

Attach UE to Cell-2 and ENDC setup with F2
    [Arguments]    ${ue_id}
    Expect message flow
    ...    gNB_8:X2AP_SgNBAdditionRequest
    ...    gNB_8:X2AP_SgNBAdditionRequestAcknowledge
    ...    gNB_8:X2AP_SgNBReconfigurationComplete
    ...    gNB_8:X2AP_SNStatusTransfer
    ...    alias=ENDC_setup_with_gNB8    overall_timeout=20
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} \ ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} \
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} cell=2
    Execute Uex Command    ${V_1}
    Flow Occurred As Expected    alias=ENDC_setup_with_gNB8

Attach UE to Cell-1 and check ENDC not established for F1
    [Arguments]    ${ue_id}
    Expect message will not occur
    ...    gNB_7:X2AP_SgNBAdditionRequest
    ...    alias=ENDC_trigger    overall_timeout=20
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} \ ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} \
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} cell=1
    Execute Uex Command    ${V_1}
    Flow Not Occurred For message    alias=ENDC_trigger

Add ENDC Bearer
    [Arguments]    ${ue_id}
        Execute Uex Command    ue_pdn_connect id=${ue_id} apn=nokia_2.net

Attach UE to Cell-2 and ENDC setup with F2 after add bearer
     [Arguments]    ${ue_id}
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} \ ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} \
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} cell=2
    Execute Uex Command    ${V_1}
    Add ENDC Bearer    ${ue_id}
    Expect message flow
    ...    gNB_8:X2AP_SgNBAdditionRequest
    ...    gNB_8:X2AP_SgNBAdditionRequestAcknowledge
    ...    gNB_8:X2AP_SgNBReconfigurationComplete
    ...    gNB_8:X2AP_SNStatusTransfer
    ...    alias=ENDC_setup_with_gNB8    overall_timeout=20
    Flow Occurred As Expected    alias=ENDC_setup_with_gNB8
