*** Settings ***
Force Tags    PY36    STATE_SW_UPLOADED
Documentation     author: Tian Chun
...               contact: chun.tian@nokia-sbell.com
...               squad group: MMW_SG_04
Suite Setup       Case Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown


Resource           ./Resources/CB007841_common_keywords.robot
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variable ***
${TS_CASE_LOG_PATH}    ${OUTPUT_DIR}
${SN_B_AWEUA}    L1214610629
${SN_B_AEUD}    L1204104605
${R_AWEUA}    AH204600118
${R_AEUD}    L1193108313
${RF_1}    RF1
${RF_7}    RF7
#${TS_CASE_LOG_PATH}    ${OUTPUT_DIR}
${T7422_scf_path}          ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T7422/

#SFP SN
${SN_B_AWEUA_RF1}    OESLKR19360383
${SN_B_AEUD_RF7}     OESLKR19360395
${SN_R_AWEUA_RF1}    OESLKR19280335
${SN_R_AEUD_RF7}     OESLKR19280353
${SN_EIF}            FR193807252

*** Test Cases ***
[1]CB007841-5G-C_1_BTS_startup_Cooled_SFP+or_SFP28_transceivers_support_for_FH_interface
    [Tags]    CRT_TRUNK    CRT_22R4
    [Setup]    robot_common_operations.Common case Setup
    Check BTS is in On Air
    Check no unexpected alarm in WebEM
    ${snapshot_file}    Collect snapshot coam
    Run keyword and continue on failure     Extract logs from snapshot        snapshot_file=${snapshot_file}
    BTS detects cooled 7422 SFP+/SFP28_2
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown

[2]CB007841-5G-C_1_BTS_startup_Cooled_SFP+or_SFP28_transceivers_support_for_FH_interface
    [Tags]        CRT_22R4
    [Setup]    robot_common_operations.Common case Setup
    Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown

[1]CB007841-5G-E_1_The_BTS_shall_support_NIDD_parameter_EQM_APEQM-SFPOperatorMode_to_enable_and_disable_SFP+or_SFP28_compliance_validation
    [Tags]    CRT_TRUNK   CRT_22R4
    [Setup]    robot_common_operations.Common case Setup
    run keyword and continue on failure    Check no unexpected alarm in WebEM
    Delete sfp in sfpwhitelist
    Reset DU
    sleep    120s
    @{SFP_List}     Create List    ${SN_EIF}
    ...    ${SN_B_AWEUA_RF1}     ${SN_R_AWEUA_RF1}    ${SN_B_AEUD_RF7}    ${SN_R_AEUD_RF7}
    Check fault 4657 and SFP status_2     Checked_SFP_LIST=${SFP_List}    status=Degraded
    change sfpOperatorMode to true
    sleep    2s
    Check fault 4657 and SFP status_2     Checked_SFP_LIST=${SFP_List}    status=Online
    Check BTS is in On Air
    sleep    60s
    Check fault 4657 and SFP status_2     Checked_SFP_LIST=${SFP_List}    status=Online
    Reset DU
    sleep    120s    
    Check fault 4657 and SFP status_2     Checked_SFP_LIST=${SFP_List}    status=Online
    sleep    5s
    change sfpOperatorMode to false
    sleep    2s
    Check fault 4657 and SFP status_2     Checked_SFP_LIST=${SFP_List}    status=Degraded
    sleep    60s
    Check BTS is in On Air
    Check fault 4657 and SFP status_2     Checked_SFP_LIST=${SFP_List}    status=Degraded
    [Teardown]    Run Keywords    Case Teardown    AND    robot_common_operations.Common Case Teardown

[1]CB007841-5G-E_2_BTS_startup_SFP+_or_SFP28_transceivers_support_for_fronthaul_and_backhaul_interface
    [Tags]    CRT_TRUNK    CRT_22R4
    [Setup]    robot_common_operations.Common case Setup
    Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown

[2]CB007841-5G-E_2_BTS_startup_SFP+or_SFP28_transceivers_support_for_fronthaul_and_backhaul_interface
    [Tags]       CRT_22R4
    [Setup]    robot_common_operations.Common case Setup
    Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown

[2]CB007841-5G-E_1_The_BTS_shall_support_NIDD_parameter_EQM_APEQM-SFPOperatorMode_to_enable_and_disable_SFP+or_SFP28_compliance_validation
    [Tags]       CRT_22R4
    [Setup]    robot_common_operations.Common case Setup
    Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown

[1]CB007841-5G-D_1_BTS_startup_SFP+_or_SFP28_transceivers_cold_start_up_support_for_backhaul_interface
    [Tags]       CRT_22R4
    [Setup]    robot_common_operations.Common case Setup
    Check BTS is in On Air
    run keyword and continue on failure     Check no unexpected alarm in WebEM
    ${snapshot_file}    Collect snapshot coam
    Extract logs from snapshot        snapshot_file=${snapshot_file}
    BTS 7422 detects cold SFP+/SFP28 startup and compare the temperature    SN=${SN_B_AWEUA}    RF=${RF_1}
    ...   R_SN=${R_AWEUA}        index=${1}
    BTS 7422 detects cold SFP+/SFP28 startup and compare the temperature    SN=${SN_B_AEUD}    RF=${RF_7}
    ...   R_SN=${R_AEUD}       index=${3}
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown

[2]CB007841-5G-D_1_BTS_startup_SFP+_or_SFP28_transceivers_cold_start_up_support_for_backhaul_interface
    [Tags]        CRT_22R4
    [Setup]    robot_common_operations.Common case Setup
   Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown

[1]CB007841-5G_1_BTS_startup_SFP_power_level_compatibility_validation_alarming_of_power_class_incompatibility
    [Tags]    CRT_TRUNK    CRT_22R4
    [Setup]    robot_common_operations.Common case Setup
    Check BTS is in On Air
    run keyword and continue on failure     Check no unexpected alarm in WebEM
    ${PowerL_file}    SSH To BTS And Collect sfp monitor log
    ${result_Level}    searchSfpPowerLevel     filename=${PowerL_file}
    should be true     ${result_Level}
    ${dump_file}    Collect dump_file And check power class    log_command=bsh 1:1    bget=bget 1:1
    ${result_class}     searchSfpPowercClass3    filename=${dump_file}   line1=6    line2=25
    should be true     ${result_class}
    ${dump_file}    Collect dump_file And check power class    log_command=bsh 2:1    bget=bget 1:1
    ${result_class}     searchSfpPowercClass3S    filename=${dump_file}
    should be true     ${result_class}
    ${dump_file}    Collect dump_file And check power class    log_command=bsh 3:2    bget=bget 1:1
    ${result_class}     searchSfpPowercClass3S    filename=${dump_file}
    should be true     ${result_class}
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown

[2]CB007841-5G_1_BTS_startup_SFP_power_level_compatibility_validation_alarming_of_power_class_incompatibility
   [Tags]      CRT_22R4
    [Setup]    robot_common_operations.Common case Setup
   Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown

[4]CB009260-SR_3_BTS_startup_SFP_power_level_3-4_compatibility_validation
   [Tags]      CRT_23R3
    [Setup]    robot_common_operations.Common case Setup
   Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown

[1]CB009260-SR_3_BTS_startup_SFP_power_level_3-4_compatibility_validation
   [Tags]      CRT_23R3
    [Setup]    robot_common_operations.Common case Setup
   Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown

[2]CB009260-SR_3_BTS_startup_SFP_power_level_3-4_compatibility_validation
   [Tags]      CRT_23R3
    [Setup]    robot_common_operations.Common case Setup
   Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown



*** Keywords ***
Case Suite Setup
    CI_interface.Common Suite Setup
    CB007841 Input default SCF
    robot_common_operations.Common Suite Setup

CB007841 Input default SCF
    [Timeout]  20 min
    [Arguments]      ${timeout}=10 min
    ${connection}    CB007308-5G-AB_common_keywords_AEQE.Connect to DU
    ${version}    coam.get_sw_version    connection=${connection}
#    ${version_list}    split string    ${version}
#    ${if_common_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS23R2
#    ${default_scf}    set variable if    ${if_common_load}   ${T7422_scf_path}SCF_SBTS23R2_7841.xml
#   ...    ${T7422_scf_path}SCF_Trunk_7841.xml
    ${version_list}    split string    ${version}    separator=_
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${version_scf}    set variable if    ${if_common_load}    SBTS00    ${version_list[0]}
    ${default_scf}    set variable    ${T7422_scf_path}SCF_${version_scf}_7841.xml
    set suite variable    ${default_scf}
    BuiltIn.Log    \n Input default SCF \n    console=yes
    run keyword and ignore error    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}
    BuiltIn.Log    \n wait until gnb cell on air \n    console=yes
    wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${connection}
    wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${connection}
    [Teardown]     CB007308-5G-AB_common_keywords_AEQE.Disconnect from DU
