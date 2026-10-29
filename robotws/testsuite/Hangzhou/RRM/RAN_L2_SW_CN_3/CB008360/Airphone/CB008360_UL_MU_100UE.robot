*** Settings ***
Documentation     Author: mao.qin@nokia-sbell.com
...
...               QC case full name:
...               CB008360_UL_MU_100UE.robot
...

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LO_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_mqin
Test Timeout      360 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
Library           taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}          gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D8U_ulMuMIMO.xml
${AIRPHONE_NAME}      AP_iphy_AQQL_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_BOAM_ulMuMIMO.xml
${WTS_NAME}           wts_CB008360_UL_MU_100UE.lua
@{LOG_NAME_LIST}      gnb_snapshot    egatelog\
#ap_snapshot    sosreport
${cellDepType}                text|SA+NSA|//*[@name\="cellDepType"]
${chBw}                       text|100MHz|//*[@name\="chBw"]
${bSRS}                       text|2|//*[@name\="bSRS"]
${actDlSrsSubbandBm}          text|true|//*[@name\="actDlSrsSubbandBm"]
${maxNumUeSrs}                text|4|//*[@name\="maxNumUeSrs"]
${actDlMuMimoEnh}             text|true|//*[@name\="actDlMuMimoEnh"]
${actDlSrsBm}                 text|true|//*[@name\="actDlSrsBm"]
${actDl256Qam}                text|true|//*[@name\="actDl256Qam"]
${actUl256Qam}                text|true|//*[@name\="actUl256Qam"]
${actUlMuMimoGroupPairing}    text|true|//*[@name\="actUlMuMimoGroupPairing"]
${wbSrsPowerThreshold}        text|-1050|//*[@name\="wbSrsPowerThreshold"]
${srsPowerThreshold}          text|-1190|//*[@name\="srsPowerThreshold"]
${actUlMuMimo}                text|true|//*[@name\="actUlMuMimo"]
${dlMuMimoRankAdaption}       text|disabled|//*[@name\="dlMuMimoRankAdaption"]
${customBeamSetName}          text|BSR_AQQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001|//*[@name\="customBeamSetName"]
${par_of_bsr_name}            BSR_AQQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
${tiltOffset}                 text|0|//*[@name\="tiltOffset"]
${actDynPdcchTdMode}          text|largestBWP|//*[@name\="actDynPdcchTdMode"]


${miNrSrsQuality}      text|5min|//*[@name\="miNrSrsQuality"]
${miNrBeamforming2}    text|5min|//*[@name\="miNrBeamforming2"]
${miNrBfConfig}        text|5min|//*[@name\="miNrBfConfig"]
${miNrUlHarqLowSEMCS}        text|5min|//*[@name\="miNrUlHarqLowSEMCS"]
${miNrUlHarqOne}             text|5min|//*[@name\="miNrUlHarqOne"]
${bbmodBoardConfigType}    text|LTETDD_NRTDD|//*[@name\="bbmodBoardConfigType"]

${pattern}     t2r4_n2_pusch_1layer
${pattern1}    CA_P2_8x4_t2r4_n2
${pattern2}    CA_P2_8x4_t1r4_n1
${pattern3}    CA_P2_8x4_t4r4_n4
${pattern4}    CA_P2_8x4_noTas_n2
${pattern5}    TDD_NSA_CA_NoRefinebeam
${pattern6}    CA_P2_8x4_t2r4_n2_nsa

${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=0 init_sub_quad_pos=1 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=0 init_sub_quad_pos=2 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=0 init_sub_quad_pos=3 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id=5 mode=fixed init_quad_pos=1 init_sub_quad_pos=0 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id=6 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id=7 mode=fixed init_quad_pos=1 init_sub_quad_pos=2 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id=8 mode=fixed init_quad_pos=1 init_sub_quad_pos=3 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id=9 mode=fixed init_quad_pos=2 init_sub_quad_pos=0 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id=10 mode=fixed init_quad_pos=2 init_sub_quad_pos=1 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id=11 mode=fixed init_quad_pos=2 init_sub_quad_pos=2 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id=12 mode=fixed init_quad_pos=2 init_sub_quad_pos=3 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id=13 mode=fixed init_quad_pos=3 init_sub_quad_pos=0 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE14}    ul_mimo_srs_beam_pos_nr profile_id=14 mode=fixed init_quad_pos=3 init_sub_quad_pos=1 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE15}    ul_mimo_srs_beam_pos_nr profile_id=15 mode=fixed init_quad_pos=3 init_sub_quad_pos=2 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE16}    ul_mimo_srs_beam_pos_nr profile_id=16 mode=fixed init_quad_pos=3 init_sub_quad_pos=3 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE17}    ul_mimo_srs_beam_pos_nr profile_id=17 mode=sweep init_quad_pos=0 init_sub_quad_pos=0 final_quad_pos=3 final_sub_quad_pos=0
                   ...    step=200 trigger_puxch_update=0 multi_path_config=0 test_type=UL_MIMO
${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1

*** Test Cases ***
CB008360_UL_MU_100UE
    Step1:Commission the above configuration on WebUI
	Step2:16UE attach to cell1
    Step3:100UE attach to cell1

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start capture GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig_by_CB008322_2    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    ${modify_list}    create list
    ...    ${cellDepType}    ${chBw}    ${bSRS}    ${actDlSrsBm}    ${actDlSrsSubbandBm}    ${actUlMuMimoGroupPairing}
    ...    ${actDl256Qam}    ${actUl256Qam}    ${actDlMuMimoEnh}    ${wbSrsPowerThreshold}    ${srsPowerThreshold}
    ...    ${maxNumUeSrs}    ${miNrBfConfig}    ${actUlMuMimo}    ${dlMuMimoRankAdaption}    ${customBeamSetName}
    ...    ${tiltOffset}    ${actDynPdcchTdMode}
    ...    ${miNrUlHarqLowSEMCS}    ${miNrUlHarqOne}
    ...    ${bbmodBoardConfigType}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Wts Execute Aashell Command2
    ...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
    Modify TL VM And AP SCTP Configuration
    Get and Update BSR File    ${par_of_bsr_name}
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    [Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File

Step2:16UE attach to cell1
    Start capture GNB and AP Syslog in 'Step2_16UE' File
    FOR    ${i}    IN RANGE    1    17
        run keyword and continue on failure    Attach UE to cell    ${i}    ${pattern}
        run keyword and continue on failure    Set UEi position${i}    ${i}
    END
    #    run keyword and continue on failure    Send trf for UE    ${i}    DL    150M    1

	FOR    ${i}    IN RANGE    1    9
        ${ul_data}    evaluate    ${i}*3
        run keyword and continue on failure    Send trf for UE    ${i}    UL    ${ul_data}M    1
    END
    FOR    ${i}    IN RANGE    9    17
        ${ul_data2}    evaluate    ${i}*2
        run keyword and continue on failure    Send trf for UE    ${i}    UL    ${ul_data2}M    1
    END

    FOR    ${i}    IN RANGE    151    167
        run keyword and continue on failure    Attach UE to cell2    ${i}    ${pattern1}
        ${p}    evaluate    ${i}-150
        run keyword and continue on failure    Set UEi position${p}    ${i}
    #    run keyword and continue on failure    Send trf for UE    ${i}    DL    150M    1
        run keyword and continue on failure    Send trf for UE    ${i}    UL    20M    1
    END

    Wait '120s' for stable running
    #Start GNB Ttitrace With Streaming Mode
	#Wait '0.5s' for stable running
	#${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_16UE
    #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    #Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    Wait '600s' for stable running
	${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${KPI_NR_5258}    ${KPI_NR_5258_2}    get KPI NR_5258    ${PM_counter_file}
    ${KPI_NR_5259}    ${KPI_NR_5259_2}    get KPI NR_5259    ${PM_counter_file}
    ${KPI_NR_5634}    get KPI NR_5634    ${PM_counter_file}
    ${KPI_NR_5089}    ${KPI_NR_5091}    get KPI NR_5089 NR_5091    ${PM_counter_file}
    Build excel table for CB008360 KPI vs
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    1    1    ${KPI_NR_5258}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    1    2    ${KPI_NR_5259}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    1    3    ${KPI_NR_5634}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    1    4    ${KPI_NR_5089}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    1    5    ${KPI_NR_5091}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    1    6    ${KPI_NR_5258_2}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    1    7    ${KPI_NR_5259_2}
    #run keyword and continue on failure    should be true    ${KPI_NR_5258}>1000
    #run keyword and continue on failure    should be true    ${KPI_NR_5258_2}>1000
    run keyword and continue on failure    should be true    ${KPI_NR_5259}>150
    run keyword and continue on failure    should be true    ${KPI_NR_5259_2}>250
    run keyword and continue on failure    should be true    ${KPI_NR_5634}>2
    [Teardown]    Stop capture GNB and AP Syslog in 'Step2_16UE' File

Step3:100UE attach to cell1
    Start capture GNB and AP Syslog in 'Step3_100UE' File
    FOR    ${i}    IN RANGE    17    40
        run keyword and continue on failure    Attach UE to cell    ${i}    ${pattern}
        run keyword and continue on failure    Send trf for UE    ${i}    UL    1M    1
    END
    FOR    ${i}    IN RANGE    40    60
        run keyword and continue on failure    Attach UE to cell    ${i}    ${pattern}
        run keyword and continue on failure    Send trf for UE    ${i}    UL    5M    1
    END
    FOR    ${i}    IN RANGE    60    80
        run keyword and continue on failure    Attach UE to cell    ${i}    ${pattern}
        run keyword and continue on failure    Send trf for UE    ${i}    UL    10M    1
    END
    FOR    ${i}    IN RANGE    80    101
        run keyword and continue on failure    Attach UE to cell    ${i}    ${pattern}
        run keyword and continue on failure    Send trf for UE    ${i}    UL    20M    1
    END
    #FOR    ${i}    IN RANGE    17    101
    #    run keyword and continue on failure    Send trf for UE    ${i}    DL    20M    1
    #END

    FOR    ${i}    IN RANGE    167    250
        run keyword and continue on failure    Attach UE to cell2    ${i}    ${pattern1}
    #    run keyword and continue on failure    Send trf for UE    ${i}    DL    20M    1
        run keyword and continue on failure    Send trf for UE    ${i}    UL    5M    1
    END
    Wait '600s' for stable running
    #Start GNB Ttitrace With Streaming Mode
	#Wait '0.3s' for stable running
	#${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_100UE
    #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    #Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
    Wait '120s' for stable running
	${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${KPI_NR_5258}    ${KPI_NR_5258_2}    get KPI NR_5258    ${PM_counter_file}
    ${KPI_NR_5259}    ${KPI_NR_5259_2}    get KPI NR_5259    ${PM_counter_file}
    ${KPI_NR_5634}    get KPI NR_5634    ${PM_counter_file}
    ${KPI_NR_5089}    ${KPI_NR_5091}    get KPI NR_5089 NR_5091    ${PM_counter_file}
    ${max_WBSRS_UE}    ${max_WBSRS_UE_2}    get WBSRS UE num    ${PM_counter_file}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    1    8    ${KPI_NR_5258}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    1    9    ${KPI_NR_5259}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    1    10    ${KPI_NR_5634}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    1    11    ${KPI_NR_5089}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    1    12    ${KPI_NR_5091}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    1    13    ${KPI_NR_5258_2}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    1    14    ${KPI_NR_5259_2}
    #run keyword and continue on failure    should be true    ${KPI_NR_5258}>1000
    #run keyword and continue on failure    should be true    ${KPI_NR_5258_2}>1000
    run keyword and continue on failure    should be true    ${KPI_NR_5259}>50
    run keyword and continue on failure    should be true    ${KPI_NR_5259_2}>150
    run keyword and continue on failure    should be true    ${KPI_NR_5634}>1
    #run keyword and continue on failure    should be true    ${max_WBSRS_UE}==4
    #run keyword and continue on failure    should be true    ${max_WBSRS_UE_2}==4
    [Teardown]    Stop capture GNB and AP Syslog in 'Step3_100UE' File


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
    Wait '1s' for stable running

Attach UE to cell2
    [Arguments]    ${ue_id}    ${pattern}
    ${ue_ability}    Obtain Ue Capability    ${pattern}
    ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${ue_id}    timeout=60    ue_capability=${ue_ability}
    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${ue_id}    timeout=60    ue_capability=${ue_ability}
    airphone_set_traffic_type    ${ue_id}    1    internal
    ${pdu_id}    evaluate    ${ue_id}%10+21
    ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${ue_id}    1    1    ${pdu_id}
    #${newNum}=    evaluate    ${ue_id}+8
    Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${ue_id}    1    1    25

Send trf for All UEs
    FOR    ${i}    IN RANGE    1    201
        Airphone SA Start Data Traffic    ue_id=${i}    direction=dl    throughput=5M    trf_id=1    duration=3600
        Airphone Sa Start Data Traffic    ue_id=${i}    direction=ul    throughput=2M    trf_id=1    duration=3600
    END

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

Add L2PS Deubg Logs
    ${debuglogs}    create list    level=DBG\n    L2.L2_PS.DEBUG=1\n    L2.L2_PS.UL.MUMIMO=1\n    L2.L2_PS.UL.MUMIMO.SE=1\n
    Active L2ps Feature Debug Traces    ${debuglogs}
    TAF_SSH.connect to    192.168.255.1   toor4nsn    oZPS0POrRieRtu   alias=bsh
    TAF_SSH.execute    rm /ffs/run/HashContainer*    connection=bsh

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
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
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

modify_swconfig_by_CB008322_2
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}
    ${local_save_path}=     Download All Common Config Files From Golden Server
    ${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
    ${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    add_txt_node    0x9D0000:5     #as PM counter period update to 15/15=1min
    #add_txt_node    0x58079e:0    #rdWbSrsConstraintTimer
    add_txt_node    0x1003F:1      #ERadCcs_AaSysLogInputLevel - Severity changed from DEBUG to INFO
    #add_txt_node    0x58057A:0x4         #rdFeatureFlagBitmapLevel
    #add_txt_node    0x58057E:0x800000    #debug: ulmumimo.counter
    #add_txt_node    0x58057a:4
    #add_txt_node    0x58057b:1048576
    #add_txt_node    0x58057c:10240
    teardown_txt
    setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt

Build excel table for CB008360 KPI vs
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    1    0    ${SOFTWARE_INFO}
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    0    1    KPI_NR_5258_16UE
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    0    2    KPI_NR_5259_16UE
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    0    3    KPI_NR_5634_16UE
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    0    4    KPI_NR_5089_16UE
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    0    5    KPI_NR_5091_16UE
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    0    7    KPI_NR_5258_16UE_cell2
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    0    8    KPI_NR_5259_16UE_cell2
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    0    9    KPI_NR_5258_100UE
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    0    10    KPI_NR_5259_100UE
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    0    11    KPI_NR_5634_100UE
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    0    12    KPI_NR_5089_100UE
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    0    13    KPI_NR_5091_100UE
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    0    14    KPI_NR_5258_100UE_cell2
    modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB008360_kpi.xls    Sheet1    0    15    KPI_NR_5259_100UE_cell2

get KPI NR_5258
    [Arguments]    ${PM_counter_file}
    ${CELL_THP_UL_MAX}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=1
    ${CELL_THP_UL_MAX_2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=2
    ${NR_5258}    evaluate    (8*${CELL_THP_UL_MAX})/1000000
    ${NR_5258_2}    evaluate    (8*${CELL_THP_UL_MAX_2})/1000000
    [Return]    ${NR_5258}    ${NR_5258_2}

get KPI NR_5259
    [Arguments]    ${PM_counter_file}
    ${CELL_THP_UL_MAX}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12002    cell_id=1
    ${CELL_THP_UL_MAX_2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12002    cell_id=2
    ${NR_5259}    evaluate    (8*${CELL_THP_UL_MAX})/1000000
    ${NR_5259_2}    evaluate    (8*${CELL_THP_UL_MAX_2})/1000000
    [Return]    ${NR_5259}    ${NR_5259_2}

get KPI NR_5634
    [Arguments]    ${PM_counter_file}
    ${nopair_ue_prb_ul}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35006    cell_id=1
    ${2pair_ue_prb_ul}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35007    cell_id=1
    ${3pair_ue_prb_ul}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35008    cell_id=1
	${4pair_ue_prb_ul}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35009    cell_id=1
    ${NR_5634_prb}    evaluate    ${nopair_ue_prb_ul} + 2*${2pair_ue_prb_ul} + 3*${3pair_ue_prb_ul} + 4*${4pair_ue_prb_ul}
    ${NR_5634_ue}    evaluate    ${nopair_ue_prb_ul} + ${2pair_ue_prb_ul} + ${3pair_ue_prb_ul} + ${4pair_ue_prb_ul}
    ${NR_5634}    evaluate    ${NR_5634_prb}/${NR_5634_ue}
    [Return]    ${NR_5634}

get KPI NR_5089 NR_5091
    [Arguments]    ${PM_counter_file}
    ${CP_INI_VOL_64TBL}    create list
	${DFT_INI_VOL_64TBL}    create list
	${CP_INI_VOL_256TBL}    create list
    ${CP_INI_VOL_LOWSE}    create list
    FOR    ${num}    IN RANGE    0    29
        ${counter_1}   evaluate   3000+${num}
	    ${PUSCH_CP_INI_VOL_64TBL_i}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_1}    cell_id=1
        append to list    ${CP_INI_VOL_64TBL}    ${PUSCH_CP_INI_VOL_64TBL_i}
        ${counter_4}   evaluate   5000+${num}
	    ${PUSCH_CP_INI_VOL_LOWSE_i}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55367C0${counter_4}    cell_id=1
        append to list    ${CP_INI_VOL_LOWSE}    ${PUSCH_CP_INI_VOL_LOWSE_i}
    END

    FOR    ${num}    IN RANGE    0    28
        ${counter_2}   evaluate   7000+${num}
	    ${PUSCH_DFT_INI_VOL_64TBL_i}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_2}    cell_id=1
        append to list    ${DFT_INI_VOL_64TBL}    ${PUSCH_DFT_INI_VOL_64TBL_i}
        ${counter_3}   evaluate   9000+${num}
	    ${PUSCH_CP_INI_VOL_256TBL_i}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_3}    cell_id=1
        append to list    ${CP_INI_VOL_256TBL}    ${PUSCH_CP_INI_VOL_256TBL_i}
    END

    ${DFT_64TBL_SAG_R2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55370C00011    cell_id=1
    ${DFT_64TBL_SAG_R4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55370C00017    cell_id=1
    ${DATA_TIME}=              get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C00009    cell_id=1
    ${PRACH_TIME}=            get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C00011    cell_id=1
    ${SYMBOLS_TIME}=            get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C03006    cell_id=1

    ${NR_5089_1}    evaluate    sum(${CP_INI_VOL_64TBL})+sum(${DFT_INI_VOL_64TBL})+sum(${CP_INI_VOL_256TBL})+sum(${CP_INI_VOL_LOWSE})
    ${NR_5089_2}    evaluate    ${DFT_64TBL_SAG_R2}+${DFT_64TBL_SAG_R4}
    ${NR_5089}    evaluate    8*(${NR_5089_1}+${NR_5089_2})/(${DATA_TIME}+${PRACH_TIME})
    ${NR_5091}    evaluate    8*(${NR_5089_1}+${NR_5089_2})/${SYMBOLS_TIME}
    [Return]    ${NR_5089}    ${NR_5091}

get WBSRS UE num
    [Arguments]    ${PM_counter_file}
    ${max_WBSRS_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55196C00012    cell_id=1
    ${max_WBSRS_UE_2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55196C00012    cell_id=2
    [Return]    ${max_WBSRS_UE}    ${max_WBSRS_UE_2}

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

Send trf for UE NSA
    [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone Nsa Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    trf_id=${num}    bearer_id=2    duration=3600
    END

Wts Execute Aashell Command2
    [Documentation]    This keyword is to execute command by 'nc 0 15007' with ute_fsmaccess.
    ...    Examples:
    ...    | Execute Aashell Command | confmgmtdefscli set --domain NrUeDlPhy --name a --value 1 --change-type persistent --timeout 5 |
    [Arguments]    ${command}
	${cmds}     split string    ${command}    ;
    ute_fsmaccess.Setup Wts Fsm Access
	FOR     ${single}    IN    @{cmds}
        ${ret}    ute_fsmaccess.Execute Command On Wts    bsh 1:1 "${single}"
	    ${ret2}    ute_fsmaccess.Execute Command On Wts    bsh 1:2 "${single}"
	    log    ${ret}
	    log    ${ret2}
    END
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access

Set UEi position1
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE1}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1

Set UEi position2
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE2}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2

Set UEi position3
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE3}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3

Set UEi position4
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE4}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4

Set UEi position5
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE5}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5

Set UEi position6
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE6}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6

Set UEi position7
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE7}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7

Set UEi position8
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE8}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8

Set UEi position9
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE9}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=9

Set UEi position10
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE10}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10

Set UEi position11
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE11}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=11

Set UEi position12
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE12}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=12

Set UEi position13
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE13}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=13

Set UEi position14
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE14}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=14

Set UEi position15
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE15}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=15

Set UEi position16
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE16}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=16

Set UEi position17
    [Arguments]    ${ue_id}
    airphone_execute_egate_command    ${PROFILE17}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=17

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
