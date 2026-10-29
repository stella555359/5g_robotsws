*** Settings ***
Documentation
...     [Author]     	"Sharavathi & Vishal"
...	    [Maintenance]	"TRS I & V Tools Bangalore Team"

Variables	ta_e2e_bts_trs_fw

*** Keywords ***
Verify E2 interface alarms
    [Arguments]      ${status}
    Verify Ems Alarm    config_device=netact	faultid=${faultnum_E2SCTPFail}   should_exist=${status}	occurrences=1
    ...    alias=lab1042	 dist_name=PLMN-PLMN/MRBTS-${bts_id}

Verify E2LinkStatus
    [Arguments]      ${AdminStatus}  ${linkStatus}
    ${e2LinkAdminStatus}=     Configuration Get     config_device=netact     param_path=${adminStatus_moc}    alias=lab1042
    Should Be Equal     ${e2LinkAdminStatus}   ${AdminStatus}
    ${E2_status_moc}=   Query Admin Infomodel   query=get object ${e2_moc_path}
    Log    ${E2_status_moc}
    ${e2_link_status}=  Get From Dictionary     dictionary=${E2_status_moc}     key=e2LinkStatus
    Should Be Equal     ${e2_link_status}   ${linkStatus}

Get Near RT RIC IPAddress
    ${nrNearRTRICIPAddress}=     Get Parameter   param_path=${nrNearRTRICIPAddress_moc}
    Set Suite Variable      ${nrNearRTRICIPAddress}

Get Near RT RIC SCTPPort
    ${nrNearRTRICSCTPPort}=     Get Parameter   param_path=${nrNearRTRICSCTPPort_moc}
    Set Suite Variable      ${nrNearRTRICSCTPPort}

Get e2Plane ipv4Addresses
    ${e2Plane_ipV4Address}=     Get Parameter   param_path=${e2Plane_ipV4AddressDN1_moc}:localIpAddr
    Set Suite Variable      ${e2Plane_ipV4Address}

Get e2Plane ipv6Addresses
    ${e2Plane_ipV6Address}=     Get Parameter   param_path=${e2Plane_ipV6AddressDN1_moc}:localIpAddr
    Set Suite Variable      ${e2Plane_ipV6Address}

Modify cplane DSCP value
   Configuration Manage  config_device=netact    config=${dscp_mod}		plan_name=iv_fw_plan	delete_plan=${True}
   ...     alias=lab1042	operation=edit

Verify E2 Link Status With Change in Flag Admin State
   Configuration Manage  config_device=netact    config=${e2link_lock}     plan_name=iv_fw_plan    delete_plan=${True}
   ...     alias=lab1042   operation=edit
   Sleep   10
   Verify E2LinkStatus     Locked    inactive
   Configuration Manage  config_device=netact    config=${e2link_unlock}     plan_name=iv_fw_plan    delete_plan=${True}
   ...     alias=lab1042   operation=edit
   Sleep   10
   Verify E2LinkStatus     Unlocked    active

Verify RIC Connection Impact On BTS
    Configuration Manage  config_device=netact    config=${ricport_invalid}     plan_name=iv_fw_plan    delete_plan=${True}
    ...    alias=lab1042   operation=edit
    Sleep    200
    Verify Bts Status   should_be_onair=${True}
    Verify E2LinkStatus     Unlocked    inactive
    Verify E2 interface alarms      ${True}
    Configuration Manage  config_device=netact    config=${ricport_valid}     plan_name=iv_fw_plan    delete_plan=${True}
    ...    alias=lab1042   operation=edit
    Sleep    200
    Verify Bts Status   should_be_onair=${True}
    Verify E2LinkStatus     Unlocked    active
    Verify E2 interface alarms      ${False}

Verify E2 link flag modification on gNB
    Configuration Manage  config_device=netact    config=${acte2_disable}     plan_name=iv_fw_plan    delete_plan=${True}
    ...    alias=lab1042   operation=edit
    Sleep    200
    Verify Bts Status   should_be_onair=${True}
    Verify E2LinkStatus     Unlocked    inactive
    Configuration Manage  config_device=netact    config=${acte2_enable}     plan_name=iv_fw_plan    delete_plan=${True}
    ...    alias=lab1042   operation=edit
    Sleep    200
    Verify Bts Status   should_be_onair=${True}
    Verify E2LinkStatus     Unlocked    active

Tear Traffic Captures and NMS Down
    Teardown Ems      config_device=netact             alias=lab1042
    Run Keyword And Continue On Failure    Traffic Capture Stop    alias=on_bts
    Run Keyword And Continue On Failure    Traffic Capture Stop    alias=bef_reset
    Run Keyword And Continue On Failure    Traffic Capture Stop    alias=aft_reset
