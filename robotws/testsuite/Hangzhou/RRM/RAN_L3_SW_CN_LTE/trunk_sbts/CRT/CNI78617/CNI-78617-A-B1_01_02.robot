*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO    team-DevHZ5_SG1
...               owner-feng.2.chen     release-SBTS22R3
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_EMIL}
...    0x7654
...    0x7699
...    0x769A
...    0x769B
...    0x76B4
...    0x76B5
...    0x7509
...    0x750A
...    0x233C
...    0x45C4
...    0x400E
...    0X400F
@{PARAMS_IN_SCF}
...    @{LTE4088}
...    @{LTE4193}
...    @{LNRELGNBCELL}
...    @{CNI_78617}
...    @{otherrelation}
...    @{cus_relation}
@{CNI_78617}
...    LNBTS-1:maxNumNrCellgNB=2
...    LNBTS-1:actX2gNB128=true
...    LNBTS-1:maxNumNrCell=10

@{LNRELGNBCELL}
...    LNBTS/LNADJGNB-1:adjGnbId=7
...    LNBTS/LNADJGNB-1:adjGnbIdLength=22
...    LNBTS/LNADJGNB-2:adjGnbId=8
...    LNBTS/LNADJGNB-2:adjGnbIdLength=22
...    LNBTS-1/LNADJGNB-1:administrativeState=unlocked
...    LNBTS-1/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNBTS-1/LNADJGNB-2:administrativeState=locked
...    LNBTS-1/LNADJGNB-2:cPlaneIpAddr=10.0.1.12

...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=115969    #gNB7 cell 501
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2

...    LNCEL-1/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-2:nrCellId=115970    #gNB7 cell 502
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2

...    LNCEL-1/LNRELGNBCELL-3:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-3:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-3:nrCellId=115984    #gNB7 cell 510
...    LNCEL-1/LNRELGNBCELL-3:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-3:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-3:nrCgiPlmnId:mncLength=2

...    LNCEL-2/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-1:nrCellId=115969    #gNB7 cell 501
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2

...    LNCEL-2/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-2:nrCellId=132356    #gNB8 cell 504
...    LNCEL-2/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL-2/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL-2/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2

...    LNCEL-2/LNRELGNBCELL-3:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-3:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-3:nrCellId=132357    #gNB8 cell 505
...    LNCEL-2/LNRELGNBCELL-3:nrCgiPlmnId:mcc=262
...    LNCEL-2/LNRELGNBCELL-3:nrCgiPlmnId:mnc=3
...    LNCEL-2/LNRELGNBCELL-3:nrCgiPlmnId:mncLength=2

...    LNCEL-3/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-3/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-3/LNRELGNBCELL-1:nrCellId=115969    #gNB7 cell 501
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2

...    LNCEL-3/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-3/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-3/LNRELGNBCELL-2:nrCellId=132356    #gNB8 cell 504
...    LNCEL-3/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL-3/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL-3/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2

...    LNCEL-3/LNRELGNBCELL-3:gnbIdLength=22
...    LNCEL-3/LNRELGNBCELL-3:lteNrDualConnectAllowed=allowed
...    LNCEL-3/LNRELGNBCELL-3:nrCellId=132357    #gNB8 cell 505
...    LNCEL-3/LNRELGNBCELL-3:nrCgiPlmnId:mcc=262
...    LNCEL-3/LNRELGNBCELL-3:nrCgiPlmnId:mnc=3
...    LNCEL-3/LNRELGNBCELL-3:nrCgiPlmnId:mncLength=2

...    LNCEL-3/LNRELGNBCELL-4:gnbIdLength=22
...    LNCEL-3/LNRELGNBCELL-4:lteNrDualConnectAllowed=allowed
...    LNCEL-3/LNRELGNBCELL-4:nrCellId=132358    #gNB8 cell 506
...    LNCEL-3/LNRELGNBCELL-4:nrCgiPlmnId:mcc=262
...    LNCEL-3/LNRELGNBCELL-4:nrCgiPlmnId:mnc=3
...    LNCEL-3/LNRELGNBCELL-4:nrCgiPlmnId:mncLength=2

...    LNCEL-4/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-4/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-4/LNRELGNBCELL-1:nrCellId=115970    #gNB7 cell 502
...    LNCEL-4/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-4/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-4/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2

...    LNCEL-3/LNRELGNBCELL-5:gnbIdLength=22
...    LNCEL-3/LNRELGNBCELL-5:lteNrDualConnectAllowed=allowed
...    LNCEL-3/LNRELGNBCELL-5:nrCellId=115971    #gNB7 cell 503
...    LNCEL-3/LNRELGNBCELL-5:nrCgiPlmnId:mcc=262
...    LNCEL-3/LNRELGNBCELL-5:nrCgiPlmnId:mnc=3
...    LNCEL-3/LNRELGNBCELL-5:nrCgiPlmnId:mncLength=2

...    LNCEL-3/LNRELGNBCELL-6:gnbIdLength=22
...    LNCEL-3/LNRELGNBCELL-6:lteNrDualConnectAllowed=allowed
...    LNCEL-3/LNRELGNBCELL-6:nrCellId=132359    #gNB8 cell 507
...    LNCEL-3/LNRELGNBCELL-6:nrCgiPlmnId:mcc=262
...    LNCEL-3/LNRELGNBCELL-6:nrCgiPlmnId:mnc=3
...    LNCEL-3/LNRELGNBCELL-6:nrCgiPlmnId:mncLength=2

@{LTE4088}
...    LNBTS-1:actLteNrDualConnectivity=true
...    LNBTS-1:tLteNrDualConnectPrep=5000
...    LNBTS-1:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
@{LTE4193}
...    LNBTS-1:actDynTrigLteNrDualConnectivity=true
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS-1/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS-1/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS-1/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS-1/NRDCDPR-0:tPeriodicPhr=50sf
...    LNBTS-1/NRDCDPR-0:tProhibitPhr=0sf

...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:nrPciNbrRelAddThresh=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:nrPciNbrRelRemThresh=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=66
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${F1}
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=258
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrq=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=30kHz
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=0
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=0

...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:nrPciNbrRelAddThresh=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:nrPciNbrRelRemThresh=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=66
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=${F1}
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=48
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrq=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=30kHz
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc1|quantityConfigId=1
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc1|quantityConfigId=1

...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-2:nrPciNbrRelAddThresh=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-2:nrPciNbrRelRemThresh=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-2:b1ThresholdNrRsrp=66
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-2:carrierFreqNrCell=${SSB7_2}
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-2:freqBandIndicatorNrL:freqBandIndicatorNr=48
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-2:ssbSubcarrierSpacing=30kHz

...    LNBTS-1/NRDCPR-1:dynTriggerLteNrDcConfList:method=coverageBased|lcrId=1
...    LNBTS-1/NRDCPR-1:dynTriggerLteNrDcConfList:actB1NrBeamMeas=false|lcrId=1
...    LNBTS-1/NRDCPR-1:dynTriggerLteNrDcConfList:method=coverageBased|lcrId=2
...    LNBTS-1/NRDCPR-1:dynTriggerLteNrDcConfList:actB1NrBeamMeas=false|lcrId=2

...    LNBTS-1/NRDCPR-1:enDCpMaxEUTRApowerOffset=0
...    LNBTS-1/NRDCPR-1:enDCpMaxNRpowerOffset=0

...    LNBTS-1/NRDCPR-1/ENDCMEASCONF-0:b1ThresholdNrRsrp=66
...    LNBTS-1/NRDCPR-1/ENDCMEASCONF-0:carrierFreqNrCell=${SSB7_2}
...    LNBTS-1/NRDCPR-1/ENDCMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=48
...    LNBTS-1/NRDCPR-1/ENDCMEASCONF-0:ssbSubcarrierSpacing=30kHz

...    LNBTS-1/NRDCPR-1/ENDCMEASCONF-1:b1ThresholdNrRsrp=66
...    LNBTS-1/NRDCPR-1/ENDCMEASCONF-1:carrierFreqNrCell=${F1}
...    LNBTS-1/NRDCPR-1/ENDCMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=48|priority=1
...    LNBTS-1/NRDCPR-1/ENDCMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=77|priority=0
...    LNBTS-1/NRDCPR-1/ENDCMEASCONF-1:ssbSubcarrierSpacing=30kHz

...    LNBTS-1/NRDCPR-1/ENDCMEASCONF-2:b1ThresholdNrRsrp=66
...    LNBTS-1/NRDCPR-1/ENDCMEASCONF-2:carrierFreqNrCell=${F1}
...    LNBTS-1/NRDCPR-1/ENDCMEASCONF-2:freqBandIndicatorNrL:freqBandIndicatorNr=48|priority=1
...    LNBTS-1/NRDCPR-1/ENDCMEASCONF-2:freqBandIndicatorNrL:freqBandIndicatorNr=77|priority=0
...    LNBTS-1/NRDCPR-1/ENDCMEASCONF-2:freqBandIndicatorNrL:freqBandIndicatorNr=78|priority=2
...    LNBTS-1/NRDCPR-1/ENDCMEASCONF-2:ssbSubcarrierSpacing=30kHz

...    LNBTS-1/NRDCPR-2:dynTriggerLteNrDcConfList:lcrId=3
...    LNBTS-1/NRDCPR-2:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS-1/NRDCPR-2:enDCpMaxEUTRApowerOffset=0
...    LNBTS-1/NRDCPR-2:enDCpMaxNRpowerOffset=0


...    LNBTS-1/NRDCPR-2/ENDCMEASCONF-0:b1ThresholdNrRsrp=66
...    LNBTS-1/NRDCPR-2/ENDCMEASCONF-0:carrierFreqNrCell=${F1}
...    LNBTS-1/NRDCPR-2/ENDCMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=48
...    LNBTS-1/NRDCPR-2/ENDCMEASCONF-0:ssbSubcarrierSpacing=30kHz

...    LNBTS-1/NRDCPR-2/ENDCMEASCONF-1:b1ThresholdNrRsrp=66
...    LNBTS-1/NRDCPR-2/ENDCMEASCONF-1:carrierFreqNrCell=${SSB7_1}
...    LNBTS-1/NRDCPR-2/ENDCMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=48
...    LNBTS-1/NRDCPR-2/ENDCMEASCONF-1:ssbSubcarrierSpacing=30kHz

...    LNBTS-1/NRDCPR-2/ENDCMEASCONF-2:b1ThresholdNrRsrp=66
...    LNBTS-1/NRDCPR-2/ENDCMEASCONF-2:carrierFreqNrCell=${FB50}
...    LNBTS-1/NRDCPR-2/ENDCMEASCONF-2:freqBandIndicatorNrL:freqBandIndicatorNr=50
...    LNBTS-1/NRDCPR-2/ENDCMEASCONF-2:ssbSubcarrierSpacing=30kHz

...    LNBTS-1/NRDCPR-2/ENDCMEASCONF-3:b1ThresholdNrRsrp=66
...    LNBTS-1/NRDCPR-2/ENDCMEASCONF-3:carrierFreqNrCell=${F1}
...    LNBTS-1/NRDCPR-2/ENDCMEASCONF-3:freqBandIndicatorNrL:freqBandIndicatorNr=48
...    LNBTS-1/NRDCPR-2/ENDCMEASCONF-3:ssbSubcarrierSpacing=30kHz

...    LNBTS-1/NRDCPR-2/ENDCMEASCONF-4:b1ThresholdNrRsrp=66
...    LNBTS-1/NRDCPR-2/ENDCMEASCONF-4:carrierFreqNrCell=${F1}
...    LNBTS-1/NRDCPR-2/ENDCMEASCONF-4:freqBandIndicatorNrL:freqBandIndicatorNr=48
...    LNBTS-1/NRDCPR-2/ENDCMEASCONF-4:ssbSubcarrierSpacing=30kHz

@{otherrelation}
...    LNBTS-1:actEndcSpidFwd=false
...    LNBTS-1:endcSchedWeightBoostDl=2
...    LNBTS-1:endcSchedWeightBoostUl=2
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNBTS-1:actAmbrModCaTrigger=false
...    LNBTS-1:nrRestrictionOverride=disabled
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=false
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None
@{cus_relation}
...    LNBTS-1:tS1eRABModInd=2000
...    LNBTS-1:actTransmittedBelowGap=false

${ue_eutra_capabilities}
...    SEPARATOR=
...    DD9FF430830008081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C108208
...    0304218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B0820082841051820838410041420
...    82061040105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E
...    0B82E0B82E0B82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F8300000810104406
...    68003E71E00020406080C0E162636383A83F7FC4B5A68190BFCD08750003006D9200004000020973C060BC02404061304D0A1E01BFE000
...    0050000003080044000A1000C010BC01

${ue_nr_capabilities}
...    SEPARATOR=
...    E1000000014F7E0302000001404807060E220C000609B00839F21078004120188004502C2FD010CA1A044083A0C30260220B64
...    80A01000C039F2107800412070701101E407800040400009B89BC09024000000120000040900000400A00C0300C0300D8028020100401180
...    28030100401004600A0040401180280001180280100C03600A0000360272A6F286F2A2B708DD200808000020C300200002830C0080001104
...    1082000064104208000210410809A55334A262B9515DA8AEC4

${ue_eutra_nr_capabilities}
...    SEPARATOR=
...    C10060B71B02004040C180385E0000000FD00000000081B8981002060E2680000103F400000000206E36040081810307134000
...    0101FA0000000010370B0200E8080000303F400000000206E26040081838040000100FD0000000008100800803004809B000804180004020
...    001008000402020040088000201000080404008011800040200010080004020200400840002010100200440001008000402020040080
${F7_1}    636667      #SSB 636704
${F7_2}    636869      #SSB 636896
${F7_3}    636965      #SSB 636992
${F7_4}    639665      #SSB 636992
${F8_1}    641667      #SSB 641696
${F8_2}    641868      #SSB 641888
${F8_3}    641970      #SSB 641984
${F8_4}    641750      #SSB 641792
${F1}    646666
${FB50}    303400

${SSB7_1}    636704
${SSB7_2}    636896
${SSB7_3}    636992
${SSB8_1}    641696
${SSB8_2}    641888
${SSB8_4}    641792    #641764
${gnb7_cell1}    SEPARATOR=
...    {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x501', nr_arfcn: ${F7_1}:${F7_1}}
${gnb7_cell2}    SEPARATOR=
...    {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x502', nr_arfcn: ${F7_2}:${F7_2}}
${gnb7_cell3}    SEPARATOR=
...    {id: 73, technology: nr , tac: 33, pci: '1:0', nrci: '0x503', nr_arfcn: ${F7_3}:${F7_3}, status: disabled}
${gnb7_cell4}    SEPARATOR=
...    {id: 74, technology: nr , tac: 33, pci: '1:1', nrci: '0x510', nr_arfcn: ${F7_4}:${F7_4}, status: disabled}

${gnb8_cell1}    SEPARATOR=
...    {id: 81, technology: nr , tac: 33, pci: '2:1', nrci: '0x504', nr_arfcn: ${F8_1}:${F8_1}}
${gnb8_cell2}    SEPARATOR=
...    {id: 82, technology: nr , tac: 33, pci: '2:2', nrci: '0x505', nr_arfcn: ${F8_2}:${F8_2}}
${gnb8_cell3}    SEPARATOR=
...    {id: 83, technology: nr , tac: 33, pci: '3:0', nrci: '0x506', nr_arfcn: ${F8_3}:${F8_3}}
${gnb8_cell4}    SEPARATOR=
...    {id: 84, technology: nr , tac: 33, pci: '3:1', nrci: '0x507', nr_arfcn: ${F8_4}:${F8_4}, status: disabled}

*** Test Cases ***
CNI78617-A-B1_ET_02_01_SSB frequency of Neighbor NR Cell in band48 is updated during ENDC Configuration Update
    [Documentation]    during ENDC Configuration Update, SSB frequency of Neighbor NR Cell in band48 should update in
    ...    corresponding ENDCMEASCONF
    [Tags]
    Delta Commission Parameters     LNBTS-1/LNADJGNB-1:administrativeState=unlocked
    Delta Commission Parameters     LNBTS-1/LNADJGNB-2:administrativeState=unlocked
    Check the ENDCMEASCONF after gNB8 X2setup
    Delta Commission Parameters     LNBTS-1:maxNumNrCellgNB=3
    Delete gNB7cell1 and add gNB7cell3
    Check the ENDCMEASCONF after ENDC Configuraton Update from gNB7
    Delete gNB8cell1 and add gNB8cell4
    Check the ENDCMEASCONF after ENDC Configuraton Update from gNB8
    Attach UEs and ENDC can establish successfully

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Execute Cmd On Pc    sudo ifconfig eth4:1 add 10.0.2.11
    Setup CUS Env    tl_type=4CELLs_FDD_2Band3_2Band7
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=11    id_type=cus
    Create Enb Alias    gNB_7    enb_id=7    id_type=wts
    Create Enb Alias    gNB_8    enb_id=8    id_type=wts
    Set ue parameters before attach
    Set enb parameters before attach
    
Modify Yaml
    FOR    ${ue_set_id}     IN RANGE    1    11
        Update Yaml    UEs/UE_sets/${ue_set_id}    bearer: 'bearer_set_1'    release: '15'    nea: 'null'    nia: 'null'
    END
    Add Yaml    BASE_STATIONS
    ...      - id: 7
    ...        gnb_id: '0x00007'
    ...        type: simulated
    ...        plmn: '262:03'
    ...        s1u: 10.0.1.11
    ...        x2: 10.0.1.11
    ...        cells:
    ...          - ${gnb7_cell1}
    ...          - ${gnb7_cell2}
    ...          - ${gnb7_cell3}
    ...          - ${gnb7_cell4}
    Add Yaml    BASE_STATIONS
    ...      - id: 8
    ...        gnb_id: '0x00008'
    ...        type: simulated
    ...        plmn: '262:03'
    ...        s1u: 10.0.1.12
    ...        x2: 10.0.1.12
    ...        cells:
    ...          - ${gnb8_cell1}
    ...          - ${gnb8_cell2}
    ...          - ${gnb8_cell3}
    ...          - ${gnb8_cell4}


Set ue parameters before attach
    [Arguments]    ${ue_id}=1-20
    Execute Egate Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Egate Command    ue_param id=${ue_id} nr_supported_bands=78
    Execute Egate Command    ue_param id=${ue_id} nr_supported_bands=48
    Execute Egate Command    ue_param id=${ue_id} nr_supported_bands=258
    Execute Egate Command    ue_cqi_param id=${ue_id} scell=0-3 rank=4 cell=target,current
    Execute Egate Command    ue_change_location id=${ue_id} cell=1 enb=1

Set enb parameters before attach
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true include_reestablish_pdcp=on scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=8 use_nr_ran_cont=true include_reestablish_pdcp=on scg_dl_dist_percent=0
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    Execute Egate Command    enb_timer T_DC_Overall=5000ms

Attach UE
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=${cell_id}
    ${command}    catenate    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Execute Uex Command    ${command}

UE send B1-NR to eNodeB
    [Arguments]    ${ue_id}    ${pci}    ${gNB_id}    ${narfcn}    ${meas_id}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_MeasurementReport(measId eq ${meas_id} and measResultNeighCellListNR-r15 contains (pci-r15 eq ${pci}))
    ...    ${gNB_id}:X2AP_SgNBAdditionRequest
    ...    ${gNB_id}:X2AP_SgNBAdditionRequestAcknowledge
    ...    ${gNB_id}:X2AP_SgNBReconfigurationComplete
    ...    ${gNB_id}:X2AP_SNStatusTransfer
    ...    alias=ENDC_setup_success    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B1_NR phycell_id=${pci} nrsrp=79 nrsrq=66 narfcn=${narfcn}
    Flow Occurred As Expected    alias=ENDC_setup_success


Delete gnb_cell
    [Arguments]    ${cell_id}    ${gNB_id}
    ${command}    catenate    gnb_cell_param id=${cell_id} gnb=${gNB_id} status=disabled
    ${command1}    catenate    endc_conf_update id=${gNB_id} target=1 served_nr_cells_to_delete=${cell_id}
    Execute Egate Command    ${command}
    Execute Egate Command    ${command1}

Add gnb_cell
    [Arguments]    ${cell_id}    ${gNB_id}
    ${command}    catenate    gnb_cell_param id=${cell_id} gnb=${gNB_id} status=enabled
    ${command1}    catenate    endc_conf_update id=${gNB_id} target=1 served_nr_cells_to_add=${cell_id}
    Execute Egate Command    ${command}
    Execute Egate Command    ${command1}

Delete gNB7cell1 and add gNB7cell3
    delete gnb_cell    cell_id=71    gNB_id=7
    add gnb_cell    cell_id=73    gNB_id=7

Delete gNB8cell1 and add gNB8cell4
    Delete gnb_cell    cell_id=81    gNB_id=8
    Add gnb_cell    cell_id=84    gNB_id=8

Check the ENDCMEASCONF after gNB8 X2setup
    Object Should Exist    LNBTS-1/NRDCPR-1/ENDCMEASCONF-0:carrierFreqNrCell=${SSB7_1}
    Object Should Exist    LNBTS-1/NRDCPR-1/ENDCMEASCONF-1:carrierFreqNrCell=${SSB7_2}
    Object Should Exist    LNBTS-1/NRDCPR-1/ENDCMEASCONF-2:carrierFreqNrCell=${SSB8_1}
    Object Should Exist    LNBTS-1/NRDCPR-2/ENDCMEASCONF-0:carrierFreqNrCell=${SSB8_1}
    Object Should Exist    LNBTS-1/NRDCPR-2/ENDCMEASCONF-1:carrierFreqNrCell=${SSB7_1}
    Object Should Exist    LNBTS-1/NRDCPR-2/ENDCMEASCONF-2:carrierFreqNrCell=${FB50}
    Object Should Exist    LNBTS-1/NRDCPR-2/ENDCMEASCONF-3:carrierFreqNrCell=${SSB8_2}
    Object Should Exist    LNBTS-1/NRDCPR-2/ENDCMEASCONF-4:carrierFreqNrCell=${F1}

Check the ENDCMEASCONF after ENDC Configuraton Update from gNB7
    Object Should Exist    LNBTS-1/NRDCPR-1/ENDCMEASCONF-0:carrierFreqNrCell=${SSB8_2}    #modify
    Object Should Exist    LNBTS-1/NRDCPR-1/ENDCMEASCONF-1:carrierFreqNrCell=${SSB7_2}
    Object Should Exist    LNBTS-1/NRDCPR-1/ENDCMEASCONF-2:carrierFreqNrCell=${SSB8_1}
    Object Should Exist    LNBTS-1/NRDCPR-2/ENDCMEASCONF-0:carrierFreqNrCell=${SSB8_1}
    Object Should Exist    LNBTS-1/NRDCPR-2/ENDCMEASCONF-1:carrierFreqNrCell=${SSB7_3}    #modify
    Object Should Exist    LNBTS-1/NRDCPR-2/ENDCMEASCONF-2:carrierFreqNrCell=${FB50}
    Object Should Exist    LNBTS-1/NRDCPR-2/ENDCMEASCONF-3:carrierFreqNrCell=${SSB8_2}
    Object Should Exist    LNBTS-1/NRDCPR-2/ENDCMEASCONF-4:carrierFreqNrCell=${F1}

Check the ENDCMEASCONF after ENDC Configuraton Update from gNB8
    Object Should Exist    LNBTS-1/NRDCPR-1/ENDCMEASCONF-0:carrierFreqNrCell=${SSB8_2}
    Object Should Exist    LNBTS-1/NRDCPR-1/ENDCMEASCONF-1:carrierFreqNrCell=${SSB7_2}
    Object Should Exist    LNBTS-1/NRDCPR-1/ENDCMEASCONF-2:carrierFreqNrCell=${SSB8_1}    #not modify
    Object Should Exist    LNBTS-1/NRDCPR-2/ENDCMEASCONF-0:carrierFreqNrCell=${SSB8_4}    #modify
    Object Should Exist    LNBTS-1/NRDCPR-2/ENDCMEASCONF-1:carrierFreqNrCell=${SSB7_3}
    Object Should Exist    LNBTS-1/NRDCPR-2/ENDCMEASCONF-2:carrierFreqNrCell=${FB50}
    Object Should Exist    LNBTS-1/NRDCPR-2/ENDCMEASCONF-3:carrierFreqNrCell=${SSB8_2}
    Object Should Exist    LNBTS-1/NRDCPR-2/ENDCMEASCONF-4:carrierFreqNrCell=${F1}

ENDC establish for UE
    [Arguments]    ${ue_id}    ${cell_id}    ${gNB_id}    ${narfcn}    ${pci}    ${meas_id}
    Attach UE    ue_id=${ue_id}    cell_id=${cell_id}
    UE send B1-NR to eNodeB    ue_id=${ue_id}    gNB_id=${gNB_id}    narfcn=${narfcn}    meas_id=${meas_id}    pci=${pci}

Attach UEs and ENDC can establish successfully
    ENDC establish for UE    ue_id=1    cell_id=1    gNB_id=gNB_7    narfcn=${SSB7_2}    meas_id=18    pci=2    #gNB7,iphy_pci=2,meas_id=18
    ENDC establish for UE    ue_id=2    cell_id=2    gNB_id=gNB_8    narfcn=${SSB8_2}    meas_id=17    pci=8    #gNB8,iphy_pci=2,meas_id=17
    ENDC establish for UE    ue_id=3    cell_id=3    gNB_id=gNB_8    narfcn=${SSB8_4}    meas_id=17    pci=10    #gNB8,iphy_pci=4,meas_id=17
    ENDC establish for UE    ue_id=4    cell_id=3    gNB_id=gNB_7    narfcn=${SSB7_3}    meas_id=18    pci=3    #gNB7,iphy_pci=3,meas_id=18
    ENDC establish for UE    ue_id=5    cell_id=3    gNB_id=gNB_8    narfcn=${SSB8_2}    meas_id=19    pci=8    #gNB8,iphy_pci=2,meas_id=19
    ENDC establish for UE    ue_id=6    cell_id=4    gNB_id=gNB_7    narfcn=${SSB7_2}    meas_id=18    pci=2    #gNB7,iphy_pci=2,meas_id=18


