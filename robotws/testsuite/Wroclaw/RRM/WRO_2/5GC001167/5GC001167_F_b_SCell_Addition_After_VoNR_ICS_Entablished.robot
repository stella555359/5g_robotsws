*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BLLL_AP_LOO

Documentation    :copyright: Nokia

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    feature_keywords.robot
Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Variables   feature_variables.py
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups
Library     taf.ul.ettf.logging

Suite Setup       Prepare Test Environement And Reach Onair With Retry
    ...				iphy_xml=${CURDIR}/config/5GC001167-F/iphy_3CC_n5_n66_n66_VoNR_APoABIO.xml
    ...				scfc=scfc_3CC_n5_n66_n66_VoNR_APoABIO.xml
    ...             egate_cfg=${CURDIR}/config/5GC001167-F/vonremcy_default_on_ics.cfg
    ...             cell_number=3
    ...             disablel1bypass=False

Test Setup        Start Default Logging    output_dirpath=${OUTPUT_DIR}

*** Variables ***
${LOGGING_POLICY}=    FULL_POLICY

*** Test Cases ***
5GC001167-F-b_SCell_Addition_with_5QI1_5_Bearer_Configured_During_ICS
    Attach UE And Start Data Traffic    ue_id=1    cell_id=1
    Verify ICS On NGAP
    Verify Successful Reconfiguration    packet_filter=${F1AP_RECONFIGURE_TO_3CC_SCELLS_A_C}
    Verify Successful VoNR Establishment On ICS
    [Teardown]    Run Keywords      Release Pdu Session    ue_id=1    pdu_id=1
        ...            AND          Deregister Ue    ue_id=1


