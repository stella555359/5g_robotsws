*** Settings ***
Documentation    This is keywords for CB009576-X cases
...              Please do not modify the file without notification to author
...              Author:yue.2.liu@nokia-sbell.com

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     ${BASIC_PATH_5G}/General_Stability_Test_Case.robot
Resource     ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource     ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource     ${BASIC_PATH_COMMON}/General_KPI_Test_Case.robot
Resource     ${BASIC_PATH_COMMON}/Manual_SiSo_SM_BTS_Block_Site.robot
Library      taf.rfrl.uuf4all.resources.python.uuf_rfrl_oam_kpi
Library      taf.fdsw.rc    WITH NAME    fdswrc
Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Library      taf.ul.oam_kpi_calculations    WITH NAME    oam_kpi_calculations
Library      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/None_Feature_SG5/OAMKPI/5GC002479/Resources/ims_keywords.py
Library      taf.ul.oam_kpi_calculations.utilities
Library      ./CB009576_X_lib.py
Resource     taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource     taf/rfrl/bts/robot/common/gnb_cell.robot
Resource     taf/rfrl/bts/robot/common/gnb_ru.robot
Resource     taf/rfrl/bts/robot/common/gnb_log.robot


*** Variables ***
@{sw_upgrade_kpis}    kpi4
@{sw_upgrade_kpis_intra}    kpi2c    kpi2d
${package_link}       https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/
${BTS_HOST_IP}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${host_ip}                     ${tl.gnbs[0].cu.oam_http_connection_details.addr}


*** Keywords ***
CB009576-SR-X_BTS_block_unblock _sucess_ratio
    General_KPI_Test_Case    case_name=Block_Site_through_WebEM    times=${20}    pass=${20}
CB009576-SR-X_RU_Reset_sucess_ratio
    General_KPI_Test_Case    case_name=General_SiSo_RF_module_reset_from_GUI_check_alarm    times=${20}    pass=${20}
CB009576-SR-X_Cell_block_unblock_sucess_ratio
    ${fault_49}    Create Dictionary    faultId=${49}
    Append To List     ${ALLOWED_HISTORY_FAULT}    ${fault_49}
    Set Suite Variable    ${ALLOWED_HISTORY_FAULT}
    General_KPI_Test_Case    case_name=Block_and_Unblock_Cell_Webem    times=${20}    pass=${20}
#CB009576-SR-X_Configuration_Reset_sucess_ratio
CB009576-SR-X_KPI1a_Site_Reset_duration
    General_KPI_Test_Case    case_name=Site_Reset_through_WebEM_KPI1a    times=${20}    pass=${20}
CB009576-SR-X_KPI3_Power_On_Reset_duration
    General_KPI_Test_Case    case_name=Power_On_Reset_KPI3    times=${20}    pass=${20}
CB009576-SR-X_KPI9_10_RAT_Reset_duration
    General_KPI_Test_Case    case_name=RAT_Reset_KPI9_10    times=${20}    pass=${20}
CB009576-SR-X_KPI4_Software_Upgrade_duration
    General_KPI_Test_Case    case_name=Software_Upgrade_Kpi4    times=${20}    pass=${20}
CB009576-SR-X_KPI2c_d_Software_Upgrade_duration
    General_KPI_Test_Case    case_name=Software_Upgrade_Kpi2c_d    times=${1}    pass=${1}

Block_Site_through_WebEM
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    Manual_SiSo_SM_BTS_Block_Site
    check no unexpected alarm
    [Teardown]    selenium logout and close browser
Block_and_Unblock_Cell_Webem
    General_SiSo_Cell_block_and_unblock    with_call=${False}
    check no unexpected alarm    is_check_historyalarm=${True}
Site_Reset_through_WebEM_KPI1a
    [Arguments]    ${kpi1a_target}=${420}
    oam_kpi_calculations.clear_results
    wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
    oam_kpi_calculations.save_search_start_timestamp
    selenium_coam.reset_site
    selenium logout and close browser
    sleep    1min
    wait until keyword succeeds    10min    10s    Check all cells Info Should Be On Air
    oam_kpi_calculations.save_search_end_timestamp
    check no unexpected alarm    is_check_historyalarm=${True}
    Collect IMS File    log_dir=${SAVE LOG DIRECTORY}/loop_ims2/
    oam_kpi_calculations.calculate_kpi1a    ims_file_path=${ims_file}
    Run Keyword and Continue on Failure  oam_kpi_calculations.save_results_to_file
    ...    file_path=${SAVE LOG DIRECTORY}/loop_ims2/results_${ims_file_date}.json
    ${result}    oam_kpi_calculations.get_results
    ${kpi_avg}=    oam_kpi_calculations.get_average_results    kpi_name=kpi1a
    Should Be True    ${kpi_avg}<${kpi1a_target}
Power_On_Reset_KPI3
    [Arguments]    ${kpi3_target}=${420}
    oam_kpi_calculations.clear_results
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
    Perform Site Power Off
    sleep    30s
    ${bts_power_on_timestamp}     DateTime.Get current date    time_zone=UTC
    Perform Site Power On
    wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    sleep    1min
    wait until keyword succeeds    10min    10s    Check all cells Info Should Be On Air
    oam_kpi_calculations.save_search_end_timestamp
    sleep    5s
    check no unexpected alarm
    Collect IMS File    log_dir=${SAVE LOG DIRECTORY}/loop_ims2/
    oam_kpi_calculations.calculate_kpi3    ims_file_path=${ims_file}    start_point_timestamp=${bts_power_on_timestamp}
    Run Keyword and Continue on Failure  oam_kpi_calculations.save_results_to_file
    ...    file_path=${SAVE LOG DIRECTORY}/loop_ims2/results_${ims_file_date}.json
    ${result}    oam_kpi_calculations.get_results
    ${kpi_avg}=    oam_kpi_calculations.get_average_results    kpi_name=kpi3
    Should Be True    ${kpi_avg}<${kpi3_target}
RAT_Reset_KPI9_10
    [Arguments]    ${kpi10_target}=${420}
    oam_kpi_calculations.clear_results
    wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
    oam_kpi_calculations.save_search_start_timestamp
    selenium_coam.reset_nr
    selenium logout and close browser
    sleep    2min
    wait until keyword succeeds    10min    10s    Check all cells Info Should Be On Air
    oam_kpi_calculations.save_search_end_timestamp
    check no unexpected alarm    is_check_historyalarm=${True}
    Collect IMS File    log_dir=${SAVE LOG DIRECTORY}/loop_ims2/
    oam_kpi_calculations.calculate_kpi10    ims_file_path=${ims_file}
    Run Keyword and Continue on Failure  oam_kpi_calculations.save_results_to_file
    ...    file_path=${SAVE LOG DIRECTORY}/loop_ims2/results_${ims_file_date}.json
    ${result}    oam_kpi_calculations.get_results
    ${kpi_avg}=    oam_kpi_calculations.get_average_results    kpi_name=kpi10
    Should Be True    ${kpi_avg}<${kpi10_target}
Software_Upgrade_Kpi4
    [Arguments]    ${New_SW_version}=SBTS00_ENB_9999_240401_000002     ${kpi4_target}=${2100}
    oam_kpi_calculations.clear_results
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
    gNB SW Upgrade to new version    New_SW_version=${New_SW_version}
    sleep    3min
    check no unexpected alarm
    Collect IMS File    log_dir=${SAVE LOG DIRECTORY}/loop_ims2/SW_upgrade
    ${ims_sesion_file_path}    get_last_disconnected_ims_log     log_dir=${SAVE LOG DIRECTORY}/loop_ims2/SW_upgrade
    ${all_ims}    Create List    ${ims_sesion_file_path}    ${ims_file}
    oam_kpi_calculations.calculate_kpis  kpi_names=${sw_upgrade_kpis}   ims_file_path=${all_ims}
    oam_kpi_calculations.save_results_to_file  file_path=${OUTPUT DIR}/kpi_upgrade.json
    ${kpi4_avg}=    oam_kpi_calculations.get_average_results    kpi_name=kpi4
    Should Be True    ${kpi4_avg}<${kpi4_target}
    gNB SW Upgrade to new version    New_SW_version=SBTS00_ENB_9999_240324_000018
    sleep    1min
    gNB SW Upgrade to new version    New_SW_version=SBTS00_ENB_9999_240325_000018
    sleep    10s
Software_Upgrade_Kpi2c_d
    [Arguments]    ${New_SW_version}=SBTS24R1_ENB_0000_001346_000000     ${kpi2c_target}=${600}    ${kpi2d_target}=${600}
    gNB SW rollback
    sleep    1s
    oam_kpi_calculations.clear_results
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
    gNB SW Upgrade to new version    New_SW_version=${New_SW_version}
    sleep    3min
    check no unexpected alarm
    ${last_disconnect_ims_path}    get_fourth_parent_directory    dir_path=${OUTPUT_DIR}
    ${ims_sesion_file_path}  get_last_disconnected_ims_log  log_dir=${last_disconnect_ims_path}
    ${ims_file_path}  gnblog.collect_im_snapshot
    ${all_ims}    Create List  ${ims_sesion_file_path}  ${ims_file_path}
    oam_kpi_calculations.calculate_kpis  kpi_names=${sw_upgrade_kpis_intra}   ims_file_path=${all_ims}
    oam_kpi_calculations.save_results_to_file    file_path=${OUTPUT DIR}/kpi_upgrade.json
    ${kpi2c_avg}=    oam_kpi_calculations.get_average_results    kpi_name=kpi2c
    ${kpi2d_avg}=    oam_kpi_calculations.get_average_results    kpi_name=kpi2d
    Should Be True    ${kpi2c_avg}<${kpi2c_target}
    Should Be True    ${kpi2d_avg}<${kpi2d_target}
    log to console    \n prepare to l3call
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call   cell_list=${cell_list}    with_peak=${False}    duration=${300}
Collect IMS File
    [Arguments]    ${log_dir}
    ${ims_file_date}    DateTime.Get current date    time_zone=UTC
    coam.collect_infomodel_log_from_current_session
    ...    target_file_name=${log_dir}/${ims_file_date}.ims2
    ...    timeout=300
    ...    alias=KPI_IMS
    Set Test Variable    ${ims_file}    ${log_dir}/${ims_file_date}.ims2
    Set Test Variable    ${ims_file_date}
check no unexpected alarm
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM    ${is_check_historyalarm}=${FALSE}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=${connection}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    run keyword if    ${is_check_historyalarm}    should be true    ${history_alarm_status}
    #[Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
gNB SW Upgrade to new version
    [Arguments]    ${New_SW_version}    ${gnb_index}=0    ${connection}=GNB_OAM
    log to console    OLD_SW_PKG:${Active_SW_version}, NEW_SW_PKG:${New_SW_version}
    #${NEW_SW_PKG}    Download SW    SW=${New_SW_version}
    #${upgrade_package_path}=    Download SW Build to UTE VM
    #...    package_full_link=${package_link}/SBTS24R1/${New_SW_version}/${New_SW_version}_release_BTSSM_downloadable_A54.zip
    log to console    start deploy to NEW_SW_PKG:${New_SW_version}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Perform SW Update    package=/home/ute/TA/Sw_build/${New_SW_version}_release_BTSSM_downloadable_A54.zip
    sleep    2min
    wait until keyword succeeds   10min    10s    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    wait until keyword succeeds   10min    30s    Check all cells Info Should Be On Air
gNB SW rollback
     [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM
    log to console    start to rollback
    wait until keyword succeeds    1min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    selenium_coam.software_rollback
    sleep    8min
    wait until keyword succeeds   10min    10s    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    wait until keyword succeeds   10min    10s    Verify all cells should be onair
    [Teardown]    selenium logout and close browser
CB009576-SR--J_FDSW_service_buttom_reset
    ${fault_4681}    Create Dictionary    faultId=${4681}
    Append To List     ${ALLOWED_FAULT}    ${fault_4681}
    set test variable    ${ALLOWED_FAULT}
    log to console    ${ALLOWED_FAULT}
    General_KPI_Test_Case    case_name=J_FDSW_service_buttom_reset    times=${5}    pass=${5}
J_FDSW_service_buttom_reset
    [Arguments]    ${ip_address}=${host_ip}   ${port}=443    ${username}=Nemuadmin   ${password}=nemuuser
    ...     ${auto_discover}=True    ${secure}=True    ${name}=default
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    selenium_coam.configuration_reset
    sleep    10s
    wait until keyword succeeds     10min    30s     fdswrc.connect to    ip_address=${ip_address}   port=${port}    username=${username}
    ...    password=${password}    auto_discover=${auto_discover}    secure=${secure}    name=${name}
    ${activeslot_id}    fdswrc.get_active_sw_partition
    ${reset_option}    fdswrc.get_available_reset_options    slot_id=${activeslot_id}
    fdswrc.software_rollback    sw_slot_id=${activeslot_id}    reset_type=${reset_option[0]}
    sleep    300s
    selenium logout and close browser
    wait until keyword succeeds     20min    1min    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    check no unexpected alarm
    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    wait until keyword succeeds     20min    1min    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    check no unexpected alarm    is_check_historyalarm=${True}
    [Teardown]    selenium logout and close browser
General_SiSo_RF_module_reset_from_GUI_check_alarm
    General_SiSo_RF_module_reset_from_GUI
    check no unexpected alarm    is_check_historyalarm=${True}