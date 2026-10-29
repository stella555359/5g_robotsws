*** Settings ***
Documentation
...    Author: Yang mengli
...    Email address: mengli.yang@nokia-sbell.com
...    Maintainer: Yang mengli
...    Email address: mengli.yang@nokia-sbell.com
...    Common KWs related to Airphone.
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guidelines for user: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/10.+Module+of+Airphone+Operation
...    Examples: https://wrgitlab.int.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test

Resource          ./library/_Airphone_Operation.robot

*** Keywords ***
Airphone Operation
    [Arguments]    ${operation}    ${product_type}    ${traffic_info_dic}=${None}     ${cmd}=${None}    ${ap_build}=${None}
    ...            ${pass_regexp}=${None}    ${timeout}=1200s    ${tag}=${None}    ${eth_config_path}=${None}    ${customer}=${None}
    Log    ${timeout} is not used
    ${result}    Run Keyword If
    ...                 '${operation}' == 'env_setup_sa' or '${operation}' == 'env_setup_nsa' or '${operation}' == 'env_setup_sansa'
    ...                                                                       Module Setup Ap Env
    ...                                                                       operation=${operation}
    ...                                                                       product_type=${product_type}
    ...                                                                       tag=${tag}
    ...                                                                       customer=${customer}
    ...    ELSE IF   '${operation}' == 'swconfig'    Airphone Replace Swconfig For Gnb and AP    tag=${tag}
    ...    ELSE IF    '${operation}' == 'wts'    Module Airphone Config Cfg    operation=${operation}
    ...                                                                        tag=${tag}
    ...    ELSE IF    '${operation}' == 'edaemon_egate_setup'    Module Airphone Edaemon Egate Setup    edaemon_port=22222    egate_port=20000
    ...    ELSE IF    '${operation}' == 'edaemon_egate_teardown'    Module Airphone Edaemon Egate Teardown
    ...    ELSE IF    '${operation}' == 'attach'    Module AP Attach    traffic_info_dic=${traffic_info_dic}
    ...    ELSE IF    '${operation}' == 'start_traffic'      Module AP Start Traffic
    ...                                                      traffic_info_dic=${traffic_info_dic}
    ...    ELSE IF    '${operation}' == 'stop_traffic'    Module AP Stop Traffic    traffic_info_dic=${traffic_info_dic}
    ...    ELSE IF    '${operation}' == 'check_traffic'    Check Traffic Tput    traffic_info_dic=${traffic_info_dic}
    ...    ELSE IF    '${operation}' == 'detach'    Module AP Detach    traffic_info_dic=${traffic_info_dic}
    ...    ELSE IF    '${operation}' == 'aplog'    Module Collect AP Logs
    ...    ELSE IF    '${product_type}'== 'enb'     fail    msg=the current ENB doesn't support Airphone
    ...    ELSE IF    '${operation}' == 'send_common_command'    Module Send AP Common Command    cmd=${cmd}
    ...                                                                                           pass_regexp=${pass_regexp}
    ...    ELSE IF    '${operation}'== 'local_ap_upgrade'     Module Local AP Upgrade    eth_config_path=${eth_config_path}
    ...                                                                                  ap_build=${ap_build}
    ...    ELSE IF    '${operation}' == 'eth_config'    Config Eth Interface    eth_config_path=${eth_config_path}
    [Return]    ${result}
