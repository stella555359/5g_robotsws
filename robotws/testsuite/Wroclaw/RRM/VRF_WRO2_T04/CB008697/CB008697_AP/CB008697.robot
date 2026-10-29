*** Settings ***
Documentation
...    Test Configuration:
...
...    1. Cells
...
...    cell     | band  |  techn. |   BW (DL/UL)    |  nrarfcn        |     DL MIMO
...    -----------------------------------------------------------------------------------
...    cell_1    |  n71  |  FDD    |    10Mhz        |  127420/136620  |  2x2 Open Loop
...    cell_2    |  n5   |  FDD    |    5MHz         |  176300/167300  |  2x2 Open Loop
...    cell_3    |  n66  |  FDD    |    20MHz/10Mhz  |  427000/347000  |  2x2 Open Loop
...    cell_4    |  n2   |  FDD    |    20MHz        |  392000/376000  |  2x2 Open Loop
...    cell_5    |  n41  |  TDD    |    60MHz        |  518580         |  2x2 Open Loop
...    cell_6    |  n77  |  TDD    |    60MHz        |  649970         |  2x2 Open Loop
...
...    2. cells CA relations:
...
...    pcell/scell |  1  |  2  |  3  |  4  |  5  |  6      CA type              external gNB relation
...    ------------------------------------------------   ---------            -------------------------
...    1           |     |     |     |     |  X  |         FDD+TDD
...    2           |     |     |  X  |  X  |     |         FDD+FDD+FDD
...    3           |  X  |     |     |     |  X  |  X      FDD+FDD+TDD+TDD
...    4           |     |     |     |     |     |         --
...    5           |  X  |     |  X  |     |     |  X      TDD+FDD+FDD+TDD
...    6           |  X  |     |     |     |     |         TDD+FDD                        X

Force Tags      CLOUD_5G_I_BOO_AP_LOO    SBTS00    RAN_5G_TDD    RAN_5G    CONFIGURED    CRT    PY310     NoResUsage    RF50
Resource     ./resources/CB008697_Keywords.robot
Variables    ./resources/CB008697_Capabilities.py


Suite Setup    Run Keywords    Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...    AND     Get Iphy Xml File
...    AND     Setup Test Line
...            iphy_xml_filepath=${CURDIR}/config/iphy.xml
...            scfc_filename=scfc.xml
...            perform_full_commissioning=${FULL_COMMISSIONING}
...            perform_testline_reset=${RESET_TL}
...            output_dirpath=${OUTPUT_DIR}/testline_prep
...    AND     Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...    AND     Set Counter Collecting Interval To Five Minutes
...    AND     Start Xn And Ng Interfaces For Second Gnb
...    AND     Reach Onair    lua_cfg=${LUA_FILEPATH_3CC}
...    AND     Modify Logging Levels For Traffic
...    AND     Stop Default Logging   output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Run Keyword If    ${RESTORE_DEFAULT_CONFIG}
...            Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...    AND     Run Keyword If    ${RESTORE_DEFAULT_CONFIG}
...            Update Iphy Configuration And Modify Swconfig
...            iphy_xml_filepath=${OUTPUT_DIR}/iphy.xml
...    AND     Stop Default Processes And Gather Logs And Compress Logs

Test Setup        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB008697_A_B25_2_Post_RRC_Reconfiguration_Overheating_Handling_during_CA_Release
    [Documentation]
    ...    This TC tests situation, where UE for which CA with Overheating is configured, sends
    ...    A2 measurement for last S-Cell release(CA Release) and immediately after sends
    ...    UE Assistance Information wgit ith Overheating Information in it ( before reception of RRC
    ...    Reconfiguration Complete by gNB). In this case Overheating assistance  shall not be taken into
    ...    consideration as we release CA from UE - this is checked by counter NUM_UE_OVH_REPORTS.
    ...    This is a corner case, and it is possible to trigger due to ue_rrc_reconf_param command
    ...    where we postpone sending of RRCReconfComplete by 2 seconds ( More seconds can result in RRC guard
    ...    timer expiration ).

    Wait Until Keyword Succeeds    2x  100ms   Attach UE    ue_id=${UE6_CELL1}
    Establish Pdu Session With Traffic    ue_id=${UE6_CELL1}   pdu_id=1    gw_id=1   direction=dl   throughput=175mbps

    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id    ue_id=${UE6_CELL1}    pcell_id=1    scellTechnology=TDD    srsrq_nr=127
    ...                                                                    srsrp_nr=127    ssinr_nr=127
    ...                                                                    pass_regexp=message c1 : rrcReconfigurationComplete    timeout=60
    Postpone RRC Reconfiguration Response    ue_id=${UE6_CELL1}
    Release S-Cell And Send Overheating Assistance In Quick Succession    ue_id=${UE6_CELL1}
    Verify Tcpdump Log   packet_filter=${RRC_RECONF_CA_RELEASE}
    Verify Tcpdump Log   packet_filter=${OVERHEATING_UE_0_MAXCCS}
    Verify Counter For Overheating Reports

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...    AND    Deregister Ue Without Confirmation    ue_id=${UE6_CELL1}
    ...    AND    Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008697_A_B2_1_Deactivation_Of_OAH_During_Last_SCell_Release
    [Documentation]
    ...    This testcase is based on USR :CB008697-A#B2 and checks gNB behavior, when UE for which CA
    ...    is configured with Overheating Assistance, sends A2 measurement report for S-Cell releases purposes,
    ...    especially when A2 measurement releases last of configured S-Cells

    ...    Testcase checks if:
    ...    UE sends two A2 measurement report for S-Cell release, after first A2 measurment verify deactivation of
    ...    one of scell and check OAI information in RRC Reconfiguration, next UE sends again A2 measurment and
    ...    verify deactivation of scell and again check overheating assistance config

    ...    Postcondition:
    ...    With last S-Cell release, Overheating Assistance configuration is released within the RRC
    ...    Reconfiguration message

    Wait Until Keyword Succeeds    2x  100ms   Attach UE    ue_id=${UE1_CELL2}
    Establish Pdu Session With Traffic    ue_id=${UE1_CELL2}   pdu_id=1    gw_id=1   direction=dl   throughput=175mbps
    Establish Pdu Session With Traffic    ue_id=${UE1_CELL2}   pdu_id=2    gw_id=2   direction=dl   throughput=175mbps
    Establish Pdu Session With Traffic    ue_id=${UE1_CELL2}   pdu_id=3    gw_id=3   direction=dl   throughput=175mbps
    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id    ue_id=${UE1_CELL2}    pcell_id=2    srsrq_nr=127    srsrp_nr=127
    ...    ssinr_nr=127
    ...    pass_regexp=${SCELL_ACTIVATION_REGEXP}
    ...    timeout=60
    Assert Traffic On Every Scell    ue_id=${UE1_CELL2}    scells_amount=2    traffic=True
    Check Activation Of Overheating Assistance Information
    Send Ue Measurement Nr Event A2 Scell Release With Aligned Meas Id     ue_id=${UE1_CELL2}    scell_id=3    scell=1    scell_rsrp=10
    ...                                                                    scell_rsrq=12    pass_regexp=message c1 : rrcReconfigurationComplete
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATION} && nr-rrc.sCellToReleaseList == 1 && !nr-rrc.overheatingAssistanceConfig == 0
    Send Ue Measurement Nr Event A2 Scell Release With Aligned Meas Id     ue_id=${UE1_CELL2}     scell_id=4    scell=2    scell_rsrp=10
    ...                                                                    scell_rsrq=12    pass_regexp=message c1 : rrcReconfigurationComplete
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATION} && nr-rrc.sCellToReleaseList == 1 && nr-rrc.overheatingAssistanceConfig == 0
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE} && ${RRC_REJECT}    number_of_messages=0

    [Teardown]    Run Keywords     Add Scout External Execution ID To Reporting Portal
    ...    AND    Deregister Ue Without Confirmation    ue_id=${UE1_CELL2}
    ...    AND    Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008697_A_B3_1_Outgoing_IntraFreq_IntergNB_HO_OA_Deconfiguration
    [Documentation]    This testcase is based on USR: CB008697-A#B2 and checks gNB behavior, when UE for which CA
    ...    with Overheating Assistance is active, sends measurement reports, indicating low coverage
    ...    of current gNB, and gNB starts inter-gNB intra-frequency HO procedure via the Xn interface.
    ...    Confirmation point: Overheating assistance set to 'setup' in message from source to target gNB.
    ...    Requirement: 5G_RAN_USR_RRM_4244

    Wait Until Keyword Succeeds    2x  100ms   Attach Ue    ue_id=${UE1_CELL6}
    Establish Pdu Session With Traffic    ue_id=${UE1_CELL6}    pdu_id=1    gw_id=1    direction=dl    throughput='168mbps'
    Establish Pdu Session With Traffic    ue_id=${UE1_CELL6}    pdu_id=2    gw_id=2    direction=dl    throughput='168mbps'
    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id    ue_id=${UE1_CELL6}    pcell_id=6    srsrq_nr=127    srsrp_nr=127
    ...                                                                    ssinr_nr=127
    ...                                                                    pass_regexp=message c1 : rrcReconfigurationComplete    timeout=60
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_1SCELL_ADDITION}
    Send Ue Measurement Nr Event A2 Handover With Aligned Meas Id    ue_id=${UE1_CELL6}    pcell_id=6    srsrp_nr=1    srsrq_nr=1
    ...                                                               pass_regexp=message c1 : rrcReconfigurationComplete
    Send Ue Measurement Nr Event A5 With Aligned Meas Id    ue_id=${UE1_CELL6}    carrier_freq=127450    srsrq_nr=1    srsrp_nr=1    ssinr_nr=1
    ...                                                     phycell_id=56    nrsrq_nr=122    nrsrp_nr=122    nsinr_nr=122
    ...                                                     pass_regexp=message c1 : rrcReconfigurationComplete
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIG_HANDOVER}
    Verify Tcpdump Log    packet_filter=${RRC_OH_SETUP}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...    AND    Deregister Ue Without Confirmation    ue_id=${UE1_CELL6}
    ...    AND    Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008697_A_B6_1_A1_PCell_Switch_Triggered_Overheating_Deactivation
    [Documentation]
    ...    This test case checks gNB behavior, for which CA configuration is available and Overheating Assistance is enabled,
    ...    when PCell Switch is triggered
    ...    5G_RAN_USR_RRM_4247
    ...
    ...    Testcase checks if:
    ...    Handover to S-cell is successful
    ...    - RRC reconfiguration contains overheating release value
    ...    - Handover Preparation contains current timerPostOverheating value

    Setup Custom UE Radio Capabilities    ue_id=${UE1_CELL1}    ue_nr_capabilities=${UE_CAPA_PCELLSWITCH}
    Set Internal Traffic Type To Ue With One Pdu Session    ue_id=${UE1_CELL1}    pdu=1
    Attach Ue    ue_id=${UE1_CELL1}
    Establish Pdu Session    ue_id=${UE1_CELL1}    pdu_id=1    gw_id=1
    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id    ue_id=${UE1_CELL1}    pcell_id=1    scellTechnology=TDD    srsrp_nr=122
    ...                                                                    srsrq_nr=122     ssinr_nr=122
    ...                                                                    pass_regexp=message c1 : rrcReconfigurationComplete    timeout=60
    Check Activation of Overheating Assistance Information
    Start Dl Data Transfer And Check If SCell Is Activated    ue_id=${UE1_CELL1}    pdu=1
    Send Ue Measurement Nr Event A1 Pcell Switch With Aligned Meas Id     ue_id=${UE1_CELL1}    scell_id=5    scell=1    scell_rsrp=127
    ...                                                                   scell_sinr=127    scell_rsrq=127
    ...                                                                   pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.5 performed
    Verify Tcpdump Log    packet_filter=${RRC_SCELL_TO_REMOVED_1}
    Verify Tcpdump Log    packet_filter=${RRC_SCELL_TO_RELEASE_1}
    Verify Tcpdump Log    packet_filter=${OH_RELEASE}

    [Teardown]    Run Keywords     Add Scout External Execution ID To Reporting Portal
    ...    AND    Deregister Ue Without Confirmation    ue_id=${UE1_CELL1}
    ...    AND    Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


CB008697_A_B7_2_3CC_All_SCell_Deactivation
    [Documentation]
     ...    This testcase checks gNB behavior, when Overheating Assistance is enabled, and UE For which CA
     ...    with 2 S-Cells are Active, sends Overheating Assitance IE, with request to deactivate all scells.
     ...    Requirement: 5G_RAN_USR_RRM_4248
     ...    Testcase checks:
     ...    - checking if all S-Cells are deactive for traffic after overheating assistance message

    Wait Until Keyword Succeeds    2x  100ms   Attach UE    ue_id=${UE2_CELL2}
    Establish Pdu Session With Traffic    ue_id=${UE2_CELL2}   pdu_id=1    gw_id=1   direction=dl   throughput=175mbps
    Establish Pdu Session With Traffic    ue_id=${UE2_CELL2}   pdu_id=2    gw_id=2   direction=dl   throughput=175mbp
    Establish Pdu Session With Traffic    ue_id=${UE2_CELL2}   pdu_id=3    gw_id=3   direction=dl   throughput=175mbps
    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id    ue_id=${UE2_CELL2}    pcell_id=2    srsrq_nr=127
    ...                                                                    srsrp_nr=127    ssinr_nr=127
    ...                                                                    pass_regexp=message c1 : rrcReconfigurationComplete
    Assert Traffic On Every Scell    ue_id=${UE2_CELL2}   scells_amount=2    traffic=${True}    traffic_stabilization=${True}
    Ue Assistance Send Nr    ue_id=${UE2_CELL2}   reducedccsdl=0
    Assert Traffic On Every Scell    ue_id=${UE2_CELL2}    scells_amount=2    traffic=${False}    traffic_stabilization=${True}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...    AND    Deregister Ue Without Confirmation    ue_id=${UE2_CELL2}
    ...    AND    Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008697_A_B8_1_Deactivate_Already_Inactive_SCells
    [Documentation]    This testcase checks gNB behavior, when Overheating Assistance is enabled, and UE For which
    ...    CA with 2 S-Cells are Active, sends Overheating Assitance IE, with request to deactivate all cells.
    ...    Confirmation point: Assert Traffic On Every Scell
    ...    Requirement: 5G_RAN_USR_RRM_4249

    Wait Until Keyword Succeeds    2x  100ms   Attach Ue    ue_id=${UE1_CELL5}
    Establish Pdu Session With Traffic    ue_id=${UE1_CELL5}    pdu_id=1    gw_id=1    direction=dl    throughput='168mbps'
    Establish Pdu Session With Traffic    ue_id=${UE1_CELL5}    pdu_id=2    gw_id=2    direction=dl    throughput='168mbps'
    Establish Pdu Session With Traffic    ue_id=${UE1_CELL5}    pdu_id=3    gw_id=3    direction=dl    throughput='168mbps'
    Establish Pdu Session With Traffic    ue_id=${UE1_CELL5}    pdu_id=4    gw_id=4    direction=dl    throughput='168mbps'

    Verify Tcpdump Log    packet_filter=${RRC_RECONF_3SCELLS_ADDITION}
    Verify Tcpdump Log    packet_filter=${F1AP_3SCELLS_ADDITION}
    Assert Traffic On Every Scell    ue_id=${UE1_CELL5}    scells_amount=3    traffic=True

    Stop Data Traffic    ues=${UE1_CELL5}    pdu=4    direction=dl
    Stop Data Traffic    ues=${UE1_CELL5}    pdu=3    direction=dl
    Stop Data Traffic    ues=${UE1_CELL5}    pdu=2    direction=dl
    Stop Data Traffic    ues=${UE1_CELL5}    pdu=1    direction=dl
    Assert Traffic On Every Scell    ue_id=${UE1_CELL5}    scells_amount=3    traffic=False
    Ue Assistance Send Nr    ue_id=${UE1_CELL5}    reducedccsdl=0
    Assert Traffic On Every Scell    ue_id=${UE1_CELL5}    scells_amount=3    traffic=False

    Start Data Traffic    ues=${UE1_CELL5}    pdu=1    direction=dl    throughput='168mbps'
    Start Data Traffic    ues=${UE1_CELL5}    pdu=2    direction=dl    throughput='168mbps'
    Start Data Traffic    ues=${UE1_CELL5}    pdu=3    direction=dl    throughput='168mbps'
    Start Data Traffic    ues=${UE1_CELL5}    pdu=4    direction=dl    throughput='168mbps'
    Assert Traffic On Every Scell    ue_id=${UE1_CELL5}    scells_amount=3    traffic=False

    Send Empty Ue Assistance Nr    ue_id=${UE1_CELL5}
    Assert Traffic On Every Scell    ue_id=${UE1_CELL5}    scells_amount=3    traffic=True

    [Teardown]    Run Keywords     Add Scout External Execution ID To Reporting Portal
    ...    AND    Deregister Ue Without Confirmation    ue_id=${UE1_CELL5}
    ...    AND    Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008697_A_B10_1_Priority_Recalculation_Same_Number_Of_SCells
    [Documentation]    This testcase checks gNB behavior, when Overheating Assistance is enabled, and UE For which CA
    ...    with 2 S-Cell is Active, sends Overheating Assistance IE, with request to deactivate one cell,
    ...    and gNB shall choose cell with higher UE load.
    ...    Confirmation point: Assert proper traffic related to given cell depending on the scenario.
    ...    Requirement: 5G_RAN_USR_RRM_4251

    ${no_traffic}=  Convert To Number  0
    Wait Until Keyword Succeeds    2x  100ms   Attach Ue    ue_id=${UE3_CELL2}
    Establish Pdu Session With Traffic    ue_id=${UE3_CELL2}    pdu_id=1    gw_id=1    direction=dl    throughput='168mbps'
    Establish Pdu Session With Traffic    ue_id=${UE3_CELL2}    pdu_id=2    gw_id=2    direction=dl    throughput='168mbps'
    Establish Pdu Session With Traffic    ue_id=${UE3_CELL2}    pdu_id=3    gw_id=3    direction=dl    throughput='168mbps'

    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id    ue_id=${UE3_CELL2}    pcell_id=2    srsrq_nr=127    srsrp_nr=127
    ...                                                                    ssinr_nr=127
    ...                                                                    pass_regexp=message c1 : rrcReconfigurationComplete    timeout=60
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_2SCELLS_ADDITION}
    Verify Tcpdump Log    packet_filter=${F1AP_2SCELLS_ADDITION}
    Assert Traffic On Every Scell    ue_id=${UE3_CELL2}    scells_amount=2    traffic=True

    Wait Until Keyword Succeeds    2x  100ms   Attach Ue    ue_id=${UE1_CELL4}
    Wait Until Keyword Succeeds    2x  100ms   Attach Ue    ue_id=${UE2_CELL4}
    Wait Until Keyword Succeeds    2x  100ms   Attach Ue    ue_id=${UE3_CELL4}
    Establish Pdu Session With Traffic    ue_id=${UE1_CELL4}    pdu_id=4    gw_id=4    direction=dl    throughput='168mbps'
    Establish Pdu Session With Traffic    ue_id=${UE2_CELL4}    pdu_id=5    gw_id=5    direction=dl    throughput='168mbps'
    Establish Pdu Session With Traffic    ue_id=${UE3_CELL4}    pdu_id=6    gw_id=6    direction=dl    throughput='168mbps'

    Ue Assistance Send Nr    ue_id=${UE3_CELL2}    reducedccsdl=1
    ${scell_1_traffic}=    Get Scell Avg Dl Data Traffic    ue_id=${UE3_CELL2}    scell=2
    Run Keyword And Continue On Failure
    ...    Should Not Be Equal    ${scell_1_traffic}    ${no_traffic}      msg=Scell_1 unproperly deactivated
    ${scell_2_traffic}=    Get Scell Avg Dl Data Traffic    ue_id=${UE3_CELL2}    scell=1
    Run Keyword And Continue On Failure
    ...    Should Be Equal    ${scell_2_traffic}    ${no_traffic}     msg=Scell_2 isn't deactivated

    Deregister Ue Without Confirmation    ue_id=${UE1_CELL4}
    Deregister Ue Without Confirmation    ue_id=${UE2_CELL4}
    Deregister Ue Without Confirmation    ue_id=${UE3_CELL4}

    Wait Until Keyword Succeeds    2x  100ms   Attach Ue    ue_id=${UE1_CELL3}
    Wait Until Keyword Succeeds    2x  100ms   Attach Ue    ue_id=${UE2_CELL3}
    Wait Until Keyword Succeeds    2x  100ms   Attach Ue    ue_id=${UE3_CELL3}
    Establish Pdu Session With Traffic    ue_id=${UE1_CELL3}    pdu_id=7    gw_id=7    direction=dl    throughput='168mbps'
    Establish Pdu Session With Traffic    ue_id=${UE2_CELL3}    pdu_id=8    gw_id=8    direction=dl    throughput='168mbps'
    Establish Pdu Session With Traffic    ue_id=${UE3_CELL3}    pdu_id=9    gw_id=9    direction=dl    throughput='168mbps'

    Ue Assistance Send Nr    ue_id=${UE1_CELL2}    reducedccsdl=1
    ${scell_1_traffic}=    Get Scell Avg Dl Data Traffic    ue_id=${UE3_CELL2}    scell=2
    Run Keyword And Continue On Failure
    ...    Should Not Be Equal    ${scell_1_traffic}    ${no_traffic}      msg=Scell_1 unproperly deactivated
    ${scell_2_traffic}=    Get Scell Avg Dl Data Traffic    ue_id=${UE3_CELL2}    scell=1
    Run Keyword And Continue On Failure
    ...    Should Be Equal    ${scell_2_traffic}    ${no_traffic}     msg=Scell_2 isn't deactivated

    Check Counters Related To CellLoad Based Deactivation

    [Teardown]    Run Keywords     Add Scout External Execution ID To Reporting Portal
    ...    AND    Deregister Ue Without Confirmation    ue_id=${UE3_CELL2}
    ...    AND    Deregister Ue Without Confirmation    ue_id=${UE1_CELL3}
    ...    AND    Deregister Ue Without Confirmation    ue_id=${UE2_CELL3}
    ...    AND    Deregister Ue Without Confirmation    ue_id=${UE3_CELL3}
    ...    AND    Deregister Ue Without Confirmation    ue_id=${UE1_CELL4}
    ...    AND    Deregister Ue Without Confirmation    ue_id=${UE2_CELL4}
    ...    AND    Deregister Ue Without Confirmation    ue_id=${UE3_CELL4}
    ...    AND    Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008697_A_B13_1_Activation_Of_More_SCells_Than_Currently_Active_Current_Max
    [Documentation]
    ...    This testcase checks gNB behavior, when Overheating Assistance is enabled, and UE For which CA with 3 S-Cells
    ...    are configured is in overheating state with already sent reducedMaxCCs=2 ( So 2 S-cells may be active ),
    ...    but only one of S-Cells has been activated for traffic, sends another OA report, with reducedMaxCCs = 2
    ...    Requirement: 5G_RAN_USR_RRM_4254
    ...    Testcase checks if:
    ...    - There is no traffic on Scell_1 after increased traffic
    ...    - Counters NUM_UE_OVH_REPORTS and NUM_REQ_2_SCELL_ALLOW_OVH are incremented properly

    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE2_CELL5}
    Establish Pdu Session With Traffic    ue_id=${UE2_CELL5}    pdu_id=1    gw_id=1    direction=dl    throughput='168mbps'
    Establish Pdu Session With Traffic    ue_id=${UE2_CELL5}    pdu_id=2    gw_id=2    direction=dl    throughput='168mbps'
    Establish Pdu Session With Traffic    ue_id=${UE2_CELL5}    pdu_id=3    gw_id=3    direction=dl    throughput='168mbps'
    Establish Pdu Session With Traffic    ue_id=${UE2_CELL5}    pdu_id=4    gw_id=4    direction=dl    throughput='168mbps'

    Verify Tcpdump Log    packet_filter=${RRC_RECONF_3SCELLS_ADDITION}
    Verify Tcpdump Log    packet_filter=${F1AP_3SCELLS_ADDITION}
    Assert Traffic On Every Scell    ue_id=${UE2_CELL5}    scells_amount=3    traffic=True

    Ue Assistance Send Nr    ue_id=${UE2_CELL5}    reducedccsdl=2

    Stop Data Traffic    ues=${UE2_CELL5}      pdu=4    direction=dl
    Stop Data Traffic    ues=${UE2_CELL5}      pdu=3    direction=dl

    Ue Assistance Send Nr    ue_id=${UE2_CELL5}    reducedccsdl=2
    Start Data Traffic    ues=${UE2_CELL5}      pdu=3    direction=dl    throughput='168mbps'
    Start Data Traffic    ues=${UE2_CELL5}      pdu=4    direction=dl    throughput='168mbps'

    ${no_traffic}=    Convert To Number    0
    ${scell_1_traffic}=    Get Scell Avg Dl Data Traffic    ue_id=${UE2_CELL5}    scell=1
    Run Keyword And Continue On Failure
    ...    Should Be Equal    ${scell_1_traffic}    ${no_traffic}    msg=Scell_1 with no traffic
    ${scell_2_traffic}=    Get Scell Avg Dl Data Traffic    ue_id=${UE2_CELL5}    scell=2
    Run Keyword And Continue On Failure
    ...    Should Not Be Equal    ${scell_2_traffic}    ${no_traffic}    msg=Scell_2 with traffic

    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Run Keyword And Continue On Failure    Verify Any Counters In File
    ...    M55118C07501    +2    NUM_UE_OVH_REPORTS
    ...    M55118C07505    +2    NUM_REQ_2_SCELL_ALLOW_OVH
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...    AND    Deregister Ue Without Confirmation    ue_id=${UE1_CELL5}
    ...    AND    Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008697_A_B18_1_Overheated_UE_SCell_Change_Interaction
    [Documentation]    This testcase checks gNB behavior, when Overheating Assistance is enabled, and UE For which CA
    ...    is configured, reported that it is in overheated state, then sends A1 measurement for S-Cell
    ...    change.
    ...    Confirmation point: Assert proper traffic related to given cell depending on the scenario.
    ...    Requirement: 5G_RAN_USR_RRM_4259

    ${no_traffic}=  Convert To Number  0
    Wait Until Keyword Succeeds    2x  100ms   Attach Ue    ue_id=${UE4_CELL3}
    Establish Pdu Session With Traffic    ue_id=${UE4_CELL3}    pdu_id=1    gw_id=1    direction=dl    throughput='168mbps'
    Establish Pdu Session With Traffic    ue_id=${UE4_CELL3}    pdu_id=2    gw_id=2    direction=dl    throughput='168mbps'
    Establish Pdu Session With Traffic    ue_id=${UE4_CELL3}    pdu_id=3    gw_id=3    direction=dl    throughput='168mbps'
    Establish Pdu Session With Traffic    ue_id=${UE4_CELL3}    pdu_id=4    gw_id=4    direction=dl    throughput='168mbps'

    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id    ue_id=${UE4_CELL3}    pcell_id=3    srsrq_nr=75    srsrp_nr=75
    ...                                                                    ssinr_nr=75
    ...                                                                    pass_regexp=message c1 : rrcReconfigurationComplete    timeout=60
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_1SCELL_ADDITION}
    Verify Tcpdump Log    packet_filter=${F1AP_1SCELL_ADDITION}
    Assert Traffic On Every Scell    ue_id=${UE4_CELL3}    scells_amount=1    traffic=True

    Ue Assistance Send Nr    ue_id=${UE4_CELL3}    reducedccsdl=0
    Assert Traffic On Every Scell    ue_id=${UE4_CELL3}    scells_amount=1    traffic=False

    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id    ue_id=${UE4_CELL3}    pcell_id=3    scellTechnology=TDD    srsrq_nr=127
    ...                                                                    srsrp_nr=127    ssinr_nr=127
    ...                                                                    pass_regexp=.*    timeout=60
    Assert Traffic On Every Scell    ue_id=${UE4_CELL3}    scells_amount=1    traffic=False

    [Teardown]    Run Keywords     Add Scout External Execution ID To Reporting Portal
    ...    AND    Deregister Ue Without Confirmation    ue_id=${UE4_CELL3}
    ...    AND    Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008697_A_B19_1_Existing_UE_Online_Deactivation
    [Documentation]
    ...    This testcase verifies gNB behavior, when there is UE connected to gNB,
    ...    with already configured CA, and Overheating Assistance,
    ...    and operator turns off Overheating Assistance feature via webUI,
    ...    then UE for which overheating was configured, sends OAI IE.
    ...    5G_RAN_USR_RRM_4260

    Set Internal Traffic Type To Ue With One Pdu Session    ue_id=${UE2_CELL1}
    Attach Ue    ue_id=${UE2_CELL1}
    Establish Pdu Session    ue_id=${UE2_CELL1}    pdu_id=1    gw_id=1
    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id    ue_id=${UE2_CELL1}    pcell_id=1    scellTechnology=TDD    srsrq_nr=127
    ...                                                                    srsrp_nr=127    ssinr_nr=127
    ...                                                                    pass_regexp=message c1 : rrcReconfigurationComplete    timeout=60
    Check Activation Of Overheating Assistance Information
    Start Dl Data Transfer And Check If SCell Is Activated    ue_id=${UE2_CELL1}  pdu=1
    Perform Parameter Commissioning    parameter=actOverheatingAssistance    value=false    dist_name=MRBTS-1/NRBTS-1
    Send Overheating Assistance And Check If SCell Is Deactivated    ue_id=${UE2_CELL1}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...    AND    Perform Parameter Commissioning
    ...           parameter=actOverheatingAssistance
    ...           value=true
    ...           dist_name=MRBTS-1/NRBTS-1
    ...    AND    Deregister Ue Without Confirmation    ue_id=${UE2_CELL1}
    ...    AND    Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008697_A_B20_1_Feature_Online_Activation
    [Documentation]    This testcase verifies gNB behavior, when overheating feature is disabled,
    ...    has UE connected with CA configured, and than Overheating
    ...    Assistance is being activated by gNB operator.
    ...    5G_RAN_USR_RRM_4261

    Perform Parameter Commissioning    parameter=actOverheatingAssistance    value=false    dist_name=MRBTS-1/NRBTS-1
    Attach Ue    ue_id=${UE3_CELL1}
    Establish Pdu Session    ue_id=${UE3_CELL1}    pdu_id=1    gw_id=1
    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id    ue_id=${UE3_CELL1}    pcell_id=1    scellTechnology=TDD    srsrq_nr=127
    ...                                                                    srsrp_nr=127    ssinr_nr=127
    ...                                                                    pass_regexp=message c1 : rrcReconfigurationComplete    timeout=60
    Verify Tshark For No Messages     packet_filter=${RRC_RECONFIGURATION_OH}    alias=default_tcpdump_alias
    Find Scfc And Send Delta Commissioning    scfc_filename=delta_8697_ue2.json
    Attach Ue    ue_id=${UE4_CELL1}
    Establish Pdu Session    ue_id=${UE4_CELL1}    pdu_id=1    gw_id=2
    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id    ue_id=${UE4_CELL1}    pcell_id=1    scellTechnology=TDD    srsrq_nr=127
    ...                                                                    srsrp_nr=127    ssinr_nr=127
    ...                                                                    pass_regexp=message c1 : rrcReconfigurationComplete    timeout=60
    Check Activation Of Overheating Assistance Information For Second UE

    [Teardown]    Run Keywords     Add Scout External Execution ID To Reporting Portal
    ...    AND    Deregister Ue Without Confirmation    ue_id=${UE3_CELL1}
    ...    AND    Deregister Ue Without Confirmation    ue_id=${UE4_CELL1}
    ...    AND    Find Scfc And Send Delta Commissioning    scfc_filename=delta_8697_revert.json
    ...    AND    Perform Parameter Commissioning
    ...           parameter=actOverheatingAssistance    value=true    dist_name=MRBTS-1/NRBTS-1
    ...    AND    Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008697_A_B21_2_Blind_Scell_Addition_RRC_Reestablishment_In_Overheated_State
    [Documentation]
    ...    This testcase verifies gNB behavior, when overheating feature is enabled, and UE for which CA is active
    ...    (blind S-Cell addition) and overheating assistance has been sent, requests for RRC Reestablishment
    ...    5G_RAN_USR_RRM_4262
    ...
    ...    Testcase checks:
    ...    - checking if all S-Cells are active for traffic after RRC Reestablishment

    Perform Parameter Commissioning    parameter=sCellAdditionMethod    value=blind    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
    Set Internal Traffic Type To Ue With One Pdu Session    ue_id=${UE5_CELL1}    pdu=1
    Attach Ue    ue_id=${UE5_CELL1}
    Establish Pdu Session    ue_id=${UE5_CELL1}   pdu_id=1    gw_id=1
    Check Activation Of Overheating Assistance Information
    Start Dl Data Transfer And Check If SCell Is Activated    ue_id=${UE5_CELL1}    pdu=1
    Send Overheating Assistance And Check If SCell Is Deactivated    ue_id=${UE5_CELL1}
    Verify Tcpdump Log    packet_filter=${UE_ASSISTANCE_REDUCED_CC_0}
    Initiate Ue RRc Reestablishment    ue_id=${UE5_CELL1}    gnb=2    cell=1
    Start Dl Data Transfer And Check If SCell Is Activated    ue_id=${UE5_CELL1}    pdu=1

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...    AND    Perform Parameter Commissioning
    ...           parameter=sCellAdditionMethod
    ...           value=covBasedA1
    ...           dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
    ...    AND    Deregister Ue Without Confirmation    ue_id=${UE5_CELL1}
    ...    AND    Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

