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
CB006877_SR_A_ET_IWK7_01_02_HKF_trigger_Multi_CA_UEs_CSI_resources_reconfigure
    [Documentation]    This test case main purpose is to verify values of the startingPRB and secondHopPRB
    ...                before and after Housekeeping Function (HKF). When some of the UEs are deregistered,
    ...                then UEs, which are active, should receive PRB resources from the deallocated UEs.
    ...                Additionally in the test case, there is performed handover and carrier aggreggation, which
    ...                also affects change of the PRB resources for the active UEs.
    ...                In this configuration startingPRB of UE51 after HKF should be equal 3
    ...                (same value as startingPRB of UE34 before HKF).
    ...                StartingPRB of UE34 after HKF should be equal 47 (same value as startingPRB of UE33 before HKF).
    ...                Requirements: 5G_CP_ARC_ALG_13177, CB_FIM_43182, CB_FIM_43835, CB_FIM_44137

    [Setup]    Run Keywords    Setup Test Line
    ...                            iphy_xml_filepath=${CURDIR}/config/iphy.xml
    ...                            scfc_filename=SCFC_CB006877_IWK7.xml
    ...                            perform_full_commissioning=${FULL_COMMISSIONING}
    ...                            perform_testline_reset=${RESET_TL}
    ...                            output_dirpath=${OUTPUT_DIR}/testline_prep
    ...        AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Start Xn And Ng Interfaces For Second Gnb
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB006877_CA_4FDD_2TDD.lua

    Attach Multiple Ues And Establish Pdu Sessions With Prb Defining    first_ue=31    last_ue=36
    ${UE31_startingPRB}    Get Prb Value Of Given Ue Sa    ue_id=31    prb=startingPRB
    ${UE31_secondHopPRB}   Get Prb Value Of Given Ue Sa    ue_id=31    prb=secondHopPRB
    ${UE31_ue_f1ap_id}     Get F1ap Ue Sa Id Value         ue_id=31
    ${UE32_startingPRB}    Get Prb Value Of Given Ue Sa    ue_id=32    prb=startingPRB
    ${UE32_secondHopPRB}   Get Prb Value Of Given Ue Sa    ue_id=32    prb=secondHopPRB
    ${UE32_ue_f1ap_id}     Get F1ap Ue Sa Id Value         ue_id=32
    ${UE35_ue_f1ap_id}     Get F1ap Ue Sa Id Value         ue_id=35
    ${UE35_startingPRB}    Get Prb Value Of Given Ue Sa    ue_id=35    prb=startingPRB
    ${UE35_secondHopPRB}   Get Prb Value Of Given Ue Sa    ue_id=35    prb=secondHopPRB

    Attach Multiple Ues And Establish Pdu Sessions With Prb Defining    first_ue=51    last_ue=52
    ${UE51_startingPRB}    Get Prb Value Of Given Ue Sa    ue_id=51    prb=startingPRB
    ${UE51_secondHopPRB}   Get Prb Value Of Given Ue Sa    ue_id=51    prb=secondHopPRB
    ${UE51_ue_f1ap_id}     Get F1ap Ue Sa Id Value         ue_id=51

    Log To Console    Setup CA for UEs 31-34 and UE36
    FOR    ${index}    IN RANGE    31    35
        Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id
        ...    ue_id=${index}    pcell_id=3    scellTechnology=FDD    srsrp=127    srsrq=127    ssinr=127
    END
    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id
    ...    ue_id=36    pcell_id=3    scellTechnology=FDD    srsrp=127    srsrq=127    ssinr=127

    Log To Console    Deregister SA UE 36
    Deregister Ue Without Confirmation    ue_id=36

    Log To Console    Handover SA UE-51 from cell 5 to cell 3 and setup CA for UE 51
    Send A2 Event For Handover    ue_id=51    pcell_id=5
    Send A5 Event To Trigger Handover    ue_id=51    phycell_id=52    carrier_freq=426970
    ...                                  pass_regexp=Intra-eNB handover from EXT_ENB-2.5 to EXT_ENB-2.3 performed
    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id
    ...    ue_id=51    pcell_id=3    scellTechnology=FDD    srsrp=127    srsrq=127    ssinr=127

    Start Pcaps Collection For Test Subcase    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    subcase_name=HKF_procedure
    Log To Console    Deregister SA UEs 31-33
    FOR    ${index}    IN RANGE    31    34
        Deregister Ue Without Confirmation    ue_id=${index}
    END
    Wait For HKF Period

    ${UE51_HKF}    Create RrcReconfiguration Filter With New Prb Values After Hkf And F1ap Id    ue_f1ap_id=${UE51_ue_f1ap_id}
    ...                                                                                          startingPRB=${UE32_startingPRB}
    ...                                                                                          secondHopPRB=${UE32_secondHopPRB}
    ${UE35_HKF}    Create RrcReconfiguration Filter With New Prb Values After Hkf And F1ap Id    ue_f1ap_id=${UE35_ue_f1ap_id}
    ...                                                                                          startingPRB=${UE31_startingPRB}
    ...                                                                                          secondHopPRB=${UE31_secondHopPRB}

    Verify Tcp Messages For Subcase    packet_filter=${UE51_HKF}    subcase_name=HKF_procedure
    Verify Tcp Messages For Subcase    packet_filter=${UE35_HKF}    subcase_name=HKF_procedure

    Get PRB Value And Assert If Is Correct    packet_filter=${UE51_HKF}    prb=startingPRB    alias=tcpdump_subcase
    ...                                       subcase=HKF_procedure    expected_value=${UE32_startingPRB}
    Get PRB Value And Assert If Is Correct    packet_filter=${UE51_HKF}    prb=secondHopPRB    alias=tcpdump_subcase
    ...                                       subcase=HKF_procedure    expected_value=${UE32_secondHopPRB}
    Get PRB Value And Assert If Is Correct    packet_filter=${UE35_HKF}    prb=startingPRB    alias=tcpdump_subcase
    ...                                       subcase=HKF_procedure    expected_value=${UE31_startingPRB}
    Get PRB Value And Assert If Is Correct    packet_filter=${UE35_HKF}    prb=secondHopPRB    alias=tcpdump_subcase
    ...                                       subcase=HKF_procedure    expected_value=${UE31_secondHopPRB}
    Stop Pcaps Collection For Test Subcase

    Log To Console    Waiting for PM counters indicating successful HKF:
    ...               RRC_RECONF_SUCC_PCSI_RES_REALL and RRC_RECONF_SENT_PCSI_RES_REALL
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55124C00523  +2  RRC_RECONF_SENT_PCSI_RES_REALL
    ...    M55124C00524  +2  RRC_RECONF_SUCC_PCSI_RES_REALL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Add Scout External Execution ID To Reporting Portal

    [Teardown]    Run Keywords    Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                           check_errors_or_warnings=both

CB006877_SR_B_ET_IWK9_01_01_HKF_Interworking_With_CNI_78446_Dedicate_Part_In_Initial_BWP
    [Documentation]    This test case verify dedicate bwp in initial bwp interworking with CB006877
    ...                After attach UEs 31-36 and releasing UEs 31-35 HKF trigger UE36 1 CSI resources reconfigure
    ...                Bwp id=1
    ...                Test case covers requirement: CB_FIM_43188

    [Setup]    Run Keywords    Setup Test Line
    ...                            iphy_xml_filepath=${CURDIR}/config/iphy_6877_IWK9.xml
    ...                            scfc_filename=SCFC_CB006877_IWK9.xml
    ...                            perform_full_commissioning=${FULL_COMMISSIONING}
    ...                            perform_testline_reset=${RESET_TL}
    ...                            output_dirpath=${OUTPUT_DIR}/testline_prep
    ...        AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Start Xn And Ng Interfaces For Second Gnb
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CA_4FDD_2TDD_small_BWP.lua

    Attach Multiple Ues    first_ue_id=31    last_ue_id=36
    Establish Pdu Session For Multiple Ues    first_ue_id=31    last_ue_id=36
    Deregister Multiple Ues    first_ue_id=31    last_ue_id=35

    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATION_BWP_1}    number_of_messages=0
    Verify Tcpdump Log    packet_filter=${RRC_SETUP} && nr-rrc.bwp_Id == 0 && nr-rrc.bwp_Id != 1    number_of_messages=6
    Sleep    60s    reason=HKF period
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATION_BWP_1}    number_of_messages=1

    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55124C00523    1    RRC_RECONF_SENT_PCSI_RES_REALL
    ...    M55124C00524    1    RRC_RECONF_SUCC_PCSI_RES_REALL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    Multi Attach And HOs

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                           check_errors_or_warnings=both

CB006877_SR_B_ET_B1_01_01_Verify_feature_activated_and_deactivated_for_multi_dedicated_BWP
    [Documentation]    This test case purpose is to verify longPucchNumDynPuschPrb and longPucchStartDynPuschPrb value
    ...                with two dedicated BWP configured.
    ...                longPucchStartDynPuschPrb value finding based on equation(from CFAM CB006877):
    ...                longPucchStartDynPuschPrb of Dedicated BWP[0] = #PRB(HARQ AN) + #PRB(SR)
    ...                + reducedNbrOfPrbsUlLowEdge longPucchStartDynPuschPrb: 6 = (numHarqF1PrbsPerSlot:2 +
    ...                numHarqF3PrbsPerSlot:2) + numSrPrbsPerSlot:2 + reducedNbrOfPrbsUlLowEdge:0
    ...                Requirements:5G_CP_ARC_ALG_12871, CB_FIM_43179, CB_FIM_43192

    [Setup]    Run Keywords    Setup Test Line
    ...                            iphy_xml_filepath=${CURDIR}/config/iphy_B1.xml
    ...                            scfc_filename=SCFC_CB006877_B1.xml
    ...                            perform_full_commissioning=${FULL_COMMISSIONING}
    ...                            perform_testline_reset=${RESET_TL}
    ...                            output_dirpath=${OUTPUT_DIR}/testline_prep
    ...        AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Start Xn And Ng Interfaces For Second Gnb

    Start Pcaps Collection For Test Subcase    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    subcase_name=feature_flag_on
    Reach Onair    lua_cfg=${CURDIR}/config/egate_CA_4FDD_2TDD_small_BWP.lua    timeout=250
    ${find_long_prb_feature_flag_on}=    Find Long Pucch Start Dyn Pusch Prb    file_name=feature_flag_on_gnb_F1_E1_RRC    expected_number=6
    ...                                  feature_flag_activated=True
    Should Be True    ${find_long_prb_feature_flag_on} == True
    Stop Pcaps Collection For Test Subcase

    Start Pcaps Collection For Test Subcase     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}   subcase_name=feature_flag_off
    Log To Console    Change actDynUlResAlloc to false to trigger PsCell_CellSetupReq change for NRCELL-3.
    Perform Parameter Commissioning      dist_name=MRBTS-1/NRBTS-1/NRCELL-3    parameter=actDynUlResAlloc    value=false
    ${find_long_prb_feature_flag_off_dedicated}=    Find Long Pucch Start Dyn Pusch Prb
    ...    file_name=feature_flag_off_gnb_F1_E1_RRC    expected_number=0    bwp_type=dedicated    feature_flag_activated=False
    Should Be True    ${find_long_prb_feature_flag_off_dedicated} == True
    ${find_long_prb_feature_flag_off_initial}=    Find Long Pucch Start Dyn Pusch Prb
    ...    file_name=feature_flag_off_gnb_F1_E1_RRC    expected_number=0    bwp_type=initial    feature_flag_activated=False
    Should Be True    ${find_long_prb_feature_flag_off_initial} == True
    Stop Pcaps Collection For Test Subcase

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                           check_errors_or_warnings=both

*** Keywords ***
Establish Pdu Session For Multiple Ues
    [Arguments]    ${first_ue_id}    ${last_ue_id}
    FOR    ${index}    IN RANGE    ${first_ue_id}    ${last_ue_id}+1
        Establish Pdu Session With Traffic    ue_id=${index}    pdu_id=1    gw_id=${index}
    END

Deregister Multiple Ues
    [Arguments]    ${first_ue_id}    ${last_ue_id}
    FOR    ${index}    IN RANGE    ${first_ue_id}    ${last_ue_id}+1
       Deregister Ue Without Confirmation    ue_id=${index}
    END

Change RD Parameters In Swconfig File Related To CB006877 Feature
    @{6877_rd_params}=    Create List
    ...    0x5901A6=1     # rdPCsiPoolHkfPeriod_min
    ...    0x5901A7=4     # rdHkfMinPCsiResPerSlot
    ...    0x5901A8=20    # rdHkfMinPCsiRepPeriod
    ...    0x59023E=50    # rdHkfPCsiPoolMaxRCUsFactorFDD
    Backup And Modify Swconfig File    parameters_list=${6877_rd_params}

Configure DRX and Meas Gap for NSA UE
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=ue_enb_param id=${ue_id} drx_config=off measurement_gap=gp0:10
    ...                          gap_trigger=gnb_triggered mgta=ms0dot50 gap_purpose=perUE
    Sleep    1s  reason=Waiting for param setup

Attach UE And Establish PDU Session And Send A5 Measurement For Inter Freq NSA HO
    [Arguments]    ${ue_id}    ${meas_id}=5    ${meas_idA2}=3    ${target_phycell_id}=51    ${nrsrp_nr}=120    ${nrsrq_nr}=120
    ...            ${pass_regexp_A2}=${SUCCESSFUL_HO_REGEX_A2_NSA}    ${pass_regexp_A5}=${SUCCESSFUL_HO_REGEX_A5_NSA}
    Attach NSA UE With Session And Send A2 Measurement    ue_id=${ue_id}  meas_id=${meas_idA2}  pass_regexp=${pass_regexp_A2}
    Send A5 Measurement And Attempt Handover    ue_id=${ue_id}  meas_id=${meas_id}  target_phycell_id=${target_phycell_id}
    ...                                         nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}  pass_regexp=${pass_regexp_A5}
Attach NSA UE With Session And Send A2 Measurement
    [Arguments]    ${ue_id}    ${meas_id}=1    ${pass_regexp}=${SUCCESSFUL_HO_REGEX_A2_NSA}
    Attach UE To Enb And Start Gnb Addition    ue_id=${ue_id}
    Send A2 Measurement    ue_id=${ue_id}  meas_id=${meas_id}  pass_regexp=${pass_regexp}

Attach UE To Enb And Start Gnb Addition
    [Arguments]    ${ue_id}
    Attach UE To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure    ue=${ue_id}  target_cells=1  target_gnb=2  bearer=2  dc_type=split_scg
    Sleep    2s  reason=Waiting for ue_dc_enb_start request to be processed

Send A2 Measurement
    [Arguments]    ${ue_id}    ${meas_id}=1    ${pass_regexp}=${SUCCESSFUL_HO_REGEX_A2_SA}
    Send Custom UE Measurement Nr    pass_regexp=${pass_regexp}
    ...                              id=${ue_id}  meas_id=${meas_id}  event=A2  srsrp_nr=11  srsrq_nr=11  srs_result=0:11:11:0
    Sleep    10s  reason=Waiting for A5 measurement report setup

Send A5 Measurement And Attempt Handover
    [Arguments]    ${ue_id}    ${meas_id}=5    ${target_phycell_id}=51    ${nrsrp_nr}=120    ${nrsrq_nr}=120
    ...            ${pass_regexp}=${SUCCESSFUL_HO_REGEX_A5_SA}
    Send Custom UE Measurement Nr    pass_regexp=${pass_regexp}  id=${ue_id}  meas_id=${meas_id}  index=0
    ...                              nrs_result=${nrsrp_nr}:${nrsrq_nr}:0  event=A5  srsrp_nr=31  srsrq_nr=31  srs_result=0:11:11:0
    ...                              phycell_id=${target_phycell_id}  nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}  rs_type=ssb

    Sleep    15s  reason=Waiting for handover request to be processed

Attach UE To Enb And Gnb
    [Arguments]    ${ue_id}=1    ${target_cells}=1
    Sleep  5s   reason=Problem with establishing x2ap link
    Attach Ue To Enb    ue_id=${ue_id}    optional_parameters=profile=1
    Start Gnb Addition Procedure    ue=${ue_id}    target_gnb=2    target_cells=${target_cells}    bearer=2    dc_type=split_scg
    ...                             pass_regexp=Proxy \\(eNB 2 cell ${target_cells}\\) reported successful RA


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

Multi Attach And HOs
    Attach Multiple Ues    first_ue_id=70    last_ue_id=99
    Establish Pdu Session For Multiple Ues    first_ue_id=71    last_ue_id=99

    Log To Console    Handover S23 SA UE-77 from cell-1 to cell-5
    Send A2 event for HO    ue_id=77    pcell_id=1
    Send A5 Event To Trigger Ho    ue_id=77    phycell_id=54    carrier_freq=518910
    ...                            pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.5 performed

    Log To Console    Deregister SA UEs 70-99
    FOR    ${index}    IN RANGE    70    100
        Deregister Ue Without Confirmation    ue_id=${index}
    END