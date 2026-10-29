*** Settings ***
Documentation
...            author:       Hubert Chrzan, hubert.chrzan@nokia.com
...            maintainer:   Hubert Chrzan, hubert.chrzan@nokia.com

Resource    wts_kw.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot


*** Keywords ***
Generic Test Setup 2APs
    [Arguments]    ${check_ap_bh_ip2}
    [Documentation]    Start WTS till reach OnAir on two WTS
    Check GNB and AP Backhaul Links APs    check_ap_bh_ip2=${check_ap_bh_ip2}
    Check And Stop Egate And Edaemon Then Reboot If Necessary
    Wait for gNB To Be Ready
    Create Suite Scope Variables
    Add IP Addresses To Local Interfaces
    ...    eth4:10.0.2.2/24    eth4:10.0.2.3/24    eth4:10.0.2.4/24    ignore_existing=yes    silent=no
    Test Case Setup    reach_on_air=without_x2_link
    setup_default_egate

Generic Test Teardown 2APs
    [Arguments]    ${do_not_stop_egate}=${False}
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
    IF    ${do_not_stop_egate}
        Test Case Teardown    detach_ues=yes    teardown_wts=no
        Do not stop Egate and Daemon
    ELSE
        Test Case Teardown    teardown_wts=yes_with_reboot
        Wait for gNB To Be Ready
    END
