*** Settings ***
Documentation
...  author:        Maciej Krysztofiak
...  contact:       maciej.krysztofiak@nokia.com

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/commissioning_2001.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/resources_2001.py
Library         testsuite/Wroclaw/RRM/resources/logs.py
Library         taf.ue

*** Keywords ***

Commissioning 2001
    Delta commissioning 2001
    Check BTS status
    Set fivegstac
    Check BTS status

Commissioning 2001 02
    Cell preparation 2001  beamsMuted=33
    ...                    beamSet=beamSet_6
    ...                    leftEdgeAngle=45
    ...                    nrBtsBeamRefinementP2=false
    ...                    rightEdgeAngle=45
    ...                    numberOfTransmittedSsBlocks=6 beams
#    ...                    numberOfRxBeamforming=4Rx
    Check BTS status

Commissioning 2001 02_1
    Cell preparation 2001  beamSet=beamSet_4
    ...                    numberOfTransmittedSsBlocks=4 beams
    ...                    leftEdgeAngle=60
    ...                    rightEdgeAngle=60
    ...                    beamsMuted=9
    ...                    numberOfRxBeamforming=2Rx
    Check BTS status

Commissioning 2001 04
    Cell preparation 2001  beamsMuted=0
    ...                    beamSet=beamSet_6
    ...                    leftEdgeAngle=45
    ...                    rightEdgeAngle=45
    Check BTS status

Commissioning 2001 04_1
    Cell preparation 2001  beamsMuted=34
    ...                    beamSet=beamSet_6
    ...                    leftEdgeAngle=45
    ...                    rightEdgeAngle=45
    Check BTS status

Commissioning 2001 05
    Cell preparation 2001  beamsMuted=2
    Eirp control power list configuration
    Eirp params configuration
    Check BTS status

Reattach
    Detach Ue   AT_BASED_UE_1
    sleep  5s
    Attach Ue   AT_BASED_UE_1
    sleep  10s

Do Throughput
    Start ULDL2  ue_alias=AT_BASED_UE_1
    ...          tput_duration=10s
    ...          tput_DL_bandwidth=1350 Mbits/sec
    ...          tput_UL_bandwidth=1350 Mbits/sec
    ...          packet_size=1400
    ...          protocol=udp
    taf.ue.Await Data Transfer Finish    DT_DL
    taf.ue.Await Data Transfer Finish    DT_UL

Get Throughput Dl
    ${tput_dl_value}  Get Average Throughput  dt_name=DT_DL
    [Return]  ${tput_dl_value}

Get Throughput Ul
    ${tput_ul_value}  Get Average Throughput  dt_name=DT_UL
    [Return]  ${tput_ul_value}

Check counters 2001 04
    @{counters}  Get muted beams counter list
    ${counters_dict}  Get last counter values  @{counters}
    ${first_cell_id}   Get global cell id of first cell
    Log To Console  ${counters_dict}
    Log To Console  ${first_cell_id}
    Verify counters 04  ${counters_dict}  ${first_cell_id}

Check counters 2001 05
    @{counters}  Get EIRP counter list
    ${counters_dict}  Get last counter values  @{counters}
    ${first_cell_id}   Get global cell id of first cell
    Verify counters 05  ${counters_dict}  ${first_cell_id}

Download latest counters
    [Arguments]  ${timer}=10m
    Cleanup all downloaded counter files
    Wait for counters  ${timer}
    Collect counters

Check BTS status
    Verify if bts is online
    ${alarms}=      get active alarms
    Check if no unexpected alarms       alarms_list=${alarms}

Collect BIP logs
    Start L1L2 logs gathering
    sleep    15s
    ${path}  Stop L1L2 logs gathering and download pcap
    [Return]  ${path}

Verify BIP logs 2001 02
    [Arguments]  ${pcap_file_path}
    log to console  ${pcap_file_path}
    ${pdml_file_path}   Convert pcap to pdml  ${pcap_file_path}
    log to console  ${pdml_file_path}
    ${logs_status}   BIP logs 2001 02  ${pdml_file_path}
    Run keyword if      ${logs_status}
    ...                 Log to console  Correct pattern has been met in BIP logs
    ...                 ELSE  FAIL  msg=Correct pattern has not been met

Verify BIP logs 2001 04
    [Arguments]  ${pcap_file_path}
    log to console  ${pcap_file_path}
    ${pdml_file_path}   Convert pcap to pdml  ${pcap_file_path}
    log to console  ${pdml_file_path}
    ${logs_status}   BIP logs 2001 04  ${pdml_file_path}
    Log to console  ${logs_status}
#    Run keyword if      ${logs_status}
#    ...                 Log to console  Correct pattern has been met in BIP logs
#    ...                 ELSE  FAIL  msg=Correct pattern has not been met
