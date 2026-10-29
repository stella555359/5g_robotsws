*** Settings ***
Documentation
...    author:          Patryk Tatarek
...    contact:         patryk.tatarek@nokia.com
...    Test Plan (QC):  /VRF_WRO3_T01/25R3/CB011107/
...    Description:
...        Split A:    Data synchronization between vCUs
...        Split C:    IP connectivity test functionality

Resource    ../../../cloud_common_resources/variables/variables.robot

*** Variables ***
${sync_fault}=          4961    #EFaultId_AutomaticDataSynchronisationFailureAl
${ip_conn_fault}=       4558    #IP connectivity test failed

*** Keywords ***
Change_parameter_in_secondary_active_vCU2_data_synchronization_via_WebEM_and_UnForced_switchover
    Log                              Step 0: Preconditions    console=True
    ${conn_prim}=                    Connect to ADMIN    hw_type=vCU
    ${conn_sec}=                     Wait Until Keyword Succeeds     5x    10s
    ...                              Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}
    ...                              alias=admin_sec    hw_type=vCU
    ${vcu_1_vnf}=                    vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=                    vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings       ${vcu_1_vnf["activity_mode"]}    active
    Should be Equal As Strings       ${vcu_2_vnf["activity_mode"]}    standby
    Switchover vCU from Standby to Active mode    connection=${conn_sec}
    Run Keyword and Ignore Error     Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
    Run Keyword and Ignore Error     Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
    Sleep    90s                     reason=Wait before new connection set
    ${conn_prim}=                    Connect to ADMIN    hw_type=vCU
    ${conn_sec}=                     Wait Until Keyword Succeeds     5x    10s
    ...                              Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}
    ...                              alias=admin_sec    hw_type=vCU
    ${vcu_1_vnf}=                    vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=                    vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings       ${vcu_1_vnf["activity_mode"]}    standby
    Should be Equal As Strings       ${vcu_2_vnf["activity_mode"]}    active
    Run Keyword and Ignore Error     Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
    Run Keyword and Ignore Error     Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
    Wait Until Keyword Succeeds      10min    10s    Check if Unit Status is OnAir    hw_type=vDU
    Log                              Step 1: Change e1NbResetRetryForFault on vCU-2    console=true
    ${conn_sec}=                     Wait Until Keyword Succeeds     5x    10s
    ...                              Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}
    ...                              alias=admin_sec    hw_type=vCU
    Change Parameter on BTS          dist_name=MRBTS-${MRBTS_CU_2}/NRBTS-${MRBTS}    param_name=e1NbResetRetryForFault
    ...                              param_value=${5}    hw_type=vCU    pre-connection=${conn_sec}
    Run Keyword and Ignore Error     Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
    Sleep    180s                    reason=Waiting for SCF sync
    Log                              Step 2: Check if e1NbResetRetryForFault was changed on vCU-1    console=true
    ${changed_value}=                Check Parameter Value    param_name=e1NbResetRetryForFault    hw_type=vCU
    Should be True                   "${changed_value[0]}"=="${5}"
    Log                              Step 3: Check alarms on both vCUs    console=true
    Alarm Should not be Active       alarm=${sync_fault}    hw_type=vCU
    ${conn_sec}=                     Wait Until Keyword Succeeds     5x    10s
    ...                              Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}
    ...                              alias=admin_sec    hw_type=vCU
    Alarm Should not be Active       alarm=${sync_fault}    hw_type=vCU    pre-connection=${conn_sec}
    Run Keyword and Ignore Error     Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
    Log                              Step 4: Switchover vCU-2 -> vCU-1    console=true
    ${conn_prim}=                    Connect to ADMIN    hw_type=vCU
    Switchover vCU from Standby to Active mode    connection=${conn_prim}
    Run Keyword and Ignore Error     Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
    Sleep    90s                     reason=Wait before new connection set
    ${conn_prim}=                    Connect to ADMIN    hw_type=vCU
    ${conn_sec}=                     Wait Until Keyword Succeeds     5x    10s
    ...                              Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}
    ...                              alias=admin_sec    hw_type=vCU
    ${vcu_1_vnf}=                    vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=                    vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings       ${vcu_1_vnf["activity_mode"]}    active
    Should be Equal As Strings       ${vcu_2_vnf["activity_mode"]}    standby
    Run Keyword and Ignore Error     Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
    Run Keyword and Ignore Error     Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
    Wait Until Keyword Succeeds      10min    10s    Check if Unit Status is OnAir    hw_type=vDU
    Log                              Step 5: Check alarms on both vCUs    console=true
    Alarm Should not be Active       alarm=${sync_fault}    hw_type=vCU
    ${conn_sec}=                     Wait Until Keyword Succeeds     5x    10s
    ...                              Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}
    ...                              alias=admin_sec    hw_type=vCU
    Alarm Should not be Active       alarm=${sync_fault}    hw_type=vCU    pre-connection=${conn_sec}
    [Teardown]    Run Keywords       Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                              connection=${conn_prim}    hw_type=vCU
    ...    AND                       Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                              connection=${conn_sec}    hw_type=vCU

Change_parameter_in_primary_active_vCU1_data_synchronization_via_MantaRay_and_UnForced_switchover
    Log                              Step 0: Preconditions    console=True
    ${conn_prim}=                    Connect to ADMIN    hw_type=vCU
    ${conn_sec}=                     Wait Until Keyword Succeeds     5x    10s
    ...                              Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}
    ...                              alias=admin_sec    hw_type=vCU
    ${vcu_1_vnf}=                    vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=                    vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings       ${vcu_1_vnf["activity_mode"]}    active
    Should be Equal As Strings       ${vcu_2_vnf["activity_mode"]}    standby
    Run Keyword and Ignore Error     Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
    Run Keyword and Ignore Error     Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
    Wait Until Keyword Succeeds      10min    10s    Check if Unit Status is OnAir    hw_type=vDU
    Log                              Step 1: Change e1NbResetRetryForFault on vCU-1 via MantaRay    console=true
    Change Parameter with NMS        MOC_DN=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}    param_name=e1NbResetRetryForFault
    ...                              param_value=${5}    LAB_NAME=${NMS_LAB}
    Log                              Step 2: Wait for SCF sync    console=true
    Sleep    180s                    reason=Waiting for SCF sync
    Log                              Step 3: Check if e1NbResetRetryForFault was changed on vCU-2    console=true
    ${conn_sec}=                     Wait Until Keyword Succeeds     5x    10s
    ...                              Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}
    ...                              alias=admin_sec    hw_type=vCU
    ${changed_value}=                Check Parameter Value    param_name=e1NbResetRetryForFault
    ...                              hw_type=vCU    pre-connection=${conn_sec}
    Should be True                   "${changed_value[0]}"=="${5}"
    Log                              Step 4: Check alarms on both vCUs    console=true
    Alarm Should not be Active       alarm=${sync_fault}    hw_type=vCU
    Alarm Should not be Active       alarm=${sync_fault}    hw_type=vCU    pre-connection=${conn_sec}
    Log                              Step 5: Switchover vCU-1 -> vCU-2    console=true
    Switchover vCU from Standby to Active mode    connection=${conn_sec}
    Run Keyword and Ignore Error     Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
    Sleep    90s                     reason=Wait before new connection set
    ${conn_prim}=                    Connect to ADMIN    hw_type=vCU
    ${conn_sec}=                     Wait Until Keyword Succeeds     5x    10s
    ...                              Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}
    ...                              alias=admin_sec    hw_type=vCU
    Log                              Step 6: Check if vCU-1 is in standby mode and vCU-2 is in active mode    console=true
    ${vcu_1_vnf}=                    vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=                    vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings       ${vcu_1_vnf["activity_mode"]}    standby
    Should be Equal As Strings       ${vcu_2_vnf["activity_mode"]}    active
    [Teardown]    Run Keywords       Run Keyword and Ignore Error     Disconnect from ADMIN
    ...                              connection=${conn_sec}     hw_type=vCU
    ...    AND                       Switchover vCU from Standby to Active mode    connection=${conn_prim}
    ...    AND                       Run Keyword and Ignore Error     Disconnect from ADMIN
    ...                              connection=${conn_sec}     hw_type=vCU
    ...    AND                       Sleep    120s    reason=Waiting after switchover
    ...    AND                       Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}
    ...                              param_name=e1NbResetRetryForFault    param_value=${3}    hw_type=vCU

Manual_IP_Destination_Reachability_Test_via_WebEM
    Log                              Step 1: Preconditions    console=True
    ${conn_prim}=                    Connect to ADMIN    hw_type=vCU
    ${conn_sec}=                     Wait Until Keyword Succeeds     5x    10s
    ...                              Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}
    ...                              alias=admin_sec    hw_type=vCU
    ${vcu_1_vnf}=                    vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=                    vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings       ${vcu_1_vnf["activity_mode"]}    active
    Should be Equal As Strings       ${vcu_2_vnf["activity_mode"]}    standby
    Run Keyword and Ignore Error     Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
    Run Keyword and Ignore Error     Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
    Wait Until Keyword Succeeds      10min    10s    Check if Unit Status is OnAir    hw_type=vDU
    Log                              Step 2-3: Perform IP connectivity test on vCU-2    console=True
    ${conn_sec}=                     Wait Until Keyword Succeeds     5x    10s
    ...                              Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}
    ...                              alias=admin_sec    hw_type=vCU
    Perform IP Connectivity Test on standby vCU    ${conn_sec}
    Log                              Step 4: Check the result of IP connectivity test    console=True
    ${alarms}=                       Get Active Alarms From BTS    hw_type=vCU    pre-connection=${conn_sec}
    ${alarm_exists}=                 Run Keyword and Return Status    Should Contain    ${alarms}    ${ip_conn_fault}
    Run Keyword If                   ${alarm_exists}    Log
    ...                              Alarm ${ip_conn_fault} present after IP connectivity test    console=True
    Run Keyword If                   not ${alarm_exists}    Log
    ...                              Alarm ${ip_conn_fault} not present after IP connectivity test    console=True
    [Teardown]                       Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
