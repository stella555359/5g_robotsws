*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: Test Cases 5GC000994

Library    testsuite.Krakow.resources.TWAMP.twamp.Twamp    WITH NAME  TWAMP
Library    testsuite.Krakow.resources.alarm.Alarm
Resource   taf/rfrl/bts/robot/gnb.robot
Resource   taf/rfrl/bts/robot/logs_collecting.robot
Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library    testsuite.Krakow.resources.RAN_PZ_KRK4.linux_hardening.linux_hardening_keywords.LinuxHardening
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       Common Suite Setup With Commissioning
Suite Teardown    Common Suite Teardown
Test Setup        Common Preconditions
Test Teardown     Common Postconditions

*** Variables ***
${A_08_scf_path} =  ${CURDIR}/config_A_08_2.xml
${C_49_scf_path} =  ${CURDIR}/config_C_49_2.xml
@{txtwampmessages_zero} =  0  0
@{txtwampmessages_1Min} =  300  450
@{txtwampmessages_5Min} =  1450  1650
@{txtwampmessages_15Min} =  4450  4650
@{txtwampmessages_not_zero} =  1  999999

*** Test Cases ***
[1]5GC000994_B_36_TWAMP stateful Reflector - disabling TWAMP reflector
    send_and_verify_packets_from_twamp_ipv4  20
    send_and_verify_packets_from_twamp_ipv6  20
    start_sending_packets
    get_twamp_session_info
    verify_test_session_status  1
    change_twamp_reflector_parameter  twampReflectorEnabled  false  1
    change_twamp_reflector_parameter  twampReflectorUdpEchoEnabled  false  1
    send_and_verify_packets_from_twamp_ipv4  10  should_fail=True
    get_twamp_session_info
    verify_test_session_status  2
    change_twamp_reflector_parameter  twampReflectorEnabled  false  4
    change_twamp_reflector_parameter  twampReflectorUdpEchoEnabled  false  4
    start_tcpdump
    send_and_verify_packets_from_twamp_ipv4  10  should_fail=True
    send_and_verify_packets_from_twamp_ipv6  10  should_fail=True
    check_destination_unreachable_ipv6
    get_twamp_session_info
    verify_test_session_status  3
    Run Keywords  stop_sending_packets
    ...  AND  change_twamp_reflector_parameter  twampReflectorEnabled  true  1
    ...  AND  change_twamp_reflector_parameter  twampReflectorUdpEchoEnabled  true  1
    ...  AND  change_twamp_reflector_parameter  twampReflectorEnabled  true  4
    ...  AND  change_twamp_reflector_parameter  twampReflectorUdpEchoEnabled  true  4

5GC000994_B_39_TWAMP stateful Reflector - session creation on Nokia TWAMP reflector
    start_sending_packets
    stop_sending_and_verify_packets
    sleep  20
    start_sending_packets
    Verify Alarm is not Active on gNB  RTT_THRESHOLD_CROSSED
    Verify Alarm is not Active on gNB  PLR_THRESHOLD_CROSSED
    start_sending_packets_with_different_dscp_number  dscp=af33
    Verify Alarm is not Active on gNB  RTT_THRESHOLD_CROSSED
    Verify Alarm is not Active on gNB  PLR_THRESHOLD_CROSSED
    Run Keywords  stop_sending_and_verify_packets
    ...  AND  stop_sending_and_verify_packets_with_different_dscp_number

5GC000994_A_01_TWAMP Sender configuration - WebEM
    configure_responder
    ${du_scf_old_path} =  get_bts_configuration_via_gui
    ${du_scf_new_path} =  add_twamp_object  ${du_scf_old_path}
    perform_du_commissioning  ${du_scf_new_path}
    wait for on air
    Verify Alarm is not Active on gNB  RTT_THRESHOLD_CROSSED
    Verify Alarm is not Active on gNB  PLR_THRESHOLD_CROSSED
    stop_responder_and_verify_packets
    change_administrative_state_parameters
    simulate_echoserver  IP_V4
    simulate_echoserver  IP_V6
    verify_echoserver_packets
    Verify Alarm is not Active on gNB  RTT_THRESHOLD_CROSSED
    Verify Alarm is not Active on gNB  PLR_THRESHOLD_CROSSED
    Run Keywords  stop_echoserver  IP_V4
    ...  AND  stop_echoserver  IP_V6

5GC000994_A_07_TWAMP Sender - PLR threshold crossed alarm
    change_administrative_state_parameters
    configure_responder
    run_tc_commands  IP_V4
    wait_until_alarm_is_active_on_gnb  PLR threshold crossed on TWAMP-1  2700
    Verify Alarm is not Active on gNB  PLR threshold crossed on TWAMP-3
    remove_additional_delay  IP_V4
    wait_until_alarm_is_not_active_on_gnb  PLR threshold crossed on TWAMP-1  2700
    run_tc_commands  IP_V6
    wait_until_alarm_is_active_on_gnb  PLR threshold crossed on TWAMP-3  2700
    Verify Alarm is not Active on gNB  PLR threshold crossed on TWAMP-1
    remove_additional_delay  IP_V6
    wait_until_alarm_is_not_active_on_gnb  PLR threshold crossed on TWAMP-3  2700
    stop_responder

5GC000994_A_06_TWAMP Sender - RTT threshold crossed alarm
    change_rtt_alarm_threshold  10000
    configure_responder
    run_tc_commands  IP_V4  RTT
    wait_until_alarm_is_active_on_gnb  RTT threshold crossed on TWAMP-1  120
    Verify Alarm is not Active on gNB  RTT threshold crossed on TWAMP-3
    remove_additional_delay  IP_V4
    wait_until_alarm_is_not_active_on_gnb  RTT threshold crossed on TWAMP-1  360
    run_tc_commands  IP_V6  RTT
    wait_until_alarm_is_active_on_gnb  RTT threshold crossed on TWAMP-3  120
    Verify Alarm is not Active on gNB  RTT threshold crossed on TWAMP-1
    remove_additional_delay  IP_V6
    wait_until_alarm_is_not_active_on_gnb  RTT threshold crossed on TWAMP-3  360
    Run Keywords  stop_responder
    ...  AND  change_rtt_alarm_threshold  1000000

5GC000994_A_15_TWAMP Reflector - configuration - WebEM
    deactivate_all_twamp_sender_sessions
    change_twamp_reflector_parameter  twampReflectorUdpEchoEnabled  false  1
    change_twamp_reflector_parameter  twampReflectorUdpEchoEnabled  false  4
    start_sending_packets
    stop_sending_and_verify_packets
    start_sending_packets  responder_port=7
    start_tcpdump
    check_destination_unreachable_ipv6
    start_tcpdump
    check_destination_unreachable_ipv4
    stop_sending_and_verify_packets  discarded=True

5GC000994_A_21_TWAMP Reflector - DSCP value in reply message
    start_sending_packets  options=--padding 27
    check_dscp_value  AF41
    stop_sending_packets
    start_sending_packets  options=--dscp af33
    check_dscp_value  7
    stop_sending_packets

[1]5GC000994_A_29_TWAMP UDP echo server - DSCP value in reply message
    change_twamp_reflector_parameter  twampReflectorUdpEchoEnabled  true  1
    change_twamp_reflector_parameter  twampReflectorUdpEchoEnabled  true  4
    change_twamp_reflector_parameter  twampReflectorEnabled  false  1
    change_twamp_reflector_parameter  twampReflectorEnabled  false  4
    start_sending_packets  responder_port=7
    check_dscp_value  AF41  7  ECHO
    stop_sending_packets
    start_sending_packets  responder_port=7  options=--dscp af33
    check_dscp_value  7  7  ECHO
    stop_sending_packets

5GC000994_A_23_TWAMP UDP echo server - configuration - WebEM
    start_sending_packets  responder_port=7  options=--padding 27
    sleep  10
    stop_sending_and_check_response
    start_sending_packets
    start_tcpdump
    check_destination_unreachable_ipv6
    start_tcpdump
    check_destination_unreachable_ipv4
    stop_sending_and_verify_packets  discarded=True

5GC000994_A_30_TWAMP Sender, Reflector and UDP echo server runs simultaneously
    change_twamp_reflector_parameter  twampReflectorEnabled  true  1
    change_twamp_reflector_parameter  twampReflectorEnabled  true  4
    start_sending_packets_simultaneously
    sleep  10
    stop_sending_simultaneously_and_verify_packets
    Verify Alarm is not Active on gNB  PLR threshold crossed on TWAMP-1
    Verify Alarm is not Active on gNB  PLR threshold crossed on TWAMP-3
    Verify Alarm is not Active on gNB  RTT threshold crossed on TWAMP-1
    Verify Alarm is not Active on gNB  RTT threshold crossed on TWAMP-3

5GC000994_A_09_TWAMP Sender - session statistics
    configure_responder
    perform_du_commissioning  ${A_08_scf_path}
    sleep  30
    check_twamp_counters  expected_1min=0  expected_15min=0  expected_txtwampmessages=@{txtwampmessages_zero}
    sleep  60
    check_twamp_counters  expected_1min=!0  expected_15min=0  expected_txtwampmessages=@{txtwampmessages_1Min}
    ...  max_losttwampmessages=15
    sleep  240
    check_twamp_counters  expected_1min=!0  expected_15min=0  expected_txtwampmessages=@{txtwampmessages_5Min}
    ...  max_losttwampmessages=75
    sleep  600
    check_twamp_counters  expected_1min=!0  expected_15min=!0  expected_txtwampmessages=@{txtwampmessages_15Min}
    ...  max_losttwampmessages=225
    introduce_jitter_and_packet_drop
    sleep   60
    verify_values_of_twamp_parameters_are_higher
    Run Keywords  remove_jitter_and_packet_drop
    ...  AND  stop_responder


5GC000994_A_08_TWAMP Sender - counters
    configure_responder
    perform_du_commissioning  ${A_08_scf_path}
    sleep  30
    check_twamp_counters  expected_1min=0  expected_15min=0  expected_txtwampmessages=@{txtwampmessages_zero}
    sleep  60
    check_twamp_counters  expected_1min=!0  expected_15min=0  expected_txtwampmessages=@{txtwampmessages_1Min}
    ...  max_losttwampmessages=15
    sleep  900
    check_pm_twamp_counters  expected_15min=!0  expected_txtwampmessages=@{txtwampmessages_not_zero}
    ...  max_losttwampmessages=15
    introduce_jitter_and_packet_drop
    sleep   900
    compare_values_of_pm_twamp_parameters  HIGHER
    remove_jitter_and_packet_drop
    change_pmtnl_twamp_statistics_interval_parameter  disabled
    check_pm_twamp_counters  expected_15min=!0  expected_txtwampmessages=@{txtwampmessages_not_zero}
    sleep  900
    compare_values_of_pm_twamp_parameters  EQUAL
    change_pmtnl_twamp_statistics_interval_parameter  30min
    wait_for_counter_change
    get_pm_twamp_counters  overwrite=True
    sleep  900
    compare_values_of_pm_twamp_parameters  EQUAL
    sleep  900
    @{counter_list}=    Create List    M51331C0  M51331C1
    compare_values_of_pm_twamp_parameters  UNEQUAL  ${counter_list}
    stop_responder

5GC000994_C_55_TWAMP enhancements - ingress rate limit for combined traffic of all configured TWAMP reflector and UDP echo server
    change_administrative_state_parameter  locked  2
    change_twamp_reflector_parameter  twampReflectorUdpEchoEnabled  true  1
    change_twamp_reflector_parameter  twampReflectorEnabled  true  1
    ${counter} =  get_iprmdroppedpacketsratelimiting_counter
    configure_multiple_twamp_senders  2  5018  options=-c 2000
    sleep  5
    kill_all_twampy_processes
    check_dropped_packets  0  5
    configure_multiple_twamp_senders  4  5018  port1=True  options=-c 2000
    sleep  10
    kill_all_twampy_processes
    check_dropped_packets  45  55
    configure_multiple_twamp_senders  2  7  options=-v -c 100000
    sleep  2
    kill_all_twampy_processes
    check_received_packets  0  10
    configure_multiple_twamp_senders  140  7  18  options=-v -c 100000
    sleep  2
    kill_all_twampy_processes
    check_received_packets  45  55
    sleep  900
    Verify Alarm is not Active on gNB  RTT_THRESHOLD_CROSSED
    Verify Alarm is not Active on gNB  PLR_THRESHOLD_CROSSED
    verify_iprmdroppedpacketsratelimiting_counter_is_higher  ${counter}


5GC000994_C_49_TWAMP enhancements - number of simultaneous TWAMP sender sessions
    perform_du_commissioning  ${C_49_scf_path}
    wait for on air
    configure_multiple_twamp_reflectors
    verify_sessions  sessions=99  version=5G21B
    kill_all_twampy_processes
    ${du_scf_old_path} =  get_bts_configuration_via_gui
    ${du_scf_new_path} =  add_twamp_100  ${du_scf_old_path}
    perform_du_commissioning  ${du_scf_new_path}
    wait for on air
    configure_multiple_twamp_reflectors
    verify_sessions  sessions=100  version=5G21B
    kill_all_twampy_processes
