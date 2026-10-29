*** Settings ***
Force Tags    SBTS00    CONFIGURED    RAN_5G_FDD    RAN_5G_TDD    RAN_5G    PY311
...           CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...           NoResUsage    CRT

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska
...              :contact: katarzyna.wisniewska@nokia.com

Resource     FGCR_7579_Keywords_And_Variables.robot

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_2c_tdd_2c_fdd_sansa_FGCR.lua
...             AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...             AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_fallback_activation.json
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                               delta_scf_filename=delta_fallback_activation.json
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
FGCR_7579
    [Documentation]   This test case checks gNB behaviour during fallback procedure to LTE when voice call (5QI 1 + 5QI 5) is initiated
    ...               via Initial Context Setup Request for UE-ID 1 and PDU Session Resource Setup Request for UE-ID 2.
    ...               Test case requires following flags to be added to default config:
    ...               actNormVCFallback set to True
    ...               actRedirect set to True
    ...               voiceFBMode set to redirection
    ...               redirFreqEutra set to LTE cell frequency (here 68586)
    ...               redirPrio set to 1
    ...               reditRat set to eutra
    ...               For UD-ID 1:
    ...               Initial PDU Session is triggered with 5QI 1 + 5QI 5. gNB is configured to support redirection,
    ...               so it initiates a voice fallback procedure using redirection method.
    ...               QoS flow setup is rejected with cause "IMS voice EPS fallback or RAT fallback triggered". It is possible to check inside
    ...               Inital Context Setup Failure message as cause of failed PDU Session Resource Setup.
    ...               gNB triggers UE Context Setup Release on 5G side and sends RRC Release message with redirectedCarrierInfo IE to indicate the
    ...               LTE carrier on which the UE must try to select a cell. Value should be equal to redirFreqEutra from SCF.
    ...               UE Context Release procedure should be successfull.
    ...               5G_RAN_USR_RRM_4581
    ...               For UE-ID 2:
    ...               Initial PDU Session is triggered with 5QI 1 + 5QI 5. Voice fallback is disabled, so gNB rejects
    ...               Initial Context Setup Request with PDU session with both 5QIs. Initial Context Setup Failure with list of failed PDU session
    ...               with cause "Not supported 5QI value" is visible in pcap.
    ...               5G_RAN_USR_RRM_4582

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach Ue    ue_id=1
    Activate Additional 5QI
    Establish PDU Session Without Confirmation    ue_id=1    pdu_id=1    gw_id=1
    Check Successful Fallback After Initial Context Setup
    Reset SMF

    Find Scfc And Send Delta Commissioning    scfc_filename=delta_fallback_error.json
    Attach Ue    ue_id=2
    Activate Additional 5QI
    Establish PDU Session Without Confirmation    ue_id=2    pdu_id=2    gw_id=2
    Check 5QI Setup Failure In Initial Context Setup

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation   ue_id=1-2
        ...       AND             Reset SMF
        ...       AND             Add Scout External Execution ID To Reporting Portal
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
