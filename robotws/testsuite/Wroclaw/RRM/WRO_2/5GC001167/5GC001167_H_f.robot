*** Settings ***
Force Tags    CRT    GQC_PLAN:DESIGNER:bondar    RAN_5G    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_BLLL_AP_LOO

Documentation    :copyright: Nokia

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     feature_keywords.robot
Variables    feature_variables.py
Library      Keywords5GC001167.py

Suite Setup       Prepare Test Environement And Reach Onair
    ...               iphy_xml=${CURDIR}/config/5GC001167-H/iphy_AHCA_n5_AHFIB_n66_H_d.xml
    ...               scfc=fdd_2CC_n5_n66_rlf.xml
    ...               egate_cfg=${CURDIR}/config/sa_fdd_cmWv_fs/fs_sa_call_fdd_cmwv_2CC_n5_n66.cfg
    ...               cell_number=2
    ...               disablel1bypass=True
Test Setup        Start Default Logging    output_dirpath=${OUTPUT_DIR}
Test Teardown     Stop Default Logging
Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${F1AP_SCELL_TO_ADD_MOD_LIST}=         (((nr-rrc.physCellId == 51)) ) && (nr-rrc.pdsch_HARQ_ACK_Codebook == 1)

*** Test Cases ***
5GC001167-H-f_RLF_during_Scell_addition
    Attach UE With Scell Configuration
    Verify Successful 2CC On NGAP And F1AP Messages
    Perform And Verify Successful 2CC After Reestablishment To The Same Cell

*** Keywords ***
Attach UE With Scell Configuration
    Set Internal Traffic Type To UEs    ue_id=1
    Attach Ue    ue_id=1    cell=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1    nwslice=1

Perform And Verify Successful 2CC After Reestablishment To The Same Cell
    Start Tcpdump On Remote Interface    alias=reestablishment    log_filename_prefix=reestablishment    log_dirpath=${OUTPUT_DIR}/tshark
    Perform Ue Reestablishment    ue_id=1    gnb_id=2    cell_id=1
    Verify Tcpdump Log    ${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}    alias=reestablishment    pcap_file_path=${OUTPUT_DIR}/tshark/reestablishment.pcap
    Verify Tcpdump Log     ${F1AP_SCELL_TO_ADD_MOD_LIST}        alias=reestablishment    pcap_file_path=${OUTPUT_DIR}/tshark/reestablishment.pcap
    Stop Tcpdump On Remote Interface
