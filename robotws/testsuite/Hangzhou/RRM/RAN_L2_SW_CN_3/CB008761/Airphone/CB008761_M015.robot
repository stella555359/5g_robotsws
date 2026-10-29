*** Settings ***
Test Timeout    180 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    owner_dianwu    AP    SBTS00    RAN_5G_TDD    RAN_5G
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


*** Test Cases ***
CB008761-ET-M015_On-line feature activation or deactivation on ASIB
    OperatingSystem.Run    sudo ip addr add 10.0.2.3/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.1.61/24 dev eth3
    Prepare gnb onair
    Start ErrWrn capture gnb and ap syslog in 'after_onair' file
    Airphone Cleanup Egate Console Log
    Check Training Status
    Modify Training Period
    ${hours}    Get GNB Time And Get Hours
    ${TrainTime}=    Create Dictionary    mlTrainingStartTime=${hours}
    ${Para}=    Create List    ${TrainTime}
    Perform Online Change Parameter Value    MRBTS-1/MNL-1/MNLENT-1/FEATCADM-1/MLCADM-1    mlTrainingParams    ${Para}
    Wait Until Keyword Succeeds    15min    30s    Verify BTS Is Onair
    Wait '60s' for stabible
	Check Training Status
	FOR    ${cell_id}    IN RANGE    1    8
	    Get cell${cell_id} inference status unavailable
	END
	Modify actMLScellAct false
	Check Idle Status
	Modify actMLScellAct true
	Check Training Status
    MultiUE Attach And Scell Addition
    Start SA UE Big DL Traffic Internal    ${UE_1}    700
    Start SA UE Big DL Traffic Internal    ${UE_2}    700
    Start SA UE Big DL Traffic Internal    ${UE_3}    700
    Start SA UE Big DL Traffic Internal    ${UE_4}    700
    Wait Until Keyword Succeeds    120m    5m    Check Trained Status
	FOR    ${cell_id}    IN RANGE    1    5
	    Get cell${cell_id} inference status unavailable
	END
	FOR    ${cell_id}    IN RANGE    5    8
	    Get cell${cell_id} inference status available
	END
	Modify actMLScellAct false
	Check Idle Status
	FOR    ${cell_id}    IN RANGE    1    8
	    Get cell${cell_id} inference status unavailable
	END
	Modify actMLScellAct true
	FOR    ${cell_id}    IN RANGE    1    8
	    Get cell${cell_id} inference status unavailable
	END
	Check Training Status
    Stop ErrWrn capture gnb and ap syslog in 'after_onair' file

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
    SA Register UE ${UE_3}
    Send A1 Report    ${UE_3}    srsrp_nr=120    phycell_id=56    meas_id=1
    SA Register UE ${UE_4}
    Send A1 Report    ${UE_4}    srsrp_nr=120    phycell_id=55    meas_id=1


