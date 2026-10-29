*** Settings ***
Library    OperatingSystem
Library    String
Library    taf.collectors.core                  WITH NAME   core
Library    taf.collectors.btslog                WITH NAME   btslog
Library    testsuite.Bangalore.ORAN.resources.python.Macro.Python.utilities     WITH NAME   utilities
Library    testsuite.Bangalore.ORAN.resources.python.Macro.Python.helpers.tl_config
Resource    ./bts/gnb.robot


*** Keywords ***
Setup Logs Collectors
    Setup gNB Btslog Collector

Teardown Logs Collectors
    Run Keyword and Ignore Error  Teardown gNB Btslog Collector

Collect Logs During Test
    Set Test Case Log Path
    Start Collecting gNB BtsLog

Collect Logs After Test Finished
    Run Keyword and Ignore Error    Stop Collecting gNB BtsLog  log_dir=${LOG_PATH}
    Run Keyword and Ignore Error    Collect Mandatory Logs
#    Run Keyword If Test Failed      Collect logs if Test Case Failed

Collect CU Mandatory Logs
    Download Snapshot From CU    path=${LOG_PATH}

Collect Mandatory Logs
    Collect IM Snapshot From gNB    log_dir=${LOG_PATH}
    Collect IMS Log From gNB        log_dir=${LOG_PATH}
    Collect Snapshot From gNB       log_dir=${LOG_PATH}
    ${Is_Cloud} =    Is Testline of Cloud Type
    Run Keyword If    ${Is_Cloud}    Collect CU Mandatory Logs

Collect Logs If Test Case Failed
    Collect Mandatory Logs
