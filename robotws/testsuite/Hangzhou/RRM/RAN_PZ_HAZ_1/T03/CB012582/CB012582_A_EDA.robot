*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is regression case for CB012582-A EDA.
...   Test ENV: CLOUD_5G_I_[LO][LO]_AP_[LOO]

Resource           ../Resources/common_resource.robot
Resource           ../../Resources/Common/Airphone.robot
Suite Setup        Common Suite Setup For RRM
Test Setup         Common Test Setup For RRM
Test Teardown      Run Keywords    Case Postcondition    AND
...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
Suite Teardown     Common Suite Teardown For RRM

Test Timeout       120 minutes

*** Variables ***
# Reduce global paramter as possilbe and automatically got from gNB or __init__
${cmd1}    trf_data_start
...    ue=1 pdu=1 qfi=2 dir=dl trf_id=2 rtp_codec=custom rtp_send_silence_period=500 period_ms=500 burst=1

&{fault_4334}            faultId=${4334}
&{fault_4293}            faultId=${4293}
&{fault_61510}           faultId=${61510}
&{fault_4459}            faultId=${4459}
&{fault_8000}            faultId=${8000}
&{fault_7300}            faultId=${7300}
&{fault_61616}           faultId=${61616}
&{fault_7529}            faultId=${7529}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_61510}    &{fault_4459}    &{fault_8000}    &{fault_7300}
...    &{fault_61616}    &{fault_7529}

*** Test Cases ***
CB012582_A_EDA_Xn based Inter-gNB HO and source gNB timestamp extension header
    [Documentation]
    ...    Step1: Attach UE1 to the gNB cell and VoNR data forwarding feature is activated.
    ...    Step2: Trigger inter-gNB Xn handover
    ...    Step3: Capture IP traffic log on target gNB side
    ...    Step4: When data forwarding of 5QI-1 is triggered, the End Marker in log should contain 0x3e
    ...    extension header which is the timestamp from Nokia source gNB.
    [Setup]    Run Keywords    Common Test Setup For RRM    AND    Case Precondition
    ATTACH UE1
    Start DL Traffic on UE
    Start IP traffic capturing
    Trigger Xn Handover to GNB-2
    ${log_path}    Stop and download IP traffic file
    Check ENDMARKER In Wireshark Log    ${log_path}

*** Keywords ***
Case Precondition
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=EDA
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=1800s

ATTACH UE1
    [Documentation]
    ...    This KW is used to Attach UE1 to gNB cell and setup 5QI-5 and 5QI-1 QoS flows.
    Log To Console      ${\n}============= Set 5QI-5 as default QoS flow and add 5QI-1 in ICS =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=2 default\=on
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=smf_param id\=1 additional_qosflows_to_activate\=3
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Start to Attach the UE =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
    ...    pass_regexp=UE NGAP ID 1 is now Registered
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
    ...    pass_regexp=Initial Context Setup Successful
    sleep    3s

Start DL Traffic on UE
    Log To Console      ${\n}============= Start DL/UL Data traffic on UE =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=5
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl mbps\=5
    ...    pass_regexp=${None}
    sleep    2s

Trigger Xn Handover to GNB-2
    Log To Console      ${\n}============= Trigger A2 Measurement Report on CELL-1 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=1 event\=A2 srsrp_nr\=11 srsrq_nr\=11 srs_result\=0:11:11:0
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Trigger A3 Measurement Report and handover to CELL-5 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=5 event\=A3 srsrp_nr\=19 phycell_id\=54 nrsrp_nr\=100
    ...    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to EXT_ENB-3.5 performed
    sleep    3s

Start IP traffic capturing
    [Documentation]    This KW is used to start IP traffic capturing on target MRBTS of handover.
    ...    Args:
    ...        ${measurement_point}: Based on WebEM settings
    ...        ${uplane_capturing}: Based on WebEM settings
    ...        ${password}: Set as None
    [Arguments]
    ...     ${bts_ip}=10.0.1.3
    ...     ${measurement_point}=NE_Terminated
    ...     ${uplane_capturing}=${TRUE}
    ...     ${password}=${EMPTY}
    coam.connect to	bts_host=${bts_ip}
    Log To Console      ${\n}============= Start IP traffic capturing =============${\n}
    coam.Start IP Capture File
    ...     measurement_point=${measurement_point}
    ...     uplane_capturing=${TRUE}
    ...     password=${EMPTY}

Stop and download IP traffic file
    [Documentation]    This KW is used to stop IP traffic capturing on MRBTS and download the file.
    [Arguments]    ${bts_index}=${1}
    Log To Console      ${\n}============= Generate IP traffic file =============${\n}
    coam.Stop IP Capture File
    coam.Generate IP Capture File
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${target_file_name}=    Set Variable    IP_Traffic_MRBTS-${bts_index}_${timestamp}.pcap.gz
    coam.Download IP Capture File    target_file_name=${TEST_LOG_DIRECTORY}/${target_file_name}
    [Return]    ${TEST_LOG_DIRECTORY}/${target_file_name}

Check ENDMARKER In Wireshark Log
    [Documentation]
    ...    This KW is used to check ENDMARKER in wireshark log.
    ...    Every End Marker should contain 0x3e extension header.
    [Arguments]    ${capture_file_path}
    Log To Console      ${\n}============= Check IP traffic file =============${\n}
    # ${output}    Parse Pcap by expression
    # ...    filter_expression=gtp
    # ...    input_file=${capture_file_path}
    # Should Contain    ${output}    End Marker

    # ${output}    Parse Pcap by expressionbackup
    # ...    filter='gtp.ext_hdr.next == 0x3e'
    # ...    filter_expression='gtp.ext_hdr.next == 0x3e'
    # ...    input_file=${capture_file_path}

    ${end_marker_values}    Parse Pcap by xpath    ${capture_file_path}
    ...    filter='gtp.message == 0xfe'
    ...    filter_expression='gtp.message == 0xfe'
    ...    xpath=.//gtp.message
    ${ext_hdr_values}    Parse Pcap by xpath    ${capture_file_path}
    ...    filter='gtp.message == 0xfe && gtp.ext_hdr.next == 0x3e'
    ...    filter_expression='gtp.ext_hdr.next == 0x3e'
    ...    xpath=.//gtp.ext_hdr.next[@show='0x3e']
    ${ret}    Should Be True    len(${end_marker_values}) == len(${ext_hdr_values})

Case Postcondition
    Airphone Operation    operation=edaemon_egate_teardown
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=200s