*** Settings ***
Documentation    TMO Automation for SISO without L3 call cases
...              Author: xiangsheng.chu@nokia-sbell.com
Suite Setup    TMO_Common_Suite_Setup    is_commission=${False}    whether_do_prepare_ue=${False}    turn_off_pa=${False}
Test Teardown    robot_common_operations.Common Suite Teardown
Suite Teardown    robot_common_operations.Common Suite Teardown
Force Tags    5G_SISO    SG_06     CA_VRF_HAZ4
...    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_counter_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_KPI_Report_Case_Common.robot

*** Variables ***
${spark_ue_logpath}      C:/tmp/uelog/AUTO/${target_version}
${ReportName_ue_kpi}      C:/spark/UE_KPI.rpt
${ReportName_ue_DL_kpi}      C:/spark/UE_DL_KPI.rpt
${ReportName_ue_prach}      C:/spark/UE_prach.rpt
${qc_lab_path_trunk}    Root\\Test_Sets\\Trunk\\VRF_HAZ\\VRF_HAZ_T06\\VRF_HAZ4_T06
${qc_lab_path_SBTS24R3}    Root\\Test_Sets\\24R3_MP\\Regression\\VRF_HAZ4\\VRF_HAZ4_T06
${qc_lab_path_SBTS24R2}    Root\\Test_Sets\\24R2_MP\\Regression\\VRF_HAZ4\\VRF_HAZ4_T06
${SAVE LOG DIRECTORY}      /tmp
${scell_add_fail}    adding UE failed
${Ue_group_full}    The UE group is full
${enb_target_ver}
${enb_target_sw}    ${enb_target_ver}

*** Test Cases ***
#5603052_AEHC_cell_edge_case005_SA_RSRP_near_mid_far condition KPI_comparison_with RACHindex9_RACHindex206_bk
#    [Tags]    UE_5G_cell   T284_TOL_5G_KPI
#    [Setup]    TMO_Common_Case_Setup_Kpi    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
#    Check Rollback is needed before sw upgrade
#    Check Enb Rollback is needed before sw upgrade
#    Check TMO Gnb Ready And All Cell On Air
#    Verify All Enbs Cell On Air
#    Set Test Variable    ${upgrade_package_path}    /home/ute/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
#    Set Test Variable    ${enb_upgrade_package_path}    /home/ute/${enb_target_sw}_release_BTSSM_downloadable_A54.zip
#    ${gnb_up}    Set Variable If    '${package_version_1525-CA}'==''      false    true
#    ${enb_up}    Set Variable If    '${enb_target_sw}'==''      false    true
#    Set Test Variable    ${whether_gnb_up}    ${gnb_up}
#    Set Test Variable    ${whether_enb_up}    ${enb_up}
#    ${version_splitted}    Split String    ${package_version_1525-CA}    _
#    ${tmp_gnb_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
#    ${qc_id}     Set Variable If    '${tmp_gnb_version}'=='24R3'     850024
#    ...                             '${tmp_gnb_version}'=='00'    35506
#    ...                             '${tmp_gnb_version}'=='24R2'    834517
#    ${qc_lab_path}     Set Variable If    '${tmp_gnb_version}'=='24R3'     ${qc_lab_path_SBTS24R3}
#    ...                             '${tmp_gnb_version}'=='00'    ${qc_lab_path_trunk}
#    ...                             '${tmp_gnb_version}'=='24R2'    ${qc_lab_path_SBTS24R2}
#    ${case_time}=    Get Current Date    result_format=%Y%m%d%H%M%S
#    ${spark_ue_logpath} =   Catenate    SEPARATOR=_   ${spark_ue_logpath}   ${case_time}
#    ${spark_ue_logname} =   Catenate    SEPARATOR=_   ${target_version}   ${case_time}
#    Set Test Variable   ${spark_ue_logname}
#    Set Test Variable   ${spark_ue_logpath}
#    Run Keyword And Continue On Failure    run keyword If    '${whether_gnb_up}'=='true'    Download SW Build from artifactory
#    Run Keyword And Continue On Failure    run keyword If    '${whether_enb_up}'=='true'    Download SW Build from artifactory
#    ...                                    target_version=${enb_target_sw}
#    Commission SCF with gnb version
#    Run Keyword And Continue On Failure     Run Keyword If   '${tl_prefix}'=='T080'    Update The Flag Whether Support 3CC    3CC_flag=${False}
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    Update Parameter to prepare L3 call    para_value=false
#    ...                                   enb_index=${fdd_enb_index}
#    Update The Prach Index    cell_index=${PCELL_INDEX}    prach_index=9
#    Update_TMO_3CC_Configration    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
#    Change cellBarred Parameter Value On Gnb    pcell_index=${PCELL_INDEX}    exp_status=notBarred
#    Get KPI Report with difference RSRP in 15min    folder_index=1    spark_ue_logpath=${spark_ue_logpath}
#    wait until keyword succeeds     5 min   10 sec     Connect to gnb coam via ssl
#    run keyword If    '${whether_gnb_up}'=='true'    coam.update_software    sw_package=${upgrade_package_path}    timeout=7200    connection=GNB_OAM
#    Run Keyword And Ignore Error    COAM Teardown gnb connections
#    sleep  5min
#    Check GNB On Air And Unexpect Alarm Should Not Exist
#    Check ENB On Air And Unexpect Alarm Should Not Exist
#    run keyword If    '${whether_enb_up}'=='true'    Enb Upgrade Only
#    Get KPI Report with difference RSRP in 15min    folder_index=2    spark_ue_logpath=${spark_ue_logpath}
#    Commission SCF with gnb version
#    Run Keyword And Continue On Failure     Run Keyword If   '${tl_prefix}'=='T080'    Update The Flag Whether Support 3CC    3CC_flag=${False}
#    Update Parameter to prepare L3 call    para_value=false
#    ...                                   enb_index=${fdd_enb_index}
#    Update_TMO_3CC_Configration    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
#    Update The Prach Index    cell_index=${PCELL_INDEX}    prach_index=9
#    Change cellBarred Parameter Value On Gnb    pcell_index=${PCELL_INDEX}    exp_status=notBarred
#    Get KPI Report with difference RSRP in 15min    folder_index=3    spark_ue_logpath=${spark_ue_logpath}
#    ${exportReport_pc_logpath_windows}    ${exportReport_pc_logpath_cygwin}    Create ExportReport logpath in UE control PC
#    ${pc_logpath_23R4_GA}    ${pc_logpath_cu_version_0}    ${pc_logpath_cu_version_1}    Create result file path to server PC
#    ...                                                    pc_logpath=${exportReport_pc_logpath_cygwin}
#    ${filepath_in_ute_3052_0} =   Catenate    SEPARATOR=/   ${TS_CASE_LOG_PATH}   1
#    ${filepath_in_ute_3052_1} =   Catenate    SEPARATOR=/   ${TS_CASE_LOG_PATH}   2
#    ${filepath_in_ute_3052_2} =   Catenate    SEPARATOR=/   ${TS_CASE_LOG_PATH}   3
#    Upload result file from ute to server PC   filepath_in_ute_3052_0=${filepath_in_ute_3052_0}   pc_logpath_23R4_GA=${pc_logpath_23R4_GA}
#    Upload result file from ute to server PC   filepath_in_ute_3052_1=${filepath_in_ute_3052_1}   pc_logpath_cu_version_0=${pc_logpath_cu_version_0}
#    Upload result file from ute to server PC   filepath_in_ute_3052_2=${filepath_in_ute_3052_2}   pc_logpath_cu_version_1=${pc_logpath_cu_version_1}
#    Spark signal Ue ExportReport with Logfiles    ue_logname=${spark_ue_logname}
#    ...                                           ue_logpath=${spark_ue_logpath}
#    ...                                           ReportName=${ReportName_ue_kpi}
#    ...                                           ReportGenerationPath=${exportReport_pc_logpath_windows}
#    ...                                           ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
#    sleep   5s
#    Run Keyword If   '${tl_prefix}'!='T080'       Spark multiUE ExportReport result to server PC
#    ...                                           ExportReport_path_cygwin=${exportReport_pc_logpath_cygwin}
#    ...                                           ExportReport_path_windows=${exportReport_pc_logpath_windows}
#    Spark signal Ue ExportReport with Logfiles    ue_logname=${spark_ue_logname}
#    ...                                           ue_logpath=${spark_ue_logpath}
#    ...                                           ReportName=${ReportName_ue_DL_kpi}
#    ...                                           ReportGenerationPath=${exportReport_pc_logpath_windows}
#    ...                                           ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
#    sleep   5s
#    Run Keyword If   '${tl_prefix}'!='T080'       Spark multiUE ExportReport result to server PC
#    ...                                           ExportReport_path_cygwin=${exportReport_pc_logpath_cygwin}
#    ...                                           ExportReport_path_windows=${exportReport_pc_logpath_windows}
#    Check Rollback is needed before sw upgrade
#    Check Enb Rollback is needed before sw upgrade
#    sleep   600s
#    Check TMO Gnb Ready And All Cell On Air
#    Verify All Enbs Cell On Air
#    [Teardown]    Run Keywords   Run Keyword If Test Failed    Report Result To Reporting Portal
#    ...    test_result=Failed   qc_lab_path=${qc_lab_path}   qc_id=${qc_id}
#    ...    AND   Run Keyword If Test Passed    Report Result To Reporting Portal   test_result=Passed   qc_lab_path=${qc_lab_path}   qc_id=${qc_id}
#    ...    AND   Run Keyword And Ignore Error    TMO_Common_Case_Teardown_kpi    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
#    ...                                           ue_type=${ue_type}


#5603142_E2E_TOL_142_CB008311_KPI_testing
#    [Tags]    UE_5G_cell   T284_TOL_5G_KP
#    [Setup]    TMO_Common_Case_Setup_Kpi    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
#    Set Test Variable    ${upgrade_package_path}    /home/ute/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
#    Set Test Variable    ${enb_upgrade_package_path}    /home/ute/${enb_target_sw}_release_BTSSM_downloadable_A54.zip
#    ${gnb_up}    Set Variable If    '${package_version_1525-CA}'==''      false    true
#    ${enb_up}    Set Variable If    '${enb_target_sw}'==''      false    true
#    Set Test Variable    ${whether_gnb_up}    ${gnb_up}
#    Set Test Variable    ${whether_enb_up}    ${enb_up}
#    log to console    --- start to download sw build from artifactory---
#    Check Rollback is needed before sw upgrade
#    Check Enb Rollback is needed before sw upgrade
#    Check TMO Gnb Ready And All Cell On Air
#    Verify All Enbs Cell On Air
#    Run Keyword And Continue On Failure    run keyword If    '${whether_gnb_up}'=='true'    Download SW Build from artifactory
#    Run Keyword And Continue On Failure    run keyword If    '${whether_enb_up}'=='true'    Download SW Build from artifactory
#    ...                                    target_version=${enb_target_sw}
#    ${remote_log_path}    OperatingSystem.Join Path    ${TS_CASE_LOG_PATH}    8311_kpi
#    OperatingSystem.Create Directory    ${remote_log_path}
#    Set Test Variable     ${remote_log_path}
#    ${case_time}=    Get Current Date    result_format=%Y%m%d%H%M%S
#    ${spark_ue_logpath} =   Catenate    SEPARATOR=_   ${spark_ue_logpath}   ${case_time}
#    ${spark_ue_logname} =   Catenate    SEPARATOR=_   ${target_version}   ${case_time}
#    Set Test Variable   ${spark_ue_logname}
#    Set Test Variable   ${spark_ue_logpath}
#    Commission SCF with gnb version
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    Update_TMO_3CC_Configration    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
#    Update Parameter to prepare L3 call    para_value=false
#    ...                                   enb_index=${fdd_enb_index}
#    Update The Prach Index    cell_index=${PCELL_INDEX}    prach_index=9
#    Change cellBarred Parameter Value On Gnb    pcell_index=${PCELL_INDEX}    exp_status=notBarred
#    run keyword If    '${whether_enb_up}'=='true'    Enb Upgrade Only
#    wait until keyword succeeds     5 min   10 sec     Connect to gnb coam via ssl
#    run keyword If    '${whether_gnb_up}'=='true'    coam.update_software    sw_package=${upgrade_package_path}    timeout=7200    connection=GNB_OAM
#    Run Keyword And Ignore Error    COAM Teardown gnb connections
#    sleep  5min
#    Check GNB On Air And Unexpect Alarm Should Not Exist
#    Check ENB On Air And Unexpect Alarm Should Not Exist
#    MultiUE Prepare UE     low_RSRP=True
#    FOR    ${i}    IN RANGE    1    195
#           log to console      "UE Attach_${i}"
#           MultiUE Attach without check TP in UE    logpath=${spark_ue_logpath}    logname=run_1_${i}    save_ue_log=False
#           ...    DL_200M_8311=DL_10M_8311
#           sleep   2s
#    END
#    ute_syslog.Start Syslog    log_dir=${SAVE LOG DIRECTORY}    log_name=btslog_scell.LOG    ip=192.168.255.126    alias=syslog
#    FOR    ${i}    IN RANGE    1    5
#           log to console      "UE Attach_no_tp_${i}"
#           MultiUE Attach without check TP in UE    logpath=${spark_ue_logpath}    logname=run_1_${i}
#           ...    DL_200M_8311=DL_400M_8311
#           sleep   2s
#    END
#    ${output1}=    run keyword and return status    ute_syslog.Message Should Exist In Syslog File    regexp=${scell_add_fail}    alias=syslog
#    ${output2}=    run keyword and return status    ute_syslog.Message Should Exist In Syslog File    regexp=${Ue_group_full}    alias=syslog
#    ute_syslog.stop_syslog    alias=syslog
#    ute_syslog.Collect Syslog Results     destination=${SAVE LOG DIRECTORY}    alias=syslog
#    run keyword if    '${output1}'=='${True}'    Fail
#    run keyword if    '${output2}'=='${True}'    Fail
#    Common_keywords.Collect Snapshot Log     log_path=${remote_log_path}
#    Commission SCF with gnb version
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    Update_TMO_3CC_Configration    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
#    Update Parameter to prepare L3 call    para_value=false
#    ...                                   enb_index=${fdd_enb_index}
#    Update actSCellReleaseForInactiveSCell in gnb
#    Update The Prach Index    cell_index=${PCELL_INDEX}    prach_index=9
#    Change cellBarred Parameter Value On Gnb    pcell_index=${PCELL_INDEX}    exp_status=notBarred
#    FOR    ${i}    IN RANGE    1    195
#           log to console      "UE Attach_${i}"
#           MultiUE Attach without check TP in UE    logpath=${spark_ue_logpath}    logname=run_1_${i}    save_ue_log=False
#           ...    DL_200M_8311=DL_10M_8311
#           sleep   2s
#    END
#    ute_syslog.Start Syslog    log_dir=${SAVE LOG DIRECTORY}    log_name=btslog_scell1.LOG    ip=192.168.255.126    alias=syslog1
#    FOR    ${i}    IN RANGE    1    5
#           log to console      "UE Attach_no_tp_${i}"
#           MultiUE Attach without check TP in UE    logpath=${spark_ue_logpath}    logname=run_1_${i}
#           ...    DL_200M_8311=DL_400M_8311
#           sleep   2s
#    END
#    ${output3}=    run keyword and return status    ute_syslog.Message Should Exist In Syslog File    regexp=${scell_add_fail}    alias=syslog1
#    ${output4}=    run keyword and return status    ute_syslog.Message Should Exist In Syslog File    regexp=${Ue_group_full}    alias=syslog1
#    ute_syslog.stop_syslog    alias=syslog1
#    ute_syslog.Collect Syslog Results     destination=${SAVE LOG DIRECTORY}    alias=syslog1
#    run keyword if    '${output3}'=='${True}'    Fail
#    run keyword if    '${output4}'=='${True}'    Fail
#    Common_keywords.Collect Snapshot Log     log_path=${remote_log_path}
#    Check Rollback is needed before sw upgrade
#    Check Enb Rollback is needed before sw upgrade
#    sleep  5min
#    Check GNB On Air And Unexpect Alarm Should Not Exist
#    Check ENB On Air And Unexpect Alarm Should Not Exist
#    power_ue.UE Attach     ue_type=sigspark_multiUE
#
#
#5603152_AVQL_TPUT_KPI_Comparsion
#    [Tags]    UE_5G_cell   T284_TOL_5G_KPI
#    [Setup]    TMO_Common_Case_Setup_Kpi    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
#    Check Rollback is needed before sw upgrade
#    Check Enb Rollback is needed before sw upgrade
#    Check TMO Gnb Ready And All Cell On Air
#    Verify All Enbs Cell On Air
#    ${case_time}=    Get Current Date    result_format=%Y%m%d%H%M%S
#    ${spark_ue_logpath} =   Catenate    SEPARATOR=_   ${spark_ue_logpath}   ${case_time}
#    ${spark_ue_logname} =   Catenate    SEPARATOR=_   ${target_version}   ${case_time}
#    Set Test Variable   ${spark_ue_logname}
#    Set Test Variable   ${spark_ue_logpath}
#    Commission SCF with gnb version
#    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
#    Update Parameter to prepare L3 call    para_value=false
#    ...                                   enb_index=${fdd_enb_index}
#    Update The Prach Index    cell_index=${PCELL_INDEX}    prach_index=9
#    Update_TMO_3CC_Configration    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
#    Change cellBarred Parameter Value On Gnb    pcell_index=${PCELL_INDEX}    exp_status=notBarred
#    Get KPI Report with difference RSRP in 15min    folder_index=1     good=good_avql    mid=mid_avql    bad=bad_avql
#    ...                                             spark_ue_logpath=${spark_ue_logpath}
#    Gnb And All Enb Upgrade
#    sleep   10min
#    Run Keyword And Continue On Failure       Check GNB On Air And Unexpect Alarm Should Not Exist
#    Run Keyword And Continue On Failure       Check ENB On Air And Unexpect Alarm Should Not Exist
#    Get KPI Report with difference RSRP in 15min    folder_index=2       good=good_avql    mid=mid_avql    bad=bad_avql
#    ...                                             spark_ue_logpath=${spark_ue_logpath}
#    Commission SCF with gnb version
#    Update Parameter to prepare L3 call    para_value=false
#    ...                                   enb_index=${fdd_enb_index}
#    Update_TMO_3CC_Configration    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
#    Update The Prach Index    cell_index=${PCELL_INDEX}    prach_index=9
#    Change cellBarred Parameter Value On Gnb    pcell_index=${PCELL_INDEX}    exp_status=notBarred
#    Get KPI Report with difference RSRP in 15min    folder_index=3      good=good_avql    mid=mid_avql    bad=bad_avql
#    ...                                             spark_ue_logpath=${spark_ue_logpath}
#    ${exportReport_pc_logpath_windows}    ${exportReport_pc_logpath_cygwin}    Create ExportReport logpath in UE control PC
#    ${pc_logpath_23R4_GA}    ${pc_logpath_cu_version_0}    ${pc_logpath_cu_version_1}    Create result file path to server PC
#    ...                                                    pc_logpath=${exportReport_pc_logpath_cygwin}
#    Run Keyword And Continue On Failure    Procedures.Start UE Prepare    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
#    ...                                                                   ue_type=${ue_type}
#    ...                                                                   get_spark_license=False
#    Spark signal Ue ExportReport with Logfiles    ue_logname=${spark_ue_logname}
#    ...                                           ue_logpath=${spark_ue_logpath}
#    ...                                           ReportName=${ReportName_ue_kpi}
#    ...                                           ReportGenerationPath=${exportReport_pc_logpath_windows}
#    ...                                           ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
#    Run Keyword If   '${tl_prefix}'!='T080'       Spark multiUE ExportReport result to server PC
#    ...                                           ExportReport_path_cygwin=${exportReport_pc_logpath_cygwin}
#    ...                                           ExportReport_path_windows=${exportReport_pc_logpath_windows}
#    Spark signal Ue ExportReport with Logfiles    ue_logname=${spark_ue_logname}
#    ...                                           ue_logpath=${spark_ue_logpath}
#    ...                                           ReportName=${ReportName_ue_DL_kpi}
#    ...                                           ReportGenerationPath=${exportReport_pc_logpath_windows}
#    ...                                           ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
#    Run Keyword If   '${tl_prefix}'!='T080'       Spark multiUE ExportReport result to server PC
#    ...                                           ExportReport_path_cygwin=${exportReport_pc_logpath_cygwin}
#    ...                                           ExportReport_path_windows=${exportReport_pc_logpath_windows}
#    ${filepath_in_ute_3052_0} =   Catenate    SEPARATOR=/   ${TS_CASE_LOG_PATH}   1
#    ${filepath_in_ute_3052_1} =   Catenate    SEPARATOR=/   ${TS_CASE_LOG_PATH}   2
#    ${filepath_in_ute_3052_2} =   Catenate    SEPARATOR=/   ${TS_CASE_LOG_PATH}   3
#    Upload result file from ute to server PC   filepath_in_ute_3052_0=${filepath_in_ute_3052_0}   pc_logpath_23R4_GA=${pc_logpath_23R4_GA}
#    Upload result file from ute to server PC   filepath_in_ute_3052_1=${filepath_in_ute_3052_1}   pc_logpath_cu_version_0=${pc_logpath_cu_version_0}
#    Upload result file from ute to server PC   filepath_in_ute_3052_2=${filepath_in_ute_3052_2}   pc_logpath_cu_version_1=${pc_logpath_cu_version_1}
#    Update Parameter to prepare L3 call    para_value=true   qRxLevMin=-52   enb_index=${fdd_enb_index}
#    Gnb And All Enb Rallback
#    sleep   600s
#    [Teardown]    Run Keyword And Ignore Error    TMO_Common_Case_Teardown_kpi    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
#    ...                                           ue_type=${ue_type}


5603052_AEHC_cell_edge_case005_SA_RSRP_near_mid_far condition KPI_comparison_with RACHindex9_RACHindex206
    [Tags]    UE_5G_cell   T284_TOL_5G_KPI
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
    ...    all_pa_trun_off=${True}
#    Backup and Modify swconfig file    swconfig_modify=@{wireshark_flag}
#    Perform gNB Reset site and Wait Onair
    ${report_timestamps_target_build}     KPI_Report_Case.Test Procedures For Multi Rounds
    ...                                   case_test_procedure_kw=TestCase.Reproduce_5603052
    ...                                   rounds=3
    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}
    Run Keyword And Continue On Failure     Generate Scout KPI Report For Target Build
    ...     report_timestamps_target_build=${report_timestamps_target_build}
    ...     gnb_index=${0}
    ...     kpi_report_filter_distnames=bts,NRCELL-301,NRCELL-311
    Check Rollback is needed before sw upgrade    active_sw_flag=Low
    ...                                           gnb_index=${0}
#    Backup and Modify swconfig file    swconfig_modify=@{wireshark_flag}
#    Perform gNB Reset site and Wait Onair
    ${report_timestamps_source_build}    Run Keyword And Continue On Failure    KPI_Report_Case.Test Procedures For Multi Rounds
    ...                                    case_test_procedure_kw=TestCase.Reproduce_5603052
    ...                                    rounds=3
    Run Keyword And Continue On Failure    Generate Scout KPI Report For Source Build
    ...    report_timestamps_source_build=${report_timestamps_source_build}
    ...    gnb_index=${0}
    ...    kpi_report_filter_distnames=bts,NRCELL-301,NRCELL-311
    #------Generate Comparator Report On Compass---------------#
    Run Keyword And Continue On Failure    Generate Comparator Report On Compass And Record To Server
    ...    report_timestamps_target_build=${report_timestamps_target_build}
    ...    report_timestamps_source_build=${report_timestamps_source_build}
    ...    gnb_index=${0}
    ...    comparator_filter_distnames=NRCELL-301,NRCELL-311,BTS
    ...    kpi_report_filter_distnames=bts,NRCELL-301,,NRCELL-311
    [Teardown]   Run Keywords    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}    AND
    ...    TMO_Common_Case_Teardown    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}     AND
    ...    csn.reset_cache