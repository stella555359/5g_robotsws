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
...    NRCELL:ulPowerControlCommon:p0NominalPucchF1F3=-108
...    @{PARAMS_FOR_IODT_ABIO_2T4F}
...    @{CA_enable}
...    @{same frequency}
...    @{NRREL}
...    @{4CC}
...    @{8311_enable}

@{CA_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=NumberCellAmount
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actHoOptimizationCa=true
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=20|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2ThresholdSCellRelSsbRsrp=34|a2TimeToTriggerSCellRelSsbRsrp=0ms

@{same frequency}
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

@{NRREL}
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-11:gNbId=1
...    NRCELL-12/NRREL-11:gNbIdLength=22
...    NRCELL-12/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-11:removeNotAllowed=false
...    NRCELL-12/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-11:lcrId=11
...    NRCELL-12/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:lcrId=2
...    NRCELL-12/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-11:gNbId=1
...    NRCELL-2/NRREL-11:gNbIdLength=22
...    NRCELL-2/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-11:removeNotAllowed=false
...    NRCELL-2/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-11:lcrId=11
...    NRCELL-2/NRREL-11:sCellPrio=1
...    NRCELL-2/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-12:gNbId=1
...    NRCELL-2/NRREL-12:gNbIdLength=22
...    NRCELL-2/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-12:removeNotAllowed=false
...    NRCELL-2/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-12:lcrId=12
...    NRCELL-2/NRREL-12:sCellPrio=1
...    NRCELL-2/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-13:gNbId=1
...    NRCELL-2/NRREL-13:gNbIdLength=22
...    NRCELL-2/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-13:removeNotAllowed=false
...    NRCELL-2/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-13:lcrId=13
...    NRCELL-2/NRREL-13:sCellPrio=1
...    NRCELL-2/NRREL-13:sCellOperationalMode=dlOnly

@{4CC}
...    MRBTS-1/NRBTS-1/NRCELL-2:maxNumScellsDlFr1=3

@{8311_enable}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=2
...    NRCELL:dlSCellConfigLevelNum=5
...    NRCELL:dllaDeltaCqiMin=-150
...    NRBTS-1:actSCellReleaseForInactiveSCell=disabled
...    NRCELL:sCellInactivityReleaseTimer=20
...    NRBTS-1:actSCellReleaseBadSCellRlq=enabled_Fr1
...    NRBTS-1:sCellExcludelistTimerFr1=30
...    NRBTS-1:sCellDeactivationBadRlqCount=1
...    NRCELL:sCellGoodChannelQualityThreshold=8
...    NRCELL:sCellBadChannelQualityThreshold=4
...    NRCELL:sCellChannelEstimationPeriod=2000

${SA_Capa_Support}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC09F11
...    C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000044000702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC09F1
...    8E7CC31E50B0381C3C17003FF001C00FFC00110001C0A836236B04610D04083C412032B64C55890E7C471EC09F1891C790E7D473E618F2858
...    1C0E1E13FFE00000FFF80000088000E000AC7C28000E20800710400388C0000082C0803808D00A2026C0410D4026018D0204081B1CF8000A0
...    233D04C00F000A070500703009401C0018090010180F82400800000004000008020000000100000200800002004000018020000100100000A
...    008004010040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C033953595358295
...    8195833582B594B5933580B581B58095811583B40D04000025949410000196525040000A59490100003965240400012594901000059652404
...    0001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154
...    162A82C55068AA531549A2A80C55028AA4D5541E28480BC04A8140A05028140A05028140A05028140A05028140A000C10100C018040080108
...    080100402018030C04008010100C01804030060100C018202018030080600C201002004040300601002004402018030080600C02018030404
...    00802010020086A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD050E0B4

${pdu_id}    1
${gw_id}    1
${nwslice}    1

@{parameter_C011}
...    NRBTS-1:actSCellReleaseForInactiveSCell=disabled
...    NRBTS-1:actSCellReleaseBadSCellRlq=enabled_Fr1
...    NRBTS-1:sCellExcludelistTimerFr1=30

@{parameter_C020}
...    NRBTS-1:actSCellReleaseForInactiveSCell=timer_based_Fr1
...    NRBTS-1:actSCellReleaseBadSCellRlq=disabled
...    NRBTS-1:sCellExcludelistTimerFr1=0
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=66
...    NRCELL-2:weightForSCellSelection=5

@{parameter_C022}
...    NRBTS-1:actSCellReleaseForInactiveSCell=disabled
...    NRBTS-1:actSCellReleaseBadSCellRlq=enabled_Fr1
...    NRBTS-1:sCellExcludelistTimerFr1=30

@{actSCellReleaseBadSCellRlq_enable}
...    NRBTS-1:actSCellReleaseBadSCellRlq=enabled_Fr1

@{sCellBlacklistTimerFr1_120}
...    NRBTS-1:sCellExcludelistTimerFr1=120

@{sCellBlacklistTimerFr1_0}
...    NRBTS-1:sCellExcludelistTimerFr1=0

@{PM_Counters_C011}
...    NRCELL-11:NCAC:${DL_RRC_1SCELL_REL_ATT_SA}=4
...    NRCELL-11:NCAC:${DL_RRC_1SCELL_REL_SUC_SA}=4
...    NRCELL-11:NCAC:${BAD_RLQ_REL_SCELL_ATT_SA}=4
...    NRCELL-11:NCAC:${BAD_RLQ_REL_SCELL_SUC_SA}=4

@{PM_Counters_C020}
...    NRCELL-12:NCAC:${DL_RRC_1SCELL_REL_ATT_SA}=2
...    NRCELL-12:NCAC:${DL_RRC_1SCELL_REL_SUC_SA}=2
...    NRCELL-12:NCAC:${BAD_RLQ_REL_SCELL_ATT_SA}=1
...    NRCELL-12:NCAC:${BAD_RLQ_REL_SCELL_SUC_SA}=1
...    NRCELL-12:NCAC:${INA_PRO_REL_SCELL_ATT_SA}=1
...    NRCELL-12:NCAC:${INA_PRO_REL_SCELL_SUC_SA}=1

${DL_RRC_1SCELL_REL_ATT_SA}    M55118C10503     #The number of DL 1 SCell Release attempts on PCell for SA
${DL_RRC_1SCELL_REL_SUC_SA}    M55118C10504     #The number of successful DL 1 SCell Release attempts on PCell for SA
${INA_PRO_REL_SCELL_ATT_SA}    M55118C10511     #The number of SCells to be released on PCell due to prolonged inactivity for SA
${INA_PRO_REL_SCELL_SUC_SA}    M55118C10512     #The number of SCells released on PCell due to prolonged inactivity for SA
${BAD_RLQ_REL_SCELL_ATT_SA}    M55118C10515     #The number of SCells to be released on PCell due to bad SCell radio link quality for SA
${BAD_RLQ_REL_SCELL_SUC_SA}    M55118C10516     #The number of SCells released on PCell due to bad SCell radio link quality for SA

*** Test Cases ***
CB008311-ET-C011_2CC_FT_SA_gNB_performs_scell_release_due_to_scell_RLQ_multiUEs
    [Documentation]
    ...    New parameter for 8311-C :
    ...    actSCellReleaseBadSCellRlq: activates/deactivates the SCell release on bad SCell RLQ.
    ...    sCellBlacklistTimerFr1: indicates the time during which the gNB does not consider the SCell for SCell selection in SCell Addition,
    ...           SCell Change, or SCell Swap after the SCell has been released due to bad SCell radio link quality (RLQ).
    ...           If NRBTS.actSCellReleaseBadSCellRlq is different from 'disabled', then NRBTS.sCellBlacklistTimerFr1 shall be configured.
    ...    actSCellReleaseForInactiveSCell: activates/deactivates the release for inactive SCells after no data activity for longer than the
    ...           SCell inactivity release timer (NRCELL.sCellInactivityReleaseTimer).
    ...    sCellInactivityReleaseTimer: indicates the time during which a SCell has no data activity or is deactivated due to UE overheating or
    ...           bad RLQ before triggering an SCell release.It shall be configured if actSCellReleaseForInactiveSCell is not equal to 'disabled'.
    ...    sCellBlacklistTimerFr1: indicates the time during which the gNB does not consider the SCell for SCell selection in SCell Addition,
    ...           SCell Change, or SCell Swap after the SCell has been released due to bad SCell radio link quality (RLQ).
    ...    1. This user scenario describes scell release due to RLQ multiUEs based blind scell addition.
    ...    2. Configuration:
    ...           cell id=1 pci=16:2 tdd_cell=on nr_arfcn=518580:518580 gscn=6480 band=n41 chbw=60M
    ...           cell id=2 pci=17:0 tdd_cell=on nr_arfcn=518598:518598 gscn=6486 band=n41 chbw=60M
    ...           cell id=11 pci=20:0 tdd_cell=off nr_arfcn=344000:424000 gscn=5300 band=n66 chbw=60M
    ...           cell id=12 pci=20:1 tdd_cell=off nr_arfcn=136620:127420 gscn=1592 band=n71 chbw=10M
    ...           cell id=13 pci=20:2 tdd_cell=off nr_arfcn=348000:428000 gscn=5350 band=n66 chbw=60M
    ...           cell id=14 pci=21:0 tdd_cell=off nr_arfcn=136620:127420 gscn=1592 band=n71 chbw=10M
    ...       Configure nrrel Relations:
    ...           cell11-cell2
    ...    3. Test Case Steps:
    ...       1). UE81 attaches to TDD cell11 and High DL data rate starts and buffer overflow happens at DU, UE81 in FT CA status.
    ...           UE82 attaches to TDD cell11 and High DL data rate starts and buffer overflow happens at DU, UE82 in FT CA status.
    ...           UE83 attaches to TDD cell11 and High DL data rate starts and buffer overflow happens at DU, UE83 in FT CA status.
    ...           UE84 attaches to TDD cell11 and High DL data rate starts and buffer overflow happens at DU, UE84 in FT CA status.
    ...       2). Trigger scell bad RLQ for UE81 UE82 UE83 UE84 one by one,since actSCellReleaseBadSCellRlq is set to enabled_Fr1 after
    ...           sCellDeactivationBadRlqCount * sCellChannelEstimationPeriod ms cell2 is deactivated.DU sends private unacknowledged F1AP message
    ...           to CU for Scell cell2 release.And the reason for the release request is bad-rlq.
    ...       3). The gNB follows the legacy blind procedure for releasing the SCell from UE. CU marks Cell2 as blacklisted for bad RLQ and starts
    ...           the sCellBlacklistTimerFr1 timer to prevent Cell2 from being selected as SCell.For UE81-UE84 after sCellBlacklistTimerFr1 expires,
    ...           UEs still remain in non-CA status since scell addtion will not be triggered due to sCellAdditionMethod is blind in this case.
    [Tags]    QC_279061    owner-Sherry.zhang    C011    CA_LABEL-FT(10MHz_FDD_n66+60MHz_TDD_n41)
    Clear Counter Files    wait=${False}
    C011 Step1 UEs in FT CA status
    C011 Step2 Trigger scell bad RLQ for UEs one by one
    C011 Step3 UEs remain in non CA status
    UE Deregister From gNB
    Check Counters    ${PM_Counters_C011}
    Check Wireshark Log    ${CURDIR}${/}a2a_C011${/}a2a.ini    wait_string=UEContextReleaseComplete::3

CB008311-ET-C020_3CC_FFT_SA_Online_modification_and_scell_release_due_to_bad_scell_RLQ_disable_to_enabled_interact_with_scell_change
    [Documentation]
    ...    New parameter for 8311-C :
    ...    actSCellReleaseBadSCellRlq: activates/deactivates the SCell release on bad SCell RLQ.
    ...    sCellBlacklistTimerFr1: indicates the time during which the gNB does not consider the SCell for SCell selection in SCell Addition,
    ...           SCell Change, or SCell Swap after the SCell has been released due to bad SCell radio link quality (RLQ).
    ...           If NRBTS.actSCellReleaseBadSCellRlq is different from 'disabled', then NRBTS.sCellBlacklistTimerFr1 shall be configured.
    ...    actSCellReleaseForInactiveSCell: activates/deactivates the release for inactive SCells after no data activity for longer than the
    ...           SCell inactivity release timer (NRCELL.sCellInactivityReleaseTimer).
    ...    sCellInactivityReleaseTimer: indicates the time during which a SCell has no data activity or is deactivated due to UE overheating or
    ...           bad RLQ before triggering an SCell release.It shall be configured if actSCellReleaseForInactiveSCell is not equal to 'disabled'.
    ...    sCellBlacklistTimerFr1: indicates the time during which the gNB does not consider the SCell for SCell selection in SCell Addition,
    ...           SCell Change, or SCell Swap after the SCell has been released due to bad SCell radio link quality (RLQ).
    ...    1. This user scenario describes SCell Release parameters - actSCellReleaseBadSCellRlq On-Line modification.
    ...    2. Configuration:
    ...       NRCELL-12/a1ThresholdSCellAddSsbRsrpTDD lower than NRCELL-11/a1ThresholdSCellAddSsbRsrpFDD
    ...           cell id=1 pci=16:2 tdd_cell=on nr_arfcn=518580:518580 gscn=6480 band=n41 chbw=60M
    ...           cell id=2 pci=17:0 tdd_cell=on nr_arfcn=518598:518598 gscn=6486 band=n41 chbw=60M
    ...           cell id=11 pci=20:0 tdd_cell=off nr_arfcn=344000:424000 gscn=5300 band=n66 chbw=60M
    ...           cell id=12 pci=20:1 tdd_cell=off nr_arfcn=136620:127420 gscn=1592 band=n71 chbw=10M
    ...           cell id=13 pci=20:2 tdd_cell=off nr_arfcn=348000:428000 gscn=5350 band=n66 chbw=60M
    ...           cell id=14 pci=21:0 tdd_cell=off nr_arfcn=136620:127420 gscn=1592 band=n71 chbw=10M
    ...        Configure nrrel Relations:
    ...           cell12-cell11, cell12-cell2
    ...    3. Test Case Steps:
    ...       1). UE81 attaches to FDD cell12 and sends A1 MR with Entry condition for SCell Addition with RSRP above FDD threshold
    ...           High DL data rate starts for UE81 and buffer overflow happens at DU, UE81 in FFT CA status.
    ...       2). Operator online reconfigures NRBTS.actSCellReleaseBadSCellRlq to enabled_Fr1 and new parameters committed.
    ...           Trigger scell bad RLQ for FDD cell11, after sCellDeactivationBadRlqCount * sCellChannelEstimationPeriod ms
    ...           cell11 deactivated. Here gNB follows the legacy bad RLQ procedure for SCell deactivated. Here actSCellReleaseForInactiveSCell
    ...           is enabled then after sCellInactivityReleaseTimer expire SCell cell11 be released due to no data.
    ...       3). Trigger A1 MR with Entry condition for UE81 for SCell change.
    ...           UE81 scell change from TDD cell2 to FDD cell11.
    ...       4). Trigger scell bad RLQ for cell11, after sCellDeactivationBadRlqCount * sCellChannelEstimationPeriod ms
    ...           cell11 deactivated.The DU sends private unacknowledged F1AP message to CU for Scell cell11 release.
    ...           And the reason for the release request is bad-rlq.
    [Tags]    QC_47056    owner-Sherry.zhang    C020    CA_LABEL-FFT(10MHz_FDD_n71+10MHz_FDD_n66+60MHz_TDD_n41)    AP_REG
    Clear Counter Files
    C020 Step1 UE attach to cell12
    C020 Step2 online change actSCellReleaseBadSCellRlq
    C020 Step3 Trigger A1 MR for SCell change
    C020 Step4 Trigger scell bad RLQ for cell11
    UE Deregister From gNB
    Check Counters    ${PM_Counters_C020}
    Check Wireshark Log    ${CURDIR}${/}a2a_C020${/}a2a.ini    wait_string=UEContextReleaseComplete::3

CB008311-ET-C022_4CC_TFFF_SA_Online_modification_of_scell_release_parameters_scell_blacklist_timer
    [Documentation]
    ...    New parameter for 8311-C :
    ...    actSCellReleaseBadSCellRlq: activates/deactivates the SCell release on bad SCell RLQ.
    ...    sCellBlacklistTimerFr1: indicates the time during which the gNB does not consider the SCell for SCell selection in SCell Addition,
    ...           SCell Change, or SCell Swap after the SCell has been released due to bad SCell radio link quality (RLQ).
    ...           If NRBTS.actSCellReleaseBadSCellRlq is different from 'disabled', then NRBTS.sCellBlacklistTimerFr1 shall be configured.
    ...    actSCellReleaseForInactiveSCell: activates/deactivates the release for inactive SCells after no data activity for longer than the
    ...           SCell inactivity release timer (NRCELL.sCellInactivityReleaseTimer).
    ...    sCellInactivityReleaseTimer: indicates the time during which a SCell has no data activity or is deactivated due to UE overheating or
    ...           bad RLQ before triggering an SCell release.It shall be configured if actSCellReleaseForInactiveSCell is not equal to 'disabled'.
    ...    sCellBlacklistTimerFr1: indicates the time during which the gNB does not consider the SCell for SCell selection in SCell Addition,
    ...           SCell Change, or SCell Swap after the SCell has been released due to bad SCell radio link quality (RLQ).
    ...    1. This user scenario describes SCell Release parameters - SCell blacklist timer On-Line modification.
    ...    2. Configuration:
    ...           cell id=1 pci=16:2 tdd_cell=on nr_arfcn=518580:518580 gscn=6480 band=n41 chbw=60M
    ...           cell id=2 pci=17:0 tdd_cell=on nr_arfcn=518598:518598 gscn=6486 band=n41 chbw=60M
    ...           cell id=11 pci=20:0 tdd_cell=off nr_arfcn=344000:424000 gscn=5300 band=n66 chbw=60M
    ...           cell id=12 pci=20:1 tdd_cell=off nr_arfcn=136620:127420 gscn=1592 band=n71 chbw=10M
    ...           cell id=13 pci=20:2 tdd_cell=off nr_arfcn=348000:428000 gscn=5350 band=n66 chbw=60M
    ...           cell id=14 pci=21:0 tdd_cell=off nr_arfcn=136620:127420 gscn=1592 band=n71 chbw=10M
    ...       Configure nrrel Relations:
    ...           cell2-cell11, cell2-cell12, cell2-cell13
    ...    3. Test Case Steps:
    ...       1). UE81 attaches to TDD cell2 and sends A1 MR with Entry condition for SCell Addition
    ...           High DL data rate starts for UE81 and buffer overflow happens at DU, UE81 in TFFF CA status.
    ...           Trigger scell bad RLQ for cell13, after sCellDeactivationBadRlqCount * sCellChannelEstimationPeriod ms
    ...           cell13 deactivated.The DU sends private unacknowledged F1AP message to CU for Scell cell13 release.
    ...           And the reason for the release request is bad-rlq.In this step, Scell cell13 will stay in the blacklist for 30s.
    ...       2). Operator online reconfigures NRBTS.sCellBlacklistTimerFr1= 120 second and new parameters committed.
    ...           Trigger scell bad RLQ for cell11 and cell12, after sCellDeactivationBadRlqCount * sCellChannelEstimationPeriod ms
    ...           cell11 and cell12 deactivated.The DU sends private unacknowledged F1AP message to CU for Scell cell11 and cell12 release.
    ...           And the reason for the release request is bad-rlq.In this step, Scell cell11 and cell12 will stay in the blacklist for 120s.
    ...           Trigger A1 MR with Entry condition for UE81 for SCell Addition.
    ...           High DL data rate starts for UE81 and buffer overflow happens at DU, since cell13 is out of black list,
    ...           cell11 and cell12 are in black list, then UE81 will configurate cell13 as scell.
    ...       3). UE82 attaches to TDD cell2 and sends A1 MR with Entry condition for SCell Addition
    ...           High DL data rate starts for UE82 and buffer overflow happens at DU, UE82 in TFFF CA status.
    ...           Trigger scell bad RLQ for cell13, after sCellDeactivationBadRlqCount * sCellChannelEstimationPeriod ms
    ...           cell13 deactivated.The DU sends private unacknowledged F1AP message to CU for Scell cell13 release.
    ...           And the reason for the release request is bad-rlq.In this step, Scell cell13 will stay in the blacklist for 120s.
    ...       4). Operator online reconfigures NRBTS.sCellBlacklistTimerFr1= 0 second and new parameters committed.
    ...           Trigger scell bad RLQ for cell11 and cell12, after sCellDeactivationBadRlqCount * sCellChannelEstimationPeriod ms
    ...           cell11 and cell12 deactivated.The DU sends private unacknowledged F1AP message to CU for Scell cell11 and cell12 release.
    ...           And the reason for the release request is bad-rlq.In this step, Scell cell11 and cell12 will stay in the blacklist for 0s.
    ...           Trigger A1 MR with Entry condition for UE82 for SCell Addition.
    ...           High DL data rate starts for UE82 and buffer overflow happens at DU, since cell13 are still in black list,
    ...           UE82 will configurate cell11 and cell12 as scell.
    [Tags]    QC_279050    owner-Sherry.zhang    C022    CA_LABEL-TFFF(60MHz_TDD_n41+10MHz_FDD_n66+10MHz_FDD_n71+20MHz_FDD_n66)
    C022 Step1 UE81 in TFFF CA status
    C022 Step2 online change then trigger bad RLQ to 2CC
    C022 Step3 UE82 in TFFF CA status
    C022 Step4 online change then trigger bad RLQ to 3CC
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}a2a_C022${/}a2a.ini    wait_string=UEContextReleaseComplete::3

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

C011 Step1 UEs in FT CA status
    OnlineParamChange    ${parameter_C011}
    UE81 UE82 in FT CA status
    UE83 UE84 in FT CA status

UE81 UE82 in FT CA status
    Update UE capa    ${SA_Capa_Support}    81
    UE Attach To Target Cell    cell_id=11    ue_id=81
    Send Throuput    ue_id=81
    Verify Throughput CA    ue_id=81    maxDLindex=2    dl=320    ul=40
    Update UE capa    ${SA_Capa_Support}    82
    UE Attach To Target Cell    cell_id=11    ue_id=82
    Send Throuput    ue_id=82
    Verify Throughput CA    ue_id=82    maxDLindex=2    dl=180    ul=20

UE83 UE84 in FT CA status
    Update UE capa    ${SA_Capa_Support}    83
    UE Attach To Target Cell    cell_id=11    ue_id=83
    Send Throuput    ue_id=83
    Verify Throughput CA    ue_id=83    maxDLindex=2    dl=110    ul=15
    Update UE capa    ${SA_Capa_Support}    84
    UE Attach To Target Cell    cell_id=11    ue_id=84
    Send Throuput    ue_id=84
    Verify Throughput CA    ue_id=84    maxDLindex=2    dl=90    ul=10

C011 Step2 Trigger scell bad RLQ for UEs one by one
    Trigger scell bad RLQ for scell    profile_id=2    scell_id=1    ue_id=81
    Trigger scell bad RLQ for scell    profile_id=2    scell_id=1    ue_id=82
    Trigger scell bad RLQ for scell    profile_id=2    scell_id=1    ue_id=83
    Trigger scell bad RLQ for scell    profile_id=2    scell_id=1    ue_id=84

C011 Step3 UEs remain in non CA status
    Verify no Scell add    ue_id=81
    Verify no Scell add    ue_id=82
    Verify no Scell add    ue_id=83
    Verify no Scell add    ue_id=84

C020 Step1 UE attach to cell12
    OnlineParamChange    ${parameter_C020}
    Update UE capa    ${SA_Capa_Support}    81
    UE Attach To Target Cell    cell_id=12    ue_id=81
    Trigger ScellAdd    carrierfreq=127450
    Send Throuput    ue_id=81
    Verify Throughput CA    ue_id=81    maxDLindex=3    dl=320    ul=10

C020 Step2 online change actSCellReleaseBadSCellRlq
    OnlineParamChange    ${actSCellReleaseBadSCellRlq_enable}
    Trigger scell bad RLQ for scell    ue_id=81    scell_id=2

C020 Step3 Trigger A1 MR for SCell change
    sleep    20s     #Waiting for sCellInactivityReleaseTimer expire
    Trigger ScellAdd    carrierfreq=127450
    Verify Throughput CA    ue_id=81    maxDLindex=3    dl=100    ul=10

C020 Step4 Trigger scell bad RLQ for cell11
    Trigger scell bad RLQ for scell    ue_id=81    scell_id=2
    Verify no Scell add

C022 Step1 UE81 in TFFF CA status
    OnlineParamChange    ${parameter_C022}
    Update UE capa    ${SA_Capa_Support}    81
    UE Attach To Target Cell    cell_id=2    ue_id=81
    Trigger ScellAdd    carrierfreq=518910    ue_id=81
    Send Throuput    ue_id=81
    Verify Throughput CA    ue_id=81    maxDLindex=4    dl=320    ul=90
    Trigger scell bad RLQ for scell    ue_id=81    scell_id=3

C022 Step2 online change then trigger bad RLQ to 2CC
    OnlineParamChange    ${sCellBlacklistTimerFr1_120}
    Trigger scell bad RLQ for scell    ue_id=81    scell_id=1
    Trigger scell bad RLQ for scell    ue_id=81    scell_id=2
    Trigger ScellAdd    carrierfreq=518910    ue_id=81
    Verify Throughput CA    ue_id=81    maxDLindex=2    dl=320    ul=90

C022 Step3 UE82 in TFFF CA status
    Update UE capa    ${SA_Capa_Support}    82
    UE Attach To Target Cell    cell_id=2    ue_id=82
    Trigger ScellAdd    carrierfreq=518910    ue_id=82
    Send Throuput    ue_id=82
    Verify Throughput CA    ue_id=82    maxDLindex=4    dl=320    ul=50
    Trigger scell bad RLQ for scell    ue_id=82    scell_id=3

C022 Step4 online change then trigger bad RLQ to 3CC
    OnlineParamChange    ${sCellBlacklistTimerFr1_0}
    Trigger scell bad RLQ for scell    ue_id=82    scell_id=1
    Trigger scell bad RLQ for scell    ue_id=82    scell_id=2
    Trigger ScellAdd    carrierfreq=518910    ue_id=82
    Verify Throughput CA    ue_id=82    maxDLindex=4    dl=270    ul=50

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell
    [Arguments]    ${cell_id}=2    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Trigger scell bad RLQ for scell
    [Arguments]    ${profile_id}=2    ${scell_id}=3    ${ue_id}=81
    Trigger scell bad RLQ       profile_id=${profile_id}    scell_id=${scell_id}    ue_id=${ue_id}
    sleep    15s     #Waiting for bad PLQ activate
    Recover scell bad RLQ       profile_id=${profile_id}    scell_id=${scell_id}    ue_id=${ue_id}

Trigger scell bad RLQ
    [Arguments]    ${profile_id}=2    ${scell_id}=3    ${ue_id}=81
    Execute Egate Command    bler_testmode_nr profile_id=${profile_id} target_mcs=0 num_dl_pkts=10000
    ...    pass_regexp=CTRL_AP_GEN_TESTMODE_NR
    ${cmd}    Catenate    ue_testmode_set_nr id=${ue_id} scell=${scell_id} testmode=bler action=activate profile_id=${profile_id}
    Execute Egate Command    ${cmd}    pass_regexp=SCellIndex ${scell_id} deactivated successfully at airphone.

Recover scell bad RLQ
    [Arguments]    ${profile_id}=2    ${scell_id}=3    ${ue_id}=81
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} scell=${scell_id} testmode=bler action=deactivate profile_id=${profile_id}
    ...    pass_regexp=CTRL_AP_UE_TESTMODE_SET_NR
    Execute Egate Command    bler_testmode_nr delete=true profile_id=${profile_id}
    ...    pass_regexp=CTRL_AP_GEN_TESTMODE_NR

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=50 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=100 trf_id=4    UE ${ue_id}: UDP UL

Verify no Scell add
    [Arguments]    ${ue_id}=81    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0] *0 *0 *0
    Should Not Match Regexp    ${scell_tput}    CellIndex-[1]
    Should Be True    ${dl_throughput}/1000>${Tput_dl}

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

Verify Throuput on Pcell and three Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=5    ${index1}=1    ${scell_dl1}=5    ${index2}=2    ${scell_dl2}=5
    ...    ${index3}=3    ${scell_dl3}=5
    sleep    15s     #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${index1}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl1}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${index2}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl2}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${index3}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl3}

Verify Throuput on Pcell and one Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=5    ${scell_id}=1    ${scell_dl}=5    ${ul}=3
    sleep    15s     #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pcell and two Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=5    ${index1}=1    ${scell_dl1}=5    ${index2}=2    ${scell_dl2}=5    ${ul}=5
    sleep    15s     #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${index1}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl1}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${index2}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl2}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Show Scell PDSCH And PUSCH Throughput
    [Arguments]    ${ue_id}=81
    sleep    15s    #wait trf stable
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0 *0
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0 *0

Verify Throughput CA
    [Arguments]    ${ue_id}=81    ${maxDLindex}=4    ${maxULindex}=1    ${dl}=315    ${ul}=10
    BuiltIn.Log    UE${ue_id} Verify Throughput CA...    console=${True}
    Show Scell PDSCH And PUSCH Throughput    ue_id=${ue_id}
    ${dl_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${maxDLindex}
        ${sid}    convert to string    ${id}
        ${result}    ${scell_tput}    Run Keyword And Ignore Error    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${sid}
        ...    type=pdsch    rate_type=ave
        Continue For Loop If    '${result}' == 'FAIL'
        Should Be True    ${scell_tput}/1000 > 0
        ${dl_tput}    Evaluate    ${dl_tput}+${scell_tput}
    END
    Should Be True    ${dl_tput}/1000>${dl}
    ${ul_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${maxULindex}
        ${sid}    convert to string    ${id}
        ${result}    ${scell_tput}    Run Keyword And Ignore Error    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${sid}
        ...    type=pusch    rate_type=ave
        Continue For Loop If    '${result}' == 'FAIL'
        Should Be True    ${scell_tput}/1000 > 0
        ${ul_tput}    Evaluate    ${ul_tput}+${scell_tput}
    END
    Should Be True    ${ul_tput}/1000>${ul}
