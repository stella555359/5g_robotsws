*** Settings ***
Documentation    Random test execution generator
...              This resource consolidates random test generation functionality

Library     random
Resource    common_cell_operations.robot
Resource    common_ue_operations.robot

*** Keywords ***
Generate Random Test Actions
    [Documentation]    Generate a sequence of random test actions
    [Arguments]    ${operations}=10    ${with_delay}=${True}    ${admin_alias}=${None}    ${cell_ids}=${None}    ${relevant_enb_id}=${None}

    ${possible_actions}    Create List    ue_register    ue_deregister    block_cell    unblock_cell

    FOR   ${_}   IN RANGE   ${operations}
        ${action}    Evaluate    random.choice($possible_actions)    random

        IF    '${action}' == 'ue_register' and ${cell_ids} != ${None}
            ${ue_id}    Execute Random UE Registration    ${cell_ids}    ${relevant_enb_id}
            IF    ${ue_id} != ${None}
                Log To Console    Registered UE: ${ue_id}
            END

        ELSE IF    '${action}' == 'ue_deregister' and ${cell_ids} != ${None}
            ${ue_id}    Execute Random UE Deregistration    ${cell_ids}    ${relevant_enb_id}
            IF    ${ue_id} != ${None}
                Log To Console    Deregistered UE: ${ue_id}
            END

        ELSE IF    '${action}' == 'block_cell' and ${admin_alias} != ${None}
            ${cell}    Block Random Cell    admin_alias=${admin_alias}
            IF    ${cell} != ${None}
                Log To Console    Blocked cell: ${cell}
            END

        ELSE IF    '${action}' == 'unblock_cell' and ${admin_alias} != ${None}
            ${cell}    Unblock Random Cell    admin_alias=${admin_alias}
            IF    ${cell} != ${None}
                Log To Console    Unblocked cell: ${cell}
            END
        END

        IF    ${with_delay}
            ${delay}    Evaluate    random.randint(10, 50) / 10    random
            Log To Console    Sleep ${delay}s
            Sleep    ${delay}s
        END
    END

Execute Combined Random Operations
    [Documentation]    Execute combined UE and cell operations with proper setup
    [Arguments]    ${operations}=10    ${with_delay}=${True}

    # Setup admin connection
    ${admin_alias}    Setup OAM HTTP Session

    # Setup UE data
    Preload Enb And Cell Information

    # Execute random actions
    Generate Random Test Actions
    ...    operations=${operations}
    ...    with_delay=${with_delay}
    ...    admin_alias=${admin_alias}
    ...    cell_ids=${CELL_IDS}
    ...    relevant_enb_id=${RELEVANT_ENB_ID}

    # Cleanup
    Unblock All Blocked Cells    admin_alias=${admin_alias}
