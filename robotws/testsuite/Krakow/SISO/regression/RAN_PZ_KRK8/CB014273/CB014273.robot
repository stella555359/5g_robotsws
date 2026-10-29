*** Settings ***
Documentation
...   Test Suite for testing CB014273 feature
...   author: Natalia Czech
...   contact: natalia.czech@nokia.com


Resource        testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/CB014273/resources/CB014273_keywords.robot


Suite Setup          Test Suite Setup
Suite Teardown       Test Suite Teardown
Test Teardown        CB014273_keywords.Test Teardown with TDS exit


*** Test Cases ***
CB014273-A Test mode for high-speed tests TDD - PRACH performance (CB007491-G) format 0 with restricted set B 1st TM
    [Setup]    keywords.Test Setup with TDS enter and BTS commissioning    prefix_tag=${100MHz-A}
    General_SiSo_Auto_PRACH_Performance_Test_Admin
    ...                                            cell_id=5
    ...                                            reception_slot=85
    ...                                            expectation_slot=0
    ...                                            act_high_speed_cell=True
    ...                                            preamble_index=30
    ...                                            accepted_timing_error=1040
    ...                                            delay_pattern_duration=0
    ...                                            constant_offset=7151
    ...                                            prach_config_index=17
    ...                                            zero_zone_config=0
    ...                                            prach_seq_type=RestrictedTypeB
    ...                                            timeout=30
    ...                                            act_prach_format_c2_with_scs=${False}
    ...                                            beam_id=969
    ...                                            ru_mode=NR_Only
    ...                                            pb_false_alarm_target=P_0005

CB014273-B Operability of PRACH performance tests is successful for 16RX-8RX UL diff MHz
     [Setup]    keywords.Test Setup with TDS enter and BTS commissioning    prefix_tag=${100MHz-B}
      General_SiSo_Auto_PRACH_Performance_Test_Admin
      ...                                          preamble_index=30
      ...                                          expectation_slot=0
      ...                                          cell_id=5
      ...                                          rep_time_int=1
      ...                                          ru_mode=NR_Only
      ...                                          act_high_speed_cell=${True}
      ...                                          prach_root_sequence_index=30
      ...                                          accepted_timing_error=1040
      ...                                          prach_config_index=17
      ...                                          delay_pattern_duration=0
      ...                                          reception_slot=85
      ...                                          prach_seq_type=RestrictedTypeB
      ...                                          zero_zone_config=0
      ...                                          constant_offset=7151
      ...                                          pb_false_alarm_target=P_0005
      ...                                          beam_id=969
      ...                                          act_prach_format_c2_with_scs=${False}
      ...                                          timeout=360

      keywords.Test Setup with TDS enter and BTS commissioning    prefix_tag=${80MHz-B}
      General_SiSo_Auto_PRACH_Performance_Test_Admin
      ...                                          preamble_index=30
      ...                                          expectation_slot=85
      ...                                          cell_id=5
      ...                                          rep_time_int=1
      ...                                          ru_mode=NR_Only
      ...                                          act_high_speed_cell=True
      ...                                          prach_root_sequence_index=30
      ...                                          accepted_timing_error=1040
      ...                                          prach_config_index=17
      ...                                          delay_pattern_duration=0
      ...                                          reception_slot=85
      ...                                          prach_seq_type=RestrictedTypeB
      ...                                          zero_zone_config=0
      ...                                          constant_offset=7151
      ...                                          pb_false_alarm_target=P_0005
      ...                                          beam_id=969
      ...                                          act_prach_format_c2_with_scs=${False}

      keywords.Test Setup with TDS enter and BTS commissioning    prefix_tag=${50MHz-B}
      General_SiSo_Auto_PRACH_Performance_Test_Admin
      ...                                          preamble_index=30
      ...                                          expectation_slot=85
      ...                                          cell_id=5
      ...                                          rep_time_int=1
      ...                                          ru_mode=NR_Only
      ...                                          act_high_speed_cell=True
      ...                                          prach_root_sequence_index=30
      ...                                          accepted_timing_error=1040
      ...                                          prach_config_index=17
      ...                                          delay_pattern_duration=0
      ...                                          reception_slot=85
      ...                                          prach_seq_type=RestrictedTypeB
      ...                                          zero_zone_config=0
      ...                                          constant_offset=7151
      ...                                          pb_false_alarm_target=P_0005
      ...                                          beam_id=969
      ...                                          act_prach_format_c2_with_scs=${False}

CB014273-B Operability of PRACH performance tests is successful for 16RX-8RX UL
    [Setup]    keywords.Test Setup with TDS enter and BTS commissioning    prefix_tag=${100MHz-B}
    General_SiSo_Auto_PRACH_Performance_Test_Admin
      ...                                          preamble_index=30
      ...                                          expectation_slot=85
      ...                                          cell_id=5
      ...                                          rep_time_int=1
      ...                                          ru_mode=NR_Only
      ...                                          act_high_speed_cell=True
      ...                                          prach_root_sequence_index=30
      ...                                          accepted_timing_error=1040
      ...                                          prach_config_index=17
      ...                                          delay_pattern_duration=0
      ...                                          reception_slot=85
      ...                                          prach_seq_type=RestrictedTypeB
      ...                                          zero_zone_config=0
      ...                                          constant_offset=7151
      ...                                          pb_false_alarm_target=P_0005
      ...                                          beam_id=969
      ...                                          act_prach_format_c2_with_scs=${False}

CB014273-B PUCCH Test mode for 16RX-8RX UL performance G-FR1-A3-13 F3
    [Setup]    keywords.Test Setup with TDS enter and BTS commissioning    prefix_tag=${100MHz-B}
    General_SiSo_Auto_PUCCH_Performance_Test_Admin
    ...                                             cell_id=5
    ...                                             rep_time_int=1
    ...                                             ru_mode=NR_Only
    ...                                             act_high_speed_cell=${False}
    ...                                             pucch_format=F1
    ...                                             num_pucch_symbol=14
    ...                                             format3_additional_dmrs=Disabled
    ...                                             prb_offset=0
    ...                                             largest_prb_index=272
    ...                                             receiving_slot=170
    ...                                             expectation_slot=170
    ...                                             digital_output_enable=${False}
    ...                                             num_payload_bit=2
    ...                                             pucch_payload_content=3
    ...                                             beam_id=@{beam_id}
