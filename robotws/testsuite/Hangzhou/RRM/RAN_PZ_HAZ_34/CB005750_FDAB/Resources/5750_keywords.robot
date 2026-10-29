*** Settings ***
Resource          ./5750_variables.robot
Variables          ./../TestData/5750_nidd_modify.py
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource           ./../../5GC002157/Resources/5GC002157_keywords.robot
Resource     taf/rfrl/bts/robot/common/gnb_link.robot
Resource     taf/rfrl/bts/robot/common/enb_cell.robot

*** Keywords ***
Get x2status from both enb and gnb side
     [Documentation]    Author: Ren Biyao
     [Arguments]      ${connection}=GNB_OAM
     Connect to gnb coam via ssl
     @{MOs_lteenb_a}    coam.get_managed_objects    class_name=LTEENB_A    connection=${connection}
     @{MOs_lteenb_r}    coam.get_managed_objects    class_name=LTEENB_R    connection=${connection}
     &{dict_x2LinkLock}     coam.get_parameters    dist_name=${MOs_lteenb_a[0]['distName']}  pattern=x2LinkLock
     ...    connection=${connection}
     &{dict_x2LinkStatus}    coam.get_parameters    dist_name=${MOs_lteenb_r[0]['distName']}  pattern=x2LinkStatus
     ...    connection=${connection}
     [Return]     ${dict_x2LinkLock}    ${dict_x2LinkStatus}
     [Teardown]      run keyword and ignore error      COAM Teardown gnb connections

Post suite condition
     [Documentation]   Author: Ren Biyao
     Delete LNADJGNB on enb side    objects_to_delete_via_api=${LNADJGNB_OBJ_TO_DELETE}    enb_index=${1}
     Tear down all SISO connections

Post case condition
     [Documentation]   Author: Ren Biyao
     [Arguments]      ${log_name}=TC
     Connect to Common Unit Master
     Connect to Common Unit Slave
     Stop trace capturing    log_prefix=${log_name}    connection_alias=ASIK Master
     core.collect_collectors   names=cpif_tcpdump    target_dir=${target_dir}
     power_ue.UE Detach    ue_type=${UE_TYPE}
     Close all connection
     CI_interface.Common Case Teardown

Disable x2 route from enb
     [Documentation]    Author: Ren Biyao
     [Arguments]      ${enb_index}=${0}
     ssh.Connect to    ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
     ...               ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.username}
     ...               ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.password}
     ...               alias=enb_${enb_index}
     ssh.send command    command=iptables -t filter -I INPUT -p sctp -s ${tl.gnbs[0].cu.oam_ssh_connection_details.addr} --dport 36422 -j DROP
     ...    connection=enb_${enb_index}
     [Teardown]     run keyword and ignore error     ssh.Disconnect     connection=enb_${enb_index}

Recover x2 route from enb
     [Documentation]    Author: Ren Biyao
     [Arguments]      ${enb_index}=${0}
     ssh.Connect to    ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
     ...               ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.username}
     ...               ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.password}
     ...               alias=enb_${enb_index}
     ssh.send command    command=iptables -D INPUT -p sctp -s ${tl.gnbs[0].cu.oam_ssh_connection_details.addr} --dport 36422 -j DROP
     ...    connection=enb_${enb_index}
     [Teardown]     run keyword and ignore error     ssh.Disconnect     connection=enb_${enb_index}

Suite setup
     [Arguments]     ${scf_tmp_to_use}=${SCF_DEFAULT_FILE_PATH}     ${enb_index}=${None}
     Connect to Common Unit Master
     Suite common setup preparation    enb_index=${enb_index}    cluster_start_up_timeout=${RECOVERY_TIMEOUT}
     ...    scf_template_path=${scf_tmp_to_use}    scf_modify_parameters=${PAPRAMS_MODIFY_SCF}
     ...    is_pdl_checking_needed=${False}    prepare_ue=${True}
     Make SgNBAddition on specific cell     gnb_ps_cell_index=${1}

Lock or unlock x2 link on enb side
     [Arguments]     ${parameters_to_update_via_api}    ${enb_index}=${0}
     Connect to eNB via ssl    connection=enblte_${enb_index}     enb_index=${enb_index}
     ${update_status}    COAM Update several parameters via rest api    connection=enblte_${enb_index}
     ...     parameters_to_update_via_api=${parameters_to_update_via_api}    timeout=6 min
     Should be true    '${update_status}'=='PASS'
     [Teardown]     run keyword and ignore error     Enblte close down     connection=enblte_${enb_index}

Lock or unlock x2 link on gnb side
    [Arguments]    ${parameters_to_update_via_api}
    Connect to gnb coam via ssl
    ${update_status}    COAM Update several parameters via rest api    connection=GNB_OAM
     ...     parameters_to_update_via_api=${parameters_to_update_via_api}    timeout=6 min
    Should be true    '${update_status}'=='PASS'
    [Teardown]      run keyword and ignore error      COAM Teardown gnb connections

Add LNADJGNB on enb side
     [Arguments]    ${parameters_to_update_via_api}    ${enb_index}=${0}
     run keyword and ignore error    Delete LNADJGNB on enb side    objects_to_delete_via_api=${LNADJGNB_OBJ_TO_DELETE}    enb_index=${1}
     wait until keyword succeeds     6min     2sec    Connect to eNB via ssl    connection=enblte_${enb_index}     enb_index=${enb_index}
     COAM add several MOs via rest api    objects_to_add_via_api=${parameters_to_update_via_api}
     ...    timeout=70    connection=enblte_${enb_index}
     [Teardown]     run keyword and ignore error     Enblte close down     connection=enblte_${enb_index}

Delete LNADJGNB on enb side
     [Arguments]    ${objects_to_delete_via_api}    ${enb_index}=${0}
     wait until keyword succeeds     6min     2sec    Connect to eNB via ssl    connection=enblte_${enb_index}     enb_index=${enb_index}
     COAM delete objects via rest api    objects_to_delete_via_api=${objects_to_delete_via_api}
     ...    timeout=70    connection=enblte_${enb_index}
     [Teardown]     run keyword and ignore error     Enblte close down     connection=enblte_${enb_index}

X2 should be available
    [Documentation]   author: Ren Biyao
    ${dict_x2LinkLock}    ${dict_x2LinkStatus}    Get x2status from both enb and gnb side
    should be equal as strings    ${dict_x2LinkStatus['x2LinkStatus']}    available

X2 should be unavailable
    [Documentation]   author: Ren Biyao
    ${dict_x2LinkLock}    ${dict_x2LinkStatus}    Get x2status from both enb and gnb side
    should be equal as strings    ${dict_x2LinkStatus['x2LinkStatus']}    unavailable

Recover route
    [Documentation]   author: Ren Biyao
    Connect to gnb coam via ssl
    ${is_need_to_recover_x2link}    run keyword and return status      Expect Fault Should Present     faultId=7308
    run keyword if    ${is_need_to_recover_x2link}    Reset eNB site status
    coam.reset_site    connection=GNB_OAM
    Wait until cluster is on cell on air status    timeout=10min    is_all_cells_checking_needed=${True}
    ...    is_x2_check_from_enb_needed=${False}    is_enb_status_check_needed=${False}
    [Teardown]      coam.teardown   connection=GNB_OAM
