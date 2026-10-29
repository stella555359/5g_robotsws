*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CIT    CLOUD_R4LAPO_CUS
...               team-SG4    release-SBTS19A    owner-pei.han
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***

@{PARAMS_IN_SCF}
...    LNCEL:cellTechnology=TDD
...    LNBTS:actAcBarringACS=true
...    @{PARAMS_FOR_RRCtrigger_ACB}
...    @{PARAMS_FOR_RACHtrigger_ACB}
...    @{LTE4627}
...    @{LTE2996_PARAMS_FOR_PLMN}

@{PARAMS_FOR_RRCtrigger_ACB}
...    LNBTS:actAcBarringRrcConn=CellOnly
...    LNCEL/SIB-0:acbNumRrcConnCellStart=2
...    LNCEL/SIB-0:acbNumRrcConnCellStop=1
...    LNCEL/SIB-0:acbUpdateTimer=30
...    LNCEL/SIB-0:acbRrcConnCellStartTimer=30
...    LNCEL/SIB-0:acbRrcConnCellStopTimer=30
...    LNCEL/LNCEL_TDD-0/MPUCCH_TDD-0:maxNumRrc=270
...    LNCEL:inactivityTimer=1000
...    LNBTS:actAcBarringCFR=false
...    LNCEL/LNCEL_TDD-0:actAutoPucchAlloc=false

# RRC trigger ACB rrc num=round(2*270)=5
@{PARAMS_FOR_RACHtrigger_ACB}
...    LNBTS:actAcBarringRrcReq=false
...    LNCEL/SIB-0:acbNumRrcReqStart=2
...    LNCEL/SIB-0:acbNumRrcReqStop=1
...    LNCEL/SIB-0:acbRrcReqFactor=0.25
...    LNCEL/LNCEL_TDD-0:maxNumActUE=100
...    LNCEL/LNCEL_TDD-0:maxNumCaConfUeDc=10
...    LNCEL/LNCEL_TDD-0:maxNumCaConfUe3c=10
...    LNCEL/LNCEL_TDD-0:maxNumCaConfUe=10
...    LNCEL/LNCEL_TDD-0/MPUCCH_TDD-0:minNumRrcNoDrb=170
...    LNCEL:inactivityTimer=1000

@{LTE4627}
...    LNBTS:actAcBarringSpecialClass=true
...    LNCEL/SIB-0:acbScTimer=2
...    LNCEL/SIB-0:acbSkipTimer=2
...    LNCEL/SIB-0:acbScStepDuration=2
...    LNCEL/SIB-0:acbECTimer=1
...    LNCEL/SIB-0:acbProfileId=0
...    LNCEL/SIB-0:acbNumSteps=2
...    LNBTS/ACBPR-0:eCallAcBarredAuto=barred
...    LNBTS/ACBPR-0:cellResHoBlockPlmnAcbMax=notReserved
...    LNBTS/ACBPR-0:emerHoBlockPlmnAcbMax=false
...    LNBTS/ACBPR-0:acBarSkipForMMTELVideo=true
...    LNBTS/ACBPR-0:acBarSkipForMMTELVoice=true
...    LNBTS/ACBPR-0:acBarSkipForSMS=false
...    LNBTS/ACBPR-0:acbScEcBitmask=5
...    LNBTS/ACBPR-0:acBarSigAutoMax:barAC=1
...    LNBTS/ACBPR-0:acBarSigAutoMax:barAC3=23
...    LNBTS/ACBPR-0:acBarSigAutoMax:barAC1=5
...    LNBTS/ACBPR-0:acBarSigAutoMax:barAC2=21
...    LNBTS/ACBPR-0:acBarSigAutoMax:probFac=0%
...    LNBTS/ACBPR-0:acBarSigAutoMax:barTime=8s
...    LNBTS/ACBPR-0:acBarSigAutoMin:probFac=90%
...    LNBTS/ACBPR-0:acBarSigAutoMin:barTime=8s
...    LNBTS/ACBPR-0:acBarOcAutoMax:barAC=1
...    LNBTS/ACBPR-0:acBarOcAutoMax:barAC3=23
...    LNBTS/ACBPR-0:acBarOcAutoMax:barAC1=5
...    LNBTS/ACBPR-0:acBarOcAutoMax:barAC2=21
...    LNBTS/ACBPR-0:acBarOcAutoMin:probFac=90%
...    LNBTS/ACBPR-0:acBarOcAutoMin:barTime=8s
...    LNBTS/ACBPR-0:acBarOcAutoMax:probFac=0%
...    LNBTS/ACBPR-0:acBarOcAutoMax:barTime=8s
...    LNBTS/ACBPR-0:acBarMMTelVoiceOcAutoMax:barAC=1
...    LNBTS/ACBPR-0:acBarMMTelVoiceOcAutoMax:barAC3=23
...    LNBTS/ACBPR-0:acBarMMTelVoiceOcAutoMax:barAC1=17
...    LNBTS/ACBPR-0:acBarMMTelVoiceOcAutoMax:barAC2=21
...    LNBTS/ACBPR-0:acBarMMTelVoiceOcAutoMin:probFac=90%
...    LNBTS/ACBPR-0:acBarMMTelVoiceOcAutoMin:barTime=8s
...    LNBTS/ACBPR-0:acBarMMTelVoiceOcAutoMax:probFac=0%
...    LNBTS/ACBPR-0:acBarMMTelVoiceOcAutoMax:barTime=8s
...    LNBTS/ACBPR-0:acBarMMTelVideoOcAutoMax:barAC=1
...    LNBTS/ACBPR-0:acBarMMTelVideoOcAutoMax:barAC3=23
...    LNBTS/ACBPR-0:acBarMMTelVideoOcAutoMax:barAC1=5
...    LNBTS/ACBPR-0:acBarMMTelVideoOcAutoMax:barAC2=21
...    LNBTS/ACBPR-0:acBarMMTelVideoOcAutoMin:probFac=90%
...    LNBTS/ACBPR-0:acBarMMTelVideoOcAutoMin:barTime=8s
...    LNBTS/ACBPR-0:acBarMMTelVideoOcAutoMax:barTime=8s
...    LNBTS/ACBPR-0:acBarMMTelVideoOcAutoMax:probFac=0%
...    LNBTS/ACBPR-0:acBarCsfbOcAutoMax:barAC=1
...    LNBTS/ACBPR-0:acBarCsfbOcAutoMax:barAC3=23
...    LNBTS/ACBPR-0:acBarCsfbOcAutoMax:barAC1=5
...    LNBTS/ACBPR-0:acBarCsfbOcAutoMax:barAC2=21
...    LNBTS/ACBPR-0:acBarCsfbOcAutoMin:probFac=90%
...    LNBTS/ACBPR-0:acBarCsfbOcAutoMin:barTime=8s
...    LNBTS/ACBPR-0:acBarCsfbOcAutoMax:probFac=0%
...    LNBTS/ACBPR-0:acBarCsfbOcAutoMax:barTime=8s

@{LTE2996_PARAMS_FOR_PLMN}
...    LNBTS:actAcBarringPlmn=false
#...    LNCEL:acbPrimaryPlmnProfileId=1
...    LNCEL/SIB-0:acbPlmnNumSteps=4
...    LNBTS/ACBPR-1:eCallAcBarredAuto=barred
...    LNBTS/ACBPR-1:cellResHoBlockPlmnAcbMax=notReserved
...    LNBTS/ACBPR-1:emerHoBlockPlmnAcbMax=false
...    LNBTS/ACBPR-1:acBarSigAutoMax:barAC=1
...    LNBTS/ACBPR-1:acBarSigAutoMax:barAC3=19
...    LNBTS/ACBPR-1:acBarSigAutoMax:barAC1=9
...    LNBTS/ACBPR-1:acBarSigAutoMax:barAC2=7
...    LNBTS/ACBPR-1:acBarSigAutoMax:probFac=0%
...    LNBTS/ACBPR-1:acBarSigAutoMax:barTime=8s
...    LNBTS/ACBPR-1:acBarSigAutoMin:probFac=90%
...    LNBTS/ACBPR-1:acBarSigAutoMin:barTime=8s
...    LNBTS/ACBPR-1:acBarOcAutoMax:barAC=1
...    LNBTS/ACBPR-1:acBarOcAutoMax:barAC3=19
...    LNBTS/ACBPR-1:acBarOcAutoMax:barAC1=9
...    LNBTS/ACBPR-1:acBarOcAutoMax:barAC2=7
...    LNBTS/ACBPR-1:acBarOcAutoMin:probFac=90%
...    LNBTS/ACBPR-1:acBarOcAutoMin:barTime=8s
...    LNBTS/ACBPR-1:acBarOcAutoMax:probFac=0%
...    LNBTS/ACBPR-1:acBarOcAutoMax:barTime=8s
...    LNBTS/ACBPR-1:acBarMMTelVoiceOcAutoMax:barAC=1
...    LNBTS/ACBPR-1:acBarMMTelVoiceOcAutoMax:barAC3=19
...    LNBTS/ACBPR-1:acBarMMTelVoiceOcAutoMax:barAC1=9
...    LNBTS/ACBPR-1:acBarMMTelVoiceOcAutoMax:barAC2=7
...    LNBTS/ACBPR-1:acBarMMTelVoiceOcAutoMin:probFac=90%
...    LNBTS/ACBPR-1:acBarMMTelVoiceOcAutoMin:barTime=8s
...    LNBTS/ACBPR-1:acBarMMTelVoiceOcAutoMax:probFac=0%
...    LNBTS/ACBPR-1:acBarMMTelVoiceOcAutoMax:barTime=8s
...    LNBTS/ACBPR-1:acBarMMTelVideoOcAutoMax:barAC=1
...    LNBTS/ACBPR-1:acBarMMTelVideoOcAutoMax:barAC3=19
...    LNBTS/ACBPR-1:acBarMMTelVideoOcAutoMax:barAC1=9
...    LNBTS/ACBPR-1:acBarMMTelVideoOcAutoMax:barAC2=7
...    LNBTS/ACBPR-1:acBarMMTelVideoOcAutoMin:probFac=90%
...    LNBTS/ACBPR-1:acBarMMTelVideoOcAutoMin:barTime=8s
...    LNBTS/ACBPR-1:acBarMMTelVideoOcAutoMax:barTime=8s
...    LNBTS/ACBPR-1:acBarMMTelVideoOcAutoMax:probFac=0%
...    LNBTS/ACBPR-1:acBarCsfbOcAutoMax:barAC=1
...    LNBTS/ACBPR-1:acBarCsfbOcAutoMax:barAC3=19
...    LNBTS/ACBPR-1:acBarCsfbOcAutoMax:barAC1=9
...    LNBTS/ACBPR-1:acBarCsfbOcAutoMax:barAC2=7
...    LNBTS/ACBPR-1:acBarCsfbOcAutoMin:probFac=90%
...    LNBTS/ACBPR-1:acBarCsfbOcAutoMin:barTime=8s
...    LNBTS/ACBPR-1:acBarCsfbOcAutoMax:probFac=0%
...    LNBTS/ACBPR-1:acBarCsfbOcAutoMax:barTime=8s
...    LNBTS/ACBPR-1:acBarSkipForMMTELVideo=true
...    LNBTS/ACBPR-1:acBarSkipForMMTELVoice=true
...    LNBTS/ACBPR-1:acBarSkipForSMS=false

@{Set_acbSkipTimer_0}
...    LNCEL/SIB-0:acbScTimer=0
...    LNCEL/SIB-0:acbSkipTimer=0
...    LNCEL/SIB-0:acbScStepDuration=2
...    LNCEL/SIB-0:acbECTimer=0
...    LNBTS/ACBPR-0:acbScEcBitmask=4
...    ${EMPTY}
...    LNBTS/ACBPR-0:acBarSigAutoMax:barAC3=23
...    LNBTS/ACBPR-0:acBarSigAutoMax:barAC2=21
...    LNBTS/ACBPR-0:acBarOcAutoMax:barAC3=23
...    LNBTS/ACBPR-0:acBarOcAutoMax:barAC2=21
...    LNBTS/ACBPR-0:acBarMMTelVoiceOcAutoMax:barAC3=23
...    LNBTS/ACBPR-0:acBarMMTelVoiceOcAutoMax:barAC2=21
...    LNBTS/ACBPR-0:acBarMMTelVideoOcAutoMax:barAC3=23
...    LNBTS/ACBPR-0:acBarMMTelVideoOcAutoMax:barAC2=21
...    LNBTS/ACBPR-0:acBarCsfbOcAutoMax:barAC3=23
...    LNBTS/ACBPR-0:acBarCsfbOcAutoMax:barAC2=21

*** Test Cases ***
LTE4627-A-d_ET_15_01_Common ACB triggered by RRC_ACB with step-wise SCs when acbSkipTimer acbECTimer and acbScTimer are 0
    [Tags]    RAN_4G    RAN_4G_TDD    CDRT    Author-pei.han
    Cell1 Block and Unblock
    Delta Commission Parameters    ${Set_acbSkipTimer_0}
    Attach 5 legacy UEs at cell1 and check Bar_State_AC3
    Detach 5 UEs and check FallBack_NoBar

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs
    Create Alias

Create Alias
    FOR    ${ue_id}    IN RANGE    1    5
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=5    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus

Modify Yaml
    Add Yaml      EPC/PGW
    ...    - id: 3
    ...    type: 'simulated'
    ...    apn: 'emergency.nsn.com'
    ...    emergency: 'on'
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1, trf_type: internal}
    ...     - {qci: 5, default: on, pdn: 3, trf_type: internal}
    ...     - {qci: 1, mbr_ul: 25, gbr_dl: 25, gbr_ul: 25, mbr_dl: 25, pdn: 1, priority: 1}
    ...     - {qci: 1, mbr_ul: 25, gbr_dl: 25, gbr_ul: 25, mbr_dl: 25, pdn: 3, priority: 1}
    FOR    ${ue_id}     IN RANGE    1    5
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_2
    END
	
Cell1 Block and Unblock
    [Arguments]    ${number}=1
    Block Cell${number}
    ${ret1}    Unblock Cell${number}

Attach 5 legacy UEs at cell1 and check Bar_State_AC3
    [Arguments]
    Execute Uex Command    ue_param id=1-5 supported_bands=38:true
    ${Bar_State_ACB_level_TH1}    catenate
    ...    ac-BarringForEmergency eq 'FALSE' and 
    ...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p90' and 
    ...                                         ac-BarringTime eq 's8' and 
    ...                                         ac-BarringForSpecialAC eq '0b00000') and
    ...    ac-BarringForMO-Data contains (ac-BarringFactor eq 'p90' and 
    ...                                   ac-BarringTime eq 's8' and 
    ...                                   ac-BarringForSpecialAC eq '0b00000') and
    ...    ssac-BarringForMMTEL-Voice-r9 contains (ac-BarringFactor eq 'p90' and 
    ...                                            ac-BarringTime eq 's8' and 
    ...                                            ac-BarringForSpecialAC eq '0b00000') and
    ...    ssac-BarringForMMTEL-Video-r9 contains (ac-BarringFactor eq 'p90' and 
    ...                                            ac-BarringTime eq 's8' and 
    ...                                            ac-BarringForSpecialAC eq '0b00000') and
    ...    ac-BarringForCSFB-r10 contains (ac-BarringFactor eq 'p90' and 
    ...                                    ac-BarringTime eq 's8' and 
    ...                                    ac-BarringForSpecialAC eq '0b00000') and
    ...    ac-BarringSkipForMMTELVoice-r12 eq 'true' and
    ...    ac-BarringSkipForMMTELVideo-r12 eq 'true'
    ${Bar_State_ACB_level_Max_Skip_EC_AC1}    catenate
    ...    ac-BarringForEmergency eq 'FALSE' and 
    ...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p00' and 
    ...                                         ac-BarringTime eq 's8' and 
    ...                                         ac-BarringForSpecialAC eq '0b10100') and
    ...    ac-BarringForMO-Data contains (ac-BarringFactor eq 'p00' and 
    ...                                   ac-BarringTime eq 's8' and 
    ...                                   ac-BarringForSpecialAC eq '0b10100') and
    ...    ssac-BarringForMMTEL-Voice-r9 contains (ac-BarringFactor eq 'p00' and 
    ...                                            ac-BarringTime eq 's8' and 
    ...                                            ac-BarringForSpecialAC eq '0b10001') and
    ...    ssac-BarringForMMTEL-Video-r9 contains (ac-BarringFactor eq 'p00' and 
    ...                                            ac-BarringTime eq 's8' and 
    ...                                            ac-BarringForSpecialAC eq '0b10100') and
    ...    ac-BarringForCSFB-r10 contains (ac-BarringFactor eq 'p00' and 
    ...                                    ac-BarringTime eq 's8' and 
    ...                                    ac-BarringForSpecialAC eq '0b10100')
    ${Bar_State_AC_Bar_AC2}    catenate
    ...    ac-BarringForEmergency eq 'FALSE' and 
    ...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p00' and 
    ...                                         ac-BarringTime eq 's8' and 
    ...                                         ac-BarringForSpecialAC eq '0b10101') and
    ...    ac-BarringForMO-Data contains (ac-BarringFactor eq 'p00' and 
    ...                                   ac-BarringTime eq 's8' and 
    ...                                   ac-BarringForSpecialAC eq '0b10101') and
    ...    ssac-BarringForMMTEL-Voice-r9 contains (ac-BarringFactor eq 'p00' and 
    ...                                            ac-BarringTime eq 's8' and 
    ...                                            ac-BarringForSpecialAC eq '0b10101') and
    ...    ssac-BarringForMMTEL-Video-r9 contains (ac-BarringFactor eq 'p00' and 
    ...                                            ac-BarringTime eq 's8' and 
    ...                                            ac-BarringForSpecialAC eq '0b10101') and
    ...    ac-BarringForCSFB-r10 contains (ac-BarringFactor eq 'p00' and 
    ...                                    ac-BarringTime eq 's8' and 
    ...                                    ac-BarringForSpecialAC eq '0b10101')
    ${Bar_State_AC_Bar_AC3}    catenate
    ...    ac-BarringForEmergency eq 'TRUE' and 
    ...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p00' and 
    ...                                         ac-BarringTime eq 's8' and 
    ...                                         ac-BarringForSpecialAC eq '0b11101') and
    ...    ac-BarringForMO-Data contains (ac-BarringFactor eq 'p00' and 
    ...                                   ac-BarringTime eq 's8' and 
    ...                                   ac-BarringForSpecialAC eq '0b11101') and
    ...    ssac-BarringForMMTEL-Voice-r9 contains (ac-BarringFactor eq 'p00' and 
    ...                                            ac-BarringTime eq 's8' and 
    ...                                            ac-BarringForSpecialAC eq '0b11101') and
    ...    ssac-BarringForMMTEL-Video-r9 contains (ac-BarringFactor eq 'p00' and 
    ...                                            ac-BarringTime eq 's8' and 
    ...                                            ac-BarringForSpecialAC eq '0b11101') and
    ...    ac-BarringForCSFB-r10 contains (ac-BarringFactor eq 'p00' and 
    ...                                    ac-BarringTime eq 's8' and 
    ...                                    ac-BarringForSpecialAC eq '0b11101')
    Expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType2 ( ${Bar_State_ACB_level_TH1} )
    ...    CELL_1:RRC_SystemInformationBlockType2 ( ${Bar_State_ACB_level_Max_Skip_EC_AC1} )
    ...    CELL_1:RRC_SystemInformationBlockType2 ( ${Bar_State_AC_Bar_AC2} )
    ...    CELL_1:RRC_SystemInformationBlockType2 ( ${Bar_State_AC_Bar_AC3} )
    ...    alias=After_5_UEs_attach    overall_timeout=500
    FOR    ${ue_id}    IN RANGE    1    5
        Execute Uex Command    ue_attach id=${ue_id} enb=1 cell=1
    END
    Execute Uex Command    ue_attach id=5 enb=1 cell=1
    Flow Occurred As Expected    alias=After_5_UEs_attach

Detach 5 UEs and check FallBack_NoBar
    ${fallback_to_barAC2}    catenate
    ...    ac-BarringForEmergency eq 'FALSE' and 
    ...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p00' and 
    ...                                         ac-BarringTime eq 's8' and 
    ...                                         ac-BarringForSpecialAC eq '0b10101') and
    ...    ac-BarringForMO-Data contains (ac-BarringFactor eq 'p00' and 
    ...                                   ac-BarringTime eq 's8' and 
    ...                                   ac-BarringForSpecialAC eq '0b10101') and
    ...    ssac-BarringForMMTEL-Voice-r9 contains (ac-BarringFactor eq 'p00' and 
    ...                                            ac-BarringTime eq 's8' and 
    ...                                            ac-BarringForSpecialAC eq '0b10101') and
    ...    ssac-BarringForMMTEL-Video-r9 contains (ac-BarringFactor eq 'p00' and 
    ...                                            ac-BarringTime eq 's8' and 
    ...                                            ac-BarringForSpecialAC eq '0b10101') and
    ...    ac-BarringForCSFB-r10 contains (ac-BarringFactor eq 'p00' and 
    ...                                    ac-BarringTime eq 's8' and
    ...                                    ac-BarringForSpecialAC eq '0b10101')
    ${fallback_to_barAC1}    catenate
    ...    ac-BarringForEmergency eq 'FALSE' and 
    ...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p00' and 
    ...                                         ac-BarringTime eq 's8' and 
    ...                                         ac-BarringForSpecialAC eq '0b10100') and
    ...    ac-BarringForMO-Data contains (ac-BarringFactor eq 'p00' and 
    ...                                   ac-BarringTime eq 's8' and 
    ...                                   ac-BarringForSpecialAC eq '0b10100') and
    ...    ssac-BarringForMMTEL-Voice-r9 contains (ac-BarringFactor eq 'p00' and 
    ...                                            ac-BarringTime eq 's8' and 
    ...                                            ac-BarringForSpecialAC eq '0b10001') and
    ...    ssac-BarringForMMTEL-Video-r9 contains (ac-BarringFactor eq 'p00' and 
    ...                                            ac-BarringTime eq 's8' and 
    ...                                            ac-BarringForSpecialAC eq '0b10100') and
    ...    ac-BarringForCSFB-r10 contains (ac-BarringFactor eq 'p00' and 
    ...                                    ac-BarringTime eq 's8' and 
    ...                                    ac-BarringForSpecialAC eq '0b10100')
    ${fallback_to_barAC_ac-BarringForEmergency_TRUE}    catenate
    ...    ac-BarringForEmergency eq 'TRUE' and 
    ...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p00' and 
    ...                                         ac-BarringTime eq 's8' and 
    ...                                         ac-BarringForSpecialAC eq '0b10000') and
    ...    ssac-BarringForMMTEL-Voice-r9 contains (ac-BarringFactor eq 'p00' and 
    ...                                            ac-BarringTime eq 's8' and 
    ...                                            ac-BarringForSpecialAC eq '0b10000') and
    ...    ssac-BarringForMMTEL-Video-r9 contains (ac-BarringFactor eq 'p00' and 
    ...                                            ac-BarringTime eq 's8' and 
    ...                                            ac-BarringForSpecialAC eq '0b10000') and
    ...    ac-BarringForCSFB-r10 contains (ac-BarringFactor eq 'p00' and 
    ...                                    ac-BarringTime eq 's8' and 
    ...                                    ac-BarringForSpecialAC eq '0b10000')
    ${ac-BarringForEmergency_FALSE}    catenate
    ...    ac-BarringForEmergency eq 'FALSE' and 
    ...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p00' and 
    ...                                         ac-BarringTime eq 's8' and 
    ...                                         ac-BarringForSpecialAC eq '0b10000') and
    ...    ssac-BarringForMMTEL-Voice-r9 contains (ac-BarringFactor eq 'p00' and 
    ...                                            ac-BarringTime eq 's8' and 
    ...                                            ac-BarringForSpecialAC eq '0b10000') and
    ...    ssac-BarringForMMTEL-Video-r9 contains (ac-BarringFactor eq 'p00' and 
    ...                                            ac-BarringTime eq 's8' and 
    ...                                            ac-BarringForSpecialAC eq '0b10000') and
    ...    ac-BarringForCSFB-r10 contains (ac-BarringFactor eq 'p00' and 
    ...                                    ac-BarringTime eq 's8' and 
    ...                                    ac-BarringForSpecialAC eq '0b10000')
    ${ac-BarringSkip+barAC_MAX}    catenate
    ...    ac-BarringForEmergency eq 'FALSE' and 
    ...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p00' and 
    ...                                         ac-BarringTime eq 's8' and 
    ...                                         ac-BarringForSpecialAC eq '0b10000') and
    ...    ssac-BarringForMMTEL-Voice-r9 contains (ac-BarringFactor eq 'p00' and 
    ...                                            ac-BarringTime eq 's8' and 
    ...                                            ac-BarringForSpecialAC eq '0b10000') and
    ...    ssac-BarringForMMTEL-Video-r9 contains (ac-BarringFactor eq 'p00' and 
    ...                                            ac-BarringTime eq 's8' and 
    ...                                            ac-BarringForSpecialAC eq '0b10000') and
    ...    ac-BarringForCSFB-r10 contains (ac-BarringFactor eq 'p00' and 
    ...                                    ac-BarringTime eq 's8' and 
    ...                                    ac-BarringForSpecialAC eq '0b10000') and
    ...    ac-BarringSkipForMMTELVoice-r12 eq 'true' and
    ...    ac-BarringSkipForMMTELVideo-r12 eq 'true'
    ${ac-Barring_TH1}    catenate
    ...    ac-BarringForEmergency eq 'FALSE' and  
    ...    ac-BarringForMO-Signalling contains (ac-BarringFactor eq 'p90' and 
    ...                                         ac-BarringTime eq 's8' and 
    ...                                         ac-BarringForSpecialAC eq '0b00000') and
    ...    ssac-BarringForMMTEL-Voice-r9 contains (ac-BarringFactor eq 'p90' and 
    ...                                            ac-BarringTime eq 's8' and 
    ...                                            ac-BarringForSpecialAC eq '0b00000') and
    ...    messagePowerOffsetGroupB eq 'dB10' and
    ...    ssac-BarringForMMTEL-Video-r9 contains (ac-BarringFactor eq 'p90' and 
    ...                                            ac-BarringTime eq 's8' and 
    ...                                            ac-BarringForSpecialAC eq '0b00000') and
    ...    ac-BarringForCSFB-r10 contains (ac-BarringFactor eq 'p90' and 
    ...                                    ac-BarringTime eq 's8' and 
    ...                                    ac-BarringForSpecialAC eq '0b00000') and
    ...    ac-BarringSkipForMMTELVoice-r12 eq 'true' and
    ...    ac-BarringSkipForMMTELVideo-r12 eq 'true'
    Expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType2 ( ${fallback_to_barAC2} )
    ...    CELL_1:RRC_SystemInformationBlockType2 ( ${fallback_to_barAC1} )
    ...    CELL_1:RRC_SystemInformationBlockType2 ( ${fallback_to_barAC_ac-BarringForEmergency_TRUE} )
    ...    CELL_1:RRC_SystemInformationBlockType2 ( ${ac-BarringForEmergency_FALSE} )
    ...    CELL_1:RRC_SystemInformationBlockType2 ( ${ac-BarringSkip+barAC_MAX} )
    ...    CELL_1:RRC_SystemInformationBlockType2 ( ${ac-Barring_TH1} )
    ...    alias=After_5_UEs_detach    overall_timeout=800
    FOR    ${ue_id}    IN RANGE    1    6
        Execute Uex Command    ue_detach id=${ue_id}
    END
    Sleep    300s    Wait_For_Downgrade
    comment    Sleep=acbScStepDuration+acbScStepDuration+acbScStepDuration+acbUpdateTimer+acbUpdateTimer+acbUpdateTimer+acbUpdateTimer
    Flow Occurred As Expected    alias=After_5_UEs_detach
