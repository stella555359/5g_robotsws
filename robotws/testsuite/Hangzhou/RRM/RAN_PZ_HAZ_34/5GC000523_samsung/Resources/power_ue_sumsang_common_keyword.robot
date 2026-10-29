*** Settings ***
Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    taf.transport.ssh    WITH NAME    ssh_lib
#Resource    ../../../../OAM/Hangzhou/common/taf_coam.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
#Resource    ../../../../OAM/Hangzhou/common/coam_resource.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot

*** Variables ***
${ultp}    90
${dltp}    1300

*** Keywords ***
Prepare UE
    [Arguments]    ${ue_index}=${0}
    log to console       Prepare UE
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung

UE Attach
    [Arguments]    ${ue_index}=${0}
    log to console      UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=samsung    log_type=Aasyslog
    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False

Start UE traffic
    [Arguments]    ${ue_index}    ${ul_throughput}    ${dl_throughput}    ${ul_duration}=600    ${dl_duration}=600    ${protocol}=tcp
    log to console      Start traffic
    power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung
    ...    iperf_type=via_command    protocol=${protocol}
    sleep    1s
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=samsung
    ...    protocol=${protocol}

Stop UE traffic
    [Arguments]    ${ue_index}=${0}    ${protocol}=tcp
    log to console     Stop traffic
    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=samsung    iperf_type=via_command    protocol=${protocol}
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=samsung    protocol=${protocol}

UE Detach
    [Arguments]    ${ue_index}=${0}
    log to console      UE Detach
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=samsung

BIP log Check
    log to console      BIP log Check
    ${log_path}    BIP log capture and download
    ...    save_time_interval=1    filter=ether[0x18:2]==0x133 or ether[0x18:2]==0x249 or ether[0x18:2]==0x135
    ${msc_and_beam_id}    Get ul dl mcs and beam id    log_path=${log_path}    sample=5

Get ul and dl peak and ave throughput and return result
    [Documentation]    Get ul and dl peak and ave throughput and return result.
    ...    :param aasys_start_flag: for short time captrue use default, for long time call use ${False}, EG:${true}/${False}
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}    du_index=${du_index}
    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}
