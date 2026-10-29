*** Settings ***
Resource    taf/rfrl/bts/robot/logs_collecting.robot


*** Keywords ***
Collect Logs IF Case Failed
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}
    Run Keyword If Test Failed      Collect Mandatory Logs In gNB     log_path=${log_path}

Collect Mandatory Logs In gNB
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}
    Collect IM Snapshot From gNB    log_dir=${log_path}
    Collect IMS Log From gNB        log_dir=${log_path}
    Collect Snapshot From gNB       log_dir=${log_path}
