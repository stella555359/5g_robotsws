# RI and RS status detection:
# RI status:NOTDETECTED
echo "grep -Gi \"RI status:NOTDETECTED\"   ===>";grep -Gi "RI status:NOTDETECTED" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
# RI status:SUSPECTED
echo "grep -Gi \"RI status:SUSPECTED\"   ===>";grep -Gi "RI status:SUSPECTED" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
# RI status:DETECTED
echo "grep -Gi \"RI status:DETECTED\"   ===>";grep -Gi "RI status:DETECTED" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
echo "grep -Gi \"remoteInterferenceDetected\":true\"   ===>";grep -Gi "remoteInterferenceDetected\":true" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
# RS status:NOTDETECTED
echo "grep -Gi \"RS status:NOTDETECTED\"   ===>";grep -Gi "RS status:NOTDETECTED" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
# RS status:TYPE1
echo "grep -Gi \"RS status:.*TYPE1\"   ===>";grep -Gi "RS status:.*TYPE1" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
# RS status:TYPE2
echo "grep -Gi \"RS status:.*TYPE2\"   ===>";grep -Gi "RS status:.*TYPE2" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
# isRiDetected and isRs1Detected
echo "grep -Gi \"isRiDetected:\s*1.*isRs1Detected:\s*1\"   ===>";grep -Gi "isRiDetected:\s*1.*isRs1Detected:\s*1" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
# isRiDetected and isRs1Detected and isRs2Detected
echo "grep -Gi \"isRiDetected:\s*1.*isRs1Detected:\s*1.*isRs2Detected:\s*1\"   ===>";grep -Gi "isRiDetected:\s*1.*isRs1Detected:\s*1.*isRs2Detected:\s*1" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
#
# Raising fault:
# FID 7525
echo "grep -Gi \"Raising fault RemoteInterferenceDetectAl (id=7525)\"   ===>";grep -Gi "Raising fault RemoteInterferenceDetectAl (id=7525)" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
# FID 7527
echo "grep -Gi \"Raising fault RimRsDetectAndDownlinkMitigationAl (id=7527)\"   ===>";grep -Gi "Raising fault RimRsDetectAndDownlinkMitigationAl (id=7527)" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
# FID 7535
echo "grep -Gi \"Raising fault RimDownlinkMitigationAl (id=7535)\"   ===>";grep -Gi "Raising fault RimDownlinkMitigationAl (id=7535)" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
#
# RimRs PoolingConfig:
echo "grep -Gi \"PoolConfiguration updates actNrRimRsResourcePooling\"   ===>";grep -Gi "PoolConfiguration updates actNrRimRsResourcePooling" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
# 1)	Log  informing about a number of resources allocated by CPRT for BBRM (for the whole L1pool):
echo "grep -Gi \"RimRsPoolingConfig:.*actNrRimRsResourcePooling:[0-1]\"   ===>";grep -Gi "RimRsPoolingConfig:.*actNrRimRsResourcePooling:[0-1]" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
#
# updateState for l1capacity:
echo "grep -Gi \"updateState.*l1capacity:\s*[0-9]\"   ===>";grep -Gi "updateState.*l1capacity:\s*[0-9]" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
#
# RimRsSendReq for RimRs TYPE1
echo "grep -Gi \"RimRsSendReq.*RimRs:TYPE1\"   ===>";grep -Gi "RimRsSendReq.*RimRs:TYPE1" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
#
# Log that introduced printing the whole RimResourceReq in Syslog containing information about requestedMinRimRsResources and requestedMaxRimRsResources  (log under flag L2.L2_PS.RIM.RS_UL):
# maxRsDetectionCapacity <=> l1RsCapacityForNewDetection, minCapacityForRevalidation <=> l1RsCapacityForRevalidation, and new is l1RsCapacityForExtraRevalidation
echo "grep -Gi \"RimResourceReq_t:.*l1RsCapacityFor.*:[1-9]\"   ===>";grep -Gi "RimResourceReq_t:.*l1RsCapacityFor.*:[1-9]" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
#
# RimResourceResp and 0 capacity
# 2) Log informing about a number of resources allocated by BBRM for cell (log under flag L2.L2_PS.RIM.RS_UL):
# echo "grep -Gi \"RimRsL1Capacity.*\[RIM.RS_UL\].*Received RimResourceResp{capacity:\s*0,\"   ===>";grep -Gi "RimRsL1Capacity.*\[RIM.RS_UL\].*Received RimResourceResp{capacity:\s*0," $1/SYSLOG*;echo "   ";echo "   ";echo "   "
# RimResourceResp and capacity not 0
# 2) Log informing about a number of resources allocated by BBRM for cell (log under flag L2.L2_PS.RIM.RS_UL):
echo "grep -Gi \"RimRsL1Capacity.*\[RIM.RS_UL\].*Received RimResourceResp{capacity:\s*[1-9]\"   ===>";grep -Gi "RimRsL1Capacity.*\[RIM.RS_UL\].*Received RimResourceResp{capacity:\s*[1-9]" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
#
# 3) Log informing that cell started using resources allocated by bbrm (log under flag L2.L2_PS.RIM.RS_UL): update not 0
echo "grep -Gi \"RimRsL1Capacity.*\[RIM.RS_UL\].*Update L1 Rs Capacity.*->\s*[1-9]\"   ===>";grep -Gi "RimRsL1Capacity.*\[RIM.RS_UL\].*Update L1 Rs Capacity.*->\s*[1-9]" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
# 4) Log, where we can find how many resources we utilized in particular ulDlSwitchingPeriod:
####echo "grep -Gi \"RimLogger.*\[RIM.RS_UL\].*C:16385.*new detections range.*consumed:\"   ===>";grep -Gi "RimLogger.*\[RIM.RS_UL\].*C:16385.*new detections range.*consumed:" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
# TYPE1 and total number of confirmed setIds not 0:
# echo "grep -Gi \"TYPE1.*total number of confirmed setIds:[1-9]\"   ===>";grep -Gi "TYPE1.*total number of confirmed setIds:[1-9]" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
#
# debug RD counters M55308CRD52002 and M55308CRD52002
echo "grep -Gi \"measurementId = 55308, counterId = 52002\"   ===>";grep -Gi "measurementId = 55308, counterId = 52002" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
echo "grep -Gi \"3624717090, value:[1-9]\"   ===>";grep -Gi "3624717090, value:[1-9]" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
echo "grep -Gi \"measurementId = 55308, counterId = 52003\"   ===>";grep -Gi "measurementId = 55308, counterId = 52003" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
#
# PR835641: SetId detections disappeared due to high RS power drop; for example: signal power is dropped from -82 to -130
echo "grep -Gi \"SetIdLogger.*TYPE1.*will be ignored due to high RS power drop\"   ===>";grep -Gi "SetIdLogger.*TYPE1.*will be ignored due to high RS power drop" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
#
echo "grep -Gi \"l1_application_rt.*fillRimRsRespPsMessage.*ctrlNrUlRim.*peak\"   ===>";grep -Gi "l1_application_rt.*fillRimRsRespPsMessage.*ctrlNrUlRim.*peak" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
# check peak value depending on rdUlPhyRimRsDetectionThreshold (default=20)
echo "grep -Gi \"peak=2[0-9]\.\"   ===>";grep -Gi "peak=2[0-9]\." $1/SYSLOG*;echo "   ";echo "   ";echo "   "
echo "grep -Gi \"peak=5[0-9]\.\"   ===>";grep -Gi "peak=5[0-9]\." $1/SYSLOG*;echo "   ";echo "   ";echo "   "
#
# using L2.L2_PS.RIM.UL_PRB_POOLING flag as well by adding 0x580580=512
echo "grep -Gi \"bbrm allocated total prb\"   ===>";grep -Gi "bbrm allocated total prb" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
