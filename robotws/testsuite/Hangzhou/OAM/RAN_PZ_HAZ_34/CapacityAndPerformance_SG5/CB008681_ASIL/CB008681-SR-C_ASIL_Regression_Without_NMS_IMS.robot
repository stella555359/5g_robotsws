*** Settings ***
Suite Setup          TestSuite_setup_withIMS
Suite Teardown       TestSuite_teardown_withIMS
Test Timeout         500 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    Resources/OMKPI_KW_interface.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/CB006277-PhaseE/Resources/CB006277_common_keywords.robot

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB008681

Force Tags    RAN_5G_TDD
...    PY36

*** Test Cases ***
[1]CNP-SR-C-13-Manual_Site_reset_downtime_KPI#1a
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${gNBMode}    gNB.CheckgNBCoreMode
    ${KPI1a_MAX}    set variable if     '${testline_name}' == '7_5_UTE5G402T683'
    ...     ${KPI['CB008457_KPI1a']['CNF_5G_11']['KPI1a_MAX']}
    ...     ${KPI['CB008457_KPI1a']['CNF_5G_25']['KPI1a_MAX']}
    ${KPI1a_AVG}    set variable if     '${testline_name}' == '7_5_UTE5G402T683'
    ...    ${KPI['CB008457_KPI1a']['CNF_5G_11']['KPI1a_AVG']}
    ...    ${KPI['CB008457_KPI1a']['CNF_5G_25']['KPI1a_AVG']}
    set test variable    ${KPI1a_AVG}
    set test variable    ${KPI1a_MAX}
    set test variable     ${KPI_intotall}    0
    OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core_IMS    WebUI_reset_times=${KPI['CB008457_KPI1a']['WebUI_reset_times']}
    [Teardown]    Run keywords    Save Coam Snapshot    timeout=${2400}    AND
    ...    SISO Coam Test Teardown
[1]CNP-SR-C-Manual_Site_reset_downtime_KPI#1f_without_RU_reset
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${gNBMode}    gNB.CheckgNBCoreMode
    ${KPI1f_MAX}    set variable if     '${testline_name}' == '7_5_UTE5G402T683'
    ...     ${KPI['CB008457_KPI1f']['CNF_5G_11']['KPI1f_MAX']}
    ...     ${KPI['CB008457_KPI1f']['CNF_5G_25']['KPI1f_MAX']}
    ${KPI1f_AVG}    set variable if     '${testline_name}' == '7_5_UTE5G402T683'
    ...    ${KPI['CB008457_KPI1f']['CNF_5G_11']['KPI1f_AVG']}
    ...    ${KPI['CB008457_KPI1f']['CNF_5G_25']['KPI1f_AVG']}
    set test variable    ${KPI1f_AVG}
    set test variable    ${KPI1f_MAX}
    set test variable     ${KPI_intotall}    0
    OAM_KPI_1f_Site_Reset_Without_RU_reset_Outage_Duration_Single_Core_IMS    WebUI_reset_times=${KPI['CB008457_KPI1f']['WebUI_reset_times']}
    [Teardown]    Run keywords    Save Coam Snapshot    timeout=${2400}    AND
    ...    SISO Coam Test Teardown
[1]CNP-SR-C-05-Power_on_startup_availability_KPI#3
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${gNBMode}    gNB.CheckgNBCoreMode
    ${KPI3_MAX}=    set variable if     '${testline_name}' == '7_5_UTE5G402T683'
    ...    ${KPI['CB008457_KPI3']['CNF_5G_11']['KPI3_MAX']}
    ...    ${KPI['CB008457_KPI3']['CNF_5G_25']['KPI3_MAX']}
    ${KPI3_AVG}=    set variable if     '${testline_name}' == '7_5_UTE5G402T683'
    ...    ${KPI['CB008457_KPI3']['CNF_5G_11']['KPI3_AVG']}
    ...    ${KPI['CB008457_KPI3']['CNF_5G_25']['KPI3_AVG']}
    set test variable    ${KPI3_MAX}
    set test variable    ${KPI3_AVG}
    set test variable     ${KPI_intotall}    0
    OAM_KPI_3_Power_on_startup_availability_IMS    WebUI_reset_times=${KPI['CB008457_KPI3']['Power_reset_times']}
    [Teardown]    Run keywords    Save Coam Snapshot    timeout=${2400}
    ...    AND    SISO Coam Test Teardown
[1]CNP-SR-C-12-Manual_RU_reset_downtime_KPI#51a
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    set test variable     ${KPI_intotall}    0
    ${ru_index_list}    get all ru index
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}
        ${ru_type}    set variable    ${ru_info}[productName]
        ${KPI51a_MAX}=    Set Variable If    '${ru_type}' == 'AKQJ' or '${ru_type}' == 'AQNA' or '${ru_type}' == 'AQQJ'
        ...    ${KPI['CB008457_KPI51']['KPI51_AVG']}
        ...    ${KPI['CB008457_KPI51']['KPI51_master_AVG']}
        set test variable    ${KPI51a_MAX}
        log to console    start to test RU manual reset for RU_${ru_index}
        OAM_KPI_51a_Manual_RU_reset_downtime_IMS    ru_index=${ru_index}
        ...    WebUI_reset_times=${KPI['CB008457_KPI51']['ru_reset_times']}
        sleep    5s
    END
    [Teardown]    Run keywords    Save Coam Snapshot    timeout=${2400}    AND
    ...    SISO Coam Test Teardown
[1]CNP-SR-C-08-Manual_5GRAT_reset_downtime_KPI#10a
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    set RAT reset precondition    input_value=true
    ${KPI10a_MAX}=    set variable if     '${testline_name}' == '7_5_UTE5G402T683'
    ...    ${KPI['CB008457_KPI10a']['CNF_5G_11']['KPI10a_AVG']}
    ...    ${KPI['CB008457_KPI10a']['CNF_5G_25']['KPI10a_AVG']}
    set test variable    ${KPI10a_MAX}
    OAM_KPI_10a_RAT_Reset_downtime_IMS    WebUI_reset_times=${KPI['CB008457_KPI10a']['5GRAT_reset_times']}
    #OAM_KPI_10a_RAT_Reset_downtime_IMS    WebUI_reset_times=${1}
    [Teardown]    Run keywords    Save Coam Snapshot    timeout=${2400}    AND
    ...    SISO Coam Test Teardown
[1]CNP-SR-C-08-Manual_5GRAT_reset_downtime_KPI#10b
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
 #   set RAT reset precondition    input_value=false
    ${KPI10b_MAX}=    set variable if     '${testline_name}' == '7_5_UTE5G402T683'
    ...    ${KPI['CB008457_KPI10b']['CNF_5G_11']['KPI10b_AVG']}
    ...    ${KPI['CB008457_KPI10b']['CNF_5G_25']['KPI10b_AVG']}
    set test variable    ${KPI10b_MAX}
    OAM_KPI_10b_RAT_Reset_downtime_IMS    WebUI_reset_times=${KPI['CB008457_KPI10b']['5GRAT_reset_times']}
    [Teardown]    Run keywords    Save Coam Snapshot    timeout=${2400}    AND
    ...    SISO Coam Test Teardown
[1]CNP-SR-C-11-RU_power_on_reset_cold_startup_downtime_KPI#54a
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${ru_index_list}    get all ru index
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}
        ${ru_type}    set variable    ${ru_info}[productName]
        ${KPI54a_MAX}=    Set Variable If    '${ru_type}' == 'AKQJ' or '${ru_type}' == 'AQNA' or '${ru_type}' == 'AQQJ'
        ...    ${KPI['CB008457_KPI54']['KPI54A_AVG']}
        ...    ${KPI['CB008457_KPI54']['KPI54A_master_AVG']}
        set test variable    ${KPI54a_MAX}
        log to console    start to test RU manual power reset for RU_${ru_index}
        OAM_KPI_54a_Manual_RU_power_on_reset_downtime_IMS    ru_index=${ru_index}
        ...    WebUI_reset_times=${KPI['CB008457_KPI54']['ru_reset_times']}
        sleep    5s
    END
    [Teardown]    Run keywords    Save Coam Snapshot    timeout=${2400}    AND
    ...    SISO Coam Test Teardown
[1]CNP-SR-C-09-Manual_lock_unlock_cell_downtime_KPI#16a_KPI#16b
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${KPI16a_MAX}=    Set Variable    ${KPI['CB008457_KPI16a']['KPI16a_MAX']}
    set test variable    ${KPI16a_MAX}
    ${KPI16b_MAX}=    Set Variable    ${KPI['CB008457_KPI16b']['KPI16b_MAX']}
    set test variable    ${KPI16b_MAX}
    ${cell_list}    Get All Cell Id    cell_type=nr
    FOR    ${cell_index}    IN    @{cell_list}
        OAM_KPI_16a_16b_Manual_lock_unlock_cell_downtime_IMS    cell_index=${cell_index}
        ...    WebUI_reset_times=${KPI['CB008457_KPI16a']['lock_cell_times']}
    END
    [Teardown]    Run keywords    Save Coam Snapshot    timeout=${2400}    AND
    ...    SISO Coam Test Teardown
[1]CNP-SR-C-10-Manual_block_unblock_cell_downtime_KPI#17a_KPI#17b
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${KPI17a_MAX}=    Set Variable    ${KPI['CB008457_KPI17a']['KPI17a_MAX']}
    set test variable    ${KPI17a_MAX}
    ${KPI17b_MAX}=    Set Variable    ${KPI['CB008457_KPI17b']['KPI17b_MAX']}
    set test variable    ${KPI17b_MAX}
    ${cell_list}    Get All Cell Id    cell_type=nr
    FOR    ${cell_index}    IN    @{cell_list}
        OAM_KPI_17a_17b_Manual_block_unblock_cell_downtime_IMS    cell_index=${cell_index}
        ...    WebUI_reset_times=${KPI['CB008457_KPI17a']['cell_block_times']}
    END
    [Teardown]    Run keywords    Save Coam Snapshot    timeout=${2400}    AND
    ...    SISO Coam Test Teardown
[1]CNP-SR-C-07-Manual_capacity_module_reset_downtime_KPI#5
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${KPI5_MAX}=    Set Variable    ${KPI['CB008457_KPI5']['KPI5_MAX']}
    set test variable    ${KPI5_MAX}
    set test variable     ${KPI_intotall}    0
    #${bbmod_index_list}    Get All BBmod Index
    ${bbmod_index_list}=    Create List   ${1}
    run keyword if     '${testline_name}' == '7_5_UTE5G402T683'
    ...    Append To List    ${bbmod_index_list}   ${2}    ${4}
    FOR    ${baseband_index}    IN    @{bbmod_index_list}
        log to console    start test BBMOD-${baseband_index}
        OAM_KPI_5_capacity_module_reset_IMS    WebUI_reset_times=${KPI['CB008457_KPI5']['BBMOD_reset_times']}
        ...    baseband_index=${baseband_index}
    END
    [Teardown]    Run keywords    Save Coam Snapshot    timeout=${2400}    AND
    ...    SISO Coam Test Teardown
[1]CNP-SR-C-14-Energy_Consumption_Measurements
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Wait for New Interval BTS counters Generate    interval=15min
    Disable Energy Consumption Measurement Collectection    interval=15min
    Set Power meter    power_meter=true
    [Teardown]    Run keywords    Save Coam Snapshot    timeout=${2400}    AND
    ...    SISO Coam Test Teardown
#[1]CNP-SR-C-15-BTS_Reset_After_Plan_Activation_downtime_KPI#12
#    [Tags]    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    ${KPI12_MAX}=    Set Variable    ${KPI['CB008457_KPI12']['KPI12_MAX']}
#    ${KPI12_AVG}=    Set Variable    ${KPI['CB008457_KPI12']['KPI12_AVG']}
#    set test variable    ${KPI12_AVG}
#    set test variable    ${KPI12_MAX}
#    set test variable     ${KPI_intotall}    0
#    OAM_KPI_12_BTS_Reset_After_Plan_Activation_downtime_IMS
#    ...    WebUI_reset_times=${KPI['CB008457_KPI12']['WebUI_reset_times']}
#    [Teardown]    Run keywords    Collect Coam Snapshot    AND
#    ...    SISO Coam Test Teardown
[1]CNP-SR-C-17-Cell_Reset_downtime_KPI#19
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${KPI19_MAX}=    Set Variable    ${KPI['CB008457_KPI19']['KPI19_MAX']}
    ${KPI19_AVG}=    Set Variable    ${KPI['CB008457_KPI19']['KPI19_AVG']}
    set test variable    ${KPI19_AVG}
    set test variable    ${KPI19_MAX}
    set test variable     ${KPI_intotall}    0
    ${cell_index_list}    Get all cell index list
    FOR    ${cell_index}    IN    @{cell_index_list}
        OAM_KPI_19_cell_reset_IMS    WebUI_reset_times=${KPI['CB008457_KPI19']['WebUI_reset_times']}
        ...    cell_index=${cell_index}
    END
    [Teardown]    Run keywords    Save Coam Snapshot    timeout=${2400}    AND
    ...    SISO Coam Test Teardown
[1]CNP-SR-C-19-SCF_activation_with_cell_locking_downtime_KPI#15
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Run keyword if    '${testline_name}' == '7_5_UTE5G402T757'
        ...    SCF_activation_with_cell_locking_downtime_KPI#15_CNF_5G_25
    Run keyword if    '${testline_name}' == '7_5_UTE5G402T683'
        ...    SCF_activation_with_cell_locking_downtime_KPI#15_CNF_5G_11
    [Teardown]    Run keywords    Save Coam Snapshot    timeout=${2400}    AND
    ...    SISO Coam Test Teardown
