*** Settings ***
Documentation
...    Test suite for regression testing for feature CB007517
...    authors: Wioleta Święs, Bartłomiej Bieńko
...    maintainer: Wioleta Święs, Bartłomiej Bieńko
...    group: RAN_PZ_KRK_SG_7
...    contact: I_5G_PZ_MMW_KRK_7SG_TEST@internal.nsn.com, wioleta.swies@nokia.com, bartlomiej.bienko@nokia.com


Library     ./resources/keywords.py    WITH NAME    keywords7517
Library     OperatingSystem
Resource    ../resources/resources.robot
Variables     ./resources/variables.py


Suite Setup    Run keywords    Create Suite Attenuator Instance   port_no=${attenuator_gNB_port_no}    AND
...                            Turn Off Attenuation On Many Ports    attenuator=${attenuator}
...                                                                  ports=${attenuator_tl_ports}    AND
...                            Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
...                                                                                 should_5G_neighbour_be_changed=${False}
...                                                                                 increase_time_for_checking_bbmod=600
...                                                                                 increase_timeout_for_update_sw=1800
...                                                                                 increase_time_for_checking_radios=2100

Test Setup       Common Preconditions With Watching Alarms
Test Teardown    Common Postconditions With Watching Alarms


*** Test Cases ***
[1]B7_FR2_inter-frequency_A4_meas_for_mobility_removed_when_A3_A5_meas_for_FR2_inter-frequency_is_configured_in_the_UE_on
    [Tags]    B7
    Set Test Variable    ${output test dir}    ${OUTPUT DIR}/TEST_B07
    Create Directory     ${output test dir}

    Toggle A2MeashoEnabled    enabled=${True}
    Toggle A2MeashoEnabledSA    enabled=${False}

    # Ensure to turn off attenuation
    Turn Off Attenuation    attenuator=${attenuator}

    # HO Events Timers Configuration
    Set Test Variable    ${fr1_supervision_timer}    10000
    Set Test Variable    ${fr2_supervision_timer}    10000
    Set Test Variable    ${a4MeasMaxNumber}          10
    Set Test Variable    ${a4RetryTimer}             ${10}

    Set A4 Periodic Meas Control Nsa    fr1_supervision_timer=${fr1_supervision_timer}
    ...                                 fr2_supervision_timer=${fr2_supervision_timer}
    ...                                 meas_max_number=${a4MeasMaxNumber}
    ...                                 retry_timer=${a4RetryTimer}
    ...                                 cell_id=${1}

    # Threshold Configuration
    Set Test Variable    ${a1ThresholdhoSsbRsrp}    71
    Set Test Variable    ${a2ThresholdhoSsbRsrp}    70
    Set A1 Measho Ssb Rsrp    a1ThresholdhoSsbRsrp=${a1ThresholdhoSsbRsrp}
    Set A2 Measho Ssb Rsrp    a2ThresholdhoSsbRsrp=${a2ThresholdhoSsbRsrp}

    # Prevent HO by modyfing ssbFrequencies within NRHOIFs to make them not corresponding to any neighbouring gNB
    keywords7517.Change SsbFrequencies by JSON    proper=${False}

    # Event configuration on NRHOIFs
    Toggle Events A On Desired NRHOIFs    mapping=${nrhoif_event_configuration_B7}

    # Attenuation-related variables
    Set Test Variable    ${begin_attenuation}       0dB
    Set Test Variable    ${attenuation}             40dB
    ${delay}=    Evaluate Attenuation Delay         retry_timer_sec=${a4RetryTimer}
    Set Test Variable    ${attenuation_duration}    ${30}

    # Save Site and NRHOIF Configuration  to Robot's logs directory
    Set Test Variable    ${SCF_file_name}            CB007517_B07_${tl.gnbs[${0}].global_bts_id}.xml

    Save SCF Of Desired gNB In Robot Logs Directory    gnb_instance_index=${0}
    ...                                                path=${output test dir}
    ...                                                file_name=${SCF_file_name}

    Save NRHOIF Configuration To Python Module    path_to_module=${output test dir}/nrhoif.py

    pcap.Start Pcap Logs
    Verify Tput with Attenuated Signal    begin_attenuation=${begin_attenuation}
    ...                                   attenuator=${attenuator}
    ...                                   attenuation=${attenuation}
    ...                                   delay=${delay}
    ...                                   attenuation_duration=${attenuation_duration}
    pcap.Stop Pcap Logs

    # PCAP LOG ANALYSIS
    @{packet_list}    pcap.Get Packet List    file_name=${TEST_NAME}_    dir_path=${output test dir}
    &{packet_with_types}    Map Packet Types With Indexes    packet_list=@{packet_list}

    # STEP NO. 1
    Log To Console    PACKET ANALYSIS FOR STEP 01
    ${packet_to_check}    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                             packet_type=RRCReconfiguration
    ...                                             n=${1}
    Has Rrcreconfiguration Configured Proper Events    packet=${packet_to_check}
    ...                                                contain=A2
    ...                                                not_contain=A4
    &{events_with_report_config_id}=     Get Events With Associated Report Config Ids    packet=${packet_to_check}
    @{measIds_with_event_types}=         Get MeasId With Event Types From Packet         packet=${packet_to_check}

    # STEP NO. 2
    Log To Console    PACKET ANALYSIS FOR STEP 02
    ${packet_to_check}    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                             packet_type=RRCReconfiguration
    ...                                             n=${2}
    Has RRCReconfiguration Drx Config Setup    packet=${packet_to_check}

    # STEP NO. 3
    Log To Console    PACKET ANALYSIS FOR STEP 03
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=SgNBModificationRequest
    ...                                                 reference_packet_type=RRCReconfiguration
    ...                                                 index_of_reference=${2}
    Has SgNBModificationRequest Meas Gap Config Setup    packet=${packet_to_check}

    # STEP NO. 4
    Log To Console    PACKET ANALYSIS FOR STEP 04
    @{nrhoifs}=    Get All Nrhoif Configuration List
    ${packet_to_check}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=RRCReconfiguration
    ...                                              n=${3}
    Has RRCReconfiguration Proper Frequencies For Event    packet=${packet_to_check}
    ...                                                    event=A4
    ...                                                    nrhoifs=@{nrhoifs}

    # STEP NO. 5
    Log To Console    PACKET ANALYSIS FOR STEP 05
    ${packet_to_check}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=RRCReconfiguration
    ...                                              n=${3}
    # TODO: generalize this KW to checking any (not only A4) event
    has RRCReconfiguration Proper Threshold For Event A4    packet=${packet_to_check}
    ...                                                     nrhoifs=@{nrhoifs}

    # STEP NO. 6
    Log To Console    PACKET ANALYSIS FOR STEP 06
    ${packet_to_check}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=RRCReconfiguration
    ...                                              n=${3}
    # TODO: fix Is MeasId Order Correct method
    Is MeasId Order Correct    packet=${packet_to_check}
    ...                        event_type=A4
    ...                        nrhoifs=@{nrhoifs}
    ${a4_reportConfigId}=    Get ReportConfigId For Event    packet=${packet_to_check}
    ...                                                      event=A4

    # STEP NO. 7
    Log To Console    PACKET ANALYSIS FOR STEP 07
    ${packet_to_check}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=Measurement${SPACE}Report
    ...                                              n=${1}
    Has Measurement Report Meas Id For Event    packet=${packet_to_check}
    ...                                         measIds_with_event_type=@{measIds_with_event_types}
    ...                                         event_type=A2

    # STEP NO. 8
    Log To Console    PACKET ANALYSIS FOR STEP 08
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}
    Has RRCReconfiguration Proper Frequencies For Event    packet=${packet_to_check}
    ...                                                    event=A3
    ...                                                    nrhoifs=@{nrhoifs}
    Has RRCReconfiguration Proper Frequencies For Event    packet=${packet_to_check}
    ...                                                    event=A5
    ...                                                    nrhoifs=@{nrhoifs}
    # STEP NO. 9
    Log To Console    PACKET ANALYSIS FOR STEP 09
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}
    # TODO: fix Has Rrc Reconfiguration Meas Id Removed
    Has Rrc Reconfiguration Meas Id Removed    packet=${packet_to_check}
    ...                                        measIds=@{measIds_with_event_types}
    ...                                        event_to_remove=A2

    # STEP NO. 10
    Log To Console    PACKET ANALYSIS FOR STEP 10
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}
    Has Packet MeasGapConfig    packet=${packet_to_check}

    # STEP NO. 11
    Log To Console    PACKET ANALYSIS FOR STEP 11
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}
    Has Rrcreconfiguration Configured Proper Event    packet=${packet_to_check}
    ...                                               event_type=A1
    @{measIds_with_event_types}=     Update MeasId With Event Types    packet=${packet_to_check}
    ...                                                                previous_measId_list=@{measIds_with_event_types}

    # STEP NO. 12
    Log To Console    PACKET ANALYSIS FOR STEP 12
    ${packet_to_check}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=Measurement${SPACE}Report
    ...                                              n=${2}
    Has Measurement Report Meas Id For Event    packet=${packet_to_check}
    ...                                         measIds_with_event_type=@{measIds_with_event_types}
    ...                                         event_type=A1

    # STEP NO. 13
    Log To Console    PACKET ANALYSIS FOR STEP 13
    ${addition_packet}    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                             packet_type=RRCReconfiguration
    ...                                             n=${1}
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${2}
    @{addition_packet_meas_ids}=    Get MeasId From Packet    packet=${addition_packet}
    @{packet_to_check_meas_ids}=    Get MeasId From Packet    packet=${packet_to_check}
    Are Meas Ids List Equal    meas_ids_1=@{addition_packet_meas_ids}
    ...                        meas_ids_2=@{packet_to_check_meas_ids}
    [Teardown]    Run Keywords    pcap.Stop Pcap Logs    AND
    ...                           keywords7517.Change SsbFrequencies by JSON    proper=${True}    AND
    ...                           keywords7517.Restore Default NRHOIF Events Configuration    AND
    ...                           Common Postconditions With Watching Alarms

[1]B11_FR1_inter-frequency_A4_meas_for_mobility_removed_when_A3_A5_meas_for_FR2_inter-frequency_is_configured_in_the_UE_on
    [Tags]    B11
    Set Test Variable    ${output test dir}    ${OUTPUT DIR}/TEST_B11
    Create Directory     ${output test dir}

    Toggle A2MeashoEnabled    enabled=${True}
    Toggle A2MeashoEnabledSA    enabled=${False}

    # Ensure to turn off attenuation
    Turn Off Attenuation    attenuator=${attenuator}

    # HO Events Timers Configuration
    Set Test Variable    ${fr1_supervision_timer}    10000
    Set Test Variable    ${fr2_supervision_timer}    10000
    Set Test Variable    ${a4MeasMaxNumber}          10
    Set Test Variable    ${a4RetryTimer}             ${10}

    Set A4 Periodic Meas Control Nsa    fr1_supervision_timer=${fr1_supervision_timer}
    ...                                 fr2_supervision_timer=${fr2_supervision_timer}
    ...                                 meas_max_number=${a4MeasMaxNumber}
    ...                                 retry_timer=${a4RetryTimer}
    ...                                 cell_id=${1}

    # Threshold Configuration
    Set Test Variable    ${a1ThresholdhoSsbRsrp}     71
    Set Test Variable    ${a2ThresholdhoSsbRsrp}     70
    Set A1 Measho Ssb Rsrp    a1ThresholdhoSsbRsrp=${a1ThresholdhoSsbRsrp}
    Set A2 Measho Ssb Rsrp    a2ThresholdhoSsbRsrp=${a2ThresholdhoSsbRsrp}

    # Prevent HO by modyfing ssbFrequencies within NRHOIFs to make them not corresponding to any neighbouring gNB
    keywords7517.Change SsbFrequencies by JSON    proper=${False}

    # Event configuration on NRHOIFs
    Toggle Events A On Desired NRHOIFs    mapping=${nrhoif_event_configuration_B11}

    # Attenuation-related variables
    Set Test Variable    ${begin_attenuation}       0dB
    Set Test Variable    ${attenuation}             40dB
    ${delay}=    Evaluate Attenuation Delay         retry_timer_sec=${a4RetryTimer}
    Set Test Variable    ${attenuation_duration}    ${30}

    # Save Site and NRHOIF Configuration  to Robot's logs directory
    Set Test Variable    ${SCF_file_name}            CB007517_B11_${tl.gnbs[${0}].global_bts_id}.xml

    Save SCF Of Desired gNB In Robot Logs Directory    gnb_instance_index=${0}
    ...                                                path=${output test dir}
    ...                                                file_name=${SCF_file_name}

    Save NRHOIF Configuration To Python Module    path_to_module=${output test dir}/nrhoif.py

    pcap.Start Pcap Logs
    Verify Tput with Attenuated Signal    begin_attenuation=${begin_attenuation}
    ...                                   attenuator=${attenuator}
    ...                                   attenuation=${attenuation}
    ...                                   delay=${delay}
    ...                                   attenuation_duration=${attenuation_duration}
    pcap.Stop Pcap Logs

    # PCAP LOG ANALYSIS
    @{packet_list}    pcap.Get Packet List    file_name=${TEST_NAME}_    dir_path=${output test dir}
    &{packet_with_types}    Map Packet Types With Indexes    packet_list=@{packet_list}

    # STEP NO. 1
    Log To Console    PACKET ANALYSIS FOR STEP 01
    ${packet_to_check}    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                             packet_type=RRCReconfiguration
    ...                                             n=${1}
    Has Rrcreconfiguration Configured Proper Events    packet=${packet_to_check}
    ...                                                contain=A2
    ...                                                not_contain=A4
    &{events_with_report_config_id}=     Get Events With Associated Report Config Ids    packet=${packet_to_check}
    @{measIds_with_event_types}=     Get MeasId With Event Types From Packet    packet=${packet_to_check}

    # STEP NO. 2
    Log To Console    PACKET ANALYSIS FOR STEP 02
    ${packet_to_check}    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                             packet_type=RRCReconfiguration
    ...                                             n=${2}
    Has RRCReconfiguration Drx Config Setup    packet=${packet_to_check}

    # STEP NO. 3
    Log To Console    PACKET ANALYSIS FOR STEP 03
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=SgNBModificationRequest
    ...                                                 reference_packet_type=RRCReconfiguration
    ...                                                 index_of_reference=${2}
    Has SgNBModificationRequest Meas Gap Config Setup    packet=${packet_to_check}

    # STEP NO. 4
    Log To Console    PACKET ANALYSIS FOR STEP 04
    @{nrhoifs}=    Get All Nrhoif Configuration List
    ${packet_to_check}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=RRCReconfiguration
    ...                                              n=${3}
    Has RRCReconfiguration Proper Frequencies For Event    packet=${packet_to_check}
    ...                                                    event=A4
    ...                                                    nrhoifs=@{nrhoifs}

    # STEP NO. 5
    Log To Console    PACKET ANALYSIS FOR STEP 05
    ${packet_to_check}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=RRCReconfiguration
    ...                                              n=${3}
    has RRCReconfiguration Proper Threshold For Event A4    packet=${packet_to_check}
    ...                                                     nrhoifs=@{nrhoifs}

    # STEP NO. 6
    Log To Console    PACKET ANALYSIS FOR STEP 06
    ${packet_to_check}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=RRCReconfiguration
    ...                                              n=${3}
    Is MeasId Order Correct    packet=${packet_to_check}     nrhoifs=@{nrhoifs}
    ${a4_reportConfigId}=    Get ReportConfigId For Event    packet=${packet_to_check}
    ...                                                      event=A4

    # STEP NO. 7
    Log To Console    PACKET ANALYSIS FOR STEP 07
    ${packet_to_check}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=Measurement${SPACE}Report
    ...                                              n=${1}
    Has Measurement Report Meas Id For Event    packet=${packet_to_check}
    ...                                         measIds_with_event_type=@{measIds_with_event_types}
    ...                                         event_type=A2

    # STEP NO. 8
    Log To Console    PACKET ANALYSIS FOR STEP 08
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}
    Has RRCReconfiguration Proper Frequencies For Event    packet=${packet_to_check}
    ...                                                    event=A5
    ...                                                    nrhoifs=@{nrhoifs}

    # STEP NO. 9
    Log To Console    PACKET ANALYSIS FOR STEP 09
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}
    Has Rrc Reconfiguration Meas Id Removed    packet=${packet_to_check}
    ...                                        measIds=@{measIds_with_event_types}
    ...                                        event_to_remove=A2

    # STEP NO. 10
    Log To Console    PACKET ANALYSIS FOR STEP 10
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}
    has_packet_measGapConfig    packet=${packet_to_check}

    # STEP NO. 11
    Log To Console    PACKET ANALYSIS FOR STEP 11
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}
    Has Rrcreconfiguration Configured Proper Event    packet=${packet_to_check}
    ...                                               event_type=A1
    @{measIds_with_event_types}=     Update MeasId With Event Types    packet=${packet_to_check}
    ...                                                                previous_measId_list=@{measIds_with_event_types}

    # STEP NO. 12
    Log To Console    PACKET ANALYSIS FOR STEP 12
    ${packet_to_check}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=Measurement${SPACE}Report
    ...                                              n=${2}
    Has Measurement Report Meas Id For Event    packet=${packet_to_check}
    ...                                         measIds_with_event_type=@{measIds_with_event_types}
    ...                                         event_type=A1

    # STEP NO. 13
    Log To Console    PACKET ANALYSIS FOR STEP 13
    ${addition_packet}    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                             packet_type=RRCReconfiguration
    ...                                             n=${1}
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${2}
    @{addition_packet_meas_ids}=    Get MeasId From Packet    packet=${addition_packet}
    @{packet_to_check_meas_ids}=    Get MeasId From Packet    packet=${packet_to_check}
    Are Meas Ids List Equal    meas_ids_1=@{addition_packet_meas_ids}
    ...                        meas_ids_2=@{packet_to_check_meas_ids}
    [Teardown]    Run Keywords    pcap.Stop Pcap Logs    AND
    ...                           keywords7517.Change SsbFrequencies by JSON    proper=${True}    AND
    ...                           keywords7517.Restore Default NRHOIF Events Configuration    AND
    ...                           Common Postconditions With Watching Alarms

[1]B12_FR2_inter-frequency_A4_meas_for_mobility_removed_when_A3_A5_meas_for_FR1_inter-frequency_is_configured_in_the_UE_on
    [Tags]    B12
    Set Test Variable    ${output test dir}    ${OUTPUT DIR}/TEST_B12
    Create Directory     ${output test dir}

    Toggle A2MeashoEnabled    enabled=${True}
    Toggle A2MeashoEnabledSA    enabled=${False}

    # Ensure to turn off attenuation
    Turn Off Attenuation    attenuator=${attenuator}

    # HO Events Timers Configuration
    Set Test Variable    ${fr1_supervision_timer}    10000
    Set Test Variable    ${fr2_supervision_timer}    10000
    Set Test Variable    ${a4MeasMaxNumber}          10
    Set Test Variable    ${a4RetryTimer}             ${10}

    Set A4 Periodic Meas Control Nsa    fr1_supervision_timer=${fr1_supervision_timer}
    ...                                 fr2_supervision_timer=${fr2_supervision_timer}
    ...                                 meas_max_number=${a4MeasMaxNumber}
    ...                                 retry_timer=${a4RetryTimer}
    ...                                 cell_id=${1}

    # Threshold Configuration
    Set Test Variable   ${a1ThresholdhoSsbRsrp}     71
    Set Test Variable   ${a2ThresholdhoSsbRsrp}     70
    Set A1 Measho Ssb Rsrp    a1ThresholdhoSsbRsrp=${a1ThresholdhoSsbRsrp}
    Set A2 Measho Ssb Rsrp    a2ThresholdhoSsbRsrp=${a2ThresholdhoSsbRsrp}

    # Prevent HO by modyfing ssbFrequencies within NRHOIFs to make them not corresponding to any neighbouring gNB
    keywords7517.Change SsbFrequencies by JSON    proper=${False}

    # Event configuration on NRHOIFs
    Toggle Events A On Desired NRHOIFs    mapping=${nrhoif_event_configuration_B12}

    # Attenuation-related variables
    Set Test Variable    ${begin_attenuation}       0dB
    Set Test Variable    ${attenuation}             40dB
    ${delay}=    Evaluate Attenuation Delay         retry_timer_sec=${a4RetryTimer}
    Set Test Variable    ${attenuation_duration}    ${30}


    # Save Site and NRHOIF Configuration  to Robot's logs directory
    Set Test Variable    ${SCF_file_name}            CB007517_B12_${tl.gnbs[${0}].global_bts_id}.xml

    Save SCF Of Desired gNB In Robot Logs Directory    gnb_instance_index=${0}
    ...                                                path=${output test dir}
    ...                                                file_name=${SCF_file_name}

    Save NRHOIF Configuration To Python Module    path_to_module=${output test dir}/nrhoif.py

    pcap.Start Pcap Logs
    Verify Tput with Attenuated Signal    begin_attenuation=${begin_attenuation}
    ...                                   attenuator=${attenuator}
    ...                                   attenuation=${attenuation}
    ...                                   delay=${delay}
    ...                                   attenuation_duration=${attenuation_duration}
    pcap.Stop Pcap Logs

    # PCAP LOG ANALYSIS
    @{packet_list}    pcap.Get Packet List    file_name=${TEST_NAME}_    dir_path=${output test dir}
    &{packet_with_types}    Map Packet Types With Indexes    packet_list=@{packet_list}

    # STEP NO. 1
    Log To Console    PACKET ANALYSIS FOR STEP 01
    ${packet_to_check}    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                             packet_type=RRCReconfiguration
    ...                                             n=${1}
    Has Rrcreconfiguration Configured Proper Events    packet=${packet_to_check}
    ...                                                contain=A2
    ...                                                not_contain=A4
    &{events_with_report_config_id}=     Get Events With Associated Report Config Ids    packet=${packet_to_check}
    @{measIds_with_event_types}=     Get MeasId With Event Types From Packet    packet=${packet_to_check}

    # STEP NO. 2
    Log To Console    PACKET ANALYSIS FOR STEP 02
    ${packet_to_check}    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                             packet_type=RRCReconfiguration
    ...                                             n=${2}
    Has RRCReconfiguration Drx Config Setup    packet=${packet_to_check}

    # STEP NO. 3
    Log To Console    PACKET ANALYSIS FOR STEP 03
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=SgNBModificationRequest
    ...                                                 reference_packet_type=RRCReconfiguration
    ...                                                 index_of_reference=${2}
    Has SgNBModificationRequest Meas Gap Config Setup    packet=${packet_to_check}

    # STEP NO. 4
    Log To Console    PACKET ANALYSIS FOR STEP 04
    @{nrhoifs}=    Get All Nrhoif Configuration List
    ${packet_to_check}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=RRCReconfiguration
    ...                                              n=${3}
    Has RRCReconfiguration Proper Frequencies For Event    packet=${packet_to_check}
    ...                                                    event=A4
    ...                                                    nrhoifs=@{nrhoifs}

    # STEP NO. 5
    Log To Console    PACKET ANALYSIS FOR STEP 05
    ${packet_to_check}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=RRCReconfiguration
    ...                                              n=${3}
    has RRCReconfiguration Proper Threshold For Event A4    packet=${packet_to_check}
    ...                                                     nrhoifs=@{nrhoifs}

    # STEP NO. 6
    Log To Console    PACKET ANALYSIS FOR STEP 06
    ${packet_to_check}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=RRCReconfiguration
    ...                                              n=${3}
    Is MeasId Order Correct    packet=${packet_to_check}     nrhoifs=@{nrhoifs}
    ${a4_reportConfigId}=    Get ReportConfigId For Event    packet=${packet_to_check}
    ...                                                      event=A4

    # STEP NO. 7
    Log To Console    PACKET ANALYSIS FOR STEP 07
    ${packet_to_check}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=Measurement${SPACE}Report
    ...                                              n=${1}
    Has Measurement Report Meas Id For Event    packet=${packet_to_check}
    ...                                         measIds_with_event_type=@{measIds_with_event_types}
    ...                                         event_type=A2

    # STEP NO. 8
    Log To Console    PACKET ANALYSIS FOR STEP 08
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}
    Has RRCReconfiguration Proper Frequencies For Event    packet=${packet_to_check}
    ...                                                    event=A5
    ...                                                    nrhoifs=@{nrhoifs}

    # STEP NO. 9
    Log To Console    PACKET ANALYSIS FOR STEP 09
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}
    Has Rrc Reconfiguration Meas Id Removed    packet=${packet_to_check}
    ...                                        measIds=@{measIds_with_event_types}
    ...                                        event_to_remove=A2

    # STEP NO. 10
    Log To Console    PACKET ANALYSIS FOR STEP 10
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}
    has_packet_measGapConfig    packet=${packet_to_check}

    # STEP NO. 11
    Log To Console    PACKET ANALYSIS FOR STEP 11
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}
    Has Rrcreconfiguration Configured Proper Event    packet=${packet_to_check}
    ...                                               event_type=A1
    @{measIds_with_event_types}=     Update MeasId With Event Types    packet=${packet_to_check}
    ...                                                                previous_measId_list=@{measIds_with_event_types}

    # STEP NO. 12
    Log To Console    PACKET ANALYSIS FOR STEP 12
    ${packet_to_check}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=Measurement${SPACE}Report
    ...                                              n=${2}
    Has Measurement Report Meas Id For Event    packet=${packet_to_check}
    ...                                         measIds_with_event_type=@{measIds_with_event_types}
    ...                                         event_type=A1

    # STEP NO. 13
    Log To Console    PACKET ANALYSIS FOR STEP 13
    ${addition_packet}    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                             packet_type=RRCReconfiguration
    ...                                             n=${1}
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${2}
    @{addition_packet_meas_ids}=    Get MeasId From Packet    packet=${addition_packet}
    @{packet_to_check_meas_ids}=    Get MeasId From Packet    packet=${packet_to_check}
    Are Meas Ids List Equal    meas_ids_1=@{addition_packet_meas_ids}
    ...                        meas_ids_2=@{packet_to_check_meas_ids}
    [Teardown]    Run Keywords    pcap.Stop Pcap Logs    AND
    ...                           keywords7517.Change SsbFrequencies by JSON    proper=${True}    AND
    ...                           keywords7517.Restore Default NRHOIF Events Configuration    AND
    ...                           Common Postconditions With Watching Alarms

[1]B13_Successful_removal_of_Inter-frequency_A3_and_or_A5_and_configuration_of_A2_meas_after_A1_MR_is_received
    [Tags]    B13
    Set Test Variable    ${output test dir}    ${OUTPUT DIR}/TEST_B13
    Create Directory     ${output test dir}

    Toggle A2MeashoEnabled      enabled=${True}
    Toggle A2MeashoEnabledSA    enabled=${False}

    # Ensure to turn off attenuation
    Turn Off Attenuation    attenuator=${attenuator}

    # HO Events Timers Configuration
    Set Test Variable    ${fr1_supervision_timer}    10000
    Set Test Variable    ${fr2_supervision_timer}    10000
    Set Test Variable    ${a4MeasMaxNumber}          10
    Set Test Variable    ${a4RetryTimer}             60

    Set A4 Periodic Meas Control Nsa    fr1_supervision_timer=${fr1_supervision_timer}
    ...                                 fr2_supervision_timer=${fr2_supervision_timer}
    ...                                 meas_max_number=${a4MeasMaxNumber}
    ...                                 retry_timer=${a4RetryTimer}
    ...                                 cell_id=${1}

    # Threshold Configuration
    Set Test Variable   ${a1ThresholdhoSsbRsrp}     71
    Set Test Variable   ${a2ThresholdhoSsbRsrp}     70
    Set A1 Measho Ssb Rsrp    a1ThresholdhoSsbRsrp=${a1ThresholdhoSsbRsrp}
    Set A2 Measho Ssb Rsrp    a2ThresholdhoSsbRsrp=${a2ThresholdhoSsbRsrp}

    # Prevent HO by modyfing ssbFrequencies within NRHOIFs to make them not corresponding to any neighbouring gNB
    keywords7517.Change SsbFrequencies by JSON    proper=${False}

    # Event configuration on NRHOIFs
    Toggle Events A On Desired NRHOIFs    mapping=${nrhoif_event_configuration_B13}

    # Attenuation-related variables
    Set Test Variable    ${begin_attenuation}       0dB
    Set Test Variable    ${attenuation}             40dB
    Set Test Variable    ${delay}                   ${8}
    Set Test Variable    ${attenuation_duration}    ${15}

    # Save Site and NRHOIF Configuration  to Robot's logs directory
    Set Test Variable    ${SCF_file_name}            CB007517_B13_${tl.gnbs[${0}].global_bts_id}.xml

    Save SCF Of Desired gNB In Robot Logs Directory    gnb_instance_index=${0}
    ...                                                path=${output test dir}
    ...                                                file_name=${SCF_file_name}

    Save NRHOIF Configuration To Python Module    path_to_module=${output test dir}/nrhoif.py

    pcap.Start Pcap Logs
    Verify Tput with Attenuated Signal    begin_attenuation=${begin_attenuation}
    ...                                   attenuator=${attenuator}
    ...                                   attenuation=${attenuation}
    ...                                   delay=${delay}
    ...                                   attenuation_duration=${attenuation_duration}
    pcap.Stop Pcap Logs

    # PCAP LOG ANALYSIS
    @{packet_list}    pcap.Get Packet List    file_name=${TEST_NAME}_    dir_path=${output test dir}
    &{packet_with_types}    Map Packet Types With Indexes    packet_list=@{packet_list}

    # STEP NO. 1
    Log To Console    PACKET ANALYSIS FOR STEP 01
    ${packet_to_check}    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                             packet_type=RRCReconfiguration
    ...                                             n=${1}
    Has Rrcreconfiguration Configured Proper Events    packet=${packet_to_check}
    ...                                                contain=A2
    ...                                                not_contain=A4
    @{measIds_with_event_types}=     Get MeasId With Event Types From Packet    packet=${packet_to_check}
    ${a2_reportConfigId}=    Get ReportConfigId For Event    packet=${packet_to_check}    event=A2

    # STEP NO. 2
    Log To Console    PACKET ANALYSIS FOR STEP 02
    ${packet_to_check}    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                             packet_type=Measurement${SPACE}Report
    ...                                             n=${1}
    Has Measurement Report Meas Id For Event    packet=${packet_to_check}
    ...                                         measIds_with_event_type=@{measIds_with_event_types}
    ...                                         event_type=A2
    Has Measurement Report Meas Id For Event    packet=${packet_to_check}
    ...                                         measIds_with_event_type=@{measIds_with_event_types}
    ...                                         event_type=A4

    # STEP NO. 3
    Log To Console    PACKET ANALYSIS FOR STEP 03
    @{nrhoifs}=    Get All Nrhoif Configuration List
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}
    Has RRCReconfiguration Proper Frequencies For Event    packet=${packet_to_check}
    ...                                                    event=A3
    ...                                                    nrhoifs=@{nrhoifs}
    Has RRCReconfiguration Proper Frequencies For Event    packet=${packet_to_check}
    ...                                                    event=A5
    ...                                                    nrhoifs=@{nrhoifs}

    # STEP NO. 4
    Log To Console    PACKET ANALYSIS FOR STEP 04
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}
    Has Rrc Reconfiguration Meas Id Removed    packet=${packet_to_check}
    ...                                        measIds=@{measIds_with_event_types}
    ...                                        event_to_remove=A2

    # STEP NO. 5
    Log To Console    PACKET ANALYSIS FOR STEP 05
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}
    Has SgNBModificationRequest Meas Gap Config Setup    packet=${packet_to_check}

    # STEP NO. 6.
    Log To Console    PACKET ANALYSIS FOR STEP 06
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}
    Has Rrcreconfiguration Configured Proper Event    packet=${packet_to_check}
    ...                                               event_type=A1
    @{measIds_with_event_types}=     Update MeasId With Event Types    packet=${packet_to_check}
    ...                                                                previous_measId_list=@{measIds_with_event_types}

    # STEP NO. 7
    Log To Console    PACKET ANALYSIS FOR STEP 07
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}
    Has Measurement Report Meas Id For Event    packet=${packet_to_check}
    ...                                         measIds_with_event_type=@{measIds_with_event_types}
    ...                                         event_type=A1

    # STEP NO. 8
    Log To Console    PACKET ANALYSIS FOR STEP 08
    ${addition_packet}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=RRCReconfiguration
    ...                                              n=${1}
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${2}
    @{addition_packet_meas_ids}=    Get MeasId From Packet    packet=${addition_packet}
    @{packet_to_check_meas_ids}=    Get MeasId From Packet    packet=${packet_to_check}
    Are Meas Ids List Equal    meas_ids_1=@{addition_packet_meas_ids}
    ...                        meas_ids_2=@{packet_to_check_meas_ids}

    # STEP NO. 9
    Log To Console    PACKET ANALYSIS FOR STEP 09
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${2}
    Has RRCReconfiguration Drx Config Release    packet=${packet_to_check}
    [Teardown]    Run Keywords    pcap.Stop Pcap Logs    AND
    ...                           keywords7517.Change SsbFrequencies by JSON    proper=${True}    AND
    ...                           keywords7517.Restore Default NRHOIF Events Configuration    AND
    ...                           Common Postconditions With Watching Alarms

[1]B01_Configuration_of_FR2_inter_frequency_A4_meas_for_mobility_to_higher_NR_frequency_priority_after_SgNB_Addition_procedure
    [Tags]    B01
    Set Test Variable    ${output test dir}    ${OUTPUT DIR}/TEST_B01
    Create Directory     ${output test dir}

    Set Test Variable   ${a4_prio_freq_enabled}     rsrp
    Set Test Variable   ${fr1_supervision_timer}    5000
    Set Test Variable   ${fr2_supervision_timer}    10000
    Set Test Variable   ${meas_max_number}          10
    Set Test Variable   ${retry_timer}              20
    Set Test Variable   ${threshold_rsrp}           30
    Set Test Variable   ${hysteresis_rsrp}          0
    Set Test Variable   ${time_to_trigger_rsrp}     ms40
    Set Test Variable   ${event_type}               A4


    Set A4 Meas Higher Prio Freq Disabled    nrhoif_list=${NRHOIF_FR2}    cell_id=${1}

    ${PRIORITY_FOR_NRHOIF_1}=    Create List   1    1
    ${PRIORITY_FOR_NRHOIF_2}=    Create List   2    30
    ${PRIORITY_FOR_NRHOIF_3}=    Create List   3    1

    ${PRIORITY_LIST}=    Create List    ${PRIORITY_FOR_NRHOIF_1}    ${PRIORITY_FOR_NRHOIF_2}    ${PRIORITY_FOR_NRHOIF_3}

    Set A4 Higher Priority    priority_list=${PRIORITY_LIST}    cell_id=${1}

    Set A4 Periodic Meas Control Nsa    fr1_supervision_timer=${fr1_supervision_timer}
    ...                                 fr2_supervision_timer=${fr2_supervision_timer}
    ...                                 meas_max_number=${meas_max_number}
    ...                                 retry_timer=${retry_timer}
    ...                                 cell_id=${1}

    Set A4 Measurement Ssb Rsrp    hysteresis_rsrp=${hysteresis_rsrp}
    ...                            threshold_rsrp=${threshold_rsrp}
    ...                            time_to_trigger_rsrp=${time_to_trigger_rsrp}
    ...                            nrhoif_list=${1}
    ...                            cell_id=${1}

    ${target_pci}    Get Target PCI                       cell_num=${1}
    ${ssb_freq}      Get Arfcn Ssb Pbch    cell_id=${402}    gnb_instance_id=${1}

    # Save Site Configuration (SCF) to Robot's logs directory
    Set Test Variable    ${SCF_file_name_0}            CB007517_B01_${tl.gnbs[${0}].global_bts_id}.xml
    Save SCF Of Desired gNB In Robot Logs Directory    gnb_instance_index=${0}
    ...                                                path=${output test dir}
    ...                                                file_name=${SCF_file_name_0}

    Set Test Variable    ${SCF_file_name_1}            CB007517_B01_${tl.gnbs[${1}].global_bts_id}.xml
    Save SCF Of Desired gNB In Robot Logs Directory    gnb_instance_index=${1}
    ...                                                path=${output test dir}
    ...                                                file_name=${SCF_file_name_1}

    pcap.Start Pcap Logs
    Verify Tput
    pcap.Stop Pcap Logs
    @{packet_list}    pcap.Get Packet List    file_name=${TEST_NAME}_    dir_path=${output test dir}

    Verify Sgnb Additione Complete        ${packet_list}
    Verify Inter Gnb Handover Complete    ${packet_list}

    ${packet_to_check}    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                             packet_type=SgNBModificationRequestAcknowledge
    ...                                             n=${1}

    ${measurement_id}    Get Measurement Id    packet=${packet_to_check}
    ...                                        rsrp_value=${threshold_rsrp}
    ...                                        ssb_freq=${ssb_freq}
    ...                                        time_to_trigger=${time_to_trigger_rsrp}
    ...                                        event_type=${event_type}

    ${packet_to_check}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=Measurement${SPACE}Report
    ...                                              n=${1}

    Verify Measurement Report             packet=${packet_to_check}
    ...                                   target_pci=${target_pci}
    ...                                   measurement_id=${measurement_id}
   [Teardown]    Run keywords    pcap.Stop Pcap Logs    AND
    ...                          Common Postconditions With Watching Alarms

[1]B4_FR2_inter_frequency_A4_meas_for_mobility_configured_periodically_in_the_UE_on_an_NSA_3X_call_on_FR1_PSCell
    [Tags]    B04
    Set Test Variable    ${output test dir}    ${OUTPUT DIR}/TEST_B04
    Create Directory     ${output test dir}

    Set Test Variable   ${fr1_supervision_timer}    3000
    Set Test Variable   ${fr2_supervision_timer}    7000
    Set Test Variable   ${meas_max_number}          5
    Set Test Variable   ${retry_timer}              10
    Set Test Variable   ${threshold_rsrp}           120
    Set Test Variable   ${hysteresis_rsrp}          0
    Set Test Variable   ${time_to_trigger_rsrp}     ms40
    Set Test Variable   ${a4_prio_freq_enabled}     rsrp
    Set Test Variable   ${event_type}               A4

    Set A4 Meas Higher Prio Freq Disabled    nrhoif_list=${NRHOIF_FR2}    cell_id=${1}

    ${PRIORITY_FOR_NRHOIF_1}=    Create List   1    1
    ${PRIORITY_FOR_NRHOIF_2}=    Create List   2    30
    ${PRIORITY_FOR_NRHOIF_3}=    Create List   3    1

    ${PRIORITY_LIST}=    Create List    ${PRIORITY_FOR_NRHOIF_1}    ${PRIORITY_FOR_NRHOIF_2}    ${PRIORITY_FOR_NRHOIF_3}

    Set A4 Higher Priority    priority_list=${PRIORITY_LIST}    cell_id=${1}

    Set A4 Periodic Meas Control Nsa    fr1_supervision_timer=${fr1_supervision_timer}
    ...                                 fr2_supervision_timer=${fr2_supervision_timer}
    ...                                 meas_max_number=${meas_max_number}
    ...                                 retry_timer=${retry_timer}
    ...                                 cell_id=${1}

    Set A4 Measurement Ssb Rsrp         hysteresis_rsrp=${hysteresis_rsrp}
    ...                                 threshold_rsrp=${threshold_rsrp}
    ...                                 time_to_trigger_rsrp=${time_to_trigger_rsrp}
    ...                                 nrhoif_list=${NRHOIF_FR1}
    ...                                 cell_id=${1}

    ${freq_rsrsp_values}    Get Ssb Frequency And Rsrp    nrhoif_list=${NRHOIF_FR1}    cell_id=${1}

    # Save Site Configuration (SCF) to Robot's logs directory
    Set Test Variable    ${SCF_file_name_0}            CB007517_B04_${tl.gnbs[${0}].global_bts_id}.xml
    Save SCF Of Desired gNB In Robot Logs Directory    gnb_instance_index=${0}
    ...                                                path=${output test dir}
    ...                                                file_name=${SCF_file_name_0}

    Set Test Variable    ${SCF_file_name_1}            CB007517_B04_${tl.gnbs[${1}].global_bts_id}.xml
    Save SCF Of Desired gNB In Robot Logs Directory    gnb_instance_index=${1}
    ...                                                path=${output test dir}
    ...                                                file_name=${SCF_file_name_1}

    pcap.Start Pcap Logs
    Verify Tput
    pcap.Stop Pcap Logs
    @{packet_list}    pcap.Get Packet List    file_name=${TEST_NAME}_    dir_path=${output test dir}

    Verify Sgnb Additione Complete    ${packet_list}
    Verify Retry Timer With Meas Max Number    packet_list=${packet_list}
    ...                                        freq_rsrsp_values=${freq_rsrsp_values}
    ...                                        event_type=${event_type}
    ...                                        max_number=${meas_max_number}
    ...                                        retry_timer=${retry_timer}
    ...                                        supervision_timer=${fr2_supervision_timer}
    ...                                        time_to_trigger=${time_to_trigger_rsrp}

    [Teardown]    Run Keywords    pcap.Stop Pcap Logs    AND
    ...                           Set A4 Periodic Meas Control Nsa    fr1_supervision_timer=5000
    ...                                                               fr2_supervision_timer=10000
    ...                                                               meas_max_number=10
    ...                                                               retry_timer=20
    ...                                                               cell_id=1    AND
    ...                           Set A4 Measurement Ssb Rsrp    hysteresis_rsrp=0
    ...                                                          threshold_rsrp=30
    ...                                                          time_to_trigger_rsrp=ms40
    ...                                                          nrhoif_list=${NRHOIF_FR1}
    ...                                                          cell_id=${1}    AND
    ...                           Common Postconditions With Watching Alarms

[1]B5_FR2_inter-frequency_A4_meas_for_mobility_configured_periodically_in_the_UE_on_an_NSA_3X_call_on_FR2_PSCell
    [Tags]    B05
    Set Test Variable    ${output test dir}    ${OUTPUT DIR}/TEST_B05
    Create Directory     ${output test dir}

    Set Test Variable   ${fr1_supervision_timer}    3000
    Set Test Variable   ${fr2_supervision_timer}    7000
    Set Test Variable   ${meas_max_number}          5
    Set Test Variable   ${retry_timer}              10
    Set Test Variable   ${threshold_rsrp}           120
    Set Test Variable   ${hysteresis_rsrp}          0
    Set Test Variable   ${time_to_trigger_rsrp}     ms40
    Set Test Variable   ${event_type}               A4

    Set A4 Meas Higher Prio Freq Disabled    nrhoif_list=${NRHOIF_FR2}    cell_id=${1}

    Set A4 Periodic Meas Control Nsa    fr1_supervision_timer=${fr1_supervision_timer}
    ...                                 fr2_supervision_timer=${fr2_supervision_timer}
    ...                                 meas_max_number=${meas_max_number}
    ...                                 retry_timer=${retry_timer}
    ...                                 cell_id=${402}
    ...                                 gnb_instance_id=${1}

    Set A4 Measurement Ssb Rsrp                  hysteresis_rsrp=${hysteresis_rsrp}
    ...                                          threshold_rsrp=${threshold_rsrp}
    ...                                          time_to_trigger_rsrp=${time_to_trigger_rsrp}
    ...                                          nrhoif_list=${NRHOIF_FR1}
    ...                                          cell_id=${1}

    ${arfcn}    Get Arfcn Ssb Pbch    cell_id=${1}
    ${b1_th_arfcn}    Get Enb B1 Threshold Nr Rsrp    carrier_freq=${arfcn}
    Set Enb B1 Threshold Nr Rsrp    ${arfcn}    b1_threshold_rsrp=${-30}

    ${ssb_freq}    Get Ssb Frequency    nrhoif_id=${1}    cell_id=${1}
    ${b1_th_ssb_freq}    Get Enb B1 Threshold Nr Rsrp    carrier_freq=${ssb_freq}
    Set Enb B1 Threshold Nr Rsrp    ${ssb_freq}    b1_threshold_rsrp=${-110}

    ${freq_rsrsp_values}    Get Ssb Frequency And Rsrp    nrhoif_list=${NRHOIF_FR1}    cell_id=${402}    gnb_instance_id=${1}

    # Save Site Configuration (SCF) to Robot's logs directory
    Set Test Variable    ${SCF_file_name_0}            CB007517_B05_${tl.gnbs[${0}].global_bts_id}.xml
    Save SCF Of Desired gNB In Robot Logs Directory    gnb_instance_index=${0}
    ...                                                path=${output test dir}
    ...                                                file_name=${SCF_file_name_0}

    Set Test Variable    ${SCF_file_name_1}            CB007517_B05_${tl.gnbs[${1}].global_bts_id}.xml
    Save SCF Of Desired gNB In Robot Logs Directory    gnb_instance_index=${1}
    ...                                                path=${output test dir}
    ...                                                file_name=${SCF_file_name_1}

    pcap.Start Pcap Logs
    Verify Tput
    pcap.Stop Pcap Logs
    @{packet_list}    pcap.Get Packet List    file_name=${TEST_NAME}_    dir_path=${output test dir}

    Verify Sgnb Additione Complete    ${packet_list}
    Verify Retry Timer With Meas Max Number    packet_list=${packet_list}
    ...                                        freq_rsrsp_values=${freq_rsrsp_values}
    ...                                        event_type=${event_type}
    ...                                        max_number=${meas_max_number}
    ...                                        retry_timer=${retry_timer}
    ...                                        supervision_timer=${fr2_supervision_timer}
    ...                                        time_to_trigger=${time_to_trigger_rsrp}

    [Teardown]    Run Keywords    pcap.Stop Pcap Logs    AND
    ...                           Set Enb B1 Threshold Nr Rsrp    ${ssb_freq}    b1_threshold_rsrp=${b1_th_ssb_freq}    AND
    ...                           Set Enb B1 Threshold Nr Rsrp    ${arfcn}    b1_threshold_rsrp=${b1_th_arfcn}    AND
    ...                           Set A4 Periodic Meas Control Nsa    fr1_supervision_timer=${5000}
    ...                                                               fr2_supervision_timer=${10000}
    ...                                                               meas_max_number=${10}
    ...                                                               retry_timer=${20}
    ...                                                               cell_id=${402}
    ...                                                               gnb_instance_id=${1}    AND
    ...                           Set A4 Measurement Ssb Rsrp    hysteresis_rsrp=${hysteresis_rsrp}
    ...                                                          threshold_rsrp=${30}
    ...                                                          time_to_trigger_rsrp=${time_to_trigger_rsrp}
    ...                                                          nrhoif_list=${NRHOIF_FR1}
    ...                                                          cell_id=${1}    AND
    ...                           Common Postconditions With Watching Alarms

[1]B14_PSCell_change_procedure_on_receipt_of_inter-frequency_A4_meas_report
    [Tags]    B14
    Set Test Variable    ${output test dir}    ${OUTPUT DIR}/TEST_B14
    Create Directory     ${output test dir}

    Set Test Variable   ${fr1_supervision_timer}    3000
    Set Test Variable   ${fr2_supervision_timer}    7000
    Set Test Variable   ${meas_max_number}          5
    Set Test Variable   ${retry_timer}              10
    Set Test Variable   ${threshold_rsrp}           120
    Set Test Variable   ${hysteresis_rsrp}          0
    Set Test Variable   ${time_to_trigger_rsrp}     ms40
    Set Test Variable   ${event_type}               A4
    ${NRHOIF_LIST}=    Create List    2    3
    Set A4 Meas Higher Prio Freq Disabled    nrhoif_list=${NRHOIF_FR2}    cell_id=${1}

    Set A4 Periodic Meas Control Nsa    fr1_supervision_timer=${fr1_supervision_timer}
    ...                                 fr2_supervision_timer=${fr2_supervision_timer}
    ...                                 meas_max_number=${meas_max_number}
    ...                                 retry_timer=${retry_timer}
    ...                                 cell_id=${1}

    Set A4 Measurement Ssb Rsrp    hysteresis_rsrp=${hysteresis_rsrp}
    ...                            threshold_rsrp=${120}
    ...                            time_to_trigger_rsrp=${time_to_trigger_rsrp}
    ...                            nrhoif_list=${NRHOIF_LIST}
    ...                            cell_id=${1}

    Set A4 Measurement Ssb Rsrp    hysteresis_rsrp=${hysteresis_rsrp}
    ...                            threshold_rsrp=${30}
    ...                            time_to_trigger_rsrp=${time_to_trigger_rsrp}
    ...                            nrhoif_list=${1}
    ...                            cell_id=${1}

    ${PRIORITY_FOR_NRHOIF_1}=    Create List   1    1
    ${PRIORITY_FOR_NRHOIF_2}=    Create List   2    30
    ${PRIORITY_FOR_NRHOIF_3}=    Create List   3    60

    ${PRIORITY_LIST}=    Create List    ${PRIORITY_FOR_NRHOIF_1}    ${PRIORITY_FOR_NRHOIF_2}    ${PRIORITY_FOR_NRHOIF_3}

    Set A4 Higher Priority    priority_list=${PRIORITY_LIST}    cell_id=${1}

    ${freq_rsrsp_values}    Get Ssb Frequency And Rsrp    nrhoif_list=${NRHOIF_FR1}    cell_id=${1}
    ${target_pci}    Get Target PCI    cell_num=${1}

    # Save Site Configuration (SCF) to Robot's logs directory
    Set Test Variable    ${SCF_file_name_0}            CB007517_B14_${tl.gnbs[${0}].global_bts_id}.xml
    Save SCF Of Desired gNB In Robot Logs Directory    gnb_instance_index=${0}
    ...                                                path=${output test dir}
    ...                                                file_name=${SCF_file_name_0}

    Set Test Variable    ${SCF_file_name_1}            CB007517_B14_${tl.gnbs[${1}].global_bts_id}.xml
    Save SCF Of Desired gNB In Robot Logs Directory    gnb_instance_index=${1}
    ...                                                path=${output test dir}
    ...                                                file_name=${SCF_file_name_1}

    pcap.Start Pcap Logs
    Verify Tput
    pcap.Stop Pcap Logs
    @{packet_list}    pcap.Get Packet List    file_name=${TEST_NAME}_    dir_path=${output test dir}

    Verify Sgnb Additione Complete    ${packet_list}
    Verify Inter Gnb Handover Complete    ${packet_list}

    ${packet_to_check}    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                             packet_type=RRCReconfiguration
    ...                                             n=${2}
    Has RRCReconfiguration Drx Config Setup    packet=${packet_to_check}

    ${packet_to_check}    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                             packet_type=SgNBModificationRequestAcknowledge
    ...                                             n=${1}

    ${meas_ids}    Meas Id Related To Freq    packet=${packet_to_check}
    ...                                       freq_rsrsp_values=${freq_rsrsp_values}
    ...                                       event_type=${event_type}
    ...                                       time_to_trigger=${time_to_trigger_rsrp}

    ${mr_pkg}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                     packet_type=Measurement${SPACE}Report
    ...                                     n=${1}

    ${gnb1_ip}=    Get X2c Ip Address
    ${gnb2_ip}=    Get X2c Ip Address    gnb_instance_id=${1}

    Verify Inter Frequency A4 Measurement Report    packet_list=@{packet_list}
    ...                                             mr_pkg=${mr_pkg}
    ...                                             freq_rsrsp_values=${freq_rsrsp_values}
    ...                                             gnb1_ip=${gnb1_ip}
    ...                                             gnb2_ip=${gnb2_ip}
    ...                                             target_pci=${target_pci}
    ...                                             meas_ids=${meas_ids}

    [Teardown]    Run Keywords    pcap.Stop Pcap Logs    AND
    ...                           Set A4 Periodic Meas Control Nsa    fr1_supervision_timer=${5000}
    ...                                                               fr2_supervision_timer=${10000}
    ...                                                               meas_max_number=${10}
    ...                                                               retry_timer=${20}
    ...                                                               cell_id=${1}    AND
    ...                           Set A4 Measurement Ssb Rsrp    hysteresis_rsrp=${0}
    ...                                                          threshold_rsrp=${30}
    ...                                                          time_to_trigger_rsrp=${time_to_trigger_rsrp}
    ...                                                          nrhoif_list=${NRHOIF_LIST}
    ...                                                          cell_id=${1}    AND
    ...                           Common Postconditions With Watching Alarms

[1]B16_Waiting_for_the_A4_MR_having_the_highest_priority
    [Tags]    B16
    Set Test Variable    ${output test dir}    ${OUTPUT DIR}/TEST_B16
    Create Directory     ${output test dir}

    Set Test Variable   ${fr1_supervision_timer}    3000
    Set Test Variable   ${fr2_supervision_timer}    7000
    Set Test Variable   ${meas_max_number}          5
    Set Test Variable   ${retry_timer}              10
    Set Test Variable   ${threshold_rsrp}           120
    Set Test Variable   ${hysteresis_rsrp}          0
    Set Test Variable   ${time_to_trigger_rsrp}     ms40
    Set Test Variable   ${event_type}               A4
    ${NRHOIF_LIST}=    Create List    2    3

    Set A4 Meas Higher Prio Freq Disabled    nrhoif_list=${NRHOIF_FR2}    cell_id=${1}

    Set A4 Periodic Meas Control Nsa    fr1_supervision_timer=${fr1_supervision_timer}
    ...                                 fr2_supervision_timer=${fr2_supervision_timer}
    ...                                 meas_max_number=${meas_max_number}
    ...                                 retry_timer=${retry_timer}
    ...                                 cell_id=${1}

    Set A4 Measurement Ssb Rsrp    hysteresis_rsrp=${hysteresis_rsrp}
    ...                            threshold_rsrp=${120}
    ...                            time_to_trigger_rsrp=${time_to_trigger_rsrp}
    ...                            nrhoif_list=${NRHOIF_LIST}
    ...                            cell_id=${1}

    Set A4 Measurement Ssb Rsrp    hysteresis_rsrp=${hysteresis_rsrp}
    ...                            threshold_rsrp=${30}
    ...                            time_to_trigger_rsrp=${time_to_trigger_rsrp}
    ...                            nrhoif_list=${1}
    ...                            cell_id=${1}


    ${PRIORITY_FOR_NRHOIF_1}=    Create List   1    60
    ${PRIORITY_FOR_NRHOIF_2}=    Create List   2    30
    ${PRIORITY_FOR_NRHOIF_3}=    Create List   3    1

    ${PRIORITY_LIST}=    Create List    ${PRIORITY_FOR_NRHOIF_1}    ${PRIORITY_FOR_NRHOIF_2}    ${PRIORITY_FOR_NRHOIF_3}


    Set A4 Higher Priority    priority_list=${PRIORITY_LIST}    cell_id=${1}

    ${freq_rsrsp_values}    Get Ssb Frequency And Rsrp    nrhoif_list=${NRHOIF_FR1}    cell_id=${1}
    ${target_pci}    Get Target PCI    cell_num=${1}

    @{nrhoifs}=    Get All Nrhoif Configuration List

    # Save Site Configuration (SCF) and NRHOIF configuration to Robot's logs directory
    Set Test Variable    ${SCF_file_name_0}            CB007517_B16_${tl.gnbs[${0}].global_bts_id}.xml
    Save SCF Of Desired gNB In Robot Logs Directory    gnb_instance_index=${0}
    ...                                                path=${output test dir}
    ...                                                file_name=${SCF_file_name_0}

    Set Test Variable    ${SCF_file_name_1}            CB007517_B16_${tl.gnbs[${1}].global_bts_id}.xml
    Save SCF Of Desired gNB In Robot Logs Directory    gnb_instance_index=${1}
    ...                                                path=${output test dir}
    ...                                                file_name=${SCF_file_name_1}

    Save NRHOIF Configuration To Python Module         path_to_module=${output test dir}/nrhoif.py

    pcap.Start Pcap Logs
    Verify Tput
    pcap.Stop Pcap Logs
    @{packet_list}    pcap.Get Packet List    file_name=${TEST_NAME}_    dir_path=${output test dir}
    Verify Sgnb Additione Complete    ${packet_list}

    ${sgnb_mod_req}    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                          packet_type=SgNBModificationRequestAcknowledge
    ...                                          n=${1}

    ${mr_pkg}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                     packet_type=Measurement${SPACE}Report
    ...                                     n=${1}

    Verify Gnb Handover For Lowest Priority    packet_list=@{packet_list}
    ...                                        sgnb_mod_req=${sgnb_mod_req}
    ...                                        mr_pkg=${mr_pkg}
    ...                                        supervision_timer=${fr2_supervision_timer}
    ...                                        target_pci=${target_pci}
    ...                                        event_type=${event_type}
    ...                                        freq_rsrsp_values=${freq_rsrsp_values}
    ...                                        nrhoifs=${nrhoifs}
    [Teardown]    Run Keywords    pcap.Stop Pcap Logs    AND
    ...                           Set A4 Periodic Meas Control Nsa    fr1_supervision_timer=${5000}
    ...                                                               fr2_supervision_timer=${10000}
    ...                                                               meas_max_number=${10}
    ...                                                               retry_timer=${20}
    ...                                                               cell_id=${1}    AND
    ...                           Set A4 Measurement Ssb Rsrp    hysteresis_rsrp=${0}
    ...                                                          threshold_rsrp=${30}
    ...                                                          time_to_trigger_rsrp=${time_to_trigger_rsrp}
    ...                                                          nrhoif_list=${NRHOIF_LIST}
    ...                                                          cell_id=${1}    AND
    ...                           Common Postconditions With Watching Alarms
