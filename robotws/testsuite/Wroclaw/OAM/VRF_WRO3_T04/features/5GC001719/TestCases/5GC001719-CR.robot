*** Settings ***
Documentation
...    author:          Patryk Tatarek
...    contact:         patryk.tatarek@nokia.com
...    Description:     Georesilinecy

Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    ../../../cloud_common_resources/variables/variables.robot
Resource    ../Resources/5GC001719-CR_Keywords.robot

*** Variables ***
${unlocked_state}=      Unlocked
${sec_cu_ssh_mrbts}=    ${MRBTS}-2

*** Keywords ***
Cloud_Unforced_Switchover_To_Standby_CNF_By_WebEM_SA_Without_Ipsec
    Log                      Step 0: Preconditions    console=True
    ${conn_prim}=            Connect to ADMIN    hw_type=vCU
    ${cells_status}=         vcu_admin.get_cells_statuses    connection=${conn_prim}
    ${cells_status}=         Get From List    ${cells_status}    ${0}
    ${cells_state}=          Get From Dictionary    ${cells_status}    administrative_state
    ${status}=               Run Keyword and Return Status    Should not be Equal    ${cells_state}    ${unlocked_state}
    Run Keyword If           ${status}    vcu_admin.unlock_cell_group    cell_group_id=${0}    connection=${conn_prim}
    Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
    Log                      Step 1-2: Check if vCU-1 is in active mode and vCU-2 is in standby mode    console=true
    ${conn_prim}=            Connect to ADMIN    hw_type=vCU
    ${conn_sec}=             Wait Until Keyword Succeeds     5x    30s
    ...                      Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    ${vcu_1_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings      ${vcu_1_vnf["activity_mode"]}    active
    Should be Equal As Strings      ${vcu_2_vnf["activity_mode"]}    standby
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
    Log                      Step 3: Check if vDU is onAir    console=true
    Wait Until Keyword Succeeds     10min    1min    Check if Unit Status is OnAir    hw_type=vDU
    Log                      Step 4: Switchover vCU-1 -> vCU-2    console=true
    Sleep    90s             reason=Wait before switchover
    ${conn_sec}=             Wait Until Keyword Succeeds     5x    30s
    ...                      Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    Switchover vCU from Standby to Active mode    connection=${conn_sec}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
    Sleep    90s             reason=Wait before new connection set
    ${conn_prim}=            Wait Until Keyword Succeeds     5x    30s    Connect to ADMIN    hw_type=vCU
    ${conn_sec}=             Wait Until Keyword Succeeds     5x    30s
    ...                      Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    Log                      Step 5: Check if vCU-1 is in standby mode and vCU-2 is in active mode    console=true
    ${vcu_1_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings      ${vcu_1_vnf["activity_mode"]}    standby
    Should be Equal As Strings      ${vcu_2_vnf["activity_mode"]}    active
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
    Log                      Step 6: Check if vDU is onAir    console=true
    Wait Until Keyword Succeeds     10min    1min    Check if Unit Status is OnAir    hw_type=vDU
    Log                      Step 7-8: Switchover 5 times and control vCUs mode    console=true
    Sleep    90s             reason=Wait before switchover
    ${conn_prim}=            Wait Until Keyword Succeeds     5x    30s    Connect to ADMIN    hw_type=vCU
    Switchover vCU from Standby to Active mode    connection=${conn_prim}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
    Sleep    90s             reason=Wait before new connection set
    ${conn_prim}=            Wait Until Keyword Succeeds     5x    30s    Connect to ADMIN    hw_type=vCU
    ${conn_sec}=             Wait Until Keyword Succeeds     5x    30s
    ...                      Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    ${vcu_1_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings      ${vcu_1_vnf["activity_mode"]}    active
    Should be Equal As Strings      ${vcu_2_vnf["activity_mode"]}    standby
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
    Wait Until Keyword Succeeds     10min    1min    Check if Unit Status is OnAir    hw_type=vDU
    Sleep    90s             reason=Wait before switchover
    ${conn_sec}=             Wait Until Keyword Succeeds     5x    30s
    ...                      Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    Switchover vCU from Standby to Active mode    connection=${conn_sec}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
    Sleep    90s             reason=Wait before new connection set
    ${conn_prim}=            Wait Until Keyword Succeeds     5x    30s    Connect to ADMIN    hw_type=vCU
    ${conn_sec}=             Wait Until Keyword Succeeds     5x    30s
    ...                      Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    ${vcu_1_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings      ${vcu_1_vnf["activity_mode"]}    standby
    Should be Equal As Strings      ${vcu_2_vnf["activity_mode"]}    active
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
    Wait Until Keyword Succeeds     10min    1min    Check if Unit Status is OnAir    hw_type=vDU
    Sleep    90s             reason=Wait before switchover
    ${conn_prim}=            Wait Until Keyword Succeeds     5x    30s    Connect to ADMIN    hw_type=vCU
    Switchover vCU from Standby to Active mode    connection=${conn_prim}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
    Sleep    90s             reason=Wait before new connection set
    ${conn_prim}=            Wait Until Keyword Succeeds     5x    30s    Connect to ADMIN    hw_type=vCU
    ${conn_sec}=             Wait Until Keyword Succeeds     5x    30s
    ...                      Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    ${vcu_1_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings      ${vcu_1_vnf["activity_mode"]}    active
    Should be Equal As Strings      ${vcu_2_vnf["activity_mode"]}    standby
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
    Wait Until Keyword Succeeds     10min    1min    Check if Unit Status is OnAir    hw_type=vDU
    Sleep    90s             reason=Wait before switchover
    ${conn_sec}=             Wait Until Keyword Succeeds     5x    30s
    ...                      Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    Switchover vCU from Standby to Active mode    connection=${conn_sec}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
    Sleep    90s             reason=Wait before new connection set
    ${conn_prim}=            Wait Until Keyword Succeeds     5x    30s    Connect to ADMIN    hw_type=vCU
    ${conn_sec}=             Wait Until Keyword Succeeds     5x    30s
    ...                      Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    ${vcu_1_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings      ${vcu_1_vnf["activity_mode"]}    standby
    Should be Equal As Strings      ${vcu_2_vnf["activity_mode"]}    active
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
    Wait Until Keyword Succeeds     10min    1min    Check if Unit Status is OnAir    hw_type=vDU
    Sleep    90s             reason=Wait before switchover
    ${conn_prim}=            Wait Until Keyword Succeeds     5x    30s    Connect to ADMIN    hw_type=vCU
    Switchover vCU from Standby to Active mode    connection=${conn_prim}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
    Sleep    90s             reason=Wait before new connection set
    ${conn_prim}=            Wait Until Keyword Succeeds     5x    30s    Connect to ADMIN    hw_type=vCU
    ${conn_sec}=             Wait Until Keyword Succeeds     5x    30s
    ...                      Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    ${vcu_1_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings      ${vcu_1_vnf["activity_mode"]}    active
    Should be Equal As Strings      ${vcu_2_vnf["activity_mode"]}    standby
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
    Wait Until Keyword Succeeds     10min    1min    Check if Unit Status is OnAir    hw_type=vDU
    Sleep    90s             reason=Wait before new connection
    ${conn_prim}=            Wait Until Keyword Succeeds     5x    30s    Connect to ADMIN    hw_type=vCU
    Log                      Step 9: Lock cells and check vCU-1 state    console=true
    Lock Cells               cell_group_id=${0}    conn=${conn_prim}
    Log                      Step 10: Unlock cells and check vCU-1 state    console=true
    Unlock Cells             cell_group_id=${0}    conn=${conn_prim}
    [Teardown]    Run Keywords    Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                           connection=${conn_prim}    hw_type=vCU
    ...    AND                    Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                           connection=${conn_sec}    hw_type=vCU

CLoud_Modification_Common_And_Site_Specific_Parameters_SCF_Sync_Via_CNF_WebEM_SA_Ipsec
    Log                      Step 1-2: Check if vCU-1 is in active mode and vCU-2 is in standby mode    console=true
    ${conn_prim}=            Connect to ADMIN    hw_type=vCU
    ${conn_sec}=             Wait Until Keyword Succeeds     5x    10s
    ...                      Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    ${vcu_1_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings    ${vcu_1_vnf["activity_mode"]}    active
    Should be Equal As Strings    ${vcu_2_vnf["activity_mode"]}    standby
    Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
    Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
    Log                      Step 3: Check if vDU is onAir    console=true
    Wait Until Keyword Succeeds     10min    1min    Check if Unit Status is OnAir    hw_type=vDU
    Log                        Step 4-1: Change BTS name on vCU-1    console=true
    ${current_btsname}=        Check Parameter Value    param_name=btsName    hw_type=vCU
    ${new_btsname}=            Set Variable    ${current_btsname[0][:-1]}${3}
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}    param_name=btsName
    ...                        param_value=${new_btsname}    hw_type=vCU
    Log                        Step 5-1: Change e1NbResetRetryForFault on vCU-1    console=true
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}    param_name=e1NbResetRetryForFault
    ...                        param_value=${5}    hw_type=vCU
    Log                        Step 6-1: Wait for SCF sync    console=true
    Sleep    180s              reason=Waiting for SCF sync
    Log                        Step 7-1: Check if e1NbResetRetryForFault was changed on vCU-2    console=true
    ${conn_sec}=               Wait Until Keyword Succeeds     5x    10s
    ...                        Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    ${changed_value}=          Check Parameter Value    param_name=e1NbResetRetryForFault
    ...                        hw_type=vCU    pre-connection=${conn_sec}
    Should be True             "${changed_value[0]}"=="${5}"
    Log                        Step 8-1: Check if BTS name wasn't changed on vCU-2    console=true
    ${changed_value}=          Check Parameter Value    param_name=btsName
    ...                        hw_type=vCU    pre-connection=${conn_sec}
    Should be True             "${changed_value[0]}"=="vCU_${sec_cu_ssh_mrbts}"
    Disconnect from ADMIN      connection=${conn_sec}     hw_type=vCU
    Log                        Step 9-1: Change BTS name on vCU-1 back to original value    console=true
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}    param_name=btsName
    ...                        param_value=${current_btsname[0]}    hw_type=vCU
    Log                        Step 10-1: Change e1NbResetRetryForFault on vCU-1    console=true
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}    param_name=e1NbResetRetryForFault
    ...                        param_value=${3}    hw_type=vCU
    Log                        Step 11-1: Wait for SCF sync    console=true
    Sleep    180s              reason=Waiting for SCF sync
    Log                        Step 12-1: Check if e1NbResetRetryForFault was changed on vCU-2    console=true
    ${conn_sec}=               Wait Until Keyword Succeeds     5x    10s
    ...                        Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    ${changed_value}=          Check Parameter Value    param_name=e1NbResetRetryForFault
    ...                        hw_type=vCU    pre-connection=${conn_sec}
    Should be True             "${changed_value[0]}"=="${3}"
    Log                        Step 13-1: Check if BTS name wasn't changed on vCU-2    console=true
    ${changed_value}=          Check Parameter Value    param_name=btsName
    ...                        hw_type=vCU    pre-connection=${conn_sec}
    Should be True             "${changed_value[0]}"=="vCU_${sec_cu_ssh_mrbts}"
    Disconnect from ADMIN      connection=${conn_sec}     hw_type=vCU
    Log                        Step 4-2: Change BTS name on vCU-1    console=true
    ${current_btsname}=        Check Parameter Value    param_name=btsName    hw_type=vCU
    ${new_btsname}=            Set Variable    ${current_btsname[0][:-1]}${3}
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}    param_name=btsName
    ...                        param_value=${new_btsname}    hw_type=vCU
    Log                        Step 5-2: Change e1NbResetRetryForFault on vCU-1    console=true
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}    param_name=e1NbResetRetryForFault
    ...                        param_value=${5}    hw_type=vCU
    Log                        Step 6-2: Wait for SCF sync    console=true
    Sleep    180s              reason=Waiting for SCF sync
    Log                        Step 7-2: Check if e1NbResetRetryForFault was changed on vCU-2    console=true
    ${conn_sec}=               Wait Until Keyword Succeeds     5x    10s
    ...                        Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    ${changed_value}=          Check Parameter Value    param_name=e1NbResetRetryForFault
    ...                        hw_type=vCU    pre-connection=${conn_sec}
    Should be True             "${changed_value[0]}"=="${5}"
    Log                        Step 8-2: Check if BTS name wasn't changed on vCU-2    console=true
    ${changed_value}=          Check Parameter Value    param_name=btsName
    ...                        hw_type=vCU    pre-connection=${conn_sec}
    Should be True             "${changed_value[0]}"=="vCU_${sec_cu_ssh_mrbts}"
    Disconnect from ADMIN      connection=${conn_sec}     hw_type=vCU
    Log                        Step 9-2: Change BTS name on vCU-1 back to original value    console=true
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}    param_name=btsName
    ...                        param_value=${current_btsname[0]}    hw_type=vCU
    Log                        Step 10-2: Change e1NbResetRetryForFault on vCU-1    console=true
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}    param_name=e1NbResetRetryForFault
    ...                        param_value=${3}    hw_type=vCU
    Log                        Step 11-2: Wait for SCF sync    console=true
    Sleep    180s              reason=Waiting for SCF sync
    Log                        Step 12-2: Check if e1NbResetRetryForFault was changed on vCU-2    console=true
    ${conn_sec}=               Wait Until Keyword Succeeds     5x    10s
    ...                        Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    ${changed_value}=          Check Parameter Value    param_name=e1NbResetRetryForFault
    ...                        hw_type=vCU    pre-connection=${conn_sec}
    Should be True             "${changed_value[0]}"=="${3}"
    Log                        Step 13-2: Check if BTS name wasn't changed on vCU-2    console=true
    ${changed_value}=          Check Parameter Value    param_name=btsName
    ...                        hw_type=vCU    pre-connection=${conn_sec}
    Should be True             "${changed_value[0]}"=="vCU_${sec_cu_ssh_mrbts}"
    Disconnect from ADMIN      connection=${conn_sec}     hw_type=vCU
    Log                        Step 4-3: Change BTS name on vCU-1    console=true
    ${current_btsname}=        Check Parameter Value    param_name=btsName    hw_type=vCU
    ${new_btsname}=            Set Variable    ${current_btsname[0][:-1]}${3}
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}    param_name=btsName
    ...                        param_value=${new_btsname}    hw_type=vCU
    Log                        Step 5-3: Change e1NbResetRetryForFault on vCU-1    console=true
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}    param_name=e1NbResetRetryForFault
    ...                        param_value=${5}    hw_type=vCU
    Log                        Step 6-3: Wait for SCF sync    console=true
    Sleep    180s              reason=Waiting for SCF sync
    Log                        Step 7-3: Check if e1NbResetRetryForFault was changed on vCU-2    console=true
    ${conn_sec}=               Wait Until Keyword Succeeds     5x    10s
    ...                        Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    ${changed_value}=          Check Parameter Value    param_name=e1NbResetRetryForFault
    ...                        hw_type=vCU    pre-connection=${conn_sec}
    Should be True             "${changed_value[0]}"=="${5}"
    Log                        Step 8-3: Check if BTS name wasn't changed on vCU-2    console=true
    ${changed_value}=          Check Parameter Value    param_name=btsName
    ...                        hw_type=vCU    pre-connection=${conn_sec}
    Should be True             "${changed_value[0]}"=="vCU_${sec_cu_ssh_mrbts}"
    Disconnect from ADMIN      connection=${conn_sec}     hw_type=vCU
    Log                        Step 9-3: Change BTS name on vCU-1 back to original value    console=true
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}    param_name=btsName
    ...                        param_value=${current_btsname[0]}    hw_type=vCU
    Log                        Step 10-3: Change e1NbResetRetryForFault on vCU-1    console=true
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}    param_name=e1NbResetRetryForFault
    ...                        param_value=${3}    hw_type=vCU
    Log                        Step 11-3: Wait for SCF sync    console=true
    Sleep    180s              reason=Waiting for SCF sync
    Log                        Step 12-3: Check if e1NbResetRetryForFault was changed on vCU-2    console=true
    ${conn_sec}=               Wait Until Keyword Succeeds     5x    10s
    ...                        Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    ${changed_value}=          Check Parameter Value    param_name=e1NbResetRetryForFault
    ...                        hw_type=vCU    pre-connection=${conn_sec}
    Should be True             "${changed_value[0]}"=="${3}"
    Log                        Step 13-3: Check if BTS name wasn't changed on vCU-2    console=true
    ${changed_value}=          Check Parameter Value    param_name=btsName
    ...                        hw_type=vCU    pre-connection=${conn_sec}
    Should be True             "${changed_value[0]}"=="vCU_${sec_cu_ssh_mrbts}"
    Disconnect from ADMIN      connection=${conn_sec}     hw_type=vCU
    [Teardown]    Run Keywords    Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                           connection=${conn_prim}     hw_type=vCU
    ...    AND                    Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                           connection=${conn_sec}     hw_type=vCU
    ...    AND                    Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}    param_name=btsName
    ...                           param_value=${current_btsname[0]}    hw_type=vCU
