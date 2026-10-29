*** Settings ***
Force Tags    CLOUD_5G_I_BOO_AP_LOO    SBTS00    RAN_5G_TDD    RAN_5G    CONFIGURED    CRT    PY310    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Maciej Katra
...              :contact: Maciej.Katra@nokia.com
...              Description of testsuite: This testsuite covers 7877-CB and checks behaviours of gNB when
...                                        NIDD parameter "actHoOptimizationCA" is set to true

Resource    ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource    ./resources/CB007877_Keywords.robot
Resource    ./resources/CB007877_variables.robot
Library     ta5g_tshark

Suite Setup    Run Keywords    Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Get Iphy Xml File
...            AND             Setup Test Line
...                                iphy_xml_filepath=${CURDIR}/config/iphy.xml
...                                scfc_filename=scfc.xml
...                                perform_full_commissioning=${FULL_COMMISSIONING}
...                                perform_testline_reset=${RESET_TL}
...                                output_dirpath=${OUTPUT_DIR}/testline_prep
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
...            AND             Start Xn And Ng Interfaces For Second Gnb
...            AND             Reach OnAir    lua_cfg=${CURDIR}/../../../resources/airphone/egate_CA_4FDD_2TDD.lua
...            AND             Perform Parameter Commissioning    parameter=actHoOptimizationCa    value=true
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Suite Teardown    Run Keywords    Perform Parameter Commissioning    parameter=actHoOptimizationCa    value=false
...               AND             Run Keyword If    ${RESTORE_DEFAULT_CONFIG}
...                               Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND             Run Keyword If    ${RESTORE_DEFAULT_CONFIG}
...                               Update Iphy Configuration And Modify Swconfig
...                                   iphy_xml_filepath=${OUTPUT_DIR}/iphy.xml
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords    Add Scout External Execution ID To Reporting Portal
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB007877_CB_2_B6_SCell_Addition_Based_On_Mobility_Measurements_Incoming_HO_Above_Threshold_UL_OL_Prev_HO_enabled
    [Documentation]
    ...    This testcase test situation when A1Measurement for P-Cell switch is active, and we do optimized
    ...    handover to that P-Cell. After HO, immediate S-Cell addition should happen, and A1 measurement shall
    ...    be configured for this S-Cell. After sending this particular measurement, Handover from P-Cell to
    ...    target S-Cell shall be performed.
    ...    NIDD explaination for TC:
    ...    a5Threshold2SsbRsrp ( In NRHOIF object of first cell we connect to ) should be set to be lower than
    ...    a1ThresholdSCellAddSsbRsrpTDD, and nrsrp value sent in A5 event should be greater than latter param.
    ...    SRSP value in A1 event for P-Cell switch shall be greater than NIDD param a1ThresholdPCellSwitch
    ...    in NRHOIF object of S-Cell.
    ...    Also verifies  P-Cell switch to S-Cell  if there is another CA UE with this S-Cell active.
    ...    OPTIMIZATION : Contains TC :
    ...    CB007877_CB_1_B6_SCell_Addition_Based_On_Mobility_Measurements_Incoming_HO_Above_Threshold
    ...    CB007877_HB_12_B6_SCell_Addition_Based_On_Mobility_Measurements_Incoming_HO_Above_Threshold

    Wait Until Keyword Succeeds    2x    100ms    Attach UE    ue_id=${UE2_CELL6}
    Establish PDU Session    ue_id=${UE2_CELL6}    pdu_id=1    gw_id=3
    Send A2 Event For A5 Configuration    ue_id=${UE2_CELL6}    pcell_id=6
    Send A5 Event For Inter-Frequency HO    ue_id=${UE2_CELL6}    neigh_phycellid=50    nrsrp=122    nrsrq=122    nsinr=122    carrier_freq=127450
    Send A1 Event For Pcell Switch    ue_id=${UE2_CELL6}    scell_id=5
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_SCELLADD}    number_of_messages=2
