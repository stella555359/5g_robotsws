*** Settings ***
Documentation   Resources for regression testing of feature CB011179
...   author:   Marcin Bereznicki
...   contact:  marcin.bereznicki@nokia.com

Library         taf.rfrl.bts.devices.du.du_operations.GnbDuOperations        WITH NAME    DU
Library         taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    Cell
Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables       taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Keywords ***
Test Model Postcondition
    gnbalarm.Wait Until Callback Logs Collection Finished
    Check TRUCK ROLL alarms
    ${TRUCK_ROLL_ALARMS}   Get Variable Value      ${TRUCK_ROLL_ALARMS}
    Run Keyword If     not ${TRUCK_ROLL_ALARMS}    Run Keywords
    ...                                            DU.Reset BTS
    ...  AND                                       DU.Wait For Site To Be onAir
    ...  AND                                       Cell.Wait For All Cells To Be onAir
    Common Postconditions With Watching Alarms
