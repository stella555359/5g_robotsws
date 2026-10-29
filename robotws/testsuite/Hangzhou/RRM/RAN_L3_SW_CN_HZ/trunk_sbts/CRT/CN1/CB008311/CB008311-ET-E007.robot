*** Settings ***
Documentation
...    author: Yan Susana
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G_TDD    SBTS00    team-Blues_SGT&A    owner-Sherry.zhang
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB008311    release-5G23R3    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    pass:True,fail:True
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{PARAMS_FOR_IODT_ABIO_2T4F}
...    @{same frequency}
...    @{NRREL}
...    @{8290_enable}
...    @{4CC}
...    @{8311_enable}
...    @{UL_CA_enable}

@{NRREL}
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-12:gNbId=1
...    NRCELL-11/NRREL-12:gNbIdLength=22
...    NRCELL-11/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-12:removeNotAllowed=false
...    NRCELL-11/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-12:lcrId=12
...    NRCELL-11/NRREL-12:sCellPrio=1
...    NRCELL-11/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-14:gNbId=1
...    NRCELL-11/NRREL-14:gNbIdLength=22
...    NRCELL-11/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-14:removeNotAllowed=false
...    NRCELL-11/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-14:lcrId=14
...    NRCELL-11/NRREL-14:sCellPrio=2
...    NRCELL-11/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlAndUl

@{8290_enable}
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fdd_Fdd
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=r4
...    NRCELL:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1ThresholdhoSsbRsrpSA=40|a1TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2ThresholdhoSsbRsrpSA=35|a2TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=20|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2ThresholdSCellRelSsbRsrp=34|a2TimeToTriggerSCellRelSsbRsrp=0ms

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-2:type0CoresetConfigurationIndex=10
...    MRBTS-1/NRBTS-1/NRCELL-2:chBw=50MHz
...    MRBTS-1/NRBTS-1/NRCELL-12:gscnOrSsPbchArfcn=1592
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnDl=127420
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136620
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12:type0CoresetConfigurationIndex=8
...    MRBTS-1/NRBTS-1/NRCELL-14:gscnOrSsPbchArfcn=1592
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:nrarfcnDl=127420
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:nrarfcnUl=136620
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-14:type0CoresetConfigurationIndex=8

@{4CC}
...    MRBTS-1/NRBTS-1/NRCELL-11:maxNumScellsDlFr1=3

@{8311_enable}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=2
...    NRCELL:dlSCellConfigLevelNum=5
...    NRCELL:dllaDeltaCqiMin=-150
...    NRBTS-1:actSCellReleaseForInactiveSCell=timer_based_Fr1
...    NRCELL:sCellInactivityReleaseTimer=20
...    NRBTS-1:actSCellReleaseBadSCellRlq=enabled_Fr1
...    NRBTS-1:sCellExcludelistTimerFr1=45
...    NRBTS-1:sCellDeactivationBadRlqCount=1
...    NRCELL:sCellGoodChannelQualityThreshold=8
...    NRCELL:sCellBadChannelQualityThreshold=4
...    NRCELL:sCellChannelEstimationPeriod=2000

@{UL_CA_enable}
...    NRCELL-1:increasePUSCHPrepTimeULCA=true
...    NRCELL:timingAdvanceOffset=n25600
...    NRBTS-1/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS-1/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40

${E007_Capa_Support}    SEPARATOR=
...    F9A0700047D0FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C160145B25AA0581
...    3E439F40478C73E618F28581C0E1E0A4FF93FE284003650000500000379C10403DEF5B8683228107000003AE0B00A2D92D502C09F21CFA023
...    C639F30C7942C0E070F066F3823007BDEB70D0645020E0000075C160145B25AA05813E439F40478C73E618F28581C0E1E0DDE7C2800F7BD6E
...    1A0C8A041C00000EB82C028B64B540B027C873E808F18E7CC31E50B0381C3C189FF27FC508006CA0000A000000950785000184D0000048158
...    70500713400000848150788C0018280001048150708C070A000001848100385000001141E230006134000A120561C2301C4D00000C120541E
...    2300071340000384C0541E2300070A00000404C0401C028809B010602308A0194130A74ED8E7C3853A76C73E1C29D3B639F0E14E9DB1CF870
...    276C73E1C29D3B639F0E14E9DB1CF870A74ED8E7C3841B1CF8603C246318C06318C7F00000026007C005638280381F84800E06000C001F010
...    E5A00000E00E5A00002E00E5A00004E00E5A00006E00E5A00008E00046505E54560656525606500C180000018000600005060001800020180
...    0060000C060000372882F95415C0E0AE530509008802783C1E0F0780002020200400808020001010020000401002080803006020040004040
...    1800010020040020100204040280301004000202014000080200410500A00E00C01C02803050020060100240100208080500602004008D403
...    80010203038D9293927814060148

@{PM_Counters_E007}
...    NRCELL-12:NCAC:${DL_RRC_1SCELL_REL_ATT_SA}=1
...    NRCELL-12:NCAC:${DL_RRC_1SCELL_REL_SUC_SA}=1
...    NRCELL-12:NCAC:${BAD_RLQ_REL_SCELL_ATT_SA}=2
...    NRCELL-12:NCAC:${BAD_RLQ_REL_SCELL_SUC_SA}=2

${DL_RRC_1SCELL_REL_ATT_SA}    M55118C10503     #The number of DL 1 SCell Release attempts on PCell for SA
${DL_RRC_1SCELL_REL_SUC_SA}    M55118C10504     #The number of successful DL 1 SCell Release attempts on PCell for SA
${BAD_RLQ_REL_SCELL_ATT_SA}    M55118C10515     #The number of SCells to be released on PCell due to bad SCell radio link quality for SA
${BAD_RLQ_REL_SCELL_SUC_SA}    M55118C10516     #The number of SCells released on PCell due to bad SCell radio link quality for SA

${pdu_id}    1
${gw_id}    1
${nwslice}    1

*** Test Cases ***
CB008311-ET-E007_2CC_FT_SA_Interaction_with_UL_CA_scell_candidate_for_UL_CA_blacklisted_measurement_based_scell_addtion
    [Documentation]
    ...    1. This user scenario describes scell addtion and released interaction with UL CA measurement based.
    ...    2. Configuration:
    ...           cell id=1 pci=16:2 tdd_cell=on nr_arfcn=518580:518580 gscn=6480 band=n41 chbw=60M
    ...           cell id=2 pci=17:0 tdd_cell=on nr_arfcn=633372:633372 gscn=7845 band=n78 chbw=50M
    ...           cell id=11 pci=20:0 tdd_cell=off nr_arfcn=344000:424000 gscn=5300 band=n66 chbw=60M
    ...           cell id=12 pci=20:1 tdd_cell=off nr_arfcn=136620:127420 gscn=1592 band=n71 chbw=10M
    ...           cell id=13 pci=20:2 tdd_cell=off nr_arfcn=348000:428000 gscn=5350 band=n66 chbw=60M
    ...           cell id=14 pci=21:0 tdd_cell=off nr_arfcn=136620:127420 gscn=1592 band=n71 chbw=10M
    ...       Configure nrrel Relations:
    ...           cell12-cell1
    ...    3. Test Case Steps:
    ...       1). UE81 attaches to FDD cell12 and sends A1 MR for SCell Addition.
    ...           High UL data rate starts for UE81, no buffer flow over for scell addition triggered
    ...           High DL data rate starts for UE81 and buffer overflow happens at DU, UE81 in FT CA status.
    ...       2). Trigger scell bad RLQ for cell1, after sCellDeactivationBadRlqCount * sCellChannelEstimationPeriod ms
    ...           cell1 deactivated.The DU sends private unacknowledged F1AP message to CU for Scell cell1 release.
    ...           And the reason for the release request is bad-rlq.
    ...           Before sCellBlacklistTimerFr1 expires, sends A1 MR for scell addition, UE81 is in no CA status.
    ...           After sCellBlacklistTimerFr1 expires, sends A1 MR for scell addition, UE81 is in FT CA status.
    ...       3). Delete PDU then rebuild PDU and start high DL data, cell1 be add as scell and activated.
    [Tags]    QC_47057    owner-Sherry.zhang    E007    CA_LABEL-FT(10MHz_FDD_n71+60MHz_TDD_n41)
    Clear Counter Files    wait=${False}
    Step1 UE81 in FT CA status
    Step2 Trigger scell bad RLQ for cell1 and scell addition
    Step3 Delete PDU then rebuild PDU
    UE Deregister From gNB    ue_id=81
    Check Counters    ${PM_Counters_E007}
    Check Wireshark Log    ${CURDIR}${/}a2a_E007${/}a2a.ini    wait_string=UEContextReleaseComplete::3

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Step1 UE81 in FT CA status
    Update UE capa    ${E007_Capa_Support}    81
    UE Attach To Target Cell    cell_id=12    ue_id=81
    Trigger ScellAdd    carrierfreq=127450    ue_id=81
    Send UL Throuput    ue_id=81
    Verify no Scell add UL data only    ue_id=81
    Send Throuput    ue_id=81
    Verify Throuput on Pcell and one Scell    ue_id=81

Step2 Trigger scell bad RLQ for cell1 and scell addition
    Trigger scell bad RLQ for scell    ue_id=81    scell_id=1
    Trigger ScellAdd    carrierfreq=127450    ue_id=81
    Verify no Scell add    ue_id=81
    sleep    20s     #Waiting for sCellBlacklistTimerFr1 expires
    Trigger ScellAdd    carrierfreq=127450    ue_id=81
    Verify Throuput on Pcell and one Scell    ue_id=81

Step3 Delete PDU then rebuild PDU
    Delete PDU then rebuild PDU
    Send Throuput    ue_id=81
    Verify Throuput on Pcell and one Scell    ue_id=81

UE Attach To Target Cell
    [Arguments]    ${cell_id}=11    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Delete PDU then rebuild PDU
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu_id}    Successfully released PDU Sessio
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Send UL Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=150 trf_id=7    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=30 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=50 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pcell and one Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=5    ${scell_id}=1    ${scell_dl}=5    ${ul}=3
    sleep    5s     #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify no Scell add
    [Arguments]    ${ue_id}=81    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0] *0 *0 *0
    Should Not Match Regexp    ${scell_tput}    CellIndex-[1]
    Should Be True    ${dl_throughput}/1000>${Tput_dl}

Verify no Scell add UL data only
    [Arguments]    ${ue_id}=81    ${pdu}=1    ${qfi}=1    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0] *0 *0 *0
    Should Not Match Regexp    ${scell_tput}    CellIndex-[1]

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger ScellAdd
    [Arguments]    ${event_type}=A1    ${carrierfreq}=424090    ${srsrp_nr}=100    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr}
    Execute Egate Command    ${cmd}    pass_regexp=RRC

Trigger scell bad RLQ for scell
    [Arguments]    ${profile_id}=2    ${scell_id}=3    ${ue_id}=81
    Trigger scell bad RLQ       profile_id=${profile_id}    scell_id=${scell_id}    ue_id=${ue_id}
    sleep    5s     #Waiting for bad PLQ activate
    Recover scell bad RLQ       profile_id=${profile_id}    scell_id=${scell_id}    ue_id=${ue_id}

Trigger scell bad RLQ
    [Arguments]    ${profile_id}=2    ${scell_id}=3    ${ue_id}=81
    Execute Egate Command    bler_testmode_nr profile_id=${profile_id} target_mcs=0 num_dl_pkts=10000
    ${cmd}    Catenate    ue_testmode_set_nr id=${ue_id} scell=${scell_id} testmode=bler action=activate profile_id=${profile_id}
    Execute Egate Command    ${cmd}    pass_regexp=SCellIndex ${scell_id} deactivated successfully at airphone.

Recover scell bad RLQ
    [Arguments]    ${profile_id}=2    ${scell_id}=3    ${ue_id}=81
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} scell=${scell_id} testmode=bler action=deactivate profile_id=${profile_id}
    ...    pass_regexp=CTRL_AP_UE_TESTMODE_SET_NR
    Execute Egate Command    bler_testmode_nr delete=true profile_id=${profile_id}