*** Settings ***
Documentation
...    I. Cell configuration
...
...    No      PCI     LCR     chBW       Band     Technology    Mplane Only    nrarfcn           RMOD RF port
...    --------------------------------------------------------------------------------------------------------
...    1        51      1        60        n41        TDD           NO          518598            FSP1 RF1, RF7
...    2        52      2        90        n41        TDD           NO          509058            FSP1 RF1, RF7
...    3        53      3       100        n77        TDD           NO          659182            FSP1 RF2, RF8
...    4        54      4        90        n77        TDD           NO          652290            FSP1 RF2, RF8
...    5        55      5       100        n41        TDD           YES         528000            FSP1 RF3, RF8
...    6        56      6        90        n41        TDD           YES         509058            FSP1 RF3, RF8
...    7        57      7     20/20        n25        FDD           NO          388440/372660     FSP2 RF1
...    8        58      8     15/15        n25        FDD           NO          393240/380100     FSP2 RF2
...    9        59      9     20/20        n66        FDD           YES         431000/349000     FSP2 RF3
...    10       60      10      5/5        n71        FDD           NO          126900/136100     FSP2 RF7
...    11       61      11    10/10        n66        FDD           NO          431000/349000     FSP2 RF8
...    12       62      12    20/20        n71        FDD           YES         126400/135600     FSP2 RF9
...
...
...    II. cells CA relations:
...
...    pcell/scell |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  |  10 |  11 |  12  |              CA type
...    -------------------------------------------------------------------------------------------------------------------
...    7           |  x  |     |  x  |  x  |  x  |     | --- |     |     |  x  |     |      |      FDD+TDD+TDD+TDD+TDD+FDD


Force Tags    CLOUD_5G_I_LOO_AP_LOOO    SBTS00    RAN_5G_TDD    RAN_5G    CONFIGURED    CRT    PY311   NoResUsage    RF50

Resource     ./resources/CB013152_Keywords.robot
Resource     ./resources/CB013152_Variables.robot
Library      ./resources/CB013152_Keywords.py
Library      ta5g_pm_counters
Library      ta5g_ue_measurements
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_testline_management
Library      ta5g_delta
Library      ta5g_throughput
Library      ta5g_cell_operations

Suite Setup    Run Keywords    Update Tshark Plugin Lua File
...            AND             Setup Test Line
...                                iphy_xml_filepath=${CURDIR}/config/iphy_CB013152_UL_2TX_switching.xml
...                                scfc_filename=SCFC_CB013152_UL_2TX_switching.xml
...                                perform_full_commissioning=${FULL_COMMISSIONING}
...                                perform_testline_reset=${RESET_TL}
...                                output_dirpath=${OUTPUT_DIR}/testline_prep
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB013152_UL_2TX_switching.lua
...                                           mplane_cells=@{mplane_cells}
...            AND             Set Counter Collecting Interval To Five Minutes
...            AND             Wait For Next Full Pm Interval
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{mplane_cells}                     5      6      9     12
@{pCSI_allocation_expected_list}    3    101
@{SR_allocation_expected_list}      0    105


*** Test Cases ***
[1]CB013152_IWK6_01_CB013152_And_CB012149-B_Deactivation_Loki
    [Documentation]    [1]CB013152_IWK6_01_CB013152_And_CB012149-B_Deactivation_Loki

    [Setup]   Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach UE With Traffic And Send A1 Measurment   ue_id=${UE1_CELL7}    cell_id=7
    ...                                             prefix_name=UE_${UE1_CELL7}_without_UL_TX_switching

    Verify SCell Addition Messages For 6CC For FDD PCell    ue_in_order=1
    Verify UL_1_TxSwitching Is Not Set On FDD PCell and TDD Scell
    Assert pCI Allocation    ue_id=${UE1_CELL7}    expected_pCSI_values_list=@{pCSI_allocation_expected_list}   nrofPRBs=2
    Assert Scheduling Request Allocation    ue_id=${UE1_CELL7}     expected_sr_values_list=@{SR_allocation_expected_list}
    Verify UL TX Counters Are Not Pegged


    Find Scfc And Send Delta Commissioning    scfc_filename=delta_CB013152_UL_TX_switch_on.json
    Check Radios Availability
    Wait For All Cells To Be Enabled    timeout=180
    Wait For Mib Reception    cell_list=7    timeout=180
    wait For Sib1 Reception    cell_list=7    timeout=180

    Attach UE With Traffic And Send A1 Measurment  ue_id=${UE2_CELL7}    cell_id=7
    ...                                            prefix_name=UE_${UE2_CELL7}_with_UL_TX_switching

    Verify SCell Addition Messages For 6CC For FDD PCell    ue_in_order=2
    Verify UL_1_TxSwitching On FDD PCell and TDD Scell
    Assert pCI Allocation    ue_id=${UE2_CELL7}    expected_pCSI_values_list=@{pCSI_allocation_expected_list}   nrofPRBs=2
    Assert Scheduling Request Allocation    ue_id=${UE2_CELL7}     expected_sr_values_list=@{SR_allocation_expected_list}
    Verify Counters for UL TX

    Roll Delta Back    initial_scf_filename=${CURDIR}/config/default/SCFC_CB013152_UL_2TX_switching.xml
    ...                delta_scf_filename=delta_CB013152_UL_TX_switch_on.json
    Check Radios Availability
    Wait For All Cells To Be Enabled    timeout=180
    Wait For Mib Reception    cell_list=7    timeout=180
    wait For Sib1 Reception    cell_list=7    timeout=180

    Attach UE With Traffic And Send A1 Measurment  ue_id=${UE3_CELL7}    cell_id=7
    ...                                            prefix_name=UE_${UE3_CELL7}_without_UL_TX_switching

    Verify SCell Addition Messages For 6CC For FDD PCell    ue_in_order=3
    Verify UL_1_TxSwitching On FDD PCell and TDD Scell
    Assert pCI Allocation    ue_id=${UE3_CELL7}    expected_pCSI_values_list=@{pCSI_allocation_expected_list}   nrofPRBs=2
    Assert Scheduling Request Allocation    ue_id=${UE3_CELL7}     expected_sr_values_list=@{SR_allocation_expected_list}


    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=${UE1_CELL7}
    ...           AND             Deregister Ue Without Confirmation    ue_id=${UE2_CELL7}
    ...           AND             Deregister Ue Without Confirmation    ue_id=${UE3_CELL7}
    ...           AND             Roll Delta Back
    ...                              initial_scf_filename=${CURDIR}/config/default/SCFC_CB013152_UL_2TX_switching.xml
    ...                              delta_scf_filename=delta_CB013152_UL_2TX_switch_on.json
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


[1]CB013152_IWK5_Interworking_With_FDD_TDD_FR1_UL_2TX_Switching_ALT5
    [Documentation]    CB013152_IWK5_Interworking_With_FDD_TDD_FR1_UL_2TX_Switching_ALT5

    [Setup]   Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach UE With Traffic And Send A1 Measurment   ue_id=${UE4_CELL7}    cell_id=7
    ...                                             prefix_name=UE_${UE4_CELL7}_without_UL_2TX_switching

    Verify SCell Addition Messages For 6CC For FDD PCell    ue_in_order=1
    Verify UL_2_TxSwitching Is Not Set On FDD PCell and TDD Scell
    Assert pCI Allocation    ue_id=${UE4_CELL7}    expected_pCSI_values_list=@{pCSI_allocation_expected_list}   nrofPRBs=2
    Assert Scheduling Request Allocation    ue_id=${UE4_CELL7}     expected_sr_values_list=@{SR_allocation_expected_list}
    Verify UL 2TX Counters Are Not Pegged


    Find Scfc And Send Delta Commissioning    scfc_filename=delta_CB013152_UL_2TX_switch_on.json
    Check Radios Availability
    Wait For All Cells To Be Enabled    timeout=180
    Wait For Mib Reception    cell_list=7    timeout=180
    wait For Sib1 Reception    cell_list=7    timeout=180

    Attach UE With Traffic And Send A1 Measurment  ue_id=${UE5_CELL7}    cell_id=7
    ...                                            prefix_name=UE_${UE5_CELL7}_with_UL_2TX_switching

    Verify SCell Addition Messages For 6CC For FDD PCell    ue_in_order=2
    Verify UL_2_TxSwitching On FDD PCell and TDD Scell
    Assert pCI Allocation    ue_id=${UE5_CELL7}    expected_pCSI_values_list=@{pCSI_allocation_expected_list}   nrofPRBs=2
    Assert Scheduling Request Allocation    ue_id=${UE5_CELL7}     expected_sr_values_list=@{SR_allocation_expected_list}
    Verify Counters for UL 2TX

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=${UE1_CELL7}
    ...           AND             Deregister Ue Without Confirmation    ue_id=${UE2_CELL7}
    ...           AND             Deregister Ue Without Confirmation    ue_id=${UE3_CELL7}
    ...           AND             Deregister Ue Without Confirmation    ue_id=${UE4_CELL7}
    ...           AND             Deregister Ue Without Confirmation    ue_id=${UE5_CELL7}
    ...           AND             Roll Delta Back
    ...                              initial_scf_filename=${CURDIR}/config/default/SCFC_CB013152_UL_2TX_switching.xml
    ...                              delta_scf_filename=delta_CB013152_UL_2TX_switch_on.json
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


