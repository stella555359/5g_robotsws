*** Settings ***
Documentation
...  author: Tomasz Dabrowski
...  contact: tomasz.dabrowski@nokia.com


Library         taf.sbts.oam.coam.admin  WITH NAME  admin
Library         ute_admin.delta
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/admin/AdminHelper.py
Library         taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    alarm_verification
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot



*** Variables ***
${tput_DL_bandwith}     300 Mbits/sec
${tput_UL_bandwith}     30 MBits/sec
${tput_deviation}       20%
${tput_duration}        30s
${packet_Size}          1200
${resource_path_CB012502}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB012502/resources
${MRBTS_ID}     51020
@{lines_gNB_T157_AQQL}       9    10    11    12



*** Keywords ***
[1][1.0] [09]CB012502-A_80MHz_20MHz_20MHz_20MHz_bandwidth_with_different_frame_structures_on_AQQL_RU
    Load scf for NR    ${resource_path_CB012502}    SCFs    scf_CB012502_1.xml    verify_cells_on_air=False
    Update Software If Necessary
    Attach All UEs And Verify Simultaneous Traffic On All Cells


[1][3.0] [11]CB012502-A_80MHz_30MHz_20MHz_20MHz_bandwidth_with_different_frame_structures_on_AQQL_RU
    Load scf for NR    ${resource_path_CB012502}    SCFs    scf_CB012502_2.xml    verify_cells_on_air=False
    Update Software If Necessary
    Attach All UEs And Verify Simultaneous Traffic On All Cells

Update Software If Necessary
    admin.connect_to  bts_host=192.168.255.129
    ${is_23_active}=    check_if_sw_incompatible_alarm_occurred
    log to console    is 23 active: ${is_23_active}
    Run keyword if    ${is_23_active}    Perform update with burak

CB012502 setup
    [Arguments]    ${scf_file}
    Load scf for NR    ${resource_path_CB012502}    SCFs    ${scf_file}    verify_cells_on_air=False
    Update Software If Necessary
    Wait until keyword succeeds    30 min    1 min    Verify all cells are onair with admin
    Set attenuation and check    lines=${lines_gNB_T157_AQQL}   value=0
    Require Ue    UE_1    capabilities=REAL_SAMSUNG_UE
    Require Ue    UE_2    capabilities=REAL_MTK_UE
    Require Ue    UE_3    capabilities=REAL_QUALCOMM_UE_2      #taro
    Require Ue    UE_4    capabilities=REAL_QUALCOMM_UE_1      #lahaina
    Run Keyword and Ignore Error   Start syslog collection
    Connect to Coam
    Get SCF
    Set global variable bts id
    Get number of cells and set ID

CB012502 teardown
    Sleeping cell test
    Detach all UEs
    Make snapshot in case of error
    Run Keyword and Ignore Error   Stop syslog collection
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    Verify Crash occurrence In Syslog
    Disconnect coam


Attach All UEs And Verify Simultaneous Traffic On All Cells
    Attach UE_1 To Cell 0
    Attach UE_2 To Cell 3
    Attach UE_3 To Cell 4
    Attach UE_4 To Cell 5
    Sleep    10s
    Start Data Transfer  dt_name=DT_DL_SA_1  ue_alias=UE_1  direction=dl  duration=600s
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_1  ue_alias=UE_1  direction=ul  duration=600s
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep    10s
    Start Data Transfer  dt_name=DT_DL_SA_2  ue_alias=UE_2  direction=dl  duration=600s
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_2  ue_alias=UE_2  direction=ul  duration=600s
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep    10s
    Start Data Transfer  dt_name=DT_DL_SA_3  ue_alias=UE_3  direction=dl  duration=600s
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_3  ue_alias=UE_3  direction=ul  duration=600s
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep    10s
    Start Data Transfer  dt_name=DT_DL_SA_4  ue_alias=UE_4    direction=dl    duration=600s
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_4  ue_alias=UE_4    direction=ul    duration=600s
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep    50s    50s of simultaneous traffic
    Verify Simultaneous Traffic On All Cells


Verify Simultaneous Traffic On All Cells
    check_data_transfer_is_alive    DT_DL_SA_1
    check_data_transfer_is_alive    DT_DL_SA_2
    check_data_transfer_is_alive    DT_DL_SA_3
    check_data_transfer_is_alive    DT_DL_SA_4

    Verify Average Throughput    DT_DL_SA_1    10Mbits/sec    omit=10    end=50
    Verify Average Throughput    DT_DL_SA_2    10Mbits/sec    omit=10    end=50
    Verify Average Throughput    DT_DL_SA_3    10Mbits/sec    omit=10    end=50
    Verify Average Throughput    DT_DL_SA_4    10Mbits/sec    omit=10    end=50

    Verify Average Throughput    DT_UL_SA_1    2Mbits/sec     omit=10    end=50
    Verify Average Throughput    DT_UL_SA_2    2Mbits/sec     omit=10    end=50
    Verify Average Throughput    DT_UL_SA_3    2Mbits/sec     omit=10    end=50
    Verify Average Throughput    DT_UL_SA_4    2Mbits/sec     omit=10    end=50


Stop Traffic
    Run keyword and ignore error    stop_data_transfers_for_all_ues

Attach UE_1 To Cell 0
    Set Suite Variable   ${delta_id}   UE_1_delta
    admin.create_delta    delta_id=${delta_id}
    Create Delta With Cell 0 notBarred with ID UE_1_delta
    Save and commission delta   ${delta_id}    ${delta_id}.json
    Wait until keyword succeeds    5 min    1 min    Verify all cells are onair with admin
    turn_mobile_data_on    UE_1
    Attach Ue  UE_1    timeout=200


Attach UE_2 To Cell 3
    Set Suite Variable   ${delta_id}   UE_2_delta
    admin.create_delta    delta_id=${delta_id}
    Create Delta With Cell 0 barred with ID UE_2_delta
    Create Delta With Cell 3 notBarred with ID UE_2_delta
    Save and commission delta   ${delta_id}    ${delta_id}.json
    Wait until keyword succeeds    5 min    1 min    Verify all cells are onair with admin
    turn_mobile_data_on    UE_2
    Attach Ue   UE_2    timeout=200


Attach UE_3 To Cell 4
    Set Suite Variable   ${delta_id}   UE_3_delta
    admin.create_delta    delta_id=${delta_id}
    Create Delta With Cell 3 barred with ID UE_3_delta
    Create Delta With Cell 4 notBarred with ID UE_3_delta
    Save and commission delta   ${delta_id}    ${delta_id}.json
    Wait until keyword succeeds    5 min    1 min    Verify all cells are onair with admin
    turn_mobile_data_on    UE_3
    Attach Ue   UE_3    timeout=200


Attach UE_4 To Cell 5
    Set Suite Variable   ${delta_id}   UE_4_delta
    admin.create_delta    delta_id=${delta_id}
    Create Delta With Cell 4 barred with ID UE_4_delta
    Create Delta With Cell 5 notBarred with ID UE_4_delta
    Save and commission delta   ${delta_id}    ${delta_id}.json
    Wait until keyword succeeds    5 min    1 min    Verify all cells are onair with admin
    turn_mobile_data_on    UE_4
    Attach Ue   UE_4    timeout=200


Create Delta With Cell ${cell_id} ${barred_status} with ID ${delta_id}
    admin.append_parameter_update_to_delta    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${cell_id}
    ...                                 parameter=cellBarred
    ...                                 value=${barred_status}
    ...                                 delta_id=${delta_id}
    Log     Created delta with id ${delta_id}. Cell ${cell_id}: ${barred_status}    console=True


Create And Commission Delta With All Cells ${barred_status} with ID ${delta_id}
    Log to console  ${barred_status}
    Log to console  ${delta_id}
    Set Suite Variable   ${delta_id}   ${delta_id}
    Set Suite Variable    ${delta_filename}  ${delta_id}
    admin.create_delta    delta_id=${delta_id}
    admin.append_parameter_update_to_delta    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-0
    ...                                 parameter=cellBarred
    ...                                 value=barred
    ...                                 delta_id=barr_cells
    admin.append_parameter_update_to_delta    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3
    ...                                 parameter=cellBarred
    ...                                 value=barred
    ...                                 delta_id=barr_cells
    admin.append_parameter_update_to_delta    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-4
    ...                                 parameter=cellBarred
    ...                                 value=barred
    ...                                 delta_id=barr_cells
    admin.append_parameter_update_to_delta    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-5
    ...                                 parameter=cellBarred
    ...                                 value=barred
    ...                                 delta_id=barr_cells

    Log     Created delta with id ${delta_id}.    console=True
    Save and commission delta  ${delta_id}   ${delta_filename}


Save and commission delta
    [Arguments]    ${delta_id}=delta_id    ${delta_filename}=${delta_id}.json
    admin.save_delta    delta_id=${delta_id}    target_file_name=${delta_filename}
    Log    Saved delta to ${delta_filename}. Commissioning started    console=True
    recommission_with_delta_from_admin    ${delta_filename}
    Log    Commissioning delta succeeded    console=True


Detach all UEs
    Detach Ue  UE_1
    Detach Ue  UE_2
    Detach Ue  UE_3
    Detach Ue  UE_4
