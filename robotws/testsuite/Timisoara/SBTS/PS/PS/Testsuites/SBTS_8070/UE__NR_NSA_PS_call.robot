*** Settings ***
Documentation  This suite contains UE__NR_PS_call TC
...    robot -v CONFIGURATION:Timisoara.10_18_UTESRANCLOUD1817 -C on -T -d /home/ute/test_results
...    -L TRACE -b debug.log -V /home/ute/testline_configuration/10_18_UTESRANCLOUD1817
...    testsuite/Timisoara/SBTS/PS/PS/Testsuites/SBTS_8070/UE__NR_NSA_PS_call.robot

Resource  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PS/resources/UE__NR_NSA_PS_call.robot


*** Test Cases ***
UE__NR_PS_call
    [Setup]  TC Setup
    UE__NR_NSA_PS_call
    [Teardown]  TC Teardown
