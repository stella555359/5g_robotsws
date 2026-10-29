*** Settings ***
Documentation
...    author:          Patryk Tatarek
...    contact:         patryk.tatarek@nokia.com
...    Description:     Georesiliency

Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    ../../../../cloud_common_resources/alarms/alarms.robot
Resource    ../../../../cloud_common_resources/certificates/certificates.robot
Resource    ../Resources/CB006524-CR_Keywords.robot

*** Variables ***
${stress_attempts}=     11    #Number of repetitions (+1)
${sec_cu_addr}=         10.44.249.69
${sec_cu_mrbts}=        84392
${sec_cu_ssh_addr}=     10.42.91.162
${sec_cu_ssh_mrbts}=    ${MRBTS}-2

${geo_login}=       georesiliency
${geo_password}=    Nokia@123

${n_plus_one}=      1+1 Cold/Warm
${one_plus_one}=    1+1 Warm

${rancnf_command}=        kubectl get rancnf -n cran843902lcm
${dry_disable_action}=    DryRunGeoRedDisabledOperation
${disable_action}=        GeoRedDisabledOperation
${enable_action}=         GeoRedEnabledOperation
${disable_phase}=         GeoRedCNFDisabled
${running_phase}=         Running
${succeed_status}=        Succeed

*** Keywords ***
Activation_and_Deactivation_via_georedundancy_commands_stress_test
    Log                              Step 0: Preconditions    console=True
    ${conn_prim}=                    Connect to ADMIN    hw_type=vCU
    ${conn_sec}=                     Wait Until Keyword Succeeds     5x    10s
    ...                              Connect to ADMIN    custom_LMP_addr=${sec_cu_addr}
    ...                              alias=admin_sec    hw_type=vCU
    ${vcu_1_vnf}=                    vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=                    vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings       ${vcu_1_vnf["activity_mode"]}    active
    Should be Equal As Strings       ${vcu_2_vnf["activity_mode"]}    standby
    Run Keyword and Ignore Error     Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
    Run Keyword and Ignore Error     Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
    Wait Until Keyword Succeeds      15min    10s    Check if Unit Status is OnAir    hw_type=vDU
    Log                              Step 1: Perform stress test based on switchover operations    console=True
    FOR    ${try}    IN RANGE    1    ${stress_attempts}
        Log                      Switchover stress test, nr: ${try}    console=True
        ${conn_sec}=             Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN
        ...                      custom_LMP_addr=${sec_cu_addr}    alias=admin_sec    hw_type=vCU
        Wait Until Keyword Succeeds     3x    5min    Forcefully Switchover vCU from Standby to Active mode
        ...                             connection=${conn_sec}
        Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU
        Sleep    60s             reason=Wait before new connection set
        ${conn_prim}=            Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN    hw_type=vCU
        ${conn_sec}=             Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN
        ...                      custom_LMP_addr=${sec_cu_addr}    alias=admin_sec    hw_type=vCU
        Log                      Check if vCU-1 is in standby mode and vCU-2 is in active mode    console=true
        ${vcu_1_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_prim}
        ${vcu_2_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_sec}
        Should be Equal As Strings      ${vcu_1_vnf["activity_mode"]}    standby
        Should be Equal As Strings      ${vcu_2_vnf["activity_mode"]}    active
        Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
        Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU

        ${conn_sec}=             Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN
        ...                      custom_LMP_addr=${sec_cu_addr}    alias=admin_sec    hw_type=vCU
        Wait Until Keyword Succeeds     3x    5min    Switchover vCU from Active to Standby mode
        ...                      connection=${conn_sec}
        Disconnect from ADMIN    connection=${conn_sec}    hw_type=vCU
        Sleep    60s             reason=Wait before new connection set
        ${conn_prim}=            Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN    hw_type=vCU
        ${conn_sec}=             Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN
        ...                      custom_LMP_addr=${sec_cu_addr}    alias=admin_sec    hw_type=vCU
        Log                      Check if both vCU-1 and vCU-2 are in standby mode    console=true
        ${vcu_1_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_prim}
        ${vcu_2_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_sec}
        Should be Equal As Strings      ${vcu_1_vnf["activity_mode"]}    standby
        Should be Equal As Strings      ${vcu_2_vnf["activity_mode"]}    standby
        Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
        Disconnect from ADMIN    connection=${conn_sec}     hw_type=vCU

        ${conn_prim}=            Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN    hw_type=vCU
        Wait Until Keyword Succeeds     3x    5min    Switchover vCU from Standby to Active mode
        ...                      connection=${conn_prim}
        Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
        Sleep    60s             reason=Wait before new connection set
        ${conn_prim}=            Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN    hw_type=vCU
        ${conn_sec}=             Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN
        ...                      custom_LMP_addr=${sec_cu_addr}    alias=admin_sec    hw_type=vCU
        Log                      Check if vCU-1 is in active mode and vCU-2 is in standby mode    console=true
        ${vcu_1_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_prim}
        ${vcu_2_vnf}=            vcu_admin.get_cu_vnf    connection=${conn_sec}
        Should be Equal As Strings      ${vcu_1_vnf["activity_mode"]}    active
        Should be Equal As Strings      ${vcu_2_vnf["activity_mode"]}    standby
        Disconnect from ADMIN           connection=${conn_prim}    hw_type=vCU
        Disconnect from ADMIN           connection=${conn_sec}     hw_type=vCU

        Restore Default Certificates on BTS          hw_type=vCU
        ${conn_sec}=                    Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN
        ...                             custom_LMP_addr=${sec_cu_addr}    alias=admin_sec    hw_type=vCU
        Wait Until Keyword Succeeds     15min    10s    Alarm Should be Active    alarm=4557
        ...                             hw_type=vCU    pre-connection=${conn_sec}
        Run Keyword and Expect Error    *    Switchover vCU from Standby to Active mode    connection=${conn_sec}
        Initialize Certificate          hw_type=vCU
        Wait Until Keyword Succeeds     15min    10s    Alarm Should not be Active    alarm=4557
        ...                             hw_type=vCU    pre-connection=${conn_sec}
        Disconnect from ADMIN           connection=${conn_sec}     hw_type=vCU
    END
    Wait Until Keyword Succeeds    15min    10s    Check if Unit Status is OnAir    hw_type=vDU
    [Teardown]    Run Keywords     Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                            connection=${conn_prim}    hw_type=vCU
    ...    AND                     Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                            connection=${conn_sec}    hw_type=vCU
    ...    AND                     Restore vCUs states before test case

Change_between_vCU_geo_red_N+1_and_vCU_geo_red_1+1
    Log                            Step 0: Preconditions    console=True
    ${geo_type_list}=              Check Parameter Value    param_name=georedundancyType
    ...                            dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1    hw_type=vCU
    Should be True                 "${geo_type_list[0]}"=="${n_plus_one}"
    ${conn_prim}=                  Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN    hw_type=vCU
    ${conn_sec}=                   Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN
    ...                            custom_LMP_addr=${sec_cu_addr}    alias=admin_sec    hw_type=vCU
    ${vcu_1_vnf}=                  vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=                  vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings     ${vcu_1_vnf["activity_mode"]}    active
    Should be Equal As Strings     ${vcu_2_vnf["activity_mode"]}    standby
    Disconnect from ADMIN          connection=${conn_prim}     hw_type=vCU
    Disconnect from ADMIN          connection=${conn_sec}      hw_type=vCU
    Wait Until Keyword Succeeds    15min    10s    Check if Unit Status is OnAir    hw_type=vDU
    Log                            Step 1: Change georedundancy type to 1+1 on vCU-1    console=True
    Change georedundancy type to 1+1 on vCU-1
    Log                            Step 2: Wait for SCF sync    console=true
    Sleep    180s                  reason=Waiting for SCF sync
    Log                            Step 3: Change georedundancy type to 1+1 on vCU-2    console=true
    Change georedundancy type to 1+1 on vCU-2
    Log                            Step 4: Wait for SCF sync    console=true
    Sleep    180s                  reason=Waiting for SCF sync
    Log                            Step 5: Check if there is no CNF-CNF link issue    console=true
    ${conn_sec}=                   Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN
    ...                            custom_LMP_addr=${sec_cu_addr}    alias=admin_sec    hw_type=vCU
    Wait Until Keyword Succeeds    5min    10s    Alarm Should not be Active    alarm=4557    hw_type=vCU
    Wait Until Keyword Succeeds    5min    10s    Alarm Should not be Active    alarm=4557    hw_type=vCU
    ...                            pre-connection=${conn_sec}
    Log                            Step 6: Check if vCU-1 is in active mode and vCU-2 is in standby mode    console=true
    ${conn_prim}=                  Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN    hw_type=vCU
    ${vcu_1_vnf}=                  vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=                  vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings     ${vcu_1_vnf["activity_mode"]}    active
    Should be Equal As Strings     ${vcu_2_vnf["activity_mode"]}    standby
    Disconnect from ADMIN          connection=${conn_prim}     hw_type=vCU
    Disconnect from ADMIN          connection=${conn_sec}      hw_type=vCU
    Log                            Step 7: Check if vDU is still onAir    console=true
    Wait Until Keyword Succeeds    15min    10s    Check if Unit Status is OnAir    hw_type=vDU
    Log                            Step 8: Change georedundancy type to N+1 on vCU-1    console=True
    Change georedundancy type to N+1 on vCU-1
    Log                            Step 9: Wait for SCF sync    console=true
    Sleep    180s                  reason=Waiting for SCF sync
    Log                            Step 10: Change georedundancy type to N+1 on vCU-2    console=True
    Change georedundancy type to N+1 on vCU-2
    Log                            Step 11: Wait for SCF sync    console=true
    Sleep    180s                  reason=Waiting for SCF sync
    Log                            Step 12: Check if there is no CNF-CNF link issue    console=true
    ${conn_sec}=                   Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN
    ...                            custom_LMP_addr=${sec_cu_addr}    alias=admin_sec    hw_type=vCU
    Wait Until Keyword Succeeds    5min    10s    Alarm Should not be Active    alarm=4557    hw_type=vCU
    Wait Until Keyword Succeeds    5min    10s    Alarm Should not be Active    alarm=4557    hw_type=vCU
    ...                            pre-connection=${conn_sec}
    Log                            Step 13: Check if vCU-1 is in active mode and vCU-2 is in standby mode    console=true
    ${conn_prim}=                  Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN    hw_type=vCU
    ${vcu_1_vnf}=                  vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=                  vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings     ${vcu_1_vnf["activity_mode"]}    active
    Should be Equal As Strings     ${vcu_2_vnf["activity_mode"]}    standby
    Disconnect from ADMIN          connection=${conn_prim}     hw_type=vCU
    Disconnect from ADMIN          connection=${conn_sec}      hw_type=vCU
    Log                            Step 14: Check if vDU is still onAir    console=true
    Wait Until Keyword Succeeds    15min    10s    Check if Unit Status is OnAir    hw_type=vDU
    [Teardown]    Run Keywords     Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                            connection=${conn_prim}    hw_type=vCU
    ...    AND                     Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                            connection=${conn_sec}     hw_type=vCU

Georedundancy_activation_deactivation_and_configuration_on_paired_vCU
    Log                            Step 0: Preconditions    console=True
    ${conn_prim}=                  Connect to ADMIN    hw_type=vCU
    ${conn_sec}=                   Wait Until Keyword Succeeds     5x    10s
    ...                            Connect to ADMIN    custom_LMP_addr=${sec_cu_addr}
    ...                            alias=admin_sec    hw_type=vCU
    ${vcu_1_vnf}=                  vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=                  vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings     ${vcu_1_vnf["activity_mode"]}    active
    Should be Equal As Strings     ${vcu_2_vnf["activity_mode"]}    standby
    ${vcu_1_type}=                 Check Parameter Value    param_name=georedundancyType    hw_type=vCU
    ...                            dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1    pre-connection=${conn_prim}
    ${vcu_2_type}=                 Check Parameter Value    param_name=georedundancyType    hw_type=vCU
    ...                            dist_name=MRBTS-${sec_cu_mrbts}/MNL-1/MNLENT-1    pre-connection=${conn_sec}
    Should be True                 "${vcu_1_type[0]}"=="${n_plus_one}"
    Should be True                 "${vcu_2_type[0]}"=="${n_plus_one}"
    Log                            Step 1: Gather necessary data before TC    console=True
    ${peerVNF_id_vcu_1}=           Check Parameter Value    param_name=peerVnf    hw_type=vCU
    ...                            dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1    pre-connection=${conn_prim}
    ${peerVNF_addr_vcu_1}=         Check Parameter Value    param_name=peerVnfIpAddress    hw_type=vCU
    ...                            dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1    pre-connection=${conn_prim}
    ${peerVNF_id_vcu_2}=           Check Parameter Value    param_name=peerVnf    hw_type=vCU
    ...                            dist_name=MRBTS-${sec_cu_mrbts}/MNL-1/MNLENT-1    pre-connection=${conn_sec}
    ${peerVNF_addr_vcu_2}=         Check Parameter Value    param_name=peerVnfIpAddress    hw_type=vCU
    ...                            dist_name=MRBTS-${sec_cu_mrbts}/MNL-1/MNLENT-1    pre-connection=${conn_sec}
    Disconnect from ADMIN          connection=${conn_prim}    hw_type=vCU
    Disconnect from ADMIN          connection=${conn_sec}     hw_type=vCU
    ${f1c_addr_2}=                 Check Parameter Value    param_name=remotef1CplaneIpAddr2    hw_type=vDU
    ...                            dist_name=MRBTS-${MRBTS}/NRBTS-${MRBTS}/NRDU-${MRBTS}
    Log                            Step 2: Remove pairing of vCUs    console=True
    Remove redundancy parameters from vCU-1
    Sleep    180s                  reason=Waiting for SCF sync
    Remove redundancy parameters from vCU-2
    Sleep    180s                  reason=Waiting for SCF sync
    Remove redundancy parameters from vDU
    Sleep    180s                  reason=Wait after redundancy is dropped
    Log                            Step 3: Check if both vCUs are still in the same modes    console=true
    Wait Until Keyword Succeeds    10min    30s    Check if vCUs are in the standalone mode
    Log                            Step 4: Check if vDU is in the right state    console=true
    Check if vDU is in the right state    None
    Log                            Step 5: Restore pairing of vCUs    console=True
    Restore redundancy parameters for vCU-1    ${peerVNF_id_vcu_1[0]}    ${peerVNF_addr_vcu_1[0]}
    Restore redundancy parameters for vCU-2    ${peerVNF_id_vcu_2[0]}    ${peerVNF_addr_vcu_2[0]}
    Restore redundancy parameters for vDU      ${f1c_addr_2}
    Sleep    180s                  reason=Wait after redundancy is restored
    Log                            Step 6: Check if both vCUs are in the right state    console=true
    Wait Until Keyword Succeeds    10min    30s    Check if vCUs are in the right mode
    Log                            Step 7: Check if vDU is in the right state    console=true
    Check if vDU is in the right state    available
    [Teardown]    Run Keywords     Disconnect from ADMIN      connection=${conn_prim}     hw_type=vCU
    ...    AND                     Disconnect from ADMIN      connection=${conn_sec}      hw_type=vCU

Report_of_CNF-CNF_interface_failure_fault
    Log                              Step 0: Preconditions    console=True
    ${conn_prim}=                    Connect to ADMIN    hw_type=vCU
    ${conn_sec}=                     Wait Until Keyword Succeeds     5x    10s
    ...                              Connect to ADMIN    custom_LMP_addr=${sec_cu_addr}
    ...                              alias=admin_sec    hw_type=vCU
    ${vcu_1_vnf}=                    vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=                    vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings       ${vcu_1_vnf["activity_mode"]}    active
    Should be Equal As Strings       ${vcu_2_vnf["activity_mode"]}    standby
    ${vcu_1_type}=                   Check Parameter Value    param_name=georedundancyType    hw_type=vCU
    ...                              dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1    pre-connection=${conn_prim}
    ${vcu_2_type}=                   Check Parameter Value    param_name=georedundancyType    hw_type=vCU
    ...                              dist_name=MRBTS-${sec_cu_mrbts}/MNL-1/MNLENT-1    pre-connection=${conn_sec}
    Should be True                   "${vcu_1_type[0]}"=="${n_plus_one}"
    Should be True                   "${vcu_2_type[0]}"=="${n_plus_one}"
    Disconnect from ADMIN            connection=${conn_prim}    hw_type=vCU
    Disconnect from ADMIN            connection=${conn_sec}     hw_type=vCU
    Log                              Step 1: Trigger CNF-CNF link failure    console=True
    Restore Default Certificates on BTS    hw_type=vCU
    Wait Until Keyword Succeeds      5min    10s    Alarm Should be Active    alarm=4557    hw_type=vCU
    Log                              Step 2: Check if vCU-1 started the timer    console=True
    #ToDo
    Log                              Step 3: Restore CNF-CNF link    console=True
    Initialize Certificate           hw_type=vCU
    Wait Until Keyword Succeeds      5min    10s    Alarm Should not be Active    alarm=4557    hw_type=vCU
    Log                              Step 4: Check if timer was canceled    console=True
    #ToDo
    Log                              Step 5: Trigger CNF-CNF link failure    console=True
    Restore Default Certificates on BTS    hw_type=vCU
    Log                              Step 6: Check if vCU-1 started the timer    console=True
    #ToDo
    Log                              Step 7: Check if vCU-1 timer expired and alarm appears    console=True
    Wait Until Keyword Succeeds      5min    10s    Alarm Should be Active    alarm=4557    hw_type=vCU
    Log                              Step 8: Check if same alarm appears on vCU-2    console=True
    ${conn_sec}=                     Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN
    ...                              custom_LMP_addr=${sec_cu_addr}    alias=admin_sec    hw_type=vCU
    Wait Until Keyword Succeeds      2min    10s    Alarm Should be Active    alarm=4557
    ...                              hw_type=vCU    pre-connection=${conn_sec}
    Disconnect from ADMIN            connection=${conn_sec}     hw_type=vCU
    Log                              Step 9: Restore CNF-CNF link    console=True
    Initialize Certificate           hw_type=vCU
    Wait Until Keyword Succeeds      5min    10s    Alarm Should not be Active    alarm=4557    hw_type=vCU
    ${conn_sec}=                     Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN
    ...                              custom_LMP_addr=${sec_cu_addr}    alias=admin_sec    hw_type=vCU
    Wait Until Keyword Succeeds      2min    10s    Alarm Should not be Active    alarm=4557
    ...                              hw_type=vCU    pre-connection=${conn_sec}
    Disconnect from ADMIN            connection=${conn_sec}     hw_type=vCU
    Log                              Step 10: Switchover vCU-1 -> vCU-2    console=True
    Sleep    90s                     reason=Wait before switchover
    ${conn_sec}=                     Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN
    ...                              custom_LMP_addr=${sec_cu_addr}    alias=admin_sec    hw_type=vCU
    Switchover vCU from Standby to Active mode    connection=${conn_sec}
    Disconnect from ADMIN            connection=${conn_sec}     hw_type=vCU
    Sleep    90s                     reason=Wait before new connection set
    ${conn_prim}=                    Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN    hw_type=vCU
    ${conn_sec}=                     Wait Until Keyword Succeeds     5x    10s
    ...                              Connect to ADMIN    custom_LMP_addr=${sec_cu_addr}
    ...                              alias=admin_sec    hw_type=vCU
    ${vcu_1_vnf}=                    vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=                    vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings       ${vcu_1_vnf["activity_mode"]}    standby
    Should be Equal As Strings       ${vcu_2_vnf["activity_mode"]}    active
    Disconnect from ADMIN            connection=${conn_prim}    hw_type=vCU
    Disconnect from ADMIN            connection=${conn_sec}     hw_type=vCU
    Log                              Step 11: Trigger CNF-CNF link failure    console=True
    Restore Default Certificates on BTS    hw_type=vCU
    Log                              Step 12: Check if CNF-CNF link alarm appears on vCU-1    console=True
    Wait Until Keyword Succeeds      5min    10s    Alarm Should be Active    alarm=4557    hw_type=vCU
    Log                              Step 13: Check if same alarm appears on vCU-2    console=True
    ${conn_sec}=                     Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN
    ...                              custom_LMP_addr=${sec_cu_addr}    alias=admin_sec    hw_type=vCU
    Wait Until Keyword Succeeds      2min    10s    Alarm Should be Active    alarm=4557
    ...                              hw_type=vCU    pre-connection=${conn_sec}
    Disconnect from ADMIN            connection=${conn_sec}     hw_type=vCU
    Log                              Step 14: Restore CNF-CNF link    console=True
    Initialize Certificate           hw_type=vCU
    Wait Until Keyword Succeeds      5min    10s    Alarm Should not be Active    alarm=4557    hw_type=vCU
    ${conn_sec}=                     Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN
    ...                              custom_LMP_addr=${sec_cu_addr}    alias=admin_sec    hw_type=vCU
    Wait Until Keyword Succeeds      2min    10s    Alarm Should not be Active    alarm=4557
    ...                              hw_type=vCU    pre-connection=${conn_sec}
    Disconnect from ADMIN            connection=${conn_sec}     hw_type=vCU
    Log                              Step 15: Switchover vCU-2 -> vCU-1    console=True
    Sleep    90s                     reason=Wait before switchover
    ${conn_prim}=                    Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN    hw_type=vCU
    Switchover vCU from Standby to Active mode    connection=${conn_prim}
    Sleep    120s                    reason=Wait after switchover operation
    [Teardown]    Run Keywords       Disconnect from ADMIN    connection=${conn_prim}    hw_type=vCU
    ...    AND                       Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                              connection=${conn_sec}    hw_type=vCU
    ...    AND                       Restore vCUs states before test case

GeoRedCnf_disabling_enabling_and_dryrun
    Log                            Step 0: Preconditions    console=True
    Wait Until Keyword Succeeds    10min    10s    Check if vCU-2 is pingable
    Wait Until Keyword Succeeds    15min    10s    Check if Unit Status is OnAir    hw_type=vDU
    SSHLibrary.Open Connection     ${sec_cu_ssh_addr}
    SSHLibrary.Login               ${SSH_K8S_USERNAME}    ${SSH_K8S_PASSWORD}
    SSHLibrary.Write               ls -1d --color=never */
    Sleep    3s                    reason=Wait until terminal execute the command
    ${ls}=                         SSHLibrary.Read
    ${clean_output}=               Replace String Using Regexp    ${ls}    \x1B\[[0-9;?]*[A-Za-z]    ${EMPTY}
    ${clean_output}=               Replace String Using Regexp    ${clean_output}    \n    ${EMPTY}
    ${tls_list}=                   Split String    ${clean_output}    \r
    ${tl_dict}=                    Set Variable    ${EMPTY}
    FOR    ${item}    IN    @{tls_list}
        ${status}=     Run Keyword and Return Status    Should Contain    ${item}    ${MRBTS}
        ${tl_dict}=    Set Variable If    ${status}    ${item}    ${tl_dict}
    END
    ${config_file_path}=           Set Variable    /var/home/core/${tl_dict}843902rancnf_vcu2.yaml
    ${cnf_phase}=                  SSHLibrary.Execute Command
    ...                            ${rancnf_command} -o custom-columns=PHASE:.status.phase --no-headers
    Should be Equal                ${cnf_phase}    ${running_phase}
    Log                            Step 1: Prepare config file for GeoRed dry-run disabling    console=True
    SSHLibrary.Execute Command     sed -i 's/geoRedCnfState: .*/geoRedCnfState: Disabled/' ${config_file_path}
    ${geoRed_state}=               SSHLibrary.Execute Command    grep 'geoRedCnfState:' ${config_file_path}
    Should Contain                 ${geoRed_state}    Disabled
    SSHLibrary.Execute Command     sed -i 's/dryRun: .*/dryRun: True/' ${config_file_path}
    ${dryrun_state}=               SSHLibrary.Execute Command    grep 'dryRun:' ${config_file_path}
    Should Contain                 ${dryrun_state}    True
    Log                            Step 2: Perform GeoRed dry-run disabling    console=True
    SSHLibrary.Execute Command     kubectl apply -f ${config_file_path}
    Wait Until Keyword Succeeds    10min    10s    Check if CNF is in right state    ${dry_disable_action}
    ...                                                                              ${succeed_status}
    ...                                                                              ${running_phase}
    Wait Until Keyword Succeeds    10min    10s    Check if vCU-2 is pingable
    Wait Until Keyword Succeeds    15min    10s    Check if Unit Status is OnAir    hw_type=vDU
    Log                            Step 3: Prepare config file for GeoRed disabling    console=True
    ${geoRed_state}=               SSHLibrary.Execute Command    grep 'geoRedCnfState:' ${config_file_path}
    Should Contain                 ${geoRed_state}    Disabled
    SSHLibrary.Execute Command     sed -i 's/dryRun: .*/dryRun: False/' ${config_file_path}
    ${dryrun_state}=               SSHLibrary.Execute Command    grep 'dryRun:' ${config_file_path}
    Should Contain                 ${dryrun_state}    False
    Log                            Step 4: Perform GeoRed disabling    console=True
    SSHLibrary.Execute Command     kubectl apply -f ${config_file_path}
    Wait Until Keyword Succeeds    10min    10s    Check if CNF is in right state    ${disable_action}
    ...                                                                              ${succeed_status}
    ...                                                                              ${disable_phase}
    Wait Until Keyword Succeeds    10min    10s    Check if vCU-2 is not pingable
    Wait Until Keyword Succeeds    15min    10s    Check if Unit Status is OnAir    hw_type=vDU
    Log                            Step 5: Prepare config file for GeoRed enabling    console=True
    SSHLibrary.Execute Command     sed -i 's/geoRedCnfState: .*/geoRedCnfState: Enabled/' ${config_file_path}
    ${geoRed_state}=               SSHLibrary.Execute Command    grep 'geoRedCnfState:' ${config_file_path}
    Should Contain                 ${geoRed_state}    Enabled
    ${dryrun_state}=               SSHLibrary.Execute Command    grep 'dryRun:' ${config_file_path}
    Should Contain                 ${dryrun_state}    False
    Log                            Step 6: Perform GeoRed enabling    console=True
    SSHLibrary.Execute Command     kubectl apply -f ${config_file_path}
    Wait Until Keyword Succeeds    15min    10s    Check if CNF is in right state    ${enable_action}
    ...                                                                              ${succeed_status}
    ...                                                                              ${running_phase}
    Wait Until Keyword Succeeds    10min    10s    Check if vCU-2 is pingable
    Wait Until Keyword Succeeds    15min    10s    Check if Unit Status is OnAir    hw_type=vDU
    [Teardown]    Run Keywords     SSHLibrary.Execute Command
    ...                            sed -i 's/geoRedCnfState: .*/geoRedCnfState: Enabled/' ${config_file_path}
    ...    AND                     SSHLibrary.Execute Command    sed -i 's/dryRun: .*/dryRun: False/' ${config_file_path}
    ...    AND                     SSHLibrary.Execute Command    kubectl apply -f ${config_file_path}
    ...    AND                     SSHLibrary.Close Connection
    ...    AND                     Wait Until Keyword Succeeds    15min    10s
    ...                            Check if Unit Status is OnAir    hw_type=vDU
