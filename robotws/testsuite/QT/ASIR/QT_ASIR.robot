*** Settings ***
Documentation
...   Test suite for QT testing of ASIR
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/bts/robot/gnb.robot
Resource     ./resources/common_keywords.robot

Library       ${CURDIR}/../SRAN/resources/python/QTListener.py
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/common_variables.py

Suite Setup       QT Suite Setup
Suite Teardown    QT Suite Teardown

*** Variables ***
${capabilities}=            REAL_UE
${capabilities2}=           REAL_UE2
${duration}=                70s
${dl_throughput}=           110 Mbits/sec
${dl_deviation}=            50%
${ul_throughput}=           13 Mbits/sec
${ul_deviation}=            50%


*** Test Cases ***
Software Upgrade
    [Tags]    ASIR
    [Setup]     Actions before test     alarms_for_test=SW_Upgrade
    SW UPGRADE
    [Teardown]      Run Keywords        Actions after test      AND
    ...             Run Keyword If Test Failed      Fatal Error     msg=SW Update Fail

L3 Call
    [Tags]    ASIR
    [Setup]     Actions before test     alarms_for_test=L3_Call
    Run Keyword And Continue On Failure     Stop Ue Proxy On Ue PC
    Start Ue Proxy On Ue PC
    Change qrxlevmin parameter     value=max
    ${first_call_ul}=      Run Keyword And Return Status       L3 Call      direction=UL        tput=${ul_throughput}
    ...                                                        deviation=${ul_deviation}
    ${first_call_dl}=      Run Keyword And Return Status       L3 Call      direction=DL        tput=${dl_throughput}
    ...                                                        deviation=${dl_deviation}        prepareUE=False
    Stop Ue Proxy On Ue PC
    Start Ue Proxy On Ue PC
    ${prepare_ue}=      Set Variable If     ${first_call_ul}==${False}     False        True
    Run Keyword If      '${first_call_ul}'=='${False}'         L3 Call     direction=UL         tput=${ul_throughput}
    ...                                                        deviation=${ul_deviation}        cap=${capabilities2}
    ...                                                        ue_alias=UE2
    Run Keyword If      '${first_call_dl}'=='${False}'         L3 Call     direction=DL         tput=${dl_throughput}
    ...                                                        deviation=${dl_deviation}        cap=${capabilities2}
    ...                                                        prepareUE=${prepare_ue}          ue_alias=UE2
    Change qrxlevmin parameter     value=min
    [Teardown]      Actions after test

Online commissioning of BTS and ASI system
    [Tags]    ASIR
    [Setup]     Actions before test     alarms_for_test=Comm_and_Recomm
    Configuration Reset On ASIR
    [Teardown]      Actions after test

BBMOD Reset
    [Tags]    ASIR
    [Setup]     Actions before test     alarms_for_test=BBMOD_Reset
    Run Keyword If      '${BBMOD_type}'!='ASOE'     Reset BBMODs
    Run Keyword If      '${BBMOD_type}'=='ASOE'     gNB Reset
    [Teardown]      Actions after test
