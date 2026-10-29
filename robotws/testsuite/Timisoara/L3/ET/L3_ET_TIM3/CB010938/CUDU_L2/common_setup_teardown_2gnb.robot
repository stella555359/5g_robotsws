*** Keywords ***
Full Commission SCF File Through Mplane With Admin
    [Arguments]    ${scf_file}    ${nrbts_id}=1    ${mplane_ip}=10.0.1.2
    ${vlan_id_str}=    Convert To String    ${VLAN_ID}
    Set Single Value From Scf File    ${scf_file}    MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1    vlanId    ${vlan_id_str}
    COAM.Setup Admin
    ...    bts_host=${mplane_ip}
    COAM.Perform Commissioning
    ...    bts_id=${nrbts_id}
    ...    scf_file=${scf_file}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=500
    [Teardown]    COAM.Teardown

Import Testline Variables For 2 GNBs
    ${ret}    ${host_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${testline_config_path1}=    Set Variable    /home/ute/testline_configuration/${host_name}
    ${testline_config_path2}=    Set Variable    /home/ute/testline_init_results/configs/${host_name}
    ${host_name1}=    Set Variable    ${host_name[0:-2]}
    ${testline_config_path3}=    Set Variable    /home/ute/testline_configuration/${host_name1}
    ${ret1}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${testline_config_path1}/__init__.py
    ${ret2}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${testline_config_path2}/__init__.py
    ${ret3}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${testline_config_path3}/__init__.py
    ${testline_config_path}=    Set Variable If    "${ret1}"=="${True}"    ${testline_config_path1}
    ...    "${ret2}"=="${True}"    ${testline_config_path2}
    ...    "${ret3}"=="${True}"    ${testline_config_path3}
    Log    Testline init file is ${testline_config_path}      console=${True}
    Import Variables    ${testline_config_path}
    Set Suite Variable    ${AP_PDU_IP}    ${tl.ues[0].l1.common_units[0].pdu_port.pdu.addr}
    Set Suite Variable    ${AP_PDU_PORT}    ${tl.ues[0].l1.common_units[0].pdu_port.port_no}
    Set Suite Variable    ${GNB_PDU_IP}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    Set Suite Variable    ${GNB_PDU_PORT}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    Set Suite Variable    ${AP_PDU}    ${tl.ues[0].l1.common_units[0].pdu_port.pdu}
    Set Suite Variable    ${GNB_PDU}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu}
    Set Suite Variable    ${GNB_PDU_IP1}    ${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    Set Suite Variable    ${GNB_PDU_PORT1}    ${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.port_no}
    Set Suite Variable    ${GNB_PDU1}    ${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.pdu}
    Set Suite Variable    ${TLPC_IP}    ${tl.test_pc.default_ssh_connection_details.addr}
    Set Suite Variable    ${TLPC_SSH_UE}    ${tl.test_pc.default_ssh_connection_details.username}
    Set Suite Variable    ${TLPC_SSH_PWD}    ${tl.test_pc.default_ssh_connection_details.password}
    Set Suite Variable    ${VLAN_ID}    ${tl.gnbs[0].cu.x2c.vlan_id}

Hard Reboot Testline For 2 GNBs
    Log To Console    Start to power off...
    PDU.Setup Pdu    ${AP_PDU}    alias=pdu_alias_ap
    PDU.Power Off    port=${AP_PDU_PORT}    pdu_device=pdu_alias_ap
    PDU.Setup Pdu    ${GNB_PDU}    alias=pdu_alias_gnb
    PDU.Power Off    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_gnb
    PDU.Setup Pdu    ${GNB_PDU1}    alias=pdu_alias_gnb1
    PDU.Power Off    port=${GNB_PDU_PORT1}    pdu_device=pdu_alias_gnb1
    Wait Until Keyword Succeeds    120s    5s    Check Ping NOK    10.0.1.2
    Wait Until Keyword Succeeds    120s    5s    Check Ping NOK    10.0.1.3
    Wait Until Keyword Succeeds    120s    5s    Check Ping NOK    10.0.2.80
    Log To Console    Start to power on...
    PDU.Power On    port=${AP_PDU_PORT}    pdu_device=pdu_alias_ap
    PDU.Power On    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_gnb
    PDU.Power On    port=${GNB_PDU_PORT1}    pdu_device=pdu_alias_gnb1
    Wait Until Keyword Succeeds    240s    5s    Check Ping OK    10.0.1.2
    Wait Until Keyword Succeeds    120s    5s    Check Ping OK    10.0.1.3
    Wait Until Keyword Succeeds    120s    5s    Check Ping OK    10.0.2.80

Reboot TL And Check Configured For 2 GNBs
    [Documentation]    This keyword is to soft reboot testline and check the status is configured.
    ...            It with try ${MAX_REBOOT_TIME} times to make sure the testline can be reboot successfully.
    Log To Console    Make sure BTS site is ready by rebooting at most ${MAX_REBOOT_TIME} times...
    Run Keyword And Ignore Error    Remove hwf File To Save Reboot Time
    #Run Keyword And Ignore Error    Wait GNB And AP SSH Connect OK
    Set Suite Variable    ${reboot_sucess_flag}    ${False}
    FOR    ${index}    IN RANGE    1    ${MAX_REBOOT_TIME}+1
        Log To Console    ===============Reboot Time: ${index}==============
        Hard Reboot Testline For 2 GNBs
        ${res}    Run Keyword And Return Status    Verify Coam Site Is Ready For 2 GNBs
        ${reboot_sucess_flag}=    Set Variable If    '${res}'=='True'    ${True}
        Exit For Loop If    '${res}'=='True'
    END
    Should Be True    "${reboot_sucess_flag}"=="${True}"    WRN:Reboot ${MAX_REBOOT_TIME} times,RRU still can't go to green state.

Verify Coam Site Is Ready For 2 GNBs
    [Documentation]    This keyword is to check the state of gNB is configured and Radio is online.
    Log To Console    Verify bts site is ready for GNB1...
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify BTS Is Configured
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify Radio Is Online
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify All Cells Are Configured
    Log To Console    Verify bts site is ready for GNB2...
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify BTS Is Configured By Mplane    10.0.1.3
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify Radio Is Online By Mplane    10.0.1.3
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify All Cells Are Configured By Mplane    10.0.1.3

Verify BTS Is Configured By Mplane
    [Arguments]    ${mplane_ip}=10.0.1.2
    [Documentation]    This keyword is to check the state of gNB is Configured or IntegratedToRan
    Log To Console    verify BTS is configured...
    COAM.Setup Admin    bts_host=${mplane_ip}
    ${bts_state}    COAM.Get Mrbts State
    Log To Console    [INFO] BTS STATE : ${bts_state}
    Should Contain Any    ${bts_state}    Configured    IntegratedToRan    OnAir    ignore_case=True
    [Teardown]    COAM.Teardown

Verify Radio Is Online By Mplane
    [Arguments]    ${mplane_ip}=10.0.1.2
    [Documentation]    This keyword is to check the state of Radios are online
    #[Arguments]    ${ru_nums}=${RRU_NUMS}
    #${ru_nums}=    Evaluate    len(${RRU_TYPE_LIST})
    Log To Console    verify Radio is online...
    COAM.Setup Admin    bts_host=${mplane_ip}
    ${bts_hw_info}    COAM.Get Bts Info
    ${ru_nums}=    Get Length    ${bts_hw_info['radioModules']['rmod']}
    Log    RRU number: ${ru_nums}    console=True
    FOR    ${id}    IN RANGE    0    ${ru_nums}
        ${radio_state}    Set Variable
        ...    ${bts_hw_info['radioModules']['rmod'][ ${id}]['status']['operationalState']}
        ${ru_id}=    Evaluate    ${id}+1
        Log To Console    [INFO]    RADIO${ru_id}    STATE : ${radio_state}
        Should Be Equal As Strings    ${radio_state}    enabled    ignore_case=True
    END
    [Teardown]    COAM.Teardown Admin

Verify All Cells Are Configured By Mplane
    [Arguments]    ${mplane_ip}=10.0.1.2
    ${all_cell_status}    Get All Cell Status From COAM By Mplane    ${mplane_ip}
    List Should Not Contain Value    ${all_cell_status}    initializing    WRN:cell is not configured.Check SCF para!

Get All Cell Status From COAM By Mplane
    [Arguments]    ${mplane_ip}=10.0.1.2    ${status_type}=proceduralStatus
    [Documentation]    This keyword is to get cell status from COAM.
    ...    status_type = administrativeState/availabilityStatus/blockingState/operationalState/proceduralStatus/usageState
    #${coam_connection}    COAM.Connect To    bts_host=${mplane_ip}
    COAM.Setup Admin    bts_host=${mplane_ip}
    ${all_cell_info}    COAM.Get Cells Info    cell_type=nr    timeout=30
    ${all_cell_status}    Create List
    FOR    ${cell_info}    IN    @{all_cell_info}
        ${cell_status}    Evaluate    ${cell_info}.get('status').get('${status_type}')
        Append To List    ${all_cell_status}    ${cell_status}
    END
    [Return]    ${all_cell_status}
    [Teardown]    COAM.Teardown

Get PhysCellId Of GNB By Mplane
    [Arguments]    ${mplane_ip}=10.0.1.2
    [Documentation]    This keyword to get radio protocol type from current scfc file
    ${coam_connection}    COAM.Connect To    bts_host=${mplane_ip}
    ${cells_info}=    COAM.get_cell_list    connection=${coam_connection}
    ${cell_num}=    Get Length    ${cells_info['cells']['nr']}
    ${pci}=    Create List
    FOR    ${cell_id}    IN RANGE    ${cell_num}
        Append To List    ${pci}    ${cells_info['cells']['nr'][${cell_id}]['physicalCellId']}
    END
    Set Suite Variable    ${NR_PHY_CELL_IDS}
    [Return]    ${pci}
    [Teardown]    COAM.Teardown    ${coam_connection}

Get Cell Numbers For 2 GNBs
    ${nr_phy_cell_ids}=    Get PhysCellId Of GNB By Mplane    10.0.1.2
    ${cell_number_gnb_1}=    Get Length    ${nr_phy_cell_ids}
    ${nr_phy_cell_ids}=    Get PhysCellId Of GNB By Mplane    10.0.1.3
    ${cell_number_gnb_2}=    Get Length    ${nr_phy_cell_ids}
    ${cell_number}=    Evaluate    sum([${cell_number_gnb_1},${cell_number_gnb_2}])
    Set Suite Variable    ${COMPONENT_CARRIER}    ${cell_number}
    Log    Cells Number: ${COMPONENT_CARRIER}     console=${True}
    [Return]    ${cell_number}
