*** Settings ***
Documentation    This Resource holds cell specific scenarios.
Library     taf.sbts.oam.coam.admin   WITH NAME   admin
Library     taf.transport.ssh
Library     taf.ul.log_collection
Resource    AI_Common.robot
Resource    ../../resources/Common/connect.robot


*** Variables ***
${number_of_operations}    10
${ai_result_dir}          /tmp/
${ADMIN_ALIAS}            AIML_ADMIN_ALIAS


*** Test Cases ***
Collect Syslog With Admin Operations

    ${log_alias}    Prepare Syslogs
    ${target_dir}   testline.Get Testcase Log Directory


    taf.ul.log_collection.Setup Collectors    names=${log_alias}
    taf.ul.log_collection.Start Collectors    names=${log_alias}

    Sleep   2s

    Test Action    number_of_operations=${number_of_operations}

    taf.ul.log_collection.Stop Collectors      names=${log_alias}
    taf.ul.log_collection.Collect Collectors   names=${log_alias}    target_dir=${target_dir}
    taf.ul.log_collection.Teardown Collectors  names=${log_alias}

    ${syslog_files}=   taf.ul.log_collection.Get Log File    log_type=syslog
    ...                                                      target_dir=${target_dir}
    ...                                                      network_element=gnb_0

    Copy Files   @{syslog_files}    ${ai_result_dir}


*** Keywords ***
Get Cell Blocked Status
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



Test Action
    [Arguments]    ${number_of_operations}

    ${ADMIN_ALIAS}     Setup OAM HTTP Session

    Set Suite Variable   ${ADMIN_ALIAS}

    FOR   ${_}   IN RANGE   ${number_of_operations}

        ${blocked_cells}   ${unblocked_cells}   Get Cell Blocked Status     admin_alias=${admin_alias}

        ${block_or_unblock}    Evaluate   random.choice(['block', 'unblock'])  random

        IF   '${block_or_unblock}'=='block'
            IF   ${{ len($unblocked_cells) > 0 }}
                ${cell}    Evaluate   random.choice($unblocked_cells)   random
                admin.Block Cell   connection=${admin_alias}   dist_name=${cell}
            END
        ELSE
            IF   ${{ len($blocked_cells) > 0 }}
                ${cell}    Evaluate   random.choice($blocked_cells)   random
                admin.Unblock Cell   connection=${admin_alias}   dist_name=${cell}
            END
        END

        ${sleep_duration}    Evaluate    random.randint(10, 80) / 10   random
        Sleep     ${sleep_duration}s

    END
