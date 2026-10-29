*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation
...        maintainer:   Lukasz Klimowicz, lukasz.klimowicz@nokia.com
...        authors:      Lukasz Klimowicz, lukasz.klimowicz@nokia.com

Resource      ./resources/CB006733_AP_resources.robot
Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../../../WRO_2/keywords/messaging.robot
Resource     ../../../WRO_2/keywords/traffic.robot
Resource     ../../../WRO_2/keywords/L3_Call.robot
Resource     ../../../WRO_2/keywords/tshark_verifying.robot
Resource     ../../resources/common_airphone_keywords.robot
Resource     ../../resources/common_keywords.robot
Resource     ../../resources/ute_report.robot
Resource     ta_messaging/flow.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_delta
Library      ta5g_iphy
Variables    logging_policy.py

Suite Setup    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
    ...            AND             Update And Put Iphy Xml    input_filepath=${ap_xml}
    ...            AND             With Gnb Configuration    commissioning=${scfc}
    ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND             With Simulator Configuration    config=${lua_cfg_file}

*** Variables ***
${LOGS_COMPRESSION}=    ${True}
#${KEEP_ALIVE}=    ${True}
${LOGGING_POLICY}=    NO_LOGS
${lua_cfg_file}=       ${CURDIR}/config/wts_6733_vonr.cfg
${scfc}=               scfc_CB006733_BOO_AP_LOO_VoNR.xml
${ap_xml}=             ${CURDIR}/config/iphy_xml_6733.xml
${LOW_PATHLOSS}=       28
${HIGH_PATHLOSS}=      120
${LOW_NOISE_PUSCH}=   -1043
${HIGH_NOISE_PUSCH}=  -300

@{UE4_trf_ids}=    1    2    3    4    5
@{UE4_mbps}=    150    150    150    150    150
@{UE4_qfi_ids}=    1    1    1    1    1
@{PCell_id}=    0
@{SCell_id}=    1
@{PCell_SCell_id}=    0    1
@{UE1_trf_ids}=    1    2    3    4    5
@{UE1_mbps}=    150    150    150    150    150
@{UE1_qfi_ids}=    1    1    1    1    1


*** Test Cases ***
CB006733-A_15_UPlane_PCell_Downlink_Quality_checks_for_UE_with_VoNR

    Prepare test environment B15

    Attach UE And Establish PDU Session    ue_id=4   cell_id=4    enb_id=2    pdu_id=4    gw_id=4
    Modify PDU By Adding Additional DRB    ue_id=4    pdu_id=4    qos_flows=2
    Start VoNR call    UE_ID=4    PDU_ID=4
    Set CQI reported by UE    CQI=8    UE_ID=4
    Start Data Traffic    ue_id=4   pdu_id=4    qfi_id_list=${UE4_qfi_ids}
    ...    trf_id_list=${UE4_trf_ids}
    ...    dir=dl
    ...    mbps_list=${UE4_mbps}
    ...    protocol=tcp
    Wait for Traffic to Stabilize

    Wait For Enabling A4 Measurements
    Send all A4 measurement reports for UE    UE_ID=4    PHYCELL_ID=55
    Verify traffic occurs only on PCell    UE_ID=4

    Start TTI trace
    Set CQI reported by UE    CQI=14    UE_ID=4
    Wait For Enabling A4 Measurements
    Send all A4 measurement reports for UE    UE_ID=4    PHYCELL_ID=55
    Stop and convert TTI trace collection    directory_name=tti

    Verify traffic occurs on PCell and SCell    UE_ID=4
    Verify VoNR transmission is uninterrupted    ue_id=4    pdu_id=4
    Verify in TTI traces that addition of SCell occurred after dlCaCqiWindow
    ...     tti_path=${OUTPUT_DIR}/${TEST_NAME}/tti/
    ...     vonr=True

    [Teardown]    Clean test environment B15


CB006733-A_16_UPlane_PCell_Uplink_Quality_checks_for_UE_with_VoNR
    [Documentation]
    ...    This scenario tests if feature properly handles situation when SCell activation should occur due to sufficient
    ...    DL traffic but is halted by uplink PCell link quality for UE with VoNR call.

    Prepare test environment B16
    Set SINR reported by UE to get good radio condition    UE_ID=1
    Attach UE And Establish PDU Session    ue_id=1   cell_id=4    enb_id=2    pdu_id=1    gw_id=1
    Modify PDU By Adding Additional DRB    ue_id=1    pdu_id=1    qos_flows=2
    Start VoNR call    UE_ID=1    PDU_ID=1
    Start Data Traffic    ue_id=1   pdu_id=1    qfi_id_list=${UE1_qfi_ids}
    ...    trf_id_list=${UE1_trf_ids}
    ...    dir=dl
    ...    mbps_list=${UE1_mbps}
    ...    protocol=tcp
    Start TTI trace
    Wait For Enabling A4 Measurements
    Send all A4 measurement reports for UE    UE_ID=1    PHYCELL_ID=55
    Stop and convert TTI trace collection    directory_name=High_SINR
    Verify traffic occurs on PCell and SCell    UE_ID=1
    Verify That Throughput Is Reached On Specific Cells    ue_id=1    cells_list=${PCell_id}
    ...    expected_throughput=190    direction=dl    margin=5%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=1    cells_list=${SCell_id}
    ...    expected_throughput=350    direction=dl    margin=5%    selection_type=maximum
    Verify VoNR transmission    tti_csv_path=${OUTPUT_DIR}/${TEST_NAME}/High_SINR/
    Release UE    ue_id=1   pdu_id=1


    Set SINR reported by UE to get bad radio condition      UE_ID=1
    Attach UE And Establish PDU Session    ue_id=1   cell_id=4    enb_id=2    pdu_id=1    gw_id=1
    Start Data Traffic    ue_id=1   pdu_id=1    qfi_id_list=${UE1_qfi_ids}
    ...    trf_id_list=${UE1_trf_ids}
    ...    dir=dl
    ...    mbps_list=${UE1_mbps}
    ...    protocol=tcp
    Wait for Traffic to Stabilize
    Start TTI trace
    Wait For Enabling A4 Measurements
    Send all A4 measurement reports for UE    UE_ID=1    PHYCELL_ID=55
    Stop and convert TTI trace collection  directory_name=Low_SINR_no_5qi
    Verify traffic occurs on PCell and SCell   UE_ID=1
    Verify That Throughput Is Reached On Specific Cells    ue_id=1    cells_list=${PCell_id}
    ...    expected_throughput=190    direction=dl    margin=5%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=1    cells_list=${SCell_id}
    ...    expected_throughput=350    direction=dl    margin=5%    selection_type=maximum
    Release UE    ue_id=1   pdu_id=1


    Set SINR reported by UE to get bad radio condition      UE_ID=1
    Attach UE And Establish PDU Session    ue_id=1   cell_id=4    enb_id=2    pdu_id=1    gw_id=1
    Modify PDU By Adding Additional DRB    ue_id=1    pdu_id=1    qos_flows=2
    Start VoNR call   UE_ID=1    PDU_ID=1
    Start Data Traffic    ue_id=1   pdu_id=1    qfi_id_list=${UE1_qfi_ids}
    ...    trf_id_list=${UE1_trf_ids}
    ...    dir=dl
    ...    mbps_list=${UE1_mbps}
    ...    protocol=tcp
    Wait for Traffic to Stabilize
    Start TTI trace
    Wait For Enabling A4 Measurements
    Send all A4 measurement reports for UE    UE_ID=1    PHYCELL_ID=55
    Stop and convert TTI trace collection  directory_name=Low_SINR
    Verify VoNR transmission    tti_csv_path=${OUTPUT_DIR}/${TEST_NAME}/Low_SINR/
    Verify traffic occurs only on PCell    UE_ID=1
    Verify That Throughput Is Reached On Specific Cells    ue_id=1    cells_list=${PCell_id}
    ...    expected_throughput=350    direction=dl    margin=5%    selection_type=maximum

    [Teardown]    Clean test environment B16

*** Keywords ***
Prepare test environment B15
    Update Parameter   param=dllaDeltaCqiMax    value=1    distname=MRBTS-1/NRBTS-1/NRCELL-4
    Update Parameter   param=dlCaMinPCellCqi    value=10    distname=MRBTS-1/NRBTS-1/NRCELL-4
    Update Parameter   param=dlCaMinPCellCqi5qi1    value=10    distname=MRBTS-1/NRBTS-1/NRCELL-4

Prepare test environment B16
    Update Parameter   param=ulCaMinPCellSinr  value=1  distname=MRBTS-1/NRBTS-1/NRCELL-4
    Update Parameter   param=ulCaMinPCellSinr5qi1  value=18  distname=MRBTS-1/NRBTS-1/NRCELL-4

Clean test environment B15
    ute_report.Add Scout Data Info To Testcase
    Release UE    ue_id=4   pdu_id=4
    Update Parameter   param=dllaDeltaCqiMax  value=1  distname=MRBTS-1/NRBTS-1/NRCELL-4
    Update Parameter   param=dlCaMinPCellCqi  value=0  distname=MRBTS-1/NRBTS-1/NRCELL-4
    Update Parameter   param=dlCaMinPCellCqi5qi1  value=0  distname=MRBTS-1/NRBTS-1/NRCELL-4

Clean test environment B16
    ute_report.Add Scout Data Info To Testcase
    Release UE    ue_id=1   pdu_id=1
    Update Parameter   param=ulCaMinPCellSinr  value=0  distname=MRBTS-1/NRBTS-1/NRCELL-4
    Update Parameter   param=ulCaMinPCellSinr5qi1  value=0  distname=MRBTS-1/NRBTS-1/NRCELL-4

Verify traffic occurs only on PCell
    [Arguments]  ${UE_ID}
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE_ID}    cells_list=${PCell_id}
    ...    expected_throughput=10    direction=dl    margin=3%    selection_type=maximum
    Execute Egate Command And Wait For Data
    ...          cmd=ue_stats_nr id=${UE_ID} scell=0-1
    ...          fail_regexp=(CellIndex-[1][\\s][\\s][1-9].*\\n){1}

Verify traffic occurs on PCell and SCell
    [Arguments]  ${UE_ID}
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE_ID}    cells_list=${PCell_id}
    ...    expected_throughput=50    direction=dl    margin=3%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE_ID}    cells_list=${SCell_id}
    ...    expected_throughput=50    direction=dl    margin=3%    selection_type=maximum

Wait For Traffic to Stabilize
    BuiltIn.Sleep    4

Wait For Enabling A4 Measurements
    Execute Egate Command And Wait For Data
    ...    cmd=ue_disp
    ...    pass_regexp=measIdToAddModList
    ...    timeout=15
