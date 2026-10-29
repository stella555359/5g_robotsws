*** Settings ***
Documentation    CI interface keywords, trigger all CI related step keyword.
...              Please do not modify the file without notification to author
...              Author: Civen Chen
...              Contact: civen.chen@nokia-sbell.com

Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ./CI_collection.robot
Resource    ./CI_commssion.robot
# Library    taf.rfrl.common_resources.common_step.sleep_cell_check.ru_transmit_power    WITH NAME    scc

*** Variables ***
${testline_name}    ${empty}
${commissionings_path}    ${CURDIR}/../../../../../../commissionings/

*** Keywords ***
######################### INTERFACE #########################
CI_interface.Common Case Setup
    [Documentation]    This keyword will contain both WA operation for CIT/UTEC and information collections.
    ...                Author: Civen Chen
    ...                maintainer: Civen Chen
    [Timeout]          10 min
    run keyword and ignore error    BuiltIn.log    to be implemented

CI_interface.Common Case Teardown
    [Documentation]    This keyword will contain both WA operation for CIT/UTEC and information collections.
    ...                Author: Civen Chen
    ...                maintainer: Civen Chen
    [Timeout]          30 min
    [Arguments]  ${connection}=GNB_OAM    ${gnb_index}=0
    ${result}    ${ru_power}    run keyword and ignore error    Wait Until Keyword Succeeds    10 min    10 min
    ...    Run Keyword And Return Status    interface.Common step trigger
    run keyword and ignore error    CI_interface.Collection Trigger at Teardown
    ...    ru_power=${ru_power}    connection=${connection}    gnb_index=${gnb_index}

CI_interface.Common Suite Setup
    [Documentation]    This keyword will contain both WA operation for CIT/UTEC in suite setup.
    [Arguments]  ${gnb_index}=${0}    ${du_index}=${0}    ${common_unit_index}=${0}
    CI_commssion.common commissioning    gnb_index=${gnb_index}   du_index=${du_index}
    ...    common_unit_index=${common_unit_index}

######################### TRIGGER #########################
CI_interface.Collection Trigger at Teardown
    [Documentation]    This keyword is the trigger of collection keywords from CI_collection.
    ...                This keyword should not be called by other resource/testsuite.
    ...                Please call `CI_interface.Common Case Teardown` as interface
    [Timeout]          10 min
    [Arguments]      ${ru_power}    ${connection}=GNB_OAM    ${gnb_index}=0
    CI_collection.Collect_execution_info    ru_power=${ru_power}    connection=${connection}    gnb_index=${gnb_index}
