*** Settings ***
Documentation
...   Author: zhuo.1.gao@nokia-sbell.com
...   Contact: zhuo.1.gao@nokia-sbell.com
...   Description: This user scenario describes

Resource          ../Resources/common_resource.robot
# Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Common MultiBTS Test Setup For RRM
Test Teardown     Common MultiBTS Test Teardown For RRM


#Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
#Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM

Force Tags
...      CRT             #Tag Item
...      RAN_VRF_HAZ_1             #Competence Area
...      RAN_VRF_HAZ_T06  #Organization
...      TA_LEVEL_23              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

*** Variables ***
# ${PA_MaxValue}           ${60}
# ${PA_NormalValue}        ${30}
${DEBUG_MODE}        ${TRUE}

*** Test Cases ***
CB013205_Case01_ Close the X2 link after S1 link down with single S1 link configured in eNB
    #[Tags]    QC_172870    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    Enable CB013205 feature
    Start Multi Bts Log
    LNMME0_blocked
    Sleep    30s
    Stop All BTSLog And Download to Local
    LNMME0_unblocked
    Sleep    10s
    Check X2 link closure For BTS0

CB013205_Case13_ Online activated feature after loss of all S1-C links
    #[Tags]    QC_172874    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    Disable CB013205 feature
    Sleep    30s
    Enable CB013205 feature
    Start Multi Bts Log
    LNMME0_blocked
    Sleep    30s
    Stop All BTSLog And Download to Local
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

Check X2 link closure For BTS${i}
    Log To Console    Check X2 link closure status
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'link closure (1)' | grep -av grep
    Should Contain    ${ret}    link closure (1)