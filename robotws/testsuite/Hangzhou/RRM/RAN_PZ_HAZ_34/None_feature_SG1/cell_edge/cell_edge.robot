*** Settings ***
Force Tags    PY36
Documentation
...    Author:
...    Contact:
...    squad
...    Feature

Suite Setup         Setup Suite
Suite Teardown     Teardown Suite
Resource          ./Resource/cell_edge_resource.robot

*** Variables ***

*** Test Cases ***
Cell_Edge_Peak_Stationary_Test
    [Documentation]
    [Tags]    CIT_TRUNK  CRT_TRUNK  CRT_22R2
    [Setup]    Setup case
    [Teardown]  Teardown case   URL=${CASE_INPUT_CellEdge['Stationary_Test']['report_server_url']}
    TC.Stationary_Test

Cell_Edge_Link_Adaption_Test
    [Documentation]
    [Tags]    CIT_TRUNK  CRT_TRUNK  CRT_22R2
    #    [Setup]    Setup case
    [Teardown]  Teardown case   URL=${CASE_INPUT_CellEdge['LA_Test']['report_server_url']}  graph=${True}   graph_type=LA
    TC.Link_Adaption_Test

Cell_Edge_KPI
    [Documentation]
    [Tags]    CIT_TRUNK   CRT_TRUNK   CRT_22R2
    [Setup]    Setup case
    [Teardown]  Teardown case   URL=${CASE_INPUT_CellEdge['KPI_Test']['report_server_url']}  graph=${True}   graph_type=KPI
    TC.KPI_Test

Cell_Attach_Success_Rate
    [Documentation]
    [Tags]    CIT_TRUNK   CRT_TRUNK   CRT_22R2
    #    [Setup]    Setup case
    TC.Attach_Success_Rate_at_Cell_Edge
    [Teardown]  Teardown case   URL=${CASE_INPUT_CellEdge['Attach_Rate']['report_server_url']}


Cell_Edge_KPI_Test_without_traffic_For_OTA_ENV
    [Documentation]
    [Tags]    CIT_TRUNK   CRT_TRUNK   CRT_23R3
    [Setup]    Setup case for OTA
    [Teardown]  Teardown case for OTA  # URL=${CASE_INPUT_CellEdge['KPI_Test']['report_server_url']}  graph=${True}   graph_type=KPI
    TC.KPI_Test_For_without_traffic_OTA_ENV

Cell_Edge_KPI_Test_with_short_time_ul_traffic_For_OTA_ENV
    [Documentation]
    [Tags]    CIT_TRUNK   CRT_TRUNK   CRT_23R3
    [Setup]    Setup case for OTA
    [Teardown]  Teardown case for OTA
    TC.KPI_Test_with_short_time_ul_traffic_For_OTA_ENV

Cell_Edge_KPI_Test_with_long_time_ul_traffic_For_OTA_ENV
    [Documentation]
    [Tags]    CIT_TRUNK   CRT_TRUNK   CRT_23R3
    [Setup]    Setup case for OTA
    [Teardown]  Teardown case for OTA
    TC.KPI_Test_with_long_time_ul_traffic_For_OTA_ENV