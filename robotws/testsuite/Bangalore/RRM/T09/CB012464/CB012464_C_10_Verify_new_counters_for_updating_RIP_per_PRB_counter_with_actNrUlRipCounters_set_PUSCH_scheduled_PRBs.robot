*** Settings ***
Force Tags      5G_SC_TDD    5G_RAN     SBTS00     SBTS25R2    CONFIGURED

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          Collections
Resource         ../../../resources/robot/Setup_Env.robot
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Library          taf.sw.scout    WITH NAME     scout
Library          ta5g_pm_counters
Library          ta5g_commissioning
Resource         ../../../resources/robot/counter_benchmark_resource.robot

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1    4


Documentation
...      author:           Bhabani    bhabani.sankar_rout@nokia.com
...      maintainer:        Bhabani   bhabani.sankar_rout@nokia.com
...      INTRODUCTION:  Activation of measurement and respective PM Counters collection for UL interference and noise measurements
...      This user scenario aims at verification of update of RIP per PRB counters with new
...      activation flag (NRBTS/NRPMRNL/NRPMCCP.actNrUlRipCounters)
...      The operator activates PM counters by setting the parameter MRBTS/NRBTS/NRPMRNL/miNrRip to a values other than 0
...      The operator sets CM parameter NRBTS/NRPMRNL/NRPMCCP.actNrUlRipCounters as below to include measurements from
...      all UL channels in RIP counters

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/egate_TMOUS_csplit.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${TRF_ID}    1
${Q_O_ADD1}    1
${epc_log_path}    /tmp/
@{5QI1}     2    12    false
&{flows_ue1_pdu1}    ${2}=${5QI1}
@{crnti_list}
${host}=   192.168.255.129
${user}=   Nemuadmin
${password}=   nemuuser
${target_dir}=    /home/ute/Desktop/

*** Test Cases ***
[1][1.0] CB012464_C_10_Verify_new_counters_for_updating_RIP_per_PRB_counter_with_actNrUlRipCounters_set__PUSCH _scheduled_PRBs
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
        Find Scfc And Send Delta Commissioning    scfc_filename=scheduled_pucch_pusch_rach.json
        Create noise Profiles
        wts_sim_keywords.MultiUE Register should be Successful    1    30
        Activate Ues to the noise Profile
        wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    30   mbps    15
        sleep    120s
        Validate the scheduled pusch for CELL_AVG_UL_RIP_SCHED_PRB and CELL_MAX_UL_RIP_SCHED_PRB
        Validate the scheduled pucch for CELL_AVG_UL_RIP_SCHED_PRB and CELL_MAX_UL_RIP_SCHED_PRB
        Stop MultiUE Data Traffic for SA     1     30
        MultiUE Deregister should be Successful    1     30
        Find Scfc And Send Delta Commissioning    scfc_filename=Unscheduled_pusch.json
        Create noise Profiles
        wts_sim_keywords.MultiUE Register should be Successful    1    30
        Activate Ues to the noise Profile
        Validate the unscheduled pusch for CELL_AVG_UL_RIP_SCHED_PRB and CELL_MAX_UL_RIP_SCHED_PRB


    [Teardown]   Run Keywords        Link SCOUT SCF to Configuration ID for Reporting
    ...         AND        wts_sim_keywords.Clean edaemon and egate
    ...         AND        run keyword if test failed    Run Keyword and Ignore Error    Get Snapshot
    ...         AND        run keyword if test failed    Run Keyword and Ignore Error    Get Sos Report
*** Keywords ***
Create noise Profiles
       ute_wtssim.Execute Egate Command
    ...    cmd=ul_cell_noise_testmode_nr profile_id=1 noise_prach=-620 noise_pucch=-610 noise_pusch=-600 noise_srs=-630
    sleep    2s

Activate Ues to the noise Profile
     ute_wtssim.Execute Egate Command
     ...    cmd=cell_testmode_set_nr cell_id=1 gnb=1 testmode=ul_cell_noise profile_id=1 action=activate


Validate the scheduled pusch for CELL_AVG_UL_RIP_SCHED_PRB and CELL_MAX_UL_RIP_SCHED_PRB
#* [>-90 value given based on ul interference]*
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    FOR    ${PRB}    IN RANGE    14    267
        ${PRB_3}     Evaluate    f"{int(${PRB}):03d}"
        ${counter_max}    Set variable    M55360C01${PRB_3}
        ${counter_avg}    Set variable    M55360C00${PRB_3}
        ${counter_sample}    Set variable    M55388C00${PRB_3}
        Verify Last Counters In File
        ...     ${counter_sample}     >1000      NUM_RIP_SAMPLES_PRB10
        ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}
        verify_if_any_pm_counter_is_in_range_of_given_values
        ...     ${counter_max}     -106    -90    local_moid=MRBTS-1/NRBTS-1/NRCELL-1     filepath=${pm_counter_file}
        verify_if_any_pm_counter_is_in_range_of_given_values
        ...     ${counter_avg}     -106    -90    local_moid=MRBTS-1/NRBTS-1/NRCELL-1     filepath=${pm_counter_file}
    END

Validate the scheduled pucch for CELL_AVG_UL_RIP_SCHED_PRB and CELL_MAX_UL_RIP_SCHED_PRB
#* [>-90 value given based on ul interference]*
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
         verify_if_any_pm_counter_is_in_range_of_given_values
         ...     M55360C01000     -100    -90    local_moid=MRBTS-1/NRBTS-1/NRCELL-1     filepath=${pm_counter_file}
         verify_if_any_pm_counter_is_in_range_of_given_values
         ...     M55360C01001     -100    -90    local_moid=MRBTS-1/NRBTS-1/NRCELL-1     filepath=${pm_counter_file}
         verify_if_any_pm_counter_is_in_range_of_given_values
         ...     M55360C01004     -100    -90    local_moid=MRBTS-1/NRBTS-1/NRCELL-1     filepath=${pm_counter_file}
         verify_if_any_pm_counter_is_in_range_of_given_values
         ...     M55360C01005     -100    -90    local_moid=MRBTS-1/NRBTS-1/NRCELL-1     filepath=${pm_counter_file}
         verify_if_any_pm_counter_is_in_range_of_given_values
         ...     M55360C01006     -100    -90    local_moid=MRBTS-1/NRBTS-1/NRCELL-1     filepath=${pm_counter_file}
         verify_if_any_pm_counter_is_in_range_of_given_values
         ...     M55360C01008     -100    -90    local_moid=MRBTS-1/NRBTS-1/NRCELL-1     filepath=${pm_counter_file}
         verify_if_any_pm_counter_is_in_range_of_given_values
         ...     M55360C01009     -100    -90    local_moid=MRBTS-1/NRBTS-1/NRCELL-1     filepath=${pm_counter_file}
         verify_if_any_pm_counter_is_in_range_of_given_values
         ...     M55360C01010     -100    -90    local_moid=MRBTS-1/NRBTS-1/NRCELL-1     filepath=${pm_counter_file}
         verify_if_any_pm_counter_is_in_range_of_given_values
         ...     M55360C01000     -100    -90    local_moid=MRBTS-1/NRBTS-1/NRCELL-1     filepath=${pm_counter_file}
         verify_if_any_pm_counter_is_in_range_of_given_values
         ...     M55360C01001     -100    -90    local_moid=MRBTS-1/NRBTS-1/NRCELL-1     filepath=${pm_counter_file}
         verify_if_any_pm_counter_is_in_range_of_given_values
         ...     M55360C01004     -100    -90    local_moid=MRBTS-1/NRBTS-1/NRCELL-1     filepath=${pm_counter_file}
         verify_if_any_pm_counter_is_in_range_of_given_values
         ...     M55360C01005     -100    -90    local_moid=MRBTS-1/NRBTS-1/NRCELL-1     filepath=${pm_counter_file}
         verify_if_any_pm_counter_is_in_range_of_given_values
         ...     M55360C01006     -100    -90    local_moid=MRBTS-1/NRBTS-1/NRCELL-1     filepath=${pm_counter_file}
         verify_if_any_pm_counter_is_in_range_of_given_values
         ...     M55360C01008     -100    -90    local_moid=MRBTS-1/NRBTS-1/NRCELL-1     filepath=${pm_counter_file}
         verify_if_any_pm_counter_is_in_range_of_given_values
         ...     M55360C01009     -100    -90    local_moid=MRBTS-1/NRBTS-1/NRCELL-1     filepath=${pm_counter_file}
         verify_if_any_pm_counter_is_in_range_of_given_values
         ...     M55360C01010     -100    -90    local_moid=MRBTS-1/NRBTS-1/NRCELL-1     filepath=${pm_counter_file}

Validate the unscheduled pusch for CELL_AVG_UL_RIP_SCHED_PRB and CELL_MAX_UL_RIP_SCHED_PRB
#* [>-90 value given based on ul interference]*
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    FOR    ${PRB}    IN RANGE    18    180
        ${PRB_3}     Evaluate    f"{int(${PRB}):03d}"
        ${counter_max1}    Set variable    M55360C01${PRB_3}
        ${counter_avg1}    Set variable    M55360C00${PRB_3}
        ${counter_sample1}    Set variable    M55388C00${PRB_3}
        Verify Last Counters In File
        ...     ${counter_sample1}    >1000    NUM_RIP_SAMPLES_PRB10
        ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}
        verify_if_any_pm_counter_is_in_range_of_given_values
        ...     ${counter_max1}     -120    -110    local_moid=MRBTS-1/NRBTS-1/NRCELL-1     filepath=${pm_counter_file}
        verify_if_any_pm_counter_is_in_range_of_given_values
        ...     ${counter_avg1}     -120    -110    local_moid=MRBTS-1/NRBTS-1/NRCELL-1     filepath=${pm_counter_file}
    END
