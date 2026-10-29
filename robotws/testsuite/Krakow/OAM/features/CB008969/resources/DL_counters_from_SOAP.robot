*** Settings ***
Documentation
...          author/contact: Elzbieta Tatoj / elzbieta.tatoj@nokia.com
...          maintainer/contact: Jaroslaw Lezon / jaroslaw.lezon@nokia.com
...          Feature CB008969 Check DL counters from SOAP messages


Library     dl_counters.py    WITH NAME    dl_counters


*** Variables ***
${gnb_id}    ${0}
${du_id}     ${0}
${ru_id}     ${0}
${stats_name_01}    receiverPcsStatusChangeCount
${stats_name_02}    receivedFecCorrectedCodewords
${stats_name_03}    receivedFecUncorrectedCodewords
${stats_name_04}    receivedCrcErroredFrames

*** Keywords ***
CHECK_COUNTERS_receiverPcsStatusChangeCount
    [Arguments]    ${update_ru_ip}=${False}
    ${result}    ${order}     dl_counters.GET LAST DL COUNTERS FROM SOAP ON RU    stats_name=${stats_name_01}
    ...    update_ru_ip=${update_ru_ip}    gnb_id=${gnb_id}    du_id=${du_id}    ru_id=${ru_id}
    Log to console    \n\n>>>>>>>>>>> Recently reached values: \n${result}\n
    [Return]    ${result}    ${order}

CHECK_COUNTERS_receivedFecCorrectedCodewords
    ${result}     dl_counters.GET LAST DL COUNTERS FROM SOAP ON RU    stats_name=${stats_name_02}
    ...                                                   gnb_id=${gnb_id}    du_id=${du_id}    ru_id=${ru_id}
    Log to console    \n\n>>>>>>>>>>> Recently reached values: \n${result}\n

CHECK_COUNTERS_receivedFecUncorrectedCodewords
    ${result}     dl_counters.GET LAST DL COUNTERS FROM SOAP ON RU    stats_name=${stats_name_03}
    ...                                                   gnb_id=${gnb_id}    du_id=${du_id}    ru_id=${ru_id}
    Log to console    \n\n>>>>>>>>>>> Recently reached values: \n${result}\n

CHECK_COUNTERS_receivedCrcErroredFrames
    ${result}     dl_counters.GET LAST DL COUNTERS FROM SOAP ON RU    stats_name=${stats_name_04}
    ...                                                   gnb_id=${gnb_id}    du_id=${du_id}    ru_id=${ru_id}
    Log to console    \n\n>>>>>>>>>>> Recently reached values: \n${result}\n
