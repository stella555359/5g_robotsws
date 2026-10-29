*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: Test Cases CB007257-5G KPI triggered alarm and log collection in gNB


Resource      taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource      taf/rfrl/procedures/resources/robot/Alarms.robot
Library       ute_ue
Library       testsuite/Krakow/resources/ue_proxy_wsl/ue_proxy_wsl.py
Library       testsuite.Krakow.resources.alarm.Alarm
Library       ./transfer_validation.py
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Test Timeout  24 hours

Suite Setup     Run Keywords
...             gnbbbu.upload_swconfig  sw_config_path=commissionings/Krakow/swconfig/default_swconfig.txt
##...             gnbbbu.upload_swconfig  sw_config_path=${CURDIR}/resources/swconfig.txt
...             AND  Common Suite Setup With Commissioning  asir_hub=${True}
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions With Watching Alarms
Test Teardown       Run Keywords
                    ...    Radio Unit Power On on gNB    radio_unit_id=${1}
                    ...    AND    Common Postconditions With Watching Alarms

*** Variables ***
${global_bts_id} =  ${tl.gnbs[0].global_bts_id}
&{actCellAutoRecalculation}    actCellAutoRecalculation=Autonomous
&{actCellAutoRecalculation_distname}  MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FMCADM-1=${actCellAutoRecalculation}
@{additional_allowed_alarms}
...    BTS Reset Cause
...    Unit power reset
...    EFaultId_NoConnectionToUnitAl
${SEND_TRUCK_ROLL_EMAIL}     ${False}

*** Test Cases ***

CB009508-A_05_Re-commissioning_first_then_ASIRMOD_installation_on_any_half_of_a_subrack_B004
     gnb_alarm.Allow Alarm    No connection to unit
     Radio Unit Power Off on gNB    radio_unit_id=${1}
     Perform Full Commissioning and Wait for onAir  prefix_tag=SINGLE_ASIRMOD  asir_hub=${True}
     Perform Full Commissioning on Classical gNB    prefix_tag=${None}
     Perform Full Commissioning on gNB ASIR hub     prefix_tag=${None}
     wait_until_alarm_is_active_on_gnb    fault_name=No connection to unit    timeout=${1200}
     Radio Unit Power ON on gNB    radio_unit_id=${1}
     wait_until_alarm_is_not_active_on_gnb    fault_name=No connection to unit    timeout=${1200}
     gnbcell.wait_for_all_cells_to_be_onair    timeout=${1200}
     gnb_alarm.Disallow Alarm    No connection to unit

CB009508-A_07_New_ASIRMOD_installation_in_already_commissioned_dual-core_BTS_#2_with_CellRecalc_Auto_B005#2
    stop_ue_proxy_on_ue_pc
    gnb_alarm.Allow Alarm    No connection to unit
    gnbbbu.verify_configuration_parameters_values    param_dict=${actCellAutoRecalculation_distname}
    Radio Unit Power Off on gNB    radio_unit_id=${1}
    start_ue_proxy_on_ue_pc
    ute_ue.Require UE     UE     capabilities=QUECTEL_UE
    ute_ue.Attach UE    UE
    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=UE
    ...                           direction=dl
    ...                           duration=180s
    ...                           size_packet=1400B
    ...                           buffer_client=2M
    ...                           buffer_server=2M
    ...                           throughput=300 MBits/sec
    ...                           protocol=tcp
    ...                           parallel_streams=1
    ...                           max_segment_size=1300
    Radio Unit Power On on gNB    radio_unit_id=${1}
    ute_ue.Await Data Transfer Finish       dt_name=DT_DL
    ute_ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=300 MBytes/sec   deviation=100%
    ${data_transfer_statistics} =    ute_ue.get_data_transfer_statistics   dt_name=DT_DL
    verify_transfer_was_not_interrupted    ${data_transfer_statistics}
    ute_ue.Detach Ue     UE
    ute_ue.Stop Using Ue    UE
    stop_ue_proxy_on_ue_pc
    gnb_alarm.Disallow Alarm    No connection to unit
