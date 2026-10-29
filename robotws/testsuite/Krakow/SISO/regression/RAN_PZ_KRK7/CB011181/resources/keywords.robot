*** Settings ***
Documentation
...   author:  Wioleta Święs (wioleta.swies@nokia.com)
...   maintainers: Wioleta Święs
...   contact: Lubomir Krzemiński (lubomir.krzeminski@nokia.com)
...   contact: Adrianna Priotrkowska (adrianna.priotrkowska@nokia.com)

Library             taf.sbts.oam.coam.admin             WITH NAME      coam
Library   taf.sbts.oam.coam.admin                                     WITH NAME  admin
Resource  taf/rfrl/l3_call/call_manager.robot

Library   taf/rfrl/procedures/resources/python/admin_info_model/admin_info_model.py    WITH NAME  admin_info_model
Library   taf/rfrl/procedures/resources/python/connections.py                          WITH NAME  connections
Library   taf/rfrl/procedures/resources/python/timer/timer.py                          WITH NAME  timer

Resource  taf/rfrl/procedures/resources/robot/StatusCheck.robot
Resource  taf/rfrl/procedures/resources/robot/HWPTA_Logger.robot
Resource  taf/rfrl/procedures/resources/robot/L3Call.robot
Resource  taf/rfrl/procedures/resources/robot/Connections.robot
Resource  taf/rfrl/procedures/resources/robot/LockUnlock.robot
Resource  taf/rfrl/procedures/resources/robot/KPI.robot


*** Keywords ***
Prepare Test Line Commissionings And Wait For OnAir
    [Arguments]    ${scf_name}    ${timeout}=600
    ${SCF_GNB_PATH}    sg7keywords.Get Default Scf Path    file_name=${scf_name}
    Perform Bts Full Commissioning    scf_file=${SCF_GNB_PATH}
    ...                               timeout=400
    Sleep    60s
    gnbcell.Wait For All Cells To Be Onair    timeout=${timeout}

Check data transfer via Quectel
    [Documentation]    Keyword used to verify throughput (both DL and UL) using Quectel UE.
    ...                Requires useage `Require UE` with same ue_alias before call this KW.
    ...                Intended to be used multiple times within single test case.
    ...                Please define variables such as:
    ...                 - UE_DEFAULT_ALIAS_NAME
    ...                 - DATA_TRANSFER_DEFAULT_DURATION
    ...                 - DEFAULT_PACKET_SIZE
    ...                 - DEFAULT_PROTOCOL
    ...                 - DEFAULT_DEVIATION
    ...                on your Suite/Test level once as this Keyword will automatically loads these as defaults arguments.
    ...                Otherwise pass it normally - expicitly giving each argument desired value.

    [Arguments]    ${throughput_DL}
    ...            ${throughput_UL}
    ...            ${parallel_streams_DL}=1
    ...            ${parallel_streams_UL}=1
    ...            ${ue_alias}=${UE_DEFAULT_ALIAS_NAME}
    ...            ${ue_capabilities}=${UE_CAPABILITIES}
    ...            ${duration}=${DATA_TRANSFER_DEFAULT_DURATION}
    ...            ${packet}=${DEFAULT_PACKET_SIZE}
    ...            ${protocol}=${DEFAULT_PROTOCOL}
    ...            ${deviation}=${DEFAULT_DEVIATION}
    ...            ${linux_congestion}=reno
    ...            ${log_throughput}=${False}
    ...            ${prepare_config_for_NSA}=${False}
    ...            ${prepare_config_for_SA}=${False}

    ute_ue.Require UE    ${ue_alias}    capabilities=${ue_capabilities}
    Run Keyword If    ${prepare_config_for_NSA}    Prepare UE For NSA L3 Call
    Run Keyword If    ${prepare_config_for_SA}     Prepare UE For SA L3 Call
    ute_ue.Attach UE    ${ue_alias}
    Sleep    10sec

    ute_ue.Get UE Info    ${ue_alias}    ALL
    Check DL and UL data transfer with Quectel    throughput_DL=${throughput_DL}
    ...                                           throughput_UL=${throughput_UL}
    ...                                           parallel_streams_DL=${parallel_streams_DL}
    ...                                           parallel_streams_UL=${parallel_streams_UL}
    ...                                           ue_alias=${ue_alias}
    ...                                           duration=${duration}
    ...                                           packet=${packet}
    ...                                           protocol=${protocol}
    ...                                           deviation=${deviation}
    ...                                           linux_congestion=${linux_congestion}
    ...                                           log_throughput=${log_throughput}

    [Teardown]    Run keywords    ute_ue.Detach UE    ${ue_alias}    AND
    ...           Run Keyword And Ignore Error    ute_ue.Stop Using UE    ${ue_alias}

Prepare UE For NSA L3 Call
    [Arguments]    ${lte_band}=${LTE_DEFAULT_BAND}    ${nr5g_band}=${NR5G_DEFAULT_BAND}    ${apn_name}=${APN_NSA_NAME}
    Adjust Apn             ${UE_DEFAULT_ALIAS_NAME}    pdp_type=IP     apn_name=${apn_name}
    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    NR5G:LTE    ue_type=${UE_TYPE}
    Set Active Bands       ${UE_DEFAULT_ALIAS_NAME}    LTE    ${lte_band}
    Set Active Bands       ${UE_DEFAULT_ALIAS_NAME}    NR5G    ${nr5g_band}
    Reboot_ue              ${UE_DEFAULT_ALIAS_NAME}    timeout=${170}
    Sleep    60
    Run Keyword And Ignore Error    ute_ue.Stop Using UE    ${ue_alias}
    Run Keyword And Ignore Error    ute_ue.Require UE    ${UE_DEFAULT_ALIAS_NAME}    capabilities=${UE_CAPABILITIES}

Prepare UE For SA L3 Call
    [Arguments]    ${nr5g_band}=${NR5G_DEFAULT_BAND}    ${apn_name}=${APN_SA_NAME}
    Adjust Apn             ${UE_DEFAULT_ALIAS_NAME}      pdp_type=IP     apn_name=${apn_name}
    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}      NR5G    ue_type=${UE_TYPE}
    Set Active Bands       ${UE_DEFAULT_ALIAS_NAME}      NR5G    ${nr5g_band}
    Reboot_ue              ${UE_DEFAULT_ALIAS_NAME}      timeout=${170}
    Sleep    60
    Run Keyword And Ignore Error    ute_ue.Stop Using UE    ${ue_alias}
    Run Keyword And Ignore Error    ute_ue.Require UE    ${UE_DEFAULT_ALIAS_NAME}    capabilities=${UE_CAPABILITIES}

Cell_Lock_Unlock
    [Arguments]                                 ${bts_type}=GNB
    ${connection}=                              connections.get_default_admin_connection_alias
    ...                                         bts_type=${bts_type}
    @{all_cells_distnames}=                     admin_info_model.get_configuration_distnames_of_all_cells
    ...                                         connection=${connection}

    Allow DSS Alarms If DSS On Any RMOD         bts_type=${bts_type}
    Lock Cells                                  bts_type=${bts_type}
    KRK7 Check If Each Cell Is Locked           bts_type=${bts_type}
    Run Keyword And Ignore Error    Unlock Each Cell    bts_type=${bts_type}
    Check If Each Cell Is Online                bts_type=${bts_type}
    Check BTS state and all RATs states         bts_type=${bts_type}
    Disallow DSS Alarms If DSS On Any RMOD      bts_type=${bts_type}
    [Teardown]  Run Keyword And Ignore Error    Unlock Each Cell
    ...                                         bts_type=${bts_type}


Lock Cells
    [Arguments]                                 ${bts_type}=GNB
    ${connection}=                              connections.get_default_admin_connection_alias
    ...                                         bts_type=${bts_type}
    @{cells}=                                   admin_info_model.get_admin_cells_parameters
    ...                                         connection=${connection}
    @{cell_dist_names}=                         admin_info_model.get_configuration_distnames_of_all_cells
    ...                                         connection=${connection}
    @{unlocked_cells_dist_names}                Copy List    ${cell_dist_names}

    FOR  ${cell}  IN  @{cells}
        ${cell_id}=                   Get From Dictionary  ${cell}  CELLID
        ${cell_rat}=                  Get From Dictionary  ${cell}  RAT
        Run Keyword If    "wcdma" in '${cell_rat}'    Continue For Loop
        ${is_iot_cell}                admin_info_model.is_iot_cell
        ...                           connection=${connection}
        ...                           cell_id=${cell_id}
        ...                           cell_type=${cell_rat}
        Continue for loop if          ${is_iot_cell}
        ${runtime_dist_name}=         Get From Dictionary  ${cell}  runtimeDistName
        ${configuration_dist_name}=   Get From Dictionary  ${cell}  configurationDistName
        ${cell_lock_timeout}=         Get Timeout Cell Lock
        ${operation_succeed}=         admin.lock
        ...                           dist_name=${runtime_dist_name}
        ...                           connection=${connection}
        ...                           timeout=80s
        ${adjusted_cell_id}=          Convert To String   ${cell_id}
        @{list_of_adjusted_cell_id}=  Create list   ${adjusted_cell_id}
        timer.wait_until_keyword_succeeds_timer
        ...                               ${cell_lock_timeout}
        ...                               5s
        ...                               Check statuses for specific cells
        ...                               cell_ids=${list_of_adjusted_cell_id}
        ...                               cell_type=${cell_rat}
        ...                               connection=${connection}
        ...                               status_variant=locked
        Run keyword if                    '${operation_succeed}'=='completed'
        ...                               Robot Log Iteration  msg=Cell ${runtime_dist_name} is locked.
        Remove Values From List           ${unlocked_cells_dist_names}   ${configuration_dist_name}
        @{configuration_dist_name_in_list}=
        ...                               create list
        ...                               ${configuration_dist_name}
    END

KRK7 Check If Each Cell Is Locked
    [Arguments]                  ${bts_type}=GNB
    ${connection}=               connections.get_default_admin_connection_alias
    ...                          bts_type=${bts_type}
    Robot Log Operation          Checking all locked cells statuses
    KRK7 Check statuses of all cells
    ...                          connection=${connection}
    ...                          status_variant=locked
    Robot Log Result             All cells are locked.
    ...                          to_console=${True}

KRK7 Check statuses of all cells
    [Arguments]             ${connection}
    ...                     ${status_variant}=online

    ${rats}=                admin_info_model.get_rats            connection=${connection}

    FOR   ${rat}   IN   @{rats}
    	Run Keyword If    "wcdma" in '${rat}'    Continue For Loop
        Robot Log Iteration             Verifying statuses of cells for RAT ${rat}...
        ...                                     to_console=${False}
        status_check.verify_statuses_of_all_cells
        ...     cells_type=${rat}
        ...     status_variant=${status_variant}
        ...     connection=${connection}
    END

    Robot Log Result      Cells statuses validation finished successfully.

