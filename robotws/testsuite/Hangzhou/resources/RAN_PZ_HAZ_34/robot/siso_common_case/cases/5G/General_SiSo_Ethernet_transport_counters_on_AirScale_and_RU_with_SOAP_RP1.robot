*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
*** Variables ***

*** Keywords ***
General_SiSo_Ethernet_transport_counters_on_AirScale_and_RU_with_SOAP_RP1
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] to Check check if cOAM BTS WebEM or Netact NMS displays counters for eCPRI interface
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.17.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${stream}    get stream from version    ${Active_SW_version}
    ${boundary}    get the boundary of stream    stream=${stream}
    ${M5130_filter}    Set Variable If    '${boundary}'=='new_version'    Ethernet interface statistics
    ...     Ethernet interface statistics measurement interval
    ${M5130_interval}    Get Parameter Via Webem    dist_name=MRBTS-${MRBTS_ID}/TNLSVC-1/PMTNLINT-1
	...    filter_param=${M5130_filter}
    log to console   \n Wait M5130 interval ${M5130_interval}
    sleep  ${M5130_interval}
    Check M5130 Counter
    [Teardown]  Selenium Logout And Close Browser
