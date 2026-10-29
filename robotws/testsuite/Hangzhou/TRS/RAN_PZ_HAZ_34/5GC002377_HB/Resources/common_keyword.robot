*** Settings ***
Documentation    author: Jerry Wu
...              Group: HGZ_MMW02
...              contact: jerry.wu@nokia-sbell.com
...              Description
Resource          ../../common/robot/common_keyword_2377HB_1913_HA.robot

*** Variables ***
${testline_name}      null
${CONFIGURATION}      null


*** Keywords ***
Commission_CU_DU   
    [Documentation]    Author: Wu Jerry
    ...                Description: do cu and du commission
    Cloud DU connect to gnb coam via ssl
    ${TL_NAME}    set variable if    '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}    Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches    ${TL_NAME}    ${pattern}    1
    ${testlinename}    Set Variable    7_5${TLNAME}[0]
    COAM Commission with scf file    
    ...    scf_file_path=${CURDIR}/../../../../commissionings/HGZ/${testlinename}/SCF_0.190_DU.xml
    ...    is_pdl_checking_needed=${False}
    ...    timeout=600
    CU Full Commission    
    ...    path_of_commission_file=${CURDIR}/../../../../commissionings/HGZ/${testlinename}/SCF_0.190_CU.xml
    wait until keyword succeeds    25 min    10 sec    COAM Check GNB cell on air
    COAM Teardown gnb connections
