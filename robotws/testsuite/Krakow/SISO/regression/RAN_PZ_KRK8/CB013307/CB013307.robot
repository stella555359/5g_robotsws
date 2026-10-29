*** Settings ***
Documentation
...   Test Suite for testing CB013307 feature
...   author: Natalia Czech
...   contact: natalia.czech@nokia.com



Resource        testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/CB013307/resources/CB013307_keywords.robot



Suite Setup          Test Suite Setup
Suite Teardown       Test Suite Teardown
Test Teardown        CB013307_keywords.Test Teardown with TDS exit



*** Test Cases ***
[Loki]Operability of PRACH performance tests is successful with FDD high-speed cell format 0 with restricted set B
    [Tags]     TL0234
    [Setup]    Test Setup with TDS enter and BTS commissioning
    General_SiSo_Auto_PRACH_Performance_Test_Admin
    ...                                            preamble_index=0
    ...                                            expectation_slot=136
    ...                                            cell_id=1
    ...                                            rep_time_int=1
    ...                                            ru_mode=NR_Only
    ...                                            act_high_speed_cell=True
    ...                                            prach_root_sequence_index=30
    ...                                            accepted_timing_error=1000
    ...                                            prach_config_index=25
    ...                                            delay_pattern_duration=0
    ...                                            reception_slot=170
    ...                                            ul_slots=${4}
    ...                                            prach_seq_type=RestrictedTypeB
    ...                                            zero_zone_config=0
    ...                                            constant_offset=7151
    ...                                            pb_false_alarm_target=P_0005
    Test Setup with TDS enter and BTS commissioning    prefix_tag=${LOKI_10MHz}
    General_SiSo_Auto_PRACH_Performance_Test_Admin
    ...                                            preamble_index=0
    ...                                            expectation_slot=136
    ...                                            cell_id=1
    ...                                            rep_time_int=1
    ...                                            ru_mode=NR_Only
    ...                                            act_high_speed_cell=True
    ...                                            prach_root_sequence_index=30
    ...                                            accepted_timing_error=1000
    ...                                            prach_config_index=25
    ...                                            delay_pattern_duration=0
    ...                                            reception_slot=170
    ...                                            ul_slots=${4}
    ...                                            prach_seq_type=RestrictedTypeB
    ...                                            zero_zone_config=0
    ...                                            constant_offset=7151
    ...                                            pb_false_alarm_target=P_0005

[Loki]Operability of PUCCH performance tests is successful with FDD high-speed cell
    [Tags]     TL0234
    [Setup]    Test Setup with TDS enter and BTS commissioning    prefix_tag=${LOKI_5MHz}
    General_SiSo_Auto_PUCCH_Performance_Test_Admin
    ...                                             cell_id=1
    ...                                             rep_time_int=1
    ...                                             ru_mode=NR_Only
    ...                                             act_high_speed_cell=${True}
    ...                                             pucch_format=F3
    ...                                             num_pucch_symbol=4
    ...                                             format3_additional_dmrs=Disabled
    ...                                             prb_offset=0
    ...                                             largest_prb_index=2
    ...                                             receiving_slot=10
    ...                                             expectation_slot=8
    ...                                             ul_slots=${2}
    ...                                             digital_output_enable=${True}
    ...                                             num_payload_bit=16
    Test Setup with TDS enter and BTS commissioning    prefix_tag=${LOKI_10MHz}
    General_SiSo_Auto_PUCCH_Performance_Test_Admin
    ...                                             cell_id=1
    ...                                             rep_time_int=1
    ...                                             ru_mode=NR_Only
    ...                                             act_high_speed_cell=${True}
    ...                                             pucch_format=F3
    ...                                             num_pucch_symbol=4
    ...                                             format3_additional_dmrs=Disabled
    ...                                             prb_offset=0
    ...                                             largest_prb_index=2
    ...                                             receiving_slot=10
    ...                                             expectation_slot=8
    ...                                             ul_slots=${2}
    ...                                             digital_output_enable=${True}
    ...                                             num_payload_bit=16

[Loki]Operability of PUSCH performance tests is successful with FRCs for high-speed cell FDD
    [Tags]     TL0234
    [Setup]    Test Setup with TDS enter and BTS commissioning    prefix_tag=${LOKI_5MHz}
    General_SiSo_Auto_PUSCH_Performance_Test_Admin          FRC_Index=G-FR1-A4-29A
    ...                                                     cell_id=1
    General_SiSo_Auto_PUSCH_Performance_Test_Admin          FRC_Index=G-FR1-A4-31A
    ...                                                     cell_id=1
    General_SiSo_Auto_PUSCH_Performance_Test_Admin          FRC_Index=G-FR1-A3-33A
    ...                                                     cell_id=1
    Test Setup with TDS enter and BTS commissioning    prefix_tag=${LOKI_10MHz}
    General_SiSo_Auto_PUSCH_Performance_Test_Admin          FRC_Index=G-FR1-A4-29
    ...                                                     cell_id=1
    General_SiSo_Auto_PUSCH_Performance_Test_Admin          FRC_Index=G-FR1-A4-31
    ...                                                     cell_id=1
    General_SiSo_Auto_PUSCH_Performance_Test_Admin          FRC_Index=G-FR1-A3-33
    ...                                                     cell_id=1
