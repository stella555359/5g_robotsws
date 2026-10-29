*** Settings ***
Documentation
...    Additional robot keywords for CNI126050 FR1 part
...    authors: Jakub Bialon
...    maintainer: Jakub Bialon
...    group: RAN_PZ_KRK_SG_7
...    contact: jakub.bialon@nokia.com

Library    Process
Library    toolsFR1.py
Library    taf.rfrl.bts.devices.du.cell_operations.GenericCellOperations    WITH NAME    celloperations
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library    ute_ue
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library     taf.rfrl.bts.devices.du.pm_counters.GenericPmCounter    WITH NAME    pmcounters


*** Variables ***
${GENERATOR_IP}    10.83.179.147
${VECTOR_UL_PATH}    testsuite/Krakow/RRM/RAN_PZ/regression/KRK7/CNI126050/resources/test_vector_ul_FR1.csv
${VECTOR_DL_PATH}    testsuite/Krakow/RRM/RAN_PZ/regression/KRK7/CNI126050/resources/test_vector_dl_FR1.csv
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}
${DATA_TRANSFER_DEFAULT_DURATION}    530s
${DEFAULT_PACKET_SIZE}    1380
${DEFAULT_UE_ALIAS}    SAMSUNG_UE
${DEFAULT_PROTOCOL}    tcp
${TPUT_DEVIATION}    10%


*** Keywords ***
Start UL Data Transfer
    ute_ue.Attach UE    ${DEFAULT_UE_ALIAS}
    Sleep    10sec    reason=Waiting for attach procedure take effect
    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${DEFAULT_UE_ALIAS}
    ...                           direction=ul
    ...                           duration=${DATA_TRANSFER_DEFAULT_DURATION}
    ...                           packet=${DEFAULT_PACKET_SIZE}
    ...                           throughput=100 Mbits/sec
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=2
    ...                           linux_congestion=reno
    Sleep    10sec    reason=Waiting for data transfer stabilization


Start DL Data Transfer
    ute_ue.Attach UE    ${DEFAULT_UE_ALIAS}
    Sleep    10sec    reason=Waiting for attach procedure take effect
    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${DEFAULT_UE_ALIAS}
    ...                           direction=dl
    ...                           duration=${DATA_TRANSFER_DEFAULT_DURATION}
    ...                           packet=${DEFAULT_PACKET_SIZE}
    ...                           throughput=500 Mbits/sec
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=4
    ...                           linux_congestion=reno
    Sleep    10sec    reason=Waiting for data transfer stabilization


Await UL Transfer Finish And Verify Throughput
    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    ute_ue.Verify Average Throughput With Deviation    dt_name=DT_UL
    ...                                                tput=50 Mbits/sec
    ...                                                deviation=${TPUT_DEVIATION}


Await DL Transfer Finish And Verify Throughput
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    ute_ue.Verify Average Throughput With Deviation    dt_name=DT_DL
    ...                                                tput=170 Mbits/sec
    ...                                                deviation=${TPUT_DEVIATION}


Start Generator With Settings
    [Arguments]    ${frequency_val}
    ...            ${amplitude_val}
    ...            ${bandwidth_val}
    toolsFR1.run_generator    generator_ip=${GENERATOR_IP}
    toolsFR1.set_generator
    ...    generator_ip=${GENERATOR_IP}
    ...    frequency_val=${frequency_val}
    ...    amplitude_val=${amplitude_val}
    ...    bandwidth_val=${bandwidth_val}


Download And Find Required Pm Counters
    [Arguments]
    ...    ${time_stamp}
    ...    ${out_dir_path}
    ${counters_ids}=    toolsFR1.Generate Names Of Counters
    ${cell_list}    gnbcell.Get All Cells Id
    ${counter_dict_list}=    pmcounters.Get Counter    counter_ids=${counters_ids}
    ${counters_excel_path}=    toolsFR1.Find Pm Counters By Time Stamp    ${time_stamp}
    ...                                                                   ${counter_dict_list}
    ...                                                                   ${cell_list}
    ...                                                                   ${out_dir_path}
    ...                                                                   ${counters_ids}
    [Return]    ${counters_excel_path}


Install pandas with pip
    ${result}=    Run Process    pip install pandas    shell=True    stdout=../../../logs/pip_install_result.txt
    Log To Console   ${result}
