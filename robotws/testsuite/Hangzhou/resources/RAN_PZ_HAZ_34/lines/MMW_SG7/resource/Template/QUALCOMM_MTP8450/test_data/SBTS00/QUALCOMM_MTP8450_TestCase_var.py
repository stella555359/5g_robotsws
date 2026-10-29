from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")
gNbId = tl.gnbs[0].instance_id

Lock_Cell2 = [
 "NRCELL-2:administrativeState=Locked"
]

UnLock_Cell2 = [
 "NRCELL-2:administrativeState=Unlocked"
]

Lock_Cell3 = [
 "NRCELL-3:administrativeState=Locked"
]

UnLock_Cell3 = [
 "NRCELL-3:administrativeState=Unlocked"
]

DELETE_Cell3_NRREL = [
 "delete:NRCELL-3/NRREL"
]

PARAMS_IN_SCF = [
 "NRSYSINFO_PROFILE-1:systemInformationTargetRate=55",
 "NRSYSINFO_PROFILE-2:systemInformationTargetRate=55",
 "NRBTS:actSaUeBasedAnrNr=true",
 "NRBTS:actSaUeBasedInterFreqAnrNr=true",
 "NRBTS:actDedicatedAnrDrxProfile=true",
 "NRBTS:actSaIntraFreqAnrDrxProf=true",
 "NRANR-1:actAutoEutraNbRemoval=false",
 "NRANR-1:actAutoNrNbRemoval=true",
 "NRANR-1:consecHoFailThres=0",
 "NRANR-1:consecHoFailThresEutra=3",
 "NRANR-1:consecXnResolveFailThres=3",
 "NRANR-1:gNbIdLengthConfig:gNbIdLength=32",
 "NRANR-1:gNbIdLengthConfig:priorityIndex=1",
 "NRANR-1:gNbIdLengthConfig:nrPlmnDN=NRPLMN-1",
 "NRANR-1:nrAnrId=1",
 "NRANRPR-1:anrThresholdSelector=RSRP",
 "NRANRPR-1:anrThresRsrpNbCell=-90",
 "NRANRPR-1:anrThresRsrqNbCell=-12",
 "NRANRPR-1:cellDepMode=SA",
 "NRANRPR-1:consecRecheckForNrNbRemoval=5",
 "NRANRPR-1:idleTimeForNrNbRemoval=2",
 "NRANRPR-1:maxNumAnrNrrelAllowed=50",
 "NRANRPR-1:nrAnrPrId=1",
 # -90 dBm is equal to RSRP value of 67 reported by the UE
 "NRANRPR-2:anrThresRsrpNbCell= -90",
 # -12 dB is equal to RSRQ value of 63 reported by the UE
 "NRANRPR-2:anrThresRsrqNbCell= -12",
 "NRANRPR-2:anrThresholdSelector=RSRP",
 "NRANRPR-2:cellDepMode=SA",
 "NRANRPR-2:consecRecheckForNrNbRemoval=5",
 # hours, value: 2 ~ 192
 "NRANRPR-2:idleTimeForNrNbRemoval=2",
 "NRANRPR-2:maxNumAnrNrrelAllowed=10",
 "NRANRPR-2:nrarfcn=125400",
 "NRANRPR-2:ssbFrequency=124350",
 "NRCELL:actCDrx=true",
 "NRCELL:drxProfileNrAnr:drxControl=any",
 "NRCELL:drxProfileNrAnr:drxInactivityTimer=80ms",
 "NRCELL:drxProfileNrAnr:drxLongCycle=320ms",
 "NRCELL:drxProfileNrAnr:drxOnDurationTimer=20ms",
 "NRCELL:drxProfileNrAnr:drxRetransTimerDl=0slot",
 "NRCELL:drxProfileNrAnr:drxRetransTimerUl=0slot",
 "NRCELL:drxProfileNrAnr:nrDrxDN=NRDRX-3",
 "NRDRX-3:drxInactivityTimer=80ms",
 "NRDRX-3:drxLongCycle=320ms",
 "NRDRX-3:drxOnDurationTimer=20ms",
 "NRDRX-3:drxRetransTimerDl=0slot",
 "NRDRX-3:drxRetransTimerUl=0slot"
]
