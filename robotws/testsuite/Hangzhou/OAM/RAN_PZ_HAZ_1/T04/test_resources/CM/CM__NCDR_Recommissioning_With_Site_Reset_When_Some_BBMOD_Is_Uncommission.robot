*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot
*** Variables ***
${Target_Plan}
...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/CM_BBMOD_UNCOMMSSION.xml
${EXPECTED_BBMOD_COUNT}    6
${EXPECTED_BBMOD_IDLE}    5
${PDU_Model}      FACOM    # pdu device to create. If it is a string, it is assumed to represent a vendor.
${PDU_IP}         10.106.253.39   #ip address or hostname of pdu device
${PDU_Ports}      7    #e.g.1,2,3,4,5
${RECOVER_FLAG}   false
*** Keywords ***
CM__NCDR_Recommissioning_With_Site_Reset_When_Some_BBMOD_Is_Uncommission
    [Documentation]
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for site startup with uncommissioned BBMODs via different reset
    ...    The main steps performed for the test are:
    ...    - Provision the BBMOD uncommission plan
    ...    - Get initial BTS RESET info from blackbox file
    ...    - Admin reset and check state
    ...    - Get final BTS RESET info from blackbox file
    ...    - Check BTS RESET 1 times
    ...    - Delta plan commission reset and check state
    ...    - Get final BTS RESET info from blackbox file
    ...    - Check BTS RESET 2 times
    ...    - Power reset and check state
    ...    Pass criteria: cell on air after every reset and no any unexpected alarm raised after site start up
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 06.02.2023 - New case by Gao Yuan
    ...    Transfer from MRT cases RAN_SyVe_CM_NCDR_Recommissioning with site reset when some BBMOD is uncommission
    Set Tags    AUTHOR-yuan.1.gao@nokia-sbell.com    OWNER-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Step 1: Provision the BBMOD uncommission plan
    Step 2: Get initial BTS RESET info from blackbox file
    Step 3: Admin reset and check state
    Step 4: Get final BTS RESET info from blackbox file
    Step 5: Check BTS RESET 1 times
    Step 6: Delta plan commission reset and check state
    Step 7: Get final BTS RESET info from blackbox file
    Step 8: Check BTS RESET 2 times
    Step 9: Power reset and check state

Step ${index}: Get ${when} BTS RESET info from blackbox file
    Log    Step ${index}: Get ${when} BTS RESET info from blackbox file    console=True
    Get BTS RESET info from blackbox file SyVe    when=${when}    target_ip=192.168.255.129

Step ${index}: Check BTS RESET ${count} times
    Log    Step ${index}: Check BTS RESET ${count} times    console=True
    Check BTS RESET behavior SyVe    ${count}

Step ${index}: Provision the BBMOD uncommission plan
    Log    Step ${index}: Provision the BBMOD uncommission plan    console=True
    Admin Get bts_id and perform commissioning    ${Target_Plan}    ${SKIP_PARAM_RELATION_ERRORS}    30 min
    Set Test Variable    ${RECOVER_FLAG}    true
    Wait Until Keyword Succeeds    20 min    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Check the BBMOD State As Expected

Step ${index}: Admin reset and check state
    Log    Step ${index}: Admin reset and check state    console=True
    coam.Reset
    Log    Admin reset started    console=True
    Wait Until Keyword Succeeds    20 min    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Check the BBMOD State As Expected

Step ${index}: Power reset and check state
    Log    Step ${index}: Power reset and check state    console=True
    ${PDU_Ports_list}    Split String    ${PDU_Ports}    ,
    Set Test Variable    ${PDU_Ports_list}
    pdu.setup_pdu    model=${PDU_Model}    host=${PDU_IP}    alias=reset_pdu
    Log    PDU Off started    console=True
    FOR    ${port}    IN    @{PDU_Ports_list}
        pdu.power_off    ${port}    pdu_device=reset_pdu
    END
    sleep    10s
    FOR    ${port}    IN    @{PDU_Ports_list}
        ${PDU_status}    PDU.get_port_status    port=${port}    pdu_device=reset_pdu
        Should Be Equal    ${PDU_status}    off
    END
    Wait Until SBTS Disconnected
    coam.Teardown Admin
    Log    PDU ON started    console=True
    sleep    10s
    FOR    ${port}    IN    @{PDU_Ports_list}
        pdu.power_on    ${port}    pdu_device=reset_pdu
    END
    sleep    10s
    FOR    ${port}    IN    @{PDU_Ports_list}
        ${PDU_status}    PDU.get_port_status    port=${port}    pdu_device=reset_pdu
        Should Be Equal    ${PDU_status}    on
    END
    Wait Until Keyword Succeeds    3min    2 sec    Check IP Is Pingable    192.168.255.129
    Start Admin    bts_host=192.168.255.129
    Wait Until Keyword Succeeds    20 min    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Check the BBMOD State As Expected

Step ${index}: Delta plan commission reset and check state
    Log    Step ${index}: Delta plan commission reset and check state    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    ${BTS_scf_content}=  coam.Get SCF    export_type=configuration
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf_content}
    ${current_value}    L_XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@distName="MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1"]/p[@name="actMplaneFronthaulFirewall"]
    ${plan_value}    Set Variable If    "${current_value}"=="false"     true    false
    Log    ${plan_value}
    coam.create_delta
    coam.append_parameter_update_to_delta    	MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    actMplaneFronthaulFirewall    value=${plan_value}
    ${json}    coam.getdelta
    coam.Perform delta recommissioning    ${json}
    Log    Delta plan commission reset started     console=True
    Wait Until Keyword Succeeds    20 min    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Check the BBMOD State As Expected

Check the BBMOD State As Expected
    Log    Check the BBMOD State As Expected    console=True
    ${bts_all_info}=    coam.Get Bts Info
    ${bbmod_info_list}=    Get From Dictionary    ${bts_all_info}    basebandModules
    Log list    ${bbmod_info_list}
    ${bbmod_active_count}    Set Variable    0
    ${bbmod_idle_count}    Set Variable    0
    &{current_bbmod_info}    Create Dictionary
    FOR    ${item}    IN    @{bbmod_info_list}
        Set To Dictionary    ${current_bbmod_info}    ${item['id']['runtime']}=${item['status']}
    END
    ${BBMOD_R_list}    Get Dictionary Keys    ${current_bbmod_info}
    ${current_bbmod_count}    Get Length    ${BBMOD_R_list}
    Should Be Equal As Strings    ${current_bbmod_count}    ${EXPECTED_BBMOD_COUNT}
    ${current_bbmod_status}    Get Dictionary Values    ${current_bbmod_info}
    FOR    ${item}    IN    @{current_bbmod_status}
        ${active_tmp}    Set Variable If    "${item['operationalState']}"=="${_Enabled_}" and "${item['usageState']}"=="${_Active_}"
        ...    ${true}    ${false}
        ${idle_tmp}    Set Variable If    "${item['operationalState']}"=="${_Enabled_}" and "${item['usageState']}"=="${_Idle_}"
        ...    ${true}    ${false}
        ${bbmod_active_count}    Convert To Integer    ${bbmod_active_count}
        ${bbmod_active_count}    Set Variable If    ${active_tmp}    ${bbmod_active_count+1}    ${bbmod_active_count}
        ${bbmod_idle_count}    Convert To Integer    ${bbmod_idle_count}
        ${bbmod_idle_count}    Set Variable If    ${idle_tmp}    ${bbmod_idle_count+1}    ${bbmod_idle_count}
    END
    Should Be Equal As Integers    ${bbmod_idle_count}    ${EXPECTED_BBMOD_IDLE}
    ${current_bbmod_count}    Convert To Integer    ${current_bbmod_count}
    Should Be Equal As Integers    ${bbmod_active_count}      ${current_bbmod_count-${bbmod_idle_count}}

Particular Teardown
    Common Test Teardown SBTS
    Start Admin    bts_host=192.168.255.129
    Run keyword if    "${RECOVER_FLAG}"=="true"     Admin Get bts_id and perform commissioning    ${scf_path}
    ...   ${SKIP_PARAM_RELATION_ERRORS}    30 min
    Log    Commissioning done. Site reset started    console=True
    Wait Until Keyword Succeeds    20 min    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    coam.Teardown Admin

TC Setup
    Common Test Setup SBTS

TC Teardown
    Particular Teardown
