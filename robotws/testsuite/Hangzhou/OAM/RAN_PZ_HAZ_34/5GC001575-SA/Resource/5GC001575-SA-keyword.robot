*** Settings ***
Documentation     author: Shenrao
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: shengrong.rao@nokia-sbell.com

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    taf.selenium.gnb.oam.coam.cu    WITH NAME   coam_cu
Library    OperatingSystem
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands


Resource          ../../common/taf_coam.robot
Resource          ../../common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot


*** Variables ***
${dltp}    200
${ultp}    50
${CU_OAM_IP}                  ${tl.gnbs[0].cu.oam_http_connection_details.addr}
*** Keywords ***

L3 call setup
    [Arguments]    ${UE_TYPE}=qct_dx50
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    #power_ue.Prepare UE    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    Log To Console    \n ###UE Start traffic and check TP ###
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=500M    duration=120s
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul   throughput=100M    duration=120s
    ${all_tp}    Get ul and dl peak and ave throughput and return result
    Run keyword and continue on failure    should be true    ${all_tp[1]}>${dltp}
    Run keyword and continue on failure    should be true    ${all_tp[4]}>${ultp}
    Log To Console    \n ### Stop traffic ###
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

L3 call setup before lock
    [Arguments]    ${UE_TYPE}=qct_dx50
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    Log To Console    \n ###UE Start traffic and check TP ###
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=500M    duration=20min
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul   throughput=100M    duration=20min
    ${all_tp}    Get ul and dl peak and ave throughput and return result
    Run keyword and continue on failure    should be true    ${all_tp[1]}>${dltp}
    Run keyword and continue on failure    should be true    ${all_tp[4]}>${ultp}

L3 call check after lock
    [Arguments]    ${UE_TYPE}=qct_dx50
    sleep     60s
    ${all_tp}    Get ul and dl peak and ave throughput and return result
    Run keyword and continue on failure    should be true    ${all_tp[1]}=0
    Run keyword and continue on failure    should be true    ${all_tp[4]}=0
    Log To Console    \n ### Stop traffic ###
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}


AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    admin_cli.teardown    connection=COAM

check cu status when reset successful
    [Arguments]    ${flag}=True
    run keyword if    '${flag}'=='True'    coam_cu.login    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/
    ...    username=Nemuadmin    password=nemuuser    browser=firefox    timeout=60
    ${dus_status}    coam_cu.get_dus_status_info
    Log    ${dus_status}
    FOR    ${dus}    IN    @{dus_status}
         should be true    ${dus['Cells enabled/disabled'].split('/')[0].strip()} == ${dus['Total Cells']}
         should be true    ${dus['Cells unlocked/locked'].split('/')[0].strip()} == ${dus['Total Cells']}
         Should Contain     ${dus['F1 Link status']}    Available
         Should Contain     ${dus['Administrative state']}    Unlocked
    END

#    ${X2_link_status}    coam_cu.get_X2_link_status_info
#    Log      ${X2_link_status}
#    FOR    ${status}    IN    @{X2_link_status}
#        should contain      ${status['X2 link status']}    Available
#        should contain      ${status['Locking state']}    Unlocked
#    END
#    ${VMs_status}    Get VMs Status Info
#    Log      ${VMs_status}
#    FOR    ${status}    IN    @{VMs_status}
#        should contain    ${status['Status']}    Online
#    END

Check DU status
    [Documentation]    check DU status
    [Arguments]    ${connection}=COAM    ${bts_host}=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...    ${nrcell}=NRCELL-1    ${administrativeState}=Unlocked    ${availabilityStatus}=Online
    ...    ${operationalState}=Enabled    ${proceduralStatus}=configured
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${bts_host}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    ${cells_info}    admin_cli.get_cells_info    connection=${connection}
    #${result_cell}    admin_cli.get_cells_info    connection=DU_OAM
    ${availability_status}=   set variable  ${cells_info[0]['status']['availabilityStatus']}
	run keyword and continue on failure
    ...    should be equal as strings     ${availability_status}    Offline    ignore_case=${True}
    ${proceduralStatus_status}=   set variable  ${cells_info[0]['status']['proceduralStatus']}
	run keyword and continue on failure
    ...    should be equal as strings     ${proceduralStatus_status}    configured    ignore_case=${True}
    ${administrativeState_status}=   set variable  ${cells_info[0]['status']['administrativeState']}
	run keyword and continue on failure
    ...    should be equal as strings     ${administrativeState_status}    Unlocked    ignore_case=${True}
    ${operationalState_status}=   set variable  ${cells_info[0]['status']['operationalState']}
	run keyword and continue on failure
    ...    should be equal as strings     ${operationalState_status}    Disabled    ignore_case=${True}
    #log    ${cells_info['NRCELLGRP-0']}
    #${nrcell-ids}    Get Dictionary Keys    ${cells_info['NRCELLGRP-0']}
    #FOR    ${cell}    IN    @{nrcell-ids}
    #    ${proceduralStatus}    set variable if    '${cell}' == '${nrcell}'    ${proceduralStatus}    configured
    #    ${administrativeState}    set variable if    '${cell}' == '${nrcell}'    ${administrativeState}    Unlocked
    #    ${availabilityStatus}    set variable if    '${cell}' == '${nrcell}'    ${availabilityStatus}    Online
    #    ${operationalStates}    set variable if    '${cell}' == '${nrcell}'    ${operationalState}    Enabled
    #    Should Contain     ${cells_info['NRCELLGRP-0']['${cell}']['NRCELL_R']['proceduralStatus']}    ${proceduralStatus}
    #    Should Contain     ${cells_info['NRCELLGRP-0']['${cell}']['NRCELL_R']['administrativeState']}    ${administrativeState}
    #    Should Contain     ${cells_info['NRCELLGRP-0']['${cell}']['NRCELL_R']['availabilityStatus']}    ${availabilityStatus}
    #    Should Contain     ${cells_info['NRCELLGRP-0']['${cell}']['NRCELL_R']['operationalState']}    ${operationalState}
    #END
    [Teardown]   run keyword and ignore error    admin_cli.teardown    connection=${connection}

Lock DU on CU WebEM
    [Arguments]    ${NRDU_id}=NRDU-1
    ${dus_status}    coam_cu.get_dus_status_info
    Log    ${dus_status}
    ${lock_duNum}    Create List
    FOR    ${du}    IN    @{dus_status}
        ${lock_dus}    run keyword if     '${du['NRDU ID']}' == '${NRDU_id}' and '${du['Administrative state']}' == 'Unlocked'
        ...    coam_cu.Lock Dus    ${NRDU_id}    ${120}
        run keyword if     '${du['NRDU ID']}' == '${NRDU_id}' and '${du['Administrative state']}' == 'Unlocked'
        ...    Should Contain  ${lock_dus}    ${NRDU_id} lock operation finished
        run keyword if    '${lock_dus}' != 'None'    Append To List    ${lock_duNum}    ${lock_dus}
    END
    Should be true    len(${lock_duNum}) > 0

Status check after Lock DU
    [Arguments]    ${NRDU_id}=NRDU-1    ${administrativeState}=Locked    ${availabilityStatus}=Offline
    ...    ${operationalState}=Disabled    ${proceduralStatus}=configured
    ...    ${F1 Link status}=Available    ${cell administrative state}=Unlocked
    coam_cu.login    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/
        ...    username=Nemuadmin    password=nemuuser    browser=firefox    timeout=60
    ${dus_status}    coam_cu.get_dus_status_info
    Log    ${dus_status}
    FOR    ${du}    IN    @{dus_status}
        ${Administrative states}    set variable if     '${du['NRDU ID']}' == '${NRDU_id}'    ${administrativeState}    Unlocked
        ${F1 Link status}    set variable if     '${du['NRDU ID']}' == '${NRDU_id}'    ${F1 Link status}    Available
        ${cell status}    set variable if     '${du['NRDU ID']}' == '${NRDU_id}'
        ...    ${du['Cells enabled/disabled'].split('/')[1].strip()}    ${du['Cells enabled/disabled'].split('/')[0].strip()}
        Should Contain     ${du['Administrative state']}    ${Administrative states}
        Should Contain     ${du['F1 Link status']}    ${F1 Link status}
        should be true    ${cell status} == ${du['Total Cells']}
    END
    ${cells_status}    coam_cu.get_cells_status_info
    Log    ${cells_status}
    FOR    ${cel}    IN    @{cells_status}
        ${cell administrative state}    set variable if    '${cel['Serving DU ID']}'=='${NRDU_id}'
        ...    ${cell administrative state}    Unlocked
        ${Operational states}    set variable if    '${cel['Serving DU ID']}'=='${NRDU_id}'
        ...    ${operationalState}    Enabled
        Should Contain     ${cel['Administrative state']}    ${cell administrative state}
        Should Contain     ${cel['Operational state']}    ${Operational states}
    END
    run keyword if     '${NRDU_id}' == 'NRDU-1'    Check DU status    administrativeState=${cell administrative state}
    ...    availabilityStatus=${availabilityStatus}     operationalState=${operationalState}    proceduralStatus=${proceduralStatus}

Status check after Lock cell
    [Arguments]    ${NRDU_id}=NRDU-1    ${NRCELL_id}=NRCELL-1    ${administrativeStates}=Locked
    ...    ${operationalStates}=Disabled
    coam_cu.login    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/
    ...    username=Nemuadmin    password=nemuuser    browser=firefox    timeout=60
    ${cells_status}    coam_cu.get_cells_status_info
    Log    ${cells_status}
    FOR    ${cel}    IN    @{cells_status}
        ${Administrative state}    set variable if    '${cel['Serving DU ID']}'=='${NRDU_id}' and '${cel['NRCELL ID']}'=='${NRCELL_id}'
        ...    ${administrativeStates}    Unlocked
        ${Operational state}    set variable if    '${cel['Serving DU ID']}'=='${NRDU_id}' and '${cel['NRCELL ID']}'=='${NRCELL_id}'
        ...    ${operationalStates}    Enabled
        Should Contain     ${cel['Administrative state']}    ${Administrative state}
        Should Contain     ${cel['Operational state']}    ${Operational state}
    END
    Check DU status     availabilityStatus=Offline     operationalState=Disabled
    coam_cu.logout

Status check after Lock cellGroups
    [Arguments]    ${NRDU_id}=NRDU-1    ${CG_id}=${0}    ${administrativeStates}=Locked
    ...    ${operationalStates}=Disabled
    coam_cu.login    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/
    ...    username=Nemuadmin    password=nemuuser    browser=firefox    timeout=60
    ${cells_status}    coam_cu.get_cells_status_info
    Log    ${cells_status}
    FOR    ${cel}    IN    @{cells_status}
        ${Administrative state}    set variable if    '${cel['Serving DU ID']}'=='${NRDU_id}' and '${cel['Cell group ID']}'=='${CG_id}'
        ...    ${administrativeStates}    Unlocked
        ${Operational state}    set variable if    '${cel['Serving DU ID']}'=='${NRDU_id}' and '${cel['Cell group ID']}'=='${CG_id}'
        ...    ${operationalStates}    Enabled
        Should Contain     ${cel['Administrative state']}    ${Administrative state}
        Should Contain     ${cel['Operational state']}    ${Operational state}
    END
    coam_cu.logout



Unlock DU on CU WebEM
    [Arguments]    ${NRDU_id}=NRDU-1
    ${dus_status}    coam_cu.get_dus_status_info
    Log    ${dus_status}
    ${unlock_duNum}    Create List
    FOR    ${du}    IN    @{dus_status}
        ${unlock_dus}    run keyword if     '${du['NRDU ID']}' == '${NRDU_id}' and '${du['Administrative state']}' == 'Locked'
        ...    coam_cu.unlock Dus    ${NRDU_id}    ${120}
        run keyword if     '${du['NRDU ID']}' == '${NRDU_id}' and '${du['Administrative state']}' == 'Locked'
        ...    Should Contain  ${unlock_dus}    ${NRDU_id} unlock operation finished
        run keyword if    '${unlock_dus}' != 'None'    Append To List    ${unlock_duNum}    ${unlock_dus}
    END
    Should be true    len(${unlock_duNum}) > 0

Lock Cells on CU WebEM
    [Arguments]    ${NRDU_id}=NRDU-1    ${NRCELL_id}=NRCELL-1
    coam_cu.login    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/
        ...    username=Nemuadmin    password=nemuuser    browser=firefox    timeout=60
    ${cells_status}    coam_cu.get_cells_status_info
    Log    ${cells_status}
    ${lock_cellNum}    Create List
    FOR    ${cel}    IN    @{cells_status}
        ${lock_Cells}    run keyword if
        ...    '${cel['Serving DU ID']}'=='${NRDU_id}' and '${cel['NRCELL ID']}'=='${NRCELL_id}' and '${cel['Administrative state']}'=='Unlocked'
        ...    coam_cu.Lock Cells    ${NRDU_id}/${NRCELL_id}    ${120}
        run keyword if    '${cel['Serving DU ID']}'=='${NRDU_id}' and '${cel['NRCELL ID']}'=='${NRCELL_id}'
        ...    Should Contain  ${lock_Cells}    ${NRCELL_id} lock operation finished
        run keyword if    '${lock_Cells}' != 'None'    Append To List    ${lock_cellNum}    ${lock_Cells}
    END
    Should be true    len(${lock_cellNum}) > 0
    coam_cu.logout


Unlock Cells on CU WebEM
    [Arguments]    ${NRDU_id}=NRDU-1    ${NRCELL_id}=NRCELL-1
    coam_cu.login    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/
    ...    username=Nemuadmin    password=nemuuser    browser=firefox    timeout=60
    ${cells_status}    coam_cu.get_cells_status_info
    Log    ${cells_status}
    ${unlock_cellNum}    Create List
    FOR    ${cel}    IN    @{cells_status}
        ${unlock_Cells}    run keyword if
        ...    '${cel['Serving DU ID']}'=='${NRDU_id}' and '${cel['NRCELL ID']}'=='${NRCELL_id}' and '${cel['Administrative state']}'=='Locked'
        ...    coam_cu.Unlock Cells    ${NRDU_id}/${NRCELL_id}    ${120}
        run keyword if    '${cel['Serving DU ID']}'=='${NRDU_id}' and '${cel['NRCELL ID']}'=='${NRCELL_id}'
        ...    Should Contain  ${unlock_Cells}    ${NRCELL_id} unlock operation finished
        run keyword if    '${unlock_Cells}' != 'None'    Append To List    ${unlock_cellNum}    ${unlock_Cells}
    END
    Should be true    len(${unlock_cellNum}) > 0
    coam_cu.logout

Lock Cell Groups on CU WebEM
    [Arguments]    ${NRDU_id}=NRDU-1    ${CG_id}=${0}
    coam_cu.login    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/
    ...    username=Nemuadmin    password=nemuuser    browser=firefox    timeout=60
    ${lock_CellGroups}    coam_cu.Lock Cell Groups    ${NRDU_id}/CG-${CG_id}    ${120}
    Should Contain    ${lock_CellGroups}    NRCELLGRP-${CG_id} lock operation finished
    coam_cu.logout


Unlock Cell Groups on CU WebEM
    [Arguments]    ${NRDU_id}=NRDU-1    ${CG_id}=${0}
    coam_cu.login    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/
    ...    username=Nemuadmin    password=nemuuser    browser=firefox    timeout=60
    ${dus_status}    coam_cu.get_dus_status_info
    ${unlock_CellGroups}    coam_cu.Unlock Cell Groups    ${NRDU_id}/CG-${CG_id}    ${120}
    Should Contain    ${unlock_CellGroups}    NRCELLGRP-${CG_id} unlock operation finished
    coam_cu.logout

Check CU status
    [Documentation]    Check status on CU
    [Arguments]    ${flag}=True
    run keyword if    '${flag}'=='True'    coam_cu.login    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/
    ...    username=Nemuadmin    password=nemuuser    browser=firefox    timeout=60
    ${dus_status}    coam_cu.get_dus_status_info
    Log    ${dus_status}
    FOR    ${dus}    IN    @{dus_status}
        should be true    ${dus['Cells unlocked/locked'].split('/')[0].strip()} == ${dus['Total Cells']}
        Should Contain     ${dus['F1 Link status']}    Available
        Should Contain     ${dus['Administrative state']}    Unlocked
    END
#    ${X2_link_status}    coam_cu.get_X2_link_status_info
#    Log      ${X2_link_status}
#    FOR    ${status}    IN    @{X2_link_status}
#        should contain      ${status['X2 link status']}    Available
#        should contain      ${status['Locking state']}    Unlocked
#    END
#    ${VMs_status}    Get VMs Status Info
#    Log      ${VMs_status}
#    FOR    ${status}    IN    @{VMs_status}
#        should contain    ${status['Status']}    Online
#    END

Precondition
    [Documentation]    Check status on CU and DU
    [Arguments]    ${flag}=True
    coam_cu.enable_virtual_display
    sleep    5s
    run keyword if    '${flag}'=='True'    coam_cu.login    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/
    ...    username=Nemuadmin    password=nemuuser    browser=firefox    timeout=60
    ${dus_status}    coam_cu.get_dus_status_info
    Log    ${dus_status}
    FOR    ${dus}    IN    @{dus_status}
        should be true    ${dus['Cells enabled/disabled'].split('/')[0].strip()} == ${dus['Total Cells']}
        should be true    ${dus['Cells unlocked/locked'].split('/')[0].strip()} == ${dus['Total Cells']}
        Should Contain     ${dus['F1 Link status']}    Available
        Should Contain     ${dus['Administrative state']}    Unlocked
    END

    ${cells_status}    coam_cu.get_cells_status_info
    Log    ${cells_status}
    FOR    ${cell}    IN    @{cells_status}
        Should Contain     ${cell['Administrative state']}    Unlocked
        Should Contain     ${cell['Operational state']}    Enabled
    END

#    ${X2_link_status}    coam_cu.get_X2_link_status_info
#    Log      ${X2_link_status}
#    FOR    ${status}    IN     @{X2_link_status}
#        should contain      ${status['X2 link status']}    Available
#        should contain      ${status['Locking state']}    Unlocked
#    END

#    ${VMs_status}    Get VMs Status Info
#    Log      ${VMs_status}
#    FOR    ${status}    IN     @{VMs_status}
#        should contain    ${status['Status']}    Online
#    END
#    Check DU status

teardown for SA
    [Arguments]    ${L3_call}=off
    run keyword and ignore error    Unlock DU on CU WebEM
    run keyword and ignore error    Unlock Cells on CU WebEM
    run keyword and ignore error    Unlock Cell Groups on CU WebEM
    run keyword and ignore error    coam_cu.logout
    coam_cu.disable_virtual_display
    run keyword if    "${L3_call}"=="on"    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}
    CI_interface.Common Case Teardown
