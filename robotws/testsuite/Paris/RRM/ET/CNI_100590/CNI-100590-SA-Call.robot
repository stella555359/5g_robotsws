*** Settings ***

Documentation     [SUITE PURPOSE]  tests for DSS feature CNI-100590 SA Call
...               Test Case Scenario author   : christophe.samson@nokia.com
...               Test Case Scenario contact  : christophe.samson@nokia.com
...               Test Case automation author :
...               Test Case automation contact:
...               Creation Date               : September 11 2024
...               Modified Date               : September 11 2024
#-------------------------------------------------------------------------------------------------------[150 characters]

Library           taf.sbts.oam.coam.admin            WITH NAME               coam
Library           ute_wtssim                         WITH NAME               wts
Library           ute_tshark
Library           ta5g_tshark
Library           ../resources/python/luashark_tools.py
Library           ../../../resources/SWENG/python/StringTool.py
Library           resources/python/Constants.py                     WITH NAME               MyConstants
Library           ../resources/DSS/python/dss_tools.py              WITH NAME               nps_dss_tools
Library           resources/python/tools.py                         WITH NAME               nps_2574_tools
Library           ../resources/common/TtiTrace/python/ttitrace.py   WITH NAME               nps_ttitraces_tools
Library           ../resources/DSS/python/Common.py                 WITH NAME               nps_dss_Common
Library           ../resources/DSS/python/pcap_analyzer_framework/set_pandas.py     WITH NAME      set_pandas
Library           ../resources/DSS/python/pcap_analyzer_framework/pcap_dataframe.py  WITH NAME     pcap_dataframe
Library           ../resources/DSS/python/DSS-lib.py

# SWENG resources
Resource          ../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../resources/SWENG/robot/SetConfig.robot

# TTI Traces resource
Resource          ../resources/common/TtiTrace/ttitrace.robot

# DSS common
Resource          ../resources/DSS/robot/btslog.robot
Resource          ../resources/DSS/robot/common_Dss_Keywords.robot
Resource          ../resources/DSS/robot/common_Dss_command.robot
Resource          ../resources/DSS/robot/common_Dss_SA_NSA.robot
Resource          ../resources/DSS/robot/aashell.robot

# 2574 specific
Resource            resources/robot/5GC002574_Kw_TestSetup.robot
Resource            resources/robot/5GC002574_keywords.robot

Variables           resources/python/Constants.py

# Tags for QC mapping
Force Tags                          CA_5G_SW_FR-Villarceaux   RRM
...                                 PY36
...                                 master_classicalbts_all
...                                 CONFIGURED    5G_RAN    RAN_5G

Suite Setup         Run keywords
...                                MyConstants.hello                                 AND
...                                Get Host Name                                     AND
...                                5GC002574_keywords.CleanUp basic*step2*.* file    AND
...                                Test Suite Setup for 2574                         AND
...                                5GC002574_keywords.Get gNB cell 5g On air
Suite Teardown      Test suite teardown for 2574


*** Variables ***

${PATTERN_DL_70_SA_OK}       0001100010-0111101110-0011100010-0111101110-0011100010-0111101110-0011100010-0111101110
${PATTERN_DL_100_SA_OK}      1011110011-1111111111-1011110011-1111111111-1011110011-1111111111-1011110011-1111111111

${PDCCHProfile_20MHz_actSlowPrbPoolingFddFr1Enh_delta_file_cell1}
...  ${CURDIR}/../resources/DSS/config/Delta_Configuration_scf_MRBTS-1_DssPh3_20MHz_w_actSlowPrbPooling_actSlowPrbPoolingFddFr1Enh.json

${DEFAULT_S1_MME_SCTP}=     sctp
${DEFAULT_UU_LESS_1000}=     less 1000

*** Test Cases ***

TestLine_preparation
   [Tags]    FULL_RUN    Cellsetup     10MHZ   CNI100590
   ...       CRT
   5GC002574_Kw_TestSetup.Test Line Preparation    ${TestDSS10Mhz_2574_A1}


TestLine_2574_Test_setup_20Mhz
   [Tags]    FULL_RUN    Cellsetup   FULL_CALL  20MHZ   CNI100590
   ...       CRT
   [Setup]   Run Keywords    set Suite Variable    ${testCaseDir}    None      AND
   ...                       common_Dss_Keywords.Get testcase log directory
   5GC002574_Kw_TestSetup.Test Setup 2574    ${TestDSS20Mhz_2574_A5}


# PRV_TC5_20MHz_DL150_20_UL30_20_CNI100590_TC_03_5gCall_with_Traffic_SA_Mode
# PRV_TC6_20MHz_DL130_20_UL30_20_GBR_NGBR_CNI100590_5gCall_with_Traffic_SA_Mode
# PRV_TC9_20MHz_DL0_1_UL0_10_GBR_2_TPUT_TGT_NGBR_CNI100590_5gCall_with_Traffic_SA_Mode
# PRV_TC10_20MHz_DL130_20_UL30_20_FAST_ALLOC_OFF_CNI100590_TC_03_5gCall_with_Traffic_SA_Mode
CNI_100590_02_Check_xLQosloadInd_period_with_load_variability_setting_2
    [Tags]    FULL_RUN     20MHZ    CNI100590    GBR    NGBR    CRT
    [Documentation]     Cellsetup Dss phase 3, BW= 20MHz, DL RATIO = 100%, Fast DL Allocation, SA 5g Call , DL/UL Tput
    [Setup]   Run Keywords    set Suite Variable    ${testCaseDir}    None                                      AND
    ...       common_Dss_Keywords.Get testcase log directory                                                    AND
    ...       common_Dss_Keywords.Start Tcpdump on TestPc    interface=eth3    option=-U -s0 sctp or icmp       AND
    ...       common_Dss_Keywords.Start Tcpdump on TestPc    interface=eth4    option=-f less 1000 -s 65535     AND
    ...       Set global variable    ${CELLSETUP_SHOULD_BE_CHECK}   0                                           AND
    ...       robot_extension.Run Keyword And Warn On Failure    btslog.Start Btslog     AND
    ...       Create Header Csv Test result                                              AND
    ...       depends   TestLine_2574_Test_setup_20Mhz
    [Timeout]    3 hours

    ${resultFile}    Set Variable     ${testCaseDir}/resultFile_${TEST NAME[0:30]}.log
    Set Test Variable    ${resultFile}
    ${resultFileCRM}    Set Variable     ${testCaseDir}/resultFileCRM_${TEST NAME[0:30]}.log
    Set Test Variable    ${resultFileCRM}

    ${status_of_execution}    Create List
    ${execution_failed}       Create List
    set test variable     ${status_of_execution}
    set test variable     ${execution_failed}

    # prepare TL here Once
    ${tc_name}    Set variable    TestLine_preparation
    ${tc_status}    getTcStatusByName    name=${tc_name}
    Run keyword if    '${tc_status}'!='PASS'
    ...                          5GC002574_Kw_TestSetup.Test Line Preparation    ${TestDSS20Mhz_2574_A5}
    ${tc_name}    Set variable    TestLine_2574_Test_setup_20Mhz
    ${tc_status}    getTcStatusByName    name=${tc_name}
    Run keyword if    '${tc_status}'!='PASS'
    ...           5GC002574_Kw_TestSetup.Test Setup 2574    ${TestDSS20Mhz_2574_A5}

    import variables        ${CURDIR}/resources/python/CNI100590-Variables.py
    common_Dss_Keywords.Update SpecificParameters for VoNR configuration In WTS Cfg File    ${TestDSS20Mhz_2574_A5}

    Log to console    =================================== RUN TEST ===================================
    # 20MHz_DL150_20_UL30_20_CNI100590_TC_03_5gCall_with_Traffic_SA_Mode
    ${tc_name}    Set Variable     20MHz_DL150_20_UL30_20_CNI100590_TC_03_5gCall_with_Traffic_SA_Mode
    Log to console      --------------> RUN 1: ${tc_name}
    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog
    Run keyword and continue on failure    Test CNI100590 Template
    ...                        dl_expect_tput_value=150
    ...                        ul_expect_tput_value=30
    ...                        gbr_dl_expect_tput_value=0
    ...                        gbr_ul_expect_tput_value=0
    ...                        deviation=10
    ...                        resultFile=${resultFile}
    ...                        resultFileCRM=${resultFileCRM}
    ...                        tc_name=${tc_name}
    ...                        rdMeaningfulDlLoadMeasurementDifference=20
    ...                        rdMeaningfulDlLoadMeasurementDifference=20
    ...                        dl_qos_load_meas_timer=10
    ...                        ul_qos_load_meas_timer=10
    ...                        NIDD_100590_PARAMS=${NIDD_100590_PARAMS_TESTS}
    ...                        StepNumber=STEP1
    ...                        alias=egate_TC1
    Append To File      ${resultFile}     \nRUN ${tc_name} ---> END\n
    ${dir_syslog}=    Prepare Logs Directory Path     resultDir=${testCaseDir}    subdir=btslog_Run_STEP1
    ${ret}    ${syslogpath}=     robot_extension.Run Keyword And Warn On Failure   btslog.Stop Btslog    target_dir=${dir_syslog}
    Run Keyword If       '${ret}' == 'FAIL'    BuiltIn.Log    Failed to stop BtsLog !!!!   level=ERROR
    Get egate_commands File Name    step=STEP1
    robot_extension.Run Keyword And Warn On Failure   Extract egate_command    dir=${tl.core.dir_path}  egate_console=egate_console.log

    # fail    STOP TESTS

    # 20MHz_DL130_10_UL30_10_GBR_NGBR_CNI100590_5gCall_with_Traffic_SA_Mode
    ${tc_name}    Set Variable     20MHz_DL150_20_UL30_20_CNI100590_TC_03_5gCall_with_Traffic_SA_Mode
    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog
    Log to console    =================================================================================
    Log to console      --------------> RUN 2: ${tc_name}
    Run keyword and continue on failure    Test CNI100590 Template
    ...                        dl_expect_tput_value=130
    ...                        ul_expect_tput_value=30
    ...                        gbr_dl_expect_tput_value=10
    ...                        gbr_ul_expect_tput_value=10
    ...                        deviation=10
    ...                        resultFile=${resultFile}
    ...                        resultFileCRM=${resultFileCRM}
    ...                        tc_name=${tc_name}
    ...                        rdMeaningfulDlLoadMeasurementDifference=10
    ...                        rdMeaningfulDlLoadMeasurementDifference=10
    ...                        dl_qos_load_meas_timer=10
    ...                        ul_qos_load_meas_timer=10
    ...                        NIDD_100590_PARAMS=${NIDD_100590_PARAMS_TESTS}
    ...                        StepNumber=STEP2
    ...                        alias=egate_TC2
    Append To File      ${resultFile}     \nRUN ${tc_name} ---> END\n
    ${dir_syslog}=    Prepare Logs Directory Path     resultDir=${testCaseDir}    subdir=btslog_Run_STEP2
    ${ret}    ${syslogpath}=     robot_extension.Run Keyword And Warn On Failure   btslog.Stop Btslog    target_dir=${dir_syslog}
    Run Keyword If       '${ret}' == 'FAIL'    BuiltIn.Log    Failed to stop BtsLog !!!!   level=ERROR
    Get egate_commands File Name    step=STEP2
    robot_extension.Run Keyword And Warn On Failure   Extract egate_command    dir=${tl.core.dir_path}  egate_console=egate_console.log

    # 20MHz_DL0_1_UL0_10_GBR_2_TPUT_TGT_NGBR_CNI100590_5gCall_with_Traffic_SA_Mode
    ${tc_name}    Set Variable     20MHz_DL150_20_UL30_20_CNI100590_TC_03_5gCall_with_Traffic_SA_Mode
    Log to console    =================================================================================
    Log to console      --------------> RUN 3: ${tc_name}
    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog
    Run keyword and continue on failure    Test CNI100590 Template 2
    ...                        dl_expect_tput_value=0
    ...                        ul_expect_tput_value=0
    ...                        gbr_dl_expect_tput_value=10
    ...                        gbr_ul_expect_tput_value=10
    ...                        deviation=10
    ...                        resultFile=${resultFile}
    ...                        resultFileCRM=${resultFileCRM}
    ...                        tc_name=${tc_name}
    ...                        rdMeaningfulDlLoadMeasurementDifference=1
    ...                        rdMeaningfulDlLoadMeasurementDifference=10
    ...                        dl_qos_load_meas_timer=10
    ...                        ul_qos_load_meas_timer=10
    ...                        NIDD_100590_PARAMS=${NIDD_100590_PARAMS_TESTS}
    ...                        StepNumber=STEP3
    ...                        alias=egate_TC3
    Append To File      ${resultFile}     \nRUN ${tc_name} ---> END\n
    ${dir_syslog}=    Prepare Logs Directory Path     resultDir=${testCaseDir}    subdir=btslog_Run_STEP3
    ${ret}    ${syslogpath}=     robot_extension.Run Keyword And Warn On Failure   btslog.Stop Btslog    target_dir=${dir_syslog}
    Run Keyword If       '${ret}' == 'FAIL'    BuiltIn.Log    Failed to stop BtsLog !!!!   level=ERROR
    Get egate_commands File Name    step=STEP3
    robot_extension.Run Keyword And Warn On Failure   Extract egate_command    dir=${tl.core.dir_path}  egate_console=egate_console.log

    # 20MHz_DL130_20_UL30_20_FAST_ALLOC_OFF_CNI100590_TC_03_5gCall_with_Traffic_SA_Mode
    ${tc_name}    Set Variable     20MHz_DL130_20_UL30_20_FAST_ALLOC_OFF_CNI100590_TC_03_5gCall_with_Traffic_SA_Mode
    Log to console    =================================================================================
    Log to console      --------------> RUN 4: ${tc_name}
    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog
    Run keyword and continue on failure    Test CNI100590 Template
    ...                        dl_expect_tput_value=130
    ...                        ul_expect_tput_value=30
    ...                        gbr_dl_expect_tput_value=10
    ...                        gbr_ul_expect_tput_value=10
    ...                        deviation=10
    ...                        resultFile=${resultFile}
    ...                        resultFileCRM=${resultFileCRM}
    ...                        tc_name=${tc_name}
    ...                        rdMeaningfulDlLoadMeasurementDifference=20
    ...                        rdMeaningfulDlLoadMeasurementDifference=20
    ...                        dl_qos_load_meas_timer=200
    ...                        ul_qos_load_meas_timer=200
    ...                        NIDD_100590_PARAMS=${NIDD_100590_PARAMS_TESTS_FAST_ALLOC_OFF}
    ...                        StepNumber=STEP4
    ...                        alias=egate_TC4
    Append To File      ${resultFile}     \nRUN ${tc_name} ---> END\n
    Log to console    =================================== End Of RUN TEST ===================================
    ${dir_syslog}=    Prepare Logs Directory Path     resultDir=${testCaseDir}    subdir=btslog_Run_STEP4
    ${ret}    ${syslogpath}=     robot_extension.Run Keyword And Warn On Failure   btslog.Stop Btslog    target_dir=${dir_syslog}
    Run Keyword If       '${ret}' == 'FAIL'    BuiltIn.Log    Failed to stop BtsLog !!!!   level=ERROR
    Get egate_commands File Name    step=STEP4
    robot_extension.Run Keyword And Warn On Failure   Extract egate_command    dir=${tl.core.dir_path}  egate_console=egate_console.log

    Run keyword and continue on failure    Check if one of executions fails    ${status_of_execution}
    BuiltIn.log    ${status_of_execution}    level=INFO
    ${number_fail}    count values in list    ${execution_failed}    Failed
    ${rob_status}    Run keyword and return status    Should be empty    ${execution_failed}
    ${ROBUSTNESS_RUN_TIMES}     set Variable     ${4}
    Log to console    =================================================================================
    log to console    Passed iteration: ${${ROBUSTNESS_RUN_TIMES}-${number_fail}}/${${ROBUSTNESS_RUN_TIMES}}
    ${levellog}=     Set Variable If     ${rob_status}      INFO    ERROR
    BuiltIn.log    Passed iteration: ${${ROBUSTNESS_RUN_TIMES}-${number_fail}}/${${ROBUSTNESS_RUN_TIMES}}    level=${levellog}
    Log to console    =================================================================================
    IF     not ${rob_status}
           log to console    Failed iteration: ${number_fail}/${${ROBUSTNESS_RUN_TIMES}}
           Fail    ${execution_failed}
    END

   #  [Teardown]    Run Keywords
   #  ...    common_Dss_Keywords.Stop Tcpdump on TestPc    interface=eth3    target_dir=${testCaseDir}    AND
   #  ...    common_Dss_Keywords.Stop Tcpdump on TestPc    interface=eth4    target_dir=${testCaseDir}    AND
   #  ...    Run Keyword And Ignore Error    btslog.Stop Btslog    target_dir=${testCaseDir}    AND
   #  ...    Teardow check Tests Kw    AND
   #  ...    Get egate_commands File Name    AND
   #  ...    Run Keyword And Ignore Error    Extract egate_command    dir=${tl.core.dir_path}    egate_console=egate_console.log    AND
   #  ...    Teardown 2574    alias=egate_TC4    AND
   #  ...    Set Suite Variable    ${testCaseDir}    None

*** Keywords ***

CNI100590_DSS_5g_Call_SA
    [Arguments]                 ${alias}=default    ${w_ue_capa}=True    ${ue_capa_tag}=UE_CAPA_W_VONR

    ${UeId}   set variable     ${Param.Context.UeId1}
    ${msg}=   Catenate    ***DSS ${Param.Context.DSS_Phase} 5gCAll SA [BW=${Param.seq.bandwidth},UeId=${UeId}] with alias=${alias}***
    Log to console   \n${blue}${msg} ${normal}

    # 10/6/2023 : for testing purpose
    # ${gnbId}   set variable     ${Param.Context.gNBId}
    # ${cell_id}   set variable     1
    # common_Dss_SA_NSA.UL Set cell noise    gnbId=${gnbId}     cell_id=${cell_id}      alias=${alias}
    # common_Dss_SA_NSA.UL Set Target Power And Disable Noise For SRS Signals   ue_id=${UeId}    alias=${alias}
    # 10/6/2023 : End of for testing purpose
    common_Dss_SA_NSA.Set UE Parameters Before Register    ue_id=${UeId}    alias=${alias}
    common_Dss_SA_NSA.UE Register To GNB                   ue_id=${UeId}    alias=${alias}   w_ue_capa=${w_ue_capa}  ue_capa_tag=${ue_capa_tag}
    common_Dss_SA_NSA.UE PDU Session Setup                 ue_id=${UeId}    alias=${alias}

    log to console   \n${blue}***DSS SA 5gCall BW=${Param.seq.bandwidth} completed*** ${normal}

TC 2574 5g SA Call
   [Documentation]                Test purpose is to test 5g DSS SA Call
   [Arguments]                    ${param}    ${alias}=default    ${step}=None
   ${suffix}=    Set Variable if    '${step}'=='None'    5gSACall.wL1L2Bip.wXP    5gSACall.${step}.wL1L2Bip.wXP
   Init Sequence                  ${param}
   Step           Start capture Bip and Xp for 2574          argument=${suffix}
   Step           CNI100590_DSS_5g_Call_SA                   argument=${alias}
   Step           Stop capture Bip and Xp for 2574           depends=Start capture Bip and Xp for 2574
   [Teardown]                      GenericTest.Display diagnosis

TC 2574 SA CellSetup
   [Documentation]                Generic test for 2574: test purpose is to setup X2, Xp and DSS CellSetup Phase3
   [Arguments]                    ${param}     ${alias}=default
   Init Sequence                  ${param}
   common_Dss_Keywords.Restart     OwnTLReset=${False}     GNBCallback=common_Dss_Keywords.Set Reset Loop Counter
   Step                           Start capture Backhaul XP for DSS       argument=BH.XP.DssCellSetup    depends=common_Dss_Keywords.Restart
   Step                           common_Dss_Keywords.Start WTS           argument=${alias}
   Step                           Check wts in active state               argument=${alias}        depends=common_Dss_Keywords.Start WTS
   Step                           Wait Xp link Up                         argument=${alias}        depends=common_Dss_Keywords.Start WTS
   Step                           X2Ap link Setup                         argument=${alias}        depends=common_Dss_Keywords.Start WTS
   Step                           common_Dss_CellSetup.DSS_CRM_Cell_Setup_Phase3    argument=${alias}     depends=Wait Xp link Up
   ${pdmlFile}                    Stop capture Backhaul XP for DSS
   Run Keyword if       '${CELLSETUP_SHOULD_BE_CHECK}' == '1'
   ...                    Step        Check DSS CellSetup Phase3      argument=${pdmlFile}   depends=common_Dss_CellSetup.DSS_CRM_Cell_Setup_Phase3
   # Wait gNB cell 5g On air with globalCellId=1
   Critical Step                  common_Dss_CellSetup.Wait gNB cell 5g On air     globalCellId=1
   Critical Step                  common_Dss_CellSetup.Verify AP Classical Cell Setup
   [Teardown]               GenericTest.Display diagnosis


TC 2574 DL Tput SA Mode
    [Documentation]                Generic test for 2574: test purpose is to test DL Tput SA mode
    [Arguments]                    ${param}      ${dl_rate}=80     ${forced_expected_dl_ratio}=100    ${alias}=default
    Init Sequence                  ${param}
    Run Keyword If     '${UL_DL_TPUT_CHECK_BASED_AASYSLOG}' == '1'     Dated log     SSH on ${GNB_DU.sys[0].M.sshId}
    ${aliasGNB_M}                 Run Keyword If     '${UL_DL_TPUT_CHECK_BASED_AASYSLOG}' == '1'    SSH Wait For Connect    ${GNB_DU.sys[0].M}
    ${tput_log_file_path_gnb}     Run Keyword If     '${UL_DL_TPUT_CHECK_BASED_AASYSLOG}' == '1'    Start tput log capture    gnb_index=0
    ...                                                                                                          asik_alias=${aliasGNB_M}
    Dated log     =========> SA Start DL Traffic on ue_id=${UE_SIMPLE_CellDSS.ue} with ${dl_rate}M
    ${hugeTputRequested}=     Evaluate     ${dl_rate}>=${175}
    Run Keyword If     not ${hugeTputRequested}
    ...       Step       SA Start Generating "${dl_rate}"mbps DL Traffic for UeId "${Param.Context.UeId1}" on SA using alias "${alias}"
    ...    ELSE
    ...       Step       SA Start Generating Huge "${dl_rate}"mbps DL Traffic for UeId "${Param.Context.UeId1}" on SA using alias "${alias}"

    Traced Sleep   5s     msg=DL Traffic to test Tput
    Run Keyword If   '${UL_DL_TPUT_CHECK_BASED_AASYSLOG}' == '1'   Run keywords
    ...             Dated log    Calculate DL and UL throughput on gnb L2Lo case ...    AND
    ...             Check Throughput from aasyslog   asik_alias=${aliasGNB_M}     tput_log_file_path_gnb_combined=${tput_log_file_path_gnb}

    ${L1L2_Pcap_File}=   5GC002574_keywords.Get L1L2 traces    time=12s   prefix=DL_Tput_SA_Mode.12sDlTput.wL1L2Bip
    ${sum_prb}   ${sum_prb_5min}   ${expected_dl_ratio}=    Sum NbrOfPrb pdschsendreq from L1L2 Pcap wo Step    ${param}
    ...                                                                                                ${testCaseDir}/${L1L2_Pcap_File.name}.pcap

    ${expected_dl_ratio}=   set variable    ${forced_expected_dl_ratio}

    ${ret}   ${tti_trace_path}    Run Keyword And Ignore Error   Get TTI traces And Decode   suffix=wDlTput
    ...                                                                                      time=1s

    Step                Start capture Backhaul XP for DSS     argument=DL_Tput_SA_Mode.XP.BH
    Traced Sleep   3s     msg=DL Traffic to test DL Qos load Indication
    ${pdmlFile}         Stop capture Backhaul XP for DSS
    Dated log     =========> Check DL Qos Load Indication MeasuredNgbrNnbrLoad ...
    common_Dss_Keywords.Check DL Qos Load Indication MeasuredNgbrNnbrLoad   ${pdmlFile}    value=${expected_dl_ratio}
    ${L1L2_Pcap_File}=   5GC002574_keywords.Get L1L2 traces    time=2s   prefix=DL_Tput_SA_Mode.2sDLTput.wL1L2Bip
    set test variable     ${L1L2_Pcap_File}

    Dated log     =========> get throughput for ue (0x${Param.Context.UeId1})
    ${ul_throughput_for_ue1}=  nps_dss_tools.get_bearer_stats_SA   ue=${Param.Context.UeId1}
    ...                                                             pdu=1   qfi=1    direction=ul  alias=${alias}
    dated log     ul throughput for ue1 is ${ul_throughput_for_ue1} Mbps

    ${dl_throughput_for_ue1}=  nps_dss_tools.get_bearer_stats_SA   ue=${Param.Context.UeId1}
    ...                                                             pdu=1   qfi=1    direction=dl  alias=${alias}
    dated log     dl throughput for ue1 is ${dl_throughput_for_ue1} Mbps

    Step       common_Dss_SA_NSA.Display Ue Statistics       argument=${alias}
    Run Keyword And Ignore Error    Get TTI traces

    # common_Dss_SA_NSA.Stop Generating Traffic         ue=${UE_SIMPLE_CellDSS.ue}
    # ...                                           bearer=${UE_SIMPLE_CellDSS.bearer}
    # ...                                           alias=${alias}
    [Teardown]           GenericTest.Display diagnosis

DSS_5g_Periodic_DL_Fast_Allocation
   [Documentation]     DL Pattern list to add to CRMSim and active it
   [Arguments]         ${param}     ${alias}=default
   Init Sequence       ${param}
   Step      common_Dss_CellSetup.Periodic DL Fast Allocation With Same Pattern      argument=${alias}
   [Teardown]                      GenericTest.Display diagnosis

DSS_5g_Periodic_UL_Fast_Allocation
   [Documentation]     UL Pattern list to add to CRMSim and active it
   [Arguments]         ${param}     ${alias}=default
   Init Sequence       ${param}
   Step      common_Dss_CellSetup.Periodic UL Fast Allocation      argument=${alias}
   [Teardown]                      GenericTest.Display diagnosis

Test CNI100590 Template
   [Documentation]    Template test for CNI-100590 for 20MHz
   [Arguments]     ${dl_expect_tput_value}=130
   ...             ${ul_expect_tput_value}=30
   ...             ${gbr_dl_expect_tput_value}=0
   ...             ${gbr_ul_expect_tput_value}=0
   ...             ${deviation}=10
   ...             ${resultFile}=None
   ...             ${resultFileCRM}=None
   ...             ${tc_name}=None
   ...             ${rdMeaningfulDlLoadMeasurementDifference}=20
   ...             ${rdMeaningfulUlLoadMeasurementDifference}=20
   ...             ${dl_qos_load_meas_timer}=10
   ...             ${ul_qos_load_meas_timer}=10
   ...             ${NIDD_100590_PARAMS}=${NIDD_100590_PARAMS_TESTS}
   ...             ${StepNumber}=STEP1
   ...             ${alias}=egate

   Run Keyword And Ignore Error     start_default_tshark_on_s1_mme_and_uu_interfaces_for_testcase
   ...                                                 log_dirpath=${testCaseDir}/tshark_${StepNumber}

   Set Test Variable    ${resultFile}
   Set Test Variable    ${resultFileCRM}

   Append To File   ${resultFile}    \n========================================================
   Append To File   ${resultFile}    \nTEST : ${TEST_NAME}
   Append To File   ${resultFile}    \nTEST : ${tc_name}
   Append To File   ${resultFile}    \nSTEP : ${StepNumber}
   Append To File   ${resultFile}    \n========================================================
   Append To File   ${resultFile}    \n

   Append To File   ${resultFileCRM}    \n========================================================
   Append To File   ${resultFileCRM}    \nTEST : ${tc_name}
   Append To File   ${resultFileCRM}    \nSTEP : ${StepNumber}
   Append To File   ${resultFileCRM}    \n========================================================
   Append To File   ${resultFileCRM}    \n

   Append To File   ${resultFile}    \ndl_expect_tput_value : ${dl_expect_tput_value}
   Append To File   ${resultFile}    \nul_expect_tput_value : ${ul_expect_tput_value}
   Append To File   ${resultFile}    \ngbr_dl_expect_tput_value : ${gbr_dl_expect_tput_value}
   Append To File   ${resultFile}    \ngbr_ul_expect_tput_value : ${gbr_ul_expect_tput_value}

   set Test variable      ${rdMeaningfulDlLoadMeasurementDifference}
   set Test variable      ${rdMeaningfulUlLoadMeasurementDifference}
   ${name}=   Catenate      SEPARATOR=    20MHz_DL${dl_expect_tput_value}_${rdMeaningfulDlLoadMeasurementDifference}_
   ...                    UL${ul_expect_tput_value}_${rdMeaningfulUlLoadMeasurementDifference}
   Set Test Variable    ${name}
   Set RAD Params Of CNI100590    rdMeaningfulDlLoadMeasurementDifference=${rdMeaningfulDlLoadMeasurementDifference}
   ...                            rdMeaningfulUlLoadMeasurementDifference=${rdMeaningfulUlLoadMeasurementDifference}

   # modification DL Ratio into the test param Ctx
   Update DSS DL pattern with     ${TestDSS20Mhz_2574_A5}     ${PATTERN_DL_100_SA_OK}
   Dated log       DL pattern into TestParam is ${TestDSS20Mhz_2574_A5.seq.dl_allocated_normal_subframes}
   ${dl_qos_timer}    set Variable     ${dl_qos_load_meas_timer}
   ${ul_qos_timer}    set Variable     ${ul_qos_load_meas_timer}
   Update DSS dl qos load meas timer "${dl_qos_timer}" ms and ul qos load meas timer "${ul_qos_timer}" ms into "${TestDSS20Mhz_2574_A5}"
   Dated log       DL qos_load_meas_timer into TestParam is ${TestDSS20Mhz_2574_A5.seq.dl_qos_load_meas_timer} ms
   Dated log       UL qos_load_meas_timer into TestParam is ${TestDSS20Mhz_2574_A5.seq.ul_qos_load_meas_timer} ms

   ${ratio}=     nps_2574_tools.calculate_ratio_bits_1    ${PATTERN_DL_100_SA_OK}
   dated log      with DL PATTERN = ${PATTERN_DL_100_SA_OK}, the ratio is ${ratio}

   Set CNI100590 NIDD PARAMETERS    ${TestDSS20Mhz_2574_A5}    ${NIDD_100590_PARAMS}

   # add here validation of NIDD configuration
   # Run keyword and continue on failure     common_Dss_Keywords.Admin Validate SCF     scf_path_file=${test_scf_file}
   robot_extension.Run Keyword And Warn On Failure    common_Dss_Keywords.Admin Validate SCF     scf_path_file=${test_scf_file}

   5GC002574_keywords.TC DSS Phase3 CellSetup         ${TestDSS20Mhz_2574_A5}    ${alias}    step=${StepNumber}

   # save the CRM/ENB configuration
   common_Dss_CellSetup.get CRM and ENB Status    ${TestDSS20Mhz_2574_A5}    ${resultFileCRM}    ${alias}

   TC 2574 5g SA Call                           ${TestDSS20Mhz_2574_A5}    ${alias}    step=${StepNumber}
   Run Keyword If      ${dl_expect_tput_value} != ${0} or ${ul_expect_tput_value} != ${0}
   ...     common_Dss_SA_NSA.DSS_5g_SA_UL_DL_Traffic      ${TestDSS20Mhz_2574_A5}
   ...                                                    ul_rate=${ul_expect_tput_value}
   ...                                                    dl_rate=${dl_expect_tput_value}
   ...                                                    alias=${alias}

   Run Keyword If      ${gbr_dl_expect_tput_value} != ${0} or ${gbr_ul_expect_tput_value} != ${0}
   ...      common_Dss_SA_NSA.DSS_5g_SA_GBR_UL_DL_Traffic      ${TestDSS20Mhz_2574_A5}
   ...                                                         ul_rate=${gbr_ul_expect_tput_value}
   ...                                                         dl_rate=${gbr_dl_expect_tput_value}
   ...                                                         alias=${alias}

   Traced Sleep    5s      msg=Waiting for UL/DL Tput

   # Default Tti Filter Profiles
   ${filter_profile_0}=         Create List         1         0         0         0
   ...                                                        0         0         0
   # DSS events
   ${filter_profile_DSS}=       Create List         8388608         0         0         0
   ...                                                              0         0         0
   # Default + DSS events
   ${filter_profile_default_DSS}=       Create List         8388609         0         0         0
   ...                                                              0         0         0
   # Default + all events
   ${filter_profile_default_allEvent}=       Create List         3         0         0         0
   ...                                                              0         0         0
   # Note that 4194304 = 0x400000 which is in binary 10000000000000000000000
   # Is the mask for the event 22 which is the ID of the DLFDSCHEDDATA
   # Some events like the utc time stamp and a few others are always present and cannot be filtered out
   # Note that 452 = 0x1C4 which is in binary 111000100
   # Is the mask for the event 34 which is the ID of the DSSSLOTTYPEDATA
   # Is the mask for the event 38 which is the ID of the ULSUBCARRIERRESOURCEALLOCDATA
   # Is the mask for the event 39 which is the ID of the ULLOADINDDATA
   # Is the mask for the event 40 which is the ID of the DLLOADINDDATA
   # Some events like the utc time stamp and a few others are always present and cannot be filtered out
   ${filter_DLFDSCHEDDATA_DSS}=         Create List     0   4194304         452         0
   ...                                              0         0         0
   Omit when TtiTrace deactivated       Update TTI Trace filter       tti_filter=${filter_DLFDSCHEDDATA_DSS}
   Omit when TtiTrace deactivated       Start TTI traces
   Start capture Backhaul XP for DSS    prefix=BH.XP.1s.wULDLTput.${StepNumber}
   Traced Sleep    1s      msg=Waiting for Xp pcap traces
   Dated log             Point AF_PATH and ENB_BUILD to local luashark XP package
   Point AF_PATH to local luashark XP package
   Point ENB_BUILD to local luashark XP package
   ${XpPdmlFile}    Stop capture Backhaul XP for DSS
   ${ttiTraceSubDir}    ${tti_trace_path}    Omit when TtiTrace deactivated    Stop TTI traces    suffix=wXP-${StepNumber}
   ...                                                  w_decoding=True

   Omit when TtiTrace deactivated       Update TTI Trace filter       tti_filter=${filter_profile_0}
   ${ret}   ${tti_trace_path}    Omit when TtiTrace deactivated
   ...                           Run Keyword And Ignore Error   Get TTI traces And Decode    suffix=wDlAndUlTput-${StepNumber}
   ...                                                                                       time=1s
   ${TtifileName}   set Variable    ttitrace_streaming.pcap
   Omit when TtiTrace deactivated    Append To File   ${resultFile}   \ntti_trace_path: ${tti_trace_path}
   Omit when TtiTrace deactivated    Append To File   ${resultFile}   \ntti_trace_file: ${TtifileName}
   Omit when TtiTrace deactivated    Append To File   ${resultFile}   \n

   ${FilePkl}=           Omit when TtiTrace deactivated
   ...      Run keyword and continue on failure      5GC002574_keywords.Convert TTI Traces to Dataframe and store as pickle
   ...                                                                                          ttitraceFilename=ttitrace_streaming.pcap
   ...                                                                                          ttitracepath=${tti_trace_path}

   Omit when TtiTrace deactivated    Run keyword and continue on failure     Generate Test Verdict From TtiTraces    FilePkl=${FilePkl}

   ${actLteNrDssFastAlloc_SCF}=         Get actLteNrDssFastAlloc from SCF
   ${lteNrDssFastAllocPerfEnh_SCF}=     Get lteNrDssFastAllocPerfEnh from SCF

   ${dl_threshold_period_max}=  Set Variable If  '${rdMeaningfulDlLoadMeasurementDifference}'=='0' or '${actLteNrDssFastAlloc_SCF}'=='false'
   ...                                   ${TestDSS20Mhz_2574_A5.seq.dl_qos_load_meas_timer}       ${100}
   ${dl_threshold_period_min}=  Set Variable If  '${rdMeaningfulDlLoadMeasurementDifference}'=='0' or '${actLteNrDssFastAlloc_SCF}'=='false'
   ...                                   ${TestDSS20Mhz_2574_A5.seq.dl_qos_load_meas_timer}       ${10}
   ${ul_threshold_period_max}=  Set Variable If  '${rdMeaningfulUlLoadMeasurementDifference}'=='0' or '${actLteNrDssFastAlloc_SCF}'=='false'
   ...                                   ${TestDSS20Mhz_2574_A5.seq.ul_qos_load_meas_timer}       ${100}
   ${ul_threshold_period_min}=  Set Variable If  '${rdMeaningfulUlLoadMeasurementDifference}'=='0' or '${actLteNrDssFastAlloc_SCF}'=='false'
   ...                                   ${TestDSS20Mhz_2574_A5.seq.ul_qos_load_meas_timer}        ${10}
   Append To File   ${resultFile}   \ndl_threshold_period_max: ${dl_threshold_period_max}
   Append To File   ${resultFile}   \ndl_threshold_period_min: ${dl_threshold_period_min}
   Append To File   ${resultFile}   \nul_threshold_period_max: ${ul_threshold_period_max}
   Append To File   ${resultFile}   \nul_threshold_period_min: ${ul_threshold_period_min}
   Append To File   ${resultFile}   \n

   set_pandas.init_pandas
   ${dl_csvFile}    Extract xp_dss_endssdlqosloadmeasurement Usefull info from Pcap    File=${testCaseDir}/${capture_BH_GNB.name}.pcap
   ${fileName}   nps_2574_tools.return_basename    ${dl_csvFile}
   ${df}    pcap_dataframe.load_csv    csv_file_name=${fileName}    folder_path=${testCaseDir}
   ...                        csv_file_name_analysis=dl_analysis_${name}_${StepNumber}.csv    threshold=${rdMeaningfulDlLoadMeasurementDifference}
   ...                        direction=DL

   Append To File   ${resultFile}   \nxp_dss_endssdlqosloadmeasurement Input file: ${capture_BH_GNB.name}.pcap
   Append To File   ${resultFile}   \nResult file: dl_analysis_${name}_${StepNumber}.csv
   Append To File   ${resultFile}   \n

   dated log     ------> check_CNI100590 for DL direction
   Append To File   ${resultFile}   \n------> check_CNI100590 for DL direction
   ${FinalResult1}    pcap_dataframe.check_CNI100590    df=${df}    threshold_period_min=${dl_threshold_period_min}
   ...                                                 threshold_period_max=${dl_threshold_period_max}     tolerance_percent=${3}
   ...                                                 folder_path=${testCaseDir}
   ...                                                 csv_file_name_analysis=dl_analysis_${name}_${StepNumber}.csv
   ...                                                 result_file=${resultFile}
   dated log     FinalResult=${FinalResult1}
   Append To File   ${resultFile}    \nFinalResult=${FinalResult1}
   Append To File   ${resultFile}    \n
   Run keyword and continue on failure      should be True     ${FinalResult1}    Final Result for DL direction is not OK!!!
   set test Variable     ${FinalResult1}

   ${ul_csvFile}    Extract xp_dss_endssulqosloadmeasurement Usefull info from Pcap    File=${testCaseDir}/${capture_BH_GNB.name}.pcap
   ${fileName}   nps_2574_tools.return_basename    ${ul_csvFile}
   ${df}    pcap_dataframe.load_csv    csv_file_name=${fileName}    folder_path=${testCaseDir}
   ...                        csv_file_name_analysis=ul_analysis_${name}_${StepNumber}.csv    threshold=${rdMeaningfulUlLoadMeasurementDifference}
   ...                        direction=UL

   Append To File   ${resultFile}   \nxp_dss_endssulqosloadmeasurement Input file: ${capture_BH_GNB.name}.pcap
   Append To File   ${resultFile}   \nResult file: ul_analysis_${name}_${StepNumber}.csv
   Append To File   ${resultFile}   \n

   dated log     ------> check_CNI100590 for UL direction
   Append To File   ${resultFile}   \n------> check_CNI100590 for UL direction
   ${FinalResult2}     pcap_dataframe.check_CNI100590    df=${df}    threshold_period_min=${ul_threshold_period_min}
   ...                                                  threshold_period_max=${ul_threshold_period_max}     tolerance_percent=${3}
   ...                                                  folder_path=${testCaseDir}
   ...                                                  csv_file_name_analysis=ul_analysis_${name}_${StepNumber}.csv
   ...                                                  result_file=${resultFile}
   dated log     FinalResult=${FinalResult2}
   Append To File   ${resultFile}    \nFinalResult=${FinalResult2}
   Append To File   ${resultFile}    \n
   Run keyword and continue on failure      should be True     ${FinalResult2}    Final Result for UL direction is not OK!!!
   set test Variable     ${FinalResult2}

   Dated log             Point AF_PATH and ENB_BUILD to local luashark XP package
   Point AF_PATH to local luashark XP package
   Point ENB_BUILD to local luashark XP package
   Dated log     =========> Check UL and DL Qos Load Indication MeasuredNgbrNnbrLoad ...
   ${status}     ${avg_ul_MeasuredNgbrNnbrLoad}=  Run Keyword and Ignore Error  common_Dss_Keywords.Check UL Qos Load Indication MeasuredNgbrNnbrLoad
   ...                                                                                              ${XpPdmlFile}
   ...                                                                                              value=64
   ...                                                                                              with_verdict=False
   Run Keyword and Ignore Error      common_Dss_Keywords.Check DL Qos Load Indication MeasuredNgbrNnbrLoad       ${XpPdmlFile}
   Run Keyword and Ignore Error      common_Dss_Keywords.Check DL Qos Load Indication measuredGbrLoad            ${XpPdmlFile}
   Run Keyword and Ignore Error      common_Dss_Keywords.Check UL Qos Load Indication measuredGbrLoad            ${XpPdmlFile}

   Dated log     =========> get dl and ul throughput for ue (0x${TestDSS20Mhz_2574_A5.Context.UeId1})
   ${ul_throughput_for_ue1}=  Run Keyword If      ${ul_expect_tput_value} != ${0}
   ...                           nps_dss_tools.get_bearer_stats_SA   ue=${TestDSS20Mhz_2574_A5.Context.UeId1}
   ...                                                             pdu=1   qfi=1    direction=ul  alias=${alias}
   ...                          ELSE     Set Variable    ${0.0}
   dated log     ul throughput for ue1 is ${ul_throughput_for_ue1} Mbps

   ${dl_throughput_for_ue1}=  Run Keyword If      ${dl_expect_tput_value} != ${0}
   ...                         nps_dss_tools.get_bearer_stats_SA   ue=${TestDSS20Mhz_2574_A5.Context.UeId1}
   ...                                                             pdu=1   qfi=1    direction=dl  alias=${alias}
   ...                          ELSE     Set Variable    ${0.0}
   dated log     dl throughput for ue1 is ${dl_throughput_for_ue1} Mbps

   ${ul_gbr_throughput_for_ue1}=  Run Keyword If      ${gbr_ul_expect_tput_value} != ${0}
   ...                            nps_dss_tools.get_bearer_stats_SA   ue=${TestDSS20Mhz_2574_A5.Context.UeId1}
   ...                                                                pdu=1   qfi=3    direction=ul  alias=${alias}
   ...                          ELSE     Set Variable    ${0.0}
   dated log     ul gbr throughput for ue1 is ${ul_gbr_throughput_for_ue1} Mbps

   ${dl_gbr_throughput_for_ue1}=   Run Keyword If      ${gbr_dl_expect_tput_value} != ${0}
   ...                            nps_dss_tools.get_bearer_stats_SA   ue=${TestDSS20Mhz_2574_A5.Context.UeId1}
   ...                                                                pdu=1   qfi=3    direction=dl  alias=${alias}
   ...                          ELSE     Set Variable    ${0.0}
   dated log     dl gbr throughput for ue1 is ${dl_gbr_throughput_for_ue1} Mbps

   Dated log     =========> Test if Expected dl throughput is reached [expected=${dl_expect_tput_value}Mbps]
   ${dl_target_tput}=         Evaluate    float(${dl_expect_tput_value})
   ${DL_tput_ok}              Verify xL tput     dir=DL    tput_value=${dl_throughput_for_ue1}
   ...                                           expect_tput_value=${dl_target_tput}    tput_deviation=${deviation}
   # following test is moved from the KW to be sure if failed it is really reported
   Run Keyword If    '${dl_expect_tput_value}'!='0'
   ...                            should be true    '${DL_tput_ok}'=='True'    Tput is not as expected!
   [Teardown]     Run Keywords     dated log    ===========> Teardow check Tests Kw
   ...               AND           Run Keyword and Ignore Error    stop_default_tshark_on_s1_mme_and_uu_interfaces_for_testcase
   ...               AND           Teardow check Tests Kw
   ...               AND           Get failed Kw
   ...               AND           Append To List    ${status_of_execution}    ${TEST_STATUS}
   ...               AND           Test Status Check
   ...               AND           set test variable     ${status_of_execution}
   ...               AND           set test variable     ${execution_failed}

Get failed Kw
   ${TEST_STATUS}       Evaluate    ${FinalResult1} and ${FinalResult2}
   set test Variable    ${TEST_STATUS}

Test Status Check
    IF    not ${TEST_STATUS}
        Append To List    ${execution_failed}    Failed
    END

Test CNI100590 Template 2
   [Documentation]    Template test for CNI-100590 for 20MHz
   ...                Test template with Dl GBR Tput target changes
   [Arguments]     ${dl_expect_tput_value}=10
   ...             ${ul_expect_tput_value}=30
   ...             ${gbr_dl_expect_tput_value}=10
   ...             ${gbr_ul_expect_tput_value}=10
   ...             ${deviation}=10
   ...             ${resultFile}=None
   ...             ${resultFileCRM}=None
   ...             ${tc_name}=None
   ...             ${rdMeaningfulDlLoadMeasurementDifference}=1
   ...             ${rdMeaningfulUlLoadMeasurementDifference}=10
   ...             ${dl_qos_load_meas_timer}=10
   ...             ${ul_qos_load_meas_timer}=10
   ...             ${NIDD_100590_PARAMS}=${NIDD_100590_PARAMS_TESTS}
   ...             ${StepNumber}=STEP1
   ...             ${alias}=egate

   Set Test Variable    ${resultFile}
   Set Test Variable    ${resultFileCRM}

   Run Keyword And Ignore Error     start_default_tshark_on_s1_mme_and_uu_interfaces_for_testcase
   ...                                                 log_dirpath=${testCaseDir}/tshark_${StepNumber}

   Append To File   ${resultFile}    \n========================================================
   Append To File   ${resultFile}    \nTEST : ${TEST_NAME}
   Append To File   ${resultFile}    \nTEST : ${tc_name}
   Append To File   ${resultFile}    \nSTEP : ${StepNumber}
   Append To File   ${resultFile}    \n========================================================
   Append To File   ${resultFile}    \n

   Append To File   ${resultFileCRM}    \n========================================================
   Append To File   ${resultFileCRM}    \nTEST : ${tc_name}
   Append To File   ${resultFileCRM}    \nSTEP : ${StepNumber}
   Append To File   ${resultFileCRM}    \n========================================================
   Append To File   ${resultFileCRM}    \n

   Append To File   ${resultFile}    \ndl_expect_tput_value : ${dl_expect_tput_value}
   Append To File   ${resultFile}    \nul_expect_tput_value : ${ul_expect_tput_value}
   Append To File   ${resultFile}    \ngbr_dl_expect_tput_value : ${gbr_dl_expect_tput_value}
   Append To File   ${resultFile}    \ngbr_ul_expect_tput_value : ${gbr_ul_expect_tput_value}

   set Test variable      ${rdMeaningfulDlLoadMeasurementDifference}
   set Test variable      ${rdMeaningfulUlLoadMeasurementDifference}
   ${name}=   Catenate      SEPARATOR=    20MHz_DL${dl_expect_tput_value}_${rdMeaningfulDlLoadMeasurementDifference}_
   ...                    UL${ul_expect_tput_value}_${rdMeaningfulUlLoadMeasurementDifference}
   Set Test Variable    ${name}
   Set RAD Params Of CNI100590    rdMeaningfulDlLoadMeasurementDifference=${rdMeaningfulDlLoadMeasurementDifference}
   ...                            rdMeaningfulUlLoadMeasurementDifference=${rdMeaningfulUlLoadMeasurementDifference}

   # modification DL Ratio into the test param Ctx
   Update DSS DL pattern with     ${TestDSS20Mhz_2574_A5}     ${PATTERN_DL_100_SA_OK}
   Dated log       DL pattern into TestParam is ${TestDSS20Mhz_2574_A5.seq.dl_allocated_normal_subframes}
   ${dl_qos_timer}    set Variable     ${dl_qos_load_meas_timer}
   ${ul_qos_timer}    set Variable     ${ul_qos_load_meas_timer}
   Update DSS dl qos load meas timer "${dl_qos_timer}" ms and ul qos load meas timer "${ul_qos_timer}" ms into "${TestDSS20Mhz_2574_A5}"
   Dated log       DL qos_load_meas_timer into TestParam is ${TestDSS20Mhz_2574_A5.seq.dl_qos_load_meas_timer} ms
   Dated log       UL qos_load_meas_timer into TestParam is ${TestDSS20Mhz_2574_A5.seq.ul_qos_load_meas_timer} ms

   ${ratio}=     nps_2574_tools.calculate_ratio_bits_1    ${PATTERN_DL_100_SA_OK}
   dated log      with DL PATTERN = ${PATTERN_DL_100_SA_OK}, the ratio is ${ratio}

   Set CNI100590 NIDD PARAMETERS    ${TestDSS20Mhz_2574_A5}    ${NIDD_100590_PARAMS}

   # add here check of NIDD configuration
   # Run keyword and continue on failure     common_Dss_Keywords.Admin Validate SCF     scf_path_file=${test_scf_file}
   robot_extension.Run Keyword And Warn On Failure    common_Dss_Keywords.Admin Validate SCF     scf_path_file=${test_scf_file}

   5GC002574_keywords.TC DSS Phase3 CellSetup         ${TestDSS20Mhz_2574_A5}    ${alias}    step=${StepNumber}

   # dump the CRM/ENB configuration
   common_Dss_CellSetup.get CRM and ENB Status    ${TestDSS20Mhz_2574_A5}    ${resultFileCRM}    ${alias}

   TC 2574 5g SA Call                           ${TestDSS20Mhz_2574_A5}    ${alias}      step=${StepNumber}
   Run Keyword If      ${dl_expect_tput_value} != ${0} or ${ul_expect_tput_value} != ${0}
   ...     common_Dss_SA_NSA.DSS_5g_SA_UL_DL_Traffic      ${TestDSS20Mhz_2574_A5}
   ...                                                    ul_rate=${ul_expect_tput_value}
   ...                                                    dl_rate=${dl_expect_tput_value}
   ...                                                    alias=${alias}

   Run Keyword If      ${gbr_dl_expect_tput_value} != ${0} or ${gbr_ul_expect_tput_value} != ${0}
   ...      common_Dss_SA_NSA.DSS_5g_SA_GBR_UL_DL_Traffic      ${TestDSS20Mhz_2574_A5}
   ...                                                         ul_rate=${gbr_ul_expect_tput_value}
   ...                                                         dl_rate=${gbr_dl_expect_tput_value}
   ...                                                         alias=${alias}

   Traced Sleep    5s      msg=Waiting for UL/DL Tput

   Omit when TtiTrace deactivated       Start TTI traces
   Start capture Backhaul XP for DSS    prefix=BH.XP.1s.wULDLTput.${StepNumber}
   Traced Sleep    1s      msg=Waiting for Xp pcap traces
   common_Dss_SA_NSA.DSS_5g_SA_GBR_UL_DL_Traffic_New_Tput_Tgt      ${TestDSS20Mhz_2574_A5}
   ...                                                             ul_rate=${gbr_ul_expect_tput_value}
   ...                                                             dl_rate=30
   ...                                                             alias=${alias}
   Traced Sleep    1s      msg=Waiting for Xp pcap traces
   Dated log             Point AF_PATH and ENB_BUILD to local luashark XP package
   Point AF_PATH to local luashark XP package
   Point ENB_BUILD to local luashark XP package
   ${XpPdmlFile}    Stop capture Backhaul XP for DSS
   Omit when TtiTrace deactivated    Stop and Get TTI traces    suffix=wXP-${StepNumber}     w_convert_pcap_to_excelCsv=False
   ...                                                          w_decoding=True

   ${ret}   ${tti_trace_path}    Omit when TtiTrace deactivated
   ...                           Run Keyword And Ignore Error   Get TTI traces And Decode    suffix=wDlAndUlTput-${StepNumber}
   ...                                                                                       time=1s
   ${TtifileName}   set Variable    ttitrace_streaming.pcap
   Omit when TtiTrace deactivated    Append To File   ${resultFile}   \ntti_trace_path: ${tti_trace_path}
   Omit when TtiTrace deactivated    Append To File   ${resultFile}   \ntti_trace_file: ${TtifileName}
   Omit when TtiTrace deactivated    Append To File   ${resultFile}   \n

   ${FilePkl}=           Omit when TtiTrace deactivated
   ...      Run keyword and continue on failure      5GC002574_keywords.Convert TTI Traces to Dataframe and store as pickle
   ...                                                                                          ttitraceFilename=ttitrace_streaming.pcap
   ...                                                                                          ttitracepath=${tti_trace_path}

   Omit when TtiTrace deactivated    Run keyword and continue on failure     Generate Test Verdict From TtiTraces    FilePkl=${FilePkl}

   ${actLteNrDssFastAlloc_SCF}=         Get actLteNrDssFastAlloc from SCF
   ${lteNrDssFastAllocPerfEnh_SCF}=     Get lteNrDssFastAllocPerfEnh from SCF

   ${dl_threshold_period_max}=  Set Variable If  '${rdMeaningfulDlLoadMeasurementDifference}'=='0' or '${actLteNrDssFastAlloc_SCF}'=='false'
   ...                                   ${TestDSS20Mhz_2574_A5.seq.dl_qos_load_meas_timer}       ${100}
   ${dl_threshold_period_min}=  Set Variable If  '${rdMeaningfulDlLoadMeasurementDifference}'=='0' or '${actLteNrDssFastAlloc_SCF}'=='false'
   ...                                   ${TestDSS20Mhz_2574_A5.seq.dl_qos_load_meas_timer}       ${10}
   ${ul_threshold_period_max}=  Set Variable If  '${rdMeaningfulUlLoadMeasurementDifference}'=='0' or '${actLteNrDssFastAlloc_SCF}'=='false'
   ...                                   ${TestDSS20Mhz_2574_A5.seq.ul_qos_load_meas_timer}       ${100}
   ${ul_threshold_period_min}=  Set Variable If  '${rdMeaningfulUlLoadMeasurementDifference}'=='0' or '${actLteNrDssFastAlloc_SCF}'=='false'
   ...                                   ${TestDSS20Mhz_2574_A5.seq.ul_qos_load_meas_timer}        ${10}
   Append To File   ${resultFile}   \ndl_threshold_period_max: ${dl_threshold_period_max}
   Append To File   ${resultFile}   \ndl_threshold_period_min: ${dl_threshold_period_min}
   Append To File   ${resultFile}   \nul_threshold_period_max: ${ul_threshold_period_max}
   Append To File   ${resultFile}   \nul_threshold_period_min: ${ul_threshold_period_min}
   Append To File   ${resultFile}   \n

   set_pandas.init_pandas
   ${dl_csvFile}    Extract xp_dss_endssdlqosloadmeasurement Usefull info from Pcap    File=${testCaseDir}/${capture_BH_GNB.name}.pcap
   ${fileName}   nps_2574_tools.return_basename    ${dl_csvFile}
   ${df}    pcap_dataframe.load_csv    csv_file_name=${fileName}    folder_path=${testCaseDir}
   ...                        csv_file_name_analysis=dl_analysis_${name}_${StepNumber}.csv    threshold=${rdMeaningfulDlLoadMeasurementDifference}
   ...                        direction=DL

   Append To File   ${resultFile}   \nxp_dss_endssdlqosloadmeasurement Input file: ${capture_BH_GNB.name}.pcap
   Append To File   ${resultFile}   \nResult file: dl_analysis_${name}.csv
   Append To File   ${resultFile}   \n

   dated log     ------> check_CNI100590 for DL direction
   Append To File   ${resultFile}   \n------> check_CNI100590 for DL direction
   ${FinalResult1}    pcap_dataframe.check_CNI100590    df=${df}    threshold_period_min=${dl_threshold_period_min}
   ...                                                 threshold_period_max=${dl_threshold_period_max}     tolerance_percent=${3}
   ...                                                 folder_path=${testCaseDir}
   ...                                                 csv_file_name_analysis=dl_analysis_${name}_${StepNumber}.csv
   ...                                                 result_file=${resultFile}
   dated log     FinalResult=${FinalResult1}
   Append To File   ${resultFile}    \nFinalResult=${FinalResult1}
   Append To File   ${resultFile}    \n
   Run keyword and continue on failure      should be True     ${FinalResult1}    Final Result for DL direction is not OK!!!
   set Test Variable     ${FinalResult1}

   ${ul_csvFile}    Extract xp_dss_endssulqosloadmeasurement Usefull info from Pcap    File=${testCaseDir}/${capture_BH_GNB.name}.pcap
   ${fileName}   nps_2574_tools.return_basename    ${ul_csvFile}
   ${df}    pcap_dataframe.load_csv    csv_file_name=${fileName}    folder_path=${testCaseDir}
   ...                        csv_file_name_analysis=ul_analysis_${name}_${StepNumber}.csv    threshold=${rdMeaningfulUlLoadMeasurementDifference}
   ...                        direction=UL

   Append To File   ${resultFile}   \nxp_dss_endssulqosloadmeasurement Input file: ${capture_BH_GNB.name}.pcap
   Append To File   ${resultFile}   \nResult file: ul_analysis_${name}.csv
   Append To File   ${resultFile}   \n

   dated log     ------> check_CNI100590 for UL direction
   Append To File   ${resultFile}   \n------> check_CNI100590 for UL direction
   ${FinalResult2}     pcap_dataframe.check_CNI100590    df=${df}    threshold_period_min=${ul_threshold_period_min}
   ...                                                  threshold_period_max=${ul_threshold_period_max}     tolerance_percent=${3}
   ...                                                  folder_path=${testCaseDir}
   ...                                                  csv_file_name_analysis=ul_analysis_${name}_${StepNumber}.csv
   ...                                                  result_file=${resultFile}
   dated log     FinalResult=${FinalResult2}
   Append To File   ${resultFile}    \nFinalResult=${FinalResult2}
   Append To File   ${resultFile}    \n
   Run keyword and continue on failure      should be True     ${FinalResult2}    Final Result for UL direction is not OK!!!
   set Test Variable     ${FinalResult2}

   Dated log             Point AF_PATH and ENB_BUILD to local luashark XP package
   Point AF_PATH to local luashark XP package
   Point ENB_BUILD to local luashark XP package
   Dated log     =========> Check UL and DL Qos Load Indication MeasuredNgbrNnbrLoad ...
   ${status}     ${avg_ul_MeasuredNgbrNnbrLoad}=  Run Keyword and Ignore Error  common_Dss_Keywords.Check UL Qos Load Indication MeasuredNgbrNnbrLoad
   ...                                                                                              ${XpPdmlFile}
   ...                                                                                              value=64
   ...                                                                                              with_verdict=False
   Run Keyword and Ignore Error      common_Dss_Keywords.Check DL Qos Load Indication MeasuredNgbrNnbrLoad       ${XpPdmlFile}
   Run Keyword and Ignore Error      common_Dss_Keywords.Check DL Qos Load Indication measuredGbrLoad            ${XpPdmlFile}
   Run Keyword and Ignore Error      common_Dss_Keywords.Check UL Qos Load Indication measuredGbrLoad            ${XpPdmlFile}

   Dated log     =========> get dl and ul throughput for ue (0x${TestDSS20Mhz_2574_A5.Context.UeId1})

   ${ul_throughput_for_ue1}=  nps_dss_tools.get_bearer_stats_SA   ue=${TestDSS20Mhz_2574_A5.Context.UeId1}
   ...                                                             pdu=1   qfi=1    direction=ul  alias=${alias}
   dated log     ul throughput for ue1 is ${ul_throughput_for_ue1} Mbps

   ${dl_throughput_for_ue1}=  nps_dss_tools.get_bearer_stats_SA   ue=${TestDSS20Mhz_2574_A5.Context.UeId1}
   ...                                                             pdu=1   qfi=1    direction=dl  alias=${alias}
   dated log     dl throughput for ue1 is ${dl_throughput_for_ue1} Mbps

   ${ul_gbr_throughput_for_ue1}=  nps_dss_tools.get_bearer_stats_SA   ue=${TestDSS20Mhz_2574_A5.Context.UeId1}
   ...                                                                pdu=1   qfi=3    direction=ul  alias=${alias}
   dated log     ul gbr throughput for ue1 is ${ul_gbr_throughput_for_ue1} Mbps

   ${dl_gbr_throughput_for_ue1}=  nps_dss_tools.get_bearer_stats_SA   ue=${TestDSS20Mhz_2574_A5.Context.UeId1}
   ...                                                                pdu=1   qfi=3    direction=dl  alias=${alias}
   dated log     dl gbr throughput for ue1 is ${dl_gbr_throughput_for_ue1} Mbps

   Dated log     =========> Test if Expected dl throughput is reached [expected=${dl_expect_tput_value}Mbps]
   ${dl_target_tput}=         Evaluate    float(${dl_expect_tput_value})
   ${DL_tput_ok}              Verify xL tput     dir=DL    tput_value=${dl_throughput_for_ue1}
   ...                                           expect_tput_value=${dl_target_tput}    tput_deviation=${deviation}
   # following test is moved from the KW to be sure if failed it is really reported
   Run Keyword If    '${dl_expect_tput_value}'!='0'
   ...                            should be true    '${DL_tput_ok}'=='True'    Tput is not as expected!
   [Teardown]     Run Keywords     dated log    ===========> Teardow check Tests Kw
   ...               AND           Run Keyword and Ignore Error    stop_default_tshark_on_s1_mme_and_uu_interfaces_for_testcase
   ...               AND           Teardow check Tests Kw
   ...               AND           Get failed Kw
   ...               AND           Append To List    ${status_of_execution}    ${TEST_STATUS}
   ...               AND           Test Status Check
   ...               AND           set test variable     ${status_of_execution}
   ...               AND           set test variable     ${execution_failed}

Check if one of executions fails
    [Arguments]    ${status_of_execution}
    FOR    ${exec}    IN    @{status_of_execution}
        should not be equal as strings    '${exec}'    'False'
    END


