*** Settings ***
Force Tags    	CLOUD_5G_I_BOO_AP_LOO    SBTS00    RAN_5G_TDD    RAN_5G    CONFIGURED    CRT    PY310     NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Anna Roskosz
...              :contact: anna.roskosz@nokia.com

Resource    ./resources/CB008697_Keywords.robot

Suite Setup    Run Keywords    Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...    AND     Get Iphy Xml File
...    AND     Setup Test Line
...            iphy_xml_filepath=${CURDIR}/config/iphy.xml
...            scfc_filename=scfc.xml
...            perform_full_commissioning=${FULL_COMMISSIONING}
...            perform_testline_reset=${RESET_TL}
...            output_dirpath=${OUTPUT_DIR}/testline_prep
...    AND     Start Xn And Ng Interfaces For Second Gnb
...    AND     Set Counter Collecting Interval To Five Minutes
...    AND     Reach OnAir    lua_cfg=${CURDIR}/../../../resources/airphone/egate_CA_4FDD_2TDD.lua
...    AND     Stop Default Logging   output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords    Add Scout External Execution ID To Reporting Portal
...              AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    Run Keyword If    ${RESTORE_DEFAULT_CONFIG}
...           Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...    AND    Run Keyword If    ${RESTORE_DEFAULT_CONFIG}
...           Update Iphy Configuration And Modify Swconfig
...           iphy_xml_filepath=${OUTPUT_DIR}/iphy.xml
...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CB008697_A_B27_1_Overheating_Assistance_After_SCell_Release
    [Documentation]
    ...    This test case verifies gNB behavior, when UE for which 3 CC CA is configured, sends A2 measurement,
    ...    followed by Overheating Report and activation of cells
    ...    5G_RAN_USR_RRM_4268
    ...
    ...    Testcase checks:
    ...    - checking if when UE sends A2 measurement report for S-Cell release and after that UE sends Overheating Report
    ...    resulted in deactivation of SCell and conditions to activate SCells are met:
    ...    SCell 'Y' is deconfigured and deactivated
    ...    Scell 'X' is activated
    Modify Logging Levels For Traffic
    Set Internal Traffic Type To Ue With Multiple Pdu Sessions    ue_id=20
    Attach Ue    ue_id=20
    Establish Pdu Session    ue_id=20    pdu_id=2    gw_id=2
    Establish Pdu Session    ue_id=20    pdu_id=3    gw_id=3
    Establish Pdu Session    ue_id=20    pdu_id=4    gw_id=4
    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id    ue_id=20    pcell_id=2    srsrp_nr=122    srsrq_nr=122
    ...                                                                    ssinr_nr=122    pass_regexp=message c1 : rrcReconfigurationComplete
    Verify Tcpdump Log    packet_filter=${RRC_SCELL_TO_ADD_2}    number_of_messages=2
    Check Activation Of Overheating Assistance Information
    Send Ue Measurement Nr Event A2 Scell Release With Aligned Meas Id    ue_id=20    scell_id=3    scell=1    scell_rsrp=10    scell_rsrq=12
    ...                                                                   pass_regexp=message c1 : rrcReconfigurationComplete
    Verify Tcpdump Log    packet_filter=${RRC_SCELL_TO_RELEASE_1}
    Ue Assistance Send Nr    ue_id=20    reducedccsdl=1
    Verify Tcpdump Log    packet_filter=${UE_ASSISTANCE_REDUCED_CC_1}
    Start Big Dl Data Transfer And Check If Only One SCell Is Activated

CB008697_A_B26_1_Overheating_Assistance_During_One_SCell_Release
    [Documentation]
    ...    This testcase verifies gNB behavior, when UE for which 3 CC CA is configured and active,
    ...    sends A2 measurement report for two S-Cell release but immediately after reception of
    ...    RRC Reconfiguration for S-Cell release, UE Sends Overheating Assistance message reducing max
    ...    number of S-Cells to 0 - this is verified by counters UM_UE_OVH_REPORTS and NUM_REQ_1_SCELL_ALLOW_OVH
    ...    5G_RAN_USR_RRM_4267
    ...
    ...    Testcase checks if:
    ...    - Counters UM_UE_OVH_REPORTS and NUM_REQ_1_SCELL_ALLOW_OVH and
    ...    5G_DENOM_CONF_UE_OVH_REPORTS (PR:02515615) are incremented properly

    Wait For Next Full Pm Interval
    Modify Logging Levels For Traffic
    Wait Until Keyword Succeeds    2x  100ms   Attach UE    ue_id=21
    Establish Pdu Session With Traffic    ue_id=21   pdu_id=1    gw_id=1   direction=dl   throughput=168mbps
    Establish Pdu Session With Traffic    ue_id=21   pdu_id=2    gw_id=2   direction=dl   throughput=168mbps
    Establish Pdu Session With Traffic    ue_id=21   pdu_id=3    gw_id=3   direction=dl   throughput=168mbps
    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id    ue_id=21    pcell_id=2    srsrq_nr=127    srsrp_nr=127    ssinr_nr=127
    ...    pass_regexp=${SCELL_ACTIVATION_REGEXP}
    ...    timeout=60
    Check Activation Of Overheating Assistance Information
    Postpone RRC Reconfiguration Response    ue_id=21
    Send A2 Event Related To SCell Release And Send OH Assistance In Quick Succession    ue_id=21
    Verify Tcpdump Log    packet_filter=${UE_ASSISTANCE_REDUCED_CC_0}
    Verify M55118C07501 And M55118C07503 And M55118C07508 Counters For Overheating Reports
