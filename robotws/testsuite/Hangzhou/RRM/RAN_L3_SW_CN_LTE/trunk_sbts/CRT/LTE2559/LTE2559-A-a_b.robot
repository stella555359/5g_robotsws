*** Settings ***
Suite Setup       Common Suite Setup and Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Testcase Setup For Set One Normal UE
Test Teardown     Testcase Teardown For Recover Normal UE
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO    team-SG4
...               owner-chao.3.zhang    release-SBTS18
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{ACTIVE_RLF_BASED_RRC_CONNECTION_REESTABLISHMENT}
...    @{QCI_FOR_LTE2559}
...    @{LIMITED_RADIO_RESOURCES}
...    @{ACTIVATE_S1_UTRAN_HO}
...    @{ACTIVE_LTE2559_AND_LTE534}
...    @{BEAR_PARAMS}
...    @{HO_PARAMS}
...    LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnChBw=10 MHz
@{ACTIVE_LTE2559_AND_LTE534}
...    LNBTS:actOperatorQCIGBR=true
...    LNBTS:actOperatorQCI=true
...    LNBTS:actPartialAcHo=true
@{LIMITED_RADIO_RESOURCES}
...    LNCEL-1/LNCEL_FDD-0:addNumDrbRadioReasHo=0
...    LNCEL-1/LNCEL_FDD-0:addNumDrbTimeCriticalHo=0
...    LNCEL-1/LNCEL_FDD-0:addNumQci1DrbRadioReasHo=0
...    LNCEL-1/LNCEL_FDD-0:addNumQci1DrbTimeCriticalHo=0
...    LNCEL-1/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-1/LNCEL_FDD-0:maxNumActDrb=6
...    LNCEL-1/LNCEL_FDD-0:maxNumActUE=3
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe=0
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe3c=0
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUeDc=0
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=0
...    LNBTS/LNCEL-1:maxGbrTrafficLimit=30
...    LNBTS/LNCEL-1:addGbrTrafficRrHo=0
...    LNBTS/LNCEL-1:addGbrTrafficTcHo=0
...    LNCEL/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:ulChBw=10 MHz
@{ACTIVE_RLF_BASED_RRC_CONNECTION_REESTABLISHMENT}
...    LNBTS:actRLFbasedRCR=true
...    LNBTS-1/LNCEL:t301Guard=100
...    LNBTS-1/LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNBTS-1/LNADJ-1:rlfBasedRCRsupported=true
...    LNBTS-1/LNADJ-1:cPlaneIpAddr=10.0.1.5
...    LNBTS-1/LNADJ-1:adjEnbId=2
...    LNBTS-1/LNADJ-1:plmnId:mcc=262
...    LNBTS-1/LNADJ-1:plmnId:mnc=3
...    LNBTS-1/LNADJ-1:plmnId:mncLength=2
@{ACTIVATE_S1_UTRAN_HO}
...    LNBTS:actHoFromUtran=true
@{HO_PARAMS}
...    LNBTS:actQCIPLMNIDProfiles=false
...    LNBTS/LNBTS_FDD-0:actInterFreqServiceBasedHo=true
...    LNBTS-1/LNCEL:iFServiceBasedHoRetryTimer=60
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1500
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19500
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19600
...    LNCEL-1:actInterFreqLB=true
...    LNCEL-2:actInterFreqLB=true
...    LNCEL-1:iFLBLoadThresholds:iFLBBearCheckTimer=12
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadGBRDL=100
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=100
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadPdcch=100
...    LNCEL-1:iFLBLoadThresholds:iFLBRetryTimer=120
...    LNCEL-1:loadSettings:nomNumPrbNonGbr=0.01
...    LNCEL-1:loadSettings:targetLoadGbrDl=100
...    LNCEL-1:loadSettings:targetLoadNonGbrDl=100
...    LNCEL-1:loadSettings:targetLoadPdcch=100
...    LNCEL-2:iFLBLoadThresholds:iFLBBearCheckTimer=0
...    LNCEL-2:iFLBLoadThresholds:iFLBHighLoadGBRDL=0
...    LNCEL-2:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=0
...    LNCEL-2:iFLBLoadThresholds:iFLBHighLoadPdcch=0
...    LNCEL-2:iFLBLoadThresholds:iFLBRetryTimer=20
...    LNCEL-2:loadSettings:nomNumPrbNonGbr=0.01
...    LNCEL-2:loadSettings:targetLoadGbrDl=0
...    LNCEL-2:loadSettings:targetLoadNonGbrDl=0
...    LNCEL-2:loadSettings:targetLoadPdcch=0
...    delete:LNCEL:intraFreqLbLoadThresholds
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=1400
...    LNBTS/MODPR-0:autoAdapt=false
...    LNBTS/MODPR-0:autoAdaptIMLB=true
...    LNBTS/MODPR-0:freqLayListDedVoLteHo=1400
...    LNBTS/MODPR-0:freqLayListLte=1400
...    LNBTS/MODPR-0:freqLayListServiceBasedHo=1400
...    LNBTS/MOPR-0:freqLayListDedVoLteHo=1400
...    LNBTS/MOPR-0:freqLayListLte=1400
...    LNBTS/MOPR-0:freqLayListServiceBasedHo=1400
...    LNCEL-2/LNHOIF-1:thresholdRsrqIFLBFilter=-120
...    LNCEL-2/LNHOIF-1:thresholdRsrpIFLBFilter=-120
...    LNCEL:iFLBA4ActLim=20
...    LNCEL:actServRlqInterFreqLB=false
...    LNCEL-1/LNREL-1:cellIndOffNeigh=0dB
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1500
@{BEAR_PARAMS}
...    LNBTS:imsEmerPlmnConfig:emerSessArpPreemCap=false
...    LNBTS:imsEmerPlmnConfig:emerSessArpPreemVul=false
...    LNBTS:imsEmerPlmnConfig:emerSessArpPrioLev=2
...    LNBTS:imsEmerPlmnConfig:emerSessLimServ=false
...    LNBTS/LNBTS_FDD-0:actIMSEmerSessR9=true
...    LNBTS:qciTab1:maxGbrDl=31
...    LNBTS:qciTab1:maxGbrUl=31
...    LNBTS:qciTab2:maxGbrDl=2048
...    LNBTS:qciTab2:maxGbrUl=840
...    LNBTS:qciTab3:maxGbrDl=2048
...    LNBTS:qciTab3:maxGbrUl=840
...    LNBTS:qciTab4:maxGbrDl=2048
...    LNBTS:qciTab4:maxGbrUl=840
@{QCI_FOR_LTE2559}
...    @{QCI_192}
...    @{QCI_193}
...    @{QCI_165}
...    @{QCI_166}
...    @{QCI_167}
...    @{QCI_168}
...    @{QCI_180}
...    @{QCI_181}
...    @{QCI_182}
...    @{QCI_183}
...    @{QCI_8}
@{QCI_8}
...    LNBTS:qciTab8:qciSupp=DISABLE
@{QCI_192}
...    LNBTS:qciTabOperator:lcgid=1|qci=192
...    LNBTS:qciTabOperator:resType=GBR|qci=192
...    LNBTS:qciTabOperator:rlcMode=RLC_AM|qci=192
...    LNBTS:qciTabOperator:pdcpProfIdx=1|qci=192
...    LNBTS:qciTabOperator:maxGbrDl=2048|qci=192
...    LNBTS:qciTabOperator:maxGbrUl=2048|qci=192
...    LNBTS:qciTabOperator:prio=30|qci=192
...    LNBTS:qciTabOperator:gbrOverbookingFactor=1|qci=192
@{QCI_193}
...    LNBTS:qciTabOperator:lcgid=2|qci=193
...    LNBTS:qciTabOperator:resType=nonGBR|qci=193
...    LNBTS:qciTabOperator:rlcMode=RLC_AM|qci=193
...    LNBTS:qciTabOperator:pdcpProfIdx=1|qci=193
@{QCI_165}
...    LNBTS:qciTabOperator:lcgid=1|qci=165
...    LNBTS:qciTabOperator:resType=GBR|qci=165
...    LNBTS:qciTabOperator:rlcMode=RLC_AM|qci=165
...    LNBTS:qciTabOperator:pdcpProfIdx=1|qci=165
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0|qci=165
...    LNBTS:qciTabOperator:maxGbrDl=2048|qci=165
...    LNBTS:qciTabOperator:maxGbrUl=2048|qci=165
...    LNBTS:qciTabOperator:dscp=0|qci=165
...    LNBTS:qciTabOperator:schedulPrio=2|qci=165
@{QCI_166}
...    LNBTS:qciTabOperator:lcgid=2|qci=166
...    LNBTS:qciTabOperator:resType=nonGBR|qci=166
...    LNBTS:qciTabOperator:rlcMode=RLC_AM|qci=166
...    LNBTS:qciTabOperator:pdcpProfIdx=1|qci=166
...    LNBTS:qciTabOperator:maxGbrDl=2048|qci=166
...    LNBTS:qciTabOperator:maxGbrUl=2048|qci=166
...    LNBTS:qciTabOperator:dscp=0|qci=166
...    LNBTS:qciTabOperator:schedulPrio=9|qci=166
@{QCI_167}
...    LNBTS:qciTabOperator:lcgid=1|qci=167
...    LNBTS:qciTabOperator:resType=GBR|qci=167
...    LNBTS:qciTabOperator:rlcMode=RLC_AM|qci=167
...    LNBTS:qciTabOperator:pdcpProfIdx=1|qci=167
...    LNBTS:qciTabOperator:gbrOverbookingFactor=1|qci=167
...    LNBTS:qciTabOperator:maxGbrDl=2048|qci=167
@{QCI_168}
...    LNBTS:qciTabOperator:lcgid=2|qci=168
...    LNBTS:qciTabOperator:resType=nonGBR|qci=168
...    LNBTS:qciTabOperator:rlcMode=RLC_AM|qci=168
...    LNBTS:qciTabOperator:pdcpProfIdx=1|qci=168
@{QCI_180}
...    LNBTS:qciTabOperator:lcgid=2|qci=180
...    LNBTS:qciTabOperator:resType=GBR|qci=180
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=180
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=180
...    LNBTS:qciTabOperator:maxGbrDl=1|qci=180
...    LNBTS:qciTabOperator:maxGbrUl=1|qci=180
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=180
...    LNBTS:qciTabOperator:gbrOverbookingFactor=1|qci=180
@{QCI_181}
...    LNBTS:qciTabOperator:lcgid=2|qci=181
...    LNBTS:qciTabOperator:resType=GBR|qci=181
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=181
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=181
...    LNBTS:qciTabOperator:maxGbrDl=1|qci=181
...    LNBTS:qciTabOperator:maxGbrUl=1|qci=181
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=181
...    LNBTS:qciTabOperator:gbrOverbookingFactor=1|qci=181
@{QCI_182}
...    LNBTS:qciTabOperator:lcgid=2|qci=182
...    LNBTS:qciTabOperator:resType=GBR|qci=182
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=182
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=182
...    LNBTS:qciTabOperator:maxGbrDl=1|qci=182
...    LNBTS:qciTabOperator:maxGbrUl=1|qci=182
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=182
...    LNBTS:qciTabOperator:gbrOverbookingFactor=1|qci=182
@{QCI_183}
...    LNBTS:qciTabOperator:lcgid=2|qci=183
...    LNBTS:qciTabOperator:resType=GBR|qci=183
...    LNBTS:qciTabOperator:rlcMode=RLC_UM|qci=183
...    LNBTS:qciTabOperator:pdcpProfIdx=102|qci=183
...    LNBTS:qciTabOperator:maxGbrDl=1|qci=183
...    LNBTS:qciTabOperator:maxGbrUl=1|qci=183
...    LNBTS:qciTabOperator:rlcProfIdx=102|qci=183
...    LNBTS:qciTabOperator:gbrOverbookingFactor=1|qci=183
${SOURCE_ENB_ID_INTER_ENB}    2
${SOURCE_CELL_ID_INTER_ENB}    21
${SOURCE_ENB_ID_INTRA_ENB}    1
${SOURCE_CELL_ID_INTRA_ENB}    2
${TARGET_ENB_ID}    1
${TARGET_CELL_ID}    1
${TARGET_PHYCELL_ID}    1
${NON_EMER_UE_ID}    4
${OTHER_UE_ID}    5
${NON_PREEMPTABLE_BY_BCC_NON_QCI1_DB_ID}    5
${NON_PREEMPTING_BY_RAC_PRB_DB_ID}    7
${PREEMPTABLE_BY_RAC_DRB_DB_ID}    10
${PREEMPTABLE_BY_RAC_PRB_DB_ID_OTHER_UE}    14
${PREEMPTABLE_BY_RAC_DRB_DB_ID_OTHER_UE}    15
@{OTHER_UE_BEARER_LIST}
...    ${PREEMPTABLE_BY_RAC_PRB_DB_ID_OTHER_UE}
...    ${PREEMPTABLE_BY_RAC_DRB_DB_ID_OTHER_UE}
${LTE2559_PM_COUNTER_ID}    M8006C281
@{PM_COUNTERS_FOR_LTE2559}
...    LNCEL-1:LTE_EPS_Bearer:${LTE2559_PM_COUNTER_ID}=1
@{NON_PM_COUNTERS_FOR_LTE2559}
...    LNCEL-1:LTE_EPS_Bearer:${LTE2559_PM_COUNTER_ID}=0
${horequest_qci5_166_9_3}
...    E-RABToBeSetupListHOReq contains (
...    e-RAB-ID eq 5 and qCI eq 5,
...    e-RAB-ID eq 6 and qCI eq 166,
...    e-RAB-ID eq 7 and qCI eq 9,
...    e-RAB-ID eq 8 and qCI eq 3)
${hoack_qci5_9_3}
...    E-RABAdmittedList contains (e-RAB-ID eq 5,e-RAB-ID eq 7,e-RAB-ID eq 8) and
...    E-RABFailedtoSetupListHOReqAck contains (e-RAB-ID eq 6)
${horequest_qci5_9_165}
...    E-RABToBeSetupListHOReq contains (
...    e-RAB-ID eq 5 and qCI eq 5,
...    e-RAB-ID eq 6 and qCI eq 9,
...    e-RAB-ID eq 8 and qCI eq 165)

${hoack_qci5_9}
...    E-RABAdmittedList contains (e-RAB-ID eq 5,e-RAB-ID eq 6) and
...    E-RABFailedtoSetupListHOReqAck contains (e-RAB-ID eq 8)
*** Test Cases ***
LTE2559-A-b1_S1_HO_partial_admission_radio_reasons_Success
    [Tags]
    [Documentation]
    ...    ue5 add qci5,192,193 on enb2 cell21,ue5 add qci5,192,193 on enb2 cell21, ue5 ho to enb1 cell1
    ...    ue4 add qci5,3,9,166 on enb2 cell21
    ...    ue4 ho to enb1 cell1, only qci 5,3,9 keep
    Delta Commission Parameters    LNBTS:actPartialAcHo=true
    ${bearer_list_to_admit}=    Create List    ${NON_PREEMPTABLE_BY_BCC_NON_QCI1_DB_ID}    ${NON_PREEMPTING_BY_RAC_PRB_DB_ID}
    ${bearer_list_to_reject}=    Create List    ${PREEMPTABLE_BY_RAC_DRB_DB_ID}
    ${bearer_list_full}=    Combine Lists    ${bearer_list_to_reject}    ${bearer_list_to_admit}
    S1 intra-LTE Handover UE succeed with specified bearers for handover cause b1
    ...  ue_id=4  bearer_list=${bearer_list_full}  cause=handover_desirable_for_radio_reasons  status=Success with Counter Increase

LTE2559-A-b2_S1_HO_partial_admission_Bearer_Released_by_MME
    [Tags]
    [Documentation]
    ...    ue5 add qci5,192,193 on enb2 cell21, ue5 ho to enb1 cell1
    ...    ue4 attach enb2 cell21 with qci5, and ho to ENB1 CELL1
    ...    check counters LNCEL-1:LTE_EPS_Bearer:M8006C281=0
    ...    ue4 detach
    ...    ue5 release QCI192 and qci193
    ...    set ue4 admission_Bearer_Released_by_MME: ue_mme_param id=4 ebi_to_be_released=7
    ...    ue4 attach enb2 cell21 with qci5,
    ...    ue4 add qci 5,9,166,165
    ...    ue4 ho to enb1 cell1, only qci5, qci9, qci165 allowed to ho request, and admit qci5 and qci9, not admit qci165
    ...    ue4 Reestablishment To Current Cell, keep qci5 and qci9
    S1 intra-LTE Handover UE succeed with specified bearers for handover cause b2
    Detach UE And Config For MME release UE bearer with specified E-RAB ID
    S1 intra-LTE Handover UE succeed with specified bearers for handover cause b21
    Reestablishment To Current Cell
    [Teardown]    Test Teardown For Reset MME

LTE2559-A-b7_S1_UTRA_HO_partial_admission_reduce_load_Failure
    [Tags]    RAN_4G    RAN_4G_FDD    CDRT
    [Documentation]
    ...    ue4 attach enb2 cell21 then start traffic qci5
    ...    then add bearer qci9,qci3,qci166
    ...    trigger ue4 ho to enb1 cell base on ho_mode=FROM_UTRAN and fail
    ...    check UE keep source qci5,qci9,qci3,qci166
    S1 from UTRA Handover UE Fail with specified bearers for handover cause
    Check UE bearer

*** Keywords ***
Common Suite Setup and Setup CUS Env
    Common Suite Setup
    Setup CUS Env
    Execute Egate Command    enb_param id=2 ho_source=s1
    Create Alias
    #Debug enter into egate

Common Testcase Setup For Set One Normal UE
    Common Test Setup And Start To Capture Logs
    Set One Normal UE To Enb2 For Verify Normal UE Should Not Be Impacted By HO

Testcase Teardown For Recover Normal UE
    Restore Normal UE
    Common Test Teardown And Stop Capture Logs

Create Alias
    FOR    ${ue_id}    IN RANGE    2    6
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    ENB_2    enb_id=2    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Modify Yaml
    ${GNB2_CELL1}    catenate    - {id: 21, technology: lte, pci: '10:1', tac: 33, earfcn: '1450:19450', bw: 20}
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.3
    ...      x2: 10.0.1.3
    ...      cells:
    ...         ${GNB2_CELL1}
    FOR    ${ue_id}    IN RANGE    2    6
        Update Yaml    UEs/UE_sets/${ue_id}    rohc: 16    sec_key: 0102030405060708090A0B0C0D0E100${ue_id}
        ...    category: 6   release: 10    eea: null    eia: null    fgi: 2,3,5,6,7,13,14,16,17,18,20,21,25,28,31,8,15,22,27
    END
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 5, default: on, priority: 1, preemption: off, vulnerability: off, pdn: 1}
    ...     - {qci: 8, priority: 3, preemption: off, vulnerability: on, pdn: 1}
    ...     - {qci: 128, priority: 3, preemption: off, vulnerability: on, gbr: no, delay: 10, pdn: 1}
    ...     - {qci: 1, priority: 4, gbr_ul: 1, gbr_dl: 1, preemption: off, vulnerability: on, pdn: 1}
    ...     - {qci: 9, priority: 5, preemption: off, vulnerability: off, pdn: 1}
    ...     - {qci: 2, priority: 6, gbr_ul: 1, gbr_dl: 768, preemption: on, vulnerability: off, pdn: 1}
    ...     - {qci: 3, priority: 7, gbr_ul: 1, gbr_dl: 1, preemption: off, vulnerability: off, pdn: 1}
    ...     - {qci: 7, priority: 8, preemption: on, vulnerability: off, pdn: 1}
    ...     - {qci: 165, priority: 1, preemption: off, vulnerability: on, gbr: yes, delay: 10, gbr_ul: 1, gbr_dl: 2048, pdn: 1}
    ...     - {qci: 166, priority: 10, preemption: off, vulnerability: on, gbr: no, delay: 10, pdn: 1}
    ...     - {qci: 167, priority: 1, preemption: off, vulnerability: off, gbr: yes, delay: 10, gbr_ul: 1, gbr_dl: 2048, pdn: 1}
    ...     - {qci: 168, priority: 10, preemption: off, vulnerability: off, gbr: no, delay: 10, pdn: 1}
    ...     - {qci: 180, priority: 11, preemption: off, vulnerability: on, gbr: yes, delay: 10, gbr_ul: 1, gbr_dl: 1, pdn: 1}
    ...     - {qci: 181, gbr: yes, priority: 12, preemption: off, vulnerability: on, delay: 10, gbr_ul: 1, gbr_dl: 1, pdn: 1}
    ...     - {qci: 182, gbr: yes, priority: 13, preemption: off, vulnerability: on, delay: 10, gbr_ul: 1, gbr_dl: 1, pdn: 1}
    ...     - {qci: 183, gbr: yes, priority: 14, preemption: off, vulnerability: on, delay: 10, gbr_ul: 1, gbr_dl: 1, pdn: 1}

    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...     - {qci: 5, default: on, priority: 1, preemption: off, vulnerability: off, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    ...     - {qci: 128, gbr: no, priority: 3, delay: 10, pdn: 1}
    ...     - {qci: 165, gbr: yes, priority: 1, delay: 10, gbr_ul: 1, gbr_dl: 2048, pdn: 1}
    ...     - {qci: 166, gbr: no, priority: 10, delay: 10, pdn: 1}
    ...     - {qci: 167, gbr: yes, priority: 1, delay: 10, gbr_ul: 1, gbr_dl: 2048, pdn: 1}
    ...     - {qci: 168, gbr: no, priority: 10, delay: 10, pdn: 1}
    ...     - {qci: 180, gbr: yes, priority: 11, delay: 10, gbr_ul: 1, gbr_dl: 1, pdn: 1}
    ...     - {qci: 181, gbr: yes, priority: 12, delay: 10, gbr_ul: 1, gbr_dl: 1, pdn: 1}
    ...     - {qci: 182, gbr: yes, priority: 13, delay: 10, gbr_ul: 1, gbr_dl: 1, pdn: 1}
    ...     - {qci: 183, gbr: yes, priority: 14, delay: 10, gbr_ul: 1, gbr_dl: 1, pdn: 1}
    ...     - {qci: 192, gbr: yes, priority: 11, preemption: off, vulnerability: on, delay: 10, gbr_ul: 1, gbr_dl: 768, pdn: 1}
    ...     - {qci: 193, gbr: no, priority: 12, preemption: off, vulnerability: on, delay: 10, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_4:
    ...     - {qci: 5, default: on, priority: 2, preemption: off, vulnerability: off, pdn: 1}
    ...     - {qci: 8, priority: 3, preemption: off, vulnerability: on, pdn: 1}
    ...     - {qci: 128, priority: 3, preemption: off, vulnerability: on, gbr: no, delay: 10, pdn: 1}
    ...     - {qci: 1, priority: 4, gbr_ul: 1, gbr_dl: 1, preemption: off, vulnerability: on, pdn: 1}
    ...     - {qci: 9, priority: 5, preemption: off, vulnerability: off, pdn: 1}
    ...     - {qci: 2, priority: 6, gbr_ul: 1, gbr_dl: 768, preemption: on, vulnerability: off, pdn: 1}
    ...     - {qci: 3, priority: 7, gbr_ul: 1, gbr_dl: 1, preemption: off, vulnerability: off, pdn: 1}
    ...     - {qci: 7, priority: 8, preemption: on, vulnerability: off, pdn: 1}
    ...     - {qci: 165, priority: 1, preemption: off, vulnerability: on, gbr: yes, delay: 10, gbr_ul: 1, gbr_dl: 2048, pdn: 1}
    ...     - {qci: 166, priority: 10, preemption: off, vulnerability: on, gbr: no, delay: 10, pdn: 1}
    ...     - {qci: 167, priority: 1, preemption: off, vulnerability: off, gbr: yes, delay: 10, gbr_ul: 1, gbr_dl: 2048, pdn: 1}
    ...     - {qci: 168, priority: 10, preemption: off, vulnerability: off, gbr: no, delay: 10, pdn: 1}
    ...     - {qci: 180, priority: 11, preemption: off, vulnerability: on, gbr: yes, delay: 10, gbr_ul: 1, gbr_dl: 1, pdn: 1}
    ...     - {qci: 181, gbr: yes, priority: 12, preemption: off, vulnerability: on, delay: 10, gbr_ul: 1, gbr_dl: 1, pdn: 1}
    ...     - {qci: 182, gbr: yes, priority: 13, preemption: off, vulnerability: on, delay: 10, gbr_ul: 1, gbr_dl: 1, pdn: 1}
    ...     - {qci: 183, gbr: yes, priority: 14, preemption: off, vulnerability: on, delay: 10, gbr_ul: 1, gbr_dl: 1, pdn: 1}
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/4    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/3    bearer: bearer_set_4
    Update Yaml    UEs/UE_sets/5    bearer: bearer_set_3

Set One Normal UE To Enb2 For Verify Normal UE Should Not Be Impacted By HO
    UE Setup with specified bearer_list at specified eNB Cell 192 193  ${OTHER_UE_ID}  ${OTHER_UE_BEARER_LIST}  ${SOURCE_ENB_ID_INTER_ENB}
    ...  ${SOURCE_CELL_ID_INTER_ENB}
    Set eNB source HO type As s1
    Set eNB S1 HO with cause    ${SOURCE_ENB_ID_INTER_ENB}    handover_desirable_for_radio_reasons
    Iphy S1 HO From eNB2 To eNB1    ${OTHER_UE_ID}
    Check bearers list at specified UE    ${OTHER_UE_BEARER_LIST}    ${OTHER_UE_ID}
    execute uex command  trf_data_start ue=${OTHER_UE_ID} qci=192 dir=dl kbps=768 protocol=udp
    execute uex command    ue_cqi_param id=${OTHER_UE_ID} rank=1 wb=0:0:0 sb=1-13:0:0:0

Iphy S1 HO From eNB2 To eNB1
    [Arguments]  ${ue_id}=${UE1}
    execute egate command  enb_param id=2 ho_source=s1
    execute uex command  ue_ho id=${ue_id} enb=1 cell=1  #S1 HO

Restore Normal UE
    execute egate command    link_unlock link\=x2 at\=enb:${SOURCE_ENB_ID_INTER_ENB} to\=enb:${TARGET_ENB_ID}    is up
    execute egate command    ue_cqi_param id=${OTHER_UE_ID} rank=2 wb=15:15:15 sb=1-13:15:15:15
    CUS UE Detach    ue_id=${OTHER_UE_ID}

CUS UE Detach
    [Arguments]    ${ue_id}
    execute uex command    ue_detach id=${ue_id}

UE Setup with specified bearer_list at specified eNB Cell 192 193
    [Arguments]    ${ue_id}    ${bearer_list}    ${enb_id}    ${cell_id}
    CUS UE attach to eNB2    ${ue_id}    ${cell_id}
    execute uex command    trf_data_start ue=${ue_id} qci=5 dir=ul kbps=10 protocol=udp   #pass_regexp=UDP UL TRF
    execute uex command    bearer_add ue=${ue_id} qci=192 gbr_dl=768 gbr_ul=1 mbr_ul=1 mbr_dl=768
    execute uex command    bearer_add ue=${ue_id} qci=193
    Check bearers list at specified UE    ${bearer_list}    ${ue_id}

UE Setup with specified bearer_list at specified eNB Cell b21
    CUS UE attach to eNB2    4    21
    execute uex command    trf_data_start ue=4 qci=5 dir=ul kbps=10 protocol=udp
    execute uex command    bearer_add ue=4 qci=9
    execute uex command    bearer_add ue=4 qci=166
    execute uex command    bearer_add ue=4 qci=165 gbr_dl=768 gbr_ul=1 mbr_ul=1 mbr_dl=768

UE Setup with specified bearer_list at specified eNB Cell
    CUS UE attach to eNB2    4    21
    execute uex command    trf_data_start ue=4 qci=5 dir=ul kbps=10 protocol=udp
    execute uex command    bearer_add ue=4 qci=9
    execute uex command    bearer_add ue=4 qci=3 gbr_ul=1 gbr_dl=1 mbr_ul=1 mbr_dl=768
    execute uex command    bearer_add ue=4 qci=166

UE Setup with specified bearer_list at specified eNB Cell b2
    CUS UE attach to eNB2    4    21
    execute uex command    trf_data_start ue=4 qci=5 dir=ul kbps=10 protocol=udp

UE Setup with specified bearer_list at specified eNB Cell b1
    [Arguments]    ${ue_id}    ${bearer_list}    ${enb_id}    ${cell_id}
    CUS UE attach to eNB2    ${ue_id}    cell_id=21
    execute uex command    trf_data_start ue=${ue_id} dir=ul kbps=5 protocol=udp
    execute uex command    bearer_add ue=${ue_id} qci=166
    execute uex command    bearer_add ue=${ue_id} qci=9
    execute uex command    bearer_add ue=${ue_id} qci=3 gbr_dl=2 gbr_ul=2 mbr_ul=5 mbr_dl=768
    Check bearers list at specified UE    ${bearer_list}    ${ue_id}

CUS UE attach to eNB2
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    execute uex command    ue_attach id=${ue_id} cell=${cell_id}

S1 intra-LTE Handover UE succeed with specified bearers for handover cause b2
    Set eNB S1 HO with cause    2    handover_desirable_for_radio_reasons
    UE Setup with specified bearer_list at specified eNB Cell b2
    Handover Should Succeed And Check LTE2559 Counter As Zero b2

S1 intra-LTE Handover UE succeed with specified bearers for handover cause b21
    Set eNB S1 HO with cause    2    handover_desirable_for_radio_reasons
    UE Setup with specified bearer_list at specified eNB Cell b21
    Handover Should Succeed b2

S1 intra-LTE Handover UE succeed with specified bearers for handover cause b1
    [Arguments]    ${ue_id}    ${bearer_list}    ${cause}    ${status}
    ${src_enb_id}=    Set Variable    ${SOURCE_ENB_ID_INTER_ENB}
    ${src_cell_id}=    Set Variable    ${SOURCE_CELL_ID_INTER_ENB}
    Set eNB S1 HO with cause    ${SOURCE_ENB_ID_INTER_ENB}    ${cause}
    UE Setup with specified bearer_list at specified eNB Cell b1    ${ue_id}    ${bearer_list}    ${src_enb_id}    ${src_cell_id}
    Handover Should Succeed And Check LTE2559 Counter b1  ue_id=${ue_id}  enb_id=${TARGET_ENB_ID}  cell_id=${TARGET_CELL_ID}

S1 intra-LTE Handover UE faill with specified bearers for handover cause
    [Arguments]    ${ue_id}    ${bearer_list}    ${cause}    ${status}
    ${src_enb_id}=    Set Variable    ${SOURCE_ENB_ID_INTER_ENB}
    ${src_cell_id}=    Set Variable    ${SOURCE_CELL_ID_INTER_ENB}
    Set eNB S1 HO with cause    ${SOURCE_ENB_ID_INTER_ENB}    ${cause}
    UE Setup with specified bearer_list at specified eNB Cell    ${ue_id}    ${bearer_list}    ${src_enb_id}    ${src_cell_id}
    Handover Should Fail  ue_id=${ue_id}  enb_id=${TARGET_ENB_ID}  cell_id=${TARGET_CELL_ID}  mode=INTRA_LTE
    ...  pass_regexp=UE${ue_id}: =* S1 HO \\(eNB .->eNB ${TARGET_ENB_ID}\\) performed
    ...  fail_regexp=UE${ue_id}: S1:HANDOVER_PREPARATION_FAILURE\\(Cause=.*\\) received
    ...    status=${status}    src_enb_id=${src_enb_id}    src_cell_id=${src_cell_id}

S1 from UTRA Handover UE Succeed with specified bearers for handover cause
    [Arguments]    ${ue_id}    ${bearer_list}    ${cause}    ${status}
    ${src_enb_id}=    Set Variable    ${SOURCE_ENB_ID_INTER_ENB}
    ${src_cell_id}=    Set Variable    ${SOURCE_CELL_ID_INTER_ENB}
    Set eNB S1 HO with cause    ${SOURCE_ENB_ID_INTER_ENB}    ${cause}
    UE Setup with specified bearer_list at specified eNB Cell    ${ue_id}    ${bearer_list}    ${src_enb_id}    ${src_cell_id}
    Handover Should Succeed  ue_id=${ue_id}  enb_id=${TARGET_ENB_ID}  cell_id=${TARGET_CELL_ID}  mode=FROM_UTRAN
    ...  pass_regexp=UE${ue_id}: =* Simulated UTRAN->LTE HO \\(RNC .+->eNB ${TARGET_ENB_ID}\\) performed
    ...  fail_regexp=UE${ue_id}: S1:HANDOVER_PREPARATION_FAILURE\\(Cause=.*\\) received
    ...    status=${status}    src_enb_id=${src_enb_id}    src_cell_id=${src_cell_id}

S1 from UTRA Handover UE Fail with specified bearers for handover cause
    Set eNB S1 HO with cause    2    reduce_load_in_serving_cell
    UE Setup with specified bearer_list at specified eNB Cell
    Handover Should Fail

Set eNB source HO type As s1
    execute egate command    enb_param id=${SOURCE_ENB_ID_INTER_ENB} ho_source=s1
    execute egate command    link_lock link\=x2 at\=enb:${SOURCE_ENB_ID_INTER_ENB} to\=enb:${TARGET_ENB_ID}    is

Set eNB source HO type As x2
    execute egate command    enb_param id=${SOURCE_ENB_ID_INTER_ENB} ho_source=x2
    execute egate command    link_unlock link\=x2 at\=enb:${SOURCE_ENB_ID_INTER_ENB} to\=enb:${TARGET_ENB_ID}    is up

Set eNB S1 HO with cause
    [Arguments]    ${enb_id}    ${cause}
    EXECUTE EGATE COMMAND    enb_param id=${enb_id} s1_ho_cause=${cause}

Handover Should Succeed And Check LTE2559 Counter b1
    [Arguments]    ${ue_id}    ${enb_id}    ${cell_id}
    Enable Tracing
    Start Rtpm Counter
    Handover UE b1  ue_id=${ue_id}  enb_id=${enb_id}  cell_id=${cell_id}
    Disable Tracing
    Check LTE2559 Counter    pm_counter=${PM_COUNTERS_FOR_LTE2559}

Handover Should Succeed And Check LTE2559 Counter b21
    Enable Tracing
    Start Rtpm Counter
    Handover UE b21    ue_id=4    enb_id=1    cell_id=1
    Disable Tracing
    Check LTE2559 Counter    pm_counter=${PM_COUNTERS_FOR_LTE2559}

Handover Should Succeed And Check LTE2559 Counter As Zero b2
    Enable Tracing
    Start Rtpm Counter
    Handover UE b2    ue_id=4    enb_id=1    cell_id=1
    Disable Tracing
    Check LTE2559 Counter    pm_counter=${NON_PM_COUNTERS_FOR_LTE2559}

Handover Should Succeed And Check LTE2559 Counter
    [Arguments]    ${ue_id}    ${enb_id}    ${cell_id}    ${mode}    ${pass_regexp}    ${fail_regexp}
    ...    ${status}    ${src_enb_id}    ${src_cell_id}
    Enable Tracing
    Start Rtpm Counter
    Handover UE  ue_id=${ue_id}  enb_id=${enb_id}  cell_id=${cell_id}  mode=${mode}  pass_regexp=${pass_regexp}  fail_regexp=${fail_regexp}
    Disable Tracing
    Check LTE2559 Counter    pm_counter=${PM_COUNTERS_FOR_LTE2559}

Handover Should Succeed And Check LTE2559 Counter As Zero
    [Arguments]    ${ue_id}    ${enb_id}    ${cell_id}    ${mode}    ${pass_regexp}    ${fail_regexp}
    ...    ${status}    ${src_enb_id}    ${src_cell_id}
    Enable Tracing
    Start Rtpm Counter
    Handover UE  ue_id=${ue_id}  enb_id=${enb_id}  cell_id=${cell_id}  mode=${mode}
    Disable Tracing
    Check LTE2559 Counter    pm_counter=${NON_PM_COUNTERS_FOR_LTE2559}

Handover Should Succeed b2
    Enable Tracing
    Handover UE  ue_id=4  enb_id=1  cell_id=1
    Disable Tracing

Handover Should Succeed
    Enable Tracing
    Handover UE  ue_id=${ue_id}  enb_id=${enb_id}  cell_id=${cell_id}  mode=${mode}  pass_regexp=${pass_regexp}  fail_regexp=${fail_regexp}
    Disable Tracing

Handover Should Fail
    Enable Tracing
    Handover UE b7
    Disable Tracing

Check LTE2559 Counter
    [Arguments]    ${pm_counter}
    Check Rtpm Counters    ${pm_counter}

Enable Tracing
    execute egate command    sim_trace uec\=1 protocol\=rrc on
    execute egate command    sim_trace enb\=${SOURCE_ENB_ID_INTER_ENB} protocol\=x2 on
    execute egate command    sim_trace mme\=1 protocol\=s1 on

Disable Tracing
    execute egate command    sim_trace uec\=1 protocol\=rrc off
    execute egate command    sim_trace enb\=${SOURCE_ENB_ID_INTER_ENB} protocol\=x2 off
    execute egate command    sim_trace mme\=1 protocol\=s1 off

Handover UE
    [Arguments]    ${ue_id}    ${enb_id}    ${cell_id}
    execute uex command    ue_ho id=${ue_id} enb=${enb_id} cell=${cell_id}

Handover UE b7
    expect message flow
    ...    MME_1:S1AP_HandoverRequest
    ...    MME_1:S1AP_HandoverFailure
    ...    alias=s1hob7_flow    overall_timeout=30
    run keyword and ignore error    Set from_utran
    flow occurred as expected    alias=s1hob7_flow

Set from_utran
    execute uex command    ue_ho id=4 enb=1 cell=1 ho_mode=FROM_UTRAN

Handover UE b1
    [Arguments]    ${ue_id}    ${enb_id}    ${cell_id}
    expect message flow
    ...    MME_1:S1AP_HandoverRequest(${horequest_qci5_166_9_3})
    ...    MME_1:S1AP_HandoverRequestAcknowledge(${hoack_qci5_9_3})
    ...    alias=s1ho_flow    overall_timeout=90
    execute uex command    ue_ho id=${ue_id} enb=${enb_id} cell=${cell_id}
    flow occurred as expected    alias=s1ho_flow

Handover UE b2
    [Arguments]    ${ue_id}    ${enb_id}    ${cell_id}
    execute uex command    ue_ho id=${ue_id} enb=${enb_id} cell=${cell_id}

Handover UE b21
    [Arguments]    ${ue_id}    ${enb_id}    ${cell_id}
    expect message flow
    ...    MME_1:S1AP_HandoverRequest(${horequest_qci5_9_165})
    ...    MME_1:S1AP_HandoverRequestAcknowledge(${hoack_qci5_9})
    ...    alias=s1ho_flow1    overall_timeout=120
    execute uex command    ue_ho id=${ue_id} enb=${enb_id} cell=${cell_id}
    flow occurred as expected    alias=s1ho_flow1

Check bearers list at specified UE
    [Arguments]    ${bearer_list}    ${ue_id}
    ${num_bearers_expected}=    Get Length    ${bearer_list}
    ${active_bearer_num}=    evaluate    ${num_bearers_expected}+1
    ${cmd_result_mme}=  execute egate command    bearer_disp ue\=${ue_id} at\=mme
    ...  UE ${ue_id}: ${active_bearer_num} active bearer\\(s\\) at MME-1

Check UE should be at expected cell
    [Arguments]    ${ue_id}    ${enb_id}    ${cell_id}
    ${command_result}=    execute uex command    ue_disp id\=${ue_id}    UE
    Log    ${command_result}
    ${match}    ${enb_id_actual}=    Should Match Regexp    ${command_result}    enb.*(\\d+)
    ${match}    ${cell_id_actual}=    Should Match Regexp    ${command_result}    cell.*(\\d+)
    Should be True    ${enb_id_actual} == ${enb_id}
    Should be True    ${cell_id_actual} == ${cell_id}

Test Teardown For Reset MME
    execute egate command    ue_mme_param id=4 reset
    Restore Normal UE
    Common Test Teardown And Stop Capture Logs

Send A4 Measurement Report
    [Arguments]    ${ue_id}    ${enb_id}    ${cell_id}    ${mode}    ${pass_regexp}    ${fail_regexp}
    Repeat Keyword  5 times  Send Single A4 Measurement Report  ue_id=${ue_id}  phycell_id=${cell_id}  pass_regexp=EGATE>  fail_regexp=${fail_regexp}

Release Dedicate Bearer
    [Arguments]    ${ue_id}    ${qci_id}
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci_id}

Detach UE And Config For MME release UE bearer with specified E-RAB ID
    CUS UE Detach    ue_id=4
    Release Dedicate Bearer    5    192
    Release Dedicate Bearer    5    193
    execute egate command    ue_mme_param id=4 ebi_to_be_released=7

Reestablishment To Current Cell
    execute uex command    ue_rrc_reestablish id=4 cell=1
    ${bearer_info}    execute uex command    get_bearer_info ue=4
    should be equal as strings    ${bearer_info[1]["qci"]}    9
    should be equal as strings    ${bearer_info[2]["qci"]}    5

Check UE bearer
#    execute uex command    ue_rrc_reestablish id=4 cell=1
    ${bearer_info}    execute uex command    get_bearer_info ue=4
    should be equal as strings    ${bearer_info[3]["qci"]}    5
    should be equal as strings    ${bearer_info[2]["qci"]}    9
    should be equal as strings    ${bearer_info[1]["qci"]}    3
    should be equal as strings    ${bearer_info[0]["qci"]}    166

