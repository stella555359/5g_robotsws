*** Settings ***
Documentation
...    Author:          Nelsandro Sampaio, nelsandro.sampaio@nokia.com
...                     Mateusz Matusik, mateusz.matusik@nokia.com
...    Maintainer:      Nelsandro Sampaio, nelsandro.sampaio@nokia.com

Library      keywords.py
Library      taf.sbts.oam.coam.admin  WITH NAME  admin_sbts
Library      taf.selenium.sc          WITH NAME    sc
Library      taf.rfrl.bts.devices.ru.ru_operations.GenericRuOperations     WITH NAME   GnbRadio
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations     WITH NAME   gnbcell
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations   WITH NAME   gnbasir
Library      taf.rfrl.bts.commissioning
Library      testsuite/Krakow/resources/RAN_PZ_KRK7/Quectel_L3_Call/helpers.py    WITH NAME     helper
Library      testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py    WITH NAME    sg7keywords
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library      taf.rfrl.csv4all.resources.utilities.utilities                WITH NAME    csv4all_utilities
Resource     keywords.robot


*** Variables ***
${BTS_ID}                     ${tl.gnbs[0].global_bts_id}
${VIRTUAL_DISPLAY}            ${True}
&{EXPECTED_ASIRMOD_STATUS}    availabilityStatus=Online    administrativeState=Unlocked    operationalState=Enabled
${COLLECT_LOGS_DURING_DATA_TRANSFER}   ${False}
${UE_DEFAULT_ALIAS_NAME}   UE
${DATA_TRANSFER_DEFAULT_DURATION}   120s
${DEFAULT_PACKET_SIZE}   1380
${DEFAULT_PROTOCOL}   tcp
${DEFAULT_DEVIATION}   40%
@{CELLS_LIST_B1}     1    2    3    4    5    6    7     8      9
...                  11    12    13    14    15    16    20    21    22
${WEBUI_URL}        https://192.168.255.129:3601
${WEBUI_NAME}       Nemuadmin
${WEBUI_PWD}        nemuuser
@{CELL_NSA_11_3_ATT_PORTS}     ${1}    ${6}
@{CELL_NSA_12_3_ATT_PORTS}     ${9}    ${4}    ${16}    ${11}
@{CELL_NSA_13_3_ATT_PORTS}     ${3}    ${4}    ${12}    ${15}
@{CELL_NSA_14_3_ATT_PORTS}     ${3}    ${8}
@{CELL_NSA_15_3_ATT_PORTS}     ${1}    ${6}    ${2}     ${5}
@{CELL_NSA_16_3_ATT_PORTS}     ${9}    ${12}
@{CELL_LTE_3}      ${11}    ${6}    ${9}    ${14}
@{CELL_LTE_3_minimal}      ${11}   # ${14}
@{CELL_LTE_6}      ${13}    ${16}
@{CELL_LTE_21_22}    ${9}    ${10}    ${16}     ${15}
@{CELL_ALL_PORTS}   ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}
              ...   ${9}    ${10}   ${11}   ${12}   ${13}   ${14}   ${15}   ${16}

*** Keywords ***
${operation} ASIRMOD-${asirmod_id} via WebEM for MRBTS-${mrbts_id}
    [Documentation]      Keywords performs reset asirmod unit from admin cli level / WEM
    Log to console     ${operation} ASIRMOD-${asirmod_id} via WebEM for MRBTS-${mrbts_id}
    Should Be True    type(${mrbts_id}) is int      msg=Invalid KW parameter: MRBTS_ID
    Should Be True    type(${asirmod_id}) is int    msg=Invalid KW parameter: asirmod_id
    Should Be True   '${operation}' in ('Reset','Lock', 'Unlock')    msg=Invalid KW parameter: silent
    admin_sbts.Connect to      name=coam
    Run Keyword IF         '${operation}' == 'Reset'     admin_sbts.reset_unit
    ...        dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ASIRMOD-${asirmod_id}
    ...        connection=coam
    ...        timeout=300
    ...        ELSE IF     '${operation}' == 'Lock'     admin_sbts.lock
    ...        dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ASIRMOD-${asirmod_id}
    ...        connection=coam
    ...        timeout=300
    ...        ELSE IF     '${operation}' == 'Unlock'     admin_sbts.unlock
    ...        dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ASIRMOD-${asirmod_id}
    ...        connection=coam
    ...        timeout=300
    admin_sbts.teardown         connection=coam



Attach UE, check bi-directional traffic and detach UE on timeout
    [Arguments]    ${max_tput_dl}     ${max_tput_ul}     ${traffic_duration}    ${protocol}
    ...            ${nr_cell_id}     ${lte_cell_id}=${3}      ${nsa_ue}=${True}
    Should Be True    type(${nr_cell_id}) is int      msg=Invalid KW parameter: nr_cell_id
    Should Be True    type(${lte_cell_id}) is int     msg=Invalid KW parameter: lte_cell_id
    gnbcell.Block All Cells
    gnbcell.Unblock Cell   cell_id=${3}   timeout=300
    run keyword if     ${nsa_ue} == ${True}    Unblock Cell and wait cell to be OnAir     cell_id=${nr_cell_id}
    ...                ELSE                    Unblock Cell and wait cell to be OnAir     cell_id=${lte_cell_id}
    Prepare UE for NSA L3 Call     band_lte=1     band_nr=3
    Attach UE and Start DL and UL traffic    throughput_DL=${max_tput_dl}
    ...                                throughput_UL=${max_tput_ul}
    ...                                duration=${traffic_duration}
    ...                                protocol=${protocol}
    ...                                ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                                desired_pci=${nr_cell_id}
    ...                                log_throughput=${True}
    sg7keywords.Unblock cells    [11,12,13,14,15,16,1,2,4,5,6,7,8,9,20,21,22]    ignore_error=${True}
    gnbcell.Wait For All Cells To Be OnAir    timeout=600
    Wait Until Keyword Succeeds    3x    30 s    gnbasir.Verify Status Of All Asir Cells Is Operational
    [Teardown]    ute_ue.Stop Using UE     ${UE_DEFAULT_ALIAS_NAME}



Attach UE, check bi-directional traffic and detach UE witohut cell check
    [Arguments]    ${max_tput_dl}     ${max_tput_ul}     ${traffic_duration}    ${protocol}
    ...            ${nr_cell_id}     ${lte_cell_id}=${3}      ${nsa_ue}=${True}
    Should Be True    type(${nr_cell_id}) is int      msg=Invalid KW parameter: nr_cell_id
    Should Be True    type(${lte_cell_id}) is int     msg=Invalid KW parameter: lte_cell_id
    gnbcell.Block All Cells
    gnbcell.Unblock Cell   cell_id=${3}   timeout=300
    run keyword if     ${nsa_ue} == ${True}    Unblock Cell and wait cell to be OnAir     cell_id=${nr_cell_id}
    ...                ELSE                    Unblock Cell and wait cell to be OnAir     cell_id=${lte_cell_id}
    Prepare UE for NSA L3 Call     band_lte=1     band_nr=3
    Attach UE and Start DL and UL traffic    throughput_DL=${max_tput_dl}
    ...                                throughput_UL=${max_tput_ul}
    ...                                duration=${traffic_duration}
    ...                                protocol=${protocol}
    ...                                ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                                desired_pci=${nr_cell_id}
    ...                                log_throughput=${True}
    sg7keywords.Unblock cells    [11,12,13,14,15,16,1,2,4,5,6,7,8,9,20,21,22]    ignore_error=${True}
    [Teardown]    ute_ue.Stop Using UE     ${UE_DEFAULT_ALIAS_NAME}




Prepare UE for NSA L3 Call
    [Arguments]      ${band_lte}      ${band_nr}
    Log to console         Preparing UE for NSA L3 Call
    ute_ue.Require UE      ${UE_DEFAULT_ALIAS_NAME}    capabilities=QUECTEL_UE
    Adjust Apn             ${UE_DEFAULT_ALIAS_NAME}    pdp_type=IP     apn_name=5gkrk
    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    NR5G:LTE    ue_type=quectel
    Set Active Bands       ${UE_DEFAULT_ALIAS_NAME}    LTE     ${band_lte}
    Set Active Bands       ${UE_DEFAULT_ALIAS_NAME}    NSA_NR5G    ${band_nr}
    Run Keyword And Ignore Error    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}



Unblock Cell and wait cell to be OnAir
    [Arguments]      ${cell_id}
    gnbcell.Unblock Cell   cell_id=${cell_id}   timeout=300
    gnbcell.Wait For Cell To Be Onair   cell_id=${cell_id}   timeout=300


Set attenuation level in dB for NR and LTE Cells
    [Arguments]       ${db_level_nr}      ${db_level_lte}      ${lte_cell_list}
    ...      ${nr_cell_list}
    FOR    ${port}    IN    @{nr_cell_list}
        setup_attenuation_for_nr_and_lte_cells         port=${port}
        ...         value=${db_level_nr}
    END
    FOR    ${port}    IN    @{lte_cell_list}
        setup_attenuation_for_nr_and_lte_cells         port=${port}
        ...         value=${db_level_lte}
    END


Attach UE and Start DL and UL traffic
    [Arguments]   ${throughput_DL}
    ...           ${throughput_UL}
    ...           ${desired_pci}
    ...           ${parallel_streams_DL}=10
    ...           ${parallel_streams_UL}=5
    ...           ${ue_alias}=${UE_DEFAULT_ALIAS_NAME}
    ...           ${duration}=${DATA_TRANSFER_DEFAULT_DURATION}
    ...           ${packet}=${DEFAULT_PACKET_SIZE}
    ...           ${protocol}=${DEFAULT_PROTOCOL}
    ...           ${deviation}=${DEFAULT_DEVIATION}
    ...           ${cells_to_block}=${None}
    ...           ${log_throughput}=${False}

    Log to console     Attaching UE
    Run Keyword If    $cells_to_block    sg7keywords.Block cells    ${cells_to_block}    ignore_error=${True}
    Sleep   2sec
    ute_ue.Attach UE   ${ue_alias}
    Sleep   10sec
    Run Keyword If    $cells_to_block    sg7keywords.Unblock cells    ${cells_to_block}    ignore_error=${True}
    Log to console      Getting UE info...  no_newline=True
    ${UE_INFO}=    ute_ue.Get UE Info    ${ue_alias}    ALL
    Run Keyword And Warn On Failure
    ...    log_keys_ue_info    ue_info=${UE_INFO}    key_list=['cell_id','ARFCN','earfcn','PCID','PCID_lte','RSRP','RSRP_lte']
    ${pci}      convert to string     ${desired_pci}
    helper.Check PCI From Get UE Info    ${UE_INFO}    ${pci}
    Log to console       Start DL traffic
    ute_ue.Start Data Transfer   dt_name=DT_DL
    ...                          ue_alias=${ue_alias}
    ...                          direction=dl
    ...                          duration=${duration}
    ...                          packet=${packet}
    ...                          max_segment_size=${packet}
    ...                          throughput=${throughput_DL}
    ...                          protocol=${protocol}
    ...                          parallel_streams=${parallel_streams_DL}
    ...                          linux_congestion=reno
    ute_ue.Await Data Transfer Finish   dt_name=DT_DL
    ${dlbps}=    Get Average Throughput    dt_name=DT_DL
    ${tputdl_mbps}=    Evaluate    $dlbps / 1000
    Run Keyword If    $log_throughput    Log To Console    DL tput is: ${tputdl_mbps} Mbps
    ute_ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${throughput_DL}   deviation=${deviation}
    # UL
    Log to console     Start UL traffic
    ute_ue.Start Data Transfer   dt_name=DT_UL
    ...                          ue_alias=${ue_alias}
    ...                          direction=ul
    ...                          duration=${duration}
    ...                          packet=${packet}
    ...                          throughput=${throughput_UL}
    ...                          protocol=${protocol}
    ...                          parallel_streams=${parallel_streams_UL}
    ...                          linux_congestion=cubic
    ...                          max_segment_size=1350
    ute_ue.Await Data Transfer Finish   dt_name=DT_UL
    ${ulbps}=    Get Average Throughput    dt_name=DT_UL
    ${tputul_mbps}=    Evaluate    $ulbps / 1000
    Run Keyword If    $log_throughput    Log To Console    , UL tput is: ${tputul_mbps} Mbps
    ute_ue.Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${throughput_UL}   deviation=${deviation}
    [Teardown]    Run Keywords
    ...    ute_ue.Detach UE    ${ue_alias}    AND
    ...    Run Keyword If    $cells_to_block and '${KEYWORD STATUS}' == 'FAIL'
        ...    sg7keywords.Unblock cells    ${cells_to_block}    ignore_error=${True}


Lock gNB Cells And Verify Results
    [Arguments]    @{cells}    ${timeout}=30

    FOR    ${cell}    IN    @{cells}
        Log    Locking cell: ${cell}
        sg7keywords.Lock gNB Cell    cell_id=${cell}
        Wait for cell to be locked    timeout=${timeout}    cell_id=${cell}
    END

Unlock gNB cells after fail in TC11
    sg7keywords.Unlock gNB Cell    cell_id=11
    sg7keywords.Unlock gNB Cell    cell_id=13
    sg7keywords.Unlock gNB Cell    cell_id=15
    sg7keywords.Unlock gNB Cell    cell_id=16


Cleanup After TC_B1-01
    Log To Console    Cleanup after t01
    ${delta}=  prepare_parameters_delta    distname=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-12
    ...  parameter=enDcSyncStatus  value=synchronous
    ${delta}=  prepare_parameters_delta    delta=${delta}    distname=MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}
    ...  parameter=actExtN77Support  value=false
    ${delta}=  prepare_parameters_delta    delta=${delta}    distname=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...  parameter=holdOverModeUsed  value=false
    ${delta}=  prepare_parameters_delta    delta=${delta}    distname=MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-2
    ...  parameter=inactivityTimer  value=30
    Wait Until Keyword Succeeds    2 min    50 sec    Perform Delta Commissioning On gNB    delta=${delta}    timeout=${600}

L3 Call TC_B1-05
    [Arguments]    ${arg1}=${None}    ${arg2}=${None}    #dummy args necessary for UU4ALL KWs
    Log To Console    L3 Call TC_B1-05, arg1=${arg1} arg2=${arg2}

    Return From Keyword If    ${OMIT_L3CALL}

    ${DURATION}         Set Variable    100s
    ${DEVIATION_NR}     Set Variable    40%
    ${DEVIATION_LTE}    Set Variable    20%

    Prepare UE for NSA L3 Call     band_lte=1     band_nr=5
    Wait Until Keyword Succeeds    3x    3 min    ute_ue.reboot_ue    ${UE_DEFAULT_ALIAS_NAME}    timeout=${170}
    Sleep    10

    Set attenuation level in dB for NR and LTE Cells     db_level_nr=10dB     db_level_lte=18dB
    ...      lte_cell_list=@{CELL_LTE_3_minimal}
    ...      nr_cell_list=@{CELL_NSA_14_3_ATT_PORTS}
    Attach UE and Start DL and UL traffic    throughput_DL=210 Mbits/sec
    ...                                throughput_UL=105 Mbits/sec
    ...                                duration=${DURATION}
    ...                                deviation=${DEVIATION_NR}
    ...                                protocol=tcp
    ...                                ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                                cells_to_block=[12,13]
    ...                                desired_pci=${14}
    ...                                log_throughput=${True}
    [Teardown]    Run Keyword If    not ${OMIT_L3CALL}    Run Keywords
    ...     Set attenuation level in dB for NR and LTE Cells     db_level_nr=110dB     db_level_lte=110dB
            ...      lte_cell_list=@{EMPTY}
            ...      nr_cell_list=@{CELL_ALL_PORTS}
            ...    AND
    ...    Run Keyword And Warn On Failure    ute_ue.Stop Using UE    ${UE_DEFAULT_ALIAS_NAME}

Setup Test Suite for TL019
    Custom Set Suite UUF Variables

    @{param_list}=    Set Variable    0x450027=1 #EnableDeveloperAccount
    ...                               0x980007=1 #PR804393 Fault 61675 "WiFi Configuration Issue"
    keywords.copy_and_modify_swconfig    ${param_list}
    ...                                  source_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...                                  target_path=/tmp/custom_swconfig.txt

    Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
    ...                                                  should_5G_neighbour_be_changed=${False}
    ...                                                  increase_time_for_checking_bbmod=600
    ...                                                  increase_timeout_for_update_sw=1800
    ...                                                  increase_time_for_checking_radios=2100
    ...                                                  increase_time_for_checking_cells=700
    ...                                                  swconfig_from_path=/tmp/custom_swconfig.txt
    ...                                                  list_of_additional_allowed_alarms=${ADDITIONAL_ALARMS_DURING_PREP}


Perform Commissioning on ASIR through GUI
    [Arguments]      ${scf_file_path}
    ${curr_data}       DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    ${download_dir}    Set Variable    /tmp/tmp_download_${curr_data}
    ${driver_alias}    Set variable    WEBEM_DRIVER
    ${path}    config handler     scf_file_paths=${scf_file_path}
    sc.create_firefox_web_driver   download_dir=${download_dir}   name=${driver_alias}
    sc.set_scope   alias=${driver_alias}   scope=global
    sc.login   ${WEBUI_URL}   ${WEBUI_NAME}   ${WEBUI_PWD}      browser=Firefox     alias=sc1
    sc.load_and_activate_configuration      scf_file_path=${path}/GNB0_ASIR_SCF.xml      sc=sc1
    sc.close browser      sc=sc1
    Wait Until Keyword Succeeds     400 sec     15 sec      gnbasir.Wait For Asir To Be Onair
    Wait Until Keyword Succeeds     400 sec     15 sec      gnbasir.Verify Status Of All Asir Cells Is Operational


Perform Commissioning on BTS
    [Arguments]    ${scf_file_path}     ${additional_allowed_alarms}
    @{common_alarms}       get_default_allowed_alarms
    @{allowed_alarms_during_line_preparation}    Create List
    ...     No X2 link available for a specific LTEENB
    ...     No X2 link available
    ...     Setup of X2 connectivity to gNB failed
    ...     Incompatible SW version detected
    ...     Incompatible Sw detected
    ...     Unit power reset
    ...     Antennas assignment not available
    append to list    ${common_alarms}
    ...               @{allowed_alarms_during_line_preparation}
    run keyword if     ${additional_allowed_alarms}      append to list
    ...                ${common_alarms}
    ...                @{additional_allowed_alarms}
    gnb_alarm.Start watching alarms       allowed_alarms=${common_alarms}     interface=lmp
    ${path}    config handler     scf_file_paths=${scf_file_path}
    Perform Full Commissioning on classical gnb    scf_path=${path}/GNB0_SCF.xml
    Wait for onAir on all DUs
    gnbcell.Wait For All Cells To Be OnAir    timeout=600

