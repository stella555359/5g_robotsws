*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_BLLL_AP_LOO

Documentation    :copyright: Nokia

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     feature_keywords.robot

Suite Setup       Prepare Test Environement And Reach Onair With Retry
    ...				iphy_xml=${CURDIR}/config/5GC001167-F/iphy.xml
    ...				scfc=fdd_3CC_n5_n66_n66_VoNR_DRX_prof2_mod.xml
    ...             egate_cfg=${CURDIR}/config/5GC001167-F/vonremcy_pdu2.cfg
    ...             cell_number=3
    ...             disablel1bypass=False
Test Setup        Start Default Logging    output_dirpath=${OUTPUT_DIR}
Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
    ...                AND        Run		command=pkill tail

*** Test Cases ***
5GC001167-F-b_DRX_profile_unchanged
    Add Scout Data Info To Testcase
    Attach UE And Start Data Traffic    ue_id=1    cell_id=1
    Verify ICS On NGAP
    Verify Successful Reconfiguration    packet_filter=${F1AP_RECONFIGURE_TO_3CC_SCELLS_A_C}
    Perform And Verify Successful Stepwise VoNR Establishment
    [Teardown]    Run Keywords      Release Pdu Session    ue_id=1    pdu_id=1
        ...            AND          Deregister Ue    ue_id=1

