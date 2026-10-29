*** Settings ***
Test Timeout      600 minutes
Suite Setup       Sg13 Common Suite Setup
Suite Teardown    Sg13 Common Suite Teardown
Test Setup    SG13 Common Test Setup
Test Teardown    SG13 Common Test Teardown
Force Tags    Qualmn    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEHC_VEFHAZ4
Documentation     CB013071 case03   author  l3gao
...    b1a74f66  ue1
...    6fbcbb79  ue2
...    92683215  ue3
...    ca3e3465  ue4
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
${UE_INDEX}    1
${PORT}    5002
${UE_NUM_SA}    2     #debug
${UE_NUM_rt}    2
${TS_CASE_LOG_PATH}      ${TEST_LOG_DIRECTORY()}/All

${scfc_configuration}                 ${CURDIR}/config/SCFC_D_Case25_37494.xml
#${scfc_configuration}                 ${CURDIR}/config/SCFC_D_Case25_37494_crash_debug.xml
${swconfig_file}                      ${CURDIR}/config/swconfig.txt
${iperf_port}     33802

${NRCELL1_CELLID}          599905
${NRCELL2_CELLID}          599906
${NRCELL3_CELLID}          599907
${NRCELL4_CELLID}          599908


*** Test Cases ***
CB013071_D_B01_CASE025_32TRX_dual_band_SubbandBm_3CC_Pmcounters
    Step1:Commission the above configuration on WebUI
    step2:attach UEs cell and check logs    cell_id_check=1
    step2:attach UEs cell and check logs    cell_id_check=2
    step2:attach UEs cell and check logs    cell_id_check=3
    step2:attach UEs cell and check logs    cell_id_check=4

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
#    Get gNB history alarms and fault
    Start Collecting GNB Syslog in 'before_onair' File
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}/SCFC_newest.xml
    copy_file       ${scfc_configuration}    ${scfc_path}
    Add RD
    Perform Full Commission       ${scfc_path}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    Get theoretical throughput from nrdim    SCF_Path=${scfc_path}

    ${parent_dir}=    Join Path    ${CURDIR}    ..
    set suite variable    ${parent_dir}
#    Set UE pos
    [Teardown]    Stop Collecting GNB Syslog in 'before_onair' File

step2:attach UEs cell and check logs
    [Arguments]    ${cell_id_check}=1
    Log To Console   \n-------------step2:attach UEs in cell${cell_id_check} and check logs--------------
    Start capture only gnb syslog in 'step2_attach_ues_cell${cell_id_check}' file
    run keyword if     ${cell_id_check}==1   Change all cell qRxLevMin value   cell1_value=-56
    run keyword if     ${cell_id_check}==2   Change all cell qRxLevMin value   cell2_value=-56
    run keyword if     ${cell_id_check}==3   Change all cell qRxLevMin value   cell3_value=-56
    run keyword if     ${cell_id_check}==4   Change all cell qRxLevMin value   cell4_value=-56

    FOR    ${bler_check}    IN RANGE    0    3
        Attach UEs and send full buffer and check tput    cell_id=${cell_id_check}
#        ${PM_counter_file}    download 2min PM counter file    ${TS_CASE_LOG_PATH}
#        ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=${cell_id_check}
#        ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=${cell_id_check}
#        Run Keyword if    ${NR_5054a_ini_bler}<0.01    Exit For Loop
#        Run Keyword if    ${NR_5054a_ini_bler}>0.01    Detach all UEs
    END
    run keyword if     ${cell_id_check}==1     modify cells actDlSrsSubbandBm and no fatal
    [Teardown]    Stop capture only gnb syslog in 'step2_attach_ues_cell${cell_id_check}' file

modify cells actDlSrsSubbandBm and no fatal
    FOR    ${num}    IN RANGE    1    30    #reproduce crash issue
        Log To Console   \nthis is cell3 the ${num}th times commission actDlSrsSubbandBm
        Online change parameters    json_file=delta_13071_D    cell1_actDlSrsSubbandBm=true    cell2_actDlSrsSubbandBm=false
        ...    cell3_actDlSrsSubbandBm=false    cell4_actDlSrsSubbandBm=false
        Online change parameters    json_file=delta_13071_D    cell1_actDlSrsSubbandBm=false    cell2_actDlSrsSubbandBm=false
        ...    cell3_actDlSrsSubbandBm=false    cell4_actDlSrsSubbandBm=false
        Get an check gNB active alarms and fault
    END
    FOR    ${num}    IN RANGE    1    2    #reproduce crash issue
        Log To Console   \nthis is cell2 the ${num}th times commission actDlSrsSubbandBm
        Online change parameters    json_file=delta_13071_D    cell1_actDlSrsSubbandBm=true    cell2_actDlSrsSubbandBm=false
        ...    cell3_actDlSrsSubbandBm=true    cell4_actDlSrsSubbandBm=true
        Online change parameters    json_file=delta_13071_D    cell1_actDlSrsSubbandBm=true    cell2_actDlSrsSubbandBm=true
        ...    cell3_actDlSrsSubbandBm=true    cell4_actDlSrsSubbandBm=true
    END
    FOR    ${num}    IN RANGE    1    2    #reproduce crash issue
        Log To Console   \nthis is cell1 the ${num}th times commission actDlSrsSubbandBm
        Online change parameters    json_file=delta_13071_D    cell1_actDlSrsSubbandBm=false    cell2_actDlSrsSubbandBm=true
        ...    cell3_actDlSrsSubbandBm=true    cell4_actDlSrsSubbandBm=true
        Online change parameters    json_file=delta_13071_D    cell1_actDlSrsSubbandBm=true    cell2_actDlSrsSubbandBm=true
        ...    cell3_actDlSrsSubbandBm=true    cell4_actDlSrsSubbandBm=true
    END

Attach UEs and send full buffer and check tput
    [Arguments]    ${cell_id}=1
	FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
	    Log To Console    cell${cell_id} UE${num} attachs
	    Spark UE Attach    ue_index=${num}    power_reset=true

	    Spark UE Send DL Traffic    ue_index=${num}    send_traffic=1326MKbits/sec    send_duration=600    apn_address=wustatic    ue_mode=None
	    Spark UE Send UL Traffic    ue_index=${num}    send_traffic=205MKbits/sec    send_duration=600    apn_address=wustatic    ue_mode=None
	END

	${cellsid}    create list    ${NRCELL${cell_id}_CELLID}
	${expect_dl_tput}=    evaluate    ${cell${cell_id}_expect_tput}[0]*0.9
	${expect_ul_tput}=    evaluate    ${cell${cell_id}_expect_tput}[1]*0.9
	Spark UE Check Tput    ue_index=${UE_INDEX}    expect_traffic=${expect_dl_tput}
	...    check_source=aasyslog    duration=1m    cells=${cellsid}    target_avg_percent=0.8
	Spark UE Check Tput    ue_index=${UE_INDEX}    direction=ul    expect_traffic=${expect_ul_tput}
	...    check_source=aasyslog    duration=1m    cells=${cellsid}    target_avg_percent=0.8


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

Detach all UEs
    Log To Console   \n-------------Detach all UEs---------------
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
       Spark UE Detach    ue_index=${num}
    END

Add RD
#    Add GNB swconfig    0x58077e:1   #rdEnableMuAwareTdSchTtiTrace
#    Add GNB swconfig    0x580539:10   #Num UE threshold,to collect trace
    Add GNB swconfig   0x9D0000:15

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

    ${cell4_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=4

    Set Test Variable   ${cell1_expect_tput}
    Set Test Variable   ${cell2_expect_tput}
    Set Test Variable   ${cell3_expect_tput}
    Set Test Variable   ${cell4_expect_tput}

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


Set UE pos
    Set Mcs3 Channel Phase And Attenuation    ${CURDIR}/config/${ATT_FILE_PATH}    ${CURDIR}/config/${PHASE_FILE_PATH}
    ...    frequency=3500_0.25_ALL


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

