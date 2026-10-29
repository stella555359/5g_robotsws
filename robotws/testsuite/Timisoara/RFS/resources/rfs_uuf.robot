*** Settings ***
Documentation    RFS Custom Keywords for UUF test
Resource    taf/rfrl/uuf4all/uuf4all_keywords.robot
Library    python_resources/tools.py
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    Collections
Library    String

*** Keywords ***
Set custom test nodes details
    ${test_nodes_details}=  Create list

    ${TEST_NODES_DETAILS_LIST}=  Split String  ${TEST_NODES_DETAILS_LIST}  ,

    FOR  ${BTS}  IN  @{TEST_NODES_DETAILS_LIST}
        ${BTS_node_status}=  Run Keyword And Return Status  Variable Should Exist  ${${BTS}_node}
        Run Keyword If  ${BTS_node_status}
        ...  Append To List  ${test_nodes_details}  ${${BTS}_node}
        ...  ELSE
        ...  Fail  Improper value for input parameter ${BTS}_testline_object!. Please populate it accordingly with your configuration!
    END

    Set Test Variable  ${test_nodes_details}

Check kpi threshold list
    ${KPI_NAMES_strip}=  Replace String  ${KPI_NAMES}  ${SPACE}  ${EMPTY}
    ${KPI_NAMES_list}=  Split String  ${KPI_NAMES_strip}  ,
    ${KPI_THRESHOLDS_strip}=  Replace String  ${KPI_THRESHOLDS}  ${SPACE}  ${EMPTY}
    ${KPI_THRESHOLDS_list}=  Split String  ${KPI_THRESHOLDS_strip}  ,

    ${kpi_targets}=  Create Dictionary

    FOR  ${name}  ${threshold}  IN ZIP  ${KPI_NAMES_list}  ${KPI_THRESHOLDS_list}
        Set To Dictionary  ${kpi_targets}  ${name}  ${threshold}
    END

    Set Test Variable  ${kpi_targets}

RFS Set Initial And Candidate SW
    FOR  ${BTS}  IN  @{BTS_LIST}
        Run Keyword If  '${${BTS}_source_sw}' == '' and '${${BTS}_target_sw}' == ''
        ...  Set Initial And Candidate SW  ${BTS}
        ...  ELSE  Set to dictionary  ${${BTS}_node}  source_sw=${${BTS}_source_sw}  target_sw=${${BTS}_target_sw}
    END

Set Initial And Candidate SW
    [Arguments]  ${BTS}

    ${initial_sw}=  tools.get_bts_decoupling_build  bts_label=${BTS}  decoupling_tag=SM_BUILD
    ${candidate_sw}=  tools.get_bts_decoupling_build  bts_label=${BTS}  decoupling_tag=TARGET_BUILD

    ${initial_sw}=  Run Keyword if  '${initial_sw}' == ''  Get Source SW
    ...  ELSE
    ...  Set Variable  ${initial_sw}

    ${candidate_sw}=  Run Keyword if  '${candidate_sw}' == ''  Get Target SW
    ...  ELSE
    ...  Set Variable    ${candidate_sw}

    Set to dictionary  ${${BTS}_node}  source_sw=${initial_sw}  target_sw=${candidate_sw}

RFS Set Candidate Activation Reset SW
    FOR  ${BTS}  IN  @{BTS_LIST}
        Run Keyword If  '${${BTS}_target_sw}' == ''
        ...  Set Candidate Activation Reset  ${BTS}
        ...  ELSE  Set To Dictionary  ${${BTS}_node}  source_sw=${${BTS}_target_sw}  target_sw=${${BTS}_target_sw}
    END

Set Candidate Activation Reset
    [Arguments]  ${BTS}

    ${candidate_sw}=  tools.get_bts_decoupling_build  bts_label=${BTS}  decoupling_tag=TARGET_BUILD
    ${candidate_sw}=  Run Keyword If  '${candidate_sw}' == ''  Get Target SW
    ...  ELSE
    ...  Set Variable  ${candidate_sw}

    Set To Dictionary  ${${BTS}_node}  source_sw=${candidate_sw}  target_sw=${candidate_sw}
