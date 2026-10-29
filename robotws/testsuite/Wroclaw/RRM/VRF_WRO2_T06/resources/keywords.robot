*** Settings ***
Documentation    :copyright: Nokia
...              :authors: I_MN_RAN_RD_VRF_WRO2_6
...              :contact: I_MN_RAN_RD_VRF_WRO2_6


Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/tshark_verifying.robot
Library     testsuite/Wroclaw/RRM/resources/airphone/wro_2/resources/common_functions.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/common_keywords.py
Library     taf.sbts.oam.coam.admin  WITH NAME    coam
Library     taf.ul.ettf.setups
Library     ta5g_iphy
Library     ta5g_commissioning
Library     ta5g_testline_management
Library     ta5g_ue_mobility

*** Variables ***
@{ALLOWED_FAULT_ID}  4655  61649  61652  4654  61524  4681  4592  1936  8150  8000  4459  7300  7107  7305

*** Keywords ***
Prepare Test Setup For One Real Gnb And Enable Tshark Verification
    [Arguments]    ${tc_id}    ${iphy}=IPHY    ${scfc}=SCFC    ${cfg}=cfg
    ${iphy}=    Create Config File Path Variable Name     filetype=${iphy}    name=${tc_id}
    ${scfc}=    Create Config File Path Variable Name     filetype=${scfc}    name=${tc_id}
    ${cfg}=     Create Config File Path Variable Name     filetype=${cfg}     name=${tc_id}

    ${iphy_filename}=    Get Variable Value    ${iphy}
    ${scfc_filename}=    Get Variable Value    ${scfc}
    ${cfg_filename}=     Get Variable Value    ${cfg}
    Run Keywords
    ...                Update And Put Iphy Xml         input_filepath=${iphy_filename}
    ...    AND         Find Scfc And Fix And Send Full Commissioning    scfc_filename=${scfc_filename}
    ...    AND         Reset Wts
    ...    AND         Check Radios Availability

Prepare Test Setup For Two Real Gnbs And Enable Tshark Verification
    [Arguments]    ${tc_id}    ${iphy}=IPHY    ${scfc_MN}=SCFC_MN    ${scfc_SN}=SCFC_SN    ${cfg}=cfg
    ${iphy}=       Create Config File Path Variable Name     filetype=${iphy}       name=${tc_id}
    ${scfc_MN}=    Create Config File Path Variable Name     filetype=${scfc_MN}    name=${tc_id}
    ${scfc_SN}=    Create Config File Path Variable Name     filetype=${scfc_SN}    name=${tc_id}
    ${cfg}=        Create Config File Path Variable Name     filetype=${cfg}        name=${tc_id}

    ${iphy_filename}=       Get Variable Value    ${iphy}
    ${scfc_MN_filename}=    Get Variable Value    ${scfc_MN}
    ${scfc_SN_filename}=    Get Variable Value    ${scfc_SN}
    ${cfg_filename}=        Get Variable Value    ${cfg}
    Run Keywords
    ...                Update And Put Iphy Xml         input_filepath=${iphy_filename}
    ...    AND         Find Scfc And Fix And Send Full Commissioning
    ...                scfc_filename=${scfc_SN_filename}
    ...                remote_host=${REMOTE_HOST_1_IP}
    ...    AND         Find Scfc And Fix And Send Full Commissioning
    ...                scfc_filename=${scfc_MN_filename}
    ...    AND         Reach Onair    lua_cfg=${cfg_filename}    remote_hosts=${REMOTE_HOSTS}
    ...    AND         Enforce protocol    nr-rrc

Prepare Test Setup Wihout Full Commissioning For One Real Gnb And Enable Tshark Verification
    [Arguments]    ${tc_id}    ${cfg}=cfg
    ${cfg}=     Create Config File Path Variable Name     filetype=${cfg}     name=${tc_id}
    ${cfg_filename}=     Get Variable Value    ${cfg}

    Run Keywords
    ...                Trigger Site Reset
    ...    AND         Reset Wts
    ...    AND         Start Vm Ethernet Interfaces For Simulated gNB2
    ...    AND         Check Radios Availability
    ...    AND         Reach Onair    lua_cfg=${cfg_filename}
    ...    AND         Setup devices aliases for realMN simSN
    ...    AND         Setup X2 Link
    ...    AND         Enforce protocol    nr-rrc

Wait ${x:\d+}s To Reset Wts
    Sleep    ${x}s

Set VM Ethernet Interfaces for Simulated Core Network
    Start Vm Ethernet Interface    if_name=eth3:S11          ip_with_mask=10.0.1.134/24
    Start Vm Ethernet Interface    if_name=eth3:ENB_X2U      ip_with_mask=10.0.1.135/24
    Start Vm Ethernet Interface    if_name=eth3:ENB_S1       ip_with_mask=10.0.1.136/24
    Start Vm Ethernet Interface    if_name=eth3:MME_SIM      ip_with_mask=10.0.1.131/24
    Start Vm Ethernet Interface    if_name=eth3:ENB_X2C      ip_with_mask=10.0.1.137/24
    Start Vm Ethernet Interface    if_name=eth3:Server       ip_with_mask=10.0.1.132/24
    Start Vm Ethernet Interface    if_name=eth3:SERV         ip_with_mask=10.0.1.133/24
    Start Vm Ethernet Interface    if_name=eth3:AMF2         ip_with_mask=10.0.1.101/24
    Start Vm Ethernet Interface    if_name=eth3:AMF3         ip_with_mask=10.0.1.102/24
    Start Vm Ethernet Interface    if_name=eth3:OTH20        ip_with_mask=10.0.2.90/24
    Start Vm Ethernet Interface    if_name=eth3:OTH21        ip_with_mask=10.0.2.91/24
    Start Vm Ethernet Interface    if_name=eth3:OTH22        ip_with_mask=10.0.2.92/24
    Start Vm Ethernet Interface    if_name=eth3:OTH31        ip_with_mask=10.0.1.9/24
    Start Vm Ethernet Interface    if_name=eth3:OTH32        ip_with_mask=10.0.1.10/24
    Start Vm Ethernet Interface    if_name=eth3:OTH33        ip_with_mask=10.0.1.11/24
    Start Vm Ethernet Interface    if_name=eth3:OTH34        ip_with_mask=10.0.1.12/24
    Start Vm Ethernet Interface    if_name=eth3:OTH35        ip_with_mask=10.0.1.13/24
    Start Vm Ethernet Interface    if_name=eth3:OTH36        ip_with_mask=10.0.1.14/24
    Start Vm Ethernet Interface    if_name=eth3:OTH48        ip_with_mask=10.0.1.121/24
    Start Vm Ethernet Interface    if_name=eth3:OTH49        ip_with_mask=10.0.1.128/24

Activate And Check If X2 Link is active
    Setup X2 Link    pass_regexp=X2AP Link .* is up
    Log to console  \n***Activation of eNBSim with X2AP interface completed ***

Get Software Release Name
    [Arguments]   ${alias}
    ${release}       coam.Get sw release name  connection=${alias}
    Should not be empty   ${release}
    [Return]   ${release}

Connect With Runtime Release
    [Arguments]      ${alias}=coam
    coam.connect to  name=${alias}
    ${release}=   Wait Until Keyword Succeeds   5 min   1 min   Get Software Release Name   ${alias}
    coam.teardown    connection=${alias}
    coam.connect_to  name=${alias}             release=${release}

Check For Unexpected Active Alarms
    Connect With Runtime Release    Alarm
    FOR  ${faultId}   IN   @{ALLOWED_FAULT_ID}
        coam.add_allowed_alarm    faultId=${faultId}   connection=Alarm
    END
    coam.assert_no_unexpected_active_alarms   connection=Alarm
    [Teardown]    coam.Teardown     connection=Alarm

Perform UE RRC Reestablishment for UE#${first_UE}-UE#${last_UE} to Cell#${cell_id} on gNB#${gnb_id}
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Initiate UE RRC Reestablishment     ue_id=${UE}    gnb=${gnb_id}   cell=${cell_id}
    END

UE#${first_UE}-UE#${last_UE} perform inter-cell HO
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
        Execute Egate Command
    ...     cmd=ue_reauth id=${UE} nr_sec_cap=zuc|zuc
    ...     pass_regexp=Reauthentication procedure is complete
    Log To Console   Intra-Cell Handover executed for UE#${UE}
    END
