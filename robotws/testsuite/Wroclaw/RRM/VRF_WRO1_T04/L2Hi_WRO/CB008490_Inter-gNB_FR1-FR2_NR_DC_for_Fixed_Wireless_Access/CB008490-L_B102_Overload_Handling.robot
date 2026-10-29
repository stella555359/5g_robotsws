*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author:     Marcin Kotuła
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    testline:   CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...    release:    25R3

*** Variables ***
${rdOverloadHighThreshold}=         0x89006F
${rdPreventOverloadActivation}=     0x89008E
${beam_change_message}=             Recv BeamGroupChangeInd
${overload_refuse_message}=         Received Xn:SNodeModificationRefuse with cause: CauseMisc::controlProcessingOverload
${syslog_path_overload_handling}=   ${OUTPUT_DIR}/[1][1.0]CB008490-L_B102_Exceptional_Case_Overload_Handling/syslog_gnb2.log

*** Keywords ***
CB008490-L_B102_Exceptional_Case_Overload_Handling
    Trigger Beamgroup Active
    Register Nrdc Ue With Default Pdu Session
    Trigger Overload State On MN
    UE Beamgroup Change
    Send A4 Measurement And Trigger Pscell Addition
    Prepare SNodeModificationRefuse On MN
    Trigger Beamgroup Deactive
    Stop Collecting Syslog And Download Files
    Verify BeamGroup Change In Syslog    ${syslog_path_overload_handling}    ${beam_change_message}
    Verify ModificationRefuse In Syslog

Prepare SNodeModificationRefuse On MN
    Execute Egate Command    cmd=gnb_nrdc_modify_param id=2 action=refuse refuse_cause=control_processing_overload
    Sleep    5s

Enable ovlSNInitModRej On MN
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-2_enable_ovlSNInitModRej.json

Trigger Overload State On MN
   Change Rad Param With Aashell    param=${rdOverloadHighThreshold}    value=0
   Change Rad Param With Aashell    param=${rdPreventOverloadActivation}    value=0
   Sleep    10s

Verify ModificationRefuse In Syslog
    Verify Message In Syslog    ${syslog_path_overload_handling}    ${overload_refuse_message}
