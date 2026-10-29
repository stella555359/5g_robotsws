*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-CN1ET    owner-christine.chen    release-5G22R3    CB008542
Resource  ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${BTS_STARTUP_RETRY}  2
${DEBUG_LOG_LEVEL}    4
${cell_id}    1
@{PARAMS_IN_SCF}
...    NRBTS:actFdmScheduling=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actLteNrDss=false
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRCELL-1:actCDrx=false
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-10:lcrId=11
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:sCellDeactivationTimerGNB=infinity
${CA_support_list}  ca_Fr1Tdd_Fdd_Nsa

@{OnlineParam_BB024}
...    NRCELL-1/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-1:maxNumOfCaUsersNRCell=3
...    NRCELL-11:maxNumOfSCellAlloc=2

@{OnlineParam_BB025}
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1:maxNumOfCaUsersNRCell=2
...    NRCELL-11:maxNumOfSCellAlloc=3

@{PM_Counters_Check_BB024}
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=3
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=2
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-1:RACCU:${SGNB_SCELL_ADMISSION_UNSUCC}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=2
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=2
...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021
#The number of radio admission requests for 1 Scell
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028
#The number of successful radio admissions for 1 Scell additions.
${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
#RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
#Successful RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${UE_PSCELL_1_CONF_SCELL_DL}    M55118C04000
#Number of CA UEs in the current cell configured as a PSCell, which have 1 configured SCell in DL
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
#The number of radio admission requests for 1 Scell
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015
#The number of successful radio admissions for 1 Scell additions.
${SGNB_SCELL_ADMISSION_UNSUCC}    M55114C00035
#The number of unsuccessful radio admissions for S-Cells additions. Updated to the PS-Cell whenever no S-Cells are admitted
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006
#The number of radio admission requests for the Scell
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007
#The number of successful radio admissions for the Scell
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000
#Number of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL

*** Test Cases ***
CB008542-ET-BB024_NSA_Multi_UEs_Radio_Admission_Control_Failure_during_Scell_Addition_due_to_gNB-CU_limitation_of_maxNumOfSCellAlloc
    [Documentation]
    ...    1. The purpose of this test case is to check the gNB behaviour at the limits of radio resources in gNB-CU,
    ...    when UE is going to be configured with carrier aggregation.
    ...        cell selection combination:
    ...        TF: config cell-11 as cell-1 scell.(blind)
    ...        NRCELL1/maxNumOfUsersPerNRCell>5
    ...        NRCELL1/maxNumOfCaUsersNrCell=3
    ...        NRCELL11/maxNumOfSCellAlloc=2
    ...    2. Test Case Steps:
    ...         a. CA NSA UE91 attach to NR Cell 1
    ...         b. check UE91 attched to cell1, scell is cell11
    ...         c. Repeat step a to b with UE92
    ...         d. Repeat step a to b with UE93, scell is not added for UE93.
    ...         e. check traffic data
    ...         f. check counter
    ...         g. all UE detach
    ...    3. Expected Results:
    ...         Step b: NSA UE91 call setup successfully. traffic is ok.
    ...                 IE: on wireshark log:
    ...                 sCellIndex = 9
    ...                 candidateCellInfoListMN.physCellId = 50
    ...                 candidateCellInfoListMN.physCellId = 60
    ...         Step c: NSA UE92 call setup successfully. traffic is ok.
    ...                 IE: on wireshark log:
    ...                 sCellIndex = 9
    ...                 candidateCellInfoListMN.physCellId = 50
    ...                 candidateCellInfoListMN.physCellId = 60
    ...         Step d: NSA UE93 call setup successfully. traffic is ok.
    ...                 IE: on wireshark log:
    ...                 servCellIndex = 8
    ...         Step g: ALL call can be released successfully.
	[Tags]    QC_164097    BB024    christine.chen
	Delta Commission Parameters    ${OnlineParam_BB024}
	Clear Counter Files
	NSA CA UE Attach To Cell and Initial blind scelladd    91    ${cell_id}
	NSA CA UE Attach To Cell and Initial blind scelladd    92    ${cell_id}
	NSA CA UE Attach To Cell and Initial blind scelladd    93    ${cell_id}
	Verify Throuput on Pscell and Scell    sleep_time=60s
	Stop Traffic And Detach Ue
	Check Wireshark And RRC Logs for BB024
	Check Counters    ${PM_Counters_Check_BB024}

CB008542-ET-BB025_NSA_Multi_UEs_Radio_Admission_Control_Failure_during_Scell_Addition_due_to_gNB-CU_limitation_of_maxNumOfCaUsersNrCell
    [Documentation]
    ...    1. The purpose of this test case is to check the gNB behaviour at the limits of radio resources in gNB-CU,
    ...    when UE is going to be configured with carrier aggregation.
    ...        cell selection combination:
    ...        TF: config cell-11 as cell-1 scell.(covBasedA1)
    ...        NRCELL1/maxNumOfUsersPerNRCell>5
    ...        NRCELL1/maxNumOfCaUsersNrCell=2
    ...        NRCELL11/maxNumOfSCellAlloc=3
    ...    2. Test Case Steps:
    ...         a. CA NSA UE91 attach to NR Cell 1
    ...         b. check UE91 attched to cell1, A1 measurement report based SCell addition is triggered.
    ...         c. Repeat step a to b with UE92.
    ...         d. Repeat step a to b with UE93,scell is not added for UE93.
    ...         e. check traffic data
    ...         f. check counter
    ...         g. all UE detach
    ...    3. Expected Results:
    ...         Step b: NSA UE91 call setup successfully. traffic is ok.
    ...                 IE: on wireshark log:
    ...                 sCellIndex = 9
    ...                 candidateCellInfoListMN.physCellId = 50
    ...                 candidateCellInfoListMN.physCellId = 60
    ...         Step c: NSA UE92 call setup successfully. traffic is ok.
    ...                 IE: on wireshark log:
    ...                 sCellIndex = 9
    ...                 candidateCellInfoListMN.physCellId = 50
    ...                 candidateCellInfoListMN.physCellId = 60
    ...         Step d: NSA UE93 call setup successfully. traffic is ok.
    ...                 IE: on wireshark log:
    ...                 servCellIndex = 8
    ...         Step g: ALL call can be released successfully.
	[Tags]    QC_164098    BB025    christine.chen
	Delta Commission Parameters    ${OnlineParam_BB025}
	Clear Counter Files
	NSA CA UE Attach To Cell and Initial covBaseA1 scelladd    91    ${cell_id}
	NSA CA UE Attach To Cell and Initial covBaseA1 scelladd    92    ${cell_id}
	NSA CA UE Attach To Cell and Initial covBaseA1 scelladd    93    ${cell_id}     scell_added_successful=fail
	Verify Throuput on Pscell and Scell    sleep_time=60s
	Stop Traffic And Detach Ue
	Check Wireshark And RRC Logs for BB025
	Check Counters    ${PM_Counters_Check_BB024}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

NSA CA UE Attach To Cell and Initial blind scelladd
    [Arguments]    ${ue_id}=91    ${cell_id}=1
    Start RRC Log    NSA_UE${ue_id}_blind_scelladd
    NSA UE attach    ${ue_id}    ${cell_id}
    Get RRC Log
    Send Throuput    ${ue_id}

NSA CA UE Attach To Cell and Initial covBaseA1 scelladd
    [Arguments]    ${ue_id}=91    ${cell_id}=1    ${scell_added_successful}=pass
    Start RRC Log    NSA_UE${ue_id}_covBaseA1_scelladd
    NSA UE attach    ${ue_id}    ${cell_id}
    Add gNB Cell1 As Scell By A1    ${ue_id}    ${scell_added_successful}
    Get RRC Log
    Send Throuput    ${ue_id}

Add gNB Cell1 As Scell By A1
    [Arguments]    ${ue_id}=91   ${scell_added_successful}=pass    ${carrierfreq}=518910
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Start RRC Log    NSA_UE${ue_id}_covBaseA1_scelladd
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=120 ssinr_nr=59 srsrq_nr=120
    ...   ${scell_added_successful}_regexp=SCellIndex 9 activated successfully

NSA UE attach
    [Arguments]    ${ue_id}=91    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    ${cmd}    catenate    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    Execute Egate Command    ${cmd}    successful RA

Check Wireshark And RRC Logs for BB024
    Check RRC log    ${CURDIR}${/}a2a_BB024${/}a2a.ini
    check wireshark log    ${CURDIR}${/}a2a_BB024${/}a2a.ini

Check Wireshark And RRC Logs for BB025
    Check RRC log    ${CURDIR}${/}a2a_BB025${/}a2a.ini
    check wireshark log    ${CURDIR}${/}a2a_BB025${/}a2a.ini

Stop Traffic And Detach Ue
    UE Detach From GNB
    Stop Traffic

Stop Traffic
    Execute Egate Command    trf_data_stop ue=91    pass_regexp=Traffic was stopped

UE Detach From GNB
    [Arguments]    ${expect_string}=${EMPTY}
    Execute Egate Command  ue_detach id=91    ${expect_string}
    Execute Egate Command  ue_detach id=92    ${expect_string}
    Execute Egate Command  ue_detach id=93    ${expect_string}

Send Throuput
    [Arguments]    ${ue_id}    ${sleep_time}=40s
    sleep    ${sleep_time}
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=110 trf_id=3    UE ${ue_id}: UDP DL
	Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=15    UE ${ue_id}: UDP UL

Verify Throuput on Pscell and Scell
    [Arguments]    ${sleep_time}=60s
    sleep    ${sleep_time}
    ${scell8_tput_91}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=8    type=pdsch    rate_type=ave
    ${scell8_tput_92}    Ap Get Throuput On Specific Scell    ue_id=92   scell_id=8    type=pdsch    rate_type=ave
    ${scell8_tput_93}    Ap Get Throuput On Specific Scell    ue_id=93    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput_91}/1000+${scell8_tput_92}/1000+${scell8_tput_93}/1000 > 300
    ${scell9_tput_91}    Ap Get Throuput On Specific Scell    ue_id=92    scell_id=9    type=pdsch    rate_type=ave
    ${scell9_tput_92}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput_91}/1000+${scell9_tput_92}/1000 > 60
    ${ul_throuput_91}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    ${ul_throuput_92}    Ap Get NSA Throughput    ue_id=92    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    ${ul_throuput_93}    Ap Get NSA Throughput    ue_id=93    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput_91}/1000+${ul_throuput_92}/1000+${ul_throuput_93}/1000 > 35

