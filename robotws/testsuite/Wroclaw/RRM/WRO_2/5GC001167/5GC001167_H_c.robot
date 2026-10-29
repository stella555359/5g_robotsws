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
    ...               scfc=fdd_2CC_n5_n66.xml
    ...               egate_cfg=${CURDIR}/config/sa_fdd_cmWv_fs/fs_sa_call_fdd_cmwv_2CC_n5_n66.cfg
    ...               cell_number=2
    ...               disablel1bypass=True
Test Setup        Start Default Logging    output_dirpath=${OUTPUT_DIR}
Test Teardown     Stop Default Logging
Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
5GC001167-H-c_gNB_Release_UE_With_2CC_Confugured_Due_UE_Inactivity
    Attach UE With Scell Configuration
    Verify Successful 2CC On NGAP And F1AP Messages
    Send Data Traffic For Ue And Display Bearer Statistic    ue_id=1
    Verify Detach Procedure After Ue Inactivity

*** Keywords ***
Attach UE With Scell Configuration
    Set Internal Traffic Type To UEs    ue_id=1
    Attach Ue    ue_id=1    cell=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1    nwslice=1

Verify Detach Procedure After Ue Inactivity
    Start Tcpdump On Remote Interface    alias=detach_check    log_filename_prefix=detach_check    log_dirpath=${OUTPUT_DIR}/tshark
    Verify Tcpdump Log    ${E1AP_UE_NOT_ACTIVE}                  alias=detach_check    timeout=40
    Verify Tcpdump Log    ${F1AP_UE_CONTEXT_RELEASE_COMPLETE}    alias=detach_check
    Stop Tcpdump On Remote Interface
