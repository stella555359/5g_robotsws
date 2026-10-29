*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS25R1
...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Kamil Dabkowski, Damian Rzeczkowski
...              :contact: kamil.dabkowski@nokia.com, damian.rzeczkowski@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/traffic.robot
Resource     ../CB013135/Keywords_CB013135.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_egate
Library      ta5g_iphy
Library      ta5g_pm_counters
Library      ta5g_ue_mobility
Variables    logging_policy.py
Library      ../CB013135/egate_console_log_verifier.py
Library      Collections
Library      taf.ul.ettf.logging

Suite Setup    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_booloo_US1.xml
...            AND             With Gnb Configuration    commissioning=CB013135-B-B5.xml
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Check Radios Availability
...            AND             With Simulator Configuration    config=${CURDIR}/config/wts_basic_US1.cfg
...            AND             Create GNB Alias   gNB_id=${GNB_ID}
...            AND             Create UE Alias    alias=UE1    ue_id=1    id_type=wts_5g
...            AND             Create UE Alias    alias=UE5    ue_id=5    id_type=wts_5g

*** Variables ***
${LOGGING_POLICY}=    FULL_POLICY  # Can be set to FULL_POLICY_WITH_EMIL to capture Emil logs during retests

${GNB_ID}=            2
${UE1_ID}=            1
${UE5_ID}=            5
${PCELL1_ID}=         1
${PCELL5_ID}=         5
${PDU_PCELL_1}=       1
${PDU_PCELL_5}=       5
${GW1_ID}=            1
${GW5_ID}=            5
${UE1_A1_MEAS_ID}=    1
${UE5_A1_MEAS_ID}=    1

${NR_CELL_IDENTITY_1}=    '0b000000000000000000000100000000000001'
${NR_CELL_IDENTITY_2}=    '0b000000000000000000000100000000000010'
${NR_CELL_IDENTITY_3}=    '0b000000000000000000000100000000000011'
${NR_CELL_IDENTITY_4}=    '0b000000000000000000000100000000000100'
${NR_CELL_IDENTITY_5}=    '0b000000000000000000000100000000000101'
${NR_CELL_IDENTITY_6}=    '0b000000000000000000000100000000000110'
${NR_CELL_IDENTITY_7}=    '0b000000000000000000000100000000000111'
${SCELL_PHYSCELL_ID_1}=    51
${SCELL_PHYSCELL_ID_2}=    52
${SCELL_PHYSCELL_ID_3}=    53
${SCELL_PHYSCELL_ID_4}=    54
${SCELL_PHYSCELL_ID_5}=    55
${SCELL_PHYSCELL_ID_6}=    56
${SCELL_PHYSCELL_ID_7}=    57
@{6CC_NR_CELL_IDENTITIY}=   ${NR_CELL_IDENTITY_2}    ${NR_CELL_IDENTITY_3}    ${NR_CELL_IDENTITY_4}    ${NR_CELL_IDENTITY_5}
...    ${NR_CELL_IDENTITY_6}
@{6CC_SCELL_PHYSCELL_ID}=    ${SCELL_PHYSCELL_ID_2}    ${SCELL_PHYSCELL_ID_3}    ${SCELL_PHYSCELL_ID_4}    ${SCELL_PHYSCELL_ID_5}
...    ${SCELL_PHYSCELL_ID_6}
@{UE5_NR_CELL_IDENTITIY}=   ${NR_CELL_IDENTITY_1}    ${NR_CELL_IDENTITY_2}    ${NR_CELL_IDENTITY_3}    ${NR_CELL_IDENTITY_4}
...    ${NR_CELL_IDENTITY_6}
@{UE5_SCELL_PHYSCELL_ID}=    ${SCELL_PHYSCELL_ID_1}    ${SCELL_PHYSCELL_ID_2}    ${SCELL_PHYSCELL_ID_3}    ${SCELL_PHYSCELL_ID_4}
...    ${SCELL_PHYSCELL_ID_6}

${egate_console_log_filename}    /opt/iphy/latest/egate_console.log
&{PATTERNS}    supportedBandCombinationList-v1780=${pattern1}
...            supportedBandCombinationList-UplinkTxSwitch-v1780=${pattern2}
...            featureSetsPerCC-v1780=${pattern3}

${pattern1}    supportedBandCombinationList-v1780\\s*\{
    ...         \\s*\{\\s*ca-ParametersNR-v1780\\s*\{
    ...             \\s*supportedAggBW-FR1-r17\\s*\{
    ...                 \\s*scalingFactorSCS-r17\\s*true,\\s*
    ...                 \\s*supportedAggBW-FDD-DL-r17\\s*fr1-r17\\s*:\\s*mhz120,\\s*
    ...                 \\s*supportedAggBW-FDD-UL-r17\\s*fr1-r17\\s*:\\s*mhz120,\\s*
    ...                 \\s*supportedAggBW-TDD-DL-r17\\s*fr1-r17\\s*:\\s*mhz160,\\s*
    ...                 \\s*supportedAggBW-TDD-UL-r17\\s*fr1-r17\\s*:\\s*mhz160,\\s*
    ...                 \\s*supportedAggBW-TotalDL-r17\\s*fr1-r17\\s*:\\s*mhz280,\\s*
    ...                 \\s*supportedAggBW-TotalUL-r17\\s*fr1-r17\\s*:\\s*mhz280\\s*
    ...             \\}\\s*
    ...         \\}\\s*

${pattern2}    supportedBandCombinationList-UplinkTxSwitch-v1780\\s*\\{\\s*
...             \\s*\\{\\s*bandCombination-v1780\\s*\\{\\s*
...                 \\s*ca-ParametersNR-v1780\\s*\\{\\s*
...                     \\s*supportedAggBW-FR1-r17\\s*\\{\\s*
...                         \\s*scalingFactorSCS-r17\\s*true,\\s*
...                         \\s*supportedAggBW-FDD-DL-r17\\s*fr1-r17\\s*:\\s*mhz120,\\s*
...                         \\s*supportedAggBW-FDD-UL-r17\\s*fr1-r17\\s*:\\s*mhz120,\\s*
...                         \\s*supportedAggBW-TDD-DL-r17\\s*fr1-r17\\s*:\\s*mhz160,\\s*
...                         \\s*supportedAggBW-TDD-UL-r17\\s*fr1-r17\\s*:\\s*mhz160,\\s*
...                         \\s*supportedAggBW-TotalDL-r17\\s*fr1-r17\\s*:\\s*mhz280,\\s*
...                         \\s*supportedAggBW-TotalUL-r17\\s*fr1-r17\\s*:\\s*mhz280\\s*
...                     \\}\\s*
...                 \\}\\s*
...             \\}\\s*
...           \\}\\s*

${pattern3}    featureSetsDownlinkPerCC-v1780\\s*\\{\\s*
...             \\{\\s*supportedBandwidthDL-v1780\\s*fr1-r17\\s*:\\s*mhz30\\s*\\},\\s*
...             \\{\\s*supportedBandwidthDL-v1780\\s*fr1-r17\\s*:\\s*mhz30\\s*\\},\\s*
...             \\{\\s*supportedBandwidthDL-v1780\\s*fr1-r17\\s*:\\s*mhz30\\s*\\},\\s*
...             \\{\\s*supportedBandwidthDL-v1780\\s*fr1-r17\\s*:\\s*mhz30\\s*\\},\\s*
...             \\{\\s*supportedBandwidthDL-v1780\\s*fr1-r17\\s*:\\s*mhz100\\s*\\},\\s*
...             \\{\\s*supportedBandwidthDL-v1780\\s*fr1-r17\\s*:\\s*mhz100\\s*\\},\\s*
...             \\{\\s*supportedBandwidthDL-v1780\\s*fr1-r17\\s*:\\s*mhz100\\s*\\}\\s*
...           \\},\\s*
...           featureSetsUplinkPerCC-v1780\\s*\\{\\s*
...             \\{\\s*supportedBandwidthUL-v1780\\s*fr1-r17\\s*:\\s*mhz30\\s*\\},\\s*
...             \\{\\s*supportedBandwidthUL-v1780\\s*fr1-r17\\s*:\\s*mhz30\\s*\\},\\s*
...             \\{\\s*supportedBandwidthUL-v1780\\s*fr1-r17\\s*:\\s*mhz30\\s*\\},\\s*
...             \\{\\s*supportedBandwidthUL-v1780\\s*fr1-r17\\s*:\\s*mhz30\\s*\\},\\s*
...             \\{\\s*supportedBandwidthUL-v1780\\s*fr1-r17\\s*:\\s*mhz100\\s*\\},\\s*
...             \\{\\s*\\},\\s*
...             \\{\\s*\\}\\s*
...           \\}

*** Test Cases ***
USCB013135-BB501_Known_BC_with_known_BCS5_indicated_for_FR1_CA_band_combination_interaction_with_CB012149_UL_Tx_Switching
    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${UE1_ID}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE1_ID}    cell_id=${PCELL1_ID}
    ...    gnb_id=${GNB_ID}   pdu_id=${PDU_PCELL_1}    gw_id=${GW1_ID}
    Trigger A1 Measurement    ue_id=${UE1_ID}    meas_id=${UE1_A1_MEAS_ID}    srsrp_nr=90    srsrq_nr=95
    Send Data Traffic    ue_id=${UE1_ID}    pdu_id=${PDU_PCELL_1}
    Verify SCell Addition Messages For CC    ue_id=${UE1_ID}    cc_nr_cell_identitiy=@{6CC_NR_CELL_IDENTITIY}
    ...    cc_scell_physcell_id=@{6CC_SCELL_PHYSCELL_ID}      num_of_reportConfigId=7
    Verify ULTxSwitching    ue_id=${UE1_ID}    physcellid_to_verify=55    num_of_reportConfigId=7    pcell_type=TDD
    Verify Selected Band Combination    ${UE1_ID}
    Release UE    ue_id=${UE1_ID}    pdu_id=${PDU_PCELL_1}

    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${UE5_ID}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE5_ID}    cell_id=${PCELL5_ID}
    ...    gnb_id=${GNB_ID}   pdu_id=${PDU_PCELL_5}    gw_id=${GW5_ID}
    Trigger A1 Measurement    ue_id=${UE5_ID}    meas_id=${UE5_A1_MEAS_ID}    srsrp_nr=90    srsrq_nr=95
    Send Data Traffic    ue_id=${UE5_ID}    pdu_id=${PDU_PCELL_5}    inactive_timer=100
    Verify SCell Addition Messages For CC    ue_id=${UE5_ID}    cc_nr_cell_identitiy=@{UE5_NR_CELL_IDENTITIY}
    ...    cc_scell_physcell_id=@{UE5_SCELL_PHYSCELL_ID}      num_of_reportConfigId=6
    Verify ULTxSwitching    ue_id=${UE5_ID}    physcellid_to_verify=51    num_of_reportConfigId=6    pcell_type=FDD
    Verify Selected Band Combination    ${UE1_ID}
    Release UE    ue_id=${UE5_ID}    pdu_id=${PDU_PCELL_5}

    Verify UE Capability from egate console log    ${egate_console_log_filename}    &{PATTERNS}

    [Teardown]    Add Scout Data Info To Testcase

