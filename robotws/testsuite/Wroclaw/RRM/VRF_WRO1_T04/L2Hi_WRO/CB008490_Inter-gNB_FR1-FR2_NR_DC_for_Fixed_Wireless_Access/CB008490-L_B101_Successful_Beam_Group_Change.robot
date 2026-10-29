*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author:Anna Chabik
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...    release: 25R2

*** Variables ***
${beam_change_message}=      Recv BeamGroupChangeInd
${syslog_path_beam_group}=   ${OUTPUT_DIR}/[1][1.0]CB008490-L_B101_Successful_Beam_Group_Change/syslog_gnb2.log

*** Keywords ***
CB008490-L_B101_Successful_Beam_Group_Change
    Trigger Beamgroup Active
    Register Nrdc Ue With Default Pdu Session
    Set expected message flow for A4 meas inter-gNB PSCell Addition For UE1 GNB3 during SN-initiated SNodeMod procedure
    Sleep    5s    Wait Measurement To Configure
    UE Beamgroup Change
    Send A4 Measurement And Trigger Pscell Addition
    Verify expected message flow for A4 meas inter-gNB PSCell Addition For UE1 GNB3 during SN-initiated SNodeMod procedure
    Trigger Beamgroup Deactive
    Stop Collecting Syslog And Download Files
    Verify BeamGroup Change In Syslog    ${syslog_path_beam_group}    ${beam_change_message}
