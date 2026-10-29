*** Settings ***
Documentation    CI collection keywords, handle CI required test env info collections.
...              Please do not modify the file without notification to author
...              Author: Civen Chen
...              Contact: civen.chen@nokia-sbell.com
Library    testsuite.Timisoara.Handover.CBRS.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.GnbAlarmAnalyzer    WITH NAME    GnbAlarmAnalyzer
Library
...  testsuite.Timisoara.Handover.CBRS.Hangzhou.resources.RAN_PZ_HAZ_34.robot.CI_Operations.CI_analyzation.RobotCaseInfo  WITH NAME  RobotCaseInfo
Library    testsuite.Timisoara.Handover.CBRS.Hangzhou.resources.RAN_PZ_HAZ_34.python.scf.scf_analysis.ScfAnalysis    WITH NAME    scfas
Library    taf.selenium.sbts    WITH NAME    selenium_coam
Resource   ../coam_gnb_classical.robot



*** Keywords ***
CI_collection.Collect_execution_info
    [Documentation]    keyword to collect alarm and report to DB.
    [Arguments]    ${ru_power}    ${connection}=GNB_OAM    ${gnb_index}=0
#    ${active_alarms}    ${history_alarms}    gnb_alarm.Get alarms from Gnb    connection=${connection}    gnb_index=${gnb_index}
#    ${active_alarms}    ${history_alarms}    gnb_alarm.Get alarms from Gnb    connection=${connection}    gnb_index=${gnb_index}
#    ${alarm_result}    GnbAlarmAnalyzer.analysis_active_alarms    alarms=${active_alarms}
#    ...                                                           case_name=${TEST NAME}
#    ${history_result}    GnbAlarmAnalyzer.analysis_history_alarms    alarms=${history_alarms}
#    ...                                                              case_name=${TEST NAME}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run keyword if    ${has_cbts}
    ...            Wait Until Keyword Succeeds    5min    30s    coam_gnb_classical.Cloud DU connect to gnb coam via ssl
    ...    ELSE    Wait Until Keyword Succeeds    5min    30s    coam_gnb_classical.Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${scf_path}    Wait Until Keyword Succeeds    2min    10s    COAM Download scf from cluster    scf_dir_path=${OUTPUT_DIR}
    ${cell_list}    testsuite.Timisoara.Handover.CBRS.Hangzhou.resources.RAN_PZ_HAZ_34.robot.bts.common.admin_operation.get_all_cell_id_via_admin
    ...    connection=${connection}
    scfas.setup    scf_path=${scf_path}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${technology_cells_dict}    get_cell_ids_based_on_cell_technology    connection_alias=${connection}
    ${get_tdd_cells_mapping}    RobotCaseInfo.get_technology_cells_mapping    cell_mapping=${cell_mapping}
    ...    technology_cells_dict=${technology_cells_dict}    technology=TDD
    ${cell_info_list}    scfas.generate_cell_info_list_from_scf    cell_mapping=${get_tdd_cells_mapping}
    ${lte_cell_info}  testsuite.Timisoara.Handover.CBRS.Hangzhou.resources.RAN_PZ_HAZ_34.robot.bts.common.admin_operation.get_lte_cell_data_via_admin
    ...                      connection=${connection}
    coam.teardown    connection=${connection}
    RobotCaseInfo.add_scf_data    cell_info_list=${cell_info_list}    lte_cell_info_list=${lte_cell_info}
#    RobotCaseInfo.add_alarm_report_data    alarms=${alarm_result}    history=${history_result}
    RobotCaseInfo.get_execution_info
    RobotCaseInfo.report    ta_status=${TEST STATUS}    ru_power=${ru_power}    case_name=${TEST NAME}
