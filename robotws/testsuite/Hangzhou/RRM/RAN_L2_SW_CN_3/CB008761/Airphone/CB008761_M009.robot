*** Settings ***
Test Timeout    180 minutes
Suite Setup    Common Suite Setup
Suite Teardown     #Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown     Common Test Teardown
Force Tags    owner_ning    AP    SBTS00    RAN_5G_TDD    RAN_5G
...   CLOUD_5G_I_BOO_AP_LOO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot
Resource    ./CB008761_resource.robot

Documentation
...     CB008761_M case to be updated

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      CB008761_M009_SCF.xml
${AIRPHONE_NAME}    iphy_CB008761_case1.xml
${WTS_NAME}    CB008761_M009_nsa.lua

@{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog

${FILTER_f1ap}    (f1ap) && (nr-rrc.supportedSRS_TxPortSwitch)
@{titles_f1ap}    nr-rrc.supportedSRS_TxPortSwitch
${FILTER_1}    (dldata_pdcchsendreq) && !(3gpp.rnti == 65535)
${FILTER_2}    (dldata_pdschsendreq) && !(3gpp.rnti == 65535)
${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
@{titles_1}    DlData_DciInfo.patternId_item
@{titles_2}    DlData_PdschGrant.patternId_item
@{titles_3}    DlData_CsiRsResource_t.patternId_item
&{GNBMIRRORINGCONFIGS}    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'
...   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'    NUMBER_OF_FILES=10
${UE_NUM}    4
${UE_1}    1
${UE_2}    2
${UE_3}    3
${UE_4}    4
${UE_7}    7
${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
...   test_type\=SRS multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-350,-350,-350,-350
${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
${alias}    conalias
@{parameter_list}     mlScellActParamSet1.mlTrainingState
${PERIOD_CONFIG_FOLDER}    /ffs/run/ml_data/bundle/SCellActivation_*/SCellActivation/
&{initialPeriod}    name=initialPeriod    hours=0    minutes=20
&{accuracyCheckPeriod}    name=accuracyCheckPeriod    hours=0    minutes=20
&{trainingPeriod}    name=trainingPeriod    hours=0    minutes=40
@{PERIOD_LIST}    ${initialPeriod}    ${accuracyCheckPeriod}    ${trainingPeriod}

@{INFERENCE_COUNTER_LIST}                    M55913C00001    M55913C00002
@{AIML_SCELL_ACT}                    M55316C00030     M55316C00031
&{COUNTER_INFO_1}             cell_id=7    MO_name=MMLIE    counter_ids_list=${INFERENCE_COUNTER_LIST}
&{COUNTER_INFO_2}             cell_id=6    MO_name=MMLIE    counter_ids_list=${INFERENCE_COUNTER_LIST}
&{AIML_COUNTER_INFO_1}             cell_id=7    MO_name=NCADU    counter_ids_list=${AIML_SCELL_ACT}
&{AIML_COUNTER_INFO_2}             cell_id=6    MO_name=NCADU    counter_ids_list=${AIML_SCELL_ACT}

@{INFERENCE_COUNTER}        ${COUNTER_INFO_1}    ${COUNTER_INFO_2}
@{AIML_COUNTER}        ${AIML_COUNTER_INFO_1}    ${AIML_COUNTER_INFO_2}

*** Test Cases ***
CB008761-ET-M009_AI ML based CA Scell activation with 5CC TTTFF use case when BTS is start-up
    OperatingSystem.Run    sudo ip addr add 10.0.2.3/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.1.61/24 dev eth3
    Prepare gnb onair
    Start ErrWrn capture gnb and ap syslog in 'after_onair' file
    Airphone Cleanup Egate Console Log
    Check Training Status
    Modify Training Period
    Set Training Start Time
    Reboot And Check Onair Again
    MultiUE Attach And Scell Addition
    Start SA UE Big DL Traffic Internal    ${UE_1}    600
    Start SA UE Big DL Traffic Internal    ${UE_2}    600
    Start SA UE Big DL Traffic Internal    ${UE_7}    600
    Wait Until Keyword Succeeds    120m    5m    Check Trained Status
    Wait Until Keyword Succeeds    1m    10s    Check Inference Status
    New Ue Attach And Scell Addition And Traffic start
    Check Inference Counter
    #Stop ErrWrn capture gnb and ap syslog in 'after_onair' file
*** Keywords ***
SA Register UE ${UE_ID}
    Airphone_cleanup_egate_console_log
    Airphone SA Attach    ue_id=${UE_ID}
    Airphone Set Traffic Type    ${UE_ID}    1    internal
    Airphone Pdu Session Setup   ${UE_ID}    1    1    ${UE_ID}
    Wait '2s' for stabible
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${UE_ID}   unzip=TRUE

MultiUE Attach And Scell Addition
    SA Register UE ${UE_1}
    Send A1 Report    ${UE_1}    srsrp_nr=120    phycell_id=56    meas_id=1
    SA Register UE ${UE_2}
    Send A1 Report    ${UE_2}    srsrp_nr=120    phycell_id=55    meas_id=1
    SA Register UE ${UE_7}
    Send A1 Report    ${UE_7}    srsrp_nr=120    phycell_id=56    meas_id=1

New Ue Attach And Scell Addition And Traffic start
    SA Register UE ${UE_3}
    Send A1 Report    ${UE_3}    srsrp_nr=120    phycell_id=56    meas_id=1
    Start SA UE Big DL Traffic Internal    ${UE_3}    300
    SA Register UE ${UE_4}
    Send A1 Report    ${UE_4}    srsrp_nr=120    phycell_id=56    meas_id=1
    Start SA UE Big DL Traffic Internal    ${UE_4}    300
    SA Register UE 5
    Send A1 Report    5    srsrp_nr=120    phycell_id=56    meas_id=1
    SA Register UE 6
    Send A1 Report    6    srsrp_nr=120    phycell_id=56    meas_id=1

Check Inference Status
    Get cell5 inference status available
    Get cell6 inference status available
    Get cell7 inference status available

Set Training Start Time
    ${hours}    Get GNB Time And Get Hours
    ${TrainTime}=    Create Dictionary    mlTrainingStartTime=${hours}
    ${Para}=    Create List    ${TrainTime}
    Perform Online Change Parameter Value    MRBTS-1/MNL-1/MNLENT-1/FEATCADM-1/MLCADM-1    mlTrainingParams    ${Para}

Check Inference Counter
    Wait Until PM Counter Update
    Wait Until Keyword Succeeds    10min    1min    Check counters

Check counters
    ${inference_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin    ${INFERENCE_COUNTER}
    Run Keyword And Continue On Failure
    ...    Should Be True    ${inference_counter_dict.cell6.M55913C00001}>100
    Run Keyword And Continue On Failure
    ...    Should Be True    ${inference_counter_dict.cell7.M55913C00001}>100
    Run Keyword And Continue On Failure
    ...    Should Be True    ${inference_counter_dict.cell6.M55913C00001}==${inference_counter_dict.cell6.M55913C00002}
    Run Keyword And Continue On Failure
    ...    Should Be True    ${inference_counter_dict.cell7.M55913C00001}==${inference_counter_dict.cell7.M55913C00002}
    ${aiml_counter_dict}    Get Multi Cells Multi PM Counters Max Values With Admin    ${AIML_COUNTER}
    Run Keyword And Continue On Failure    Should Be True    ${aiml_counter_dict.cell6.M55316C00030}>=1
    Run Keyword And Continue On Failure    Should Be True    ${aiml_counter_dict.cell6.M55316C00031}>=1
