*** Settings ***
Library     taf.rfrl.ue.iperf.tput_runner.ThroughputRunner    WITH NAME  tput
Library     testsuite.Krakow.SISO.regression.RAN_PZ_KRK4.CB008924.resources.scf_operations.ConfigurationOperations  WITH NAME  conf_op
Resource    taf/rfrl/bts/robot/gnb.robot
Library     taf.ue    WITH NAME    ute_ue

*** Keywords ***
Manual SiSo CM Recommissioning
    [Arguments]    ${duration}          ${data_size_dl}    ${data_size_ul}
    ...            ${parallel_streams}  ${protocol}=tcp    ${deviation}=10%  ${maximum_segment_size}=${EMPTY}
    attach_mtk_ue
    tput.Set data transfer parameters
    ...  parallel_streams_ul=${parallel_streams}
    ...  data_size_ul=${data_size_ul}
    ...  parallel_streams_dl=${parallel_streams}
    ...  data_size_dl=${data_size_dl}
    ...  protocol=${protocol}
    ...  maximum_segment_size=${maximum_segment_size}
    tput.run_bi_dir_traffic_with_ues_simultaneously
    ...  duration=${duration}
    tput.Validate current throughput values
    ...  transfers_to_validate=1
    ...  dl_tput=${data_size_dl}
    ...  ul_tput=${data_size_ul}
    ...  tolerance=${deviation}
    detach_mtk_ue
    conf_op.change_parameter                dist=MRBTS-{}/MNL-1/MNLENT-1/SYNC-1
    ...                                     param=Manual frame timing adjustment
    ...                                     value=1
    conf_op.activate_plan
    wait_for_site_to_be_onair
    attach_mtk_ue
    tput.run_bi_dir_traffic_with_ues_simultaneously
    ...  duration=${duration}
    tput.Validate current throughput values
    ...  transfers_to_validate=1
    ...  dl_tput=${data_size_dl}
    ...  ul_tput=${data_size_ul}
    ...  tolerance=${deviation}
    conf_op.verify_parameter_after_change   dist=MRBTS-{}/MNL-1/MNLENT-1/SYNC-1
    ...                                     param=Manual frame timing adjustment
    ...                                     value=1 (microseconds)
    Verify Allowed Alarms on gNB            allowed_alarms=@{allowed_alarms}
    detach_mtk_ue
    conf_op.save_and_verify_report

