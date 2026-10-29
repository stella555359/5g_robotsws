*** Settings ***
Force Tags    CRT    RAN_5G

Documentation   :copyright: Nokia
...             :authors: Katarzyna Bandrowska & Marta Klukas
...             :contact: katarzyna.bandrowska@nokia.com & marta.klukas@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource    ../5GC001167/feature_keywords.robot
Resource     CB008533_filters_and_keywords.robot
Library      ta5g_testline_management
Library      ta5g_cell_operations
Library      ta5g_enb

Variables    ../resources/custom_policy.py

Suite Setup    Run Keywords    Enable C-Plane Debug Logs    with_reboot=${false}
...    AND         With Swconfig Flags        flags=@{SWCONFIG_FLAGS_LIST}
...    AND         Wait For Environment To Stabilize

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/egate_A_B3.cfg
${iphy_xml}=                ${CURDIR}/config/iphy_6Cells_AHLOA_AEHC_AHFIB_AHCA_mixed_ABIO_FDD_TDD_20_40_MHz_dlmimomode70.xml
${iphy_xml_lpq}=            ${CURDIR}/config/iphy_6Cells_AHLOA_AEHC_AHFIB_AHCA_mixed_ABIO_FDD_TDD_20_40_MHz_dlmimomode70_LPQ.xml
${scfc_lpq}=                scfc_8533_A_B3_LPQ.xml
${scfc}=                    scfc_8533_A_B3.xml
${ue_id}=                                         1
${pcell_id}=                                      1
${gnb_id}=                                        2
${a1_meas_id}=                                    3
${a1_rsrp}=                                       127
${a1_rsrq}=                                       110
@{SWCONFIG_FLAGS_LIST}=       ${rdMergedMeasGapSetupAndDrxRelease}

*** Test Cases ***
CB008533_A_B3a_Single_UE_Call_A1_PCell_Measurement_based_SCell_addition_for_FDD_PCell_with_4CC_DL_CA_FDD_FDD_TDD_TDD_SINCE_23R2
    [Tags]    SBTS00__WITH__CIT__WITH__CLOUD_5G_I_LPQ_AP_LOO
    [Setup]        With Retry Context    1
    ...                Update And Put Iphy Xml         input_filepath=${iphy_xml_lpq}
    ...    AND         With Gnb Configuration          commissioning=${scfc_lpq}
    ...    AND         Enable Tshark Verification
    ...    AND         With Simulator Configuration    config=${cfg}
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${pcell_id}    enb_id=${gnb_id}
    Start Traffic In Both Directions
    Send A1 Measurement For SCell Addition And Verify
    Verify Successful 4CC FFTT On F1AP Messages
    Verify Deconfiguration Of A1 Measurement
    Verify Configuration Of A2 Measurement    filter=${A2_REPORT_CONFIG_TO_ADD_LIST}
    Verify Beam Refinement For Two TDD SCells On RRC Reconfiguration Message
    Verify Beam Refinement For Two TDD SCells On F1AP UE Context Modification Response

CB008533_A_B3b_Single_UE_Call_A1_PCell_Measurement_based_SCell_addition_for_FDD_PCell_with_4CC_DL_CA_FDD_FDD_FDD_TDD_SINCE_23R2
    [Tags]    SBTS00__WITH__CRT__WITH__CLOUD_5G_I_BOO_AP_LOO
    [Setup]        With Retry Context    1
    ...                Update And Put Iphy Xml         input_filepath=${iphy_xml}
    ...    AND         With Gnb Configuration          commissioning=${scfc}
    ...    AND         Enable Tshark Verification
    ...    AND         With Simulator Configuration    config=${cfg}
    Lock Cell And Check
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${pcell_id}    enb_id=${gnb_id}
    Start Traffic In Both Directions
    Send A1 Measurement For SCell Addition And Verify
    Verify Successful 4CC FFFT On F1AP Messages
    Verify Deconfiguration Of A1 Measurement
    Verify Configuration Of A2 Measurement   filter=${F1AP_A2_REPORT_CONFIG_TO_ADD_LIST}
    Verify Beam Refinement For One TDD SCell On RRC Reconfiguration Message
    Verify Beam Refinement For One TDD SCell On F1AP UE Context Modification Response
    Unlock Single Cell    cell_id=3    timeout=90

*** Keywords ***
Lock Cell And Check
    Lock Single Cell              cell_id=3
    Wait For Cell To Be Locked    cell_id=3
    Check Cell Is Locked          cell_id=3

Send A1 Measurement For SCell Addition And Verify
    Execute Egate Command And Wait For Data
    ...     cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${a1_meas_id} event\=A1 srsrp_nr\=${a1_rsrp} srsrq_nr\=${a1_rsrq}
    ...     pass_regexp=message c1 : rrcReconfigurationComplete
    Verify SCells Activation

Verify SCells Activation
    Clear Egate Buffer From Logs
    Verify Egate Content    expected_pattern=SCellIndex 1 activated successfully at airphone
    Verify Egate Content    expected_pattern=SCellIndex 2 activated successfully at airphone
    Verify Egate Content    expected_pattern=SCellIndex 3 activated successfully at airphone
    Display DL Traffic Scheduling On All SCells

Start Traffic In Both Directions
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 mbps=150 dir=dl
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 mbps=50 dir=ul
    traffic.Wait For Traffic To Stabilize
    Display DL Traffic Scheduling On All SCells
