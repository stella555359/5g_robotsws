*** Settings ***
Documentation    Suite description
...    Author:        qiang.1.zhou@nokia-sbell.com
...    Maintainer:    Zhou Qiang

Library     ./utils/Bbox5Check.py
Library     ./utils/BboxCheck.py
Library     ./utils/filtering_syslog.py
Library     ./tools/lib_install.py
Resource    ./common_setup.robot
Resource    ./l3call.robot
Resource    ./UUF.robot
Resource    ../../Module/Module.robot

Library    ute_syslog
Library    ./utils/earfcn.py
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.ul.oam_kpi_calculations    WITH NAME    KPI
Library    taf.hw.pdu    WITH NAME    pdu

*** Keywords ***
Data Transfer
    [Arguments]    ${required_cells}=${Empty}     ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    ...    ${is_stability_test}=${FALSE}
    Make Tput    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    Run Keyword If    ${is_stability_test}    Sleep    1800s
    Check Alarms
    Check Historical Alarms

Common_SiSo_State Management_Sub-cell failure in super cell configuration
    [Arguments]    ${required_cells}=${Empty}
    ${cell_list}    Run Keyword If
    ...    '${required_cells}'!='${Empty}'   Get Rquired Cells   ${ALL_CELL_LIST}    ${required_cells}
    ...    ELSE    Choose Cells    ${ALL_CELL_LIST}

    FOR    ${cell_info}    IN    @{cell_list}
        TX Failure Creation For One Subcell    ${cell_info}
        TX Failure Creation For All Subcell Except one    ${cell_info}
        TX Failure Creation For All Subcell And Resetup    ${cell_info}
    END
    Run Keyword And Continue On Failure    Make L3Call    required_cells=${required_cells}
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    Check Alarms
    Check Historical Alarms    additional_allowed_alarms=No connection to unit
    [Teardown]    Run Keywords     Pdu Turn On All Devices From Serial Number List
    ...    ${USED_FR_SN_LIST}       ${BTS_CONFIG}    FR    AND
    ...    Wait For All Cells OnAir    timeout=${ONAIR_TIME}

Cell Block And Unblock All
     [Arguments]    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
     FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Block Cell    ${cell_info}
     END

     FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Unblock Cell   ${cell_info}
     END
     Verify All Cells OnAir
     Check Alarms
     Check Historical Alarms    additional_allowed_alarms=Cell blocked
     Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
     Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Cell Block And Unblock Random And Tput
     [Arguments]    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${random_operate_cell_num}=${1}
     ${cell_num}    Get Length    ${ALL_CELL_LIST}
     ${tput_cell_list}    Copy List    ${ALL_CELL_LIST}
     ${operate_cell_list}    Evaluate    random.sample(range(${cell_num}), ${random_operate_cell_num})    modules=random
     ${operate_blocked_cell_list}    Create List
     FOR    ${cell_index}    IN    @{operate_cell_list}
         Append To List    ${operate_blocked_cell_list}    ${ALL_CELL_LIST[${cell_index}]}
         ${is_need_to_operate}   Check Is Operation Cell    ${ALL_CELL_LIST[${cell_index}]}
         Run Keyword If   ${is_need_to_operate}    Block Cell    ${ALL_CELL_LIST[${cell_index}]}
         Remove Values From List    ${tput_cell_list}    ${ALL_CELL_LIST[${cell_index}]}
     END
     Make Tput    cell_list=${tput_cell_list}    extra_peak_rate_config=${extra_peak_rate_config}
     FOR    ${cell_info}    IN    @{operate_blocked_cell_list}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Unblock Cell    ${cell_info}
     END
     Verify All Cells OnAir
     sleep    3min
     Make Tput    cell_list=${operate_blocked_cell_list}    extra_peak_rate_config=${extra_peak_rate_config}

Cell Block And Unblock Sequential
     [Arguments]    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
     FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Continue For Loop If    '${is_need_to_operate}'=='False'
         Block Cell    ${cell_info}
         Unblock Cell   ${cell_info}
         Verify All Cells OnAir
         Make L3Call    required_cells=${cell_info["phyCellId"]}     extra_peak_rate_config=${extra_peak_rate_config}
     END
     Check Historical Alarms    additional_allowed_alarms=Cell blocked
     Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Cell Block And Unblock All with rfreset
     [Arguments]    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}    ${required_power_rfs}=${EMPTY}
     FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Block Cell    ${cell_info}
     END
     ${required_power_rfs_list}    Split String    ${required_power_rfs}    :
     ${rf_list}    Set Variable If    "${required_power_rfs}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_power_rfs_list}
     ${cell_cross_rru}    Check Is Cell Cross RRU
     FOR    ${fr_serial_number}    IN    @{rf_list}
        Radio Reset without onair    ${fr_serial_number}
     END
     FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Unblock Cell   ${cell_info}
     END
     Verify All Cells OnAir
     Check Alarms
     Check Historical Alarms    additional_allowed_alarms=Cell blocked
     Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
     Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Cell Block And Unblock All loop 4 times
     [Arguments]    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}    ${required_power_rfs}=${EMPTY}
     Log    ${extra_peak_rate_config}
     Log    ${required_cells}
     Log    ${required_power_rfs}
     FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Block Cell    ${cell_info}
     END
     FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Unblock Cell   ${cell_info}
     END
     Verify All Cells OnAir
     FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Block Cell    ${cell_info}
     END
     FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Unblock Cell   ${cell_info}
     END
     Verify All Cells OnAir
     FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Block Cell    ${cell_info}
     END
     FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Unblock Cell   ${cell_info}
     END
     Verify All Cells OnAir
     FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Block Cell    ${cell_info}
     END
     FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Unblock Cell   ${cell_info}
     END
     Verify All Cells OnAir
     Check Alarms
     Check Historical Alarms    additional_allowed_alarms=Cell blocked
#     Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
     Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Site Reset
    [Arguments]    ${timeout}=${ONAIR_TIME}
    Reset BTS Until Onair    timeout=${timeout}
    Check Alarms
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=1

BBMOD Reset
    [Documentation]    Auther: nick.1.wu@nokia-sbell.com
    [Arguments]    ${timeout}=300s    ${bbmod_id_list}=${Empty}    ${test_loops}=${Empty}
    ...    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
    FOR    ${bts_id}    IN    @{BTS_LIST}
        Reset BBMOD Until Onair    timeout=${timeout}    require_bbmod=${bbmod_id_list}    btsid=${bts_id}
        ...    test_loops=${test_loops}
    END
    Check Alarms
    Check Historical Alarms
    Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

BTS Block And Unblock
    [Documentation]    Auther: nick.1.wu@nokia-sbell.com
    [Arguments]    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
    FOR    ${bts_id}    IN    @{BTS_LIST}
        ${host_ip}    Get Scfc localIpAddr    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
        Selenium Block BTS Site    btsid=${bts_id}    hostip=${host_ip}
        sleep    20s
        Selenium Unblock BTS Site    btsid=${bts_id}    hostip=${host_ip}
        sleep    3min
        Wait For All Cells OnAir    timeout=${ONAIR_TIME}
        Verify HW State
        Check Alarms
        Check Historical Alarms    additional_allowed_alarms=BTS blocked
        Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
        Get And Check Reset Counter For All BTS Node     correct_reset_counter=1
    END

SISO_RF module power reset
    [Arguments]    ${required_power_rfs}=${EMPTY}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
    [Documentation]    Author:        amy.wu@nokia-sbell.com
    ...                Maintainer:    amy.wu@nokia-sbell.com
    ${required_power_rfs_list}    Split String    ${required_power_rfs}    :
    ${rf_list}    Set Variable If    "${required_power_rfs}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_power_rfs_list}
    Set Test Variable    ${HAS_CPRIN}    ${False}
    FOR    ${fr_serial_number}    IN    @{rf_list}
        Power Off Radio    ${fr_serial_number}
        Sleep    30 sec
        Power On Radio    ${fr_serial_number}
    END
    Check Multinode Without Unexpect Alarm
    Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    ${additional_alarms}    Set Variable    No connection to unit:Failure in optical interface:Unit power reset
    Run Keyword If    ${HAS_CPRIN}    Check Historical Alarms
    ...  additional_allowed_alarms=${additional_alarms}:Not able to synchronize baseband bus:Baseband bus failure
    ...  ELSE     Check Historical Alarms  additional_allowed_alarms=${additional_alarms}
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]    Run Keyword If    "${KEYWORD STATUS}"=="FAIL"    Power On Radio    ${fr_serial_number}

SISO_RF module power reset without 1815
    [Arguments]    ${required_power_rfs}=${EMPTY}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
    [Documentation]    Author:        amy.wu@nokia-sbell.com
    ...                Maintainer:    amy.wu@nokia-sbell.com
    ${required_power_rfs_list}    Split String    ${required_power_rfs}    :
    ${rf_list}    Set Variable If    "${required_power_rfs}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_power_rfs_list}
    FOR    ${fr_serial_number}    IN    @{rf_list}
        Power Off Radio without Check 1815    ${fr_serial_number}
        Sleep    30 sec
        Power On Radio    ${fr_serial_number}
    END
    Check Multinode Without Unexpect Alarm
    Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    Check Historical Alarms  additional_allowed_alarms=No connection to unit:Failure in optical interface:Unit power reset
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]    Run Keyword If    "${KEYWORD STATUS}"=="FAIL"    Power On Radio    ${fr_serial_number}

General_SiSo_Commissioning_BTS_Template_Commissioning
    [Arguments]    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    [Documentation]    Author:        amy.wu@nokia-sbell.com
    ...                Maintainer:    amy.wu@nokia-sbell.com
    Log    ${extra_peak_rate_config}
    FOR    ${bts_id}    IN    @{BTS_LIST}
        Perform Template File Commissioning    ${bts_id}    ignore_errors=False    connection=${CASE_NAME}_${bts_id}
    END
    Verify HW State
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Check Multinode Without Unexpect Alarm
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=1

Automated SiSo OnLine Parameters Commissioning
    [Arguments]    ${online_commissioning_tmp}=${online_commissioning}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    ...    ${required_cells}=${EMPTY}
    Log    ${extra_peak_rate_config}
    FOR    ${bts_id}    IN    @{BTS_LIST}
        Run Keywords
        ...    Perform Parameters Commissioning
        ...    ${bts_id}   ignore_errors=False    connection=${CASE_NAME}_${bts_id}    online_commissioning_tmp=${online_commissioning_tmp}
        ...    AND    Verify HW State
    END
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Make L3Call    required_cells=${required_cells}
    Check Multinode Without Unexpect Alarm
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

SISO_Recovery RF module reset
    [Arguments]    ${required_power_rfs}=${EMPTY}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
    [Documentation]    Author:        amy.wu@nokia-sbell.com
    ...                Maintainer:    amy.wu@nokia-sbell.com
    ${required_power_rfs_list}    Split String    ${required_power_rfs}    :
    ${rf_list}    Set Variable If    "${required_power_rfs}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_power_rfs_list}
    ${cell_cross_rru}    Check Is Cell Cross RRU
    FOR    ${fr_serial_number}    IN    @{rf_list}
        Radio Reset    ${fr_serial_number}
    END
    Check Multinode Without Unexpect Alarm
    Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    Run Keyword If    ${cell_cross_rru}
    ...    Check Historical Alarms    additional_allowed_alarms=Transmission path failure:Tx Failure Turn Mimo Off
    ...    ELSE    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Ru lock And Unlock All
     [Documentation]   Auther: lisa.ding@nokia-sbell.com
     [Arguments]    ${timeout}=10 min    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
     FOR    ${btsId}    IN    @{ALL_BTS_ID_LIST}
         Lock RU   ${btsId}
         Unlock RU   ${btsId}
     END
     Wait For All Cells OnAir    timeout=${timeout}
     Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
     Check Multinode Without Unexpect Alarm
     Check Historical Alarms
     Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Earfcn Update And Check
     [Documentation]   Auther: lisa.ding@nokia-sbell.com
     [Arguments]    ${earfcn_config}={'301': {'InRange': {'Dl':'37900', 'Ul': '37900'}, 'OutRange': {'Dl':'37900', 'Ul': '37900'}}}
     ${earfcn_config_dict}    Evaluate    ${earfcn_config}
     ${pci_list}    Get Dictionary Keys    ${earfcn_config_dict}
     FOR    ${pci}    IN    @{pci_list}
         #${pci_int}    Convert To Integer    ${pci}
         #${cell_info}   Get Cell Info From All Cells With PCI    ${ALL_CELL_LIST}    ${pci}
         ${cell_info}   Get Cell Info With PCI    ${ALL_CELL_LIST}    ${pci}
         Update_Specail_Cell_Earfcn_And_Check   ${cell_info}   ${earfcn_config_dict}
     END

Site Reset With Remove Hwbin
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    ${host_ip_list}    Get Dictionary Values    ${BTS_CONFIG["HOST_IP"]}
    FOR    ${host_ip}    IN    @{host_ip_list}
         Run Keyword And Ignore Error    Setup eNB FSM Access
         ...    host=${BTS_HOST}    timeout=15    remote_host=${host_ip}
         ...    alias=rm_hwbin_${host_ip}
         Run Keyword And Ignore Error    execute_command_on_enb
         ...    cmd=rm -rf /ffs/run/config/hwf.bin.gz    alias=rm_hwbin_${host_ip}
    END
    Reset BTS Until Onair    timeout=${ONAIR_TIME}
    Verify HW state
    Check Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=1
    [Teardown]    teardown_all_aliases_for_enb_fsmaccess

Bts Power Reset
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    ${nodes_status}    Run Keyword And Return Status    List Should Contain Value    ${${CURRENT_CONFIG_ID}}    NODES
    ${external_nodes}    Run Keyword If    ${nodes_status}    Config Nodes List Split    ${CURRENT_CONFIG_ID}
    ...    ELSE    Create Dictionary
    ${multi_config_id}    Create Dictionary    TL1=${CURRENT_CONFIG_ID}    &{external_nodes}
    common_setup.Power Off Test Node FSM    ${multi_config_id}
    sleep    1s
    common_setup.Power On Test Node FSM    ${multi_config_id}
    sleep    2min
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Verify HW state
    Check Alarms
    Check Historical Alarms    additional_allowed_alarms=Fault signature for crash or failure
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=1

Lock_Unlock_SFP_BBMOD
    Lock all sfp lane and check status    ${MASTER_BTS_ID}    SFP
    sleep    30s
    [Teardown]    Unlock all sfp lane and check status    ${MASTER_BTS_ID}

Lock_Unlock_QSFP_BBMOD
    Lock all sfp lane and check status    ${MASTER_BTS_ID}    QSFP
    sleep    30s
    [Teardown]    Unlock all sfp lane and check status    ${MASTER_BTS_ID}

Test_Dedicated_uplink
    [Documentation]    Author: Lou Xingxin
    [Arguments]    ${beam_pattern_nr_id}=600
    Reset_to_Test_Dedicated
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        ${bts_id}    Set Variable     ${cell_info["btsId"]}
        Test Dedicated Uplink Start   ${cell_info}  ${beam_pattern_nr_id}
        sleep    5s
        Test Dedicated Uplink Stop   ${cell_info}
        sleep    5s
        ${SMOD_name}  bts_common_interface.Get SMOD Product Name   ${NODE_CFG["${bts_id}"]["scf_file_path"]}
        ${is_ASOE}    Run Keyword And Return Status    Should Match Regexp    ${SMOD_name}   ASOE
    END
    Check Historical Alarms
    ${status}    Run Keyword And Return Status    Get And Check Reset Counter For All BTS Node    correct_reset_counter=1
    Run Keyword If    "${is_ASOE}"=="False" and "${status}"=="Flase"    Fail
    [Teardown]    Reset BTS Until Onair    timeout=${ONAIR_TIME}

Test_Dedicated_downlink
    [Arguments]    ${tdd_frame_conf}=3    ${tdd_spec_sub_conf}=8  ${beam_pattern_nr_id}=600
    Log    ${tdd_frame_conf}
    Log    ${tdd_spec_sub_conf}
    Reset_to_Test_Dedicated
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        ${bts_id}    Set Variable     ${cell_info["btsId"]}
        Test Dedicated Downlink Start   ${cell_info}  ${beam_pattern_nr_id}
        sleep    5s
        Test Dedicated Downlink Stop   ${cell_info}
        sleep    5s
        ${SMOD_name}  bts_common_interface.Get SMOD Product Name   ${NODE_CFG["${bts_id}"]["scf_file_path"]}
        ${is_ASOE}    Run Keyword And Return Status    Should Match Regexp    ${SMOD_name}   ASOE
    END
    Check Historical Alarms
    ${status}    Run Keyword And Return Status    Get And Check Reset Counter For All BTS Node    correct_reset_counter=1
    Run Keyword If    "${is_ASOE}"=="False" and "${status}"=="Flase"    Fail
    [Teardown]    Reset BTS Until Onair    timeout=${ONAIR_TIME}

Simultaneously Launching TestModels
    [Documentation]    Author: Lou Xingxin
    [Arguments]    ${beam_pattern_nr_id}=600
    Reset_to_Test_Dedicated
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        Test Dedicated Downlink Start   ${cell_info}  ${beam_pattern_nr_id}
        sleep  10s
        Test Dedicated Uplink Start   ${cell_info}  ${beam_pattern_nr_id}
        sleep  10s
    END
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        Test Dedicated Downlink Stop   ${cell_info}
        sleep  10s
        Test Dedicated Uplink Stop   ${cell_info}
        sleep  10s
    END
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=1
    [Teardown]    Reset BTS Until Onair    timeout=${ONAIR_TIME}

Test Dedicated Uplink With Switch Testmodel
    [Documentation]    Author: Lou Xingxin
    Reset_to_Test_Dedicated
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        ${bts_id}    Set Variable     ${cell_info["btsId"]}
        Run Keyword If    '${cell_info["NetworkType"]}'=='4G'  LTE Test Dedicated Uplink  ${cell_info}      ${CASE_NAME}_${bts_id}
        Run Keyword If    '${cell_info["NetworkType"]}'=='SA' or '${cell_info["NetworkType"]}'=='NSA'
        ...    NR Test Dedicated Uplink  ${cell_info}     ${CASE_NAME}_${bts_id}
         ${SMOD_name}  bts_common_interface.Get SMOD Product Name   ${NODE_CFG["${bts_id}"]["scf_file_path"]}
        ${is_ASOE}    Run Keyword And Return Status    Should Match Regexp    ${SMOD_name}   ASOE
    END
    Check Historical Alarms
    ${status}    Run Keyword And Return Status    Get And Check Reset Counter For All BTS Node    correct_reset_counter=1
    Run Keyword If    "${is_ASOE}"=="False" and "${status}"=="Flase"    Fail
    [Teardown]    Reset BTS Until Onair    timeout=${ONAIR_TIME}

Test Dedicated Downlink With Switch Testmodel
    [Documentation]    Author: Lou Xingxin
    Reset_to_Test_Dedicated
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        ${bts_id}    Set Variable     ${cell_info["btsId"]}
        Run Keyword If    '${cell_info["NetworkType"]}'=='4G'  LTE Test Dedicated Downlink  ${cell_info}    ${CASE_NAME}_${bts_id}
        Run Keyword If    '${cell_info["NetworkType"]}'=='SA' or '${cell_info["NetworkType"]}'=='NSA'
        ...    NR Test Dedicated Downlink  ${cell_info}      ${CASE_NAME}_${bts_id}
        ${SMOD_name}  bts_common_interface.Get SMOD Product Name   ${NODE_CFG["${bts_id}"]["scf_file_path"]}
        ${is_ASOE}    Run Keyword And Return Status    Should Match Regexp    ${SMOD_name}   ASOE
    END
    Check Historical Alarms
    ${status}    Run Keyword And Return Status    Get And Check Reset Counter For All BTS Node    correct_reset_counter=1
    Run Keyword If    "${is_ASOE}"=="False" and "${status}"=="Flase"    Fail
    [Teardown]    Reset BTS Until Onair    timeout=${ONAIR_TIME}

RF Fault Without Recovery Action
    [Arguments]    ${faultid}    ${required_rfs}=${EMPTY}
    Set Test Variable    ${FAULTID}    ${faultid}

    ${required_rfs_list}    Split String    ${required_rfs}    :
    ${rf_list}    Set Variable If    "${required_rfs}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_rfs_list}
    FOR    ${fr_serial_number}    IN    @{rf_list}
        ${RRU_Info}    Get RRU Info    serial_num=${fr_serial_number}
        ${RRU_IP}    Set Variable    ${RRU_Info['parameters']["ipAddress"]}
        ${bts_id}    Get Master BTS Id With RF serial Number     serial_num=${fr_serial_number}
        ${connection_id}   Set Variable    ${CASE_NAME}_${bts_id}
        ${ret}    Run Keyword And Return Status    Should Start with      ${RRU_Info["parameters"]["productName"]}    AZ
        Run Keyword If    ${ret}    Rf Fault trigger without recovery Rel5    ${RRU_IP}    ${faultid}   ${connection_id}
        ...    ELSE    Rf Fault trigger without recovery    ${RRU_IP}    ${faultid}    ${connection_id}

        Sleep    20s
        Radio Reset With Admin     ${fr_serial_number}    ${bts_id}
    END
    Wait For All Cells OnAir    timeout=240
    Check Multinode Without Unexpect Alarm
    Make L3Call

RF Fault With recovery Action Rel6
    [Arguments]    ${faultid}        ${required_rfs}=${EMPTY}
    Set Test Variable    ${FAULTID}    ${faultid}
    ${required_rfs_list}    Split String    ${required_rfs}    :
    ${rf_list}    Set Variable If    "${required_rfs}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_rfs_list}
    FOR    ${fr_serial_number}    IN    @{rf_list}
        ${RRU_Info}    Get RRU Info    serial_num=${fr_serial_number}
        ${RRU_IP}    Set Variable    ${RRU_Info['parameters']["ipAddress"]}
        ${bts_id}    Get Master BTS Id With RF serial Number     serial_num=${fr_serial_number}
        ${connection_id}   Set Variable    ${CASE_NAME}_${bts_id}
        Rf Fault trigger with recovery Rel6    ${RRU_IP}    ${faultid}
        ...    ${fr_serial_number}    ${bts_id}    ${connection_id}
    END
    Check Alarms
    Check Historical Alarms   additional_allowed_alarms=Radio autonomous reset as recovery action:TX out of order:Tx Failure Turn Mimo Off
    Get And Check Reset Counter For All BTS Node    correct_reset_counter=0
#    Make L3Call

RF Fault Without recovery Action Rel6
    [Arguments]    ${faultid}        ${required_rfs}=${EMPTY}
    Set Test Variable    ${FAULTID}    ${faultid}
    ${required_rfs_list}    Split String    ${required_rfs}    :
    ${rf_list}    Set Variable If    "${required_rfs}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_rfs_list}
    FOR    ${fr_serial_number}    IN    @{rf_list}
        ${RRU_Info}    Get RRU Info    serial_num=${fr_serial_number}
        ${RRU_IP}    Set Variable    ${RRU_Info['parameters']["ipAddress"]}
        ${bts_id}    Get Master BTS Id With RF serial Number     serial_num=${fr_serial_number}
        ${connection_id}   Set Variable    ${CASE_NAME}_${bts_id}
        Rf Fault trigger without recovery Rel6    ${RRU_IP}    ${faultid}
        ...    ${fr_serial_number}    ${bts_id}    ${connection_id}
    END
    Wait For All Cells OnAir
    Get And Check Reset Counter For All BTS Node    correct_reset_counter=0
#    Make L3Call

RF Fault Without recovery Action AZNA
    [Arguments]    ${faultid}        ${required_rfs}=${EMPTY}
    Set Test Variable    ${FAULTID}    ${faultid}
    ${required_rfs_list}    Split String    ${required_rfs}    :
    ${rf_list}    Set Variable If    "${required_rfs}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_rfs_list}
    FOR    ${fr_serial_number}    IN    @{rf_list}
        ${RRU_Info}    Get RRU Info    serial_num=${fr_serial_number}
        ${RRU_IP}    Set Variable    ${RRU_Info['parameters']["ipAddress"]}
        ${bts_id}    Get Master BTS Id With RF serial Number     serial_num=${fr_serial_number}
        ${connection_id}   Set Variable    ${CASE_NAME}_${bts_id}
        ${ret}    Run Keyword And Return Status    Should Start with      ${RRU_Info["parameters"]["productName"]}    AZ
        Run Keyword If    ${ret}
        ...    Rf Fault trigger without recovery Rel5 AZNA   ${RRU_IP}    ${faultid}
        ...    ${fr_serial_number}    ${bts_id}     ${connection_id}
        ...    ELSE
        ...    Rf Fault trigger without recovery    ${RRU_IP}    ${faultid}    ${connection_id}
    END
    Sleep    20s
    Wait For All Cells OnAir    timeout=240
    Check Multinode Without Unexpect Alarm
    Make L3Call

RF Fault With Recovery Action
    [Arguments]    ${faultid}    ${required_rfs}=${EMPTY}
    Set Test Variable    ${FAULTID}    ${faultid}

    ${required_rfs_list}    Split String    ${required_rfs}    :
    ${rf_list}    Set Variable If    "${required_rfs}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_rfs_list}
    FOR    ${fr_serial_number}    IN    @{rf_list}
        ${RRU_Info}    Get RRU Info    serial_num=${fr_serial_number}
        ${RRU_IP}    Set Variable    ${RRU_Info['parameters']["ipAddress"]}
        ${bts_id}    Get Master BTS Id With RF serial Number     serial_num=${fr_serial_number}
        ${connection_id}   Set Variable    ${CASE_NAME}_${bts_id}
        ${ret1}    Run Keyword And Return Status    Should Start with
        ...     ${RRU_Info["parameters"]["productName"]}    AZ
        ${ret2}    Run Keyword And Return Status    Should Start with
        ...    ${RRU_Info["parameters"]["productName"]}    AA
        Run Keyword If    ${ret1}
        ...    Rf Fault trigger with recovery Rel5     ${RRU_IP}    ${faultid}     ${connection_id}
        ...    ELSE IF    ${ret2}    Rf_Fault_trigger_with_recovery_MMIMO    ${RRU_IP}    ${faultid}
        ...    ${fr_serial_number}    ${connection_id}
        ...    ELSE    Rf Fault trigger with recovery    ${RRU_IP}    ${faultid}    ${connection_id}
    END
    Sleep    20s
    Wait For All Cells OnAir    timeout=480s
    Check Multinode Without Unexpect Alarm
    Make L3Call

RF Fault With recovery Action AZNA
    [Arguments]    ${faultid}    ${required_rfs}=${EMPTY}
    Set Test Variable    ${FAULTID}    ${faultid}

    ${required_rfs_list}    Split String    ${required_rfs}    :
    ${rf_list}    Set Variable If    "${required_rfs}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_rfs_list}
    FOR    ${fr_serial_number}    IN    @{rf_list}
        ${RRU_Info}    Get RRU Info    serial_num=${fr_serial_number}
        ${RRU_IP}    Set Variable    ${RRU_Info['parameters']["ipAddress"]}
        ${bts_id}    Get Master BTS Id With RF serial Number     serial_num=${fr_serial_number}
        ${connection_id}   Set Variable    ${CASE_NAME}_${bts_id}
        ${ret1}    Run Keyword And Return Status    Should Start with
        ...     ${RRU_Info["parameters"]["productName"]}    AZ
        ${ret2}    Run Keyword And Return Status    Should Start with
        ...    ${RRU_Info["parameters"]["productName"]}    AA
        Run Keyword If    ${ret1}
        ...    Rf Fault trigger with recovery Rel5 AZNA       ${RRU_IP}    ${faultid}
        ...    ${fr_serial_number}    ${bts_id}     ${connection_id}
        ...    ELSE IF    ${ret2}
        ...    Rf_Fault_trigger_with_recovery_MMIMO    ${RRU_IP}    ${faultid}
        ...    ${fr_serial_number}    ${connection_id}
        ...    ELSE    Rf Fault trigger with recovery    ${RRU_IP}    ${faultid}    ${connection_id}
    END
    Sleep    20s
    Wait For All Cells OnAir    timeout=480s
    Check Multinode Without Unexpect Alarm
    Make L3Call

RF Fault 4698 SFP transceiver temperrature too high
    [Arguments]    ${rf_sn}
    ${RRU_Info}    Get RRU Info    serial_num=${rf_sn}
    ${RRU_IP}    Set Variable    ${RRU_Info['parameters']["ipAddress"]}
    ${bts_id}    Get Master BTS Id With RF serial Number     serial_num=${rf_sn}
    ${connection_id}   Set Variable    ${CASE_NAME}_${bts_id}
    Run Keyword And Continue On Failure
    ...    RF Fault 4698 Trigger With Recovery     ${RRU_IP}    ${connection_id}
    ${para}    Create Dictionary    distName=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    paraName=actTransceiverAlarmMonitoring    paraValue=Transceiver alarms and warnings
    ${para_list}    Create List    ${para}
    Online Change Multi Parameters    ${para_list}    ${connection_id}
    Wait For All Cells OnAir    timeout=300s
    Check Multi Parameters Recommission Result    ${para_list}    ${connection_id}
    Run Keyword And Continue On Failure
    ...    RF Fault 4698 Trigger With Recovery     ${RRU_IP}    ${connection_id}
    Wait For All Cells OnAir    timeout=300s
    Check Multinode Without Unexpect Alarm

SISO Voltage Set And Powersaving Check
    [Arguments]    ${sleep_mode}=False    ${parameter_list}=${voltage_parameters}
    [Documentation]    Author:        haoyun-lyle.sheng@nokia-sbell.com
    ...                Maintainer:    haoyun-lyle.sheng@nokia-sbell.com
    ${connection_id}    Set Variable    ${CASE_NAME}_${MASTER_BTS_ID}
    ${parameter_list}   Evaluate    ${parameter_list}
    Online Change Multi Parameters    ${parameter_list}    ${connection_id}
    Wait For All Cells OnAir    ${ONAIR_TIME}
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        Exit For Loop If    '${sleep_mode}'=='False'
        Block Cell    ${cell_info}
    END
    Run Keyword And Continue On Failure    Check Multi Parameters Recommission Result    ${parameter_list}
    ...    ${connection_id}
    sleep    120 sec
    ${para}    Set Variable If    '${sleep_mode}'=='False'    voltage    power
    ${consumption}=    coam.get_parameters    /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1/POWER_MEASUREMENT_L-1
    ...    ${para}    connection=${connection_id}
    ${value}    Convert To Integer   ${consumption['consumption']['${para}']}
    Run Keyword If    '${sleep_mode}'=='False'    Run Keyword And Continue On Failure    Should Be True
    ...    ${value}>48000 and ${value}<54000
    ...    ELSE IF    '${sleep_mode}'=='True'    Run Keyword And Continue On Failure    Should Be True
    ...    ${value}<364900
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        Exit For Loop If    '${sleep_mode}'=='False'
        Unblock Cell   ${cell_info}
    END
    Check Alarms
    Check Historical Alarms     additional_allowed_alarms=Cell blocked
    Get And Check Reset Counter For All BTS Node    correct_reset_counter=0
    Make L3Call

BBOX File Check
    ${log_path}    Logging Save Snapshot    ${TEST_LOGS_DIR_PATH}    alias=${CASE_NAME}_${MASTER_BTS_ID}
    ${check results1}=    check bbox file contents    snapshot_path=${log_path}
    Run Keyword If    '${check results1}' != 'PASS'    Fail    ${check results1}
    ${log_path}    Logging Save Snapshot    ${TEST_LOGS_DIR_PATH}    alias=${CASE_NAME}_${MASTER_BTS_ID}    coverage=HealthCheck
    ${check results2}=    check bbox file contents        snapshot_path=${log_path}
    Run Keyword If    '${check results2}' != 'PASS'    Fail    ${check results2}

L3call Robustness
    [Arguments]    ${ping}=${False}    ${required_cells}=${Empty}
    4G Robustness    ping=${ping}    required_cells=${required_cells}

SISO Antenna Calibration Check
    [Documentation]   Auther: nick.1.wu@nokia-sbell.com
    [Arguments]    ${calibration_path}=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/tools/
    ...    ${log_name}=check_syslog_calibration.log
    ...    ${command}=${calibration_path}calibrationLogAnalyzer.py --log ${SUITE_LOGS_DIR_PATH}/${log_name} --bw 20M
#    ...    ${commadn_install}=${calibration_path}lib_install.py
#    run and return rc and output    python ${commadn_install}
    lib_install
    sleep    15 mins
    ute_syslog.Start syslog    log_dir=${SUITE_LOGS_DIR_PATH}    log_name=check_syslog_calibration.log
    ...    ip=192.168.255.126    alias=cb_check
    sleep    5 mins
    ute_syslog.Collect Syslog Results    unzip=true    alias=cb_check
    ${rc}    ${output}    run and return rc and output    python ${command}
    Log    ${output}
    should contain    ${output}    Ok
    should not contain    ${output}    NOk
    Check Historical Alarms

SISO Antenna Calibration Check ECPRI
    [Documentation]   Auther: nick.1.wu@nokia-sbell.com
    [Arguments]    ${required_rfs}=${EMPTY}    ${cell_list}=${ALL_CELL_LIST}    ${ru_password_user}=${EMPTY}
    ...    ${antenna_elements}=8
    Reset BTS Until Onair
    sleep    10 mins

#    ${required_rfs_list}    Split String    ${required_rfs}    :
#    ${rf_list}    Set Variable If    "${required_rfs_list}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_rfs_list}
#    FOR    ${fr_serial_number}    IN    @{rf_list}

    ${fr_serial_number}    Set Variable    ${required_rfs}
    ${rru_ip}    ${side_info}    ${rru_name}    Get RRU Side Info    ${fr_serial_number}
    ${host_ip}    ${bbu_ip}    Get BBU Side Info    ${side_info}
    ${ru_password_defualt}    Set Variable    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
    ${ru_password}    Set Variable If    '${ru_password_user}'!='${EMPTY}'    ${ru_password_user}
    ...    ${ru_password_defualt}
    ${out}    Send RRU Command Check Antenna Calibration ECPRI    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
    ...    ${ru_password}
    ${cali_info}    Split String    ${out}    Latest calibration:
    ${cell_need_to_use}    Choose Cells    ${cell_list}
    FOR    ${cell_info}    IN    @{cell_need_to_use}
        Continue For Loop If    "${cell_info['RF'][0]['serialNumber']}" != "${fr_serial_number}"
        ${status}    ${return}    Run Keyword And Ignore Error    Variable Should Exist    ${cell_info["earfcn"]}
        ${out_fcn}    Set Variable If    '${status}'=='FAIL'    ${cell_info["nrarfcn"]}    ${cell_info["earfcn"]}
        ${out_frequency}=    Run Keyword If    '${status}'=='PASS'    earfcn.change_earfcn_to_frequency    ${out_fcn}
        ...    ELSE IF    600000<${out_fcn}<2016666    Evaluate    3000+0.015*(${out_fcn}-600000)
        ...    ELSE IF    0<${out_fcn}<590000    Evaluate    0+(${out_fcn}-0)/200
        ...    ELSE    Evaluate    24250.08+0.06*(${out_fcn}-2016667)
        ${ret}    Match Cali RX Info    ${cali_info}    ${out_frequency}
        ...    Successfully calibrated antenna elements: ${antenna_elements}/${antenna_elements}
        Should Be True    "${ret}"=="PASS"
        ${ret}    Match Cali TX Info    ${cali_info}    ${out_frequency}
        ...    Successfully calibrated antenna elements: ${antenna_elements}/${antenna_elements}
        Should Be True    "${ret}"=="PASS"
    END
    Check Historical Alarms

SISO Antenna Calibration Check AEQP
    [Documentation]   Auther: nick.1.wu@nokia-sbell.com
    [Arguments]    ${required_rfs}=${EMPTY}    ${cell_list}=${ALL_CELL_LIST}
    Reset BTS Until Onair
    sleep    10 mins

#    ${required_rfs_list}    Split String    ${required_rfs}    :
#    ${rf_list}    Set Variable If    "${required_rfs_list}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_rfs_list}
#    FOR    ${fr_serial_number}    IN    @{rf_list}

    ${fr_serial_number}    Set Variable    ${required_rfs}
    ${rru_ip}    ${side_info}    ${rru_name}    Get RRU Side Info    ${fr_serial_number}
    ${host_ip}    ${bbu_ip}    Get BBU Side Info    ${side_info}
    ${out}    Send RRU Command Check Antenna Calibration AEQP    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
    ${cali_info}    Split String    ${out}    Latest calibration:
    ${cell_need_to_use}    Choose Cells    ${cell_list}
    FOR    ${cell_info}    IN    @{cell_need_to_use}
        Continue For Loop If    "${cell_info['RF'][0]['serialNumber']}" != "${fr_serial_number}"
        ${status}    ${return}    Run Keyword And Ignore Error    Variable Should Exist    ${cell_info["earfcn"]}
        ${out_fcn}    Set Variable If    '${status}'=='FAIL'    ${cell_info["nrarfcn"]}    ${cell_info["earfcn"]}
        ${out_frequency}=    Run Keyword If    '${status}'=='PASS'    earfcn.change_earfcn_to_frequency    ${out_fcn}
        ...    ELSE IF    600000<${out_fcn}<2016666    Evaluate    3000+0.015*(${out_fcn}-600000)
        ...    ELSE IF    0<${out_fcn}<590000    Evaluate    0+0.005*(${out_fcn}-0)
        ...    ELSE    Evaluate    24250.08+0.06*(${out_fcn}-2016667)
        ${ret}    Match Cali RX Info    ${cali_info}    ${out_frequency}
        ...    Successfully calibrated antenna elements: 64/64
        Should Be True    "${ret}"=="PASS"
        ${ret}    Match Cali TX Info    ${cali_info}    ${out_frequency}
        ...    Successfully calibrated antenna elements: 64/64
        Should Be True    "${ret}"=="PASS"
    END
    Check Historical Alarms

SiSo Alarm report in Test Dedicated State
    [Documentation]    Author:        haoyun-lyle.sheng@nokia-sbell.com
    ...                Maintainer:    haoyun-lyle.sheng@nokia-sbell.com
    Reset_to_Test_Dedicated
    Test Dedicated Downlink And Uplink Start
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        ${connection_id}    Set Variable    ${CASE_NAME}_${cell_info['btsId']}
        ${R_class_name}   Get R CELL Class Name   ${cell_info}
        ${cell_distname}    Get R Object Distname    class_name=${R_class_name}    id=${cell_info["cellId"]}
        ...    connection=${connection_id}
        coam.Block Cell    dist_name=${cell_distname}    timeout=30    connection=${connection_id}
        ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${cell_info["distName"]}    connection=${connection_id}
        Should Be Equal As Strings    ${cell_R_info["status"]["blockingState"]}    Blocked
        Wait Until Keyword Succeeds    30 sec    10 sec    coam.assert_alarm_active
        ...    parameters=faultId=49,severity=Critical,alarmingResource=${cell_distname}    connection=${connection_id}

        coam.Unblock Cell    dist_name=${cell_distname}    timeout=20    connection=${connection_id}
        ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${cell_info["distName"]}    connection=${connection_id}
        Should Be Equal As Strings    ${cell_R_info["status"]["blockingState"]}  Unblocked
        Wait Until Keyword Succeeds    30 sec    10 sec    coam.assert_alarm_inactive
        ...    parameters=faultId=49,severity=Critical,alarmingResource=${cell_distname}    connection=${connection_id}
    END
    [Teardown]    Run Keywords    Test Dedicated Downlink And Uplink Stop    AND    Reset_BTS_Until_Onair
    ...    AND    Check Historical Alarms    AND    Get And Check Reset Counter For All BTS Node
    ...    correct_reset_counter=2

Stability Test Model
    [Arguments]    ${duration}=10min    ${repetition}=${1}
    [Documentation]    Author:        xingxin.lou@nokia-sbell.com
    ...                Maintainer:    xingxin.lou@nokia-sbell.com
    ${fail_number}    Set Variable    ${0}
    ${reset_count}    Set Variable    ${0}
    FOR    ${i}    IN RANGE    ${repetition}
        ${status}    Run Keyword And Return Status    Reset_to_Test_Dedicated
        ${test_status}    Set Variable If   ${status}    PASS    FAIL
        ${fail_number}    Run Keyword If    "${test_status}"=="FAIL"    Run Keywords    Evaluate    ${fail_number}+1    AND
        ...    Reset BTS Until Onair    AND    Continue For Loop
        ...   ELSE    Set Variable    ${fail_number}
        sleep  ${duration}
        Check Alarms
        Check Historical Alarms
        Reset BTS Until Onair
        ${reset_count}   Evaluate    ${reset_count}+2
    END
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=${reset_count}
    Should Be Equal As Integers    ${fail_number}    ${0}

SWDL For Factory Load SW RRU
    [Arguments]    ${fr_serial_number}
    ${rru_ip}    ${side_info}    ${rru_name}    Get RRU Side Info    ${fr_serial_number}
    ${host_ip}    ${bbu_ip}    Get BBU Side Info    ${side_info}
    Upload RF Image To FR    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
    ...    /run/    ${tl_config.RF_FACTORY_SW_STORAGE['${fr_serial_number}']['IMAGE_FILE']}    ${fr_serial_number}
    ${ret1}    ${output}    Run Keyword And Ignore Error    Variable Should Exist
    ...    ${tl_config.RF_FACTORY_SW_STORAGE['${fr_serial_number}']['LRM']}
    ${ret2}    ${output}    Run Keyword And Ignore Error    Variable Should Exist
    ...    ${tl_config.RF_FACTORY_SW_STORAGE['${fr_serial_number}']['SRM']}
    Run Keyword If    '${ret1}' == 'PASS'
    ...    Upgrade LRM RF Image To FR    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
    ...    /run/    ${tl_config.RF_FACTORY_SW_STORAGE['${fr_serial_number}']['IMAGE_FILE']}    ${fr_serial_number}
    ...    ELSE IF    '${ret2}' == 'PASS'
    ...    Upgrade SRM RF Image To FR    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
    ...    /run/    ${tl_config.RF_FACTORY_SW_STORAGE['${fr_serial_number}']['IMAGE_FILE']}    ${fr_serial_number}
    ...    ELSE      Upgrade RF Image To FR    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
    ...    /run/    ${tl_config.RF_FACTORY_SW_STORAGE['${fr_serial_number}']['IMAGE_FILE']}    ${fr_serial_number}
    PDU Turn Off Unit    pdu_type=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['port']}
    PDU Turn On Unit    pdu_type=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['port']}
#    Send Ping RRU Command via SSH    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
    Check RRU Incompatible Alarm And Upgrade    ${fr_serial_number}
    Wait Until Keyword Succeeds    ${ONAIR_TIME}    30 sec    Verify All Cells OnAir
    Check Alarms
    Make L3Call

SWDL For Incompatible Load SW RRU
    [Documentation]   Auther: nick.1.wu@nokia-sbell.com
    [Arguments]    ${fr_serial_number}    ${required_cells}=${EMPTY}
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        Make L3Call    required_cells=${required_cells}

        ${sw_version}    ${sw_release}    Get Node SW Build And Release    ${NODE_CFG["${bts_id}"].node}
        ${rru_ip}    ${side_info}    ${rru_name}    Get RRU Side Info    ${fr_serial_number}
        ${host_ip}    ${bbu_ip}    Get BBU Side Info    ${side_info}

        Run Keyword If    '${sw_release}' == 'SBTS00'
        ...    Upload Incompatible RF Image To FR    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
        ...    /run/    ${tl_config.RF_INCOMPATIBLE_SW_STORAGE['${fr_serial_number}']['IMAGE_FILE_23R2']}
        ...    ${fr_serial_number}    ${sw_release}
        ...    ELSE IF    '${sw_release}' == 'SBTS23R2'
        ...    Upload Incompatible RF Image To FR    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
        ...    /run/    ${tl_config.RF_INCOMPATIBLE_SW_STORAGE['${fr_serial_number}']['IMAGE_FILE_23R1']}
        ...    ${fr_serial_number}    ${sw_release}
        ...    ELSE    Upload Incompatible RF Image To FR    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
        ...    /run/    ${tl_config.RF_INCOMPATIBLE_SW_STORAGE['${fr_serial_number}']['IMAGE_FILE_22R4']}
        ...    ${fr_serial_number}    ${sw_release}

        ${ret1}    ${output}    Run Keyword And Ignore Error    Variable Should Exist
        ...    ${tl_config.RF_INCOMPATIBLE_SW_STORAGE['${fr_serial_number}']['LRM']}
        ${ret2}    ${output}    Run Keyword And Ignore Error    Variable Should Exist
        ...    ${tl_config.RF_INCOMPATIBLE_SW_STORAGE['${fr_serial_number}']['SRM']}

        Run Keyword If    '${ret1}' == 'PASS' and '${sw_release}' == 'SBTS00'
        ...    Upgrade Incompatible LRM RF Image To FR    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
        ...    /run/    ${tl_config.RF_INCOMPATIBLE_SW_STORAGE['${fr_serial_number}']['IMAGE_FILE_23R2']}
        ...    ${fr_serial_number}    ${sw_release}
        ...    ELSE IF    '${ret1}' == 'PASS' and '${sw_release}' == 'SBTS23R2'
        ...    Upgrade Incompatible LRM RF Image To FR    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
        ...    /run/    ${tl_config.RF_INCOMPATIBLE_SW_STORAGE['${fr_serial_number}']['IMAGE_FILE_23R1']}
        ...    ${fr_serial_number}    ${sw_release}
        ...    ELSE IF    '${ret1}' == 'PASS' and '${sw_release}' == 'SBTS23R1'
        ...    Upgrade Incompatible LRM RF Image To FR    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
        ...    /run/    ${tl_config.RF_INCOMPATIBLE_SW_STORAGE['${fr_serial_number}']['IMAGE_FILE_22R4']}
        ...    ${fr_serial_number}    ${sw_release}
        ...    ELSE IF    '${ret2}' == 'PASS' and '${sw_release}' == 'SBTS00'
        ...    Upgrade Incompatible SRM RF Image To FR    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
        ...    /run/    ${tl_config.RF_INCOMPATIBLE_SW_STORAGE['${fr_serial_number}']['IMAGE_FILE_23R2']}
        ...    ${fr_serial_number}    ${sw_release}
        ...    ELSE IF    '${ret2}' == 'PASS' and '${sw_release}' == 'SBTS23R2'
        ...    Upgrade Incompatible SRM RF Image To FR    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
        ...    /run/    ${tl_config.RF_INCOMPATIBLE_SW_STORAGE['${fr_serial_number}']['IMAGE_FILE_23R1']}
        ...    ${fr_serial_number}    ${sw_release}
        ...    ELSE IF    '${ret2}' == 'PASS' and '${sw_release}' == 'SBTS23R1'
        ...    Upgrade Incompatible SRM RF Image To FR    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
        ...    /run/    ${tl_config.RF_INCOMPATIBLE_SW_STORAGE['${fr_serial_number}']['IMAGE_FILE_22R4']}
        ...    ${fr_serial_number}    ${sw_release}
        ...    ELSE IF    '${ret1}' == 'FAIL' and '${sw_release}' == 'SBTS00'
        ...    Upgrade Incompatible RF Image To FR    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
        ...    /run/    ${tl_config.RF_INCOMPATIBLE_SW_STORAGE['${fr_serial_number}']['IMAGE_FILE_23R2']}
        ...    ${fr_serial_number}    ${sw_release}
        ...    ELSE
        ...    Upgrade Incompatible RF Image To FR    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
        ...    /run/    ${tl_config.RF_INCOMPATIBLE_SW_STORAGE['${fr_serial_number}']['IMAGE_FILE_22R4']}
        ...    ${fr_serial_number}    ${sw_release}

        PDU Turn Off Unit    pdu_type=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['type']}
        ...    pdu_ip=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['ip_addr']}
        ...    pdu_port=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['port']}
        PDU Turn On Unit    pdu_type=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['type']}
        ...    pdu_ip=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['ip_addr']}
        ...    pdu_port=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['port']}

    #    Send Ping RRU Command via SSH    ${host_ip}    ${bbu_ip}    ${rru_ip}    ${side_info}
        Check RRU Incompatible Alarm With Incompatible SW And Upgrade    ${fr_serial_number}    ${sw_release}
        Wait Until Keyword Succeeds    ${ONAIR_TIME}    30 sec    Verify All Cells OnAir
        Check Alarms
        Make L3Call    required_cells=${required_cells}
    END

Automated SiSo BS FV EAC Alarm Input on RFM
    ${EAC_info}    Evaluate    ${EAC_info}
    Set Test Variable    ${EAC_info}
    FOR    ${bts_id}    IN    @{BTS_LIST}
        ${out_eac_alarm_list}    Get EAC Alarm Info     ${bts_id}
        Should not be empty    ${out_eac_alarm_list}
        BS FV EAC Alarm Input on RFM    ${EAC_info["IP"]}    ${out_eac_alarm_list}    ${bts_id}
    END
    #Make L3call

Hot Remove Insert Same Band FR HZ
    [Arguments]    ${parameter_list}    ${rf_sn}= ${EMPTY}
    ${RFgroup}    Evaluate    ${FR_SERIAL_NUMBER_SAME_BAND}
    PDU Turn On Unit    pdu_type=${BTS_CONFIG['FR']['${RFgroup['${rf_sn}']}']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FR']['${RFgroup['${rf_sn}']}']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FR']['${RFgroup['${rf_sn}']}']['pdu']['port']}
    ${ggmapdict}    Evaluate    ${GGMAP}
    ${parameter_list}   Evaluate    ${parameter_list}
    ${btsIdList}    Get RRU Connected BtsId    ${rf_sn}
    ${connection_id}    Set Variable    ${CASE_NAME}_${btsIdList[0]}
    ${cablink_r}     coam.Get Managed Objects    CABLINK_R    connection=${connection_id}
    ${rmod_r}     coam.Get Managed Objects    RMOD_R    connection=${connection_id}
    ${smod_r}     coam.Get Managed Objects    SMOD_R    connection=${connection_id}
    ${bbmod_r}     coam.Get Managed Objects    BBMOD_R    connection=${connection_id}
    ${topo}    get_current_topo    ${cablink_r}    ${rmod_r}    ${bbmod_r}    ${smod_r}
    ${breaked_link_list}    get_breaked_link_list    ${topo}    ${ggmapdict}    ${rf_sn}
    FOR    ${link}    IN    @{breaked_link_list}
        Break Link    ${tl_config.FW_INFO['IP']}    ${tl_config.FW_INFO['USERNAME']}
        ...    ${tl_config.FW_INFO['PASSWORD']}    ${link}
        ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}
    END
    coam.assert_alarm_active    parameters=faultId=10,severity=Critical    timeout=300    connection=${connection_id}
    ${connect_link_list}    get_connect_link_list    ${topo}    ${ggmapdict}    ${RFgroup}    ${rf_sn}
    FOR    ${link}    IN    @{connect_link_list}
        Connect Link    ${tl_config.FW_INFO['IP']}    ${tl_config.FW_INFO['USERNAME']}
        ...    ${tl_config.FW_INFO['PASSWORD']}    ${link}
        ...    FW_type=${tl_config.FW_INFO['TYPE']}
    END
    Software Check And Correct
    ${status}    run keyword and return status    coam.assert_alarm_active    parameters=faultId=1807,severity=Critical
        ...    timeout=300    connection=${connection_id}
    run keyword if    ${status}    Online Change Multi Parameters    ${parameter_list}    connection=${connection_id}
    Wait Until Keyword Succeeds    10 min    10 sec    Verify All Cells OnAir

SiSo Recovery Hot Remove And Insert RF Fibers
    [Arguments]    ${rflink}={'L1202407672': ['primary', 'secondary']}
    ${linkdict}    Evaluate    ${rflink}
    ${ggmapdict}    Evaluate    ${GGMAP}
    ${rfs}    Get Dictionary Keys    ${linkdict}
    FOR    ${rf}    IN    @{rfs}
        ${btsIdList}    Get RRU Connected BtsId    ${rf}
        ${connection_id}    Set Variable    ${CASE_NAME}_${btsIdList[0]}
        ${cablink_r}     coam.Get Managed Objects    CABLINK_R    connection=${connection_id}
        ${rmod_r}     coam.Get Managed Objects    RMOD_R    connection=${connection_id}
        ${smod_r}     coam.Get Managed Objects    SMOD_R    connection=${connection_id}
        ${bbmod_r}     coam.Get Managed Objects    BBMOD_R    connection=${connection_id}
        ${topo}    get_current_topo    ${cablink_r}    ${rmod_r}    ${bbmod_r}    ${smod_r}
        ${primary}    ${return}    run keyword and ignore error    Should Contain    ${linkdict['${rf}']}    primary
        ${secondary}    ${return}    run keyword and ignore error    Should Contain    ${linkdict['${rf}']}    secondary
        ${linkpri}    ${linktype}     get_selected_link    ${topo}    ${ggmapdict}    ${rf}      primary
        ${linksec}    ${linktype}     get_selected_link    ${topo}    ${ggmapdict}    ${rf}      secondary
        Set Test Variable    ${linkpri}
        Set Test Variable    ${linksec}
        Run Keyword IF    '${primary}'== 'PASS'    Break Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${linkpri}
        ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}
        Run Keyword IF    '${secondary}'== 'PASS'    Break Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${linksec}
        ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}
        ${status}    ${btsIds}    Run Keyword And Ignore Error    Should Contain    ${linktype}
        ...    eCpri    ignore_case=True
        # and '${status}'=='FAIL'
        Run Keyword If     '${primary}'== 'PASS'    coam.assert_alarm_active
        ...    parameters=faultId=10
        ...    timeout=300    connection=${connection_id}
        Run Keyword And Ignore Error    Run Keyword If     '${primary}'== 'PASS' and '${status}'=='FAIL'
        ...    coam.assert_alarm_active    parameters=faultId=2002    timeout=600    connection=${connection_id}
        Run Keyword If     '${primary}'== 'FAIL' and '${secondary}'== 'PASS'
        ...    coam.assert_alarm_active    parameters=faultId=2002    timeout=600    connection=${connection_id}
        Run Keyword IF    '${primary}'== 'PASS'    Connect Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${linkpri}
        ...    FW_type=${tl_config.FW_INFO['TYPE']}
        Run Keyword IF    '${secondary}'== 'PASS'    Connect Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${linksec}
        ...    FW_type=${tl_config.FW_INFO['TYPE']}
    END
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    [Teardown]    Run Keyword And Ignore Error    Run Keywords
    ...    Connect Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${linkpri}
    ...    FW_type=${tl_config.FW_INFO['TYPE']}
    ...    AND    Connect Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${linksec}
    ...    FW_type=${tl_config.FW_INFO['TYPE']}

Automated RF Diagnostic Test
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
        Run Keyword And Continue On Failure    Admin Alarms Get And Check    allowed=${GLO_ADMIN_ALLOWED_ALARM}
        ...    alias=${connection_id}
    END
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        ${lcrid}    Set Variable    ${cell_info["lcrId"]}
        ${cellType}   Set Variable If  "${cell_info["NetworkType"]}"=="SA"  NR
        ...    "${cell_info["NetworkType"]}"=="NSA"  NR
        ...    "${cell_info["NetworkType"]}"=="4G"  LTE
#        ${m_band}    Set Variable    ${cell_info["band"]}
        Run RF Diagnostic Test    ${lcrid}    ${cellType}    alias=rfDiagnosticTest_${bts_id}
#        Get And Check RF Diagnostic Test Result    alias=rfDiagnosticTest_${bts_id}
        Run Keyword If    "${cellType}"=="NR"    Get And Check RF Diagnostic Test Result 5G    alias=rfDiagnosticTest_${bts_id}
        ...    ELSE IF    "${cellType}"=="LTE"    Get And Check RF Diagnostic Test Result 4G    alias=rfDiagnosticTest_${bts_id}
    END
    Verify All Cells OnAir
    Check Alarms
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Automated SiSo Calibration Switch
    [Arguments]    ${fr_serial_number}
    [Documentation]    Author:        bibo.lei@nokia-sbell.com
    ...                Maintainer:    haoyun-lyle.sheng@nokia-sbell.com
    ${RRU_Info}    Get RRU Info    serial_num=${fr_serial_number}
    ${RRU_IP}    Set Variable    ${RRU_Info['parameters']["ipAddress"]}
    ${bts_id}    Get Master BTS Id With RF serial Number     serial_num=${fr_serial_number}
    ${connection_id}   Set Variable    ${CASE_NAME}_${bts_id}
    Calibration Port Switch Time Window Setup    +7hour    +8hour    ${bts_id}
    Reset BTS Until Onair
    ${cell_list}    Get Cells State On Specific FR    ${fr_serial_number}
    ${tmp_lncell}     Set Variable    ${cell_list[0]["distName"]}
    ${xpath}    Set Variable
    ...     .//managedObject[contains(@class,'NOKLTE:LNCEL_TDD') and contains(@distName,'${tmp_lncell}')]
    ${tmp_mmimo_config}=    Get Element Text    ${cell_list[0]["scfc"]}    xpath=${xpath}/p[@name="mMimoAntArrayMode"]
    ${temp_ret}    ${orientation}    ${path_num}=
    ...     Should Match Regexp    ${tmp_mmimo_config}    (.+)\\s(\\d+)TRX\\sArray\\s\\(\\dx\\dx2\\)
    ${pipe}    Set Variable If    "${path_num}"=="${64}"    ${8}    ${4}
    ${fault_6051_cmd_list}    ${unexpected_ports}    fault_6051_calcuate    ${orientation}    ${pipe}
    Log To Console    Wait about 15 mins for fault 1911 and 6051
    ${RF_fault_info}    Evaluate    ${RF_fault_info}
    Wait Until Keyword Succeeds    600 sec    10 sec    Send Fault 1911 Command    ${RRU_IP}    ${fault_6051_cmd_list}
    ...    ${RF_fault_info}    ${connection_id}
#    Send RRU Command Mmimo    ${RRU_IP}    ${fault_6051_cmd_list}    ${RF_fault_info['6051']['port']}
#    Wait Until Keyword Succeeds    600 sec    10 sec    coam.assert_alarm_active
#    ...    parameters=faultId=1911    connection=${connection_id}
    Wait Until Keyword Succeeds    1200 sec    10 sec    coam.assert_alarm_active
    ...    parameters=faultId=6051    connection=${connection_id}
    coam.assert_alarm_inactive    parameters=faultId=4650    connection=${connection_id}
    ${get_objects}    coam.get_managed_objects     class_name=RMOD_R    connection=${connection_id}
    Should Be True    '${get_objects[0]['parameters']['calibrationPortsInUse']}'=='37'
    Calibration Port Switch Time Window Setup    +8hour3minutes    +9hour    ${bts_id}
    Log To Console    Wait about 5 mins for fault 4650
#    Wait Until Keyword Succeeds    600 sec    10 sec    coam.assert_alarm_active
#    ...    parameters=faultId=4650    timeout=5    connection=${connection_id}
    ute_admin_infomodel.setup_infomodel    address=${BTS_HOST}    alias=${connection_id}
    Check Alarm Active    parameters=faultId=4650    connection=${connection_id}    timeout=600
    ${get_objects}    coam.get_managed_objects     class_name=RMOD_R    connection=${connection_id}
    Should Be True    '${get_objects[0]['parameters']['calibrationPortsInUse']}'=='20'
    Wait Until Keyword Succeeds    300 sec    10 sec    coam.assert_alarm_inactive    parameters=faultId=6051
    ...    connection=${connection_id}
    Log To Console    Wait about 20mins for antenna calibration checking
    Antenna Calibration Check Without Unexpected Ports    ${unexpected_ports}
    Get And Check Reset Counter For All BTS Node    correct_reset_counter=1
    Make L3Call
    [Teardown]    Run Keyword And Continue On Failure    Run Keywords
    ...    Send RRU Command Mmimo    ${RRU_IP}    reboot    22    AND    Sleep    20
    ...    AND    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    ...    AND    Run Keyword And Ignore Error    ute_admin_infomodel.teardown_all_aliases_for_infomodel

Stability Site Reset
    [Arguments]    ${timeout}=${ONAIR_TIME}    ${repetition}=${1}
    [Documentation]    Author:        amy.wu@nokia-sbell.com
    ...                Maintainer:    amy.wu@nokia-sbell.com
    ${fail_number}    Set Variable    ${0}
    ${count}    Evaluate    ${repetition}-1
    FOR    ${i}    IN RANGE    ${repetition}
        ${status}    Run Keyword And Return Status   Site Reset    ${timeout}
        ${test_status}    Set Variable If   ${status}    PASS    FAIL
        ${fail_number}    Run Keyword If    "${test_status}"=="FAIL"    Evaluate    ${fail_number}+1
        ...    ELSE    Set Variable    ${fail_number}
        Run Keyword If    ${i} != ${count}    Logging Multinode Restart    test_status=${test_status}
    END
    Should Be Equal As Integers    ${fail_number}    ${0}


NR_RAT_reset_for_concurrent
    [Arguments]    ${required_cells}=${EMPTY}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    Log    ${extra_peak_rate_config}
    Get NR and LTE Cell List
    ${Due_mode_rru_list}    Create List
    ${Due_mode_rru_list}    Get Due Mode RRU List    ${NR_CELL_LIST}     ${LTE_CELL_LIST}
    FOR    ${fr_sn}    IN    @{Due_mode_rru_list}
        Remove Invalid Cell    ${fr_sn}
    END
    RAT reset and make L3call for concurrent    NR    ${LTE_CELL_LIST}    ${required_cells}
    sleep    180
    Verify All Cells OnAir


LTE_RAT_reset_for_concurrent
    [Arguments]    ${required_cells}=${EMPTY}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    Log    ${extra_peak_rate_config}
    Get NR and LTE Cell List
    ${Due_mode_rru_list}    Create List
    ${Due_mode_rru_list}    Get Due Mode RRU List    ${NR_CELL_LIST}     ${LTE_CELL_LIST}
    FOR    ${fr_sn}    IN    @{Due_mode_rru_list}
        Remove Invalid Cell    ${fr_sn}
    END
    RAT reset and make L3call for concurrent    LTE    ${NR_CELL_LIST}    ${required_cells}
    sleep    180
    Verify All Cells OnAir

RAT reset from WebEm For NR testline
    [Arguments]    ${required_cells}=${EMPTY}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    Log    ${extra_peak_rate_config}
    Get NR and LTE Cell List
    RAT reset and make L3call    NR    ${required_cells}
    sleep    180
    Verify All Cells OnAir

RAT reset from WebEm For LTE testline
    [Arguments]    ${required_cells}=${EMPTY}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    Log    ${extra_peak_rate_config}
    Get NR and LTE Cell List
    RAT reset and make L3call    LTE    ${required_cells}
    sleep    180
    Verify All Cells OnAir

SiSo Multi Parameters Recommissioning
    [Arguments]    ${para_list}    ${object_list}=${EMPTY}    ${required_cells}=${Empty}
    ...    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${ping}=${True}
    [Documentation]    Author:     haoyun-lyle.sheng@nokia-sbell.com; xingxin.lou@nokia-sbell.com
    ...                Maintainer: haoyun-lyle.sheng@nokia-sbell.com; xingxin.lou@nokia-sbell.com
    ${online_para_dict}    Create Dictionary
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        ${bts_para_list}    Create List
        ${online_para_dict}    Set To Dictionary    ${online_para_dict}    ${bts_id}    ${bts_para_list}
    END
    ${require_reset_paras}    Create List
    FOR    ${para}    IN    @{para_list}
        ${dist_name_split}    Split String    ${para["dist_name"]}    /
        ${bts_id_split}    Split String    ${dist_name_split[0]}    -
        Set To Dictionary    ${para}    bts_id    ${bts_id_split[1]}
        Run Keyword If    '${para['require_reset']}'=='True'    Append To List    ${require_reset_paras}    ${para}
        ...    ELSE    Append To List    ${online_para_dict['${bts_id_split[1]}']}    ${para}
    END
    log to console     ${online_para_dict}
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        ${ret}    Run Keyword And Return Status    Should Be Equal    '${online_para_dict['${bts_id}']}'   '[]'
        Continue For Loop if    ${ret}
        Multi Parameters Recommission And Check BTS Reset   ${online_para_dict['${bts_id}']}    ${object_list}
        ...    ${bts_id}
    END
    FOR    ${para}    IN    @{require_reset_paras}
        ${is_para_exist}    Run Keyword And Return Status    Variable Should Exist    ${para["required_reset_bts_id"]}
        ${required_bts_id}    Set Variable If    ${is_para_exist}    ${para["required_reset_bts_id"]}    ${EMPTY}
        Multi Parameters Recommission And Check BTS Reset    ${para}    ${object_list}    ${para["bts_id"]}    True
        ...    ${required_bts_id}
    END
    Make L3call    ping=${ping}    required_cells=${required_cells}    extra_peak_rate_config=${extra_peak_rate_config}
    Check Alarms
    Check Historical Alarms

General SISO Online Cell Addition Deletion
    [Arguments]    ${addition_deletion_cell}    ${required_cells}=${EMPTY}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${repetition}=${2}
    [Documentation]    Author:        amy.wu@nokia-sbell.com
    ...                Maintainer:    amy.wu@nokia-sbell.com
    ${addition_deletion_cell_list}    Split String    ${addition_deletion_cell}    :
    ${cell_list}    Create List
    ${bts_id_list}    Create List
    FOR    ${pci}    IN    @{addition_deletion_cell_list}
        ${cell_info}   Get Cell Info With PCI    ${ALL_CELL_LIST}    ${pci}
        Append To List    ${cell_list}    ${cell_info}
        Append To List    ${bts_id_list}    ${cell_info["btsId"]}
    END
    ${bts_id_list}    Remove Duplicates    ${bts_id_list}
    ${required_cells_after_deletion}    Remove Cells    ${required_cells}    ${cell_list}
    MultiNode Selenium Login    ${bts_id_list}
    FOR    ${index}    IN RANGE    ${repetition}
        Cells deletion With Selenium     ${cell_list}
        MultiNode Selenium Activate    ${bts_id_list}
        Remove Values From List    ${ALL_CELL_LIST}    @{cell_list}
        Verify All Cells OnAir
        Check Cells Deletion Not Exist    ${cell_list}
        Make Tput    required_cells=${required_cells_after_deletion}    extra_peak_rate_config=${extra_peak_rate_config}
        Cells Addition With Selenium    ${cell_list}    ${bts_id_list}
        MultiNode Selenium Activate    ${bts_id_list}
        Append To List    ${ALL_CELL_LIST}    @{cell_list}
        Wait For All Cells OnAir    timeout=5 min
        Make Tput    required_cells=${required_cells}    extra_peak_rate_config=${extra_peak_rate_config}
    END
    Check Alarms
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]    Run Keyword And Ignore Error    MultiNode Selenium Logout    ${bts_id_list}

Update Sw To Target
    [Arguments]    ${UpToTarget}=YES    ${TROLLBACK}=YES    ${rollback}=${RB_TO_TARGET}    ${T1}=NO    ${T2}=NO
    ...    ${target_builds}=${TARGET_SW_VERSION}    ${L3Call}=NO
    ${TARGET_SW_VERSION_DICT}    Evaluate    ${target_builds}
    ${btsIds}    Get Dictionary Keys    ${TARGET_SW_VERSION_DICT}
    ${host_ip_list}    Get Dictionary Values    ${BTS_CONFIG["HOST_IP"]}
    #FOR    ${host_ip}    IN    @{host_ip_list}
    #     Setup eNB FSM Access    host=${BTS_HOST}    timeout=15    remote_host=${host_ip}    alias=rm_ps_${host_ip}
    #     Run Keyword And Ignore Error    execute_command_on_enb    cmd=mount -o remount,rw /ffs/stb
    #     ...    alias=rm_ps_${host_ip}
    #     Run Keyword And Ignore Error    execute_command_on_enb    cmd=rm -r /ffs/stb/*    alias=rm_ps_${host_ip}
    #END
    ${btsNum}    Get Length    ${btsIds}
    FOR    ${btsId}   IN    @{btsIds}
        Set Test Variable    ${swVersion}    ${PRE_NODE_CFG['${btsId}']['software_active']}
        ${swVersion}    Get From Dictionary    ${TARGET_SW_VERSION_DICT}    ${btsId}
        ${status}    ${return}    Run Keyword And Ignore Error    Variable Should Exist    ${CURRENT_SW_${btsId}}
        Run Keyword IF    '${swVersion}'==''    Set Test Variable    ${swVersion}
        ...    ${PRE_NODE_CFG['${btsId}']['software_active']}
        ${status}    ${return}    Run Keyword And Ignore Error    Variable Should Exist    ${ENB_BUILD}
        Run Keyword IF    '${status}'=='PASS'    Set Test Variable    ${swVersion}    ${ENB_BUILD}
        ${status}    ${return}    Run Keyword And Ignore Error    Variable Should Exist    ${PKG_TYPE}
        ${type}    Set Variable If    '${status}'=='FAIL'    Normal    ${PKG_TYPE}
        Run Keyword IF    '${UpToTarget}'=='YES'    Download SW Build    ${swVersion}    type=${type}
        ${files}    OperatingSystem.List Files In Directory    ${SW_BUILDS_DIR_PATH}
        ${matched_file}    Get Matches   ${files}    ${swVersion}*
        Run Keyword IF    '${UpToTarget}'=='YES'    Wait Until Keyword Succeeds    20 min    30 sec
        ...    coam.Update Software    ${SW_BUILDS_DIR_PATH}/${matched_file[0]}    timeout=3600
        ...    connection=${CASE_NAME}_${btsId}
        Run Keyword IF    '${T1}'=='YES'    sw_package_download   ${swVersion}   target_dir=${SW_BUILDS_DIR_PATH}
        ...    package_type=T1
    END
    Run Keyword IF    '${UpToTarget}'=='YES'    sleep    180s
    Run Keyword IF    '${UpToTarget}'=='YES'    Wait Until Keyword Succeeds    480    30
    ...     Create Nodes Parameters Init    ${GLO_CONFIG_ID}
    ${start_datetime}  DateTime.Get Current Date
    Run Keyword IF    '${UpToTarget}'=='YES'    Run Keyword And Ignore Error
    ...    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}/UpToTarget_${start_datetime}
    Run Keyword IF    '${UpToTarget}'=='YES'    Logging Multinode Start
    FOR    ${btsId}   IN    @{btsIds}
        Run Keyword IF    '${UpToTarget}'=='YES'    Wait Until Keyword Succeeds    600    30
        ...    Verify SMOD BBMOD Enabled    ${btsId}    ${CASE_NAME}_${btsId}
        Run Keyword IF    '${UpToTarget}'=='YES'    Wait For All Cells OnAir    ${ONAIR_TIME}
        Run Keyword IF    '${UpToTarget}'=='YES'    Check Alarms
    END
    Run Keyword IF    '${L3Call}'=='YES'    Make L3Call
    FOR    ${btsId}   IN    @{btsIds}
        Run Keyword IF    '${TROLLBACK}'=='YES'    coam.rollback_software
        ...    connection=${CASE_NAME}_${btsId}    timeout=1200
    END
    Run Keyword IF    '${TROLLBACK}'=='YES'    sleep    180s
    Run Keyword IF    '${TROLLBACK}'=='YES'    Wait Until Keyword Succeeds    480    30
    ...    Create Nodes Parameters Init    ${GLO_CONFIG_ID}
    ${start_datetime}  DateTime.Get Current Date
    Run Keyword IF    '${TROLLBACK}'=='YES'    Run Keyword And Ignore Error
    ...    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}/rollback_${start_datetime}
    Run Keyword IF    '${TROLLBACK}'=='YES'    Logging Multinode Start
    FOR    ${btsId}   IN    @{btsIds}
        Run Keyword IF    '${TROLLBACK}'=='YES'    Wait Until Keyword Succeeds    600    30
        ...    Verify SMOD BBMOD Enabled    ${btsId}    ${CASE_NAME}_${btsId}
        Run Keyword IF    '${TROLLBACK}'=='YES'    Wait For All Cells OnAir    ${ONAIR_TIME}
        Run Keyword IF    '${TROLLBACK}'=='YES'    Check Alarms
    END
    FOR    ${btsId}   IN    @{btsIds}
        ${files}    OperatingSystem.List Files In Directory    ${SW_BUILDS_DIR_PATH}
        ${matched_file}    Get Matches   ${files}    ${swVersion}*T1*
        Run Keyword IF    '${T1}'=='YES'    Wait Until Keyword Succeeds    20 min    30 sec    coam.Update Software
        ...    ${SW_BUILDS_DIR_PATH}/${matched_file[0]}    timeout=3600    connection=${CASE_NAME}_${btsId}
        Run Keyword IF    '${T2}'=='YES'    sw_package_download   ${swVersion}   target_dir=${SW_BUILDS_DIR_PATH}
        ...    package_type=T2
    END
    Run Keyword IF    '${T1}'=='YES'    sleep    180s
    Run Keyword IF    '${T1}'=='YES'    Wait Until Keyword Succeeds    480    30
    ...    Create Nodes Parameters Init    ${GLO_CONFIG_ID}
    Run Keyword IF    '${T1}'=='YES'    Run Keyword And Ignore Error    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}
    Run Keyword IF    '${T1}'=='YES'    Run Keyword And Ignore Error    Logging Multinode Start
    FOR    ${btsId}   IN    @{btsIds}
        Run Keyword IF    '${T1}'=='YES'    Wait For All Cells OnAir    ${ONAIR_TIME}
        Run Keyword IF    '${T1}'=='YES'    Check Alarms
    END
    FOR    ${btsId}   IN    @{btsIds}
        ${files}    OperatingSystem.List Files In Directory    ${SW_BUILDS_DIR_PATH}
        ${matched_file}    Get Matches   ${files}    ${swVersion}*T2*
        Run Keyword IF    '${T2}'=='YES'    Wait Until Keyword Succeeds    20 min    30 sec    coam.Update Software
        ...    ${SW_BUILDS_DIR_PATH}/${matched_file[0]}    timeout=3600    connection=${CASE_NAME}_${btsId}
    END
    Run Keyword IF    '${T2}'=='YES'    sleep    180s
    Run Keyword IF    '${T2}'=='YES'    Wait Until Keyword Succeeds    480    30
    ...    Create Nodes Parameters Init    ${GLO_CONFIG_ID}
    Run Keyword IF    '${T2}'=='YES'    Run Keyword And Ignore Error    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}
    Run Keyword IF    '${T2}'=='YES'    Run Keyword And Ignore Error    Logging Multinode Start
    FOR    ${btsId}   IN    @{btsIds}
        Run Keyword IF    '${rollback}'=='YES'    Wait Until Keyword Succeeds    600    30
        ...    Verify SMOD BBMOD Enabled    ${btsId}    ${CASE_NAME}_${btsId}
        Run Keyword IF    '${T2}'=='YES'    Wait For All Cells OnAir    ${ONAIR_TIME}
        Run Keyword IF    '${T2}'=='YES'    Check Alarms
    END
    FOR    ${btsId}   IN    @{btsIds}
        run keyword if    '${rollback}'=='YES'    coam.rollback_software
        ...    connection=${CASE_NAME}_${btsId}    timeout=1200
    END
    Run Keyword IF    '${rollback}'=='YES'    sleep    180s
    Run Keyword IF    '${rollback}'=='YES'    Wait Until Keyword Succeeds    480    30
        ...    Create Nodes Parameters Init    ${GLO_CONFIG_ID}
    ${start_datetime}  DateTime.Get Current Date
    Run Keyword IF    '${rollback}'=='YES'    Run Keyword And Ignore Error
        ...    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}/rollbackToTarget_${start_datetime}
    Run Keyword IF    '${rollback}'=='YES'    Run Keyword And Ignore Error    Logging Multinode Start
    FOR    ${btsId}   IN    @{btsIds}
        Run Keyword IF    '${rollback}'=='YES'    Wait Until Keyword Succeeds    600    30
        ...    Verify SMOD BBMOD Enabled    ${btsId}    ${CASE_NAME}_${btsId}
        Run Keyword IF    '${rollback}'=='YES'    Wait For All Cells OnAir    ${ONAIR_TIME}
        Run Keyword IF    '${rollback}'=='YES'    Check Alarms
    END
    [Teardown]    run keyword and ignore error  teardown_all_aliases_for_enb_fsmaccess

Manual_SiSo_STARTUP_Start-up_and_Detection_of_RF_Module
    [Documentation]    Author:        qiang.1.zhou@nokia-sbell.com
    ...                Maintainer:    qiang.1.zhou@nokia-sbell.com
    [Arguments]    ${required_rfs}=${EMPTY}
    ${required_rfs_list}    Split String    ${required_rfs}    :
    ${rf_list}    Set Variable If    "${required_rfs}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_rfs_list}
    FOR    ${fr_serial_number}    IN    @{rf_list}
        Restart RF And Check the Soap Msg    fr_serial_number=${fr_serial_number}
        Restart RF And Check the Soap Msg    fr_serial_number=${fr_serial_number}
        ${ru_info}    Get RRU Info    serial_num=${fr_serial_number}
        Check RU Pingable    ru_info=${ru_info}
    END

    Wait For All Cells OnAir    timeout=10 min
    Check Multinode Without Unexpect Alarm
    Check Historical Alarms    additional_allowed_alarms=No connection to unit:Failure in optical interface
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

SiSo_BTS_startup_with_delayed_RF_link
    [Documentation]    Author:        haoyun-lyle.sheng@nokia-sbell.com
    ...                Maintainer:    haoyun-lyle.sheng@nokia-sbell.com
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        BTS Startup With Delayed RF Link    ${bts_id}
    END
	Wait For All Cells OnAir    timeout=${ONAIR_TIME}
	Check Alarms
	Check Historical Alarms    additional_allowed_alarms=No connection to unit
	Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

General SiSo Online Sector Addition Deletion
    [Arguments]    ${antl_dict}    ${required_cells}=${EMPTY}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${repetition}=${2}
    [Documentation]    Author:        amy.wu@nokia-sbell.com
    ...                Maintainer:    amy.wu@nokia-sbell.com
    ${antl_dict}    Evaluate    ${antl_dict}
    ${fr_sn_list}    Get Dictionary Keys    ${antl_dict}
    ${cells_del_add}    Create List
    ${bts_id_list}    Create List
    FOR    ${fr_sn}    IN    @{fr_sn_list}
        ${cell_mapping_rf_list}    Get Cells On Specific FR ANTL    ${fr_sn}    ${antl_dict["${fr_sn}"]}
        ${rfs_bts_id}    Get Bts Id With FR Serial Number    ${fr_sn}
        Append To List    ${cells_del_add}    @{cell_mapping_rf_list}
        Append To List    ${bts_id_list}    @{rfs_bts_id}
    END
    ${bts_id_list}    Remove Duplicates    ${bts_id_list}
    ${cells_del_add}    Remove Duplicates    ${cells_del_add}
    ${required_cells_after_deletion}    Remove Cells    ${required_cells}    ${cells_del_add}
    MultiNode Selenium Login    ${bts_id_list}
    FOR    ${index}    IN RANGE    ${repetition}
        Cells deletion With Selenium    ${cells_del_add}
        MultiNode Selenium Activate    ${bts_id_list}
        Remove Values From List    ${ALL_CELL_LIST}    @{cells_del_add}
        Verify All Cells OnAir
        Check Cells Deletion Not Exist    ${cells_del_add}
        Make Tput    required_cells=${required_cells_after_deletion}    extra_peak_rate_config=${extra_peak_rate_config}
        Cells Addition With Selenium    ${cells_del_add}    ${bts_id_list}
        MultiNode Selenium Activate    ${bts_id_list}
        Append To List    ${ALL_CELL_LIST}    @{cells_del_add}
        Wait For All Cells OnAir    timeout=1 min
        Make Tput    required_cells=${required_cells}    extra_peak_rate_config=${extra_peak_rate_config}
    END
    Check Alarms
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]    Run Keyword And Ignore Error    MultiNode Selenium Logout    ${bts_id_list}

Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to collect Snapshot logs in WebUI
    ...    and check if RFSW logs from Radio Unit are included in Snapshot
    ${btsIdList}    Create List
    ${btsIds}    Get Dictionary Keys    ${NODE_CFG}
    FOR    ${btsId}    IN    @{btsIds}
        Check_RFSW_logs_In_BTS_Snapshot    ${btsId}
    END

Supercell_Super_Cell_Setup
    [Arguments]    ${required_cells}=${EMPTY}
    [Documentation]    Author:        nick.1.wu@nokia-sbell.com
    ...                Maintainer:    nick.1.wu@nokia-sbell.com

    ${cell_list}    Run Keyword If
    ...    '${required_cells}'!='${Empty}'   Get Rquired Cells   ${ALL_CELL_LIST}    ${required_cells}
    ...    ELSE    Choose Cells    ${ALL_CELL_LIST}

    FOR    ${cell_info}    IN    @{cell_list}
        Supercell Setup With Compare Number of subcells    ${cell_info}
    END
    Check Alarms
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

SuperCell Reconfiguration
    [Arguments]    ${required_cells}=${EMPTY}
    [Documentation]    Author:        amy.wu@nokia-sbell.com;haoyun-lyle.sheng@nokia-sbell.com
    ...                Maintainer:    amy.wu@nokia-sbell.com;haoyun-lyle.sheng@nokia-sbell.com
    ${cell_list}    Run Keyword If
    ...    '${required_cells}'!='${Empty}'   Get Rquired Cells   ${ALL_CELL_LIST}    ${required_cells}
    ...    ELSE    Choose Cells    ${ALL_CELL_LIST}

    SuperCell Reconfiguration With Half Subcell Deletion    ${cell_list}
    FOR    ${cell_info}    IN    @{cell_list}
         SuperCell Reconfiguration With Half Subcell Expansion    ${cell_info}
         SuperCell Reconfiguration With Half Subcell Split    ${cell_info}
    END
    Check Alarms
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=2

Power Reduction With Static DVM Parameters Into AZNA/AZHA
    [Arguments]    ${power_origin}   ${M40002C1_origin}   ${M40003C2_origin}   ${intervals}=15min  ${wait_for_counter}=30min
    [Documentation]    Author:        xingxin.lou@nokia-sbell.com
    ${connection_id}    Set Variable   ${CASE_NAME}_${MASTER_BTS_ID}
    coam.perform_parameter_recommissioning    dist_name=MRBTS-${MASTER_BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1   parameter=actPowerMeter
    ...    operation=update   value=true   connection=${connection_id}
    coam.perform_parameter_recommissioning    dist_name=MRBTS-${MASTER_BTS_ID}/MNL-1/MNLENT-1/PMMNL-1   parameter=mtBtsEnergyMonitoring
    ...    operation=update   value=${intervals}  connection=${connection_id}
    coam.perform_parameter_recommissioning    dist_name=MRBTS-${MASTER_BTS_ID}/MNL-1/MNLENT-1/PMMNL-1   parameter=mtSBTSSmEnergyMonitoring
    ...    operation=update   value=${intervals}   connection=${connection_id}
    coam.perform_parameter_recommissioning    dist_name=MRBTS-${MASTER_BTS_ID}/MNL-1/MNLENT-1/PMMNL-1   parameter=mtSBTSRfmEnergyMonitoring
    ...    operation=update   value=${intervals}   connection=${connection_id}
    Wait For All Cells OnAir    ${ONAIR_TIME}
    Check Alarms
    sleep    ${wait_for_counter}
    Selenium Login    alias=${connection_id}
    FOR  ${rru_serial_num}  IN  @{USED_FR_SN_LIST}
        ${rru_info}   Get RRU Info   ${rru_serial_num}
        ${rru_productName}  Set Variable  ${rru_info["parameters"]["productName"]}
        Continue For Loop If    "${rru_productName}"!="AZNA" and "${rru_productName}"!="AZHA"
        ${rmod_distname}    Get R Object Distname By SN    class_name=RMOD_R    sn=${rru_serial_num}    connection=${connection_id}
        ${rmod_distname_group}  Split String  ${rmod_distname}  /
        ${voltage_new}  ${power_new}   Get Latest Realtime Measurement   RMOD   measured_object=${rmod_distname_group[-1]}
        ...   connection=${connection_id}
        ${M40003C2_timestamp}  ${M40003C2_new}   Get Latest Counter Content    M40003C2   ${connection_id}
        Should Be True  ${power_new}<${power_origin}
        Should Be True  ${M40003C2_new}<${M40003C2_origin}
    END
    ${M40003C2_timestamp}  ${M40002C1_new}   Get Latest Counter Content    M40002C1   ${connection_id}
    Should Be True  ${M40002C1_new}<${M40002C1_origin}
    Check Alarms
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]   Selenium Logout   alias=${connection_id}

SuperCell Reconfiguration To Norall
    [Arguments]    ${required_cells}=${EMPTY}    ${pkrt}=${PEAK_RATE_CONFIG}
    [Documentation]    Author:        lisa.ding@nokia-sbell.com
    ...                Maintainer:    lisa.ding@nokia-sbell.com
    Run Keyword And Continue On Failure    Make Tput    extra_peak_rate_config=${pkrt}
    ${cell_list}    Run Keyword If
    ...    '${required_cells}'!='${Empty}'   Get Rquired Cells   ${ALL_CELL_LIST}    ${required_cells}
    ...    ELSE    Choose Cells    ${ALL_CELL_LIST}
    ${bts_id}    Set Variable    ${cell_list[0]["btsId"]}
    ${alias}    Set Variable    ${CASE_NAME}_${bts_id}_ui
    ${PRE_NODE_CFG}    Copy Dictionary    ${NODE_CFG}    deepcopy=True
    FOR    ${cell_info}    IN    @{cell_list}
         ${newcells}    All Subcell To Normal Cell    ${cell_info}    ${alias}
         ${pkrt}    Update Peak Rate Config With Cell Index    ${cell_info}    ${newcells}    ${pkrt}
    END
    Cells deletion With Selenium    ${cell_list}
    Selenium Active Plan    alias=${alias}
    Wait Until Keyword Succeeds    1 min    10 sec    Verify All Cells OnAir
    #$${new_cell_info}    Get Cell Info With PCI    ${cell_list}    ${cell_info["phyCellId"]}
    Run Keyword And Continue On Failure    Make Tput    extra_peak_rate_config=${pkrt}
    #${normal_cell_list}    Get Rquired Cells   ${cell_list}    ${normal_cells}
    Check Alarms
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Selenium Logout    alias=${alias}
    ...    AND    Set Test Variable    ${NODE_CFG}    ${PRE_NODE_CFG}
    ...    AND    MultiNode Template File Commissioning

WebEM RF Diagnostic Editing And Saving Thresholds Step
    [Arguments]    ${bts_id}    ${UI_bts_thresholds}
    ...    ${bts_thresholds}
    ...    ${bands_thresholds}=${None}   ${UI_bands_thresholds}=${None}
    ...    ${technology}=LTE    ${cell}=All LTE cells

    Log    ${technology}
    Log    ${cell}
    ${localIpAddr}    Get Scfc localIpAddr    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
    Selenium Login    url=https://${localIpAddr}
    ...    version=${NODE_CFG["${bts_id}"]["software_release"]}    alias=${bts_id}
    RF Diagnostic Test Edit And Saving Thresholds    bts_thresholds=${UI_bts_thresholds}
    ...    bands_thresholds=${UI_bands_thresholds}    alias=${bts_id}
    Get And Check TEST Thresholds    bts_id=${bts_id}
    ...    bts_thresholds=${bts_thresholds}    bands_thresholds=${bands_thresholds}
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout    alias=${bts_id}

LTE Monitor Maximum And Average Transmit Power via PM
    [Arguments]    ${intervals}=15min   ${wait_for_counter}=30min
    [Documentation]    Author:        xingxin.lou@nokia-sbell.com
    FOR    ${bts_id}    IN    @{BTS_LIST}
        ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
        coam.perform_parameter_recommissioning    dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}   parameter=actL1PM
        ...    operation=update   value=true   connection=${connection_id}
        coam.perform_parameter_recommissioning    dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}/PMRNL-1   parameter=mtPowQualDL
        ...    operation=update   value=${intervals}   connection=${connection_id}
        ${mcc}=    Evaluate Xpath    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
        ...     string(.//managedObject[@class='NOKLTE:LNBTS']/p[@name='mcc'])
        ${mnc}=    Evaluate Xpath    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
        ...     string(.//managedObject[@class='NOKLTE:LNBTS']/p[@name='mnc'])
    END
    ${start_datetime}  DateTime.Get Current Date
    ${start_timestamp}  DateTime.Convert Date  ${start_datetime}  epoch
   Sleep  ${wait_for_counter}
   MultiNode Selenium Login    ${BTS_LIST}
    Check Counter M8010C74 And M8010C75    ${mcc}  ${mnc}   ${start_timestamp}
    FOR    ${bts_id}    IN    @{BTS_LIST}
        Lock RU   ${bts_id}
    END
    ${lock_datetime}  DateTime.Get Current Date
    ${lock_timestamp}  DateTime.Convert Date  ${lock_datetime}  epoch
    Sleep  ${intervals}
    Check Counter M8010C74 And M8010C75   ${mcc}  ${mnc}  ${lock_timestamp}
    FOR    ${bts_id}    IN    @{BTS_LIST}
        UnLock RU   ${bts_id}
        coam.perform_parameter_recommissioning    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1   parameter=actPowerMeter
        ...    operation=update   value=false   connection=${CASE_NAME}_${bts_id}
        ${M8010C74_status}   Run Keyword And Return Status   Get Latest Counter Content    M8010C74   ${CASE_NAME}_${bts_id}_ui
        ${M8010C75_status}   Run Keyword And Return Status   Get Latest Counter Content    M8010C75   ${CASE_NAME}_${bts_id}_ui
        Run Keyword If     '${M8010C74_status}'=='true'    Fail
        Run Keyword If     '${M8010C75_status}'=='true'    Fail
	END
	Check Alarms
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]   MultiNode Selenium Logout    ${BTS_LIST}

ET Modify RF Diagnostic Thresholds to PassFail
    [Arguments]    ${bts_id}    ${technology}=LTE
    [Documentation]    Author: haoyun-lyle.sheng@nokia-sbell.com
    ${alias}    Set Variable    ${CASE_NAME}_${bts_id}_ui
    ${bands_thresholds}    Get All Cells Bands Thresholds    ${bts_id}
    ${bts_thresholds}    Create Dictionary   RF power error high threshold=8    RF power error low threshold=-8
    ...    RTWP high threshold=-30    RTWP low threshold=-110    TX antenna VSWR high threshold=3
    ${localIpAddr}    Get Scfc localIpAddr    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
    Selenium Login    url=https://${localIpAddr}
    ...    version=${NODE_CFG["${bts_id}"]["software_release"]}    alias=${alias}
    Run Keyword And Ignore Error    selenium_coam.clear_finished_results    sbts=${alias}
    Start RF Diagnostic Test And Check    bts_thresholds=${bts_thresholds}    bands_thresholds=${bands_thresholds}
    ...    technology=${technology}    alias=${alias}    check_status=Pass
    ${detail_dict}    Selenium Get RF Diagnostic Detailed Result    technology=${technology}    alias=${alias}
    ${value_dict}    Check RF Diagnostic Test Detail Result    ${detail_dict}

    ${rtwp_thresholds}    Create Dictionary    RTWP low threshold=-180    RTWP high threshold=0
    RF Diagnostic Test Edit And Saving Thresholds    bts_thresholds=${rtwp_thresholds}    alias=${alias}
    ${fail_low_rtwp}    Evaluate    int(random.uniform(${value_dict["RTWP"][-1]},0))    modules=random
    ${fail_high_rtwp}    Evaluate    int(random.uniform(-180,${value_dict["RTWP"][0]}))    modules=random
    ${low_rtwp_thresholds}    Create Dictionary    RTWP low threshold=${fail_low_rtwp}    RTWP high threshold=0
    ${high_rtwp_thresholds}   Create Dictionary    RTWP low threshold=-180    RTWP high threshold=${fail_high_rtwp}
    ${rtwp_thresholds_list}    Create List    ${low_rtwp_thresholds}    ${high_rtwp_thresholds}
    ${fail_rtwp_thresholds}    Evaluate    random.choice(@{rtwp_thresholds_list})    modules=random
    Start RF Diagnostic Test And Check    bts_thresholds=${fail_rtwp_thresholds}    technology=${technology}
    ...    alias=${alias}    check_status=Fail
    Start RF Diagnostic Test And Check    bts_thresholds=${bts_thresholds}    bands_thresholds=${bands_thresholds}
    ...    technology=${technology}    alias=${alias}    check_status=Pass

    ${fail_vswr_thresholds}    Create Dictionary    TX antenna VSWR high threshold=1
    Start RF Diagnostic Test And Check    bts_thresholds=${fail_vswr_thresholds}    technology=${technology}
    ...    alias=${alias}    check_item=vswr    check_status=Fail
    Start RF Diagnostic Test And Check    bts_thresholds=${bts_thresholds}    bands_thresholds=${bands_thresholds}
    ...    technology=${technology}    alias=${alias}    check_status=Pass

#    ${fail_power_error_thresholds}    Create Dictionary
#    ...    RF power error high threshold=2    RF power error low threshold=-2
#    Start RF Diagnostic Test And Check     bts_thresholds=${fail_power_error_thresholds}    technology=${technology}
#    ...    alias=${alias}    check_item=rf_power_error    check_status=Fail
#    Start RF Diagnostic Test And Check    bts_thresholds=${bts_thresholds}    bands_thresholds=${bands_thresholds}
#    ...    technology=${technology}    alias=${alias}    check_status=Pass
    Check Alarms
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]    Selenium Logout    alias=${alias}

Unsupported Radio Connection Between FDD And TDD Configuration With Fault 4525
    [Arguments]    ${target_ru_info}    ${btsids}
    [Documentation]    Author:        nick.1.wu@nokia-sbell.com
    Wait For All Cells OnAir
    Check Alarms
    Check Historical Alarms
    FOR    ${ru_info}    IN    @{target_ru_info}
        Power On And Off Target RU    ${ru_info}    ${btsids}
    END

Unsupported Radio Connection Between ABIA And ABIC Configuration With Fault 4525
    [Arguments]    ${target_ru_info}    ${btsids}    ${wait_time}=3min
    [Documentation]    Author:        nick.1.wu@nokia-sbell.com
    Wait For All Cells OnAir
    Check Alarms
    Check Historical Alarms
    FOR    ${ru_info}    IN    @{target_ru_info}
        Break Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${ru_info["breaklink"]}
        ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}
        Connect Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${ru_info["linksec"]}
        ...    FW_type=${tl_config.FW_INFO['TYPE']}
        sleep    ${wait_time}
        Get Fault 4525 In Target Ru Info    ${ru_info}    ${btsids}
        sleep    ${wait_time}
        Break Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${ru_info["linksec"]}
        ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}
        Connect Link    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${ru_info["breaklink"]}
        ...    FW_type=${tl_config.FW_INFO['TYPE']}
        sleep    ${wait_time}
    END

Run RF Diagnostic Test With Block Unblock Cell
    [Arguments]    ${bts_id}=${MASTER_BTS_ID}    ${technology}=LTE
    [Documentation]    Author:        amy.wu@nokia-sbell.com
    ${alias}    Set Variable    ${CASE_NAME}_${bts_id}_ui
    ${localIpAddr}    Get Scfc localIpAddr    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
    Selenium Login    url=https://${localIpAddr}
    ...    version=${NODE_CFG["${bts_id}"]["software_release"]}    alias=${alias}
    ${cell_list}    Select Specific Rat Cells    ${bts_id}    technology=${technology}
    ${bands_thresholds}    Get All Cells Bands Thresholds    ${bts_id}     cell_list=${cell_list}
    ${rat_cell_list_count}    Get Length    ${cell_list}
    ${random}    Evaluate    random.randrange(0, ${rat_cell_list_count})    modules=random
    ${cell_info}     Get From List    ${cell_list}    ${random}
    ${cell_list_cp}    Copy List    ${cell_list}
    Remove Values From List    ${cell_list_cp}     ${cell_info}
    ${block_cell_list}    Create List    ${cell_info}
    Block Cell    ${cell_info}
    Run RF Diagnostic Test And Check After Block/Lock    ${block_cell_list}    ${cell_list_cp}
    ...    bands_thresholds=${bands_thresholds}    technology=${technology}    alias=${alias}
    Unblock Cell    ${cell_info}
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Selenium Run Diagnostic Test    bands_thresholds=${bands_thresholds}    technology=${technology}    alias=${alias}
    Get And Check RF Diagnostic Test Result    ${cell_list}    alias=${CASE_NAME}_${bts_id}
    FOR    ${cell_info}    IN    @{cell_list}
        Block Cell    ${cell_info}
    END
    Run RF Diagnostic Test And Check After Block/lock    ${cell_list}    ${EMPTY}    bands_thresholds=${bands_thresholds}
    ...    technology=${technology}    alias=${alias}
    FOR    ${cell_info}    IN    @{cell_list}
         Unblock Cell    ${cell_info}
    END
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Selenium Run Diagnostic Test    bands_thresholds=${bands_thresholds}    technology=${technology}    alias=${alias}
    Get And Check RF Diagnostic Test Result    ${cell_list}    alias=${CASE_NAME}_${bts_id}
    Remove RF Diagnostic Test    ${bts_id}    alias=${alias}
    Get And Check RF Diagnostic Test Remove    ${bts_id}
    Check Alarms
    Check Historical Alarms    additional_allowed_alarms=Cell blocked
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout    alias=${alias}

Run RF Diagnostic Test With lock Unlock RU
    [Arguments]    ${bts_id}=${MASTER_BTS_ID}    ${technology}=LTE
    [Documentation]    Author:        amy.wu@nokia-sbell.com
    ${alias}    Set Variable    ${CASE_NAME}_${bts_id}_ui
    ${connection_id}    Set Variable    ${CASE_NAME}_${bts_id}
    ${localIpAddr}    Get Scfc localIpAddr    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
    Selenium Login    url=https://${localIpAddr}
    ...    version=${NODE_CFG["${bts_id}"]["software_release"]}    alias=${alias}
    ${cell_list}    Select Specific Rat Cells    ${bts_id}    technology=${technology}
    ${bands_thresholds}    Get All Cells Bands Thresholds    ${bts_id}     cell_list=${cell_list}
    ${fr_sn}    Evaluate    random.choice(${NODE_CFG["${bts_id}"]["fr_sn_list"]})    modules=random
    ${cell_mapping_rf_list}    Get Cells State On Specific FR    ${fr_sn}
    ${disabled_cell_list}    Select Specific Rat Cells    ${bts_id}    technology=${technology}    cell_list=${cell_mapping_rf_list}
    ${cell_list_cp}    Copy List    ${cell_list}
    Remove Values From List    ${cell_list_cp}     @{disabled_cell_list}
    ${rmod_distname}    Get R Object Distname By SN    class_name=RMOD_R    sn=${fr_sn}    connection=${connection_id}
    coam.lock    dist_name=${rmod_distname}    connection=${CASE_NAME}_${bts_id}    timeout=180
    RU Should Be Locked With Admin    distName=${rmod_distname}    connection=${connection_id}
    Run RF Diagnostic Test And Check After Block/Lock    ${disabled_cell_list}    ${cell_list_cp}
    ...    bands_thresholds=${bands_thresholds}    technology=${technology}    alias=${alias}
    coam.unlock    dist_name=${rmod_distname}    connection=${connection_id}    timeout=180
    RU Should Be Unlocked With Admin    distName=${rmod_distname}    connection=${connection_id}
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Selenium Run Diagnostic Test    bands_thresholds=${bands_thresholds}    technology=${technology}    alias=${alias}
    Get And Check RF Diagnostic Test Result    ${cell_list}    alias=${CASE_NAME}_${bts_id}
    Remove RF Diagnostic Test    ${bts_id}    alias=${alias}
    Get And Check RF Diagnostic Test Remove    ${bts_id}
    Check Alarms
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]    Run Keywords     Run Keyword If    "${KEYWORD STATUS}"=="False"    Run Keyword And Ignore Error
    ...    coam.unlock    dist_name=${rmod_distname}    connection=${connection_id}    timeout=180
    ...    AND    Run Keyword And Ignore Error    Selenium Logout    alias=${alias}

OBSAI_CPRI-N_CPRI-FJ_Commissioning_with_fiber_change
    [Arguments]    ${breaklink}    ${connectlink}    ${earfcn_config}    ${parameter_list1}    ${parameter_list2}
    Log    ${connectlink}
    ${host_ip_list}    Get Dictionary Values    ${BTS_CONFIG["HOST_IP"]}
    ${connection_id}    Set Variable   ${CASE_NAME}_${MASTER_BTS_ID}
    FOR    ${host_ip}    IN    @{host_ip_list}
         Setup eNB FSM Access    host=${BTS_HOST}    timeout=15    remote_host=${host_ip}
         ...    alias=rm_hwbin_${host_ip}
         execute_command_on_enb    cmd=rm -rf /ffs/run/config/hwf.bin.gz    alias=rm_hwbin_${host_ip}
    END
    Reset BTS Until Onair    timeout=${ONAIR_TIME}
    Make L3Call    extra_peak_rate_config=${PEAK_RATE_CONFIG}    required_cells=${EMPTY}
    Break Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${breaklink}
    ...    link_type=single    FW_type=${tl_config.FW_INFO['TYPE']}
    Connect Link    ${tl_config.FW_INFO['IP']}
    ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${linksec}
    ...    FW_type=${tl_config.FW_INFO['TYPE']}
    coam.assert_alarm_active    parameters=faultId=1807    timeout=420    connection=${connection_id}
    Earfcn Update And Check    ${earfcn_config}
    #/MRBTS-2466/EQM-1/APEQM-1/RMOD-1  timingGroupId=1
    #/MRBTS-2466/EQM-1/APEQM-1/CABINET-1/BBMOD-1  distRefPoint=20
    #/MRBTS-2466/LNBTS-2466  bbPoolAllocPrioList  allocPriority=1   allocCriterion=Timing groups
    Online Change Multi Parameters    ${parameter_list1}    connection=${connection_id}
    Create Node Parameters From Current SCF
    Wait Until Keyword Succeeds    1 min    10 sec    Verify All Cells OnAir
    #/MRBTS-2466/EQM-1/APEQM-1/RMOD-1  timingGroupId=1 for FXEB,AHDB  timingGroupId=2 for URGA
    #/MRBTS-2466/EQM-1/APEQM-1/CABINET-1/BBMOD-1  distRefPoint=20  for FXEB,AHDB   distRefPoint=5 for URGA
    #/MRBTS-2466/LNBTS-2466  bbPoolAllocPrioList  allocPriority=1   allocCriterion=Timing groups
    Online Change Multi Parameters    ${parameter_list2}    connection=${connection_id}
    Create Node Parameters From Current SCF
    Wait Until Keyword Succeeds    1 min    10 sec    Verify All Cells OnAir

Check SRIO Collision Handling And Connection Failed
    Check SRIO Collision Handling
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Check SRIO Connection Failed
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Check Alarms
    Check Historical Alarms    additional_allowed_alarms=No connection between primary and BTS extension system module
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=2

Check SRIO And ETH Connection
    BTS Power Off And On
    FOR    ${bts_id}    IN    @{BTS_LIST}
        ${connection}  Set Variable  ${CASE_NAME}_${bts_id}
        Wait Until Keyword Succeeds    3 min    1 min  Check SRIO Connection   connection=${connection}
        ${host_ip}  Set Variable   ${BTS_CONFIG['HOST_IP']['TL1']}
        Check Secondary Core Pingable   ${host_ip}
        Wait Until Keyword Succeeds    3 min    1 min  Check ETH Connection   connection=${connection}
    END

Validation Of Power Exceeding Max Allowed Power Per Pipe
    [Arguments]    ${pmax_config}    ${bts_id}
    [Documentation]    Author:        xingxin.lou@nokia-sbell.com
    ${localIpAddr}    Get Scfc localIpAddr    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
    Selenium Login    url=https://${localIpAddr}
    ...    version=${NODE_CFG["${bts_id}"]["software_release"]}    alias=${CASE_NAME}_${bts_id}_ui
    FOR    ${pmax_info}    IN    @{pmax_config}
        ${origin_value}    selenium_coam.get_parameter_value   dist_name=${pmax_info["dist_name"]}
        ...    filter_param=Maximum output power   sbts=${CASE_NAME}_${bts_id}_ui
        Set To Dictionary   ${pmax_info}    origin_value    ${origin_value}
        selenium_coam.set_parameter_value   dist_name=${pmax_info["dist_name"]}    filter_param=Maximum output power
        ...    new_value=${pmax_info["para_value"]}    sbts=${CASE_NAME}_${bts_id}_ui
    END
    selenium_coam.validate_plan    sbts=${CASE_NAME}_${bts_id}_ui
    sleep    10s
    selenium_coam.activate_plan   activate_plan_despite_errors=True   sbts=${CASE_NAME}_${bts_id}_ui
    FOR    ${pmax_info}    IN    @{pmax_config}
        ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${pmax_info["dist_name"]}    connection=${CASE_NAME}_${bts_id}
        Wait Until Keyword Succeeds    60s  20s   coam.assert_alarm_active
        ...    parameters=faultId=4008,severity=Critical,alarmingResource=${cell_R_info["id"]["internal"]}
        ...     connection=${CASE_NAME}_${bts_id}
        ...    timeout=10
    END
    FOR    ${pmax_info}    IN    @{pmax_config}
        selenium_coam.set_parameter_value   dist_name=${pmax_info["dist_name"]}    filter_param=Maximum output power
        ...    new_value=${pmax_info["origin_value"]}    sbts=${CASE_NAME}_${bts_id}_ui
    END
    Selenium Active Plan   alias=${CASE_NAME}_${bts_id}_ui
    Check Multinode Without Unexpect Alarm
    Check Historical Alarms   additional_allowed_alarms=Power level not supported
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]    Selenium Logout

Update To CMCC Package
    [Arguments]    ${cmcc_sw}
    ${status}    ${return}    Run Keyword And Ignore Error    Variable Should Exist    ${ENB_BUILD}
    Run Keyword IF    '${status}'=='PASS'    Set Test Variable    ${TEST_BUILD}    ${ENB_BUILD}
    Run Keyword IF    '${status}'=='FAIL'    Set Test Variable    ${TEST_BUILD}    ${cmcc_sw}
    FOR    ${btsid}    IN    @{BTS_LIST}
        ${sw}    sw_package_download   ${TEST_BUILD}   target_dir=${SW_BUILDS_DIR_PATH}    package_type=CMCC
        Move File    ${sw}    ${SW_BUILDS_DIR_PATH}/${TEST_BUILD}.zip
        Run Keyword And Ignore Error    OperatingSystem.Remove File    ${sw}
        Download_Yaft_Latest    ${NODE_CFG['${btsId}'].host_ip}
        Update_Sw_Build_By_Yaft    ${NODE_CFG['${btsId}'].host_ip}    ${SW_BUILDS_DIR_PATH}/${TEST_BUILD}.zip
    END
    Verify HW State
    Create Nodes Parameters Init    ${CURRENT_CONFIG_ID}
    Wait Until Keyword Succeeds    240 sec    30 sec    MultiNode Template File Commissioning
    Verify HW State
    Software Check And Correct
    Wait For All Cells OnAir        timeout=${ONAIR_TIME}

SISO Check Fault 4079 When Fan Speed Lower Than Defined Range
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        Check Fault 4079 Fan Vendor Not Detected    ${bts_id}
    END
    Check Multinode Without Unexpect Alarm
    Check Historical Alarms    additional_allowed_alarms=Fan vendor not detected
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=2

SISO_RF module power reset with check ru startup time
    [Arguments]    ${required_power_rfs}=${EMPTY}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
    ...    ${expected_duration}=180
    [Documentation]    Author:        amy.wu@nokia-sbell.com
    ...                Maintainer:    amy.wu@nokia-sbell.com
    ${required_power_rfs_list}    Split String    ${required_power_rfs}    :
    ${rf_list}    Set Variable If    "${required_power_rfs}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_power_rfs_list}
    Set Test Variable    ${HAS_CPRIN}    ${False}
    FOR    ${fr_serial_number}    IN    @{rf_list}
        Power Off Radio    ${fr_serial_number}
        Sleep    30 sec
        ${bts_id}    Get Master BTS Id With RF serial Number    ${fr_serial_number}
        filtering_syslog.start_filter_log    Radio Module detected    host=${NODE_CFG["${bts_id}"]["host_ip"]}
        ...    alias=power_reset_${bts_id}
        ${start_time}    Power On Radio With Return Time    ${fr_serial_number}
        ${filtered_log}    filtering_syslog.get_filtered_log    alias=power_reset_${bts_id}
        filtering_syslog.stop_filter_log    alias=power_reset_${bts_id}
        assert_ru_startup_time    ${filtered_log}    start_time=${start_time}    expected_duration=${expected_duration}
    END
    Check Multinode Without Unexpect Alarm
    Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    ${alarm_allowed}   set variable    :Baseband bus failure:Unit power reset
    Run Keyword If    ${HAS_CPRIN}    Check Historical Alarms
    ...  additional_allowed_alarms=No connection to unit:Failure in optical interface:Not able to synchronize baseband bus${alarm_allowed}
    ...  ELSE     Check Historical Alarms  additional_allowed_alarms=No connection to unit:Failure in optical interface:Unit power reset
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]    Run Keyword If    "${KEYWORD STATUS}"=="FAIL"    Power On Radio    ${fr_serial_number}

Site Reset With Check RU Startup Time
    [Arguments]    ${expected_duration}=180    ${timeout}=${ONAIR_TIME}
    [Documentation]    Author:        amy.wu@nokia-sbell.com
    ...                Maintainer:    amy.wu@nokia-sbell.com
    Log to console    only check first detect radio\n
    FOR    ${bts_id}    IN    @{BTS_LIST}
        filtering_syslog.start_filter_log    RESET_IND|Radio Module detected    host=${NODE_CFG["${bts_id}"]["host_ip"]}
        ...    alias=site_reset_${bts_id}
    END
    Reset BTS Until Onair    timeout=${timeout}
    Check Alarms
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=1
    FOR    ${bts_id}    IN    @{BTS_LIST}
        ${filtered_log}    filtering_syslog.get_filtered_log    alias=site_reset_${bts_id}
        filtering_syslog.stop_filter_log    alias=site_reset_${bts_id}
        assert_ru_startup_time    ${filtered_log}    expected_duration=${expected_duration}
    END

SISO_Recovery RF module reset With Check Startup Time
    [Arguments]    ${required_power_rfs}=${EMPTY}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
    ...    ${expected_duration}=180
    [Documentation]    Author:        amy.wu@nokia-sbell.com
    ...                Maintainer:    amy.wu@nokia-sbell.com
    ${required_power_rfs_list}    Split String    ${required_power_rfs}    :
    ${rf_list}    Set Variable If    "${required_power_rfs}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_power_rfs_list}
    ${cell_cross_rru}    Check Is Cell Cross RRU
    FOR    ${fr_serial_number}    IN    @{rf_list}
        ${bts_id}    Get Master BTS Id With RF serial Number    ${fr_serial_number}
        filtering_syslog.start_filter_log    RU_L-\\d+/RESET_TASK|Radio Module detected    host=${NODE_CFG["${bts_id}"]["host_ip"]}
        ...    alias=radio_reset_${bts_id}
        Radio Reset    ${fr_serial_number}
        ${filtered_log}    filtering_syslog.get_filtered_log    alias=radio_reset_${bts_id}
        filtering_syslog.stop_filter_log    alias=radio_reset_${bts_id}
        assert_ru_startup_time    ${filtered_log}    expected_duration=${expected_duration}
    END
    Check Multinode Without Unexpect Alarm
    Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    Run Keyword If    ${cell_cross_rru}
    ...    Check Historical Alarms    additional_allowed_alarms=Transmission path failure:Tx Failure Turn Mimo Off
    ...    ELSE    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Check Parameter Default Value
    [Arguments]    ${parameter_list}
    FOR    ${parameter}    IN    @{parameter_list}
        ${match}    ${bts_id}    Should Match Regexp    ${parameter["dist_name"]}    (?:MRBTS-)?(\\d+)
        ${release}    Set Variable    ${NODE_CFG["${bts_id}"]["software_release"]}
        ${localIpAddr}    Get Scfc localIpAddr    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
        Selenium Login    url=https://${localIpAddr}    version=${release}    alias=${CASE_NAME}_${bts_id}_ui
        ${detail}    selenium_coam.get_parameter_details    dist_name=${parameter["dist_name"]}
        ...    filter_param=${parameter["filter_param"]}     abbr=${parameter["abbr"]}    sbts=${CASE_NAME}_${bts_id}_ui
        Should Be Equal As Strings    ${detail["Default value"]}    ${parameter["default_value"]}
        Run Keyword And Ignore Error    Selenium Logout    alias=${CASE_NAME}_${bts_id}_ui
    END

Manual SISO PM 5G uDTX
    [Arguments]    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        ${nrbts_distname}    Get R Object Distname    class_name=NRBTS_A  id=${bts_id}    connection=${CASE_NAME}_${bts_id}
        ${actMicroDTX}    coam.get_parameters    dist_name=${nrbts_distname}   pattern=actMicroDTX   connection=${CASE_NAME}_${bts_id}
        ${scf_path}    Set Variable    ${NODE_CFG["${bts_id}"]["scf_file_path"]}
        ${FEATCADM_distname}=
        ...    Evaluate Xpath   ${scf_path}    string(.//managedObject[(@class="com.nokia.srbts.mnl:FEATCADM")]/@distName)
        ${FEATCADM_distname} =  convert to string  ${FEATCADM_distname}
        coam.perform_parameter_recommissioning    dist_name=${FEATCADM_distname}   parameter=actPowerMeter
        ...    operation=update   value=true   connection=${CASE_NAME}_${bts_id}
        ${out_dist_name}=
        ...    Evaluate Xpath   ${scf_path}    string(.//managedObject[(@class="com.nokia.srbts.nrbts:NRBTS")]/@distName)
        ${out_dist_name} =  convert to string  ${out_dist_name}
        Run Keyword If  '${actMicroDTX['actMicroDTX']}'=='True'
        ...    coam.perform_parameter_recommissioning    dist_name=${out_dist_name}   parameter=actMicroDTX
        ...    operation=update   value=false   connection=${CASE_NAME}_${bts_id}
        sleep  3min
        ${rmod_measurements_origin}     Get RMOD Realtime Measurements    connection_id=${CASE_NAME}_${bts_id}
        coam.perform_parameter_recommissioning    dist_name=${out_dist_name}   parameter=actMicroDTX
        ...    operation=update   value=true   connection=${CASE_NAME}_${bts_id}
        sleep  3min
        ${rmod_measurements_new}     Get RMOD Realtime Measurements    connection_id=${CASE_NAME}_${bts_id}
        Check RMOD Power Save   ${rmod_measurements_origin}   ${rmod_measurements_new}
        Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
        coam.perform_parameter_recommissioning    dist_name=${out_dist_name}   parameter=actMicroDTX
        ...    operation=update   value=false   connection=${CASE_NAME}_${bts_id}
    END
    Wait For All Cells OnAir        timeout=${ONAIR_TIME}
    Check Multinode Without Unexpect Alarm
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    [Arguments]    ${bbmod_id_list}=${EMPTY}    ${required_cells}=${EMPTY}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    FOR    ${btsId}    IN    @{ALL_BTS_ID_LIST}
        Lock RU   ${btsId}
    END
    FOR    ${btsId}    IN    @{ALL_BTS_ID_LIST}
        Reset BB Module   require_bbmod=${bbmod_id_list}    btsid=${btsId}
    END
    FOR    ${bts_id}    IN   @{ALL_BTS_ID_LIST}
        Admin HW Check    BBMOD   ${NODE_CFG['${bts_id}'].bbmod_sn_list}    parameters=operationalState=regex"(?i)Enabled"
        ...    timeout=600s    connection=${CASE_NAME}_${bts_id}
        Admin HW Check    RMOD   ${NODE_CFG['${bts_id}'].fr_sn_list}     parameters=operationalState=regex"(?i)Enabled"
        ...    timeout=600s    connection=${CASE_NAME}_${bts_id}
    END
    FOR    ${btsId}    IN    @{ALL_BTS_ID_LIST}
        Unlock RU   ${btsId}
    END
    Wait For All Cells OnAir        timeout=${ONAIR_TIME}
    Check Multinode Without Unexpect Alarm
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}


Common_SiSo_Recovery_RF module reset_Then_BBMOD_reset
    [Arguments]    ${bbmod_id_list}=${EMPTY}     ${required_power_rfs}=${EMPTY}
    ...    ${required_cells}=${EMPTY}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    ${required_power_rfs_list}    Split String    ${required_power_rfs}    :
    ${rf_list}    Set Variable If    "${required_power_rfs}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_power_rfs_list}
    FOR    ${fr_serial_number}    IN    @{rf_list}
        Radio Reset without onair    ${fr_serial_number}
    END

    FOR    ${btsId}    IN    @{ALL_BTS_ID_LIST}
        Reset BB Module   require_bbmod=${bbmod_id_list}    btsid=${btsId}
    END
    FOR    ${bts_id}    IN   @{ALL_BTS_ID_LIST}
        Admin HW Check    BBMOD   ${NODE_CFG['${bts_id}'].bbmod_sn_list}    parameters=operationalState=regex"(?i)Enabled"
        ...    timeout=600s    connection=${CASE_NAME}_${bts_id}
        Admin HW Check    RMOD   ${NODE_CFG['${bts_id}'].fr_sn_list}     parameters=operationalState=regex"(?i)Enabled"
        ...    timeout=600s    connection=${CASE_NAME}_${bts_id}
    END

    Wait For All Cells OnAir        timeout=${ONAIR_TIME}
    Check Multinode Without Unexpect Alarm
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}


Common_SiSo_Recovery_RF_module_reset_Then_RAT_reset
    [Arguments]    ${required_power_rfs}=${EMPTY}
    ...    ${required_cells}=${EMPTY}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    ${required_power_rfs_list}    Split String    ${required_power_rfs}    :
    ${rf_list}    Set Variable If    "${required_power_rfs}"=="${EMPTY}"
    ...    ${TESTED_FR_SN_LIST}    ${required_power_rfs_list}
    ${rat_type_list}    Create List
    FOR    ${btsId}    IN    @{BTS_LIST}
        ${cell_type}    Set Variable    ${NODE_CFG['${btsId}'].cells_class_name}
        Run Keyword IF    ${cell_type}==['NRCEL', 'LNCEL']    Evaluate    $rat_type_list.append(["NR","LTE"])
        ...    ELSE IF    ${cell_type}==['WNCEL', 'LNCEL']    Evaluate    $rat_type_list.append(["WCDMA","LTE"])
        ...    ELSE IF    ${cell_type}==['NRCEL']    Append To List    ${rat_type_list}    NR
        ...    ELSE IF    ${cell_type}==['LNCEL']    Append To List    ${rat_type_list}    LTE
        ...    ELSE IF    ${cell_type}==['WNCEL']    Append To List    ${rat_type_list}    WCDMA
        ...    ELSE IF    ${cell_type}==['GNCEL']    Append To List    ${rat_type_list}    GSM
    END
    FOR    ${rat_type_sub}    IN    @{rat_type_list}
        ${is_list}    Evaluate    isinstance($rat_type_sub,list)
        ${rat_type_concurrent}    Set Variable If    ${is_list}    ${rat_type_sub}    ${rat_type_list}
    END
    ${rat_type}    Evaluate    random.choice(${rat_type_concurrent})   modules=random
    Run Keyword And Continue On Failure    Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}
    ...    required_cells=${required_cells}
    FOR    ${fr_serial_number}    IN    @{rf_list}
        Radio Reset without onair    ${fr_serial_number}
    END
    Run Keyword And Ignore Error    coam.wait_sw_update_possible     alias=${CASE_NAME}_${ALL_BTS_ID_LIST[0]}
    FOR    ${btsId}    IN    @{BTS_LIST}
        coam.reset_rat    rat_type=${rat_type}    timeout=260    connection=${CASE_NAME}_${bts_id}
    END
    FOR    ${bts_id}    IN    @{BTS_LIST}
        Admin HW Check    RMOD    ${NODE_CFG['${bts_id}'].fr_sn_list}
        ...    parameters=operationalState=regex"(?i)Enabled"    timeout=600s    connection=${CASE_NAME}_${bts_id}
    END
    Wait For All Cells OnAir        timeout=${ONAIR_TIME}
    Check Multinode Without Unexpect Alarm
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    Run Keyword And Continue On Failure    Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}
    ...    required_cells=${required_cells}


RF lock And Unlock with BTS Reset
    [Arguments]    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
    FOR    ${btsId}    IN    @{ALL_BTS_ID_LIST}
         ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
         Lock RU   ${btsId}
         ${if_need_blocking}    Set Variable If    '${SITE_MODE}'=='RF_Sharing'    ${False}    ${True}
         coam.reset_site    timeout=600    connection=${connection_id}    wait_for_reconnection=${if_need_blocking}
         Wait Until Keyword Succeeds    5min    10 sec    coam.assert any    class_name=RMOD    parameters=operationalState=regex"(?i)Enabled"
         ...    timeout=600s    alias=${CASE_NAME}_${bts_id}
         Unlock RU   ${btsId}
    END
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    Check Multinode Without Unexpect Alarm
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=1

Common_SiSo_State Management_cell Lock_Then_resetBBMOD_Then_cell unlock
    [Arguments]    ${bbmod_id_list}=${EMPTY}    ${required_cells}=${EMPTY}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    ${cell_list}    Run Keyword If
    ...    '${required_cells}'!='${Empty}'   Get Rquired Cells   ${ALL_CELL_LIST}    ${required_cells}
    ...    ELSE    Choose Cells    ${ALL_CELL_LIST}
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Block Cell    ${cell_info}
    END
#    sleep  1min
    FOR    ${btsId}    IN    @{ALL_BTS_ID_LIST}
        Reset BB Module   require_bbmod=${bbmod_id_list}    btsid=${btsId}
    END
    sleep  3min
    FOR    ${bts_id}    IN   @{ALL_BTS_ID_LIST}
        Admin HW Check    BBMOD   ${NODE_CFG['${bts_id}'].bbmod_sn_list}    parameters=operationalState=regex"(?i)Enabled"
        ...    timeout=600s    connection=${CASE_NAME}_${bts_id}
        Admin HW Check    RMOD   ${NODE_CFG['${bts_id}'].fr_sn_list}     parameters=operationalState=regex"(?i)Enabled"
        ...    timeout=600s    connection=${CASE_NAME}_${bts_id}
    END
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Unblock Cell   ${cell_info}
    END
#    sleep  5min
    Wait For All Cells OnAir        timeout=${ONAIR_TIME}
    Check Alarms
    Check Historical Alarms     additional_allowed_alarms=Cell blocked
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}

Common_SiSo_State Management_Block & Unblock cell_Then_ RF lock & unlock
    [Arguments]    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Block Cell    ${cell_info}
    END
    FOR    ${btsId}    IN    @{ALL_BTS_ID_LIST}
         ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
         Lock RU   ${btsId}
         Wait Until Keyword Succeeds    5min    10 sec    coam.assert any    class_name=RMOD    parameters=operationalState=regex"(?i)Enabled"
         ...    timeout=600s    alias=${CASE_NAME}_${bts_id}
         Unlock RU   ${btsId}
    END
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
         ${is_need_to_operate}   Check Is Operation Cell    ${cell_info}
         Run Keyword If   ${is_need_to_operate}    Unblock Cell   ${cell_info}
    END
    Wait For All Cells OnAir        timeout=${ONAIR_TIME}
    Check Multinode Without Unexpect Alarm
    Check Historical Alarms    additional_allowed_alarms=Cell blocked
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}

Exceptional_RF Fiber Insert&Removal Break_config and data_Link
    [Arguments]    ${rflink}=['L1202407672']
    ${rfs}    Evaluate    ${rflink}
    ${ggmapdict}    Evaluate    ${GGMAP}
    #${rfs}    Get Dictionary Keys    ${linkdict}
    FOR    ${rf}    IN    @{rfs}
        Exceptional_RF Fiber Insert&Removal Break_config and data_Link For one RF    ${rf}
    END

Exceptional_RF Fiber Insert&Removal Break_config or data_Link
    [Arguments]    ${rflink}=['L1202407672']
    ${rfs}    Evaluate    ${rflink}
    ${ggmapdict}    Evaluate    ${GGMAP}
    #${rfs}    Get Dictionary Keys    ${linkdict}
    FOR    ${rf}    IN    @{rfs}
        Exceptional_RF Fiber Insert&Removal Break_config or data_Link For one RF    ${rf}
    END

Exceptional_RF Fiber Insert&Removal Break_then_connect_Link
    [Arguments]    ${rflink}=['L1202407672']
    ${rfs}    Evaluate    ${rflink}
    ${ggmapdict}    Evaluate    ${GGMAP}
    #${rfs}    Get Dictionary Keys    ${linkdict}
    FOR    ${rf}    IN    @{rfs}
        Exceptional_RF Fiber Insert&Removal Break_then_connect_Link For one RF    ${rf}
    END

Common_SiSo_State Management_RF Lock & Unlock_with_RF Reset
    [Documentation]   Auther:qing.2.he@nokia-sbell.com
    [Arguments]    ${timeout}=10 min    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}   ${required_power_rfs}=${EMPTY}
    FOR    ${btsId}    IN    @{ALL_BTS_ID_LIST}
    Lock RU   ${btsId}
    END
    sleep    2min
    ${required_power_rfs_list}    Split String    ${required_power_rfs}    :
    ${rf_list}    Set Variable If    "${required_power_rfs}"=="${EMPTY}"    ${TESTED_FR_SN_LIST}    ${required_power_rfs_list}
    ${cell_cross_rru}    Check Is Cell Cross RRU
    FOR    ${fr_serial_number}    IN    @{rf_list}
         Radio Reset without onair    ${fr_serial_number}
    END
    sleep   2min
    FOR    ${btsId}    IN    @{ALL_BTS_ID_LIST}
    Unlock RU   ${btsId}
    END
    Wait For All Cells OnAir    timeout=${timeout}
    Make L3Call    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    Check Multinode Without Unexpect Alarm
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Common_SiSo_Call_Multicarrier Throughput Measurements when block one cell
    [Arguments]  ${required_rfs}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
     ${required_rfs_list}    Split String    ${required_rfs}    :
     FOR  ${rf}  IN    @{required_rfs_list}
        ${cell_list}    Get Cells State On Specific FR    ${rf}
        Block One Cell And Make Tput    ${cell_list}    ${extra_peak_rate_config}
     END
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    Check Alarms
    Check Historical Alarms    additional_allowed_alarms=Cell blocked

Site Reset With L3 Cache QoS
    [Arguments]    ${timeout}=${ONAIR_TIME}    ${cache_config_id}=9999
    [Documentation]    Author:        amy.wu@nokia-sbell.com
    ...                Maintainer:    amy.wu@nokia-sbell.com
    FOR    ${bts_id}    IN    @{BTS_LIST}
        filtering_syslog.start_filter_log    API_HWCTRL_SET_CACHE_CONFIG_REQ_MSG received|Received API_HWCTRL_SET_CACHE_CONFIG_RESP_MSG
        ...    host=${NODE_CFG["${bts_id}"]["host_ip"]}    alias=site_reset_${bts_id}
    END
    Reset BTS Until Onair    timeout=${timeout}
    Check Alarms
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=1
    FOR    ${bts_id}    IN    @{BTS_LIST}
        ${node_id_list}    Get Node Id List    ${bts_id}
        ${filtered_log}    filtering_syslog.get_filtered_log    alias=site_reset_${bts_id}
        filtering_syslog.stop_filter_log    alias=site_reset_${bts_id}
        log_check_l3_cache_qos    ${filtered_log}    API_HWCTRL_SET_CACHE_CONFIG_REQ_MSG received    ${node_id_list}
        ...    cache_config_id=${cache_config_id}
        log_check_l3_cache_qos    ${filtered_log}    Received API_HWCTRL_SET_CACHE_CONFIG_RESP_MSG    ${node_id_list}
        ...    cache_config_id=${cache_config_id}
    END

Recovery_from_failure_of_current_best_ToP_Master_with_available_second-best_ToP_Master
    [Arguments]    ${rf_sn}    ${tsn_config}
    [Documentation]    Author:        amy.wu@nokia-sbell.com
    ...                Maintainer:    amy.wu@nokia-sbell.com
    ...    ${tsn_config}    {"account": {"ip": "10.68.252.24", "username": "cli", "username2": "admin", "password": "Admin@1830"},
    ...                      "port": {"1": "port8", "2": "port10"}}
    ${type}    Evaluate    type($tsn_config).__name__
    ${tsn_config}    Run Keyword If    "${type}"!="dict"    Evaluate    ${tsn_config}
    ...    ELSE    ${tsn_config}
    ${bts_id}    Get Master BTS Id With RF serial Number    ${rf_sn}
    ${connection_id}    Set Variable    ${CASE_NAME}_${bts_id}
    ${configDN}    Get RMOD ConfigDN    ${rf_sn}    ${connection_id}
    ${topSlavePortNumber}    ${port}    Disable TOPP    ${configDN}    ${tsn_config}    ${connection_id}
    Verify All Cells OnAir
    ${topSlavePortNumber2}    ${port2}    Disable TOPP    ${configDN}    ${tsn_config}    ${connection_id}
    Should Not Be Equal As Integers    ${topSlavePortNumber}    ${topSlavePortNumber2}
    coam.assert_alarm_active    parameters=faultId=16    timeout=120    connection=${connection_id}
    coam.assert_alarm_active    parameters=faultId=4298    timeout=120    connection=${connection_id}
    coam.assert_alarm_inactive    parameters=faultId=61631    timeout=10    connection=${connection_id}
    Radio Should Be Disbled    ${rf_sn}    ${bts_id}
    Enable TOPP    ${tsn_config}    ${port}    ${port2}
    Check Alarms
    ${additional_allowed_alarms}    Catenate    SEPARATOR=:    ToP master service RU eCPRI port #${topSlavePortNumber} unusable
    ...    ToP master service RU eCPRI port #${topSlavePortNumber2} unusable
    ...    ToP reference missing    Unit synchronization failed
    Check Historical Alarms    additional_allowed_alarms=${additional_allowed_alarms}
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]    Run keyword If    "${KEYWORD STATUS}"=="FAIL"    Enable TOPP    ${tsn_config}    ${port}    ${port2}

UE_traffic_test_with_sync_resiliency_activated_when_sync_master_switch
    [Arguments]    ${rf_sn}    ${tsn_config}    ${required_cell}    ${dl}    ${ul}
    ${type}    Evaluate    type($tsn_config).__name__
    ${tsn_config}    Run Keyword If    "${type}"!="dict"    Evaluate    ${tsn_config}
    ...    ELSE    ${tsn_config}
    ${bts_id}    Get Master BTS Id With RF serial Number    ${rf_sn}
    ${connection_id}    Set Variable    ${CASE_NAME}_${bts_id}
    ${cell_info}    Get Cell Info With PCI    ${ALL_CELL_LIST}    ${required_cell}
    ${earfcn}    Get EARFCN    ${cell_info}
    ${matched_ue_info}    Get Matched Ue     ${cell_info["band"]}    ${tl_config.UE_INFO}
    ...    network_type=${cell_info["NetworkType"]}
    Set Test Variable    ${MATCHED_UE_INFO}    ${matched_ue_info}
    Online Change cellBarred For Multi Cell    cell_info=${cell_info}    value=barred
    Set PA Values   ${cell_info["RF"]}
    ${ue_ip}    Attach With Nokia CPE    ${bts_id}    ${required_cell}    ${cell_info["band"]}    ${earfcn}
    ...    ${cell_info["NetworkType"]}
    ${tag}=    Get Timestamp
    Start Run DL Tput    ${required_cell}    ${ue_ip}    ${dl}    ${tag}
    Start Run UL Tput    ${required_cell}    ${ul}    ${tag}
    ${configDN}    Get RMOD ConfigDN    ${rf_sn}    ${connection_id}
    ${topSlavePortNumber}    ${port}    Disable TOPP    ${configDN}    ${tsn_config}    ${connection_id}
    Verify All Cells OnAir
    sleep    10 sec
    CPE.Check Throughput    ${required_cell}    ${tag}    ${dl}    ${ul}
    Run Keyword And Continue On Failure    Enable TOPP    ${tsn_config}    ${port}
    coam.assert_alarm_inactive    parameters=faultId=61631    timeout=30    connection=${connection_id}
    Check Alarms
    Check Historical Alarms    additional_allowed_alarms=ToP master service RU eCPRI port #${topSlavePortNumber} unusable
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Stop Run DL Tput
    ...    AND    Run Keyword And Ignore Error    Stop Run UL Tput
    ...    AND    Run Keyword And Ignore Error    Set PA Values   ${cell_info["RF"]}    disable
    ...    AND    Run Keyword And Ignore Error    Online Change cellBarred For Multi Cell    cell_info=${cell_info}  value=notBarred
    ...    AND    Run keyword If    "${KEYWORD STATUS}"=="FAIL"    Run Keyword And Ignore Error    Enable TOPP
    ...    ${tsn_config}    ${port}

Modify vendor parameters of CB012528
    [Arguments]    ${bts_id}
    ${modify_paramters}    Create List
    ...    text|true|.//managedObject[@class="NRBTS"]/p[@name="actTwoCoresL2DeploymentFddFr1"]
    ...    text|26|.//managedObject[@class="NRBTS"]/list[@name="bbPoolCapacity"]/item/p[@name="maxNumScheUePdschL2Sp"]
    ...    text|22|.//managedObject[@class="NRBTS"]/list[@name="bbPoolCapacity"]/item/p[@name="maxNumScheUePuschL2Sp"]
    Modify vendor parameters    ${bts_id}    ${modify_paramters}
    wait for all cells onair
    ${smod_sn}    Set Variable    ${NODE_CFG["${bts_id}"]["master_sm"]}
    ${bbu_side}    Set Variable If    "${NODE_CFG["${bts_id}"]["bbu_info"]["${smod_sn}"]["horizontalPosition"]}"=="1"    1    4
    ${dist_name}    Set Variable    /MRBTS-1/RAT-1/BTS_L-${bbu_side}/BTS_CONF-1/NP-1/SCF-1/MRBTS_A-${bts_id}/NRBTS_A-${bts_id}
    ${parameters}    coam.get_parameters    ${dist_name}    connection=${CASE_NAME}_${bts_id}
    verify_vendor_value    ${parameters}    actTwoCoresL2DeploymentFddFr1    True
    verify_vendor_value    ${parameters}    bbPoolCapacity.maxNumScheUePdschL2Sp    26
    verify_vendor_value    ${parameters}    bbPoolCapacity.maxNumScheUePuschL2Sp    22

General_SiSo_Recovery_Multiple changes_of_Long optical fiber
    [Arguments]    ${fr_sn}    ${link_dict}    ${required_cells}=${EMPTY}    ${repetition}=1
    ${link_dict}    Evaluate    ${link_dict}
    Set Test Variable    ${HAS_CPRIN}    ${False}
    FOR    ${i}    IN RANGE    ${repetition}
        Recovery_Multiple changes_of_Long optical fiber    ${fr_sn}    ${link_dict}    required_cells=${required_cells}
    END
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    ${additional_alarms}    Set Variable    No connection to unit:Failure in optical interface:Unit power reset
    Run Keyword If    ${HAS_CPRIN}    Check Historical Alarms
    ...  additional_allowed_alarms=${additional_alarms}:Not able to synchronize baseband bus:Baseband bus failure
    ...  ELSE     Check Historical Alarms  additional_allowed_alarms=${additional_alarms}

Radio_Module_fail_safe_mode_fault_activation
    [Arguments]    ${rf_sn}
    ${RRU_Info}    Get RRU Info    serial_num=${rf_sn}
    ${RRU_IP}    Set Variable    ${RRU_Info['parameters']["ipAddress"]}
    ${bts_id}    Get Master BTS Id With RF serial Number     serial_num=${rf_sn}
    ${connection_id}   Set Variable    ${CASE_NAME}_${bts_id}
    ${trigger_command1}    Create List    / action create ResetControl /CI/resetControl/module /module
    ...    /CI/resetControl/module action enable_fail_safe_mode
    ${trigger_command2}    Create List    / action create ResetControl /CI/resetControl/module /module
    ...    /CI/resetControl/module get fail_safe_mode
    ${reboot_command}    Create List    reboot
    ${recovery_command}    Create List    / action create ResetControl /CI/resetControl/module /module
    ...    /CI/resetControl/module action disable_fail_safe_mode
    log to console    ***************** trigger fault *********************
    Send RRU Command in frmonShellClient     ${rf_sn}    ${RRU_IP}    ${trigger_command1}
    Send RRU Command via ssh    ${rf_sn}    ${RRU_IP}    ${reboot_command}
    sleep    60s
    Wait Until Keyword Succeeds    300s    10s    Verify HW State
    Wait Until Keyword Succeeds    300s    10s    coam.assert_alarm_active
    ...    parameters=faultId=2934    connection=${connection_id}
    log to console    ***************** Check Status *********************
    Send RRU Command in frmonShellClient     ${rf_sn}    ${RRU_IP}    ${trigger_command2}
    coam.assert any    class_name=RMOD    parameters=availabilityStatus=regex"(?i)Failed", serialNumber=${rf_sn}
    ...    timeout=60s    alias=${CASE_NAME}_${bts_id}
    coam.assert any    class_name=RMOD    parameters=operationalState=regex"(?i)disabled", serialNumber=${rf_sn}
    ...    timeout=60s    alias=${CASE_NAME}_${bts_id}
    ${result1}    Run Keyword And Return Status    Check Ru Fault History Log
    ...    ${rf_sn}    ${RRU_IP}    ru_fault_id=1462    file_path=/ram/fault_history_log.txt
    ${result2}    Run Keyword And Return Status    Check Ru Fault History Log
    ...    ${rf_sn}    ${RRU_IP}    ru_fault_id=1462    file_path=/ram/fault_history_log_temp.txt
    Should Be True    ${result1} or ${result2}
    log to console    ***************** clear fault *********************
    Send RRU Command in frmonShellClient     ${rf_sn}    ${RRU_IP}    ${recovery_command}
    Send RRU Command via ssh    ${rf_sn}    ${RRU_IP}    ${reboot_command}
    sleep    60s
    Wait Until Keyword Succeeds    300s    10s    Verify HW State
    Wait Until Keyword Succeeds    300s    10s    coam.assert_alarm_inactive
    ...    parameters=faultId=2394    connection=${connection_id}
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Check Alarms
    ${fault4590}    Set Variable    Fault signature for crash or failure
    ${fault2394_related}    Set Variable    Radio Module fail safe mode:SW corrupted:No connection to unit
    Check Historical Alarms    additional_allowed_alarms=${fault2394_related}:${fault4590}
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]    Run Keyword And Ignore Error    Run Keywords
    ...    Send RRU Command in frmonShellClient   ${rf_sn}    ${RRU_IP}    ${recovery_command}
    ...    AND    Send RRU Command via ssh    ${rf_sn}    ${RRU_IP}    ${reboot_command}
    ...    AND    Wait For All Cells OnAir    timeout=${ONAIR_TIME}

Link_break_BBmod_reset
    [Documentation]    Author: ling.qin
    [Arguments]    ${port_list}     ${timeout}=300s    ${bbmod_id_list}=${Empty}    ${test_loops}=${Empty}
    ...    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}    ${break_time}=${break_time}
    FOR    ${bts_id}    IN    @{BTS_LIST}
        Reset BBMOD Until Onair    timeout=${timeout}    require_bbmod=${bbmod_id_list}    btsid=${bts_id}
        ...    test_loops=${test_loops}
        Flash Break    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${port_list}
        ...    ${break_time}    ${break_time}     ${tl_config.FW_INFO['TYPE']}
        Check Alarm Is Appear    fault_parameter=faultId=4760    bts_id=${bts_id}
        Check Alarm Is Appear    fault_parameter=faultId=4590    bts_id=${bts_id}
    END
    Check Alarms
#    Check Historical Alarms    additional_allowed_alarms=${additional_alarms}
    Make tput    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Deep Sleep Mode RU Lock and Unlock
    [Documentation]    Author: xingxin.lou
    [Arguments]    ${rru_sn}     ${required_cells}=${EMPTY}   ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    ${rru_sn_list}   Create List
    ${rru_distname_list}   Create List
    ${rru_sn_list}   Split String    ${rru_sn}    :
#    ${bts_id}    Get Master BTS Id With RF serial Number    ${rru_sn}
    ${connection_id}    Set Variable    ${CASE_NAME}_${MASTER_BTS_ID}
    FOR    ${sn}    IN    @{rru_sn_list}
        ${rmod_distname}    Get R Object Distname By SN    class_name=RMOD_R    sn=${sn}    connection=${connection_id}
        Append To List    ${rru_distname_list}    ${rmod_distname}
    END
    FOR    ${rmod_distname}    IN    @{rru_distname_list}
        coam.lock    dist_name=${rmod_distname}    connection=${connection_id}    timeout=180
        Wait Until Keyword Succeeds    2min    10 sec
        ...    RU Should Be Locked With Admin    distName=${rmod_distname}    connection=${connection_id}
    END
    sleep    5min
    FOR    ${rmod_distname}    IN    @{rru_distname_list}
        ${ru_R_info}    coam.get_parameters    dist_name=${rmod_distname}    connection=${connection_id}
        Should Be Equal As Strings  ${ru_R_info["powerState"]}   SLEEP
    END
    FOR    ${rmod_distname}    IN    @{rru_distname_list}
        coam.unlock    dist_name=${rmod_distname}    connection=${connection_id}    timeout=180
        Wait Until Keyword Succeeds    2min    10 sec
        ...    Check If RU Offline    rmod_distname=${rmod_distname}    connection=${connection_id}
    END
    Wait For All Cells OnAir
    Check Alarms
    Check Historical Alarms
    Make tput    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

BBOX5 File Reset Counter
    [Arguments]    ${ru_sn}    ${timeout}=${ONAIR_TIME}
    ${log_path}    Logging Save Snapshot    ${TEST_LOGS_DIR_PATH}    alias=${CASE_NAME}_${MASTER_BTS_ID}
    ${check results1}=    Bbox5Check.check bbox5 file contents    sn=${ru_sn}    snapshot_path=${log_path}    patt=Reset trigger occur times
    ${num1}    Should Match Regexp    ${check results1[0]}   Reset trigger occur times:\\s(\\d+)
    ${num1}=   Convert To Integer     ${num1[1]}
    Reset BTS Until Onair    timeout=${timeout}
    ${log_path}    Logging Save Snapshot    ${TEST_LOGS_DIR_PATH}    alias=${CASE_NAME}_${MASTER_BTS_ID}
    ${check results2}=    Bbox5Check.check bbox5 file contents    sn=${ru_sn}    snapshot_path=${log_path}    patt=Reset trigger occur times
    ${num2}    Should Match Regexp    ${check results2[0]}   Reset trigger occur times:\\s(\\d+)
    ${num2}=   Convert To Integer     ${num2[1]}
    Should Be True    ${num2} == ${num1}+1

CB013082 radio module recovers after link break triggering 4685 actForceUnitAutoReset
    [Arguments]    ${fr_sn}    ${link_type}    ${extra_fiber}=${EMPTY}    ${online_parameters}=${EMPTY}    ${required_cells}=${EMPTY}
    Log    ${required_cells}
    ${btsIdList}    Get RRU Connected BtsId    ${fr_sn}
    ${bts_id}    Set Variable    ${btsIdList[0]}
    ${connection_id}    Set Variable    ${CASE_NAME}_${bts_id}
    Run Keyword If    "${online_parameters}" != "${EMPTY}"
    ...   Check And Online Parameter Recommission    ${bts_id}   ${online_parameters}
    ${actForceUnitAutoReset}    Scfc Get actForceUnitAutoReset Value    ${bts_id}
    ${linkpri}    ${linktype}    Get Link Info    ${fr_sn}    ${link_type}
    Do Short Break With Fiber Changed    ${linkpri}    extra_fiber=${extra_fiber}
    coam.assert_alarm_active    parameters=faultId=4685    timeout=200    connection=${connection_id}
    ${has_cell_onair}    Run Keyword If    "${actForceUnitAutoReset}" == "false"    Check If A Cell Onair On One RF    ${fr_sn}
    Run Keyword If    ${has_cell_onair}    Radio Reset With Admin    ${fr_sn}    ${bts_id}
    Radio Should Be Disbled    ${fr_sn}    ${bts_id}
    Radio Should Be On    ${fr_sn}    ${bts_id}
    coam.assert_alarm_inactive    parameters=faultId=4685    timeout=200    connection=${connection_id}
    Wait For All Cells OnAir
    #Make L3call    required_cells=${required_cells}
    Check Alarms
    Check Historical Alarms    additional_allowed_alarms=Radio autonomous reset as recovery action:Runtime Fibre Delay Change Out Of Tolerance
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]    Run keywords    Radio Reset With Admin    ${fr_sn}    ${bts_id}
    ...    AND    Do Short Break With Fiber Changed    ${linkpri}
    ...    AND    sleep  5 min
   #...    AND    Wait For All Cells OnAir
   #...    AND    Check Alarms

CB013082 radio module recovers after link break triggering 4685 actCpriLinkRecovery false
    [Arguments]    ${fr_sn}    ${link_type}    ${extra_fiber}=${EMPTY}    ${online_parameters}=${EMPTY}    ${required_cells}=${EMPTY}
    Log    ${required_cells}
    ${btsIdList}    Get RRU Connected BtsId    ${fr_sn}
    ${bts_id}    Set Variable    ${btsIdList[0]}
    ${connection_id}    Set Variable    ${CASE_NAME}_${btsIdList[0]}
    Run Keyword If    "${online_parameters}" != "${EMPTY}"
    ...   Check And Online Parameter Recommission    ${bts_id}   ${online_parameters}
    ute_admin_infomodel.setup_infomodel    address=${BTS_HOST}    alias=link_break_${bts_id}
    ${linkpri}    ${linktype}    Get Link Info    ${fr_sn}    ${link_type}
    Do Short Break With Fiber Changed    ${linkpri}    extra_fiber=${extra_fiber}
    coam.assert_alarm_active    parameters=faultId=4685    timeout=200    connection=${connection_id}
    coam.assert_alarm_inactive    parameters=faultId=4685    timeout=200    connection=${connection_id}
    Wait For All Cells OnAir
    #Make L3call    required_cells=${required_cells}
    ute_admin_infomodel.save_infomodel_log    filename=${TEST_LOGS_DIR_PATH}/link_break_infomodel.ims2
    ...    alias=link_break_${bts_id}
    ${rmod_change_sets}=    Get change sets    ${TEST_LOGS_DIR_PATH}/link_break_infomodel.ims2
    ...    event=//EQM_L-1/RMOD_L-*/RU_L-1 [stateInfo.proceduralState: * -> resetting]
    ...     alias=link_break_${bts_id}
    Should Be Empty    ${rmod_change_sets}
    Check Alarms
    Check Historical Alarms    additional_allowed_alarms=Runtime Fibre Delay Change Out Of Tolerance
    #Check Historical Alarms   additional_allowed_alarms=Radio autonomous reset as recovery action:TX out of order:Tx Failure Turn Mimo Off
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]    Run keywords    Run Keyword And Ignore Error    ute_admin_infomodel.teardown_all_aliases_for_infomodel
    ...    AND    Do Short Break With Fiber Changed    ${linkpri}
    ...    AND    sleep  1 min
    ...    AND    Wait For All Cells OnAir
    ...    AND    Check Alarms

Support BTSID And BTSSW
    [Arguments]    ${ru_sn}
    ${log_path}    Logging Save Snapshot    ${TEST_LOGS_DIR_PATH}    alias=${CASE_NAME}_${MASTER_BTS_ID}
    ${check_results}=    Bbox5Check.extract permanent info    sn=${ru_sn}    snapshot_path=${log_path}
    ${check_results}=    Convert To String    ${check_results}
    ${MRBTS_info_list}    coam.Get Managed Objects    class_name=MRBTS_A    connection=${CASE_NAME}_${MASTER_BTS_ID}
    FOR    ${MRBTS_info}    IN    @{MRBTS_info_list}
        ${info1}    Set Variable    ${MRBTS_info['parameters']['btsName']}
        Should Contain   ${check_results}   ${info1}
    END
    ${RMOD_info_list}    coam.Get Managed Objects    class_name=RMOD_R   connection=${CASE_NAME}_${MASTER_BTS_ID}
    FOR    ${RMOD_info}    IN    @{RMOD_info_list}
        Continue For Loop If    '${RMOD_info['parameters']['serialNumber']}'!='${ru_sn}'
        ${rmod_dist}    Set Variable    ${RMOD_info['distName']}
        Exit For Loop
    END
    ${CABL_info_list}    coam.Get Managed Objects    class_name=CABLINK_R   connection=${CASE_NAME}_${MASTER_BTS_ID}
    FOR    ${CABL_info}    IN    @{CABL_info_list}
        Continue For Loop If    '${CABL_info['parameters']['secondEndpointDN']}'!='${rmod_dist}'
        Continue For Loop If    '${CABL_info['parameters']['linkModeConfiguration']}'!='True'
        ${bbmod_dist}    Set Variable    ${CABL_info['parameters']['firstEndpointDN']}
    END
    FOR    ${CABL_info}    IN    @{CABL_info_list}
        Continue For Loop If    '${CABL_info['parameters']['secondEndpointDN']}'!='${bbmod_dist}'
        ${smod_dist}    Set Variable    ${CABL_info['parameters']['firstEndpointDN']}
    END
    ${BBMOD_info_list}    coam.Get Managed Objects    class_name=BBMOD_R    connection=${CASE_NAME}_${MASTER_BTS_ID}
    FOR    ${BBMOD_info}    IN    @{BBMOD_info_list}
        Continue For Loop If    '${BBMOD_info['distName']}'!='${bbmod_dist}'
        ${info4}    Set Variable    ${BBMOD_info['parameters']['productCode']}
        Should Contain   ${check_results}   ${info4}
        ${info5}    Set Variable    ${BBMOD_info['parameters']['serialNumber']}
        Should Contain   ${check_results}   ${info5}
        Exit For Loop
    END
    ${SMOD_info_list}    coam.Get Managed Objects    class_name=SMOD_R    connection=${CASE_NAME}_${MASTER_BTS_ID}
    FOR    ${SMOD_info}    IN    @{SMOD_info_list}
        Continue For Loop If    '${SMOD_info['distName']}'!='${smod_dist}'
        ${info2}    Set Variable    ${SMOD_info['parameters']['productCode']}
        Should Contain   ${check_results}   ${info2}
        ${info3}    Set Variable    ${SMOD_info['parameters']['serialNumber']}
        Should Contain   ${check_results}   ${info3}
        Exit For Loop
    END
    Should be equal as strings  ${check_results}    ${info1}_${info2}_${info3}_${info4}_${info5}

SiSo DeltaFile Recommissioning
    [Arguments]    ${deltaDict}    #${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${ping}=${True}
    [Documentation]    Author:     lisa.ding@nokia-sbell.com
    ${deltaDict}      Evaluate    ${deltaDict}
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        ${deltafile}    Get From Dictionary    ${deltaDict}    ${bts_id}
        coam.Perform delta recommissioning    ${deltafile}    skip_parameter_relation_errors=True
        ...    connection=${CASE_NAME}_${bts_id}      timeout=600
        Create Node Parameters From Current SCF
    END
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Check Alarms
    Check Historical Alarms
    Make L3call    ping=${ping}    required_cells=${required_cells}    extra_peak_rate_config=${extra_peak_rate_config}

Long_Break_SecondaryLink
    [Documentation]    Author: ling.qin
    [Arguments]    ${rf_sn}    ${break_time}=${break_time}
#	...    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
	${linkpri}    ${linktype}    ${topo}   Get Link Info And Topo   ${rf_sn}    secondary
	${topo_keys}  Get Dictionary Keys  ${topo}
	FOR  ${topo_key}  IN  @{topo_keys}
	    Continue For Loop If    ${topo["${topo_key}"]["linkModeConfiguration"]}==True
		${primary_link}    Set Variable    ${topo_key}
	END
    #flash break
    FOR    ${bts_id}    IN    @{BTS_LIST}
        ${primary_link_distname}    Get Cablink Distname    ${rf_sn}    primary    ${bts_id}
        ${secondary_link_distname}    Get Cablink Distname    ${rf_sn}    secondary    ${bts_id}
        ${gg_port}    Split String    ${linkpri}    :
        Flash Break    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${gg_port}
        ...    ${break_time}    ${break_time}     ${tl_config.FW_INFO['TYPE']}
#        coam.assert_alarm_active
#        ...    parameters=faultId=4760,alarmingResource=${secondary_link_distname}    timeout=60    connection=${CASE_NAME}_${bts_id}
#        ${fault_status}    Run Keyword And Return Status    coam.assert_alarm_active
#        ...    parameters=faultId=4760,alarmingResource=${primary_link_distname}    timeout=60    connection=${CASE_NAME}_${bts_id}
#        Should Not Be True    ${fault_status}
        ${rf_sn_list}    Create List    ${rf_sn}
		Check Not Testing Related FRs States When Testing FR Is Resetting   ${rf_sn_list}    ${bts_id}
		Wait Until Keyword Succeeds    6 min    1 min    Check Counter M40015C10 Or M40015C11    M40015C11    ${primary_link}    ${bts_id}
    END
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Check Alarms
    Check Historical Alarms
    ...    additional_allowed_alarms=Fronthaul Long Link Break:
#    Make tput    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Short_Break_PrimaryLink
    [Documentation]    Author: ling.qin
    [Arguments]    ${rf_sn}    ${break_time}=${break_time}
#	...    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
	${linkpri}    ${linktype}    ${topo}   Get Link Info And Topo   ${rf_sn}    primary
	${topo_keys}  Get Dictionary Keys  ${topo}
	FOR  ${topo_key}  IN  @{topo_keys}
	    Continue For Loop If    ${topo["${topo_key}"]["linkModeConfiguration"]}==False
		${primary_link}    Set Variable    ${topo_key}
	END
    #flash break
    FOR    ${bts_id}    IN    @{BTS_LIST}
        ${primary_link_distname}    Get Cablink Distname    ${rf_sn}    primary    ${bts_id}
        ${gg_port}    Split String    ${linkpri}    :
        Flash Break    ${tl_config.FW_INFO['IP']}
        ...    ${tl_config.FW_INFO['USERNAME']}    ${tl_config.FW_INFO['PASSWORD']}    ${gg_port}
        ...    ${break_time}    ${break_time}     ${tl_config.FW_INFO['TYPE']}
#        ${fault_status}    Run Keyword And Return Status    coam.assert_alarm_active
#        ...    parameters=faultId=4760,alarmingResource=${primary_link_distname}    timeout=30    connection=${CASE_NAME}_${bts_id}
#        Should Not Be True    ${fault_status}
        ${rf_sn_list}    Create List    ${rf_sn}
		Check Not Testing Related FRs States When Testing FR Is Resetting   ${rf_sn_list}    ${bts_id}
		Wait Until Keyword Succeeds    6 min    1 min    Check Counter M40015C10 Or M40015C11    M40015C10    ${primary_link}    ${bts_id}
    END
    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Check Alarms
    Check Historical Alarms
    ...    additional_allowed_alarms=Fronthaul Long Link Break:Fault signature for crash or failure
#    Make tput    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

