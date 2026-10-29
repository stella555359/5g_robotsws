#!/bin/bash

# 0.	Check that the MCU is ready
(echo "tag -0r sys.hwapi.online"; sleep 1) | telnet localhost 15007

# 1.	Enable clock towards BB cards (note, no need to enable to all if there is only one or two cards present)
echo 1 > /dev/ddal/clock/board_00/CG03/bbx1_rp1clk30m72_en
echo 1 > /dev/ddal/clock/board_00/CG03/bbx2_rp1clk30m72_en
echo 1 > /dev/ddal/clock/board_00/CG03/bbx3_rp1clk30m72_en
echo 1 > /dev/ddal/clock/board_00/CG04/bbx1_rp1burst_en
echo 1 > /dev/ddal/clock/board_00/CG04/bbx2_rp1burst_en
echo 1 > /dev/ddal/clock/board_00/CG04/bbx3_rp1burst_en

# 2.	Trigger Oscillator object to start warmup related procedures
# Pre-requisite: Should be executed prior the "Set common BCN with GPS" commands
# Return status: EOperationStatus_OK on success
/opt/hwmt/python/sendommessage.sh -s 0x04dc -d HWASYNC-1/OSCILLATOR-1 --proto SYNC/oscillator -t update --args enable=true
sleep 5
# Probe the last one command
/opt/hwmt/python/sendommessage.sh -s 0x04dc -d HWASYNC-1/OSCILLATOR-1 --proto SYNC/oscillator -t query
# --------------------
# enable: true
# oscillatorWarmUp: EOscillatorWarmUp_NotPerformed
# oscillatorFreqStabilizationPeriod: 30
# ocxoControlValue: 1941
# outerOvenMaxTemp: 85
# calibrationDataStatus: ECalibrationDataStatus_Ok
# outerOvenStatus: EOuterOvenStatus_Ok
# oscillatorStatus: EOscillatorStatus_WarmUpPerformed
# sensorStatus: ESensorStatus_Undefined
# --------------------

# 3.	Enable tuner
# Enable tuner
/opt/hwmt/python/sendommessage.sh -s 0x04dc -d HWASYNC-1/TUNER-1 --proto SYNC/tuner -t update --args enable=1
sleep 5
# Probe the last one command
/opt/hwmt/python/sendommessage.sh -s 0x04dc -d HWASYNC-1/TUNER-1 --proto SYNC/tuner -t query referenceClocksList

# --------------------
# enable: true
# referenceClocksList {
#   source: ESource_Pps
#   status: EStatus_Available
# }
# ...
# selectedClockSource: ESelectedClockSource_None
# tuningMode: ETuningMode_None
# tuningVariant: ETuningVariant_None
# localPhaseError: 0.0
# syncHubRole: ESyncHubRole_Master
# calibrationUpdateAllowed: ECalibrationUpdateAllowed_True
# clockCalibrationStatus: EClockCalibrationStatus_NotStarted
# hpfUpdateAllowed: EhpfUpdateAllowed_True
# maxFreqErrorDiffInBuffer: 4
# minFreqErrorValueInBuffer: 130
# --------------------

# 4.	Enable GNSS
# 4.1	Get GNNS interface
/opt/hwmt/python/sendommessage.sh -s 0x04cb -d HWAGNSS-1 --proto GNSS/hwagnss -t query
# 4.2	Enable GNSS from GPS device
# Don't forget to set both Major and Minor parameters with the feedback of the last one command
/opt/hwmt/python/sendommessage.sh -s 0x04cb -d HWAGNSS-1 --proto GNSS/hwagnss -t update --args versionMajor=18:versionMinor=0:enable=true
# Probe the last one command
/opt/hwmt/python/sendommessage.sh -s 0x04cb -d HWAGNSS-1 --proto GNSS/hwagnss -t query

# --------------------
# versionMajor: 18
# versionMinor: 0
# enable: true
# --------------------

# 5.	Wait here that GNSS get operational
/opt/hwmt/python/sendommessage.sh -s 0x04cb -d HWAGNSS-1/DEVICE-1 --proto GNSS/device -t execute --action setEnable --args enable=1
# Probe the last one command
/opt/hwmt/python/sendommessage.sh -s 0x04cb -d HWAGNSS-1/DEVICE-1 --proto GNSS/device -t query

# --------------------
# hwType: "FYGM"
# hwVersion: "3042"
# hwSerial: "1745000538"
# swVersion {
#   swVersionMajor: "2"
#   swVersionMinor: "41"
#   buildNumber: "0"
# }
# protocol: "TSIP"
# enable: true
# portType: EPortType_ExtSyncIn
# ppsRefPropagationDelay: 4.90000009537
# --------------------

# 6.	Set common BCN and start tuning
# 6.1	Set common BCN with GPS
/opt/hwmt/python/sendommessage.sh -s 0x04db -d HWATIME-1/CONFIG-1 --proto TIME/config -t execute --action setCommonBcn --args commonBcnSource=2:commonBcnAlignmentMode=1:phaseMode=0
# Probe the last one command
/opt/hwmt/python/sendommessage.sh -s 0x04db -d HWATIME-1/CONFIG-1 --proto TIME/config -t query
# --------------------
# dayLightSavingStatus: EDayLightSavingStatus_Undefined
# timeDifferenceThreshold: 200
# cdmaSystemTimeMode: ECdmaSystemTimeMode_Undefined
# cdmaSystemTimeValidity: ECdmaSystemTimeValidity_Invalid
# cdmaMaxDrifting: 10
# commonBcnStatus: EStatus_Ok
# userProvidedUtcGpsOffset: 0
# commonBcnSource: ECommonBcnSource_GnssSyncIn
# btsRtcTimeStatus: EBtsRtcTimeStatus_Undefined
# btsRtcValidity: EBtsRtcValidity_NotSet
# gsmFclkFnFrameBurstInternalAdjustment: EGsmFclkFnFrameBurstInternalAdjustment_Undefined
# btsRtcSource: EBtsRtcSource_NotSet
# bcnTimeError: 0
# configuredTimeError: 0
# commonBcnAlignmentMode: ECommonBcnAlignmentMode_NetworkLevelPhaseSync
# bcnDistributionStatus: EBcnDistributionStatus_Undefined
# phaseMode: EPhaseMode_Accurate
# --------------------

/opt/hwmt/python/SendOMMessage.py -s 0x04dc -d HWASYNC-1/TUNER-1 --proto SYNC/tuner -t execute --action startTuning --args clockSource=1:mode=2:variant=1
sleep 30
# Probe the last one command
# Waiting the transition ETuningVariant_Coarse -> ETuningVariant_Normal
/opt/hwmt/python/SendOMMessage.py -s 0x04dc -d HWASYNC-1/TUNER-1 --proto SYNC/tuner -t query
# --------------------
# enable: true
# referenceClocksList {
#   source: ESource_Pps
#   status: EStatus_Available
# }
# ...
# selectedClockSource: ESelectedClockSource_Pps
# tuningMode: ETuningMode_Phase
# tuningVariant: ETuningVariant_Normal
# localPhaseError: -12.970432653
# phaseError: -12.970432653
# frequencyDeviation: 0.267741501331
# syncHubRole: ESyncHubRole_Master
# calibrationUpdateAllowed: ECalibrationUpdateAllowed_True
# clockCalibrationStatus: EClockCalibrationStatus_NotStarted
# hpfUpdateAllowed: EhpfUpdateAllowed_True
# maxFreqErrorDiffInBuffer: 4
# minFreqErrorValueInBuffer: 130
# --------------------

# 7.	Initialize BTS RTC
# 7.1	Initialize BTS RTC with GPS
/opt/hwmt/python/sendommessage.sh -s 0x04db -d HWATIME-1/CONFIG-1 --proto TIME/config -t execute --action initializeBtsRtc --args btsRtcSource=1
# Probe the last one command
/opt/hwmt/python/sendommessage.sh -s 0x04db -d HWATIME-1/CONFIG-1 --proto TIME/config -t query
# --------------------
# dayLightSavingStatus: EDayLightSavingStatus_Undefined
# timeDifferenceThreshold: 200
# cdmaSystemTimeMode: ECdmaSystemTimeMode_Undefined
# cdmaSystemTimeValidity: ECdmaSystemTimeValidity_Invalid
# cdmaMaxDrifting: 10
# commonBcnStatus: EStatus_Ok
# utcGpsOffset: 18
# userProvidedUtcGpsOffset: 0
# commonBcnSource: ECommonBcnSource_GnssSyncIn
# btsRtcTimeStatus: EBtsRtcTimeStatus_Ok
# referenceBtsRtc {
#   bcn: 2059289299727279740
#   axxiaTime: 0
#   utcSeconds: 1543396854
#   utcMicroseconds: 0
# }
# btsRtcValidity: EBtsRtcValidity_NotSet
# gsmFclkFnFrameBurstInternalAdjustment: EGsmFclkFnFrameBurstInternalAdjustment_Undefined
# btsRtcSource: EBtsRtcSource_GnssSyncIn
# bcnTimeError: 0
# configuredTimeError: 0
# commonBcnAlignmentMode: ECommonBcnAlignmentMode_NetworkLevelPhaseSync
# bcnDistributionStatus: EBcnDistributionStatus_Undefined
# phaseMode: EPhaseMode_Accurate
# --------------------

# 8.	Add nodes ID  !!!!!!!!!!!  PUT YOUR TARGET NODE ID  !!!!!!!!!!!!!!!!!!!
# Get all nodes status
/opt/hwmt/python/sendommessage.sh -s 0x04db -d HWATIME-1/NODECONFIG-1 --proto TIME/nodeconfig -t query nodesList
# 8.0 	Remove all nodes ID if they have been added before
#      To get loner node is syscomctl node_id list
DMID=$(ddal -s ddal_sysinfo_module_get_domain_id 0)
DMID=${DMID:25}

/opt/hwmt/python/sendommessage.sh -s 0x04db -d HWATIME-1/NODECONFIG-1 --proto TIME/nodeconfig -t execute --action removeNode --args nodeId=0x${DMID}011
/opt/hwmt/python/sendommessage.sh -s 0x04db -d HWATIME-1/NODECONFIG-1 --proto TIME/nodeconfig -t execute --action removeNode --args nodeId=0x${DMID}021
/opt/hwmt/python/sendommessage.sh -s 0x04db -d HWATIME-1/NODECONFIG-1 --proto TIME/nodeconfig -t execute --action removeNode --args nodeId=0x${DMID}23d
/opt/hwmt/python/sendommessage.sh -s 0x04db -d HWATIME-1/NODECONFIG-1 --proto TIME/nodeconfig -t execute --action removeNode --args nodeId=0x${DMID}24d
/opt/hwmt/python/sendommessage.sh -s 0x04db -d HWATIME-1/NODECONFIG-1 --proto TIME/nodeconfig -t execute --action removeNode --args nodeId=0x${DMID}25d


# 8.1 	Add nodes ID
/opt/hwmt/python/sendommessage.sh -s 0x04db -d HWATIME-1/NODECONFIG-1 --proto TIME/nodeconfig -t execute --action addNode --args nodeId=0x${DMID}011:moduleVersion="":nodeType=0
/opt/hwmt/python/sendommessage.sh -s 0x04db -d HWATIME-1/NODECONFIG-1 --proto TIME/nodeconfig -t execute --action addNode --args nodeId=0x${DMID}021:moduleVersion="":nodeType=0
/opt/hwmt/python/sendommessage.sh -s 0x04db -d HWATIME-1/NODECONFIG-1 --proto TIME/nodeconfig -t execute --action addNode --args nodeId=0x${DMID}23d:moduleVersion="":nodeType=0
/opt/hwmt/python/sendommessage.sh -s 0x04db -d HWATIME-1/NODECONFIG-1 --proto TIME/nodeconfig -t execute --action addNode --args nodeId=0x${DMID}24d:moduleVersion="":nodeType=0
/opt/hwmt/python/sendommessage.sh -s 0x04db -d HWATIME-1/NODECONFIG-1 --proto TIME/nodeconfig -t execute --action addNode --args nodeId=0x${DMID}25d:moduleVersion="":nodeType=0


# 9.	Check that loner node is synchronized
# Get all nodes status
/opt/hwmt/python/sendommessage.sh -s 0x04db -d HWATIME-1/NODECONFIG-1 --proto TIME/nodeconfig -t query nodesList

