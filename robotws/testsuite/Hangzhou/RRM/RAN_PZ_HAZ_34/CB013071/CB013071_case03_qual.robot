*** Settings ***
Test Timeout      600 minutes
Suite Setup       Sg13 Common Suite Setup
Suite Teardown    Sg13 Common Suite Teardown
Test Setup    SG13 Common Test Setup    ${allowed_faults_ids}
Test Teardown    SG13 Common Test Teardown
Force Tags    Qualmn    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEHC_VEFHAZ4
Documentation     CB013071 case03   author  l3gao
...    b1a74f66  ue1
...    6fbcbb79  ue4
...    92683215  ue3
...    ca3e3465  ue2
...    add keywords to reboot qualcommUE before start this case

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/common_resource/common_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/internal_resource/internal_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    nrdim_get_tput
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/mcs_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB013071/Resources/CB013071_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

*** Variables ***
${CONFIG_DIR_PATH}         ${CURDIR}/config
@{LOG_NAME_LIST}    gnb_snapshot
${ATT_FILE_PATH}    att_case06
${PHASE_FILE_PATH}    phase_case06
${UE_ID}       1
${PORT}    5002
${UE_NUM_SA}         2
${TS_CASE_LOG_PATH}      ${TEST_LOG_DIRECTORY()}/All
${scfc_configuration}                 ${CURDIR}/config/SCFC_Case03_1302_ASIM.xml
${swconfig_file}                      ${CURDIR}/config/swconfig.txt
${iperf_port}     33820

${NRCELL1_CELLID}          9420801
${NRCELL2_CELLID}          9420802
${NRCELL3_CELLID}          9420803
${NRCELL4_CELLID}          9420804
${allowed_faults_ids}    7107,7523,49

*** Test Cases ***
CB013071_A_B01_CASE003_64TRX_single_band_SubbandBm_3CC_subbandSize_change
    Step1:Commission the above configuration on WebUI
    step2:attach UEs in cell1 and check logs
    step3:attach UEs in cell2 and check logs by counter
    step4:attach UEs in cell3 and check logs by counter
    step5:block cell and unblock

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Start Capture Gnb Syslogs in 'before_onair' file
    Log To Console    Modify GNB swconfig and detach all ue
    Qualcom detach    Detach_UE_num=2
    Add RD
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}/SCFC_newest.xml
    copy_file       ${scfc_configuration}    ${scfc_path}
    Perform Full Commission       ${scfc_path}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    Wait '60s' for stable
    Get theoretical throughput from nrdim 3cell    SCF_Path=${scfc_path}
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    set suite variable    ${parent_dir}
    [Teardown]    Stop Capture Gnb Syslogs in 'before_onair' file

step2:attach UEs in cell1 and check logs
    Log To Console   \n-------------step2:attach UEs in cell1 and check logs--------------
    Start Capture Gnb Syslogs in 'step2' file
    Change all 3cell qRxLevMin value  cell1_value=-45    cell2_value=-22    cell3_value=-22    gnb_id=575
    FOR    ${bler_check}    IN RANGE    0    2
        Attach UEs and send full buffer    cell_id=1    duration=1500
        ${PM_counter_file}    download 2min PM counter file    ${TS_CASE_LOG_PATH}
        ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=1
        ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=1
        Run Keyword if    ${NR_5054a_ini_bler}<0.01    Exit For Loop
        Run Keyword if    ${NR_5054a_ini_bler}>0.01    Qualcom detach and stop data
#    Start collect ttitrace
#    Wait for '1s' to stop ttitrace with name'tti_cell1'
    END
    cell peak check    cell_id=1
    Get 13071 eCPRI UPlane and Fast CPlane counter    ${PM_counter_file}    cell_id=1
    should be true    ${NR_5055b_res_bler}<0.001
    should be true    ${NR_5054a_ini_bler}<0.01
    Qualcom detach and stop data

    [Teardown]    Stop Capture Gnb Syslogs in 'step2' file

step3:attach UEs in cell2 and check logs by counter
    Log To Console   \n-------------step3:attach UEs in cell2 and check logs--------------
    Start Capture Gnb Syslogs in 'step3' file
    Change all 3cell qRxLevMin value   cell1_value=-22    cell2_value=-45    cell3_value=-22    gnb_id=575

    FOR    ${bler_check}    IN RANGE    0    2
        Attach UEs and send full buffer    cell_id=2    duration=1500
        ${PM_counter_file}    download 2min PM counter file    ${TS_CASE_LOG_PATH}
        ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=2
        ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=2
        Run Keyword if    ${NR_5054a_ini_bler}<0.01    Exit For Loop
        Run Keyword if    ${NR_5054a_ini_bler}>0.01    Qualcom detach and stop data
    END
    Get 13071 eCPRI UPlane and Fast CPlane counter    ${PM_counter_file}    cell_id=2
    Get RT and DFT user Num by counter    ${PM_counter_file}    cell_id=2    rt=2    dft=0
    should be true    ${NR_5055b_res_bler}<0.001
    should be true    ${NR_5054a_ini_bler}<0.01
    Qualcom detach and stop data

    [Teardown]    Stop Capture Gnb Syslogs in 'step3' file

step4:attach UEs in cell3 and check logs by counter
    Log To Console   \n-------------step4:attach UEs in cell3 and check logs--------------
    Start Capture Gnb Syslogs in 'step4' file
    Change all 3cell qRxLevMin value  cell1_value=-22    cell2_value=-22    cell3_value=-45    gnb_id=575
    FOR    ${bler_check}    IN RANGE    0    2
        Attach UEs and send full buffer     cell_id=3    duration=1500
        ${PM_counter_file}    download 2min PM counter file    ${TS_CASE_LOG_PATH}
        ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=3
        ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=3
        Run Keyword if    ${NR_5054a_ini_bler}<0.01    Exit For Loop
        Run Keyword if    ${NR_5054a_ini_bler}>0.01    Qualcom detach and stop data
    END
    Get 13071 eCPRI UPlane and Fast CPlane counter    ${PM_counter_file}    cell_id=3
    Get RT and DFT user Num by counter    ${PM_counter_file}    cell_id=3    rt=2    dft=0
    should be true    ${NR_5055b_res_bler}<0.001
    should be true    ${NR_5054a_ini_bler}<0.01
    Qualcom detach and stop data
    [Teardown]    Stop Capture Gnb Syslogs in 'step4' file

step5:block cell and unblock
    Log To Console   \n-------------step5:block cell and unblock--------------
    Start Capture Gnb Syslogs in 'step5' file
    Block cell    53    gnb1302
    Unblock cell    53    gnb1302
    FOR    ${bler_check}    IN RANGE    0    3
        Attach UEs and send full buffer     cell_id=3    duration=1500
        ${PM_counter_file}    download 2min PM counter file    ${TS_CASE_LOG_PATH}
        ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=3
        ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=3
        Run Keyword if    ${NR_5054a_ini_bler}<0.01    Exit For Loop
        Run Keyword if    ${NR_5054a_ini_bler}>0.01    Qualcom detach and stop data
    END
    Get 13071 eCPRI UPlane and Fast CPlane counter    ${PM_counter_file}    cell_id=3
    Get RT and DFT user Num by counter    ${PM_counter_file}    cell_id=3    rt=2    dft=0
    should be true    ${NR_5055b_res_bler}<0.001
    should be true    ${NR_5054a_ini_bler}<0.01

    Qualcom detach and stop data
    [Teardown]    Stop Capture Gnb Syslogs in 'step5' file

cell peak check
    [Arguments]    ${cell_id}=1
	${cellsid}    create list    ${NRCELL${cell_id}_CELLID}
    ${target_dl_tput}=    evaluate    ${cell${cell_id}_expect_tput}[0]*0.98
	${target_ul_tput}=    evaluate    ${cell${cell_id}_expect_tput}[1]*0.98
	Log To Console   cell${cellsid}_target_dl_tput is ${target_dl_tput}
    Log To Console   cell${cellsid}_target_ul_tput is ${target_ul_tput}

    ${expect_dl_tput}=    evaluate    ${cell${cell_id}_expect_tput}[0]*1
	${expect_ul_tput}=    evaluate    ${cell${cell_id}_expect_tput}[1]*1
    Log To Console   cell${cellsid}_expect_dl_tput is ${expect_dl_tput}
    Log To Console   cell${cellsid}_expect_ul_tput is ${expect_ul_tput}
	${tput_log}    power_ue.Collect Tput    ue_type=${UE_TYPE}    duration=5m    check_source=aasyslog
     run keyword and continue on failure    power_ue.Check Tput     ue_type=${UE_TYPE}     direction=dl     cells=${cellsid}   log=${tput_log}
     ...    target_throughput=${expect_dl_tput}    target_avg_percent=0.98    min_percent=0.85    check_source=aasyslog
#     run keyword and continue on failure    power_ue.Check Tput     ue_type=${UE_TYPE}     direction=ul     cells=${cellsid}    log=${tput_log}
#     ...    target_throughput=${expect_ul_tput}    target_avg_percent=0.94    min_percent=0.85    check_source=aasyslog

Attach UEs and send full buffer
    [Arguments]    ${cell_id}=1    ${duration}=1500
	FOR    ${ue_index}    IN RANGE    0    ${UE_NUM_SA}
	    Log To Console    \n--UE${ue_index} attachs to cell${cell_id}--
	    ${ue_type}    translate power ue type from testline    ${ue_index}
	    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}
        power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    END
	FOR    ${ue_index}    IN RANGE    0    ${UE_NUM_SA}
		${iperf_port_1}    evaluate    ${iperf_port}+${ue_index}
	    ${ue_type}    translate power ue type from testline    ${ue_index}
        Log To Console    UE${ue_index} DL_UL full data push start
        power_ue.Start traffic   ue_index=${ue_index}    ue_type=${ue_type}   direction=dl   throughput=1600M
        ...    duration=${duration}
        power_ue.Start traffic   ue_index=${ue_index}    ue_type=${ue_type}   direction=ul   throughput=300M
        ...    duration=${duration}    iperf_port=${iperf_port_1}
     END


Qualcom detach and stop data
     FOR    ${ue_index}    IN RANGE    0    ${UE_NUM_SA}
         Log To Console    UE${ue_index} detach and deactive data
         ${ue_type}    translate power ue type from testline    ${ue_index}
	     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
         Stop UE traffic    ue_type=${ue_type}    ue_index=${ue_index}
         power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    END

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
    [Arguments]    ${ue_type}    ${ue_index}=${0}
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


Get theoretical throughput from nrdim 3cell
    [Arguments]    ${SCF_Path}    ${pcellid}=1
    [Documentation]  Get theoretical throughput from nrdim
    ...    RETURN list [theoretical_dl , theoretical_ul]

    ${cell1_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=${pcellid}

    ${cell2_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=2

    ${cell3_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=3

#    ${cell4_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
#    ...    scf_path=${SCF_Path}    cell_id=4

    Set Test Variable   ${cell1_expect_tput}
    Set Test Variable   ${cell2_expect_tput}
    Set Test Variable   ${cell3_expect_tput}
#    Set Test Variable   ${cell4_expect_tput}
    Log To Console   cell1_expect_tput is ${cell1_expect_tput}
    Log To Console   cell2_expect_tput is ${cell2_expect_tput}
    Log To Console   cell3_expect_tput is ${cell3_expect_tput}
#    Log To Console   cell4_expect_tput is ${cell4_expect_tput}


Add RD
#    Add GNB swconfig    0x58077e:1   #rdEnableMuAwareTdSchTtiTrace
#    Add GNB swconfig    0x580539:10   #Num UE threshold,to collect trace
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

