*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1    NoResUsage
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/traffic.robot
Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource    ../keywords/logging.robot
Resource     ../CB008717/feature_keywords.robot

Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups
Library     ta5g_ue_measurements
Library     ta5g_testline_management

Variables    ../resources/custom_policy.py

Suite Setup    Run Keywords    Enable C-Plane Debug Logs    with_reboot=${false}
...    AND         With Swconfig Flags        flags=@{SWCONFIG_FLAGS_LIST}
...    AND         Wait For Environment To Be Ready

Test Setup      With Retry Context    3
...                Trigger Site Reset
...    AND         Check Radios Availability
...    AND         Update And Put Iphy Xml         input_filepath=${iphy_xml}
...    AND         With Gnb Configuration          commissioning=${scfc}
...    AND         Enable Tshark Verification
...    AND         With Simulator Configuration    config=${cfg}

Test Teardown     Run Keywords    Deregister UE   ue_id=${UE_ID}
...               AND             Stop Default Logging
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${LOGGING_POLICY}=          MANUAL_TEST_POLICY
${cfg}=                     ${CURDIR}/config/egate_A-B10a.cfg
${iphy_xml}=                ${CURDIR}/config/iphy_6Cells_AHLOA_AEHC_AHFIB_AHCA_mixed_ABIO_FDD_TDD_40_100_MHz.xml
${scfc}=                    scfc_6Cells_AHLOA_AEHC_AHFIB_AHCA_mixed_ABIO_FDD_TDD_40_100_MHz.xml
${UE_ID}=             1
${PCELL_ID}=          1
${4CC_A1_MEAS_ID}=    4
${A1_RSRP}=           90
${SCELL}=             2
${GNB_ID}=            2
${A1_MEAS_ID_PCELL_CHANGE}=     6
${NR_RRC_A1_MEASUREMENT_FOR_SCELL_ADDITION}=       (nr-rrc.c1) && (nr-rrc.a1_Threshold ) &&
                                             ...   (nr-rrc.reportConfigId == 4) &&
                                             ...   (nr-rrc.measObjectId == 1) && (nr-rrc.measId == ${4CC_A1_MEAS_ID})

${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}=                f1ap.SCell_ToBeSetupMod_List == 3

${NR_RCC_SCELL_TO_BE_SETUP_MOD_LIST}=              (nr-rrc.c1) && (nr-rrc.sCellToAddModList == 3) &&
                                            ...    (nr-rrc.FreqBandIndicatorNR == 66) &&
                                            ...    (nr-rrc.FreqBandIndicatorNR == 41) &&
                                            ...    (nr-rrc.FreqBandIndicatorNR == 41)

${NR_RRC_A2_MEASUREMENT_FOR_SCELL1_RELEASE}=       (nr-rrc.a2_Threshold) && (nr-rrc.reportConfigId == 6) &&
                                            ...    (nr-rrc.measObjectId == 2) && (nr-rrc.freqBandIndicatorNR == 66) &&
                                            ...    (nr-rrc.measId == 8)

${NR_RRC_A2_MEASUREMENT_FOR_SCELL2_RELEASE}=       (nr-rrc.a2_Threshold) && (nr-rrc.reportConfigId == 6) &&
                                            ...    (nr-rrc.measObjectId == 3) &&
                                            ...    (nr-rrc.freqBandIndicatorNR == 41) && (nr-rrc.measId == 9)

${NR_RRC_A2_MEASUREMENT_FOR_SCELL3_RELEASE}=       (nr-rrc.a2_Threshold) && (nr-rrc.reportConfigId == 6) &&
                                             ...    (nr-rrc.measObjectId == 4) &&
                                             ...    (nr-rrc.freqBandIndicatorNR == 41) && (nr-rrc.measId == 10)

${NR_RRC_A1_MEASUREMENT_FOR_PCELL_CHANGE_TO_SCELL1}=    (nr-rrc.a1_Threshold) && (nr-rrc.reportConfigId == 5) &&
                                                    ...    (nr-rrc.measObjectId == 2) &&
                                                    ...    (nr-rrc.freqBandIndicatorNR == 66)  && (nr-rrc.measId == 5)


${NR_RRC_A1_MEASUREMENT_FOR_PCELL_CHANGE_TO_SCELL2}=    (nr-rrc.a1_Threshold) && (nr-rrc.reportConfigId == 5) &&
                                                    ...     (nr-rrc.measObjectId == 3) &&
                                                    ...    (nr-rrc.freqBandIndicatorNR == 41)  && (nr-rrc.measId == 6)


${NR_RRC_A1_MEASUREMENT_FOR_PCELL_CHANGE_TO_SCELL3}=    (nr-rrc.a1_Threshold) && (nr-rrc.reportConfigId == 5) &&
                                                    ...    (nr-rrc.measObjectId == 4) &&
                                                    ...    (nr-rrc.freqBandIndicatorNR == 41)  && (nr-rrc.measId == 7)

${NR_RRC_TO_RELEASE_LIST}=     nr-rrc.sCellToReleaseList == 3
@{SWCONFIG_FLAGS_LIST}=       ${rdMergedMeasGapSetupAndDrxRelease}

*** Test Cases ***
CB008533_A_B10a_PCell_Change
    Attach UE And Establish PDU Session    ue_id=${UE_ID}    cell_id=${PCELL_ID}    enb_id=${GNB_ID}    pdu_session_setup_timeout=20
    Verify A1 Measurement For SCell Addition
    Send A1 Measurement To PCell For 4CC
    Verify Successful 4CC FFTT On RRC And F1AP Messages
    Verify A2 Measurement For SCell Release Is Configured At The UE For Each Of The SCells
    Verify A1 Measurement For PCell Change Is Configured At The UE
    Send Data Traffic
    Verify That Traffic Is Scheduled On All SCells
    Send A1 Measurement For PCell Change To SCell2
    Verify Successful PCell Change And SCells Release

*** Keywords ***
Verify A1 Measurement For SCell Addition
    Verify Tcpdump Log      packet_filter=${NR_RRC_A1_MEASUREMENT_FOR_SCELL_ADDITION}    continue_on_failure=False

Send A1 Measurement To PCell For 4CC
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${4CC_A1_MEAS_ID} srsrp_nr=${A1_RSRP} event=A1
    ...    pass_regexp=rrcReconfigurationComplete
    ...    timeout=30

Send A1 Measurement For PCell Change To SCell2
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${A1_MEAS_ID_PCELL_CHANGE} event=A1 scell=${SCELL} scell_rsrp=${A1_RSRP}
    ...    pass_regexp=rrcReconfigurationComplete
    ...    timeout=30

Verify Successful 4CC FFTT On RRC And F1AP Messages
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}
    Verify Tcpdump Log      packet_filter=${NR_RCC_SCELL_TO_BE_SETUP_MOD_LIST}

Verify A2 Measurement For SCell Release Is Configured At The UE For Each Of The SCells
    Verify Tcpdump Log      packet_filter=${NR_RRC_A2_MEASUREMENT_FOR_SCELL1_RELEASE}
    Verify Tcpdump Log      packet_filter=${NR_RRC_A2_MEASUREMENT_FOR_SCELL2_RELEASE}
    Verify Tcpdump Log      packet_filter=${NR_RRC_A2_MEASUREMENT_FOR_SCELL3_RELEASE}

Verify A1 Measurement For PCell Change Is Configured At The UE
    Verify Tcpdump Log      packet_filter=${NR_RRC_A1_MEASUREMENT_FOR_PCELL_CHANGE_TO_SCELL1}
    Verify Tcpdump Log      packet_filter=${NR_RRC_A1_MEASUREMENT_FOR_PCELL_CHANGE_TO_SCELL2}
    Verify Tcpdump Log      packet_filter=${NR_RRC_A1_MEASUREMENT_FOR_PCELL_CHANGE_TO_SCELL3}

Verify Successful PCell Change And SCells Release
    Verify Tcpdump Log      packet_filter=${NR_RRC_TO_RELEASE_LIST}  number_of_messages=2


