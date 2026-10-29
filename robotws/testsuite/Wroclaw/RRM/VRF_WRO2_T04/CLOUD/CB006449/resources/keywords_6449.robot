*** Settings ***
Documentation
...   Keywords for CB006449

Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/counters_aic.py

*** Keywords ***
Verify 6449 counters
    counters.Wait For Pm Counters Interval    offset=120
    Run Keyword And Continue On Failure
    ...    Vcu Counter Incremented Successfully For Cell    M55114C01584    cell_id=${AEHC_CELL_41}
    Run Keyword And Continue On Failure
    ...    Vcu Counter Incremented Successfully For Cell    M55118C10005    cell_id=${AEHC_CELL_41}
    ...    operator=>=    expected_value=150
    Run Keyword And Continue On Failure
    ...    Vcu Counter Incremented Successfully For Cell    M55118C10001    cell_id=${AEHC_CELL_41}
    Run Keyword And Continue On Failure
    ...    Vcu Counter Incremented Successfully For Cell    M55118C10002    cell_id=${AEHC_CELL_41}
    Run Keyword And Continue On Failure
    ...    Vcu Counter Incremented Successfully For Cell    M55138C03524    cell_id=${AEHC_CELL_41}
    Run Keyword And Continue On Failure
    ...    Vcu Counter Incremented Successfully For Cell    M55138C03527    cell_id=${AEHC_CELL_41}
    Run Keyword And Continue On Failure
    ...    Vcu Counter Incremented Successfully For Cell    M55118C11058    cell_id=${AEHC_CELL_41}
    Run Keyword And Continue On Failure
    ...    Vcu Counter Incremented Successfully For Cell    M55118C11068    cell_id=${AEHC_CELL_41}
    Run Keyword And Continue On Failure
    ...    Vcu Counter Incremented Successfully For Cell    M55118C00094    cell_id=${AEHC_CELL_41}
    ...    operator=>=    expected_value=150
    Run Keyword And Continue On Failure
    ...    Vcu Counter Incremented Successfully For Cell    M55114C01572    cell_id=${AEHC_CELL_41}
    ...    operator=>=    expected_value=150
    Run Keyword And Continue On Failure
    ...    Vdu Counter Incremented Successfully For Cell    M55139C05516    cell_id=${AEHC_CELL_41}
    Run Keyword And Continue On Failure
    ...    Vdu Counter Incremented Successfully For Cell    M55139C05519    cell_id=${AEHC_CELL_41}
    Run Keyword And Continue On Failure
    ...    Vdu Counter Incremented Successfully For Cell    M55316C04001    cell_id=${AEHC_CELL_41}
    ...    operator=>=    expected_value=150
    Run Keyword And Continue On Failure
    ...    Vdu Counter Incremented Successfully For Cell    M55316C06001    cell_id=${AEHC_CELL_41}
    Run Keyword And Continue On Failure
    ...    Vdu Counter Incremented Successfully For Cell    M55316C15039    cell_id=${AEHC_CELL_41}
    ...    operator=>=    expected_value=150

    Run Keyword And Continue On Failure
    ...    Vcu Counter Incremented Successfully For Cell    M55118C10006    cell_id=${AEHC_CELL_40}
    ...    operator=>=    expected_value=150
    Run Keyword And Continue On Failure
    ...    Vdu Counter Incremented Successfully For Cell    M55139C01001    cell_id=${AEHC_CELL_40}
    Run Keyword And Continue On Failure
    ...    Vdu Counter Incremented Successfully For Cell    M55139C01002    cell_id=${AEHC_CELL_40}
    Run Keyword And Continue On Failure
    ...    Vdu Counter Incremented Successfully For Cell    M55310C02032    cell_id=${AEHC_CELL_40}
    ...    operator=>=    expected_value=900000000
