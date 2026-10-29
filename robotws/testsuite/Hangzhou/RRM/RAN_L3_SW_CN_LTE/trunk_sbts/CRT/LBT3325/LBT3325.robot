*** Settings ***
Documentation     Verification of Test Case I.LBT3325.002 correct application of DRX in case different RF channel quality condition events inter-act
...               with different procedures like re-establishment, intra-cell HO, out of sync and intra-eNB HO events.
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO
...               DevHZ5_FV    owner-zhiwen.bu,ying.shang
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS-1:actCSFBRedir=Enabled
...    LNBTS-1:actCsfbPsHoToUtra=true
...    LNBTS-1:act8EpsBearers=true
...    LNBTS-1:actHOtoWcdma=true
...    LNBTS-1:actRedirect=disabled
...    LNBTS-1:anrOmExtEnable=true
...    LNBTS-1:enableBwCombCheck=false
...    LNBTS-1:maxNumOfLnadjLimit=256
...    LNBTS-1:actOperatorQCI=true
...    LNBTS-1:actOperatorQCIGBR=true
...    LNBTS-1:actQCIPLMNIDProfiles=false
...    LNBTS-1:actS1OlHandling=true
...    LNBTS-1:geranDtmCap=true
...    LNBTS-1:multScellReleaseTimer=5
...    LNBTS-1:tS1RelPrepL=500
...    LNBTS-1:tS1RelPrepU=1000
...    LNBTS-1:tX2RelocPrep=500
...    LNBTS-1/ANR-0:minNotActivatedUtraRSCFS=1440
...    LNBTS-1/LNCEL-1:a1TimeToTriggerDeactInterMeas=100ms
...    LNBTS-1/LNCEL-1:a2TimeToTriggerActInterFreqMeas=100ms
...    LNBTS-1/LNCEL-1:a2TimeToTriggerActWcdmaMeas=0ms
...    LNBTS-1/LNCEL-1:defaultLnRelGnbCellId=${EMPTY}
...    LNBTS-1/LNCEL-1:a3Offset=12
...    LNBTS-1/LNCEL-1:a3ReportInterval=1024ms
...    LNBTS-1/LNCEL-1:a3TimeToTrigger=1280ms
...    LNBTS-1/LNCEL-1:a3TriggerQuantityHO=RSRP
...    LNBTS-1/LNCEL-1:a5ReportInterval=640ms
...    LNBTS-1/LNCEL-1:a5TimeToTrigger=1280ms
...    LNBTS-1/LNCEL-1:act3fdd3tddRestrict=false
...    LNBTS-1/LNCEL-1:enableLowAgg=false
...    LNBTS-1/LNCEL:enablePcPdcch=true
...    LNBTS-1/LNCEL-3:a1TimeToTriggerDeactInterMeas=100ms
...    LNBTS-1/LNCEL-3:a2TimeToTriggerActInterFreqMeas=100ms
...    LNBTS-1/LNCEL-3:a2TimeToTriggerActWcdmaMeas=0ms
...    LNBTS-1/LNCEL-3:defaultLnRelGnbCellId=${EMPTY}
...    LNBTS-1/LNCEL-3:a3Offset=12
...    LNBTS-1/LNCEL-3:a3ReportInterval=1024ms
...    LNBTS-1/LNCEL-3:a3TimeToTrigger=1280ms
...    LNBTS-1/LNCEL-3:a3TriggerQuantityHO=RSRP
...    LNBTS-1/LNCEL-3:a5ReportInterval=640ms
...    LNBTS-1/LNCEL-3:a5TimeToTrigger=1280ms
...    LNBTS-1/LNCEL-3:act3fdd3tddRestrict=false
...    LNBTS-1/LNCEL-3:enableLowAgg=false
...    LNBTS-1/LNCEL-2:a1TimeToTriggerDeactInterMeas=2560ms
...    LNBTS-1/LNCEL-2:a2TimeToTriggerActInterFreqMeas=100ms
...    LNBTS-1/LNCEL-2:a2TimeToTriggerActWcdmaMeas=0ms
...    LNBTS-1/LNCEL-2:defaultLnRelGnbCellId=${EMPTY}
...    LNBTS-1/LNCEL-2:a3TimeToTrigger=100ms
...    LNBTS-1/LNCEL-2:a5TimeToTrigger=100ms
...    LNBTS-1/LNCEL-2:a3Offset=12
...    LNBTS-1/LNCEL-2:a3ReportInterval=1024ms
...    LNBTS-1/LNCEL-2:a3TriggerQuantityHO=RSRP
...    LNBTS-1/LNCEL-2:a5ReportInterval=640ms
...    LNBTS-1/LNCEL-2:act3fdd3tddRestrict=false
...    LNBTS-1/LNCEL-2:enableLowAgg=false
...    LNCEL-1/LNHOW-1:b1TimeToTriggerCSFBUtraMeas=80ms
...    LNCEL-1/LNHOW-1:b2Threshold1Utra=57
...    LNCEL-1/LNHOW-1:b2Threshold2UtraRscp=60
...    LNCEL-1/LNHOW-1:b2TimeToTriggerUtraMeas=480ms
...    LNCEL-1/LNHOW-1:hysB2ThresholdUtra=0
...    LNCEL-1/LNHOW-1:offsetFreqUtra=0
...    LNCEL-1/LNHOW-1:reportIntervalUtra=2048ms
...    LNCEL-1/LNHOW-1:utraCarrierFreq=9692
...    LNCEL-1/LNHOW-2:b1TimeToTriggerCSFBUtraMeas=80ms
...    LNCEL-1/LNHOW-2:b2Threshold1Utra=57
...    LNCEL-1/LNHOW-2:b2Threshold2UtraRscp=60
...    LNCEL-1/LNHOW-2:b2TimeToTriggerUtraMeas=480ms
...    LNCEL-1/LNHOW-2:hysB2ThresholdUtra=0
...    LNCEL-1/LNHOW-2:offsetFreqUtra=0
...    LNCEL-1/LNHOW-2:reportIntervalUtra=2048ms
...    LNCEL-1/LNHOW-2:utraCarrierFreq=9842
...    LNCEL-2/LNHOW-0:utraCarrierFreq=10592
...    LNCEL-2/LNHOW-1:b1TimeToTriggerCSFBUtraMeas=80ms
...    LNCEL-2/LNHOW-1:b2Threshold1Utra=57
...    LNCEL-2/LNHOW-1:b2Threshold2UtraRscp=60
...    LNCEL-2/LNHOW-1:b2TimeToTriggerUtraMeas=480ms
...    LNCEL-2/LNHOW-1:hysB2ThresholdUtra=0
...    LNCEL-2/LNHOW-1:offsetFreqUtra=0
...    LNCEL-2/LNHOW-1:reportIntervalUtra=2048ms
...    LNCEL-2/LNHOW-1:utraCarrierFreq=9692
...    LNCEL-2/LNHOW-2:b1TimeToTriggerCSFBUtraMeas=80ms
...    LNCEL-2/LNHOW-2:b2Threshold1Utra=57
...    LNCEL-2/LNHOW-2:b2Threshold2UtraRscp=60
...    LNCEL-2/LNHOW-2:b2TimeToTriggerUtraMeas=480ms
...    LNCEL-2/LNHOW-2:hysB2ThresholdUtra=0
...    LNCEL-2/LNHOW-2:offsetFreqUtra=0
...    LNCEL-2/LNHOW-2:reportIntervalUtra=2048ms
...    LNCEL-2/LNHOW-2:utraCarrierFreq=9842
...    LNCEL-3/LNHOW-0:b1TimeToTriggerCSFBUtraMeas=80ms
...    LNCEL-3/LNHOW-0:b2Threshold1Utra=57
...    LNCEL-3/LNHOW-0:b2Threshold2UtraRscp=60
...    LNCEL-3/LNHOW-0:b2TimeToTriggerUtraMeas=480ms
...    LNCEL-3/LNHOW-0:hysB2ThresholdUtra=0
...    LNCEL-3/LNHOW-0:offsetFreqUtra=0
...    LNCEL-3/LNHOW-0:reportIntervalUtra=2048ms
...    LNCEL-3/LNHOW-0:utraCarrierFreq=10592
...    LNCEL-3/LNHOW-1:b1TimeToTriggerCSFBUtraMeas=80ms
...    LNCEL-3/LNHOW-1:b2Threshold1Utra=57
...    LNCEL-3/LNHOW-1:b2Threshold2UtraRscp=60
...    LNCEL-3/LNHOW-1:b2TimeToTriggerUtraMeas=480ms
...    LNCEL-3/LNHOW-1:hysB2ThresholdUtra=0
...    LNCEL-3/LNHOW-1:offsetFreqUtra=0
...    LNCEL-3/LNHOW-1:reportIntervalUtra=2048ms
...    LNCEL-3/LNHOW-1:utraCarrierFreq=9692
...    LNCEL-3/LNHOW-2:b1TimeToTriggerCSFBUtraMeas=80ms
...    LNCEL-3/LNHOW-2:b2Threshold1Utra=57
...    LNCEL-3/LNHOW-2:b2Threshold2UtraRscp=60
...    LNCEL-3/LNHOW-2:b2TimeToTriggerUtraMeas=480ms
...    LNCEL-3/LNHOW-2:hysB2ThresholdUtra=0
...    LNCEL-3/LNHOW-2:offsetFreqUtra=0
...    LNCEL-3/LNHOW-2:reportIntervalUtra=2048ms
...    LNCEL-3/LNHOW-2:utraCarrierFreq=9842
...    LNCEL-3/LNHOW-3:b1TimeToTriggerCSFBUtraMeas=80ms
...    LNCEL-3/LNHOW-3:b2Threshold1Utra=57
...    LNCEL-3/LNHOW-3:b2Threshold2UtraRscp=60
...    LNCEL-3/LNHOW-3:b2TimeToTriggerUtraMeas=480ms
...    LNCEL-3/LNHOW-3:hysB2ThresholdUtra=0
...    LNCEL-3/LNHOW-3:offsetFreqUtra=0
...    LNCEL-3/LNHOW-3:reportIntervalUtra=2048ms
...    LNCEL-3/LNHOW-3:utraCarrierFreq=1192
#LNBTS-1:supportedNumOfAnrMoi=4000 | LNBTS-1:supportedNumOfLnadj=256
@{Precondition}
...    LNBTS-1:actHOtoWcdma=false
...    LNBTS-1:qciTab1:delayTarget=80ms
...    LNBTS-1:qciTab1:schedulPrio=5
...    LNBTS-1:qciTab1:lcgid=1
...    LNBTS-1:qciTab1:dscp=46
...    LNBTS-1:qciTab1:pdcpProfIdx=101
...    LNBTS-1:qciTab1:prio=20
...    LNBTS-1:qciTab1:qci=1
...    LNBTS-1:qciTab1:qciSupp=ENABLE
...    LNBTS-1:qciTab1:resType=GBR
...    LNBTS-1:qciTab1:rlcMode=RLC_UM
...    LNBTS-1:qciTab1:rlcProfIdx=101
...    LNBTS-1:qciTab1:drxProfileIndex=2
...    LNBTS-1:qciTab1:schedulBSD=100ms
...    LNBTS-1:qciTab1:maxGbrDl=36
...    LNBTS-1:qciTab1:maxGbrUl=36
...    LNBTS-1:qciTab1:enforceTtiBundling=true
...    LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=false
...    LNBTS-1/LNCEL-1:a3Offset=0
...    LNBTS-1/LNCEL-1:a3TimeToTrigger=480ms
...    LNBTS-1/LNCEL-1:threshold2InterFreq=68
...    LNBTS-1/LNCEL-1:threshold2a=72
...    LNBTS-1/LNCEL-1:actDrx=true
...    LNBTS-1/LNCEL-1:actDrxDuringMeasGap=true
...    LNBTS-1/LNCEL-2:threshold2InterFreq=68
...    LNBTS-1/LNCEL-2:threshold2a=72
...    LNBTS-1/LNCEL-2:actDrx=true
...    LNBTS-1/LNCEL-2:actDrxDuringMeasGap=true
@{Case1_Delta_Commission_1}
...  LNBTS-1:actIfHo=enabled
...  LNBTS-1:qciTab6:schedulWeight=20
...  LNBTS-1:qciTab6:schedulPrio=9
...  LNBTS-1:qciTab6:lcgid=3
...  LNBTS-1:qciTab6:dscp=18
...  LNBTS-1:qciTab6:pdcpProfIdx=2
...  LNBTS-1:qciTab6:prio=60
...  LNBTS-1:qciTab6:qci=6
...  LNBTS-1:qciTab6:qciSupp=ENABLE
...  LNBTS-1:qciTab6:resType=nonGBR
...  LNBTS-1:qciTab6:rlcMode=RLC_AM
...  LNBTS-1:qciTab6:rlcProfIdx=2
...  LNBTS-1:qciTab6:rlcProfIdx3cc=6
...  LNBTS-1:qciTab6:rlcProfIdx4cc5cc=7
...  LNBTS-1:qciTab6:drxProfileIndex=3
...  LNBTS-1:qciTab6:schedulBSD=300ms
...  LNBTS-1:qciTab6:enforceTtiBundling=false
...  LNBTS-1/LNCEL-1:actQci1RfDrx=true
...  LNBTS-1/LNCEL-1/DRX-0:qci1DrxOnThreshold=132
...  LNBTS-1/LNCEL-1/DRX-0:qci1DrxOffThreshold=130
@{Decommission_parameter}
...    delete:LNREL.*
...    delete:LNADJ.*
...    delete:LNCEL-1/LNHOW-3
...    delete:LNCEL-1/LNHOW-0
...    delete:LNCEL-2/LNHOW-3
...    delete:LNCEL-2/LNHOW-0

*** Test Cases ***
LBT3325_002_01_IF-HO enabled_LBT3325 enabled
    [Documentation]    Test Case for feature "LBT3325_002" for WMP eNB Testlines
    ...    original case2
    ...    IF-HO enabled, LBT3325 enabled, re-establishment inter-action
    [Tags]    TC01
    Configuration Parameter one time    instance=1
    CQI lowThr    ue_id=2
    UE Attach    ue_id=2
    Report Inter-freq A2    ue_id=2
    Trigger ReEstablishment    ue_id=2
    CQI_Higher    ue_id=2
    Deleted Bearer QCI_1_5    ue_id=2    qci1=2    qci2=6
    UE Detach    ue_id=2

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Execute Egate Command    trace_sim on mme=1 protocol=s1
    Execute Egate Command    trace uec=1 protocol=rrc on
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 2, gbr_ul: 144, gbr_dl: 144, mbr_ul: 144, mbr_dl: 144, preprovisioned: on, default: off, filter: 1, precedence: 1, pdn: 1}
    ...     - {qci: 3, gbr_ul: 64, gbr_dl: 128, mbr_ul: 64, mbr_dl: 128, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 330, mbr_ul: 32, mbr_dl: 320, pdn: 1}
    ...     - {qci: 5, pdn: 1}
    ...     - {qci: 6, preprovisioned: on, default: off, filter: 2, precedence: 2, pdn: 1}
    ...     - {qci: 7, pdn: 1}
    ...     - {qci: 9, pdn: 1}
    ...     - {qci: 8, default: on, pdn: 2, trf_type: external}
    ...     - {qci: 6, pdn: 2}
    ...     - {qci: 7, pdn: 2}
    ...     - {qci: 9, pdn: 2}
    FOR    ${ue_set_id}     IN RANGE    1    11
        Update Yaml    UEs/UE_sets/${ue_set_id}    bearer: 'bearer_set_2'    release: '15'    nea: 'null'    nia: 'null'
    END

Configuration Parameter one time
    [Arguments]    ${instance}    ${Num1}=1    ${Num2}=2
    Delta Commission Parameters    ${Decommission_parameter}
    Delta Commission Parameters    ${Precondition}
    Cells Should Be OnAir
    Delta Commission Parameters    ${Case${instance}_Delta_Commission_${Num1}}

UE Attach
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(measGapConfig contains (release is present))
    ...    alias=measgaprelease_ue_attach    overall_timeout=20
    Execute Uex Command    ue_attach id=${ue_id} cell=1
    flow occurred as expected    alias=measgaprelease_ue_attach

UE Detach
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_detach id=${ue_id}

Report Inter-freq A2
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(gapOffset contains (gp0 eq 32))
    ...    alias=ue_send_A2    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=30 srsrq=15 amount=1
    flow occurred as expected    alias=ue_send_A2

Trigger ReEstablishment
    [Arguments]    ${ue_id}=1
    ${reestablish_RRCReconfig}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((measIdToRemoveList contains (1,2,3,30,31,32)) and (gp0 eq 32) and
    ...    (onDurationTimer eq "psf6") and (drx-InactivityTimer eq "psf4")
    ...    and (drx-RetransmissionTimer eq "psf4") and (sf40 eq 3)) as reestablish_RRCReconfig
    expect message flow
    ...    ${reestablish_RRCReconfig}
    ...    alias=ue_reestablish    overall_timeout=20
    Execute Uex Command    ue_rrc_reestablish id=${ue_id} cell=1 cause=otherFailure
    Flow Occurred As Expected    alias=ue_reestablish

CQI lowThr
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_cqi_param id=${ue_id} wb=5:5:0
    wait for cqi modify success

CQI_Higher
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_cqi_param id=${ue_id} wb=15:15:0
    wait for cqi modify success

Deleted Bearer QCI_1_5
    [Arguments]    ${ue_id}=1    ${qci1}=2    ${qci2}=6
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(drb-ToReleaseList contains (5))
    ...    MME_1:S1AP_E-RABReleaseResponse (E-RABReleaseListBearerRelComp contains (e-RAB-ID eq 6))
    ...    alias=bearer_del_qci1    overall_timeout=20
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(drb-ToReleaseList contains (6))
    ...    MME_1:S1AP_E-RABReleaseResponse (E-RABReleaseListBearerRelComp contains (e-RAB-ID eq 7))
    ...    alias=bearer_del_qci2    overall_timeout=20
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci1}
    flow occurred as expected    alias=bearer_del_qci1
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci2}
    flow occurred as expected    alias=bearer_del_qci2
    wait for bearer modify success

wait for bearer modify success
    sleep    5s

wait for cqi modify success
    sleep    5s
