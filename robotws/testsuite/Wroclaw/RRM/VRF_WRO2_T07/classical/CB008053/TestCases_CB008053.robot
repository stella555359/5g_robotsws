*** Settings ***
Documentation
...   Testsuite for 5GC008053_A

Library        taf.ue
Library        taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_5GC007949/resources/test_specific_keywords.py
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008053/resources/test_specific_keywords_8053.py
Library        testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2    WITH NAME    L1L2
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/pm_counters.py
Library        Collections
Library        DateTime
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008053/resources/test_specific_keywords.robot


*** Variables ***
@{cells_used_in_8053}=                               1   2   3   5   4

*** Keywords ***
CB008053_02_A1_based_SCell_addition_mix_inter&intra_L2RT_BF_different_frame_structure
    [Documentation]  This test case verifies the successful >>TDD FR1 DL CA up to 4CC<< feature activation
    ...              with SCell Addition set to >>covBasedA1<< for all NREL objects of all cells
    ...              where gNB performs SCell selection for 4CC TDD FR1 CA with PCell as TDD in SA mode.
    ...              Cell:               pCell   sCell1  sCell2   sCEll3
    ...              Bandwidths:         40MHz   40MHz   60MHz    5MHZ
    ...              Bands:              N41     N41     N77      N66
    ...              Cells MO:           1       2       3        5
    ...              Cells PhyCellID:    101     102     103      105
    ...              Channels:           1-4     1-4     5-8      9-10

    ${ports_PCI_1012}  Create list  1  2  3  4
    ${ports_PCI_103}  Create list  5  6  7  8
    ${ports_PCI_105}  Create list  9  10

    log  >> preconditions <<            console=True
    ${pre_change_scf}                   backup current scf
    set preconditions 4CC 02            ${cells_used_in_8053}
    log  >> initialise attenuator <<    console=True
    initialise attenuator
    set attenuation                     value_string=90            port=${tl.all_cells_ports}
    ${ports}  Combine Lists  ${ports_PCI_1012}  ${ports_PCI_103}  ${ports_PCI_105}
    set attenuation                     value_string=0             port=${ports_PCI_1012}
    set attenuation                     value_string=20             port=${ports_PCI_103}
    log  >> require_ues <<              console=True
    require_ues                         1                          capabilities=REAL_UE_SA

    log  >> 3CC attach part <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   console=True
    log  >> start btslog on local machine 1st time<<  console=True
    start btslog on local machine

    log  >> 3x30s attach_ues 1st time <<          console=True
    Wait Until Keyword Succeeds     3x            30s          attach_ues                1
    ${nr_cell_dns}                  get_multiple_cells_dists   ${cells_used_in_8053}
    L1L2.start_gnbmirroring         new_l1l2=True              nr_cell_dns=${nr_cell_dns}
    log  >> sleep 20s <<            console=True
    BuiltIn.Sleep                           20
    set attenuation                     value_string=0             port=${ports_PCI_103}
    log  >> start UL 1st time <<    console=True
    start ul data transfer on ues   num_of_ues=1  duration=30s  throughput=100Mbits/sec  protocol=udp  custom_dt_name=1
    log  >> start DL 1st time <<    console=True
    start dl data transfer on ues   num_of_ues=1  duration=30s  throughput=4Gbits/sec  protocol=udp  custom_dt_name=1

    log  >> sleep 10s for call stability in 3cc <<   console=True
    BuiltIn.Sleep                           10
    Run keyword and ignore error    check dl transfer is alive  1
    Run keyword and ignore error    check ul transfer is alive  1
    await dl data transfer finish   num_of_ues=1    custom_dt_name=1
    log  >> detach_ues 1st time <<  console=True
    detach_ues                      1

    log  >> L1L2.stop_gnbmirroring 1st time <<                 console=True
    ${l1l2_logs_a}                  L1L2.stop_gnbmirroring_and_download_logs
    log  >> sleep 1s <<                                        console=True
    BuiltIn.Sleep                           1
    log  >> stop_and_collect_btslog 1 <<
    ${btslog_dir_1}                 stop_and_collect_btslog    attempt_number=one
    start btslog on local machine
    log  >> btslog on local machine 2nd time already started <<

    log  >> 4CC attach part <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  console=True
    set attenuation                     value_string=0             port=${ports_PCI_105}
    log  >> maxNumSCellsDlFr1 = 3 <<  console=True
    Enable 4cc For Test 02            ${cells_used_in_8053}

    log  >> 3x30s attach_ues 2nd time <<          console=True
    Wait Until Keyword Succeeds     3x            30s          attach_ues                1
    L1L2.start_gnbmirroring         new_l1l2=True              nr_cell_dns=${nr_cell_dns}
    log  >> sleep 20s <<            console=True
    BuiltIn.Sleep                           20
    log  >> start UL 2nd time <<    console=True
    start ul data transfer on ues   num_of_ues=1  duration=60s  throughput=100Mbits/sec  protocol=udp  custom_dt_name=2
    log  >> start DL 2nd time <<    console=True
    start dl data transfer on ues   num_of_ues=1  duration=60s  throughput=4Gbits/sec  protocol=udp  custom_dt_name=2

    Get Logging Start Time
    log  >> sleep 10s for call stability in 4cc <<   console=True
    BuiltIn.Sleep                           10
    Get 2nd Call Setup Time
    Run keyword and ignore error    check dl transfer is alive  1
    Run keyword and ignore error    check ul transfer is alive  1
    log  >> sleep 20s of 4cc call <<                            console=True
    BuiltIn.Sleep                           20
    Get 2nd Call Stop Time
    Get Logging Stop Time
    await dl data transfer finish    num_of_ues=1    custom_dt_name=2

    Get Omit Before 2nd Call
    Get End After 2nd Call

    log  >> checking tput of 4cc set ( call 2 ) <<    console=True
    ${call_2_result}=  Run Keyword And Return Status  verify average dl throughput
    ...                            num_of_ues=1
    ...                            tput_min=500Mbits/sec
    ...                            omit=${OMIT_BEFORE_2_CALL}
    ...                            end=${END_AFTER_2_CALL}
    ...                            custom_dt_name=2

    log  >> detach_ues 2nd time <<  console=True
    detach_ues                         1

    ${3cc_4cc_counter_result}=  Check 3cc 4cc Counters

    log  >> L1L2.stop_gnbmirroring 2nd time <<                 console=True
    ${l1l2_logs_b}                 L1L2.stop_gnbmirroring_and_download_logs
    log  >> sleep 1s <<                                        console=True
    BuiltIn.Sleep                          1
    log  >> stop_and_collect_btslog 2 <<                       console=True
    ${btslog_dir_2}                stop_and_collect_btslog     attempt_number=two
    log  >> release attenuator <<  console=True
    release attenuator

    log  >>>>>>>>>>>>>>>>>>>>>>>>> THE END - check the logs now <<  console=True
    ${3cc_in_syslog_result}=  Run Keyword And Return Status  check 3cc in syslog  ${btslog_dir_1}
    ${4cc_in_syslog_result}=  Run Keyword And Return Status  check 4cc in syslog TC02  ${btslog_dir_2}


    &{the_result_dict} =           Create Dictionary
    ...                            3cc_in_syslog_result=${3cc_in_syslog_result}
    ...                            4cc_in_syslog_result=${4cc_in_syslog_result}
    ...                            call_2_result=${call_2_result}
    ...                            3cc_4cc_counter_result=${3cc_4cc_counter_result}

    Log  the_result_dict: ${the_result_dict}                   console=True
    Dictionary Should Not Contain Value
    ...                            dictionary=&{the_result_dict}
    ...                            value=${False}
    ...                            msg='Results contain value False, check dict keys to see what goes wrong'

     [Teardown]  Run Keywords
     ...         Run keyword and ignore error                     release attenuator       AND
     ...         Run keyword and ignore error  detach_ues         1                        AND
     ...         L1L2.teardown_gnbmirroring                                                AND
     ...         Run keyword and ignore error  ${btslog_dir_1}    stop_and_collect_btslog  AND
     ...         Run keyword and ignore error  ${btslog_dir_2}    stop_and_collect_btslog  AND
     ...         Revert SCF                    ${pre_change_scf}


CB008053_03_Feature_deactivation_4CC_A2 SCell_Release_BF_beamRefinement_different_frame_structure_RSRP
    [Documentation]  The purpose of this Test Case is to check successful disabling 3TDD+1FDD DL CA
    ...              by gNB reconfiguration and SCell Release based on A2 measurement
    ...              Cell:               pCell   sCell1  sCell2  sCell3
    ...              Bandwidths:         40MHz   40MHz   40MHz   5MHz
    ...              Bands:              N41     n77     n77     n66
    ...              Cells MO:           1       3       4       5
    ...              Cells PhyCellID:    101     103     104     105
    ...              Channels:           1-4    5-8      5-8     9-10

    ${ports_PCI_101}                            Create list  1    2    3    4
    ${ports_PCI_103_104}                        Create list  5    6    7    8
    ${ports_PCI_105}                            Create list  9    10

    log  >> precondition <<                     console=True
    ${pre_change_scf}                           backup current scf
    set preconditions 4CC 03                    ${cells_used_in_8053}
    Lock cell before test           2
    log  >> initialise attenuator <<            console=True
    initialise attenuator

    start btslog on local machine
    set attenuation                             value_string=90           port=${tl.all_cells_ports}
    set attenuation                             value_string=0           port=${ports_PCI_101}
    set attenuation                             value_string=20           port=${ports_PCI_103_104}
    set attenuation                             value_string=20          port=${ports_PCI_105}

    log  >> 1 Call attach UE to PCell <<        console=True
    require_ues                                 1                         capabilities=REAL_UE_SA
    Wait Until Keyword Succeeds                 3x    30s    attach_ues    1
    ${nr_cell_dns}                              get multiple cells dists  ${cells_used_in_8053}
    L1L2.start_gnbmirroring                     new_l1l2=True             nr_cell_dns=${nr_cell_dns}
    log  >> sleep 20s <<                        console=True
    Builtin.Sleep    20s
    log  >> start UL <<                         console=True
    start ul data transfer on ues               num_of_ues=1  duration=500s  throughput=100Mbits/sec  protocol=udp
    log  >> start DL <<                         console=True
    start dl data transfer on ues               num_of_ues=1  duration=500s  throughput=4Gbits/sec    protocol=udp

    Get Logging Start Time
    log  >> setup 4CC based on A1 <<            console=True
    set attenuation                             value_string=15            port=${ports_PCI_105}
    BuiltIn.Sleep                                       5s
    set attenuation                             value_string=0           port=${ports_PCI_103_104}
    BuiltIn.Sleep                                       5s
    set attenuation                             value_string=0            port=${ports_PCI_101}
    BuiltIn.Sleep                                       5s
    set attenuation                             value_string=0            port=${ports_PCI_103_104}
    log  >> sleep 15s <<                        console=True
    BuiltIn.Sleep                                       60s

    Get 1st Call Setup Time
    Run keyword and ignore error                check dl transfer is alive  1
    Run keyword and ignore error                check ul transfer is alive  1
    log  >> sleep 20s of 1st call <<            console=True
    BuiltIn.Sleep                                       20s
    Get 1st Call Stop Time
    log  >> sleep 10s <<                        console=True
    BuiltIn.Sleep                                       10s

    log  >> 4CC disabled 1st time <<            console=True
    disable 4CC in DL                           ${cells_used_in_8053}
    BuiltIn.Sleep                                       5s

    log  >> attenuation to trigger A2 <<        console=True
    gradually increase attenuation              init_value=0      max_value=20   step=5      port=${ports_PCI_101}
    gradually increase attenuation              init_value=0      max_value=90   step=5      port=${ports_PCI_105}
    gradually increase attenuation              init_value=0      max_value=90   step=5      port=${ports_PCI_103_104}
    log  >> sleep 10s <<                        console=True
    BuiltIn.Sleep                                       10s

    log  >> 1st btslog for 4CC stopped <<       console=True
    ${btslog_dir_1}                             stop_and_collect_btslog   attempt_number=one
    ###    Run keyword and ignore error  detach_ues       1
    start btslog on local machine
    log  >> 2nd btslog for 3CC started <<       console=True

    log  >> attenuation to trigger A1 3CC <<    console=True
    set attenuation                             value_string=0           port=${ports_PCI_103_104}
    BuiltIn.Sleep                                       5s
    set attenuation                             value_string=10           port=${ports_PCI_105}
    log  >> sleep 5s <<                         console=True
    BuiltIn.Sleep                                       5s
    set attenuation                             value_string=0            port=${ports_PCI_101}
    BuiltIn.Sleep                                       20s

    log  >> sleep 20s <<                        console=True
    BuiltIn.Sleep                                       20s
    log  >> await dl data transfer finish <<    console=True
    await dl data transfer finish               1
    await ul data transfer finish               1
    Get Logging Stop Time
    log  >> detach ues <<                       console=True
    detach_ues                                  1

    log  >> 2nd btslog for 3CC stopped <<       console=True
    Get Omit Before 1st Call
    Get End After 1st Call
    Get 1st Call Duration
    log  >> checking tput of 1st 4CC call before release ( call 1 ) <<    console=True
    ${call_1_result}=  Run Keyword And Return Status  verify average dl throughput
    ...                            num_of_ues=1
    ...                            tput_min=600Mbits/sec
    ...                            omit=${OMIT_BEFORE_1_CALL}
    ...                            end=${END_AFTER_1_CALL}

    ${btslog_dir_2}                             stop_and_collect_btslog   attempt_number=two
    ${3cc_in_syslog_result_1}=  Run Keyword And Return Status  check 3cc in syslog TC03  ${btslog_dir_2}
    log     >>>>>>>>>>>>>>>>${3cc_in_syslog_result_1}    console=True
    start btslog on local machine
    log  >> 3rd btslog for 4CC started <<       console=True

    log  >> enable 4CC in DL <<                 console=True
    Unlock cell after test      2
    enable 4CC in DL                            ${cells_used_in_8053}
    Lock cell before test       2

    log  >> set attenuation before 2nd call <<  console=True
    set attenuation                             value_string=90           port=${tl.all_cells_ports}
    set attenuation                             value_string=20           port=${ports_PCI_101}
    set attenuation                             value_string=30           port=${ports_PCI_103_104}
    set attenuation                             value_string=40           port=${ports_PCI_105}

    log  >> 2nd Call attach UE to PCell <<      console=True
    Wait Until Keyword Succeeds                 3x    30s    attach_ues    1
    log  >> sleep 20s <<                        console=True
    BuiltIn.Sleep                                       20s
    log  >> start UL <<                         console=True
    start ul data transfer on ues               num_of_ues=1  duration=300s  throughput=100Mbits/sec  protocol=udp
    log  >> start DL <<                         console=True
    start dl data transfer on ues               num_of_ues=1  duration=300s  throughput=4Gbits/sec    protocol=udp
    BuiltIn.Sleep     20s
    Get Logging Start Time

    log  >> setup 4CC based on A1 <<            console=True
    BuiltIn.Sleep                                       5s
    set attenuation                             value_string=15            port=${ports_PCI_105}
    BuiltIn.Sleep                                       5s
    set attenuation                             value_string=0           port=${ports_PCI_103_104}
    BuiltIn.Sleep                                       5s
    set attenuation                             value_string=0            port=${ports_PCI_101}
    BuiltIn.Sleep                                       5s
    set attenuation                             value_string=0            port=${ports_PCI_103_104}

    log  >> sleep 10s <<                        console=True
    BuiltIn.Sleep                                       10s

    Get 2nd Call Setup Time
    Run keyword and ignore error                check dl transfer is alive  1
    Run keyword and ignore error                check ul transfer is alive  1
    log  >> sleep 20s of 2nd call <<            console=True
    BuiltIn.Sleep                                       20s
    Get 2nd Call Stop Time
    log  >> sleep 10s <<                        console=True
    BuiltIn.Sleep                                       10s

    log  >> attenuation to trigger A2 <<        console=True
    gradually increase attenuation              init_value=0     max_value=20   step=5       port=${ports_PCI_101}
    gradually increase attenuation              init_value=0     max_value=90   step=5      port=${ports_PCI_103_104}
    gradually increase attenuation              init_value=0     max_value=90   step=5      port=${ports_PCI_105}
    log  >> sleep 10s <<                        console=True
    BuiltIn.Sleep                                       10s

    log  >> 3rd btslog for 4CC stopped <<       console=True
    ${btslog_dir_3}                             stop_and_collect_btslog   attempt_number=three
    start btslog on local machine
    log  >> 4th btslog for 3CC started <<       console=True

    log  >> await dl data transfer finish <<    console=True
    await dl data transfer finish               1
    await ul data transfer finish               1
    Get Logging Stop Time

    log  >> detach ues <<                       console=True
    detach ues                                  1

    log  >> 4CC disabled 2nd time <<            console=True
    Unlock cell after test      2
    disable 4CC REL remove                      ${cells_used_in_8053}
    Lock cell before test       2
    BuiltIn.Sleep                                       5s

    log  >> attenuation for 2nd attach 4CC <<   console=True
    set attenuation                             value_string=10           port=${ports_PCI_101}
    set attenuation                             value_string=20          port=${ports_PCI_103_104}
    set attenuation                             value_string=30          port=${ports_PCI_105}

    log  >> 3nd Call attach UE to Pcell <<      console=True
    Wait Until Keyword Succeeds                 3x    30s    attach_ues    1
    log  >> sleep 20s <<                        console=True
    BuiltIn.Sleep                                       20s
    log  >> start UL <<                         console=True
    start ul data transfer on ues               num_of_ues=1  duration=200s  throughput=100Mbits/sec  protocol=udp
    log  >> start DL <<                         console=True
    start dl data transfer on ues               num_of_ues=1  duration=200s  throughput=4Gbits/sec    protocol=udp

    log  >> attenuation to trigger A1 <<        console=True
    set attenuation                             value_string=0           port=${ports_PCI_103_104}
    set attenuation                             value_string=0           port=${ports_PCI_105}
    BuiltIn.Sleep                                       5s
    set attenuation                             value_string=0            port=${ports_PCI_101}
    BuiltIn.Sleep                                       5s

    log  >> sleep 20s <<                        console=True
    BuiltIn.Sleep                                       20s

    Run keyword and ignore error                check dl transfer is alive  1
    Run keyword and ignore error                check ul transfer is alive  1
    log  >> sleep 20s of 2nd call <<            console=True
    BuiltIn.Sleep                                       20s

    log  >> await dl data transfer finish <<    console=True
    await dl data transfer finish               1
    await ul data transfer finish               1

    log  >> detach ues <<                       console=True
    detach_ues                                  1

    log  >> 4rd btslog for 3CC stopped <<       console=True
    ${btslog_dir_4}                             stop_and_collect_btslog   attempt_number=four
    log  >> nullify attenuation for all cells <<              console=True
    set attenuation                 value_string=0            port=${tl.all_cells_ports}
    log  >> L1L2.stop_gnbmirroring <<           console=True
    ${l1l2_logs}                   L1L2.stop_gnbmirroring_and_download_logs
    Unlock cell after test    2
    log  >> release attenuator <<               console=True
    release attenuator

    log  >>>>>>>>>>>>>>>>>>>>>>>>> THE END - check the logs now <<        console=True
    Get Omit Before 2nd Call
    Get End After 2nd Call
    Get 2nd Call Duration

    ${call_2_result}=  Run Keyword And Return Status  verify average dl throughput
    ...                            num_of_ues=1
    ...                            tput_min=500Mbits/sec
    ...                            omit=${OMIT_BEFORE_2_CALL}
    ...                            end=${END_AFTER_2_CALL}

    ${4cc_in_syslog_result_1}=  Run Keyword And Return Status  check 4cc in syslog TC03  ${btslog_dir_1}
    ${4cc_in_syslog_result_2}=  Run Keyword And Return Status  check 4cc in syslog TC03  ${btslog_dir_3}

    ${3cc_in_syslog_result_1}=  Run Keyword And Return Status  check 3cc in syslog TC03  ${btslog_dir_2}
    ${3cc_in_syslog_result_2}=  Run Keyword And Return Status  check 3cc in syslog TC03  ${btslog_dir_4}

     #######A2 release check

    &{the_result_dict} =	       Create Dictionary
    ...                            call_1_result=${call_1_result}
    ...                            4cc_in_syslog_result_1=${4cc_in_syslog_result_1}
    ...                            3cc_in_syslog_result_1=${3cc_in_syslog_result_1}
    ...                            call_2_result=${call_2_result}
    ...                            4cc_in_syslog_result_2=${4cc_in_syslog_result_2}
    ...                            3cc_in_syslog_result_2=${3cc_in_syslog_result_2}

    Log  the_result_dict: ${the_result_dict}                   console=True
    Dictionary Should Not Contain Value
    ...                            dictionary=&{the_result_dict}
    ...                            value=${False}
    ...                            msg='Results contain value False, check dict keys to see what goes wrong'

     [Teardown]  Run Keywords
     ...         Run keyword and ignore error  release attenuator                                               AND
     ...         Run keyword and ignore error    Unlock cell after test    2                                    AND
     ...         Run keyword and ignore error  detach_ues       1                                               AND
     ...         L1L2.teardown_gnbmirroring                                                                     AND
     ...         Run keyword and ignore error  ${btslog_dir_1}  stop_and_collect_btslog  attempt_number=one     AND
     ...         Run keyword and ignore error  ${btslog_dir_2}  stop_and_collect_btslog  attempt_number=two     AND
     ...         Run keyword and ignore error  ${btslog_dir_3}  stop_and_collect_btslog  attempt_number=three   AND
     ...         Run keyword and ignore error  ${btslog_dir_4}  stop_and_collect_btslog  attempt_number=four    AND
     ...         Revert SCF                    ${pre_change_scf}


CB008053_14_Pcell_Lock_Unlock_and_HO
    [Documentation]  The purpose of this Test Case is to check if Cell Block/Unblock procedure is working
    ...              and UE can be attached after cell unblocking, and check HO.
    ...              Bandwidths:         40MHz   40MHz   60MHz    5MHZ
    ...              Cell:               pCell   sCell1  sCell2   sCell3
    ...              Bands:              n41     n41     n77      n66
    ...              Global Cell ID:     1       2       3        5
    ...              Phys Cell ID:       101     102     103      105
    ...              NR Cell ID:        .185    .186    .187     .189
    ...              Channels:           9-12    9-12    1-4      17-20

    ${ports_PCI_1012}  Create list  1    2    3    4
    ${ports_PCI_103}  Create list  5    6    7    8
    ${ports_PCI_105}  Create list  9    10

    log  >> preconditions <<            console=True
    ${pre_change_scf}                   backup current scf
    set preconditions 4CC 14            ${cells_used_in_8053}
    log  >> initialise attenuator <<                           console=True
    initialise attenuator

    log  >>>>>>>>>>>>>>>>>>>>>>>>>> 0 call - pcell part <<  console=True
    log  >> start btslog on local machine 1st time <<          console=True
    start btslog on local machine
    set attenuation                 value_string=0             port=${tl.all_cells_ports}
    set attenuation                 value_string=90            port=${tl.cell_0_7_ports}
    set attenuation                 value_string=0             port=${ports_PCI_1012}
    set attenuation                 value_string=20            port=${ports_PCI_103}
    set attenuation                 value_string=20            port=${ports_PCI_105}
    log  >> require_ues <<          console=True
    require_ues                     1                          capabilities=REAL_UE_SA
    log  >> 3x30s attach_ues <<     console=True
    Wait Until Keyword Succeeds     3x            30s          attach_ues                1
    ${nr_cell_dns}                  get_multiple_cells_dists   ${cells_used_in_8053}
    L1L2.start_gnbmirroring         new_l1l2=True              nr_cell_dns=${nr_cell_dns}
    log  >> sleep 20s <<            console=True
    BuiltIn.Sleep                           20
    log  >> 0 call start <<         console=True
    log  >> start DL <<             console=True
    start dl data transfer on ues   num_of_ues=1  duration=510s  throughput=4Gbits/sec  protocol=udp
    log  >> start UL <<             console=True
    start ul data transfer on ues   num_of_ues=1  duration=510s  throughput=100Mbits/sec  protocol=udp
    Get Logging Start Time

    log  >> sleep 30s for stability <<            console=True
    BuiltIn.Sleep                           30

    log  >> no attenuation and waiting for 4CC <<   console=True
    set attenuation                 value_string=0             port=${ports_PCI_1012}
    set attenuation                 value_string=0             port=${ports_PCI_103}
    set attenuation                 value_string=0             port=${ports_PCI_105}
    BuiltIn.Sleep                           60

    log  >> start of 1 call checking <<   console=True
    Get 1st Call Setup Time
    Run keyword and ignore error    check dl transfer is alive  1
    Run keyword and ignore error    check ul transfer is alive  1
    log  >> sleep 20s of 1st call <<                           console=True
    BuiltIn.Sleep                           20
    log  >> stop of 1 call checking <<   console=True
    Get 1st Call Stop Time
    log  >> sleep 10s just to be sure <<                       console=True
    BuiltIn.Sleep                           10

    log  >> stop_and_collect_btslog 1 <<
    ${btslog_dir_1}                 stop_and_collect_btslog    attempt_number=one
    start btslog on local machine
    log  >> btslog on local machine 2nd time already started <<                   console=True

    log  >>>>>>>>>>>>>>>>>>>>>>>>>> 2nd call <<    console=True
    set attenuation                 value_string=20             port=${ports_PCI_105}
    log  >> Lock pcell 1 <<         console=True
    Lock cell before test           1
    log  >> sleep 10s <<            console=True
    BuiltIn.Sleep                           20

    Get 2nd Call Setup Time
    Run keyword and ignore error    check dl transfer is alive  1
    Run keyword and ignore error    check ul transfer is alive  1
    log  >> sleep 10s of 2nd call <<                           console=True
    BuiltIn.Sleep                           20
    Get 2nd Call Stop Time

    log  >>>>>>>>>>>>>>>>>>>>>>>>>> 3rd call part <<  console=True
    log  >> Unlock cell 1 <<       console=True
    Unlock cell after test          1
    log  >> sleep 10s <<            console=True
    BuiltIn.Sleep                           20
    gradually increase attenuation  init_value=0  max_value=20  step=3  interval=1  port=${ports_PCI_103}
    log  >> sleep 20s <<            console=True
    BuiltIn.Sleep                           10
    set attenuation                 value_string=0             port=${ports_PCI_103}
    set attenuation                 value_string=0             port=${ports_PCI_105}
    log  >> sleep 10s <<            console=True
    BuiltIn.Sleep                           30

    ###     here we're expecting HO and 4cc established

    log  >> start of 3 call checking >>    console=True
    Get 3rd Call Setup Time
    Run keyword and ignore error    check dl transfer is alive  1
    Run keyword and ignore error    check ul transfer is alive  1
    log  >> sleep 20s of 3rd call <<                           console=True
    BuiltIn.Sleep                           30
    log  >> stop of 3 call checking >>    console=True
    Get 3rd Call Stop Time

    log  >> await dl data transfer finish <<                   console=True
    await dl data transfer finish  1
    Get Logging Stop Time

    log  >>>>>>>>>>>>>>>>>>>>>>>>>> 4 - finally fully attenuation of all cells after call <<  console=True
    set attenuation                 value_string=90            port=${tl.all_cells_ports}

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

    log  >> checking tput of call 1 <<    console=True
    ${call_1_result}=  Run Keyword And Return Status  verify average dl throughput
    ...                            num_of_ues=1
    ...                            tput_min=500Mbits/sec
    ...                            omit=${OMIT_BEFORE_1_CALL}
    ...                            end=${END_AFTER_1_CALL}
    log  >> checking tput of 1st CA set after ho from the 2nd one ( call 3 ) <<    console=True
    ${call_3_result}=  Run Keyword And Return Status  verify average dl throughput
    ...                            num_of_ues=1
    ...                            tput_min=500Mbits/sec
    ...                            omit=${OMIT_BEFORE_3_CALL}
    ...                            end=${END_AFTER_3_CALL}

    log  >> detach_ues <<          console=True
    Run keyword and ignore error   detach_ues      1

    log  >> L1L2.stop_gnbmirroring <<                          console=True
    ${l1l2_logs}                   L1L2.stop_gnbmirroring_and_download_logs
    log  >> sleep 1s <<                                        console=True
    BuiltIn.Sleep                          1
    log  >> stop_and_collect_btslog 2 <<                         console=True
    ${btslog_dir_2}                 stop_and_collect_btslog      attempt_number=two
    log  >> release attenuator <<  console=True
    release attenuator

    ${4cc_in_syslog_result_1}=  Run Keyword And Return Status  check 4cc in syslog  ${btslog_dir_1}
    ${4cc_in_syslog_result_2}=  Run Keyword And Return Status  check 4cc in syslog  ${btslog_dir_2}

    ${scelladdition_result_1}=  Run Keyword And Return Status  check scelladdition            ${btslog_dir_1}
    ${scelladdition_result_2}=  Run Keyword And Return Status  check scelladdition            ${btslog_dir_2}

    ${pcells_list}=                Create List                 find_used_pcells                  ${btslog_dir_2}
    ${handover_cell}=	           Get From List	           ${pcells_list}	                 0
    ${return_cell}=	               Get From List	           ${pcells_list}	                 1
    Log  ${pcells_list}  console=True
    Log  handover_cell: ${handover_cell}  console=True
    Log  return_cell: ${return_cell}  console=True

    ${ho_msg1_result}=  Run Keyword And Return Status  check ho related msg in bts log  ${btslog_dir_2}
    ${ho_msg2_result}=  Run Keyword And Return Status  check ho related msg in bts log  ${btslog_dir_2}

    &{the_result_dict} =	       Create Dictionary
    ...                            call_1_result=${call_1_result}
    ...                            4cc_in_syslog_result_1=${4cc_in_syslog_result_1}
    ...                            call_3_result=${call_3_result}
    ...                            4cc_in_syslog_result_2=${4cc_in_syslog_result_2}
    ...                            scelladdition_result_1=${scelladdition_result_1}
    ...                            scelladdition_result_2=${scelladdition_result_2}
    ...                            ho_msg1_result=${ho_msg1_result}
    ...                            ho_msg2_result=${ho_msg2_result}

    Log  the_result_dict: ${the_result_dict}                   console=True
    Dictionary Should Not Contain Value
    ...                            dictionary=&{the_result_dict}
    ...                            value=${False}
    ...                            msg='Results contain value False, check dict keys to see what goes wrong'

     [Teardown]  Run Keywords
     ...         Run keyword and ignore error    release attenuator                         AND
     ...         Run keyword and ignore error    detach_ues     1                           AND
     ...         L1L2.teardown_gnbmirroring                                                 AND
     ...         Run keyword and ignore error    ${btslog_dir_1}  stop_and_collect_btslog   AND
     ...         Run keyword and ignore error    ${btslog_dir_2}  stop_and_collect_btslog   AND
     ...         Run keyword and ignore error    Unlock cell after test    1                AND
     ...         Revert SCF                      ${pre_change_scf}
