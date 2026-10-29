*** Settings ***
Documentation
...    Author:        qiang.1.zhou@nokia.com
...    Maintainer:    qiang.1.zhou@nokia.com

Library    String
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.ul.alarms_watchdog.interface.alarms_watchdog                     WITH NAME    awd
Library    taf.rfrl.common_resources.python.ims2_alarms.IMS2AlarmVerifier       WITH NAME    iav
Library     ./MMIMOFault.py
Library     ./utils/modify_json.py
Library     ./utils/others.py
Library     ./tools/calibration_log_analysis.py
Library     taf.ul.oam_kpi_calculations    WITH NAME    oam_kpi
Library     ute_admin_infomodel
Library     ./kpiReporter.py

Resource    ./RRU_command.robot
Resource    ./admin_ui.robot

Variables     ./test_models_variables.py
*** Variables ***
@{mmimo_antenna_ordinal_aahf_top}    2_0    2_3    1_0    1_3    2_1    2_2    1_1    1_2
@{mmimo_antenna_ordinal_aahf_bottom}    3_2    3_1    0_2    0_1    3_3    3_0    0_3    0_0
@{mmimo_antenna_ordinal_aahf_right}    0_0    0_1    0_2    0_3    1_0    1_1    1_2    1_3
@{mmimo_antenna_ordinal_aahf_left}    3_0    3_1    3_2    3_3    2_0    2_1    2_2    2_3
@{AAHF_type}      AAHF    AAHJ
@{AAHB_type}      AAHB    AAHE
@{mmimo_fault_1937_8_telnet_cmd1}    / action create ConfigAccess /cofi /module
...    /cofi action store PERMANENT DECODED "deviceoverheated.bin" "/run/deviceoverheated.json"
...    /cofi action update    / action create ThermometerDevice /Module_CORE /bbFpga/core
...    /Module_CORE action override TEMPERATURE 50
...    / action create ThermometerDevice /DFE2_CORE /dfeFpga2/core    /DFE2_CORE action override TEMPERATURE 50.000
...    / action create ConfigAccess /ca /module    /ca action fetch DECODED "tcs.bin" "/ram/tcs.json"
@{mmimo_fault_1937_8_ssh_cmd2}    sed -ie 's/"deltaTmulti": 50.0,/"deltaTmulti": 150.0,/g' /ram/tcs.json
@{mmimo_fault_1937_8_telnet_cmd3}    /ca action store PERMANENT DECODED "tcs.bin" "/ram/tcs.json"
@{mmimo_fault_1937_8_ssh_cmd4}    reboot
@{mmimo_fault_1938_ssh_cmd5}    sed -ie 's/50/109/g' /mnt/runtime/thermometer_module\:CORE
@{mmimo_fault_1938_ssh_cmd6}    sed -ie 's/109/50/g' /mnt/runtime/thermometer_module\:CORE
@{mmimo_fault_1937_ssh_cmd5}    sed -ie 's/109/127/g' /mnt/runtime/thermometer_module\:CORE
@{mmimo_fault_1937_ssh_cmd6}    sed -ie 's/127/50/g' /mnt/runtime/thermometer_module\:CORE
@{mmimo_fault_1937_8_telnet_cmd7}     / action create ConfigAccess /cofi /module    /cofi action delete ALL
@{mmimo_fault_1938_ssh_cmd8}    sync    reboot
@{mmimo_fault_1937_8_telnet_cmd9}     / action create ThermometerDevice /Module_CORE /bbFpga/core
...    /Module_CORE action override OFF
...    / action create ThermometerDevice /DFE2_CORE /dfeFpga2/core    /DFE2_CORE action override OFF
${SSH_RSA_CMD}      -o PubkeyAcceptedAlgorithms=+ssh-rsa -o HostkeyAlgorithms=+ssh-rsa

*** Keywords ***

RAT reset and make L3call for concurrent
    [Arguments]    ${rat_type}    ${check_cell_list}    ${required_cells}=${EMPTY}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    FOR    ${bts_id}    IN    @{BTS_LIST}
        coam.rat_reset    rat_type=${rat_type}    timeout=260    connection=${CASE_NAME}_${bts_id}
        Verify All Cells OnAir        check_cell_list=${check_cell_list}
        Wait Until Keyword Succeeds    600sec    10sec    Verify All Cells OnAir
        Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    END

RAT reset and make L3call
    [Arguments]    ${rat_type}    ${required_cells}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    FOR    ${bts_id}    IN    @{BTS_LIST}
        coam.rat_reset    rat_type=${rat_type}    timeout=260    connection=${CASE_NAME}_${bts_id}
        Wait Until Keyword Succeeds    600sec    10sec    Verify All Cells OnAir
        Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    END

Remove Invalid Cell
    [Arguments]    ${fr_sn}
    FOR    ${bts_id}    IN    @{BTS_LIST}
        ${rmod_distname}    Get R Object Distname By SN    class_name=RMOD_R    sn=${fr_sn}    connection=${CASE_NAME}_${bts_id}
        ${first_point_ID}    Get FirstEndPointId by distName    class_name=CABLINK_R
        ...    distName=${rmod_distname}    connection=${CASE_NAME}_${bts_id}
        ${bbpool1_type}    SCFC get bbPoolTech    ${bts_id}
        ${removed_cell}    Get Cells State On Specific FR    ${fr_sn}
        Run Keyword If    "${bbpool1_type}"=="LTE" and "${first_point_ID}"<"7"    Remove Values From List    ${NR_CELL_LIST}    @{removed_cell}
        ...    ELSE IF    ("${bbpool1_type}"=="NR" or "${bbpool1_type}"=="5G") and "${first_point_ID}">"6"
        ...    Remove Values From List    ${NR_CELL_LIST}    @{removed_cell}
        ...    ELSE    Remove Values From List    ${LTE_CELL_LIST}    @{removed_cell}
    END
Select One Subcell
    [Arguments]    ${cell_info}    ${flag}=-1
    ${bts_id}    Set Variable    ${cell_info["btsId"]}
    ${bts_info}   Set Variable    ${NODE_CFG["${bts_id}"]}
    ${fr_chain_list}    Set Variable    ${bts_info['fr_chain_list']}
    ${cell_fr_chain_list}   resort_rf_topo_for_one_cell    cell_info=${cell_info}    bts_rf_topos=${fr_chain_list}

    ${chain_list_count}    Get Length    ${cell_fr_chain_list}
    ${random} =	Evaluate	random.randint(0, ${chain_list_count}-1)    modules=random
    ${fr_serial_number}    Get From List	${cell_fr_chain_list[${random}]}    ${flag}

    [Return]    ${fr_serial_number}

Get Distname For with RF Id
    [Arguments]    ${fr_serial_number}
    ${RF_distName}    Set Variable    ${EMPTY}
    ${out_rmoder_info}    Get RRU Sw Info    ${fr_serial_number}
    ${RF_distName}    Set Variable    ${out_rmoder_info['distName']}

    [Return]    ${RF_distName}

Check Cell Status For Supercell With To Power Off RF
    [Arguments]     ${cell_info}    ${operational_state}    ${availability_status}
    ${pci_list}    Set Variable    ${cell_info["multi_carries"]}
    FOR    ${pci}    IN    @{pci_list}
        ${related_cell_info}   Get Cell Info With PCI   ${ALL_CELL_LIST}    ${pci}
        ${connection_id}    Set Variable   ${CASE_NAME}_${related_cell_info["btsId"]}
        ${cell_R_info}    coam.Get Cell Specific Info
        ...    cell_id=${related_cell_info["distName"]}    connection=${connection_id}
        Should Be Equal As Strings  ${cell_R_info["status"]["operationalState"]}   ${operational_state}
        Should Be Equal As Strings  ${cell_R_info["status"]["availabilityStatus"]}  ${availability_status}
    END

#Check Cells State On Specific FR With To Power Off RF
#    [Arguments]    ${fr_serial_number}    ${operational_state}    ${availability_status}
#    FOR    ${cell}    IN    @{ALL_CELL_LIST}
#        ${is_cells_fr}    Check Is Cell's FR    ${fr_serial_number}    ${cell["RF"]}
#        Continue For Loop If    not ${is_cells_fr}
#        ${cells_fr_num}    Get Length    ${cell["RF"]}
#        Continue For Loop If    "${operational_state}" == "disabled" and ${cells_fr_num} > ${1}
#        ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${cell["distName"]}
#        ...    connection=${CASE_NAME}_${cell["btsId"]}
#        Should Be Equal As Strings  ${cell_R_info["status"]["operationalState"]}   ${operational_state}
#        Should Be Equal As Strings  ${cell_R_info["status"]["availabilityStatus"]}  ${availability_status}
#    END

TX Failure Creation For One Subcell
    [Arguments]    ${cell_info}
    ${fr_serial_number}    Select One Subcell    cell_info=${cell_info}

#    ${rf_dist_name}    Get Distname For with RF Id   ${fr_serial_number}


    PDU Turn Off Unit    pdu_type=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['port']}

    ${connection_id}    Set Variable   ${CASE_NAME}_${cell_info["btsId"]}

    Wait Until Keyword Succeeds    120sec  20sec   coam.assert_alarm_active
    ...    parameters=faultId=10
    ...     connection=${connection_id}
    ...    timeout=10
    Check Cell Status For Supercell With To Power Off RF
    ...    cell_info=${cell_info}    operational_state=enabled    availability_status=degraded

    FOR    ${RF_info}    IN    @{cell_info["subCell"]}
        ${RF_serial_num}    Set Variable    ${RF_info[0]["serialNumber"]}
        continue_for_loop_if    '${RF_serial_num}'=='${fr_serial_number}'
        Run Keyword And Continue On Failure    Make L3call For One Subcell    cell_info=${cell_info}    RF_info=${RF_info}
    END

    PDU Turn On Unit    pdu_type=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['port']}

    Wait For All Cells OnAir    timeout=${ONAIR_TIME}

    ${alarms}   coam.assert_alarm_inactive
    ...    parameters=faultId=10
    ...     connection=${connection_id}
    ...    timeout=30

TX Failure Creation For All Subcell Except one
    [Arguments]    ${cell_info}
    ${fr_serial_number}    Select One Subcell    cell_info=${cell_info}   flag=0

    FOR    ${RF_info}    IN    @{cell_info["subCell"]}
        ${RF_serial_num}    Set Variable    ${RF_info[0]["serialNumber"]}
        continue_for_loop_if    '${RF_serial_num}'=='${fr_serial_number}'
        PDU Turn Off Unit    pdu_type=${BTS_CONFIG['FR']['${RF_serial_num}']['pdu']['type']}
        ...    pdu_ip=${BTS_CONFIG['FR']['${RF_serial_num}']['pdu']['ip_addr']}
        ...    pdu_port=${BTS_CONFIG['FR']['${RF_serial_num}']['pdu']['port']}
    END

    ${connection_id}    Set Variable   ${CASE_NAME}_${cell_info["btsId"]}

    FOR    ${RF_info}    IN    @{cell_info["subCell"]}
        ${RF_serial_num}    Set Variable    ${RF_info[0]["serialNumber"]}
        continue_for_loop_if    '${RF_serial_num}'=='${fr_serial_number}'
#        ${rf_dist_name}    Get Distname For with RF Id   ${RF_serial_num}
        Wait Until Keyword Succeeds    120sec  20sec   coam.assert_alarm_active
        ...    parameters=faultId=10
        ...     connection=${connection_id}
        ...    timeout=10
    END

    Check Cell Status For Supercell With To Power Off RF
    ...    cell_info=${cell_info}    operational_state=enabled    availability_status=degraded

    FOR    ${RF_info}    IN    @{cell_info["subCell"]}
        ${RF_serial_num}    Set Variable    ${RF_info[0]["serialNumber"]}
        continue_for_loop_if    '${RF_serial_num}'!='${fr_serial_number}'
        Run Keyword And Continue On Failure    Make L3call For One Subcell    cell_info=${cell_info}    RF_info=${RF_info}
    END

    FOR    ${RF_info}    IN    @{cell_info["subCell"]}
        ${RF_serial_num}    Set Variable    ${RF_info[0]["serialNumber"]}
        continue_for_loop_if    '${RF_serial_num}'=='${fr_serial_number}'
        PDU Turn On Unit    pdu_type=${BTS_CONFIG['FR']['${RF_serial_num}']['pdu']['type']}
        ...    pdu_ip=${BTS_CONFIG['FR']['${RF_serial_num}']['pdu']['ip_addr']}
        ...    pdu_port=${BTS_CONFIG['FR']['${RF_serial_num}']['pdu']['port']}
    END

    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    ${alarms}   coam.assert_alarm_inactive
    ...    parameters=faultId=10
    ...     connection=${connection_id}
    ...    timeout=30

TX Failure Creation For All Subcell And Resetup
    [Arguments]    ${cell_info}
    ${connection_id}    Set Variable   ${CASE_NAME}_${cell_info["btsId"]}
    FOR    ${RF_info}    IN    @{cell_info["subCell"]}
        ${RF_serial_num}    Set Variable    ${RF_info[0]["serialNumber"]}
        PDU Turn Off Unit    pdu_type=${BTS_CONFIG['FR']['${RF_serial_num}']['pdu']['type']}
        ...    pdu_ip=${BTS_CONFIG['FR']['${RF_serial_num}']['pdu']['ip_addr']}
        ...    pdu_port=${BTS_CONFIG['FR']['${RF_serial_num}']['pdu']['port']}
    END

    FOR    ${RF_info}    IN    @{cell_info["subCell"]}
        ${RF_serial_num}    Set Variable    ${RF_info[0]["serialNumber"]}
#        ${rf_dist_name}    Get Distname For with RF Id   ${RF_serial_num}
        Wait Until Keyword Succeeds    120sec  20sec      coam.assert_alarm_active
        ...    parameters=faultId=10
        ...     connection=${connection_id}
        ...    timeout=10
    END

    Check Cell Status For Supercell With To Power Off RF
    ...    cell_info=${cell_info}    operational_state=disabled    availability_status=failed

    FOR    ${RF_info}    IN    @{cell_info["subCell"]}
        ${RF_serial_num}    Set Variable    ${RF_info[0]["serialNumber"]}
        PDU Turn On Unit    pdu_type=${BTS_CONFIG['FR']['${RF_serial_num}']['pdu']['type']}
        ...    pdu_ip=${BTS_CONFIG['FR']['${RF_serial_num}']['pdu']['ip_addr']}
        ...    pdu_port=${BTS_CONFIG['FR']['${RF_serial_num}']['pdu']['port']}
    END

    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    ${alarms}   coam.assert_alarm_inactive
    ...    parameters=faultId=10
    ...     connection=${connection_id}
    ...    timeout=30
#    Run Keyword And Continue On Failure    Make L3Call

SCFC get bbPoolTech
    [Arguments]    ${bts_id}
    ${current_scfc}    Get Current Scfc    ${bts_id}
    ${out_dist_name}=    Evaluate Xpath    ${current_scfc}
    ...  string(.//managedObject[contains(@class, ":BBPOOL") and contains(@distName, "BBPOOL-1")]/p[@name='bbPoolTech'])
    [Return]    ${out_dist_name}

Get FirstEndPointId by distName
    [Arguments]    ${class_name}    ${distName}    ${connection}    ${timeout}=10
    ${require_objects}    coam.Get Managed Objects    class_name=${class_name}
    ...                   timeout= ${timeout}    connection=${connection}
    FOR    ${object_info}    IN    @{require_objects}
        ${secondEndpointDN}    Set Variable    ${object_info['parameters']['secondEndpointDN']}
        ${linkModeSynchronization}    Set Variable    ${object_info['parameters']['linkModeSynchronization']}
        return from keyword if    '${secondEndpointDN}'=='${distName}' and '${linkModeSynchronization}'=='True'
        ...    ${object_info['parameters']['firstEndpointPortId']}
    END
    Fail

Get NR and LTE Cell List
    ${NR_Cell_List}    Create List
    ${LTE_Cell_List}    Create List
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        Run Keyword If    "${cell_info["NetworkType"]}"=="SA"    Append To List    ${NR_Cell_List}    ${cell_info}
        ...    ELSE IF    "${cell_info["NetworkType"]}" == "4G"    Append To List    ${LTE_Cell_List}    ${cell_info}
    END
    set test variable    ${NR_CELL_LIST}    ${NR_Cell_List}
    set test variable    ${LTE_CELL_LIST}    ${LTE_Cell_List}

Get Due Mode RRU List
    [Arguments]    ${NR_Cell_List}    ${LTE_Cell_List}
    ${Due_mode_rru_list}    Create List
    FOR    ${NR_cell_info}    IN    @{NR_Cell_List}
        Check Due Mode rru    ${NR_cell_info}    ${LTE_Cell_List}    ${Due_mode_rru_list}
    END
    ${Due_mode_rru_list}    Remove Duplicates    ${Due_mode_rru_list}
    [Return]     ${Due_mode_rru_list}

Check Due Mode rru
    [Arguments]    ${NR_cell_info}    ${LTE_Cell_List}    ${Due_mode_rru_list}
    FOR    ${LTE_cell_info}    IN    @{LTE_Cell_List}
        Compare RF Serial Number   ${NR_cell_info["RF"]}    ${LTE_cell_info["RF"]}    ${Due_mode_rru_list}
    END

Compare RF Serial Number
    [Arguments]    ${NR_RF_List}    ${4G_RF_List}    ${Due_mode_rru_list}
    FOR    ${rf}    IN    @{NR_RF_List}
        ${status}    Check Is Cell's FR    ${rf["serialNumber"]}    ${4G_RF_List}
        Run keyword If    "${status}" == "True"    Append To List    ${Due_mode_rru_list}    ${rf["serialNumber"]}
    END

Set Constant Variables
    [Arguments]    ${cell_info}
    ${bts_id}    Set Variable     ${cell_info["btsId"]}
    ${current_SW_release}    Set Variable    ${NODE_CFG["${bts_id}"]["software_release"]}
    Run Keyword If    "${current_SW_release}"=="SBTS22R2" or "${current_SW_release}"=="SBTS22R1"
    ...     Set Constant Variables For Legacy
    ...    ELSE       Set Constant Variables For New


Set Constant Variables For New
    Set Test Variable    ${cell_operational_state_enabled}    enabled
    Set Test Variable    ${cell_operational_state_disabled}     disabled
    Set Test Variable    ${cell_blocking_state_blocked}      Blocked
    Set Test Variable    ${cell_blocking_state_unblocked}     Unblocked
    Set Test Variable    ${cell_availabilityStatus_offline}    off line
    Set Test Variable    ${cell_availabilityStatus_online}     online

Set Constant Variables For Legacy
    Set Test Variable    ${cell_operational_state_enabled}    Enabled
    Set Test Variable    ${cell_operational_state_disabled}    Disabled
    Set Test Variable    ${cell_blocking_state_blocked}      Blocked
    Set Test Variable    ${cell_blocking_state_unblocked}     Unblocked
    Set Test Variable    ${cell_availabilityStatus_offline}     Offline
    Set Test Variable    ${cell_availabilityStatus_online}       Online


Online Change NR Cell For 4G
    [Arguments]    ${4G_connection_alias}    ${lncell_dist_name}    ${nrcell_index}
    coam.perform_parameter_recommissioning    ${lncell_dist_name}    defaultLnRelGnbCellId    update   ${nrcell_index}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=300
    ...    connection=${4G_connection_alias}
    #coam.Assert Any    LNCEL    proceduralState=regex"OnAirDone"]    timeout=20    alias=${4G_connection_alias}
    Verify All Cells OnAir
    Create Node Parameters From Current SCF

Online Change cellBarred
     [Arguments]    ${cell_info}    ${value}=barred
     ${p_node_dist_name}    Run Keyword If    '${cell_info['NetworkType']}'=='4G'
     ...    Set Variable    ${cell_info["distName"]}/SIB-0
     ...    ELSE IF     '${cell_info['NetworkType']}'=='SA'    Set Variable    ${cell_info["distName"]}
     ...    ELSE IF     '${cell_info['NetworkType']}'=='NSA'    Set Variable    ${cell_info["distName"]}
     coam.Append parameter update to delta    ${p_node_dist_name}    cellBarred   ${value}
     ...    delta_id=delta_${CASE_NAME}_${cell_info["btsId"]}
#     coam.perform_parameter_recommissioning    ${p_node_dist_name}    cellBarred    update   ${value}
#    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=300    alias=${connect_id}

Online Change cellBarred For Muti Carrier
    [Arguments]    ${cell_info}    ${value}=barred
    ${status}    Run Keyword And Return Status    Dictionary Should Not Contain Key    ${cell_info}    multi_carries
    Return From Keyword If    ${status}
    ${m_cell_list}    Set Variable    ${cell_info["multi_carries"]}

    ${len}    Get Length    ${m_cell_list}
    Return From Keyword If    '${len}'=='1' or '${len}'=='0'

    coam.Create delta
    FOR    ${m_cell_id}   IN    @{m_cell_list}
        Continue For Loop if    '${m_cell_id}'=='${cell_info["phyCellId"]}'
        ${m_cell_info}    Get Cell Info With PCI    ${ALL_CELL_LIST}    ${m_cell_id}
        Online Change cellBarred    ${m_cell_info}    ${value}
    END
    ${connect_id}   Set Variable    ${CASE_NAME}_${cell_info["btsId"]}
    ${delta_update}=    coam.Get delta
    coam.Perform delta recommissioning    ${delta_update}     timeout=300
    ...    should_activate=${TRUE}     connection=${connect_id}

    Run Keyword If    "${cell_info['cellType']}"!="Supercell"    Verify All Cells OnAir

Online Change cellBarred For Multi Cell
    [Arguments]    ${cell_info}    ${value}=barred
    ${is_all}    Run Keyword And Return Status    Variable Should Exist    ${MATCHED_UE_INFO["ALL_CELL_BARRED"]}
    ${bar_cell_part}    Run Keyword If    "${is_all}"=="False"    Get Bar Cell For Same RRU And PA    ${cell_info}
    ${bar_cell_all}    Copy List    ${ALL_CELL_LIST}
    Remove Values From List    ${bar_cell_all}    ${cell_info}

    ${bar_cell_list}    Set Variable If    "${is_all}"=="True"    ${bar_cell_all}    ${bar_cell_part}

    ${status}    Run Keyword And Return Status    Variable Should Exist    ${cell_info["related_cell"]}
    ${bar_cell_list}   Run Keyword If   ${status}    Remove Cells From Cell List       ${bar_cell_list}   ${cell_info}
    ...   ELSE   Set Variable    ${bar_cell_list}

    ${status}    Run Keyword And Return Status    Should Not Be Empty    ${bar_cell_list}


    Return From Keyword If    '${status}'=='False'
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        coam.Create delta    delta_id=delta_${CASE_NAME}_${bts_id}
    END
    FOR    ${bar_cell_info}   IN    @{bar_cell_list}
        Online Change cellBarred    ${bar_cell_info}    ${value}
    END
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        ${connect_id}   Set Variable    ${CASE_NAME}_${bts_id}
        ${delta_update}=    coam.Get delta    delta_id=delta_${CASE_NAME}_${bts_id}
        coam.Perform delta recommissioning    ${delta_update}     timeout=300
        ...    should_activate=${TRUE}     alias=${connect_id}
    END
    Sleep    30s
    Run Keyword If     "${cell_info['cellType']}"!="Supercell"    Wait For All Cells OnAir

Get NSA Mapping Info
   [Arguments]    ${cell_list}   ${nrcell_id}
   ${nrcell_config_index}    Set Variable    ${EMPTY}
   ${mapping_lncell}    Set Variable    ${EMPTY}
   FOR   ${cell_info}   IN    @{cell_list}
        ${status}    Run Keyword And Return Status    Dictionary Should Not Contain Key    ${cell_info}    nrCellList
        Continue For Loop If    ${status}
        ${nrcell_config_index}=     Check nrCell Config And Return Index    ${cell_info["nrCellList"]}     ${nrcell_id}
        Continue For Loop If    '${nrcell_config_index}'=='None'
        ${mapping_lncell}    Set Variable    ${cell_info}
        Exit For Loop
    END
   [Return]    ${mapping_lncell}     ${nrcell_config_index}

Check nrCell Config And Return Index
    [Arguments]    ${nr_cell_list}   ${nrcell_id}
    ${nrcell_index}    Set Variable    ${EMPTY}
    FOR   ${nrcell_config}   IN    @{nr_cell_list}
         ${nrcell_index}    Set Variable If    '${nrcell_config[1]}'=='${nrcell_id}'    ${nrcell_config[0]}
         Exit For Loop If    '${nrcell_config[1]}'=='${nrcell_id}'
    END
    [Return]    ${nrcell_index}

Check And Set Anchor Cell For NR Cell
    [Arguments]    ${cell_list}    ${5g_pci}
#    ${is_need_reconfig}    Run Keyword And Return Status     dictionary_should_not_contain_key
#    ...    ${anchor_cell_mapping}    ${5g_pci}
#
#    Return From Keyword If   ${is_need_reconfig}   1
    ${5g_cell_info}    Get Cell Info With PCI   cell_list=${cell_list}   pci=${5g_pci}
    ${nrcell_id}    Set Variable    ${5g_cell_info["nrCellId"]}
    ${4g_cell_info}    ${nrcell_config_index}    Get NSA Mapping Info    ${cell_list}     ${nrcell_id}
    Run Keyword If      '${nrcell_config_index}'=='${EMPTY}'    Fail

    Return From Keyword If    '${4g_cell_info["nrCellList"][0][1]}'=='${nrcell_id}'
#    Return From Keyword If    '${4g_cell_info["nrCellId"]}'=='${nrcell_id}'
    Online Change NR Cell For 4G   4G_connection_alias=${CASE_NAME}_${4g_cell_info["btsId"]}
    ...    lncell_dist_name=${4g_cell_info["distName"]}
    ...    nrcell_index=${nrcell_config_index}

Verify All Cells OnAir
    [Arguments]    ${pre_alias}=${CASE_NAME}    ${check_cell_list}=${ALL_CELL_LIST}
    FOR    ${cell_list}    IN    @{check_cell_list}
        ${bts_id}    Set Variable     ${cell_list["btsId"]}
        ${current_sw_release}    Set Variable    ${NODE_CFG["${bts_id}"]["software_release"]}
        ${cell_info}    coam.Get Cell Specific Info    cell_id=${cell_list["distName"]}    connection=${pre_alias}_${cell_list["btsId"]}
        ${operational_state}    Convert To Lowercase    ${cell_info["status"]["operationalState"]}
        ${blocking_state}    Convert To Lowercase    ${cell_info["status"]["blockingState"]}
        Should Be Equal As Strings    ${operational_state}    enabled
        Should Be Equal As Strings    ${blocking_state}    unblocked
        Run Keyword If    "${current_sw_release}"=="SBTS22R2" or "${current_sw_release}"=="SBTS22R1" or "${current_sw_release}"=="SBTS21B"
        ...    Should Be Equal As Strings    ${cell_info["status"]["availabilityStatus"]}    Online
        ...    ELSE    Variable Should Not Exist    ${cell_info["status"]["availabilityStatus"]}
    END
    FOR    ${distname}    IN    @{2G_3G_DISTNAME_LIST}
        ${bts_id}    Should Match Regexp    ${distname}    (?:MRBTS-)?(\\d+)
        ${cell_info}    coam.Get Cell Specific Info    cell_id=${distname}    connection=${pre_alias}_${bts_id[1]}
        ${operational_state}    Convert To Lowercase    ${cell_info["status"]["operationalState"]}
        ${blocking_state}    Convert To Lowercase    ${cell_info["status"]["blockingState"]}
        Should Be Equal As Strings    ${operational_state}    enabled
        Should Be Equal As Strings    ${blocking_state}    unblocked
        Run Keyword If    "${current_sw_release}"=="SBTS22R2" or "${current_sw_release}"=="SBTS22R1" or "${current_sw_release}"=="SBTS21B"
        ...    Should Be Equal As Strings    ${cell_info["status"]["availabilityStatus"]}    Online
        ...    ELSE    Variable Should Not Exist    ${cell_info["status"]["availabilityStatus"]}
    END

Wait For All Cells OnAir
    [Arguments]    ${timeout}=600s
    Wait Until Keyword Succeeds    ${timeout}    30 sec    Verify All Cells OnAir

Check All Cells OnAir
    [Arguments]    ${timeout}=${ONAIR_TIME}
    ${status}    Run Keyword And Return Status    Wait For All Cells OnAir    timeout=${timeout}
    Run keyword If    "${status}" == "False"    Reset BTS Until Onair    timeout=${timeout}

Get Master BTS Id With RF serial Number
    [Arguments]    ${serial_num}
    ${rfs_bts_id}    Get Bts Id With FR Serial Number    ${serial_num}
    ${reset_bts_id}    Get RF Reset Btsid    ${rfs_bts_id}
    [Return]    ${reset_bts_id}

Get RRU IP
    [Arguments]    ${serial_num}
    ${object_info}    Get RRU Info    serial_num=${serial_num}

    ${ip}    Set Variable    ${object_info["parameters"]["ipAddress"]}
    [Return]   ${ip}

Get RRU Info
    [Arguments]    ${serial_num}
    ${bts_id}    Get Master BTS Id With RF serial Number    ${serial_num}
    ${object_info}    Get RRU Object Info With Serialnum    class_name=RMOD_L    serial_num=${serial_num}
    ...     connection=${CASE_NAME}_${bts_id}

    [Return]   ${object_info}

Get R_RRU Info
    [Arguments]    ${serial_num}
    ${bts_id}    Get Master BTS Id With RF serial Number    ${serial_num}
    ${object_info}    Get R_RRU Object Info With Serialnum    class_name=RMOD_R    serial_num=${serial_num}
    ...     connection=${CASE_NAME}_${bts_id}

    [Return]   ${object_info}

Block Cell
    [Arguments]    ${cell_info}    ${timeout}=90s
    ${connection_id}    Set Variable   ${CASE_NAME}_${cell_info["btsId"]}
    ${R_class_name}   Get R CELL Class Name   ${cell_info}
    ${cell_distname}    Get R Object Distname    class_name=${R_class_name}
    ...     id=${cell_info["cellId"]}    connection=${connection_id}
    coam.Block Cell    dist_name=${cell_distname}    timeout=${timeout}
    ...    connection=${connection_id}

    Cell Should Be Blocked With Admin    cell_info=${cell_info}
    ...     connection_id=${connection_id}

    ${resouce_dist_name}     Set Variable If       '${R_class_name}'=='NRCELL_R' and '${sw_release}'!='SBTS24R3' and '${sw_release}'!='SBTS25R1'
    ...     ${cell_info["distName"]}       ${cell_distname}
    ${alarms}   coam.assert_alarm_active
    ...    parameters=faultId=49,severity=Critical,alarmingResource=${resouce_dist_name}
    ...     connection=${connection_id}
Get R CELL Class Name
    [Arguments]    ${cell_info}
    ${R_class_name}   Run Keyword If    '${cell_info['NetworkType']}'=='SA'
    ...     Set Variable    NRCELL_R
    ...     ELSE IF     '${cell_info['NetworkType']}'=='NSA'    Set Variable    NRCELL_R
    ...     ELSE IF     '${cell_info['NetworkType']}'=='4G'    Set Variable    LNCEL_R
    ...     ELSE    Set Variable    LNCEL_R
    [Return]    ${R_class_name}
Unblock Cell
    [Arguments]    ${cell_info}    ${timeout}=20s
    ${connection_id}    Set Variable   ${CASE_NAME}_${cell_info["btsId"]}
    ${R_class_name}   Get R CELL Class Name   ${cell_info}
    ${cell_distname}    Get R Object Distname    class_name=${R_class_name}
    ...     id=${cell_info["cellId"]}    connection=${connection_id}     connection=${connection_id}
    coam.Unblock Cell    dist_name=${cell_distname}    timeout=${timeout}
    ...    connection=${connection_id}

#    Sleep    10s
    Wait Until Keyword Succeeds    600sec    10sec    Cell Should Be Unblocked With Admin    cell_info=${cell_info}
    ...     connection_id=${connection_id}

    ${resouce_dist_name}     Set Variable If       '${R_class_name}'=='NRCELL_R' and '${sw_release}'!='SBTS24R3' and '${sw_release}'!='SBTS25R1'
    ...     ${cell_info["distName"]}       ${cell_distname}

    coam.assert_alarm_inactive
    ...    parameters=faultId=49,severity=Critical,alarmingResource=${resouce_dist_name}
    ...    connection=${connection_id}

Block One Cell And Make Tput
    [Arguments]    ${cell_list}     ${extra_peak_rate_config}
    FOR  ${cell_info}  IN  @{cell_list}
        Block Cell   ${cell_info}
        ${required_cells}  Copy List   ${cell_list}
        Remove Values From List  ${required_cells}   ${cell_info}
        Make Tput    extra_peak_rate_config=${extra_peak_rate_config}    cell_list=${required_cells}
        Unblock Cell   ${cell_info}
     END

Cell Should Be Blocked With Admin
    [Documentation]   Auther: qiang.1.zhou@nokia-sbell.com
    [Arguments]  ${cell_info}   ${connection_id}
#    ${subcell_status}=  Get Cell Status      cell_idx=${cell_idx}
#    ...                                      cell_group_idx=${cell_group_idx}
#    ...                                      timeout=${timeout}
#    ...                                      connection=${connection}
    Set Constant Variables    ${cell_info}
    ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${cell_info["distName"]}    connection=${connection_id}
    #${operational_state}    convert_to_lower    ${cell_R_info["status"]["operationalState"]}
    Should Be Equal As Strings  ${cell_R_info["status"]["operationalState"]}   ${cell_operational_state_disabled}
    Should Be Equal As Strings  ${cell_R_info["status"]["availabilityStatus"]}  ${cell_availabilityStatus_offline}
    Should Be Equal As Strings  ${cell_R_info["status"]["blockingState"]}  ${cell_blocking_state_blocked}

Cell Should Be Unblocked With Admin
    [Documentation]   Auther: qiang.1.zhou@nokia-sbell.com
    [Arguments]  ${cell_info}   ${connection_id}
    Set Constant Variables    ${cell_info}
    ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${cell_info["distName"]}    connection=${connection_id}
    Should Be Equal As Strings  ${cell_R_info["status"]["operationalState"]}   ${cell_operational_state_enabled}
    #Should Be Equal As Strings  ${cell_R_info["status"]["availabilityStatus"]}  ${cell_availabilityStatus_online}
    Should Be Equal As Strings  ${cell_R_info["status"]["blockingState"]}  ${cell_blocking_state_unblocked}

Reset BTS Until Onair
    [Arguments]    ${timeout}=${ONAIR_TIME}
    FOR    ${bts_id}    IN    @{BTS_LIST}
        ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
        ${if_need_blocking}    Set Variable If    '${SITE_MODE}'=='RF_Sharing'    ${False}    ${True}
        coam.reset_site    timeout=600    connection=${connection_id}    wait_for_reconnection=${if_need_blocking}
    END
    Run Keyword If    '${SITE_MODE}'=='RF_Sharing'     Sleep    3min
    Wait For All Cells OnAir    timeout=${timeout}
    Verify HW state

Get BBMOD Info With SN
    [Arguments]    ${bbmods_infos}    ${sn}
    ${bbmod_info}    Set Variable    ${Empty}
    FOR   ${bbmods_info}   IN    @{bbmods_infos}
        ${bbmod_info}     Set Variable If    '${bbmods_info["parameters"]["serialNumber"]}'=='${sn}'    ${bbmods_info}
        Exit For Loop If      '${bbmods_info["parameters"]["serialNumber"]}'=='${sn}'
    END
    [Return]     ${bbmod_info}

Get Require BBMOD To Reset
    [Arguments]    ${bbmods_infos}    ${bbmod_sns}
    Return From Keyword If    '${bbmod_sns}'=='${EMPTY}'    ${bbmods_infos}
    ${require_bbmods}     Split String    ${bbmod_sns}    :
    ${require_bbmods_info}   Create List

    FOR   ${sn}   IN    @{require_bbmods}
       ${bbmod_info}    Get BBMOD Info With SN    ${bbmods_infos}    ${sn}
       ${input_type}=  Evaluate  type($bbmod_info).__name__
       Run Keyword If    '${input_type}'=='dict'    Append To List     ${require_bbmods_info}    ${bbmod_info}
    END

    Return From Keyword    ${require_bbmods_info}


Reset BBMOD Until Onair
    [Documentation]    Author: nick.1.wu@nokia-sbell.com
    [Arguments]    ${timeout}    ${require_bbmod}    ${btsid}    ${test_loops}
    ${status}    Run Keyword And Return Status    Variable Should Exist    ${TOP50}
    ${require_bbmods_info}    coam.Get Managed Objects    class_name=BBMOD_R    connection=${CASE_NAME}_${btsid}
    ${require_bbmods_info}    Get Require BBMOD To Reset    ${require_bbmods_info}    ${require_bbmod}

    ${test_loops}    Set Variable If    '${test_loops}' == '${EMPTY}'    ${1}    ${test_loops}

    ${require_bbmods_info_kpi}    Evaluate    (${require_bbmods_info}*${test_loops})[:${test_loops}]
    ${require_bbmods_list}    Set Variable If    ${status}    ${require_bbmods_info_kpi}    ${require_bbmods_info}
    FOR    ${bbmod_info}    IN    @{require_bbmods_list}
        ${bbmod_distname}    Set Variable    ${bbmod_info['distName']}
        coam.reset_unit    dist_name=${bbmod_distname}    reset_type=Warm
        ...    force_radio_reset=${True}    timeout=${timeout}    connection=${CASE_NAME}_${btsid}
        Run Keyword If    ${status}    sleep    4min
        Run Keyword If    ${status}    Calculate BBMOD Reset KPI    ${btsid}
        ...    ${bbmod_info['parameters']['serialNumber']}
    END
    Wait For All Cells OnAir    timeout=${timeout}
    Verify HW state

Reset BB Module
    [Arguments]    ${require_bbmod}    ${btsid}   ${timeout}=300s
    ${require_bbmods_info}    coam.Get Managed Objects    class_name=BBMOD_R    connection=${CASE_NAME}_${btsid}
    ${require_bbmods_list}    Get Require BBMOD To Reset    ${require_bbmods_info}    ${require_bbmod}
    FOR    ${bbmod_info}    IN    @{require_bbmods_list}
        ${bbmod_distname}    Set Variable    ${bbmod_info['distName']}
        coam.reset_unit    dist_name=${bbmod_distname}    reset_type=Warm
        ...    force_radio_reset=${True}    timeout=${timeout}    connection=${CASE_NAME}_${btsid}
    END

Check Alarms
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
        Run Keyword And Continue On Failure    Admin Alarms Get And Check    allowed=${GLO_ADMIN_ALLOWED_ALARM}
        ...    alias=${connection_id}
    END

Check Historical Alarms
    [Arguments]    ${additional_allowed_alarms}=${EMPTY}
    ${additional_allowed_alarm_list}    split_string    ${additional_allowed_alarms}    :
    ${allowed_alarm_list}     combine_lists    ${GLO_ADMIN_ALLOWED_ALARM}    ${additional_allowed_alarm_list}
    ...     ${GLO_ADMIN_HISTORY_ALLOWED_ALARM}
    Remove Values From List    ${allowed_alarm_list}    ${empty}
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
        Run Keyword And Continue On Failure    Admin Historical Alarms Get And Check    allowed=${allowed_alarm_list}
        ...    alias=${connection_id}
    END

Power Off Radio
    [Arguments]    ${fr_serial_number}
    PDU Turn Off Unit    pdu_type=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['port']}
    ${rfs_bts_id}    Get Bts Id With FR Serial Number    ${fr_serial_number}
    FOR    ${bts_id}    IN    @{rfs_bts_id}
        ${fault1815_status}    Check If Fault 1815 Raise    ${bts_id}    ${fr_serial_number}
        Run Keyword If    ${fault1815_status}
        ...    Run Keywords    Set Test Variable    ${HAS_CPRIN}    ${True}
        ...    AND    coam.assert_alarm_active    parameters=faultId=1815    timeout=10    connection=${CASE_NAME}_${bts_id}
        ...    ELSE    coam.assert_alarm_inactive    parameters=faultId=1815    timeout=10    connection=${CASE_NAME}_${bts_id}
    END
    FOR    ${bts_id}    IN    @{rfs_bts_id}
        ${not_testing_related_frs}    ${fr_next_hops_list}    Get Not Testing Realted And Next Hops FR List
        ...    ${fr_serial_number}    ${bts_id}
        Radio Should Be Off    ${fr_serial_number}    ${bts_id}
        coam.assert_alarm_active    parameters=faultId=10    timeout=120    connection=${CASE_NAME}_${bts_id}
        Check Not Testing Related FRs States When Testing FR Is Resetting    ${not_testing_related_frs}    ${bts_id}
    END

Power Off Radio without Check 1815
    [Arguments]    ${fr_serial_number}
    PDU Turn Off Unit    pdu_type=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['port']}
    ${rfs_bts_id}    Get Bts Id With FR Serial Number    ${fr_serial_number}
    FOR    ${bts_id}    IN    @{rfs_bts_id}
        ${not_testing_related_frs}    ${fr_next_hops_list}    Get Not Testing Realted And Next Hops FR List
        ...    ${fr_serial_number}    ${bts_id}
        Radio Should Be Off    ${fr_serial_number}    ${bts_id}
        coam.assert_alarm_active    parameters=faultId=10    timeout=120    connection=${CASE_NAME}_${bts_id}
        Check Not Testing Related FRs States When Testing FR Is Resetting    ${not_testing_related_frs}    ${bts_id}
    END

Get First RRU In The Chain
    [Arguments]    ${bts_id}
    ${first_rru_list}    Create List
    ${fr_chain_list}    Set Variable    ${NODE_CFG["${bts_id}"]["fr_chain_list"]}
    FOR    ${fr_chain}    IN    @{fr_chain_list}
        ${fr_list}    Split String    ${fr_chain}    ->
        Append To List    ${first_rru_list}    ${fr_list[0]}
    END
    [Return]    ${first_rru_list}

Check If Fault 1815 Raise
    [Arguments]    ${bts_id}    ${fr_sn}
    ${l3Protocol}    Scfc Get RU l3Protocol    ${NODE_CFG["${bts_id}"]["scf_file_path"]}    ${fr_sn}
    Return From Keyword If    "${l3Protocol}"!="CPRI_RP1"    ${False}
    ${release}    Set Variable    ${NODE_CFG["${bts_id}"]["software_release"]}
    Return From Keyword If   "${release}"=="SBTS23R1" or "${release}"=="SBTS22R4" or "${release}"=="SBTS22R3"  ${False}
    ${fr_chain_list}    Set Variable    ${NODE_CFG["${bts_id}"]["fr_chain_list"]}
    ${first_rru_list}    Get First RRU In The Chain    ${bts_id}
    Return From Keyword If    "${fr_sn}" in "${fr_chain_list}" and "${fr_sn}" not in "${first_rru_list}"    ${False}
    Return From Keyword    ${True}

Check Alarm Is Appear
    [Arguments]    ${bts_id}    ${fault_parameter}
    ${type}    Evaluate    type(${bts_id}).__name__
    ${bts_id_list}    Run Keyword If    "${type}"!="list"    Create List    ${bts_id}
    ...    ELSE    Set Variable    ${bts_id}
    FOR    ${bts_id}    IN    @{bts_id_list}
        coam.assert_alarm_active    parameters=${fault_parameter}    timeout=10    connection=${CASE_NAME}_${bts_id}
    END

Check Alarm Is Disappear
    [Arguments]    ${bts_id}    ${fault_parameter}
    ${type}    Evaluate    type(${bts_id}).__name__
    ${bts_id_list}    Run Keyword If    "${type}"!="list"    Create List    ${bts_id}
    ...    ELSE    Set Variable    ${bts_id}
    FOR    ${bts_id}    IN    @{bts_id_list}
        coam.assert_alarm_inactive    parameters=${fault_parameter}    timeout=10    connection=${CASE_NAME}_${bts_id}
    END

Scfc Get RU l3Protocol
    [Arguments]    ${scfc_file_path}    ${fr_sn}
    ${l3Protocol}    Get Element Text   ${scfc_file_path}
    ...    xpath=//managedObject[@class='com.nokia.srbts.eqmr:RMOD_R'][p[@name="serialNumber"]="${fr_sn}"]/p[@name="l3Protocol"]
    [Return]    ${l3Protocol}

Radio Reset
    [Arguments]    ${fr_serial_number}
    ${rfs_bts_id}    Get Bts Id With FR Serial Number    ${fr_serial_number}
    ${reset_bts_id}    Get RF Reset Btsid    ${rfs_bts_id}
    ${not_testing_related_frs}    ${fr_next_hops_list}    Get Not Testing Realted And Next Hops FR List    ${fr_serial_number}    ${reset_bts_id}
    Run Keyword And Ignore Error    Radio Reset With Admin     ${fr_serial_number}    ${reset_bts_id}    timeout=20
    Radio Should Be Disbled    ${fr_serial_number}    ${reset_bts_id}    ${fr_next_hops_list}
    Check Not Testing Related FRs States When Testing FR Is Resetting    ${not_testing_related_frs}    ${reset_bts_id}
    FOR    ${bts_id}    IN    @{rfs_bts_id}
        Radio Should Be On    ${fr_serial_number}    ${bts_id}    ${fr_next_hops_list}
    END
    Wait For All Cells OnAir    timeout=10 min

Radio Reset without onair
    [Arguments]    ${fr_serial_number}
    ${rfs_bts_id}    Get Bts Id With FR Serial Number    ${fr_serial_number}
    ${reset_bts_id}    Get RF Reset Btsid    ${rfs_bts_id}
    ${not_testing_related_frs}    ${fr_next_hops_list}    Get Not Testing Realted And Next Hops FR List    ${fr_serial_number}    ${reset_bts_id}
    Run Keyword And Ignore Error    Radio Reset With Admin     ${fr_serial_number}    ${reset_bts_id}    timeout=20
    Radio Should Be Disbled    ${fr_serial_number}    ${reset_bts_id}    ${fr_next_hops_list}
    Check Not Testing Related FRs States When Testing FR Is Resetting    ${not_testing_related_frs}    ${reset_bts_id}
    FOR    ${bts_id}    IN    @{rfs_bts_id}
        Radio Should Be On    ${fr_serial_number}    ${bts_id}    ${fr_next_hops_list}
    END

Check Not Testing Related FRs States When Testing FR Is Resetting
    [Arguments]    ${not_testing_related_frs}    ${bts_id}
    FOR    ${fr_sn}    IN    @{not_testing_related_frs}
        ${rfs_bts_id}    Get Bts Id With FR Serial Number    ${fr_sn}
        Continue For Loop If    "${bts_id}" not in "${rfs_bts_id}"
        coam.assert any    class_name=RMOD
        ...    parameters=operationalState=regex"(?i)Enabled", serialNumber=${fr_sn}
        ...    timeout=10s    alias=${CASE_NAME}_${bts_id}
    END

Get Not Testing Realted And Next Hops FR List
    [Arguments]    ${fr_serial_number}    ${bts_id}
    ${fr_chain_list}    Set Variable    ${NODE_CFG["${bts_id}"]["fr_chain_list"]}
    ${fr_next_hops_list}    Run Keyword If    "${fr_serial_number}" in "${fr_chain_list}"    Get Next Hops FR List
    ...    ${fr_serial_number}    ${fr_chain_list}
    ...    ELSE    Create List
    ${not_testing_related_frs}    Create List    @{USED_FR_SN_LIST}
    Remove Values From List    ${not_testing_related_frs}    @{fr_next_hops_list}    ${fr_serial_number}
    [Return]    ${not_testing_related_frs}    ${fr_next_hops_list}

Get Next Hops FR List
    [Arguments]    ${fr_serial_number}    ${fr_chain_list}
    FOR    ${fr_chain}    IN    @{fr_chain_list}
         ${status}    Run Keyword And Return Status    Should Match Regexp    ${fr_chain}    .*${fr_serial_number}(->)?(.*)
         Continue For Loop If    not ${status}
         ${fr_next_hops}    Should Match Regexp    ${fr_chain}    .*${fr_serial_number}(->)?(.*)
         ${fr_next_hops_list}    Split String    ${fr_next_hops[2]}    ->
    END
    ${fr_next_hops_list}    Run Keyword If    "${fr_next_hops_list[0]}" == ""    Create List
    ...    ELSE    Set Variable    ${fr_next_hops_list}
    [Return]    ${fr_next_hops_list}

Radio Should Be Disbled
    [Arguments]    ${fr_serial_number}    ${bts_id}    ${fr_next_hops_list}=${None}
    ${fr_next_hops_list}    Run Keyword If   "${fr_next_hops_list}"=="${None}"    Create List
    ...    ELSE    Set Variable    ${fr_next_hops_list}
    coam.assert any    class_name=RMOD
    ...    parameters=operationalState=regex"(?i)Disabled", serialNumber=${fr_serial_number}
    ...    timeout=300s    alias=${CASE_NAME}_${bts_id}
    FOR    ${fr_next_hop}    IN    @{fr_next_hops_list}
        coam.assert any    class_name=RMOD
        ...    parameters=operationalState=regex"(?i)Disabled", serialNumber=${fr_next_hop}
        ...    timeout=10s    alias=${CASE_NAME}_${bts_id}
    END
    Wait Until Keyword Succeeds    2 min    10s    Check Cells State On Specific FR    ${fr_serial_number}    operational_state=disabled
    FOR    ${fr_next_hop}    IN    @{fr_next_hops_list}
        Wait Until Keyword Succeeds    5 min    10s    Check Cells State On Specific FR    ${fr_next_hop}    operational_state=disabled
    END

Radio Should Be Off
    [Arguments]    ${fr_serial_number}    ${bts_id}
    ${assert_parameters}    Set Variable    availabilityStatus=regex"NotInstalled|not installed", operationalState=regex"(?i)Disabled"
    coam.assert any    class_name=RMOD
    ...    parameters=${assert_parameters}, serialNumber=${fr_serial_number}
    ...    timeout=300s    alias=${CASE_NAME}_${bts_id}
    Wait Until Keyword Succeeds    2 min    10s    Check Cells State On Specific FR    ${fr_serial_number}    operational_state=disabled

Radio Reset With Admin
    [Arguments]    ${fr_serial_number}    ${bts_id}    ${timeout}=300
    coam.reset unit    dist_name=${NODE_CFG["${bts_id}"]["rmod_info"]["${fr_serial_number}"]["distName"]}
    ...    reset_type=Soft    timeout=${timeout}    connection=${CASE_NAME}_${bts_id}

Scfc Get rfSharingEnabled
    [Arguments]    ${scf_file_path}
    ${out_value}=    Evaluate Xpath    ${scf_file_path}
    ...     string(.//managedObject[@class='com.nokia.srbts.mnl:FEATCADM']/p[@name='rfSharingEnabled'])
    ${out_value}=    Convert To Boolean    ${out_value}
    [Return]    ${out_value}

Scfc Get rfSharing Master Status
    [Arguments]    ${scf_file_path}
    ${out_value}=    Evaluate Xpath    ${scf_file_path}
    ...     string(.//managedObject[@class='com.nokia.srbts.eqm:RMOD']/p[@name='radioMasterDN'])
    ${master_status}    Run Keyword And Return Status     Should Contain    ${out_value}    BBMOD
    [Return]    ${master_status}

Get RF Reset Btsid
    [Arguments]    ${rfs_bts_id}
    ${rfSharingEnabled}    Scfc Get rfSharingEnabled    ${NODE_CFG["${rfs_bts_id[0]}"]["scf_file_path"]}
    Return From Keyword If    not ${rfSharingEnabled}    ${rfs_bts_id[0]}
    FOR    ${bts_id}    IN    @{rfs_bts_id}
        ${master_status}    Scfc Get rfSharing Master Status    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
        Return From Keyword If    ${master_status}    ${bts_id}
    END

Power On Radio
    [Arguments]    ${fr_serial_number}
    PDU Turn On Unit    pdu_type=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['port']}
    ${rfs_bts_id}    Get Bts Id With FR Serial Number    ${fr_serial_number}
    FOR    ${bts_id}    IN    @{rfs_bts_id}
        Radio Should Be On    ${fr_serial_number}    ${bts_id}
        coam.assert_alarm_inactive    parameters=faultId=10, severity=Critical    timeout=200    connection=${CASE_NAME}_${bts_id}
    END
    Wait For All Cells OnAir    timeout=10 min

Power On Radio With Return Time
    [Arguments]    ${fr_serial_number}
    pdu.Setup Pdu        host=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['ip_addr']}
    ...    model=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['type']}
    pdu.Power On    port=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['port']}
    ${start_time}    DateTime.Get Current Date    UTC    result_format=%Y-%m-%dT%H:%M:%S
    ${rfs_bts_id}    Get Bts Id With FR Serial Number    ${fr_serial_number}
    FOR    ${bts_id}    IN    @{rfs_bts_id}
        Radio Should Be On    ${fr_serial_number}    ${bts_id}
        coam.assert_alarm_inactive    parameters=faultId=10, severity=Critical    timeout=120    connection=${CASE_NAME}_${bts_id}
    END
    Wait For All Cells OnAir    timeout=10 min
    [Return]    ${start_time}

Radio Should Be On
    [Arguments]    ${fr_serial_number}    ${bts_id}    ${fr_next_hops_list}=${None}
    ${fr_next_hops_list}    Run Keyword If   "${fr_next_hops_list}"=="${None}"    Create List
    ...    ELSE    Set Variable    ${fr_next_hops_list}
    coam.assert any    class_name=RMOD    parameters=operationalState=regex"(?i)Enabled", serialNumber=${fr_serial_number}
    ...    timeout=600s    alias=${CASE_NAME}_${bts_id}
    FOR    ${fr_next_hop}    IN    @{fr_next_hops_list}
        coam.assert any    class_name=RMOD
        ...    parameters=operationalState=regex"(?i)Enabled", serialNumber=${fr_next_hop}
        ...    timeout=600s    alias=${CASE_NAME}_${bts_id}
    END

Get Bts Id With FR Serial Number
    [Arguments]    ${fr_serial_number}
    ${rfs_bts_id}    Create List
    FOR    ${bts_id}    IN    @{BTS_LIST}
        Run Keyword If    "${fr_serial_number}" in ${NODE_CFG['${bts_id}'].fr_sn_list}
        ...    Append To List    ${rfs_bts_id}    ${bts_id}
    END
    [Return]    ${rfs_bts_id}

Check Cells State On Specific FR
    [Arguments]    ${fr_serial_number}    ${operational_state}
    FOR    ${cell}    IN    @{ALL_CELL_LIST}
        ${is_cells_fr}    Check Is Cell's FR    ${fr_serial_number}    ${cell["RF"]}
        Continue For Loop If    not ${is_cells_fr}
        ${cells_fr_num}    Get Length    ${cell["RF"]}
        Continue For Loop If    "${operational_state}" == "disabled" and ${cells_fr_num} > ${1}
        ${cell_runtime_info}    coam.Get Cell Specific Info    cell_id=${cell["distName"]}
        ...    connection=${CASE_NAME}_${cell["btsId"]}
        ${runtime_operational_state}    Convert To Lowercase    ${cell_runtime_info["status"]["operationalState"]}
        Should Be Equal As Strings    ${runtime_operational_state}    ${operational_state}
    END

Check Is Cell's FR
    [Arguments]    ${fr_sn}    ${rf_list}
    FOR    ${rf}    IN    @{rf_list}
        Return From Keyword If    "${fr_sn}" == "${rf["serialNumber"]}"    ${True}
    END
    Return From Keyword    ${False}


Check Is Cell Cross RRU
    FOR    ${cell}    IN    @{ALL_CELL_LIST}
        ${cells_fr_num}    Get Length    ${cell["RF"]}
        Return From Keyword If    ${cells_fr_num} > ${1}    ${True}
    END
    Return From Keyword    ${False}

Check Is Cell's ANTL In FR
    [Arguments]    ${fr_sn}    ${antl}    ${rf_list}
    FOR    ${rf}    IN    @{rf_list}
        Return From Keyword If    "${fr_sn}" == "${rf["serialNumber"]}" and "${antl}" in "${rf['antl']}"    ${True}
    END
    Return From Keyword    ${False}

Lock RU
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    [Arguments]    ${btsId}
    ${connection_id}    Set Variable   ${CASE_NAME}_${btsId}
    ${bts_info}    Get From Dictionary    ${NODE_CFG}    ${btsId}
    ${rru_info}    Get From Dictionary    ${bts_info}    rmod_info
    ${rru_sn_list}    Get Dictionary Keys    ${rru_info}
    FOR    ${sn}    IN    @{rru_sn_list}
        ${rmod_distname}    Get R Object Distname By SN    class_name=RMOD_R    sn=${sn}    connection=${connection_id}
        coam.lock    dist_name=${rmod_distname}    connection=${connection_id}    timeout=180
        Wait Until Keyword Succeeds    2min    10 sec
        ...    RU Should Be Locked With Admin    distName=${rmod_distname}    connection=${connection_id}
    END

UnLock RU
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    [Arguments]    ${btsId}
    ${connection_id}    Set Variable   ${CASE_NAME}_${btsId}
    ${bts_info}    Get From Dictionary    ${NODE_CFG}    ${btsId}
    ${rru_info}    Get From Dictionary    ${bts_info}    rmod_info
    ${rru_sn_list}    Get Dictionary Keys    ${rru_info}
    FOR    ${sn}    IN    @{rru_sn_list}
        ${rmod_distname}    Get R Object Distname By SN    class_name=RMOD_R    sn=${sn}    connection=${connection_id}
        coam.unlock    dist_name=${rmod_distname}    connection=${connection_id}    timeout=180
        Wait Until Keyword Succeeds    5min    10 sec
        ...    RU Should Be Unlocked With Admin    distName=${rmod_distname}    connection=${connection_id}
    END

Ru Should Be Locked With Admin
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    [Arguments]    ${distName}    ${connection}
#    ${subcell_status}=  Get Cell Status      cell_idx=${cell_idx}
#    ...                                      cell_group_idx=${cell_group_idx}
#    ...                                      timeout=${timeout}
#    ...                                      connection=${connection}

    ${ru_R_info}    coam.get_parameters    dist_name=${distName}    connection=${connection}
    Should Be Equal As Strings  ${ru_R_info["administrativeState"]}   Locked


Ru Should Be Unlocked With Admin
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    [Arguments]    ${distName}    ${connection}
#    ${subcell_status}=  Get Cell Status      cell_idx=${cell_idx}
#    ...                                      cell_group_idx=${cell_group_idx}
#    ...                                      timeout=${timeout}
#    ...                                      connection=${connection}

    ${ru_R_info}    coam.get_parameters    dist_name=${distName}    connection=${connection}
    Should Be Equal As Strings  ${ru_R_info["administrativeState"]}   Unlocked


Update_Specail_Cell_Earfcn_And_Check
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    [Arguments]    ${cell_info}    ${earfcn_config}
    ${connection_id}    Set Variable   ${CASE_NAME}_${cell_info['btsId']}
    ${R_class_name}   Get R CELL Class Name   ${cell_info}
    ${cell_distname}    Get R Object Distname    class_name=${R_class_name}
    ...     id=${cell_info["cellId"]}    connection=${connection_id}
    ${update_earfcn_dict}    Get From Dictionary    ${earfcn_config}    ${cell_info['phyCellId']}
    ${update_earfcn_type}    Get Dictionary Keys    ${update_earfcn_dict}
    Sort List    ${update_earfcn_type}
    Reverse List    ${update_earfcn_type}
    ${status}    Run Keyword And Return Status   List Should Contain Value    ${update_earfcn_type}    NSAS
    ${sas_fun}=    Set Variable If    '${status}'=='True'    enable    disable
    Set Test Variable    ${network_type}    ${cell_info["NetworkType"]}
    Run Keyword If    '${cell_info["NetworkType"]}'=='SA' or '${cell_info["NetworkType"]}'=='NSA'
    ...     Set Test Variable    ${network_type}    5G
    FOR    ${type}    IN    @{update_earfcn_type}
         Return From Keyword If    '${type}'=='NSAS'
         ${update_earfcn}    Get From Dictionary    ${update_earfcn_dict}    ${type}
         Run Keyword If    '${network_type}'=='4G' and '${cell_info["cellTechnology"]}'=='TDD'
         ...     coam.perform_parameter_recommissioning    dist_name=${cell_info['distName']}/LNCEL_TDD-0
         ...     parameter=earfcn     operation=update     value=${update_earfcn['Dl']}
         ...     skip_parameter_relation_errors=True    connection=${connection_id}
         Run Keyword If    '${network_type}'=='4G' and '${cell_info["cellTechnology"]}'=='FDD'
         ...     coam.perform_parameter_recommissioning    dist_name=${cell_info['distName']}/LNCEL_FDD-0
         ...     parameter=earfcnDl     operation=update     value=${update_earfcn['Dl']}
         ...     skip_parameter_relation_errors=True    connection=${connection_id}
         Run Keyword If    '${network_type}'=='5G' and '${cell_info["cellTechnology"]}'=='TDD'
         ...     coam.perform_parameter_recommissioning    dist_name=${cell_info['distName']}
         ...     parameter=nrarfcn     operation=update     value=${update_earfcn['Dl']}
         ...     skip_parameter_relation_errors=True    connection=${connection_id}
         Run Keyword If    '${network_type}'=='5G' and '${cell_info["cellTechnology"]}'=='FDD'
         ...     coam.perform_parameter_recommissioning    dist_name=${cell_info['distName']}/NRCELL_FDD-1
         ...     parameter=nrarfcnDl     operation=update     value=${update_earfcn['Dl']}
         ...     skip_parameter_relation_errors=True    connection=${connection_id}
         Run Keyword If    '${type}'=='OutRange' and '${network_type}'=='5G'
         ...    Wait Until Keyword Succeeds    10 mins    30 sec
         ...    coam.assert_alarm_active
         ...    parameters=faultId=1900,severity=Critical
         ...     connection=${connection_id}
         Run Keyword If    '${type}'=='OutRange' and '${network_type}'=='4G' and '${sas_fun}'=='disable'
         ...    Wait Until Keyword Succeeds    10 mins    30 sec
         ...    coam.assert_alarm_active
         ...    parameters=faultId=1807,severity=Critical
         ...     connection=${connection_id}
         ${cell_R}    Run Keyword If    '${type}'=='OutRange' and '${network_type}'=='4G' and '${sas_fun}'=='enable'
         ...    coam.Get Cell Specific Info    cell_id=${cell_info["distName"]}    connection=${connection_id}
         Run Keyword If    '${type}'=='OutRange' and '${network_type}'=='4G' and '${sas_fun}'=='enable'
         ...    Should Be Equal As Strings  ${cell_R["status"]["operationalState"]}   disabled
         Run Keyword If    '${type}'=='OutRange' and '${network_type}'=='4G' and '${sas_fun}'=='enable'
         ...    Should Be Equal As Strings  ${cell_R["status"]["availabilityStatus"]}  off line
         Run Keyword If    '${type}'=='InRange' or '${sas_fun}'=='enable'   Wait For All Cells OnAir    timeout=10 mins
     END

Get Cell Info From All Cells With PCI
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    [Arguments]    ${all_cells}    ${pci}
    FOR    ${btscells}    IN    @{all_cells}
         ${status}   ${cell_info}   Run Keyword And Ignore Error
         ...    Get Cell Info With PCI    ${btscells}    ${pci}
         Return From Keyword If      '${status}'=='PASS'     ${cell_info}
    END

Lock all sfp lane and check status
    [Arguments]    ${bts_id}    ${sfp_type}
    log to console    \n*** Lock all sfp lane and check status ***
    ${lane_id_list}    Get SFP LANE Id    ${bts_id}    ${sfp_type}
    Set Test Variable    ${lane_id_list}
#    ${lane_distname_list}    Get Lane Dist Name    ${NODE_CFG["${bts_id}"]["scf_file_path"]}    ${sfp_type}
#    Set Test Variable    ${lane_distname_list}
#    FOR    ${lane_id}    IN    @{lane_id_list}
#        Sfp Should Be Unlocked    ${lane_id}     connection=${CASE_NAME}_${bts_id}
#    END
    Should Not Be Empty    ${lane_id_list}
    FOR    ${lane_id}    IN    @{lane_id_list}
        coam.Lock    ${lane_id[3]}    timeout=120    connection=${CASE_NAME}_${bts_id}
    END
    Sleep    10s
    ${lane_rrus}    Create List
    FOR    ${lane_id}    IN    @{lane_id_list}
        Sfp Should Be Locked    ${lane_id}     connection=${CASE_NAME}_${bts_id}
        ${ru_configuration}    COAM get lane connect ru    ${lane_id}    connection=${CASE_NAME}_${bts_id}
        ${configDN}    ${rmod_label}    Split String From Right    ${ru_configuration}   /    1
        ${config_DN}    fetch from right    ${configDN}    RMOD-
        ${config_DN}    convert to integer    ${config_DN}
        Append To List    ${lane_rrus}    ${config_DN}
    END
    ${lane_rrus}    Remove Duplicates    ${lane_rrus}
    ${rru_info_list}    Get Dictionary Values    ${NODE_CFG["${bts_id}"]["rmod_info"]}
    FOR    ${rru_info}    IN    @{rru_info_list}
        ${rmodId}    Convert To Integer    ${rru_info["rmodId"]}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${lane_rrus}    ${rmodId}
        Run Keyword If    ${status}    RU Status Should Be NotInstalled    connection=${CASE_NAME}_${bts_id}    ru_index=${rmodId}
        ...    ELSE    Ru Status Should Be Online    ru_index=${rmodId}    connection=${CASE_NAME}_${bts_id}
    END
    ${allowed_faults}    Create List    @{GLO_ADMIN_ALLOWED_ALARM}    No connection to unit
    Admin Alarms Get And Check    allowed=${allowed_faults}    alias=${CASE_NAME}_${bts_id}

Unlock all sfp lane and check status
    [Arguments]    ${bts_id}
    log to console    \n*** Unlock all sfp lane and check status ***
    FOR    ${lane_id}    IN    @{lane_id_list}
        coam.unLock    ${lane_id[3]}    timeout=120    connection=${CASE_NAME}_${bts_id}
    END
    sleep   20s
    FOR    ${lane_id}    IN    @{lane_id_list}
        Sfp Should Be Unlocked    ${lane_id}     connection=${CASE_NAME}_${bts_id}
    END
    Wait For All Cells OnAir

Get SFP LANE Id
    [Documentation]    get sfp hw_name, object_name, lane_id
    [Arguments]    ${bts_id}    ${sfp_type}
    ${current_scfc}    Get Current Scfc    ${bts_id}
    ${lane_id_list}    siteinfo.get_sfp_info    ${current_scfc}    ${sfp_type}
    [Return]    ${lane_id_list}

Sfp Should Be Locked
    [Arguments]    ${lane_id}    ${connection}=GNB_OAM
    ${operationalState}    COAM get lane status    ${lane_id}    connection=${connection}
    should be equal as strings    ${operationalState}    disabled

Sfp Should Be Unlocked
    [Arguments]    ${lane_id}    ${connection}=GNB_OAM
    ${operationalState}    COAM get lane status    ${lane_id}    connection=${connection}
    should be equal as strings    ${operationalState}    enabled

COAM get lane status
    [Arguments]    ${lane_id}    ${connection}=GNB_OAM
    ${fbb_info}    coam.get_fbb_info    connection=${connection}
    ${sfp_distname}    Set Variable
    FOR    ${cabinet}    IN    @{fbb_info}
        Continue For Loop If    "${cabinet["status"]['usageState']}" == "Idle"
        ${sfp_distname}    Run Keyword If    "${lane_id[0]}" in "${cabinet['id']['configuration']}"
        ...    COAM get sfp distName    ${cabinet['ports']}    ${lane_id[1]}
        Exit For Loop If    "${lane_id[0]}" in "${cabinet['id']['configuration']}"
    END
    ${lane_r_list}    coam.get_managed_objects    LANE_R    connection=${connection}
    ${lane_status_list}    Set Variable
    FOR    ${lane_r}    IN    @{lane_r_list}
        ${lane_r_id}    Fetch From Right    ${lane_r["distName"]}    -
        ${lane_idx}    Fetch From Right    ${lane_id[3]}    -
        ${lane_status_list}    Run Keyword if    "${sfp_distname}" in "${lane_r['distName']}" and "${lane_r_id}"=="${lane_idx}"
        ...    coam.get_parameters    ${lane_r['distName']}    pattern=operationalState    connection=${connection}
        Exit For Loop If    "${sfp_distname}" in "${lane_r['distName']}" and "${lane_r_id}"=="${lane_idx}"
    END
    [Return]    ${lane_status_list['operationalState']}

COAM get lane connect ru
    [Arguments]    ${lane_id}    ${connection}=GNB_OAM
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    FOR    ${cable}    IN    @{hw_info['cables']}
        Return From Keyword If    "${lane_id[0]}/${lane_id[1]}" in "${cable['firstEndPointId']['configuration']}"
        ...    ${cable['secondEndPointId']['configuration']}
    END

Get RU Detial Info By RU Index
    [Arguments]    ${ru_index}=1    ${connection}=GNB_OAM
    ${ru_index}    Convert to string    ${ru_index}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    Should be true    ${count_RUs}>=1    msg=No RU found
    &{dict_RUs_detail_info}   Create dictionary
    FOR    ${RU}    IN    @{list_RUs}
        ${status}    Run Keyword And Return Status    Should Contain   '${RU}'   RMOD-${ru_index}/
        Run keyword if   '${status}'=='True'    Set to dictionary    ${dict_RUs_detail_info}    ${ru_index}    ${RU}
    END
    [Return]  ${dict_RUs_detail_info['${ru_index}']}

RU Status Should Be NotInstalled
    [Arguments]  ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_status}    Get RU Detial Info By RU Index     ru_index=${ru_index}   connection=${connection}
#    ${rmod_distname}    Get R Object Distname    class_name=RMOD_R
#        ...     id=${ru_index}    connection=${connection}
#    ${ru_R_info}    coam.get_parameters    dist_name=${rmod_distname}    connection=${connection}
    Should be equal as strings    ${ru_status['status']['operationalState']}       disabled
                                  ...  msg=Current RU operationalStatus is not in Disabled status    ignore_case=${True}
    Should be equal as strings    ${ru_status['status']['availabilityStatus']}     not installed
                                  ...  msg=Current RU availabilityStatus is not in Offline status    ignore_case=${True}

RU Status Should Be Online
    [Arguments]  ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_status}    Get RU Detial Info By RU Index      ru_index=${ru_index}   connection=${connection}
    Should be equal as strings    ${ru_status['status']['operationalState']}    Enabled
                                  ...  msg=Current RU operationalStatus is not in Enabled status    ignore_case=${True}
    Should be equal as strings    ${ru_status['status']['availabilityStatus']}    Online
                                  ...  msg=Current RU availabilityStatus is not in Online status    ignore_case=${True}

Get Current Config RRU Index
    [Documentation]    Author: Zhou Qiang
    ...                Description: Reset Current config RRUs
    [Arguments]    ${bts_id}
    ${RF_serial_number_list}    siteinfo.get_rru_list    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
    ${ru_index_list}  create list
    FOR    ${RF_info}    IN    @{RF_serial_number_list}
        ${ru_index}    Get RF Index With Serial Num    ${RF_info[0]}
        Run KeyWord If     '${ru_index}'=='${empty}'    Fail
        append to list    ${RF_info}    ${ru_index}
        ${ru_index}    Evaluate    ${ru_index}-1
        append to list    ${RF_info}    ${ru_index}
    END
    [Return]  ${RF_serial_number_list}

COAM get sfp distName
    [Arguments]    ${cabinet_ports}    ${object_name}
    FOR    ${port}    IN    @{cabinet_ports}
        Return From Keyword If    "${object_name}" == "${port['label']}"    ${port['id']['internal']}
    END

Get RF Index With Serial Num
    [Documentation]
    [Arguments]    ${RF_serial_num}
    ${count}    Get Length    ${RU_list}
    FOR    ${index}    IN RANGE    0    ${count}
         ${RF_index}    Evaluate    ${index}+1
         Return From Keyword If   '${RU_list[${index}].serial_number}'=='${RF_serial_num}'    ${RF_index}
    END
    Return From Keyword    ${empty}

Test Dedicated Uplink Start
    [Documentation]    Author: Lou Xingxin
    [Arguments]    ${cell_info}   ${beam_pattern_nr_id}
    ${channel_number}    Set Variable    A1_3
    ${beam_pattern_nr}    Create List    ${beam_pattern_nr_id}
    ${connectionId}    Set Variable    ${CASE_NAME}_${cell_info["btsId"]}
    ${R_class_name}  Get R CELL Class Name  ${cell_info}
    ${cell_distname}  Get R Object Distname  class_name=${R_class_name}    id=${cell_info["cellId"]}    connection=${connectionId}
    ${earfcn}    Run Keyword If    '${cell_info["NetworkType"]}'=='SA' or '${cell_info["NetworkType"]}'=='NSA'
    ...    Set Variable If    '${cell_info["cellTechnology"]}'=='FDD'    ${cell_info["earfcnUl"]}    ${cell_info["nrarfcn"]}
    ${earfcn}    Run Keyword If    '${cell_info["NetworkType"]}'=='4G'
    ...    Set Variable If    '${cell_info["cellTechnology"]}'=='FDD'    ${cell_info["earfcnUl"]}    ${cell_info["earfcn"]}
    ${serial_num}   Set Variable   ${cell_info["RF"][0]["serialNumber"]}
    ${rru_info}   Get RRU Info   ${serial_num}
    ${rru_productName}   Set Variable   ${rru_info["parameters"]["productName"]}
    ${status}  ${frc_index}    Run Keyword And Ignore Error    Get From Dictionary     ${frc_index_dict}    ${rru_productName}
    ${status}  Run Keyword And Return Status    Run Keyword If    '${cell_info["NetworkType"]}'=='SA' or '${cell_info["NetworkType"]}'=='NSA'
    ...    coam.start_5g_uplink_test  ${cell_distname}   ${frc_index}   ${beam_pattern_nr}  1  0  NR_Only
    ...    ${cell_info['phyCellId']}   connection=${connectionId}
    Run Keyword If    '${cell_info["NetworkType"]}'=='4G'
    ...    coam.start_uplink_test  ${cell_distname}  ${channel_number}  1    0    ${earfcn}    BinaryHarq
    ...  tdd_frame_conf=3    tdd_spec_subf_conf=8   connection=${connectionId}
    ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${cell_info["distName"]}    connection=${connectionId}
#    Wait Until Keyword Succeeds    30    5 sec    Should Be Equal As Strings  ${cell_R_info["status"]["availabilityStatus"]}  in test

Test Dedicated Uplink Stop
    [Documentation]    Author: Lou Xingxin
    [Arguments]    ${cell_info}
    ${connectionId}    Set Variable    ${CASE_NAME}_${cell_info["btsId"]}
    ${R_class_name}  Get R CELL Class Name  ${cell_info}
    ${cell_distname}  Get R Object Distname  class_name=${R_class_name}    id=${cell_info["cellId"]}    connection=${connectionId}
    Run Keyword If    '${cell_info["NetworkType"]}'=='SA' or '${cell_info["NetworkType"]}'=='NSA'
    ...    coam.stop_5g_uplink_test  ${cell_distname}   connection=${connectionId}
    Run Keyword If    '${cell_info["NetworkType"]}'=='4G'
    ...    coam.stop_uplink_test  ${cell_distname}  connection=${connectionId}
    ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${cell_info["distName"]}    connection=${connectionId}
#    Wait Until Keyword Succeeds    30    5 sec   Should Be Equal As Strings  ${cell_R_info["status"]["availabilityStatus"]}  off line

Reset_to_Test_Dedicated
    [Documentation]    Author: Lou Xingxin
    [Arguments]    ${timeout}=15 min
    FOR    ${bts_id}    IN    @{BTS_LIST}
        coam.Reset_to_Test_Dedicated   timeout=360   alias=${CASE_NAME}_${bts_id}
        Wait Until Keyword Succeeds    ${timeout}    20 sec   Verify Test Dedicated   ${bts_id}
    END

Verify Test Dedicated
    [Documentation]    Author: Lou Xingxin
    [Arguments]    ${bts_id}
    ${require_objects_list}    coam.Get Managed Objects    class_name=MRBTS_M    connection=${CASE_NAME}_${bts_id}
    ${require_parameters}    coam.get_parameters    dist_name=${require_objects_list[0]["distName"]}    pattern=testingState
    ...  connection=${CASE_NAME}_${bts_id}
    Should be equal as strings  ${require_parameters["stateInfo"]["testingState"]}  Enabled

Test Dedicated Downlink Start
    [Documentation]    Author: Lou Xingxin
    [Arguments]    ${cell_info}  ${beam_pattern_nr_id}
    ${beam_pattern_nr}    Create List    ${beam_pattern_nr_id}
    ${connectionId}    Set Variable    ${CASE_NAME}_${cell_info["btsId"]}
    ${R_class_name}  Get R CELL Class Name  ${cell_info}
    ${cell_distname}  Get R Object Distname  class_name=${R_class_name}    id=${cell_info["cellId"]}    connection=${connectionId}
    ${earfcn}    Run Keyword If    '${cell_info["NetworkType"]}'=='SA' or '${cell_info["NetworkType"]}'=='NSA'
    ...    Set Variable If    '${cell_info["cellTechnology"]}'=='FDD'    ${cell_info["earfcnDl"]}    ${cell_info["nrarfcn"]}
    ${earfcn}    Run Keyword If    '${cell_info["NetworkType"]}'=='4G'
    ...    Set Variable If    '${cell_info["cellTechnology"]}'=='FDD'    ${cell_info["earfcnDl"]}    ${cell_info["earfcn"]}
    Run Keyword If    '${cell_info["NetworkType"]}'=='SA' or '${cell_info["NetworkType"]}'=='NSA'
    ...    coam.start_5g_downlink_test  ${cell_distname}   TM1_1   ${beam_pattern_nr}    P_plus45_or_0    1    NR_Only
    ...    ${cell_info["phyCellId"]}    0    0    0    0    1   connection=${connectionId}
    Run Keyword If    '${cell_info["NetworkType"]}'=='4G'
    ...    coam.start_downlink_test  ${cell_distname}  E_TM1_1  ${earfcn}    ${cell_info["phyCellId"]}    tdd_frame_conf=3
        ...    tdd_spec_sub_conf=8   connection=${connectionId}
    ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${cell_info["distName"]}    connection=${connectionId}
#    Wait Until Keyword Succeeds    30    5 sec   Should Be Equal As Strings  ${cell_R_info["status"]["availabilityStatus"]}  in test

Test Dedicated Downlink Stop
    [Documentation]    Author: Lou Xingxin
    [Arguments]    ${cell_info}
    ${connectionId}    Set Variable    ${CASE_NAME}_${cell_info["btsId"]}
    ${R_class_name}  Get R CELL Class Name  ${cell_info}
    ${cell_distname}  Get R Object Distname  class_name=${R_class_name}    id=${cell_info["cellId"]}    connection=${connectionId}
    Run Keyword If    '${cell_info["NetworkType"]}'=='SA' or '${cell_info["NetworkType"]}'=='NSA'
    ...    coam.stop_5g_downlink_test  ${cell_distname}   connection=${connectionId}
    Run Keyword If    '${cell_info["NetworkType"]}'=='4G'
    ...    coam.stop_downlink_test  ${cell_distname}  connection=${connectionId}
    ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${cell_info["distName"]}    connection=${connectionId}
#    Wait Until Keyword Succeeds    30    5 sec   Should Be Equal As Strings  ${cell_R_info["status"]["availabilityStatus"]}  off line

Test Dedicated Downlink And Uplink Start
    [Documentation]    Author:        haoyun-lyle.sheng@nokia-sbell.com
    ...                Maintainer:    haoyun-lyle.sheng@nokia-sbell.com
    ${beam_pattern_nr_downlink}    Create list    1
    ${beam_pattern_nr_uplink}    Create List    0  1200
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        Log Variables
        ${connectionId}    Set Variable    ${CASE_NAME}_${cell_info["btsId"]}
        ${R_class_name}    Get R CELL Class Name    ${cell_info}
        ${cell_distname}    Get R Object Distname    class_name=${R_class_name}    id=${cell_info["cellId"]}
        ...    connection=${connectionId}
        ${earfcn_dl}    Run Keyword If    '${cell_info["NetworkType"]}'=='FDD'   Set Variable   ${cell_info["earfcnDl"]}
        ...    ELSE    Set Variable    ${cell_info["earfcn"]}
        ${earfcn_ul}    Run Keyword If    '${cell_info["NetworkType"]}'=='FDD'   Set Variable   ${cell_info["earfcnUl"]}
        ...    ELSE    Set Variable    ${cell_info["earfcn"]}
        Run Keyword If    '${R_class_name}'=='LNCEL_R'    Run Keywords    coam.start_downlink_test    ${cell_distname}
        ...    E_TM1_1    ${earfcn_dl}    ${cell_info["phyCellId"]}    tdd_frame_conf=3    tdd_spec_sub_conf=8
        ...    timeout=60    connection=${connectionId}    AND    coam.start_uplink_test    ${cell_distname}    A1_3
        ...    1    0    ${earfcn_ul}    BinaryHarq    tdd_frame_conf=3    tdd_spec_subf_conf=8   timeout=240
        ...    alias=${connectionId}
        ...    ELSE IF    '${R_class_name}'=='NRCELL_R'    Run Keywords    coam.start_5g_downlink_test
        ...    ${cell_distname}    TM1_1     ${beam_pattern_nr_downlink}    P_plus45_or_0    1    NR_Only
        ...    ${cell_info["phyCellId"]}    0    0    0    0    1    timeout=60    connection=${connectionId}    AND
        ...    coam.start_5g_uplink_test    ${cell_distname}    G_FR1_A1_1    ${beam_pattern_nr_uplink}   1   1    MSR
        ...    ${cell_info["phyCellId"]}  timeout=240   connection=${connectionId}
    END

Test Dedicated Downlink And Uplink Stop
    [Documentation]    Author:        haoyun-lyle.sheng@nokia-sbell.com
    ...                Maintainer:    haoyun-lyle.sheng@nokia-sbell.com
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        ${connectionId}    Set Variable    ${CASE_NAME}_${cell_info["btsId"]}
        ${R_class_name}    Get R CELL Class Name    ${cell_info}
        ${cell_distname}    Get R Object Distname    class_name=${R_class_name}    id=${cell_info["cellId"]}
        ...    connection=${connectionId}
        Run Keyword If    '${R_class_name}'=='LNCEL_R'    Run Keywords    coam.stop_downlink_test    ${cell_distname}
        ...    alias=${connectionId}    AND    coam.stop_uplink_test    ${cell_distname}    alias=${connectionId}
        ...    ELSE IF    '${R_class_name}'=='NRCELL_R'    Run Keywords    coam.stop_5g_downlink_test   ${cell_distname}
        ...    connection=${connectionId}    AND    coam.stop_5g_uplink_test    ${cell_distname}
        ...    connection=${connectionId}
    END

LTE Test Dedicated Uplink
    [Documentation]    Author: Lou Xingxin
    [Arguments]    ${cell_info}   ${connection}
    ${LTE_TEST_MODEL_UPLINK}   Evaluate    ${LTE_TEST_MODEL_UPLINK}
    ${R_class_name}  Get R CELL Class Name  ${cell_info}
    ${cell_distname}  Get R Object Distname  class_name=${R_class_name}    id=${cell_info["cellId"]}    connection=${connection}
    ${pci}    Set Variable   ${cell_info["phyCellId"]}
    ${test_model_para}    Set Variable   ${LTE_TEST_MODEL_UPLINK["${pci}"]}
    ${earfcn}   Set Variable If    '${cell_info["cellTechnology"]}'=='FDD'    ${cell_info["earfcnUl"]}    ${cell_info["earfcn"]}
    FOR    ${channel_number}   IN   @{test_model_para["testmodel"]}
        coam.start_uplink_test   dist_name=${cell_distname}
        ...                      reference_channel_number=${channel_number}
        ...                      reporting_time_interval=1
        ...                      resource_block_offset=0
        ...                      earfcn=${earfcn}
        ...                      digital_output_type=BinaryHarq
        ...                      tdd_frame_conf=1
        ...                      tdd_spec_subf_conf=7
        ...                      connection=${connection}
        sleep  5s
        coam.stop_uplink_test  ${cell_distname}  connection=${connection}
    END
    ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${cell_info["distName"]}    connection=${connection}
    Wait Until Keyword Succeeds    30    5 sec    Should Be Equal As Strings  ${cell_R_info["status"]["availabilityStatus"]}  off line

LTE Test Dedicated Downlink
    [Documentation]    Author: Lou Xingxin
    [Arguments]    ${cell_info}   ${connection}
    ${LTE_TEST_MODEL_DOWNLINK}   Evaluate    ${LTE_TEST_MODEL_DOWNLINK}
    ${R_class_name}  Get R CELL Class Name  ${cell_info}
    ${cell_distname}  Get R Object Distname  class_name=${R_class_name}    id=${cell_info["cellId"]}    connection=${connection}
    ${pci}    Set Variable   ${cell_info["phyCellId"]}
    ${test_model_para}    Set Variable   ${LTE_TEST_MODEL_DOWNLINK["${pci}"]}
    ${earfcn}   Set Variable If    '${cell_info["cellTechnology"]}'=='FDD'    ${cell_info["earfcnDl"]}    ${cell_info["earfcn"]}
    FOR    ${test_model}   IN   @{test_model_para["testmodel"]}
        coam.start_downlink_test   dist_name=${cell_distname}
        ...                        test_model=${test_model}
        ...                        earfcn=${earfcn}
        ...                        tdd_frame_conf=3
        ...                        tdd_spec_sub_conf=8
        ...                        connection=${connection}
        sleep  5s
        coam.stop_downlink_test  ${cell_distname}  connection=${connection}
    END
    ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${cell_info["distName"]}    connection=${connection}
    Wait Until Keyword Succeeds    30    5 sec    Should Be Equal As Strings  ${cell_R_info["status"]["availabilityStatus"]}  off line

NR Test Dedicated Uplink
    [Documentation]    Author: Lou Xingxin
    [Arguments]    ${cell_info}      ${connection}
    ${NR_TEST_MODEL_UPLINK}   Evaluate    ${NR_TEST_MODEL_UPLINK}
    ${R_class_name}  Get R CELL Class Name  ${cell_info}
    ${cell_distname}  Get R Object Distname  class_name=${R_class_name}    id=${cell_info["cellId"]}    connection=${connection}
    ${pci}    Set Variable   ${cell_info["phyCellId"]}
    ${test_model_para}    Set Variable   ${NR_TEST_MODEL_UPLINK["${pci}"]}
    FOR    ${channel_number}   IN   @{test_model_para["testmodel"]}
        coam.start_5g_uplink_test   dist_name=${cell_distname}
        ...                      frc_index=${channel_number}
        ...                      beam_pattern_id=${test_model_para["beam_pattern_id"]}
        ...                      interval=1
        ...                      prb_offset=0
        ...                      ru_mode=NR_Only
        ...                      phys_cell_id=${pci}
        ...                      connection=${connection}
        ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${cell_info["distName"]}    connection=${connection}
        Wait Until Keyword Succeeds    30    5 sec    Should Be Equal As Strings  ${cell_R_info["status"]["availabilityStatus"]}  in test
        sleep  5s
        coam.stop_5g__uplink_test  ${cell_distname}  connection=${connection}
        ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${cell_info["distName"]}    connection=${connection}
        Wait Until Keyword Succeeds    30    5 sec    Should Be Equal As Strings  ${cell_R_info["status"]["availabilityStatus"]}  off line
    END

NR Test Dedicated Downlink
    [Documentation]    Author: Lou Xingxin
    [Arguments]    ${cell_info}      ${connection}
    ${NR_TEST_MODEL_DOWNLINK}   Evaluate    ${NR_TEST_MODEL_DOWNLINK}
    ${R_class_name}  Get R CELL Class Name  ${cell_info}
    ${cell_distname}  Get R Object Distname  class_name=${R_class_name}    id=${cell_info["cellId"]}    connection=${connection}
    ${pci}    Set Variable   ${cell_info["phyCellId"]}
    ${test_model_para}    Set Variable   ${NR_TEST_MODEL_DOWNLINK["${pci}"]}
    ${earfcn}   Set Variable If    '${cell_info["cellTechnology"]}'=='FDD'    ${cell_info["earfcnDl"]}    ${cell_info["earfcn"]}
    FOR    ${test_model}   IN   @{test_model_para["testmodel"]}
        coam.start_5g_downlink_test   dist_name=${cell_distname}
        ...                           test_model=${test_model}
        ...                           beam_pattern_id=${test_model_para["beam_pattern_id"]}
        ...                           polarization=P_plus45_or_0
        ...                           power_backoff=1
        ...                           ru_mode=NR_Only
        ...                           phys_cell_id=${pci}
        ...                           codebook_2_antports=0
        ...                           i11_codebook_4_antports=0
        ...                           i2_codebook_4_antports=0
        ...                           i13_codebook_4_antports=0
        ...                           mimo_rank=1
        ...                           connection=${connection}
        ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${cell_info["distName"]}    connection=${connection}
        Wait Until Keyword Succeeds    30    5 sec    Should Be Equal As Strings  ${cell_R_info["status"]["availabilityStatus"]}  in test
        sleep  5s
        coam.stop_5g_downlink_test  ${cell_distname}  connection=${connection}
        ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${cell_info["distName"]}    connection=${connection}
        Wait Until Keyword Succeeds    30    5 sec    Should Be Equal As Strings  ${cell_R_info["status"]["availabilityStatus"]}  off line
    END

Online Change Multi Parameters
    [Arguments]    ${parameter_list}    ${connection}
    [Documentation]    Author:        haoyun-lyle.sheng@nokia-sbell.com
    ...                Maintainer:    haoyun-lyle.sheng@nokia-sbell.com
    coam.Create delta
    FOR    ${parameter}    IN    @{parameter_list}
        coam.Append parameter update to delta    ${parameter['distName']}    ${parameter['paraName']}
        ...    ${parameter['paraValue']}
    END
    ${delta_update}=    coam.Get delta
    coam.Perform delta recommissioning    ${delta_update}    skip_parameter_relation_errors=True
    ...    connection=${connection}
    [Teardown]    coam.Remove delta

Check Multi Parameters Recommission Result
    [Arguments]    ${para_list}    ${connection}
    [Documentation]    Author:        haoyun-lyle.sheng@nokia-sbell.com
    ...                Maintainer:    haoyun-lyle.sheng@nokia-sbell.com
    coam.get_current_scf_file    ${SUITE_LOGS_DIR_PATH}    SCFC.xml    export_type=configurationAndRuntimeObjects
    ...    connection=${connection}
    ${current_scfc_path}    Set Variable    ${SUITE_LOGS_DIR_PATH}/SCFC.xml
    FOR    ${para}    IN    @{para_list}
        ${out_tmp_value}=    Get Element Text    ${current_scfc_path}
         ...    xpath=.//managedObject[@distName='${para['distName']}']/p[@name='${para['paraName']}']
        Run Keyword And Continue On Failure    Should Be Equal    ${para['paraValue']}    ${out_tmp_value}
    END

Informodel check any condition is true cycel
    [Arguments]    ${fault_info}    ${cycel_index}=2    ${cycel_interval}=10    ${connection_id}=default
    [Documentation]    ${query_list} shuold be a list
    FOR    ${num}    IN RANGE    ${cycel_index}
        ${ret_query}=    Run Keyword And Return Status    coam.assert_alarm_active
        ...    parameters=${fault_info}
        ...    connection=${connection_id}
        ...    timeout=30
        Exit For Loop If    ${ret_query}
        Sleep    ${cycel_interval}
    END
    Should Be True    ${ret_query}

Rf Fault trigger without recovery
    [Arguments]    ${RRU_IP}    ${faultid}    ${connection_id}
    ${RF_fault_info}    Evaluate    ${RF_fault_info}
    Send RRU Command    ${RRU_IP}    ${RF_fault_info['${faultid}']['trigger']}    ${RF_fault_info['${faultid}']['port']}
    ${alarms}   coam.assert_alarm_active
    ...    parameters=faultId=${faultid},severity=${tl_config.RF_FAULT_INFO['${faultid}']['serverity']}
    ...     connection=${connection_id}
    Informodel check any condition is true cycel    fault_info=faultId=${faultid}
    ...     cycel_index=5    cycel_interval=60    connection_id=${connection_id}
    Run Keyword If    '${faultid}'!='1923'
    ...    Send RRU Command    ${RRU_IP}    ${RF_fault_info['${faultid}']['cancel']}
    ...    ${RF_fault_info['${faultid}']['port']}
    Run Keyword If    '${faultid}'!='1923'    sleep    20

    Run Keyword If    '${faultid}'!='1923'    coam.assert_alarm_inactive
    ...    parameters=faultId=${faultid},severity=${tl_config.RF_FAULT_INFO['${faultid}']['serverity']}
    ...     connection=${connection_id}
    Run Keyword If    '${faultid}'!='1923'    Check Alarms
    Run Keyword If    '${faultid}'!='1923'    Send RRU Command
    ...     ${RRU_IP}    ${RF_fault_info['${faultid}']['trigger']}    ${RF_fault_info['${faultid}']['port']}
    Run Keyword If    '${faultid}'!='1923'
    ...    Informodel check any condition is true cycel    fault_info=faultId=${faultid}
    ...     cycel_index=5    cycel_interval=60    connection_id=${connection_id}

Rf Fault trigger without recovery Rel5
    [Arguments]    ${RRU_IP}    ${faultid}    ${connection_id}
    Send RRU Command via Telnet Rel5
    ...    ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['trigger']['telnet']['before']}
    Send RRU Command via SSH Rel5     ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['trigger']['ssh']}
    Send RRU Command via Telnet Rel5
    ...    ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['trigger']['telnet']['after']}

    coam.reset_site    connection=${connection_id}
    Informodel check any condition is true cycel    fault_info=faultId=${faultid},severity=Critical
    ...     cycel_index=10    cycel_interval=300    connection_id=${connection_id}

    Send RRU Command via Telnet Rel5
    ...   ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['cancel']['telnet']['before']}
    Send RRU Command via SSH Rel5     ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['cancel']['ssh']}
    Send RRU Command via Telnet Rel5
    ...    ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['cancel']['telnet']['after']}
    Comment    Reset BTS Until Onair

Rf Fault trigger without recovery Rel6 Changename
    [Arguments]    ${RRU_IP}    ${faultid}    ${fr_serial_number}    ${bts_id}    ${connection_id}
    Send RRU Command via SSH Rel6     ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['trigger']}
    Radio Reset With Admin     ${fr_serial_number}    ${bts_id}
    Send Ping RRU Command via SSH Rel6     ${RRU_IP}

    Informodel check any condition is true cycel    fault_info=faultId=${faultid},severity=Warning
    ...     cycel_index=10    cycel_interval=1    connection_id=${connection_id}

    Wait Until Keyword Succeeds    300s    1s
    ...    Send RRU Command via SSH Rel6     ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['cancel']}
    [Teardown]    Wait Until Keyword Succeeds    600s    10s
    ...    Send RRU Command via SSH Rel6     ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['cancel']}

Rf Fault trigger without recovery Rel6
    [Arguments]    ${RRU_IP}    ${faultid}    ${fr_serial_number}    ${connection_id}
    Send Agent RRU Command via SSH Rel6
    ...    ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['trigger']['ssh']['before']}
    FOR    ${command}    IN    @{tl_config.RF_FAULT_INFO['${faultid}']['trigger']['ssh']['before']}
        ${status1}    ${file}    Run Keyword And Ignore Error    Should Match Regexp    ${command}    /\\w+/\\w+\.json
        ${status2}    ${file_name}    Run Keyword And Ignore Error    Should Match Regexp    ${command}    \\w+\.json
        Run Keyword If    '${status1}'=='PASS'    Set Test Variable    ${out_file}    ${file}
        Run Keyword If    '${status2}'=='PASS'    Set Test Variable    ${out_file_name}    ${file_name}
    END
    Download File From FR Rel6    ${RRU_IP}    ${out_file}    ${out_file_name}    ${SUITE_LOGS_DIR_PATH}
    FOR    ${parameter}   IN   @{tl_config.RF_FAULT_INFO['${faultid}']['trigger']['ssh']['parameter']}
        Process Json    input_file=${SUITE_LOGS_DIR_PATH}/${out_file_name}
        ...    search_key=${parameter['name']}
        ...    modify_value=${parameter['value']}
    END
    Upload File To FR Rel6    ${RRU_IP}    /ram/    ${out_file_name}    ${SUITE_LOGS_DIR_PATH}
    Send Agent RRU Command via SSH Rel6
    ...    ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['trigger']['ssh']['after']}
    Power Off Radio    ${fr_serial_number}    ${connection_id}
    sleep  60s
    Power On Radio    ${fr_serial_number}    ${connection_id}
    Wait For All Cells OnAir
    Send Agent RRU Command via SSH Rel6
    ...    ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['trigger']['ssh']['set_alarm']}
    Wait Until Keyword Succeeds    1800 sec    30 sec  coam.assert_alarm_active
    ...    parameters=faultId=${faultid}    connection=${connection_id}
    [Teardown]    Run Keyword And Ignore Error    Send Agent RRU Command via SSH Rel6     ${RRU_IP}
    ...    ${tl_config.RF_FAULT_INFO['${faultid}']['cancel']}

Rf Fault trigger with recovery Rel6
    [Arguments]    ${RRU_IP}    ${faultid}    ${fr_serial_number}    ${connection_id}
    Send Agent RRU Command via SSH Rel6
    ...    ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['trigger']['ssh']['before']}
    FOR    ${command}    IN    @{tl_config.RF_FAULT_INFO['${faultid}']['trigger']['ssh']['before']}
        ${status1}    ${file}    Run Keyword And Ignore Error    Should Match Regexp    ${command}    /\\w+/\\w+\.json
        ${status2}    ${file_name}    Run Keyword And Ignore Error    Should Match Regexp    ${command}    \\w+\.json
        Run Keyword If    '${status1}'=='PASS'    Set Test Variable    ${out_file}    ${file}
        Run Keyword If    '${status2}'=='PASS'    Set Test Variable    ${out_file_name}    ${file_name}
    END
    Download File From FR Rel6    ${RRU_IP}    ${out_file}    ${out_file_name}    ${SUITE_LOGS_DIR_PATH}
    FOR    ${parameter}   IN   @{tl_config.RF_FAULT_INFO['${faultid}']['trigger']['ssh']['parameter']}
        Process Json    input_file=${SUITE_LOGS_DIR_PATH}/${out_file_name}
        ...    search_key=${parameter['name']}
        ...    modify_value=${parameter['value']}
    END
    Upload File To FR Rel6    ${RRU_IP}    /ram/    ${out_file_name}    ${SUITE_LOGS_DIR_PATH}
    Send Agent RRU Command via SSH Rel6
    ...    ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['trigger']['ssh']['after']}
    ${rmod_distname}    Get R Object Distname By SN    class_name=RMOD_R    sn=${fr_serial_number}    connection=${connection_id}
    coam.lock    dist_name=${rmod_distname}    connection=${connection_id}    timeout=180
    coam.unlock    dist_name=${rmod_distname}    connection=${connection_id}    timeout=180
#    ${out_history_alarms_list}    coam.Get Historic Alarms    connection=${alias}    timeout=60
    Wait Until Keyword Succeeds    300 sec    5 sec    coam.assert_alarm_active
    ...    parameters=faultId=${faultid}   connection=${connection_id}
    Wait For All Cells OnAir

Rf Fault trigger without recovery Rel5 AZNA
    [Arguments]    ${RRU_IP}    ${faultid}      ${fr_serial_number}    ${bts_id}    ${connection_id}
    Send RRU Command via SSH Rel5 AZNA     ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['trigger']['ssh']}
    Radio Reset With Admin     ${fr_serial_number}    ${bts_id}
    #coam.reset_site    connection=${connection_id}
#    ${reboot}=	 Create List    reboot
#    Send RRU Command via SSH Rel5 AZNA    ${RRU_IP}    ${reboot}    no
    Informodel check any condition is true cycel
    ...     fault_info=faultId=${faultid},severity=${tl_config.RF_FAULT_INFO['${faultid}']['serverity']}
    ...     cycel_index=10    cycel_interval=300    connection_id=${connection_id}
    Send RRU Command via SSH Rel5 AZNA     ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['cancel']['ssh']}
    Radio Reset With Admin     ${fr_serial_number}    ${bts_id}

Rf Fault trigger with recovery
    [Arguments]    ${RRU_IP}    ${faultid}    ${connection_id}
    ${RF_fault_info}    Evaluate    ${RF_fault_info}
    FOR    ${trigger_index}    IN RANGE    ${RF_fault_info['${faultid}']['trigger'][1]}
        ${trigger_index}    Evaluate    ${trigger_index}+1
        ${trigger_cmd}    Replace String
        ...    ${RF_fault_info['${faultid}']['trigger'][0]}    1 0 0 0    ${trigger_index} 0 0 0
        Send RRU Command    ${RRU_IP}    ${trigger_cmd}    ${RF_fault_info['${faultid}']['port']}
    END

    Informodel check any condition is true cycel    fault_info=faultId=${faultid}
    ...     cycel_index=10    cycel_interval=6    connection_id=${connection_id}

Rf Fault trigger with recovery Rel5
    [Arguments]    ${RRU_IP}    ${faultid}    ${connection_id}
    Send RRU Command via Telnet Rel5
    ...    ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['trigger']['telnet']['before']}
    Send RRU Command via SSH Rel5
    ...    ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['trigger']['ssh']}
    Send RRU Command via Telnet Rel5
    ...    ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['trigger']['telnet']['after']}
    coam.reset_site    connection=${connection_id}

    Informodel check any condition is true cycel    fault_info=faultId=${faultid},severity=Critical
    ...     cycel_index=10    cycel_interval=300    connection_id=${connection_id}
    Send RRU Command via Telnet Rel5
    ...    ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['cancel']['telnet']['before']}
    Send RRU Command via SSH Rel5    ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['cancel']['ssh']}
    Send RRU Command via Telnet Rel5
    ...    ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['cancel']['telnet']['after']}
    Reset BTS Until Onair

Rf Fault trigger with recovery Rel5 AZNA
    [Arguments]    ${RRU_IP}    ${faultid}    ${fr_serial_number}    ${bts_id}     ${connection_id}
    Send RRU Command via SSH Rel5 AZNA    ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['trigger']['ssh']}
    #Radio Reset With Admin     ${fr_serial_number}    ${bts_id}

    Informodel check any condition is true cycel
    ...     fault_info=faultId=${faultid},severity=severity=${tl_config.RF_FAULT_INFO['${faultid}']['serverity']}
    ...     cycel_index=20    cycel_interval=30    connection_id=${connection_id}

    Send RRU Command via SSH Rel5 AZNA    ${RRU_IP}    ${tl_config.RF_FAULT_INFO['${faultid}']['cancel']['ssh']}
    Radio Reset With Admin     ${fr_serial_number}    ${bts_id}

Get Cells State On Specific FR
    [Arguments]    ${fr_serial_number}
    ${cell_mapping_rf_list}    Create List
    FOR    ${cell}    IN    @{ALL_CELL_LIST}
        ${is_cells_fr}    Check Is Cell's FR    ${fr_serial_number}    ${cell["RF"]}
        Continue For Loop If    not ${is_cells_fr}
        Append To List    ${cell_mapping_rf_list}    ${cell}
    END
    [Return]   ${cell_mapping_rf_list}


Upload File To FR
    [Arguments]    ${pc_target_file}    ${rf_target_file}    ${rf_host_name}
    ${path_tmp}    ${file_name}=    split path    ${rf_target_file}
    ute_fsmaccess.Setup Enb Fsm Access
    ute_fsmaccess.Put Enb File    ${pc_target_file}    /user/toor4nsn/${file_name}
    ute_fsmaccess.Teardown Enb Fsm Access
    SSHLibrary.Open Connection    host=${BTS_HOST}    timeout=30
    SSHLibrary.Login    username=toor4nsn    password=oZPS0POrRieRtu
    ${ret}    SSHLibrary.Execute Command    lxc-ls --active
    ${ret1}    Run Keyword And Ignore Error    Should Match Regexp    ${ret}    0x2018
    ${ret2}    Run Keyword And Ignore Error    Should Match Regexp    ${ret}    0x1018
    Run Keyword If    '${ret1[0]}'=='PASS'    SSHLibrary.Write    lxc-attach -n 0x2018
    Run Keyword If    '${ret2[0]}'=='PASS'    SSHLibrary.Write    lxc-attach -n 0x1018
    SSHLibrary.Read Until    >
    ${out_ssh_rsa}     Run Keyword And Return Status      Variable Should Exist     ${SSH_RSA}
    Run Keyword If     ${out_ssh_rsa}    SSHLibrary.Write
    ...    scp -O ${SSH_RSA_CMD} ${file_name} ${rf_host_name}:${rf_target_file}
    ...    ELSE    SSHLibrary.Write    scp -O ${file_name} ${rf_host_name}:${rf_target_file}
    ${ret}    Run Keyword And Return Status    SSHLibrary.Read Until    ?
    Run Keyword If    ${ret}    SSHLibrary.Write    yes    ELSE    SSHLibrary.Write    \n
    SSHLibrary.Read Until    >
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Rf_Fault_trigger_with_recovery_MMIMO
    [Arguments]    ${RRU_IP}    ${faultid}    ${fr_serial_number}   ${connection_id}
    ${RF_fault_info}    Evaluate    ${RF_fault_info}
    set test variable    ${RF_fault_info}
    ${cell_list}    Get Cells State On Specific FR    ${fr_serial_number}
    ${tmp_lncell}     Set Variable    ${cell_list[0]["distName"]}

    ${xpath}    Set Variable
    ...     .//managedObject[contains(@class,'NOKLTE:LNCEL_TDD') and contains(@distName,'${tmp_lncell}')]
    ${tmp_mmimo_config}=    Get Element Text
    ...     ${cell_list[0]["scfc"]}
    ...    xpath=${xpath}/p[@name="mMimoAntArrayMode"]
    ${temp_ret}    ${orientation}    ${path_num}=
    ...     Should Match Regexp    ${tmp_mmimo_config}    (.+)\\s(\\d+)TRX\\sArray\\s\\(\\dx\\dx2\\)
    #${out_earfcn}=    SCFC Get earfcn Tdd    ${OUT_SCFC_CURRENT_FILE_PATH}    ${tmp_lcrid}
    ${out_earfcn}     Set Variable     ${cell_list[0]["earfcn"]}
    ${out_frequency}=    Set Variable    ${cell_list[0]['freq']}
    ${earfcn_range}    EVALUATE    ${EARFCN_RANGE}
    ${freq}=    run keyword if
    ...    ${out_earfcn}>=0.5*(${earfcn_range['${fr_serial_number}'][0]}+${earfcn_range['${fr_serial_number}'][1]})
    ...    evaluate    ${out_frequency}*0.1-20
    ...    ELSE    evaluate    ${out_frequency}*0.1+20
    ${RRU_info}    Get RRU Info    ${fr_serial_number}
    ${is_aahf_type}=    run keyword and return status    Should Contain Match    ${AAHF_type}
    ...    ${RRU_info['parameters']['productName']}
    @{fault_list_1907_1911}=    create list    1907    1911
    @{fault_list_1937_1938}=    create list    1937    1938
    ${ret1}=    run keyword and return status    should contain match    ${fault_list_1907_1911}    ${faultid}
    ${ret2}=    run keyword and return status    should contain match    ${fault_list_1937_1938}    ${faultid}
    run keyword if
    ...    '${orientation}'=='Full' and '${path_num}'=='64' and '${is_aahf_type}'=='True' and '${ret1}'=='True'
    ...    Rf_Fault_trigger_with_recovery_MMIMO_${faultid}_Full
    ...    ${RRU_IP}    ${faultid}    ${freq}    ${fr_serial_number}    ${connection_id}
    run keyword if
    ...    '${orientation}'!='Full' and '${path_num}'=='32' and '${is_aahf_type}'=='True' and '${ret1}'=='True'
    ...    Rf_Fault_trigger_with_recovery_MMIMO_${faultid}_Half
    ...    ${RRU_IP}    ${faultid}    ${freq}    ${orientation}    ${connection_id}
    run keyword if    '${orientation}'!='Full' and '${path_num}'=='32'and '${ret2}'=='True'
    ...    Rf_Fault_trigger_with_recovery_MMIMO_${faultid}_Half    ${RRU_IP}    ${faultid}    ${connection_id}
    run keyword if
    ...    '${orientation}'=='Full' and '${path_num}'=='64' and '${is_aahf_type}'=='True' and '${ret2}'=='True'
    ...    Rf_Fault_trigger_with_recovery_MMIMO_${faultid}_Full    ${RRU_IP}    ${faultid}    ${fr_serial_number}
    ...    ${connection_id}
    [Teardown]    run keyword and continue on failure    run keywords
    ...    PDU Turn Off Unit    pdu_type=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['port']}
    ...    AND    sleep    5
    ...    AND    PDU Turn On Unit
    ...    pdu_type=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['port']}
    ...    AND    Sleep    20

Rf_Fault_trigger_with_recovery_MMIMO_1907_Full
    [Arguments]    ${RRU_IP}    ${faultid}    ${freq}    ${fr_serial_number}    ${connection_id}
    ${1907_7654_dfe_one_antenna_group_top}
    ...    Evaluate    random.choice(@{mmimo_antenna_ordinal_aahf_top})    modules=random
    ${1907_7654_dfe_one_antenna_group_bottom}
    ...    Evaluate    random.choice(@{mmimo_antenna_ordinal_aahf_bottom})    modules=random
    @{1907_7654_dfe_two_antenna_group_top_bottom}=
    ...    create list    ${1907_7654_dfe_one_antenna_group_top}    ${1907_7654_dfe_one_antenna_group_bottom}
    @{1907_7654_cmd_two_antenna_group_top_bottom}=
    ...    fault_1907_calcuate_multi    ${freq}    ${1907_7654_dfe_two_antenna_group_top_bottom}
    Send RRU Command Mmimo    ${RRU_IP}
    ...    ${1907_7654_cmd_two_antenna_group_top_bottom}    ${RF_fault_info['${faultid}']['port']}

    Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=${faultid},alarmId=7654    connection=${connection_id}
#    Informodel check any condition is true cycel    fault_info=faultId=${faultid},alarmId=7654
#    ...     cycel_index=10    cycel_interval=6    connection_id=${connection_id}
    ${mmimo_antenna_ordinal_aahf_top_copy}    copy list    ${mmimo_antenna_ordinal_aahf_top}
    Remove Values From List    ${mmimo_antenna_ordinal_aahf_top_copy}    ${1907_7654_dfe_one_antenna_group_top}
    Rf_Fault_trigger_with_recovery_MMIMO_1907_one_antenna_7652
    ...    ${RRU_IP}    ${mmimo_antenna_ordinal_aahf_top_copy}    ${freq}    ${faultid}   ${connection_id}
    @{1907_7654_cmd_eight_antenna_group_top}=
    ...    fault_1907_calcuate_multi    ${freq}    ${mmimo_antenna_ordinal_aahf_top}
    Send RRU Command Mmimo
    ...    ${RRU_IP}    ${1907_7654_cmd_eight_antenna_group_top}    ${RF_fault_info['${faultid}']['port']}
    Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=${faultid},alarmId=7654    connection=${connection_id}

    Rf_Fault_trigger_with_recovery_MMIMO_1907_one_antenna_7652
    ...    ${RRU_IP}    ${mmimo_antenna_ordinal_aahf_bottom}    ${freq}    ${faultid}    ${connection_id}
    ${cell_list}    Get Cells State On Specific FR    ${fr_serial_number}
    ${out_dist_name}=
    ...    Evaluate Xpath   ${cell_list[0]["scfc"]}    string(.//managedObject[(@class="NOKLTE:LNBTS")]/@distName)
    ${out_dist_name} =  convert to string  ${out_dist_name}
    coam.perform_parameter_recommissioning
    ...    ${out_dist_name}    txPathFailureMode    update    disableCell
    ...    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=300    alias=${connection_id}

    Wait For All Cells OnAir
    Rf_Fault_trigger_with_recovery_MMIMO_1907_one_antenna_7652    ${RRU_IP}
    ...    ${mmimo_antenna_ordinal_aahf_bottom}    ${freq}    ${faultid}   ${connection_id}

Rf_Fault_trigger_with_recovery_MMIMO_1907_Half
    [Arguments]    ${RRU_IP}    ${faultid}    ${freq}    ${orientation}    ${connection_id}
    ${1907_7654_dfe_one_antenna_group_temps}    Evaluate
    ...    random.choice(@{mmimo_antenna_ordinal_aahf_${orientation}})    modules=random
    @{1907_7654_dfe_one_antenna_group_templ}=    Split String    ${1907_7654_dfe_one_antenna_group_temps}    _
    ${1907_7654_cmd_one_antenna_group_tmp}=    fault_1907_calcuate    ${freq}
    ...      ${1907_7654_dfe_one_antenna_group_templ[0]}    ${1907_7654_dfe_one_antenna_group_templ[1]}
    Send RRU Command Mmimo
    ...    ${RRU_IP}    ${1907_7654_cmd_one_antenna_group_tmp}    ${RF_fault_info['${faultid}']['port']}
    ${fault_status}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=${faultid},severity=Minor    connection=${connection_id}
    Should Not Be True    ${fault_status}
    ${mmimo_antenna_ordinal_aahf_half_copy}    copy list    ${mmimo_antenna_ordinal_aahf_${orientation}}
    Remove Values From List    ${mmimo_antenna_ordinal_aahf_half_copy}    ${1907_7654_dfe_one_antenna_group_temps}
    ${1907_7654_dfe_one_antenna_group_temps2}
    ...     Evaluate    random.choice(@{mmimo_antenna_ordinal_aahf_half_copy})    modules=random
    @{1907_7654_dfe_one_antenna_group_templ2}=    Split String        ${1907_7654_dfe_one_antenna_group_temps2}    _
    ${1907_7654_cmd_one_antenna_group_tmp2}=    fault_1907_calcuate    ${freq}
    ...    ${1907_7654_dfe_one_antenna_group_templ2[0]}    ${1907_7654_dfe_one_antenna_group_templ2[1]}
    Send RRU Command Mmimo    ${RRU_IP}
    ...    ${1907_7654_cmd_one_antenna_group_tmp2}    ${RF_fault_info['${faultid}']['port']}
    Sleep    20 sec
    Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=${faultid},severity=Major    connection=${connection_id}

    Remove Values From List    ${mmimo_antenna_ordinal_aahf_half_copy}    ${1907_7654_dfe_one_antenna_group_temps2}
    ${1907_7654_dfe_one_antenna_group_temps3}
    ...    Evaluate    random.choice(@{mmimo_antenna_ordinal_aahf_half_copy})    modules=random
    @{1907_7654_dfe_one_antenna_group_templ3}=    Split String    ${1907_7654_dfe_one_antenna_group_temps3}    _
    ${1907_7654_cmd_one_antenna_group_tmp3}=    fault_1907_calcuate
    ...    ${freq}    ${1907_7654_dfe_one_antenna_group_templ3[0]}    ${1907_7654_dfe_one_antenna_group_templ3[1]}
    Send RRU Command Mmimo
    ...    ${RRU_IP}    ${1907_7654_cmd_one_antenna_group_tmp3}    ${RF_fault_info['${faultid}']['port']}
    Sleep    20 sec
    Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=${faultid},severity=Major    connection=${connection_id}

    Remove Values From List    ${mmimo_antenna_ordinal_aahf_half_copy}    ${1907_7654_dfe_one_antenna_group_temps3}
    ${1907_7654_dfe_one_antenna_group_temps4}
    ...    Evaluate    random.choice(@{mmimo_antenna_ordinal_aahf_half_copy})    modules=random
    @{1907_7654_dfe_one_antenna_group_templ4}=    Split String    ${1907_7654_dfe_one_antenna_group_temps4}    _
    ${1907_7654_cmd_one_antenna_group_tmp4}=    fault_1907_calcuate
    ...    ${freq}    ${1907_7654_dfe_one_antenna_group_templ4[0]}    ${1907_7654_dfe_one_antenna_group_templ4[1]}
    Send RRU Command Mmimo
    ...    ${RRU_IP}    ${1907_7654_cmd_one_antenna_group_tmp4}    ${RF_fault_info['${faultid}']['port']}
    Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=${faultid},severity=Major    connection=${connection_id}

    Remove Values From List    ${mmimo_antenna_ordinal_aahf_half_copy}    ${1907_7654_dfe_one_antenna_group_temps4}
    ${1907_7654_dfe_one_antenna_group_temps5}
    ...    Evaluate    random.choice(@{mmimo_antenna_ordinal_aahf_half_copy})    modules=random
    @{1907_7654_dfe_one_antenna_group_templ5}=    Split String    ${1907_7654_dfe_one_antenna_group_temps5}    _
    ${1907_7654_cmd_one_antenna_group_tmp5}=    fault_1907_calcuate
    ...    ${freq}    ${1907_7654_dfe_one_antenna_group_templ5[0]}    ${1907_7654_dfe_one_antenna_group_templ5[1]}
    Send RRU Command Mmimo
    ...    ${RRU_IP}    ${1907_7654_cmd_one_antenna_group_tmp4}    ${RF_fault_info['${faultid}']['port']}
    Wait Until Keyword Succeeds    180 sec    10 sec   Verify All Cells OnAir With Abnormal State
    ...    avail_status=degraded

Rf_Fault_trigger_with_recovery_MMIMO_1907_one_antenna_7652
    [Arguments]    ${RRU_IP}    ${mmimo_antenna_ordinal_temp}    ${freq}    ${faultid}    ${connection_id}
    ...    ${faultid}    ${connection_id}
    ${1907_7652_dfe_one_antenna_group_temp}
    ...    Evaluate    random.choice(@{mmimo_antenna_ordinal_temp})    modules=random
    @{1907_7652_dfe_one_antenna_group_temp}=    split string    ${1907_7652_dfe_one_antenna_group_temp}    _
    ${1907_7652_cmd_one_antenna_group_tmp}=    fault_1907_calcuate
    ...    ${freq}    ${1907_7652_dfe_one_antenna_group_temp[0]}    ${1907_7652_dfe_one_antenna_group_temp[1]}
#    @{fault_list}=    Create List    //ALARM_L-* is [alarmInformation.faultId=${faultid},alarmActivity=Transient]
#    ...    //FRI-*/ALARM-* is [faultId=${faultid},alarmActivity=Transient]
    Send RRU Command Mmimo
    ...    ${RRU_IP}    ${1907_7652_cmd_one_antenna_group_tmp}    ${RF_fault_info['${faultid}']['port']}
    Wait Until Keyword Succeeds    100 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=${faultid},activity=Transient    connection=${connection_id}
    Wait For All Cells OnAir    timeout=30
    Check Alarms

Rf_Fault_trigger_with_recovery_MMIMO_1911_Full
    [Arguments]    ${RRU_IP}    ${faultid}    ${connection_id}
    ${1911_antenna_group_top}    Evaluate    random.choice(@{mmimo_antenna_ordinal_aahf_top})    modules=random
    ${1911_antenna_group_bottom}    Evaluate    random.choice(@{mmimo_antenna_ordinal_aahf_bottom})    modules=random
    @{1911_antenna_group_top_list}    create list    ${1911_antenna_group_top}
    @{1911_antenna_group_bottom_list}    create list    ${1911_antenna_group_bottom}
    @{1911_cmd_antenna_group_top}    fault_1911_calcuate_multi    ${1911_antenna_group_top_list}
    @{1911_cmd_antenna_group_bottom}    fault_1911_calcuate_multi    ${1911_antenna_group_bottom_list}
    @{1911_cmd_two_antenna_top}    Create List    ${1911_cmd_antenna_group_top[0]}    ${1911_cmd_antenna_group_top[1]}
    Send RRU Command Mmimo    ${RRU_IP}    ${1911_cmd_two_antenna_top}    ${RF_fault_info['${faultid}']['port']}
    ${fault_status}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    180 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=${faultid}    connection=${connection_id}
    Should Not Be True    ${fault_status}
    Sleep    30 minutes
    @{1911_cmd_four_antenna_top}    Create List    ${1911_cmd_antenna_group_top[2]}    ${1911_cmd_antenna_group_top[3]}
    Send RRU Command Mmimo    ${RRU_IP}    ${1911_cmd_four_antenna_top}    ${RF_fault_info['${faultid}']['port']}
    ${fault_status}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    180 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=${faultid}    connection=${connection_id}
    Should Not Be True    ${fault_status}
    @{1911_cmd_fifth_antenna_bottom}    Create List    ${1911_cmd_antenna_group_bottom[0]}
    Send RRU Command Mmimo    ${RRU_IP}    ${1911_cmd_fifth_antenna_bottom}    ${RF_fault_info['${faultid}']['port']}
    Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=${faultid},severity=Minor   connection=${connection_id}

    ${mmimo_antenna_ordinal_aahf_top_copy}    copy list    ${mmimo_antenna_ordinal_aahf_top}
    ${mmimo_antenna_ordinal_aahf_bottom_copy}    copy list    ${mmimo_antenna_ordinal_aahf_bottom}
    Remove Values From List    ${mmimo_antenna_ordinal_aahf_top_copy}    ${1911_antenna_group_top}
    Remove Values From List    ${mmimo_antenna_ordinal_aahf_bottom_copy}    ${1911_antenna_group_bottom}
    ${1911_antenna_group_top2}    Evaluate    random.choice(@{mmimo_antenna_ordinal_aahf_top_copy})    modules=random
    ${1911_antenna_group_bottom2}
    ...    Evaluate    random.choice(@{mmimo_antenna_ordinal_aahf_bottom_copy})    modules=random
    @{1911_antenna_group_top_bottom2}    create list    ${1911_antenna_group_top2}    ${1911_antenna_group_bottom2}
    @{1911_cmd_antenna_group_top_bottom2}    fault_1911_calcuate_multi    ${1911_antenna_group_top_bottom2}
    Send RRU Command Mmimo
    ...    ${RRU_IP}    ${1911_cmd_antenna_group_top_bottom2}    ${RF_fault_info['${faultid}']['port']}
    Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=${faultid},severity=Major    connection=${connection_id}

    Remove Values From List    ${mmimo_antenna_ordinal_aahf_top_copy}    ${1911_antenna_group_top2}
    Remove Values From List    ${mmimo_antenna_ordinal_aahf_bottom_copy}    ${1911_antenna_group_bottom2}
    ${1911_antenna_group_top3}    Evaluate    random.choice(@{mmimo_antenna_ordinal_aahf_top_copy})    modules=random
    ${1911_antenna_group_bottom3}
    ...    Evaluate    random.choice(@{mmimo_antenna_ordinal_aahf_bottom_copy})    modules=random
    @{1911_antenna_group_top_bottom3}    create list    ${1911_antenna_group_top3}    ${1911_antenna_group_bottom3}
    @{1911_cmd_antenna_group_top_bottom3}    fault_1911_calcuate_multi    ${1911_antenna_group_top_bottom3}
    Send RRU Command Mmimo
    ...    ${RRU_IP}    ${1911_cmd_antenna_group_top_bottom3}    ${RF_fault_info['${faultid}']['port']}
    Sleep    20 sec
    Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=${faultid},severity=Major    connection=${connection_id}

    Remove Values From List    ${mmimo_antenna_ordinal_aahf_top_copy}    ${1911_antenna_group_top3}
    Remove Values From List    ${mmimo_antenna_ordinal_aahf_bottom_copy}    ${1911_antenna_group_bottom3}
    ${1911_antenna_group_top4}    Evaluate    random.choice(@{mmimo_antenna_ordinal_aahf_top_copy})    modules=random
    ${1911_antenna_group_bottom4}
    ...    Evaluate    random.choice(@{mmimo_antenna_ordinal_aahf_bottom_copy})    modules=random
    @{1911_antenna_group_top_bottom4}    create list    ${1911_antenna_group_top4}    ${1911_antenna_group_bottom4}
    @{1911_cmd_antenna_group_top_bottom4}    fault_1911_calcuate_multi    ${1911_antenna_group_top_bottom4}
    Send RRU Command Mmimo
    ...    ${RRU_IP}    ${1911_cmd_antenna_group_top_bottom4}    ${RF_fault_info['${faultid}']['port']}
    Sleep    20 sec
    Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=${faultid},severity=Major    connection=${connection_id}

    Remove Values From List    ${mmimo_antenna_ordinal_aahf_top_copy}    ${1911_antenna_group_top4}
    Remove Values From List    ${mmimo_antenna_ordinal_aahf_bottom_copy}    ${1911_antenna_group_bottom4}
    ${1911_antenna_group_top5}    Evaluate    random.choice(@{mmimo_antenna_ordinal_aahf_top_copy})    modules=random
    ${1911_antenna_group_bottom5}
    ...    Evaluate    random.choice(@{mmimo_antenna_ordinal_aahf_bottom_copy})    modules=random
    @{1911_antenna_group_top_bottom5}    create list    ${1911_antenna_group_top5}    ${1911_antenna_group_bottom5}
    @{1911_cmd_antenna_group_top_bottom5}    fault_1911_calcuate_multi    ${1911_antenna_group_top_bottom5}
    Send RRU Command Mmimo
    ...    ${RRU_IP}    ${1911_cmd_antenna_group_top_bottom5}    ${RF_fault_info['${faultid}']['port']}
    Wait Until Keyword Succeeds    300 sec    10 sec    Check Historical Alarms
    ...    additional_allowed_alarms=RX out of order:RX out of order:Radio autonomous reset as recovery action
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}

Rf_Fault_trigger_with_recovery_MMIMO_1911_Half
    [Arguments]    ${RRU_IP}    ${faultid}    ${orientation}    ${connection_id}
    ${1911_7654_dfe_one_antenna_group_temps}
    ...    Evaluate    random.choice(@{mmimo_antenna_ordinal_aahf_${orientation}})    modules=random
    @{1911_7654_dfe_one_antenna_group_templ}=    Split String    ${1911_7654_dfe_one_antenna_group_temps}    _
    ${1911_7654_cmd_one_antenna_group_tmp}=
    ...    fault_1911_calcuate    ${1911_7654_dfe_one_antenna_group_templ[0]}
    ...    ${1911_7654_dfe_one_antenna_group_templ[1]}
    Send RRU Command Mmimo
    ...    ${RRU_IP}    ${1911_7654_cmd_one_antenna_group_tmp}    ${RF_fault_info['${faultid}']['port']}
    Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=${faultid},alarmId=7654    connection=${connection_id}
#    Informodel check any condition is true cycel    fault_info=faultId=${faultid},alarmId=7654
#    ...     cycel_index=10   cycel_interval=6   connection_id=${connection_id}
    ${mmimo_antenna_ordinal_aahf_half_copy}    copy list    ${mmimo_antenna_ordinal_aahf_${orientation}}
    Remove Values From List    ${mmimo_antenna_ordinal_aahf_half_copy}    ${1911_7654_dfe_one_antenna_group_temps}
    Rf_Fault_trigger_with_recovery_MMIMO_1911_one_antenna_7653
    ...    ${RRU_IP}    ${mmimo_antenna_ordinal_aahf_half_copy}    ${faultid}    ${connection_id}

Rf_Fault_trigger_with_recovery_MMIMO_1911_one_antenna_7653
    [Arguments]    ${RRU_IP}    ${mmimo_antenna_ordinal_temp}    ${faultid}    ${connection_id}
    ${1911_7653_dfe_one_antenna_group_temp}
    ...    Evaluate    random.choice(@{mmimo_antenna_ordinal_temp})    modules=random
    @{1911_7653_dfe_one_antenna_group_temp}=    split string    ${1911_7653_dfe_one_antenna_group_temp}    _
    ${1911_7653_cmd_one_antenna_group_tmp}=    fault_1911_calcuate
    ...     ${1911_7653_dfe_one_antenna_group_temp[0]}    ${1911_7653_dfe_one_antenna_group_temp[1]}
    Send RRU Command Mmimo
    ...    ${RRU_IP}    ${1911_7653_cmd_one_antenna_group_tmp}    ${RF_fault_info['${faultid}']['port']}
    Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=${faultid}    connection=${connection_id}
#    Informodel check any condition is true cycel    fault_info=faultId=${faultid}
#    ...     cycel_index=10   cycel_interval=6   connection_id=${connection_id}
    Sleep    20 sec
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}

Rf_Fault_trigger_with_recovery_MMIMO_1938_Half
    [Arguments]    ${RRU_IP}    ${faultid}    ${connection_id}
    Upload File To FR    ${CURDIR}/deviceoverheated.json   /run/deviceoverheated.json    root@${RRU_IP}
    Send RRU Command Mmimo    ${RRU_IP}    ${mmimo_fault_1937_8_telnet_cmd1}    2000
    Send RRU Command Mmimo    ${RRU_IP}    ${mmimo_fault_1937_8_ssh_cmd2}    22
    Send RRU Command Mmimo    ${RRU_IP}    ${mmimo_fault_1937_8_telnet_cmd3}    2000
    Send RRU Command Mmimo    ${RRU_IP}    ${mmimo_fault_1937_8_ssh_cmd4}    22
    sleep    20    #wait for rf rest
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Send RRU Command Mmimo    ${RRU_IP}    ${mmimo_fault_1938_ssh_cmd5}    22
    sleep    120    #wait for alarm is reported
    Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=${faultid}    connection=${connection_id}
    Send RRU Command Mmimo    ${RRU_IP}    ${mmimo_fault_1938_ssh_cmd6}    22
    Wait Until Keyword Succeeds    180 sec    10 sec   Verify All Cells OnAir With Abnormal State
    ...    avail_status=degraded
    Wait Until Keyword Succeeds    120 sec    10 sec    Check Alarms
    [Teardown]    run keyword and continue on failure    run keywords
    ...    Send RRU Command Mmimo    ${RRU_IP}    ${mmimo_fault_1937_8_telnet_cmd7}    2000
    ...    AND    Send RRU Command Mmimo    ${RRU_IP}    ${mmimo_fault_1938_ssh_cmd8}    22
    ...    AND    Sleep    60    #wait for rf rest
    ...    AND    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    ...    AND    Send RRU Command Mmimo    ${RRU_IP}    ${mmimo_fault_1937_8_telnet_cmd9}    2000

Rf_Fault_trigger_with_recovery_MMIMO_1938_Full
    [Arguments]    ${RRU_IP}    ${faultid}    ${fr_serial_number}    ${connection_id}
    Upload File To FR    ${CURDIR}/deviceoverheated.json    /run/deviceoverheated.json    root@${RRU_IP}
    Send RRU Command Mmimo    ${RRU_IP}    ${mmimo_fault_1937_8_telnet_cmd1}    2000
    Send RRU Command Mmimo    ${RRU_IP}    ${mmimo_fault_1937_8_ssh_cmd2}    22
    Send RRU Command Mmimo    ${RRU_IP}    ${mmimo_fault_1937_8_telnet_cmd3}    2000
    Send RRU Command Mmimo    ${RRU_IP}    ${mmimo_fault_1937_8_ssh_cmd4}    22
    Sleep    60    #wait for rf rest
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Send RRU Command Mmimo    ${RRU_IP}    ${mmimo_fault_1938_ssh_cmd5}    22
    Sleep    60    #wait for alarm is reported
    Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=${faultid}    connection=${connection_id}
    Send RRU Command Mmimo    ${RRU_IP}    ${mmimo_fault_1937_ssh_cmd5}    22
    sleep    60    #wait for alarm is reported
    Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=1937    connection=${connection_id}
    Send RRU Command Mmimo    ${RRU_IP}    ${mmimo_fault_1937_ssh_cmd6}    22
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Wait Until Keyword Succeeds    120 sec    10 sec    Check Alarms
    ${cell_list}    Get Cells State On Specific FR    ${fr_serial_number}
    ${out_dist_name}=
    ...    Evaluate Xpath   ${cell_list[0]["scfc"]}    string(.//managedObject[(@class="NOKLTE:LNBTS")]/@distName)
    ${out_dist_name} =  convert to string  ${out_dist_name}
    coam.perform_parameter_recommissioning    ${out_dist_name}    txPathFailureMode    update
    ...    disableCell    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=300    alias=${connection_id}
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Rf_Fault_trigger_with_recovery_MMIMO_1938_Half    ${RRU_IP}    ${faultid}    ${connection_id}
    [Teardown]    run keyword and continue on failure    run keywords
    ...    Send RRU Command Mmimo    ${RRU_IP}    ${mmimo_fault_1937_8_telnet_cmd7}    2000
    ...    AND    Send RRU Command Mmimo    ${RRU_IP}    ${mmimo_fault_1938_ssh_cmd8}    22
    ...    AND    sleep    60    #wait for rf rest
    ...    AND    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    ...    AND    Send RRU Command Mmimo    ${RRU_IP}    ${mmimo_fault_1937_8_telnet_cmd9}

RF Fault 4698 Trigger With Recovery
    [Arguments]    ${RRU_IP}    ${connection_id}
    @{fault_4698_trigger_cmds}    Create List    / action create SfpInfo /sfp
    ...    /sfp action sfp_override_memory 1 PAGE PAGE_1 0x70 DATA 0x80
    @{fault_4698_recovery_cmds}    Create List    /sfp action cancel_sfp_override_memory 1
    Send RRU Command Trigeer Fault 4698    ${RRU_IP}    ${fault_4698_trigger_cmds}
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=4698    connection=${connection_id}
    sleep    10s
    Send RRU Command Trigeer Fault 4698   ${RRU_IP}    ${fault_4698_recovery_cmds}
    Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_inactive
    ...    parameters=faultId=4698    connection=${connection_id}
    [Teardown]    Run Keyword And Ignore Error
    ...    Send RRU Command Trigeer Fault 4698   ${RRU_IP}    ${fault_4698_recovery_cmds}

Get Scfc SBTS
    [Arguments]    ${scfc_dir_path}
    coam.Setup admin    bts_host=${BTS_HOST}    bts_port=443    use_ssl=True    alias=getscfc
    coam.Collect scf    ${scfc_dir_path}    export_type=configurationAndRuntimeObjects    alias=getscfc
    coam.teardown admin    alias=getscfc
    [Return]    ${scfc_dir_path}

4G Robustness
    [Arguments]    ${ping}=${False}    ${required_cells}=${Empty}    ${invalid_ipAddrPrim}=1.1.1.1
    ${OUT_SCFC_CURRENT_FILE_PATH}    Get Scfc SBTS    ${TEST_LOGS_DIR_PATH}/SCFC.xml
    ${out_dist_name}=    Evaluate Xpath   ${OUT_SCFC_CURRENT_FILE_PATH}
    ...    string(.//managedObject[(@class="LNBTS" or @class="NOKLTE:LNBTS")and p[@name="actS1Flex"]]/@distName)
    ${out_dist_name}    Convert To Bytes     ${out_dist_name}
    ${out_dist_name}    convert to string     ${out_dist_name}
    coam.Setup admin    bts_host=${BTS_HOST}    bts_port=443    use_ssl=True    alias=robus
    ${out}    coam.perform_parameter_recommissioning    ${out_dist_name}    actS1Flex    update    enabled
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=300    alias=robus
    ${out_mme_dist_name}=    Evaluate Xpath   ${OUT_SCFC_CURRENT_FILE_PATH}
    ...    string(.//managedObject[(@class="LNMME" or @class="NOKLTE:LNMME")and p[@name="ipAddrPrim"]]/@distName)
    ${pre_mme_dist_name}    ${mme_id}    Split String From Right    ${out_mme_dist_name}    -    1
    ${invalid_mme_id}    Evaluate    ${mme_id} + 10
    ${transportNwId}    Evaluate Xpath   ${OUT_SCFC_CURRENT_FILE_PATH}
    ...     string(.//managedObject[(@class='LNMME' or @class='NOKLTE:LNMME')]/p[@name='transportNwId'])
    ${administrativeState}    Evaluate Xpath   ${OUT_SCFC_CURRENT_FILE_PATH}
    ...     string(.//managedObject[(@class='LNMME' or @class='NOKLTE:LNMME')]/p[@name='administrativeState'])
    ${mmeRatSupport}    Evaluate Xpath   ${OUT_SCFC_CURRENT_FILE_PATH}
    ...     string(.//managedObject[(@class='LNMME' or @class='NOKLTE:LNMME')]/p[@name='mmeRatSupport'])
    coam.Create delta
    coam.append_managed_object_to_delta    ${pre_mme_dist_name}-${invalid_mme_id}    create
    coam.append_parameter_update_to_delta    ${pre_mme_dist_name}-${invalid_mme_id}
    ...     ipAddrPrim    ${invalid_ipAddrPrim}
    coam.append_parameter_update_to_delta    ${pre_mme_dist_name}-${invalid_mme_id}
    ...     transportNwId    ${transportNwId}
    coam.append_parameter_update_to_delta    ${pre_mme_dist_name}-${invalid_mme_id}
    ...     administrativeState    ${administrativeState}
    coam.append_parameter_update_to_delta    ${pre_mme_dist_name}-${invalid_mme_id}
    ...     mmeRatSupport    ${mmeRatSupport}
    ${delta_update}=    coam.Get delta
    coam.append_managed_object_to_delta    ${pre_mme_dist_name}-${invalid_mme_id}    delete
    ${delta_delete}=    coam.Get delta
    coam.Perform delta recommissioning    ${delta_update}    skip_parameter_relation_errors=True    alias=robus
    coam.Assert alarm active    faultId=6202    timeout=120    alias=robus
    Make L3Call    ping=${ping}    required_cells=${required_cells}
    [Teardown]    Run Keywords    coam.Remove Delta
    ...    AND    Run Keyword And Ignore Error    coam.Perform delta recommissioning    ${delta_delete}
    ...     skip_parameter_relation_errors=True    alias=robus
    ...    AND    Verify All Cells OnAir
    ...    AND    coam.Assert alarm inactive    faultId=6202    timeout=30    alias=robus
    ...    AND    coam.teardown admin    alias=robus

Get RRU Side Info
    [Arguments]    ${serial_number}
    ${connection_id}    Set Variable   ${CASE_NAME}_${MASTER_BTS_ID}
    ${rmode_infos}    coam.get_managed_objects    RMOD_L    connection=${connection_id}
    FOR    ${rmode_info}    IN    @{rmode_infos}
        Continue For Loop If    "${rmode_info["parameters"]["serialNumber"]}" != "${serial_number}"
        ${status}    ${value}    Run Keyword And Ignore Error    Should Match Regexp
        ...    ${rmode_info["parameters"]["ipAddress"]}    ^172
        Run Keyword If    '${status}'=='PASS'    Set Test Variable    ${out_rmode_info}    ${rmode_info}
    END
    Should Not Be Empty    ${out_rmode_info["parameters"]["masterAgentDN"]}
    Should Not Be Empty    ${out_rmode_info["parameters"]["productName"]}
    ${side_info}    Should Match Regexp    ${out_rmode_info["parameters"]["masterAgentDN"]}    BTS_L-(\\d+)
    [Return]    ${out_rmode_info["parameters"]["ipAddress"]}    ${side_info[1]}
    ...    ${out_rmode_info["parameters"]["productName"]}

Get BBU Side Info
    [Arguments]    ${side_info}
    ${tl2_status}    ${output}    Run Keyword And Ignore Error    Variable Should Exist
    ...    ${BTS_CONFIG['HOST_IP']['TL2']}
    ${host_ip}=    Set Variable If    '${tl2_status}'=='PASS' and '${side_info}'=='4'
    ...    ${BTS_CONFIG['HOST_IP']['TL2']}    ${BTS_CONFIG['HOST_IP']['TL1']}
    ${bbu_ip}=    Set Variable If    '${tl2_status}'=='PASS' and '${side_info}'=='4'
    ...    192.168.255.119    192.168.255.129
    [Return]    ${host_ip}    ${bbu_ip}

Check RRU Available Info
    [Arguments]    ${serial_number}
    ${connection_id}    Set Variable   ${CASE_NAME}_${MASTER_BTS_ID}
    ${rmode_infos}    coam.get_managed_objects    RMOD_L    connection=${connection_id}
    FOR    ${rmode_info}    IN    @{rmode_infos}
        Continue For Loop If    "${rmode_info["parameters"]["serialNumber"]}" != "${serial_number}"
        ${status}    Run Keyword And Return Status    Should Not Be Empty    ${rmode_info["parameters"]["stateInfo"]}
       Run Keyword If    '${status}'=='True'    Set Test Variable    ${out_rfmode_info}    ${rmode_info}
    END
    Should Be Equal As Strings    ${out_rfmode_info["parameters"]["stateInfo"]["availabilityStatus"]}     Online

Get RRU Sw Info
    [Arguments]    ${serial_number}
    ${connection_id}    Set Variable   ${CASE_NAME}_${MASTER_BTS_ID}
    ${rmoder_infos}    coam.get_managed_objects    RMOD_R    connection=${connection_id}
    FOR    ${rmoder_info}    IN    @{rmoder_infos}
        Continue For Loop If    "${rmoder_info["parameters"]["serialNumber"]}" != "${serial_number}"
        ${status}    Run Keyword And Return Status    Should Not Be Empty    ${rmoder_info["distName"]}
        Run Keyword If    '${status}'=='True'    Set Test Variable    ${out_rmoder_info}    ${rmoder_info}
    END
    [Return]    ${out_rmoder_info}

Check RRU Incompatible Alarm And Upgrade
    [Arguments]    ${serial_number}
    ${connection_id}    Set Variable   ${CASE_NAME}_${MASTER_BTS_ID}
    ${rf}    Set Variable      ${tl_config.RF_FACTORY_SW_STORAGE['${serial_number}']}
    Wait Until Keyword Succeeds    6 min    3 sec    Check RRU Available Info    ${serial_number}
    sleep    10sec
    ${out_rmoder_info}    Get RRU Sw Info    ${serial_number}
    coam.assert_alarm_active
    ...    parameters=faultId=23,severity=Critical
    ...    timeout=600    connection=${connection_id}
    ${out_rmoder_new}    Get RRU Sw Info    ${serial_number}
    Run Keyword If
    ...   '${out_rmoder_new["parameters"]["activeSwVersion"]}'=='${rf['BuildVersion']}'
    ...    Run Keywords    sleep    10 mins
    ...    AND  Software Check And Correct
    ...    ELSE       Run Keywords    Log  upgraded RF factory fail  console=yes  AND  Fail

Check RRU Incompatible Alarm With Incompatible SW And Upgrade
    [Arguments]    ${serial_number}    ${sw_release}
    ${connection_id}    Set Variable   ${CASE_NAME}_${MASTER_BTS_ID}
    ${rf}    Set Variable      ${tl_config.RF_INCOMPATIBLE_SW_STORAGE['${serial_number}']}
    ${Target_BuildVersion}    Run Keyword If    '${sw_release}' == 'SBTS00'
    ...    Set Variable    ${rf['BuildVersion_23R1']}
    ...    ELSE    Set Variable    ${rf['BuildVersion_22R4']}
    Wait Until Keyword Succeeds    6 min    3 sec    Check RRU Available Info    ${serial_number}
    sleep    10sec
    ${out_rmoder_info}    Get RRU Sw Info    ${serial_number}
    coam.assert_alarm_active
    ...    parameters=faultId=23,alarmingResource=${out_rmoder_info["distName"]}
    ...    timeout=300    connection=${connection_id}
    ${out_rmoder_new}    Get RRU Sw Info    ${serial_number}
    Run Keyword If
    ...   '${out_rmoder_new["parameters"]["activeSwVersion"]}'=='${Target_BuildVersion}'
    ...    Run Keywords    sleep    10 mins
    ...    AND  Software Check And Correct
    ...    ELSE       Run Keywords    Log  upgraded RF factory fail  console=yes  AND  Fail

Send Ping RRU Command via SSH
    [Arguments]    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
    SSHLibrary.Open Connection    ${host_ip}    timeout=20   alias=ping_rf
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    ${out}    SSHLibrary.Write    ssh toor4nsn@${bbu_ip}
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    ${out}    Run Keyword If    ${stas}    SSHLibrary.Write    oZPS0POrRieRtu    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    >
    Run Keyword If    '${side_info}'=='4'    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${side_info}'=='1'    SSHLibrary.Write    lxc-attach -n 0x1018\n
    Sleep   5s
    ${out}    SSHLibrary.Read Until    >
    ${out}    SSHLibrary.Write    ping ${rru_ip}
    ${out}    Wait Until Keyword Succeeds    600s    1s    SSHLibrary.Read Until    from ${rru_ip}: icmp
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Upload RF Image To FR
    [Arguments]    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}    ${file_path}    ${file_name}
    ...    ${serial_number}
    ${rf}    Set Variable      ${tl_config.RF_FACTORY_SW_STORAGE['${serial_number}']}
    SSHLibrary.Open Connection    ${host_ip}    timeout=30   alias=download_rf_image
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    SSHLibrary.Write    mkdir -p ${SW_BUILDS_DIR_PATH}
    Sleep   20s
    SSHLibrary.Write
    ...    scp -O ${rf['LOGIN']}@${rf['HOST_IP']}:${rf['SW_PATH']}${rf['IMAGE_FILE']} ${SW_BUILDS_DIR_PATH}
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    ${stas}    SSHLibrary.Write    ${rf['PASSWORD']}    ELSE    SSHLibrary.Write    \n
    ${out}    Wait Until Keyword Succeeds    200s    1s    SSHLibrary.Read Until    100%
    SSHLibrary.Write    scp -O ${SW_BUILDS_DIR_PATH}${file_name} toor4nsn@${bbu_ip}:/user/toor4nsn/${file_name}
    ${out}    SSHLibrary.Read    delay=0.5s
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    100%
    ${ret1}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    Password:
    Run Keyword If      '${ret1[0]}'=='PASS'    Run Keywords    SSHLibrary.Write    oZPS0POrRieRtu
    ...     AND     Wait Until Keyword Succeeds    200s    1s    SSHLibrary.Read Until    100%
    ${out}    SSHLibrary.Write    ssh toor4nsn@${bbu_ip}
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    ${out}    Run Keyword If    ${stas}    SSHLibrary.Write    oZPS0POrRieRtu    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    >
    Run Keyword If    '${side_info}'=='4'    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${side_info}'=='1'    SSHLibrary.Write    lxc-attach -n 0x1018\n
    Sleep   5s
    ${out}    SSHLibrary.Read Until    >
#    ${rru_user}=    Set Variable If    '${rru_name}'=='AEHC'    rfsw    root
    ${out_ssh_rsa}     Run Keyword And Return Status      Variable Should Exist     ${SSH_RSA}
    ${out}    Run Keyword If     ${out_ssh_rsa}    SSHLibrary.Write
    ...    scp -O ${SSH_RSA_CMD} /user/toor4nsn/${file_name} ${rf['RRUuser']}@${rru_ip}:${file_path}${file_name}
    ...    ELSE    SSHLibrary.Write    scp -O /user/toor4nsn/${file_name} ${rf['RRUuser']}@${rru_ip}:${file_path}${file_name}
    ${out}    SSHLibrary.Read    delay=0.5s
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    Host key verification failed
    ${ret1}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    yes\/no
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword    Upload RF Image To FR For Hosts
    ...    scp -O /user/toor4nsn/${file_name} ${rf['RRUuser']}@${rru_ip}:${file_path}${file_name}
    ...    ELSE IF    '${ret1[0]}'=='PASS'    SSHLibrary.Write    yes
    ...    ELSE    SSHLibrary.Write    \n
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    ${stas}     SSHLibrary.Write    ${rf['RRUpassword']}
    ...    ELSE    SSHLibrary.Write    \n
    sleep    60s
    ${out}    Run Keyword If     ${out_ssh_rsa}    SSHLibrary.Write    ssh ${SSH_RSA_CMD} ${rf['RRUuser']}@${rru_ip}
    ...    ELSE    SSHLibrary.Write    ssh ${rf['RRUuser']}@${rru_ip}
    ${out}    SSHLibrary.Read    delay=0.5s
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    Host key verification failed
    ${ret1}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    yes\/no
    Run Keyword If    '${ret0[0]}'=='PASS'
    ...    Run Keyword    Upload RF Image To FR For Hosts    ssh ${rf['RRUuser']}@${rru_ip}
    ...    ELSE IF    '${ret1[0]}'=='PASS'    SSHLibrary.Write    yes
    ...    ELSE    SSHLibrary.Write    \n
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    ${stas}     SSHLibrary.Write    ${rf['RRUpassword']}
    ...    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Write    stat ${file_path}${file_name}
    ${out}    SSHLibrary.Read Until    regular file
    SSHLibrary.Close Connection

Upload RF Image To FR For Hosts
    [Arguments]    ${image_command}
    SSHLibrary.Write    rm -rf /user/toor4nsn/.ssh/known_hosts
    SSHLibrary.Write    ${image_command}
    ${ret}    Run Keyword And Return Status    SSHLibrary.Read Until    (yes/no/[fingerprint])?
    ${out}    Run Keyword If    ${ret}    SSHLibrary.Write    yes    ELSE    SSHLibrary.Write    \n

Upgrade RF Image To FR
    [Arguments]    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}    ${file_path}    ${file_name}
    ...    ${serial_number}
    ${rf}    Set Variable      ${tl_config.RF_FACTORY_SW_STORAGE['${serial_number}']}
    SSHLibrary.Open Connection    ${host_ip}    timeout=30   alias=upgrade_rf_image
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    ${out}    SSHLibrary.Write    ssh toor4nsn@${bbu_ip}
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    ${out}    Run Keyword If    ${stas}    SSHLibrary.Write    oZPS0POrRieRtu    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    >
    Run Keyword If    '${side_info}'=='4'    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${side_info}'=='1'    SSHLibrary.Write    lxc-attach -n 0x1018\n
    Sleep   5s
    ${out}    SSHLibrary.Read Until    >
#    ${rru_user}=    Set Variable If    '${rru_name}'=='AEHC'    rfsw    root
#    ${out}    SSHLibrary.Write    ssh ${rf['RRUuser']}@${rru_ip}
    ${out_ssh_rsa}     Run Keyword And Return Status      Variable Should Exist     ${SSH_RSA}
    ${out}    Run Keyword If     ${out_ssh_rsa}    SSHLibrary.Write    ssh ${SSH_RSA_CMD} ${rf['RRUuser']}@${rru_ip}
    ...    ELSE    SSHLibrary.Write    ssh ${rf['RRUuser']}@${rru_ip}
    ${out}    SSHLibrary.Read    delay=0.5s
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    Host key verification failed
    ${ret1}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    yes\/no
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword    Upload RF Image To FR For Hosts
    ...    ssh ${rf['RRUuser']}@${rru_ip}
    ...    ELSE IF    '${ret1[0]}'=='PASS'    SSHLibrary.Write    yes
    ...    ELSE    SSHLibrary.Write    \n
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    ${stas}     SSHLibrary.Write    ${rf['RRUpassword']}
    ...    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Write
    ...    SWmanShellCommand -s ${file_path}${file_name} ${rf['checksum']} ${rf['fileVersion']} ""
    ${out}    Wait Until Keyword Succeeds    900s    1s    SSHLibrary.Read Until Regexp    (?s).*status:\\s+OK.*
    ${out}    SSHLibrary.Write
    ...    SWmanShellCommand -a ${rf['BuildName']} ${rf['BuildVersion']} ${file_name} ${rf['fileVersion']}
    ${out}    SSHLibrary.Read Until Regexp    (?s).*status:\\s+OK.*
    SSHLibrary.Close Connection
    sleep    2s

Upgrade LRM RF Image To FR
    [Arguments]    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}    ${file_path}    ${file_name}
    ...    ${serial_number}
    ${rf}    Set Variable      ${tl_config.RF_FACTORY_SW_STORAGE['${serial_number}']}
    SSHLibrary.Open Connection    ${host_ip}    timeout=30   alias=upgrade_rf_image
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    ${out}    SSHLibrary.Write    ssh toor4nsn@${bbu_ip}
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    ${out}    Run Keyword If    ${stas}    SSHLibrary.Write    oZPS0POrRieRtu    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    >
    Run Keyword If    '${side_info}'=='4'    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${side_info}'=='1'    SSHLibrary.Write    lxc-attach -n 0x1018\n
    Sleep   5s
    ${out}    SSHLibrary.Read Until    >
#    ${rru_user}=    Set Variable If    '${rru_name}'=='AEHC'    rfsw    root
    ${out}    SSHLibrary.Write    ssh ${rf['RRUuser']}@${rru_ip}
    ${out}    SSHLibrary.Read    delay=0.5s
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    Host key verification failed
    ${ret1}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    yes\/no
    Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword    Upload RF Image To FR For Hosts
    ...    ssh ${rf['RRUuser']}@${rru_ip}
    ...    ELSE IF    '${ret1[0]}'=='PASS'    SSHLibrary.Write    yes
    ...    ELSE    SSHLibrary.Write    \n
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    ${stas}     SSHLibrary.Write    ${rf['RRUpassword']}
    ...    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Write
    ...    SWmanShellCommand -s ${file_path}${file_name} ${rf['checksum']} ${rf['fileVersion']} ""
    Sleep    900s
    SSHLibrary.Close Connection
    SSHLibrary.Open Connection    ${host_ip}    timeout=30   alias=switch_rf_image
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    ${out}    SSHLibrary.Write    ssh toor4nsn@${bbu_ip}
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    ${out}    Run Keyword If    ${stas}    SSHLibrary.Write    oZPS0POrRieRtu    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    >
    Run Keyword If    '${side_info}'=='4'    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${side_info}'=='1'    SSHLibrary.Write    lxc-attach -n 0x1018\n
    Sleep   5s
    ${out}    SSHLibrary.Read Until    >
#    ${rru_user}=    Set Variable If    '${rru_name}'=='AEHC'    rfsw    root
    ${out}    SSHLibrary.Write    ssh ${rf['RRUuser']}@${rru_ip}
    ${out}    SSHLibrary.Read    delay=0.5s
    ${ret0}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    Host key verification failed
    ${ret1}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    yes\/no
   Run Keyword If    '${ret0[0]}'=='PASS'    Run Keyword    Upload RF Image To FR For Hosts
    ...    ssh ${rf['RRUuser']}@${rru_ip}
    ...    ELSE IF    '${ret1[0]}'=='PASS'    SSHLibrary.Write    yes
    ...    ELSE    SSHLibrary.Write    \n
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    ${stas}     SSHLibrary.Write    ${rf['RRUpassword']}
    ...    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Write
    ...    SWmanShellCommand -a ${rf['BuildName']} ${rf['BuildVersion']} ${file_name} ${rf['fileVersion']}
    ${out}    SSHLibrary.Read Until Regexp    (?s).*status:\\s+OK.*
    SSHLibrary.Close Connection
    sleep    2s

Upgrade SRM RF Image To FR
    [Arguments]    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}    ${file_path}    ${file_name}
    ...    ${serial_number}
    ${rf}    Set Variable      ${tl_config.RF_FACTORY_SW_STORAGE['${serial_number}']}
    SSHLibrary.Open Connection    ${host_ip}    timeout=30   alias=upgrade_rf_image
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    ${out}    SSHLibrary.Write    ssh toor4nsn@${bbu_ip}
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    ${out}    Run Keyword If    ${stas}    SSHLibrary.Write    oZPS0POrRieRtu    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    >
    Run Keyword If    '${side_info}'=='4'    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${side_info}'=='1'    SSHLibrary.Write    lxc-attach -n 0x1018\n
    Sleep   5s
    ${out}    SSHLibrary.Read Until    >
    ${out}    SSHLibrary.Write    ssh -o serveraliveinterval=180 ${rf['RRUuser']}@${rru_ip}
    ${out}    SSHLibrary.Read    delay=0.5s
    ${ret1}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    yes\/no
    Run Keyword If    '${ret1[0]}'=='PASS'    SSHLibrary.Write    yes
    ...    ELSE    SSHLibrary.Write    \n
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    ${stas}     SSHLibrary.Write    ${rf['RRUpassword']}    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read    delay=0.5s
    ${out}    SSHLibrary.Write    su root
    ${out}    SSHLibrary.Read    delay=0.5s
    #${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    #${out}    Run Keyword If    ${stas}     SSHLibrary.Write    ${tl_config.RF_FACTORY_SW_STORAGE['rootpassword']}
    ${out}    SSHLibrary.Write    ${rf['rootpassword']}
    ${out}    SSHLibrary.Read    delay=0.5s
    ${out}    SSHLibrary.Write    su rfsw
    ${out}    SSHLibrary.Read    delay=0.5s
    ${out}    SSHLibrary.Write
    ...    SWmanShellCommand -s ${file_path}${file_name} ${rf['fileVersion']} "${rf['BuildVersion']}" "jekins"
    ${out}    SSHLibrary.Read    delay=0.5s
    Sleep    1500s
    ${out}    SSHLibrary.Read    delay=0.5s
    SSHLibrary.Close Connection
    SSHLibrary.Open Connection    ${host_ip}    timeout=30   alias=switch_rf_image
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    Sleep    5s
    ${out}    SSHLibrary.Write    ssh toor4nsn@${bbu_ip}
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    ${out}    Run Keyword If    ${stas}    SSHLibrary.Write    oZPS0POrRieRtu    ELSE    SSHLibrary.Write    \n
    Sleep    5s
    ${out}    SSHLibrary.Read Until    >
    Run Keyword If    '${side_info}'=='4'    SSHLibrary.Write    lxc-attach -n 0x2018\n
    Run Keyword If    '${side_info}'=='1'    SSHLibrary.Write    lxc-attach -n 0x1018\n
    Sleep   5s
    ${out}    SSHLibrary.Read Until    >
    ${out}    SSHLibrary.Write    ssh ${rf['RRUuser']}@${rru_ip}
    ${out}    SSHLibrary.Read    delay=0.5s
    ${ret1}    Run Keyword And Ignore Error    Should Match Regexp    ${out}    yes\/no
    Run Keyword If    '${ret1[0]}'=='PASS'    SSHLibrary.Write    yes
    ...    ELSE    SSHLibrary.Write    \n
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    password:
    ${out}    Run Keyword If    ${stas}     SSHLibrary.Write    ${rf['RRUpassword']}    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read    delay=0.5s
    ${out}    SSHLibrary.Write    su root
    ${out}    SSHLibrary.Read    delay=0.5s
    #${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    #${out}    Run Keyword If    ${stas}     SSHLibrary.Write    ${tl_config.RF_FACTORY_SW_STORAGE['rootpassword']}
    ${out}    SSHLibrary.Write    ${rf['rootpassword']}
    ${out}    SSHLibrary.Read    delay=0.5s
    ${out}    SSHLibrary.Write    su rfsw
    ${out}    SSHLibrary.Read    delay=0.5s
    ${out}    SSHLibrary.Write
    ...     SWmanShellCommand -a "${file_name}" "${rf['BuildName']}" "${file_name}" "${rf['BuildVersion']}"
    ${out}    SSHLibrary.Read    delay=1s
    #${out}    SSHLibrary.Read Until Regexp    (?s).*status:\\s+OK.*
    SSHLibrary.Close Connection
    sleep    2s

Get EAC Alarm Info
    [Arguments]    ${bts_id}
    ${require_objects_list}    coam.Get Managed Objects    class_name=EAC_IN_A   connection=${CASE_NAME}_${bts_id}
    ${require_parameters}    coam.get_parameters    dist_name=${require_objects_list[0]["distName"]}    inUse=True
    ...  connection=${CASE_NAME}_${bts_id}
    #Should be equal as strings  ${require_parameters["stateInfo"]["testingState"]}  Enabled
    [Return]    ${require_objects_list}

BS FV EAC Alarm Input on RFM
    [Arguments]    ${eac_ip}    ${alarmline_list}    ${bts_id}
    FOR    ${alarm_list}    IN    @{alarmline_list}
        ${faultid}    Evaluate    1399+${alarm_list["parameters"]["portId"]}
        ${alarmline}    Set Variable    ${EAC_info["WAN"]}${alarm_list["parameters"]["portId"]}
        SSHLibrary.Open Connection    ${eac_ip}    timeout=10    alias=eac_alarm
        SSHLibrary.Login    pi    pi
        ${out}    SSHLibrary.Write    eac ${alarmline} c
        ${out}    SSHLibrary.Read Until    CLOSED
        SSHLibrary.Close Connection
        coam.assert_alarm_active    parameters=faultId=${faultid}    timeout=120    connection=${CASE_NAME}_${bts_id}
        SSHLibrary.Open Connection    ${eac_ip}    timeout=10    alias=eac_alarm
        SSHLibrary.Login    pi    pi
        ${out}    SSHLibrary.Write    eac ${alarmline} o
        ${out}    SSHLibrary.Read Until    OPEN
        coam.assert_alarm_inactive    parameters=faultId=${faultid}    timeout=120    connection=${CASE_NAME}_${bts_id}
    END
    [Teardown]    SSHLibrary.Close Connection

Get RRU Connected BtsId
    [Arguments]    ${sn}
    ${btsIdList}    Create List
    ${btsIds}    Get Dictionary Keys    ${NODE_CFG}
    FOR    ${btsId}    IN    @{btsIds}
        ${status}    ${btsIds}    Run Keyword And Ignore Error
        ...    List Should Contain Value    ${NODE_CFG['${btsId}']['fr_sn_list']}    ${sn}
        Run Keyword If    '${status}'=='PASS'    Append To List    ${btsIdList}    ${btsId}
        ${status}    ${btsIds}    Run Keyword And Ignore Error
        ...    List Should Contain Value    ${NODE_CFG['${btsId}']['bbmod_sn_list']}    ${sn}
        Run Keyword If    '${status}'=='PASS'    Append To List    ${btsIdList}    ${btsId}
        ${status}    ${btsIds}    Run Keyword And Ignore Error
        ...    List Should Contain Value    ${NODE_CFG['${btsId}']['sm_sn_list']}    ${sn}
        Run Keyword If    '${status}'=='PASS'    Append To List    ${btsIdList}    ${btsId}
    END
    [Return]    ${btsIdList}


Run RF Diagnostic Test
    [Arguments]    ${cell_id}    ${cellType}    ${alias}=default
    coam.start_rf_diagnostic_test    True    ${cell_id}    ${cellType}    8    -8    3    -110    -30
    ...    alias=${alias}

Get And Check RF Diagnostic Test Result
    [Arguments]    ${cell_list}=${ALL_CELL_LIST}    ${alias}=default
    ${test_result}=    coam.save_rf_diagnostic_test_results    alias=${alias}
    log many   ${test_result}
    FOR    ${cell_info}    IN    @{cell_list}
        ${t_info}    get_cell_rf_diagnostic_test_result    ${cell_info["cellId"]}    ${test_result}
        Run Keyword If    "${cell_info["NetworkType"]}"=="4G"    Check RF Diagnostic Test Result 4G    ${t_info["results"]}
        ...    ELSE    Check RF Diagnostic Test Result 5G    ${t_info["results"]}
    END


Get And Check RF Diagnostic Test Result 5G
    [Arguments]    ${alias}=default
    ${test_result}=    coam.save_rf_diagnostic_test_results    alias=${alias}
    log many   ${test_result}
    ${out_len}    get length    ${test_result}
    Run Keyword If    '${out_len}' == '0'    Fail
    ${out_test_info}    Set Variable    ${test_result[0]}
    ${t_info}    Set Variable    ${out_test_info["results"]}
    FOR    ${index}    IN RANGE   1   ${out_len}
        ${test_info}    Set Variable    ${test_result[${index}]}
        log many    ${test_info}
        log many    ${test_info["results"]}
        ${t_result}    Set Variable    ${test_info["results"]}
        log many    ${t_result["actualStartTime"]}
        ${out_cmp_code}    Run Keyword And Ignore Error    Compare Time     ${t_info["actualStartTime"]}
        ...    ${t_result["actualStartTime"]}
        ${t_info}    Set Variable If    ${out_cmp_code}    ${t_result}    ${t_info}
    END
    Check RF Diagnostic Test Result 5G    ${t_info}

Get And Check RF Diagnostic Test Result 4G
    [Arguments]    ${alias}=default
    ${test_result}=    coam.save_rf_diagnostic_test_results    alias=${alias}
    log many   ${test_result}
    ${out_len}    get length    ${test_result}
    Run Keyword If    '${out_len}' == '0'    Fail
    ${out_test_info}    Set Variable    ${test_result[0]}
    ${t_info}    Set Variable    ${out_test_info["results"]}
    FOR    ${index}    IN RANGE   1   ${out_len}
        ${test_info}    Set Variable    ${test_result[${index}]}
        log many    ${test_info}
        log many    ${test_info["results"]}
        ${t_result}    Set Variable    ${test_info["results"]}
        log many    ${t_result["actualStartTime"]}
        ${out_cmp_code}    Run Keyword And Ignore Error    Compare Time     ${t_info["actualStartTime"]}
        ...    ${t_result["actualStartTime"]}
        ${t_info}    Set Variable If    ${out_cmp_code}    ${t_result}    ${t_info}
    END
    Check RF Diagnostic Test Result 4G    ${t_info}

Check RF Diagnostic Test Result 4G
    [Arguments]    ${test_info}
    log many   ${test_info}
    log many   ${test_info["rvrsTestDisp"]}
    log many   ${test_info["testOutcome"]}
    log many   ${test_info["fwdTestDisp"]}
    should_start_with    ${test_info["testOutcome"]}    Pass
    should_start_with    ${test_info["rvrsTestDisp"]}    Pass
    should_start_with    ${test_info["fwdTestDisp"]}    Pass
    log many   ${test_info["rfAntResults"]}
    ${detail_info}     Set Variable    ${test_info["rfAntResults"]}
    ${out_len}    get length    ${detail_info}
    FOR    ${index}    IN RANGE   0   ${out_len}
        ${antld_info}    Set Variable    ${detail_info[${index}]}
        log many    ${antld_info["antlId"]}
        log many    ${antld_info["fwdTTPW"]}
        log many    ${antld_info["fwdTTPdBm"]}
        log many    ${antld_info["fwdETPdBm"]}
        log many    ${antld_info["fwdETPW"]}
        log many    ${antld_info["fwdTPError"]}
        ${out_vswr}  evaluate   float(${antld_info["vswr"]}) >= 1
        ${out_rtwp}  evaluate   float(${antld_info["rtwp"]}) != 0
        Should Be True    ${out_vswr} and ${out_rtwp}
    END

Check RF Diagnostic Test Result 5G
    [Arguments]    ${test_info}
    log many   ${test_info}
    log many   ${test_info["rvrsTestDisp"]}
    log many   ${test_info["testOutcome"]}
    log many   ${test_info["fwdTestDisp"]}
    should_start_with    ${test_info["testOutcome"]}    Pass
    should_start_with    ${test_info["rvrsTestDisp"]}    Pass
    should_start_with    ${test_info["fwdTestDisp"]}    Pass
    log many   ${test_info["fwdETPdBm"]}
    log many   ${test_info["fwdETPW"]}
    log many   ${test_info["rfAntResults"]}
    ${status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${test_info}    rtwp
    Run Keyword If    ${status}    should be true  float(${test_info["rtwp"]}) != 0
    ${detail_info}     Set Variable    ${test_info["rfAntResults"]}
    ${out_len}    get length    ${detail_info}
    FOR    ${index}    IN RANGE   0   ${out_len}
        ${antld_info}    Set Variable    ${detail_info[${index}]}
        log many    ${antld_info["antlId"]}
        log many    ${antld_info["rssi"]}
        log many    ${antld_info["sinr"]}
        log many    ${antld_info["rModId"]}
        log many    ${antld_info["vswr"]}
        Run Keyword If    not ${status}    should be true  float(${antld_info["rtwp"]}) != 0
    END

SAS For AEQM
    ute_fsmaccess.Setup Enb Fsm Access
    ute_fsmaccess.Put Enb File    ${GLO_SAS_FILE_PATH}/nokia04.cert    /rom/etc/sas/cbrsVendorCertChain.pem
    ute_fsmaccess.Put Enb File    ${GLO_SAS_FILE_PATH}/nokia04.key    /rom/etc/sas/cbrsPrivKey.pem.crk
    ute_fsmaccess.Put Enb File    ${GLO_SAS_FILE_PATH}/ca.cert    /rom/etc/sas/cbrsRootCACertificate.pem
    ute_fsmaccess.Teardown Enb Fsm Access
    SSHLibrary.Open Connection    ${BTS_HOST}    timeout=10
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${out}    SSHLibrary.Write    cd /rom/etc/sas
    ${out}    SSHLibrary.Write    openssl x509 -noout -hash -in cbrsRootCACertificate.pem
    ${out}    SSHLibrary.Read Until    dcaaf7f0
    ${out}    SSHLibrary.Write    ln -s /rom/etc/sas/cbrsRootCACertificate.pem /rom/etc/sas/dcaaf7f0
    ${out}    SSHLibrary.Write    chown btssw:btssw /rom/etc/sas/ -R
    sleep    2s
#    ${out}    SSHLibrary.Write    reboot
    SSHLibrary.Close Connection
    coam.Setup admin    bts_host=${BTS_HOST}    bts_port=443    use_ssl=True    alias=resetrru
    coam.reset_site    timeout=600    connection=resetrru
    coam.teardown admin    alias=resetrru
#    ${init_sm}=            Get Dictionary Keys    ${BTS_CONFIG['FSM']}
#    Pdu Turn Off All Devices From Serial Number List    ${init_sm}    ${BTS_CONFIG}    FSM
#    Pdu Turn On All Devices From Serial Number List    ${init_sm}    ${BTS_CONFIG}    FSM

Antenna Calibration Check Without Unexpected Ports
    [Documentation]    Author:        haoyun-lyle.sheng@nokia-sbell.com
    ...                Maintainer:    haoyun-lyle.sheng@nokia-sbell.com
    [Arguments]    ${unexpected_ports}
    ...    ${calibration_path}=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1/resources/tools/
    ...    ${log_name}=check_syslog_calibration.log
    ...    ${command}=${calibration_path}calibrationLogAnalyzer.py --log ${SUITE_LOGS_DIR_PATH}/${log_name} --bw 20M
    ...    ${commadn_install}=${calibration_path}lib_install.py
    run and return rc and output    python ${commadn_install}
    sleep    15 mins
    ute_syslog.Start syslog    log_dir=${SUITE_LOGS_DIR_PATH}    log_name=check_syslog_calibration.log
    ...    ip=192.168.255.126    alias=cb_check
    sleep    5 mins
    ute_syslog.Collect Syslog Results    unzip=true    alias=cb_check
    ${rc}    ${output}    run and return rc and output    python ${command}
    Log    ${output}
    ${ret}    get_syslog_result_without_unexpected_port    ${output}    ${unexpected_ports}
    ${ret}    Convert To String    ${ret}
    should contain    ${ret}    Ok
    should not contain    ${ret}    NOk

Get And Check Reset Counter For All BTS Node
    [Arguments]    ${correct_reset_counter}=-1    ${required_bts_id}=${EMPTY}
    ${required_bts_list}    Split String    ${required_bts_id}    :
    ${bts_id_list}    Set Variable If    "${required_bts_id}"=="${EMPTY}"    ${ALL_BTS_ID_LIST}    ${required_bts_list}
    FOR   ${bts_id}    IN    @{bts_id_list}
         ${contain_reset_counter}    Run Keyword And Return Status
         ...    Dictionary Should Contain Key     ${NODE_CFG['${bts_id}']}     reset_info

         ${previous_reset_info}     Set Variable if     ${contain_reset_counter}
         ...     ${NODE_CFG['${bts_id}'].reset_info}     ${Empty}
         ${reset_info}   Get Reset Counter With FSM     remote_host=${NODE_CFG['${bts_id}'].host_ip}
         #${current_counter}     Evaluate    int(${counter})
         Set To Dictionary     ${NODE_CFG['${bts_id}']}     reset_info    ${reset_info}
         Continue For Loop If    not ${contain_reset_counter} or '${correct_reset_counter}'=='-1'
         ${reset_counter}    Compare Reset Counter Info    ${previous_reset_info}     ${reset_info}

         ${check_flag}     Evaluate     int(${correct_reset_counter})==int(${reset_counter})
         Should Be True    ${check_flag}
    END

Get Reset Counter With FSM
    [Arguments]    ${remote_host}
    IF    "${remote_host}" != "None"
        csn.connect to    ${remote_host}    ute    ute    port=22    alias=remote_host
        csn.connect to    ${BTS_HOST}    toor4nsn    oZPS0POrRieRtu    port=22    proxy=remote_host    timeout=60
        ...    alias=bts
    ELSE
        csn.connect to    ${BTS_HOST}    toor4nsn    oZPS0POrRieRtu    port=22    timeout=60    alias=bts
    END
    ${file_content}     csn.execute
    ...      cat /ffs/run/config/lifedata/blackbox|| cat /ffs/run/logs/lifetimedata/blackbox_reset
    ...      connection=bts

    ${reset_info}=    Get Reset Counter Info    ${file_content}

    [Teardown]    Run Keywords    Run Keyword If    "${remote_host}" != "None"    Run Keyword And Ignore Error
    ...    csn.disconnect    connection=remote_host
    ...    AND    csn.disconnect    connection=bts
    [Return]    ${reset_info}

Multi Parameters Recommission And Check BTS Reset
    [Arguments]    ${para_list}    ${object_list}=${EMPTY}    ${bts_id}=${MASTER_BTS_ID}    ${require_reset}=ignore
    ...    ${required_bts_id}=${EMPTY}
    [Documentation]    Author:        haoyun-lyle.sheng@nokia-sbell.com; xingxin.lou@nokia-sbell.com
    ...                Maintainer:    haoyun-lyle.sheng@nokia-sbell.com; xingxin.lou@nokia-sbell.com
    ${is_para_exist}    Run Keyword And Return Status    Should Not Be Empty    ${para_list}
    Return From Keyword If    "${is_para_exist}"=="False"
    ute_admin_infomodel.setup_infomodel    address=${BTS_HOST}    alias=rat_reset
    ${is_list}    Evaluate    isinstance(${para_list}, list)
    ${para_list}    Run Keyword If    ${is_list}    Set Variable    ${para_list}    ELSE    Create List    ${para_list}
    FOR    ${para}    IN    @{para_list}
        ${related_para_exist}    Run Keyword And Return Status    Should Not Be Empty    ${para["related_paras"]}
        ${para_list}    Run Keyword If    ${related_para_exist}
        ...    Combine Lists    ${para_list}    ${para["related_paras"]}
        ...    ELSE    Set Variable    ${para_list}
    END
    ${host_ip}    Get Scfc localIpAddr    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
    Selenium Login    url=https://${host_ip}    version=${NODE_CFG["${bts_id}"]["software_release"]}    alias=${bts_id}
    ${is_obj_exist}    Run Keyword And Return Status    Should Not Be Empty    ${object_list}
    Run Keyword If    "${is_obj_exist}"=="True"    Selenium Multi Objects Operate    ${object_list}
    ...    alias=${bts_id}
    Selenium Multi Parameters Recommission    ${para_list}    alias=${bts_id}
    Selenium Active Plan    alias=${bts_id}
    Wait Until Keyword Succeeds   5x   10s
    ...    Selenium Check Multi Parameters Value    ${para_list}    alias=${bts_id}
    ${reset_check}    Set Variable If    "${require_reset}"=="True" or "${require_reset}"=="site_reset"    ${1}    ${0}
    Run Keyword If    "${require_reset}"!="ignore"    Get And Check Reset Counter For All BTS Node
    ...    correct_reset_counter=${reset_check}    required_bts_id=${required_bts_id}
    FOR    ${para}    IN    @{para_list}
        ${dist}    Split String    ${para["dist_name"]}    /
        ${lenth}	Evaluate	len(${dist})
        ${tec}    Run Keyword If    ${lenth}>1    Split String    ${dist[1]}    -
        Run Keyword And Ignore Error    Exit For Loop If    "${para["require_reset"]}"=="rat_reset"
    END
    ${dist_tec}    Set Variable If    "${tec}"=="None"    NRBTS    ${tec[0]}
    ute_admin_infomodel.save_infomodel_log    filename=${SUITE_LOGS_DIR_PATH}/${CASE_NAME}_infomodel.ims2
    ...    alias=rat_reset
    ${change_sets}    ute_admin_infomodel.get_change_sets   filename=${SUITE_LOGS_DIR_PATH}/${CASE_NAME}_infomodel.ims2
    ...    event=/MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/${dist_tec}_R-*/RAT_RESET_PROCEDURE_R-*    alias=rat_reset
    Run Keyword If    "${require_reset}"=="rat_reset"    Should Not Be Empty      ${change_sets}
    [Teardown]    Run Keywords    ute_admin_infomodel.teardown_infomodel    alias=rat_reset   AND
    ...    Selenium Logout    alias=${bts_id}

Get MRBTSID and NRBTSID or LNBTSID
    [Arguments]    ${networktype}    ${scfc_file_path}
    ${out_dist_name}=    Run Keyword If    "${networktype}"=="4G"
    ...    Evaluate Xpath    ${scfc_file_path}    string(.//managedObject[@class='NOKLTE:LNBTS']/@distName)
    ...    ELSE    Evaluate Xpath    ${scfc_file_path}    string(.//managedObject[@class='com.nokia.srbts.nrbts:NRBTS']/@distName)
    ${ret}    Should Match Regexp    ${out_dist_name}    MRBTS-(\\d+)/(NRBTS|LNBTS)-(\\d+)
    Set Test Variable    ${MRBTS_ID}    ${ret[1]}
    Run Keyword If    "${networktype}"=="4G"    Set Test Variable    ${LNBTS_ID}    ${ret[3]}
    ...    ELSE    Set Test Variable    ${NRBTS_ID}    ${ret[3]}

Get Scfc localIpAddr
    [Arguments]    ${scf_file_path}
    ${mPlaneIpv4AddressDN}    Get Element Text    ${scf_file_path}
    ...    .//managedObject[@class='com.nokia.srbts.mnl:MPLANENW']/p[@name="mPlaneIpv4AddressDN"]
    ${localIpAddr}=    Evaluate Xpath    ${scf_file_path}
    ...     .//managedObject[@class="com.nokia.srbts.tnl:IPADDRESSV4" and @distName="${mPlaneIpv4AddressDN}"]/p[@name="localIpAddr"]/text()
    [Return]    ${localIpAddr[0]}

Match Cali RX Info
    [Arguments]    ${cali_info}    ${out_frequency}    ${out_elements}
    ${out_frequency}=    Convert To Number    ${out_frequency}
#    ${out_frequency}=    Evaluate    ${out_frequency}*0.1
    ${out_frequency}=    Convert To String    ${out_frequency}
    FOR    ${info}    IN    @{cali_info}
        ${ret}=    Run Keyword And Ignore Error    Should Match Regexp    ${info}
        ...    (?s).*Carrier name:.*RX_.*Carrier frequency: ${out_frequency}.*${out_elements}
        Exit For Loop If    "${ret[0]}"=="PASS"
    END
    [Return]    ${ret[0]}

Match Cali TX Info
    [Arguments]    ${cali_info}    ${out_frequency}    ${out_elements}
    ${out_frequency}=    Convert To Number    ${out_frequency}
#    ${out_frequency}=    Evaluate    ${out_frequency}*0.1
    ${out_frequency}=    Convert To String    ${out_frequency}
    FOR    ${info}    IN    @{cali_info}
        ${ret}=    Run Keyword And Ignore Error    Should Match Regexp    ${info}
        ...    (?s).*Carrier name:.*TX_.*Carrier frequency: ${out_frequency}.*${out_elements}
        Exit For Loop If    "${ret[0]}"=="PASS"
    END
    [Return]    ${ret[0]}

Lock Cell
    [Arguments]    ${cell_list}    ${alias}=defult
    FOR    ${cell_info}    IN    @{cell_list}
        ${status}   Set Variable If  "${cell_info["NetworkType"]}"=="SA"  Locked
        ...    "${cell_info["NetworkType"]}"=="NSA"  Locked
        ...    "${cell_info["NetworkType"]}"=="4G"  locked
        selenium_coam.set_parameter_value    dist_name=${cell_info["distName"]}    filter_param=Administrative state
        ...    new_value=${status}    sbts=${alias}
    END
    sleep    10s
    selenium_coam.validate_plan    sbts=${alias}
    sleep    10s
    selenium_coam.activate_plan    activate_plan_despite_errors=True    sbts=${alias}
    FOR    ${cell_info}    IN    @{cell_list}
        ${status}   Set Variable If  "${cell_info["NetworkType"]}"=="SA"  Locked
        ...    "${cell_info["NetworkType"]}"=="NSA"  Locked
        ...    "${cell_info["NetworkType"]}"=="4G"  locked
        ${out_value}    selenium_coam.get_parameter_value    dist_name=${cell_info["distName"]}
        ...    filter_param=Administrative state    sbts=${alias}
        Should Be Equal    ${status}    ${out_value}
    END

Unlock Cell
    [Arguments]    ${cell_list}    ${alias}=defult
    FOR    ${cell_info}    IN    @{cell_list}
        ${status}   Set Variable If  "${cell_info["NetworkType"]}"=="SA"  Unlocked
        ...    "${cell_info["NetworkType"]}"=="NSA"  Unlocked
        ...    "${cell_info["NetworkType"]}"=="4G"  unlocked
        selenium_coam.set_parameter_value    dist_name=${cell_info["distName"]}    filter_param=Administrative state
        ...    new_value=${status}    sbts=${alias}
    END
    sleep    10s
    selenium_coam.validate_plan    sbts=${alias}
    sleep    10s
    selenium_coam.activate_plan    activate_plan_despite_errors=True    sbts=${alias}
    FOR    ${cell_info}    IN    @{cell_list}
        ${status}   Set Variable If  "${cell_info["NetworkType"]}"=="SA"  Unlocked
        ...    "${cell_info["NetworkType"]}"=="NSA"  Unlocked
        ...    "${cell_info["NetworkType"]}"=="4G"  unlocked
        ${out_value}    selenium_coam.get_parameter_value    dist_name=${cell_info["distName"]}
        ...    filter_param=Administrative state    sbts=${alias}
        Should Be Equal    ${status}    ${out_value}
    END

Calculate KPIs
    [Arguments]    ${kpi_names}    ${connection}
    coam.collect_infomodel_log_from_current_session
    ...    target_file_name=${TEST_LOGS_DIR_PATH}/${connection}_kpi_infomodel.ims
    ...    connection=${connection}
    ${results}    oam_kpi.calculate_kpis    ${kpi_names}    ${TEST_LOGS_DIR_PATH}/${connection}_kpi_infomodel.ims
    [Return]    ${results}
    [Teardown]    oam_kpi.clear_results

Calculate Ru Reset KPI
    ${kpi_names}    Create List    KPI51a    KPI51b
    ${kpi_dictionary}    Create Dictionary
    FOR    ${bts_id}    IN    @{BTS_LIST}
        ${connection}    Set Variable    ${CASE_NAME}_${bts_id}
        ${results}    Calculate KPIs    ${kpi_names}    ${connection}
        Set Delta Time To Seconds    ${results}    ${kpi_dictionary}
    END
    [Return]    ${kpi_dictionary}

Calculate BBMOD Reset KPI
    [Arguments]    ${bts_id}    ${num}
    ${kpi5_dic}    Create Dictionary
    coam.collect_infomodel_log_from_current_session    target_file_name=${TEST_LOGS_DIR_PATH}/kpi_${bts_id}_${num}.ims
    ...    connection=${CASE_NAME}_${bts_id}
    ${kpi5_result}    oam_kpi.calculate_kpi5    ims_file_path=${TEST_LOGS_DIR_PATH}/kpi_${bts_id}_${num}.ims
    Set To Dictionary    ${kpi5_dic}    ${bts_id}=${kpi5_result['kpi5'][0]['delta']}
    set suite variable    ${kpi5_dic}
    [Return]    ${kpi5_dic}

Calibration Port Switch Time Window Setup
    [Arguments]    ${start_utc}    ${end_utc}    ${bts_id}
    ${connection_id}   Set Variable    ${CASE_NAME}_${bts_id}
    ${dist_name}    Set Variable    MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1/FEATLADM-1
    ${switch_start}=    DateTime.Get Current Date    UTC    ${start_utc}
    ${switch_end}=    DateTime.Get Current Date    UTC    ${end_utc}
    ${para_dict1}    Create Dictionary    distName=${dist_name}    paraName=calibrationPortSwitchStart
    ...    paraValue=${switch_start[11:16]}
    ${para_dict2}    Create Dictionary    distName=${dist_name}    paraName=calibrationPortSwitchEnd
    ...    paraValue=${switch_end[11:16]}
    ${para_list}    Create List    ${para_dict1}    ${para_dict2}
    Online Change Multi Parameters    ${para_list}    ${connection_id}

Restart RF And Check the Soap Msg
    [Arguments]    ${fr_serial_number}
    ${bts_id}    Get Master BTS Id With RF serial Number     serial_num=${fr_serial_number}
    ${connection_id}   Set Variable    ${CASE_NAME}_${bts_id}
    Power Off Radio    ${fr_serial_number}
    Sleep    30 sec
    PDU Turn On Unit    pdu_type=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['port']}
    Radio Should Be On    fr_serial_number=${fr_serial_number}    bts_id=${bts_id}
    ${ru_info}    Get RRU Info    serial_num=${fr_serial_number}
    #${release}    Set Variable     22R4
    ${active_sw_version}=      coam.get_sw_release_name    connection=${connection_id}
    ${active_sw_version}    get_substring   ${active_sw_version}    4
    Set Test Variable    ${active_sw_version}
    Check Rf Config    ru_info=${ru_info}

Get Cross RF Serial Num List
    [Arguments]    ${cell_list}=${ALL_CELL_LIST}
    ${cross_ru_list}    Create List
    FOR    ${cell_info}    IN    @{cell_list}
        ${rf_list}    Set Variable    ${cell_info["RF"]}
        ${cells_fr_num}    Get Length    ${rf_list}
        Run Keyword If    ${cells_fr_num} > ${1}    Append To List    ${cross_ru_list}    @{rf_list}
    END
    ${cross_ru_sn_list}    Create List
    FOR    ${ru_info}     IN    @{cross_ru_list}
        Append To List    ${cross_ru_sn_list}    ${ru_info["serialNumber"]}
    END
    ${cross_ru_sn_list}    Remove Duplicates    ${cross_ru_sn_list}
    [Return]    ${cross_ru_sn_list}

BTS Startup With Delayed RF Link
    [Arguments]    ${bts_id}
    [Documentation]    Author:        haoyun-lyle.sheng@nokia-sbell.com
    ...                Maintainer:    haoyun-lyle.sheng@nokia-sbell.com
    ${bts_cfg}    Set Variable    ${NODE_CFG['${bts_id}']}
    ${bbmod_sn_list}    Set Variable    ${bts_cfg['bbmod_sn_list']}
    ${fr_sn_list}    Set Variable    ${bts_cfg['fr_sn_list']}
    ${connection_id}    Set Variable    ${CASE_NAME}_${bts_id}
    PDU Turn Off All Devices From Serial Number List    ${bbmod_sn_list}    ${BTS_CONFIG}    FSM
    PDU Turn Off All Devices From Serial Number List    ${fr_sn_list}    ${BTS_CONFIG}    FR
    Sleep    5s
    PDU Turn On All Devices From Serial Number List    ${bbmod_sn_list}    ${BTS_CONFIG}    FSM
    Sleep    30s
    FOR    ${fr_serial_number}    IN    @{fr_sn_list}
        Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_active
        ...    parameters=faultId=10,serialNo=${fr_serial_number}    timeout=5    connection=${connection_id}
    END
	Sleep    30s
    PDU Turn On All Devices From Serial Number List    ${fr_sn_list}    ${BTS_CONFIG}    FR
    FOR    ${fr_serial_number}    IN    @{fr_sn_list}
        Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_inactive
        ...    parameters=faultId=10,serialNo=${fr_serial_number}    timeout=5    connection=${connection_id}
    END

Delta Commissioning Kpi For Multi BTS
    [Arguments]    ${para_list}
    [Documentation]    Author:        haoyun-lyle.sheng@nokia-sbell.com
    ...                Maintainer:    haoyun-lyle.sheng@nokia-sbell.com
    ${status}    Run Keyword And Return Status    Should Not Be Empty    ${para_list}
    Return From Keyword If    '${status}'=='False'
    ${reset_counter_dict}    Create Dictionary
    ${rat_tec_dict}    Create Dictionary
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        coam.Create delta    ${bts_id}
        Set To Dictionary    ${reset_counter_dict}    ${bts_id}=${0}
        Set To Dictionary    ${rat_tec_dict}    ${bts_id}=NRBTS
        ute_admin_infomodel.setup_infomodel    address=${BTS_HOST}    remote_host=${NODE_CFG['${bts_id}']['host_ip']}
        ...    alias=rat_reset_${bts_id}
    END
    FOR    ${para}     IN    @{para_list}
        coam.Append parameter update to delta    ${para['dist_name']}    ${para['para_name']}
        ...    ${para['para_value']}    delta_id=${para['bts_id']}
        Run Keyword If    '${para['reset_tag']}'=='site_reset'
        ...    Set To Dictionary    ${reset_counter_dict}    ${para['bts_id']}=${1}
        ${dist_name_split}    Split String    ${para["dist_name"]}    /
        ${rat_type}    Split String    ${dist_name_split[1]}    -
        ${contain_bts}    Run Keyword And Return Status    Should Contain    ${rat_type[0]}    BTS
        Run Keyword If    '${para['reset_tag']}'=='rat_reset' and ${contain_bts}
        ...    Set To Dictionary    ${rat_tec_dict}    ${para['bts_id']}=${rat_type[0]}
        ${is_rat_reset}    Set Variable If    '${para['reset_tag']}'=='rat_reset'    True    False
    END
    ${test_bts_id}    Create List
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        ${delta_update}    coam.Get delta    delta_id=${bts_id}
        ${is_empty}    Run Keyword And Return Status    Should Be Empty    ${delta_update}
        Continue For Loop If    '${is_empty}'=='True'
        coam.Perform delta recommissioning    ${delta_update}     timeout=900    should_activate=${TRUE}
        ...    alias=${CASE_NAME}_${bts_id}
        Append To List    ${test_bts_id}    ${bts_id}
    END
    Wait For All Cells OnAir    ${ONAIR_TIME}
    FOR    ${bts_id}    IN    @{test_bts_id}
        coam.get_current_scf_file    ${SUITE_LOGS_DIR_PATH}    current_scfc_${bts_id}.xml
        ...    export_type=configurationAndRuntimeObjects    connection=${CASE_NAME}_${bts_id}
        Get And Check Reset Counter For All BTS Node
        ...    correct_reset_counter=${reset_counter_dict['${bts_id}']}   required_bts_id=${bts_id}
        ute_admin_infomodel.save_infomodel_log    filename=${SUITE_LOGS_DIR_PATH}/${CASE_NAME}_${bts_id}_infomodel.ims2
        ...    alias=rat_reset_${bts_id}
        ${dist_rat}    Set Variable    ${rat_tec_dict['${bts_id}']}
        ${change_sets}    ute_admin_infomodel.get_change_sets
        ...    filename=${SUITE_LOGS_DIR_PATH}/${CASE_NAME}_${bts_id}_infomodel.ims2
        ...    event=/MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/${dist_rat}_R-${bts_id}/RAT_RESET_PROCEDURE_R-*
        ...    alias=rat_reset_${bts_id}
        Run Keyword If    ${is_rat_reset}    Should Not Be Empty      ${change_sets}
    END
    FOR    ${para}     IN    @{para_list}
        ${get_value}=    Get Element Text    ${SUITE_LOGS_DIR_PATH}/current_scfc_${para['bts_id']}.xml
        ...    xpath=.//managedObject[@distName='${para['dist_name']}']/p[@name='${para['para_name']}']
        Run Keyword And Continue On Failure    Should Be Equal    ${para['para_value']}    ${get_value}
    END
    [Teardown]    ute_admin_infomodel.teardown_all_aliases_for_infomodel

Get Cells On Specific FR ANTL
    [Arguments]    ${fr_serial_number}    ${antl}
    ${cell_mapping_rf_list}    Create List
    FOR    ${cell}    IN    @{ALL_CELL_LIST}
        ${is_cells_fr}    Check Is Cell's ANTL In FR    ${fr_serial_number}    ${antl}    ${cell["RF"]}
        Continue For Loop If    not ${is_cells_fr}
        Append To List    ${cell_mapping_rf_list}    ${cell}
    END
    [Return]   ${cell_mapping_rf_list}

Verify All Cells OnAir With Abnormal State
    [Arguments]    ${pre_alias}=${CASE_NAME}    ${check_cell_list}=${ALL_CELL_LIST}    ${operational_state}=enabled
    ...    ${blocking_state}=unblocked    ${avail_status}=${EMPTY}
    FOR    ${cell_list}    IN    @{check_cell_list}
        ${bts_id}    Set Variable     ${cell_list["btsId"]}
        ${cell_info}    coam.Get Cell Specific Info    cell_id=${cell_list["distName"]}
        ...    connection=${pre_alias}_${cell_list["btsId"]}
        ${operational_state}    Convert To Lowercase    ${cell_info["status"]["operationalState"]}
        ${blocking_state}    Convert To Lowercase    ${cell_info["status"]["blockingState"]}
        Should Be Equal As Strings    ${operational_state}    ${operational_state}
        Should Be Equal As Strings    ${blocking_state}    ${blocking_state}
        Run Keyword If    "${avail_status}"=="${EMPTY}"
        ...    Variable Should Not Exist    ${cell_info["status"]["availabilityStatus"]}
        ...    ELSE    Should Be Equal As Strings    ${cell_info["status"]["availabilityStatus"]}    ${avail_status}
    END
    FOR    ${distname}    IN    @{2G_3G_DISTNAME_LIST}
        ${bts_id}    Should Match Regexp    ${distname}    (?:MRBTS-)?(\\d+)
        ${cell_info}    coam.Get Cell Specific Info    cell_id=${distname}    connection=${pre_alias}_${bts_id[1]}
        ${operational_state}    Convert To Lowercase    ${cell_info["status"]["operationalState"]}
        ${blocking_state}    Convert To Lowercase    ${cell_info["status"]["blockingState"]}
        Should Be Equal As Strings    ${operational_state}    ${operational_state}
        Should Be Equal As Strings    ${blocking_state}    ${blocking_state}
        Run Keyword If    "${avail_status}"=="${EMPTY}"
        ...    Variable Should Not Exist    ${cell_info["status"]["availabilityStatus"]}
        ...    ELSE    Should Be Equal As Strings    ${cell_info["status"]["availabilityStatus"]}    ${avail_status}
    END

Check_RFSW_logs_In_BTS_Snapshot
    [Arguments]    ${btsId}
    log to console    start to Collect Snapshot
    Logging Save Snapshot    ${TEST_LOGS_DIR_PATH}    alias=${CASE_NAME}_${btsId}
    ${bts_info}    Get From Dictionary    ${NODE_CFG}    ${btsId}
    ${rru_info}    Get From Dictionary    ${bts_info}    rmod_info
    ${rru_sn_list}    Get Dictionary Keys    ${rru_info}
    ${snapshotfile}   get_bts_snapshot_file    ${btsId}    ${TEST_LOGS_DIR_PATH}
    unzipfile    ${snapshotfile}    ${snapshotfile[:-4]}
    FOR    ${sn}    IN    @{rru_sn_list}
        ${snapshot_file_list}    OperatingSystem.Get File    ${snapshotfile[:-4]}/snapshot_file_list.txt
        Should Match Regexp    ${snapshot_file_list}    ${sn}_RMOD_L_\\d+_startup
        Should Match Regexp    ${snapshot_file_list}    ${sn}_RMOD_L_\\d+_runtime
    END

Online Change SubCell to NormalCell
    [Arguments]    ${cell_info}    ${change_channelgroup_id}    ${add_value}=${1}
    ${bts_id}    Set Variable    ${cell_info["btsId"]}
    ${alias}    Set Variable    ${CASE_NAME}_${cell_info["btsId"]}_ui
    ${cell_id_list}    Get Key Values From Json List    cellId    ${ALL_CELL_LIST}
    ${cellgrp_list}    Get Key Values From Json List    nrCellGRP    ${ALL_CELL_LIST}
    ${pci_list}    Get Key Values From Json List    phyCellId    ${ALL_CELL_LIST}
    ${lcr_id_list}    Get Key Values From Json List    lcrId    ${ALL_CELL_LIST}
    ${new_lcrid}    Set Variable    ${lcr_id_list[-1]}
    ${new_phyCellId}    Set Variable    ${pci_list[-1]}
    ${new_cell_id}     Set Variable     ${cell_id_list[-1]}
    ${new_cellgrp_id}    Set Variable    ${cellgrp_list[-1]}
    ${new_cells}    Set Variable
    FOR    ${channel_group_id}    IN    @{change_channelgroup_id}
        ${new_lcrid}    Evaluate    ${new_lcrid}+${add_value}
        ${new_phyCellId}     Evaluate    ${new_phyCellId}+${add_value}
        ${new_cell_id}    Evaluate    ${new_cell_id}+${add_value}
        ${new_cellgrp_id}    Evaluate   ${new_cellgrp_id}+${add_value}
        Normal NRcell Copy From Super cell    ${cell_info["cellId"]}    ${cell_info["nrCellGRP"]}    ${channel_group_id}
        ...    ${new_phyCellId}    ${new_lcrid}    ${new_cellid}    ${new_cellgrp_id}     ${cell_info["btsId"]}    alias=${alias}
        ${new_cells}	Catenate	SEPARATOR=:    ${new_cells}    ${new_phyCellId}
    END
    Delete SubCells In One Cell    ${cell_info["cellId"]}    ${change_channelgroup_id}    ${bts_id}   alias=${alias}
    ${new_cells}    Strip String    ${new_cells}    characters=:
    [Return]    ${new_cells}

Get Loki Number
    [Arguments]    ${fr_sn}    ${bts_id}
    ${connection_id}    Set Variable    ${CASE_NAME}_${bts_id}
    ${rmod_distname}    Get R Object Distname By SN    class_name=RMOD_R    sn=${fr_sn}    connection=${connection_id}
    ${first_point_ID}    Get FirstEndPointId by distName    class_name=CABLINK_R
    ...    distName=${rmod_distname}    connection=${connection_id}
    ${loki_num}    Set Variable If    "${first_point_ID}"<"7"    1    2
    [Return]    ${loki_num}

Get SMOD Product Name
    [Arguments]     ${scf_file_path}
    ${product_name}    Get Element Text   ${scf_file_path}
    ...    xpath=//managedObject[@class='com.nokia.srbts.eqmr:SMOD_R']/p[@name="productName"]
    [Return]    ${product_name}

Get Subcell In One Loki
    [Arguments]    ${bts_id}
    ${first_loki}    Create List
    ${second_loki}    Create List
    FOR    ${fr_sn}    IN    @{NODE_CFG["${bts_id}"]["fr_sn_list"]}
        ${loki_num}    Get Loki Number    ${fr_sn}    ${bts_id}
        Run Keyword If    "${loki_num}"=="1"    Append To List    ${first_loki}    ${fr_sn}
        ...    ELSE IF    "${loki_num}"=="2"    Append To List    ${second_loki}    ${fr_sn}
    END
    [Return]    ${first_loki}    ${second_loki}

Recover Scfc
    [Arguments]    ${bts_id}    ${scf_file}
    coam.Perform Commissioning
    ...    ${bts_id}    ${scf_file}    skip_parameter_relation_errors=False
    ...    should_activate=True    timeout=1200    connection=${CASE_NAME}_${bts_id}
    Wait Until Keyword Succeeds    600    30    Create Node Parameters From Current SCF
    Wait For All Cells Onair    timeout=${ONAIR_TIME}

SuperCell Reconfiguration With Half Subcell Deletion
    [Arguments]    ${cell_list}
#    Get And Check Reset Counter For All BTS Node
    ${bts_id}    Set Variable    ${cell_list[0]["btsId"]}
    ${alias}    Set Variable    ${CASE_NAME}_${bts_id}_ui
    ${scf_file}    Set Variable    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
    ${smod_product_name}    Get SMOD Product Name    ${scf_file}
    ${localIpAddr}    Get Scfc localIpAddr    ${scf_file}
    ${frs_in_first_loki}     ${frs_in_second_loki}    Get Subcell In One Loki    ${bts_id}
    Selenium Login    url=https://${localIpAddr}
    ...    version=${NODE_CFG["${bts_id}"]["software_release"]}    alias=${alias}

    ${all_normal_cells}    Set Variable
    ${value}    Set Variable    ${1}
    FOR    ${cell_info}    IN    @{cell_list}
         ${change_channelgroup_id}    get_change_channelgroup_id    ${cell_info}    ${frs_in_second_loki}    ${smod_product_name}
         ${normal_cells}    Online Change SubCell to NormalCell    ${cell_info}    ${change_channelgroup_id}    add_value=${value}
         ${all_normal_cells}	Catenate	SEPARATOR=:    ${all_normal_cells}    ${normal_cells}
         ${value}    Evaluate    ${value}+1
    END
    ${all_normal_cells}    Strip String    ${all_normal_cells}    characters=:
    ${delete_cell_list}    Copy List    ${cell_list}
    ${left_cell_info}    Remove From List    ${delete_cell_list}    0
    ${left_subcells}     get_change_channelgroup_id    ${left_cell_info}    ${frs_in_first_loki}    ${smod_product_name}
    ${cell_nums}    Get Length    ${delete_cell_list}
    ${extra_subcell_nums}    Evaluate    len(${left_subcells})-3
    Run Keyword If   ${cell_nums} > 0    Cells deletion With Selenium    ${delete_cell_list}
    Run Keyword If    ${extra_subcell_nums} > 0    Delete SubCells In One Cell     ${left_cell_info["cellId"]}
    ...    ${left_subcells[-${extra_subcell_nums}:]}    ${bts_id}   alias=${alias}
    Selenium Active Plan    alias=${alias}
    Get Rquired Cells   ${ALL_CELL_LIST}    ${all_normal_cells}
    ${new_cell_info}    Get Cell Info With PCI    ${ALL_CELL_LIST}    ${left_cell_info["phyCellId"]}
#    Run Keyword And Continue On Failure    Make Tput For One Super Cell    cell_info=${new_cell_info}
#    ...    extra_peak_rate_config=${PEAK_RATE_CONFIG}
#    ${supercell_count}    Get Supercell Count With BtsId    ${bts_id}
#    ${reset_count}    Set Variable If    "${supercell_count}"=="1"    2    0
#    Get And Check Reset Counter For All BTS Node     correct_reset_counter=${reset_count}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Selenium Logout    alias=${alias}
    ...    AND    Recover Scfc    ${bts_id}    ${scf_file}

SuperCell Reconfiguration With Half Subcell Expansion
    [Arguments]    ${cell_info}
#    Get And Check Reset Counter For All BTS Node
    ${bts_id}    Set Variable    ${cell_info["btsId"]}
    ${alias}    Set Variable    ${CASE_NAME}_${bts_id}_ui
    ${scf_file}    Set Variable    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
    ${localIpAddr}    Get Scfc localIpAddr    ${scf_file}
    ${channelgroup_id_list}    Get Dictionary Keys    ${cell_info["channelgroup"]}
    ${subcell_count}    Get Length    ${channelgroup_id_list}
    ${count}    Evaluate    int(${subcell_count}/2)
    ${left_subcell}    Evaluate    ${subcell_count}-${count}
    ${change_channelgroup_id}    Set Variable    ${channelgroup_id_list}[-${count}:]

    Selenium Login    url=https://${localIpAddr}
    ...    version=${NODE_CFG["${bts_id}"]["software_release"]}    alias=${alias}

    Delete SubCells In One Cell    ${cell_info["cellId"]}    ${change_channelgroup_id}    ${bts_id}    alias=${alias}
    Selenium Active Plan    alias=${alias}
#    ${current_scfc}    Get Current Scfc    ${bts_id}
#    ${bbu_list}    ${rmod_list}    ${cell_list}    ${rmod_chain}    btsInfo    ${current_scfc}
    ${new_cell_info}    Get Cell Info With PCI    ${ALL_CELL_LIST}    ${cell_info["phyCellId"]}
    ${actual_subcell}    Evaluate    len(${new_cell_info["channelgroup"]}.keys())
    Should Be Equal As Integers    ${left_subcell}    ${actual_subcell}
    Run Keyword And Continue On Failure    Make Tput For One Super Cell    cell_info=${new_cell_info}
    ...    extra_peak_rate_config=${PEAK_RATE_CONFIG}
    Selenium Refresh Page     alias=${alias}
    Add SubCells In One Cell    ${cell_info["cellId"]}    ${change_channelgroup_id}    ${bts_id}    ${scf_file}    alias=${alias}
    Selenium Active Plan    alias=${alias}
    Run Keyword And Continue On Failure    Make Tput For One Super Cell    cell_info=${cell_info}
    ...    extra_peak_rate_config=${PEAK_RATE_CONFIG}
#    ${supercell_count}    Get Supercell Count With BtsId    ${bts_id}
#    ${reset_count}    Set Variable If    "${supercell_count}"=="1"    2    0
#    Get And Check Reset Counter For All BTS Node     correct_reset_counter=${reset_count}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Selenium Logout    alias=${alias}
    ...    AND   Run Keyword If    "${KEYWORD_STATUS}"=="FAIL"    Recover Scfc    ${bts_id}    ${scf_file}

SuperCell Reconfiguration With Half Subcell Split
    [Arguments]    ${copy_cell_info}
    [Documentation]    Author:        haoyun-lyle.sheng@nokia-sbell.com
    ...                Maintainer:    haoyun-lyle.sheng@nokia-sbell.com
#    Get And Check Reset Counter For All BTS Node
    ${bts_id}    Set Variable    ${copy_cell_info['btsId']}
    ${alias}    Set Variable    supercell_split_${bts_id}
    ${copy_cell_id}    Set Variable    ${copy_cell_info['cellId']}
    ${copy_cellgrp_id}    Set Variable    ${copy_cell_info['nrCellGRP']}
    ${cell_id_list}    Get Key Values From Json List    cellId    ${ALL_CELL_LIST}
    ${cellgrp_list}    Get Key Values From Json List    nrCellGRP    ${ALL_CELL_LIST}
    ${channelgroup_id_list}    Get Dictionary Keys    ${copy_cell_info["channelgroup"]}
    ${subcell_count}    Get Length    ${channelgroup_id_list}
    ${new_cell_id}    Evaluate    ${cell_id_list[-1]}+1
    ${new_cellgrp_id}    Evaluate    ${cellgrp_list[-1]}+1
    ${scf_file}     Set Variable    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
    ${localIpAddr}    Get Scfc localIpAddr    ${scf_file}
    Selenium Login    url=https://${localIpAddr}    version=${NODE_CFG["${bts_id}"]["software_release"]}    alias=${alias}
    Copy Nrcell With Subobject    bts_id=${bts_id}    copy_cell_id=${copy_cell_id}    new_cell_id=${new_cell_id}
    ...    alias=${alias}
    Copy Nrcellgrp With Subobject    bts_id=${bts_id}    copy_cellgrp_id=${copy_cellgrp_id}   new_cellgrp_id=${new_cellgrp_id}
    ...    new_cell_id=${new_cell_id}    alias=${alias}
    Copy Lcelnr With Half Subcell    bts_id=${bts_id}    copy_Lcelnr_id=${copy_cell_id}    copy_chlgrp_count=${subcell_count}
    ...    new_lcelnr_id=${new_cell_id}    alias=${alias}
    Selenium Active Plan    alias=${alias}
#    Wait For All Cells OnAir
#    ${current_scfc}    Get Current Scfc    ${bts_id}
#    ${bbu_list}    ${rmod_list}    ${cell_list}    ${rmod_chain}    Bts Info    ${current_scfc}
    ${new_cell_info}    Get Cell Info With PCI    ${ALL_CELL_LIST}    ${copy_cell_info["phyCellId"]}
    Run Keyword And Continue On Failure    Make Tput For One Super Cell    cell_info=${new_cell_info}
    ...    extra_peak_rate_config=${PEAK_RATE_CONFIG}
#    ${supercell_count}    Get Supercell Count With BtsId    ${bts_id}
#    ${reset_count}    Set Variable If    "${supercell_count}"=="1"    1    0
#    Get And Check Reset Counter For All BTS Node     correct_reset_counter=${reset_count}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Selenium Logout    alias=${alias}
    ...    AND   Recover Scfc    ${bts_id}    ${scf_file}

Get Supercell Count With BtsId
    [Arguments]    ${bts_id}
    ${supercell_count}    Set Variable    ${0}
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        Continue For Loop If    "${cell_info["btsId"]}"!="${bts_id}"
        ${supercell_count}    Run Keyword If    "${cell_info["subCell"]}"!="[]"    Evaluate    ${supercell_count}+1
        ...    ELSE    Evaluate    ${supercell_count}+0
    END
    [Return]    ${supercell_count}

Get Key Values From Json List
    [Arguments]    ${key}    ${json_list}=${ALL_CELL_LIST}
    ${value_list}    Create List
    ${is_num}    Set Variable    ${False}
    FOR    ${json}    IN    @{json_list}
        ${is_num}    Run Keyword And Return Status    Evaluate    int(${json['${key}']})
        ${num_type}    Run Keyword If    ${is_num}    Evaluate    type(${json['${key}']}).__name__
        ${eval_num}    Run Keyword If    ${is_num} and "${num_type}"=="float"    Evaluate   float(${json['${key}']})
        ...   ELSE IF    ${is_num}    Evaluate    int(${json['${key}']})
        ${value}    Set Variable If    ${is_num}    ${eval_num}    ${json['${key}']}
        Append To List    ${value_list}    ${value}
    END
    Run Keyword If    ${is_num}    Sort List    ${value_list}
    [Return]    ${value_list}

Supercell Setup With Compare Number of subcells
    [Arguments]    ${cell_info}
    ${bts_id}    Set Variable    ${cell_info["btsId"]}
    ${alias}    Set Variable    ${CASE_NAME}_${bts_id}_ui
    ${current_scfc}    Get Current Scfc    ${bts_id}
    ${localIpAddr}    Get Scfc localIpAddr    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
    Selenium Login    url=https://${localIpAddr}    version=${NODE_CFG["${bts_id}"]["software_release"]}    alias=${alias}
    ${cell_status}    Run Keyword    selenium_coam.get_cell_info    cell_idx=${cell_info["cellId"]}
    ...    sbts=${CASE_NAME}_${cell_info["btsId"]}_ui

    ${channelGroup_num}=    Get Length    ${cell_info['channelgroup']}

    Should Be True    '${channelGroup_num}' == '${cell_status['Number of subcells for super cell']}'
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout    alias=${alias}

Get Latest Counter Content
    [Arguments]   ${counter_id}     ${connection}   ${dist_name}=${EMPTY}    ${full_path}=${EMPTY}    ${index}=-1
    ${counter_info}   selenium_coam.get_bts_counters_info   counter_id=${counter_id}   dist_name=${dist_name}
    ...      full_path=${full_path}    timeout_for_loading_available_counters=120    sbts=${connection}
    ${time_list}    Get Dictionary Keys   ${counter_info}
    sort list    ${time_list}
    ${last_time}   Set Variable    ${time_list[${index}]}
    ${value}    Get From Dictionary   ${counter_info}    ${last_time}
    [Return]  ${last_time}   ${value}

Get Latest Realtime Measurement
    [Arguments]   ${object_name}   ${measured_object}   ${connection}
    ${measurements}   selenium_coam.get_real_time_measurements   ${object_name}   ${measured_object}   sbts=${connection}
    ${measurements_content}  Get From Dictionary  ${measurements}   ${object_name}/${measured_object}
    ${time_list}    Get Dictionary Keys   ${measurements_content}
    sort list    ${time_list}
    ${last_time}   Set Variable    ${time_list[-1]}
    ${value}    Get From Dictionary   ${measurements_content}    ${last_time}
    ${voltage}  Get From Dictionary  ${value}  Voltage
    ${power}  Get From Dictionary  ${value}  Power
    [Return]  ${voltage}  ${power}

All Subcell To Normal Cell
    [Arguments]    ${cell_info}    ${alias}=alias
    ${bts_id}    Set Variable    ${cell_info["btsId"]}
    ${alias}    Set Variable    ${CASE_NAME}_${bts_id}_ui
    ${localIpAddr}    Get Scfc localIpAddr    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
    ${channelgroup_id_list}    Get Dictionary Keys    ${cell_info["channelgroup"]}
    ${subcell_count}    Get Length    ${channelgroup_id_list}
    ${count}    Evaluate    int(${subcell_count})
    ${change_channelgroup_id}    Set Variable    ${channelgroup_id_list}[-${count}:]
    Selenium Login    url=https://${localIpAddr}
    ...    version=${NODE_CFG["${bts_id}"]["software_release"]}    alias=${alias}
    ${normal_cells}    Online Change SubCell to NormalCell    ${cell_info}    ${change_channelgroup_id}
    [Return]    ${normal_cells}

Get And Check TEST Thresholds
   [Arguments]    ${bts_id}    ${bts_thresholds}   ${bands_thresholds}=${None}
   ${scfc_dir_path}    Get Current Scfc    ${bts_id}
   ${dist_name}=    XML.evaluate xpath    ${scfc_dir_path}
   ...     //managedObject[@class="com.nokia.srbts.mnl:RFTHLD"]/@distName
   Should Contain    ${dist_name[0]}    \TEST-
   ${rFPowerErrorHighThreshold}=    XML.evaluate xpath    ${scfc_dir_path}
   ...  //managedObject[@distName="${dist_name[0]}"]/p[@name="rFPowerErrorHighThreshold"]/text()

   ${rFPowerErrorLowThreshold}=    XML.evaluate xpath    ${scfc_dir_path}
   ...  //managedObject[@distName="${dist_name[0]}"]/p[@name="rFPowerErrorLowThreshold"]/text()

   ${rfTemperatureHighThreshold}=    XML.evaluate xpath    ${scfc_dir_path}
   ...  //managedObject[@distName="${dist_name[0]}"]/p[@name="rfTemperatureHighThreshold"]/text()

   ${rfTemperatureLowThreshold}=    XML.evaluate xpath    ${scfc_dir_path}
   ...  //managedObject[@distName="${dist_name[0]}"]/p[@name="rfTemperatureLowThreshold"]/text()

   ${rxAntennaRTWPHighThreshold}=    XML.evaluate xpath    ${scfc_dir_path}
   ...  //managedObject[@distName="${dist_name[0]}"]/p[@name="rxAntennaRTWPHighThreshold"]/text()
   ${rxAntennaRTWPLowThreshold}=    XML.evaluate xpath    ${scfc_dir_path}
   ...  //managedObject[@distName="${dist_name[0]}"]/p[@name="rxAntennaRTWPLowThreshold"]/text()
   ${txAntennaVSWRHighThreshold}=    XML.evaluate xpath    ${scfc_dir_path}
   ...  //managedObject[@distName="${dist_name[0]}"]/p[@name="txAntennaVSWRHighThreshold"]/text()
   ${band_list}=    XML.evaluate xpath    ${scfc_dir_path}
   ...    //managedObject[@distName="${dist_name[0]}"]/list[@name="bandRfTestThresholds"]/item
   should_be_equal_as_strings    ${bts_thresholds["rFPowerErrorHighThreshold"]}    ${rFPowerErrorHighThreshold[0]}
   should_be_equal_as_strings    ${bts_thresholds["rFPowerErrorLowThreshold"]}    ${rFPowerErrorLowThreshold[0]}
   should_be_equal_as_strings    ${bts_thresholds["rfTemperatureHighThreshold"]}    ${rfTemperatureHighThreshold[0]}
   should_be_equal_as_strings    ${bts_thresholds["rfTemperatureLowThreshold"]}    ${rfTemperatureLowThreshold[0]}
   should_be_equal_as_strings    ${bts_thresholds["rxAntennaRTWPHighThreshold"]}    ${rxAntennaRTWPHighThreshold[0]}
   should_be_equal_as_strings    ${bts_thresholds["rxAntennaRTWPLowThreshold"]}    ${rxAntennaRTWPLowThreshold[0]}
   should_be_equal_as_strings    ${bts_thresholds["txAntennaVSWRHighThreshold"]}    ${txAntennaVSWRHighThreshold[0]}
   check_rf_diagnostic_band_config_info   scfc_path=${scfc_dir_path}     dist_name=${dist_name[0]}
    ...    bands_thresholds=${bands_thresholds}

Start RF Diagnostic Test And Check
    [Arguments]    ${bts_thresholds}=${None}    ${bands_thresholds}=${None}    ${technology}=LTE
    ...    ${cell}=All LTE cells    ${alias}=default    ${check_item}=${EMPTY}    ${check_status}=Pass
    Selenium Start RF Diagnostic Test    bts_thresholds=${bts_thresholds}    bands_thresholds=${bands_thresholds}
    ...    technology=${technology}    cell=${cell}    alias=${alias}
    ${cur_time}=    DateTime.Get Current Date    UTC    +8hour
    Selenium Check RF Diagnostic General Test Information    technology=${technology}    alias=${alias}
    ...    check_item=${check_item}    check_status=${check_status}

Check RF Diagnostic Test Detail Result
    [Arguments]    ${detail_dict}
    ${detail_list}    Create List
    ${keys}    Get Dictionary Keys    ${detail_dict}
    FOR    ${key}    IN    @{keys}
        ${detail_list}    Combine Lists    ${detail_list}    ${detail_dict["${key}"]}
    END
    ${value_dict}    Get And Check RF Diagnostic Detail Result Values    ${detail_list}
    [Return]    ${value_dict}

Get And Check RF Diagnostic Detail Result Values
    [Arguments]    ${detail_list}
    ${rtwp}    Get Key Values From Json List    RTWP (dBm)    ${detail_list}
    ${vswr}    Get Key Values From Json List    VSWR    ${detail_list}
    ${total_power}    Get Key Values From Json List    Forward total transmit RF power    ${detail_list}
    ${power_error}    Get Key Values From Json List    Forward transmit RF power error (dB)    ${detail_list}
    ${list_length}    Get Length    ${detail_list}
    FOR    ${index}    IN RANGE    ${list_length}
        ${each_rtwp}    Evaluate    float(${rtwp[${index}]})
        ${each_vswr}    Evaluate    float(${vswr[${index}]})
        ${total_power}    Convert To String    ${total_power}
        Should Be True    ${each_rtwp}!=0
        Should Be True    ${each_vswr}>=1
        Should Not Contain    ${total_power[${index}]}    0
    END
    ${rtwp_list}    Run Keyword If    ${list_length}!=1    Create List    ${rtwp[0]}    ${rtwp[-1]}
    ...    ELSE    Create List    ${rtwp[0]}
    ${vswr_list}    Run Keyword If    ${list_length}!=1    Create List    ${vswr[0]}    ${vswr[-1]}
    ...    ELSE    Create List    ${vswr[0]}
    ${power_error_list}    Run Keyword If    ${list_length}!=1   Create List    ${power_error[0]}    ${power_error[-1]}
    ...    ELSE    Create List    ${power_error[0]}
    ${detail_dict}    Create Dictionary    RTWP=${rtwp_list}    VSWR=${vswr_list}   RF_power_error=${power_error_list}
    [Return]    ${detail_dict}

Get All Cells Bands Thresholds
    [Arguments]    ${bts_id}    ${total_power_high_threshold}=150    ${total_power_low_threshold}=0.1
    ...    ${cell_list}=${ALL_CELL_LIST}
    ${bands_thresholds}    Create List
    FOR    ${cell_info}    IN    @{cell_list}
        Continue For Loop If    "${bts_id}"!="${cell_info["btsId"]}"
        ${threshold}    Create List    ${cell_info["band"]}    ${total_power_high_threshold}
        ...    ${total_power_low_threshold}
        Append To List    ${bands_thresholds}    ${threshold}
    END
    ${bands_thresholds}    Remove Duplicates    ${bands_thresholds}
    [Return]    ${bands_thresholds}

Power On And Off Target RU
    [Arguments]    ${ru_info}    ${btsids}    ${wait_time}=6min
    pdu.Setup Pdu    model=${ru_info["pdu_type"]}
    ...    host=${ru_info["pdu_ipaddr"]}
    ${port_status}    pdu.Get Port Status    port=${ru_info["target_pdu_port"]}
    Run Keyword If    "${port_status}" == "on"    Get Fault 4525 In Target Ru Info    ${ru_info}    ${btsids}
    ...    ELSE    Power On If Target Ru Is Off    ${ru_info}    ${wait_time}    ${btsids}
    #[Teardown]    pdu.Power Off    ${ru_info["target_pdu_port"]}

Power On If Target Ru Is Off
    [Arguments]    ${ru_info}    ${wait_time}    ${btsids}
    pdu.Power On    ${ru_info["target_pdu_port"]}
    sleep    ${wait_time}
    Get Fault 4525 In Target Ru Info    ${ru_info}    ${btsids}

Get Fault 4525 In Target Ru Info
    [Arguments]    ${ru_info}    ${btsids}
    FOR    ${bts_id}    IN    @{btsids}
        ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
        Judge Fault 0023 In Target RU And Upgrade    ${ru_info}    ${bts_id}    ${connection_id}
        Judge Fault 4525 In Target RU    ${ru_info}    ${connection_id}
    END

Judge Fault 4525 In Target RU
    [Arguments]    ${ru_info}    ${connection_id}
    ${target_alarm_info}    Run Keyword    coam.assert_alarm_active    parameters=faultId=4525
    ...    timeout=420    connection=${connection_id}
    FOR    ${alarm_info}    IN    @{target_alarm_info}
        Run Keyword If
        ...    '${alarm_info['serialNo']}'=='${ru_info['serialNo']}' and '${alarm_info['additionalFaultID']}'!='4525'
        ...    Fail
    END

Judge Fault 0023 In Target RU And Upgrade
    [Arguments]    ${ru_info}    ${bts_id}    ${connection_id}
    ${target_alarm_info}    Run Keyword    coam.assert_alarm_active    parameters=faultId=regex"23|4525"
    ...    timeout=420    connection=${connection_id}
    FOR    ${alarm_info}    IN    @{target_alarm_info}
        Run Keyword If
        ...    '${alarm_info['serialNo']}'=='${ru_info['serialNo']}' and '${alarm_info['additionalFaultID']}'=='23'
        ...    Fault 4525 RF Software Check And Correct    ${bts_id}
    END
    Verify HW state

Fault 4525 RF Software Check And Correct
    [Arguments]    ${bts_id}    ${pre_alias}=${CASE_NAME}
    ${status}    Run Keyword And Return Status    OperatingSystem.Directory Should Not Exist   ${SW_BUILDS_DIR_PATH}
    Run Keyword If    ${status}    OperatingSystem.Create Directory    ${SW_BUILDS_DIR_PATH}
    ${files}    OperatingSystem.List Files In Directory    ${SW_BUILDS_DIR_PATH}
    ${sw_downloaded}    Run Keyword And Return Status    Should Contain Match    ${files}
    ...    regexp=${NODE_CFG['${bts_id}'].software_active}
    ${package_type}    Get Variable Value    ${tl_config.PACKAGE_TYPE}    Normal
    Run Keyword If    '${sw_downloaded}'=='False'    Sw Package Download    ${NODE_CFG['${bts_id}'].software_active}
    ...    target_dir=${SW_BUILDS_DIR_PATH}    package_type=${package_type}
    ${files}    OperatingSystem.List Files In Directory    ${SW_BUILDS_DIR_PATH}
    ${matched_file}    Get Matches   ${files}    ${NODE_CFG['${bts_id}'].software_active}*
    Set To Dictionary    ${NODE_CFG['${bts_id}']}    active_file_path=${matched_file[0]}
    Run Keyword And Ignore Error    coam.wait_sw_update_possible    connection=${pre_alias}_${bts_id}
    coam.Update Software    ${SW_BUILDS_DIR_PATH}/${matched_file[0]}    timeout=3600
    ...    connection=${pre_alias}_${bts_id}

Check Counter M8010C74 And M8010C75
    [Arguments]    ${mcc}  ${mnc}  ${start_timestamp}
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        ${bts_id}    Set Variable    ${cell_info["btsId"]}
        ${cell_id}   Set Variable    ${cell_info["cellId"]}
        ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}_ui
        ${M8010C74_distname}  Set Variable  CELLS/LNCEL-${cell_id}/MCC-${mcc}_MNC-0${mnc}/LTE Power and Quality DL/M8010C74
        ${M8010C75_distname}  Set Variable  CELLS/LNCEL-${cell_id}/MCC-${mcc}_MNC-0${mnc}/LTE Power and Quality DL/M8010C75
        ${M8010C74_time}  ${M8010C74_avg}  Get Latest Counter Content   M8010C74  dist_name=${M8010C74_distname}  connection=${connection_id}
        ${M8010C75_time}  ${M8010C75_max}  Get Latest Counter Content   M8010C75  dist_name=${M8010C75_distname}  connection=${connection_id}
        ${M8010C74_timestamp}  DateTime.Convert Date  ${M8010C74_time}  epoch
        ${M8010C75_timestamp}  DateTime.Convert Date  ${M8010C75_time}  epoch
        Should Be True  ${start_timestamp}<${M8010C74_timestamp}
        Should Be True  ${start_timestamp}<${M8010C75_timestamp}
#        Should Be True  "${M8010C74_avg}"=="${M8010C75_max}"
    END
Check Counter M40015C11 And M40015C10
    [Arguments]    ${counter_id}    ${full_name_list}    ${connection}
    FOR    ${full_name}    IN    @{full_name_list}
        ${last_time}    ${counter_value_1}     Get Latest Counter Content    ${counter_id}   ${connection}    full_path=${full_name}
        ...     index=-2
        ${last_time}    ${counter_value_2}     Get Latest Counter Content    ${counter_id}   ${connection}    full_path=${full_name}
        ...     index=-1
        ${counter_value}    Evaluate    ${counter_value_1}+${counter_value_2}
        Should Be True    ${counter_value}>=1
    END

Get And Check RF Diagnostic Test Remove
    [Arguments]     ${bts_id}
    ${scfc_dir_path}    Get Current Scfc    ${bts_id}
    ${test_distname}    XML.evaluate xpath    ${scfc_dir_path}
    ...     //managedObject[@class="com.nokia.srbts.mnl:TEST"]/@distName
    ${actRemoteRfDiag}    XML.evaluate xpath    ${scfc_dir_path}
    ...  //managedObject[@class="com.nokia.srbts.mnl:FEATCADM"]/p[@name="actRemoteRfDiag"]/text()
    Should Be Empty    ${test_distname}
    Should Be Equal As Strings    ${actRemoteRfDiag[0]}    false

Select Specific Rat Cells
    [Arguments]    ${bts_id}    ${technology}=LTE    ${cell_list}=${ALL_CELL_LIST}
    ${cell_mapping_rat_list}    Create List
    FOR    ${cell_info}    IN    @{cell_list}
        continue for loop if    "${cell_info["btsId"]}"!="${bts_id}"
        Run Keyword If    "${technology}"=="LTE" and "${cell_info["NetworkType"]}"=="4G"
        ...    Append To List    ${cell_mapping_rat_list}    ${cell_info}
        Run Keyword If    "${technology}"=="NR" and ("${cell_info["NetworkType"]}"!="SA" or "${cell_info["NetworkType"]}"!="NSA")
        ...    Append To List    ${cell_mapping_rat_list}    ${cell_info}
    END
    [Return]    ${cell_mapping_rat_list}

Run RF Diagnostic Test And Check After Block/lock
    [Arguments]    ${disabled_cell_list}    ${enabled_cell_list}    ${bts_thresholds}=${None}    ${bands_thresholds}=${None}
    ...     ${technology}=LTE    ${alias}=default
    ${class_name}     Set Variable If    "${technology}"=="LTE"    LNCEL    NRCEL
    ${status}    Run Keyword And Return Status    Should Be Empty    ${enabled_cell_list}
    ${test_status}    Run Keyword And Return Status    Selenium Run Diagnostic Test    bts_thresholds=${bts_thresholds}
    ...    bands_thresholds=${bands_thresholds}    technology=${technology}    alias=${alias}
    Run Keyword If    ${status}    Should Not Be True    ${test_status}
    ...    ELSE    Run Keywords    Should Be True    ${test_status}
    ...    AND    Selenium Check RF Diagnostic General Test Information    cell_list=${disabled_cell_list}    technology=${technology}
    ...    alias=${alias}    check_status=PrematureTermination
    ...    AND    Selenium Check RF Diagnostic General Test Information    cell_list=${enabled_cell_list}    technology=${technology}
    ...    alias=${alias}    check_status=Pass

Execute Command On SystemModule
    [Arguments]    ${command}    ${host}=${BTS_HOST}    ${remote_host}=${None}
    Setup eNB FSM Access    host=${host}    timeout=15    remote_host=${remote_host}    alias=enb
    ${rc}    Execute Command On Enb    cmd=${command}   return_rc=${True}    alias=enb
    [Return]    ${rc}
    [Teardown]    Teardown Enb Fsm Access    alias=enb

Check Domain Collision Reasoning Status
    [Arguments]    ${alias}=default
    ${srio_portconf_list}    coam.get_managed_objects    class_name=SRIO_PORTCONF_L    connection=${alias}
    FOR    ${srio_portconf}    IN    @{srio_portconf_list}
        ${status}    Run Keyword And Return Status    Should Contain    ${srio_portconf["distName"]}    CONCENTRATOR_L
        Exit For Loop If    ${status}
    END
    Should Be Equal As Strings    ${srio_portconf["parameters"]["stateInfo"]["reasoningStatus"][0]}    DomainIdCollisionReported

Check SRIO Collision Handling
    ${alias}    Set Variable    ${CASE_NAME}_${MASTER_BTS_ID}
    ${get_srio_id}    Set Variable    ddal -s ddal_sysinfo_module_get_domain_id DDAL_BOARD_LOCAL
    ${set_srio_id}    Set Variable    ddal -s ddal_sysinfo_module_set_domain_id 0
    ${right_core_host_ip}    Set Variable    ${tl.test_pcs[1].default_ssh_connection_details.addr}
    ${primary_srio_id}    Execute Command On SystemModule    ${get_srio_id}
    ${primary_srio_id}    Fetch From Right    ${primary_srio_id[0]}    =
    ${second_srio_id}    Execute Command On SystemModule    ${get_srio_id}    host=192.168.255.7    remote_host=${right_core_host_ip}
    ${second_srio_id}    Fetch From Right    ${second_srio_id[0]}    =
    Should Not Be Equal As Integers    ${primary_srio_id}    ${second_srio_id}
    Execute Command On SystemModule    ${set_srio_id} ${primary_srio_id}    host=192.168.255.7    remote_host=${right_core_host_ip}
    ${check_second_srio_id}    Execute Command On SystemModule    ${get_srio_id}    host=192.168.255.7    remote_host=${right_core_host_ip}
    ${check_second_srio_id}    Fetch From Right    ${check_second_srio_id[0]}    =
    Should Be Equal As Integers    ${primary_srio_id}    ${check_second_srio_id}
    coam.reset_site    timeout=600    connection=${alias}
    Wait Until Host Is Available    ${BTS_HOST}    timeout=300
    Wait Until Host Is Available    192.168.255.7    remote_host=${right_core_host_ip}    timeout=300
    Wait Until Keyword Succeeds    5 min    10 s    Check Domain Collision Reasoning Status    alias=${alias}
    Wait Until Host Is Unavailable    192.168.255.7    remote_host=${right_core_host_ip}    timeout=1000
    Wait Until Host Is Available    192.168.255.7    remote_host=${right_core_host_ip}    timeout=300
    ${second_srio_id_after}    Execute Command On SystemModule    ${get_srio_id}    host=192.168.255.7    remote_host=${right_core_host_ip}
    ${second_srio_id_after}    Fetch From Right    ${second_srio_id_after[0]}    =
    Should Not Be Equal As Integers    ${primary_srio_id}    ${second_srio_id_after}

Check SRIO Connection Failed
    ${alias}    Set Variable    ${CASE_NAME}_${MASTER_BTS_ID}
    ${right_core_host_ip}    Set Variable    ${tl.test_pcs[1].default_ssh_connection_details.addr}
    ${master_sm}    Set Variable    ${NODE_CFG["${MASTER_BTS_ID}"]["master_sm"]}
    ${slave_sm}    Set Variable    ${NODE_CFG["${MASTER_BTS_ID}"]["slave_sm"]}
    PDU Turn Off All Devices From Serial Number List    ${USED_SM_SN_LIST}    ${BTS_CONFIG}    FSM
    Wait Until Host Is Unavailable    ${BTS_HOST}    timeout=1000
    Wait Until Host Is Unavailable    192.168.255.7    remote_host=${right_core_host_ip}    timeout=1000
    PDU Turn On Unit    pdu_type=${BTS_CONFIG['FSM']['${master_sm}']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FSM']['${master_sm}']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FSM']['${master_sm}']['pdu']['port']}
    coam.assert any    SMOD    parameters=operationalState=regex"(?i)Enabled", serialNumber=${master_sm}
    ...    timeout=600s    connection=${alias}
    coam.assert_alarm_active    parameters=faultId=4352    timeout=900    connection=${alias}
    PDU Turn On Unit    pdu_type=${BTS_CONFIG['FSM']['${slave_sm}']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FSM']['${slave_sm}']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FSM']['${slave_sm}']['pdu']['port']}
    coam.assert_alarm_inactive    parameters=faultId=4352    timeout=420    connection=${alias}
    [Teardown]    Run Keyword If    "${KEYWORD STATUS}"=="FAIL"    Run Keyword And Ignore Error
    ...    PDU Turn On All Devices From Serial Number List    ${USED_SM_SN_LIST}    ${BTS_CONFIG}    FSM

Check SRIO Connection
    [Arguments]   ${connection}
    ${concentrator_infos}  coam.get_managed_objects   class_name=CONCENTRATOR_L     connection=${connection}
    ${SRIO_concentrators}  Create List
    FOR  ${concentrator}  IN  @{concentrator_infos}
        Run Keyword If  "${concentrator["parameters"]["concentratorType"]}"=="SRIO"   Append To List  ${SRIO_concentrators}
        ...    ${concentrator}
    END
    log  ${SRIO_concentrators}
    FOR  ${concentrator}  IN  @{SRIO_concentrators}
        ${connector_distname}  Set Variable   ${concentrator["distName"]}/CONNECTOR_L-1
        ${connector}  coam.get_parameters   dist_name=${connector_distname}   connection=${connection}
        ${hw_port}  coam.get_parameters   dist_name=${connector_distname}/HWPORT_L-1   connection=${connection}
        ${SRIO_portconf}  coam.get_parameters   dist_name=${connector_distname}/HWPORT_L-1/SRIO_PORTCONF_L-1   connection=${connection}
        Should Be True  "${connector["connectorType"]}"=="SRIO"
        Should Be True  "${hw_port["defaultAxmConnection"]}"=="True"
        Should Be True  "${hw_port["hwlinkType"]}"=="SRIOLink"
        Should Be True  "${SRIO_portconf["stateInfo"]["availabilityStatus"]}"=="Online"
        Should Be True  "${SRIO_portconf["stateInfo"]["operationalState"]}"=="Enabled"
    END

Check ETH Connection
    [Arguments]   ${connection}
    ${ethernet_infos}  coam.get_managed_objects   class_name=ETHERNET_PORTCONF_L     connection=${connection}
    FOR  ${ethernet}  IN  @{ethernet_infos}
        Continue For Loop If  "${ethernet["parameters"]["inetPortId"]}"!="MateFCTLink1"
        ${ethernet_distname}  Set Variable  ${ethernet["distName"]}
        ${connector_distname}  ${rest1}  ${rest2}  Split String From Right   ${ethernet_distname}    /   2
        ${connector}  coam.get_parameters   dist_name=${connector_distname}   connection=${connection}
        Should Be True  "${connector["stateInfo"]["operationalState"]}"=="Enabled"
        Should Be True  "${connector["stateInfo"]["availabilityStatus"]}"=="Online"
    END

Check Secondary Core Pingable
    [Arguments]    ${host_ip}    ${primary_core_ip}=${BTS_HOST}    ${secondary_core_ip}=192.168.255.7
    SSHLibrary.Open Connection    ${host_ip}    timeout=20   alias=ping_secondary_core
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    ${out}    SSHLibrary.Write    ssh toor4nsn@${primary_core_ip}
    ${stas}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    ${out}    Run Keyword If    ${stas}    SSHLibrary.Write    oZPS0POrRieRtu    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    >
    ${out}    SSHLibrary.Write    ping ${secondary_core_ip}
    ${out}    Wait Until Keyword Succeeds    100s    1s    SSHLibrary.Read Until    from ${secondary_core_ip}: icmp
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

BTS Power Off And On
    ${nodes_status}    Run Keyword And Return Status    List Should Contain Value    ${${CURRENT_CONFIG_ID}}    NODES
    ${external_nodes}    Run Keyword If    ${nodes_status}    Config Nodes List Split    ${CURRENT_CONFIG_ID}
    ...    ELSE    Create Dictionary
    ${multi_config_id}    Create Dictionary    TL1=${CURRENT_CONFIG_ID}    &{external_nodes}
    common_setup.Power Off Test Node FSM    ${multi_config_id}
    sleep    1s
    common_setup.Power On Test Node FSM    ${multi_config_id}
    sleep    2min

Update Peak Rate Config With Cell Index
    [Arguments]    ${cell}    ${newcell}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
#    ${pk_dict}    Evaluate    ${extra_peak_rate_config}
    ${newcell_list}    Split String    ${newcell}    :
    FOR    ${ncell}    IN    @{newcell_list}
         ${pkr}   Get From Dictionary    ${extra_peak_rate_config}    ${cell['phyCellId']}
         Set To Dictionary   ${extra_peak_rate_config}    ${ncell}    ${pkr}
    END
    Remove From Dictionary    ${extra_peak_rate_config}    ${cell['phyCellId']}
    [Return]    ${extra_peak_rate_config}

Generate Delta Plan
    [Arguments]    ${parameter_list}
    coam.Create delta
    FOR    ${parameter}    IN    @{parameter_list}
        coam.Append parameter update to delta    ${parameter['dist_name']}    ${parameter['para_name']}
        ...    ${parameter['para_value']}
    END
    ${delta_update}=    coam.Get delta
    [Return]    ${delta_update}

Check Fault 4079 Fan Vendor Not Detected
    [Arguments]    ${bts_id}
    ${case_pass}    Set Variable    ${False}
    ${xml_info}   Set Variable   '<config><tag name="app.bm.climate.fanspeed.testmode" type="u16">6</tag></config>'
    ${fault_4079_command}   Set Variable   echo ${xml_info} > /rom/config/fct/pcf.xml;chmod 644 /rom/config/fct/pcf.xml
    ${host_ip}    Get Scfc localIpAddr    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
    ${ret}    Send BBU Command    ${host_ip}    ${fault_4079_command}
    Reset BTS Until Onair
    Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=4073    connection=${CASE_NAME}_${bts_id}
    Wait Until Keyword Succeeds    300 sec    10 sec    Check Fault From RawAlarmsHistory    ${host_ip}
    Wait Until keyword Succeeds    5x    5s    Send BBU Command    ${host_ip}    rm -rf /rom/config/fct/pcf.xml
    Reset BTS Until Onair
    Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_inactive
    ...    parameters=faultId=4073    connection=${CASE_NAME}_${bts_id}
    Wait Until Keyword Succeeds    300 sec    10 sec
    ...    Check Fault From RawAlarmsHistory    ${host_ip}   fault_exist=False
    ${case_pass}    Set Variable    ${True}
    [Teardown]    Run Keyword If    "${case_pass}"=="${False}"    Run Keywords
    ...    Run Keyword And Ignore Error    Send BBU Command    ${host_ip}    rm -rf /rom/config/fct/pcf.xml
    ...    AND    Reset BTS Until Onair

Check Fault From RawAlarmsHistory
    [Arguments]    ${host_ip}    ${fault}=4079    ${fault_exist}=${True}
    ${ret}    Send BBU Command    ${host_ip}    cat /tmp/RawAlarmHistory.txt
    ${out}    Run Keyword If    "${fault_exist}"=="True"
    ...    Should Match Regexp    ${ret}    (Active faults\r\n+(.*\r\n+)*(.*(${fault}))(.*\r\n+)* Inactive faults)
    ...    ELSE
    ...    Should Not Match Regexp    ${ret}    (Active faults\r\n+(.*\r\n+)*(.*(${fault}))(.*\r\n+)* Inactive faults)
    log    ${out}

Send BBU Command
    [Arguments]    ${bbu_ip}    ${command}    ${prompt}=>
    SSHLibrary.Open Connection    ${bbu_ip}    timeout=10    alias=send_to_bbu
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${out}    SSHLibrary.Write    ${command}
    ${ret}    Run Keyword And Continue On Failure    SSHLibrary.Read Until    ${prompt}
    [Return]    ${ret}
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Get RMOD Realtime Measurements
    [Arguments]    ${connection_id}
    ${rmod_measurements}    Create Dictionary
    ${measurements}    coam.get_real_time_measurements    connection=${connection_id}
    FOR  ${measurement}  IN  @{measurements}
        ${object}    Get Dictionary Keys   ${measurement}
        ${object}    Set Variable   ${object[0]}
        ${is_rmod}    Run Keyword And Return Status    Should Match Regexp    '${object}'   ENERGY_EFFICIENCY/RMOD/
        Run Keyword If  ${is_rmod}    Set To Dictionary    ${rmod_measurements}    ${object}     ${measurement['${object}']}
    END
    [Return]    ${rmod_measurements}

Check RMOD Power Save
    [Arguments]    ${rmod_measurements_origin}   ${rmod_measurements_new}
    ${rmod_path}   Get Dictionary Keys    ${rmod_measurements_origin}
    FOR  ${rmod_path}  IN  @{rmod_path}
        ${rmod_power_origin}    Set Variable    ${rmod_measurements_origin['${rmod_path}']['power']}
        ${rmod_power_new}    Set Variable    ${rmod_measurements_new['${rmod_path}']['power']}
        ${rmod_exp}    Evaluate    ${rmod_power_origin}*0.75
        Should Be True   ${rmod_power_new}<${rmod_exp}
    END

Exceptional_RF Fiber Insert&Removal Break_config and data_Link For one RF
    [Arguments]    ${rf}
    ${ggmapdict}    Evaluate    ${GGMAP}
    ${btsIdList}    Get RRU Connected BtsId    ${rf}
    ${connection_id}    Set Variable    ${CASE_NAME}_${btsIdList[0]}
    ${cablink_r}     coam.Get Managed Objects    CABLINK_R    connection=${connection_id}
    ${rmod_r}     coam.Get Managed Objects    RMOD_R    connection=${connection_id}
    ${smod_r}     coam.Get Managed Objects    SMOD_R    connection=${connection_id}
    ${bbmod_r}     coam.Get Managed Objects    BBMOD_R    connection=${connection_id}
    ${topo}    get_current_topo    ${cablink_r}    ${rmod_r}    ${bbmod_r}    ${smod_r}
    ${cell_list}    get_cell_list_with_rf    ${ALL_CELL_LIST}    ${rf}
#        ${primary}    ${return}    run keyword and ignore error    Should Contain    ${linkdict['${rf}']}    primary
#        ${secondary}    ${return}    run keyword and ignore error    Should Contain    ${linkdict['${rf}']}    secondary
    ${rf_dist_name}    Get Distname For with RF Id   ${fr_serial_number}



    ${config_links}     get_selected_link    ${topo}    ${ggmapdict}    ${rf}      primary
    ${data_links}    ${linktype}     get_selected_link    ${topo}    ${ggmapdict}    ${rf}      secondary

    ${primary_link}    randomly_select_links    links=${config_links}   num=1
    ${data_link}    randomly_select_links    links=${data_links}   num=1
    Break Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${primary_link[0][0]}
    ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}
    Break Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${data_link[0][0]}
    ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}
    coam.assert_alarm_active
    ...    parameters=faultId=10,alarmingResource=${rf_dist_name}
    ...    timeout=300    connection=${connection_id}

    Connect Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${primary_link[0][0]}
    ...    FW_type=${tl_config.FW_INFO['TYPE']}

    Connect Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${data_link[0][0]}
    ...    FW_type=${tl_config.FW_INFO['TYPE']}

    coam.assert_alarm_inactive
    ...    parameters=faultId=10,alarmingResource=${rf_dist_name}
    ...    timeout=300    connection=${connection_id}


    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Make L3Call    required_cells=${cell_list}

    ${data_link}    randomly_select_links    links=${data_links}   num=2

        FOR    ${link_info}    IN    @{config_links}
        Break Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link_info[0]}
        ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}
    END

    FOR    ${link_info}    IN    @{data_link}
        Break Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link_info[0]}
        ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}
    END

    coam.assert_alarm_active
    ...    parameters=faultId=10,alarmingResource=${rf_dist_name}
    ...    timeout=300    connection=${connection_id}


    FOR    ${link_info}    IN    @{config_links}
        Connect Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link_info[0]}
        ...    FW_type=${tl_config.FW_INFO['TYPE']}
    END

    FOR    ${link_info}    IN    @{data_link}
        Connect Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link_info[0]}
        ...    FW_type=${tl_config.FW_INFO['TYPE']}
    END

    coam.assert_alarm_inactive
    ...    parameters=faultId=10
    ...    timeout=300    connection=${connection_id}

    Wait For All Cells OnAir    timeout=${ONAIR_TIME}


    FOR    ${link_info}    IN    @{config_links}
        Break Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link_info[0]}
        ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}
    END

    FOR    ${link_info}    IN    @{data_links}
        Break Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link_info[0]}
        ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}
    END

    coam.assert_alarm_active
    ...    parameters=faultId=10,alarmingResource=${rf_dist_name}
    ...    timeout=300    connection=${connection_id}


    FOR    ${link_info}    IN    @{config_links}
        Connect Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link_info[0]}
        ...    FW_type=${tl_config.FW_INFO['TYPE']}
    END

    FOR    ${link_info}    IN    @{data_links}
        Connect Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link_info[0]}
        ...    FW_type=${tl_config.FW_INFO['TYPE']}
    END

    coam.assert_alarm_inactive
    ...    parameters=faultId=10
    ...    timeout=300    connection=${connection_id}

    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Make L3Call    required_cells=${cell_list}

Exceptional_RF Fiber Insert&Removal Break_then_connect_Link For one RF
    [Arguments]    ${rf}
    ${ggmapdict}    Evaluate    ${GGMAP}
    ${btsIdList}    Get RRU Connected BtsId    ${rf}
    ${connection_id}    Set Variable    ${CASE_NAME}_${btsIdList[0]}
    ${cablink_r}     coam.Get Managed Objects    CABLINK_R    connection=${connection_id}
    ${rmod_r}     coam.Get Managed Objects    RMOD_R    connection=${connection_id}
    ${smod_r}     coam.Get Managed Objects    SMOD_R    connection=${connection_id}
    ${bbmod_r}     coam.Get Managed Objects    BBMOD_R    connection=${connection_id}
    ${topo}    get_current_topo    ${cablink_r}    ${rmod_r}    ${bbmod_r}    ${smod_r}
    ${cell_list}    get_cell_list_with_rf    ${ALL_CELL_LIST}    ${rf}
#        ${primary}    ${return}    run keyword and ignore error    Should Contain    ${linkdict['${rf}']}    primary
#        ${secondary}    ${return}    run keyword and ignore error    Should Contain    ${linkdict['${rf}']}    secondary
    ${rf_dist_name}    Get Distname For with RF Id   ${fr_serial_number}



    ${config_links}     get_selected_link    ${topo}    ${ggmapdict}    ${rf}      primary
    ${data_links}    ${linktype}     get_selected_link    ${topo}    ${ggmapdict}    ${rf}      secondary

    ${primary_link}    randomly_select_links    links=${config_links}   num=1
    ${data_link}    randomly_select_links    links=${data_links}   num=1
    Break Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${primary_link[0][0]}
    ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}

    Connect Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${primary_link[0][0]}
    ...    FW_type=${tl_config.FW_INFO['TYPE']}
    Wait For All Cells OnAir    timeout=30
    Make L3Call    required_cells=${cell_list}

    Break Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${data_link[0][0]}
    ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}

    Connect Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${data_link[0][0]}
    ...    FW_type=${tl_config.FW_INFO['TYPE']}
    Wait For All Cells OnAir    timeout=30
    Make L3Call    required_cells=${cell_list}


    ${data_link}    randomly_select_links    links=${data_links}   num=2
    FOR    ${link_info}    IN    @{data_links}
        Break Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link_info[0]}
        ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}
    END


    FOR    ${link_info}    IN    @{data_link}
        Connect Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link_info[0]}
        ...    FW_type=${tl_config.FW_INFO['TYPE']}
    END

    Wait For All Cells OnAir    timeout=30


    ${data_link}    randomly_select_links    links=${data_links}   num=3
    FOR    ${link_info}    IN    @{data_link}
        Break Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link_info[0]}
        ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}
    END

    FOR    ${link_info}    IN    @{data_link}
        Connect Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link_info[0]}
        ...    FW_type=${tl_config.FW_INFO['TYPE']}
    END

    Wait For All Cells OnAir    timeout=30
    Make L3Call    required_cells=${cell_list}

Exceptional_RF Fiber Insert&Removal Break_config or data_Link For one RF
    [Arguments]    ${rf}
    ${ggmapdict}    Evaluate    ${GGMAP}
    ${btsIdList}    Get RRU Connected BtsId    ${rf}
    ${connection_id}    Set Variable    ${CASE_NAME}_${btsIdList[0]}
    ${cablink_r}     coam.Get Managed Objects    CABLINK_R    connection=${connection_id}
    ${rmod_r}     coam.Get Managed Objects    RMOD_R    connection=${connection_id}
    ${smod_r}     coam.Get Managed Objects    SMOD_R    connection=${connection_id}
    ${bbmod_r}     coam.Get Managed Objects    BBMOD_R    connection=${connection_id}
    ${topo}    get_current_topo    ${cablink_r}    ${rmod_r}    ${bbmod_r}    ${smod_r}
    ${cell_list}    get_cell_list_with_rf    ${ALL_CELL_LIST}    ${rf}
#        ${primary}    ${return}    run keyword and ignore error    Should Contain    ${linkdict['${rf}']}    primary
#        ${secondary}    ${return}    run keyword and ignore error    Should Contain    ${linkdict['${rf}']}    secondary
    ${rf_dist_name}    Get Distname For with RF Id   ${fr_serial_number}



    ${config_links}     get_selected_link    ${topo}    ${ggmapdict}    ${rf}      primary
    ${data_links}    ${linktype}     get_selected_link    ${topo}    ${ggmapdict}    ${rf}      secondary

    ${primary_link}    randomly_select_links    links=${config_links}   num=1
    ${data_link}    randomly_select_links    links=${data_links}   num=1
    Break Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${primary_link[0][0]}
    ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}

    coam.assert_alarm_active
    ...    parameters=faultId=10,alarmingResource=${rf_dist_name}
    ...    timeout=300    connection=${connection_id}

    Connect Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${primary_link[0][0]}
    ...    FW_type=${tl_config.FW_INFO['TYPE']}

    coam.assert_alarm_inactive
    ...    parameters=faultId=10
    ...    timeout=300    connection=${connection_id}

    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Make L3Call    required_cells=${cell_list}

    Break Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${data_link[0][0]}
    ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}

    coam.assert_alarm_inactive
    ...    parameters=faultId=10
    ...    timeout=300    connection=${connection_id}

    Connect Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${data_link[0][0]}
    ...    FW_type=${tl_config.FW_INFO['TYPE']}

    Wait For All Cells OnAir    timeout=${ONAIR_TIME}


    ${data_link}    randomly_select_links    links=${data_links}   num=2
    FOR    ${link_info}    IN    @{data_links}
        Break Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link_info[0]}
        ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}
    END

    coam.assert_alarm_inactive
    ...    parameters=faultId=10
    ...    timeout=300    connection=${connection_id}

    FOR    ${link_info}    IN    @{data_link}
        Connect Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link_info[0]}
        ...    FW_type=${tl_config.FW_INFO['TYPE']}
    END

    Wait For All Cells OnAir    timeout=${ONAIR_TIME}


    ${data_link}    randomly_select_links    links=${data_links}   num=3
    FOR    ${link_info}    IN    @{data_link}
        Break Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link_info[0]}
        ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}
    END

    coam.assert_alarm_inactive
    ...    parameters=faultId=10
    ...    timeout=300    connection=${connection_id}

    FOR    ${link_info}    IN    @{data_link}
        Connect Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link_info[0]}
        ...    FW_type=${tl_config.FW_INFO['TYPE']}
    END
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Make L3Call    required_cells=${cell_list}

Antenna Line Online Monitoring check
     FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
         ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
         ${antennas}    coam.get_antennas     connection=${connection_id}
         ${rmods}     Get Dictionary Keys      ${antennas}
         ${ANTL_R}     Get_Antl_List     ${rmods}     ${antennas}
         ${ANTL_R_List}     Remove Duplicates      ${ANTL_R}
         coam.start_antl_online_monitoring    target_dns=${ANTL_R_List}      connection=${connection_id}
         sleep     15s
         coam.stop_antl_online_monitoring    output_file_name=${TEST_LOGS_DIR_PATH}/AntOnlineMonitor.json
         ...    connection=${connection_id}
         modify_json.check_antenna_line_online_monitoring    ${TEST_LOGS_DIR_PATH}/AntOnlineMonitor.json     RTWP
     END

Get_Antl_R_List
     [Arguments]    ${rmod}     ${ANTL_R}    ${antennas}
     FOR    ${ant}     IN     @{antennas['${rmod}']}
         Run Keyword IF    'TX/RX'=='${ant['direction']}' or 'RX'=='${ant['direction']}' or 'TX'=='${ant['direction']}'
         ...    append to list    ${ANTL_R}      ${ant['id']['runtime']}
     END
     [Return]     ${ANTL_R}


Get_Antl_List
     [Arguments]    ${rmods}    ${antennas}
     ${ANTL_R}      create list
     FOR    ${rmod}    IN    @{rmods}
         ${ANTL_R}     Get_Antl_R_List      ${rmod}     ${ANTL_R}      ${antennas}
     END
     [Return]     ${ANTL_R}

Get Node Id List
     [Arguments]    ${bts_id}
     ${bbu_info}    Set Variable    ${NODE_CFG["${bts_id}"]["bbu_info"]}
     ${sn_list}    Get Dictionary Keys    ${bbu_info}
     ${node_id_list}    Create List
     FOR    ${sn}    IN    @{sn_list}
         ${horizontalPosition}    Set Variable    ${bbu_info["${sn}"]["horizontalPosition"]}
         ${verticalPosition}    Set Variable    ${bbu_info["${sn}"]["verticalPosition"]}
         Run Keyword If    "${horizontalPosition}"=="1" and "${verticalPosition}"=="1"
         ...    Append To List    ${node_id_list}    0x10
         ...    ELSE IF    "${horizontalPosition}"=="2" and "${verticalPosition}"=="1"
         ...    Append To List    ${node_id_list}    0x20
         ...    ELSE    Append To List    ${node_id_list}    0x${horizontalPosition}${verticalPosition}
     END
     [Return]    ${node_id_list}

Send fault 1911 Command
    [Arguments]     ${RRU_IP}    ${fault_6051_cmd_list}    ${RF_fault_info}    ${connection_id}
    Send RRU Command Mmimo    ${RRU_IP}    ${fault_6051_cmd_list}    ${RF_fault_info['6051']['port']}
    Wait Until Keyword Succeeds    600 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=1911    connection=${connection_id}

Check Fault Signature
    [Arguments]      ${faultId}    ${category}    ${connection}
    ${alarm_list}    coam.get_historical_alarms    connection=${connection}
    FOR    ${alarm}    IN    @{alarm_list}
        Continue For Loop If    "${alarm["faultId"]}" != "${faultId}"
        Continue For Loop If    "${alarm["faultSignature"]["category"]}" == "-"
        Should Be Equal As Strings    ${category}    ${alarm["faultSignature"]["category"]}
        Should Be True    ${alarm["faultSignature"]["resetCounter"]} > ${0}
        Return From Keyword
    END
    Fail

Send Comand With SSH
    [Arguments]    ${ip}    ${username}    ${password}    ${command}    ${prompt}    ${username2}=${NONE}
    ${type}    Evaluate    type($command).__name__
    ${command}    Run Keyword If    "${type}"!="list"    Create List    ${command}
    ...    ELSE    Set Variable    ${command}
    SSHLibrary.Open Connection    localhost    timeout=20   alias=tsn
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    ${out}    SSHLibrary.Write    ssh ${username}@${ip}
    Run Keyword If    "${username2}"!="${NONE}"    Run Keywords    SSHLibrary.Read Until    Username:
    ...    AND    SSHLibrary.Write    ${username2}\n
    ${status}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    ${out}    Run Keyword If    ${status}    SSHLibrary.Write    ${password}    ELSE    SSHLibrary.Write    \n
    ${ret}    Run Keyword And Return Status    SSHLibrary.Read Until    ?
    Run Keyword If    ${ret}    SSHLibrary.Write    y    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    ${prompt}
    FOR    ${cmd}    IN    @{command}
        SSHLibrary.Write    ${cmd}\n
        SSHLibrary.Read Until    ${prompt}
    END
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Get RMOD ConfigDN
    [Arguments]    ${rf_sn}    ${connection_id}
    ${rmod_r_list}    coam.get_managed_objects    class_name=RMOD_R    connection=${connection_id}
    FOR    ${rmod_r}    IN    @{rmod_r_list}
        ${sn}    Set Variable    ${rmod_r["parameters"]["serialNumber"]}
        ${configDN}    Set Variable    ${rmod_r["parameters"]["configDN"]}
        Return From Keyword If    "${rf_sn}"=="${sn}"    ${configDN}
    END
    Fail

Get topSlavePortNumber value with topMasterUsed as True
    [Arguments]    ${configDN}    ${connection_id}
    ${topp_r_list}    coam.get_managed_objects    class_name=TOPP_R    connection=${connection_id}
    FOR    ${topp_r}    IN    @{topp_r_list}
        ${targetDN}    Set Variable    ${topp_r["parameters"]["targetDN"]}
        ${topMasterList}    Set Variable    ${topp_r["parameters"]["topMasterList"]}
        Exit For Loop If    "${targetDN}"=="${configDN}"
    END
    should be equal as strings    ${targetDN}    ${configDN}
    FOR    ${topMaster}    IN    @{topMasterList}
        ${topSlavePortNumber}    Set Variable    ${topMaster["topSlavePortNumber"]}
        Return From Keyword If    "${topMaster["topMasterUsed"]}"=="used"    ${topSlavePortNumber}
    END
    Fail

Disable TOPP
    [Arguments]    ${configDN}    ${tsn_config}    ${connection_id}
    ${ip}    Set Variable    ${tsn_config["account"]["ip"]}
    ${username}    Set Variable    ${tsn_config["account"]["username"]}
    ${username2}    Set Variable    ${tsn_config["account"]["username2"]}
    ${password}    Set Variable    ${tsn_config["account"]["password"]}
    ${prompt}    Set Variable    ${tsn_config["account"]["prompt"]}
    ${topSlavePortNumber}    Get topSlavePortNumber value with topMasterUsed as True    ${configDN}    ${connection_id}
    ${port}    Set Variable    ${tsn_config["port"]["${topSlavePortNumber}"]}
    ${command}    Set Variable    config sync 1 ptp clock1 ${port} adminState down
    ute_admin_infomodel.setup_infomodel    address=${BTS_HOST}    alias=${connection_id}
    Send Comand With SSH    ${ip}    ${username}    ${password}    ${command}    ${prompt}    username2=${username2}
#    Check Alarm Active
    coam.assert_alarm_active
    ...    parameters=faultId=61631,faultName="ToP master service RU eCPRI port #${topSlavePortNumber} unusable"
    ...    connection=${connection_id}
    ...    timeout=30
    [Return]    ${topSlavePortNumber}    ${port}
    [Teardown]    Run Keyword And Ignore Error    ute_admin_infomodel.teardown_all_aliases_for_infomodel


Enable TOPP
    [Arguments]    ${tsn_config}    ${port}    ${port2}=${NONE}
    ${ip}    Set Variable    ${tsn_config["account"]["ip"]}
    ${username}    Set Variable    ${tsn_config["account"]["username"]}
    ${username2}    Set Variable    ${tsn_config["account"]["username2"]}
    ${password}    Set Variable    ${tsn_config["account"]["password"]}
    ${prompt}    Set Variable    ${tsn_config["account"]["prompt"]}
    ${command}    Set Variable    config sync 1 ptp clock1 ${port} adminState up
    ${command2}    Set Variable    config sync 1 ptp clock1 ${port2} adminState up
    Send Comand With SSH    ${ip}    ${username}    ${password}    ${command}    ${prompt}    username2=${username2}
    Run Keyword If    "${port2}"!="${NONE}"    Send Comand With SSH    ${ip}    ${username}    ${password}
    ...    ${command2}    ${prompt}    username2=${username2}
    Wait For All Cells OnAir

Modify vendor parameters
    [Arguments]    ${bts_id}    ${modify_paramters}
    ${connection_id}    Set Variable    ${CASE_NAME}_${bts_id}
    ${default_vendor_file}    Set Variable    ${TEST_LOGS_DIR_PATH}/vendor.xml
    coam.download_vendor_file    ${default_vendor_file}    connection=${connection_id}
    ${target_xml}    Set Variable    ${TEST_LOGS_DIR_PATH}/modify_vendor.xml
    modify_xml    ${default_vendor_file}    ${target_xml}    ${modify_paramters}
    coam.set_vendor_file    ${target_xml}    connection=${connection_id}
    Perform Template File Commissioning    ${bts_id}    connection=${connection_id}

Recovery_Multiple changes_of_Long optical fiber
    [Arguments]    ${fr_sn}    ${link_dict}    ${required_cells}=${EMPTY}
    Make L3call    required_cells=${required_cells}
    Power Off Radio    ${fr_sn}
    Break Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link_dict["${fr_sn}"]["break"]}
    ...    FW_type=${tl_config.FW_INFO['TYPE']}
    Connect Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link_dict["${fr_sn}"]["connect"]}
    ...    FW_type=${tl_config.FW_INFO['TYPE']}
    Power On Radio    ${fr_sn}
    Make L3call    required_cells=${required_cells}
    Check Alarms
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Break Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link_dict["${fr_sn}"]["connect"]}
    ...    FW_type=${tl_config.FW_INFO['TYPE']}
    ...    AND    Run Keyword And Ignore Error    Connect Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${link_dict["${fr_sn}"]["break"]}
    ...    FW_type=${tl_config.FW_INFO['TYPE']}
    ...    AND    Power On Radio    ${fr_sn}
    ...    AND    Wait For All Cells OnAir

Check If RU Offline
    [Arguments]    ${rmod_distname}     ${connection}
    ${ru_R_info}    coam.get_parameters    dist_name=${rmod_distname}    connection=${connection}
    Should Be Equal As Strings  ${ru_R_info["availabilityStatus"]}   not installed

Get Link Info
    [Arguments]    ${fr_sn}    ${link_type}
    ${ggmapdict}    Evaluate    ${GGMAP}
    ${btsIdList}    Get RRU Connected BtsId    ${fr_sn}
    ${connection_id}    Set Variable    ${CASE_NAME}_${btsIdList[0]}
    ${cablink_r}     coam.Get Managed Objects    CABLINK_R    connection=${connection_id}
    ${rmod_r}     coam.Get Managed Objects    RMOD_R    connection=${connection_id}
    ${smod_r}     coam.Get Managed Objects    SMOD_R    connection=${connection_id}
    ${bbmod_r}     coam.Get Managed Objects    BBMOD_R    connection=${connection_id}
    ${topo}    get_current_topo    ${cablink_r}    ${rmod_r}    ${bbmod_r}    ${smod_r}
    ${linkpri}    ${linktype}     get_selected_link    ${topo}    ${ggmapdict}    ${fr_sn}      ${link_type}
    should not be empty    ${linkpri}
    [Return]    ${linkpri}    ${linktype}

Do Short Break With Fiber Changed
    [Arguments]    ${linkpri}    ${extra_fiber}=${EMPTY}
    Run Keyword If    "${extra_fiber}" == "${EMPTY}"    Run Keywords    Connect Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${linkpri}
    ...    FW_type=${tl_config.FW_INFO['TYPE']}
    ...    AND    Return From Keyword
    ${extra_fiber}    Evaluate    ${extra_fiber}
    ${ports}    Split String    ${linkpri}    :
    ${longer_link}    Set Variable    ${ports[0]}:${extra_fiber[0]};${extra_fiber[1]}:${ports[1]}
    Connect Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${longer_link}
    ...    FW_type=${tl_config.FW_INFO['TYPE']}

Check If A Cell Onair On One RF
    [Arguments]    ${fr_sn}
    ${cell_mapping_rf_list}    Get Cells State On Specific FR    ${fr_sn}
    ${status}    Run Keyword And Return Status    Verify All Cells OnAir With Abnormal State
    ...    check_cell_list=${cell_mapping_rf_list}    operational_state=disabled
    ...    avail_status=failed
    ${has_cell_onair}    Set Variable If    ${status}    ${False}    ${True}
    [Return]    ${has_cell_onair}

Scfc Get actForceUnitAutoReset Value
    [Arguments]    ${bts_id}
    ${current_scfc}    Get Current Scfc    ${bts_id}
    ${actForceUnitAutoReset}    Get Element Text   ${current_scfc}
    ...    xpath=//managedObject[@class='com.nokia.srbts.mnl:FMCADM']/p[@name="actForceUnitAutoReset"]
    [Return]    ${actForceUnitAutoReset}

Scfc Get actCpriLinkRecovery Value
    [Arguments]    ${bts_id}
    ${current_scfc}    Get Current Scfc    ${bts_id}
    ${actForceUnitAutoReset}    Get Element Text   ${current_scfc}
    ...    xpath=//managedObject[@class='com.nokia.srbts.mnl:FMCADM']/p[@name="actCpriLinkRecovery"]
    [Return]    ${actCpriLinkRecovery}

Check And Online Parameter Recommission
    [Arguments]    ${bts_id}    ${parameter_list}
    ${parameter_list}    Evaluate    ${parameter_list}
    ${current_scfc}    Get Current Scfc    ${bts_id}
    ${need_modify_parameters}    Create List
    FOR    ${parameter}    IN    @{parameter_list}
        ${out_tmp_value}=    Get Element Text    ${current_scfc}
         ...    xpath=.//managedObject[@distName='${parameter['distName']}']/p[@name='${parameter['paraName']}']
         Run Keyword If    "${out_tmp_value}" != " ${parameter['paraValue']}"
         ...    Append To List    ${need_modify_parameters}    ${parameter}
    END
    ${status}    Run Keyword And Return Status    Should Be Empty    ${need_modify_parameters}
    Return From Keyword If    ${status}
    coam.Create delta
    FOR    ${parameter}    IN    @{parameter_list}
        coam.Append parameter update to delta    ${parameter['distName']}    ${parameter['paraName']}
        ...    ${parameter['paraValue']}
    END
    ${delta_update}=    coam.Get delta
    coam.Perform delta recommissioning    ${delta_update}    skip_parameter_relation_errors=True
    ...    connection=${CASE_NAME}_${bts_id}
    Check Multi Parameters Recommission Result    ${parameter_list}    ${CASE_NAME}_${bts_id}
    [Teardown]    Run Keyword And Ignore Error    coam.Remove delta

Get Link Info And Topo
    [Arguments]    ${fr_sn}    ${link_type}
    ${ggmapdict}    Evaluate    ${GGMAP}
    ${btsIdList}    Get RRU Connected BtsId    ${fr_sn}
    ${connection_id}    Set Variable    ${CASE_NAME}_${btsIdList[0]}
    ${cablink_r}     coam.Get Managed Objects    CABLINK_R    connection=${connection_id}
    ${rmod_r}     coam.Get Managed Objects    RMOD_R    connection=${connection_id}
    ${smod_r}     coam.Get Managed Objects    SMOD_R    connection=${connection_id}
    ${bbmod_r}     coam.Get Managed Objects    BBMOD_R    connection=${connection_id}
    ${topo}    get_current_topo    ${cablink_r}    ${rmod_r}    ${bbmod_r}    ${smod_r}
    ${linkpri}    ${linktype}     get_selected_link    ${topo}    ${ggmapdict}    ${fr_sn}      ${link_type}
    should not be empty    ${linkpri}
    [Return]    ${linkpri}    ${linktype}    ${topo}

Check Counter M40015C10 Or M40015C11
	[Arguments]  ${counter_id}    ${primary_link}    ${bts_id}
	${bbmod_info_list}    Should Match Regexp    ${primary_link}    BBMOD_R-(\\d+):(\\w+)\\(\\d+\\)
	${bbmod_info}  Set Variable  ${bbmod_info_list[0]}
	${bbmod_sn}   Set Variable  ${bbmod_info_list[-1]}
	${sfp_index}   Set Variable  ${bbmod_info[-2]}
	${bbmod_r_info}    Split String    ${bbmod_info}    :
#	${bbmod_distname}    Get R Object Distname By SN    class_name=BBMOD_R    sn=${bbmod_sn}   connection=${CASE_NAME}_${bts_id}
	${current_scfc}    Get Current Scfc    ${bts_id}
	${out_configDN}=    Evaluate Xpath    ${current_scfc}
    ...  string(.//managedObject[contains(@class, ":BBMOD_R") and contains(@distName, "${bbmod_r_info[0]}")]/p[@name='configDN'])
	${counter_dist_name}  Set Variable  BTS/${out_configDN}/SFP-${sfp_index}/LANE-1/SBTS_SFP_BBMOD_LANE/${counter_id}
#	${last_time}    ${counter_value_1}     Get Latest Counter Content By Distname    M40015C10   ${CASE_NAME}_${bts_id}
#    ...     dist_name=${counter_dist_name}    index=-2
    ${last_time}    ${counter_value_2}     Get Latest Counter Content By Distname   ${counter_id}    ${CASE_NAME}_${bts_id}
    ...     dist_name=${counter_dist_name}    index=-1
#    ${counter_value}    Evaluate    ${counter_value_1}+${counter_value_2}
    Should Be True    ${counter_value_2}>=1

Get Latest Counter Content By Distname
    [Arguments]   ${counter_id}     ${connection}   ${dist_name}=${EMPTY}    ${index}=-1
    ${counter_info}   coam.get_counters_info   dist_name=${dist_name}    connection=${connection}
    ${counter_info}    Convert To String    ${counter_info}
     ${counter_content_list}    Should Match Regexp    ${counter_info}     '${counter_id}': {(.+)(\\d)}
     ${counter_content}    Evaluate    {${counter_content_list[0]}}
     ${counter_content}   Set Variable    ${counter_content["${counter_id}"]}
    ${time_list}    Get Dictionary Keys   ${counter_content}
    sort list    ${time_list}
    ${last_time}   Set Variable    ${time_list[${index}]}
    ${value}    Get From Dictionary   ${counter_content}    ${last_time}
    [Return]  ${last_time}   ${value}

Get Cablink Distname
    [Arguments]    ${rf_sn}    ${linktype}    ${bts_id}
    ${CABLINK_R}    coam.Get Managed Objects     CABLINK_R    connection=${CASE_NAME}_${bts_id}
    ${if_primary_link}    Set Variable If    "${linktype}"=="primary"    True    False
    ${rmod_distname}    Get R Object Distname By SN    class_name=RMOD_R    sn=${rf_sn}     connection=${CASE_NAME}_${bts_id}
    FOR    ${cablink_info}    IN    @{CABLINK_R}
        ${linkModeSynchronization}    Set Variable    ${cablink_info["parameters"]["linkModeSynchronization"]}
        ${secondEndpointDN}    Set Variable    ${cablink_info["parameters"]["secondEndpointDN"]}
        Continue For Loop If    "${linkModeSynchronization}"!="${if_primary_link}" or "${secondEndpointDN}"!="${rmod_distname}"
        ${cablink}    Set Variable    ${cablink_info["distName"]}
    END
    ${counter_content_list}    Should Match Regexp    ${cablink}     EQM_R(.+)
    ${cablink_distname}    Set Variable    MRBTS-${btsid}/${counter_content_list[0]}
    [Return]    ${cablink_distname}

Check Alarm Active
    [Arguments]    ${parameters}    ${connection}    ${timeout}=60
    ${fault_id}    Get Regexp Matches    ${parameters}    faultId=(\\d+)    1
    ${release}    coam.get_sw_release_name    connection=${connection}
    coam.get_current_scf_file    ${TEST_LOGS_DIR_PATH}    SCFC.xml    export_type=configurationAndRuntimeObjects
    ...    connection=${connection}
    ${current_scfc_path}    Set Variable    ${TEST_LOGS_DIR_PATH}/SCFC.xml
    ${smod_product}     Evaluate Xpath    ${current_scfc_path}
    ...    .//managedObject[@class="com.nokia.srbts.eqmr:SMOD_R"]/p[@name="productName"]/text()
    ${smod_num}    Get Length    ${smod_product}
    ${second_status}    Run Keyword If    ${smod_num}==2    Evaluate    "FSMF" in "${smod_product[1]}"
    ...    ELSE   Set Variable    True
    ${status}    Evaluate    ("FSMF" in "${smod_product[0]}" and ${second_status}) or "FSIH" in "${smod_product[0]}"
    Run Keyword If    ${status}
    ...    Run Keywords    coam.assert_alarm_active    parameters=${parameters}
    ...    connection=${connection}    timeout=${timeout}
    ...    AND    Return From Keyword
    iav.set start timestamp
    ${status}     ${alarm_list}    Run Keyword And Ignore Error    coam.assert_alarm_active    parameters=${parameters}
    ...    connection=${connection}    timeout=${timeout}
    iav.set end timestamp
    Run Keyword If    "${status}"=="FAIL"     ute_admin_infomodel.save_infomodel_log
    ...    filename=${TEST_LOGS_DIR_PATH}/check_alarm_infomodel.ims2
    ...    alias=${connection}
    ${detected_alarm}    Run Keyword If    "${status}"=="FAIL"     Check Alarm In IMS2    fault_id=${fault_id[0]}
    ...    ims_file_path=${TEST_LOGS_DIR_PATH}/check_alarm_infomodel.ims2
    Return From Keyword If    "${status}"=="FAIL"
    FOR    ${alarm}    IN    @{alarm_list}
        ${alarm_id}    Get From Dictionary    ${alarm}    alarmId
        ${severity}    Get From Dictionary    ${alarm}    severity
        Run Keyword If    "${alarm["faultId"]}"=="${fault_id[0]}"
        ...    Should Be True    ("${alarm_id}"!="7115" and "${alarm_id}"!="7102") or ("${severity}"!="Minor" and "${severity}"!="Warning")
    END

Check Alarm In IMS2
    [Arguments]    ${fault_id}    ${ims_file_path}
    ${wanted_alarm1}    awd.create_alarm    alarm_id=7115    fault_id=${fault_id}    severity=Minor
    ${wanted_alarm2}    awd.create_alarm    alarm_id=7115    fault_id=${fault_id}    severity=Warning
    ${wanted_alarm3}    awd.create_alarm    alarm_id=7102   fault_id=${fault_id}    severity=Minor
    ${wanted_alarm4}    awd.create_alarm    alarm_id=7102    fault_id=${fault_id}    severity=Warning
    ${wanted_alarm_list}    Create List    ${wanted_alarm1}    ${wanted_alarm2}    ${wanted_alarm3}    ${wanted_alarm4}
    FOR    ${wanted_alarm}    IN    @{wanted_alarm_list}
        ${status}    Run Keyword And Return Status    iav.verify alarm was set    alarm=${wanted_alarm}
        ...    ims_file_path=${ims_file_path}
        Return From Keyword If    ${status}
    END
    Fail    msg=fault${fault_id} not visible in ims2!
