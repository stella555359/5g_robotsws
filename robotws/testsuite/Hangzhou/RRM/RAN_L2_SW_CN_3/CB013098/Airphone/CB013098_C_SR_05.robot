*** Settings ***
Documentation     Author: qianqian.ren@nokia-sbell.com
...
...               QC case full name:
...               CB009235_DL_MU_100UE.robot
...

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LO_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_mqin
Test Timeout      360 minutes
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot
Library           taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}          SCFC_CB013098_C_SR_05.xml
${AIRPHONE_NAME}      IPHY_AQQL_1CELL_APLO_8x4_GL.xml
${WTS_NAME}           wts_CB013098_C_SR_05.lua
@{LOG_NAME_LIST}      egatelog\    ap_snapshot    gnb_snapshot
#sosreport
${cellDepType}    text|SA+NSA|//*[@name\="cellDepType"]
${chBw}           text|100MHz|//*[@name\="chBw"]
${bSRS}           text|2|//*[@name\="bSRS"]

${actDlMuMimoEnh}                       text|false|//*[@name\="actDlMuMimoEnh"]
${actMuAwareTdSch}         text|false|//*[@name\="actMuAwareTdSch"]
${dlMuMimoRankAdaption}    text|disabled|//*[@name\="dlMuMimoRankAdaption"]
${dlMuAwareCorrThd}        text|2|//*[@name\="dlMuAwareCorrThd"]
${dlMuAwarePrbRatio}       text|20|//*[@name\="dlMuAwarePrbRatio"]
${dlMuMimoCorrThd}         text|2|//*[@name\="dlMuMimoCorrThd"]
${dlMuPairingPrbRatio}     text|20|//*[@name\="dlMuPairingPrbRatio"]
${customBeamSetName}    text|BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001|//*[@name\="customBeamSetName"]
${miNrBfConfig}         text|5min|//*[@name\="miNrBfConfig"]
${par_of_bsr_name}    BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
${tiltOffset}      text|0|//*[@name\="tiltOffset"]

${pattern}     t2r4_n2_pusch_1layer
${pattern1}    CA_P2_8x4_t2r4_n2
${pattern2}    CA_P2_8x4_t1r4_n1
${pattern3}    CA_P2_8x4_t4r4_n4
${pattern4}    CA_P2_8x4_noTas_n2
${pattern5}    TDD_NSA_CA_NoRefinebeam
#${pattern6}    ue_eutra_nr_cap

#${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=UL_MIMO
#${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=50 zenith\=-15 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=45 zenith\=-26 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=40 zenith\=-15 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=35 zenith\=-26 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=-15 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=25 zenith\=-26 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=20 zenith\=-15 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=-26 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=10 zenith\=-15 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=5 zenith\=-26 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id\=12 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=-15 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id\=13 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-5 zenith\=-26 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE14}    ul_mimo_srs_beam_pos_nr profile_id\=14 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-10 zenith\=-15 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE15}    ul_mimo_srs_beam_pos_nr profile_id\=15 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=-26 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE16}    ul_mimo_srs_beam_pos_nr profile_id\=16 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-20 zenith\=-15 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE17}    ul_mimo_srs_beam_pos_nr profile_id\=17 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-25 zenith\=-26 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE18}    ul_mimo_srs_beam_pos_nr profile_id\=18 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-30 zenith\=-15 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE19}    ul_mimo_srs_beam_pos_nr profile_id\=19 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-35 zenith\=-26 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE20}    ul_mimo_srs_beam_pos_nr profile_id\=20 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=1 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-40 zenith\=-15 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE21}    ul_mimo_srs_beam_pos_nr profile_id\=21 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-45 zenith\=-26 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE22}    ul_mimo_srs_beam_pos_nr profile_id\=22 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-50 zenith\=-15 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE23}    ul_mimo_srs_beam_pos_nr profile_id\=23 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=57 zenith\=-22 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE24}    ul_mimo_srs_beam_pos_nr profile_id\=24 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=47 zenith\=-19 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE25}    ul_mimo_srs_beam_pos_nr profile_id\=25 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=37 zenith\=-22 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE26}    ul_mimo_srs_beam_pos_nr profile_id\=26 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=27 zenith\=-19 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE27}    ul_mimo_srs_beam_pos_nr profile_id\=27 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=17 zenith\=-22 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE28}    ul_mimo_srs_beam_pos_nr profile_id\=28 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=7 zenith\=-19 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE29}    ul_mimo_srs_beam_pos_nr profile_id\=29 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-3 zenith\=-22 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE30}    ul_mimo_srs_beam_pos_nr profile_id\=30 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-13 zenith\=-19 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE31}    ul_mimo_srs_beam_pos_nr profile_id\=31 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-23 zenith\=-22 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE32}    ul_mimo_srs_beam_pos_nr profile_id\=32 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-33 zenith\=-19 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE33}    ul_mimo_srs_beam_pos_nr profile_id\=33 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-43 zenith\=-22 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE34}    ul_mimo_srs_beam_pos_nr profile_id\=34 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-53 zenith\=-19 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE35}    ul_mimo_srs_beam_pos_nr profile_id\=35 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
               ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-63 zenith\=-22 srs_transmit_power_per_port\=-200,-200,-200,-200

*** Test Cases ***
CB013098-C-SR-05-Online_activate_deactivate_DLMUMIMO_ITW_CB008701
    Step1:Commission the above configuration on WebUI
    Step2:4UE 16layer MU
    #Step3:100UE attach to cell1
    #Step4:enable CB009235

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start capture GNB and AP Syslog in 'Step1_before_onair' File2
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}/WTS/${AIRPHONE_NAME}
  #  modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}/SCF/${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/SCF/${SCFC_NAME}    ${scfc_path}
    ${modify_list}    create list
    ...    ${cellDepType}    ${chBw}    ${bSRS}
    ...    ${customBeamSetName}
    ...    ${miNrBfConfig}
    ...    ${actMuAwareTdSch}
    ...    ${dlMuMimoRankAdaption}
    ...    ${actDlMuMimoEnh}
    #...    ${dlMuAwareCorrThd}
    #...    ${dlMuAwarePrbRatio}
    #...    ${dlMuMimoCorrThd}
    #...    ${dlMuPairingPrbRatio}
    ...    ${tiltOffset}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Wts Execute Aashell Command
    ...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
    Modify TL VM And AP SCTP Configuration
    Get and Update BSR File    ${par_of_bsr_name}
    Perform Full Commission And Reach Onair With Log2    ${scfc_path}    ${CONFIG_DIR_PATH}/WTS/${WTS_NAME}    reset_after_commission=${False}
    [Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File2

Step2:4UE 16layer MU
    Start capture GNB and AP Syslog in 'Step2_4UE' File
    FOR    ${num}    IN RANGE    2    36    #34pos
        airphone_execute_egate_command    ${PROFILE${num}}
    END

    FOR    ${i}    IN RANGE    1    5
        run keyword and continue on failure    Attach UE to cell    ${i}    ${pattern}
    END
    Online change actDlMuMimoEnh to true
    FOR    ${i}    IN RANGE    1    5
        run keyword and continue on failure    Send trf for UE    ${i}    DL    150M    8
    END
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=16
    airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=22
    airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=27
    #Start GNB Ttitrace With Streaming Mode
    Wait '50s' for stable running2
    #${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_4UE
    #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    #Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    ${DL_throughput}    ${UL_throughput}    get tput from PM counter
    ${KIP_NR_5593a}    get KPI NR_5593a
    #${KIP_NR_5634a}    get KPI NR_5634a
    Build excel table for CB009235 KPI vs
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB009235_kpi.xls    Sheet1    1    1    ${DL_throughput}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB009235_kpi.xls    Sheet1    1    2    ${KIP_NR_5593a}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${nopair_ue_prb_dl}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34012    cell_id=1
    ${2pair_ue_prb_dl}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34013    cell_id=1
    ${3pair_ue_prb_dl}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34014    cell_id=1
    ${4pair_ue_prb_dl}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34015    cell_id=1
    ${4ue_pair_ratio}    evaluate    ${4pair_ue_prb_dl} / (${nopair_ue_prb_dl} + ${2pair_ue_prb_dl} + ${3pair_ue_prb_dl} + ${4pair_ue_prb_dl})
    run keyword and continue on failure    should be true    ${DL_throughput}>1700
    run keyword and continue on failure    should be true    ${4ue_pair_ratio}>0
    FOR    ${i}    IN RANGE    1    5
        Airphone Sa Stop Data Traffic    ${i}    dl
        Detach UE    ${i}
    END
    [Teardown]    Stop capture GNB and AP Syslog in 'Step2_4UE' File

Step3:100UE attach to cell1
    Start capture GNB and AP Syslog in 'Step3_100UE' File2
    FOR    ${num}    IN RANGE    2    36    #34pos
        airphone_execute_egate_command    ${PROFILE${num}}
    END

    FOR    ${i}    IN RANGE    1    20
        run keyword and continue on failure    Attach UE to cell    ${i}    ${pattern}
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
        run keyword and continue on failure    Send trf for UE    ${i}    DL    50M    1
    END

    FOR    ${i}    IN RANGE    20    40
        run keyword and continue on failure    Attach UE to cell    ${i}    ${pattern1}
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=16
        run keyword and continue on failure    Send trf for UE    ${i}    DL    50M    1
    END

    FOR    ${i}    IN RANGE    40    70
        run keyword and continue on failure    Attach UE to cell    ${i}    ${pattern2}
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=22
        run keyword and continue on failure    Send trf for UE    ${i}    DL    30M    1
    END

    FOR    ${i}    IN RANGE    70    120
        run keyword and continue on failure    Attach UE to cell    ${i}    ${pattern2}
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=27
        run keyword and continue on failure    Send trf for UE    ${i}    DL    20M    1
    END

    FOR    ${i}    IN RANGE    101    120
        run keyword and continue on failure    Airphone Sa Stop Data Traffic    ${i}    dl
        run keyword and continue on failure    Detach UE    ${i}
    END

    FOR    ${i}    IN RANGE    101    120
        run keyword and continue on failure    Attach UE to cell    ${i}    ${pattern2}
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=27
        run keyword and continue on failure    Send trf for UE    ${i}    DL    20M    1
    END

    FOR    ${i}    IN RANGE    1    20
        Resend DL data
    END

    FOR    ${i}    IN RANGE    90    120
        UEs moving    ${i}
    END
    Wait '600s' for stable running2
    #Start GNB Ttitrace With Streaming Mode
    #Wait '0.1s' for stable running2
    #${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_100UE
    #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    #Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
	${DL_throughput}    ${UL_throughput}    get tput from PM counter
    ${KIP_NR_5593a}    get KPI NR_5593a
    #${KIP_NR_5634a}    get KPI NR_5634a
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB009235_kpi.xls    Sheet1    1    3    ${DL_throughput}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB009235_kpi.xls    Sheet1    1    4    ${KIP_NR_5593a}
    run keyword and continue on failure    should be true    ${DL_throughput}>1600
    run keyword and continue on failure    should be true    ${KIP_NR_5593a}>1
    [Teardown]    Stop capture GNB and AP Syslog in 'Step3_100UE' File2

Step4:enable CB009235
    Start capture GNB and AP Syslog in 'Step4_CB009235' File
    COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuMimoRankAdaption
    ...    operation=update    value=adaptive    skip_parameter_relation_errors=True    should_activate=True    connection=online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    COAM.teardown admin    connection=online

    COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=actMuAwareTdSch
    ...    operation=update    value=true    skip_parameter_relation_errors=True    should_activate=True    connection=online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    COAM.teardown admin    connection=online

    Wait '600s' for stable running2
    #Start GNB Ttitrace With Streaming Mode
    #Wait '0.1s' for stable running2
    #${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_CB009235
    #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    #Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    ${DL_throughput}    ${UL_throughput}    get tput from PM counter
    ${KIP_NR_5593a}    get KPI NR_5593a
    #${KIP_NR_5634a}    get KPI NR_5634a
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB009235_kpi.xls    Sheet1    1    5    ${DL_throughput}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB009235_kpi.xls    Sheet1    1    6    ${KIP_NR_5593a}
    run keyword and continue on failure    should be true    ${DL_throughput}>1000
    run keyword and continue on failure    should be true    ${KIP_NR_5593a}>1
    [Teardown]    Stop capture GNB and AP Syslog in 'Step4_CB009235' File


Resend UL data
    FOR    ${i}    IN RANGE    36    46
        Stop UE DL Traffic    ${i}
        Wait '1s' for stable running
        Send trf for UE    ${i}    UL    20M   1
    END

Resend DL data
    FOR    ${i}    IN RANGE    1    11
        Stop UE DL Traffic    ${i}
        Wait '1s' for stable running2
        Send trf for UE    ${i}    DL    30M   1
        ${i_2}    evaluate    ${i}+34
        Stop UE DL Traffic    ${i_2}
        Wait '2s' for stable running2
        Send trf for UE    ${i_2}    DL    40M   1
    END

UEs moving
    [Arguments]    ${ue_id}
    FOR    ${i}    IN RANGE    2    36
        airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${i}
    END

Attach UE to cell
    [Arguments]    ${ue_id}    ${pattern}
    ${ue_ability}    Obtain Ue Capability    ${pattern}
    ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${ue_id}    timeout=60    ue_capability=${ue_ability}
    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${ue_id}    timeout=60    ue_capability=${ue_ability}
    airphone_set_traffic_type    ${ue_id}    1    internal
    ${pdu_id}    evaluate    ${ue_id}%10+1
    ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${ue_id}    1    1    ${pdu_id}
    #${newNum}=    evaluate    ${ue_id}+8
    Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${ue_id}    1    1    5
    Wait '1s' for stable running2

Send trf for UE
    [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone SA Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    pdu_id=1    duration=10800s    trf_id=${num}
    END

Stop UE DL Traffic
    [Arguments]    ${ue_id}
    airphone_sa_stop_data_traffic    ${ue_id}    DL

Detach UE
    [Arguments]    ${ue_id}
    airphone_sa_detach    ue_id=${ue_id}    timeout=30

Detach All UEs
    FOR    ${i}    IN RANGE    1    11
        Airphone Sa Stop Data Traffic    ${i}    dl
        Detach UE    ${i}
    END

    FOR    ${i}    IN RANGE    51    61
        Airphone Sa Stop Data Traffic    ${i}    dl
        Detach UE    ${i}
    END

Override UEi to DL RANKj and CQIk
    [Arguments]    ${ue_id}    ${ranki}    ${cqii}
    airphone_execute_egate_command
   	...    csi_override_testmode_nr profile_id\=${ue_id} ri_mode\=fixed ri\=${ranki} cqi_mode\=fixed cqi\=${cqii}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=${ue_id}

Set UEi position
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE1}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1

Set UEi position bad
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE2}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2

Set UEi position bad2
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE3}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3

Block Cell1
    COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=administrativeState
    ...    operation=update    value=Locked    skip_parameter_relation_errors=True    should_activate=True    connection=online
    #Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    COAM.teardown admin    connection=online

Unlock Cell1
    COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=administrativeState
    ...    operation=update    value=Unlocked    skip_parameter_relation_errors=True    should_activate=True    connection=online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    COAM.teardown admin    connection=online

get tput from PM counter
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    ${remaining_time}     evaluate    ${remaining_time}+300
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${PM_counter_DL_value}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55309C12001
    ...   cell_id=1
    ${DL_throughput}    evaluate    ${PM_counter_DL_value}*8/1024/1024
    ${PM_counter_UL_value}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55309C12002
    ...   cell_id=1
    ${UL_throughput}    evaluate    ${PM_counter_UL_value}*8/1024/1024
    [Return]    ${DL_throughput}    ${UL_throughput}

modify_swconfig_by_CB008322
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}
    ${local_save_path}=     Download All Common Config Files From Golden Server
    ${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
    ${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    #add_txt_node    0x9D0000:5        #as PM counter period update to 15/15=1min
    #add_txt_node    0x58079e:0       #rdWbSrsConstraintTimer
    add_txt_node    0x1003F:1         #ERadCcs_AaSysLogInputLevel - Severity changed from DEBUG to INFO
    teardown_txt
    setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt

Perform Full Commission And Reach Onair With Log2
    [Arguments]     ${scfc}      ${wts_config}    ${wait_onair_timeout}=1500    ${reset_after_commission}=${False}
    ...             ${wait_bts_timeout}=600    ${wait_rru_timeout}=600    ${L1b}=False
    [Documentation]    This keyword will use ${scfc} to do full commission, and use ${wts_config} to start wts process and check onair
    ...    | Input Parameters | Man. | Description |
    ...    | scfc | Yes | SCF file path. |
    ...    | wts_config | Yes | WTS config file |
    ...    | wait_onair_timeout | No | timeout to check onair. Default is 1500 |
    ...    | reset_after_commission | No | Will reset bts after commission.Default is False |
    ...    Examples:
    ...    | Perform Full Commission And Reach Onair | scfc.xml |  wts_config.xml |
    Log to console    Perform Full Commissioning And Reach Onair start.
    ${new_scfc}    GNB_BASE.Change Vlan Id In Scfc    ${scfc}    ${test_log_directory()}/full_commission/
    Perform Full Commission     ${new_scfc}
    Run Keyword If    '${reset_after_commission}'=='True'     Reset Testline
    FOR    ${loop}    IN RANGE    2
        ${bts_status}=    Run Keyword And Return Status    Wait Unit Bts Configured    ${wait_bts_timeout}
        Run Keyword If    '${bts_status}' == 'False' and ${loop} < 1    Reset Testline
        Continue For Loop If    '${bts_status}' == 'False' and ${loop} < 1
        Run Keyword If    '${bts_status}' == 'False' and ${loop} >= 1    Fail
        ${remote info}     Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
        run keyword and ignore error    Start Tcpdump    cellSetup${loop}    -i any    ${remote info}
        ${rru_status}=    Run Keyword And Return Status    Wait Until RRU Configured    ${wait_rru_timeout}
        Run Keyword If    '${rru_status}' == 'False' and ${loop} < 1    Reset Testline
        Continue For Loop If    '${rru_status}' == 'False' and ${loop} < 1
        Run Keyword If    '${rru_status}' == 'False' and ${loop} >= 1    Fail
        Run Keyword If    '${L1b}' == 'True'
         ...    Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
        ${onair_status}=    Run Keyword And Return Status    Start Wts And Wait Bts Until Onair     ${wts_config}
         ...    timeout=${wait_onair_timeout}
        Run Keyword If    '${onair_status}' == 'True'    Stop Tcpdump       cellSetup${loop}     ${test_log_directory()}
        OperatingSystem.Run    mv ${test_log_directory()}/cellSetup*.pcap ${test_log_directory()}/cellSetup0.pcap
        Return From Keyword If    '${onair_status}' == 'True'
        Run Keyword If    '${onair_status}' == 'False' and ${loop} < 1    Reset Testline
        Run Keyword If    '${onair_status}' == 'False' and ${loop} >= 1    Fail
    END

Wait '${time}' for stable running2
    sleep    ${time}

get PDSCH pair ratio from PM counter
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    ${remaining_time}     evaluate    ${remaining_time}+300
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${PM_counter_used_PDSCH}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55308C10001
    ...   cell_id=1
    ${PM_counter_DLMU_8layer}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55308C34011
    ...   cell_id=1
    ${PM_counter_DLMU_12layer}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55308C34019
    ...   cell_id=1
    ${PM_counter_DLMU_16layer}=    get_counter_value_from_counter_file
    ...   counter_file=${PM_counter_file}
    ...   counter_id=M55308C34023
    ...   cell_id=1
    ${DLMU_8layyer_ratio}    evaluate    ${PM_counter_DLMU_8layer}/PM_counter_used_PDSCH
    ${DLMU_12layyer_ratio}    evaluate    ${PM_counter_DLMU_12layer}/PM_counter_used_PDSCH
    ${DLMU_16layyer_ratio}    evaluate    ${PM_counter_DLMU_16layer}/PM_counter_used_PDSCH
    [Return]    ${DL_throughput}    ${UL_throughput}

get KPI NR_5593a
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${nopair_ue_prb_dl}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34012    cell_id=1
    ${2pair_ue_prb_dl}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34013    cell_id=1
    ${3pair_ue_prb_dl}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34014    cell_id=1
    ${4pair_ue_prb_dl}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34015    cell_id=1
    ${5pair_ue_prb_dl}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34024    cell_id=1
    ${6pair_ue_prb_dl}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34025    cell_id=1
    ${7pair_ue_prb_dl}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34026    cell_id=1
    ${8pair_ue_prb_dl}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34027    cell_id=1
    ${NR_5593a_prb_1}    evaluate    ${nopair_ue_prb_dl} + 2*${2pair_ue_prb_dl} + 3*${3pair_ue_prb_dl} + 4*${4pair_ue_prb_dl}
    ${NR_5593a_prb_2}    evaluate    5*${5pair_ue_prb_dl} + 6*${6pair_ue_prb_dl} + 7*${7pair_ue_prb_dl} + 8*${8pair_ue_prb_dl}
    ${NR_5593a_ue_1}    evaluate    ${nopair_ue_prb_dl} + ${2pair_ue_prb_dl} + ${3pair_ue_prb_dl} + ${4pair_ue_prb_dl}
    ${NR_5593a_ue_2}    evaluate     ${5pair_ue_prb_dl} + ${6pair_ue_prb_dl} + ${7pair_ue_prb_dl} + ${8pair_ue_prb_dl}
    ${NR_5593a}    evaluate    (${NR_5593a_prb_1} + ${NR_5593a_prb_2})/(${NR_5593a_ue_1} + ${NR_5593a_ue_2})
    [Return]    ${NR_5593a}

get KPI NR_5634a
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${nopair_ue_prb_ul}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35006    cell_id=1
    ${2pair_ue_prb_ul}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35007    cell_id=1
    ${3pair_ue_prb_ul}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35008    cell_id=1
	${4pair_ue_prb_ul}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35009    cell_id=1
    ${NR_5634a_prb}    evaluate    ${nopair_ue_prb_ul} + 2*${2pair_ue_prb_ul} + 3*${3pair_ue_prb_ul} + 4*${4pair_ue_prb_ul}
    ${NR_5634a_ue}    evaluate    ${nopair_ue_prb_ul} + ${2pair_ue_prb_ul} + ${3pair_ue_prb_ul} + ${4pair_ue_prb_ul}
    ${NR_5634a}    evaluate    ${NR_5634a_prb}/${NR_5634a_ue}
    [Return]    ${NR_5634a}

Build excel table for CB009235 KPI vs
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB009235_kpi.xls    Sheet1    1    0    ${SOFTWARE_INFO}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB009235_kpi.xls    Sheet1    0    1    tput_M55309C12001_4ue
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB009235_kpi.xls    Sheet1    0    2    KIP_NR_5593a_4ue
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB009235_kpi.xls    Sheet1    0    3    tput_M55309C12001_100ue
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB009235_kpi.xls    Sheet1    0    4    KIP_NR_5593a_100ue
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB009235_kpi.xls    Sheet1    0    5    tput_M55309C12001_100ue_CB009235
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB009235_kpi.xls    Sheet1    0    6    KIP_NR_5593a_100ue_CB009235

Start capture gnb and ap syslog in '${file_name}' file2
    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/${file_name}/syslog_${file_name}
    ...    log_name=${file_name}_gnb    ip=${GNB_SYSLOG.ip}    alias=collect_gnb
    ute_syslog.Start Syslog    file_limit=${AP_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/${file_name}/syslog_${file_name}
    ...    log_name=${file_name}_ap    ip=${AP_SYSLOG.ip}    alias=collect_ap

Stop capture gnb and ap syslog in '${file_name}' file2
    #check_err_wrn_in_btslog    ${TEST_LOG_DIRECTORY()}${/}${file_name}${/}syslog_${file_name}${/}    syslog_${file_name}
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}${file_name}   unzip=TRUE
    ute_syslog.Collect Syslog Results    alias=collect_gnb    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}${file_name}${/}syslog_${file_name}${/}${file_name}_gnb.tar.gz
    ute_syslog.Collect Syslog Results    alias=collect_ap    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}${file_name}${/}syslog_${file_name}${/}${file_name}_ap.tar.gz

Online change actDlMuMimoEnh to true
    COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=actDlMuMimoEnh
    ...    operation=update    value=true    skip_parameter_relation_errors=True    should_activate=True    connection=online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    COAM.teardown admin    connection=online
