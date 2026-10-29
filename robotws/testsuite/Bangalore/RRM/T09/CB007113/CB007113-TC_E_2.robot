*** Settings ***
Force Tags
...             CONFIGS_Bangalore/RRM/ET/CB007113/CB007113_E1_2_SBWP.yml
...             CRT   5G_RAN_FDD   SBTS00    RAN_5G   5G_RAN    CONFIGURED

Documentation    :copyright: Nokia
...              :authors:Madhu/Chaithanya/prapulla
...              :contact:madhusudhan.y@nokia.com/chaithanya.h_s@nokia.com/prapulla.bt@nokia.com
...   This feature introduces the functionality of TDD FR1 PRB pooling in UL to improve the cell amounts in BB cell set configuration:
...   1. The resources of processing PRB in L1 UL shall be pooled instead of dedicated allocation to achieve the cell amount
...    requirement in BB cell set feature. As figure 1 below, the pooling range includes:
...    a. Intra L1 subpool PRB pooing.
...   The NRCells in one L1 subpool share the pooled resources in its own L1 subpool. The PRB capability of each L1 subpool
...    is not changable in runtime.
...    b. Inter L1 subpool PRB pooling


Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../../resources/robot/Setup_Env.robot
Resource         ../../../resources/robot/Airphone.robot
Resource         ../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../resources/robot/PM_Counters.robot
Resource	     ../../../resources/robot/common_log_collection.robot
Resource         resources/load_based_validation_keywords.resource
Resource         resources/CB007113_Keyword.robot


Suite Setup         Run keywords     log to console     Suite Setup
...                 AND     Update GNB R&D Parameter   ${LOG_PATH}   ${r&d_parameter}
...                 AND     Prepare TL with all config files
...                 AND    Add routes
...                 AND    log to console   loading cfg file....
...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}


Suite Teardown      Run Keywords   Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error     Stop Default Logging   output_dirpath=${LOG_PATH}
...                 AND      Run Keyword and Ignore Error     Collect GNB AP SnapShot    log_dir_gnb=${LOG_PATH}
...                 AND      Run Keyword and Ignore Error     Collect SosReport     log_dir=${LOG_PATH}

Test Teardown    Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}        ${CURDIR}/configs/basic_setup_E_SBWP_4Cells_eachCell_30UEs.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}               1
${nwslice_ID}          1
${gw_ID}               1
${Pdu_session_ID}      1
${qfi_id}              1
${RTP_COD}             1
${epc_log_path}        /tmp/
${Q_O_ADD}             1
${TRF_ID}              1
${GFBR}                9
${r&d_parameter}     0x420068=7;0x58069C=1;0x580612=1;0x580686=0xa;0x58057c = 0x2800;0x58057a = 0x4
${PM_PCELL_COUNTER1}    M55139C00504
${PM_PCELL_COUNTER2}    M55167C00004
${PM_PCELL_COUNTER3}    M55167C00002
${SCFC}=               ${CURDIR}/configs/ABIP_SCF_7113_E.xml
${AP_XML}=             ${CURDIR}/configs/iphy_CB007113_E_ABIP.xml
@{PhysCellID}      50    51    52    53


*** Test Cases ***
[1]CB007113_E1_2_Verify_SBWP_GBR_UE_Call_rejection_in_Cell4_when_SBWP_PUSCH_PRB_pool_is_fully_used
    set test variable   ${LOG_PATH}
    Start Log    btslog
    Register 4Non GBR UEs High Traffic in each Cell and Traffic Check   1   91   80
    Register Multiple UEs and VoNR Traffic	2    92    30
	Stop Log    btslog    test_scenario=Step1

	Start Log    btslog
    Register GBR Ues in Cell1 and Traffic Check
    Stop Log    btslog    test_scenario=Step2
    Verify PM Counter for DRB Rejection 1st Cell    M55139C00504

    Start Log    btslog
    Register GBR Ues in Cell3 and Traffic Check
    Stop Log    btslog    test_scenario=Step3
    Verify PM Counter for DRB Rejection 3rd Cell    M55139C00504

    Start Log    btslog
    Register GBR Ues in Cell2 and Traffic Check
    Stop Log    btslog    test_scenario=Step4
    Verify PM Counter for DRB Rejection 2nd Cell    M55139C00504

    Start Log    btslog
    Register GBR Ues in Cell4 and Traffic Check
    Stop Log    btslog    test_scenario=Step5
    Verify PM Counter for DRB Rejection 4th Cell   M55139C00504
#     Run Keyword And ignore error     Validate TTITraces For Loadbase Alogorithm    ${scen1}[ttitrace]/tcpdump_ttitrace.pcap    816

    Collect TTI Log   Test_Step=prballoc   Duration=500ms
    Decode and Valiadate Prb Allocation from TTI Logs  Test_Step=prballoc
    ...   CellId=${PhysCellID}   DL_Threshold1=273    DL_Threshold2=273   UL_Threshold1=185    UL_Threshold2=273

    log to console    ${CURDIR}
*** Keywords ***
Register GBR Ues in Cell1 and Traffic Check
    Register Multiple UEs and ViNR Traffic   3   16  5
    sleep   7s
    MultiUE Get AVG UL DATA TRAFFIC For NonGBR UEs   1   1   65
    MultiUE Get AVG UL DATA TRAFFIC For GBR UEs   3   16   5   4

Register GBR Ues in Cell2 and Traffic Check
    Register Multiple UEs and ViNR Traffic   33   46   5
    sleep   7s
    MultiUE Get AVG UL DATA TRAFFIC For NonGBR UEs   31   31   65
    MultiUE Get AVG UL DATA TRAFFIC For GBR UEs   33   46   5   4

Register GBR Ues in Cell3 and Traffic Check
    Register Multiple UEs and ViNR Traffic   63   76   5
    sleep   7s
    MultiUE Get AVG UL DATA TRAFFIC For NonGBR UEs   61   61   65
    MultiUE Get AVG UL DATA TRAFFIC For GBR UEs   63   76   5   4

Register GBR Ues in Cell4 and Traffic Check
    Register Multiple UEs and ViNR Traffic   93   106   5
    sleep   7s
    MultiUE Get AVG UL DATA TRAFFIC For NonGBR UEs   91   91   65
    MultiUE Get AVG UL DATA TRAFFIC For GBR UEs   93   106   5   4

Register 4Non GBR UEs High Traffic in each Cell and Traffic Check
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

Register Multiple UEs and ViNR Traffic
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
    Run Keyword and Ignore Error   Register Multiple UEs with ViNR Reject   17   18   5
    sleep   2s
    Wait until the next Measurement Period starts
    ${PM_dir_D2_3}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    PM_Counters.Check PM counter value equal or bigger than   expected_value=1   pm_files_location=${PM_dir_D2_3}
    ...  pi_id=${PM_counter}    moc=NRCELL-1

Verify PM Counter for DRB Rejection 2nd Cell
    [Arguments]     ${PM_counter}
    Run Keyword and Ignore Error   Register Multiple UEs with ViNR Reject   47   48   5
    sleep   2s
    Wait until the next Measurement Period starts
    ${PM_dir_D2_4}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    PM_Counters.Check PM counter value equal or bigger than   expected_value=1   pm_files_location=${PM_dir_D2_4}
    ...  pi_id=${PM_counter}    moc=NRCELL-2

Verify PM Counter for DRB Rejection 3rd Cell
    [Arguments]     ${PM_counter}
    Run Keyword and Ignore Error   Register Multiple UEs with ViNR Reject   77   78   5
    sleep   2s
    Wait until the next Measurement Period starts
    ${PM_dir_D2_5}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    PM_Counters.Check PM counter value equal or bigger than   expected_value=1   pm_files_location=${PM_dir_D2_5}
    ...  pi_id=${PM_counter}    moc=NRCELL-3

Verify PM Counter for DRB Rejection 4th Cell
    [Arguments]     ${PM_counter}
    Run Keyword and Ignore Error   Register Multiple UEs with ViNR Reject   107   108   5
    sleep   2s
    Wait until the next Measurement Period starts
    ${PM_dir_D2_6}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    PM_Counters.Check PM counter value equal or bigger than   expected_value=1   pm_files_location=${PM_dir_D2_6}
    ...  pi_id=${PM_counter}    moc=NRCELL-4

Register Multiple UEs with ViNR Reject
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

Validate UL GBR Traffic For SA
    [Arguments]    ${ue_id}     ${ul_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}

MultiUE Get AVG UL DATA TRAFFIC For NonGBR UEs
    [Arguments]    ${st_ue_id}   ${end_ue_id}   ${UL_Rate}   ${qfi}=1   ${scell_idx}=0     ${unit}=mbps
    ${UL_Val}   Set UL Validation Variables   ${UL_Rate}    ${unit}
    FOR  ${UE}   IN RANGE   ${st_ue_id}   ${end_ue_id}+1
       Get PUSCH UE Stats NR   ${UE}
       Run Keyword And Ignore Error  Validate UL Traffic For SA   ${UE}   ul_rate=${UL_Val}    qfi_id=${qfi}
    END
    log to console  ${scell_idx}

MultiUE Get AVG UL DATA TRAFFIC For GBR UEs
    [Arguments]    ${st_ue_id}   ${end_ue_id}   ${UL_Rate}   ${qfi}=1   ${scell_idx}=0     ${unit}=mbps
    ${UL_Val}   Set UL Validation Variables   ${UL_Rate}    ${unit}
    FOR  ${UE}   IN RANGE   ${st_ue_id}   ${end_ue_id}+1
       Get PUSCH UE Stats NR   ${UE}
       Run Keyword And Ignore Error  Validate UL GBR Traffic For SA   ${UE}   ul_rate=${UL_Val}    qfi_id=${qfi}
    END
    log to console  ${scell_idx}

Get PUSCH UE Stats NR
    [documentation]   WA to CleanUp egate Console...
    [Arguments]    ${ue_id}=1    ${scell_idx}=0
    # Log to Console    PUSCH UE stats for given CC
    wtsrunner.ue_stats_nr   id=${ue_id}    type=pusch    scell=${scell_idx}
    ${output}    wtsrunner.Read Wtsemu Output Until    expected=NR PUSCH Throughput   timeout=10
    [Return]      ${output}

Collect TTI Log
    [Arguments]    ${Test_Step}  ${Duration}
    Start Log      ttitrace
    Sleep     ${Duration}
    ${tti_path}    Stop Log       ttitrace   test_scenario=${Test_Step}

Decode and Valiadate Prb Allocation from TTI Logs
    [Arguments]    ${Test_Step}   ${CellId}   ${DL_Threshold1}    ${DL_Threshold2}   ${UL_Threshold1}    ${UL_Threshold2}
    Decode TTI Trace DLUL   ${Test_Step}
    FOR  ${Cell}  IN  @{CellId}
         Validate cell prballocation from TTI traces multicell    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${Test_Step}    ${Cell}
         ...    ${DL_Threshold1}    ${DL_Threshold2}   ${UL_Threshold1}    ${UL_Threshold2}
    END
    Sleep    40s

Validate cell prballocation from TTI traces multicell
    [Arguments]   ${csv_file_path}  ${CellId}    ${DL_Threshold1}    ${DL_Threshold2}   ${UL_Threshold1}    ${UL_Threshold2}
    log to console   python123 ...
    ${DL_Check}   Verify cell dlprballocation multicell   ${csv_file_path}/output_dl_formated.csv    ${CellId}
    ...      ${DL_Threshold1}    ${DL_Threshold2}
    ${UL_Check}   Verify cell ulprballocation multicell   ${csv_file_path}/output_ul_formated.csv    ${CellId}
    ...      ${UL_Threshold1}    ${UL_Threshold2}
    log to console   Debug123 ...
    run keyword and continue on failure   Run Keyword if   ${DL_Check}!=${True}   Fail   prb allocation failure
    run keyword and continue on failure   Run Keyword if   ${UL_Check}!=${True}   Fail   prb allocation failure

Verify cell ulprballocation multicell
    [Arguments]   ${csv_file_path}  ${cellid}    ${Threshold1}    ${Threshold2}
    log to console   python123_CALLING_PYTHON ...
    ${Result}   check_dl_ul_prballocation.check_ulallocatedprb   ${csv_file_path}    ${cellId}    ${Threshold1}
    ...                        ${Threshold2}
    [Return]   ${Result}
Verify cell dlprballocation multicell
    [Arguments]   ${csv_file_path}  ${cellid}    ${Threshold1}    ${Threshold2}
    log to console   python123_CALLING_PYTHON ...
    ${Result}   check_dl_ul_prballocation.check_dlallocatedprb   ${csv_file_path}    ${cellId}    ${Threshold1}
    ...                        ${Threshold2}
    [Return]   ${Result}

Verify cell ulprballocation multicell_G
    [Arguments]   ${csv_file_path}      ${cellid}    ${Threshold1}    ${Threshold2}
    log to console   python123_CALLING_PYTHON ...
    ${Result}   check_prb_multicell.check_ulallocatedprb      ${csv_file_path}    ${cellId}      ${Threshold1}
    ...                        ${Threshold2}
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
