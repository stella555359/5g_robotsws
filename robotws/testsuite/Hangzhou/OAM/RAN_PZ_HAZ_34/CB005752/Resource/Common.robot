*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.collectors.btslog       WITH NAME    btslog
Library     taf.collectors.core         WITH NAME    core
Resource    ../../common/taf_coam.robot
Resource    ../../common/qc_tag.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/symptom_collectors_hangzhou.robot
Variables   ../../libraries/global_vars.py
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot

*** Variables ***

*** Keyword ***
Common Setup
    Run Keyword And Ignore Error   Check Extra Reset From Blackbox
    Log To Console   ${EMPTY}
    Set Suite Variable    ${BTS_ID}   ${tl.gnbs[0].instance_id}
    Set Suite Variable    ${MO_NAME}    MRBTS-${BTS_ID}
    Set Suite Variable    ${DN}    PLMN-PLMN/${MO_NAME}
    COAM Login
    # Set QC Instance ID Test Tag

Common Teardown
    Run Keyword And Ignore Error   COAM Logout
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   10m   1m   COAM Login
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   15m   1m   COAM Check BTS OnAir
    Run Keyword And Ignore Error   COAM Logout
    Check Extra Reset From Blackbox
    CI_interface.Common Case Teardown

Set QC Instance ID Test Tag
    ${qc_def}   Get Common Tags Info By SMOD and Release   file_path=${CURDIR}/qc_id_def.csv
    Set Case Common Tags By Test Aggregate   qc_def=${qc_def}
