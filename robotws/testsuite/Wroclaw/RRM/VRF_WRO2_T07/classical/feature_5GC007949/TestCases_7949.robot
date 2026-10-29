*** Settings ***
Documentation
...   Testsuite for 5GC007949_D+E

Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008053/resources/test_specific_keywords.robot
Library        taf.ue
Library        taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_5GC007949/resources/test_specific_keywords.py
Library        testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2    WITH NAME    L1L2
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/pm_counters.py
Library        Collections
Library        DateTime


*** Variables ***
${pre_change_scf}=                                      None
@{cells_used_in_TC_A1}=                                 1   2   3
@{cells_used_in_TC_A2}=                                 1   2   3
@{cells_used_in_TC_A8}=                                 1   2   3
@{cells_used_in_TC_A11}=                                0   2   1
@{cells_used_in_TC_B1}=                                 1   2   3
@{cells_used_in_TC_B4}=                                 0   1   2   3   4
@{cells_used_in_TC_B5}=                                 1   2   3   5   6
@{secondary_cells_used_in_TC_B5}=                       3   5   6
@{cells_used_in_TC_B13}=                                1   2   3   7
@{cells_used_in_TC_D1}=                                 1   2   3
@{cells_used_in_TC_D2}=                                 1   2   3   4   0
@{cells_used_in_TC_E1}=                                 1   2   3
${wait_time_between_deact_and_dettach_inseconds}=       60
${tput_min}=                                            100Mbits/sec
${time_before_buffer_based_activation}=                 3
${wait_time_after_attach}=                              20
${pm_interval}=                                         5


*** Keywords ***
CB007949_A_01_Feature_activation_3CC_with_blind_SCell_addition_inter_L2RT_BF_same_frame_structure
    [Documentation]  This TC covers basic activation of 3CC feature and checks if after activation CA is established
    ...              Cell:               pCell   sCell1  sCell2
    ...              Bandwidths:         40MHz   40MHz   60MHz
    ...              Bands:              N41     N41     n77
    ...              Cells MO:           1       2       3
    ...              Cells PhyCellID:    101     102     103
    ...              Channels:           1-4     1-4     5-8
    ${pre_change_scf}           backup current scf
    ${cells_used_in_TC}         Set Variable    ${cells_used_in_TC_A1}
    check preconditions a_1                     ${cells_used_in_TC_A1}
    ${btslog_dir}                               generic_7949_tc_body_execution
    check scelladdition                         ${btslog_dir}
    check carrier aggregation activation        ${btslog_dir}
    check carrier aggregation deactivation      ${btslog_dir}
     [Teardown]  Run Keywords
     ...         Run keyword and ignore error  release attenuator  AND
     ...         Revert SCF  ${pre_change_scf}


CB007949_A_02_TDD_3CC_DL_CA_buffer_based_SCell_activation_and_deactivation_intra_L2RT_BF
    [Documentation]  This TC covers activation of 3CC feature with buffer based SCell Activation
    ...              and checks if after activation CA is established and running
    ...              Cell:               pCell   sCell1  sCell2
    ...              Bandwidths:         40MHz   40MHz   60MHz
    ...              Bands:              N41     N41     n77
    ...              Cells MO:           1       2       3
    ...              Cells PhyCellID:    101     102     103
    ...              Channels:           1-4     1-4     5-8
    ${pre_change_scf}           backup current scf
    ${cells_used_in_TC}         Set Variable    ${cells_used_in_TC_A2}
    check preconditions a_2                     ${cells_used_in_TC_A2}
    ${btslog_dir}                               generic_7949_tc_body_execution
    check scelladdition                         ${btslog_dir}
    check carrier aggregation activation        ${btslog_dir}
    check carrier aggregation deactivation      ${btslog_dir}
     [Teardown]  Run Keywords
     ...         Run keyword and ignore error  release attenuator  AND
     ...         Revert SCF  ${pre_change_scf}


CB007949_A_08_Single_UE_max_Tput_with_TDD_3CC_with_different_bandwidth_and_RLQ_based_deactivation
    [Documentation]  This TC covers max throughput via 3CC feature and deactivation of SCell via RLQ
    ...              and checks if after activation CA is established and running
    ...              Cell:               pCell   sCell1  sCell2
    ...              Bandwidths:         40MHz   40MHz   60MHz
    ...              Bands:              N41     N41     n77
    ...              Cells MO:           1       2       3
    ...              Cells PhyCellID:    101     102     103
    ...              Channels:           1-4     1-4     5-8
    ${pre_change_scf}           backup current scf
    check preconditions a_8                                ${cells_used_in_TC_A8}
    start btslog on local machine
    initialise attenuator
    ${ports_PCI_103}  Create list  5    6    7    8
    set_attenuation             value_string=90            port=${tl.all_cells_ports}
    set_attenuation             value_string=0             port=${tl.cell_1_2_ports}
    set_attenuation             value_string=10             port=${ports_PCI_103}
    require_ues                 1                          capabilities=REAL_UE_SA
    Wait Until Keyword Succeeds   3x   30s       attach_ues     1
    set attenuation             value_string=0             port=${ports_PCI_103}
    Log to console  Wait for 20s - just to see if 3rd cell shows up, before call start
    BuiltIn.Sleep    20s
    Log to console  Start data transfer
    start ul data transfer on ues  num_of_ues=1  duration=150s  throughput=100Mbits/sec  protocol=udp
    start dl data transfer on ues  num_of_ues=1  duration=150s  throughput=4Gbits/sec    protocol=udp
    BuiltIn.Sleep                       10
    Run keyword and ignore error  check dl transfer is alive  1
    Run keyword and ignore error  check ul transfer is alive  1
    BuiltIn.Sleep                       60
    verify average dl throughput   num_of_ues=1  tput_min=${tput_min}
    gradually increase attenuation           init_value=0  max_value=40  step=2  interval=1  port=${ports_PCI_103}
    BuiltIn.Sleep                       ${wait_time_between_deact_and_dettach_inseconds}
    detach_ues                  1
    ${btslog_dir}               stop_and_collect_btslog
    release attenuator
    verify deactivation via rlq                 ${btslog_dir}   ${wait_time_between_deact_and_dettach_inseconds}
    check scelladdition                         ${btslog_dir}
    check carrier aggregation activation        ${btslog_dir}
    check carrier aggregation deactivation      ${btslog_dir}
     [Teardown]  Run Keywords
     ...         Run keyword and ignore error  release attenuator  AND
     ...         Revert SCF  ${pre_change_scf}


CB007949_A_11_Buffer_based_SCell_activation_TDD_2CC_DL_CA_BF_different_frame_structure_1116_0ms_1208
    [Documentation]  This TC covers activation of 2CC within scope of 3CC feature
    ...              Cell:               pCell   sCell1
    ...              Bandwidths:         40MHz   40MHz
    ...              Bands:              N79     N41
    ...              Cells MO:           0       2
    ...              Cells PhyCellID:    100     102
    ...              Channels:           13-16   1-4

    ${pre_change_scf}           backup current scf
    check preconditions a_11                               ${cells_used_in_TC_A11}
    start btslog on local machine
    initialise attenuator
    set attenuation             value_string=90            port=${tl.all_cells_ports}
    set attenuation             value_string=0             port=${tl.cell_0_7_ports}
    set attenuation             value_string=30            port=${tl.cell_1_2_ports}
    BuiltIn.Sleep                       10
    require_ues                 1                          capabilities=REAL_UE_SA
    Wait Until Keyword Succeeds   3x   30s       attach_ues                  1
    BuiltIn.Sleep                       15
    set_attenuation             value_string=0             port=${tl.cell_1_2_ports}
    BuiltIn.Sleep                       ${time_before_buffer_based_activation}
    ${waited_after_attach_timestamp}         get_smod_time
    start ul data transfer on ues  num_of_ues=1  duration=60s  throughput=100Mbits/sec  protocol=udp
    start dl data transfer on ues  num_of_ues=1  duration=60s  throughput=4Gbits/sec    protocol=udp
    BuiltIn.Sleep                       10
    Run keyword and ignore error  check dl transfer is alive  1
    Run keyword and ignore error  check ul transfer is alive  1
    BuiltIn.Sleep                       50
    detach_ues                  1
    ${btslog_dir}               stop_and_collect_btslog
    release attenuator
    unlock cell after test      7
    check scelladdition         ${btslog_dir}
    check scell activation      ${btslog_dir}   ${waited_after_attach_timestamp}
    check carrier aggregation deactivation      ${btslog_dir}
     [Teardown]  Run Keywords
     ...         Run keyword and ignore error  release attenuator  AND
     ...         Revert SCF  ${pre_change_scf}


CB007949_B_01_A1_Scell_Addition_and_A2_SCell_Release
    [Documentation]  This TC covers buffer based SCell Addition and A2 SCell release
    ...              Cell:               pCell   sCell1  sCell2
    ...              Bandwidths:         40MHz   40MHz   60MHz
    ...              Bands:              N41     N41     n77
    ...              Cells MO:           1       2       3
    ...              Cells PhyCellID:    101     102     103
    ...              Channels:           1-4     1-4     5-8
    ${pre_change_scf}           backup current scf
    check preconditions b_01    ${cells_used_in_TC_B1}
    start btslog on local machine
    initialise attenuator
    set attenuation             value_string=90            port=${tl.all_cells_ports}
    set attenuation             value_string=0             port=${tl.cell_1_2_ports}
    require_ues                 1                          capabilities=REAL_UE_SA
    Wait Until Keyword Succeeds   3x   30s       attach_ues                  1
    BuiltIn.Sleep                       5
    ${waited_after_attach_timestamp}=                      get_smod_time
    start ul data transfer on ues  num_of_ues=1  duration=120s  throughput=100Mbits/sec  protocol=udp
    start dl data transfer on ues  num_of_ues=1  duration=120s  throughput=4Gbits/sec    protocol=udp
    BuiltIn.Sleep                       ${wait_time_after_attach}
    Run keyword and ignore error  check dl transfer is alive  1
    Run keyword and ignore error  check ul transfer is alive  1
    gradually increase attenuation     init_value=90  max_value=0  step=1  interval=1  port=${tl.cell_3_4_ports}
    BuiltIn.Sleep                       30
    detach_ues                  1
    ${btslog_dir}               stop_and_collect_btslog
    release attenuator

    check scelladdition         ${btslog_dir}
    check scell release         ${btslog_dir}  ${wait_time_after_attach}  ${waited_after_attach_timestamp}
    check carrier aggregation activation        ${btslog_dir}
    check carrier aggregation deactivation      ${btslog_dir}
     [Teardown]  Run Keywords
     ...         Run keyword and ignore error  release attenuator  AND
     ...         Revert SCF  ${pre_change_scf}


CB007949_B_04_PCell_Change_from_3CC_to_3CC
    [Documentation]  This TC covers pcell change from 3CC, to another set of CA cells
    ...              Cell:               pCell   sCell1  sCell2  -  pCell   sCell1  sCell2
    ...              Bandwidths:         40MHz   40MHz   60MHz   -  60MHz   60MHz   40MHz
    ...              Bands:              N41     N41     N77     -  N77     N77     N79
    ...              Cells MO:           1       2       3       -  3       4       0
    ...              Cells PhyCellID:    101     102     103     -  103     104     100
    ...              Channels:           1-4     1-4     5-8     -  5-8     5-8     13-16
    log  >> backup scf, preconditions <<                       console=True
    ${pre_change_scf}               backup current scf
    check preconditions b_04        ${cells_used_in_TC_B4}
    log  >> start btslog on local machine <<                   console=True
    start btslog on local machine
    log  >> initialise attenuator <<                           console=True
    initialise attenuator

    ${ports_PCI_101}  Create list  9  10
    ${ports_PCI_102}  Create list  11  12
    ${ports_PCI_103}  Create list  3  4
    ${ports_PCI_104}  Create list  1  2
    ${ports_PCI_100}  Create list  13  14

    log  >>>>>>>>>>>>>>>>>>>>>>>>>> 1st call in 1st CA set <<  console=True
    set attenuation                 value_string=90            port=${tl.all_cells_ports}
    set attenuation                 value_string=20            port=${ports_PCI_101}
    set attenuation                 value_string=0             port=${ports_PCI_102}
    set attenuation                 value_string=20            port=${ports_PCI_103}
    log  >> sleep 10s <<            console=True
    BuiltIn.Sleep                           10

    log  >> require_ues <<          console=True
    require_ues                     1                          capabilities=REAL_UE_SA
    log  >> 3x30s attach_ues <<     console=True
    Wait Until Keyword Succeeds     3x            30s          attach_ues                1

    set attenuation                 value_string=0             port=${ports_PCI_101}
    set attenuation                 value_string=0             port=${ports_PCI_103}
    log  >> sleep 20s <<            console=True
    BuiltIn.Sleep                           20

    log  >> start UL <<             console=True
    start ul data transfer on ues   num_of_ues=1  duration=510s  throughput=100Mbits/sec  protocol=udp
    log  >> start DL <<             console=True
    start dl data transfer on ues   num_of_ues=1  duration=510s  throughput=4Gbits/sec  protocol=udp

    Get Logging Start Time
    log  >> sleep 10s for call stability in proper CA set <<   console=True
    BuiltIn.Sleep                           10

    Get 1st Call Setup Time
    Run keyword and ignore error    check dl transfer is alive  1
    Run keyword and ignore error    check ul transfer is alive  1
    log  >> sleep 20s of 1st call <<                           console=True
    BuiltIn.Sleep                           20
    Get 1st Call Stop Time
    log  >> sleep 10s just to be sure <<                       console=True
    BuiltIn.Sleep                           10

    log  >>>>>>>>>>>>>>>>>>>>>>>>>> 2nd call /ho from 1st CA set to the 2nd CA set <<    console=True
    set attenuation                 value_string=0             port=${ports_PCI_100}
    set attenuation                 value_string=0             port=${ports_PCI_104}
    log  >> sleep 10s <<            console=True
    BuiltIn.Sleep                           10
    gradually increase attenuation  init_value=0  max_value=90  step=3  interval=1  port=${tl.cell_1_2_ports}

    Get 2nd Call Setup Time
    Run keyword and ignore error    check dl transfer is alive  1
    Run keyword and ignore error    check ul transfer is alive  1
    log  >> sleep 20s of 2nd call <<                           console=True
    BuiltIn.Sleep                           20
    Get 2nd Call Stop Time
    log  >> sleep 10s just to be sure <<                       console=True
    BuiltIn.Sleep                           10

    log  >>>>>>>>>>>>>>>>>>>>>>>>>> 3rd call /ho from 2nd CA set back to the 1st CA set <<  console=True
    set attenuation                 value_string=0             port=${tl.cell_1_2_ports}
    log  >> sleep 10s <<            console=True
    BuiltIn.Sleep                           10
    set attenuation                 value_string=0             port=${ports_PCI_103}
    ${ports}                        Combine Lists              ${ports_PCI_104}  ${ports_PCI_100}
    gradually increase attenuation  init_value=0  max_value=90  step=3  interval=1  port=${ports}
    log  >> sleep 10s <<            console=True
    BuiltIn.Sleep                           10

    Get 3rd Call Setup Time
    Run keyword and ignore error    check dl transfer is alive  1
    Run keyword and ignore error    check ul transfer is alive  1
    log  >> sleep 20s of 3rd call <<                           console=True
    BuiltIn.Sleep                           20
    Get 3rd Call Stop Time

    log  >> await dl data transfer finish <<                   console=True
    await dl data transfer finish  1
    Get Logging Stop Time

    log  >>>>>>>>>>>>>>>>>>>>>>>>>> 4 - finally fully attenuation of all cells after call <<  console=True
    set attenuation                 value_string=0            port=${tl.all_cells_ports}

    log  >>>>>>>>>>>>>>>>>>>>>>>>> THE END - check the logs now <<  console=True
    Get Omit Before 1st Call
    Get End After 1st Call
    Get Omit Before 2nd Call
    Get End After 2nd Call
    Get Omit Before 3rd Call
    Get End After 3rd Call
    Get 1st Call Duration
    Get 2nd Call Duration
    Get 3rd Call Duration

    log  >> checking tput of 1st CA set before ho to the 2nd one ( call 1 ) <<    console=True
    ${call_1_result}=  Run Keyword And Return Status  verify average dl throughput
    ...                            num_of_ues=1
    ...                            tput_min=400Mbits/sec
    ...                            omit=${OMIT_BEFORE_1_CALL}
    ...                            end=${END_AFTER_1_CALL}
    log  >> checking tput of 2nd CA set after ho from the 1st one ( call 2 ) <<    console=True
    ${call_2_result}=  Run Keyword And Return Status  verify average dl throughput
    ...                            num_of_ues=1
    ...                            tput_min=400Mbits/sec
    ...                            omit=${OMIT_BEFORE_2_CALL}
    ...                            end=${END_AFTER_2_CALL}
    log  >> checking tput of 1st CA set after ho from the 2nd one ( call 3 ) <<    console=True
    ${call_3_result}=  Run Keyword And Return Status  verify average dl throughput
    ...                            num_of_ues=1
    ...                            tput_min=300Mbits/sec
    ...                            omit=${OMIT_BEFORE_3_CALL}
    ...                            end=${END_AFTER_3_CALL}
    log  >> checking whole tput of all <<    console=True
    ${all_calls_result}=  Run Keyword And Return Status  verify average dl throughput
    ...                            num_of_ues=1
    ...                            tput_min=400Mbits/sec
    ...                            omit=0
    ...                            end=0

    log  >> detach_ues <<          console=True
    detach_ues                     1
    log  >> stop_and_collect_btslog <<                         console=True
    ${btslog_dir}                  stop_and_collect_btslog
    log  >> release attenuator <<  console=True
    release attenuator
    log  >> unlock cell after test <<                          console=True
    unlock cell after test         7
    ${scelladdition_result}=       Run Keyword And Return Status  check scelladdition            ${btslog_dir}
    ${pcells_list}=                Create List                 find_used_pcells                  ${btslog_dir}
    ${handover_cell}=	           Get From List	           ${pcells_list}	                 0
    ${return_cell}=	               Get From List	           ${pcells_list}	                 1
    Log  handover_cell: ${handover_cell}  console=True
    Log  return_cell: ${return_cell}  console=True
    ${ho_msg1_result}=  Run Keyword And Return Status  check ho related msg in bts log  ${btslog_dir}
    ${ho_msg2_result}=  Run Keyword And Return Status  check ho related msg in bts log  ${btslog_dir}
    ${ca_activation_result}=  Run Keyword And Return Status  check carrier aggregation activation  ${btslog_dir}
    ${ca_deactivation_result}=  Run Keyword And Return Status  check carrier aggregation deactivation  ${btslog_dir}

    &{the_result_dict} =	       Create Dictionary
    ...                            call_1_result=${call_1_result}
    ...                            call_2_result=${call_2_result}
    ...                            call_3_result=${call_3_result}
    ...                            all_calls_result=${all_calls_result}
    ...                            scelladdition_result=${scelladdition_result}
    ...                            ho_msg1_result=${ho_msg1_result}
    ...                            ho_msg2_result=${ho_msg2_result}
    ...                            ca_activation_result=${ca_activation_result}
    ...                            ca_deactivation_result=${ca_deactivation_result}

    Log  the_result_dict: ${the_result_dict}                   console=True
    Dictionary Should Not Contain Value
    ...                            dictionary=&{the_result_dict}
    ...                            value=${False}
    ...                            msg='Results contain value False, check dict keys to see what goes wrong'
     [Teardown]  Run Keywords
     ...         Run keyword and ignore error                 release attenuator       AND
     ...         Run keyword and ignore error  ${btslog_dir}  stop_and_collect_btslog  AND
     ...         Revert SCF                                   ${pre_change_scf}


CB007949_B_05_SCell_Change_3TDD_to_TDD_2FDD
    [Documentation]  This TC covers pcell change from 3CC, to another set of CA cells: TDD+2FDD
    ...              Cell:               pCell   sCell1  sCell2  -  pCell   sCell1  sCell2
    ...              Bandwidths:         60MHz   40MHz   60MHz   -  60/40   5MHz    5MHz
    ...              Bands:              N41     N41     N77     -  N41     N66     N25
    ...              Cells MO:           1       2       3       -  1/2     5       6
    ...              Cells PhyCellID:    101     102     103     -  101/2   105     106
    ...              Channels:           1-4     1-4     5-8     -  1-4    9-10     11-12
    ${pre_change_scf}           backup current scf
    check preconditions b_05    ${cells_used_in_TC_B5}
    start btslog on local machine
    initialise attenuator
    set attenuation             value_string=90            port=${tl.all_cells_ports}
    set attenuation             value_string=15            port=${tl.cell_1_2_ports}
    set attenuation             value_string=20            port=${tl.cell_3_4_ports}
    set attenuation             value_string=21            port=${tl.cell_5_6_ports}
    BuiltIn.Sleep                       10
    require_ues                 1                          capabilities=REAL_UE_SA
    Wait Until Keyword Succeeds   3x   30s       attach_ues                  1
    set attenuation             value_string=0             port=${tl.cell_3_4_ports}
    start ul data transfer on ues  num_of_ues=1  duration=240s  throughput=100Mbits/sec  protocol=udp
    start dl data transfer on ues  num_of_ues=1  duration=240s  throughput=4Gbits/sec    protocol=udp
    BuiltIn.Sleep                       10
    Run keyword and ignore error  check dl transfer is alive  1
    Run keyword and ignore error  check ul transfer is alive  1
    BuiltIn.Sleep                       20
    verify average dl throughput   num_of_ues=1  tput_min=350Mbits/sec           omit=10
    set attenuation             value_string=0             port=${tl.cell_5_6_ports}
    BuiltIn.Sleep                       10
    ${ports}                    Combine Lists              ${tl.cell_1_2_ports}  ${tl.cell_5_6_ports}
    gradually decrease attenuation     init_value=15  min_value=0  step=3  interval=1
    ...                                port=${ports}
    BuiltIn.Sleep                       30
    log                         Scell change attempted                  console=True
    detach_ues                  1
    ${btslog_dir}               stop and collect btslog
    release attenuator
    check scell change msg in bts log           ${btslog_dir}       ${secondary_cells_used_in_TC_B5}
    check scelladdition                         ${btslog_dir}
    check carrier aggregation activation        ${btslog_dir}
    check carrier aggregation deactivation      ${btslog_dir}
     [Teardown]  Run Keywords
     ...         Run keyword and ignore error  release attenuator  AND
     ...         Revert SCF  ${pre_change_scf}


CB007949_B_13_Inter_gNB_HO_to_non_CA_Cell_and_return
    [Documentation]  This TC covers pcell change from 3CC, to cell without CA and return
    ...              Cell:               pCell   sCell1  sCell2  -  cell
    ...              Bandwidths:         60MHz   40MHz   60MHz   -  40Mhz
    ...              Bands:              N41     N41     N77     -  N79
    ...              Cells MO:           1       2       3       -  7
    ...              Cells PhyCellID:    101     102     103     -  107
    ...              Channels:           1-4     1-4     5-8     -  13-16
    log  >> backup scf, preconditions <<                       console=True
    ${pre_change_scf}               backup current scf
    check preconditions b_13        ${cells_used_in_TC_B13}
    lock cell before test    4
    lock cell before test    0
    log  >> start btslog on local machine <<                   console=True
    start btslog on local machine
    log  >> initialise attenuator <<                           console=True
    initialise attenuator

    log  >>>>>>>>>>>>>>>>>>>>>>>>>> 1st call in 1st CA set <<  console=True
    set attenuation                 value_string=90            port=${tl.all_cells_ports}
    set attenuation                 value_string=0             port=${tl.cell_1_2_ports}
    set attenuation                 value_string=20            port=${tl.cell_3_4_ports}
    log  >> sleep 10s <<            console=True
    BuiltIn.Sleep                           10

    log  >> require_ues <<          console=True
    require_ues                     1                          capabilities=REAL_UE_SA
    log  >> 3x30s attach_ues <<     console=True
    Wait Until Keyword Succeeds     3x            30s          attach_ues                1

    set attenuation                 value_string=0            port=${tl.cell_3_4_ports}
    log  >> sleep 10s <<            console=True
    log  >> sleep 10s <<            console=True
    BuiltIn.Sleep                           10

    log  >> start UL <<             console=True
    start ul data transfer on ues   num_of_ues=1  duration=540s  throughput=100Mbits/sec  protocol=udp
    log  >> start DL <<             console=True
    start dl data transfer on ues   num_of_ues=1  duration=540s  throughput=4Gbits/sec  protocol=udp

    Get Logging Start Time
    log  >> sleep 20s for call stability in proper CA set <<   console=True
    BuiltIn.Sleep                           20

    Get 1st Call Setup Time
    Run keyword and ignore error    check dl transfer is alive  1
    Run keyword and ignore error    check ul transfer is alive  1
    log  >> sleep 20s of 1st call <<                           console=True
    BuiltIn.Sleep                           20
    Get 1st Call Stop Time
    log  >> sleep 10s just to be sure <<                       console=True
    BuiltIn.Sleep                           10

    log  >>>>>>>>>>>>>>>>>>>>>>>>>> 2nd call /ho from 1st CA set to the 2nd CA set <<    console=True
    set attenuation             value_string=0             port=${tl.cell_0_7_ports}
    gradually increase attenuation  init_value=0  max_value=90  step=3  interval=1  port=${tl.cell_1_2_ports}
    log                         Handover attempted                  console=True
    BuiltIn.Sleep                       30
    set attenuation             value_string=0             port=${tl.cell_1_2_ports}
    gradually increase attenuation  init_value=0  max_value=90  step=3  interval=1  port=${tl.cell_0_7_ports}
    BuiltIn.Sleep                       20

    Get 2nd Call Setup Time
    Run keyword and ignore error    check dl transfer is alive  1
    Run keyword and ignore error    check ul transfer is alive  1
    log  >> sleep 20s of 2nd call <<                           console=True
    BuiltIn.Sleep                           20
    Get 2nd Call Stop Time

    log  >> await dl data transfer finish <<                   console=True
    await dl data transfer finish  1
    Get Logging Stop Time

    log  >>>>>>>>>>>>>>>>>>>>>>>>>> 4 - finally fully attenuation of all cells after call <<  console=True
    set attenuation                 value_string=0            port=${tl.all_cells_ports}

    log  >>>>>>>>>>>>>>>>>>>>>>>>> THE END - check the logs now <<  console=True
    Get Omit Before 1st Call
    Get End After 1st Call
    Get Omit Before 2nd Call
    Get End After 2nd Call
    Get 1st Call Duration
    Get 2nd Call Duration

    log  >> checking tput of 1st CA set before ho to the 2nd one ( call 1 ) <<    console=True
    ${call_1_result}=  Run Keyword And Return Status  verify average dl throughput
    ...                            num_of_ues=1
    ...                            tput_min=400Mbits/sec
    ...                            omit=${OMIT_BEFORE_1_CALL}
    ...                            end=${END_AFTER_1_CALL}
    log  >> checking tput of 2nd CA set after ho from the 1st one ( call 2 ) <<    console=True
    ${call_2_result}=  Run Keyword And Return Status  verify average dl throughput
    ...                            num_of_ues=1
    ...                            tput_min=400Mbits/sec
    ...                            omit=${OMIT_BEFORE_2_CALL}
    ...                            end=${END_AFTER_2_CALL}

    log  >> detach_ues <<          console=True
    detach_ues                     1
    log  >> remove preconditions b13 <<                        console=True
    unlock cell after test    4
    unlock cell after test    0
    remove preconditions b13       ${cells_used_in_TC_B13}
    log  >> stop_and_collect_btslog <<                         console=True
    ${btslog_dir}                  stop_and_collect_btslog
    log  >> release attenuator <<  console=True
    release attenuator
    ${scelladdition_result}=  Run Keyword And Return Status  check scelladdition        ${btslog_dir}
    ${pcells_list}=                Create List                 find_used_pcells         ${btslog_dir}
    ${handover_cell}=	           Get From List	           ${pcells_list}	        0
    ${return_cell}=	               Get From List	           ${pcells_list}	        1
    Log  handover_cell: ${handover_cell}  console=True
    Log  return_cell: ${return_cell}  console=True
    ${ho_msg1_result}=  Run Keyword And Return Status  check ho related msg in bts log  ${btslog_dir}
    ${ho_msg2_result}=  Run Keyword And Return Status  check ho related msg in bts log  ${btslog_dir}
    ${ca_activation_result}=  Run Keyword And Return Status  check carrier aggregation activation      ${btslog_dir}
    ${ca_deactivation_result}=  Run Keyword And Return Status  check carrier aggregation deactivation  ${btslog_dir}

    &{the_result_dict} =	       Create Dictionary
    ...                            call_1_result=${call_1_result}
    ...                            call_2_result=${call_2_result}
    ...                            scelladdition_result=${scelladdition_result}
    ...                            ho_msg1_result=${ho_msg1_result}
    ...                            ho_msg2_result=${ho_msg2_result}
    ...                            ca_activation_result=${ca_activation_result}
    ...                            ca_deactivation_result=${ca_deactivation_result}

    Log  the_result_dict: ${the_result_dict}                   console=True
    Dictionary Should Not Contain Value
    ...                            dictionary=&{the_result_dict}
    ...                            value=${False}
    ...                            msg='Results contain value False, check dict keys to see what goes wrong'
     [Teardown]  Run Keywords
     ...         Run keyword and ignore error                 release attenuator       AND
     ...         Run keyword and ignore error  ${btslog_dir}  stop_and_collect_btslog  AND
     ...         Revert SCF                                   ${pre_change_scf}


CB007949_D_01_TDD_FR1_DL_3CC_CA_interworking_with_5GC002200_For_Rel15_UE
    [Documentation]  This TC covers interaction with 8x4 Closed Loop Spatial Multiplexing feature enabled
    ...              Cell:               pCell   sCell1  sCell2
    ...              Bandwidths:         40MHz   40MHz   60MHz
    ...              Bands:              N41     N41     n77
    ...              Cells MO:           1       2       3
    ...              Cells PhyCellID:    101     102     103
    ...              Channels:           1-4     1-4     5-8
    ${pre_change_scf}           backup current scf
    ${cells_used_in_TC}         Set Variable    ${cells_used_in_TC_D1}
    check preconditions d_1                     ${cells_used_in_TC_D1}
    ${btslog_dir}                               generic_7949_tc_body_execution
    check scelladdition                         ${btslog_dir}
    check carrier aggregation activation        ${btslog_dir}
    check carrier aggregation deactivation      ${btslog_dir}
     [Teardown]  Run Keywords
     ...         Run keyword and ignore error  release attenuator  AND
     ...         Revert SCF  ${pre_change_scf}


CB007949_D_02_VoNR_with_and_without_DRX_3CC_TDD_DL_CA_HO
    [Documentation]  This TC covers VoNR with DRX enabled with handover to different set of 3CC cells.
    ...              Cell:               pCell   sCell1  sCell2  -  pCell   sCell1  sCell2
    ...              Bandwidths:         40MHz   40MHz   60MHz   -  60MHz   60MHz   40MHz
    ...              Bands:              N41     N41     N77     -  N77     N77     N79
    ...              Cells MO:           1       2       3       -  3       4       0
    ...              Cells PhyCellID:    101     102     103     -  103     104     100
    ...              Channels:           1-4     1-4     5-8     -  5-8     5-8     13-16
    log  >> backup scf, preconditions <<                       console=True
    ${pre_change_scf}               backup current scf
    check preconditions d_2         ${cells_used_in_TC_D2}
    log  >> start btslog on local machine <<                   console=True
    start btslog on local machine
    log  >> initialise attenuator <<                           console=True
    initialise attenuator

    log  >>>>>>>>>>>>>>>>>>>>>>>>>> 1st call in 1st CA set <<  console=True
    set attenuation                 value_string=90            port=${tl.all_cells_ports}
    set attenuation                 value_string=0             port=${tl.cell_1_2_ports}
    set attenuation                 value_string=60            port=${tl.cell_3_4_ports}
    log  >> sleep 10s <<            console=True

    log  >> require_ues <<          console=True
    require_ues                     1                          capabilities=REAL_UE_SA
    log  >> 3x30s attach_ues <<     console=True
    Wait Until Keyword Succeeds     3x            30s          attach_ues                1
    ${waited_after_attach_timestamp}                           get_smod_time

    set attenuation                 value_string=0             port=${tl.cell_1_2_ports}
    set attenuation                 value_string=20             port=${tl.cell_3_4_ports}

    log  >> start UL <<             console=True
    start ul data transfer on ues   num_of_ues=1  duration=180s  throughput=100Mbits/sec  protocol=udp
    log  >> start DL <<             console=True
    start dl data transfer on ues   num_of_ues=1  duration=180s  throughput=500Mbits/sec protocol=udp

    Get Logging Start Time
    log  >> sleep 10s for call stability in proper CA set <<   console=True

    Get 1st Call Setup Time
    Run keyword and ignore error    check dl transfer is alive  1
    Run keyword and ignore error    check ul transfer is alive  1
    Get 1st Call Stop Time
    log  >> start voice call <<     console=True
    attach_utils.start voice call   vc_alias=VC_1   ue_alias=UE_1   to=+555800903300998
    log  >> sleep 10s just to be sure <<                       console=True
    BuiltIn.Sleep                           10

    log  >>>>>>>>>>>>>>>>>>>>>>>>>> 2nd call /ho from 1st CA set to the 2nd CA set <<    console=True
    set attenuation                 value_string=35             port=${tl.cell_0_7_ports}
    set attenuation                 value_string=15             port=${tl.cell_3_4_ports}
    log  >> sleep 10s <<            console=True
    BuiltIn.Sleep                           10
    gradually increase attenuation  init_value=0  max_value=90  step=10  interval=1  port=${tl.cell_1_2_ports}

    log  >> stop voice call <<      console=True
    ${stop_vc_result}=  Run Keyword And Return Status  attach_utils.stop voice call    vc_alias=VC_1
    log  >> await dl data transfer finish <<                   console=True
    await dl data transfer finish  1
    Get Logging Stop Time

    log  >>>>>>>>>>>>>>>>>>>>>>>>>> 4 - finally fully attenuation of all cells after call <<  console=True
    set attenuation                 value_string=0            port=${tl.all_cells_ports}

    log  >>>>>>>>>>>>>>>>>>>>>>>>> THE END - check the logs now <<  console=True
    Get Omit Before 1st Call
    Get End After 1st Call
    Get 1st Call Duration

    log  >> checking tput of 1st CA set before ho to the 2nd one ( call 1 ) <<    console=True
    ${call_1_result}=  Run Keyword And Return Status  verify average dl throughput
    ...                            num_of_ues=1
    ...                            tput_min=400Mbits/sec
    ...                            omit=${OMIT_BEFORE_1_CALL}
    ...                            end=${END_AFTER_1_CALL}

    log  >> stop_and_collect_btslog <<                         console=True
    ${btslog_dir}                  stop_and_collect_btslog
    ${counter_dir}                 Collect Counters            log_name=TC_D2
    log  >> Wait for next pm period <<  console=True
    GnbCounter.Wait for next pm period                         interval=${pm_interval}
    log  >> check if 5QI1 counters incremented <<  console=True
    ${counter_result}=   Run Keyword And Return Status   check if 5QI1 counters incremented
    ...                                                  ${counter_dir}
    ...                                                  M55125C09518
    ...                                                  target_counter_value=1
    log  >> release attenuator <<  console=True
    release attenuator
    log  >> unlock cell after test <<                          console=True
    unlock cell after test         7
    ${scelladdition_result}=  Run Keyword And Return Status  check scelladdition            ${btslog_dir}
    ${pcells_list}=                Create List                 find_used_pcells                  ${btslog_dir}
    ${handover_cell}=	           Get From List	           ${pcells_list}	                 0
    ${return_cell}=	               Get From List	           ${pcells_list}	                 1
    Log  handover_cell: ${handover_cell}  console=True
    Log  return_cell: ${return_cell}  console=True

    ${ho_msg1_result}=  Run Keyword And Return Status  check ho related msg in bts log  ${btslog_dir}
    ${ca_activation_result}=  Run Keyword And Return Status  check carrier aggregation activation  ${btslog_dir}
    ${ca_deactivation_result}=  Run Keyword And Return Status  check carrier aggregation deactivation  ${btslog_dir}

    &{the_result_dict} =	       Create Dictionary
    ...                            stop_vc_result=${stop_vc_result}
    ...                            call_1_result=${call_1_result}
    ...                            counter_result=${counter_result}
    ...                            scelladdition_result=${scelladdition_result}
    ...                            ho_msg1_result=${ho_msg1_result}
    ...                            ca_activation_result=${ca_activation_result}
    ...                            ca_deactivation_result=${ca_deactivation_result}
    Log  the_result_dict: ${the_result_dict}                   console=True
    Dictionary Should Not Contain Value
    ...                            dictionary=&{the_result_dict}
    ...                            value=${False}
    ...                            msg='Results contain value False, check dict keys to see what goes wrong'
     [Teardown]  Run Keywords
     ...         Run keyword and ignore error                 release attenuator         AND
     ...         Run keyword and ignore error  ${btslog_dir}  stop_and_collect_btslog    AND
     ...         Revert SCF     ${pre_change_scf}


CB007949_E_01_TDD_3CC_DL_CA_pCSI_bundling_applied_to_all_cells_SCell_released
    [Documentation]  This TC covers 3CC interaction with pCSI bundling
    ...              Cell:               pCell   sCell1  sCell2
    ...              Bandwidths:         40MHz   40MHz   60MHz
    ...              Bands:              N41     N41     n77
    ...              Cells MO:           1       2       3
    ...              Cells PhyCellID:    101     102     103
    ...              Channels:           1-4     1-4     5-8
    ${pre_change_scf}           backup current scf
    ${cells_used_in_TC}         Set Variable    ${cells_used_in_TC_E1}
    check preconditions e_1    ${cells_used_in_TC_E1}
    ${btslog_dir}                               generic_7949_tc_body_execution
    check scelladdition                         ${btslog_dir}
    check carrier aggregation activation        ${btslog_dir}
    check carrier aggregation deactivation      ${btslog_dir}
     [Teardown]  Run Keywords
     ...         Run keyword and ignore error  release attenuator  AND
     ...         Revert SCF  ${pre_change_scf}


Generic_7949_TC_body_execution
    start btslog on local machine
    initialise attenuator
    set attenuation             value_string=90            port=${tl.all_cells_ports}
    set attenuation             value_string=0             port=${tl.cell_1_2_ports}
    set attenuation             value_string=25            port=${tl.cell_3_4_ports}
    BuiltIn.Sleep                       10
    require_ues                 1                          capabilities=REAL_UE_SA
    Wait Until Keyword Succeeds   3x   30s   attach_ues                  1
    set attenuation             value_string=0             port=${tl.cell_3_4_ports}
    start ul data transfer on ues  num_of_ues=1  duration=60s  throughput=100Mbits/sec  protocol=udp
    start dl data transfer on ues  num_of_ues=1  duration=60s  throughput=4Gbits/sec    protocol=udp
    BuiltIn.Sleep                       10
    Run keyword and ignore error  check dl transfer is alive  1
    Run keyword and ignore error  check ul transfer is alive  1
    BuiltIn.Sleep                       60
    detach_ues                  1
    ${btslog_dir}               stop_and_collect_btslog
    [Return]                    ${btslog_dir}
