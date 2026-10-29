*** Settings ***
Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com

Library         ute_ue

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource        testsuite/Wroclaw/RRM/resources/logs.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/FGCR-10143/resources/kw_fgcr10143.robot
#Resource        ./resources/test_emil.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/dcap/dcap.robot

Suite Setup     Run keyword
...             Setup attenuators

Test Teardown   Run Keyword
...    Delete active DCAP trace for BTS   host=10.44.90.145


*** Variables ***
${tput_DL_bandwith_10143}     1000 Mbits/sec
${tput_UL_bandwith_10143}     50 MBits/sec
${tput_deviation}       10%
${tput_duration_10143}        60s
${Packet_Size}          1200

*** Test Cases ***
[1]FGCR-10143-A_05_RRC_Connection_release_with_cellReselectionPriorities_IE_procedure_TDD_to_FDD_multiple_targets_with_CA_setup
    [Documentation]   The purpose of this test is to verify that gNB is supporting simplified Idle Mode Mobillity
    ...               steering for multiple targets from TDD to FDD with CA setup.
    # Start syslog collection
    # sleep  10s
    # Setup attenuators
    # Set attenuators for 10143
    # Connect to RUDE
    # Initialize RUDE
    sleep  10s
    # Reset rule on RUDE
    # Start rule on RUDE
    # Set delay on RUDE  delay_value=1500  delay_ratio=10
    # Reset rule on RUDE
    # Disconnect RUDE
    # sleep  100s
    # Attach UE SA For test
    # Set attenuation and check  lines=${lines_gNB_190_AHLOA_1_FDD}   value=14
    # Waiting for RRC idle
    # Start ULDL UDP SA  ${tput_DL_bandwith_10143}   ${tput_UL_bandwith_10143}   ${tput_duration_10143}
    # Stop syslog collection
    # sleep  10s
    # # Log to console   send sshpass
    # # Run Keyword and Ignore Error   Verify ULDL UDP SA     ${tput_DL_bandwith_10143}   ${tput_UL_bandwith_10143}
    # # Verify TDD Cell RRC_realese triggered by user inactivity
    # # Verify RRC_realese contains freqPriorityListNR
    # # Verify TDD SCell configuration
    # # Verify TDD SCell activation
    # Log to console  Waiting for counter updete 120s
    # sleep  120s
    # Verify PM Counters for 10143

# [1]FGCR-10143-A_05_RRC_Connection_release_with_cellReselectionPriorities_IE_procedure_TDD_to_FDD_multiple_targets_with_CA_setup
#     [Documentation]   The purpose of this test is to verify that gNB is supporting simplified Idle Mode Mobillity
#     ...               steering for multiple targets from TDD to FDD with CA setup.
#     Start syslog collection
#     sleep  10s
#     Setup attenuators
#     Set attenuators for 10143

#     sleep  100s
#     Attach UE SA For test
#     Set attenuation and check  lines=${lines_gNB_190_AHLOA_1_FDD}   value=14
#     Waiting for RRC idle
#     Start ULDL UDP SA  ${tput_DL_bandwith_10143}   ${tput_UL_bandwith_10143}   ${tput_duration_10143}
#     Stop syslog collection
#     sleep  260s
#     Log to console   send sshpass
#     Run Keyword and Ignore Error   Verify ULDL UDP SA     ${tput_DL_bandwith_10143}   ${tput_UL_bandwith_10143}
#     Verify TDD Cell RRC_realese triggered by user inactivity
#     Verify RRC_realese contains freqPriorityListNR
#     Verify TDD SCell configuration
#     Verify TDD SCell activation
#     Log to console  Waiting for counter updete 120s
#     sleep  120s
#     Verify PM Counters for 10143
