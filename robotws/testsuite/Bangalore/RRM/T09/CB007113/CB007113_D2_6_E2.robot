*** Settings ***
Force Tags        CLOUD_5G_I_MP_AP_LOOO     VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...               RAN_5G_TDD    SBTS00    CONFIGURED   CRT   TOOLS_PROFILE_TTI_LEGACY
Documentation    :copyright: Nokia
...              :authors: Sunil/Shekhar/Bhabani/Chaithanya
...              :contact: Sunil.T_Kurian@nokia.com (TC01)/chaithanya.h_s@nokia.com(TC02)
...   This feature introduces the functionality of TDD FR1 PRB pooling in UL to improve the cell amounts in BB cell set configuration:
...   1. The resources of processing PRB in L1 UL shall be pooled instead of dedicated allocation to achieve the cell amount requirement
...   in BB cell set feature. As figure 1 below, the pooling range includes:
...   a. Intra L1 subpool PRB pooing.
...   The NRCells in one L1 subpool share the pooled resources in its own L1 subpool. The PRB capability of each L1 subpool
...   not changable in runtime.
...   b. Inter L1 subpool PRB pooling


Resource         ../../5GET_BLR/CB008541/resources/CB008541_Keywords.robot
Resource         CB007113_Keyword.robot
Library          ./resources/check_cell_expected_prballocation.py
Library          ./resources/check_dl_ul_prballocation.py
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../5GET_BLR/resources/robot/Setup_Env.robot
Resource         ../../5GET_BLR/resources/robot/Airphone.robot
Resource         ../../5GET_BLR/resources/robot/WTS_Runner_Keywords.robot
Resource         ../../5GET_BLR/resources/robot/PM_Counters.robot
Resource	     ../../5GET_BLR/resources/robot/common_log_collection.robot
#Resource         resources/load_based_validation_keywords.resource


*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/basic_setup_7113-D.lua
${wts_cfg_file1}        ${CURDIR}/config/basic_setup_E_SBWP_4Cells_eachCell_30UEs.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}               1
${nwslice_ID}          1
${gw_ID}               1
${Pdu_session_ID}      1
${qfi_id}              1
${Q_O_ADD}             1
${RTP_COD}             1
${epc_log_path}        /tmp/
${TRF_ID}              1
${GFBR}                9
${r&d_parameter}     0x420068=7;0x58069C=1;0x580612=1;0x580686=0xa;0x58057c = 0x2800;0x58057a = 0x4
${PM_PCELL_COUNTER1}    M55139C00504
${PM_PCELL_COUNTER2}    M55167C00004
${PM_PCELL_COUNTER3}    M55167C00002
${SCFC}=               ${CURDIR}/config/SCF/SCF_CB007113_D2_6_ABIP_4Cell.xml
${AP_XML}=             ${CURDIR}/config/SCF/iphy_CB007113_D2_6_ABIP.xml
@{PhysCellID}      50    51    52


*** Test Cases ***
[1]CB007113_D2_6_Verify_successful_intra_gNB_HO_for_GBR_call_when_PUSCHPRB_pool_is_fully_used_with_GbrTrafficHO_10
    [Tags]   QC_27120   QCD_MN_RAN   QCP_RAN_VRF  TC01
    [Setup]    Run keywords     log to console     Suite Setup
    ...                 AND     Update GNB R&D Parameter   ${LOG_PATH}   ${r&d_parameter}
    ...                 AND     Prepare TL with all config files
    ...                 AND     Add routes
    ...                 AND     log to console   loading cfg file....
    ...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
    set test variable   ${LOG_PATH}
    Register 4Non GBR UEs High Traffic in each Cell and Traffic Check   1   61   80
    Register GBR Ues in Cell1 and Traffic Check
    Register GBR Ues in Cell2 and Traffic Check
    Register GBR Ues in Cell3 and Traffic Check
    Register GBR Ues in Cell4 and Traffic Check
    Run keyword and continue on failure    Verify PM Counter for DRB Rejection 4th Cell   M55139C00504
    Run keyword and continue on failure    Get PMCounters before HO
    Collect and decode TTI Log   Test_Step=BeforeHO   Duration=500ms
    Run keyword and continue on failure      Valiadate Prb Allocation from TTI Logs before HO    Test_Step=BeforeHO
    Validate GBR HO from Cell1 to Cell4   2   1   53
    Run keyword and continue on failure    Get PMCounters after HO and compare with old values
    Run keyword and continue on failure    Verify PM Counter for PRBs Available for PUSCH after HO   M55308C10004
    Collect and decode TTI Log   Test_Step=AfterHO   Duration=500ms
    Valiadate Prb Allocation from TTI Logs after HO    Test_Step=AfterHO
    [Teardown]    Run Keywords   Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting
    ...                 AND     Run Keyword and Ignore Error     Stop Default Logging   output_dirpath=${LOG_PATH}
    ...                 AND      Run Keyword and Ignore Error     Collect GNB AP SnapShot    log_dir_gnb=${LOG_PATH}
    ...                 AND      Run Keyword and Ignore Error     Collect SosReport     log_dir=${LOG_PATH}

[1]CB007113_E1_2_Verify_SBWP_GBR_UE_Call_rejection_in_Cell4_when_SBWP_PUSCH_PRB_pool_is_fully_used
    [Tags]   TC02
    [Setup]    Run keywords   BuiltIn.Set Suite Variable     ${SCFC}      ${CURDIR}/config/SCF/ABIP_SCF_7113_E.xml
    ...   AND   BuiltIn.Set Suite Variable   ${AP_XML}        ${CURDIR}/config/SCF/iphy_CB007113_E_ABIP.xml
    ...   AND   BuiltIn.Set Suite Variable   @{PhysCellID}      50    51    52    53
    ...                 AND     Update GNB R&D Parameter   ${LOG_PATH}   ${r&d_parameter}
    ...                 AND     Prepare TL with all config files
    ...                 AND    Add routes
    ...                 AND    log to console   loading cfg file....
    ...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file1}
    set test variable   ${LOG_PATH}
    Start Log    btslog
    Register 4Non GBR UEs High Traffic in each Cell and Traffic Check1   1   91   80
    Register Multiple UEs and VoNR Traffic	2    92    30
	Stop Log    btslog    test_scenario=Step1

	Start Log    btslog
    Register GBR Ues in Cell1 and Traffic Check1
    Stop Log    btslog    test_scenario=Step2
    Verify PM Counter for DRB Rejection 1st Cell    M55139C00504

    Start Log    btslog
    Register GBR Ues in Cell3 and Traffic Check1
    Stop Log    btslog    test_scenario=Step3
    Verify PM Counter for DRB Rejection 3rd Cell    M55139C00504

    Start Log    btslog
    Register GBR Ues in Cell2 and Traffic Check1
    Stop Log    btslog    test_scenario=Step4
    Verify PM Counter for DRB Rejection 2nd Cell    M55139C00504

    Start Log    btslog
    Register GBR Ues in Cell4 and Traffic Check1
    Stop Log    btslog    test_scenario=Step5
    Verify PM Counter for DRB Rejection 4th Cell1   M55139C00504
#     Run Keyword And ignore error     Validate TTITraces For Loadbase Alogorithm    ${scen1}[ttitrace]/tcpdump_ttitrace.pcap    816
    Collect TTI Log   Test_Step=prballoc   Duration=500ms
    Decode and Valiadate Prb Allocation from TTI Logs  Test_Step=prballoc
    ...   CellId=${PhysCellID}   DL_Threshold1=273    DL_Threshold2=273   UL_Threshold1=185    UL_Threshold2=273

    log to console    ${CURDIR}
    [Teardown]   Run Keywords   Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...        AND      Link SCOUT SCF to Configuration ID for Reporting
    ...                 AND     Run Keyword and Ignore Error     Stop Default Logging   output_dirpath=${LOG_PATH}
    ...                 AND      Run Keyword and Ignore Error     Collect GNB AP SnapShot    log_dir_gnb=${LOG_PATH}
    ...                    AND      Run Keyword and Ignore Error     Collect SosReport     log_dir=${LOG_PATH}

*** Keywords ***
Validate GBR HO from Cell1 to Cell4
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    MultiUE Get AVG UL DATA TRAFFIC GBR UEs   ${ue_id}   ${ue_id}   10   4
    sleep   2s
    log to console   ${ue_id}th GBR UE HO triggering now...
    Trigger A3 RsrpAndRsrq Measurement for intragnb HO   ${ue_id}   ${meas_id}   ${phycell_id}
    sleep   4s
    log to console     /n ${ue_id} GBR ue from Cell1 to Cell4 handover success
    MultiUE Get AVG UL DATA TRAFFIC GBR UEs   ${ue_id}   ${ue_id}   10   4

Register 4Non GBR UEs High Traffic in each Cell and Traffic Check
    [Arguments]   ${Start_UE}   ${MAX_UE}   ${UL_Rate}   ${Traffic_rate}=mbps
    ${UL_Val}   Set UL Validation Variables   ${UL_Rate}    ${Traffic_rate}
    Start Log   btslog
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${MAX_UE}+1   20
         log to console   ${UE} NonGBR UE attach triggering now
         UE Register should be Successful     ${UE}   gw_id=${UE}
         sleep   2s
         Trigger UL Non Bursty Data Traffic for SA   ue_id=${UE}   Traffic_rate=${Traffic_rate}   ul_rate=70
    END
    Stop Log   btslog    test_scenario=4_high_NoNGBR_Ues_each_cell
    Sleep   7s
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${MAX_UE}+1   20
         Get PUSCH UE Stats NR   ${UE}
         Run Keyword And Ignore Error  Validate UL GBR Traffic For SA   1   ${UL_Val}
    END

Register 4Non GBR UEs High Traffic in each Cell and Traffic Check1
    [Arguments]   ${Start_UE}   ${MAX_UE}   ${UL_Rate}   ${Traffic_rate}=mbps
    ${UL_Val}   Set UL Validation Variables   ${UL_Rate}    ${Traffic_rate}
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${MAX_UE}+1   30
         log to console   GBR UEs attach triggering now...${UE}
         UE Register should be Successful     ${UE}   gw_id=${UE}
         sleep   2s
         Trigger UL Non Bursty Data Traffic for SA   ue_id=${UE}   Traffic_rate=${Traffic_rate}   ul_rate=80
    END
    Sleep   7s
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${MAX_UE}+1   30
         Get PUSCH UE Stats NR   ${UE}
         Run Keyword And Ignore Error  Validate UL Traffic For SA   1   ${UL_Val}
    END

Register GBR Ues in Cell1 and Traffic Check
    Start Log  btslog
    Register Multiple UEs and ViNR Traffic   2   8  10
    sleep   7s
    #MultiUE Get AVG UL DATA TRAFFIC NonGBR UEs   1   1   65
    MultiUE Get AVG UL DATA TRAFFIC GBR UEs   2   8   10   4
    Stop Log    btslog    test_scenario=1st_cell_GBR_ues

Register GBR Ues in Cell1 and Traffic Check1
    Register Multiple UEs and ViNR Traffic1   3   16  5
    sleep   7s
    MultiUE Get AVG UL DATA TRAFFIC For NonGBR UEs   1   1   65
    MultiUE Get AVG UL DATA TRAFFIC For GBR UEs   3   16   5   4

Register GBR Ues in Cell2 and Traffic Check
    Start Log   btslog
    Register Multiple UEs and ViNR Traffic   22   27   10
    sleep   7s
    #MultiUE Get AVG UL DATA TRAFFIC NonGBR UEs   21   21   65
    MultiUE Get AVG UL DATA TRAFFIC GBR UEs   22   27  10   4
    Stop Log   btslog    test_scenario=2nd_cell_GBR_ues

Register GBR Ues in Cell2 and Traffic Check1
    Register Multiple UEs and ViNR Traffic1   33   46   5
    sleep   7s
    MultiUE Get AVG UL DATA TRAFFIC For NonGBR UEs   31   31   65
    MultiUE Get AVG UL DATA TRAFFIC For GBR UEs   33   46   5   4

Register GBR Ues in Cell3 and Traffic Check
    Start Log    btslog
    Register Multiple UEs and ViNR Traffic   42   46   10
    sleep   7s
    #MultiUE Get AVG UL DATA TRAFFIC NonGBR UEs   41   41   55
    MultiUE Get AVG UL DATA TRAFFIC GBR UEs   42   46   10   4
    Stop Log    btslog    test_scenario=3rd_cell_GBR_ues

Register GBR Ues in Cell3 and Traffic Check1
    Register Multiple UEs and ViNR Traffic1   63   76   5
    sleep   7s
    MultiUE Get AVG UL DATA TRAFFIC For NonGBR UEs   61   61   65
    MultiUE Get AVG UL DATA TRAFFIC For GBR UEs   63   76   5   4

Register GBR Ues in Cell4 and Traffic Check
    Start Log   btslog
    Register Multiple UEs and ViNR Traffic   62   63   10
    sleep   7s
    MultiUE Get AVG UL DATA TRAFFIC GBR UEs   62   63   10   4
     Stop Log    btslog    test_scenario=4th_cell_GBR_ues

Register GBR Ues in Cell4 and Traffic Check1
    Register Multiple UEs and ViNR Traffic1   93   106   5
    sleep   7s
    MultiUE Get AVG UL DATA TRAFFIC For NonGBR UEs   91   91   65
    MultiUE Get AVG UL DATA TRAFFIC For GBR UEs   93   106   5   4

Register Multiple UEs and ViNR Traffic
    [Arguments]   ${Start_UE}   ${MAX_UE}   ${UL_Rate}   ${Traffic_rate}=mbps
    ${UL_Val}   Set UL Validation Variables   ${UL_Rate}    ${Traffic_rate}
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${MAX_UE}+1
        log to console   ${UE}th GBR UE reg triggering now...
        UE Register should be Successful     ${UE}   gw_id=${UE}
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=2
        sleep   3s
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=3
        sleep   3s
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=4
        sleep   3s
        Run Keyword And Continue On Failure   Trigger VoNR DL Traffic for SA   ${UE}   qfi_id=3   rtp_codec=custom
        Run Keyword And Continue On Failure   Trigger VoNR UL Traffic for SA   ${UE}   qfi_id=3   rtp_codec=custom
        Run Keyword And Continue On Failure   Trigger UL Non Bursty Data Traffic for SA   ue_id=${UE}
        ...   Traffic_rate=${Traffic_rate}   ul_rate=10   qfi_id=4
        sleep   5s
        Run Keyword And Ignore Error  Validate UL GBR Traffic For SA   ue_id=${UE}   ul_rate=${UL_Val}   qfi_id=4
        log to console  /n Ue${UE} ViNR call Successful
    END

Validate UL GBR Traffic For SA
    [Arguments]    ${ue_id}     ${ul_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}

MultiUE Get AVG UL DATA TRAFFIC NonGBR UEs
    [Arguments]    ${st_ue_id}   ${end_ue_id}   ${UL_Rate}   ${qfi}=1   ${scell_idx}=0     ${unit}=mbps
    ${UL_Val}   Set UL Validation Variables   ${UL_Rate}    ${unit}
    BuiltIn.Log to console   ${scell_idx}
    FOR  ${UE}   IN RANGE   ${st_ue_id}   ${end_ue_id}+1
       Get PUSCH UE Stats NR   ${UE}
       Run Keyword and Ignore Error  Validate UL GBR Traffic For SA   ${UE}   ul_rate=${UL_Val}    qfi_id=${qfi}
    END

MultiUE Get AVG UL DATA TRAFFIC GBR UEs
    [Arguments]    ${st_ue_id}   ${end_ue_id}   ${UL_Rate}   ${qfi}=1   ${scell_idx}=0     ${unit}=mbps
    BuiltIn.Log to console    ${scell_idx}
    ${UL_Val}   Set UL Validation Variables   ${UL_Rate}    ${unit}
    set test variable    ${count}    ${0}
    FOR  ${UE}   IN RANGE   ${st_ue_id}   ${end_ue_id}+1
       Get PUSCH UE Stats NR   ${UE}
       Run Keyword And Continue On Failure   Validate UL GBR Traffic For SA   ${UE}   ul_rate=${UL_Val}    qfi_id=${qfi}
    END

Set UL Validation Variables
    [Arguments]    ${UL_Rate}    ${Traffic_rate}=mbps
    ${UL}   Evaluate    ${UL_Rate} / 1000
    ${UL_Rate}    Set Variable if   "${Traffic_rate}"=="kbps"     ${UL}
    ...     "${Traffic_rate}"=="mbps"     ${UL_Rate}
    [Return]    ${UL_Rate}

Get PUSCH UE Stats NR
    [documentation]   WA to CleanUp egate Console...
    [Arguments]    ${ue_id}=1    ${scell_idx}=0
    wtsrunner.ue_stats_nr   id=${ue_id}    type=pusch    scell=${scell_idx}
    ${output}    wtsrunner.Read Wtsemu Output Until    expected=NR PUSCH Throughput   timeout=10
    [Return]      ${output}

Verify PM Counter for DRB Rejection 4th Cell
    [Arguments]     ${PM_counter}
    Wait until the next Measurement Period starts
    Run Keyword and Ignore Error     Register Multiple UEs with ViNR Reject   64   69   10
    Wait until the current Measurement Period stops
    ${PM_dir_D2_6}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    PM_Counters.Check PM counter value equal or bigger than   expected_value=1   pm_files_location=${PM_dir_D2_6}
    ...  pi_id=${PM_counter}    moc=NRCELL-4

Verify PM Counter for DRB Rejection 4th Cell1
    [Arguments]     ${PM_counter}
    Run Keyword and Ignore Error   Register Multiple UEs with ViNR Reject1   107   108   5
    sleep   2s
    Wait until the next Measurement Period starts
    ${PM_dir_D2_6}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    PM_Counters.Check PM counter value equal or bigger than   expected_value=1   pm_files_location=${PM_dir_D2_6}
    ...  pi_id=${PM_counter}    moc=NRCELL-4

Get PMCounters before HO
        ${PM_dir1} =     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
        ${Cell1b4HO_PRB_USED_PUSCH}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C10002   moc=NRCELL-1
        ${Cell4b4HO_PRB_USED_PUSCH}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C10002   moc=NRCELL-4
        Set Suite Variable     ${Cell1b4HO_PRB_USED_PUSCH}
        Set Suite Variable     ${Cell4b4HO_PRB_USED_PUSCH}

Get PMCounters after HO and compare with old values
        Wait until the next Measurement Period starts
        Wait until the next Measurement Period starts
        ${PM_dir1} =     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
        ${Cell1afterHO_PRB_USED_PUSCH}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C10002    moc=NRCELL-1
        ${Cell4afterHO_PRB_USED_PUSCH}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C10002    moc=NRCELL-4
        Set Suite Variable     ${Cell1afterHO_PRB_USED_PUSCH}
        Set Suite Variable     ${Cell4afterHO_PRB_USED_PUSCH}
        log to console    Cell1-b4HO_PRB_USED_PUSCH=${Cell1b4HO_PRB_USED_PUSCH}
        log to console    Cell1-afterHO_PRB_USED_PUSCH=${Cell1afterHO_PRB_USED_PUSCH}
        log to console    Cell4-b4HO_PRB_USED_PUSCH=${Cell4b4HO_PRB_USED_PUSCH}
        log to console    Cell4afterHO_PRB_USED_PUSCH=${Cell4afterHO_PRB_USED_PUSCH}
        Should Be True    ${Cell1b4HO_PRB_USED_PUSCH} > ${Cell1afterHO_PRB_USED_PUSCH}
#        Should Be True    ${Cell4b4HO_PRB_USED_PUSCH} < ${Cell4afterHO_PRB_USED_PUSCH}

Verify PM Counter for PRBs Available for PUSCH after HO
    [Arguments]     ${PM_counter}
    ${PM_dir_D2_6}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    PM_Counters.Check PM counter value equal   expected_value=29160000  pm_files_location=${PM_dir_D2_6}
    ...  pi_id=${PM_counter}    moc=NRCELL-1
	PM_Counters.Check PM counter value equal   expected_value=29160000  pm_files_location=${PM_dir_D2_6}
    ...  pi_id=${PM_counter}    moc=NRCELL-2
	PM_Counters.Check PM counter value equal   expected_value=29160000  pm_files_location=${PM_dir_D2_6}
    ...  pi_id=${PM_counter}    moc=NRCELL-3
	PM_Counters.Check PM counter value equal   expected_value=29160000   pm_files_location=${PM_dir_D2_6}
    ...  pi_id=${PM_counter}    moc=NRCELL-4

Register Multiple UEs with ViNR Reject
    [Arguments]   ${Start_UE}   ${MAX_UE}   ${UL_Rate}   ${Traffic_rate}=mbps
    ${UL_Val}   Set UL Validation Variables   ${UL_Rate}    ${Traffic_rate}
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${MAX_UE}+1
        log to console   ${UE}th GBR UE reg triggering now...
        UE Register should be Successful     ${UE}   gw_id=${UE}
        Run Keyword and Ignore Error    UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=2
        sleep   3s
        Run Keyword and Ignore Error    UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=3
        sleep   3s
        Run Keyword and Ignore Error    UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=4
        sleep   3s
        Run Keyword and Ignore Error    Trigger VoNR DL Traffic for SA   ${UE}   qfi_id=3   rtp_codec=custom
        Run Keyword and Ignore Error    Trigger VoNR UL Traffic for SA   ${UE}   qfi_id=3   rtp_codec=custom
        Run Keyword and Ignore Error    Trigger UL Non Bursty Data Traffic for SA   ue_id=${UE}
        ...   Traffic_rate=${Traffic_rate}   ul_rate=10   qfi_id=4
        sleep   5s
        Run Keyword and Ignore Error    Validate UL Traffic For SA   ue_id=${UE}   ul_rate=${UL_Val}   qfi_id=4
        log to console  /n Ue${UE} ViNR call Successful
    END

Collect and decode TTI Log
    [Arguments]    ${Test_Step}  ${Duration}
    Start Log      ttitrace
    Sleep     ${Duration}
    ${tti_path}    Stop Log       ttitrace   test_scenario=${Test_Step}
    Decode TTI Trace DLUL   ${Test_Step}

Valiadate Prb Allocation from TTI Logs before HO
    [Arguments]    ${Test_Step}
    Validate cell prballocation from TTI traces multicell    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${Test_Step}    CellId=50
    ...    UL_Threshold1=200   UL_Threshold2=273
    Validate cell prballocation from TTI traces multicell    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${Test_Step}    CellId=51
    ...    UL_Threshold1=200    UL_Threshold2=273
    Validate cell prballocation from TTI traces multicell    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${Test_Step}    CellId=52
    ...    UL_Threshold1=200    UL_Threshold2=273
    Validate cell prballocation from TTI traces multicell    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${Test_Step}    CellId=53
    ...    UL_Threshold1=180    UL_Threshold2=273

Valiadate Prb Allocation from TTI Logs after HO
    [Arguments]    ${Test_Step}
    Validate cell prballocation from TTI traces multicell    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${Test_Step}    CellId=50
    ...    UL_Threshold1=180    UL_Threshold2=273
    Validate cell prballocation from TTI traces multicell    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${Test_Step}    CellId=51
    ...    UL_Threshold1=200    UL_Threshold2=273
    Validate cell prballocation from TTI traces multicell    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${Test_Step}    CellId=52
    ...    UL_Threshold1=200    UL_Threshold2=273
    Validate cell prballocation from TTI traces multicell    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${Test_Step}    CellId=53
    ...    UL_Threshold1=200    UL_Threshold2=273

Validate cell prballocation from TTI traces multicell
    [Arguments]   ${csv_file_path}  ${CellId}  ${UL_Threshold1}    ${UL_Threshold2}
    log to console   python123 ...
    ${UL_Check}   Verify cell ulprballocation multicell   ${csv_file_path}/output_ul_formated.csv    ${CellId}
    ...      ${UL_Threshold1}    ${UL_Threshold2}
    log to console   Debug123 ...
    run keyword and continue on failure   Run Keyword if   ${UL_Check}!=${True}   Fail   ul prb allocation failure

Verify cell ulprballocation multicell
    [Arguments]   ${csv_file_path}  ${cellid}    ${Threshold1}    ${Threshold2}
    log to console   python123_CALLING_PYTHON ...
    ${Result}   check_dl_ul_prballocation.check_ulallocatedprb   ${csv_file_path}    ${cellId}    ${Threshold1}
    ...         ${Threshold2}    weightage=70
    [Return]   ${Result}

Verify cell dlprballocation multicell
    [Arguments]   ${csv_file_path}  ${cellid}    ${Threshold1}    ${Threshold2}
    log to console   python123_CALLING_PYTHON ...
    ${Result}   check_dl_ul_prballocation.check_dlallocatedprb   ${csv_file_path}    ${cellId}    ${Threshold1}
    ...           ${Threshold2}
    [Return]   ${Result}

Decode TTI Trace DLUL
    [Arguments]    ${ttitrace_path}=${EMPTY}
    Dated Log                        converting ttitrace pcap to csv
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}/
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}
    Common Format Tti In Stream Mode         ${tti_path}/output_dl.csv     ${tti_path}/output_dl_formated.csv
    Common Format Tti In Stream Mode         ${tti_path}/output_ul.csv     ${tti_path}/output_ul_formated.csv

Update GNB R&D Parameter
   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt

Add routes
    [Documentation]    This keyword is to configure VM interfaces..
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.99/24 dev eth3
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.3/24 dev eth3
    Run    sudo ip addr add 10.0.1.4/24 dev eth3
    Run    sudo ip addr add 10.0.1.61/24 dev eth3
    Run    sudo ip addr add 10.0.1.62/24 dev eth3
    Run    sudo ip addr add 10.0.1.138/24 dev eth3
    Run    sudo ip addr add 10.0.1.139/24 dev eth3
    Run    sudo ip addr add 10.0.1.140/24 dev eth3
    Run    sudo ip addr add 10.0.1.141/24 dev eth3

Register Multiple UEs and ViNR Traffic1
    [Arguments]   ${Start_UE}   ${MAX_UE}   ${UL_Rate}   ${Traffic_rate}=mbps
    ${UL_Val}   Set UL Validation Variables   ${UL_Rate}    ${Traffic_rate}
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${MAX_UE}+1
        log to console   GBR UEs attach triggering now...${UE}
        UE Register should be Successful     ${UE}   gw_id=${UE}
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=2
        sleep   3s
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=4
        sleep   3s
        Run Keyword And Continue On Failure   Trigger UL Non Bursty Data Traffic for SA   ue_id=${UE}
        ...   Traffic_rate=${Traffic_rate}   ul_rate=5   qfi_id=3
        sleep   5s
        Run Keyword And Ignore Error    Validate UL GBR Traffic For SA    ue_id=${UE}   ul_rate=${UL_Val}
        ...   qfi_id=3
        log to console  Ue${UE} ViNR call Successful
    END

Register Multiple UEs and VoNR Traffic
    [Arguments]   ${Start_UE}   ${MAX_UE}   ${UL_Rate}   ${Traffic_rate}=mbps
    ${UL_Val}   Set UL Validation Variables   ${UL_Rate}    ${Traffic_rate}
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${MAX_UE}+1   30
        log to console   GBR UEs attach triggering now...${UE}
        UE Register should be Successful     ${UE}   gw_id=${UE}
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=2
        sleep   3s
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=3
        sleep   3s
        Run Keyword And Continue On Failure   Trigger VoNR DL Traffic for SA   ${UE}   qfi_id=3   rtp_codec=custom
        Run Keyword And Continue On Failure   Trigger VoNR UL Traffic for SA   ${UE}   qfi_id=3   rtp_codec=custom
    END
    sleep   5s
	FOR  ${UE}   IN RANGE   ${Start_UE}   ${MAX_UE}+1   30
			Get PUSCH UE Stats NR   ${UE}
			Run Keyword And Ignore Error   Validate UL Traffic For SA   ue_id=${UE}   ul_rate=${UL_Val}
			...   qfi_id=3
			log to console  Ue${UE} VoNR call Successful
	 END

Verify PM Counter for DRB Rejection 1st Cell
    [Arguments]     ${PM_counter}
    Run Keyword and Ignore Error   Register Multiple UEs with ViNR Reject1  17   18   5
    sleep   2s
    Wait until the next Measurement Period starts
    ${PM_dir_D2_3}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    PM_Counters.Check PM counter value equal or bigger than   expected_value=1   pm_files_location=${PM_dir_D2_3}
    ...  pi_id=${PM_counter}    moc=NRCELL-1

Verify PM Counter for DRB Rejection 2nd Cell
    [Arguments]     ${PM_counter}
    Run Keyword and Ignore Error   Register Multiple UEs with ViNR Reject1   47   48   5
    sleep   2s
    Wait until the next Measurement Period starts
    ${PM_dir_D2_4}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    PM_Counters.Check PM counter value equal or bigger than   expected_value=1   pm_files_location=${PM_dir_D2_4}
    ...  pi_id=${PM_counter}    moc=NRCELL-2

Verify PM Counter for DRB Rejection 3rd Cell
    [Arguments]     ${PM_counter}
    Run Keyword and Ignore Error   Register Multiple UEs with ViNR Reject1   77   78   5
    sleep   2s
    Wait until the next Measurement Period starts
    ${PM_dir_D2_5}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    PM_Counters.Check PM counter value equal or bigger than   expected_value=1   pm_files_location=${PM_dir_D2_5}
    ...  pi_id=${PM_counter}    moc=NRCELL-3

Register Multiple UEs with ViNR Reject1
    [Arguments]   ${Start_UE}   ${MAX_UE}   ${UL_Rate}   ${Traffic_rate}=mbps
    ${UL_Val}   Set UL Validation Variables   ${UL_Rate}    ${Traffic_rate}
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${MAX_UE}+1
        log to console   ${UE}th GBR UE reg triggering now...
        UE Register should be Successful     ${UE}   gw_id=${UE}
        Run Keyword And Ignore Error   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=2
        sleep   3s
        Run Keyword And Ignore Error   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=4
        sleep   3s
        Run Keyword And Ignore Error   Trigger UL Non Bursty Data Traffic for SA   ue_id=${UE}
        ...   Traffic_rate=${Traffic_rate}   ul_rate=5   qfi_id=3
        sleep   5s
        Run Keyword And Ignore Error   Validate UL Traffic For SA   ue_id=${UE}   ul_rate=${UL_Val}   qfi_id=3
        log to console  /n Ue${UE} ViNR call Not Successful
    END

Decode and Valiadate Prb Allocation from TTI Logs
    [Arguments]    ${Test_Step}   ${CellId}   ${DL_Threshold1}    ${DL_Threshold2}   ${UL_Threshold1}    ${UL_Threshold2}
    Decode TTI Trace DLUL   ${Test_Step}
    FOR  ${Cell}  IN  @{CellId}
         Validate cell prballocation from TTI traces multicell1    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${Test_Step}    ${Cell}
         ...    ${DL_Threshold1}    ${DL_Threshold2}   ${UL_Threshold1}    ${UL_Threshold2}
    END
    Sleep    40s

Validate cell prballocation from TTI traces multicell1
    [Arguments]   ${csv_file_path}  ${CellId}    ${DL_Threshold1}    ${DL_Threshold2}   ${UL_Threshold1}    ${UL_Threshold2}
    log to console   python123 ...
    ${DL_Check}   Verify cell dlprballocation multicell   ${csv_file_path}/output_dl_formated.csv    ${CellId}
    ...      ${DL_Threshold1}    ${DL_Threshold2}
    ${UL_Check}   Verify cell ulprballocation multicell   ${csv_file_path}/output_ul_formated.csv    ${CellId}
    ...      ${UL_Threshold1}    ${UL_Threshold2}
    log to console   Debug123 ...
    run keyword and continue on failure   Run Keyword if   ${DL_Check}!=${True}   Fail   prb allocation failure
    run keyword and continue on failure   Run Keyword if   ${UL_Check}!=${True}   Fail   prb allocation failure

Collect TTI Log
    [Arguments]    ${Test_Step}  ${Duration}
    Start Log      ttitrace
    Sleep     ${Duration}
    ${tti_path}    Stop Log       ttitrace   test_scenario=${Test_Step}

MultiUE Get AVG UL DATA TRAFFIC For GBR UEs
    [Arguments]    ${st_ue_id}   ${end_ue_id}   ${UL_Rate}   ${qfi}=1   ${scell_idx}=0     ${unit}=mbps
    Log to console    ${scell_idx}
    ${UL_Val}   Set UL Validation Variables   ${UL_Rate}    ${unit}
    FOR  ${UE}   IN RANGE   ${st_ue_id}   ${end_ue_id}+1
       Get PUSCH UE Stats NR   ${UE}
       Run Keyword And Ignore Error  Validate UL GBR Traffic For SA   ${UE}   ul_rate=${UL_Val}    qfi_id=${qfi}
    END

MultiUE Get AVG UL DATA TRAFFIC For NonGBR UEs
    [Arguments]    ${st_ue_id}   ${end_ue_id}   ${UL_Rate}   ${qfi}=1   ${scell_idx}=0     ${unit}=mbps
    Log to console    ${scell_idx}
    ${UL_Val}   Set UL Validation Variables   ${UL_Rate}    ${unit}
    FOR  ${UE}   IN RANGE   ${st_ue_id}   ${end_ue_id}+1
       Get PUSCH UE Stats NR   ${UE}
       Run Keyword And Ignore Error  Validate UL Traffic For SA   ${UE}   ul_rate=${UL_Val}    qfi_id=${qfi}
    END
