*** Settings ***
Library           Collections
Library           json
Library           OperatingSystem
Library           Process
Library           String
Library           taf.config.scf                        WITH NAME    scf
Library           taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu
Library           taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library           taf.hw.fhgw.cli                       WITH NAME    issh
Library           taf.transport.ssh                     WITH NAME    tafssh
Library           taf.selenium.gnb.oam.coam.cu          WITH NAME    scu
Library           taf.selenium.gnb.oam.coam.vdu         WITH NAME    svdu
Library           taf.nms.nom                           WITH NAME    nom_rest
Library           testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/py_tool/utils.py
Library           testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/py_tool/global_variables.py
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/cu_oam_fm.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_oam_fm.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/variables.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/common_pre_post_condition.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/common_setup_teardown.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_trs_conn.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vran_others.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/nom_oam_cm.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/cu_testline_configuration.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/cu_oam_state.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/cu_oam_cm.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_testline_configuration.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_oam_state.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_oam_cm.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_cloud_deployment.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/nom_testline_configuration.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/common_log.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_log_other.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/kw_to_be_optimized.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/aic_common_resources_new.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Keywords ***
AiC Common Case Setup
    [Teardown]  run keyword and ignore error  disconnect all ssh connections
    [Documentation]  Do some common things for every precondition of cases
    ...              any case should include it in suite setup or test setup
    ...              it will do following actions
    ...              1) kill unexpected process
    ...              2) import static test line variables and convert to readable variables
    ...              3) automatically get some deployment information from test line
    ...              4) add one folder for test cases -- logs, cm files, download files...
    ...              5) backup SCF from test line for traceablity
    ...   *Author*: xianbiao.cheng@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2019-11-15 | xianbiao.cheng | initial creation |
    ...   | 2022-4-6 | hongysun | update documentation |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   None
    ...   *Return*
    ...   None
    ...   *Example*
    ...   | AiC Common Test Setup |
    set test variable   ${AIC_COMMON_TEST_SETUP_EXECUTED_FLAG}    0
#    set test variable    ${UTE_SSH_IP}    ${tl.test_pc.default_ssh_connection_details.addr}
#    set test variable   ${UTE_SSH_USER_NAME}  ${tl.test_pc.default_ssh_connection_details.username}
#    set test variable   ${UTE_SSH_PASSWORD}     ${tl.test_pc.default_ssh_connection_details.password}
    run keyword and ignore error    _Init Nom Server Global Variable
    _Create Logs Folder For Test Case
    run keyword and ignore error  Clear Agent Flag
    run keyword and ignore error  _Delete Core Dump Files
    _Kill Unexpected Process
    set_vdu_pod_container_suite_variables
    ${vcu_nf_type}   Get VCU NF Type
    run keyword if  "${vcu_nf_type}"=="CNF"   Run Keyword And Ignore Error   _VCU CNF Environment WA
    set test variable   ${AIC_COMMON_TEST_SETUP_EXECUTED_FLAG}    1
    run keyword and ignore error    online enable actcli for cu
    run keyword and ignore error    Online Enable actCli For vDU
    Run Keyword And Ignore Error    Get Running Build Number
    robot_common_operations.Common Case Setup
