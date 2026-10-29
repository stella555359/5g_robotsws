*** Settings ***
Documentation
...    author: Ming Shi
...    contact:ming.shi@nokia-sbell.com
...    squad group: 5G_PZ_HZ_3_SG
...    feature : TMO_Non_Feature

Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup
...                            AND    check SA or NSA suite name
...                            AND    FDD_TMO_common_keyword_new.Common Suite Setup for COAM
...                            AND    Prepare the gnb commission for SFE GNB1    SCF_name=${SCF_name}    cell_type=${cell_type}
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
...                            AND    Run Keyword And Ignore Error    Save snapshot Teardown for SFE    connection=GNB_OAM    gnb_index=0
...                            AND    Get bts package version
...                            AND    sleep    15min
...                            AND    generate new report and get report id    file_path=${KPI_templet_path}
...                               report_name=${report_name}_${package_version}    tl_id=${tl_id}    check_out_entry=${check_out_entry}
...                               package_version=${package_version}    start_time=${start_time}    end_time=${end_time}
#...                            AND    Run Keyword And Ignore Error    Crawling and download kpi data   file_path=${excel_kpi_path}
#...                               report_id=${report_id}    file_name=${report_name}_${package_version}    tl_id=${tl_id}
...                            AND    download_kpi_file      report_id=${report_id}    path=${excel_kpi_path}
...                            AND    Run Keyword If Any Tests Failed    Teardown for case failure


Resource    ../Resources/FDD_TMO_common_keyword_new.robot
Resource    ../Resources/TDD_FDD_HO_common_keyword_new.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/SFE_TMO_common_keywords.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/HBTE_PA_setting_375.py


*** Variables ***
@{pm_all_list}
${atten_ip}    ${tl.attenuator[0].ip_addr}     #atten1
${atten_ip2}    ${tl.attenuator[1].ip_addr}    #atten2
${att_api_port}    ${tl.attenuator[0].port}
${max_attenuation_value}    ${127}
${vendor}    ${tl.attenuators[0].vendor}
${cell_type}    SA
${ue_type}    samsung
${SCF_name}    GNB1_SA_SCF.xml
${tl_id}    375
${file_path}    /opt/workspace/SCF/
${KPI_templet_path}    /opt/workspace/SCF/03856857_kpi_report.yml
${report_name}    TL375_03856857
${excel_kpi_path}    /opt/workspace/SCF/Excel_KPI/
${brust_traffic_path}    /opt/workspace/SCF/
${brust_file_name}    ryan.py
${sh_file_name}    03856857.sh
${check_out_entry}    true
*** Test Cases ***
[1]E2E_Rep_005_03856857_CB008311_5GC000937_PS_BWP_buffer_base_scell_addition_IWK_on_TDD
    [Documentation]   03841043_03856857_CB008311_5GC000937_Concurrent PS-BWP swtich and scell addtion_IWK_On_TDD
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_23R3    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][5]
    multi_all_ues_network_operate    action_index=${0}
    Start brust DL UDP traffic    tl_id=${tl_id}    path=${brust_traffic_path}    file_name=${brust_file_name}
    ...    shell_file_name=${sh_file_name}
    set PA port on one cell    pa_name=${gnb1_cell23_pa_info}    value=${gnb1_cell23_pa_value}[setup][0]
    Prepare with PM counter time to caculate    period=start
    Get record time    label=start
    sleep    20min
    sleep    20min
    Prepare with PM counter time to caculate    period=start
    Get record time    label=end
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND    Stop brust DL UDP traffic    tl_id=${tl_id}   sh_file_name=${sh_file_name}
    ...    AND    multi_all_ues_network_operate    action_index=${1}
    ...    AND    PA recover
*** Keywords ***

