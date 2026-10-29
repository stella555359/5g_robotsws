*** Settings ***
Documentation
...    Test suite for regression testing for feature CB009025 (continuation of CB007517)
...    authors: Wioleta Święs, Bartłomiej Bieńko
...    maintainer: Wioleta Święs, Bartłomiej Bieńko
...    group: RAN_PZ_KRK_SG_7
...    contact: I_5G_PZ_MMW_KRK_7SG_TEST@internal.nsn.com, wioleta.swies@nokia.com, bartlomiej.bienko@nokia.com

Library      ./resources/keywords.py    WITH NAME    keywords9205
Library      OperatingSystem
Variables    ./resources/variables.py
Resource     ../resources/resources.robot

Force Tags    STATE_SW_UPLOADED    CRT    CLOUD_5G_CLASSICAL_ASIK_ABIL_AHLOA_ENB_ANDROID

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
[1]B03_PSCell_change_procedure_on_receipt_of_inter-frequency_A4_meas_report_-_Inter-gNB
    [Tags]    B03_Inter
    Enable Feature CB009205    gnb_instance_index=${main_gnb_instance_index}
    ...                        nrbts_id=${main_nrbts_id}
    ...                        nrcell_id=${main_nrcell_id}
    ...                        enabled=${True}
    Set Test Variable    ${output test dir}    ${OUTPUT DIR}/TEST_B03_Inter
    Create Directory     ${output test dir}

    # Desired NRCELL related variables
    Set Test Variable    ${gnb_instance_from_init_index}    ${0}
    Set Test Variable    ${gnb_global_id}                   ${tl.gnbs[${gnb_instance_from_init_index}].global_bts_id}
    Set Test Variable    ${addition_nrcell_id}              1

    # Change Addition Cell (attach to LTE and then addition to SgNB)
    Change SgNB Addition Cell On ENB    gnbId_to_addition=${gnb_global_id}    cellId_to_addition=${addition_nrcell_id}

    # HO Events Timers Configuration
    Set Test Variable    ${fr1_supervision_timer}    7000
    Set Test Variable    ${fr2_supervision_timer}    7000
    Set Test Variable    ${a4MeasMaxNumber}          5
    Set Test Variable    ${a4RetryTimer}             10

    Set A4 Periodic Meas Control Nsa    fr1_supervision_timer=${fr1_supervision_timer}
    ...                                 fr2_supervision_timer=${fr2_supervision_timer}
    ...                                 meas_max_number=${a4MeasMaxNumber}
    ...                                 retry_timer=${a4RetryTimer}
    ...                                 cell_id=${1}

    Set Test Variable    ${a1ThresholdhoSsbRsrp}         70
    Set Test Variable    ${a1HysteresishoSsbRsrp}        0
    Set Test Variable    ${a1TimeToTriggerhoSsbRsrp}     ms64

    keywords.Set A1 Measho Pref NR Layer Ssb Rsrp    a1ThresholdhoSsbRsrp=${a1ThresholdhoSsbRsrp}
    ...                                              a1HysteresishoSsbRsrp=${a1HysteresishoSsbRsrp}
    ...                                              a1TimeToTriggerhoSsbRsrp=${a1TimeToTriggerhoSsbRsrp}

    # Event configuration on NRHOIFs
    Toggle Events A On Desired NRHOIFs    mapping=${nrhoif_event_configuration_B03_Inter}

    Set Test Variable    ${a2MeasReleaseEnabled}     none
    Set Test Variable    ${a2MeasRedirectEnabled}    none
    Set Test Variable    ${a2MeashoEnabled}          rsrp
    Set Test Variable    ${a2MeashoEnabledSA}        none

    keywords.Set A2 Meas Ho Nsa    a2MeasReleaseEnabled=${a2MeasReleaseEnabled}
    ...                            a2MeasRedirectEnabled=${a2MeasRedirectEnabled}
    ...                            a2MeashoEnabled=${a2MeashoEnabled}
    ...                            a2MeashoEnabledSA=${a2MeashoEnabledSA}
    ...                            nr_cell_id=1

    Set Test Variable    ${a4HysteresisSsbRsrp}       0
    Set Test Variable    ${a4ThresholdSsbRsrp}        ${a1ThresholdhoSsbRsrp}
    Set Test Variable    ${a4TimeToTriggerSsbRsrq}    ms40
    Set Test Variable    @{nrhoifs_ids}    1    2    3    4    5    6
    keywords.Set A4 Measurement Ssb Rsrp    hysteresis_rsrp=${a4HysteresisSsbRsrp}
    ...                                     threshold_rsrp=${a4ThresholdSsbRsrp}
    ...                                     time_to_trigger_rsrp=${a4TimeToTriggerSsbRsrq}
    ...                                     nrhoif_list=${nrhoifs_ids}
    ...                                     cell_id=1

    # PCAP GENERATION
    # L3-Call flow:
        # 1. SgNB Addition
        # 2. RRCReconfiguration at addition installs configuration for events A1, A2, A3 and A5 (without A4)
        # 3. During next a4RetryTimer seconds nothing happens
        # 4. Attenuation is decreased and MR A1 is being reported
        # 5. Loop starts with supervisionTimer
        # 6. Within this supervisionTimer UE recieves RRCReconfiguration with A4 event configuration
        # 7. UE performs HO - if given A4 has highest priority - HO is being performed immediately,
        #                     if not - HO is being performed as soon as supervisionTimer ends

    # Attenuation configuration
    Set Test Variable    ${begin_attenuation}         45dB
    Set Test Variable    ${attenuation}               0dB
    Set Test Variable    ${delay}                     ${8}
    Set Test Variable    ${attenuation_duration}      ${0}

    # Save Site Configuration to dedicated Robot's logs directory
    Save Nrhoif Configuration To Python Module    path_to_module=${output test dir}/nrhoif.py

    Set Test Variable    ${SCF_file_name_0}            CB009205_B03_Inter_${tl.gnbs[${0}].global_bts_id}.xml
    Save SCF Of Desired gNB In Robot Logs Directory    gnb_instance_index=${0}
    ...                                                path=${output test dir}
    ...                                                file_name=${SCF_file_name_0}

    Set Test Variable    ${SCF_file_name_1}            CB009205_B03_Inter_${tl.gnbs[${1}].global_bts_id}.xml
    Save SCF Of Desired gNB In Robot Logs Directory    gnb_instance_index=${1}
    ...                                                path=${output test dir}
    ...                                                file_name=${SCF_file_name_1}

    pcap.Start Pcap Logs
    Verify Tput with Attenuated Signal    begin_attenuation=${begin_attenuation}
    ...                                   attenuator=${attenuator}
    ...                                   attenuation=${attenuation}
    ...                                   delay=${delay}
    ...                                   attenuation_duration=${attenuation_duration}
    pcap.Stop Pcap Logs

    ${packet_list}    pcap.Get Packet List    file_name=${TEST_NAME}_    dir_path=${output test dir}
    &{packet_with_types}    Map Packet Types With Indexes    packet_list=@{packet_list}

    ${packet_to_check}    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                             packet_type=RRCReconfiguration
    ...                                             n=${1}
    Has Rrcreconfiguration Configured Desired Event    packet=${packet_to_check}
    ...                                                         event_type=A1
    @{measIds_with_event_types}=     Get MeasId With Event Types From Packet    packet=${packet_to_check}

    ${packet_to_check}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=Measurement${SPACE}Report
    ...                                              n=${1}
    Has Measurement Report Meas Id For Event    packet=${packet_to_check}
    ...                                         measIds_with_event_type=@{measIds_with_event_types}
    ...                                         event_type=A1

    @{nrhoifs}=    Get All Nrhoif Configuration List
    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}
    Has RRCReconfiguration Proper Frequencies For Event    packet=${packet_to_check}
    ...                                                    event=A4
    ...                                                    nrhoifs=@{nrhoifs}

    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}
    Is MeasId Order Correct    packet=${packet_to_check}     nrhoifs=@{nrhoifs}

    ${target_pci}    Get Target PCI    cell_num=${1}
    Verify Inter Gnb Handover Complete    ${packet_list}
    ${begin_pkg}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                        packet_type=SgNBModificationRequest
    ...                                        n=${1}

    ${end_pkg}=      Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                        packet_type=SgNBChangeRequired
    ...                                        n=${1}

    ${mr_pkg}=       Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                        packet_type=Measurement${SPACE}Report
    ...                                        n=${2}

    Verify HO Depend on Supervision Timer      packet_begin=${begin_pkg}
    ...                                        packet_end=${end_pkg}
    ...                                        packet_to_check=${packet_to_check}
    ...                                        mr_pkg=${mr_pkg}
    ...                                        supervision_timer=${fr1_supervision_timer}
    ...                                        event_type=A4
    ...                                        rsrp_value=${a1ThresholdhoSsbRsrp}
    ...                                        time_trigger=${a4TimeToTriggerSsbRsrq}
    ...                                        target_pci= ${target_pci}
    ...                                        nrhoifs=${nrhoifs}

    ${from_pkg}=       Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                          packet_type=RRCReconfiguration
    ...                                          n=${3}

    ${gnb1_ip}=    Get X2c Ip Address
    ${gnb2_ip}=    Get X2c Ip Address    gnb_instance_id=${1}

    ${to_pkg}=         Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                          packet_type=SgNBReconfigurationComplete
    ...                                          n=${2}

    Verify Changing Ip During Ho               from_pkg=${from_pkg}
    ...                                        to_pkg=${to_pkg}
    ...                                        gnb1_ip=${gnb1_ip}
    ...                                        gnb2_ip=${gnb2_ip}

    [Teardown]    Run Keywords    pcap.Stop Pcap Logs    AND
    ...                           Change SgNB Addition Cell On ENB    gnbId_to_addition=${main_nrbts_id}
    ...                                                               cellId_to_addition=${main_nrcell_id}    AND
    ...                           Enable Feature CB009205    gnb_instance_index=${main_gnb_instance_index}
    ...                                                      nrbts_id=${main_nrbts_id}
    ...                                                      nrcell_id=${main_nrcell_id}
    ...                                                      enabled=${False}    AND
    ...                           Toggle Events A On Desired NRHOIFs    mapping=${nrhoif_default_event_configuration}    AND
    ...                           Common Postconditions With Watching Alarms

[1]B04_A1_meas_report_received_to_configure_A4_meas_for_mobility_to_higher_priority_NR_frequency
    [Tags]    B04
    Enable Feature CB009205    gnb_instance_index=${main_gnb_instance_index}
    ...                        nrbts_id=${main_nrbts_id}
    ...                        nrcell_id=${main_nrcell_id}
    ...                        enabled=${True}
    Set Test Variable    ${output test dir}    ${OUTPUT DIR}/TEST_B04
    Create Directory     ${output test dir}

    Set Test Variable    ${a1ThresholdhoSsbRsrp}         60
    Set Test Variable    ${a1HysteresishoSsbRsrp}        0
    Set Test Variable    ${a1TimeToTriggerhoSsbRsrp}     ms64

    Set Test Variable    ${begin_attenuation}       45dB
    Set Test Variable    ${attenuation}             0dB
    Set Test Variable    ${delay}                   ${5}
    Set Test Variable    ${attenuation_duration}    ${0}

    Set Test Variable   ${threshold_rsrp}           110
    Set Test Variable   ${hysteresis_rsrp}          0
    Set Test Variable   ${time_to_trigger_rsrp}     ms40
    ${NRHOIF_LIST}=    Create List    1    2    3

    keywords.Set A1 Meas Ho Pref NR Layer Ssb Rsrp    a1ThresholdhoSsbRsrp=${a1ThresholdhoSsbRsrp}
    ...                                               a1HysteresishoSsbRsrp=${a1HysteresishoSsbRsrp}
    ...                                               a1TimeToTriggerhoSsbRsrp=${a1TimeToTriggerhoSsbRsrp}

    ${PRIORITY_FOR_NRHOIF_1}=    Create List   1    60
    ${PRIORITY_FOR_NRHOIF_2}=    Create List   2    30
    ${PRIORITY_FOR_NRHOIF_3}=    Create List   3    60

    ${PRIORITY_LIST}=    Create List    ${PRIORITY_FOR_NRHOIF_1}    ${PRIORITY_FOR_NRHOIF_2}    ${PRIORITY_FOR_NRHOIF_3}

    Set A4 Higher Priority    priority_list=${PRIORITY_LIST}    cell_id=${1}

    keywords.Set A4 Measurement Ssb Rsrp    hysteresis_rsrp=${hysteresis_rsrp}
    ...                                     threshold_rsrp=${threshold_rsrp}
    ...                                     time_to_trigger_rsrp=${time_to_trigger_rsrp}
    ...                                     nrhoif_list=${NRHOIF_LIST}
    ...                                     cell_id=${1}

    ${report_interval}=    Get Report Interval Ho Nsa
    ${report_amount}=      Get Report Amount Ho Nsa

    &{a1_parameters}=    Create Dictionary    rsrp=${a1ThresholdhoSsbRsrp}
    ...                                       time_to_trigger=${a1TimeToTriggerhoSsbRsrp}
    ...                                       hysteresis=${a1HysteresishoSsbRsrp}
    ...                                       interval=${report_interval}
    ...                                       amount=${report_amount}

    # Save Site and NRHOIF Configuration  to Robot's logs directory
    Set Test Variable    ${SCF_file_name_0}            CB009205_B04_${tl.gnbs[${0}].global_bts_id}.xml
    Save SCF Of Desired gNB In Robot Logs Directory    gnb_instance_index=${0}
    ...                                                path=${output test dir}
    ...                                                file_name=${SCF_file_name_0}

    Set Test Variable    ${SCF_file_name_1}            CB009205_B04_${tl.gnbs[${1}].global_bts_id}.xml
    Save SCF Of Desired gNB In Robot Logs Directory    gnb_instance_index=${1}
    ...                                                path=${output test dir}
    ...                                                file_name=${SCF_file_name_1}

    pcap.Start Pcap Logs
    Verify Tput with Attenuated Signal    begin_attenuation=${begin_attenuation}
    ...                                   attenuator=${attenuator}
    ...                                   attenuation=${attenuation}
    ...                                   delay=${delay}
    ...                                   attenuation_duration=${attenuation_duration}

    pcap.Stop Pcap Logs
    ${packet_list}    pcap.Get Packet List    file_name=${TEST_NAME}_    dir_path=${output test dir}

    ${packet_to_check}    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                             packet_type=RRCReconfiguration
    ...                                             n=${1}

    Has Rrcreconfiguration Configured Desired Event    packet=${packet_to_check}
    ...                                                event_type=A1
    ...                                                parameters=${a1_parameters}

    Has Rrcreconfiguration Configured Proper Events    packet=${packet_to_check}
    ...                                                not_contain=A4

    @{measIds_with_event_types}=     Get MeasId With Event Types From Packet    packet=${packet_to_check}

    ${packet_to_check}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=Measurement${SPACE}Report
    ...                                              n=${1}

    Has Measurement Report Meas Id For Event    packet=${packet_to_check}
    ...                                         measIds_with_event_type=@{measIds_with_event_types}
    ...                                         event_type=A1

    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}

    Has Rrcreconfiguration Configured Proper Events    packet=${packet_to_check}
    ...                                                contain=A4

    @{nrhoifs}=    Get All Nrhoif Configuration List
    Has RRCReconfiguration Proper Frequencies For Event    packet=${packet_to_check}
    ...                                                    event=A4
    ...                                                    nrhoifs=@{nrhoifs}

    ${packet_to_check}    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                             packet_type=RRCReconfiguration
    ...                                             n=${2}
    Has RRCReconfiguration Drx Config Setup    packet=${packet_to_check}

    [Teardown]    Run Keywords    pcap.Stop Pcap Logs    AND
    ...                           keywords.Set A1 Meas Ho Pref NR Layer Ssb Rsrp
    ...                           a1ThresholdhoSsbRsrp=${a1ThresholdhoSsbRsrp}
    ...                           a1HysteresishoSsbRsrp=${a1HysteresishoSsbRsrp}
    ...                           a1TimeToTriggerhoSsbRsrp=${a1TimeToTriggerhoSsbRsrp}    AND
    ...                           Enable Feature CB009205    gnb_instance_index=${main_gnb_instance_index}
    ...                                                      nrbts_id=${main_nrbts_id}
    ...                                                      nrcell_id=${main_nrcell_id}
    ...                                                      enabled=${False}    AND
    ...                           Common Postconditions With Watching Alarms

[1]EC01_A1_meas_report_received_while_A4_meas_for_mobility_to_higher_priority_NR_freq_is_already_configured_in_the_UE
    [Tags]    EC01
    Enable Feature CB009205    gnb_instance_index=${main_gnb_instance_index}
    ...                        nrbts_id=${main_nrbts_id}
    ...                        nrcell_id=${main_nrcell_id}
    ...                        enabled=${True}
    Set Test Variable    ${output test dir}    ${OUTPUT DIR}/TEST_EC01
    Create Directory     ${output test dir}

    ${PRIORITY_FOR_NRHOIF_1}=    Create List   1    1
    ${PRIORITY_FOR_NRHOIF_2}=    Create List   2    2
    ${PRIORITY_FOR_NRHOIF_3}=    Create List   3    3
    ${PRIORITY_FOR_NRHOIF_4}=    Create List   4    4
    ${PRIORITY_FOR_NRHOIF_5}=    Create List   5    5
    ${PRIORITY_FOR_NRHOIF_6}=    Create List   6    6

    ${PRIORITY_LIST}=    Create List    ${PRIORITY_FOR_NRHOIF_1}
    ...                                 ${PRIORITY_FOR_NRHOIF_2}
    ...                                 ${PRIORITY_FOR_NRHOIF_3}
    ...                                 ${PRIORITY_FOR_NRHOIF_4}
    ...                                 ${PRIORITY_FOR_NRHOIF_5}
    ...                                 ${PRIORITY_FOR_NRHOIF_6}

    Set A4 Higher Priority    priority_list=${PRIORITY_LIST}    cell_id=${1}

    Set Test Variable    @{nrhoifs_ids}    1    2    3
    Set Test Variable    ${a4HysteresisSsbRsrp}       0
    Set Test Variable    ${a4ThresholdSsbRsrp}        110
    Set Test Variable    ${a4TimeToTriggerSsbRsrq}    ms40

    keywords.Set A4 Measurement Ssb Rsrp    hysteresis_rsrp=${a4HysteresisSsbRsrp}
    ...                                     threshold_rsrp=${a4ThresholdSsbRsrp}
    ...                                     time_to_trigger_rsrp=${a4TimeToTriggerSsbRsrq}
    ...                                     nrhoif_list=${nrhoifs_ids}
    ...                                     cell_id=${1}

    # Event configuration on NRHOIFs
    Toggle Events A On Desired NRHOIFs    mapping=${nrhoif_event_configuration_EC01}

    Set Test Variable    ${a1ThresholdhoSsbRsrp}         60
    Set Test Variable    ${a1HysteresishoSsbRsrp}        0
    Set Test Variable    ${a1TimeToTriggerhoSsbRsrp}     ms64

    keywords.Set A1 Measho Pref NR Layer Ssb Rsrp    a1ThresholdhoSsbRsrp=${a1ThresholdhoSsbRsrp}
    ...                                              a1HysteresishoSsbRsrp=${a1HysteresishoSsbRsrp}
    ...                                              a1TimeToTriggerhoSsbRsrp=${a1TimeToTriggerhoSsbRsrp}

    Set Test Variable    ${max_react}    ${max_react_default_value}
    Set A4 Meas Higher Prio Freq Max React    max_react=${max_react}
    ...                                       cell_id=${1}

    ${report_interval}=    Get Report Interval Ho Nsa
    ${report_amount}=      Get Report Amount Ho Nsa

    Set Test Variable   ${fr1_supervision_timer}    10000
    Set Test Variable   ${fr2_supervision_timer}    10000
    Set Test Variable   ${meas_max_number}          2
    Set Test Variable   ${retry_timer}              10

    keywords.Set A4 Periodic Meas Control Nsa    fr1_supervision_timer=${fr1_supervision_timer}
    ...                                          fr2_supervision_timer=${fr2_supervision_timer}
    ...                                          meas_max_number=${meas_max_number}
    ...                                          retry_timer=${retry_timer}
    ...                                          cell_id=${1}

    &{a1_parameters}=    Create Dictionary    rsrp=${a1ThresholdhoSsbRsrp}
    ...                                       time_to_trigger=${a1TimeToTriggerhoSsbRsrp}
    ...                                       hysteresis=${a1HysteresishoSsbRsrp}
    ...                                       interval=${report_interval}
    ...                                       amount=${report_amount}

    Set Test Variable    ${begin_attenuation}       45dB
    Set Test Variable    ${attenuation}             0dB
    Set Test Variable    ${delay}                   ${0}
    ${attenuation_duration}=    Calculate Supervision Retry Loop Time Sec    supervision_timer=${fr2_supervision_timer}
    ...                                                                      retry_timer=${retry_timer}
    ...                                                                      a4meas_max_number=${meas_max_number}

    # Save Site and NRHOIF Configuration  to Robot's logs directory
    Set Test Variable    ${SCF_file_name_0}            CB009205_EC01_${tl.gnbs[${0}].global_bts_id}.xml
    Save SCF Of Desired gNB In Robot Logs Directory    gnb_instance_index=${0}
    ...                                                path=${output test dir}
    ...                                                file_name=${SCF_file_name_0}

    Set Test Variable    ${SCF_file_name_1}            CB009205_EC01_${tl.gnbs[${1}].global_bts_id}.xml
    Save SCF Of Desired gNB In Robot Logs Directory    gnb_instance_index=${1}
    ...                                                path=${output test dir}
    ...                                                file_name=${SCF_file_name_1}

    pcap.Start Pcap Logs
    Verify Tput with Attenuated Signal    begin_attenuation=${begin_attenuation}
    ...                                   attenuator=${attenuator}
    ...                                   attenuation=${attenuation}
    ...                                   delay=${delay}
    ...                                   attenuation_duration=${attenuation_duration}
    ...                                   max_react=${max_react}
    pcap.Stop Pcap Logs
    ${packet_list}    pcap.Get Packet List    file_name=${TEST_NAME}_    dir_path=${output test dir}
    ${packet_to_check}    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                             packet_type=RRCReconfiguration
    ...                                             n=${1}

    Has Rrcreconfiguration Configured Desired Event    packet=${packet_to_check}
    ...                                                event_type=A1
    ...                                                parameters=${a1_parameters}

    Has Rrcreconfiguration Configured Proper Events    packet=${packet_to_check}
    ...                                                not_contain=A4

    @{measIds_with_event_types}=     Get MeasId With Event Types From Packet    packet=${packet_to_check}

    ${packet_to_check}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=Measurement${SPACE}Report
    ...                                              n=${1}

    Has Measurement Report Meas Id For Event    packet=${packet_to_check}
    ...                                         measIds_with_event_type=@{measIds_with_event_types}
    ...                                         event_type=A1

    ${packet_to_check}=    Find Nearest Packet After    packet_list=@{packet_list}
    ...                                                 packet_type_to_find=RRCReconfiguration
    ...                                                 reference_packet_type=Measurement${SPACE}Report
    ...                                                 index_of_reference=${1}

    @{nrhoifs}=    Get All Nrhoif Configuration List
    Has RRCReconfiguration Proper Frequencies For Event    packet=${packet_to_check}
    ...                                                    event=A4
    ...                                                    nrhoifs=@{nrhoifs}

    ${packet_to_check}=    Get Nth Packet Of Type    packet_list=@{packet_list}
    ...                                              packet_type=Measurement${SPACE}Report
    ...                                              n=${2}

    Has Measurement Report Meas Id For Event    packet=${packet_to_check}
    ...                                         measIds_with_event_type=@{measIds_with_event_types}
    ...                                         event_type=A1

    ${freq_rsrsp_values}    Get Ssb Frequency And Rsrp    nrhoif_list=${NRHOIF_FR1}    cell_id=${1}

    Verify Supervision Timer And Meas Id    packet_list=@{packet_list}
    ...                                     freq_rsrsp_values=${freq_rsrsp_values}
    ...                                     supervision_time=${fr2_supervision_timer}
    ...                                     event_type=A4
    ...                                     time_to_trigger=${a4TimeToTriggerSsbRsrq}
    ...                                     meas_max=${meas_max_number}
    ...                                     max_react=${max_react}

    Verify Retry Timer    packet_list=@{packet_list}
    ...                   retry_timer=${retry_timer}

    [Teardown]    Run Keywords    pcap.Stop Pcap Logs    AND
    ...                           keywords.Set A1 Meas Ho Pref NR Layer Ssb Rsrp
    ...                           a1ThresholdhoSsbRsrp=100
    ...                           a1HysteresishoSsbRsrp=${a1HysteresishoSsbRsrp}    AND
    ...                           Enable Feature CB009205    gnb_instance_index=${main_gnb_instance_index}
    ...                                                      nrbts_id=${main_nrbts_id}
    ...                                                      nrcell_id=${main_nrcell_id}
    ...                                                      enabled=${False}    AND
    ...                           Toggle Events A On Desired NRHOIFs    mapping=${nrhoif_default_event_configuration}    AND
    ...                           Common Postconditions With Watching Alarms
