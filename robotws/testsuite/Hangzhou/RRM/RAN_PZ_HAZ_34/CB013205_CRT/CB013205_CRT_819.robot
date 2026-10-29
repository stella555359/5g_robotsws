*** Settings ***
Documentation
...   Author: zhuo.1.gao@nokia-sbell.com
...   Contact: zhuo.1.gao@nokia-sbell.com
...   Description: CB013205

Resource           ../../../resources/RAN_PZ_HAZ_34/lines/SG6/Module_And_KW/interface_resource.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot
# Suite Setup    Common MultiBTS Suite Setup For RRM Migration
# Suite Teardown    Common Suite Teardown For RRM Migration
# Test Setup        Common Test Setup For RRM Migration
# Test Teardown     Common Test Teardown For RRM Migration
# Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1    VRF_HAZ_T06
# ...    CLOUD_5G_CLASSICAL_ANDROIDX2_CA_ASIA_ABIAL_AZNC_FXEB
# Test Timeout      120 minutes

Suite Setup     TMO_Common_Suite_Setup   is_commission=${True}   ute_space=10    whether_do_prepare_ue=${False}
Suite Teardown   Run Keyword And Ignore Error    COAM Teardown gnb connections
Test Teardown    Run Keyword And Ignore Error    robot_common_operations.Common Case Teardown
Force Tags   SG_06


*** Variables ***
${SERIALS}      RFCWA0G52XE
${COUNTER_TIME}    120s
${DL_IPERF_SERVER}    10.68.254.195
${IPERF_OPTION}    -b 200M -t 1800 -u -i 1 -l 1024 -p 5504


*** Test Cases ***
[1]CB013205_Case01_ Close the X2 link after S1 link down with single S1 link configured in eNB
    #[Tags]    QC_172870    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    Enable CB013205 feature
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    LNMME0_blocked
    Sleep    30s
    LNMME0_unblocked
    Sleep    10s
    Check X2 link closure For BTS0


[1]CB013205_Case13_ Online activated feature after loss of all S1-C links
    #[Tags]    QC_172874    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    Disable CB013205 feature
    Sleep    15s
    Enable CB013205 feature
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    LNMME0_blocked
    Sleep    30s
    LNMME0_unblocked
    Sleep    10s
    Check X2 link closure For BTS0

*** Keywords ***
Enable CB013205 feature
    @{para_list}      Create List    actS1InducedX2Closure
    @{mo_list}        Create List    MRBTS-819/LNBTS-8191
    @{value_list}     Create List    true
    ${out}            Parameter Operation    operation=parameter_update    product_type=enb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}

Disable CB013205 feature
    @{para_list}      Create List    actS1InducedX2Closure
    @{mo_list}        Create List    MRBTS-819/LNBTS-8191
    @{value_list}     Create List    false
    ${out}            Parameter Operation    operation=parameter_update    product_type=enb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}


LNMME0_blocked
    @{para_list}      Create List    administrativeState
    @{mo_list}        Create List    MRBTS-819/LNBTS-8191/LNMME-0
    @{value_list}     Create List    locked
    ${out}            Parameter Operation    operation=parameter_update    product_type=enb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}

LNMME0_unblocked
    @{para_list}      Create List    administrativeState
    @{mo_list}        Create List    MRBTS-819/LNBTS-8191/LNMME-0
    @{value_list}     Create List    unlocked
    ${out}            Parameter Operation    operation=parameter_update    product_type=enb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}

Check X2 link closure For BTS0
    Log To Console    Check X2 link closure status
    ${local_file_path}    Log Collection    stop_and_download    syslog    product_type=gnb    bts_index=${0}
    &{syslog_filter_conditions}     create dictionary      line_regex=link closure \\(1\\)    element_regex=link closure \\(1\\)
    &{analysis_dict_syslog_1}     create dictionary        filter_conditions=${syslog_filter_conditions}
    ${result}=    Log Analysis    filter    syslog    ${local_file_path}    ${analysis_dict_syslog_1}
    should not be empty   ${result}
