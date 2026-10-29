*** Settings ***
Documentation    CB013709
Suite Setup    Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags        CRT    SBTS00   RAN_5G_TDD    RAN_5G    CLOUD_5G_I_BOO_AP_LOO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot
*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCFC_13709_microdtx.xml
${AIRPHONE_NAME}    IPHY_13709.xml
${WTS_NAME}    wts_13709.lua
@{LOG_NAME_LIST}    gnb_snapshot
${UE_NUM_SA}    1


${UE_NUM}    3
${UE_ID}    1
${UE_ID2}    2
${UE_ID3}    3
${FILTER_f1ap_srsModify}    itf_l2_ps_user_reconfigurationrequiredind||rrc||f1ap||itf_l2_ps_user_usermodifyreq
@{titles_tasSrsResourceInd}    3gpp.sfn    3gpp.slot    3gpp.rnti    itf_l2_ps_user_ReconfigurationRequiredInd_t.tasSrsResourceInd
...    itf_l2_ps_user_ReconfigurationRequiredInd_t.ueIdDu
${FILTER_f1ap_rrc_itl_l2ps}    f1ap||e1ap||rrc
...    ||itf_l2_ps_user_reconfigurationrequiredind||itf_l2_ps_user_usermodifyreq||itf_l2_ps_user_usersetupreq
@{titles_duID_Crnti}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID

#${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=40 zenith\=30 srs_transmit_power_per_port\=-280,-280,-280,-280
@{TOOLS_LIST}    luashark      bip_script    common_config_golden    common_config_private    mcshark    ttitrace_decode
${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type=SRS
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type=SRS
${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
*** Test Cases ***
CB013709_B_B3_case007_Interworking with micro-DTX handling during high load TDD
  Add RD parameters
  Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
  Prepare gnb onair
  Start ErrWrn capture gnb and ap syslog in 'after_onair' file
  Airphone Cleanup Egate Console Log
  Step1 microdtx ue pri 22
  Step2 microdtx ue pri switch to 19
  Step3 microdtx ue pri switch to 22
  Stop ErrWrn capture gnb and ap syslog in 'after_onair' file
*** Keywords ***
Add RD parameters
   Add GNB swconfig    0x5808A6:1 #rdEnableOverloadErrMsg
   Add GNB swconfig    0x5800CA:4004004 #rdMaxNumUeTdDl
   Wait '2s' for stabible
   Add GNB swconfig    0x5800CB:4004004 #rdMaxNumUeTdUl
   Wait '2s' for stabible
   Add GNB swconfig    0x9D0000:15
   Wait '2s' for stabible
   Add GNB swconfig    0x5808E8 : 5005  #rdMicroDtxOlcDlPerCent 0x5808E8
Step1 microdtx ue pri 22
    #change location to cell3
    SA Register UE 1
	SA Register UE 2
    Airphone SA Start Data Traffic    1   UL  175M   pdu_id=${UE_ID}   duration=170000    trf_id=1
    Airphone SA Start Data Traffic    2   UL  175M   pdu_id=${UE_ID}   duration=170000    trf_id=1
    Airphone SA Start Data Traffic    1   DL  1M   pdu_id=${UE_ID}   duration=170000    trf_id=1    burst=1
	run keyword and continue on failure    Check L2PS cell1 M55208C0001x value
  	Start collect ttitrace
  	Wait for '1s' to stop ttitrace with name'ttidtx'
  	run keyword and continue on failure    check pri is 22 in ttitrace
Step2 microdtx ue pri switch to 19
    SA Register UE 3
    SA Register UE 4
    SA Register UE 5
    SA Register UE 6
    SA Register UE 7
    SA Register UE 8
    Start ul data
    Start dl data
    run keyword and continue on failure    Check L2PS cell1 M55208C0001x value overload
   	Start collect ttitrace
  	Wait for '1s' to stop ttitrace with name'ttinotnbr'
  	run keyword and continue on failure    check pri is 19 in ttitrace
Step3 microdtx ue pri switch to 22
    DeRegister UE from '2' to '8'
	run keyword and continue on failure    Check L2PS cell1 M55208C0001x value
  	Start collect ttitrace
  	Wait for '1s' to stop ttitrace with name'ttidtx'
  	run keyword and continue on failure    check pri is 22 in ttitrace
SA Register UE 1 to 8
    SA Register UE 1
    SA Register UE 2
    SA Register UE 3
    SA Register UE 4
    SA Register UE 5
    SA Register UE 6
    SA Register UE 7
    SA Register UE 8
check pri is 22 in ttitrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/DL_pri22.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
check pri is 19 in ttitrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/DL_pri19_cell1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
DeRegister UE from '${low}' to '${hi}'
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
       airphone_sa_detach    ue_id=${num}    timeout=5
       Wait '3s' for stabible
    END
change location to cell3
    airphone_execute_egate_command	  ue_change_location cell\=3 id\=1-8
check throughput pell is 0
    Log To Console		=====tp=====
	${ul_throughput_pcell_sa}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
	run keyword and continue on failure    should be true    ${ul_throughput_pcell_sa}==0
check throughput sell is 0
    Log To Console		=====tp=====
	${ul_throughput_scell_sa}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=2    type=pusch    tput_type=ave
	run keyword and continue on failure    should be true    ${ul_throughput_scell_sa}==0
Send A1 event for UE'${UE_ID}' to add scell
    airphone_execute_egate_command    ue_measurement_send_nr id\=${UE_ID} meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=100
Keep position for time${TIME}
    Wait '${TIME}s' for stabible
check throughput
    Log To Console		=====tp=====
	${dl_throughput_pcell_sa}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
	run keyword and continue on failure    should be true    ${dl_throughput_pcell_sa}>=100000
	${dl_throughput_pcell_sa2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
	run keyword and continue on failure    should be true    ${dl_throughput_pcell_sa}>=50000
	${dl_throughput_pcell_sa3}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=2    type=pdsch    tput_type=ave
	run keyword and continue on failure    should be true    ${dl_throughput_pcell_sa}>=100000
 	${dl_throughput_pcell_sa4}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=3    type=pdsch    tput_type=ave
	run keyword and continue on failure    should be true    ${dl_throughput_pcell_sa}>=100000
SA Register UE ${UE_ID}
#	Airphone_cleanup_egate_console_log
  airphone_execute_egate_command	  ue_change_location cell\=6 id\=${UE_ID}
	Airphone SA Attach    ue_id=${UE_ID}
	Airphone Set Traffic Type    ${UE_ID}    1    internal
	Airphone Pdu Session Setup   ${UE_ID}    1    1    ${UE_ID}
	Wait '2s' for stabible
#	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${UE_ID}   unzip=TRUE
Start dl data
    Airphone SA Start Data Traffic    1   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=1
    Airphone SA Start Data Traffic    2   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=1
    Airphone SA Start Data Traffic    3   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=1
    Airphone SA Start Data Traffic    4   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=1
    Airphone SA Start Data Traffic    5   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=1
    Airphone SA Start Data Traffic    6   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=1
    Airphone SA Start Data Traffic    7   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=1
    Airphone SA Start Data Traffic    8   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=1
#    Airphone SA Start Data Traffic    9   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=3
#    Airphone SA Start Data Traffic    10   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=4
#    Airphone SA Start Data Traffic    11   DL   175M   pdu_id=${UE_ID}   duration=170000   trf_id=5
#    Airphone SA Start Data Traffic    12   DL   175M   pdu_id=${UE_ID}   duration=170000   trf_id=6
#    Airphone SA Start Data Traffic    13   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=1
#    Airphone SA Start Data Traffic    14   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=2
#    Airphone SA Start Data Traffic    15   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=3
#    Airphone SA Start Data Traffic    16   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=4
#    Airphone SA Start Data Traffic    17   DL   175M   pdu_id=${UE_ID}   duration=170000   trf_id=5
#    Airphone SA Start Data Traffic    18   DL   175M   pdu_id=${UE_ID}   duration=170000   trf_id=6
#    Airphone SA Start Data Traffic    19   DL   175M   pdu_id=${UE_ID}   duration=170000   trf_id=5
#    Airphone SA Start Data Traffic    20   DL   175M   pdu_id=${UE_ID}   duration=170000   trf_id=6
Start ul data
    Airphone SA Start Data Traffic    1   UL   50M   pdu_id=${UE_ID}   duration=170000    trf_id=1
    Airphone SA Start Data Traffic    2   UL   50M   pdu_id=${UE_ID}   duration=170000    trf_id=1
    Airphone SA Start Data Traffic    3   UL   50M   pdu_id=${UE_ID}   duration=170000    trf_id=1
    Airphone SA Start Data Traffic    4   UL   50M   pdu_id=${UE_ID}   duration=170000    trf_id=1
    Airphone SA Start Data Traffic    5   UL   50M   pdu_id=${UE_ID}   duration=170000    trf_id=1
    Airphone SA Start Data Traffic    6   UL   50M   pdu_id=${UE_ID}   duration=170000    trf_id=1
    Airphone SA Start Data Traffic    7   UL   50M   pdu_id=${UE_ID}   duration=170000    trf_id=1
    Airphone SA Start Data Traffic    8   UL   50M   pdu_id=${UE_ID}   duration=170000    trf_id=1
Check L2PS cell1 M55208C0001x value
    Wait until keyword succeeds    300s    60s    counter cell1 M55208C0001x value
counter cell1 M55208C0001x value
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
	Wait '${remaining_time}s' for stabible
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
    ${M55208C00017_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
    ...    counter_id=M55208C00017    cell_grp_id=0
    ${M55208C00005_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
    ...    counter_id=M55208C00005    cell_grp_id=0
    should be true    ${M55208C00017_value}==0
	  should be true    ${M55208C00005_value}<5
Check L2PS cell1 M55208C0001x value overload
    Wait until keyword succeeds    300s    60s    counter cell1 M55208C0001x value overload
counter cell1 M55208C0001x value overload
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
	  Wait '${remaining_time}s' for stabible
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
    ${M55208C00017_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
    ...    counter_id=M55208C00017    cell_grp_id=0
    ${M55208C00005_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
    ...    counter_id=M55208C00005    cell_grp_id=0
    should be true    ${M55208C00017_value}==375
	  should be true    ${M55208C00005_value}>5
Check L2PS cell1 M55208C0001x value restore
    Wait until keyword succeeds    300s    60s    counter cell1 M55208C0001x value restore
counter cell1 M55208C0001x value restore
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
	  Wait '${remaining_time}s' for stabible
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
    ${M55208C00017_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
    ...    counter_id=M55208C00017    cell_grp_id=0
    ${M55208C00005_value}=    get_counter_value_from_counter_file_by_grp    counter_file=${PM_counter_file}
    ...    counter_id=M55208C00005    cell_grp_id=0
    should be true    ${M55208C00017_value}==0
Block cell
    [Arguments]    ${phy_cell_id}    ${alias}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.administrativeState}'=='Unlocked'    Run Keywords
        ...    TAF_ADMIN.block    ${nrcel.id}    timeout=60    connection=${alias}
        ...    AND    sleep    60
    END
    TAF_ADMIN.teardown    connection=${alias}
Unblock cell
    [Arguments]    ${phy_cell_id}    ${alias}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}'    Run Keywords    TAF_ADMIN.unblock    ${nrcel.id}    timeout=60
        ...    connection=${alias}
        ...    AND    sleep    60
    END
    TAF_ADMIN.teardown    connection=${alias}
Block Unblock cell trained
  airphone_sa_detach    ue_id=3    timeout=5
	airphone_sa_detach    ue_id=2    timeout=5
	airphone_sa_detach    ue_id=1    timeout=5
    Log To Console   \n-------------block cell5---------------
	Block cell    54    gnb
    Get cell5 inference status unavailable
	Log To Console   \n-------------block cell6---------------
	Block cell    55    gnb
	Get cell6 inference status unavailable
	Check Trained Status
	Log To Console   \n-------------unblock cell5---------------
	Unblock cell    54    gnb
    Get cell5 inference status available
	Log To Console   \n-------------block cell5---------------
	Block cell    54    gnb
    Get cell5 inference status unavailable
	Log To Console   \n-------------block cell7---------------
	Block cell    56    gnb
	Get cell7 inference status unavailable
	Check Idle Status
	Log To Console   \n-------------unblock cell7---------------
    Unblock cell    56    gnb
	Check Training Status
	Get cell7 inference status unavailable
Block Unblock cell training
    Log To Console   \n-------------block cell5---------------
	Block cell    54    gnb
	Log To Console   \n-------------block cell6---------------
	Block cell    55    gnb
	Check Training Status
	Log To Console   \n-------------block cell7---------------
	Block cell    56    gnb
	Check Idle Status
    Unblock cell    56   gnb
	Check Training Status
    Unblock cell    55   gnb
    Unblock cell    54   gnb
    Check Training Status
Get cell${cell_id} inference status available
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=oam
    ${dist_parameters}    TAF_ADMIN.Get Parameter By Distname     dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    ...    connection=oam    timeout=30
    ${InferenceState}    Set Variable    ${dist_parameters[0]['parameters']['mlScellActParamSet2']}
    ${State}    Set Variable    ${InferenceState[0]['mlInferenceState']}
    Should Be True    "${State}"=="available"
    Log To Console    NRCELL-${cell_id} ${State}
    [Teardown]    TAF_ADMIN.teardown    connection=oam
Get cell${cell_id} inference status unavailable
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=oam
    ${dist_parameters}    TAF_ADMIN.Get Parameter By Distname     dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    ...    connection=oam    timeout=30
    ${InferenceState}    Set Variable    ${dist_parameters[0]['parameters']['mlScellActParamSet2']}
    ${State}    Set Variable    ${InferenceState[0]['mlInferenceState']}
    Should Be True    "${State}"=="unavailable"
    Log To Console    NRCELL-${cell_id} ${State}
    [Teardown]    TAF_ADMIN.teardown    connection=oam
Check Idle Status
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${Train_Status_Res}=     TAF_ADMIN.Get Parameter By Distname     dist_name=MRBTS-1/NRBTS-1/NRDU-1    parameter_list=@{parameter_list}
    ...    connection=${alias}    timeout=30
    ${Train_Status}    Evaluate    ${Train_Status_Res}[0].get('parameters').get('mlScellActParamSet1')[0].get('mlTrainingState')
    Should Be True    "${Train_Status}"=="Idle"
    Log To Console    ${Train_Status}
    TAF_ADMIN.teardown    connection=${alias}
Set UEs Pos
    airphone_execute_egate_command    ${PROFILE1}
    airphone_execute_egate_command    ${SET_PROFILE1}
    airphone_execute_egate_command    ${PROFILE2}
    airphone_execute_egate_command    ${SET_PROFILE2}