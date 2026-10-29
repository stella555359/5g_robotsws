*** Settings ***
Test Timeout      600 minutes
Suite Setup       Sg13 Common Suite Setup
Suite Teardown    Sg13 Common Suite Teardown
Test Setup    SG13 Common Test Setup    ${allowed_faults_ids}
Test Teardown    SG13 Common Test Teardown
Force Tags    Qualmn    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEHC_VEFHAZ4
Documentation     CB013071 case03   author  l3gao
...    b1a74f66  ue1
...    ca3e3465  ue2
...    92683215  ue3
...    6fbcbb79  ue4
...    add keywords to reboot qualcommUE before start this case
...    ue rank report not stable rankThreshold=2


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
${UE_NUM_SA}         1     #debug
${TS_CASE_LOG_PATH}      ${TEST_LOG_DIRECTORY()}/All
${scfc_in_case}                 SCFC_B_Case12_1302_ASIM_refine.xml
${swconfig_file}                      ${CURDIR}/config/swconfig.txt
${iperf_port}     33810

${NRCELL2147483644_CELLID}          68719475201
${NRCELL2147483645_CELLID}          68719475202
${NRCELL2147483646_CELLID}          68719475203
${NRCELL2147483647_CELLID}          68719475204
${allowed_faults_ids}    7107,7523,49

*** Test Cases ***
CB013071_B_B01_CASE012_64TRX_dual_band_SubbandBm_4CC_CA_MUMIMO
    Step1:Commission the above configuration on WebUI
    Step2:attach UEs to cells      cell_id_check=2147483644
#    Step2:attach UEs to cells      cell_id_check=2147483645
#    Step2:attach UEs to cells      cell_id_check=2147483646
#    Step2:attach UEs to cells      cell_id_check=2147483647
    step3:block cell and unblock
    step4:modify cells actDlSrsSubbandBm and check peak

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Start Capture Gnb Syslogs in 'before_onair' file
    Log To Console    Modify GNB swconfig and detach all ue
    Qualcom detach    Detach_UE_num=2
    Log To Console    sw is ${SW_BRANCH}
    Add RD
    ${scfc_configuration}    Set Variable    ${CURDIR}/config/${SW_BRANCH}/${scfc_in_case}
    Log To Console    scfc_configuration is ${scfc_configuration}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}/SCFC_newest.xml
    copy_file       ${scfc_configuration}    ${scfc_path}
    Perform Full Commission       ${scfc_path}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    Wait '60s' for stable
    Get theoretical throughput from nrdim 3cell    SCF_Path=${scfc_path}
    [Teardown]    Stop Capture Gnb Syslogs in 'before_onair' file

Step2:attach UEs to cells
    [Arguments]    ${cell_id_check}
    Log To Console   \n-------------step2:attach UEs to cell_${cell_id_check}--------------
    run keyword if     ${cell_id_check}==2147483644    Change all cell qRxLevMin value newgnbid   cell1_value=-45    cell2_value=-22
    ...    cell3_value=-22    cell4_value=-22    gnb_id=4294967200
    run keyword if     ${cell_id_check}==2147483645    Change all cell qRxLevMin value newgnbid   cell1_value=-22    cell2_value=-45
    ...    cell3_value=-22    cell4_value=-22    gnb_id=4294967200
    run keyword if     ${cell_id_check}==2147483646    Change all cell qRxLevMin value newgnbid   cell1_value=-22    cell2_value=-22
    ...    cell3_value=-45    cell4_value=-22    gnb_id=4294967200
    run keyword if     ${cell_id_check}==2147483647    Change all cell qRxLevMin value newgnbid   cell1_value=-22    cell2_value=-22
    ...    cell3_value=-22    cell4_value=-45    gnb_id=4294967200
    FOR    ${bler_check}    IN RANGE    0    3
        Attach UEs and send full buffer     cell_id=${cell_id_check}    duration=1500
        ${PM_counter_file}    download 2min PM counter file    ${TS_CASE_LOG_PATH}
        ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=${cell_id_check}
        ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=${cell_id_check}
        ${NR_5258a_DL_MAX_PEAK}    get KPI NR_5258a    ${PM_counter_file}    cell_id=${cell_id_check}
        ${NR_5258a_UL_MAX_PEAK}    get KPI NR_5259a    ${PM_counter_file}    cell_id=${cell_id_check}
        Run Keyword if    ${NR_5054a_ini_bler}<0.01 and ${NR_5258a_DL_MAX_PEAK}>500    Exit For Loop
        Run Keyword if    ${NR_5054a_ini_bler}>0.01 or ${NR_5258a_DL_MAX_PEAK}<500    Qualcom detach and stop data
        Log To Console    cellid ${cell_id_check}‘s bler ${NR_5055b_res_bler} ${NR_5054a_ini_bler}
        ...    tp_peak DL ${NR_5258a_DL_MAX_PEAK} UL ${NR_5258a_UL_MAX_PEAK}
    END
    run keyword if     ${cell_id_check}==2147483644     cell peak check    cell_id=2147483644
    Get 13071 eCPRI UPlane and Fast CPlane counter    ${PM_counter_file}    cell_id=${cell_id_check}
    Get RT and DFT user Num by counter    ${PM_counter_file}    cell_id=${cell_id_check}    rt=1    dft=0
    should be true    ${NR_5055b_res_bler}<0.001
    should be true    ${NR_5054a_ini_bler}<0.01
    Qualcom detach and stop data

step3:block cell and unblock
    Log To Console   \n-------------step6:block cell and unblock--------------
    Start Capture Gnb Syslogs in 'step6' file
    Change all cell qRxLevMin value newgnbid   cell1_value=-22    cell2_value=-22      cell3_value=-22    cell4_value=-45    gnb_id=4294967200
    Block cell    54    gnb1302
    Unblock cell    54    gnb1302
    FOR    ${bler_check}    IN RANGE    0    3
        Attach UEs and send full buffer     cell_id=2147483647    duration=1500
        ${PM_counter_file}    download 2min PM counter file    ${TS_CASE_LOG_PATH}
        ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=2147483647
        ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=2147483647
        Run Keyword if    ${NR_5054a_ini_bler}<0.01    Exit For Loop
        Run Keyword if    ${NR_5054a_ini_bler}>0.01    Qualcom detach and stop data
    END
    Get 13071 eCPRI UPlane and Fast CPlane counter    ${PM_counter_file}    cell_id=2147483647
    Get RT and DFT user Num by counter    ${PM_counter_file}    cell_id=2147483647    rt=1    dft=0
    should be true    ${NR_5055b_res_bler}<0.001
    should be true    ${NR_5054a_ini_bler}<0.01

    Qualcom detach and stop data
    [Teardown]    Stop Capture Gnb Syslogs in 'step6' file

step4:modify cells actDlSrsSubbandBm and check peak
    Log To Console   \n-------------step7:modify cells actDlSrsSubbandBm and check peak--------------
    Start Capture Gnb Syslogs in 'step7' file
    modify cells actDlSrsSubbandBm and no fatal
 #    attach UEs to cell    cell_id_check=1
 #   attach UEs to cell    cell_id_check=2
 #   attach UEs to cell    cell_id_check=3
    [Teardown]    Stop Capture Gnb Syslogs in 'step7' file


modify cells actDlSrsSubbandBm and no fatal
    FOR    ${num}    IN RANGE    1    2    #reproduce crash issue
        Log To Console   \nthis is cell3 the ${num}th times commission actDlSrsSubbandBm
        Online change parameters    json_file=delta_13071_CIT    cell1_actDlSrsSubbandBm=true    cell2_actDlSrsSubbandBm=true
        ...    cell3_actDlSrsSubbandBm=false    cell4_actDlSrsSubbandBm=true
        Online change parameters    json_file=delta_13071_CIT    cell1_actDlSrsSubbandBm=true    cell2_actDlSrsSubbandBm=true
        ...    cell3_actDlSrsSubbandBm=true    cell4_actDlSrsSubbandBm=true
        Get an check gNB active alarms and fault
    END
    FOR    ${num}    IN RANGE    1    2    #reproduce crash issue
        Log To Console   \nthis is cell2 the ${num}th times commission actDlSrsSubbandBm
        Online change parameters    json_file=delta_13071_CIT    cell1_actDlSrsSubbandBm=true    cell2_actDlSrsSubbandBm=false
        ...    cell3_actDlSrsSubbandBm=true    cell4_actDlSrsSubbandBm=true
        Online change parameters    json_file=delta_13071_CIT    cell1_actDlSrsSubbandBm=true    cell2_actDlSrsSubbandBm=true
        ...    cell3_actDlSrsSubbandBm=true    cell4_actDlSrsSubbandBm=true
    END
    FOR    ${num}    IN RANGE    1    2    #reproduce crash issue

        Log To Console   \nthis is cell1 the ${num}th times commission actDlSrsSubbandBm
        Online change parameters    json_file=delta_13071_CIT    cell1_actDlSrsSubbandBm=false    cell2_actDlSrsSubbandBm=true
        ...    cell3_actDlSrsSubbandBm=true    cell4_actDlSrsSubbandBm=true
        Online change parameters    json_file=delta_13071_CIT    cell1_actDlSrsSubbandBm=true    cell2_actDlSrsSubbandBm=true
        ...    cell3_actDlSrsSubbandBm=true    cell4_actDlSrsSubbandBm=true
    END

Online change parameters
     [Arguments]    ${json_file}    ${cell1_actDlSrsSubbandBm}    ${cell2_actDlSrsSubbandBm}    ${cell3_actDlSrsSubbandBm}
     ...    ${cell4_actDlSrsSubbandBm}
     log to console    \n${cell1_actDlSrsSubbandBm} ${cell2_actDlSrsSubbandBm} ${cell3_actDlSrsSubbandBm} ${cell4_actDlSrsSubbandBm}
     ${template}    OperatingSystem.Get File    ${CURDIR}/config/json/${json_file}.json
     log to console    ${template}
     ${message} =    Replace Variables    ${template}
     Create File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${json_file}_modified.json    ${message}
     Online recommissioning with delta json file
     ...   ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${json_file}_modified.json
     Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair


capture snapshot start once
    [Arguments]    ${log_tag}
    Log To Console    --capture snapshot start
    Run Keyword And Ignore Error    Collect GNB SnapShot    target_file_name=${TEST_LOG_DIRECTORY()}/All/${log_tag}_gnb_comon_snapshot.zip

cell peak check
    [Arguments]    ${cell_id}=1
	${cellsid}    create list    ${NRCELL${cell_id}_CELLID}
    ${expect_dl_tput}=    evaluate    ${cell${cell_id}_expect_tput}[0]*1
	${expect_ul_tput}=    evaluate    ${cell${cell_id}_expect_tput}[1]*1
    Log To Console   cell${cellsid}_expect_dl_tput is ${expect_dl_tput}
    Log To Console   cell${cellsid}_expect_ul_tput is ${expect_ul_tput}
	${tput_log}    power_ue.Collect Tput    ue_type=${UE_TYPE}    duration=1m    check_source=aasyslog
     run keyword and continue on failure    power_ue.Check Tput     ue_type=${UE_TYPE}     direction=dl     cells=${cellsid}   log=${tput_log}
     ...    target_throughput=${expect_dl_tput}    target_avg_percent=0.90    min_percent=0.85    check_source=aasyslog
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
#        Log To Console    UE${ue_index} DL_UL little data push start
#        power_ue.Start traffic   ue_index=${ue_index}    ue_type=${ue_type}   direction=dl   throughput=10M
#        ...    duration=${duration}
#        power_ue.Start traffic   ue_index=${ue_index}    ue_type=${ue_type}   direction=ul   throughput=1M
#        ...    duration=${duration}    iperf_port=${iperf_port}+${ue_index}
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
    [Arguments]    ${SCF_Path}
    [Documentation]  Get theoretical throughput from nrdim
    ...    RETURN list [theoretical_dl , theoretical_ul]

    ${cell2147483644_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=2147483644

    ${cell2147483645_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=2147483645

    ${cell2147483646_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=2147483646

    ${cell2147483647_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=2147483647

    Set Test Variable   ${cell2147483644_expect_tput}
    Set Test Variable   ${cell2147483645_expect_tput}
    Set Test Variable   ${cell2147483646_expect_tput}
    Set Test Variable   ${cell2147483647_expect_tput}
    Log To Console   cell2147483644_expect_tput is ${cell2147483644_expect_tput}
    Log To Console   cell2147483645_expect_tput is ${cell2147483645_expect_tput}
    Log To Console   cell2147483646_expect_tput is ${cell2147483646_expect_tput}
    Log To Console   cell2147483647_expect_tput is ${cell2147483647_expect_tput}

Add RD
    Add GNB swconfig   0x9D0000:5

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

Change all cell qRxLevMin value newgnbid
    [Arguments]    ${cell1_value}=-22    ${cell2_value}=-22    ${cell3_value}=-22    ${cell4_value}=-22    ${gnb_id}=${10754}
    ${conn}    TAF_ADMIN.connect to    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    bts_port=443    use_ssl=True    name=online
    ${modify1}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-2147483644
    ...    parameter=qRxLevMin    value=${cell1_value}
    ${modify2}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-2147483645
    ...    parameter=qRxLevMin    value=${cell2_value}
    ${modify3}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-2147483646
    ...    parameter=qRxLevMin    value=${cell3_value}
    ${modify4}    Create Dictionary    dist_name=MRBTS-${gnb_id}/NRBTS-${gnb_id}/NRCELL-2147483647
    ...    parameter=qRxLevMin    value=${cell4_value}

    @{modify_param}    Create List     ${modify1}    ${modify2}    ${modify3}    ${modify4}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${conn}    timeout=600
    Wait '30s' for stabible

    [Teardown]    TAF_ADMIN.teardown admin    connection=online
