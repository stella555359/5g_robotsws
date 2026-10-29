*** Settings ***
Documentation
...         author: Lixia.tang
...         contact: lixia.tang@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         Common error warning check after bts startup

Resource    ./Resources/ERR_WRN_Common_Keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          ./Resources/CB007053_common.robot
Variables         ./Resources/CB007053_para.py

*** Variables ***
${Check_Err_Wrn_Log_Path}    /home/ute/Case_Logs/Check_Err_Wrn

*** Test Cases ***
[1]CB007053_01_8 cells configuration with BB cell set type CB007053-A and CB007053-B
    [Setup]    Test Case setup
    [Timeout]    40min
    Run Keyword And Ignore error    Start BTSlogs Collection In Log Server
    Execute BTS Site Reset
    attach power ue
    start power ue traffic ul and dl      ul_throughput=30M    dl_throughput=200M
    Check power ue Tput    ul_throughput=24    dl_throughput=160
    stop multi power ue traffic ul and dl
#    BBMOD Reset 1 Times
    sleep    10s
    Run Keyword And Ignore error    Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure    Check ERR Or WRN From Syslog    sys_logs_path=${UTE_syslogs_path}    Fail_Case=True
    Check Exception in Syslog    log_file=${syslog_file}    filter_string=${Exception_string}
    [Teardown]    Test Case teardown

