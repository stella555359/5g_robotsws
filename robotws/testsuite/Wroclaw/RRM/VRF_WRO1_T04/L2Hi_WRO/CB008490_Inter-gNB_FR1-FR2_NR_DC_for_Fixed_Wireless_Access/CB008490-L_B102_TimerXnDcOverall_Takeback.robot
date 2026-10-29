*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author:     Marcin Kotuła
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    testline:   CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...    release:    25R3

*** Variables ***
${beam_change_message}=                     Recv BeamGroupChangeInd
${tXnDCoverallExpiry_message}=              CauseRadioNetwork::tXnDCoverallExpiry
${syslog_path_timerXnDcOverall_takeback}=   ${OUTPUT_DIR}/[1][1.0]CB008490-L_B102_Exceptional_Case_TimerXnDcOverall_Takeback/syslog_gnb2.log

*** Keywords ***
CB008490-L_B102_Exceptional_Case_TimerXnDcOverall_Takeback
    Trigger Beamgroup Active
    Register Nrdc Ue With Default Pdu Session
    Start Traffic 150Mbps In DL
    UE Beamgroup Change
    Send A4 Measurement And Trigger Pscell Addition
    Trigger Not Sending Confirm
    Display Data Traffic On Mcg And Scg Leg
    Trigger Beamgroup Deactive
    Stop Collecting Syslog And Download Files
    Verify TimerXnDcOveral Expire In Syslog
    Verify BeamGroup Change In Syslog    ${syslog_path_timerXnDcOverall_takeback}    ${beam_change_message}

Decrease timerXnDcOverall On MN And SN
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-2_set_timerXnDcOverall_200.json
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-3_set_timerXnDcOverall_200.json
    ...    remote_host=${REMOTE_HOST_1_IP}

Display Data Traffic On Mcg And Scg Leg
    Sleep    10s
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=MCG type=pdsch
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=SCG type=pdsch scell=1
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=1 dir=dl

Start Traffic 150Mbps In DL
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=1
    Sleep    10s

Trigger Not Sending Confirm
    Execute Egate Command    cmd=gnb_nrdc_modify_param id=2 action=do_not_send_confirm
    Sleep    40s    Wait Measurement To Configure

Verify TimerXnDcOveral Expire In Syslog
    Verify Message In Syslog    ${syslog_path_timerXnDcOverall_takeback}    ${tXnDCoverallExpiry_message}
