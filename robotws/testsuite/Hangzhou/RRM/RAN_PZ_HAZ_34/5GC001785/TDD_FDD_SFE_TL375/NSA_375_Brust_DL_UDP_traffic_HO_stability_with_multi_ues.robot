*** Settings ***
Documentation
...    author: Ming Shi
...    contact:ming.shi@nokia-sbell.com
...    squad group: 5G_PZ_HZ_3_SG
...    feature : TMO_Non_Feature

Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup
...                               AND    check SA or NSA suite name
...                               AND    FDD_TMO_common_keyword_new.Common Suite Setup for COAM
...                               AND    get traffic direction and ho times    cell_type=NSA
...                               AND    get value of control parameter
...                               AND    check and prepare the gnb commission for SFE two testline
...                               AND    Get record time    label=start

Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
#...                              AND    check hanging resource
...                               AND    change AMF status
...                               AND    Run Keyword And Ignore Error    Save snapshot Teardown for SFE    connection=GNB_OAM    gnb_index=0
...                               AND    Get record time    label=end
...                               AND    Get bts package version
...                               AND    sleep    15min
...                               AND    generate new report and get report id    file_path=${path}    report_name=${report_name}
...                               tl_id=${tl_id}     package_version=${package_version}    start_time=${start_time}    end_time=${end_time}
...                               AND    Run Keyword And Ignore Error    Crawling and download kpi data   file_path=${excel_kpi_path}
...                               report_id=${report_id}    file_name=${report_name}_${package_version}    tl_id=${tl_id}
#...                               AND    download_kpi_file      report_id=${report_id}    path=${excel_kpi_path}
...                               AND    Run Keyword If Any Tests Failed    Teardown for case failure

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
${interval}    12
${pa_settime}    0.6
${paerror_counter}    0
${ANR_ho_times}    10
${DL_traffic_send}    2M
${UL_traffic_send}    1M
${ue_type}    samsung
${path}    /opt/workspace/SCF/NSA_kpi_report.yml
${report_name}    TL375_NSA
${tl_id}    375
${excel_kpi_path}    /opt/workspace/SCF/Excel_KPI/
${brust_traffic_path}    /opt/workspace/SCF/
${brust_file_name}    ryan.py
${sh_file_name}    5GC007835_NSA.sh
*** Test Cases ***
[1]CB007835_5G_A_007_NSA_intragnb_intrafre_FDD_HO_FDD_1094_stability
    [Documentation]    CELL1-CELL3 Intra F (FDD-FDD) intra gnb HO
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_23R3    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
    ...    cell_type=NSA
    set PA port on one cell    pa_name=${enb1_cell11_pa_info}    value=${enb1_cell11_pa_value}[setup][0]
    multi_all_ues_network_operate    action_index=${0}
    Start brust DL UDP traffic    tl_id=${tl_id}    path=${brust_traffic_path}    file_name=${brust_file_name}
    ...    shell_file_name=${sh_file_name}
    Adjust_HBTE_PA with loop    pa_name=${gnb1_cell3_pa_info}    s_value=${gnb1_cell3_pa_value}[setup][1]
    ...    e_value=${gnb1_cell3_pa_value}[setup][2]    step=${gnb1_cell3_pa_info}[step][0]    ho_times=${ho_times}
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    Stop brust DL UDP traffic    tl_id=${tl_id}   sh_file_name=${sh_file_name}
    ...    AND    multi_all_ues_network_operate    action_index=${1}
    ...    AND    PA recover

[1]CB007835_5G_A_008_NSA_intergnb_interfre_FDD_HO_TDD_1095_stability
    [Documentation]    CELL1-CELL441 Inter F(FDD-TDD) intra gnb HO
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_23R3    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][2]
    ...    cell_type=NSA
    set PA port on one cell    pa_name=${enb1_cell11_pa_info}    value=${enb1_cell11_pa_value}[setup][0]
    multi_all_ues_network_operate    action_index=${0}
    Start brust DL UDP traffic    tl_id=${tl_id}    path=${brust_traffic_path}    file_name=${brust_file_name}
    ...    shell_file_name=${sh_file_name}
    Adjust_HBTE_PA with loop    pa_name=${gnb2_cell441_pa_info}    s_value=${gnb2_cell441_pa_value}[setup][1]
    ...    e_value=${gnb2_cell441_pa_value}[setup][2]    step=${gnb2_cell441_pa_info}[step][0]    ho_times=${ho_times}
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    Stop brust DL UDP traffic    tl_id=${tl_id}   sh_file_name=${sh_file_name}
    ...    AND    multi_all_ues_network_operate    action_index=${1}
    ...    AND    PA recover

[1]CB007835_5G_A_009_NSA_intragnb_interfre_FDD_HO_TDD_1095_stability
    [Documentation]    CELL1-CELL301 Inter F(FDD-TDD) intra gnb HO
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_23R3    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][1]
    ...    cell_type=NSA
    set PA port on one cell    pa_name=${enb1_cell11_pa_info}    value=${enb1_cell11_pa_value}[setup][0]
    multi_all_ues_network_operate    action_index=${0}
    Start brust DL UDP traffic    tl_id=${tl_id}    path=${brust_traffic_path}    file_name=${brust_file_name}
    ...    shell_file_name=${sh_file_name}
    Adjust_HBTE_PA with loop    pa_name=${gnb1_cell301_pa_info}    s_value=${gnb1_cell301_pa_value}[setup][1]
    ...    e_value=${gnb1_cell301_pa_value}[setup][2]    step=${gnb1_cell301_pa_info}[step][0]    ho_times=${ho_times}
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    Stop brust DL UDP traffic    tl_id=${tl_id}   sh_file_name=${sh_file_name}
    ...    AND    multi_all_ues_network_operate    action_index=${1}
    ...    AND    PA recover

[1]CB007835_5G_A_010_NSA_intergnb_intrafre_TDD_HO_TDD_573_stability
    [Documentation]    CELL301<-->CELL441 intra F (TDD-TDD) inter gnb HO via Xn
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_23R3    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][0]
    ...    cell_type=NSA
    set PA port on one cell    pa_name=${enb1_cell11_pa_info}    value=${enb1_cell11_pa_value}[setup][0]
    multi_all_ues_network_operate    action_index=${0}
    Start brust DL UDP traffic    tl_id=${tl_id}    path=${brust_traffic_path}    file_name=${brust_file_name}
    ...    shell_file_name=${sh_file_name}
    Adjust_HBTE_PA with loop    pa_name=${gnb2_cell441_pa_info}    s_value=${gnb2_cell441_pa_value}[setup][1]
    ...    e_value=${gnb2_cell441_pa_value}[setup][2]    step=${gnb2_cell441_pa_info}[step][0]    ho_times=${ho_times}
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    Stop brust DL UDP traffic    tl_id=${tl_id}   sh_file_name=${sh_file_name}
    ...    AND    multi_all_ues_network_operate    action_index=${1}
    ...    AND    PA recover

[1]CB007835_5G_A_013_NSA_interenb_interfre_FDD_HO_FDD_574_stability
    [Documentation]    Ecell1_Gcell5<-->Ecell2_Gcell5 Inter F(TDD-TDD) intra gnb HO via Xn
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_23R3    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
    ...    cell_type=NSA
    set PA port on one cell    pa_name=${enb1_cell11_pa_info}    value=${enb1_cell11_pa_value}[setup][0]
    multi_all_ues_network_operate    action_index=${0}
    Start brust DL UDP traffic    tl_id=${tl_id}    path=${brust_traffic_path}    file_name=${brust_file_name}
    ...    shell_file_name=${sh_file_name}
    Adjust_HBTE_PA with loop    pa_name=${enb2_cell24_pa_info}    s_value=${enb2_cell24_pa_value}[setup][1]
    ...    e_value=${enb2_cell24_pa_value}[setup][2]    step=${enb2_cell24_pa_info}[step][0]    ho_times=${ho_times}
    set PA port on one cell    pa_name=${enb2_cell24_pa_info}    value=${enb2_cell24_pa_value}[max]
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    Stop brust DL UDP traffic    tl_id=${tl_id}   sh_file_name=${sh_file_name}
    ...    AND    multi_all_ues_network_operate    action_index=${1}
    ...    AND    PA recover

[1]CB007835_5G_A_014_NSA_intraenb_interfre_FDD_HO_FDD_575_stability
    [Documentation]    CB007835_5G_A_013_NSA_interenb_interfre_FDD_HO_FDD_574_stability
    ...                Ecell1_Gcell5<-->Ecell3_Gcell5 Inter F(TDD-TDD) intra gnb HO via Xn
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_23R3    CRT_23R4
    [Setup]
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
    ...    cell_type=NSA
    set PA port on one cell    pa_name=${enb1_cell11_pa_info}    value=${enb1_cell11_pa_value}[setup][0]
    multi_all_ues_network_operate    action_index=${0}
    Start brust DL UDP traffic    tl_id=${tl_id}    path=${brust_traffic_path}    file_name=${brust_file_name}
    ...    shell_file_name=${sh_file_name}
    Adjust_HBTE_PA with loop    pa_name=${gnb1_cell23_pa_info}    s_value=${gnb1_cell23_pa_value}[setup][3]
    ...    e_value=${gnb1_cell23_pa_value}[setup][4]    step=${gnb1_cell23_pa_info}[step][0]    ho_times=${ho_times}
   [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    Stop brust DL UDP traffic    tl_id=${tl_id}   sh_file_name=${sh_file_name}
    ...    AND    multi_all_ues_network_operate    action_index=${1}
    ...    AND    PA recover

*** Keywords ***


