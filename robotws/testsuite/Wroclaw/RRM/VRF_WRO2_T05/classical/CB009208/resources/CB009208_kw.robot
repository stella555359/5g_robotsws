*** Settings ***
Documentation    Suite description
Resource        testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/phase_shifter/ps.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009208/resources/CB009208.py    WITH NAME    CB009208
Library         taf.sbts.oam.coam.admin  WITH NAME  coam

*** Keywords ***
Read counters value For PRACH
    ${counters_values}=   Create List
    Collect Counters   n_last=15
    @{counters}   Create list  M55306C03001  M55306C06001
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   3  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Read counters value For Mu Scheduling
    ${counters_values}=   Create List
    Collect Counters   n_last=15
    @{counters}   Create list  M55308C34013  M55308C34011
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   2  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Read counters value For Power Saving
    ${counters_values}=   Create List
    Collect Counters   n_last=15
    @{counters}   Create list   M55351C00001  M55351C00002  M55351C01001  M55351C01002  M55308C33000  M55308C33001
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   2  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters For PRACH
    log to console              Waiting for BTS Counters update 300s
    sleep   300s
    ${counters}                 Read Counters Value For PRACH
    Log to console  ${counters}
    ${rasetup}                    get_counter_value_from_single_cell   ${counters}  501    M55306C03001
    ${msg3_reception}             get_counter_value_from_single_cell   ${counters}  501    M55306C06001
    Should Be True      ${rasetup}>=2
    Should Be True      ${msg3_reception}>=2

Verify PM Counters For Mu Scheduling
    log to console              Waiting for BTS Counters update 300s
    sleep   300s
    ${counters}                 Read counters value For Mu Scheduling
    Log to console  ${counters}
    ${PRBs_for_2_UE_pair}           get_counter_value_from_single_cell   ${counters}  501    M55308C34013
    ${PRBs_for_8_layer}             get_counter_value_from_single_cell   ${counters}  501    M55308C34011
    Should Be True      ${PRBs_for_2_UE_pair}>0  Lack of counters for M55308C34013 Num of PRBs for 2 UE pair tx for MU MIMO in DL
    Should Be True      ${PRBs_for_8_layer}>0  Lack of counters for M55308C34011 Number of PRBs for 8-layer Tx for MU MIMO in DL

Verify PM Counters For Power Saving Step 1
    log to console              Waiting for BTS Counters update 300s
    sleep   300s
    ${counters}                 Read counters value For Power Saving
    Log to console  ${counters}
    ${max_ue_power_saving_bwp}           get_counter_value_from_single_cell   ${counters}  501    M55351C00001
    ${avg_ue_power_saving_bwp}           get_counter_value_from_single_cell   ${counters}  501    M55351C00002
    ${max_ue_with_2_bwp}                 get_counter_value_from_single_cell   ${counters}  501    M55351C01001
    ${avg_ue_with_2_bwp}                 get_counter_value_from_single_cell   ${counters}  501    M55351C01002
    ${put_under_DTX_sched}               get_counter_value_from_single_cell   ${counters}  501    M55308C33000
    ${end_of_DTX_retention}              get_counter_value_from_single_cell   ${counters}  501    M55308C33001
    Should Be True      ${max_ue_power_saving_bwp}>0  Lack of counters for M55351C00001 Maximum number of UEs with active Power Saving BWP
    Should Be True      ${avg_ue_power_saving_bwp}>0  Lack of counters for M55351C00002 Average number of UEs with active Power Saving BWP
    Should Be True      ${max_ue_with_2_bwp}>0  Lack of counters for M55351C01001 Maximum number of UEs configured with 2 BWPs
    Should Be True      ${avg_ue_with_2_bwp}>0  Lack of counters for M55351C01002 Average number of UEs configured with 2 BWPs
    Should Be True      ${put_under_DTX_sched}>0  Lack of counters for M55308C33000 Accumulated number of UEs put under DTX optimized scheduling
    Should Be True      ${end_of_DTX_retention}>0  Lack of counters for M55308C33001 Accumulated number of UEs reached end of DTX retention before

Verify PM Counters For Power Saving Step 2
    log to console              Waiting for BTS Counters update 300s
    sleep   300s
    ${counters}                 Read counters value For Power Saving
    Log to console  ${counters}
    ${max_ue_power_saving_bwp}           get_counter_value_from_single_cell   ${counters}  501    M55351C00001
    ${avg_ue_power_saving_bwp}           get_counter_value_from_single_cell   ${counters}  501    M55351C00002
    ${max_ue_with_2_bwp}                 get_counter_value_from_single_cell   ${counters}  501    M55351C01001
    ${avg_ue_with_2_bwp}                 get_counter_value_from_single_cell   ${counters}  501    M55351C01002
    ${put_under_DTX_sched}               get_counter_value_from_single_cell   ${counters}  501    M55308C33000
    ${end_of_DTX_retention}              get_counter_value_from_single_cell   ${counters}  501    M55308C33001
    Should Be True      ${avg_ue_power_saving_bwp}==0  M55351C00002 Should be 0
    Should Be True      ${max_ue_with_2_bwp}>0  Lack of counters for M55351C01001 Maximum number of UEs configured with 2 BWPs
    Should Be True      ${avg_ue_with_2_bwp}>0  Lack of counters for M55351C01002 Average number of UEs configured with 2 BWPs
    Should Be True      ${put_under_DTX_sched}>0  Lack of counters for M55308C33000 Accumulated number of UEs put under DTX optimized scheduling
    ${result} =    Evaluate    ${end_of_DTX_retention}/${put_under_DTX_sched} < 0.5
    Should Be True      ${result}  M55308C33001 / M55308C33000 should be < 0.5

Setup phase shifter
    [Arguments]  ${frequency}=3550_0.5_ALL
    ps.Setup phase shifter  server_ip=10.44.234.46  model=MCS2350A2-128B16-A5  frequency=${frequency}

Update phase shifter config
    [Arguments]  ${config_file}
    ps.Create output channels lists  file=${config_file}
    ps.Update attenuations    length=128
    ps.Update phases    length=128

Teardown phase shifter
    ps.Teardown MCS

Add 0x580265=0 flag to sw config and wait cells on air
    CB009208.add_flag_to_swconfig  swconfig_backup  0x580265=0
    Wait until keyword succeeds    20 min    1 min    CB009208.Verify all cells onair with admin

Restore original sw config and wait cells on air
    CB009208.restore_original_swconfig  swconfig_backup
    Wait until keyword succeeds    20 min    1 min    CB009208.Verify all cells onair with admin

Load scf for NR 9208
    [Arguments]         ${resource_path}    ${folder_name}    ${scf_nr_name}
    ${host_name}=       Get TL hostname 9208
    ${stream_name}=     Get stream name 9208
    log to console      Start commissioning NR
    ${result}  coam.perform_commissioning     scf_file=${resource_path}/${folder_name}/${host_name}/${stream_name}/${scf_nr_name}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=600
    ...   connection=cOAM
    log to console      Commissioning NR result=${result}
    Sleep   100s
    Wait until keyword succeeds    20 min    1 min    CB009208.Verify all cells onair with admin

Get TL hostname 9208
    ${result} = 	Run   uname -a|awk '{print $2}'
    [Return]  ${result}

Get stream name 9208
    # [Arguments]    ${connection}=cOAM_stream
    ${stream} = 	coam.Get sw release name    connection=cOAM
    ${stream_name}=  Set Variable If
    ...  '${stream}'=='SBTS23R1'  SBTS23R1
    ...  '${stream}'=='SBTS23R2'  SBTS23R2
    ...  '${stream}'=='SBTS23R3'  SBTS23R3
    ...  '${stream}'=='SBTS23R4'  SBTS23R4
    ...  '${stream}'=='SBTS26R1'  SBTS26R1   TRUNK
    [Return]  ${stream_name}
