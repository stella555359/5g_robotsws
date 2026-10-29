*** Settings ***
Documentation  CB007042

Library    OperatingSystem
Library    taf.ul.verify_snapshot  WITH NAME  snapshot
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.transport.ssh    WITH NAME    ssh
Resource    ../resources/bts_states.robot
Resource    ../resources/ssh_utils.robot
Resource    ../resources/pdu.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/unpacking.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Keywords ***
TC__LOGS__CB007042_B_112_AZQS_concurrent_operations_between_IQ_data_capture_and_L1low_dump_script_executions
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this case is to verify the concurrent operations between L1low dump and IQ data capture script execution
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.10.2025 - Andrei Maria - Initial Creation
    ...  *******************

    Set Tags    CA-LOGS    AUTHOR-andrei.maria@nokia.com    MAINTAINER-andrei.maria@nokia.com
    ...   GROUP_IN_CHARGE-TSR1_7_Vrf    PHASE-CRT

    Step 0: Preconditions
    Step 1: Trigger IQ data capture script while L1low dump script is ongoing
    Step 2: Check if IQ data capture script collection is rejected
    Step 3: Trigger L1low dump script while IQ data capture script is ongoing
    Step 4: Check if L1low dump script collection is rejected

Step 0: Preconditions
    [Documentation]
    ...  In this step necessary test variables are set.

    Log  \nStep 0: Preconditions  console=${True}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable   ${bts_id}
    @{NR_LTE_RMOD}    Create List    MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-1
    Set Test Variable    @{NR_LTE_RMOD}
    @{LTE_CELL}    Create List    MRBTS-${bts_id}/LNBTS-${bts_id}/LNCEL-48263
    Set Test Variable    @{LTE_CELL}
    @{NR_CELL}    Create List    MRBTS-${bts_id}/NRBTS-43266/NRCELL-58260
    Set Test Variable    @{NR_CELL}

Step 1: Trigger IQ data capture script while L1low dump script is ongoing
    Log  \nStep 1: Trigger IQ data capture script while L1low dump script is ongoing  console=${True}
    ${background_connection}  coam.Connect To  name=background_connection
    ${output_task_in_background}    coam.Run_Keyword_In_Background    Launch Troubleshooting Script    script_name=RU_Common_capture_L1low_data
    ...    output_file_name=${BTS_Files}/L1low_data.zip    cell_list=${NR_CELL}    rmod_list=${NR_LTE_RMOD}
    ...    free_parameters=${EMPTY}    timeout=${1200}    connection=background_connection
    Sleep  1s
    ${result_IQ_data_script}    Run Keyword And Ignore Error    coam.launch_troubleshooting_script    script_name=RU_Common_capture_IQ_data
    ...    output_file_name=${BTS_Files}/IQ_data.zip    cell_list=${NR_CELL}    rmod_list=${NR_LTE_RMOD}
    ...    free_parameters=${EMPTY}    timeout=${60}
    ${result_L1low_dump_script}    coam.Collect Keyword Result    task=${output_task_in_background}    timeout=${1200}
    log    ${result_L1low_dump_script}
    log    ${result_IQ_data_script}
    Set Test Variable   ${result_L1low_dump_script}
    Set Test Variable   ${result_IQ_data_script}

Step 2: Check if IQ data capture script collection is rejected
    Log  \nStep 2: Check if IQ data capture script collection is rejected  console=${True}
    Should Contain    ${result_L1low_dump_script}
    ...    Launching succeeded
    Should Contain    ${result_IQ_data_script[1]}
    ...    Launching failed, the operation conflicts due to launch script is ongoing

Step 3: Trigger L1low dump script while IQ data capture script is ongoing
    Log  \nStep 3: Trigger L1low dump script while IQ data capture script is ongoing  console=${True}
    ${background_connection}  coam.Connect To  name=background_connection
    ${output_task_in_background}    coam.Run_Keyword_In_Background    Launch Troubleshooting Script    script_name=RU_Common_capture_IQ_data
    ...    output_file_name=${BTS_Files}/IQ_data.zip    cell_list=${LTE_CELL}    rmod_list=${NR_LTE_RMOD}
    ...    free_parameters=${EMPTY}    timeout=${1200}    connection=background_connection
    Sleep  1s
    ${result_L1low_dump_script}    Run Keyword And Ignore Error    coam.launch_troubleshooting_script    script_name=RU_Common_capture_L1low_data
    ...    output_file_name=${BTS_Files}/L1low_data.zip    cell_list=${LTE_CELL}    rmod_list=${NR_LTE_RMOD}
    ...    free_parameters=${EMPTY}    timeout=${60}
    ${result_IQ_data_script}    coam.Collect Keyword Result    task=${output_task_in_background}    timeout=${1200}
    log    ${result_IQ_data_script}
    log    ${result_L1low_dump_script}
    Set Test Variable   ${result_IQ_data_script}
    Set Test Variable   ${result_L1low_dump_script}

Step 4: Check if L1low dump script collection is rejected
    Log  \nStep 4: Check if L1low dump script collection is rejected  console=${True}
    Should Contain    ${result_IQ_data_script}
    ...    Launching succeeded
    Should Contain    ${result_L1low_dump_script[1]}
    ...    Launching failed, the operation conflicts due to launch script is ongoing

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...  interface.Common step trigger
    ...  AND  Setup Scout And Send Configuration
    ...  AND  Common Test Teardown
