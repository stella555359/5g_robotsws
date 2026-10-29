*** Settings ***
Test Timeout      600 minutes
Suite Setup       Sg13 Common Suite Setup
Suite Teardown    Sg13 Common Suite Teardown
Test Setup    SG13 Common Test Setup    ${allowed_faults_ids}
Test Teardown    SG13 Common Test Teardown
Force Tags    Qualmn    CLOUD_5G_CLASSICAL_FULLRACK_SA_ASIML_ABIOB1_ABIAB3_2xAHLOA_2xAHFIB-ASIMR_ABIPB4_ABIPB5_AVHA
Documentation     CB013711_A_case01   author  l3gao  lineIs37577
...    c2d07079  ue3   MCS 1-2-3-4 MTP8750
...    2cdcf49b  ue4
...    db6ec13d  ue1   MCS 9-10-11-12 MTP8750
...    83fe0001  ue2   MCS 13-14-15-16 MTP8550
...    add keywords to reboot qualcommUE before start this case
...    ue rank report not stable rankThreshold=2
...    tmo-config 2cc /uDTX enable ,tti trace PRB not exceed/PM counter RTWP cauculate /72e-72a

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/common_resource/common_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/internal_resource/internal_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    nrdim_get_tput
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/mcs_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB013711/Resources/CB013711_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Library           ./Resources/Slim_prb_check.py

*** Variables ***
${CONFIG_DIR_PATH}         ${CURDIR}/config
@{LOG_NAME_LIST}    gnb_snapshot
${ATT_FILE_PATH}    att_case06
${PHASE_FILE_PATH}    phase_case06
${UE_ID}       1
${PORT}    5002
${UE_NUM_SA}         3     #debug
${TS_CASE_LOG_PATH}      ${TEST_LOG_DIRECTORY()}/All
${scfc_configuration}     ${CURDIR}/config/SCFC_A_Case01_37577.xml
${swconfig_file}          ${CURDIR}/config/swconfig.txt
${iperf_port}     33950

${NRCELL700_CELLID}          615662268
${NRCELL701_CELLID}          615662269
${NRCELL703_CELLID}          615662270
${NRCELL704_CELLID}          615662271
${allowed_faults_ids}    4298,49,4290,6327,7107,7311,6203,4291

*** Test Cases ***
CB013711_A_CASE001_72a_1CC_feature_activation_deactivation
    Step1:Commission the above configuration on WebUI
#    step2:enable slim and check peak and tti
    step3:change to 72e and check enable slim

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Start Collecting GNB Syslog in 'before_onair' File
    Log To Console    Modify GNB swconfig and detach all ue
    Qualcom detach    Detach_UE_num=2
    Add RD
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}/SCFC_newest.xml
    copy_file       ${scfc_configuration}    ${scfc_path}
    Perform Full Commission       ${scfc_path}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    Wait '60s' for stable
    Get theoretical throughput from nrdim    SCF_Path=${scfc_path}
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    set suite variable    ${parent_dir}
    Build excel table
#    capture snapshot start once    on_air
    [Teardown]    Stop Collecting GNB Syslog in 'before_onair' File


step2:enable slim and check peak and tti
    Log To Console   \n-------------step2:enable slim and check peak and tti--------------
    Start Collecting GNB Syslog in 'step2' File
    Change 2 cells qRxLevMin value   cell700_qrx=-45    cell701_qrx=-22    gnb_id=37577
    change cells slim parameters    cell1_id=700    cell1_slim1=100    cell2_id=701    cell2_slim1=80   excel_line=1    tag=72a
    Attach UE to cell hardly    #change to 100+80
    Cell peak counter check   cell_700_DL_tp=1390    cell_700_uL_tp=200    cell_701_DL_tp=1100    cell_701_uL_tp=0    excel_line=1

    Start collect ttitrace    lcr_cell_id=700,701    name=tti_slim_disable
    Wait for '1s' to stop ttitrace with name'tti_slim_disable'
    run keyword and continue on failure    check_the_slim_prb_perslot    ${test_log_directory()}/All//tti_slim_disable_dl.csv
    ...   700    273    0
    run keyword and continue on failure    check_the_slim_prb_perslot    ${test_log_directory()}/All//tti_slim_disable_dl.csv
    ...   701    217    0
    Qualcom detach and stop data 2_4
    #change to 86+57.5
    change cells slim parameters    cell1_id=700    cell1_slim1=86    cell2_id=701    cell2_slim1=57.5    excel_line=2    tag=72a
    Wait '60s' for stable
    Attach UE to cell hardly
    Cell peak counter check    cell_700_DL_tp=1180    cell_700_uL_tp=165    cell_701_DL_tp=765    cell_701_uL_tp=0    excel_line=2
    Start collect ttitrace    lcr_cell_id=700,701    name=tti_slim_enable
    Wait for '1s' to stop ttitrace with name'tti_slim_enable'
    run keyword and continue on failure    check_the_slim_prb_perslot    ${test_log_directory()}/All//tti_slim_enable_dl.csv
    ...   700    233    6
    run keyword and continue on failure    check_the_slim_prb_perslot    ${test_log_directory()}/All//tti_slim_enable_dl.csv
    ...   701    154    4
    Qualcom detach and stop data 2_4
    [Teardown]    Stop Collecting GNB Syslog in 'step2' File

step3:change to 72e and check enable slim
    Log To Console   \n-------------step3:change to 72e and check enable slim--------------
    Start Collecting GNB Syslog in 'step3' File
    change cells slim parameters    cell1_id=700    cell1_slim1=86    cell2_id=701    cell2_slim1=57.5    excel_line=2    tag=72a      #+new
    change cells slim cells to be 72e    cell1_id=700    cell1_slim1=86    cell2_id=701    cell2_slim1=57.5    excel_line=3    tag=72e
    Attach UE to cell hardly    #change to 100+80
    Cell peak counter check   cell_700_DL_tp=1180    cell_700_uL_tp=165    cell_701_DL_tp=765    cell_701_uL_tp=0    excel_line=3

    Start collect ttitrace    lcr_cell_id=700,701    name=tti_slim_enable_72e
    Wait for '1s' to stop ttitrace with name'tti_slim_enable_72e'
    run keyword and continue on failure    check_the_slim_prb_perslot    ${test_log_directory()}/All/tti_slim_enable_72e_dl.csv
    ...   700    233    6
    run keyword and continue on failure    check_the_slim_prb_perslot    ${test_log_directory()}/All/tti_slim_enable_72e_dl.csv
    ...   701    154    4
    Qualcom detach and stop data 2_4
    Set Global Variable    ${scfc_configuration}    ${CURDIR}/config/SCFC_A_Case01_37577_CUS.xml
    Perform Full Commission       ${scfc_configuration}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    Wait '60s' for stable

    [Teardown]    Stop Collecting GNB Syslog in 'step3' File

change cells slim cells to be 72e
    [Arguments]    ${cell1_id}=700    ${cell1_slim1}=86    ${cell2_id}=701    ${cell2_slim1}=57.5    ${excel_line}=3    ${tag}=72e
    append to list    ${Cells_slim_Config}    cell${cell1_id}_${cell1_slim1}    cell${cell2_id}_${cell2_slim1}    ${tag}
    FOR    ${num}    IN RANGE    0    3
        ${num_table}    evaluate    ${num}+1
        modify excel cell       ${TEST_LOG_DIRECTORY()}/All/13711.xls     Sheet1     ${excel_line}    ${num_table}    ${Cells_slim_Config[${num}]}
    END
    FOR    ${num}    IN RANGE    1    2    #reproduce crash issue
        Log To Console   \nthis is the ${num}times enable 72e
        run keyword if    '${tag}'=='72e'    Online change parameters to 72e_a    json_file=delta_13711_slim_72e
        ...    actEcpri72e=true    nrCellType=16DL4UL    numberOfRxBeamforming=16Rx    fPdcchMonOccsnPo=3
        ...    700_bwpDN=2860    701_bwpDN=2575
        Get an check gNB active alarms and fault
    END
    FOR    ${num}    IN RANGE    1    2    #reproduce crash issue
        Log To Console   \nthis is the ${num}times enable 72e
        run keyword if    '${tag}'=='72a'    Online change parameters to 72e_a    json_file=delta_13711_slim_72e
        ...    actEcpri72e=false    nrCellType=16DL8UL    numberOfRxBeamforming=8Rx    fPdcchMonOccsnPo=2
        ...    700_bwpDN=860    701_bwpDN=575
        Get an check gNB active alarms and fault
    END

change cells slim parameters
    [Arguments]    ${cell1_id}=700    ${cell1_slim1}=86    ${cell2_id}=701    ${cell2_slim1}=57.5    ${excel_line}=2    ${tag}=72a
    append to list    ${Cells_slim_Config}    cell${cell1_id}_${cell1_slim1}    cell${cell2_id}_${cell2_slim1}    ${tag}
    FOR    ${num}    IN RANGE    0    3
        ${num_table}    evaluate    ${num}+1
        modify excel cell       ${TEST_LOG_DIRECTORY()}/All/13711.xls     Sheet1     ${excel_line}    ${num_table}    ${Cells_slim_Config[${num}]}
    END

    FOR    ${num}    IN RANGE    1    2    #reproduce crash issue
        Log To Console   \nthis is the ${num}times change cell's slim and check cell on air and alarm
        run keyword if    ${cell1_slim1}==86    Online change parameters    json_file=delta_13711_slim
        ...    cellid=${cell1_id}    chBw=90MHz    nbrOfBlankedPRBs=6    slimRfFilter=${cell1_slim1}MHz    bwpDN_Co=860    bwpDN_De=8601
        Get an check gNB active alarms and fault
        run keyword if    ${cell2_slim1}==57.5    Online change parameters    json_file=delta_13711_slim
        ...    cellid=${cell2_id}    chBw=60MHz    nbrOfBlankedPRBs=4    slimRfFilter=${cell2_slim1}MHz    bwpDN_Co=575    bwpDN_De=5751
    END

    FOR    ${num}    IN RANGE    1    2    #reproduce crash issue
        Log To Console   \nthis is the ${num}times ,cell's slim and check cell on air and alarm
        run keyword if    ${cell1_slim1}==100    Online change parameters    json_file=delta_13711_slim
        ...    cellid=${cell1_id}    chBw=100MHz    nbrOfBlankedPRBs=0    slimRfFilter=Nominal    bwpDN_Co=1000    bwpDN_De=10001
        Get an check gNB active alarms and fault
        run keyword if    ${cell2_slim1}==80    Online change parameters    json_file=delta_13711_slim
        ...    cellid=${cell2_id}    chBw=80MHz    nbrOfBlankedPRBs=0    slimRfFilter=Nominal    bwpDN_Co=800    bwpDN_De=8001
    END
    Wait '60s' for stable
    Backup Scf    ${test_log_directory()}/All    cell1_id${cell1_id}_cell1_slim${cell1_slim1}_scf.xml

Cell peak counter check
    [Arguments]    ${cell_700_DL_tp}    ${cell_700_uL_tp}    ${cell_701_DL_tp}    ${cell_701_uL_tp}    ${excel_line}
    ${PM_counter_file}    Download PM counter file after attach pass    ${TS_CASE_LOG_PATH}
    FOR    ${cell_id}    IN RANGE    700    702    # check each cells peak by PM counter
        ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=${cell_id}
        ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=${cell_id}
        ${NR_5258a_DL_MAX_PEAK}    get KPI NR_5258a    ${PM_counter_file}    cell_id=${cell_id}
        ${NR_5258a_UL_MAX_PEAK}    get KPI NR_5259a    ${PM_counter_file}    cell_id=${cell_id}
        Get 13711 eCPRI UPlane and Fast CPlane counter    ${PM_counter_file}    cell_id=${cell_id}
        Log To Console    cellid ${cell_id}‘s bler ${NR_5055b_res_bler} ${NR_5054a_ini_bler} tp_peak ${NR_5258a_DL_MAX_PEAK} ${NR_5258a_UL_MAX_PEAK}
        should be true    ${NR_5055b_res_bler}<0.001
        should be true    ${NR_5054a_ini_bler}<0.01
        run keyword if    ${cell_id}==700   should be true    ${NR_5258a_DL_MAX_PEAK}>=${cell_700_DL_tp}
        run keyword if    ${cell_id}==700   should be true    ${NR_5258a_UL_MAX_PEAK}>=${cell_700_uL_tp}
        run keyword if    ${cell_id}==701   should be true    ${NR_5258a_DL_MAX_PEAK}>=${cell_701_DL_tp}
        run keyword if    ${cell_id}==701   should be true    ${NR_5258a_UL_MAX_PEAK}>=${cell_701_uL_tp}
        append to list    ${Cells_slim_TP}     cell${cell_id}_${NR_5258a_DL_MAX_PEAK}    cell${cell_id}_${NR_5258a_UL_MAX_PEAK}
    END
    FOR    ${num}    IN RANGE    0    4
        ${num_table}    evaluate    ${num}+4
        modify excel cell       ${TEST_LOG_DIRECTORY()}/All/13711.xls     Sheet1     ${excel_line}    ${num_table}    ${Cells_slim_TP[${num}]}
    END

Attach UE to cell hardly
    FOR    ${bler_check}    IN RANGE    0    ${UE_NUM_SA}
        Attach UEs and send full buffer 2_4    cell_id=700    duration=1500
        log to console    start downloading PM counter file and check KPI
        ${PM_counter_file}    download PM counter file when attach on ongoing    ${TS_CASE_LOG_PATH}
        ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=700
        ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=700
        Run Keyword if    ${NR_5054a_ini_bler}<0.01    Exit For Loop
        Run Keyword if    ${NR_5054a_ini_bler}>0.01    Qualcom detach and stop data
    END

Build excel table
    ${colomn_13711}   create list
    ${Cells_slim_Config}   create list     #fill cell slim bandwidth
    ${Cells_slim_TP}   create list   #fill cell slim tp
    set global variable    ${Cells_slim_Config}
    set global variable    ${Cells_slim_TP}
    append to list    ${colomn_13711}    Cell_700_slim_bandwidth
    append to list    ${colomn_13711}    Cell_701_slim_bandwidth
    append to list    ${colomn_13711}    Cell_700_uplink_tp
    append to list    ${colomn_13711}    Cell_700_downlink_tp
    append to list    ${colomn_13711}    Cell_701_uplink_tp
    append to list    ${colomn_13711}    Cell_701_downlink_tp
    modify excel cell       ${TEST_LOG_DIRECTORY()}/All/13711.xls     Sheet1     0    0    ${SOFTWARE_INFO}_CB013711_perfomance_case3
    FOR    ${num}    IN RANGE    0    6
        ${num_table}    evaluate    ${num}+1
        modify excel cell       ${TEST_LOG_DIRECTORY()}/All/13711.xls     Sheet1     0    ${num_table}    ${colomn_13711[${num}]}
    END
    Log To Console    ${TEST_LOG_DIRECTORY()}/All/13711.xls


Wait for '${time}' to stop ttitrace with name'${tti_tag}'
    sleep   ${time}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode    name=${tti_tag}
    Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}

step3:attach UEs in cell2 and check logs by counter
    Log To Console   \n-------------step3:attach UEs in cell2 and check logs--------------
    Start Capture Gnb Syslogs in 'step3' file
    Change 2 cells qRxLevMin value   cell700_qrx=-45    cell701_qrx=-22    =37577
    FOR    ${bler_check}    IN RANGE    0    3
        Attach UEs and send full buffer    cell_id=2    duration=1500
        ${PM_counter_file}    download 2min PM counter file    ${TS_CASE_LOG_PATH}
        ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=2
        ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=2
        Run Keyword if    ${NR_5054a_ini_bler}<0.01    Exit For Loop
        Run Keyword if    ${NR_5054a_ini_bler}>0.01    Qualcom detach and stop data
    END
    Online change parameters    json_file=delta_13071_CIT    cell1_actDlSrsSubbandBm=true    cell2_actDlSrsSubbandBm=true
        ...    cell3_actDlSrsSubbandBm=false    cell4_actDlSrsSubbandBm=true
    Get 13711 eCPRI UPlane and Fast CPlane counter    ${PM_counter_file}    cell_id=2
    should be true    ${NR_5055b_res_bler}<0.001
    should be true    ${NR_5054a_ini_bler}<0.01
    Qualcom detach and stop data
    [Teardown]    Stop Capture Gnb Syslogs in 'step3' file

step4:attach UEs in cell3 and check logs by counter
    Log To Console   \n-------------step4:attach UEs in cell3 and check logs--------------
    Start Capture Gnb Syslogs in 'step4' file
    Change all cell qRxLevMin value   cell1_value=-22    cell2_value=-22    cell3_value=-45    cell4_value=-22    gnb_id=37577
    FOR    ${bler_check}    IN RANGE    0    3
        Attach UEs and send full buffer     cell_id=3    duration=1500
        ${PM_counter_file}    download 2min PM counter file    ${TS_CASE_LOG_PATH}
        ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=3
        ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=3
        Run Keyword if    ${NR_5054a_ini_bler}<0.01    Exit For Loop
        Run Keyword if    ${NR_5054a_ini_bler}>0.01    Qualcom detach and stop data
    END
    Get 13711 eCPRI UPlane and Fast CPlane counter    ${PM_counter_file}    cell_id=3
    Get RT and DFT user Num by counter    ${PM_counter_file}    cell_id=3    rt=2    dft=0
    should be true    ${NR_5055b_res_bler}<0.001
    should be true    ${NR_5054a_ini_bler}<0.01
    Qualcom detach and stop data
    [Teardown]    Stop Capture Gnb Syslogs in 'step4' file

step5:attach UEs in cell4 and check logs by counter
    Log To Console   \n-------------step5:attach UEs in cell4 and check logs by counter--------------
    Start Capture Gnb Syslogs in 'step5' file
    Change all cell qRxLevMin value   cell1_value=-22    cell2_value=-22    cell3_value=-22    cell4_value=-45    gnb_id=37577
    FOR    ${bler_check}    IN RANGE    0    3
        Attach UEs and send full buffer     cell_id=4    duration=1500
        ${PM_counter_file}    download 2min PM counter file    ${TS_CASE_LOG_PATH}
        ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=4
        ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=4
        Run Keyword if    ${NR_5054a_ini_bler}<0.01    Exit For Loop
        Run Keyword if    ${NR_5054a_ini_bler}>0.01    Qualcom detach and stop data
    END
    Get 13071 eCPRI UPlane and Fast CPlane counter    ${PM_counter_file}    cell_id=4
    Get RT and DFT user Num by counter    ${PM_counter_file}    cell_id=4    rt=2    dft=0
    should be true    ${NR_5055b_res_bler}<0.001
    should be true    ${NR_5054a_ini_bler}<0.01
    Qualcom detach and stop data
    [Teardown]    Stop Capture Gnb Syslogs in 'step5' file

step6:block cell and unblock
    Log To Console   \n-------------step6:block cell and unblock--------------
    Start Capture Gnb Syslogs in 'step6' file
    Block cell    54    gnb1302
    Unblock cell    54    gnb1302
    FOR    ${bler_check}    IN RANGE    0    3
        Attach UEs and send full buffer     cell_id=4    duration=1500
        ${PM_counter_file}    download 2min PM counter file    ${TS_CASE_LOG_PATH}
        ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=4
        ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=4
        Run Keyword if    ${NR_5054a_ini_bler}<0.01    Exit For Loop
        Run Keyword if    ${NR_5054a_ini_bler}>0.01    Qualcom detach and stop data
    END
    Get 13071 eCPRI UPlane and Fast CPlane counter    ${PM_counter_file}    cell_id=4
    Get RT and DFT user Num by counter    ${PM_counter_file}    cell_id=4    rt=2    dft=0
    should be true    ${NR_5055b_res_bler}<0.001
    should be true    ${NR_5054a_ini_bler}<0.01

    Qualcom detach and stop data
    [Teardown]    Stop Capture Gnb Syslogs in 'step6' file

step7:modify cells actDlSrsSubbandBm and check peak
    Log To Console   \n-------------step7:modify cells actDlSrsSubbandBm and check peak--------------
    Start Capture Gnb Syslogs in 'step7' file
    modify cells actDlSrsSubbandBm and no fatal
 #   attach UEs to cell    cell_id_check=1
 #   attach UEs to cell    cell_id_check=2
 #   attach UEs to cell    cell_id_check=3
    [Teardown]    Stop Capture Gnb Syslogs in 'step7' file

attach UEs to cell
    [Arguments]    ${cell_id_check}
    run keyword if     ${cell_id_check}==1    Change all cell qRxLevMin value   cell1_value=-45    cell2_value=-22
    ...    cell3_value=-22    cell4_value=-22    gnb_id=575
    run keyword if     ${cell_id_check}==2    Change all cell qRxLevMin value   cell1_value=-22    cell2_value=-45
    ...    cell3_value=-22    cell4_value=-22    gnb_id=575
    run keyword if     ${cell_id_check}==3    Change all cell qRxLevMin value   cell1_value=-22    cell2_value=-22
    ...    cell3_value=-45    cell4_value=-22    gnb_id=575
    run keyword if     ${cell_id_check}==4    Change all cell qRxLevMin value   cell1_value=-22    cell2_value=-22
    ...    cell3_value=-22    cell4_value=-45    gnb_id=575
    FOR    ${bler_check}    IN RANGE    0    3
        Attach UEs and send full buffer     cell_id=4    duration=1500
        ${PM_counter_file}    download 2min PM counter file    ${TS_CASE_LOG_PATH}
        ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=4
        ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=4
        Run Keyword if    ${NR_5054a_ini_bler}<0.01    Exit For Loop
        Run Keyword if    ${NR_5054a_ini_bler}>0.01    Qualcom detach and stop data
    END
    Get 13071 eCPRI UPlane and Fast CPlane counter    ${PM_counter_file}    cell_id=${cell_id_check}
    Get RT and DFT user Num by counter    ${PM_counter_file}    cell_id=${cell_id_check}    rt=2    dft=0
    should be true    ${NR_5055b_res_bler}<0.001
    should be true    ${NR_5054a_ini_bler}<0.01
    Qualcom detach and stop data


Online change parameters
     [Arguments]    ${json_file}    ${cellid}    ${chBw}    ${nbrOfBlankedPRBs}
     ...    ${slimRfFilter}    ${bwpDN_Co}    ${bwpDN_De}
     log to console    \n${json_file} ${cellid} ${chBw} ${nbrOfBlankedPRBs} ${slimRfFilter} ${bwpDN_Co} ${bwpDN_De}
     ${template}    OperatingSystem.Get File    ${CURDIR}/config/json/${json_file}.json
     log to console    ${template}
     ${message} =    Replace Variables    ${template}
     Create File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${json_file}_modified.json    ${message}
     Online recommissioning with delta json file
     ...   ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${json_file}_modified.json
     Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
     Wait until keyword succeeds    1600s    60s    check cell status

Online change parameters to 72e_a
     [Arguments]    ${json_file}    ${actEcpri72e}    ${nrCellType}    ${numberOfRxBeamforming}
     ...    ${fPdcchMonOccsnPo}    ${700_bwpDN}    ${701_bwpDN}
     log to console    \n${json_file} ${actEcpri72e} ${nrCellType} ${numberOfRxBeamforming} ${fPdcchMonOccsnPo}
     ...    ${700_bwpDN}    ${701_bwpDN}
     ${template}    OperatingSystem.Get File    ${CURDIR}/config/json/${json_file}.json
     log to console    ${template}
     ${message} =    Replace Variables    ${template}
     Create File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${json_file}_modified.json    ${message}
     Online recommissioning with delta json file
     ...   ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${json_file}_modified.json
     Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
     Wait until keyword succeeds    1600s    60s    check cell status


Get CELL Operational State
    [Arguments]    ${cell_id}=700
    COAM.setup admin    bts_host=192.168.255.129    alias=coam_operational
    ${cell_status}=    COAM.Get Cells Info    connection=coam_operational
    [Return]    ${cell_status[${cell_id}-1]['status']['operationalState']}
    [Teardown]    COAM.Teardown    coam_operational

Unblock Cell
     [Arguments]    ${alias}
     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
     ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
     : FOR    ${nrcel}    IN    @{nrcel_list}
     \    Comment    Log to console    \n physical cell ${lncel.phyCellId} is ${lncel.blockingState}
     \    Run Keyword If    '${nrcel.operationalState}'=='Disabled'
          ...    Run Keywords    TAF_ADMIN.unlock     ${nrcel.id}    connection=${alias}  AND    sleep    60

Block Cell
     [Arguments]    ${phy_cell_id}    ${alias}
     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
     ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
     : FOR    ${nrcel}    IN    @{nrcel_list}
     \    Comment    Log to console    \n physical cell ${nrcel.phyCellId} is ${nrcel.blockingState}
     \    Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.blockingState}'=='Unblocked'
          ...    Run Keywords    TAF_ADMIN.lock    ${nrcel.id}    timeout=60    connection=${alias}  AND    sleep    60
     TAF_ADMIN.teardown    connection=${alias}

capture snapshot start once
    [Arguments]    ${log_tag}
    Log To Console    --capture snapshot start
    Run Keyword And Ignore Error    Collect GNB SnapShot    target_file_name=${TEST_LOG_DIRECTORY()}/All/${log_tag}_gnb_comon_snapshot.zip

cell peak check
    [Arguments]    ${cell_id}=1
	${cellsid}    create list    ${NRCELL${cell_id}_CELLID}
    ${target_dl_tput}=    evaluate    ${cell${cell_id}_expect_tput}[0]*0.95
	${target_ul_tput}=    evaluate    ${cell${cell_id}_expect_tput}[1]*0.95
	Log To Console   cell${cellsid}_target_dl_tput is ${target_dl_tput}
    Log To Console   cell${cellsid}_target_ul_tput is ${target_ul_tput}

    ${nrdim_dl_tput}=    evaluate    ${cell${cell_id}_expect_tput}[0]*1
	${nrdim_ul_tput}=    evaluate    ${cell${cell_id}_expect_tput}[1]*1
    Log To Console   cell${cellsid}_expect_dl_tput is ${nrdim_dl_tput}
    Log To Console   cell${cellsid}_expect_ul_tput is ${nrdim_ul_tput}
	${tput_log}    power_ue.Collect Tput    ue_type=${UE_TYPE}    duration=1m    check_source=aasyslog
    run keyword and continue on failure    power_ue.Check Tput     ue_type=${UE_TYPE}     direction=dl     cells=${cellsid}   log=${tput_log}
     ...    target_throughput=${nrdim_dl_tput}    target_avg_percent=0.95    min_percent=0.85    check_source=aasyslog
     run keyword and continue on failure    power_ue.Check Tput     ue_type=${UE_TYPE}     direction=ul     cells=${cellsid}    log=${tput_log}
     ...    target_throughput=${nrdim_ul_tput}    target_avg_percent=0.94    min_percent=0.85    check_source=aasyslog

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
	    ${iperf_port_1}    evaluate    ${iperf_port}+${ue_index}+1
	    ${ue_type}    translate power ue type from testline    ${ue_index}
        Log To Console    UE${ue_index} DL_UL full data push start
        power_ue.Start traffic   ue_index=${ue_index}    ue_type=${ue_type}   direction=dl   throughput=1600M
        ...    duration=${duration}
        power_ue.Start traffic   ue_index=${ue_index}    ue_type=${ue_type}   direction=ul   throughput=300M
        ...    duration=${duration}    iperf_port=${iperf_port_1}
     END

Attach UEs and send full buffer 2_4
    [Arguments]    ${cell_id}=1    ${duration}=1500
	FOR    ${ue_index}    IN RANGE    1    3
	    Log To Console    \n--UE${ue_index} attachs to cell${cell_id}--
	    ${ue_type}    translate power ue type from testline    ${ue_index}
	    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}
        power_ue.Verify attach    ue_type=${UE_TYPE}   ue_index=${ue_index}    5Grach_ed=${5Grach_ed_0}    4G_check=False
#        Log To Console    UE${ue_index} DL_UL little data push start
#        power_ue.Start traffic   ue_index=${ue_index}    ue_type=${ue_type}   direction=dl   throughput=10M
#        ...    duration=${duration}
#        power_ue.Start traffic   ue_index=${ue_index}    ue_type=${ue_type}   direction=ul   throughput=1M
#        ...    duration=${duration}    iperf_port=${iperf_port}+${ue_index}
    END
	FOR    ${ue_index}    IN RANGE    1    3
	    ${iperf_port_1}    evaluate    ${iperf_port}+${ue_index}+1
	    ${ue_type}    translate power ue type from testline    ${ue_index}
        Log To Console    UE${ue_index} DL_UL full data push start
        power_ue.Start traffic   ue_index=${ue_index}    ue_type=${ue_type}   direction=dl   throughput=1600M
        ...    duration=${duration}
        power_ue.Start traffic   ue_index=${ue_index}    ue_type=${ue_type}   direction=ul   throughput=300M
        ...    duration=${duration}    iperf_port=${iperf_port_1}
     END



Qualcom detach and stop data
     FOR    ${ue_index}    IN RANGE    1    ${UE_NUM_SA}
         Log To Console    UE${ue_index} detach and deactive data
         ${ue_type}    translate power ue type from testline    ${ue_index}
	     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
         Stop UE traffic    ue_type=${ue_type}    ue_index=${ue_index}
         power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    END

Qualcom detach and stop data 2_4
     FOR    ${ue_index}    IN RANGE    1    3
         Log To Console    UE${ue_index} detach and deactive data
         ${ue_type}    translate power ue type from testline    ${ue_index}
	     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
         Stop UE traffic    ue_type=${ue_type}    ue_index=${ue_index}
         power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    END

Qualcom detach
     [Arguments]    ${Detach_UE_num}=4
     FOR    ${ue_index}    IN RANGE    1    ${Detach_UE_num}+1
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


Get theoretical throughput from nrdim
    [Arguments]    ${SCF_Path}    ${pcellid}=700
    [Documentation]  Get theoretical throughput from nrdim
    ...    RETURN list [theoretical_dl , theoretical_ul]

    ${cell700_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=${pcellid}

    ${cell701_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=701

#    ${cell3_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
#    ...    scf_path=${SCF_Path}    cell_id=3
#
#    ${cell4_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
#    ...    scf_path=${SCF_Path}    cell_id=4

    Set Test Variable   ${cell700_expect_tput}
    Set Test Variable   ${cell701_expect_tput}
#    Set Test Variable   ${cell3_expect_tput}
#    Set Test Variable   ${cell4_expect_tput}
    Log To Console   cell700_expect_tput is ${cell700_expect_tput}
    Log To Console   cell701_expect_tput is ${cell701_expect_tput}
#    Log To Console   cell3_expect_tput is ${cell3_expect_tput}
#    Log To Console   cell4_expect_tput is ${cell4_expect_tput}


Add RD
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
