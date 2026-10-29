*** Settings ***

Library   Process
Resource  ../dcap.robot

Suite Setup  start dcap container
Suite Teardown  stop dcap container

     
*** test cases ***

Test DCAP Emil trace on local gnb without profile argument
    [TAGS]               DCAP    EMIL
    Pass Execution If    'SKIP_DCAP' in $test_tags  dcap not installed, test skipped
    Start DCAP Tracing
    sleep                10s
    Stop DCAP Tracing
    Collect DCAP Traces

Test DCAP Emil trace on local gnb with profile argument
    [TAGS]               DCAP    EMIL
    Pass Execution If    'SKIP_DCAP' in $test_tags  dcap not installed, test skipped
    @{my_profile}        Create List  cp_5g  SCF5g 
    Start DCAP Tracing   custom_profile=${my_profile}
    sleep                10s
    Stop DCAP Tracing
    Collect DCAP Traces

Test DCAP Emil trace on remote gnb
    [TAGS]                DCAP    EMIL
    ${number_of_gnbs}     Get length                 ${tl.gnbs}
    Pass Execution if     ${number_of_gnbs} < ${2}   no second gNB, test skipped
    start dcap container  node_id=1
    ${VM_alias}=          Connect to test pc proxy for node   1
    Pass Execution If     'SKIP_DCAP' in $test_tags  dcap not installed, test skipped
    Start DCAP Tracing    node_id=1
    sleep                 10s
    Stop DCAP Tracing     node_id=1
    Collect DCAP Traces   node_id=1
    stop dcap container   node_id=1
    
