*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_BLLL_AP_LOO

Documentation    :copyright: Nokia

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     feature_keywords.robot
Variables    feature_variables.py
Library      Keywords5GC001167.py

Suite Setup       Prepare Test Environement And Reach Onair
    ...               iphy_xml=${CURDIR}/config/5GC001167-H/iphy_AHCA_n5_AHFIB_n66_H_d.xml
    ...               scfc=fdd_2CC_n5_n66_rlf_vonr_H_d.xml
    ...               egate_cfg=${CURDIR}/config/sa_fdd_cmWv_fs/fs_sa_call_fdd_cmwv_2CC_n5_n66.cfg
    ...               cell_number=2
    ...               disablel1bypass=False
Test Setup        Start Default Logging    output_dirpath=${OUTPUT_DIR}
Test Teardown     Stop Default Logging
Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${E1AP_FIVEQI1_SETUP}=    (e1ap.qos_flow_Information_To_Be_Setup && e1ap.fiveQI == 1)
${F1AP_FIVEQI1_SETUP}=    (f1ap.DRBs_ToBeSetupMod_List && f1ap.fiveQI == 1)

*** Test Cases ***
5GC001167-H-d_gNB_should_configure_mix_bearers_gbr_and_nongbr_to_UE_with_CA
    Attach UE With Scell Configuration
    Verify Successful 2CC On NGAP And F1AP Messages
    Perform And Verify Successful VoNR Establishment

*** Keywords ***
Attach UE With Scell Configuration
    Set Internal Traffic Type To UEs    ue_id=2
    Attach Ue    ue_id=2    cell=1
    Establish Pdu Session    ue_id=2    pdu_id=2    gw_id=1    nwslice=1

Perform And Verify Successful VoNR Establishment
    Establish VoNR Qosflow    ue_id=2    qosflows=2
    Verify Tcpdump Log     packet_filter=${E1AP_FIVEQI1_SETUP}    continue_on_failure=False
    Verify Tcpdump Log     packet_filter=${F1AP_FIVEQI1_SETUP}    continue_on_failure=False
