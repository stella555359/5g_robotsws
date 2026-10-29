from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
gNbId = tl.gnbs[0].instance_id

PARAMS_IN_SCF = [
       "MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1:actInternalTrace=True",
       "NRBTS-1/NRCELL-2:pucchF1ResOccConf=1-1-0_OCCs",
       "NRBTS-1/NRCELL-2:reqMinNumPuschPrb=1",
       "NRBTS-1/NRCELL-2:actLongPucchResourceOpt=true",
       "NRCELL:numOfRadioResReservForPa=0",
       "NRBTS-1/NRCELL-2:srPeriodicity=slots80",
       "NRBTS-1/NRCELL-1:srPeriodicity=slots80",
       "NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots160",
       "NRBTS-1/NRCELL-2:actAdaptiveSr=true",
       "NRBTS-1/NRCELL-1:actAdaptiveSr=true",
       "NRBTS-1/NRCELL-2:actServiceAwareConfig=false",
       "NRBTS-1/NRCELL-1:actServiceAwareConfig=false",
       "NRBTS-1/NRCELL-2:actDynUlResAllocPhase2=true",
       "NRBTS-1/NRCELL-1:actDynUlResAllocPhase2=true",
       "NRBTS-1/NRCELL-2:actSrAllocOpt=true",
       "NRBTS-1/NRCELL-1:actSrAllocOpt=true",
       "NRBTS-1/NRCELL-2:actDynUlResAlloc=true",
       "NRBTS-1/NRCELL-1:actDynUlResAlloc=true",
       "NRBTS-1/NRCELL-2:srPeriodicityMin=slots10",
       "NRBTS-1/NRCELL-1:srPeriodicityMin=slots10",
       "NRBTS-1/NRCELL-2:adaptiveSrLoadThresholdUp=65",
       "NRBTS-1/NRCELL-1:adaptiveSrLoadThresholdUp=65",
       "NRBTS-1/NRCELL-2:adaptiveSrLoadThresholdDown=40",
       "NRBTS-1/NRCELL-1:adaptiveSrLoadThresholdDown=40",
       "NRBTS-1/NRCELL-2:preferredVoNrSrPeriod=slots40",
       "NRBTS-1/NRCELL-1:preferredVoNrSrPeriod=slots40",
       "NRBTS-1/NRCELL-2:vonrReservation=10",
       "NRBTS-1/NRCELL-1:vonrReservation=10",
       # "NRBTS-1/NRCELL-2:lowLatencyReservation=10",
       # "NRBTS-1/NRCELL-1:lowLatencyReservation=10",
       "NRBTS-1/NRCELL-2:adaptiveSrBlockingMinimization=20",
       "NRBTS-1/NRCELL-1:adaptiveSrBlockingMinimization=20",
       # disable multibwp
       "NRBTS-1:actMultipleDedicatedBWPs=false",
       "NRBTS-1/NRCELL:actEnhMultipleDedicatedBWPs=false",
       "delete:NRCELL-1:cellBwpList:cellBwpId=2",
       "NRBTS-1/NRCELL-1:actPowerSavingBWP=false",
       "NRBTS-1/NRCELL-1:actULSchedInactiveBwp=false",
       "delete:NRCELL-2:cellBwpList:cellBwpId=2",
       "delete:NRCELL-2:cellBwpList:cellBwpId=3",
       "NRBTS-1/NRCELL-2:actPowerSavingBWP=false",
       "NRBTS-1/NRCELL-2:actULSchedInactiveBwp=false",
       "delete:NRCELL-4:cellBwpList:cellBwpId=2",
       "delete:NRCELL-4:cellBwpList:cellBwpId=3",
       "NRBTS-1/NRCELL-4:actPowerSavingBWP=false",
       "NRBTS-1/NRCELL-4:actULSchedInactiveBwp=false",
       "delete:NRCELL-6:cellBwpList:cellBwpId=2",
       "delete:NRCELL-6:cellBwpList:cellBwpId=3",
       "NRBTS-1/NRCELL-6:actPowerSavingBWP=false",
       "NRBTS-1/NRCELL-6:actULSchedInactiveBwp=false",
       # change chbw
       "NRBTS-1/NRCELL-2:chBw=80MHz",
       "NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=6291",
       "NRBTS-1/NRCELL-2:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-215",
       "NRBTS-1/NRCELL-2:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-185",
       "NRBTS/BWP_PROFILE-185/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|duration=9",
       "NRBTS/BWP_PROFILE-185/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|duration=1",
       "NRBTS/BWP_PROFILE-185/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=2|duration=1",
       "NRBTS/BWP_PROFILE-185/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|duration=1",
       "NRBTS/BWP_PROFILE-185/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|duration=1",
       "NRBTS/BWP_PROFILE-185/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|duration=3",
       "NRBTS/BWP_PROFILE-185/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=3|duration=3",
       "NRBTS/BWP_PROFILE-185/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|duration=3",
       "NRBTS/BWP_PROFILE-185/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|duration=3",
]


DELTA_PARAS_Lock_Cell = [
    "NRCELL-2:administrativeState=Locked",
    "NRCELL-6:administrativeState=Locked",
]

DELTA_PARAS_UnLock_Cell = [
    "NRCELL-2:administrativeState=Unlocked",
]
