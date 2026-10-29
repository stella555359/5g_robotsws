*** Settings ***
Documentation
...         author: Lixia.tang
...         contact: lixia.tang@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         Common error warning check after bts startup

Resource    ./Resources/ERR_WRN_Common_Keywords.robot

*** Variables ***
${Check_Err_Wrn_Log_Path}    /home/ute/Case_Logs/Check_Err_Wrn

*** Test Cases ***
[1]CB011104_Reset_Site_Once_And_Check_Err_Wrn
    [Setup]    Test Case setup
    [Timeout]    40min
    Run Keyword And Ignore error    Start BTSlogs Collection In Log Server
    Execute BTS Site Reset
#    BBMOD Reset 1 Times
    sleep    10s
    Run Keyword And Ignore error    Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure    Check ERR Or WRN From Syslog    sys_logs_path=${UTE_syslogs_path}    Fail_Case=True
    Check Exception in Syslog    log_file=${syslog_file}    filter_string=${Exception_string}
    [Teardown]    Test Case teardown

[1]CB011104_Collect_Snapshot_And_Check_Err_Wrn
    [Setup]    Test Case setup
    [Timeout]    40min
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
#    Connect to gnb coam via ssl    connection=${connection}
#    Collect snapshot logs    snapshot_path=${Check_Err_Wrn_Log_Path}
    BBMOD Reset 1 Times
    sleep    10s
    Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure    Check ERR Or WRN From Syslog    sys_logs_path=${UTE_syslogs_path}    Fail_Case=True
    Save Checking Error Warning Syslog    log_file=${syslog_file}    save_log_path=${Check_Err_Wrn_Log_Path}
    [Teardown]    Test Case teardown

