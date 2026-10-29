*** Settings ***
Test Timeout      60 minutes
Suite Setup       Sg13 Common Suite Setup
Suite Teardown    Sg13 Common Suite Teardown
Test Setup    SG13 Common Test Setup    ${allowed_faults_ids}
Test Teardown    SG13 Common Test Teardown
Force Tags    Qualmn    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEHC_VEFHAZ4
Documentation     CB013071 case01   author  menzheng
...    b1a74f66  ue1
...    6fbcbb79  ue2
...    92683215  ue3
...    ca3e3465  ue4

#Library     ../Resources/Reorder_CSV.py
#Library     ../Resources/CB009235_check.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/common_resource/common_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/internal_resource/internal_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    nrdim_get_tput
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/mcs_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB013071/Resources/CB013071_common_keywords.robot

*** Variables ***
${CONFIG_DIR_PATH}         ${CURDIR}/config
@{LOG_NAME_LIST}    gnb_snapshot
${ATT_FILE_PATH}    att_case06
${PHASE_FILE_PATH}    phase_case06
${UE_ID}       1
${PORT}    5002
${UE_NUM_SA}         1
${TS_CASE_LOG_PATH}      ${TEST_LOG_DIRECTORY()}/All
${scfc_configuration}                 ${CURDIR}/config/ASIB_ABIO_AVQL_3cell_1302.xml
${swconfig_file}                      ${CURDIR}/config/swconfig.txt

${NRCELL1_CELLID}          9201
${NRCELL2_CELLID}          9202
${NRCELL3_CELLID}          9203
${allowed_faults_ids}    7107,7307

*** Test Cases ***
CB013071_A_B01_CASE001_64TRX_single_band_SubbandBm_3CC_basic
    Step1:Commission the above configuration on WebUI
    step2:attach UEs in cell1 and check logs
    #step3:attach UEs in cell2 and check logs by counter
    #step4:attach UEs in cell3 and check logs by counter


*** Keywords ***
Step1:Commission the above configuration on WebUI
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Start Collecting GNB Syslog in 'before_onair' File
    Log To Console    Modify GNB swconfig
#    Modify GNB swconfig
    Qualcom detach    Detach_UE_num=2
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}/SCFC_newest.xml
    copy_file       ${scfc_configuration}    ${scfc_path}
    Perform Full Commission       ${scfc_path}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    Get theoretical throughput from nrdim    SCF_Path=${scfc_path}
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    set suite variable    ${parent_dir}
    Qualcom detach    Detach_UE_num=4
    [Teardown]    Stop Collecting GNB Syslog in 'before_onair' File

step2:attach UEs in cell1 and check logs
    Log To Console   \n-------------step2:attach UEs in cell1 and check logs--------------
    Start capture only gnb syslog in 'step2' file
    Change all cell qRxLevMin value   cell1_value=-56    cell2_value=-26    cell3_value=-26    gnb_id=575
    Attach UEs and send full buffer and check tput
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti_cell1'
    Multi UE Detach And Stop Traffic
    [Teardown]    Stop capture only gnb syslog in 'step2' file

step3:attach UEs in cell2 and check logs by counter
    Log To Console   \n-------------step3:attach UEs in cell2 and check logs--------------
    Start capture only gnb syslog in 'step3' file
    Change all 3cell qRxLevMin value   cell1_value=-22    cell2_value=-56    cell3_value=-22    gnb_id=575
    Attach UEs and send full buffer    cell_id=2    duration=1500
    ${PM_counter_file}    download PM counter file    ${TS_CASE_LOG_PATH}
    ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=2
    ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=2
    should be true    ${NR_5054a_ini_bler}<0.05
    should be true    ${NR_5055b_res_bler}==0

    Multi UE Detach And Stop Traffic   ue_num=4
    [Teardown]    Stop capture only gnb syslog in 'step3' file

step4:attach UEs in cell3 and check logs by counter
    Log To Console   \n-------------step4:attach UEs in cell3 and check logs--------------
    Start capture only gnb syslog in 'step4' file
    Change all 3cell qRxLevMin value  cell1_value=-22    cell2_value=-22    cell3_value=-56    gnb_id=575

    Attach UEs and send full buffer     cell_id=3    duration=1500
    ${PM_counter_file}    download PM counter file    ${TS_CASE_LOG_PATH}
    ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=3
    ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=3
    should be true    ${NR_5054a_ini_bler}<0.05
    should be true    ${NR_5055b_res_bler}==0
    Multi UE Detach And Stop Traffic   ue_num=4
    [Teardown]    Stop capture only gnb syslog in 'step4' file

Attach UEs and send full buffer and check tput
    [Arguments]    ${cell_id}=1    ${duration}=1500    ${iperf_port}=33802
	FOR    ${ue_index}    IN RANGE    0    ${UE_NUM_SA}
	    Log To Console    UE${ue_index} attachs
	    ${ue_type}    translate power ue type from testline    ${ue_index}
	    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}
        power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False
        power_ue.Start traffic   ue_index=${ue_index}    ue_type=${ue_type}   direction=dl   throughput=1600M    duration=${duration}
        Log To Console    UE${ue_index} detach and attach again void qualcomm issue
        power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
        Wait '2s' for stable
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}  #attach with data again to void qualcomm bler
        power_ue.Start traffic   ue_index=${ue_index}    ue_type=${ue_type}   direction=ul   throughput=170M
		...   duration=${duration}    iperf_port=${iperf_port}+${ue_index}
     END
	${cellsid}    create list    ${NRCELL${cell_id}_CELLID}
    ${expect_dl_tput}=    evaluate    $cell${cell_id}_expect_tput[0]
	${expect_ul_tput}=    evaluate    $cell${cell_id}_expect_tput[1]
	${tput_log}    power_ue.Collect Tput    ue_type=${UE_TYPE}    duration=5m    check_source=aasyslog
     run keyword and continue on failure    power_ue.Check Tput     ue_type=${UE_TYPE}     direction=dl     cells=${cellsid}   log=${tput_log}
     ...    target_throughput=${expect_dl_tput}    target_avg_percent=0.98    min_percent=0.8    check_source=aasyslog
     #run keyword and continue on failure    power_ue.Check Tput     ue_type=${UE_TYPE}     direction=ul     cells=${cellsid}    log=${tput_log}
     #...    target_throughput=${expect_ul_tput}    target_avg_percent=0.98    min_percent=0.8    check_source=aasyslog

Attach UEs and send full buffer
    [Arguments]    ${cell_id}=1    ${duration}=1500    ${iperf_port}=33802
	FOR    ${ue_index}    IN RANGE    0    4
	    Log To Console    \n--UE${ue_index} attachs to cell${cell_id}--
	    ${ue_type}    translate power ue type from testline    ${ue_index}
	    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}
        power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False
 #        power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False
        Log To Console    UE${ue_index} DL data push start
        power_ue.Start traffic   ue_index=${ue_index}    ue_type=${ue_type}   direction=dl   throughput=1600M    duration=${duration}
        Log To Console    UE${ue_index} detach and attach again void qualcomm issue
        power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
        Wait '2s' for stable
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}  #attach with data again to void qualcomm bler

        power_ue.Start traffic   ue_index=${ue_index}    ue_type=${ue_type}   direction=ul   throughput=300M
        ...    duration=${duration}    iperf_port=${iperf_port}+${ue_index}
     END


Multi UE Detach And Stop Traffic
    [Arguments]    ${ue_num}=1
    FOR    ${ue_no}    IN RANGE    0    ${ue_num}
        Run Keyword And Continue On Failure    Common Stop traffic    direction=dl    ue_index=${ue_no}
        Run Keyword And Continue On Failure    Common Stop traffic    direction=ul    ue_index=${ue_no}
        Run Keyword And Continue On Failure    Common UE Detach    ue_index=${ue_no}    power_reset=true
    END

Common Stop traffic
    [Arguments]    ${direction}    ${ue_index}=${0}    ${ue_mode}=SA
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_index=${ue_index}    ue_mode=${ue_mode}

Common UE Detach
    [Arguments]    ${ue_index}=${0}    ${power_reset}=False
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}
Qualcom detach
     [Arguments]    ${Detach_UE_num}=4
     FOR    ${ue_index}    IN RANGE    0    ${Detach_UE_num}
         Log To Console    UE${ue_index} detach
         ${ue_type}    translate power ue type from testline    ${ue_index}
	     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
         power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    END


Qualmn UE attach
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    translate power ue type from testline    ${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${UE_TYPE}
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

Start send UE traffic
    [Arguments]    ${ue_index}=${0}    ${duration}=1500
    ${ue_type}    translate power ue type from testline    ${ue_index}
    power_ue.Start traffic   ue_index=${ue_index}    ue_type=${ue_type}   direction=dl   throughput=1220M    duration=${duration}
    power_ue.Start traffic   ue_index=${ue_index}    ue_type=${ue_type}   direction=ul   throughput=220M    duration=${duration}

Stop UE traffic
    [Arguments]    ${ue_index}=${0}
    log to console      Stop traffic
    ${ue_type}    translate power ue type from testline    ${ue_index}
    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}

Check cell thp
    [Arguments]    ${cellid}=${0}
    ${tput_log}    power_ue.Collect Tput    ue_type=${UE_TYPE}    duration=5m    check_source=aasyslog
    ${cellsid}    create list    ${cellid}
#    power_ue.Check Tput     ue_type=${UE_TYPE}     direction=ul     cells=1    log=${tput_log}
#    ...                     target_throughput=${Expected_Throughput_UL}
    power_ue.Check Tput     ue_type=${UE_TYPE}     direction=dl     cells=${cellsid}    log=${tput_log}    target_throughput=${dl_peak_tput}
    ...    target_avg_percent=0.98    min_percent=0.8    check_source=aasyslog


Get theoretical throughput from nrdim
    [Arguments]    ${SCF_Path}    ${pcellid}=1
    [Documentation]  Get theoretical throughput from nrdim
    ...    RETURN list [theoretical_dl , theoretical_ul]

    ${cell1_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=${pcellid}

    ${cell2_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=2

    ${cell3_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=3
    Set Test Variable   ${cell1_expect_tput}
    Set Test Variable   ${cell2_expect_tput}
    Set Test Variable   ${cell3_expect_tput}
    Log To Console   cell1_expect_tput is ${cell1_expect_tput}
    Log To Console   cell2_expect_tput is ${cell2_expect_tput}
    Log To Console   cell3_expect_tput is ${cell3_expect_tput}


Change all cell qRxLevMin value
    [Arguments]    ${cell1_value}=-56    ${cell2_value}=-56    ${cell3_value}=-56    ${gnb_id}=${10754}
    ${conn}    TAF_ADMIN.connect to    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    bts_port=443    use_ssl=True    name=online
    ${modify1}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-1
    ...    parameter=qRxLevMin    value=${cell1_value}
    ${modify2}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-2
    ...    parameter=qRxLevMin    value=${cell2_value}
    ${modify3}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-3
    ...    parameter=qRxLevMin    value=${cell3_value}
    @{modify_param}    Create List     ${modify1}    ${modify2}    ${modify3}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${conn}    timeout=600
    Wait '30s' for stabible
    [Teardown]    TAF_ADMIN.teardown admin    connection=online

Add RD
    Add GNB swconfig    0x58077e:1   #rdEnableMuAwareTdSchTtiTrace
    Add GNB swconfig    0x580539:10   #Num UE threshold,to collect trace
    Add GNB swconfig   0x9D0000:15

Add GNB swconfig
    [Arguments]    @{Rdparameter}
    Backup Swconfig    ${CURDIR}    gnb_swconfig.txt
    setup_txt    src_file=${CURDIR}/gnb_swconfig.txt    save_path=${CURDIR}/gnb_swconfig_modify.txt
    FOR    ${parameter}    IN    @{Rdparameter}
        ${key}    ${value}    Split String    ${parameter}    :
        run keyword and ignore error    delete txt node    ${key}
        add txt node    ${parameter}
    END
    teardown txt
    GNB Upload Swconfig    ${CURDIR}/gnb_swconfig_modify.txt



Convert cellsetup bip and check
    Log To Console   Convert cellsetup bip and check
    Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/cellsetup.pcap
     ...    ${TEST_LOG_DIRECTORY()}/All/cellsetup.csv    ${filter_cell_setup}    ${titles_muaware}
    check_log_with_au2anlysis    ini_path=${parent_dir}/TestData/cellsetup_bip.ini   log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/

Modify GNB swconfig
    ${cur_relative_dir}    set variable    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/Non_Feature_SG13/TestCases
    ${sw_relative_dir}    set variable    commissionings/HGZ
    ${swconfig_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${sw_relative_dir}
    Log To Console    ${swconfig_base_path}
    setup_txt    src_file=${swconfig_base_path}/${TL_NAME}/swconfig.txt    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#    add_txt_node    0x9D0000:15             #as PM counter period update to 15/15=1min
    add_txt_node    0x58077e:1   #rdEnableMuAwareTdSchTtiTrace
    add_txt_node    0x580539:10   #Num UE threshold,to collect trace
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
