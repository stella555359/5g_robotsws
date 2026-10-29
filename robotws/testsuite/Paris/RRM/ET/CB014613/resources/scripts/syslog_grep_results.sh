# RI and RS status detection:
# RI status:
echo "grep -Gi \"RI status:\"   ===>";grep -Gi "RI status:" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
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
#
# Raising fault:
# FID 7525
echo "grep -Gi \"FaultNotif.*7525\"   ===>";grep -Gi "FaultNotif.*7525" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
#
# updateState for l1capacity:
echo "grep -Gi \"updateState.*l1capacity:\s*[0-9]\"   ===>";grep -Gi "updateState.*l1capacity:\s*[0-9]" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
#
# RimRsSendReq for RimRs TYPE1
echo "grep -Gi \"RimRsSendReq.*RimRs:TYPE1\"   ===>";grep -Gi "RimRsSendReq.*RimRs:TYPE1" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
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
#
# PR835641: SetId detections disappeared due to high RS power drop; for example: signal power is dropped from -82 to -130
echo "grep -Gi \"SetIdLogger.*TYPE1.*will be ignored due to high RS power drop\"   ===>";grep -Gi "SetIdLogger.*TYPE1.*will be ignored due to high RS power drop" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
#
echo "grep -Gi \"l1_application_rt.*fillRimRsRespPsMessage.*ctrlNrUlRim.*peak\"   ===>";grep -Gi "l1_application_rt.*fillRimRsRespPsMessage.*ctrlNrUlRim.*peak" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
#
# using L2.L2_PS.RIM.UL_PRB_POOLING flag as well by adding 0x580580=512
echo "grep -Gi \"bbrm allocated total prb\"   ===>";grep -Gi "bbrm allocated total prb" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
#
# CB014613: actDynamicRiThresBaseCalc
echo "grep -Gi \"actDynamicRiThresBaseCalc\"   ===>";grep -Gi "actDynamicRiThresBaseCalc" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
# riThresBaseSubband[0-4] 
echo "grep -Gi \"L2-PS.*RemoteInterferenceIndSender.*remoteInterferenceDetected.*nrRiThresBasePerSubband\"   ===>";grep -Gi "L2-PS.*RemoteInterferenceIndSender.*remoteInterferenceDetected.*nrRiThresBasePerSubband" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
# Starting new AutoRiThresBaseCalcTimer
echo "grep -Gi \"Starting new AutoRiThresBaseCalcTimer\"   ===>";grep -Gi "Starting new AutoRiThresBaseCalcTimer" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
# Starting new AutoRiThresBaseCalcTimer
echo "grep -Gi \"L2-PS.*Calculated nrRiThresBasePerSubband\"   ===>";grep -Gi "L2-PS.*Calculated nrRiThresBasePerSubband" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
# Rssi histogram
echo "grep -Gi \"L2-PS.*Rssi histogram\"   ===>";grep -Gi "L2-PS.*Rssi histogram" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
#
# ERR/L2-PS ?
echo "grep -Gi \"ERR.*L2-PS\"   ===>";grep -Gi "ERR.*L2-PS" $1/SYSLOG*;echo "   ";echo "   ";echo "   "
#
echo "grep -Gi \"L2-PS/src/ul/sch/rim/RimLogger.*0;0;0\"   ===>";grep -Gi "L2-PS/src/ul/sch/rim/RimLogger.*0;0;0" $1/SYSLOG*;echo "   ";echo "   ";echo "   "