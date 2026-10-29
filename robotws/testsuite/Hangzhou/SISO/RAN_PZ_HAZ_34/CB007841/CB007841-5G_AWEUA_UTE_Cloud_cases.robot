# *** Settings ***
# # Documentation     author: Tian Chun
# # ...               contact: chun.tian@nokia-sbell.com
# # ...               squad group: MMW_SG_04
# 
# # Force Tags    SBTS00    RAN_5G    RAN_5G_TDD    CRT_UTE    CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABIOB1-B3_2xAWEUA_AEUD_ENB
# # ...      STATE_SW_UPLOADED    PY36
# 
# # Suite Setup       Case Suite Setup
# # Suite Teardown
# # Resource           ./Resources/CB007841_common_keywords.robot
# 
# 
# # *** Variable ***
# # ${TS_CASE_LOG_PATH}    ${OUTPUT_DIR}
# # ${SN_B_AWEUA}    L1214610629
# # ${SN_B_AEUD}    L1204104605
# # ${R_AWEUA}    AH204600118
# # ${R_AEUD}    L1192711970
# # ${RF_1}    RF1
# # ${RF_7}    RF7
# # ${TS_CASE_LOG_PATH}    ${OUTPUT_DIR}
# 
# # *** Test Cases ***
# # [1]CB007841-5G-C_1_BTS_startup_Cooled_SFP+or_SFP28_transceivers_support_for_FH_interface
# #     [Tags]    CRT_TRUNK    CRT_22R4
# #     [Setup]
# #     Check BTS is in On Air
# #     Check no unexpected alarm in WebEM
# #     ${snapshot_file}    Collect snapshot coam
# #     Run keyword and continue on failure     Extract logs from snapshot        snapshot_file=${snapshot_file}
# #     BTS detects cooled 7422 SFP+/SFP28    SN=${SN_B_AWEUA}    R_SN=${R_AWEUA}    RF=${RF_1}
# #     BTS detects cooled 7422 SFP+/SFP28    SN=${SN_B_AEUD}    R_SN=${R_AEUD}    RF=${RF_7}
# #     [Teardown]    CI_interface.Common Case Teardown
# 
# 
# # [1]CB007841-5G-E_1_The_BTS_shall_support_NIDD_parameter_EQM_APEQM-SFPOperatorMode_to_enable_and_disable_SFP+or_SFP28_compliance_validation
# #    [Tags]    CRT_TRUNK   CRT_22R4
# #     run keyword and continue on failure    Check no unexpected alarm in WebEM
# #     Delete sfp in sfpwhitelist
# #     Reset DU
# #     Check fault 4657 and check SFP status     SN=${SN_B_AWEUA}     RF=${RF_1}    R_SN=${R_AWEUA}
# #     Check fault 4657 and check SFP status     SN=${SN_B_AEUD}     RF=${RF_7}    R_SN=${R_AEUD}
# #     change sfpOperatorMode to true
# #     sleep    2s
# #     Check none fault 4657 and check SFP status    SN=${SN_B_AWEUA}    RF=${RF_1}    R_SN=${R_AWEUA}
# #     Check none fault 4657 and check SFP status    SN=${SN_B_AEUD}    RF=${RF_7}    R_SN=${R_AEUD}
# #     Check BTS is in On Air
# #     sleep    60s
# #     check SFP status once more    SN=${SN_B_AWEUA}    RF=${RF_1}   expected_status=Online    R_SN=${R_AWEUA}
# #     check SFP status once more    SN=${SN_B_AEUD}    RF=${RF_7}    expected_status=Online    R_SN=${R_AEUD}
# #     Reset DU
# #     Check none fault 4657 and check SFP status    SN=${SN_B_AWEUA}    RF=${RF_1}    R_SN=${R_AWEUA}
# #     Check none fault 4657 and check SFP status    SN=${SN_B_AEUD}    RF=${RF_7}    R_SN=${R_AEUD}
# #     sleep    5s
# #     change sfpOperatorMode to false
# #     sleep    2s
# #     Check fault 4657 and check SFP status     SN=${SN_B_AWEUA}     RF=${RF_1}    R_SN=${R_AWEUA}
# #     Check fault 4657 and check SFP status     SN=${SN_B_AEUD}     RF=${RF_7}    R_SN=${R_AEUD}
# #     sleep    60s
# #     Check BTS is in On Air
# #     check SFP status once more    SN=${SN_B_AWEUA}    RF=${RF_1}    expected_status=Degraded    R_SN=${R_AWEUA}
# #     check SFP status once more    SN=${SN_B_AEUD}    RF=${RF_7}    expected_status=Degraded    R_SN=${R_AEUD}
# #     [Teardown]    Case Teardown
# 
# # [1]CB007841-5G-E_2_BTS_startup_SFP+_or_SFP28_transceivers_support_for_fronthaul_and_backhaul_interface
# #     [Tags]    CRT_TRUNK    CRT_22R4
# #     [Setup]
# #     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
# #     [Teardown]    CI_interface.Common Case Teardown
# 
# # [1]CB007841-5G_1_BTS_startup_SFP_power_level_compatibility_validation_alarming_of_power_class_incompatibility
# #    [Tags]    CRT_TRUNK    CRT_22R4
# #     Check BTS is in On Air
# #     run keyword and continue on failure     Check no unexpected alarm in WebEM
# #     ${PowerL_file}    SSH To BTS And Collect sfp monitor log
# #     ${result_Level}    searchSfpPowerLevel     filename=${PowerL_file}
# #     should be true     ${result_Level}
# #     ${dump_file}    Collect dump_file And check power class    log_command=bsh 1:1    bget=bget 1:1
# #     ${result_class}     searchSfpPowercClass3    filename=${dump_file}   line1=6    line2=25
# #     should be true     ${result_class}
# #     ${dump_file}    Collect dump_file And check power class    log_command=bsh 2:1    bget=bget 1:1
# #     ${result_class}     searchSfpPowercClass3S    filename=${dump_file}
# #     should be true     ${result_class}
# #     ${dump_file}    Collect dump_file And check power class    log_command=bsh 3:2    bget=bget 1:1
# #     ${result_class}     searchSfpPowercClass3S    filename=${dump_file}
# #     should be true     ${result_class}
# #     [Teardown]    CI_interface.Common Case Teardown
# 
# 
# 
# 
# # *** Keywords ***
# # Case Suite Setup
# #        CI_interface.Common Suite Setup
# #        Input default SCF
