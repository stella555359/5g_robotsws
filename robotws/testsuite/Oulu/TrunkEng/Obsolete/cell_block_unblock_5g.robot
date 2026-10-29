*** Settings ***
Force Tags  PY36

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot


Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
${REPORT}               ${True}
${CELL_TO_BLOCK}        1
${WAIT_CHECKS}          10
&{state_dict_unblock}   administrativeState=unlocked  operationalState=enabled  blockingState=unblocked
&{state_dict_block}     administrativeState=unlocked  availabilityStatus=off line  operationalState=disabled
                   ...  blockingState=blocked
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt

*** Test Cases ***
Block unblock cell
    [Documentation]   Blocks and unblocks user given cell and checks alarms and cell states.
    Run Keyword In Loop And Return Pass Rate
        ...    name=Block Unblock Cell
        ...    test_case=1
        ...    loops=1
		...    keywords=Block unblock cell
        ...    expected_pass_rate=1

Block unblock all cells
    [Documentation]   Blocks and unblocks all cells and checks alarms and cell states.
    Run Keyword In Loop And Return Pass Rate
        ...    name=Block Unblock All Cells
        ...    test_case=2
        ...    loops=1
		...    keywords=Block unblock all cells
        ...    expected_pass_rate=1

Block unblock all cells one by one
    [Documentation]   Blocks and unblocks all cells one by one and checks alarms and cell states.
    Run Keyword In Loop And Return Pass Rate
        ...    name=Block Unblock All Cells One By One
        ...    test_case=3
        ...    loops=1
		...    keywords=Block unblock all cells one by one
        ...    expected_pass_rate=1

*** Keywords ***
Block unblock cell
    Print Step Text                      1  Check Preconditions
    Common Preconditions
    ${cells_in_alarm}=                      Parse Cell Information For Alarm  ${CELL_TO_BLOCK}
    ${cell_dist_name}=                      Get Cell DistName By LocalId  ${CELL_TO_BLOCK}
    Print Step Text                      2  Check cell states
    &{cell_state_dict}                      Create Dictionary  NRCell-${CELL_TO_BLOCK}=${state_dict_unblock}
    Check Cell States                       ${cell_state_dict}  states_of_other_cells=${state_dict_unblock}
    Print Step Text                      3  Block cell ${CELL_TO_BLOCK}
    FOR  ${cell}  IN  @{cells_in_alarm}
        Add Expected Alarm               alarm_id=7653  fault_id=49  fault_name=Cell blocked  severity=Critical
                                         ...  unit_path=${cell}
    END
    Add Expected Alarm To Allowed
    ADMIN.Block Cell                        dist_name=${cell_dist_name}  timeout=180  detailed_output=True
    Print Step Text                      4  Check alarms
    Run Keyword And Continue On Failure     Check Expected Alarms  wait_active_timeout=300
    Wait Time And Reason                    ${WAIT_CHECKS}  before checking cell states
    Print Step Text                      5  Check cell states
    Remove From Dictionary     ${cell_state_dict}    All_cells
    Set To Dictionary                       ${cell_state_dict}  NRCell-${CELL_TO_BLOCK}  ${state_dict_block}
    Run Keyword And Continue On Failure     Check Cell States  ${cell_state_dict}
                                       ...  states_of_other_cells=${state_dict_unblock}
    Print Step Text                      6  Unblock cell ${CELL_TO_BLOCK}
    Run Keyword And Continue On Failure     ADMIN.Unblock Cell  dist_name=${cell_dist_name}  timeout=300
                                       ...  detailed_output=True
    Run Keyword And Continue On Failure     Wait For All Cells Up  time_limit=${300}
    Wait Time And Reason                    ${WAIT_CHECKS}  before checking alarm history
    Print Step Text                      7  Check alarm history
    Run Keyword And Continue On Failure     Check Alarm History
    Print Step Text                      8  Check cell states
    Set To Dictionary                       ${cell_state_dict}  NRCell-${CELL_TO_BLOCK}  ${state_dict_unblock}
    Run Keyword And Continue On Failure     Check Cell States  ${cell_state_dict}
                                       ...  states_of_other_cells=${state_dict_unblock}
    Print Step Text                      9  Check Postconditions
    Common Postconditions

Block unblock all cells
    Print Step Text                      1  Check Preconditions
    Common Preconditions
    Print Step Text                      2  Check cell states
    &{cell_state_dict}                      Create Dictionary  All_cells=${state_dict_unblock}
    Check Cell States                       ${cell_state_dict}
    Print Step Text                      3  Block all cells
    Add Expected Alarm                      option=add_cells_to_alarm  alarm_id=7653  fault_id=49
                                       ...  fault_name=Cell blocked  severity=Critical
    Add Expected Alarm To Allowed
    ADMIN.Block All Cells                   rat=NR  timeout=180  detailed_output=True
    Print Step Text                      4  Check alarms
    Run Keyword And Continue On Failure     Check Expected Alarms  wait_active_timeout=300
    Wait Time And Reason                    ${WAIT_CHECKS}  before checking cell states
    Print Step Text                      5  Check cell states
    Set To Dictionary                       ${cell_state_dict}  All_cells  ${state_dict_block}
    Run Keyword And Continue On Failure     Check Cell States  ${cell_state_dict}
    Print Step Text                      6  Unblock all cells
    Run Keyword And Continue On Failure     ADMIN.Unblock All Cells  rat=NR  timeout=300  detailed_output=True
    Run Keyword And Continue On Failure     Wait For All Cells Up  time_limit=${300}
    Wait Time And Reason                    ${WAIT_CHECKS}  before checking alarm history
    Print Step Text                      7  Check alarm history
    Run Keyword And Continue On Failure     Check Alarm History  reset_alarms=True
    Print Step Text                      8  Check cell states
    Set To Dictionary                       ${cell_state_dict}  All_cells  ${state_dict_unblock}
    Run Keyword And Continue On Failure     Check Cell States  ${cell_state_dict}
    Print Step Text                      9  Check Postconditions
    Common Postconditions

Block unblock all cells one by one
    Print Step Text                      1  Check Preconditions
    Common Preconditions
    Print Step Text                      2  Block all cells one by one and make checks
    &{cell_local_and_dist}=                 Get LocalIds And DistNames of Cells
    &{cell_state_dict}                      Create Dictionary  All_cells=${state_dict_unblock}
    Check Cell States                       ${cell_state_dict}
    &{cell_state_dict}                      Create Dictionary
    FOR  ${cell_local_id}  IN  @{cell_local_and_dist.keys()}
        ${cells_in_alarm}=                      Parse Cell Information For Alarm  ${cell_local_id}
        FOR  ${cell}  IN  @{cells_in_alarm}
            Add Expected Alarm            alarm_id=7653   fault_id=49   fault_name=Cell blocked
                                          ...  severity=Critical  unit_path=${cell}
        END
        Add Expected Alarm To Allowed
		Run Keyword And Continue On Failure     ADMIN.Block Cell  dist_name=${cell_local_and_dist["${cell_local_id}"]}
		                                   ...  timeout=180  detailed_output=True
        Run Keyword And Continue On Failure     Check Expected Alarms  wait_active_timeout=300
        Wait Time And Reason                    ${WAIT_CHECKS}  before checking cell states
        Set To Dictionary                       ${cell_state_dict}   ${cell_local_id}   ${state_dict_block}
        Run Keyword And Continue On Failure     Check Cell States  ${cell_state_dict}
                                           ...  states_of_other_cells=${state_dict_unblock}
    END

    Print Step Text                      3  Unblock all cells one by one and make checks
    FOR  ${cell_local_id}  IN  @{cell_local_and_dist.keys()}
        Run Keyword And Continue On Failure     ADMIN.Unblock Cell  dist_name=${cell_local_and_dist["${cell_local_id}"]}
                                           ...  timeout=300  detailed_output=True
        Wait Time And Reason                    ${WAIT_CHECKS}  before checking cell states
        Set To Dictionary                       ${cell_state_dict}  ${cell_local_id}  ${state_dict_unblock}
        Run Keyword And Continue On Failure     Check Cell States  ${cell_state_dict}
                                           ...  states_of_other_cells=${state_dict_block}
    END
    Print Step Text                      4  Check alarm history
    Run Keyword And Continue On Failure     Check Alarm History
    Print Step Text                      9  Check Postconditions
    Common Postconditions
