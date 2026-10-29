*** Settings ***
Documentation
...    Test Configuration - cells:
...
...    cell     | band   |  techn. |   BW (DL/UL)    |  nrarfcn        |     DL MIMO
...    -----------------------------------------------------------------------------------
...    cell_1    |  n71  |  FDD    |    10Mhz        |  127420/136620  |  2x2 Open Loop
...    cell_2    |  n5   |  FDD    |    5MHz         |  176300/167300  |  2x2 Open Loop
...    cell_3    |  n66  |  FDD    |    20MHz/10Mhz  |  427000/347000  |  2x2 Open Loop
...    cell_4    |  n2   |  FDD    |    20MHz        |  392000/376000  |  2x2 Open Loop
...    cell_5    |  n41  |  TDD    |    60MHz        |  518580         |  2x2 Open Loop
...    cell_6    |  n77  |  TDD    |    60MHz        |  649970         |  2x2 Open Loop

...    Authors: Wojciech Bednarz, Anna Roskosz
...    Contact: wojciech.bednarz@nokia.com, anna.roskosz@nokia.com
...    Maintainer: Piotr Gudas
...    Contact: piotr.gudas@nokia.com

Force Tags    CLOUD_5G_I_BOO_AP_LOO    PY310    NoResUsage    RF50

Resource     ./resources/CB006877_Keywords.robot
Resource     ./resources/CB006877_Variables.robot
Library       ta5g_iphy
Library       ta5g_enb
Library       ta5g_testline_management
Library       ta5g_pm_counters

Suite Setup    Run Keywords    Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Get Iphy Xml File
...            AND             Change RD Parameters in Swconfig File

Suite Teardown     Stop Default Processes And Gather Logs And Compress Logs    teardown_egate_instances=False

*** Variables ***
${RRC_RECONFIGURATION_BWP_1}=    ${RRC_RECONFIGURATION} && nr-rrc.bwp_Id == 1 && nr-rrc.bwp_Id != 0 && nr-rrc.resourceToAddModList == 1
${FULL_COMMISSIONING}=    ${TRUE}
${RESET_TL}=    ${FALSE}
${RESTORE_DEFAULT_CONFIG}=    ${TRUE}

*** Test Cases ***
CB006878_SR_A_ET_B2_01_04_HKF_Trigger_Multi_UEs_CSI_Resources_Reconfigure_From_Higher_Index_I_To_Lower_Index_I_And_Check_HKF_Counter
    [Documentation]    This test case verify multi UEs HKF
    ...                Test case covers requirement: 5G_RAN_USR_RRM_23359; 5G_CP_ARC_ALG_12854

    [Setup]    Run Keywords    Setup Test Line
    ...                            iphy_xml_filepath=${CURDIR}/config/iphy_B2.xml
    ...                            scfc_filename=SCFC_CB006877_B2.xml
    ...                            perform_full_commissioning=${FULL_COMMISSIONING}
    ...                            perform_testline_reset=${RESET_TL}
    ...                            output_dirpath=${OUTPUT_DIR}/testline_prep
    ...        AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Start Xn And Ng Interfaces For Second Gnb
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB006877_B2_CA_4FDD_2TDD.lua

    Attach Multiple Ues And Establish Pdu Sessions With Prb Defining    first_ue=31    last_ue=36
    ${UE32_startingPRB}    Get Prb Value Of Given Ue Sa    ue_id=32    prb=startingPRB
    ${UE32_secondHopPRB}   Get Prb Value Of Given Ue Sa    ue_id=32    prb=secondHopPRB
    ${UE31_startingPRB}    Get Prb Value Of Given Ue Sa    ue_id=31    prb=startingPRB
    ${UE31_secondHopPRB}   Get Prb Value Of Given Ue Sa    ue_id=31    prb=secondHopPRB
    ${UE34_startingPRB}    Get Prb Value Of Given Ue Sa    ue_id=34    prb=startingPRB
    ${UE34_secondHopPRB}   Get Prb Value Of Given Ue Sa    ue_id=34    prb=secondHopPRB
    ${UE36_ue_f1ap_id}     Get F1ap Ue Sa Id Value         ue_id=36

    Attach Multiple Ues And Establish Pdu Sessions With Prb Defining    first_ue=51    last_ue=54
    ${UE53_ue_f1ap_id}    Get F1ap Ue Sa Id Value         ue_id=53
    ${UE52_startingPRB}   Get Prb Value Of Given Ue Sa    ue_id=52    prb=startingPRB
    ${UE52_secondHopPRB}  Get Prb Value Of Given Ue Sa    ue_id=52    prb=secondHopPRB
    ${UE51_startingPRB}   Get Prb Value Of Given Ue Sa    ue_id=51    prb=startingPRB
    ${UE51_secondHopPRB}  Get Prb Value Of Given Ue Sa    ue_id=51    prb=secondHopPRB

    Attach Multiple Ues And Start Gnb Addition With Prb Defining    first_ue=1    last_ue=6    target_cells=3    gnb_triggered=False

    ${UE1_startingPRB}    Get Prb Value Of Given Ue Nsa    ue_id=1    prb=startingPRB
    ${UE1_secondHopPRB}   Get Prb Value Of Given Ue Nsa    ue_id=1    prb=secondHopPRB
    ${UE2_startingPRB}    Get Prb Value Of Given Ue Nsa    ue_id=2    prb=startingPRB
    ${UE2_secondHopPRB}   Get Prb Value Of Given Ue Nsa    ue_id=2    prb=secondHopPRB
    ${UE4_startingPRB}    Get Prb Value Of Given Ue Nsa    ue_id=4    prb=startingPRB
    ${UE4_secondHopPRB}   Get Prb Value Of Given Ue Nsa    ue_id=4    prb=secondHopPRB
    ${UE6_ue_f1ap_id}     Get F1ap Ue Nsa Id Value         ue_id=6
    ${UE5_ue_f1ap_id}     Get F1ap Ue Nsa Id Value         ue_id=5

    Attach Multiple Ues And Start Gnb Addition With Prb Defining    first_ue=7    last_ue=9    target_cells=5    gnb_triggered=False
    ${UE7_startingPRB}    Get Prb Value Of Given Ue Nsa    ue_id=7    prb=startingPRB
    ${UE7_secondHopPRB}   Get Prb Value Of Given Ue Nsa    ue_id=7    prb=secondHopPRB

    Start Pcaps Collection For Test Subcase    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    subcase_name=HKF_procedure
    Perform B2 Case Handovers
    Wait For HKF Period

    ${UE36_HKF}    Create RrcReconfiguration Filter With New Prb Values After Hkf And F1ap Id    ue_f1ap_id=${UE36_ue_f1ap_id}
    ...                                                                                          startingPRB=${UE34_startingPRB}
    ...                                                                                          secondHopPRB=${UE34_secondHopPRB}

    ${UE6_HKF_1ST}    Create UEContextModificationRequired Filter With New Prb Values After Hkf And F1ap Id    ue_f1ap_id=${UE6_ue_f1ap_id}
    ...                                                                                                        startingPRB=${UE4_startingPRB}
    ...                                                                                                        secondHopPRB=${UE4_secondHopPRB}

    Verify Tcp Messages For Subcase    packet_filter=${UE36_HKF} && nr-rrc.resourceToAddModList == 1    subcase_name=HKF_procedure

    Verify Tcp Messages For Subcase    packet_filter=${UE6_HKF_1ST} && nr-rrc.resourceToAddModList == 1 && nr-rrc.cellGroupId == 1
    ...                                subcase_name=HKF_procedure

    Get PRB Value And Assert If Is Correct    packet_filter=${UE36_HKF}    prb=startingPRB    alias=tcpdump_subcase
    ...                                       subcase=HKF_procedure    expected_value=${UE34_startingPRB}
    Get PRB Value And Assert If Is Correct    packet_filter=${UE36_HKF}    prb=secondHopPRB    alias=tcpdump_subcase
    ...                                       subcase=HKF_procedure    expected_value=${UE34_secondHopPRB}
    Get PRB Value And Assert If Is Correct    packet_filter=${UE6_HKF_1ST}    prb=startingPRB    alias=tcpdump_subcase
    ...                                       subcase=HKF_procedure    expected_value=${UE4_startingPRB}
    Get PRB Value And Assert If Is Correct    packet_filter=${UE6_HKF_1ST}    prb=secondHopPRB    alias=tcpdump_subcase
    ...                                       subcase=HKF_procedure    expected_value=${UE4_secondHopPRB}
    Stop Pcaps Collection For Test Subcase

    Start Pcaps Collection For Test Subcase    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    subcase_name=HKF_2_procedure
    Reestablish Ues
    Attach Additional Sa Ue

    ${UE53_HKF}   Create RrcReconfiguration Filter With New Prb Values After Hkf And ResourceToAddModList    startingPRB=${UE31_startingPRB}
    ...                                                                                                      secondHopPRB=${UE31_secondHopPRB}
    ${UE5_HKF}    Create UEContextModificationRequired Filter With New Prb Values After Hkf And ResourceToAddModList
    ...           startingPRB=${UE1_startingPRB}    secondHopPRB=${UE1_secondHopPRB}
    ${UE35_HKF}   Create RrcReconfiguration Filter With New Prb Values After Hkf And ResourceToAddModList    startingPRB=${UE32_startingPRB}
    ...                                                                                                      secondHopPRB=${UE32_secondHopPRB}
    ${UE6_HKF_2ED}    Create UEContextModificationRequired Filter With New Prb Values After Hkf And ResourceToAddModList
    ...               startingPRB=${UE2_startingPRB}    secondHopPRB=${UE2_secondHopPRB}
    Wait For HKF Period

    Verify Tcp Messages For Subcase    packet_filter=${UE53_HKF}    subcase_name=HKF_2_procedure
    Verify Tcp Messages For Subcase    packet_filter=${UE5_HKF}    subcase_name=HKF_2_procedure
    Verify Tcp Messages For Subcase    packet_filter=${UE35_HKF}    subcase_name=HKF_2_procedure
    Verify Tcp Messages For Subcase    packet_filter=${UE6_HKF_2ED}    subcase_name=HKF_2_procedure

    Stop Pcaps Collection For Test Subcase

    Start Pcaps Collection For Test Subcase    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    subcase_name=HKF_3_procedure
    Deregister Ues
    Wait For HKF Period

    ${UE34_HKF}   Create RrcReconfiguration Filter With New Prb Values After Hkf And ResourceToAddModList    startingPRB=${UE52_startingPRB}
    ...                                                                                                      secondHopPRB=${UE52_secondHopPRB}
    ${UE31_HKF}   Create RrcReconfiguration Filter With New Prb Values After Hkf And ResourceToAddModList    startingPRB=${UE51_startingPRB}
    ...                                                                                                      secondHopPRB=${UE51_secondHopPRB}
    ${UE33_HKF}   Create RrcReconfiguration Filter With New Prb Values After Hkf And ResourceToAddModList    startingPRB=${UE7_startingPRB}
    ...                                                                                                      secondHopPRB=${UE7_secondHopPRB}

    Verify Tcp Messages For Subcase    packet_filter=${UE34_HKF}    subcase_name=HKF_3_procedure
    Verify Tcp Messages For Subcase    packet_filter=${UE31_HKF}    subcase_name=HKF_3_procedure    number_of_messages=2
    Verify Tcp Messages For Subcase    packet_filter=${UE33_HKF}    subcase_name=HKF_3_procedure    number_of_messages=2

    Stop Pcaps Collection For Test Subcase

    Wait For Next Full PM Interval
    ${pm_counter_file}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55124C00523    6    RRC_RECONF_SENT_PCSI_RES_REALL
    ...    M55124C00524    6    RRC_RECONF_SUCC_PCSI_RES_REALL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE}

    Verify Any Counters In File
    ...    M55124C00523    3    RRC_RECONF_SENT_PCSI_RES_REALL
    ...    M55124C00524    3    RRC_RECONF_SUCC_PCSI_RES_REALL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
    ...    file_path=${PM_COUNTER_FILE}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                           check_errors_or_warnings=both

*** Keywords ***
Change RD Parameters In Swconfig File Related To CB006877 Feature
    @{6877_rd_params}=    Create List
    ...    0x5901A6=1     # rdPCsiPoolHkfPeriod_min
    ...    0x5901A7=4     # rdHkfMinPCsiResPerSlot
    ...    0x5901A8=20    # rdHkfMinPCsiRepPeriod
    ...    0x59023E=50    # rdHkfPCsiPoolMaxRCUsFactorFDD
    Backup And Modify Swconfig File    parameters_list=${6877_rd_params}

Send A5 Event To Trigger Ho
    [Arguments]    ${ue_id}=1   ${srsrq_nr}=31    ${srsrp_nr}=31    ${ssinr_nr}=31    ${phycell_id}=2
    ...            ${nrsrq_nr}=122    ${nrsrp_nr}=122    ${nsinr_nr}=122    ${timeout}=30    ${carrier_freq}=518910
    ...            ${pass_regexp}=message c1

    Send Ue Measurement Nr Event A5 With Aligned Meas Id    ue_id=${ue_id}    carrier_freq=${carrier_freq}
    ...                              pass_regexp=${pass_regexp}    srsrq_nr=${srsrq_nr}    srsrp_nr=${srsrp_nr}
    ...                              ssinr_nr=${ssinr_nr}    phycell_id=${phycell_id}    nrsrq_nr=${nrsrq_nr}
    ...                              nrsrp_nr=${nrsrp_nr}    nsinr_nr=${nsinr_nr}    timeout=${timeout}

Send A2 event for HO
    [Arguments]    ${ue_id}=1    ${pcell_id}=1    ${srsrp}=31    ${srsrq}=31    ${ssinr}=1     ${cell_type}=SA
    ...            ${pass_regexp}=.*

    Send Ue Measurement Nr Event A2 Handover With Aligned Meas Id
    ...    ue_id=${ue_id}
    ...    pcell_id=${pcell_id}
    ...    srsrp_nr=${srsrp}
    ...    srsrq_nr=${srsrq}
    ...    ssinr_nr=${ssinr}
    ...    pass_regexp=${pass_regexp}
    ...    cell_type=${cell_type}

    Sleep    3s    reason=ensure A2 event for HO is sent

Send A2 event for HO For NSA
    [Arguments]    ${ue_id}=1    ${pcell_id}=1    ${srsrp}=31    ${srsrq}=31    ${ssinr}=1     ${cell_type}=NSA
    ...            ${pass_regexp}=.*

    Send Ue Measurement Nr Event A2 Handover With Aligned Meas Id
    ...    ue_id=${ue_id}
    ...    pcell_id=${pcell_id}
    ...    srsrp_nr=${srsrp}
    ...    srsrq_nr=${srsrq}
    ...    ssinr_nr=${ssinr}
    ...    pass_regexp=${pass_regexp}
    ...    cell_type=${cell_type}

    Sleep    3s    reason=ensure A2 event for HO is sent

Attach Sa and Nsa Ues
    Attach Multiple Ues And Establish Pdu Sessions With Prb Defining    first_ue=31    last_ue=36

    Attach Multiple Ues And Establish Pdu Sessions With Prb Defining    first_ue=51    last_ue=54

    Attach Multiple Ues And Start Gnb Addition With Prb Defining    first_ue=1    last_ue=6    target_cells=3

    Attach Multiple Ues And Start Gnb Addition With Prb Defining    first_ue=7    last_ue=9    target_cells=5

Perform B2 Case Handovers
    Log To Console    Handover SA UE-34 to cell-5
    Send A2 event for HO    ue_id=34    pcell_id=3
    Send A5 Event To Trigger Ho    ue_id=34    phycell_id=54    carrier_freq=518910
    ...                            pass_regexp=Intra-eNB handover from EXT_ENB-2.3 to EXT_ENB-2.5 performed

    Log To Console    Handover NSA UE-4 to cell-5
    Send A2 event for HO For NSA   ue_id=4    pcell_id=3     cell_type=NSA
    Send A5 Event To Trigger Ho    ue_id=4    phycell_id=54    carrier_freq=518910
    ...                            pass_regexp=Proxy \\(eNB 2 cell 5\\) reported successful RA

    Log To Console    Handover SA UE-53 to cell-3
    Send A2 Event For HO    ue_id=53    pcell_id=5
    Send A5 Event To Trigger Ho    ue_id=53    phycell_id=52    carrier_freq=426490
    ...                            pass_regexp=Intra-eNB handover from EXT_ENB-2.5 to EXT_ENB-2.3 performed

    Log To Console    Handover NSA UE-9 to cell-3
    Send A2 event for HO For NSA    ue_id=9    pcell_id=5     cell_type=NSA
    Send A5 Event To Trigger Ho    ue_id=9    phycell_id=52    carrier_freq=426490
    ...                            pass_regexp=Proxy \\(eNB 2 cell 3\\) reported successful RA

Reestablish Ues
    Log To Console    Re-establish SA UEs 31-33 to cell-5
    FOR    ${index}    IN RANGE    31    34
        Initiate Ue Rrc Reestablishment    ue_id=${index}    gnb=2    cell=5    cause=otherFailure    retries=1
    END

    Log To Console    Detach NSA UEs 1-3
    FOR    ${index}    IN RANGE    1   4
        Detach Ue    ue_id=${index}
    END

Attach Additional Sa Ue
    Log To Console    Attach SA UEs 17 to cell-1
    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=17
    Establish Pdu Session With Traffic    ue_id=17    pdu_id=1    gw_id=17

Deregister Ues
    Log To Console    Deregister SA UEs 51-52
    FOR    ${index}    IN RANGE    51    53
        Deregister Ue Without Confirmation    ue_id=${index}
    END

    Log To Console    Detach NSA UEs 7-8
    FOR    ${index}    IN RANGE    7   9
        Detach Ue    ue_id=${index}
    END

    Deregister Ue Without Confirmation    ue_id=54
