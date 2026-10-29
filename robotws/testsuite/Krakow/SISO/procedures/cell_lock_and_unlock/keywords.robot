*** Settings ***

Resource    taf/rfrl/bts/robot/gnb.robot

*** Keywords ***
Modify timeout for X2 link drop
    [Arguments]     ${new_value}
    [Documentation]    Modifies shutdownNogNBCellTmr parameter that tells how long site waits to drop X2 link
    ...                after all cells have been locked
    ...     :param new_value:    New value of shutdownNogNBCellTmr parameter
    Perform Configuration Parameter Recommissioning On gNB
    ...     dist_name=MRBTS-{}/NRBTS-{}
    ...     param_name=shutdownNogNBCellTmr
    ...     param_value=${new_value}
    ...     skip_parameter_relation_errors=${True}
