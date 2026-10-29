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

Force Tags    CLOUD_5G_I_BLLL_AP_LOO    PY310    NoResUsage    RF50

Resource     ./resources/CB006877_Keywords.robot
Resource     ./resources/CB006877_Variables.robot

Suite Setup    Run Keywords    Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Get Iphy Xml File
...            AND             Change RD Parameters in Swconfig File

Suite Teardown     Stop Default Processes And Gather Logs And Compress Logs    teardown_egate_instances=False

*** Variables ***
${BWP_ID_ZERO}=    nr-rrc.bwp_Id == 0 && nr-rrc.bwp_Id != 1 && nr-rrc.rrcSetup_element
${BWP_ID_ONE}=     SEPARATOR=
...                nr-rrc.rrcReconfiguration_element && nr-rrc.bwp_Id == 1 && nr-rrc.bwp_Id != 0 &&
...                nr-rrc.resourceToAddModList == 1

*** Test Cases ***
CB006877_SR_A_ET_IWK5_01_01_DL_and_UL_PRB_blanking_when_CB006877_is_enabled_with_single_BWP
    [Documentation]    This test case main purpose is to verify values of the startingPRB and secondHopPRB
    ...                before and after Housekeeping Function (HKF). When some of the UEs are detached/deregistered,
    ...                then UEs, which are active, should receive PRB resources from the deallocated UEs.
    ...                Requirement: CB_FIM_43186

    [Setup]    Run Keywords    Setup Test Line
    ...                                iphy_xml_filepath=${CURDIR}/config/iphy_ABIL.xml
    ...                                scfc_filename=SCFC_CB006877_IWK5_ABIL.xml
    ...                                perform_full_commissioning=${FULL_COMMISSIONING}
    ...                                perform_testline_reset=${RESET_TL}
    ...                                output_dirpath=${OUTPUT_DIR}/testline_prep
    ...        AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
    ...        AND             Start Xn And Ng Interfaces For Second Gnb
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB006877_CA_4FDD_2TDD.lua

    Attach Multiple Ues And Establish Pdu Sessions With Prb Defining    first_ue=11    last_ue=14
    ${UE11_startingPRB}    Get Prb Value Of Given Ue Sa    ue_id=11    prb=startingPRB
    ${UE11_secondHopPRB}   Get Prb Value Of Given Ue Sa    ue_id=11    prb=secondHopPRB
    ${UE11_ue_f1ap_id}     Get F1ap Ue Sa Id Value         ue_id=11
    ${UE14_startingPRB}    Get Prb Value Of Given Ue Sa    ue_id=14    prb=startingPRB
    ${UE14_secondHopPRB}   Get Prb Value Of Given Ue Sa    ue_id=14    prb=secondHopPRB
    ${UE14_ue_f1ap_id}     Get F1ap Ue Sa Id Value         ue_id=14

    Attach Multiple Ues And Start Gnb Addition With Prb Defining    first_ue=1    last_ue=4
    ${UE1_startingPRB}    Get Prb Value Of Given Ue Nsa    ue_id=1    prb=startingPRB
    ${UE1_secondHopPRB}   Get Prb Value Of Given Ue Nsa    ue_id=1    prb=secondHopPRB
    ${UE4_ue_f1ap_id}     Get F1ap Ue Nsa Id Value         ue_id=4

    Start Pcaps Collection For Test Subcase    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    subcase_name=HKF_procedure

    FOR    ${index}    IN RANGE    11    14
        Deregister Ue Without Confirmation    ue_id=${index}
    END

    FOR    ${index}    IN RANGE    1   4
        Detach Ue    ue_id=${index}
    END

    Wait For HKF Period

    ${UE14_HKF}    Create RrcReconfiguration Filter With New Prb Values After Hkf And F1ap Id    ue_f1ap_id=${UE14_ue_f1ap_id}
    ...                                                                                          startingPRB=${UE11_startingPRB}
    ...                                                                                          secondHopPRB=${UE11_secondHopPRB}
    ${UE_4_HKF}    Create UEContextModificationRequired Filter With New Prb Values After Hkf And F1ap Id   ue_f1ap_id=${UE4_ue_f1ap_id}
    ...                                                                                                    startingPRB=${UE1_startingPRB}
    ...                                                                                                    secondHopPRB=${UE1_secondHopPRB}
    Verify Tcp Messages For Subcase    packet_filter=${UE14_HKF} && nr-rrc.resourceToAddModList == 1    subcase_name=HKF_procedure
    Verify Tcp Messages For Subcase    packet_filter=${UE4_HKF} && nr-rrc.resourceToAddModList == 1 && nr-rrc.cellGroupId == 1
    ...                                subcase_name=HKF_procedure
    Get PRB Value And Assert If Is Correct    packet_filter=${UE14_HKF}    prb=startingPRB    alias=tcpdump_subcase
    ...                                       subcase=HKF_procedure    expected_value=${UE11_startingPRB}
    Get PRB Value And Assert If Is Correct    packet_filter=${UE14_HKF}    prb=secondHopPRB    alias=tcpdump_subcase
    ...                                       subcase=HKF_procedure    expected_value=${UE11_secondHopPRB}
    Get PRB Value And Assert If Is Correct    packet_filter=${UE4_HKF}    prb=startingPRB    alias=tcpdump_subcase
    ...                                       subcase=HKF_procedure    expected_value=${UE1_startingPRB}
    Get PRB Value And Assert If Is Correct    packet_filter=${UE4_HKF}    prb=secondHopPRB    alias=tcpdump_subcase
    ...                                       subcase=HKF_procedure    expected_value=${UE1_secondHopPRB}

    Stop Pcaps Collection For Test Subcase

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                           check_errors_or_warnings=both

CB006877_SR_A_ET_B14_01_01_HKF_interworking_with_CNI_94516_dedicated_part_in_initial_BWP
    [Documentation]    This test case is focusing on the dedicated part in initial BWP interwork with CB006877.
    ...                Also it is checking if Housekeeping function is triggered after deregistration of the UEs.
    ...                Requirements: 5G_RAN_USR_RRM_24139, CB_FIM_44985

    [Setup]    Run Keywords    Setup Test Line
    ...                            iphy_xml_filepath=${CURDIR}/config/iphy_B14_ABIL.xml
    ...                            scfc_filename=SCFC_CB006877_B14_ABIL.xml
    ...                            perform_full_commissioning=${FULL_COMMISSIONING}
    ...                            perform_testline_reset=${RESET_TL}
    ...                            output_dirpath=${OUTPUT_DIR}/testline_prep
    ...        AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/TestLogs
    ...        AND             Start Xn And Ng Interfaces For Second Gnb
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB006877_B14_CA_4FDD_2TDD.lua

    Attach Multiple Ues And Establish Pdu Sessions With Prb Defining    first_ue=11    last_ue=16

    ${UE11_startingPRB}    Get Prb Value Of Given Ue Sa    ue_id=11    prb=startingPRB
    ${UE11_secondHopPRB}    Get Prb Value Of Given Ue Sa    ue_id=11    prb=secondHopPRB
    ${UE16_ue_f1ap_id}    Get F1ap Ue Sa Id Value    ue_id=16

    Start Pcaps Collection For Test Subcase    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    subcase_name=HKF_procedure
    FOR    ${index}    IN RANGE    11    16
        Deregister Ue Without Confirmation    ue_id=${index}
    END
    Wait For HKF Period
    ${UE16_HKF}    Create RrcReconfiguration Filter With New Prb Values After Hkf And F1ap Id    ue_f1ap_id=${UE16_ue_f1ap_id}
    ...                                                                                          startingPRB=${UE11_startingPRB}
    ...                                                                                          secondHopPRB=${UE11_secondHopPRB}
    Verify Tcp Messages For Subcase    packet_filter=${UE16_HKF}    subcase_name=HKF_procedure
    Get PRB Value And Assert If Is Correct    packet_filter=${UE16_HKF}    prb=startingPRB    alias=tcpdump_subcase
    ...                                       subcase=HKF_procedure    expected_value=${UE11_startingPRB}
    Get PRB Value And Assert If Is Correct    packet_filter=${UE16_HKF}    prb=secondHopPRB    alias=tcpdump_subcase
    ...                                       subcase=HKF_procedure    expected_value=${UE11_secondHopPRB}
    Stop Pcaps Collection For Test Subcase

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                           check_errors_or_warnings=both