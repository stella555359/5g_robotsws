*** Settings ***
Force Tags    CONFIGURED    CRT    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation
...  maintainer:  Blanka Gozdek, blanka.gozdek@nokia.com
...  author:      Marcin Gorczyca, marcin.gorczyca@nokia.com
...  Description: Suite description in QC

Resource     ../resources/CB008053_AP_resources.robot
Resource     ../../resources/ute_report.robot
Resource     ../../../WRO_2/keywords/messaging.robot
Resource     ../../../WRO_2/keywords/L3_Call.robot

Library      ta_messaging
Library      ../resources/traffic_handling.py
Library      ../resources/CB008053_resources.py
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_delta
Library      ute_fsmaccess
Library      ta5g_iphy
Library      ta_emss


Suite Setup    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
    ...            AND             Update And Put Iphy Xml    input_filepath=${ap_xml}
    ...            AND             With Gnb Configuration    commissioning=${scfc}
    ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND             With Simulator Configuration    config=${egate_config}
    ...            AND             Add Scout Data Info To Testcase


*** Variables ***
${LOGS_COMPRESSION}=    ${False}
${LOGGING_POLICY}=    NO_LOGS
${egate_config}=  ${CURDIR}/config/wts_3cells_FDD_4cells_TDD.cfg
${scfc}=          SCF_CB008053-C-B3.xml
${ap_xml}=        ${CURDIR}/config/iphy_CB008053-C-B3.xml


*** Test Cases ***
CB008053-C-B3_1_SCell_Addition_under_PCell_interfered_condition_for_PCell_frame_structure_change_of_PCell_infFrameStructureType_to_tdLTe
    [Documentation]    This test case verifies SCell Addition mechanism under PCell interfered condition.
                ...    If gNB-CU tries to add more then 1 SCell and maximum HARQ-AN bits per bundle window
                ...    is higher than maximum allowed HARQ bits on PUCCH (maxHarqAn) some SCell candidates
                ...    should be rejected.
                ...    !!! this test needs to be fixed - initial value of parameter needs to be aligned with TP
                ...    initial config
                ...    NRBTS/NRCELL.infTddFrameStructure.infFrameStructureType = '2: semiStatic' (as in testplan)
                ...    !!! then online modification
                ...    Step 7: Activate interfering TDD frame muting for Cell-4. Set NRBTS/NRCELL.actInfTddFrameMuting to True for Cell-4.

    Create UE Alias    alias=UE_1    ue_id=1    id_type=wts_5g
    Create gNB Alias
    Register 4CC DL CA capable NR-UE1 to gNB-2 Cell-4
    Establish PDU session for NR-UE1


    Start 960Mbps DL data traffic for NR-UE1
    Start 100Mbps UL data traffic for NR-UE1
    Wait 15s for throughput stable

    Send A1 measurement report with srsrp value eq 127 and meas_id eq 1 to trigger SCells addition for NR-UE1
    Wait 60s for throughput stable

    Log traffic on scells NR-UE1 scells 0 to 7
    Verify that maximum DL throughput in SA mode on SCell-0 is about 316MBps for NR-UE1
    Verify that maximum DL throughput in SA mode on SCell-1 is about 207MBps for NR-UE1
    Verify that maximum DL throughput in SA mode on SCell-2 is about 100MBps for NR-UE1

    Stop DL and UL traffic on PDU for NR-UE1
    Release PDU session for NR-UE1
    Deregister NR-UE1


    Change infTddFrameStructure configuration to tdLte on Cell4

    Register 4CC DL CA capable NR-UE1 to gNB-2 Cell-4
    Establish PDU session for NR-UE1
    Start 960Mbps DL data traffic for NR-UE1
    Start 100Mbps UL data traffic for NR-UE1
    Wait 15s for throughput stable

    Send A1 measurement report with srsrp value eq 127 and meas_id eq 1 to trigger SCells addition for NR-UE1
    Wait 60s for throughput stable

    Log traffic on scells NR-UE1 scells 0 to 7
    Verify that maximum DL throughput in SA mode on SCell-0 is about 241MBps for NR-UE1
    Verify that maximum DL throughput in SA mode on SCell-1 is about 140MBps for NR-UE1

    [Teardown]  Run keywords
    ...         Stop DL and UL traffic on PDU for NR-UE1
    ...    AND  Release PDU session for NR-UE1
    ...    AND  Deregister NR-UE1
