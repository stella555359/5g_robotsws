*** Settings ***
Documentation    Suite for parity feature CB010546_CB007426_CB008154 on ABIQ and ASIM.

Resource    ../common_resources/UUF/upgrade.robot
Resource    ../common_resources/UUF/reset.robot
Resource    ../common_resources/gathering_logs/gathering_logs.robot
Resource    ../common_resources/variables/variables.robot

Test Timeout      100h
Suite Setup       Suite Setup

*** Test Cases ***
[1]OAM_UFF_01_Stress_Multieloops_SiteReset
    [Tags]
    Site reset
    [Teardown]    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...                                           team_name=PZ3WRO4
    ...                                           input_logs_dir=${NONE}

*** Keywords ***
Suite Setup
    Run Keyword and Ignore Error  Generate and Send Configuration ID to ReP
    Prelimitary upgrade
