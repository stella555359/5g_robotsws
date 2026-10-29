*** Settings ***
Documentation
...    Author: Jacek Dziedzicki
...    Contact: Jacek.Dziedzicki@nokia.com
...    Description: Test cases for CB015933 5+5Mhz carrier overlapping configuration deployment support

Resource      testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/CB015933/resources/CB015933_Keywords.robot

Test Timeout  11 hours 55 minutes

Force Tags    CA_VRF_KRK    RF50

Suite Setup       CB015933_Keywords.Test Suite Setup
Suite Teardown    CB015933_Keywords.Test Suite Teardown
Test Setup        CB015933_Keywords.Test Setup
Test Teardown     CB015933_keywords.Test Teardown

*** Test Cases ***
CB015933 3. SW upgrade from N-1 to N release with 3.6 MHz carrier spacing between 5+5MHz LTE cells
    [Setup]    Test Setup For SW Upgrade TC
    Perform SW Upgrade    ${target_sw_version}
    Lock radio units
    Run keyword And Ignore Error    gnbcell.Block Cell    cell_id=91
    Attach UE    ${global_cell_id_178}
    [Teardown]    Run Keywords    Run keyword And Ignore Error    gnbcell.Unblock Cell    cell_id=91    AND
                  ...             Unlock Radio Units    AND
                  ...             Perform SW Upgrade If Needed    AND
                  ...             CB015933_keywords.Test Teardown

CB015933 2. Setting 3.6 MHz carrier spacing between 5+5MHz LTE cells on two different family RU
    [Setup]    CB015933_Keywords.Test Setup    prefix_tag=CB015933_TSPY215_TC2_2RU
    Run keyword And Ignore Error    rmod.Lock Radio Unit    radio_unit_id=1
    Block eNB Cells
    Attach UE    ${global_cell_id_179}
    gnbcell.Unblock Cell    cell_id=92
    Run keyword And Ignore Error    gnbcell.Block Cell    cell_id=82
    Attach UE    global_cell_id=${global_cell_id_178}    prepareUE=${False}
    [Teardown]    Run Keywords    Unblock eNB Cells    AND
                  ...             Run keyword And Ignore Error    rmod.Unlock Radio Unit    radio_unit_id=1    AND
                  ...             CB015933_keywords.Test Teardown
