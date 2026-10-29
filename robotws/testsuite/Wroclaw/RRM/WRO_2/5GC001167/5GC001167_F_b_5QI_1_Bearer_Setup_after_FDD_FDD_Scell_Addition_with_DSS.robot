*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_BLLL_AP_LOO    SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     feature_keywords.robot
Variables    feature_variables.py
Library      Keywords5GC001167.py

Suite Setup       Run Keywords    Add Additional Interfaces
    ...    AND     With Swconfig Flags             flags=@{SWCONFIG_FLAGS_LIST}
    ...    AND     Update And Put Iphy Xml    input_filepath=${CURDIR}/config/5GC001167-F/iphy_DSS_APoABIO.xml
    ...    AND     With Gnb Configuration    commissioning=fdd_3CC_n25_n66_n71_vonr_dss_APoABIO.xml
    ...    AND     Wait For Testline Icmp Echo Replies And Ssh Services
    ...    AND     Wait For Gnb To Reach Configured State
    ...    AND     Start Default Logging    output_dirpath=${OUTPUT_DIR}
    ...    AND     Reach Onair Without Confirmation    lua_cfg=${CURDIR}/config/5GC001167-F/gnb_fs_sa_fdd_cmwv_3CC_DSS_enb_crmsim_APoABIO.cfg
    ...    AND     Wait For All Cells To Be Enabled    timeout=700
    ...    AND     Activate And Check If Xp Link is active
    ...    AND     Sleep    90s    Wait for Xp Link to stabilize
    ...    AND     Proceed with DSS Activation Script With Extended Timer For SIB Reception
    ...    AND     Verify Ngap Messages    packet_filter=${NGAP_SETUP_RESPONSE}    timeout=${NGAP_SETUP_RESPONSE_TIMEOUT}
    ...    AND     Wait For Information Block Reception For Given Cells    cells=${CELLS_1_2_AND_3_DICTIONARY}
    ...    infoblocktype=SystemInformationBlockType1    timeout=600
    ...    AND     Wait For Information Block Reception For Given Cells    cells=${CELLS_1_2_AND_3_DICTIONARY}
    ...    infoblocktype=MasterInformationBlock    timeout=600


Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{SWCONFIG_FLAGS_LIST}=       ${rdMergedMeasGapSetupAndDrxRelease}

*** Test Cases ***
5GC001167-F-b_5QI_1_Bearer_Setup_after_FDD_FDD_Scell_Addition_with_DSS
    Attach UE And Start Data Traffic    ue_id=1    cell_id=1
    Verify ICS On NGAP
    Verify Successful Reconfiguration    packet_filter=${F1AP_RECONFIGURE_TO_3CC_SCELLS_B_C}
    Verify Successful VoNR Establishment On ICS
    [Teardown]    Run Keywords      Release Pdu Session    ue_id=1    pdu_id=1
        ...            AND          Deregister Ue    ue_id=1

