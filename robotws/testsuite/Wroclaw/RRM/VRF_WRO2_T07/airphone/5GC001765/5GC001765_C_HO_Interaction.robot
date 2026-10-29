*** Settings ***
Force Tags    CLOUD_5G_I_BOO_AP_LOO    SBTS00    RAN_5G_TDD   RAN_5G    CONFIGURED    CRT    PY310    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Maciej Katra
...              :contact: Maciej.Katra@nokia.com

Resource     ./resources/Keywords.robot

Suite Setup    Run Keywords    Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Get Iphy Xml File
...            AND     	       Setup Test Line
...                            iphy_xml_filepath=${CURDIR}/config/iphy.xml
...                            scfc_filename=scfc.xml
...                            perform_full_commissioning=${FULL_COMMISSIONING}
...                            perform_testline_reset=${RESET_TL}
...                            output_dirpath=${OUTPUT_DIR}/testline_prep
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
...            AND             Start Xn And Ng Interfaces For Second Gnb
...            AND             Reach OnAir    lua_cfg=${CURDIR}/../../../resources/airphone/egate_CA_4FDD_2TDD.lua
...            AND             Set Counter Collecting Interval To Five Minutes
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Suite Teardown    Run Keywords    Run Keyword If    ${RESTORE_DEFAULT_CONFIG}
...                               Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND             Run Keyword If    ${RESTORE_DEFAULT_CONFIG}
...                               Update Iphy Configuration And Modify Swconfig
...                               iphy_xml_filepath=${OUTPUT_DIR}/iphy.xml
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    test_name=${TEST_NAME}
Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Variables ***
${RESET_TL} =                  ${FALSE}
${FULL_COMMISSIONING} =        ${TRUE}
${RESTORE_DEFAULT_CONFIG} =    ${TRUE}
${RRC_RELEASE_REJECT} =    ${RRC_RELEASE} || ${RRC_REJECT}
${B11_RRC_RCFG_A1_ORIGINATED} =    ${RRC_RECONFIGURATION} && ${EVENT_A2} && nr-rrc.physCellId == 54
${B11_RRC_RCFG_HO_ORIGINATED} =    nr-rrc.reportConfigToRemoveList == 3 && nr-rrc.reportConfigToAddModList == 3
...                                && nr-rrc.measIdToRemoveList == 4 && ${DRBS_TO_BE_MODIFIED_LIST}

*** Test Cases ***
5GC001765_AA_11_B1_Successful_A1_PCell_Triggered_SCell_Addition_Handover_Originated
    [Documentation]    Testsuite checks if:
    ...                gNB configures A1 measurement for Resource S-Cell addition if UE originates in P-Cell from Handover
    ...                procedure, and if we can successfully add S-Cell to that UE using A1 measurement.
    ...                OPTIMIZED TC :
    ...                5GC001765_A_3_B2_Configuration_Of_A1_Measurement_During_Handover_to_Pcell_SA
    ...                Test case covers requirement: 5G_RAN_USR_RRM_3745; 5G_RAN_USR_RRM_3749

    Wait Until Keyword Succeeds    2x  100ms    Attach UE    ue_id=60
    Establish Pdu Session With Traffic    ue_id=60    pdu_id=1    gw_id=3
    Send A2 Event For HO    ue_id=60    pcell_id=6
    Send A5 Event For Inter-Frequency HO    neigh_phycellid=50    ue_id=60    carrier_freq=127450
    Send A1 Event For S-Cell Addition    ue_id=60    pcell_id=1    scellTechnology=TDD
    Verify Tcpdump Log    packet_filter=${B11_RRC_RCFG_HO_ORIGINATED}
    Verify Tcpdump Log    packet_filter=${B11_RRC_RCFG_A1_ORIGINATED}
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATION_COMPLETE}    number_of_messages=6
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE_REJECT}    number_of_messages=0
