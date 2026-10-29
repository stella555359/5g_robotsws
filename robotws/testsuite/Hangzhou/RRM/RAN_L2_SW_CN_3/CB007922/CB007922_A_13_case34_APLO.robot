# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown  Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags        CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1    SBTS22R4
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    owner_pennwang
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}         11
# ${SCFC_NAME}      SCFC_case34.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_AEHC_2CELL_case34.xml
# ${WTS_NAME}       WTS_interband_intraMeNB.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${TTITRACE_TAG}    tti
# ${UE_A2_EVENT}    ue_measurement_send_nr event\=A2 id\=11 meas_id\=3 rs_type\=ssb scell\=9 scell_rsrp\=30
# 
# 
# *** Test Cases ***
# CB007922_case34_A_13_interL2RT_intraBand_NSA_Overwrite_PUCCH_F3_max_code_rate_when_Scell_is_added_or_released
#     Add GNB swconfig    0x340000:3
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Execute AP Command before attach
#     Airphone Nsa Attach     ${UE_ID}
#     Check coderate to zeroDot08
#     UE send A1 Event
#     Check coderate to zeroDot15
#     NSA send ue '${UE_ID}' mutiple trf '11' for each '175M' DL data
#     Wait Until Keyword Succeeds    120s    20s   Check addition counter is correct
#     Wait Until Keyword Succeeds    120s    20s   Check addition cell configure counter is correct
#     Wait Until Keyword Succeeds    30s    2s    Check tput is peak
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'${TTITRACE_TAG}'
#     Check ttitrace
#     UE send A2 Event trigger scell release
#     Check coderate to zeroDot08 again
#     Airphone NSA Detach    ue_id=${UE_ID} 
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# 
# *** Keywords ***
# Check tput is peak
#     Check NSA ue '11' 'pcell' dl throught should '> 700000'
#     Check NSA ue '11' 'scell' dl throught should '> 700000'
# 
# Check addition counter is correct
#     Check pm counter M55115C00015 in cell 1 is expected == 1
#     Check pm counter M55118C02000 in cell 1 is expected == 1
#     Check pm counter M55118C03000 in cell 1 is expected == 1
# 
# Check addition cell configure counter is correct
#     Check pm counter M55118C04000 in cell 1 is expected == 60
#     Check pm counter M55118C05000 in cell 2 is expected == 60
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# UE send A1 Event
#     Airphone Measurement Send Nr    id=11    meas_id=2    event=A1    rs_type=ssb    srsrp_nr=70
# 
# UE send A2 Event trigger scell release
#     airphone_execute_egate_command    ${UE_A2_EVENT}
#     Check Scell release
# 
# Check Scell release
#     Wait '30s' for stabible
#     airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/release    unzip=TRUE
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scell_release.ini    u    save_log_directory=${TEST_LOG_DIRECTORY()}/All/release
# 
# Check scell add succesfully
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_scelladd.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check coderate to zeroDot08
#     Wait '2s' for stabible
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/coderate1   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_coderate_zeroDot08.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/coderate1
# 
# Check coderate to zeroDot15
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/coderate2   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_coderate_zeroDot15.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/coderate2
# 
# Check coderate to zeroDot08 again
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/coderate3   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_coderate_zeroDot08.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/coderate3
