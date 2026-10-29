*** Settings ***
Documentation
...  Feature CB010519
...
...  author/contact: krzysztof.1.wrobel@nokia.com

Library         ute_wtssim
Library         ta5g_egate
Library         ta5g_syslog
Library         testsuite.Wroclaw.RRM.VRF_WRO1_T04.SAS_ET.CB010519.CB010519

Resource    ../resources/common_configuration.robot

Test Setup    Test Setup Prepare
Test Teardown    Run Keywords    Send Configuration ID To Scout
    ...    AND    Test Teardown Prepare

*** Test Cases ***

[1]CB010519_Check_content_of_SERVEDAMF_NRPLMN_SUPPORT_on_clasical_BTS_after_successful_NG_Setup_procedure
    Start Ip Capture
    Block Ng Link
    UnBlock Ng Link
    Stop Ip Capture And Download
    Check Admin Output And Pcap Output