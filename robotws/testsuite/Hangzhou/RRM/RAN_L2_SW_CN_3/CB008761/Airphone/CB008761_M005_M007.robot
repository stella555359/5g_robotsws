*** Settings ***
Documentation    CB008761
Test Timeout    180 minutes
Suite Setup    Common Suite Setup
Suite Teardown  #  Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown   # Common Test Teardown
Force Tags    owner_ning    AP    SBTS00    RAN_5G_TDD    RAN_5G
...   CLOUD_5G_I_BOO_AP_LOO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot
Resource    ../Airphone/CB008761_resource.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      scfc_cell6_1t3f_cell7_2t2f.xml
${AIRPHONE_NAME}    iphy_CB008761_case1.xml
${WTS_NAME}    CB008761_case1.lua
@{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog
${UE_NUM}    2
${UE_ID}    1
${UE_ID2}    2
${alias}    conalias
@{parameter_list}     mlScellActParamSet1.mlTrainingState
${PERIOD_CONFIG_FOLDER}    /ffs/run/ml_data/bundle/SCellActivation_*/SCellActivation
&{initialPeriod}    name=initialPeriod    hours=0    minutes=20
&{accuracyCheckPeriod}    name=accuracyCheckPeriod    hours=0    minutes=20
&{trainingPeriod}    name=trainingPeriod    hours=0    minutes=40
@{PERIOD_LIST}    ${initialPeriod}    ${accuracyCheckPeriod}    ${trainingPeriod}
${save_dir}    ${TEST_LOG_DIRECTORY()}
*** Test Cases ***
CB008761-ET-M007_AI ML based CA Scell activation with 4CC TFFF use case when BTS is start-up
  OperatingSystem.Run    sudo ip addr add 10.0.2.3/24 dev eth4
  OperatingSystem.Run    sudo ip addr add 10.0.1.61/24 dev eth3
  Add RD parameters
  Prepare gnb onair
  Prepare to train
  Start ErrWrn capture gnb and ap syslog in 'after_onair' file
  Airphone Cleanup Egate Console Log
  SA Register UE 1
  SA Register UE 2
  Start muchmore data
  Check trained reach
  Check all tdd cells inference status
  Block Unblock cell trained
  Stop ErrWrn capture gnb and ap syslog in 'after_onair' file
  Download ml_data
*** Keywords ***
Add RD parameters
    Add GNB swconfig     0x590072:2
    Add GNB swconfig     0x66001b:2
    Add GNB swconfig     0x890001:2
    Add GNB swconfig     0x890002:2
    Add GNB swconfig     0x890003:2
    Add GNB swconfig     0x890004:2
    Add GNB swconfig     0x890005:2
    Add GNB swconfig     0x890006:2
    Add GNB swconfig     0x890008:2
    Add GNB swconfig     0x890009:2
    Add GNB swconfig     0x9D0000:3
    Add GNB swconfig     0x58057a:4
    Add GNB swconfig     0x580580:0x300000
    Add GNB swconfig     0x1002B:0x17FB
    Add GNB swconfig     0x1005A:1
    Add GNB swconfig     0x100CE:0
    Add GNB swconfig     0x1002A:2
Prepare to train
    Check Training Status
	Block Unblock cell training
    Modify Training Period
    ${hours}    Get GNB Time And Get Hours
    &{TrainTime}     Create Dictionary    mlTrainingStartTime=${hours}
    ${Para}     Create List    ${TrainTime}
    Perform Online Change Parameter Value    MRBTS-1/MNL-1/MNLENT-1/FEATCADM-1/MLCADM-1    mlTrainingParams    ${Para}
    Wait Until Keyword Succeeds    15min    30s    Verify BTS Is Onair
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
	Airphone_cleanup_egate_console_log
	Airphone SA Attach    ue_id=${UE_ID}
	Airphone Set Traffic Type    ${UE_ID}    1    internal
	Airphone Pdu Session Setup   ${UE_ID}    1    1    ${UE_ID}
	Wait '2s' for stabible
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${UE_ID}   unzip=TRUE
Start muchmore data
    Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=1
    Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=2
    Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=3
    Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=4
    Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=5
    Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=6
    Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=1
    Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=2
    Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=3
    Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=${UE_ID}   duration=170000    trf_id=4
    Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=${UE_ID}   duration=170000   trf_id=5
    Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=${UE_ID}   duration=170000   trf_id=6
Check trained reach
    Wait until keyword succeeds    120m    20m    Check Trained Status
Check inference status
    Wait until keyword succeeds    20m    10m    Check all tdd cells inference status
Check all tdd cells inference status
    Get cell5 inference status available
    Get cell6 inference status available
    Get cell7 inference status available
Check counter value
    Wait until keyword succeeds    300s    30s    counter value
counter value
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
	Wait '${remaining_time}s' for stabible
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
    ${PM_counter_value_Pcell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55911C00004
	${PM_counter_value_Pcell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55911C00005
	${PM_counter_value_Pcell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55911C00006
    should be true    ${PM_counter_value_Pcell}==1
	should be true    ${PM_counter_value_Pcell1}==0
	should be true    ${PM_counter_value_Pcell2}==0
Check L2PS counterL2PSM55913C value
    Wait until keyword succeeds    600s    300s    counter L2PSM55913C value
Check L2PS counterL2PSM55316C0003 value
    Wait until keyword succeeds    600s    300s    counter L2PSM55316C0003 value
counter L2PSM55913C value
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
	Wait '${remaining_time}s' for stabible
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
    ${PM_counter_value_Pcell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55913C00001    cell_id=6
	${PM_counter_value_Pcell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55913C00002    cell_id=6
    should be true    ${PM_counter_value_Pcell}==1800
	should be true    ${PM_counter_value_Pcell1}==1800
counter L2PSM55316C0003 value
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
	Wait '${remaining_time}s' for stabible
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
    ${PM_counter_value_Pcell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C00030    cell_id=6
	${PM_counter_value_Pcell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C00031    cell_id=6
    should be true    ${PM_counter_value_Pcell}==2
	should be true    ${PM_counter_value_Pcell1}==1
Check L2PS counter
    airphone_sa_detach    ue_id=2    timeout=5
	SA Register UE 2
	Airphone SA Start Data Traffic    ${UE_ID2}   DL   100M   pdu_id=1   duration=170000    trf_id=1
	Check L2PS counterL2PSM55913C value
	Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=1   duration=170000    trf_id=2
	Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=1   duration=170000    trf_id=3
	Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=1   duration=170000    trf_id=4
	Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=1   duration=170000    trf_id=5
	counter L2PSM55316C0003 value
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