*** Settings ***
Documentation
...   This test suite is used to collect syslogs for evaluation
...   of different aspects of syslog
...
...   /home/ute/rotta/5G_2/nuecker/
...
...   Jira: https://jiradc.ext.net.nokia.com/projects/AI_ML_VRF_ULM/
...   Confluence: https://confluence.ext.net.nokia.com/display/5GFTUlm/Syslog+Analysis%3A+Procedure+detection

Library        DateTime
Library        generate_random_test_execution.py
Library        determine_ue_ids.py
Library        taf.ul.log_collection
Library        ute_wtssim

Resource       ../../resources/Common/testline.robot
Resource       ../../resources/Common/ute_workarounds.robot
Resource       ../../resources/Common/wts_ue.robot
Resource       AI_Common.robot
Resource       ue_resources.robot

Suite Setup     Run Keywords
...                  Bring Airphone to on Air status

*** Variables ***
${AI_RESULT_DIR}          /tmp/
${NUMBER_OF_OPERATIONS}   50
${ADMIN_ALIAS}            AIML_ADMIN_ALIAS


*** Test Cases ***
Collect Syslog With Multiple Attaches And Detaches
    ${ADMIN_ALIAS}     Setup OAM HTTP Session
    Set Suite Variable   ${ADMIN_ALIAS}

    ${log_alias}    Prepare Syslogs
    ${target_dir}   testline.Get Testcase Log Directory

    taf.ul.log_collection.Setup Collectors    names=${log_alias}
    taf.ul.log_collection.Start Collectors    names=${log_alias}

    Test Action With Multiple UEs   operations=${NUMBER_OF_OPERATIONS}

    taf.ul.log_collection.Stop Collectors      names=${log_alias}
    taf.ul.log_collection.Collect Collectors   names=${log_alias}    target_dir=${target_dir}
    taf.ul.log_collection.Teardown Collectors  names=${log_alias}

    ${syslog_files}=   taf.ul.log_collection.Get Log File    log_type=syslog
    ...                                                      target_dir=${target_dir}
    ...                                                      network_element=gnb_0

    ${rotta_mounted}   Run Keyword And Return Status    Directory Should Exist   ${AI_RESULT_DIR}

    IF   ${rotta_mounted}
        Copy Files   @{syslog_files}    ${AI_RESULT_DIR}
    ELSE
        Log    ROTTA not mounted! Files are not copied!   level=WARN
    END

*** Keywords ***
Test Action With Multiple UEs
    [Documentation]    Execute a action flow of random generated actions including
    ...                ue registrations and ue deregistrations as well as blocking of
    ...                cells and unblocking of cells.

    [Arguments]    ${operations}

    Log To Console    ${CURDIR}

    ${ue_ids}    Get All UE IDs

    ${generated_keyword}=    Create Random UE Operations Keyword
    ...                                      filename=${CURDIR}/MyGeneratedUeResource.robot
    ...                                      ue_ids=${ue_ids}
    ...                                      operations=${operations}
    ...                                      with_delay=${True}

    ${target_dir}      testline.Get Testcase Log Directory
    Copy File          ${CURDIR}/MyGeneratedUeResource.robot   ${target_dir}
    Import Resource    ${CURDIR}/MyGeneratedUeResource.robot

    ${resource_file}   Set Variable     MyGeneratedUeResource

    Run Keyword And Warn On Failure    ${resource_file}.${generated_keyword}

    # Deregister all possible ues, to have a clean setup.
    FOR   ${ue_id}   IN   @{ue_ids}
        Run Keyword And Ignore Error    Ue Deregister    ue_id=${ue_id}
    END


