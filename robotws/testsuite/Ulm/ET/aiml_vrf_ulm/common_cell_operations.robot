*** Settings ***
Documentation    Common cell operation keywords for blocking/unblocking cells
...              This resource consolidates cell management functionality used across multiple test files.

Library     taf.sbts.oam.coam.admin   WITH NAME   admin
Library     random
Resource    ../../resources/Common/connect.robot

*** Keywords ***
Get Cell Blocked Status
    [Documentation]    Get lists of blocked and unblocked cells from admin connection
    [Arguments]    ${admin_alias}

    ${cell_info}    admin.Get Cells Info   connection=${admin_alias}

    ${blocked_cells}     Create List
    ${unblocked_cells}   Create List
    FOR   ${cell}   IN   @{cell_info}
        IF   '${cell["status"]["blockingState"]}'=='Blocked'
            Append To List   ${blocked_cells}   ${cell["id"]["internal"]}
        ELSE
            Append To List   ${unblocked_cells}   ${cell["id"]["internal"]}
        END
    END

    RETURN   ${blocked_cells}   ${unblocked_cells}

Block Random Cell
    [Documentation]    Block a randomly selected unblocked cell
    [Arguments]    ${admin_alias}

    ${blocked_cells}   ${unblocked_cells}   Get Cell Blocked Status    admin_alias=${admin_alias}
    IF   ${{ len($unblocked_cells) > 0 }}
        ${cell}    Evaluate   random.choice($unblocked_cells)   random
        admin.Block Cell   connection=${admin_alias}   dist_name=${cell}
        RETURN    ${cell}
    END
    RETURN    ${None}

Unblock Random Cell
    [Documentation]    Unblock a randomly selected blocked cell
    [Arguments]    ${admin_alias}

    ${blocked_cells}   ${unblocked_cells}   Get Cell Blocked Status    admin_alias=${admin_alias}
    IF   ${{ len($blocked_cells) > 0 }}
        ${cell}    Evaluate   random.choice($blocked_cells)   random
        admin.Unblock Cell   connection=${admin_alias}   dist_name=${cell}
        RETURN    ${cell}
    END
    RETURN    ${None}

Unblock All Blocked Cells
    [Documentation]    Unblock all currently blocked cells
    [Arguments]    ${admin_alias}

    ${blocked_cells}   ${unblocked_cells}   Get Cell Blocked Status    admin_alias=${admin_alias}

    FOR   ${cell}   IN   @{blocked_cells}
        admin.Unblock Cell   connection=${admin_alias}   dist_name=${cell}
    END

    RETURN    ${blocked_cells}

Perform Random Cell Operations
    [Documentation]    Perform random cell blocking/unblocking operations
    [Arguments]    ${admin_alias}    ${number_of_operations}=10    ${with_delay}=${True}

    FOR   ${_}   IN RANGE   ${number_of_operations}
        ${blocked_cells}   ${unblocked_cells}   Get Cell Blocked Status     admin_alias=${admin_alias}

        ${block_or_unblock}    Evaluate   random.choice(['block', 'unblock'])  random

        IF   '${block_or_unblock}'=='block'
            ${cell}    Block Random Cell    admin_alias=${admin_alias}
            IF    ${cell} != ${None}
                Log To Console    Blocked cell: ${cell}
            END
        ELSE
            ${cell}    Unblock Random Cell    admin_alias=${admin_alias}
            IF    ${cell} != ${None}
                Log To Console    Unblocked cell: ${cell}
            END
        END

        IF    ${with_delay}
            ${sleep_duration}    Evaluate    random.randint(10, 80) / 10   random
            Sleep     ${sleep_duration}s
        END
    END
