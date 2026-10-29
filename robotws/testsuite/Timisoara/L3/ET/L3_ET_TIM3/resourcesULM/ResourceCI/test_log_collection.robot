*** Settings ***
Library     ./gnbtl.py
Library     OperatingSystem
Resource    ../log_collection.robot

*** Test Cases ***
Test Save DU Configs from gNB
    [TAGS]      LOG
    ${log_dir}=     Set Variable   /tmp/test_save_du_configs/
    Create Directory     ${log_dir}
    log_collection.Save DU configs from all gNBs     resultConfigsDir=${log_dir}
    ${log_files}=     List Files In Directory   ${log_dir}
    Should Not Be Empty     ${log_files}

Test Save DU Logs from all gNBs
    [TAGS]      LOG

    ${log_dir}=     Set Variable   /tmp/test_save_du_logs/
    Create Directory     ${log_dir}

    log_collection.Save DU logs from all gNBs   resultLogsDir=${log_dir}

    ${log_files}=     List Files In Directory   ${log_dir}
    Should Not Be Empty     ${log_files}
