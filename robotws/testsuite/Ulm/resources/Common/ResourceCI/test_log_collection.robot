*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real classical TL.
...   It verifies proper function of KWs in log_collection.robot for classical deployments.


Library     OperatingSystem

Resource    ../log_collection.robot
Resource    ../testline.robot

*** Test Cases ***
Test Save DU Configs From all gNB
    [TAGS]      LOG
    log_collection.Save DU Configs From All GNBs
    ${log_files}=     List Files In Directory   ${P_resultSuiteConfigDir}
    Should Not Be Empty     ${log_files}

Test Save DU Logs from all gNBs
    [TAGS]      LOG
    ${log_dir}   testline.Get Testcase Log Directory
    log_collection.Save DU Logs From All GNBs   resultLogsDir=${log_dir}
    ${log_files}=     List Files In Directory   ${log_dir}
    Should Not Be Empty     ${log_files}

