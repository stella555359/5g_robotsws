*** Settings ***
Force Tags          CONFIGS_2_11_UTESRAN106/custom_config.yaml
...                 CLOUD_5G_CLASSICAL_SA_ASIL_2xABIO_AHFIB_AHLOA_AEHC

Documentation
...   Author:   Heikki Autio
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
&{state_dict_unblock}   administrativeState=unlocked  operationalState=enabled  blockingState=unblocked
&{state_dict_block}     administrativeState=unlocked  availabilityStatus=off line  operationalState=disabled
                   ...  blockingState=blocked
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${WAIT_CHECKS}          20

*** Test Cases ***
OMKPI Block unblock all cells
    Run Keyword In Loop And Return Pass Rate
        ...    name=Block Unblock All Cells
        ...    test_case=1
        ...    loops=1
        ...    keywords=Block unblock all cells
        ...    expected_pass_rate=1

*** Keywords ***
Block unblock all cells
    Print Step Text                    1  Check Preconditions
    Run Keyword And Continue On Failure   Common Preconditions
    Print Step Text                    2  Check cell states
    &{cell_state_dict}                    Create Dictionary  All_cells=${state_dict_unblock}
    Run Keyword And Continue On Failure   Check Cell States  ${cell_state_dict}
    Print Step Text                    3  Block all cells
    Add Expected Alarm                    option=add_cells_to_alarm   alarm_id=7653   fault_id=49   fault_name=Cell blocked
                                     ...  severity=Critical
    Add Expected Alarm To Allowed
    Run Keyword And Continue On Failure   ADMIN.Block All Cells   rat=LTE   timeout=180  detailed_output=True
    Print Step Text                    4  Check alarms
    Run Keyword And Continue On Failure   Check Expected Alarms   wait_active_timeout=300
    Print Step Text                    5  Check cell states
    Set To Dictionary                     ${cell_state_dict}  All_cells  ${state_dict_block}
    Run Keyword And Continue On Failure   Check Cell States  ${cell_state_dict}
    Print Step Text                    6  Unblock all cells
    Run Keyword And Continue On Failure   ADMIN.Unblock All Cells   rat=LTE   timeout=300  detailed_output=True
    Run Keyword And Continue On Failure   Wait For All Cells Up   time_limit=${300}
    Print Step Text                    7  Check alarm history
    Run Keyword And Continue On Failure   Check Alarm History  reset_alarms=True
    Print Step Text                    8  Check cell states
    Set To Dictionary                     ${cell_state_dict}  All_cells  ${state_dict_unblock}
    Run Keyword And Continue On Failure   Check Cell States  ${cell_state_dict}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${FalseF}