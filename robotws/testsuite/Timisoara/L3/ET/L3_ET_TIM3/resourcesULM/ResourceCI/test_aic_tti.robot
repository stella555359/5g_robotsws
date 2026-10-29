*** Settings ***

Documentation   testsuite for TTI AiC gNB KWs

Resource        ../aic_tti.robot
Resource        ../testline.robot
Resource        ../gnb.robot

Suite Setup     Set Skip Tag If Not AiC TL

*** Test Cases ***

Test start and stop TTI trace
    Skip If Not AiC TL
    Start To Collect TTI Trace On AIC
    sleep  60s
    Stop And Download TTI Trace On AIC  /tmp/


Test Get Node Deployment Type for AiC
    Skip If Not AiC TL
    ${gnb_type}     Get Node Deployment Type
    Log To Console  \ngnb_type: '${gnb_type}'
    should be equal as strings  ${gnb_type}  aic

Test Get Pods Info
    Skip If Not AiC TL
    Get Pods Info

Test Get DU Cell Summary
    Skip If Not AiC TL
    Get DU Cell Summary

Test Get DU SW Version
    Skip If Not AiC TL
    Get DU SW Version

Test Get DU current plan file
    Skip If Not AiC TL
    ${result}=  Get DU current plan file
    file should exist  ${result}

Test Get CU SW Version
    Skip If Not AiC TL
    Get CU SW Version

Test Get CU current plan file
    Skip If Not AiC TL
    ${result}=  Get CU current plan file
    file should exist  ${result}

Test Get gNB SW Version
    Skip If Not AiC TL
    ${result}=  Get gNB SW Version
    Log To Console  ${result}

Test Get SCF from Gnb DU
    Skip If Not AiC TL
    ${result}=  gnb.Get SCF from gNB
    file should exist  ${result}

Test Get SCF from Gnb CU
    Skip If Not AiC TL
    ${result}=  gnb.Get SCF from gNB  component=CU
    file should exist  ${result}


*** Keywords ***
Set Skip Tag If Not AiC TL
    Run Keyword If   '${tl_info.deployment_type()}'!='aic'  Run Keywords
    ...         Log To Console  Test suite isn't applicable for '${tl_info.deployment_type()}' !
    ...   AND   Set Tags    SKIP
    gnb.Get SCF from gNB
    gnb.Get SCF from gNB  component=CU

Skip If Not AiC TL
    Pass Execution If   'SKIP' in @{TEST TAGS}  Test is only applicable for AiC!
