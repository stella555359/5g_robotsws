*** Settings ***
Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LOO_DC    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Piotr Pondel
...              :contact: piotr.pondel@nokia.com
...
...    Test Configuration:
...
...    1. Cells
...
...    cell     | band  |  techn. |   BW (DL/UL)    |  nrarfcn        |     DL MIMO
...    -----------------------------------------------------------------------------------
...    cell_1	 |	n71	 |	FDD	   |	10Mhz		 |	127420/136620  |  2x2 Open Loop
...    cell_2	 |	n66	 |	FDD    |	20MHz		 |	431000/349000  |  2x2 Open Loop
...    cell_3	 |	n66	 |	FDD	   |	20MHz    	 |	427000/347000  |  2x2 Open Loop
...    cell_4	 |	n2	 |	FDD	   |	20MHz		 |	392000/376000  |  2x2 Open Loop
...    cell_5	 |	n41	 |	TDD	   |	60MHz		 |	518580         |  2x2 Open Loop
...    cell_6	 |	n77	 |	TDD	   |	60MHz		 |	649970         |  2x2 Open Loop
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
...    6           |  X  |     |     |     |     |         TDD+FDD                       X

Resource     ./resources/CB010413_CB008697_Keywords.robot
Variables    ./resources/Capabilities.py

Suite Setup    Run Keywords    Enable Cloud
...            AND             Update And Put Iphy Xml Aic    input_filepath=${CURDIR}/config/iphy.xml
...            AND             Send Commissioning Vcu And All Vdus Scfc Filepath
...                            scf_vcu_filepath=${CURDIR}/config/default/SCFC_CU_CB010413.xml
...                            scf_vdu_1_filepath=${CURDIR}/config/default/SCFC_DU_CB010413.xml
...            AND             Call Ap Console Reboot
...            AND             Trigger Site Reset Aic Vcu    waiting_for_f1=False
...            AND             Trigger Site Reset Aic Vdu
...            AND             Wait For All Radios To Be Enabled Aic    timeout=600
...            AND             Wait For F1 Links To Be Available Aic
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
...            AND             Start Additional Vm Ethernet Interfaces
...            AND             Reach Onair    lua_cfg=${CURDIR}/../../../../resources/airphone/egate_CA_4FDD_2TDD_aic.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB008697_A_B2_1_Deactivation_Of_OAH_During_Last_SCell_Release
    [Documentation]
    ...        This testcase is based on USR :CB008697-A#B2 and checks gNB behavior, when UE for which CA
    ...        is configured with Overheating Assistance, sends A2 measurement report for S-Cell releases purposes,
    ...        especially when A2 measurement releases last of configured S-Cells

    ...        Testcase checks if:
    ...        UE sends two A2 measurement report for S-Cell release, after first A2 measurment verify deactivation of
    ...        one of scell and check OAI information in RRC Reconfiguration, next UE sends again A2 measurment and
    ...        verify deactivation of scell and again check overheating assistance config

    ...        Postcondition:
    ...        With last S-Cell release, Overheating Assistance configuration is released within the RRC
    ...        Reconfiguration message

    Wait Until Keyword Succeeds    2x  100ms    Attach UE    ue_id=${UE1_CELL2}
    Establish Pdu Session With Traffic    ue_id=${UE1_CELL2}    pdu_id=1    gw_id=1    direction=dl    throughput=175mbps
    Establish Pdu Session With Traffic    ue_id=${UE1_CELL2}    pdu_id=2    gw_id=2    direction=dl    throughput=175mbps
    Establish Pdu Session With Traffic    ue_id=${UE1_CELL2}    pdu_id=3    gw_id=3    direction=dl    throughput=175mbps
    Send A1 event for S-Cell Addition     ue_id=${UE1_CELL2}    meas_id=2
    ...    pass_regexp=SCellIndex 2 activated successfully at airphone.
    Assert Traffic On Every Scell    ue_id=${UE1_CELL2}    scells_amount=2    traffic=True
    Check Activation Of Overheating Assistance Information
    Send A2 Event Related To SCell Release
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATION} && nr-rrc.sCellToReleaseList == 1 && !nr-rrc.overheatingAssistanceConfig == 0
    Send A2 Event Related To SCell Release    meas_id=7    scell=2
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATION} && nr-rrc.sCellToReleaseList == 1 && nr-rrc.overheatingAssistanceConfig == 0
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE} && ${RRC_REJECT}    number_of_messages=0

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=${UE1_CELL2}
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008697_A_B3_1_Outgoing_IntraFreq_IntergNB_HO_OA_Deconfiguration
    [Documentation]    This testcase is based on USR: CB008697-A#B2 and checks gNB behavior, when UE for which CA
    ...                with Overheating Assistance is active, sends measurement reports, indicating low coverage
    ...                of current gNB, and gNB starts inter-gNB intra-frequency HO procedure via the Xn interface.
    ...                Confirmation point: Overheating assistance set to 'setup' in message from source to target gNB.
    ...                Requirement: 5G_RAN_USR_RRM_4244

    Wait Until Keyword Succeeds    2x  100ms   Attach Ue    ue_id=${UE1_CELL6}
    Establish Pdu Session With Traffic    ue_id=${UE1_CELL6}    pdu_id=1    gw_id=1    direction=dl    throughput='168mbps'
    Establish Pdu Session With Traffic    ue_id=${UE1_CELL6}    pdu_id=2    gw_id=2    direction=dl    throughput='168mbps'
    Send A1 Event For S-Cell Addition    ue_id=${UE1_CELL6}    meas_id=2
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_1SCELL_ADDITION}
    Send A2 Event For A5 Configuration    ue_id=${UE1_CELL6}    meas_id=1
    Send A5 Event To Trigger Ho    ue_id=${UE1_CELL6}    phycell_id=56    nrsrp_nr=122    nrsrq_nr=122    nsinr_nr=122    meas_id=5
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIG_HANDOVER}
    Verify Tcpdump Log    packet_filter=${RRC_OH_SETUP}

    [Teardown]       Run Keywords    Deregister Ue Without Confirmation    ue_id=${UE1_CELL6}
    ...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008697_A_B6_1_A1_PCell_Switch_Triggered_Overheating_Deactivation
    [Documentation]
    ...        This test case checks gNB behavior, for which CA configuration is available and Overheating Assistance is enabled,
    ...        when PCell Switch is triggered
    ...        5G_RAN_USR_RRM_4247
    ...
    ...        Testcase checks if:
    ...        - Handover to S-cell is successful
    ...        - RRC reconfiguration contains overheating release value
    ...        - Handover Preparation contains current timerPostOverheating value

    Setup Custom UE Radio Capabilities    ue_id=${UE1_CELL1}    ue_nr_capabilities=${UE_CAPA_PCELLSWITCH}
    Set Internal Traffic Type To Ue With One Pdu Session    ue_id=${UE1_CELL1}    pdu=1
    Attach Ue    ue_id=${UE1_CELL1}
    Establish Pdu Session    ue_id=${UE1_CELL1}    pdu_id=1    gw_id=1
    Send Custom Ue Measurement Nr    id=${UE1_CELL1} event=A1 meas_id=2 srsrp_nr=122 srsrq_nr=122 ssinr_nr=122
    ...                              pass_regexp=message c1 : rrcReconfigurationComplete
    Check Activation of Overheating Assistance Information
    Start Dl Data Transfer And Check If SCell Is Activated    ue_id=${UE1_CELL1}    pdu=1
    Perform A1 PCell Switch And Verify If Handover Is Successful    ue_id=${UE1_CELL1}    meas_id=5
    Verify Tcpdump Log    packet_filter=${RRC_SCELL_TO_REMOVED_1}
    Verify Tcpdump Log    packet_filter=${RRC_SCELL_TO_RELEASE_1}
    Verify Tcpdump Log    packet_filter=${OH_RELEASE}

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=${UE1_CELL1}
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008697_A_B18_1_Overheated_UE_SCell_Change_Interaction
    [Documentation]    This testcase checks gNB behavior, when Overheating Assistance is enabled, and UE For which CA
    ...                is configured, reported that it is in overheated state, then sends A1 measurement for S-Cell
    ...                change.
    ...                Confirmation point: Assert proper traffic related to given cell depending on the scenario.
    ...                Requirement: 5G_RAN_USR_RRM_4259

    ${no_traffic}=  Convert To Number  0
    Wait Until Keyword Succeeds    2x  100ms    Attach Ue    ue_id=${UE4_CELL3}
    Establish Pdu Session With Traffic    ue_id=${UE4_CELL3}    pdu_id=1    gw_id=1    direction=dl    throughput='168mbps'
    Establish Pdu Session With Traffic    ue_id=${UE4_CELL3}    pdu_id=2    gw_id=2    direction=dl    throughput='168mbps'
    Establish Pdu Session With Traffic    ue_id=${UE4_CELL3}    pdu_id=3    gw_id=3    direction=dl    throughput='168mbps'
    Establish Pdu Session With Traffic    ue_id=${UE4_CELL3}    pdu_id=4    gw_id=4    direction=dl    throughput='168mbps'

    Send A1 Event For S-Cell Addition    ue_id=${UE4_CELL3}    meas_id=1    srsrp=75    srsrq=75    ssinr=75
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_1SCELL_ADDITION}
    Verify Tcpdump Log    packet_filter=${F1AP_1SCELL_ADDITION}
    Assert Traffic On Every Scell    ue_id=${UE4_CELL3}    scells_amount=1    traffic=True

    Ue Assistance Send Nr    ue_id=${UE4_CELL3}    reducedccsdl=0
    Sleep    2s    reason=wating for PsUser_UserChangeInd msg from Cplane to L2PS
    Assert Traffic On Every Scell    ue_id=${UE4_CELL3}    scells_amount=1    traffic=False

    Send A1 Event For S-Cell Addition    ue_id=${UE4_CELL3}    meas_id=2    pass_regexp=.*
    Assert Traffic On Every Scell    ue_id=${UE4_CELL3}    scells_amount=1    traffic=False

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=${UE4_CELL3}
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008697_A_B25_2_Post_RRC_Reconfiguration_Overheating_Handling_during_CA_Release
    [Documentation]
    ...             This TC tests situation, where UE for which CA with Overheating is configured, sends
    ...             A2 measurement for last S-Cell release(CA Release) and immediately after sends
    ...             UE Assistance Information wgit ith Overheating Information in it ( before reception of RRC
    ...             Reconfiguration Complete by gNB). In this case Overheating assistance  shall not be taken into
    ...             consideration as we release CA from UE - this is checked by counter NUM_UE_OVH_REPORTS.
    ...             This is a corner case, and it is possible to trigger due to ue_rrc_reconf_param command
    ...             where we postpone sending of RRCReconfComplete by 2 seconds ( More seconds can result in RRC guard
    ...             timer expiration ).

    Wait Until Keyword Succeeds    2x  100ms    Attach UE    ue_id=${UE6_CELL1}
    Establish Pdu Session With Traffic    ue_id=${UE6_CELL1}    pdu_id=1    gw_id=1    direction=dl    throughput=175mbps
    Send A1 Event For S-Cell Addition    ue_id=${UE6_CELL1}    meas_id=2
    Postpone RRC Reconfiguration Response    ue_id=${UE6_CELL1}
    Release S-Cell And Send Overheating Assistance In Quick Succession    ue_id=${UE6_CELL1}
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_CA_RELEASE}
    Verify Tcpdump Log    packet_filter=${OVERHEATING_UE_0_MAXCCS}
    Verify Counter For Overheating Reports

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=${UE6_CELL1}
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
