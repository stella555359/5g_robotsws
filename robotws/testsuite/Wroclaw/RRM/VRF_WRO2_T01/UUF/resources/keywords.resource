*** Settings ***
Documentation  Utility keywords for CSV4ALL test suites purposes.
...            To avoid copiyng keywords between files please add here reused UUF extensions / keywords.

*** Keywords ***
Set Tester Name
    run keyword if  '${tester_name}'!='${None}'
    ...  set global variable  ${rep_comment}  ${rep_comment}_${tester_name}

Check current testline setup
    [Arguments]     ${TL_type}
    Run Keyword If    '${TL_type}' == 'NSA'
        ...    Set Suite Variable    ${FINALNODES}    ${NODES_NSA}
    Run Keyword If    '${TL_type}' == 'SA'
        ...    Set Suite Variable    ${FINALNODES}    ${NODES_SA}
    Run Keyword If    '${TL_type}' == 'MRAT'
        ...    Set Suite Variable    ${FINALNODES}    ${NODES_MRAT}
    Run Keyword If    '${TL_type}' == 'LTE'
        ...    Set Suite Variable    ${FINALNODES}    ${NODES_LTE}
