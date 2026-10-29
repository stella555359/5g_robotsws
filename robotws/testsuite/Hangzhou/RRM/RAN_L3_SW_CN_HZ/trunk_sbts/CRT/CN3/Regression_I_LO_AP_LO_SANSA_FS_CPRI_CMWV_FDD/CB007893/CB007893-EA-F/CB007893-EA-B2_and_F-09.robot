*** Settings ***
Suite Setup       Start BTS With Specified Config Files
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G
...               Regression_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD  team-CN1  owner-jun.3.ye release-5G21B
Resource          ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    fddtdd_sansa_cmwv/2cells_1T1F
@{PARAMS_IN_SCF}
...  @{CA_Basic}
...  @{CB007893}
@{CA_Basic}
...  NRDU-1:actInterNumerologyCa=true
...  NRDU-1:flexibleCAMode=MixedCAMode
...  NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Nsa
...  NRDU-1:refNrCellGroup=0,1
...  NRCELL-1:pucchModeSelect=longPucch
@{CB007893}
...  NRBTS:actMeasBasedSCellAdditionSa=A1-based
...  NRBTS:actMeasBasedSCellAdditionNsa=true
...  NRCELL-1:a1MeasSCellAddEnabled=rsrpCombined
...  NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...  NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...  NRCELL-1:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...  NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...  NRCELL-2:a2MeasSCellRelEnabled=rsrpCombined
...  NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...  NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=480ms
...  NRCELL-2:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2ThresholdSCellRelSsbRsrq=480ms
...  NRCELL-2:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2ThresholdSCellRelSsbRsrq=480ms
...  NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...  NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...  NRCELL-1/NRREL-10:gNbId=2
...  NRCELL-1/NRREL-10:gNbIdLength=22
...  NRCELL-1/NRREL-10:lcrId=2
...  NRCELL-1/NRREL-10:removeNotAllowed=false
...  NRCELL-1/NRREL-10:gnbPlmn:mcc=311|mncLength=3
...  NRCELL-1/NRREL-10:gnbPlmn:mnc=489|mncLength=3
...  NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
@{PM_Counters}
...  NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...  NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
@{PM_Counters_B_22}
...  NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=2
...  NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...  NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...  NRCELL-2:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
@{PM_Counters_F_09}
...  NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...  NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...  NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_ATT_NSA}=1
...  NRCELL-1:NCAC:${A2MEAS_REL1DLSCELL_SUCC_NSA}=1
...  NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...  NRCELL-2:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
@{Value_Flag_of_SCellAddition_and_sCellAdditionMethod_False}
...  MRBTS-2/NRBTS-2:actMeasBasedSCellAdditionSa=disabled
...  MRBTS-2/NRBTS-2:actMeasBasedSCellAdditionNsa=false
...  MRBTS-2/NRBTS-2/NRCELL-1/NRREL-10:sCellAdditionMethod=blind
...  MRBTS-2/NRBTS-2/NRCELL-2:a2MeasSCellRelEnabled=none
@{Value_actMeasBasedSCellAdditionNSA_False}
...  MRBTS-2/NRBTS-2:actMeasBasedSCellAdditionSa=A1-based
...  MRBTS-2/NRBTS-2:actMeasBasedSCellAdditionNsa=false
...  MRBTS-2/NRBTS-2/NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...  MRBTS-2/NRBTS-2/NRCELL-2:a2MeasSCellRelEnabled=rsrpCombined
@{Value_actMeasBasedSCellAdditionNSA_True}
...  MRBTS-2/NRBTS-2:actMeasBasedSCellAdditionSa=A1-based
...  MRBTS-2/NRBTS-2:actMeasBasedSCellAdditionNsa=true
...  MRBTS-2/NRBTS-2/NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
@{Value_a1MeasSCellAddEnabled_none_and_sCellAdditionMethod_blind}
...  MRBTS-2/NRBTS-2/NRCELL-1:a1MeasSCellAddEnabled=none
...  MRBTS-2/NRBTS-2/NRCELL-1/NRREL-10:sCellAdditionMethod=blind
...  MRBTS-2/NRBTS-2:actMeasBasedSCellAdditionSa=disabled
...  MRBTS-2/NRBTS-2:actMeasBasedSCellAdditionNsa=false
...  MRBTS-2/NRBTS-2/NRCELL-2:a2MeasSCellRelEnabled=none
@{Value_a1MeasSCellAddEnabled_rsrp_and_sCellAdditionMethod_covBasedA1}
...  MRBTS-2/NRBTS-2/NRCELL-1:a1MeasSCellAddEnabled=rsrp
...  MRBTS-2/NRBTS-2/NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...  MRBTS-2/NRBTS-2:actMeasBasedSCellAdditionSa=A1-based
...  MRBTS-2/NRBTS-2:actMeasBasedSCellAdditionNsa=true
...  MRBTS-2/NRBTS-2/NRCELL-2:a2MeasSCellRelEnabled=rsrpCombined
@{B_17_18_Preconditions_Parameters}
...  MRBTS-2/NRBTS-2/NRCELL-1:a1MeasSCellAddEnabled=rsrp
@{Value_of_a1MeasSCellAddEnabled_rsrpCombined}
...  MRBTS-2/NRBTS-2/NRCELL-1:a1MeasSCellAddEnabled=rsrpCombined
@{Value_of_a1MeasSCellAddEnabled_rsrpAndRsrq}
...  MRBTS-2/NRBTS-2/NRCELL-1:a1MeasSCellAddEnabled=rsrpAndRsrq
@{B_20_Preconditions_Parameters}
...  MRBTS-2/NRBTS-2/NRCELL-1:a1MeasSCellAddEnabled=rsrqCombined
@{Value_a1ThresholdSCellAddSsbRsrpTDD_and_a1HysteresisSCellAddSsbRsrp_below}
...  MRBTS-2/NRBTS-2/NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=40
...  MRBTS-2/NRBTS-2/NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
@{Value_a1ThresholdSCellAddSsbRsrpTDD_and_a1ThresholdSCellAddSsbRsrq_bigger}
...  MRBTS-2/NRBTS-2/NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=127
...  MRBTS-2/NRBTS-2/NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=35
@{F_09_Preconditions_Parameters}
...  MRBTS-2/NRBTS-2/NRCELL-2:a2MeasSCellRelEnabled=rsrpCombined
...  MRBTS-2/NRBTS-2/NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
...  MRBTS-2/NRBTS-2/NRCELL-1:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30
@{Value_of_a2ThresholdSCellRelSsbRsrq_bigger}
...  MRBTS-2/NRBTS-2/NRCELL-2:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=127
${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
${A2MEAS_REL1DLSCELL_ATT_NSA}    M55118C06503
${A2MEAS_REL1DLSCELL_SUCC_NSA}    M55118C06504
${UE_PSCELL_1_CONF_SCELL_DL}    M55118C04000
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000

*** Test Cases ***
CB007893-EA-B2_ET_15_01_Online change actMeasBasedSCellAddition and sCellAdditionMethod parameters after Pcell A1 measurement configured
    [Documentation]
    ...    This case is to verify:
    ...    Online change actMeasBasedSCellAdditionSa=disabled, actMeasBasedSCellAdditionNSA=false and sCellAdditionMethod=blind,
    ...    A1 event will not trigger CA addition
    ...    Online change actMeasBasedSCellAdditionSa=A1-based, actMeasBasedSCellAdditionNSA=false and sCellAdditionMethod= covBasedA1,
    ...    A1 event will not trigger CA addition
    ...    Online change actMeasBasedSCellAdditionSa=A1-based, actMeasBasedSCellAdditionNSA=true and sCellAdditionMethod= covBasedA1,
    ...    A1 event will trigger CA addition
    [Tags]
    clear counter files
    UE Attach and initial EN-DC
    Delta Commission Parameters    ${Value_Flag_of_SCellAddition_and_sCellAdditionMethod_False}
    No action when receiving A1 event
    Delta Commission Parameters    ${Value_actMeasBasedSCellAdditionNSA_False}
    No action when receiving A1 event
    Delta Commission Parameters    ${Value_actMeasBasedSCellAdditionNSA_True}
    Scell addition triggered by A1 event
    check wireshark log    ${CURDIR}${/}a2a_CB007893-EA-B2_ET${/}a2a.ini
    Check counters    ${PM_Counters}
    [Teardown]    Recover The ENV And Stop Capture Logs    ${Value_actMeasBasedSCellAdditionNSA_True}

CB007893-EA-B2_ET_17_01_Online change a1MeasSCellAddEnabled and sCellAdditionMethod parameters after Pcell A1 measurement configured
    [Documentation]
    ...    This case is to verify:
    ...    Online change a1MeasSCellAddEnabled=none and sCellAdditionMethod= blind, A1 event will not trigger CA addition
    ...    Online change a1MeasSCellAddEnabled=rsrp and sCellAdditionMethod= covBasedA1, A1 event will trigger CA addition
    [Tags]
    clear counter files
    Precondition Setting    Preconditions_param=${B_17_18_Preconditions_Parameters}
    UE Attach and initial EN-DC
    Delta Commission Parameters    ${Value_a1MeasSCellAddEnabled_none_and_sCellAdditionMethod_blind}
    No action when receiving A1 event
    Delta Commission Parameters    ${Value_a1MeasSCellAddEnabled_rsrp_and_sCellAdditionMethod_covBasedA1}
    Scell addition triggered by A1 event
    check wireshark log    ${CURDIR}${/}a2a_CB007893-EA-B2_ET${/}a2a.ini
    Check counters    ${PM_Counters}
    [Teardown]    Recover The ENV And Stop Capture Logs    ${Value_of_a1MeasSCellAddEnabled_rsrpCombined}

CB007893-EA-B2_ET_19_01_Online change a1MeasSCellAddEnabled to different values after Pcell A1 measurement configured
    [Documentation]
    ...    This case is to verify
    ...    Online change a1MeasSCellAddEnabled from rsrpCombined to rsrpAndRsrq, A1 event will trigger CA addition with rsrq value below
    ...    a1ThresholdSCellAddSsbRsrq+a1Hysteresis
    [Tags]
    clear counter files
    UE Attach and initial EN-DC
    No action when receiving A1 event    srsrq_nr=20
    Delta Commission Parameters    ${Value_of_a1MeasSCellAddEnabled_rsrpAndRsrq}
    Scell addition triggered by A1 event    srsrq_nr=20
    check wireshark log    ${CURDIR}${/}a2a_CB007893-EA-B2_ET${/}a2a.ini
    Check counters    ${PM_Counters}
    [Teardown]    Recover The ENV And Stop Capture Logs    ${Value_of_a1MeasSCellAddEnabled_rsrpCombined}

CB007893-EA-B2_ET_22_01_Online change a1ThresholdSCellAddSsbRsrp when a1MeasSCellAddEnabled is rsrpAndRsrq after Pcell A1 measurement configured
    [Documentation]
    ...    This case is to verify
    ...    no change a1ThresholdSCellAddSsbRsrp value when a1MeasSCellAddEnabled is rsrpAndRsrq, A1 event will trigger CA addition with rsrq
    ...    value below a1ThresholdSCellAddSsbRsrq+a1Hysteresis
    ...    Online change a1ThresholdSCellAddSsbRsrp and rsrq to bigger values to bigger when a1MeasSCellAddEnabled is rsrpAndRsrq, A1 event will
    ...    trigger CA addition with same value again
    [Tags]
    clear counter files
    Precondition Setting    Preconditions_param=${Value_of_a1MeasSCellAddEnabled_rsrpAndRsrq}
    UE Attach and initial EN-DC
    Scell addition triggered by A1 event    srsrq_nr=20
    Delta Commission Parameters    ${Value_a1ThresholdSCellAddSsbRsrpTDD_and_a1ThresholdSCellAddSsbRsrq_bigger}
    UE Attach and initial EN-DC    32
    Scell addition triggered by A1 event    32    2    srsrp_nr=50
    check wireshark log    ${CURDIR}${/}a2a_CB007893-EA-B2_ET_22_01${/}a2a.ini
    Check counters    ${PM_Counters_B_22}
    [Teardown]    Recover The ENV And Stop Capture Logs    ${Value_of_a1MeasSCellAddEnabled_rsrpCombined}    31,32

CB007893-F-B1-B2_ET_09_01_Scell A2 measurement report but do not meet threshold when a2MeasSCellRelEnabled set to rsrpCombined
    [Documentation]
    ...    This case is to verify
    ...    rsrq value above a2HysteresisSCellRelSsbRsrq+a2ThresholdSCellRelSsbRsrq when a2MeasSCellRelEnabled set to rsrpCombined after A1 event
    ...    trigger, A2 event will not be trigger
    ...    Online change a2ThresholdSCellRelSsbRsrq to bigger value, A2 event will trigger Scell Removed with same value again
    [Tags]
    clear counter files
    Precondition Setting    Preconditions_param=${F_09_Preconditions_Parameters}
    UE Attach and initial EN-DC
    Scell addition triggered by A1 event
    No action when receiving A2 event
    Delta Commission Parameters    ${Value_of_a2ThresholdSCellRelSsbRsrq_bigger}
    Scell Removed triggered by A2 event
    check wireshark log    ${CURDIR}${/}a2a_CB007893-EA-F_ET_09_01${/}a2a.ini
    Check counters    ${PM_Counters_F_09}
    [Teardown]    Recover The ENV And Stop Capture Logs    ${F_09_Preconditions_Parameters}

*** Keywords ***
Start BTS With Specified Config Files
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}

Modify Cfg
    Update Cfg    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    ${UE_EUTRA_NR_CAP}  catenate  SEPARATOR=
    ...  ue_param id=31-60 ue_eutra_nr_capabilities=A11FF82384C0C03850001C46000000122205C160601C46000002022205C260601828
    ...  0388C00000824440B84C0C038500018460001848881005011A0140030506504893A24ED8E7C3853A76C73E1C49D1276C73E1C403639F0C0
    ...  801880002010100200804030060800040202018030800020101002000040300610000402020040100806000 ue_nr_capabilities=E9A0
    ...  9000575F5A13160003C12016093170019C3D0304D9061CF9863CA160704C020311C02EE3614606B04610D04083A40236B64C558D0E7C471
    ...  E819F604F8C48E3C873EA39F30C7942C0E070F05C0017C0070005F0002400702A0D883AC1184341020F1008CAD931562439F604F88E3C62
    ...  471E439F51CF9863CA1607038784FEC000003FB0000001220380030F506C46D608C21A081078804656C98AB121CFB027C471E31238F21CF
    ...  A8E7CC31E50B0381C3C27F0000001FC00000009001C00550388C080000240A838280388C000004240AC3C28000C2300008240AC1C280800
    ...  06020EB0F0A000305000040107003011A0140283902C09DB1CF870A74ED8E7C3851276C73E1C089B1CF870A24ED8E7C31E81E00F000A070
    ...  300E0600A80E000C0480080C07C120040000000200000401000000008000010040000100200000C01000008008000050040020080200800
    ...  00600400003802001000000040000400200002401000806018020000280100001600800409024010000180672A6B2A6B052B032B066B056
    ...  B296B266B016B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292
    ...  020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480629555D2AAAA55174AA2A82C55038
    ...  AA0D154A62A93455018AA051549AAA83C5030BC04A8140A05028140A05028140A05028140A05028140A000800101E018202004000080600
    ...  C101002008040300000080C004101002008040080018A1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F41
    ...  400 dual_conn=eutra_nr

    Update Cfg  ${UE_EUTRA_NR_CAP}

UE Attach and initial EN-DC
    [Arguments]    ${ue_id}=31    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id} profile=1    === UE IS ACTIVE
    Start RRC Log    UE_initial_ENDC
    ${ret1}=    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    reported successful RA    timeout=20s
    Should Contain    ${ret1}    eventId eventA1
    Get RRC Log

Scell addition triggered by A1 event
    [Arguments]    ${ue_id}=31    ${meas_id}=1    ${srsrp_nr}=80    ${srsrq_nr}=40
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=60 event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ...    value SgNBModificationConfirm    timeout=20s
    Should Contain    ${ret1}    value SgNBModificationRequired
    Should Contain    ${ret1}    Successfully reconfigured dual connectivity
    Should Contain    ${ret1}    value SgNBModificationConfirm

No action when receiving A1 event
    [Arguments]    ${ue_id}=31    ${meas_id}=1    ${srsrp_nr}=80    ${srsrq_nr}=40
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=60 event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ...    uENRMeasurements    timeout=20s
    Should not Contain    ${ret1}    value SgNBModificationRequired

Recover The ENV And Stop Capture Logs
    [Arguments]    ${Online_Param}    ${ue_id}=31
    Delta Commission Parameters    ${Online_Param}
    Execute Egate Command    ue_detach id=${ue_id}
    Common Test Teardown And Stop Capture Logs

Precondition Setting
    [Arguments]    ${Preconditions_param}=${EMPTY}
    Delta Commission Parameters    ${Preconditions_param}

No action when receiving A2 event
    [Arguments]    ${ue_id}=31    ${meas_id}=2    ${scell_rsrp}=60    ${scell_rsrq}=20
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=9 scell_rsrp=${scell_rsrp} scell_rsrq=${scell_rsrq}
    ...    uENRMeasurements    timeout=20s
    Should not Contain    ${ret1}    value SgNBModificationRequired

Scell Removed triggered by A2 event
    [Arguments]    ${ue_id}=31    ${meas_id}=2    ${scell_rsrp}=60    ${scell_rsrq}=20
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=9 scell_rsrp=${scell_rsrp} scell_rsrq=${scell_rsrq}
    ...    value SgNBModificationConfirm    timeout=20s
    Should Contain    ${ret1}    value SgNBModificationRequired
    Should Contain    ${ret1}    value Cause : radioNetwork : rRM-purpose
    Should Contain    ${ret1}    value SgNBModificationConfirm
