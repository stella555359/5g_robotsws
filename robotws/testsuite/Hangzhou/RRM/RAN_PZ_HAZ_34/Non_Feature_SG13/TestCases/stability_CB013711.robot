*** Settings ***
Documentation     stabilitycase
Test Timeout      500 minutes
Suite Setup       Sg13 Common Suite Setup      ${allowed_faults_ids}
Suite Teardown    Sg13 Common Suite Teardown
Test Setup    SG13 Common Test Setup     ${allowed_faults_ids}
Test Teardown    SG13 Common Test Teardown
Force Tags    Spark    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEHC_VEFHAZ4
...    3879376  ue1

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/common_resource/common_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/internal_resource/internal_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    nrdim_get_tput
Library           taf.selenium.sbts    WITH NAME    seleLib
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/mcs_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
##Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB013711/Resources/nr_rim.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB013711/Resources/CB013711_common_keywords.robot

*** Variables ***
${CONFIG_DIR_PATH}         ${CURDIR}/config
@{LOG_NAME_LIST}    gnb_snapshot
#${ATT_FILE_PATH}    att_case06
#${PHASE_FILE_PATH}    phase_case06
${UE_ID}       1
${PORT}    5002
${UE_NUM_SA}         1
${TS_CASE_LOG_PATH}      ${TEST_LOG_DIRECTORY()}/All
${scfc_configuration}                 ${CURDIR}/config/scfc_stability_13711.xml
${swconfig_file}                      ${CURDIR}/config/gnb_swconfig.txt
${NRCELL1_CELLID}          175177729
${NRCELL2_CELLID}          175177730
${NRCELL3_CELLID}          175177731
${allowed_faults_ids}    49,7107,6450,1900,7107,7304
${UE_INDEX}                   1
*** Test Cases ***
TL10692_test
    Step1:Commission the above configuration on WebUI
    Step2:lock unlock cells
    Step3:Change slimRfFilterDLUL value
    Step4:Change mumimo value

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Start Collecting GNB Syslog in 'before_onair' File
    Log To Console    Modify GNB swconfig
    Add RD
    #Qualcom detach    Detach_UE_num=1
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}/SCFC_newest.xml
    copy_file      ${scfc_configuration}    ${scfc_path}
    Perform Full Commission       ${scfc_path}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    Get theoretical throughput from nrdim    SCF_Path=${scfc_path}
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    set suite variable    ${parent_dir}
    [Teardown]    Stop Collecting GNB Syslog in 'before_onair' File
Step3:Change slimRfFilterDLUL value
    [Arguments]    ${loop_times}=1
        FOR    ${value}    IN RANGE    15    ${loop_times}+1
            Log    Setting change value: ${value}
            Change all cell slimRfFilterDLUL value
            Change all cell slimRfFilterDLUL value back
        END
Step4:Change mumimo value
    [Arguments]    ${loop_times}=1
        FOR    ${value}    IN RANGE    15    ${loop_times}+1
            Log    Setting change value: ${value}
            Change all cell actULDlMuMimoEnh value
            Change all cell actULDlMuMimoEnh value back
        END
Step2:lock unlock cells
    [Arguments]    ${loop_times}=1
        FOR    ${value}    IN RANGE    15    ${loop_times}+1
            Log    Setting lock value: ${value}
            block all cells
            unblock all cells
        END
block all cells
    Log To Console   \n-------------block all cells--------------
    Block cell    51     gnb10692
    Block cell    52     gnb10692
    Block cell    53     gnb10692
    Block cell    62     gnb10692
    Block cell    63     gnb10692
unblock all cells
    Log To Console   \n-------------block all cells--------------
    Unblock cell    51    gnb10692
    Unblock cell    52    gnb10692
    Unblock cell    53    gnb10692
    Unblock cell    62    gnb10692
    Unblock cell    63    gnb10692
Change all cell slimRfFilterDLUL value
    [Arguments]    ${cell1ul_value}=Nominal    ${cell1dl_value}=Nominal    ${gnb_id}=${10692}
    ${conn}    TAF_ADMIN.connect to    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    bts_port=443    use_ssl=True    name=online
    ${modify1}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-2
    ...    parameter=slimRfFilterUL    value=${cell1ul_value}
    ${modify2}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-2
    ...    parameter=slimRfFilterDL    value=${cell1dl_value}
    @{modify_param}    Create List     ${modify1}    ${modify2}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${conn}    timeout=600
    Wait '30s' for stabible
    [Teardown]    TAF_ADMIN.teardown admin    connection=online
Change all cell slimRfFilterDLUL value back
    [Arguments]    ${cell1ul_value}=44MHz    ${cell1dl_value}=44MHz    ${gnb_id}=${10692}
    ${conn}    TAF_ADMIN.connect to    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    bts_port=443    use_ssl=True    name=online
    ${modify1}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-2
    ...    parameter=slimRfFilterUL    value=${cell1ul_value}
    ${modify2}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-2
    ...    parameter=slimRfFilterDL    value=${cell1dl_value}
    @{modify_param}    Create List     ${modify1}    ${modify2}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${conn}    timeout=600
    Wait '30s' for stabible
    [Teardown]    TAF_ADMIN.teardown admin    connection=online
Change all cell actULDlMuMimoEnh value
    [Arguments]    ${cell1ul_value}=false    ${cell1dl_value}=false    ${gnb_id}=${10692}
    ${conn}    TAF_ADMIN.connect to    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    bts_port=443    use_ssl=True    name=online
    ${modify1}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-1
    ...    parameter=actDlMuMimoEnh    value=${cell1ul_value}
    ${modify2}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-1
    ...    parameter=actUlMuMimo    value=${cell1dl_value}
    @{modify_param}    Create List     ${modify1}    ${modify2}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${conn}    timeout=600
    Wait '30s' for stabible
    [Teardown]    TAF_ADMIN.teardown admin    connection=online
Change all cell actULDlMuMimoEnh value back
    [Arguments]    ${cell1ul_value}=true    ${cell1dl_value}=true    ${gnb_id}=${10692}
    ${conn}    TAF_ADMIN.connect to    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    bts_port=443    use_ssl=True    name=online
    ${modify1}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-1
    ...    parameter=actDlMuMimoEnh    value=${cell1ul_value}
    ${modify2}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-1
    ...    parameter=actUlMuMimo    value=${cell1dl_value}
    @{modify_param}    Create List     ${modify1}    ${modify2}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${conn}    timeout=600
    Wait '30s' for stabible
    [Teardown]    TAF_ADMIN.teardown admin    connection=online
step2:attach UEs in cell1 and check logs
    Log To Console   \n-------------step2:attach UEs in cell1 and check logs--------------
    #Start capture only gnb syslog in 'step2' file
    #Start Capture Gnb Syslogs in 'step2' file
    #Change all cell qRxLevMin value   cell1_value=-56    cell2_value=-26    gnb_id=10692
    Attach UEs and send full buffer and check tput
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti_cell1'
    Multi UE Detach And Stop Traffic
    #[Teardown]    Stop capture only gnb syslog in 'step2' file
    [Teardown]    Stop Capture Gnb Syslogs in 'step2' file
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
    [Arguments]    ${cell_id}=2
	FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}
	    Log To Console    UE${num} attachs
	    Spark UE Attach    ue_index=${num}    power_reset=true

	    Spark UE Send DL Traffic    ue_index=${num}    send_traffic=1000MKbits/sec    send_duration=600    apn_address=wustatic    ue_mode=None
	    Spark UE Send UL Traffic    ue_index=${num}    send_traffic=100MKbits/sec    send_duration=600    apn_address=wustatic    ue_mode=None
	END

	${cellsid}    create list    ${NRCELL${cell_id}_CELLID}
	${expect_dl_tput}=    evaluate    ${cell${cell_id}_expect_tput}[0]*0.3
	${expect_ul_tput}=    evaluate    ${cell${cell_id}_expect_tput}[1]*0.3
	run keyword and continue on failure    Spark UE Check Tput    ue_index=${UE_INDEX}    expect_traffic=${expect_dl_tput}
	...    check_source=aasyslog    duration=1m    cells=${cellsid}    target_avg_percent=0.4
	run keyword and continue on failure    Spark UE Check Tput    ue_index=${UE_INDEX}    direction=ul    expect_traffic=${expect_ul_tput}
	...    check_source=aasyslog    duration=1m    cells=${cellsid}    target_avg_percent=0.4

Attach UEs and send full buffer
    [Arguments]    ${cell_id}=1
	FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
	    Log To Console    UE${num} attachs
	    Spark UE Attach    ue_index=${num}    power_reset=true

	    Spark UE Send DL Traffic    ue_index=${num}    send_traffic=1326MKbits/sec    send_duration=600    apn_address=wustatic    ue_mode=None
	    Spark UE Send UL Traffic    ue_index=${num}    send_traffic=205MKbits/sec    send_duration=600    apn_address=wustatic    ue_mode=None
	END

	${cellsid}    create list    ${NRCELL${cell_id}_CELLID}
	${expect_dl_tput}=    evaluate    ${cell${cell_id}_expect_tput}[0]*0.9
	${expect_ul_tput}=    evaluate    ${cell${cell_id}_expect_tput}[1]*0.9
	run keyword and continue on failure    Spark UE Check Tput    ue_index=${UE_INDEX}    expect_traffic=${expect_dl_tput}
	...    check_source=aasyslog    duration=1m    cells=${cellsid}    target_avg_percent=0.8
	run keyword and continue on failure    Spark UE Check Tput    ue_index=${UE_INDEX}    direction=ul    expect_traffic=${expect_ul_tput}
	...    check_source=aasyslog    duration=1m    cells=${cellsid}    target_avg_percent=0.8

Multi UE Detach And Stop Traffic
    [Arguments]    ${ue_num}=1
    FOR    ${ue_no}    IN RANGE    1    ${ue_num}
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
    Set Test Variable   ${cell1_expect_tput}
    Set Test Variable   ${cell2_expect_tput}
    Log To Console   cell1_expect_tput is ${cell1_expect_tput}
    Log To Console   cell2_expect_tput is ${cell2_expect_tput}


Change all cell qRxLevMin value
    [Arguments]    ${cell1_value}=-60    ${cell2_value}=-22    ${gnb_id}=${10692}
    ${conn}    TAF_ADMIN.connect to    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    bts_port=443    use_ssl=True    name=online
    ${modify1}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-1
    ...    parameter=qRxLevMin    value=${cell1_value}
    ${modify2}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-2
    ...    parameter=qRxLevMin    value=${cell2_value}
    @{modify_param}    Create List     ${modify1}    ${modify2}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${conn}    timeout=600
    Wait '30s' for stabible
    [Teardown]    TAF_ADMIN.teardown admin    connection=online

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

Add RD
    Add GNB swconfig   0x9D0000:15
