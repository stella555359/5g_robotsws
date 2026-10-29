*** Settings ***
Documentation
...   author: Adam Kropiwnicki
...   contact: adam.kropiwnicki@nokia.com

Library    taf.ue
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.perf_cap.cell_edge.resources.cell_edge.CellEdge  WITH NAME  CELL_EDGE

Suite Setup   CELL_EDGE.Suite Setup
Suite Teardown   CELL_EDGE.Suite Teardown

*** Test Cases ***
Cell Edge
    [Setup]   CELL_EDGE.Test Setup
    CELL_EDGE.Run
    [Teardown]   CELL_EDGE.Test Teardown
