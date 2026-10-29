*** Settings ***
Documentation
...    author:  dandan.chen@nokia-sbell.com
...    contact: dandan.chen@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_BOO_AP_LOO
...            owner-Tingjian.Mao    team-CN1ET    release-SBTS24R3
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_IPHY_XML}    fddFrequencyRange=FR1_WB

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_8224}
...    @{PowerSaving}
...    @{Xn_link}
...    @{PARAMS_FOR_CA}
...    @{large_fdd_cell}
...    @{CB007552_CB008541}
...    @{1630_enable}
...    @{5GC000740_flag}
@{CB007552_CB008541}
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true


@{large_fdd_cell}
#n66    40Mhz    25Mhz
...    NRCELL-13/NRCELL_FDD-1:nrarfcnDl=430900
...    NRCELL-13/NRCELL_FDD-1:nrarfcnUl=348920
...    NRCELL-13/NRCELL_FDD-1:chBwDl=40MHz
...    NRCELL-13:gscnOrSsPbchArfcn=5384
#n71    20Mhz    15Mhz
#...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=126900
#...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136100
#...    NRCELL-12/NRCELL_FDD-1:chBwDl=20MHz
#...    NRCELL-12:gscnOrSsPbchArfcn=1584
#n71    15Mhz
...    NRCELL-14/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-14/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL-14/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-14:gscnOrSsPbchArfcn=1584

@{1630_enable}
...    NRBTS-1:actRanSharing=true
...    delete:NRBTS-1/NRCELL:configuredEpsTac
...    delete:NRBTS-1/NRCELL:trackingAreaDN
...    MRBTS-1/NRBTS-1/NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    MRBTS-1/NRBTS-1/NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL/NRPLMNSET_NSA-1:nrPlmnSetNsaId=1
...    MRBTS-1/NRBTS-1/NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL/NRPLMNSET_SA-1:nrPlmnSetSaId=1
...    MRBTS-1/NRBTS-1/NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200

@{PARAMS_FOR_8224}
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-4
#...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-2
#...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-4
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-3:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-4

...    NRCELL-11/NRCELL_FDD-1:nrarfcnDl=144500
...    NRCELL-11/NRCELL_FDD-1:nrarfcnUl=144500
...    NRCELL-11/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-11:gscnOrSsPbchArfcn=1804
...    NRCELL-11:freqBandIndicatorNR=29
...    NRCELL-11:type0CoresetConfigurationIndex=2

...    NRCELL-11:nrCellType=2DL0UL
...    NRCELL-11:cellBarred=barred
...    NRCELL-11:intraFreqReselection=notAllowed
...    MRBTS-1/NRBTS-1/NRCELL-11/NRCELL_FDD-1:chBwUl=0MHz

#...    NRCELL-12:nrCellType=2DL0UL
#...    NRCELL-12:cellBarred=barred
#...    NRCELL-12:intraFreqReselection=notAllowed
#...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwUl=0MHz

...    NRCELL-13:nrCellType=2DL0UL
...    NRCELL-13:cellBarred=barred
...    NRCELL-13:intraFreqReselection=notAllowed
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwUl=0MHz
...    NRCELL-14:nrCellType=2DL0UL
...    NRCELL-14:cellBarred=barred
...    NRCELL-14:intraFreqReselection=notAllowed
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:chBwUl=0MHz

...    NRCELL-13:administrativeState=Locked
...    NRCELL-14:administrativeState=Locked
...    NRCELL-11:administrativeState=Locked
#...    NRCELL-12:administrativeState=Locked

${CaSup}    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl,ca_Fdd_Fr1Tdd_Sa_WithUl

@{PARAMS_FOR_CA}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS-1:actCarrierAggregation=true
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:carrierAggregationSupportList=${CaSup}
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRBTS:maxNumScellsDl=4
...    NRBTS:maxNumScellsUl=1
...    NRCELL:maxNumScellsDlFr1=4
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms

...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=1
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=forbidden
...    NRCELL-1/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:nrDcAllowed=false
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3

...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=1
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=forbidden
...    NRCELL-1/NRREL-12:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:nrDcAllowed=false
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3

...    NRCELL-1/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-13:gNbId=1
...    NRCELL-1/NRREL-13:gNbIdLength=22
...    NRCELL-1/NRREL-13:handoverAllowedSA=forbidden
...    NRCELL-1/NRREL-13:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-13:lcrId=13
...    NRCELL-1/NRREL-13:nrDcAllowed=false
...    NRCELL-1/NRREL-13:removeNotAllowed=false
...    NRCELL-1/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-13:gnbPlmn:mncLength=3

...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=forbidden
...    NRCELL-1/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:nrDcAllowed=false
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3

...    NRCELL-2:nrarfcn=634400
...    NRCELL-2:gscnOrSsPbchArfcn=7857

@{PowerSaving}
...    NRBTS:actNrLBPowerSaving=true
...    NRBTS:actCoordinated4g5gPowerSaving=cellDeactivation
...    NRBTS/NRPGRP-10:lbpsCSONCtlEnabled=true
...    NRBTS/NRPGRP-10:lbpsLastCellMinLoad=20
...    NRBTS/NRPGRP-10:lbpsLastCellRTXMinLoad=10
...    NRBTS/NRPGRP-10:lbpsLastCellSOEnabled=true
...    NRBTS/NRPGRP-10:lbpsMaxLoad=60
...    NRBTS/NRPGRP-10:lbpsMinLoad=20
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOff=120
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOn=120
...    NRBTS/NRPGRP-10:lbpsPdcchLoadOffset=4
...    NRBTS/NRPGRP-10:lbpsRTXCellCapOffset=80
...    NRBTS/NRPGRP-10:lbpsRTXMaxLoad=60
...    NRBTS/NRPGRP-10:lbpsRTXMinLoad=20
...    NRBTS/NRPGRP-10:lbpsRTXSOffTime=300
...    NRBTS/NRPGRP-10:lbpsRTXSOnTime=120
...    NRBTS/NRPGRP-10:lbpsSOMethod=cell switch off
...    NRBTS/NRPGRP-10:lbpsCellList:lbpsCellSOOrder=70|nrCellId=1
...    NRPGRP-10:lbpsPeriodList:lbpsDuration=35|lbpsDayOfWeek=Wed
...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeHour=8|lbpsDayOfWeek=Wed
...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeMinute=20|lbpsDayOfWeek=Wed
...    NRBTS:x2EnDcCfUpRspTmr=3
...    NRBTS:maxX2EnDcCfUpRetry=3
...    NRBTS:x2EnDcCfUpRdmDelayTmr=3
...    NRBTS:xnNgRanCfUpRdmDelayTmr=3
...    NRBTS:actLbpsCtrlLogicEnh=true
...    NRBTS/NRPGRP-10:lbpsLoadCalcMethod=Max(G, C, P)
...    NRBTS/NRPGRP-10:lbpsSOnTrRule=MinValueMethod
...    NRBTS/NRPGRP-10:lbpsSOffTrRule=MaxValueMethod

@{5GC000740_flag}
...    NRBTS-1:actNgcFlexSaMode=true
...    SERVEDAMF-1:amfIPAddress=10.0.1.1
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:defaultAMF=true
...    SERVEDAMF-1:administrativeState=Unlocked
...    SERVEDAMF-2:amfIPAddress=10.0.1.102
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=true
...    SERVEDAMF-2:administrativeState=Unlocked
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    NRPLMN-2:mcc=311
...    NRPLMN-2:mnc=402
...    NRPLMN-2:mncLength=3
...    NRPLMN-3:mcc=311
...    NRPLMN-3:mnc=404
...    NRPLMN-3:mncLength=3
...    SNSSAI-1:administrativeState=Unlocked
...    SNSSAI-1:sd=13714341
...    SNSSAI-1:sst=1
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-2:administrativeState=Unlocked
...    SNSSAI-2:sd=13714342
...    SNSSAI-2:sst=1
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST_2}
...    SNSSAI-3:administrativeState=Unlocked
...    SNSSAI-3:sd=13714343
...    SNSSAI-3:sst=1
...    SNSSAI-3:nrPlmnDNList=${NRPLMNDNLIST_3}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=5min
...    MRBTS-1/NRBTS-1:ngUeRetentionEnabled=false
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=240
...    MRBTS-1/NRBTS-1:srbInactivityTimerSA=600
...    NRBTS:drbInactivityTimerSA=600

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1
${NRPLMNDNLIST_2}    MRBTS-1/NRBTS-1/NRPLMN-2
${NRPLMNDNLIST_3}    MRBTS-1/NRBTS-1/NRPLMN-3

@{PARAMS_FOR_8224_lock}
...    NRCELL-13:administrativeState=Unlocked     #Sunil will provide the IMprovment
...    NRCELL-14:administrativeState=Unlocked
...    NRCELL-11:administrativeState=Unlocked     #Sunil will provide the IMprovment


@{cellDepType_SA}
...    NRBTS-1/NRCELL-11:cellDepType=SA
...    delete:NRCELL-11/NRPLMNSET_NSA-1

@{cellDepType_NSA}
...    NRBTS-1/NRCELL-11:cellDepType=NSA
...    delete:NRCELL-11/NRPLMNSET_SA-1

@{cellDepType_MIX}
...    NRBTS-1/NRCELL-11:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-11/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1

@{cellDepType_MIX_R}
...    NRBTS-1/NRCELL-11:cellDepType=SA+NSA
...    NRCELL-11/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL-11/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200

@{Xn_link}
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.1.122
...    NRBTS/XNLINK-1:cPlaneIpAddrCtrl=oamControlled
...    NRBTS:actIncXn=true

@{LOCKX2LINK}
...    NRBTS-1/LTEENB-0:x2LinkLock=locked

@{UNLOCKX2LINK}
...    NRBTS-1/LTEENB-0:x2LinkLock=unlocked

${Lock_AMF1}    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Locked
${Lock_AMF2}    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Locked
${Unlock_AMF1}    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked
${Unlock_AMF2}    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
#X2 fault
${7107_fault_name}    Cell problem due to unavailability of associated links
${7107_fault_id}    7107
${7114_alarm_id}    7114

@{5CC_DL_2CC_UL_CHECK}
...    pcid:61, scellIdx:3] configure_1_1
...    pcid:61, scellIdx:3] configure_0_1
...    pcid:62, scellIdx:4] configure_1_1
...    pcid:60, scellIdx:2] configure_1_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:51, scellIdx:1] configure_1_1

${5CC_DL_2CC_UL_N29}    SEPARATOR=
...    FFA0F200475F7A6B5F83820660034005DC01001012083E6010124098031FFF800140F804060380950FC28DF981A150452CB2A204817BFF303
...    9036FFFB7FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FFB7FFDBFFEDFFF6FFFB7FFDBFFEDFFF51804DFE7FEDFE7FE2140028015B3
...    00078003300078000150FC41DF981A150452CB2A204817BFF3039036FFFB7FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FFB7FFDBF
...    FEDFFF6FFFB7FFDBFFEDFFF51804DFE7FEDFE7FE2140028015B300078003300078000150FC4DDF981A150452CB2A204817BFF3039036FFFB7
...    FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FFB7FFDBFFEDFFF6FFFB7FFDBFFEDFFF51804DFE7FEDFE7FE2140028015B3000780033
...    00078000150781CDF981A150452CB2A204817BFF3039036FFFB7FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FFB7FFDBFFEDFFF6FF
...    FB7FFDBFFEDFFF51804DFE7FE214002800B3300078001507C46DF981A150452CB2A204816BFF3039036FFFB7FFDBFFEDFFF6FFFB7FFDBFFE7
...    FFFA7FFDF1F9F87FC7FF77FFDBFFEDFFF6FFFB7FFDBFFEA3004DFE7FEDFE7FE2140028015B300078003300078000006A2F13400389A001C28
...    000C0E01C41000E230000002B7E0000000040E26800001FE000000028BC18000E20800710400388C001C4D000E268000022B7E00000000014
...    018809B01183501280E04FC0FF5EDC09F81FEBDB813F03FD7B6003818C63FDFFFFF84E00F800F000C0705807800703F09801E001806BB82C0
...    2C00380D770580580070200100000008004000000DE00C88000001644000002A00B066F2A68064F000029659427800054B2CA1200004A5965
...    490000352CB2A01A8345D2A8AA557541AE8045010040080401002010040080400801010020040400801000802006501002004040080101002
...    00404008010100400804010020B41280

*** Test Cases ***
CB008224-ET-B004_SA_SDL_Band_FDD_Band_Intra_Gnb_Ca_CB009855_5CC_DL_2CC_UL_CA_BbMOD_Reset
    [Documentation]
    ...    1. This user scenario intends to verify that newly introduced 3T + 2F / 2T + 3F DL CA would work as expected
    ...       together with T+F UL 2CC CA.
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                                 Cell-1    Cell-1    Cell-11    Cell-12    Cell-13    Cell-14
    ...    Technology                    TDD      TDD       FDD         FDD       FDD        FDD
    ...          Band                    n41      n78       n29         n71       n66        n71
    ...           Pci                     50       51       60          61        62         63
    ...     Bandwidth                     60       50       10          20        40         15
    ...         Arfcn                   518580    633372    144550    126900    430900    126900
    ...        LCELNR                   DL/UL     DL/UL      DL         DL        DL        DL
    ...    maxNumOfUsersPerNRCell     all cells are 275
    ...    maxNumOfSCellAlloc         all cells are 250
    ...    weightForSCellSelection    all cells are 50
    ...    2. Test Case Steps:
    ...           a. Ue register and pdu session setup
    ...           b. UE send A1 to add CA and Send Throughput
    ...           c. Reset BBMODs
    ...           d. Repetition step a to b
    ...    4. Expected Results:
    ...           a. Ue register and pdu session setup successfully
    ...           b. DL 5CC UL 2CC and Traffic successfully
    ...           c. Reset BBMODs successfully
    ...           d. The result conforms to the prefetching
    [Tags]    B004    QC_348965
    unlock SDL cell
    Check UE DL 5CC UL 2CC and Traffic is normal
    lock SDL cell
    Reset BBMODs
    unlock SDL cell
    Release Ues    ue_type=all
    Check cells on Air
    Check SDL cells on Air
    Check UE DL 5CC UL 2CC and Traffic is normal
    Release Ues    ue_type=all

CB008224-ET-A008_Cell_management_5GC000900_5GC001630
    [Documentation]
    ...    1. This user scenario validates that an SDL cell is up and running in the n75 SDL band and that no UE can camp
    ...       on this SDL cell as the cell is barred.
    ...       Note: There is not yet user traffic in this scenario.
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                                 Cell-1    Cell-1    Cell-11    Cell-12    Cell-13    Cell-14
    ...    Technology                    TDD      TDD       FDD         FDD       FDD        FDD
    ...          Band                    n41      n78       n29         n71       n66        n71
    ...           Pci                     50       51       60          61        62         63
    ...     Bandwidth                     60       50       10          20        40         15
    ...         Arfcn                   518580    633372    144550    126900    430900    126900
    ...        LCELNR                   DL/UL     DL/UL      DL         DL        DL        DL
    ...    maxNumOfUsersPerNRCell     all cells are 275
    ...    maxNumOfSCellAlloc         all cells are 250
    ...    weightForSCellSelection    all cells are 50
    ...    2. Test Case Steps:
    ...           a. Lock AMF1 and Lock x2 link
    ...           b. X2 setup first, then NG setup later
    ...           c. Lock AMF1 and Lock x2 link
    ...           d. NG setup first, then X2 setup later
    ...           e. online change Nrcell-11 from mixed mode to SA mode then to NSA mode then back to mixed mode,
    ...               TrackingAreaDN and EPSTAC updated accordingly.
    ...    4. Expected Results:
    ...           a. Check X2 Link Alarm and cell state successfully
    ...           b. ALL CELL state on air
    ...           c. Check X2 Link Alarm and cell state successfully
    ...           d. ALL CELL state on air
    ...           e. Check F1,X2,NG,Xn interface msg flows. and NRCELL-11 on air
    [Tags]    A008    QC_46906
    unlock SDL cell
    verification SDL CELL state X2 AMF LOCK UNLOCK
    verification SDL CELL state cellDepType change
    recovery AMF

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_n29

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${5CC_DL_2CC_UL_N29}
    Update Cfg    set_amf_region id=1 tac_list=200 plmn=311:489
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1 name=SimModeAMF1
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=1 set_id=2 pointer=2 name=SimModeAMF2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 ue=all amf=1-2 default=on
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1-2
    Update Cfg    set_nwslice id=3 snssai=0x01:0xd143a7 ue=all amf=1-2
    Update Cfg    amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc
    update cfg    amf_ng_setup_param id=1 relative_capacity=100 include_backup_amf_name=on
    update cfg    amf_ng_setup_param id=2 relative_capacity=100
    update cfg    set_backup_amf main=1 backup_amfs=2
    Update Cfg    set_qosflow id=2 5qi=7 default=off
    Update Cfg    set_qosflow id=3 5qi=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    ${Update_Cfg_Cell_11}    Catenate
    ...    set_cell id=11 gnb=2 pci=20:0 tac=200 nrci=0x0B tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=144500:144500
    ...    gscn=1804 mandatory_for_activation=off is_fr1sdl_cell=on
    ${Update_Cfg_Cell_12}    Catenate
    ...    set_cell id=12 gnb=2 pci=20:1 tac=200 nrci=0x0C tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=136100:126900
    ...    gscn=1584 mandatory_for_activation=off is_fr1sdl_cell=on
    ${Update_Cfg_Cell_13}    Catenate
    ...    set_cell id=13 gnb=2 pci=20:2 tac=200 nrci=0x0D tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=348920:430900
    ...    gscn=5384 mandatory_for_activation=off is_fr1sdl_cell=on
    ${Update_Cfg_Cell_14}    Catenate
    ...    set_cell id=14 gnb=2 pci=21:0 tac=200 nrci=0x0E tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=136100:126900
    ...    gscn=1584 mandatory_for_activation=off is_fr1sdl_cell=on
    ${Update_Cfg_Cell_2}    Catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=634400:634400
    ...    gscn=7857 mandatory_for_activation=off
    Update Cfg    ${Update_Cfg_Cell_11}
    Update Cfg    ${Update_Cfg_Cell_12}
    Update Cfg    ${Update_Cfg_Cell_13}
    Update Cfg    ${Update_Cfg_Cell_14}
    Update Cfg    ${Update_Cfg_Cell_2}

verification SDL CELL state X2 AMF LOCK UNLOCK
    Make both AMF1 and X2 in LOCK state        #lock AMF1 ,ENB1
    Lock AMF2                                  #lock AMF2
    Check Alarm and cell state                 #critical 7107
    lock SDL cell                              #lock sdl cell    8224 workaround
    Unlock AMF2                                #unlock AMF2, CELL ON AIR, MAJOR 7107
    unlock SDL cell                            #unlock sdl cell    8224 workaround
    Unlock X2 Link                             #unlock enb1, 7107 cleared
    Unlock AMF1                                #unlock AMF1
    Make both AMF1 and X2 in LOCK state        #lock AMF1 ,ENB1
    Lock AMF2                                  #lock AMF2
    Check Alarm and cell state                 #critical 7107
    lock SDL cell                              #lock sdl cell    8224 workaround
    Unlock X2 Link    severity=Critical        #unlock X2, CELL ON AIR, MAJOR 7107
    unlock SDL cell
    Unlock AMF1
    Check Alarm Cleared                        #unlock AMF1, 7107 Cleared
    Unlock AMF2

verification SDL CELL state cellDepType change
    OnlineParamChange    ${cellDepType_SA}
    Lock X2 Link
    Check X2 Link Alarm and cell11 state on air
    Unlock X2 Link
    OnlineParamChange    ${cellDepType_MIX}
    OnlineParamChange    ${cellDepType_NSA}
    Lock AMF1
    Lock AMF2
    Check cell11 state on air

recovery AMF
    Unlock AMF1
    Unlock AMF2
    OnlineParamChange    ${cellDepType_MIX_R}

Make both AMF1 and X2 in LOCK state
    Lock AMF1
    Lock X2 Link
    Check X2 Link Alarm and cell state

Check UE DL 5CC UL 2CC and Traffic is normal
    Ue register and pdu session setup
    UE send A1 to add DL 5CC UL 2CC
    Send Throughput
    Check Traffic

lock SDL cell
    lock cell11
    lock cell13
    lock cell14

unlock SDL cell
    unlock cell11
    unlock cell13
    unlock cell14

OnlineParamChange
    [Arguments]    ${Online_Param}
    lock SDL cell
    Delta Commission Parameters    ${Online_Param}
    wait until keyword succeeds    5 min    60 sec    Check cells on Air
    unlock SDL cell
    wait until keyword succeeds    5 min    60 sec    Check SDL cells on Air

Check cells on Air
    Cells Should Be Onair    cell_id=1    check_sib=${True}    timeout=600
    Cells Should Be Onair    cell_id=2    check_sib=${True}    timeout=600
    Cells Should Be Onair    cell_id=12    check_sib=${True}    timeout=600

Check SDL cells on Air
    Cells Should Be Onair    cell_id=13    check_sib=${False}    timeout=600
    Cells Should Be Onair    cell_id=11    check_sib=${False}    timeout=600
    Cells Should Be Onair    cell_id=14    check_sib=${False}    timeout=600

Lock X2 Link
    Delta Commission Parameters    ${LOCKX2LINK}

Check X2 Link Alarm and cell state
    ${fault7107}    Create List    fault_id=${7107_fault_id}    alarm_id=${7114_alarm_id}    severity=Major
    ...    fault_name=${7107_fault_name}
    Fm Fault Should Be Raised    ${fault7107}    5min
    Check cell state as expected    operationalState=enabled    barringStatus=unbarred    availabilityStatus=degraded

Check Alarm and cell state
    ${fault7107}    Create List    fault_id=${7107_fault_id}    alarm_id=${7114_alarm_id}    severity=Critical
    ...    fault_name=${7107_fault_name}
    Fm Fault Should Be Raised    ${fault7107}    5min
    Check cell state as expected    operationalState=disabled    barringStatus=unbarred    availabilityStatus=failed

Check X2 Link Alarm and cell11 state on air
    ${fault7107}    Create List    fault_id=${7107_fault_id}    alarm_id=${7114_alarm_id}    severity=Major
    ...    fault_name=${7107_fault_name}
    Fm Fault Should Be Raised    ${fault7107}    5min
    Object Should Exist    NRCELL-11:barringStatus=unbarred
    Object Should Not Exist    NRCELL-11:availabilityStatus=${EMPTY}

Check cell11 state on air
    Object Should Exist    NRCELL-11:barringStatus=unbarred
    Object Should Not Exist    NRCELL-11:availabilityStatus=${EMPTY}

Check cell state as expected
    [Arguments]    ${operationalState}    ${barringStatus}    ${availabilityStatus}
    Object Should Exist    NRCELL:operationalState=${operationalState}
    Object Should Exist    NRCELL:barringStatus=${barringStatus}
    Object Should Exist    NRCELL:availabilityStatus=${availabilityStatus}

Unlock X2 Link
    [Arguments]    ${severity}=Major
    ${fault7107}    Create List    fault_id=${7107_fault_id}    alarm_id=${7114_alarm_id}    severity=${severity}
    ...    fault_name=${7107_fault_name}
    Delta Commission Parameters    ${UNLOCKX2LINK}
    Execute Egate Command    enb_x2_link_up enb=1 target=2    pass_regexp=is up    timeout=120
    Fm Fault Should Be Cleared    ${fault7107}    5min
    Object Should Not Exist    NRCELL:availabilityStatus=${EMPTY}

Check Alarm Cleared
    ${fault7107}    Create List    fault_id=${7107_fault_id}    alarm_id=${7114_alarm_id}    severity=Major
    ...    fault_name=${7107_fault_name}
    Fm Fault Should Be Cleared    ${fault7107}    5min
    Object Should Not Exist    NRCELL:availabilityStatus=${EMPTY}

Lock AMF1
    delta commission parameters    ${Lock_AMF1}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Inactive

Lock AMF2
    delta commission parameters    ${Lock_AMF2}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Inactive

Unlock AMF1
    delta commission parameters    ${Unlock_AMF1}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active

Unlock AMF2
    delta commission parameters    ${Unlock_AMF2}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active

Ue register and pdu session setup
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${enb}=2    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    amf_ue_pdu_setup_param id=1 reset
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${pass_regexp}

UE send A1 to add DL 5CC UL 2CC
    [Arguments]    ${ue_id}=1    ${cellfreq}=518910
    ${A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${A1} event=A1 srsrq_nr=70 srsrp_nr=90
    ...    pass_regexp=@{5CC_DL_2CC_UL_CHECK}

Send Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=dl mbps=170 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=dl mbps=170 trf_id=2    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=dl mbps=170 trf_id=3    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=dl mbps=170 trf_id=4    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=ul mbps=170 trf_id=1    pass_regexp=Started Uplink
    sleep    15s    #Flow stability

Check Traffic
    [Arguments]    ${ue_id}=1    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${Pcell_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${Pcell_tput}/1000 > 10
    ${Scell1_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${Scell1_Tput}/1000 > 10
    ${Scell2_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${Scell2_Tput}/1000 > 10
    ${Scell3_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pdsch    rate_type=ave
    Should Be True    ${Scell3_Tput}/1000 > 10
    ${Scell4_Tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=4    type=pdsch    rate_type=ave
    Should Be True    ${Scell4_Tput}/1000 > 10
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000> 10
    ${ul_throughput2}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput2}/1000> 10

Reset BBMODs
    [Arguments]    ${str_bbmods_list}=null
    ${bbmods_list}    string.split string    ${str_bbmods_list}
    ${coam_conn}    taf.sbts.oam.coam.admin.Connect To
    ${fbb_info}=    taf.sbts.oam.coam.admin.Get fbb info    connection=${coam_conn}
    FOR    ${fbb}    IN    @{fbb_info}
        taf.sbts.oam.coam.admin.Reset Unit    ${fbb['id']['internal']}    reset_type=Warm    timeout=${300}    connection=${coam_conn}
    END
   [Teardown]    taf.sbts.oam.coam.admin.Teardown    ${coam_conn}
