*** Settings ***
Documentation
...    Author:  ya.1.sun
...    Contact: ya.1.sun@nokia-sbell.com
...    Feature: CB009794
...    Release: 23R3

Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot

*** Variables ***
@{ALLOWED_FAULT}
${scfc_file}    CB009793_US13_ASOE_AZHL_TDD_eCPRI_4T4R.xml
${isCommission}    True
${command}    sed -i '/0x340000/d' /ffs/run/swconfig.txt

*** Test Cases ***
CB009794_US13_activate_deactivate_feature_and_NR_RTWP_measurement_with_ASOE_TDD_ECPRI_AZHL_trunk
    [Tags]    ASOE    SMAwave    CPE    CB009794    US13    Trunk    QC_462619
    execute command on BTS via ssh    ${command}
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB009794${/}${scfc_file}    5min
    perform delta scf recommission    ${SCFC_path}${/}CB009794${/}enableRtwpMeasurement.json
    ${counter_file_1}    get PM counter file    5
    Set test Variable    ${counter_file_1}
    check PM counter value 1
    SMAwave UE attach      rat=5G
    SMAwave Start Data Traffic    0M    100M
    ${counter_file_2}    get PM counter file    5
    Set test Variable    ${counter_file_2}
    check PM counter value 2
    perform delta scf recommission    ${SCFC_path}${/}CB009794${/}disableRtwpMeasurement.json
    ${counter_file_3}    get PM counter file    5
    Set test Variable    ${counter_file_3}
    check PM counter value 3
    SMAwave Stop Data And Detach

CB009794_US13_activate_deactivate_feature_and_NR_RTWP_measurement_with_ASOE_TDD_ECPRI_AZHL_branch
    [Tags]    ASOE    SMAwave    CPE    CB009794    US13    Branch    QC_538364
    execute command on BTS via ssh    ${command}
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB009794${/}${scfc_file}    5min
    perform delta scf recommission    ${SCFC_path}${/}CB009794${/}enableRtwpMeasurement.json
    ${counter_file_1}    get PM counter file    5
    Set test Variable    ${counter_file_1}
    check PM counter value 1
    SMAwave UE attach      rat=5G
    SMAwave Start Data Traffic    0M    100M
    ${counter_file_2}    get PM counter file    5
    Set test Variable    ${counter_file_2}
    check PM counter value 2
    perform delta scf recommission    ${SCFC_path}${/}CB009794${/}disableRtwpMeasurement.json
    ${counter_file_3}    get PM counter file    5
    Set test Variable    ${counter_file_3}
    check PM counter value 3
    SMAwave Stop Data And Detach

*** Keywords ***
check PM counter value 1
    ${cell11_RTWP_counter_M55369C00000}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00000    11
    ${cell11_RTWP_counter_M55369C00001}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00001    11
    ${cell11_RTWP_counter_M55369C00002}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00002    11
    ${cell11_RTWP_counter_M55369C00003}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00003    11
    ${cell11_RTWP_counter_M55369C00004}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00004    11
    ${cell11_RTWP_counter_M55369C00005}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00005    11
    ${cell11_RTWP_counter_M55369C00006}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00006    11
    ${cell11_RTWP_counter_M55369C00007}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00007    11

    ${cell11_RTWP_counter_M55369C00100}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00100    11
    ${cell11_RTWP_counter_M55369C00101}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00101    11
    ${cell11_RTWP_counter_M55369C00102}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00102    11
    ${cell11_RTWP_counter_M55369C00103}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00103    11
    ${cell11_RTWP_counter_M55369C00104}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00104    11
    ${cell11_RTWP_counter_M55369C00105}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00105    11
    ${cell11_RTWP_counter_M55369C00106}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00106    11
    ${cell11_RTWP_counter_M55369C00107}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00107    11

    ${cell11_RTWP_counter_M55369C00200}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00200    11
    ${cell11_RTWP_counter_M55369C00201}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00201    11
    ${cell11_RTWP_counter_M55369C00202}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00202    11
    ${cell11_RTWP_counter_M55369C00203}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00203    11
    ${cell11_RTWP_counter_M55369C00204}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00204    11
    ${cell11_RTWP_counter_M55369C00205}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00205    11
    ${cell11_RTWP_counter_M55369C00206}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00206    11
    ${cell11_RTWP_counter_M55369C00207}=    get_counter_value_from_counter_file   ${counter_file_1}    M55369C00207    11

    should_be_true    ${cell11_RTWP_counter_M55369C00000}<=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00001}<=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00002}<=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00003}<=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00004}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00005}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00006}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00007}==0

    should_be_true    ${cell11_RTWP_counter_M55369C00100}<=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00101}<=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00102}<=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00103}<=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00104}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00105}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00106}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00107}==0

    should_be_true    ${cell11_RTWP_counter_M55369C00200}<=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00201}<=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00202}<=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00203}<=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00204}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00205}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00206}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00207}==0

check PM counter value 2
    ${cell11_RTWP_counter_M55369C00000}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00000    11
    ${cell11_RTWP_counter_M55369C00001}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00001    11
    ${cell11_RTWP_counter_M55369C00002}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00002    11
    ${cell11_RTWP_counter_M55369C00003}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00003    11
    ${cell11_RTWP_counter_M55369C00004}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00004    11
    ${cell11_RTWP_counter_M55369C00005}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00005    11
    ${cell11_RTWP_counter_M55369C00006}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00006    11
    ${cell11_RTWP_counter_M55369C00007}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00007    11

    ${cell11_RTWP_counter_M55369C00100}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00100    11
    ${cell11_RTWP_counter_M55369C00101}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00101    11
    ${cell11_RTWP_counter_M55369C00102}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00102    11
    ${cell11_RTWP_counter_M55369C00103}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00103    11
    ${cell11_RTWP_counter_M55369C00104}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00104    11
    ${cell11_RTWP_counter_M55369C00105}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00105    11
    ${cell11_RTWP_counter_M55369C00106}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00106    11
    ${cell11_RTWP_counter_M55369C00107}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00107    11

    ${cell11_RTWP_counter_M55369C00200}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00200    11
    ${cell11_RTWP_counter_M55369C00201}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00201    11
    ${cell11_RTWP_counter_M55369C00202}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00202    11
    ${cell11_RTWP_counter_M55369C00203}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00203    11
    ${cell11_RTWP_counter_M55369C00204}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00204    11
    ${cell11_RTWP_counter_M55369C00205}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00205    11
    ${cell11_RTWP_counter_M55369C00206}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00206    11
    ${cell11_RTWP_counter_M55369C00207}=    get_counter_value_from_counter_file   ${counter_file_2}    M55369C00207    11

    # should_be_true    ${cell11_RTWP_counter_M55369C00000}>=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00001}>=-85
    # should_be_true    ${cell11_RTWP_counter_M55369C00002}>=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00003}>=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00004}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00005}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00006}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00007}==0

    # should_be_true    ${cell11_RTWP_counter_M55369C00100}>=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00101}>=-85
    # should_be_true    ${cell11_RTWP_counter_M55369C00102}>=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00103}>=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00104}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00105}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00106}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00107}==0

    # should_be_true    ${cell11_RTWP_counter_M55369C00200}>=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00201}>=-85
    # should_be_true    ${cell11_RTWP_counter_M55369C00202}>=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00203}>=-85
    should_be_true    ${cell11_RTWP_counter_M55369C00204}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00205}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00206}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00207}==0

check PM counter value 3
    ${cell11_RTWP_counter_M55369C00000}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00000    11
    ${cell11_RTWP_counter_M55369C00001}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00001    11
    ${cell11_RTWP_counter_M55369C00002}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00002    11
    ${cell11_RTWP_counter_M55369C00003}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00003    11
    ${cell11_RTWP_counter_M55369C00004}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00004    11
    ${cell11_RTWP_counter_M55369C00005}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00005    11
    ${cell11_RTWP_counter_M55369C00006}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00006    11
    ${cell11_RTWP_counter_M55369C00007}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00007    11

    ${cell11_RTWP_counter_M55369C00100}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00100    11
    ${cell11_RTWP_counter_M55369C00101}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00101    11
    ${cell11_RTWP_counter_M55369C00102}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00102    11
    ${cell11_RTWP_counter_M55369C00103}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00103    11
    ${cell11_RTWP_counter_M55369C00104}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00104    11
    ${cell11_RTWP_counter_M55369C00105}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00105    11
    ${cell11_RTWP_counter_M55369C00106}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00106    11
    ${cell11_RTWP_counter_M55369C00107}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00107    11

    ${cell11_RTWP_counter_M55369C00200}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00200    11
    ${cell11_RTWP_counter_M55369C00201}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00201    11
    ${cell11_RTWP_counter_M55369C00202}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00202    11
    ${cell11_RTWP_counter_M55369C00203}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00203    11
    ${cell11_RTWP_counter_M55369C00204}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00204    11
    ${cell11_RTWP_counter_M55369C00205}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00205    11
    ${cell11_RTWP_counter_M55369C00206}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00206    11
    ${cell11_RTWP_counter_M55369C00207}=    get_counter_value_from_counter_file   ${counter_file_3}    M55369C00207    11

    should_be_true    ${cell11_RTWP_counter_M55369C00000}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00001}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00002}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00003}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00004}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00005}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00006}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00007}==0

    should_be_true    ${cell11_RTWP_counter_M55369C00100}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00101}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00102}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00103}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00104}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00105}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00106}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00107}==0

    should_be_true    ${cell11_RTWP_counter_M55369C00200}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00201}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00202}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00203}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00204}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00205}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00206}==0
    should_be_true    ${cell11_RTWP_counter_M55369C00207}==0
