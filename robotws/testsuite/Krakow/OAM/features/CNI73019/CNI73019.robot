*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: Test Cases CNI-73019 Cell Mapping info in gNB

Resource      taf/rfrl/bts/robot/logs_collecting.robot
Library       resources/resources.py    WITH NAME    lr
Library       ${CURDIR}/resources/Delta_add_cell.py
Variables     ${CURDIR}/resources/Delta_remove_cell.py

Test Timeout  24 hours

Force Tags    STATE_SW_UPLOADED    RAN_5G    RAN_5G_MP    CRT
...  SBTS00__WITH__CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEUD_IPV6
...  SBTS23R1__WITH__CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEUD_IPV6
...  SBTS22R4__WITH__CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEUD_IPV6
...  SBTS22R3__WITH__CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEUD_IPV6

Suite Setup         Perform commissioning on gNB to onAir state   prefix_tag=CNI_73019
Suite Teardown      Teardown Logs Collectors
Test Setup          Run Keyword And Ignore Error     Collect logs during test
Test Teardown       Run Keyword And Ignore Error     Collect logs after test finished

*** Variables ***
${SNAPSHOT_DIR} =  ${OUTPUTDIR}/snapshot

*** Test Cases ***
[1]CNI-73019_1_Cell_mapping_information_included_in_snapshot_ASIK+ABIL
    ${add_cell_delta}=  Prepare Delta
    ${number_of_cells_1} =  Collect Snapshot and Verify Component and Cell Info
    Perform Delta Commissioning On gNB
    ...  delta=${add_cell_delta}  skip_parameter_relation_errors=${True}
    ${number_of_cells_2} =  Collect Snapshot and Verify Component and Cell Info
    Should Be Equal  ${number_of_cells_1+1}  ${number_of_cells_2}
    Perform Delta Commissioning On gNB
    ...  delta=${remove_cell_delta}  skip_parameter_relation_errors=${True}
    ${number_of_cells_3} =  Collect Snapshot and Verify Component and Cell Info
    Should Be Equal  ${number_of_cells_1}  ${number_of_cells_3}

[1]CNI-73019_13_Cell_mapping_information_could_be_obtained_with_WebEM_remote_tool
    Verify SubCells Info

*** Keywords ***
Collect Snapshot and Verify Component and Cell Info
    Remove old snapshot
    Collect Snapshot From gNB
    ...  log_dir=${SNAPSHOT_DIR}
    Get nrcellmappinginfo
    ${number_of_cells} =  Verify component and cell info
    [return]  ${number_of_cells}
