*** Settings ***
Documentation
...   author: Tomasz Romanowski, tomasz.1.romanowski@nokia.com
...   maintainer: Joanna Lechowicz, joanna.lechowicz@nokia.com

Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK2/CB007306_5GC001300/resources/Resource.robot

Force Tags    STATE_SW_UPLOADED   CRT    RAN_5G    PY39

Suite Setup     Suite Setup 5GC001300
Test Setup      Test Setup
Test Teardown   Test Teardown

*** Test Cases ***
[1][3.0]CB007306_5GC001300_Verify_enable_and_disable_of_PRACH_format_C2_with_prach_175_120_kHz
    [Tags]  CIT  CDRT
    Set prachConfigIndex to 175 on DU
    ${log_file} =  Catch L1L2 Trace And Extract
    Convert L1L2 for RACH  ${log_file}   ${OUTPUT DIR}/BIP_175.txt
    rach.Check Prach Received Messages  ${OUTPUT DIR}/BIP_175.txt     ${PRACH_INDEX_TABLE}         175

