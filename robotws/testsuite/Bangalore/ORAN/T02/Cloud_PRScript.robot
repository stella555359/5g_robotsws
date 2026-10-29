*** Settings ***

Documentation
...   author: Rubina Nath
...   contact: rubina.nath@nokia.com
...   Description: PR finding in Cloud

Library     SSHLibrary
Library     BuiltIn
Library     String
Library     DateTime
Library     Collections
Library     OperatingSystem     WITH NAME    os
Library     taf.selenium.sbts  WITH NAME   sel
Library     taf.gnb.oam.coam.vdu    WITH NAME    admindu
Library     taf.gnb.oam.coam.cu    WITH NAME    admincu
Suite Setup		        Suite_Setup
Test Setup	            Test Setup
Test Teardown           Run Keywords    Test_Teardown
Suite Teardown		    Suite Teardown
Resource                testsuite/Bangalore/ORAN/T02/resources/robot/CloudKeywords.robot

*** Variables ***

${host_vDU}    10.58.230.100
${host_vCU}    10.58.230.102
${PORT}        443
${USER}        Nemuadmin
${PWD}         Nokia@123
${BTS_path}=    /home/ute/logs
${vDU_NODE_HOST}        10.41.31.130
${vDU_NODE_USER}        core
${vDU_NODE_PASSWORD}    system123
${vDU_NAMESPACE}        cran30026
${dist_name}            MRBTS-30026
${webem_addr}           10.43.196.131
${webem_username}       Nemuadmin
${webem_password}       Nokia@123
${remote_username}      test1
${timeout}              100
${loop}=                10

*** Test Cases ***

VDUReset
    [Documentation]    VDU_Reset_5times
    [Tags]    test1

    FOR    ${i}    IN RANGE    1    ${loop}
        ResetVdu
        Wait until keyword succeeds    10m    30s    Check vDU Cell status
        IF    "${i}" == "1"
             os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/
             Snapshot_vDU    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/
             Snapshot_vCU    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/
        END
    END
    Log to console    End of test

VCUReset
    [Documentation]    VCU_Reset_5times
    [Tags]    test2

    FOR    ${i}    IN RANGE    1    ${loop}
        ResetVcu
        Wait until keyword succeeds    10m    30s    Check vDU Cell status
        IF    "${i}" == "1"
             os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/
             Snapshot_vDU    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/
             Snapshot_vCU    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Iteration${i}/
        END
    END
    Log to console    End of test