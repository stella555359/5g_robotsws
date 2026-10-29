*** Settings ***
Documentation
...   author: chris.l.cao@nokia-sbell.com
...   contact: chris.l.cao@nokia-sbell.com
...   Description: This case is collect log when case result is failure

Suite Setup       AiC Common Suite Setup
Suite Teardown    AiC Common Suite Teardown

Resource    ../aic_common_resources.robot


Test Timeout    20 minutes

*** Variables ***
${vdu_index}   0
${gnb_index}   0
${agent_flag_file}   ${EMPTY}
${active_alarm_file}  ${EMPTY}
${historical_alarm_file}   ${EMPTY}

*** Test Cases ***
#logs
#    [Setup]   Case Test Setup
#    [Teardown]   Case Test Teardown
#    Step1: Collect Log
#    Step2: Set Agent Flag
#    Step3: Collect Alarm


#set_agent_flag
#    [Setup]   Case Test Setup
#    [Teardown]   Case Test Teardown
#    Step2: Set Agent Flag
#    Step3: Collect Alarm

Dummy Test Case
    [Documentation]    This is a dummy TC
    Log To Console    Running dummy test case...
    Should Be Equal    1    1

*** Keywords ***
Step1: Collect Log
    run keyword and ignore error    VDU Rest Login
    ${r}  ${operation_id}=   run keyword and ignore error  vdu.trigger local snapshot
    run keyword and ignore error   Collect VDU Describe PODs Log   vdu_index=${vdu_index}  gnb_index=${gnb_index}
    run keyword and ignore error   Collect vDU Kubectl Logs   vdu_index=${vdu_index}  #gnb_index=${gnb_index}
    run keyword and ignore error   Collect VDU Infrastructure Log
    ${mypath}   Get A Directory  snapshot_teardown
    run keyword if   '${r}'=='PASS'    run keyword and ignore error
    ...  vdu.check local snapshot status and save it    ${mypath}   ${operation_id}


Step2: Set Agent Flag
    Set Agent Flag By TA Utility   agent_flag_file=${agent_flag_file}


Step3: Collect Alarm
    run keyword and ignore error   VDU Save Active Alarm To A File   file_name=${active_alarm_file}   vdu_index=${vdu_index}
    run keyword and ignore error   VDU Save Historical Alarm To A File   file_name=${historical_alarm_file}   vdu_index=${vdu_index}


Case Test Setup
    Log To Console   ta_utility: Case Test Setup
    set test variable    ${UTE_SSH_IP}    ${tl.test_pc.default_ssh_connection_details.addr}
    set test variable   ${UTE_SSH_USER_NAME}  ${tl.test_pc.default_ssh_connection_details.username}
    set test variable   ${UTE_SSH_PASSWORD}     ${tl.test_pc.default_ssh_connection_details.password}

    _Create Logs Folder For Test Case
    #run keyword and ignore error    _Set Pod And Container Name Prefix
    set_vdu_pod_container_suite_variables

    #${vcu_nf_type}   Get VCU NF Type
    #run keyword if  "${vcu_nf_type}"=="CNF"   Run Keyword And Ignore Error   _VCU CNF Environment WA
    # run keyword if  "${vcu_nf_type}"=="CNF"   _Set CU Pod And Container Name Prefix


Case Test Teardown
    Log To Console   ta_utility: Case Test Teardown
    Run Keyword And Ignore Error  Disconnect All SSH Connections
    Run Keyword And Ignore Error  Vdu Rest Logout
    Run Keyword And Ignore Error  CU Rest Logout
