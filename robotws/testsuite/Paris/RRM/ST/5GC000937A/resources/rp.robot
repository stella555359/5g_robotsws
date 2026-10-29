*** Keywords ***
Report test result to reporting portal
     [Arguments]    ${log_dir}    ${gnb_id}=${0}
     ${tsResult}=    Set variable if    "${TEST_STATUS}"=="PASS"    passed    failed
     ${isForDebugging}=    Set variable if    "${TEST_STATUS}"=="PASS"    no    yes
     ${rest}    ${suiteName}=    Split string from right    ${SUITE_SOURCE}    separator=/    max_split=1
     ${qcFile}=    Replace string using regexp    ${suiteName}   \[0-9]*?.robot    .qc
     ${qcFilePath}=    Set variable    ${rest}/${qcFile}
     ${qcFilePath}=    Replace string using regexp    ${qcFilePath}    .*testsuite    testsuite
     reporting.Online Reporting to ReP    tcName=${TEST_NAME}    tsResult=${tsResult}    resultDir=${log_dir}    isForDebugging=${isForDebugging}
     ...    qcFilePath=${qcFilePath}    gnb_id=${gnb_id}
