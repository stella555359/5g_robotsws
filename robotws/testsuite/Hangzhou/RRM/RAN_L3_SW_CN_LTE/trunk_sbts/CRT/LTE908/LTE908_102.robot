*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               DevHZ5_SG4    owner-kexin.zhou
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${anrUtraTRSCFS}    5000ms    #default value in SCF
${anrUtraInactivityTimer}    5    #inactivity timer in vendor
${anrUtraTRSC}    2500ms    #default value in vendor
${anrUtraTRCGI}    8200ms    #default value in vendor

@{PARAMS_IN_SCF}
...  LNBTS-1:actCSFBRedir=Enabled
...  LNBTS-1:actCsfbPsHoToUtra=true
...  LNBTS-1:act8EpsBearers=true
...  LNBTS-1:actHOtoWcdma=true
...  LNBTS-1:actRedirect=disabled
...  LNBTS-1:anrOmExtEnable=true
...  LNBTS-1:enableBwCombCheck=false
...  LNBTS-1:maxNumOfLnadjLimit=256
...  LNBTS-1:actOperatorQCI=true
...  LNBTS-1:actOperatorQCIGBR=true
...  LNBTS-1:actQCIPLMNIDProfiles=false
...  LNBTS-1:actS1OlHandling=true
...  LNBTS-1:geranDtmCap=true
...  LNBTS-1:multScellReleaseTimer=5
...  LNBTS-1:tS1RelPrepL=500
...  LNBTS-1:tS1RelPrepU=1000
...  LNBTS-1:tX2RelocPrep=500
...  LNBTS-1/ANR-0:minNotActivatedUtraRSCFS=1440
...  LNBTS-1/LNCEL-1:a1TimeToTriggerDeactInterMeas=100ms
...  LNBTS-1/LNCEL-1:a2TimeToTriggerActInterFreqMeas=100ms
...  LNBTS-1/LNCEL-1:a2TimeToTriggerActWcdmaMeas=0ms
...  LNBTS-1/LNCEL-1:defaultLnRelGnbCellId=${EMPTY}
...  LNBTS-1/LNCEL-1:a3Offset=12
...  LNBTS-1/LNCEL-1:a3ReportInterval=1024ms
...  LNBTS-1/LNCEL-1:a3TimeToTrigger=1280ms
...  LNBTS-1/LNCEL-1:a3TriggerQuantityHO=RSRP
...  LNBTS-1/LNCEL-1:a5ReportInterval=640ms
...  LNBTS-1/LNCEL-1:a5TimeToTrigger=1280ms
...  LNBTS-1/LNCEL-1:act3fdd3tddRestrict=false
...  LNBTS-1/LNCEL-1:enableLowAgg=false
...  LNBTS-1/LNCEL-1:enablePcPdcch=true
...  LNBTS-1/LNCEL-3:a1TimeToTriggerDeactInterMeas=100ms
...  LNBTS-1/LNCEL-3:a2TimeToTriggerActInterFreqMeas=100ms
...  LNBTS-1/LNCEL-3:a2TimeToTriggerActWcdmaMeas=0ms
...  LNBTS-1/LNCEL-3:defaultLnRelGnbCellId=${EMPTY}
...  LNBTS-1/LNCEL-3:a3Offset=12
...  LNBTS-1/LNCEL-3:a3ReportInterval=1024ms
...  LNBTS-1/LNCEL-3:a3TimeToTrigger=1280ms
...  LNBTS-1/LNCEL-3:a3TriggerQuantityHO=RSRP
...  LNBTS-1/LNCEL-3:a5ReportInterval=640ms
...  LNBTS-1/LNCEL-3:a5TimeToTrigger=1280ms
...  LNBTS-1/LNCEL-3:act3fdd3tddRestrict=false
...  LNBTS-1/LNCEL-3:enableLowAgg=false
...  LNBTS-1/LNCEL-3:enablePcPdcch=true
...  LNBTS-1/LNCEL-2:a1TimeToTriggerDeactInterMeas=2560ms
...  LNBTS-1/LNCEL-2:a2TimeToTriggerActInterFreqMeas=100ms
...  LNBTS-1/LNCEL-2:a2TimeToTriggerActWcdmaMeas=0ms
...  LNBTS-1/LNCEL-2:defaultLnRelGnbCellId=${EMPTY}
...  LNBTS-1/LNCEL-2:a3TimeToTrigger=100ms
...  LNBTS-1/LNCEL-2:a5TimeToTrigger=100ms
...  LNBTS-1/LNCEL-2:a3Offset=12
...  LNBTS-1/LNCEL-2:a3ReportInterval=1024ms
...  LNBTS-1/LNCEL-2:a3TriggerQuantityHO=RSRP
...  LNBTS-1/LNCEL-2:a5ReportInterval=640ms
...  LNBTS-1/LNCEL-2:act3fdd3tddRestrict=false
...  LNBTS-1/LNCEL-2:enableLowAgg=false
...  LNBTS-1/LNCEL-2:enablePcPdcch=true
...  LNBTS-1/LNCEL-2:a3ReportInterval=1024ms
...  LNCEL-1/LNHOW-1:b1TimeToTriggerCSFBUtraMeas=80ms
...  LNCEL-1/LNHOW-1:b2Threshold1Utra=57
...  LNCEL-1/LNHOW-1:b2Threshold2UtraRscp=60
...  LNCEL-1/LNHOW-1:b2TimeToTriggerUtraMeas=480ms
...  LNCEL-1/LNHOW-1:hysB2ThresholdUtra=0
...  LNCEL-1/LNHOW-1:offsetFreqUtra=0
...  LNCEL-1/LNHOW-1:reportIntervalUtra=2048ms
...  LNCEL-1/LNHOW-1:utraCarrierFreq=9692
...  LNCEL-1/LNHOW-2:b1TimeToTriggerCSFBUtraMeas=80ms
...  LNCEL-1/LNHOW-2:b2Threshold1Utra=57
...  LNCEL-1/LNHOW-2:b2Threshold2UtraRscp=60
...  LNCEL-1/LNHOW-2:b2TimeToTriggerUtraMeas=480ms
...  LNCEL-1/LNHOW-2:hysB2ThresholdUtra=0
...  LNCEL-1/LNHOW-2:offsetFreqUtra=0
...  LNCEL-1/LNHOW-2:reportIntervalUtra=2048ms
...  LNCEL-1/LNHOW-2:utraCarrierFreq=9842
...  LNCEL-2/LNHOW-0:utraCarrierFreq=10592
...  LNCEL-2/LNHOW-1:b1TimeToTriggerCSFBUtraMeas=80ms
...  LNCEL-2/LNHOW-1:b2Threshold1Utra=57
...  LNCEL-2/LNHOW-1:b2Threshold2UtraRscp=60
...  LNCEL-2/LNHOW-1:b2TimeToTriggerUtraMeas=480ms
...  LNCEL-2/LNHOW-1:hysB2ThresholdUtra=0
...  LNCEL-2/LNHOW-1:offsetFreqUtra=0
...  LNCEL-2/LNHOW-1:reportIntervalUtra=2048ms
...  LNCEL-2/LNHOW-1:utraCarrierFreq=9692
...  LNCEL-2/LNHOW-2:b1TimeToTriggerCSFBUtraMeas=80ms
...  LNCEL-2/LNHOW-2:b2Threshold1Utra=57
...  LNCEL-2/LNHOW-2:b2Threshold2UtraRscp=60
...  LNCEL-2/LNHOW-2:b2TimeToTriggerUtraMeas=480ms
...  LNCEL-2/LNHOW-2:hysB2ThresholdUtra=0
...  LNCEL-2/LNHOW-2:offsetFreqUtra=0
...  LNCEL-2/LNHOW-2:reportIntervalUtra=2048ms
...  LNCEL-2/LNHOW-2:utraCarrierFreq=9842
...  LNCEL-3/LNHOW-0:b1TimeToTriggerCSFBUtraMeas=80ms
...  LNCEL-3/LNHOW-0:b2Threshold1Utra=57
...  LNCEL-3/LNHOW-0:b2Threshold2UtraRscp=60
...  LNCEL-3/LNHOW-0:b2TimeToTriggerUtraMeas=480ms
...  LNCEL-3/LNHOW-0:hysB2ThresholdUtra=0
...  LNCEL-3/LNHOW-0:offsetFreqUtra=0
...  LNCEL-3/LNHOW-0:reportIntervalUtra=2048ms
...  LNCEL-3/LNHOW-0:utraCarrierFreq=10592
...  LNCEL-3/LNHOW-1:b1TimeToTriggerCSFBUtraMeas=80ms
...  LNCEL-3/LNHOW-1:b2Threshold1Utra=57
...  LNCEL-3/LNHOW-1:b2Threshold2UtraRscp=60
...  LNCEL-3/LNHOW-1:b2TimeToTriggerUtraMeas=480ms
...  LNCEL-3/LNHOW-1:hysB2ThresholdUtra=0
...  LNCEL-3/LNHOW-1:offsetFreqUtra=0
...  LNCEL-3/LNHOW-1:reportIntervalUtra=2048ms
...  LNCEL-3/LNHOW-1:utraCarrierFreq=9692
...  LNCEL-3/LNHOW-2:b1TimeToTriggerCSFBUtraMeas=80ms
...  LNCEL-3/LNHOW-2:b2Threshold1Utra=57
...  LNCEL-3/LNHOW-2:b2Threshold2UtraRscp=60
...  LNCEL-3/LNHOW-2:b2TimeToTriggerUtraMeas=480ms
...  LNCEL-3/LNHOW-2:hysB2ThresholdUtra=0
...  LNCEL-3/LNHOW-2:offsetFreqUtra=0
...  LNCEL-3/LNHOW-2:reportIntervalUtra=2048ms
...  LNCEL-3/LNHOW-2:utraCarrierFreq=9842
...  LNCEL-3/LNHOW-3:b1TimeToTriggerCSFBUtraMeas=80ms
...  LNCEL-3/LNHOW-3:b2Threshold1Utra=57
...  LNCEL-3/LNHOW-3:b2Threshold2UtraRscp=60
...  LNCEL-3/LNHOW-3:b2TimeToTriggerUtraMeas=480ms
...  LNCEL-3/LNHOW-3:hysB2ThresholdUtra=0
...  LNCEL-3/LNHOW-3:offsetFreqUtra=0
...  LNCEL-3/LNHOW-3:reportIntervalUtra=2048ms
...  LNCEL-3/LNHOW-3:utraCarrierFreq=1192

@{Precondition}
...  LNBTS-1/ANRPRW-1:anrUtraEcNoThres=47
...  LNBTS-1/ANRPRW-1:utraCarrierFreq=10592
...  LNBTS-1/ANRPRW-1:enableAnrProfile=true
...  LNBTS-1/LNADJW-1:uTargetScFdd=110
...  LNBTS-1/LNADJW-1:uTargetCid=1
...  LNBTS-1/LNADJW-1:uTargetFreq=10592
...  LNBTS-1/LNADJW-2:uTargetScFdd=220
...  LNBTS-1/LNADJW-2:uTargetCid=2
...  LNBTS-1/LNADJW-2:uTargetFreq=10592
...  LNBTS-1/LNADJW-2:uTargetLac=1
...  LNBTS-1/LNADJW-2:uTargetRac=1
...  LNBTS-1:actCSFBRedir=Enabled
...  LNBTS-1:actCsfbPsHoToUtra=true
...  LNCEL-1/LNHOW-1:maxNumCsfbTargets=10
...  LNCEL-1/LNHOW-1:utraCarrierFreq=10592
...  LNCEL-1/LNHOW-1:b1ThresholdCSFBUtraRscp=45
...  LNCEL-1/LNHOW-2:maxNumCsfbTargets=6
...  LNCEL-1/LNHOW-2:utraCarrierFreq=9692
...  LNCEL-1/LNHOW-2:b1ThresholdCSFBUtraRscp=45
...  LNCEL-2/LNHOW-1:maxNumCsfbTargets=10
...  LNCEL-2/LNHOW-1:utraCarrierFreq=10592
...  LNCEL-2/LNHOW-1:b1ThresholdCSFBUtraRscp=45
...  LNCEL-2/LNHOW-2:maxNumCsfbTargets=6
...  LNCEL-2/LNHOW-2:utraCarrierFreq=9692
...  LNCEL-2/LNHOW-2:b1ThresholdCSFBUtraRscp=45
...  LNCEL-3/LNHOW-0:b1ThresholdCSFBUtraRscp=45
...  LNCEL-3/LNHOW-1:b1ThresholdCSFBUtraRscp=45
...  LNCEL-3/LNHOW-2:b1ThresholdCSFBUtraRscp=45
...  LNCEL-3/LNHOW-3:b1ThresholdCSFBUtraRscp=45
...  LNCEL-1/LNRELW-1:uTargetCid=1
...  LNCEL-1/LNRELW-2:uTargetCid=2
...  LNCEL-2/LNRELW-1:uTargetCid=1
...  LNCEL-2/LNRELW-2:uTargetCid=2
...  LNBTS-1:maxNumAnrMoiAllowed=4000

@{Case4_Delta_Commission_1}
...  LNBTS-1:actUeBasedAnrUtran=true
...  LNBTS-1/ANRPRW-1:lnRelWLimitForAnr=3
...  LNBTS-1/ANRPRW-1:lnRelWDefaults:csfbPsHoAllowed=forbidden
...  LNBTS-1/ANRPRW-1:lnRelWDefaults:psHoAllowed=allowed
...  LNBTS-1/ANRPRW-1:lnRelWDefaults:srvccAllowed=allowed
...  LNBTS-1/ANRPRW-1:lnRelWDefaults:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNHOW-1:maxNumCsfbTargets=2
...  delete:LNADJW-2
...  delete:LNCEL-1/LNRELW-2
...  delete:LNCEL-2/LNRELW-2
...  delete:LNCEL-1/LNRELW-1
...  delete:LNCEL-2/LNRELW-1
...  delete:LNADJW-1
...  LNBTS-1/ANRPRW-1:cellsToApplyList=1,2
...  LNBTS-1:maxNumAnrMoiAllowed=4000
@{Case4_Delta_Commission_2}
...  LNCEL-1/LNRELW-2:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-2:nrControl=automatic
...  LNCEL-1/LNRELW-2:psHoAllowed=allowed
...  LNCEL-1/LNRELW-2:srvccAllowed=allowed
...  LNCEL-1/LNRELW-2:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELW-2:removeAllowed=false
...  LNCEL-1/LNRELW-2:utranLbAllowed=false
...  LNCEL-1/LNRELW-2:uTargetCid=2
...  LNCEL-1/LNRELW-2:uTargetRncId=1
...  LNCEL-2/LNRELW-2:csfbPsHoAllowed=forbidden
...  LNCEL-2/LNRELW-2:nrControl=automatic
...  LNCEL-2/LNRELW-2:psHoAllowed=allowed
...  LNCEL-2/LNRELW-2:srvccAllowed=allowed
...  LNCEL-2/LNRELW-2:redirWithSysInfoAllowed=forbidden
...  LNCEL-2/LNRELW-2:removeAllowed=false
...  LNCEL-2/LNRELW-2:utranLbAllowed=false
...  LNCEL-2/LNRELW-2:uTargetRncId=1
...  LNBTS-1/LNADJW-2:uTargetScFdd=1
...  LNBTS-1/LNADJW-2:uTargetCid=2
...  LNBTS-1/LNADJW-2:uTargetFreq=10592
...  LNBTS-1/LNADJW-2:uTargetLac=1
...  LNBTS-1/LNADJW-2:uTargetRncId=1
...  LNBTS-1/LNADJW-2:uTargetRac=1

@{Decommission_parameter}
...  delete:LNREL.*
...  delete:LNADJ.*
...  delete:LNCEL-1/LNHOW-3
...  delete:LNCEL-1/LNHOW-0
...  delete:LNCEL-2/LNHOW-3
...  delete:LNCEL-2/LNHOW-0

${ue_eutra_capabilities}  SEPARATOR=
...    CD9FF4F9B2E7500010610102912464D0312040E07FFFFFFFFCA18800182008295020022A0060B3FFFFFFFE014FFFFFFFFC

${RSCFS_CF}
...    measConfig contains (
...      measObjectToAddModList contains (carrierFreq eq 10592)
...      and
...      reportConfigToAddModList contains (purpose eq 'reportStrongestCellsForSON')
...      and
...      measIdToAddModList contains (measId eq 32)
...    )

${RSC_CF}
...    measConfig contains (
...      measObjectToAddModList contains (carrierFreq eq 10592)
...      and
...      reportConfigToAddModList contains (purpose eq 'reportStrongestCells')
...      and
...      measIdToAddModList contains (measId eq 32)
...    )

${CGI_CF}
...    measConfig contains (
...      measObjectToAddModList contains (carrierFreq eq 10592)
...      and
...      reportConfigToAddModList contains (purpose eq 'reportCGI')
...      and
...      measIdToAddModList contains (measId eq 32)
...    )

*** Test Cases ***
LTE908_102_04_Cross with LBT2853_max MOI limit just not reached by 1 no creation of LNADJW or LNRELW
    [Documentation]    Test Case for feature "LTE908_102" for WMP eNB Testlines
    ...    original case6
    ...
    ...    The purpose of this test case is to verify the correct consolidation of neighbor relations configured in
    ...    ... \ \ eNB in case via online commissioning LNCEL objects are modified (physicalCellId), LNADJL objects are created, modified
    ...    ... \ \ (physicalCellId, dlEarfcn) or deleted or LNREL objects are created or deleted. Different side conditions are considered
    ...    ... \ \ in the different test instances e.g. related to collision detection of neighbor relations in a cell of local eNB
    ...    ... \ \ leading to automatic LNREL deletion.
    [Tags]    RAN_4G    RAN_4G_FDD    CDRT    TC04
    Configuration Parameters Muilti times    instance=4
    Calculate UtraAnr Timeout
    UE Attach And Report RSCFS
    Report RCS And CGI MeasurementReport
    Check case4 MO

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts
    Set UE parameters for WCDMA capability

Modify Yaml
    Add Yaml      EPC/RNC
    ...    - id: 12
    ...    host_enb: 4
    ...    rnc_id: 1
    ...    lac: 1
    ...    plmn: '262:03'
    ${rnc12_enb4_CELL1}    catenate    - {id: 41, technology: utran, rnc: 12, uarfcn: '10592:9692',  type: FDD,
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 11111, rac: 1, pci: '3:1'}
    ${rnc12_enb4_CELL1_LTE}   catenate    - {id: 1, technology: 'lte', tac: 33, pci: '4:1', earfcn: '1400:19400', eci: '0x0000401'}
    Add Yaml    BASE_STATIONS
    ...    - id: 4
    ...    type: 'simulated'
    ...    plmn: '262:03'
    ...    s1: '10.0.1.31'
    ...    enb_id: '0x00004'
    ...    x2_peers: none
    ...    cells:
    ...      ${rnc12_enb4_CELL1}
    ...      ${rnc12_enb4_CELL1_LTE}

Set UE parameters for WCDMA capability
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=${ue_id} type=nr release=15 nr_supported_bands=7
    Execute Egate Command    ue_enb_param id=${ue_id} ue_config_release_r9=rel15
	Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    Execute Egate Command    enb_timer T_DC_Overall=5000ms
    Execute Uex Command    ue_param eutra_interrat_utra_fdd=VII id=${ue_id}

UE Attach And Report RSCFS
    [Arguments]    ${ue_id}=1
    ${RSCFS_CMD}    catenate
    ...    ue_rrc_reconf_param id=1 if_contains=purpose with_value=reportStrongestCellsForSON
    ...    action=measurement_send id=1 phycell_id=10 arfcn=10592 type=fdd nrscp=91 necn0=49
    ...    lac=1 rac=1 strongest=utra cgi=262:03|0x0002B67 son=true
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${RSCFS_CF})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${RSC_CF})
    ...    alias=RSCFS&RSC    overall_timeout=20
    Execute Uex Command    ${RSCFS_CMD}
    Execute Uex Command    ue_attach id=${ue_id} enb=1 cell=1 ue_eutra_capabilities=${ue_eutra_capabilities}
    Flow Occurred As Expected    alias=RSCFS&RSC

Report RCS And CGI MeasurementReport
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${CGI_CF})
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=LTE908_cgi    overall_timeout=${utraAnr_timeout}
    ${rsc_report_command}=    Catenate
    ...    ue_measurement_send id=1 phycell_id=10 arfcn=10592 type=fdd
    ...    nrscp=91 necn0=49 lac=1 rac=1 strongest=utra cgi=262:03|0x0002B67 son=true
    Execute Uex Command    ${rsc_report_command}
    Flow Occurred As Expected    alias=LTE908_cgi

Configuration Parameters Muilti times
    [Arguments]    ${instance}    ${Num1}=1    ${Num2}=2
    Delta Commission Parameters    ${Decommission_parameter}
    Delta Commission Parameters    ${Precondition}
    Cells Should Be OnAir
    Delta Commission Parameters    ${Case${instance}_Delta_Commission_${Num1}}
    Cells Should Be OnAir
    Delta Commission Parameters    ${Case${instance}_Delta_Commission_${Num2}}
    Cells Should Be OnAir

Check case4 MO
    ${object_list}  Create List  LNADJW:uTargetCid=11111  LNADJW:uTargetFreq=10592  LNADJW:uTargetLac=1  LNADJW:uTargetRac=1
    ...  LNADJW:uTargetRncId=0
    ...    LNADJW:uTargetScFdd=10
    Object Should Exist    ${object_list}
    ${scf}=    Download Scf
    ${object_list}  Create List  LNRELW:csfbPsHoAllowed=forbidden  LNRELW:nrControl=automatic  LNRELW:nrStatus=available  LNRELW:psHoAllowed=allowed
    ...  LNRELW:redirWithSysInfoAllowed=forbidden
    ...  LNRELW:removeAllowed=true  LNRELW:srvccAllowed=allowed  LNRELW:uTargetCid=11111  LNRELW:uTargetRncId=0  LNRELW:utranLbAllowed=true
    Object Should Exist    ${object_list}    scf=${scf}

Calculate UtraAnr Timeout
    ${anrUtraTRSCFS_timeout}=    Remove String Using Regexp    ${anrUtraTRSCFS}    \\D+
    ${anrUtraTRSC_timeout}=    Remove String Using Regexp    ${anrUtraTRSC}    \\D+
    ${anrUtraTRCGI_timeout}=    Remove String Using Regexp    ${anrUtraTRCGI}    \\D+
    ${utraAnr_timeout}    set variable    ${${${anrUtraTRSCFS_timeout}+${anrUtraTRSC_timeout}+${anrUtraTRCGI_timeout}}/1000}
    set suite variable    ${utraAnr_timeout}