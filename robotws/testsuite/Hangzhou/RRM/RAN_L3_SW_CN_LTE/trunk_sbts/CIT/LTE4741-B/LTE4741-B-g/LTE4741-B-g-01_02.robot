*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT
...               CLOUD_R4LAPO_CUS    release-FL00    DevHZ5_SG5    owner-kurt.shu
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  LNBTS:actAcBarringRrcConn=CellOnly
...  LNBTS:actAcBarringPlmn=true
...  LNCEL-1/LNCEL_FDD-0:maxNumActUE=195
...  LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrc=200
...  LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrcEmergency=230
...  @{PARAMS_FOR_CATM}
...  @{ACBPRList}
...  @{SIB0}
...  LNCEL-1:acbPrimaryPlmnProfileId=2
...  LNCEL-1:furtherPlmnIdL:acbFurtherPlmnProfileId=4|mnc=4
...  LNCEL-1:furtherPlmnIdL:acbFurtherPlmnProfileId=6|mnc=5
...  LNCEL-1:furtherPlmnIdL:acbFurtherPlmnProfileId=8|mnc=6
...  LNCEL-1:furtherPlmnIdL:acbFurtherPlmnProfileId=10|mnc=7
...  LNCEL-1:furtherPlmnIdL:acbFurtherPlmnProfileId=12|mnc=8
...  LNCEL-1:furtherPlmnIdL:acbFurtherPlmnProfileIdCatM=5|mnc=4
...  LNCEL-1:furtherPlmnIdL:acbFurtherPlmnProfileIdCatM=7|mnc=5
...  LNCEL-1:furtherPlmnIdL:acbFurtherPlmnProfileIdCatM=9|mnc=6
...  LNCEL-1:furtherPlmnIdL:acbFurtherPlmnProfileIdCatM=11|mnc=7
...  LNCEL-1:furtherPlmnIdL:acbFurtherPlmnProfileIdCatM=13|mnc=8
...  LNBTS:actAcBarringACS=true
@{PARAMS_FOR_CATM}
...  LNCEL-1/LNCEL_FDD-0:actCatM=true
...  LNCEL-1/CATMCEL-0:actAcBarringCatM=true
...  LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...  LNBTS/CATMPR-1:inactivityTimerCatM=30
...  LNCEL-1/LNCEL_FDD-0:catMProfId=1
...  LNCEL-1/SIB-0:siWindowLen=40ms
...  LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...  LNCEL-1/CATMCEL-0:acbProfileIdCatM=1
...  LNCEL-1/CATMCEL-0:acbNumStepsCatM=3
...  LNCEL-1/CATMCEL-0:acbPrimaryPlmnProfileIdCatM=3
...  LNCEL-1/CATMCEL-0:acbPlmnNumStepsCatM=2
@{ACBPRList}
...  @{ACBPR0}
...  @{ACBPR1}
...  @{ACBPR2}
...  @{ACBPR3}
...  @{ACBPR4}
...  @{ACBPR5}
...  @{ACBPR6}
...  @{ACBPR7}
...  @{ACBPR8}
...  @{ACBPR9}
...  @{ACBPR10}
...  @{ACBPR11}
...  @{ACBPR12}
...  @{ACBPR13}
@{ACBPR0}
...  LNBTS/ACBPR-0:eCallAcBarredStatic=Not barred
...  LNBTS/ACBPR-0:acBarSigStatic:barTime=8s
...  LNBTS/ACBPR-0:acBarSigStatic:probFac=95%
...  LNBTS/ACBPR-0:acBarOcStatic:barTime=8s
...  LNBTS/ACBPR-0:acBarOcStatic:probFac=95%
...  LNBTS/ACBPR-0:acBarMMTelVoiceOcStatic=${empty}
...  LNBTS/ACBPR-0:acBarMMTelVideoOcStatic=${empty}
...  LNBTS/ACBPR-0:acBarCsfbOcStatic=${empty}
...  LNBTS/ACBPR-0:eCallAcBarredAuto=barred
...  LNBTS/ACBPR-0:acBarSkipForMMTELVideo=true
...  LNBTS/ACBPR-0:acBarSkipForMMTELVoice=true
...  LNBTS/ACBPR-0:acBarSkipForSMS=true
...  LNBTS/ACBPR-0:acBarSigAutoMin:barTime=4s
...  LNBTS/ACBPR-0:acBarSigAutoMin:probFac=95%
...  LNBTS/ACBPR-0:acBarSigAutoMax:barTime=512s
...  LNBTS/ACBPR-0:acBarSigAutoMax:probFac=0%
...  LNBTS/ACBPR-0:acBarOcAutoMin:barTime=4s
...  LNBTS/ACBPR-0:acBarOcAutoMin:probFac=95%
...  LNBTS/ACBPR-0:acBarOcAutoMax:barTime=512s
...  LNBTS/ACBPR-0:acBarOcAutoMax:probFac=0%
...  LNBTS/ACBPR-0:acBarMMTelVoiceOcAutoMin=${empty}
...  LNBTS/ACBPR-0:acBarMMTelVoiceOcAutoMax=${empty}
...  LNBTS/ACBPR-0:acBarMMTelVideoOcAutoMin=${empty}
...  LNBTS/ACBPR-0:acBarMMTelVideoOcAutoMax=${empty}
...  LNBTS/ACBPR-0:acBarCsfbOcAutoMin=${empty}
...  LNBTS/ACBPR-0:acBarCsfbOcAutoMax=${empty}
@{ACBPR1}
...  LNBTS/ACBPR-1:eCallAcBarredStatic=Not barred
...  LNBTS/ACBPR-1:acBarSigStatic:barTime=8s
...  LNBTS/ACBPR-1:acBarSigStatic:probFac=95%
...  LNBTS/ACBPR-1:acBarOcStatic=${empty}
...  LNBTS/ACBPR-1:acBarMMTelVoiceOcStatic=${empty}
...  LNBTS/ACBPR-1:acBarMMTelVideoOcStatic=${empty}
...  LNBTS/ACBPR-1:acBarCsfbOcStatic=${empty}
...  LNBTS/ACBPR-1:eCallAcBarredAuto=barred
...  LNBTS/ACBPR-1:acBarSkipForMMTELVideo=false
...  LNBTS/ACBPR-1:acBarSkipForMMTELVoice=true
...  LNBTS/ACBPR-1:acBarSkipForSMS=true
...  LNBTS/ACBPR-1:acBarSigAutoMin:barTime=4s
...  LNBTS/ACBPR-1:acBarSigAutoMin:probFac=95%
...  LNBTS/ACBPR-1:acBarSigAutoMax:barTime=512s
...  LNBTS/ACBPR-1:acBarSigAutoMax:probFac=0%
...  LNBTS/ACBPR-1:acBarOcAutoMin=${empty}
...  LNBTS/ACBPR-1:acBarOcAutoMax=${empty}
...  LNBTS/ACBPR-1:acBarMMTelVoiceOcAutoMin=${empty}
...  LNBTS/ACBPR-1:acBarMMTelVoiceOcAutoMax=${empty}
...  LNBTS/ACBPR-1:acBarMMTelVideoOcAutoMin=${empty}
...  LNBTS/ACBPR-1:acBarMMTelVideoOcAutoMax=${empty}
...  LNBTS/ACBPR-1:acBarCsfbOcAutoMin=${empty}
...  LNBTS/ACBPR-1:acBarCsfbOcAutoMax=${empty}
@{ACBPR2}
...  LNBTS/ACBPR-2:eCallAcBarredStatic=Not barred
...  LNBTS/ACBPR-2:acBarSigStatic=${empty}
...  LNBTS/ACBPR-2:acBarOcStatic=${empty}
...  LNBTS/ACBPR-2:acBarMMTelVoiceOcStatic=${empty}
...  LNBTS/ACBPR-2:acBarMMTelVideoOcStatic=${empty}
...  LNBTS/ACBPR-2:acBarCsfbOcStatic:barTime=8s
...  LNBTS/ACBPR-2:acBarCsfbOcStatic:probFac=95%
...  LNBTS/ACBPR-2:eCallAcBarredAuto=barred
...  LNBTS/ACBPR-2:acBarSkipForMMTELVideo=false
...  LNBTS/ACBPR-2:acBarSkipForMMTELVoice=false
...  LNBTS/ACBPR-2:acBarSkipForSMS=false
...  LNBTS/ACBPR-2:acBarSigAutoMin=${empty}
...  LNBTS/ACBPR-2:acBarSigAutoMax=${empty}
...  LNBTS/ACBPR-2:acBarOcAutoMin=${empty}
...  LNBTS/ACBPR-2:acBarOcAutoMax=${empty}
...  LNBTS/ACBPR-2:acBarMMTelVoiceOcAutoMin=${empty}
...  LNBTS/ACBPR-2:acBarMMTelVoiceOcAutoMax=${empty}
...  LNBTS/ACBPR-2:acBarMMTelVideoOcAutoMin=${empty}
...  LNBTS/ACBPR-2:acBarMMTelVideoOcAutoMax=${empty}
...  LNBTS/ACBPR-2:acBarCsfbOcAutoMin:barTime=4s
...  LNBTS/ACBPR-2:acBarCsfbOcAutoMin:probFac=95%
...  LNBTS/ACBPR-2:acBarCsfbOcAutoMax:barTime=512s
...  LNBTS/ACBPR-2:acBarCsfbOcAutoMax:probFac=0%
@{ACBPR3}
...  LNBTS/ACBPR-3:eCallAcBarredStatic=Not barred
...  LNBTS/ACBPR-3:acBarSigStatic=${empty}
...  LNBTS/ACBPR-3:acBarOcStatic:barTime=8s
...  LNBTS/ACBPR-3:acBarOcStatic:probFac=95%
...  LNBTS/ACBPR-3:acBarMMTelVoiceOcStatic=${empty}
...  LNBTS/ACBPR-3:acBarMMTelVideoOcStatic=${empty}
...  LNBTS/ACBPR-3:acBarCsfbOcStatic=${empty}
...  LNBTS/ACBPR-3:eCallAcBarredAuto=barred
...  LNBTS/ACBPR-3:acBarSkipForMMTELVideo=false
...  LNBTS/ACBPR-3:acBarSkipForMMTELVoice=false
...  LNBTS/ACBPR-3:acBarSkipForSMS=false
...  LNBTS/ACBPR-3:acBarSigAutoMin=${empty}
...  LNBTS/ACBPR-3:acBarSigAutoMax=${empty}
...  LNBTS/ACBPR-3:acBarOcAutoMin:barTime=4s
...  LNBTS/ACBPR-3:acBarOcAutoMin:probFac=95%
...  LNBTS/ACBPR-3:acBarOcAutoMax:barTime=512s
...  LNBTS/ACBPR-3:acBarOcAutoMax:probFac=0%
...  LNBTS/ACBPR-3:acBarMMTelVoiceOcAutoMin=${empty}
...  LNBTS/ACBPR-3:acBarMMTelVoiceOcAutoMax=${empty}
...  LNBTS/ACBPR-3:acBarMMTelVideoOcAutoMin=${empty}
...  LNBTS/ACBPR-3:acBarMMTelVideoOcAutoMax=${empty}
...  LNBTS/ACBPR-3:acBarCsfbOcAutoMin=${empty}
...  LNBTS/ACBPR-3:acBarCsfbOcAutoMax=${empty}
@{ACBPR4}
...  LNBTS/ACBPR-4:eCallAcBarredStatic=Not barred
...  LNBTS/ACBPR-4:acBarSigStatic=${empty}
...  LNBTS/ACBPR-4:acBarOcStatic=${empty}
...  LNBTS/ACBPR-4:acBarMMTelVoiceOcStatic=${empty}
...  LNBTS/ACBPR-4:acBarMMTelVideoOcStatic:barTime=8s
...  LNBTS/ACBPR-4:acBarMMTelVideoOcStatic:probFac=95%
...  LNBTS/ACBPR-4:acBarCsfbOcStatic=${empty}
...  LNBTS/ACBPR-4:eCallAcBarredAuto=barred
...  LNBTS/ACBPR-4:acBarSkipForMMTELVideo=false
...  LNBTS/ACBPR-4:acBarSkipForMMTELVoice=false
...  LNBTS/ACBPR-4:acBarSkipForSMS=false
...  LNBTS/ACBPR-4:acBarSigAutoMin=${empty}
...  LNBTS/ACBPR-4:acBarSigAutoMax=${empty}
...  LNBTS/ACBPR-4:acBarOcAutoMin=${empty}
...  LNBTS/ACBPR-4:acBarOcAutoMax=${empty}
...  LNBTS/ACBPR-4:acBarMMTelVoiceOcAutoMin=${empty}
...  LNBTS/ACBPR-4:acBarMMTelVoiceOcAutoMax=${empty}
...  LNBTS/ACBPR-4:acBarMMTelVideoOcAutoMin:barTime=4s
...  LNBTS/ACBPR-4:acBarMMTelVideoOcAutoMin:probFac=95%
...  LNBTS/ACBPR-4:acBarMMTelVideoOcAutoMax:barTime=512s
...  LNBTS/ACBPR-4:acBarMMTelVideoOcAutoMax:probFac=0%
...  LNBTS/ACBPR-4:acBarCsfbOcAutoMin=${empty}
...  LNBTS/ACBPR-4:acBarCsfbOcAutoMax=${empty}
...  LNBTS/ACBPR-4:cellResHoBlockPlmnAcbMax=reserved
@{ACBPR5}
...  LNBTS/ACBPR-5:eCallAcBarredStatic=Not barred
...  LNBTS/ACBPR-5:acBarSigStatic=${empty}
...  LNBTS/ACBPR-5:acBarOcStatic=${empty}
...  LNBTS/ACBPR-5:acBarMMTelVoiceOcStatic:barTime=8s
...  LNBTS/ACBPR-5:acBarMMTelVoiceOcStatic:probFac=95%
...  LNBTS/ACBPR-5:acBarMMTelVideoOcStatic=${empty}
...  LNBTS/ACBPR-5:acBarCsfbOcStatic=${empty}
...  LNBTS/ACBPR-5:eCallAcBarredAuto=barred
...  LNBTS/ACBPR-5:acBarSkipForMMTELVideo=false
...  LNBTS/ACBPR-5:acBarSkipForMMTELVoice=false
...  LNBTS/ACBPR-5:acBarSkipForSMS=false
...  LNBTS/ACBPR-5:acBarSigAutoMin=${empty}
...  LNBTS/ACBPR-5:acBarSigAutoMax=${empty}
...  LNBTS/ACBPR-5:acBarOcAutoMin=${empty}
...  LNBTS/ACBPR-5:acBarOcAutoMax=${empty}
...  LNBTS/ACBPR-5:acBarMMTelVoiceOcAutoMin:barTime=4s
...  LNBTS/ACBPR-5:acBarMMTelVoiceOcAutoMin:probFac=95%
...  LNBTS/ACBPR-5:acBarMMTelVoiceOcAutoMax:barTime=512s
...  LNBTS/ACBPR-5:acBarMMTelVoiceOcAutoMax:probFac=0%
...  LNBTS/ACBPR-5:acBarMMTelVideoOcAutoMin=${empty}
...  LNBTS/ACBPR-5:acBarMMTelVideoOcAutoMax=${empty}
...  LNBTS/ACBPR-5:acBarCsfbOcAutoMin=${empty}
...  LNBTS/ACBPR-5:acBarCsfbOcAutoMax=${empty}
...  LNBTS/ACBPR-5:cellResHoBlockPlmnAcbMax=reserved
@{ACBPR6}
...  LNBTS/ACBPR-6:eCallAcBarredStatic=Not barred
...  LNBTS/ACBPR-6:acBarSigStatic=${empty}
...  LNBTS/ACBPR-6:acBarOcStatic=${empty}
...  LNBTS/ACBPR-6:acBarMMTelVoiceOcStatic=${empty}
...  LNBTS/ACBPR-6:acBarMMTelVideoOcStatic:barTime=8s
...  LNBTS/ACBPR-6:acBarMMTelVideoOcStatic:probFac=95%
...  LNBTS/ACBPR-6:acBarCsfbOcStatic=${empty}
...  LNBTS/ACBPR-6:eCallAcBarredAuto=barred
...  LNBTS/ACBPR-6:acBarSkipForMMTELVideo=false
...  LNBTS/ACBPR-6:acBarSkipForMMTELVoice=false
...  LNBTS/ACBPR-6:acBarSkipForSMS=false
...  LNBTS/ACBPR-6:acBarSigAutoMin=${empty}
...  LNBTS/ACBPR-6:acBarSigAutoMax=${empty}
...  LNBTS/ACBPR-6:acBarOcAutoMin=${empty}
...  LNBTS/ACBPR-6:acBarOcAutoMax=${empty}
...  LNBTS/ACBPR-6:acBarMMTelVoiceOcAutoMin=${empty}
...  LNBTS/ACBPR-6:acBarMMTelVoiceOcAutoMax=${empty}
...  LNBTS/ACBPR-6:acBarMMTelVideoOcAutoMin:barTime=4s
...  LNBTS/ACBPR-6:acBarMMTelVideoOcAutoMin:probFac=95%
...  LNBTS/ACBPR-6:acBarMMTelVideoOcAutoMax:barTime=512s
...  LNBTS/ACBPR-6:acBarMMTelVideoOcAutoMax:probFac=0%
...  LNBTS/ACBPR-6:acBarCsfbOcAutoMin=${empty}
...  LNBTS/ACBPR-6:acBarCsfbOcAutoMax=${empty}
...  LNBTS/ACBPR-6:cellResHoBlockPlmnAcbMax=reserved
@{ACBPR7}
...  LNBTS/ACBPR-7:eCallAcBarredStatic=Not barred
...  LNBTS/ACBPR-7:acBarSigStatic=${empty}
...  LNBTS/ACBPR-7:acBarOcStatic=${empty}
...  LNBTS/ACBPR-7:acBarMMTelVoiceOcStatic:barTime=8s
...  LNBTS/ACBPR-7:acBarMMTelVoiceOcStatic:probFac=95%
...  LNBTS/ACBPR-7:acBarMMTelVideoOcStatic=${empty}
...  LNBTS/ACBPR-7:acBarCsfbOcStatic=${empty}
...  LNBTS/ACBPR-7:eCallAcBarredAuto=barred
...  LNBTS/ACBPR-7:acBarSkipForMMTELVideo=false
...  LNBTS/ACBPR-7:acBarSkipForMMTELVoice=false
...  LNBTS/ACBPR-7:acBarSkipForSMS=false
...  LNBTS/ACBPR-7:acBarSigAutoMin=${empty}
...  LNBTS/ACBPR-7:acBarSigAutoMax=${empty}
...  LNBTS/ACBPR-7:acBarOcAutoMin=${empty}
...  LNBTS/ACBPR-7:acBarOcAutoMax=${empty}
...  LNBTS/ACBPR-7:acBarMMTelVoiceOcAutoMin:barTime=4s
...  LNBTS/ACBPR-7:acBarMMTelVoiceOcAutoMin:probFac=95%
...  LNBTS/ACBPR-7:acBarMMTelVoiceOcAutoMax:barTime=512s
...  LNBTS/ACBPR-7:acBarMMTelVoiceOcAutoMax:probFac=0%
...  LNBTS/ACBPR-7:acBarMMTelVideoOcAutoMin=${empty}
...  LNBTS/ACBPR-7:acBarMMTelVideoOcAutoMax=${empty}
...  LNBTS/ACBPR-7:acBarCsfbOcAutoMin=${empty}
...  LNBTS/ACBPR-7:acBarCsfbOcAutoMax=${empty}
...  LNBTS/ACBPR-7:cellResHoBlockPlmnAcbMax=reserved
@{ACBPR8}
...  LNBTS/ACBPR-8:eCallAcBarredStatic=Not barred
...  LNBTS/ACBPR-8:acBarSigStatic=${empty}
...  LNBTS/ACBPR-8:acBarOcStatic=${empty}
...  LNBTS/ACBPR-8:acBarMMTelVoiceOcStatic=${empty}
...  LNBTS/ACBPR-8:acBarMMTelVideoOcStatic:barTime=8s
...  LNBTS/ACBPR-8:acBarMMTelVideoOcStatic:probFac=95%
...  LNBTS/ACBPR-8:acBarCsfbOcStatic=${empty}
...  LNBTS/ACBPR-8:eCallAcBarredAuto=barred
...  LNBTS/ACBPR-8:acBarSkipForMMTELVideo=false
...  LNBTS/ACBPR-8:acBarSkipForMMTELVoice=false
...  LNBTS/ACBPR-8:acBarSkipForSMS=false
...  LNBTS/ACBPR-8:acBarSigAutoMin=${empty}
...  LNBTS/ACBPR-8:acBarSigAutoMax=${empty}
...  LNBTS/ACBPR-8:acBarOcAutoMin=${empty}
...  LNBTS/ACBPR-8:acBarOcAutoMax=${empty}
...  LNBTS/ACBPR-8:acBarMMTelVoiceOcAutoMin=${empty}
...  LNBTS/ACBPR-8:acBarMMTelVoiceOcAutoMax=${empty}
...  LNBTS/ACBPR-8:acBarMMTelVideoOcAutoMin:barTime=4s
...  LNBTS/ACBPR-8:acBarMMTelVideoOcAutoMin:probFac=95%
...  LNBTS/ACBPR-8:acBarMMTelVideoOcAutoMax:barTime=512s
...  LNBTS/ACBPR-8:acBarMMTelVideoOcAutoMax:probFac=0%
...  LNBTS/ACBPR-8:acBarCsfbOcAutoMin=${empty}
...  LNBTS/ACBPR-8:acBarCsfbOcAutoMax=${empty}
...  LNBTS/ACBPR-8:cellResHoBlockPlmnAcbMax=reserved
@{ACBPR9}
...  LNBTS/ACBPR-9:eCallAcBarredStatic=Not barred
...  LNBTS/ACBPR-9:acBarSigStatic=${empty}
...  LNBTS/ACBPR-9:acBarOcStatic=${empty}
...  LNBTS/ACBPR-9:acBarMMTelVoiceOcStatic:barTime=8s
...  LNBTS/ACBPR-9:acBarMMTelVoiceOcStatic:probFac=95%
...  LNBTS/ACBPR-9:acBarMMTelVideoOcStatic=${empty}
...  LNBTS/ACBPR-9:acBarCsfbOcStatic=${empty}
...  LNBTS/ACBPR-9:eCallAcBarredAuto=barred
...  LNBTS/ACBPR-9:acBarSkipForMMTELVideo=false
...  LNBTS/ACBPR-9:acBarSkipForMMTELVoice=false
...  LNBTS/ACBPR-9:acBarSkipForSMS=false
...  LNBTS/ACBPR-9:acBarSigAutoMin=${empty}
...  LNBTS/ACBPR-9:acBarSigAutoMax=${empty}
...  LNBTS/ACBPR-9:acBarOcAutoMin=${empty}
...  LNBTS/ACBPR-9:acBarOcAutoMax=${empty}
...  LNBTS/ACBPR-9:acBarMMTelVoiceOcAutoMin:barTime=4s
...  LNBTS/ACBPR-9:acBarMMTelVoiceOcAutoMin:probFac=95%
...  LNBTS/ACBPR-9:acBarMMTelVoiceOcAutoMax:barTime=512s
...  LNBTS/ACBPR-9:acBarMMTelVoiceOcAutoMax:probFac=0%
...  LNBTS/ACBPR-9:acBarMMTelVideoOcAutoMin=${empty}
...  LNBTS/ACBPR-9:acBarMMTelVideoOcAutoMax=${empty}
...  LNBTS/ACBPR-9:acBarCsfbOcAutoMin=${empty}
...  LNBTS/ACBPR-9:acBarCsfbOcAutoMax=${empty}
...  LNBTS/ACBPR-9:cellResHoBlockPlmnAcbMax=reserved
@{ACBPR10}
...  LNBTS/ACBPR-10:eCallAcBarredStatic=Not barred
...  LNBTS/ACBPR-10:acBarSigStatic=${empty}
...  LNBTS/ACBPR-10:acBarOcStatic=${empty}
...  LNBTS/ACBPR-10:acBarMMTelVoiceOcStatic=${empty}
...  LNBTS/ACBPR-10:acBarMMTelVideoOcStatic:barTime=8s
...  LNBTS/ACBPR-10:acBarMMTelVideoOcStatic:probFac=95%
...  LNBTS/ACBPR-10:acBarCsfbOcStatic=${empty}
...  LNBTS/ACBPR-10:eCallAcBarredAuto=barred
...  LNBTS/ACBPR-10:acBarSkipForMMTELVideo=false
...  LNBTS/ACBPR-10:acBarSkipForMMTELVoice=false
...  LNBTS/ACBPR-10:acBarSkipForSMS=false
...  LNBTS/ACBPR-10:acBarSigAutoMin=${empty}
...  LNBTS/ACBPR-10:acBarSigAutoMax=${empty}
...  LNBTS/ACBPR-10:acBarOcAutoMin=${empty}
...  LNBTS/ACBPR-10:acBarOcAutoMax=${empty}
...  LNBTS/ACBPR-10:acBarMMTelVoiceOcAutoMin=${empty}
...  LNBTS/ACBPR-10:acBarMMTelVoiceOcAutoMax=${empty}
...  LNBTS/ACBPR-10:acBarMMTelVideoOcAutoMin:barTime=4s
...  LNBTS/ACBPR-10:acBarMMTelVideoOcAutoMin:probFac=95%
...  LNBTS/ACBPR-10:acBarMMTelVideoOcAutoMax:barTime=512s
...  LNBTS/ACBPR-10:acBarMMTelVideoOcAutoMax:probFac=0%
...  LNBTS/ACBPR-10:acBarCsfbOcAutoMin=${empty}
...  LNBTS/ACBPR-10:acBarCsfbOcAutoMax=${empty}
...  LNBTS/ACBPR-10:cellResHoBlockPlmnAcbMax=reserved
@{ACBPR11}
...  LNBTS/ACBPR-11:eCallAcBarredStatic=Not barred
...  LNBTS/ACBPR-11:acBarSigStatic=${empty}
...  LNBTS/ACBPR-11:acBarOcStatic=${empty}
...  LNBTS/ACBPR-11:acBarMMTelVoiceOcStatic:barTime=8s
...  LNBTS/ACBPR-11:acBarMMTelVoiceOcStatic:probFac=95%
...  LNBTS/ACBPR-11:acBarMMTelVideoOcStatic=${empty}
...  LNBTS/ACBPR-11:acBarCsfbOcStatic=${empty}
...  LNBTS/ACBPR-11:eCallAcBarredAuto=barred
...  LNBTS/ACBPR-11:acBarSkipForMMTELVideo=false
...  LNBTS/ACBPR-11:acBarSkipForMMTELVoice=false
...  LNBTS/ACBPR-11:acBarSkipForSMS=false
...  LNBTS/ACBPR-11:acBarSigAutoMin=${empty}
...  LNBTS/ACBPR-11:acBarSigAutoMax=${empty}
...  LNBTS/ACBPR-11:acBarOcAutoMin=${empty}
...  LNBTS/ACBPR-11:acBarOcAutoMax=${empty}
...  LNBTS/ACBPR-11:acBarMMTelVoiceOcAutoMin:barTime=4s
...  LNBTS/ACBPR-11:acBarMMTelVoiceOcAutoMin:probFac=95%
...  LNBTS/ACBPR-11:acBarMMTelVoiceOcAutoMax:barTime=512s
...  LNBTS/ACBPR-11:acBarMMTelVoiceOcAutoMax:probFac=0%
...  LNBTS/ACBPR-11:acBarMMTelVideoOcAutoMin=${empty}
...  LNBTS/ACBPR-11:acBarMMTelVideoOcAutoMax=${empty}
...  LNBTS/ACBPR-11:acBarCsfbOcAutoMin=${empty}
...  LNBTS/ACBPR-11:acBarCsfbOcAutoMax=${empty}
...  LNBTS/ACBPR-11:cellResHoBlockPlmnAcbMax=reserved
@{ACBPR12}
...  LNBTS/ACBPR-12:eCallAcBarredStatic=Not barred
...  LNBTS/ACBPR-12:acBarSigStatic=${empty}
...  LNBTS/ACBPR-12:acBarOcStatic=${empty}
...  LNBTS/ACBPR-12:acBarMMTelVoiceOcStatic=${empty}
...  LNBTS/ACBPR-12:acBarMMTelVideoOcStatic:barTime=8s
...  LNBTS/ACBPR-12:acBarMMTelVideoOcStatic:probFac=95%
...  LNBTS/ACBPR-12:acBarCsfbOcStatic=${empty}
...  LNBTS/ACBPR-12:eCallAcBarredAuto=barred
...  LNBTS/ACBPR-12:acBarSkipForMMTELVideo=false
...  LNBTS/ACBPR-12:acBarSkipForMMTELVoice=false
...  LNBTS/ACBPR-12:acBarSkipForSMS=false
...  LNBTS/ACBPR-12:acBarSigAutoMin=${empty}
...  LNBTS/ACBPR-12:acBarSigAutoMax=${empty}
...  LNBTS/ACBPR-12:acBarOcAutoMin=${empty}
...  LNBTS/ACBPR-12:acBarOcAutoMax=${empty}
...  LNBTS/ACBPR-12:acBarMMTelVoiceOcAutoMin=${empty}
...  LNBTS/ACBPR-12:acBarMMTelVoiceOcAutoMax=${empty}
...  LNBTS/ACBPR-12:acBarMMTelVideoOcAutoMin:barTime=4s
...  LNBTS/ACBPR-12:acBarMMTelVideoOcAutoMin:probFac=95%
...  LNBTS/ACBPR-12:acBarMMTelVideoOcAutoMax:barTime=512s
...  LNBTS/ACBPR-12:acBarMMTelVideoOcAutoMax:probFac=0%
...  LNBTS/ACBPR-12:acBarCsfbOcAutoMin=${empty}
...  LNBTS/ACBPR-12:acBarCsfbOcAutoMax=${empty}
...  LNBTS/ACBPR-12:cellResHoBlockPlmnAcbMax=reserved
@{ACBPR13}
...  LNBTS/ACBPR-13:eCallAcBarredStatic=Not barred
...  LNBTS/ACBPR-13:acBarSigStatic=${empty}
...  LNBTS/ACBPR-13:acBarOcStatic=${empty}
...  LNBTS/ACBPR-13:acBarMMTelVoiceOcStatic:barTime=8s
...  LNBTS/ACBPR-13:acBarMMTelVoiceOcStatic:probFac=95%
...  LNBTS/ACBPR-13:acBarMMTelVideoOcStatic=${empty}
...  LNBTS/ACBPR-13:acBarCsfbOcStatic=${empty}
...  LNBTS/ACBPR-13:eCallAcBarredAuto=barred
...  LNBTS/ACBPR-13:acBarSkipForMMTELVideo=false
...  LNBTS/ACBPR-13:acBarSkipForMMTELVoice=false
...  LNBTS/ACBPR-13:acBarSkipForSMS=false
...  LNBTS/ACBPR-13:acBarSigAutoMin=${empty}
...  LNBTS/ACBPR-13:acBarSigAutoMax=${empty}
...  LNBTS/ACBPR-13:acBarOcAutoMin=${empty}
...  LNBTS/ACBPR-13:acBarOcAutoMax=${empty}
...  LNBTS/ACBPR-13:acBarMMTelVoiceOcAutoMin:barTime=4s
...  LNBTS/ACBPR-13:acBarMMTelVoiceOcAutoMin:probFac=95%
...  LNBTS/ACBPR-13:acBarMMTelVoiceOcAutoMax:barTime=512s
...  LNBTS/ACBPR-13:acBarMMTelVoiceOcAutoMax:probFac=0%
...  LNBTS/ACBPR-13:acBarMMTelVideoOcAutoMin=${empty}
...  LNBTS/ACBPR-13:acBarMMTelVideoOcAutoMax=${empty}
...  LNBTS/ACBPR-13:acBarCsfbOcAutoMin=${empty}
...  LNBTS/ACBPR-13:acBarCsfbOcAutoMax=${empty}
...  LNBTS/ACBPR-13:cellResHoBlockPlmnAcbMax=reserved
@{SIB0}
...  LNCEL/SIB-0:acbProfileId=0
...  LNCEL/SIB-0:acbUpdateTimer=${acbUpdateTimer}
...  LNCEL/SIB-0:acbNumSteps=4
...  LNCEL/SIB-0:acbNumRrcConnCellStart=2
...  LNCEL/SIB-0:acbNumRrcConnCellStop=1
...  LNCEL/SIB-0:acbRrcConnCellStartTimer=${acbRrcConnCellStartTimer}
...  LNCEL/SIB-0:acbRrcConnCellStopTimer=${acbRrcConnCellStopTimer}
...  LNCEL/SIB-0:acbPlmnNumSteps=3
...  LNCEL/SIB-0:primPlmnCellresAcbMax=reserved
...  LNCEL-1/SIB-0:acbECTimer=1
...  LNCEL-1/SIB-0:acbSkipTimer=1
${acbUpdateTimer}    30
${acbRrcConnCellStartTimer}    30
${acbRrcConnCellStopTimer}    30
${catm_ue_eutra_capabilities}    D61FF000800055555D55001000804510021200055C041900    # CAT-M
${normal_ue_eutra_capabilities}    CD9FF4F9B2E7500010610102912464D0312040E07FFFFFFFFCA18800182008295020022A0060B3FFFFFFFE014FFFFFFFFC
@{PM_COUNTERS_FOR_01_02}
...  ${AC Barring factor set to p95 for class MO-Signaling for LTE-M}>20
...  ${AC Barring factor set to p50 for class MO-Signaling for LTE-M}=0
...  ${AC Barring factor set to p40 for class MO-Signaling for LTE-M}>20
...  ${AC Barring factor set to p00 for class MO-Signaling for LTE-M}>20
...  ${TIME_ACB_EC_BARRING}>20
...  ${TIME_ACB_EC_BARRING_LTEM}>20
...  ${TIME_ACB_ALL_LTEM}>200
...  ${TIME_ACB_SKIP_OFF_LTEM}>50
...  ${DURATION_ACB_PLMN_SRANM}>200
...  ${AC Barring factor set to p95 for class MO-Data for LTE-M}=0
...  ${AC Barring factor set to p95 for class MMTEL-Voice for LTE-M}=0
${AC Barring factor set to p95 for class MO-Signaling for LTE-M}    M8057C121
${AC Barring factor set to p50 for class MO-Signaling for LTE-M}    M8057C114
${AC Barring factor set to p40 for class MO-Signaling for LTE-M}    M8057C113
${AC Barring factor set to p00 for class MO-Signaling for LTE-M}    M8057C106
${TIME_ACB_EC_BARRING}    M8057C138
${TIME_ACB_EC_BARRING_LTEM}    M8057C139
${TIME_ACB_ALL_LTEM}    M8057C140
${TIME_ACB_SKIP_OFF_LTEM}    M8057C141
${DURATION_ACB_PLMN_SRANM}    M8038C51
${AC Barring factor set to p95 for class MO-Data for LTE-M}    M8057C105
${AC Barring factor set to p95 for class MMTEL-Voice for LTE-M}    M8057C137
${WB_CATM reach P_ACB min level}
...    ac-BarringInfo contains (
...    ac-BarringForEmergency eq 'FALSE' and
...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8') and
...    ac-BarringForMO-Data contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8')) and
...    ac-BarringSkipForSMS-r12 eq 'true' and
...    ac-BarringSkipForMMTELVoice-r12 eq 'true' and
...    ac-BarringSkipForMMTELVideo-r12 eq 'true' and
...    ac-BarringPerPLMN-List-r12 contains (
...    ac-BarringInfo-r12 contains (ac-BarringForEmergency-r12 eq 'FALSE') and
...    ac-BarringForCSFB-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's4'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's4'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's4'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's4'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's4'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's4'))
${WB_CATM reach P_ACB min level_BR}
...    ac-BarringInfo contains (
...    ac-BarringForEmergency eq 'FALSE' and
...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8')) and
...    ac-BarringSkipForSMS-r12 eq 'true' and
...    ac-BarringSkipForMMTELVoice-r12 eq 'true' and
...    ac-BarringSkipForSMS-r12 eq 'true' and
...    ac-BarringPerPLMN-List-r12 contains (
...    ac-BarringInfo-r12 contains (ac-BarringForEmergency-r12 eq 'FALSE' and ac-BarringFactor eq 'p95' and ac-BarringTime eq 's4'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's4'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's4'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's4'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's4'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's4'))
${WB reach P_ACB 2 level}
...    ac-BarringInfo contains (
...    ac-BarringForEmergency eq 'FALSE' and
...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8') and
...    ac-BarringForMO-Data contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8')) and
...    ac-BarringSkipForSMS-r12 eq 'true' and
...    ac-BarringSkipForMMTELVoice-r12 eq 'true' and
...    ac-BarringSkipForMMTELVideo-r12 eq 'true' and
...    ac-BarringPerPLMN-List-r12 contains (
...    ac-BarringInfo-r12 contains (ac-BarringForEmergency-r12 eq 'FALSE') and
...    ac-BarringForCSFB-r12 contains (ac-BarringFactor eq 'p40' and ac-BarringTime eq 's64'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p40' and ac-BarringTime eq 's64'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p40' and ac-BarringTime eq 's64'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p40' and ac-BarringTime eq 's64'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p40' and ac-BarringTime eq 's64'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p40' and ac-BarringTime eq 's64'))
${WB reach P_ACB 2 level_BR}
...    ac-BarringInfo contains (
...    ac-BarringForEmergency eq 'FALSE' and
...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8')) and
...    ac-BarringSkipForSMS-r12 eq 'true' and
...    ac-BarringSkipForMMTELVoice-r12 eq 'true' and
...    ac-BarringPerPLMN-List-r12 contains (
...    ac-BarringInfo-r12 contains (ac-BarringForEmergency-r12 eq 'FALSE' and ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'))
${P_ACB MAX level3}
...    ac-BarringInfo contains (
...    ac-BarringForEmergency eq 'FALSE' and
...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8') and
...    ac-BarringForMO-Data contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8')) and
...    ac-BarringSkipForSMS-r12 eq 'true' and
...    ac-BarringSkipForMMTELVoice-r12 eq 'true' and
...    ac-BarringSkipForMMTELVideo-r12 eq 'true' and
...    ac-BarringPerPLMN-List-r12 contains (
...    ac-BarringInfo-r12 contains (ac-BarringForEmergency-r12 eq 'FALSE') and
...    ac-BarringForCSFB-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'))
${C_ACB level min}
...    ac-BarringInfo contains (
...    ac-BarringForEmergency eq 'FALSE' and
...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's4') and
...    ac-BarringForMO-Data contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's4')) and
...    ac-BarringSkipForSMS-r12 eq 'true' and
...    ac-BarringSkipForMMTELVoice-r12 eq 'true' and
...    ac-BarringSkipForMMTELVideo-r12 eq 'true' and
...    ac-BarringPerPLMN-List-r12 contains (
...    ac-BarringInfo-r12 contains (ac-BarringForEmergency-r12 eq 'FALSE') and
...    ac-BarringForCSFB-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'))
${C_ACB level min_BR}
...    ac-BarringInfo contains (
...    ac-BarringForEmergency eq 'FALSE' and
...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's4')) and
...    ac-BarringSkipForSMS-r12 eq 'true' and
...    ac-BarringSkipForMMTELVoice-r12 eq 'true' and
...    ac-BarringPerPLMN-List-r12 contains (
...    ac-BarringInfo-r12 contains (ac-BarringForEmergency-r12 eq 'FALSE' and ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'))
${C_ACB level 2}
...    ac-BarringInfo contains (
...    ac-BarringForEmergency eq 'FALSE' and
...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p70' and ac-BarringTime eq 's16') and
...    ac-BarringForMO-Data contains (ac-BarringFactor eq 'p70' and ac-BarringTime eq 's16')) and
...    ac-BarringSkipForSMS-r12 eq 'true' and
...    ac-BarringSkipForMMTELVoice-r12 eq 'true' and
...    ac-BarringSkipForMMTELVideo-r12 eq 'true' and
...    ac-BarringPerPLMN-List-r12 contains (
...    ac-BarringInfo-r12 contains (ac-BarringForEmergency-r12 eq 'FALSE') and
...    ac-BarringForCSFB-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'))
${C_ACB level 2_BR}
...    ac-BarringInfo contains (
...    ac-BarringForEmergency eq 'FALSE' and
...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p40' and ac-BarringTime eq 's64')) and
...    ac-BarringSkipForSMS-r12 eq 'true' and
...    ac-BarringSkipForMMTELVoice-r12 eq 'true' and
...    ac-BarringPerPLMN-List-r12 contains (
...    ac-BarringInfo-r12 contains (ac-BarringForEmergency-r12 eq 'FALSE' and ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'))
${C_ACB level MAX4}
...    ac-BarringInfo contains (
...    ac-BarringForEmergency eq 'FALSE' and
...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512') and
...    ac-BarringForMO-Data contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512')) and
...    ac-BarringSkipForSMS-r12 eq 'true' and
...    ac-BarringSkipForMMTELVoice-r12 eq 'true' and
...    ac-BarringSkipForMMTELVideo-r12 eq 'true' and
...    ac-BarringPerPLMN-List-r12 contains (
...    ac-BarringInfo-r12 contains (ac-BarringForEmergency-r12 eq 'FALSE') and
...    ac-BarringForCSFB-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'))
${C_ACB MAX}
...    ac-BarringInfo contains (
...    ac-BarringForEmergency eq 'FALSE' and
...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p25' and ac-BarringTime eq 's128') and
...    ac-BarringForMO-Data contains (ac-BarringFactor eq 'p25' and ac-BarringTime eq 's128')) and
...    ac-BarringSkipForSMS-r12 eq 'true' and
...    ac-BarringSkipForMMTELVoice-r12 eq 'true' and
...    ac-BarringSkipForMMTELVideo-r12 eq 'true' and
...    ac-BarringPerPLMN-List-r12 contains (
...    ac-BarringInfo-r12 contains (ac-BarringForEmergency-r12 eq 'FALSE') and
...    ac-BarringForCSFB-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'))
${C_ACB MAX_BR}
...    ac-BarringInfo contains (
...    ac-BarringForEmergency eq 'FALSE' and
...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512')) and
...    ac-BarringSkipForSMS-r12 eq 'true' and
...    ac-BarringSkipForMMTELVoice-r12 eq 'true' and
...    ac-BarringPerPLMN-List-r12 contains (
...    ac-BarringInfo-r12 contains (ac-BarringForEmergency-r12 eq 'FALSE' and ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'))
${SKIP IE REMOVED}
...    ac-BarringInfo contains (
...    ac-BarringForEmergency eq 'FALSE' and
...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512') and
...    ac-BarringForMO-Data contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512')) and
...    ac-BarringPerPLMN-List-r12 contains (
...    ac-BarringInfo-r12 contains (ac-BarringForEmergency-r12 eq 'FALSE') and
...    ac-BarringForCSFB-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'))
${SKIP IE REMOVED_BR}
...    ac-BarringInfo contains (
...    ac-BarringForEmergency eq 'FALSE' and
...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512')) and
...    ac-BarringPerPLMN-List-r12 contains (
...    ac-BarringInfo-r12 contains (ac-BarringForEmergency-r12 eq 'FALSE' and ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'))
${ac-BarringForEmergency set to true}
...    ac-BarringInfo contains (
...    ac-BarringForEmergency eq 'TRUE' and
...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512') and
...    ac-BarringForMO-Data contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512')) and
...    ac-BarringPerPLMN-List-r12 contains (
...    ac-BarringInfo-r12 contains (ac-BarringForEmergency-r12 eq 'TRUE') and
...    ac-BarringForCSFB-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'))
${ac-BarringForEmergency set to true_BR}
...    ac-BarringInfo contains (
...    ac-BarringForEmergency eq 'TRUE' and
...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512')) and
...    ac-BarringPerPLMN-List-r12 contains (
...    ac-BarringInfo-r12 contains (ac-BarringForEmergency-r12 eq 'TRUE' and ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p00' and ac-BarringTime eq 's512'))
${NO AACB state WBCATM static}
...    ac-BarringInfo contains (
...    ac-BarringForEmergency eq 'FALSE' and
...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8') and
...    ac-BarringForMO-Data contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8')) and
...    ac-BarringSkipForSMS-r12 eq 'true' and
...    ac-BarringSkipForMMTELVoice-r12 eq 'true' and
...    ac-BarringSkipForMMTELVideo-r12 eq 'true' and
...    ac-BarringPerPLMN-List-r12 contains (
...    ac-BarringInfo-r12 contains (ac-BarringForEmergency-r12 eq 'FALSE') and
...    ac-BarringForCSFB-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8'),
...    ssac-BarringForMMTEL-Video-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8'))
${NO AACB state WBCATM static_BR}
...    ac-BarringInfo contains (
...    ac-BarringForEmergency eq 'FALSE' and
...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8')) and
...    ac-BarringSkipForSMS-r12 eq 'true' and
...    ac-BarringSkipForMMTELVoice-r12 eq 'true' and
...    ac-BarringSkipForSMS-r12 eq 'true' and
...    ac-BarringPerPLMN-List-r12 contains (
...    ac-BarringInfo-r12 contains (ac-BarringForEmergency-r12 eq 'FALSE' and ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8'),
...    ssac-BarringForMMTEL-Voice-r12 contains (ac-BarringFactor eq 'p95' and ac-BarringTime eq 's8'))

*** Test Cases ***
Auto_case_name_1
    [Documentation]
    ...    case name was:[LTE4741-B-g_01_02_Start automatic common and PLMN specific ACB WB steps bigger than Cat-M steps
    ...    upgrade and downgrade stepwise triggered by RRC_ACB from StaticAcb to P_AcbMax and C_AcbMax]
    ...    This Case is to verify AACB INFO
    ...    in SIB2/SIB2-BR triggered by RRC_ACB stepwise upgrade to PLMN ACB and Common ACB max level with
    ...    out skipTimer and Ectimer configured then back to static ACB
    [Tags]
    Start Rtpm Counter
    Trigger RRC_ACB and Wait ACB Reach C_ACB MAX
    Intra eNB Inter cell HO    ue_id=3    cell_id=2    #expectString=Intra-eNB handover
    Intra eNB Inter cell HO back    ue_id=3    cell_id=1    #expectString=The UE stays at source cell
    All UE Detach
    Wait ACB Reach Static ACB
#    Check RRC log    ${CURDIR}${/}A2A_Bg_02${/}a2a.ini
    Check Rtpm Counters    ${PM_COUNTERS_FOR_01_02}

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus

Modify Yaml
    add yaml    EPC
    ...    MME_POOL_AREA:
    ...    - {id: 2, plmn: '262:04', mmegi: 2, tac_list: 33}
    ...    - {id: 3, plmn: '262:05', mmegi: 3, tac_list: 33}
    ...    - {id: 4, plmn: '262:06', mmegi: 4, tac_list: 33}
    ...    - {id: 5, plmn: '262:07', mmegi: 5, tac_list: 33}
    ...    - {id: 6, plmn: '262:08', mmegi: 6, tac_list: 33}
    update yaml    EPC/MME/1
    ...      pool: ['1:1', '2:2', '3:3', '4:4', '5:5', '6:6']

All UE Detach
    execute uex command    ue_detach all

Trigger RRC_ACB and Wait ACB Reach C_ACB MAX
    UE attach to eNB1    ue_id=1    ue_eutra_capabilities=${catm_ue_eutra_capabilities}
    UE attach to eNB1    ue_id=2    ue_eutra_capabilities=${catm_ue_eutra_capabilities}
    UE attach to eNB1    ue_id=3
    UE attach to eNB1    ue_id=4
    Start UL Traffic    1
    Start UL Traffic    2
    Start UL Traffic    3
    Start UL Traffic    4
    sleep    10s
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType2(${WB_CATM reach P_ACB min level})
    ...    CELL_1:RRC_SystemInformationBlockType2-BR-r13(${WB_CATM reach P_ACB min level_BR})
    ...    alias=P_ACB_min_level  overall_timeout=32
    Wait Paging message    ${acbRrcConnCellStartTimer}    #WB/CATM reach P_ACB min level
    Flow Occurred As Expected    alias=P_ACB_min_level
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType2 (${WB reach P_ACB 2 level})
    ...    CELL_1:RRC_SystemInformationBlockType2-BR-r13 (${WB reach P_ACB 2 level_BR})
    ...    alias=WB_reach_P_ACB_2_level  overall_timeout=32
    Wait Paging message    ${acbUpdateTimer}    #WB reach P_ACB 2 level,CATM reached max level
    Flow Occurred As Expected    alias=WB_reach_P_ACB_2_level
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType2 (${P_ACB MAX level3})
    ...    alias=P_ACB_MAX_level3  overall_timeout=32
    Wait Paging message    ${acbUpdateTimer}    #WB reach P_ACB MAX level(3),NO SIB2-BR due to CATM already reached P_ACB MAX
    Flow Occurred As Expected    alias=P_ACB_MAX_level3
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType2 (${C_ACB level min})
    ...    CELL_1:RRC_SystemInformationBlockType2-BR-r13 (${C_ACB level min_BR})
    ...    alias=C_ACB_level_min  overall_timeout=32
    Wait Paging message    ${acbUpdateTimer}    #WB/CATM reach P_ACB MAX level,C_ACB min level
    Flow Occurred As Expected    alias=C_ACB_level_min
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType2 (${C_ACB level 2})
    ...    CELL_1:RRC_SystemInformationBlockType2-BR-r13 (${C_ACB level 2_BR})
    ...    alias=C_ACB_level_2  overall_timeout=32
    Wait Paging message    ${acbUpdateTimer}    #WB/CATM reach P_ACB MAX level,C_ACB 2 level
    Flow Occurred As Expected    alias=C_ACB_level_2
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType2 (${C_ACB MAX})
    ...    CELL_1:RRC_SystemInformationBlockType2-BR-r13 (${C_ACB MAX_BR})
    ...    alias=C_ACB_MAX  overall_timeout=32
    Wait Paging message    ${acbUpdateTimer}    WB reach P_ACB MAX level,C_ACB 3 level,CATM reached C_ACB MAX
    Flow Occurred As Expected    alias=C_ACB_MAX
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType2 (${C_ACB level MAX4})
    ...    alias=C_ACB_level_MAX4  overall_timeout=32
    Wait Paging message    ${acbUpdateTimer}    #WB reach P_ACB MAX level,C_ACB MAX level(4),NO SIB2-BR due to CATM already reached max
    Flow Occurred As Expected    alias=C_ACB_level_MAX4
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType2 (${SKIP IE REMOVED})
    ...    CELL_1:RRC_SystemInformationBlockType2-BR-r13 (${SKIP IE REMOVED_BR})
    ...    alias=SKIP_IE_REMOVED_BR  overall_timeout=32
    Wait Paging message    ${acbUpdateTimer}    #WB/CATM reached C_ACB MAX and SKIP IE removed
    Flow Occurred As Expected    alias=SKIP_IE_REMOVED_BR
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType2 (${ac-BarringForEmergency set to true})
    ...    CELL_1:RRC_SystemInformationBlockType2-BR-r13 (${ac-BarringForEmergency set to true_BR})
    ...    alias=ac-BarringForEmergency_flow  overall_timeout=32
    Wait Paging message    ${acbUpdateTimer}    WB/CATM reached C_ACB MAX and SKIP IE removed and ac-barringforemergency set to true
    Flow Occurred As Expected    alias=ac-BarringForEmergency_flow

UE attach to eNB1
    [Arguments]    ${ue_id}=1    ${ue_eutra_capabilities}=${normal_ue_eutra_capabilities}
    execute uex command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=1

Wait ACB Reach Static ACB
    Wait Paging message    ${acbRrcConnCellStopTimer}    wait RRC_ACB inactive
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType2 (${SKIP IE REMOVED})
    ...    CELL_1:RRC_SystemInformationBlockType2-BR-r13 (${SKIP IE REMOVED_BR})
    ...    alias=SKIP_IE_REMOVED_BR2  overall_timeout=32
    Wait Paging message    ${acbUpdateTimer}    WB/CATM reached C_ACB MAX and SKIP IE removed and ac-barringforemergency set to false
    Flow Occurred As Expected    alias=SKIP_IE_REMOVED_BR2
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType2 (${C_ACB level MAX4})
    ...    CELL_1:RRC_SystemInformationBlockType2-BR-r13 (${C_ACB MAX_BR})
    ...    alias=C_ACB_level_MAX4_2  overall_timeout=32
    Wait Paging message    ${acbUpdateTimer}    WB/CATM reached C_ACB MAX and SKIP IE recovered
    Flow Occurred As Expected    alias=C_ACB_level_MAX4_2
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType2 (${C_ACB MAX})
    ...    alias=C_ACB_MAX_2  overall_timeout=32
    Wait Paging message    ${acbUpdateTimer}    WB reach P_ACB MAX level,C_ACB 3 level,NO SIB2-BR due to CATM remain C_ACB max
    Flow Occurred As Expected    alias=C_ACB_MAX_2
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType2 (${C_ACB level 2})
    ...    CELL_1:RRC_SystemInformationBlockType2-BR-r13 (${C_ACB level 2_BR})
    ...    alias=C_ACB_level_2_2  overall_timeout=32
    Wait Paging message    ${acbUpdateTimer}    WB/CATM reach P_ACB MAX level,C_ACB 2 level
    Flow Occurred As Expected    alias=C_ACB_level_2_2
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType2 (${C_ACB level min})
    ...    CELL_1:RRC_SystemInformationBlockType2-BR-r13 (${C_ACB level min_BR})
    ...    alias=C_ACB_level_min_2  overall_timeout=32
    Wait Paging message    ${acbUpdateTimer}    WB/CATM reach P_ACB MAX level,C_ACB min level
    Flow Occurred As Expected    alias=C_ACB_level_min_2
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType2 (${P_ACB MAX level3})
    ...    CELL_1:RRC_SystemInformationBlockType2-BR-r13 (${WB reach P_ACB 2 level_BR})
    ...    alias=P_ACB_MAX_level3_2  overall_timeout=32
    Wait Paging message    ${acbUpdateTimer}    WB/CATM reach P_ACB MAX level(3)
    Flow Occurred As Expected    alias=P_ACB_MAX_level3_2
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType2 (${WB reach P_ACB 2 level})
    ...    alias=WB_reach_P_ACB_2_level_2  overall_timeout=32
    Wait Paging message    ${acbUpdateTimer}    WB reach P_ACB 2 level,NO SIB2-BR due to CATM remain P_ACB max
    Flow Occurred As Expected    alias=WB_reach_P_ACB_2_level_2
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType2 (${WB_CATM reach P_ACB min level})
    ...    CELL_1:RRC_SystemInformationBlockType2-BR-r13 (${WB_CATM reach P_ACB min level_BR})
    ...    alias=P_ACB_min_level_2  overall_timeout=32
    Wait Paging message    ${acbUpdateTimer}    reach P_ACB min level
    Flow Occurred As Expected    alias=P_ACB_min_level_2
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType2 (${NO AACB state WBCATM static})
    ...    CELL_1:RRC_SystemInformationBlockType2-BR-r13 (${NO AACB state WBCATM static_BR})
    ...    alias=NO AACB state  overall_timeout=32
    Wait Paging message    ${acbUpdateTimer}    reach ACB static level
    Flow Occurred As Expected    alias=NO AACB state

Start UL Traffic
    [Arguments]    ${ue_id}=1
    execute uex command  trf_data_start ue=${ue_id} qci=8 dir=ul Mbps=1 protocol=udp

Wait Paging message
    [Arguments]    ${waittime}=30s    ${reason}=None
    Sleep    ${waittime}

Intra eNB Inter cell HO
    [Arguments]    ${ue_id}={UE1}    ${cell_id}=2    #${expectString}=Intra-eNB handover
    execute uex command    ue_ho id=${ue_id} enb=1 cell=${cell_id}    #${expectString}
    sleep    2s

Intra eNB Inter cell HO back
    [Arguments]    ${ue_id}={UE1}    ${cell_id}=2    #${expectString}=Intra-eNB handover
    execute uex command and expect error    ue_ho id=${ue_id} enb=1 cell=${cell_id}    sErrMeasStepTimeExceed
    sleep    1s
