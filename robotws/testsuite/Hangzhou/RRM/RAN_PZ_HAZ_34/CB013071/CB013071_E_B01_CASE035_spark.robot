*** Settings ***
Documentation     CB013071 case035
Test Timeout      120 minutes
Suite Setup       Sg13 Common Suite Setup
Suite Teardown    Sg13 Common Suite Teardown
Test Setup        SG13 Common Test Setup    ${allowed_faults_ids}
Test Teardown     SG13 Common Test Teardown
Force Tags    spark    CLOUD_5G_CLASSICAL_ASIML_ABIPB1_AVQL    for_gNB37494


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
@{LOG_NAME_LIST}           gnb_snapshot
${ATT_FILE_PATH}           att_case035
${PHASE_FILE_PATH}         phase_case035
${TS_CASE_LOG_PATH}      ${TEST_LOG_DIRECTORY()}/All
${UE_INDEX}                   0
${PORT}                    5002
${UE_NUM_SA}               4
${NRCELL1_CELLID}          68719474961
${NRCELL2_CELLID}          68719474962
${NRCELL3_CELLID}          68719474963
${NRCELL2147483647_CELLID}          68719474964
${scfc_configuration}      ${CURDIR}/config/SCFC_Case035_37494.xml
${swconfig_file}           ${CURDIR}/config/swconfig.txt
${allowed_faults_ids}    49

*** Test Cases ***
CB013071_E_B01_CASE035_32TRX_dual_band_SubbandBm_200Mhz_plus_4CC
    Step1:Commission the above configuration on WebUI
    step2:attach UEs in cell1 and check logs
    step3:attach UEs in cell2 and check logs
    step4:attach UEs in cell3 and check logs
    step5:attach UEs in cell4 and check logs


*** Keywords ***
Step1:Commission the above configuration on WebUI
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Start Collecting GNB Syslog in 'before_onair' File
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}/SCFC_newest.xml
    copy_file       ${scfc_configuration}    ${scfc_path}
    Add RD
    Perform Full Commission       ${scfc_path}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    Get theoretical throughput from nrdim    SCF_Path=${scfc_path}
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    set suite variable    ${parent_dir}
    #Set UE pos
    [Teardown]    Stop Collecting GNB Syslog in 'before_onair' File

step2:attach UEs in cell1 and check logs
    Log To Console   \n-------------step2:attach UEs in cell1 and check logs--------------
    Start capture only gnb syslog in 'step2_attach_ues_cell2' file
    #Change all cell qRxLevMin value   cell1_value=-56    cell2_value=-22    cell3_value=-22    cell4_value=-22
	block all cells
	cell unblock
    Attach UEs and send full buffer and check tput
    ${PM_counter_file}    download PM counter file    ${TS_CASE_LOG_PATH}
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti_cell1'
    Get 13071 eCPRI UPlane and Fast CPlane counter    ${PM_counter_file}    cell_id=1
    run keyword and ignore error    Get RT and DFT user Num by counter    ${PM_counter_file}    cell_id=1    rt=4    dft=0
    [Teardown]    Stop capture only gnb syslog in 'step2_attach_ues_cell2' file

step3:attach UEs in cell2 and check logs
    Log To Console   \n-------------step3:attach UEs in cell2 and check logs--------------
    Start capture only gnb syslog in 'step3_attach_ues_cell2' file
    #Change all cell qRxLevMin value   cell1_value=-22    cell2_value=-56    cell3_value=-22    cell4_value=-22
    Detach all UEs
	cell unblock    52
	cell block    51
    Attach UEs and send full buffer and check tput    cell_id=2
    ${PM_counter_file}    download PM counter file    ${TS_CASE_LOG_PATH}
    Get 13071 eCPRI UPlane and Fast CPlane counter    ${PM_counter_file}    cell_id=2
    run keyword and ignore error    Get RT and DFT user Num by counter    ${PM_counter_file}    cell_id=2    rt=4    dft=0
#    Start collect ttitrace
#    Wait for '1s' to stop ttitrace with name'tti_cell2'

    [Teardown]    Stop capture only gnb syslog in 'step3_attach_ues_cell2' file

step4:attach UEs in cell3 and check logs
    Log To Console   \n-------------step4:attach UEs in cell3 and check logs--------------
    Start capture only gnb syslog in 'step4_attach_ues_cell3' file
    #Change all cell qRxLevMin value   cell1_value=-22    cell2_value=-22    cell3_value=-56    cell4_value=-22
    Detach all UEs
	cell unblock    53
	cell block    52
    Attach UEs and send full buffer and check tput    cell_id=3
    ${PM_counter_file}    download PM counter file    ${TS_CASE_LOG_PATH}
    Get 13071 eCPRI UPlane and Fast CPlane counter    ${PM_counter_file}    cell_id=3
    run keyword and ignore error    Get RT and DFT user Num by counter    ${PM_counter_file}    cell_id=3    rt=4    dft=0
#    Start collect ttitrace
#    Wait for '1s' to stop ttitrace with name'tti_cell3'


    [Teardown]    Stop capture only gnb syslog in 'step4_attach_ues_cell3' file

step5:attach UEs in cell4 and check logs
    Log To Console   \n-------------step5:attach UEs in cell4 and check logs--------------
    Start capture only gnb syslog in 'step5_attach_ues_cell4' file
    #Change all cell qRxLevMin value   cell1_value=-22    cell2_value=-22    cell3_value=-22    cell4_value=-56
    Detach all UEs
	cell unblock    54
	cell block    53
    Attach UEs and send full buffer and check tput    cell_id=2147483647
    ${PM_counter_file}    download PM counter file    ${TS_CASE_LOG_PATH}
    Get 13071 eCPRI UPlane and Fast CPlane counter    ${PM_counter_file}    cell_id=2147483647
    run keyword and ignore error    Get RT and DFT user Num by counter    ${PM_counter_file}    cell_id=2147483647    rt=4    dft=0
#    Start collect ttitrace
#    Wait for '1s' to stop ttitrace with name'tti_cell4'
    [Teardown]    Stop capture only gnb syslog in 'step5_attach_ues_cell4' file

Attach UEs and send full buffer and check tput
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

step6:stop all UEs data and detach all UEs
    Log To Console   \n-------------step6:stop all UEs data and detach all UEs---------------
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#       Spark UE Stop traffic    dl    ue_index=${num}
       Spark UE Detach    ue_index=${num}
    END

block all cells
    Log To Console   \n-------------block all cells--------------
    cell block    51
    cell block    52
    cell block    53
    cell block    54

cell block
    [Arguments]    ${physCellId}=51
    Block cell    ${physCellId}    gnb37494

cell unblock
    [Arguments]    ${physCellId}=51
    Log To Console   \n-------------block cell and unblock--------------
    Unblock cell    ${physCellId}    gnb37494

Detach all UEs
    Log To Console   \n-------------Detach all UEs---------------
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
       Spark UE Detach    ue_index=${num}
    END

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

    ${cell2147483647_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=2147483647

    Set Test Variable   ${cell1_expect_tput}
    Set Test Variable   ${cell2_expect_tput}
    Set Test Variable   ${cell3_expect_tput}
    Set Test Variable   ${cell2147483647_expect_tput}

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


Set UE pos
    Set Mcs3 Channel Phase And Attenuation    ${CURDIR}/config/${ATT_FILE_PATH}    ${CURDIR}/config/${PHASE_FILE_PATH}
    ...    frequency=3500_1_ALL


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
