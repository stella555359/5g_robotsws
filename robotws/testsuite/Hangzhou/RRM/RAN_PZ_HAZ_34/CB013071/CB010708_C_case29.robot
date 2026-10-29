*** Settings ***
Test Timeout      120 minutes
Suite Setup       Sg13 Common Suite Setup
Suite Teardown    Sg13 Common Suite Teardown
Test Setup        SG13 Common Test Setup
Test Teardown     SG13 Common Test Teardown
Force Tags    spark    CLOUD_5G_CLASSICAL_ASIML_ABIPB1_AVQL
Documentation     CB010708 case29  author  l3gao
...    1-4 UE1；5-8 UE2；9-12 UE3 UE4；13-16 UE5 UE6 UE7 UE8.

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
@{LOG_NAME_LIST}           gnb_snapshot
${ATT_FILE_PATH}           att_case06
${PHASE_FILE_PATH}         phase_case06
${UE_INDEX}                   0
${PORT}                    5002
${UE_NUM_SA}               2
${NRCELL1_CELLID}          44048385
#${NRCELL1_CELLID}          599905
${scfc_configuration}      ${CURDIR}/config/SCFC_10708_C_Case29_Line10754.xml
#${scfc_configuration}      ${CURDIR}/config/SCFC_D_Case25_37494.xml
${swconfig_file}           ${CURDIR}/config/swconfig.txt


*** Test Cases ***
CB010708_C2_case029_two_rank2_Ues_16RX_PUSCH_performance_with_Attenuation_change
    Step1:Commission the above configuration on WebUI
    step2:attach UEs in cell1 and check logs

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Start Capture Gnb Syslogs in 'before_onair' file
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}/SCFC_newest.xml
    copy_file       ${scfc_configuration}    ${scfc_path}
    Perform Full Commission       ${scfc_path}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    Get theoretical throughput from nrdim    SCF_Path=${scfc_path}

    ${parent_dir}=    Join Path    ${CURDIR}    ..
    set suite variable    ${parent_dir}
#    Set UE pos
    [Teardown]    Stop Capture Gnb Syslogs in 'before_onair' file

step2:attach UEs in cell1 and check logs
    Log To Console   \n-------------step2:attach UEs in cell1 and check logs--------------
    Start Capture Gnb Syslogs in 'step2_attach_ues_cell2' file
    online change parameters
     ...    json_file=delta_10708    basicBeamSet=beamSet_4    nrBtsBeamRefinementP2=false    numberOfTransmittedSsBlocks=4
     ...    bwpDN_Co=3    bwpDN_De=54
     ...    frameStructureType=semiStatic    guardPeriodLength=2Symbols    tdLteUlDlConfig=tdLteConfig2    ulDlDataSlotRatio=3/7
     ...    actDlSrsBm=true    actUlSrsBm=true    prachConfigurationIndex=98
    Attach UEs and send full buffer and check tput
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti_cell1'

    Detach all UEs
    [Teardown]    Stop Capture Gnb Syslogs in 'step2_attach_ues_cell2' file

Online change parameters
     [Arguments]    ${json_file}    ${basicBeamSet}    ${nrBtsBeamRefinementP2}    ${numberOfTransmittedSsBlocks}
     ...    ${bwpDN_Co}    ${bwpDN_De}
     ...    ${frameStructureType}    ${guardPeriodLength}    ${tdLteUlDlConfig}    ${ulDlDataSlotRatio}
     ...    ${actDlSrsBm}    ${actUlSrsBm}    ${prachConfigurationIndex}    ${lteToNrFrameShift}=0ms
     log to console    ${basicBeamSet} ${nrBtsBeamRefinementP2} ${numberOfTransmittedSsBlocks} ${bwpDN_Co} ${bwpDN_De}
     ...    ${frameStructureType} ${guardPeriodLength} ${tdLteUlDlConfig} ${ulDlDataSlotRatio}
     ...    ${actDlSrsBm} ${actUlSrsBm} ${prachConfigurationIndex} ${lteToNrFrameShift}
     ${template}    OperatingSystem.Get File    ${CURDIR}/config/json/${json_file}.json
     log to console    ${template}
     ${message} =    Replace Variables    ${template}
     Create File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${json_file}_modified.json    ${message}
     Online recommissioning with delta json file
     ...   ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${json_file}_modified.json
     Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair

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
	run keyword and continue on failure    Spark UE Check Tput    ue_index=${num}    expect_traffic=${expect_dl_tput}
	...    check_source=aasyslog    duration=3m    cells=${cellsid}    target_avg_percent=0.8
	run keyword and continue on failure    Spark UE Check Tput    ue_index=${num}    direction=ul    expect_traffic=${expect_ul_tput}
	...    check_source=aasyslog    duration=3m    cells=${cellsid}    target_avg_percent=0.8




step6:stop all UEs data and detach all UEs
    Log To Console   \n-------------step6:stop all UEs data and detach all UEs---------------
    FOR    ${num}    IN RANGE    0    ${UE_NUM_SA}
#       Spark UE Stop traffic    dl    ue_index=${num}
       Spark UE Detach    ue_index=${num}
    END

Detach all UEs
    Log To Console   \n-------------Detach all UEs---------------
    FOR    ${num}    IN RANGE    0    ${UE_NUM_SA}
       Spark UE Detach    ue_index=${num}
    END

Get theoretical throughput from nrdim
    [Arguments]    ${SCF_Path}    ${pcellid}=1
    [Documentation]  Get theoretical throughput from nrdim
    ...    RETURN list [theoretical_dl , theoretical_ul]

    ${cell1_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=${pcellid}

#    ${cell2_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
#    ...    scf_path=${SCF_Path}    cell_id=2
#
#    ${cell3_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
#    ...    scf_path=${SCF_Path}    cell_id=3
#
#    ${cell4_expect_tput}    nrdim_get_tput.Get Theoretical Throughput
#    ...    scf_path=${SCF_Path}    cell_id=4

    Set Test Variable   ${cell1_expect_tput}
#    Set Test Variable   ${cell2_expect_tput}
#    Set Test Variable   ${cell3_expect_tput}
#    Set Test Variable   ${cell4_expect_tput}

Add RD
    Add GNB swconfig    0x58077e:1   #rdEnableMuAwareTdSchTtiTrace
    Add GNB swconfig    0x580539:10   #Num UE threshold,to collect trace

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


