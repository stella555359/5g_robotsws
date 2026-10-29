*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/case_keywords.robot
Resource    ./../Resources/CB007873_keywords.robot
Resource    ./../Resources/CB007873_case_keyword.robot

Documentation    Suite description
...   author: Wang Yixiang
...   contact: yixiang.x.wang@nokia-sbell.com
...   squad group: MMW_SG1
...   Feature CB007873

Force Tags    5G_RRM
...    PY36    RF50
Suite Setup     7873 Suite preparation
Suite Teardown    run keyword and ignore error    CA Suite teardown


*** Test Cases ***
#CB007873_test
#    [Tags]   debug
#    [Documentation]    Author: Wang Yixiang
#    ...  The case is to verify keywords
#    [Setup]    Common case setup    is_log_required=${False}
#    ${logpath}   set variable    /opt/ute/results/tcpdump_L2L1_bip_filtering_off.pcap0
#    Check csi beam report in biplog     tcpdump_log=${logpath}
#    [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${False}    detach_ue=${False}
#
#CB007873_basic_L3_call
#    [Tags]
#    [Documentation]    Author: Wang Yixiang
#    ...  The case is to verify basic l3 call
#    [Setup]    Common case setup    is_log_required=${False}
#    CA_basic_L3_call_bi_direction_and_single-direction_traffic    dl_tput=${DL_TPUT}    ul_tput=${UL_TPUT}
#    ...     dl_cell_id=1,2     exp_dl=150,380    ul_cell_id=1     exp_ul=50
#    ...     wa_flag=${True}
#    [Teardown]    run keyword and ignore error    Case teardown feature    is_log_required=${False}    detach_ue=${True}
#
#[1]CB007873_H_17_FA_B1_Dynamic_Data_Split_Pcell_Scell_Simplified_FC_Blind_Scell_Activation_nonBF_ABIO_SA
#    [Documentation]    Author: Cui Lingxue
#    ...    The aim of this test is to check the successful call setup with FDD FR1-TDD Carrier aggregation for the single UE with dynamic flow
#    ...    control, data split over PCell and SCell, with blind SCell activation of the FR1-TDD SCell and without PF metric exchange between
#    ...    PCell and SCell. Beamforming is disabled. Bandwidth configuration can be FDD 20MHz & TDD 60MHz.
#    [Setup]    Common case setup    NSA_SA=SA
#    Set PCell primaryPathMaxQueueingDelay=10 and SCell secondaryPathMaxQueueingDelay=0
#    CA_basic_L3_call    dl_tput=${DL_TPUT}    ul_tput=${UL_TPUT}
#    ...     dl_cell_id=1,2     exp_dl=150,0    ul_cell_id=1,2     exp_ul=50,0
#    ...     wa_flag=${False}    check_counter=${False}    check_scell_activation=${False}
#    ${remote_file_path}    ${case_start_time_info}    Wait for next PM counter file is generated    reporting_interval=5
#    sleep    1min
#    Wait for next PM counter file is generated    reporting_interval=5
#    ${pm_files_local_path}    Download PM counter files of a period    starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}
#    ${list_measurement_ids}    create list    M55310C05007    M55310C01007    M55310C03007
#    ${dict_measurements_value}    run keyword and continue on failure  counter.get_total_counter_from_multiple_files
#    ...    list_file_path=${pm_files_local_path}    list_measurement_ids=${list_measurement_ids}
#    ### verify counter value, primary path delay should be larger than secondary, throughput counter should have value.
#    Stop data transfer and detach UE
#
#    Set PCell primaryPathMaxQueueingDelay=0 and SCell secondaryPathMaxQueueingDelay=10
#    CA_basic_L3_call    dl_tput=${DL_TPUT}    ul_tput=${UL_TPUT}
#    ...     dl_cell_id=1,2     exp_dl=0,380    ul_cell_id=1,2     exp_ul=50,0
#    ...     wa_flag=${False}    check_counter=${False}    check_scell_activation=${False}
#    ${remote_file_path}    ${case_start_time_info}    Wait for next PM counter file is generated    reporting_interval=5
#    sleep    1min
#    Wait for next PM counter file is generated    reporting_interval=5
#    ${pm_files_local_path}    Download PM counter files of a period    starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}
#    ${dict_measurements_value}    run keyword and continue on failure  counter.get_total_counter_from_multiple_files
#    ...    list_file_path=${pm_files_local_path}    list_measurement_ids=${list_measurement_ids}
#    ### verify counter value, primary path delay should be smaller than secondary, throughput counter should have value.
#    [Teardown]    run keyword and ignore error    run keywords    Restore PathMaxQueueingDelay    AND
#    ...    Common case teardown    detach_ue=${True}
#
#[1]CB007873_H_18_FA_B2_Dynamic_Data_Split_Pcell_Scell_Simplified_FC_BufferBased_Scell_Activation_BF_BeamRefinement_ABIO_SA
#    [Tags]    CRT_21B
#    [Documentation]    Author: Cui Lingxue
#    ...    Description: The aim of this test is to check the successful call setup with FDD  FR1-TDD Carrier aggregation for the single UE with
#    ...                 dynamic flow control, data split over PCell and SCell without PF metric exchange between PCell and SCell, and
#    ...                 Activation / Deactivation of the FR1-TDD SCell based on the DRB data buffer trigger for SA configuration
#    ...                 (sCellAdditionMethod set to ‘bufferBased’). Beamforming is enabled and beam refinement can also be.
#    ...                 Bandwidth configuration can be FDD 20MHz & TDD 60MHz.
#    ...    Note: with the WA introduced by PR577410, L2HI will force to send one PDU on secondary leg after receiving bufferEmpty
#    ...          Report from L2LO regardless secondaryPathMaxQueueingDelay value. This will cause scell activation once DL data transmission
#    ...          is started although secondaryPathMaxQueueingDelay is configured 0, and 2~3Mbps data on scell.
#    ...          Once this WA is removed, the scell should not be activated when secondaryPathMaxQueueingDelay is configured 0.
#    ...          CuDo PR583423: [21A][SA][F+T CA][Classical] secondaryPathMaxQueueingDelay should not be set to 0 on Scell
#    ...    Step 1> Configure PCell primaryPathMaxQueueingDelay=10 and SCell secondaryPathMaxQueueingDelay=0 on gNB.
#    ...    Step 2> UE perform attach to FDD NR cell.
#    ...    Step 3> Verify Scell is inactive.(In aasyslog)
#    ...    Step 4> Start UL data transmission of the non-GBR DRB bearer.
#    ...    Step 5> Verify throughput on FDD PCell and verify no scell is activated. (In aasyslog)
#    ...    Step 6> Start DL data transmission of the non-GBR DRB bearer.
#    ...    Step 7> Verify throughput of PCell and Scell.
#    ...    Step 8> Verify no scell is activated/Scell is activated.
#    ...    Step 9> Stop both UL and DL data transmission.
#    ...    Step 10> Verify scell deactivation.
#    ...    Step 11> Configure PCell primaryPathMaxQueueingDelay=0 and SCell secondaryPathMaxQueueingDelay=10 on gNB.
#    ...    Step 12> UE perform attach to FDD NR cell.
#    ...    Step 13> Verify Scell is inactive.(In aasyslog)
#    ...    Step 14> Start UL and DL data transmission of the non-GBR DRB bearer.
#    ...    Step 15> Verify throughput of PCell and Scell.
#    ...    Step 16> Stop both UL and DL data transmission.
#    [Setup]    Common case setup    nidd_modify_via_api=${RESTAPI_SCELL_ACTIVATION_BUFFER_BASED}   NSA_SA=SA
#    Basic_split_mode_flow_control
#    [Teardown]    run keyword and ignore error    run keywords    Restore PathMaxQueueingDelay    AND
#    ...    Common case teardown    detach_ue=${True}
#
#CB007873_H_21_E_B1_DRX_activation_for_single_UE_with_CA-FDD-FR1-TDD_drxLongCycle-below-80ms_Bufferbased-SCellActivation_Bursty_traffic_SA
#    [Tags]    CRT_21B    CRT_22R1
#    [Documentation]    Author: Cui Lingxue
#    ...    Description: The goal of this test is to validate DRX setup for UEs with data DRB after SCell configuration, where
#    ...                     drxLongCycle < 80ms;
#    ...                     sCellActivationMethod = BufferBased;
#    ...                     beamforming = false;
#    ...                     and bursty DL + UL traffic on Pcell (for DL and UL) & Scell (for DL).
#    ...    Step 1> UE attach to gNB with FDD cell as Pcell, FR1-TDD cell as Scell.
#    ...    Step 2> Start bursty DL+UL traffic(ping), calculate ping latency.
#    ...    Step 3> Configure gNB with DRX parameters.
#    ...    Step 4> UE attach to gNB with FDD cell as Pcell, FR1-TDD cell as Scell.
#    ...    Step 5> Verify DRX configurations in RRC Reconfiguration.
#    ...    Step 6> Start continuous DL traffic + bursty UL traffic(ping), calculate ping latency.
#    ...    Step 7> Start bursty DL+UL traffic, calculate ping latency.
#    ...    Step 8> compare average ping latency after DRX enabled with bursty traffic, should be larger than others.
#    [Setup]    Common case setup    NSA_SA=SA
#    Long_drx_in_CA_mode    is_drx_cycle_above_80ms=${False}
#    [Teardown]    run keyword and ignore error    Common case teardown    detach_ue=${True}

CB007873_H_22_E_B1_DRX_activation_for_Single-UE_with_CA-FDD-FR1-TDD_drxLongCycle-above-80ms_Bufferbased-SCellActivation_Bursty_traffic_SA
    [Tags]    CRT_TRUNK    CRT_21B    CIT_22R1    CIT_22R2    CRT_22R1    CRT_22R3    CDRT_22R2    CRT_22R4    CRT_23R1
    [Documentation]    Author: Cui Lingxue
    ...    Description: The goal of this test is to validate DRX setup for UEs with data DRB after SCell configuration, where
    ...                     drxLongCycle > 80ms;
    ...                     sCellActivationMethod = BufferBased;
    ...                     beamforming = false;
    ...                     and bursty DL + UL traffic on Pcell (for DL and UL) & Scell (for DL).
    ...    Step 1> UE attach to gNB with FDD cell as Pcell, FR1-TDD cell as Scell.
    ...    Step 2> Start bursty DL+UL traffic(ping), calculate ping latency.
    ...    Step 3> Configure gNB with DRX parameters.
    ...    Step 4> UE attach to gNB with FDD cell as Pcell, FR1-TDD cell as Scell.
    ...    Step 5> Verify DRX configurations in RRC Reconfiguration.
    ...    Step 6> Start continuous DL traffic + bursty UL traffic(ping), calculate ping latency.
    ...    Step 7> Start bursty DL+UL traffic, calculate ping latency.
    ...    Step 8> compare average ping latency after DRX enabled with bursty traffic, should be larger than others.
    [Setup]    Common case setup    NSA_SA=SA
    Long_drx_in_CA_mode    is_drx_cycle_above_80ms=${True}
    [Teardown]    run keyword and ignore error    Common case teardown    detach_ue=${True}
#
#CB007873_H_02_A_B5_Successful_operation_of_deactivation_of_FR1_carrier_aggregation_related_features_5GC002255_and_5GC001390_ABIO_SA
#    [Tags]     CRT_21B    CRT_22R1
#    [Documentation]    Author: Wang Yixiang
#    ...    The purpose of this test case is to verify GNB’s supporting of the successful operation of
#    ...    deactivation of FR1 carrier aggregation related features 5GC002255 and 5GC001390
#    ...    Step 1	Deactivate feature 5GC001390 by setting carrierAggregationSupportList enumeration parameter to 0 (none).Then acive plan.
#    ...    Step 2	Remove CA relation by modifying NRREL object for each FDD cell pointing to the corresponding FR1-TDD cell having coverage
#    ...             overlaid with FDD cell. Within NRREL object remove optional sCellAdditionMethod parameter.then active plan
#    ...    Step 3	Deactivate feature 5GC002255 by setting 5GC002255 feature flag to false (actInterNumerologyCa = false).
#    ...    Step 4	Deactivate feature 5GC001390 by setting carrierAggregationSupportList enumeration parameter is set to 0 (none). Then active plan.
#    ...    Step 5	UE attach to FDD cell
#    ...    Step 6	UE attach to TDD cell
#    [Setup]    Common case setup   NSA_SA=SA
#    Remove_and_add_NRREL_check_data_transmission
#    [Teardown]    run keyword and ignore error    Common case teardown    detach_ue=${True}    is_scf_restore=${False}
#
#CB007873_H_01_A_B4_Successful_operation_of_activation_of_FR1_carrier_aggregation_related_features_5GC002255_and_5GC001390_ABIO_SA
#    [Tags]    CRT_21B
#    [Documentation]    Author: Wang Yixiang
#    ...  The purpose of this test case is to verify GNB’s supporting of  the successful operation of activation of
#    ...  FR1 carrier aggregation related features 5GC002255 and 5GC001390
#    ...    1. Set 5GC001390 active without 5GC002255 and check PDL error
#    ...    2. Check UE attach and CA counter
#    ...    3. UE attach to TDD cell and verify NO CA
#    [Setup]    Common case setup   NSA_SA=SA
#    Check_PDL_error_and_check_data_transmission    dl_tput=${DL_TPUT}    ul_tput=${UL_TPUT}
#    [Teardown]    run keyword and ignore error    Common case teardown    detach_ue=${True}

*** Keywords ***
Case teardown feature
    [Arguments]     ${is_log_required}=${False}    ${detach_ue}=${False}
    Teardown the Aasyslog save progress
    Common case teardown    is_log_required=${is_log_required}    detach_ue=${detach_ue}

