*** Settings ***
Documentation
...   Author: xiaowei.1.chen@nokia-sbell.com
...   Contact: xiaowei.1.chen@nokia-sbell.com
...   Description: This user scenario describes

Suite Setup       Common Suite Setup For RRM
Test Setup        Common Test Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Teardown     Common Test Teardown For RRM

Test Timeout    120 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot

*** Variables ***
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
${analysis_dict_1}    filter_conditions=ngap.InitialContextSetupResponse_element.radioNetwork == not-supported-5QI-value
*** Test Cases ***
Case_Precondition
    Case Precondition
wireshark
    Start Collect Wireshark For GNB
    sleep   300s
    Stop Wireshark log For GNB
TTI
    Start TTI For GNB
    sleep   300s
    Stop TTI For GNB
Update dcap
    start_dcap_controller_common
*** Keywords ***
Case Precondition
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=CB008118_RJIO
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
    ...                   customer=RJIO
#    [Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
#    ...                                 tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s
Update dcap
    log_to_console     Plugin download
    start_dcap_controller_common
Start Collect Wireshark For GNB
    ${wireshark_argument}   Create Dictionary   wireshark_options=-i any
    ${dict_argument}   Create Dictionary   argument=${wireshark_argument}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}
    sleep     5s
Stop Wireshark log For GNB
    ${local_file_path}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${0}
    [Return]    ${local_file_path}
Analyze Wireshark log
    ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict_1}
    Log To Console    \nAnalyze log: ${result}
Start TTI For GNB
    start_dcap_controller_common
    ${dcap_argument}   Create Dictionary   nrCells=NRCELL_R-1
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    Log Collection    start    tti    product_type=gnb    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}
Stop TTI For GNB
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=gnb    bts_index=${0}    cudu_index=${0}