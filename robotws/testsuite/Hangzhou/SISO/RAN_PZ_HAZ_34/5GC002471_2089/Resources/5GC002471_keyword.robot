*** Settings ***

Documentation
...    author: Ye, Michael
...    contact: tianyi.ye@nokia-sbell.com
...    Group: HGZ_SG8


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
*** Variables ***
@{bandlist}

*** Keywords ***

General_SiSo_E2E_system_setup_with_data_transfer_conducted_peak_contiguous
    ${contiguous_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_5040_
    Commissioning SCF And Check On Air    scf_path=${contiguous_SCF}
    ${bandlist}    create list    ${50}    ${40}
    ${bands}    set variable    ${EMPTY}
    FOR    ${item}    IN    @{bandlist}
        ${bands}    catenate    SEPARATOR=_    ${bands}    ${item}MHz
    END
    ${length}     Get length    ${frame_structure_list${bands}}[0][frame]
    FOR    ${index}    IN RANGE    ${length}
        ${frame_info}    Get framestructinfo   framelistname=${frame_structure_list_${bands}}    frameindex=${index}
        data_transfer_2089_differenc band    ue_index_list=${ue_list}    cell_list=${cell_list}    frames_info=${frame_info}
        ...    bandlist=${bandlist}    ue_num_each_call=2
    END

data_transfer_2089
    [Arguments]  ${ue_index_list}    ${cell_list}     ${band}=${None}    ${frame_structure}=${None}    ${dl_tp}=300M  ${ul_tp}=100M
    ...    ${duration}=${600}    ${protocol}=udp    ${check_wait_time}=30    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    ...    ${iperf_type}=${None}    ${ue_ul_layer}=1    &{kwargs}
    log to console    \nUe Attach and Start DL UL Traffic
    ${iperf_type}    Get Iperf Type    iperf_type=${iperf_type}    protocol=${protocol}
    ${cell_and_peak_info}    generate peak information     cell_list=${cell_list}
    ...    connection=${connection}    ue_ul_layer=${ue_ul_layer}    duration=${duration}
    ${ue_and_cell}    create dictionary
    ${process_num}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
        ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
        Connect to Common Unit Master  alias=${alias}
        connect to gnb coam via ssl    connection=${connection}
        ${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=/tmp/5Grach.txt
        ...    alias=${alias}    connection=${connection}
        set to dictionary  ${ue_and_cell}  ${ue_index}  ${cell_id}
    END
    ${ue_number}  get length  ${ue_index_list}
    ${dl_tp}  ${ul_tp}  ${duration_call}  get_start_traffic_information    cell_id=${cell_id}    ue_number=${ue_number}  dl_tp=${dl_tp}
        ...    ul_tp=${ul_tp}    duration=${duration}    cell_and_peak_info=${cell_and_peak_info}
        ...    check_wait_time=${check_wait_time}
    FOR  ${ue_index}  IN  @{ue_index_list}
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
        ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${process_num}
        power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
        ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}    data_amount=2M
    END
    UE Verify Peak Throughput    ue_index_list=${ue_index_list}    ue_and_cell=${ue_and_cell}    cell_and_peak_info=${cell_and_peak_info}
    [Teardown]    run keywords  run keyword and ignore error  csn.disconnect    connection=${alias}  AND  Ue Stop DL UL Traffic and Detach
    ...    ue_index_list=${ue_index_list}    iperf_type=${iperf_type}    protocol=${protocol}


data_transfer_2089_differenc band
    [Arguments]    ${bandlist}    ${ue_index_list}    ${cell_list}    ${frames_info}    ${ue_num_each_call}=1  ${random_access}=${False}
    ...    ${dl_tp}=300M    ${ul_tp}=100M    ${duration}=${600}    ${protocol}=udp    ${check_wait_time}=30    ${alias}=ASIK MASTER
    ...    ${connection}=GNB_OAM    ${iperf_type}=${None}    ${ue_ul_layer}=1    &{kwargs}
    ${iperf_type}    Get Iperf Type    iperf_type=${iperf_type}    protocol=${protocol}
    ${process_num}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    ${ue_number}  get length  ${ue_index_list}
#    ${cell_and_peak_info}    generate peak information     cell_list=${cell_list}
#    ...    connection=${connection}    ue_ul_layer=${ue_ul_layer}    duration=${duration}
    ${ue_and_cell}    create dictionary
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
        ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
        Connect to Common Unit Master  alias=${alias}
        connect to gnb coam via ssl    connection=${connection}
        ${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=/tmp/5Grach.txt
        ...    alias=${alias}    connection=${connection}
        set to dictionary  ${ue_and_cell}  ${ue_index}  ${cell_id}
    END
    ${dl_tp}  ${ul_tp}  ${duration_call}  get_start_traffic_information    cell_id=${cell_id}    ue_number=${ue_number}  dl_tp=${dl_tp}
    ...    ul_tp=${ul_tp}    duration=${duration}    cell_and_peak_info=${cell_and_peak_info_contiguous}    check_wait_time=${check_wait_time}
    FOR  ${ue_index}  IN  @{ue_index_list}
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
        ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${process_num}
        power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
        ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}    data_amount=2M
    END
    UE Verify Peak Throughput    ue_index_list=${ue_index_list}    ue_and_cell=${ue_and_cell}    cell_and_peak_info=${cell_and_peak_info_contiguous}
    ...    duration=${300}
    [Teardown]    run keyword  run keyword and ignore error  csn.disconnect    connection=${alias}
