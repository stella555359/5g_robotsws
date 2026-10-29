*** Settings ***
Suite Setup       Common Suite Setup And Setup Cus Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               DevHZ5_SG4    owner-Chendong.He
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${anrUtraTRSCFS}    5000ms    #default value in SCF
${anrUtraInactivityTimer}    5    #inactivity timer in vendor
${anrUtraTRSC}    2500ms    #default value in vendor
${anrUtraTRCGI}    8200ms    #default value in vendor
@{PARAMS_IN_SCF}
...  @{Delete Neighbour Relation}
...  @{Mobility_Parameter}
...  @{Drx_Parameter}
...  @{PARAMS_FOR_ANRUTRA}
...  @{PARAMS_TO_DISABLE_OTHER_ANR}
@{Delete Neighbour Relation}
...  delete:LNADJ.*
...  delete:LNREL.*
...  delete:LNADJW.*
...  delete:LNRELW.*
@{PARAMS_FOR_001_TC18}
...  ANRPRW-0:rncIdCoding:rncIdType=extended
@{Mobility_Parameter}
...  LNCEL-1:threshold1=80
...  LNCEL-1:a3Offset=12
...  LNCEL-1:hysA3Offset=0
...  LNCEL-1:threshold3=59
...  LNCEL-1:threshold3a=60
...  LNCEL-1:threshold2a=70
@{Drx_Parameter}
...  LNCEL-1/DRX-0:drxProfile3:drxProfilePriority=30
...  LNCEL-1/DRX-0:drxProfile3:drxOnDuratT=6
...  LNCEL-1/DRX-0:drxProfile3:drxInactivityT=10
...  LNCEL-1/DRX-0:drxProfile3:drxRetransT=4
...  LNCEL-1/DRX-0:drxProfile3:drxLongCycle=80ms
...  LNCEL-1:drxProfile102:drxInactivityT=2560
...  LNCEL-1:drxProfile102:drxLongCycle=1280ms
...  LNCEL-1:drxProfile102:drxOnDuratT=10
...  LNCEL-1:drxProfile102:drxProfileIndex=102
...  LNCEL-1:drxProfile102:drxProfilePriority=30
...  LNCEL-1:drxProfile102:drxRetransT=16
...  LNBTS-1:qciTab8:qci=8
...  LNBTS-1:qciTab8:drxProfileIndex=3
@{PARAMS_TO_DISABLE_OTHER_ANR}
...  LNBTS-1:actUeBasedAnrInterFreqLte=false
...  LNBTS-1:actUeBasedAnrIntraFreqLte=false
...  LNBTS-1:actAnrRtt=false
...  LNCEL-1:idleLBPercentageOfUes=0
...  LNCEL-1:actDrx=true
...  LNBTS-1:actIfHo=disabled
...  LNBTS-1:actHOtoWcdma=false
...  delete:a2TimeToTriggerActInterFreqMeas
...  LNBTS-1:actRedirect=disabled
@{PARAMS_FOR_ANRUTRA}
...  LNBTS-1:actUeBasedAnrUtran=true
...  ANRPRW-0:utraCarrierFreq=${UTRA_SIM_ENB_ARFCN_1}
...  ANRPRW-0:rncIdCoding:rncIdAlignment=left
...  ANRPRW-0:rncIdCoding:rncIdType=normal
...  ANRPRW-0:lnRelWLimitForAnr=3
...  ANR-0:anrUtraTRSCFS=${anrUtraTRSCFS}
${UTRA_SIM_ENB_ARFCN_1}    10562
${Ue_Capabilities_908_fgi_19_1_33_na_114_na}    851FF05003254CA010581030206040C08181030205FC34F202002010
${Ue_Capabilities_908_no_gaps_needed}    851FF05003254CA010580010002000400080010001FC34F202002010
${Ue_Capabilities_908_fgi_19_1_33_1F_114_1}    C91FF05003254CA010581030206040C08181030205DC34F202002010800C1620000000002000080000
@{PM_COUNTERS}
...  ${UTRAN_REPORT_CGI_ATT}=1
...  ${UTRAN_REPORT_CGI_SUCC}=1
...  ${UTRAN_REPORT_CGI_INCOMPL}=0
${UTRAN_REPORT_CGI_INCOMPL}    M8008C14
${UTRAN_REPORT_CGI_SUCC}    M8008C13
${UTRAN_REPORT_CGI_ATT}    M8008C12

*** Test Cases ***
LTE908 TC18 RSC report CGI Measurement RNC Id decoding extended left
    [Documentation]    check ReportCgi correctly when RNC ID decoding is left and extended
    [Tags]
    Change RNC ID Decoding
    Calculate UtraAnr Timeout
    Start Rtpm Counter
    UE Attach And Report RSCFS
    Report RCS And CGI MeasurementReport
    Release All Ues
    Check Objects Exist
    Check RTPM Counter    file_name=reference_PM_001_TC18

*** Keywords ***
Common Suite Setup And Setup Cus Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Execute Egate Command    trace_sim on mme=1 protocol=s1
    Execute Egate Command    trace uec=1 protocol=rrc on
    Create Alias

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create mme alias    MME_1    mme_id=1    id_type=wts
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts

Change RNC ID Decoding
    Parameters Configuration    ${PARAMS_FOR_001_TC18}

Parameters Configuration
    [Arguments]    ${delta_params}
    Delta Commission Parameters    ${delta_params}
    Cells Should Be OnAir

Modify Yaml
    Add Yaml      EPC/RNC
    ...    - id: 12
    ...    host_enb: 4
    ...    rnc_id: 19
    ...    lac: 44
    ...    plmn: '262:03'
    Add Yaml      EPC/RNC
    ...    - id: 13
    ...    host_enb: 5
    ...    rnc_id: 20
    ...    lac: 44
    ...    plmn: '262:03'
    Add Yaml      EPC/RNC
    ...    - id: 14
    ...    host_enb: 6
    ...    rnc_id: 21
    ...    lac: 44
    ...    plmn: '262:03'
    ${rnc12_enb4_CELL1}    catenate    - {id: 41, technology: utran, rnc: 12, uarfcn: '10562:6666',  type: FDD,
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 1101, rac: 55, pci: '13:1'}
    ${rnc12_enb4_CELL1_LTE}   catenate    - {id: 1, technology: 'lte', tac: 33, pci: '4:1', earfcn: '1400:19400', eci: '0x0000401'}
    ${rnc13_enb5_CELL1}    catenate    - {id: 51, technology: utran, rnc: 13, uarfcn: '10562:6666',  type: FDD,
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 1102, rac: 55, pci: '13:2'}
    ${rnc13_enb5_CELL1_LTE}   catenate    - {id: 1, technology: 'lte', tac: 33, pci: '5:1', earfcn: '1400:19400', eci: '0x0000501'}
    ${rnc14_enb6_CELL1}    catenate    - {id: 61, technology: utran, rnc: 14, uarfcn: '10562:6666',  type: FDD,
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 1103, rac: 55, pci: '14:1'}
    ${rnc14_enb6_CELL1_LTE}   catenate    - {id: 1, technology: 'lte', tac: 33, pci: '6:1', earfcn: '1400:19400', eci: '0x0000601'}
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
    Add Yaml    BASE_STATIONS
    ...    - id: 5
    ...    type: 'simulated'
    ...    plmn: '262:03'
    ...    s1: '10.0.1.32'
    ...    enb_id: '0x00005'
    ...    x2_peers: none
    ...    cells:
    ...      ${rnc13_enb5_CELL1}
    ...      ${rnc13_enb5_CELL1_LTE}
    Add Yaml    BASE_STATIONS
    ...    - id: 6
    ...    type: 'simulated'
    ...    plmn: '262:03'
    ...    s1: '10.0.1.33'
    ...    enb_id: '0x00006'
    ...    x2_peers: none
    ...    cells:
    ...      ${rnc14_enb6_CELL1}
    ...      ${rnc14_enb6_CELL1_LTE}

Cus UE attach to eNB1
    [Arguments]    ${ueid}=1    ${cellid}=1    ${ue_eutra_capabilities}=${ue_eutra_capabilities}    ${sleeptime}=0
    Execute Uex Command    ue_param id=${ueid} csfb_rat=utran_geran voice_domain_preference=lte_preferred
    Execute Uex Command    ue_param id=${ueid} ue_eutra_capabilities=${ue_eutra_capabilities}
    Execute Uex Command    ue_attach id=${ueid} cell=${cellid} selected_plmn=262:03
    sleep    ${sleeptime}

Configure RSCFS Reporting
    ${rscfs_report_command}=    Catenate
    ...    ue_rrc_reconf_param id=1 if_contains=purpose with_value=reportStrongestCellsForSON
    ...    action=measurement_send id=1 phycell_id=40 arfcn=10562 type=fdd nrscp=91 necn0=49
    ...    lac=44 rac=55 strongest=utra cgi=244:09|0x4D04130 son=true
    Execute Uex Command    ${rscfs_report_command}

Report RCS And CGI MeasurementReport
    ${cgi_check_command}=    Catenate
    ...    s-Measure eq 80 and
    ...    purpose eq 'reportCGI' and
    ...    drx-InactivityTimer eq 'psf2560' and
    ...    drx-RetransmissionTimer eq 'psf16' and
    ...    longDRX-CycleStartOffset contains ( 'sf1280' ) and
    ...    onDurationTimer eq 'psf10' and
    ...    timeAlignmentTimerDedicated eq 'sf10240'
    ${drx_check_command}=    Catenate
    ...    drx-InactivityTimer eq 'psf10' and
    ...    drx-RetransmissionTimer eq 'psf4' and
    ...    longDRX-CycleStartOffset contains ( 'sf80' ) and
    ...    onDurationTimer eq 'psf6' and
    ...    timeAlignmentTimerDedicated eq 'sf10240'
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration ( ${cgi_check_command} )
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    UE_1:RRC_RRCConnectionReconfiguration ( ${drx_check_command} )
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=LTE908_tc18_flow2    overall_timeout=${utraAnr_timeout}
    ${rsc_report_command}=    Catenate
    ...    ue_measurement_send id=1 phycell_id=40 arfcn=10562 type=fdd
    ...    nrscp=91 necn0=49 lac=44 rac=55 strongest=utra cgi=244:09|0x4D04130 son=true
    Execute Uex Command    ${rsc_report_command}
    Flow Occurred As Expected    LTE908_tc18_flow2

UE Attach And Report RSCFS
    ${rscfs_check}=    Catenate
    ...    measObjectToAddModList contains ( measObject contains ( measObjectEUTRA contains ( carrierFreq eq 1400 ))) and
    ...    measObjectToAddModList contains ( measObject contains ( measObjectUTRA contains ( carrierFreq eq 10562 ))) and
    ...    purpose eq 'reportStrongestCellsForSON' and
    ...    s-Measure eq 0
    Configure RSCFS Reporting
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionRequest ( establishmentCause eq 'mo-Signalling' )
    ...    UE_1:RRC_RRCConnectionSetup
    ...    UE_1:RRC_RRCConnectionSetupComplete
    ...    UE_1:RRC_RRCConnectionReconfiguration ( ${rscfs_check} )
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    UE_1:RRC_RRCConnectionReconfiguration ( purpose eq 'reportStrongestCells' )
    ...    alias=LTE908_tc18_flow1    overall_timeout=30
    Cus UE attach to eNB1    ue_eutra_capabilities=${Ue_Capabilities_908_fgi_19_1_33_na_114_na}
    Flow Occurred As Expected    LTE908_tc18_flow1

Calculate UtraAnr Timeout
    ${anrUtraTRSCFS_timeout}=    Remove String Using Regexp    ${anrUtraTRSCFS}    \\D+
    ${anrUtraTRSC_timeout}=    Remove String Using Regexp    ${anrUtraTRSC}    \\D+
    ${anrUtraTRCGI_timeout}=    Remove String Using Regexp    ${anrUtraTRCGI}    \\D+
    ${utraAnr_timeout}    set variable    ${${${anrUtraTRSCFS_timeout}+${anrUtraTRSC_timeout}+${anrUtraTRCGI_timeout}}/1000}
    set suite variable    ${utraAnr_timeout}

Check Objects Exist
    ${object_list}  Create List  LNADJW:uTargetCid=304  LNADJW:uTargetFreq=10562  LNADJW:uTargetLac=44  LNADJW:uTargetRac=55
    ...  LNADJW:uTargetRncId=19716
    ...    LNADJW:uTargetScFdd=40
    Object Should Exist    ${object_list}
    ${scf}=    Download Scf
    ${object_list}  Create List  LNRELW:csfbPsHoAllowed=allowed  LNRELW:nrControl=automatic  LNRELW:nrStatus=available  LNRELW:psHoAllowed=allowed
    ...  LNRELW:redirWithSysInfoAllowed=allowed
    ...  LNRELW:removeAllowed=true  LNRELW:srvccAllowed=allowed  LNRELW:uTargetCid=304  LNRELW:uTargetRncId=19716  LNRELW:utranLbAllowed=true
    Object Should Exist    ${object_list}    scf=${scf}

Check RTPM Counter
    [Arguments]    ${file_name}
    Check Rtpm Counters    pm_reference_file=${CURDIR}/Data/${file_name}.txt

