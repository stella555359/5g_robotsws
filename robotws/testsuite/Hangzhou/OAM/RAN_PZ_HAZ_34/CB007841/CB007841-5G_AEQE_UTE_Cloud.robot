# *** Settings ***
# Documentation     author: chun.tian
# ...               contact: chun.tian@nokia-sbell.com
# ...               squad group: MMW_SG_04
# Suite Setup    Case Suite Setup
# Suite Teardown    Case Suite Teardown
# 
# Resource          ../CB007308-5G-AB/Resources/CB007308-5G-AB_FID4657_keywords_AEQE.robot
# Resource          ../CB007308-5G-AB/Resources/CB007308-5G-AB_common_keywords_AEQE.robot
# Resource           ./Resources/CB007841_common_keywords.robot
# Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Force Tags        SBTS00    RAN_5G    RAN_5G_TDD    CRT_UTE    	CLOUD_5G_CLASSICAL_ANDROID_SA_ASOE_AEQE    STATE_SW_UPLOADED
# ...    PY36
# 
# 
# *** Variable ***
# ${TS_CASE_LOG_PATH}    ${OUTPUT_DIR}
# ${T733_scf_path}       ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T733/
# 
# *** Test Cases ***
# [1]CB007841-5G-C_1_AEQE_BTS startup Cooled SFP+ or SFP28 transceivers support for FH interface
#     [Tags]    CRT_TRUNK    CRT_22R4
#     [Setup]    Case Setup
#     CB007308-5G-AB_common_keywords_AEQE.Check BTS is in On Air
#     run keyword and continue on failure     Check no unexpected alarm in WebEM
#     ${snapshot_file}    Collect snapshot coam
#     Extract logs from snapshot        snapshot_file=${snapshot_file}
#     CB007308-5G-AB_common_keywords_AEQE.BTS detects cooled SFP+/SFP28
#     [Teardown]    Case_Teardown_7841
# 
# [1]CB007841-5G-E_1_AEQE_The_BTS_shall_support_NIDD_parameter_EQM_APEQM-SFPOperatorMode_to_enable_and_disable_SFP+or_SFP28_compliance_validation
#     [Tags]    CRT_TRUNK    CRT_22R4
#     [Setup]    Case Setup
#     CB007308-5G-AB_FID4657_keywords_AEQE.Set SFPWhiteList File Name
#     CB007308-5G-AB_FID4657_keywords_AEQE.Create dir
#     CB007308-5G-AB_FID4657_keywords_AEQE.Download whitelist file
#     CB007308-5G-AB_FID4657_keywords_AEQE.Delete parameter in sfpwhitelist    sfp_model=AOSD
#     CB007308-5G-AB_FID4657_keywords_AEQE.Delete parameter in sfpwhitelist    sfp_model=AOZEB
#     CB007308-5G-AB_FID4657_keywords_AEQE.Delete parameter in sfpwhitelist    sfp_model=AOZEA
#     CB007308-5G-AB_FID4657_keywords_AEQE.Delete parameter in sfpwhitelist    sfp_model=FOTB
#     CB007308-5G-AB_FID4657_keywords_AEQE.Upload whitelist file
#     ...    upload_whitelist_path=${SFPwhitelist_PATH}${SFPwhitelist_NAME}
#     CB007308-5G-AB_FID4657_keywords_AEQE.Reset DU
#     sleep    10s
#     run keyword and continue on failure    CB007308-5G-AB_FID4657_keywords_AEQE.check fault 4657
#     ${i}    CB007308-5G-AB_FID4657_keywords_AEQE.Get EIF1 distname
#     ${ii}    CB007308-5G-AB_FID4657_keywords_AEQE.Get RF1 distname
#     ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}
#     ...    CB007308-5G-AB_FID4657_keywords_AEQE.Get Availability status for SFP    i=${i}    ii=${ii}
#     CB007308-5G-AB_FID4657_keywords_AEQE.Check SFP availability status
#     ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
#     ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Degraded
#     CB007308-5G-AB_FID4657_keywords_AEQE.change sfpOperatorMode to true
#     sleep    2s
#     run keyword and continue on failure    CB007308-5G-AB_FID4657_keywords_AEQE.check none fault 4657
#     ${i}    CB007308-5G-AB_FID4657_keywords_AEQE.Get EIF1 distname
#     ${ii}    CB007308-5G-AB_FID4657_keywords_AEQE.Get RF1 distname
#     ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}
#     ...    CB007308-5G-AB_FID4657_keywords_AEQE.Get Availability status for SFP    i=${i}    ii=${ii}
#     CB007308-5G-AB_FID4657_keywords_AEQE.Check SFP availability status
#     ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
#     ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Online
#     sleep    60s
#     ${i}    CB007308-5G-AB_FID4657_keywords_AEQE.Get EIF1 distname
#     ${ii}    CB007308-5G-AB_FID4657_keywords_AEQE.Get RF1 distname
#     ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}
#     ...    CB007308-5G-AB_FID4657_keywords_AEQE.Get Availability status for SFP    i=${i}    ii=${ii}
#     CB007308-5G-AB_FID4657_keywords_AEQE.Check SFP availability status
#     ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
#     ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Online
#     CB007308-5G-AB_FID4657_keywords_AEQE.Reset DU
#     run keyword and continue on failure    CB007308-5G-AB_FID4657_keywords_AEQE.check none fault 4657
#     sleep    10s
#     ${i}    CB007308-5G-AB_FID4657_keywords_AEQE.Get EIF1 distname
#     ${ii}    CB007308-5G-AB_FID4657_keywords_AEQE.Get RF1 distname
#     ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}
#     ...    CB007308-5G-AB_FID4657_keywords_AEQE.Get Availability status for SFP    i=${i}    ii=${ii}
#     CB007308-5G-AB_FID4657_keywords_AEQE.Check SFP availability status
#     ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
#     ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Online
#     sleep    5s
#     CB007308-5G-AB_FID4657_keywords_AEQE.change sfpOperatorMode to false
#     sleep    20s
#     run keyword and continue on failure    CB007308-5G-AB_FID4657_keywords_AEQE.check fault 4657
#     sleep    2s
#     ${i}    CB007308-5G-AB_FID4657_keywords_AEQE.Get EIF1 distname
#     ${ii}    CB007308-5G-AB_FID4657_keywords_AEQE.Get RF1 distname
#     ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}
#     ...    CB007308-5G-AB_FID4657_keywords_AEQE.Get Availability status for SFP    i=${i}    ii=${ii}
#     CB007308-5G-AB_FID4657_keywords_AEQE.Check SFP availability status
#     ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
#     ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Degraded
#     sleep    60s
#     ${i}    CB007308-5G-AB_FID4657_keywords_AEQE.Get EIF1 distname
#     ${ii}    CB007308-5G-AB_FID4657_keywords_AEQE.Get RF1 distname
#     ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}
#     ...    CB007308-5G-AB_FID4657_keywords_AEQE.Get Availability status for SFP    i=${i}    ii=${ii}
#     CB007308-5G-AB_FID4657_keywords_AEQE.Check SFP availability status
#     ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
#     ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Degraded
#     [Teardown]    Case Teardown
# 
# [1]CB007841-5G-E_2_BTS_startup_SFP+_or_SFP28_transceivers_support_for_fronthaul_and_backhaul_interface
#     [Tags]      CRT_22R4
#     [Setup]    Case Setup
#     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
#     [Teardown]    Case Teardown
# 
# [1]CB007841-5G-A_1_AEQE_BTS_startup_SFP_power_level_compatibility_validation_alarming_of_power_class_incompatibility
#     [Tags]    CRT_TRUNK    CRT_22R4
#     [Setup]    Case Setup
#     CB007308-5G-AB_common_keywords_AEQE.Check BTS is in On Air
#     run keyword and continue on failure     Check no unexpected alarm in WebEM
#     ${PowerL_file}    SSH To BTS And Collect sfp monitor log
#     ${result_Level}    searchSfpPowerLevel     filename=${PowerL_file}
#     should be true     ${result_Level}
#     ${dump_file}    Collect dump_file And check power class
#     ${result_class}     searchSfpPowercClass3    filename=${dump_file}
#     should be true     ${result_class}
#     [Teardown]    Case_Teardown_7841
# 
# #CB009260-A
# [1]CB009260-SR_3_BTS_startup_SFP_power_level_3-4_compatibility_validation
#    [Tags]      CRT_Trunk
#    [Setup]    Case Setup
#    Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
#    [Teardown]    Case_Teardown_7841
# 
# [1]CB007841-5G-D_1_AEQE_BTS_startup_SFP+_or_SFP28_transceivers_cold_start_up_support_for_backhaul_interface
#     [Tags]     CRT_22R4
#     [Setup]    Case Setup
#     CB007308-5G-AB_common_keywords_AEQE.Check BTS is in On Air
#     run keyword and continue on failure     Check no unexpected alarm in WebEM
#     ${snapshot_file}    Collect snapshot coam
#     Extract logs from snapshot        snapshot_file=${snapshot_file}
#     CB007308-5G-AB_common_keywords_AEQE.BTS detects cold SFP+/SFP28 startup and compare the temperature
#     [Teardown]    Case_Teardown_7841
# 
# 
# *** Keywords ***
# Case Suite Setup
#     CI_interface.Common Suite Setup
#     robot_common_operations.Common Suite Setup
#     T733 Input default SCF
# 
# Case Suite Teardown
#     CI_interface.Common Case Teardown
#     robot_common_operations.Common Suite Teardown
# 
# Case Setup
#     robot_common_operations.Common case Setup
# 
# Case_Teardown_7841
#     CI_interface.Common Case Teardown
#     robot_common_operations.Common case Teardown
# 
# T733 Input default SCF
#     [Timeout]  20 min
#     [Arguments]      ${timeout}=10 min
#     ${connection}    CB007308-5G-AB_common_keywords_AEQE.Connect to DU
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${version_list}    split string    ${version}
#     ${if_common_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS22R4
#     ${default_scf}    set variable if    ${if_common_load}   ${T733_scf_path}SCF_SBTS22R4_7841.xml
#     ...    ${T733_scf_path}SCF_Trunk_7841.xml
#     set suite variable    ${default_scf}
#     BuiltIn.Log    \n Input default SCF \n    console=yes
#     run keyword and ignore error    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}
#     BuiltIn.Log    \n wait until gnb cell on air \n    console=yes
#     wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${connection}
#     wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${connection}
#     [Teardown]     CB007308-5G-AB_common_keywords_AEQE.Disconnect from DU
