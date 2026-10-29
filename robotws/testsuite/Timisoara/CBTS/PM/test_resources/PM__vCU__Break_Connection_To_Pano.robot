*** Settings ***
Documentation
...  First, TC is checking that a new 3GPP PM file is created on vCU and Pano server.
...  Then activeBulkPmReportingFormat is changed to OMeS and a new PM file should not be created.
...  activeBulkPmReportingFormat parameter is restored and vesEndpointIpAddress is set to dummy address.
...  Fault 4639 'Problem sending VES event to SMO/ONAP VES Endpoint' must be visible.
...  vesEndpointIpAddress is restored and fid 4639 must be cleared.
...  In the end, TC checks if new 3GPP PM file is created on vCU and Pano server.

Resource  ../../common_resources/vcu_frame.robot
Resource  ../resources/PM_general.robot


*** Keywords ***
TC__PM__vCU__Break_Connection_To_Pano
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29360
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29360 - TC creation

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  FEATURE-CB006088

    Step0: TC Prerequisites
    Step1: Check New 3GPP File Is Created On Vcu And Pano
    Step2: Change ActiveBulkPmReportingFormat To OMeS
    Step3: Check New 3GPP File Is Not Created On Vcu And Pano
    Step4: Change ActiveBulkPmReportingFormat To 3GPP_OMeS
    Step5: Change VesEndpointIpAddress To Dummy IP And Check If Fid 4639 Is Visible
    Step6: Restore VesEndpointIpAddress And Check If Fid 4639 Is Cleared
    Step7: Check New 3GPP File Is Created On Vcu And Pano


Step0: TC Prerequisites
    ${rep_interval_value}  VCU Get Parameter Value  reportingIntervalPm  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    IF  '${rep_interval_value}'!='5min'
      Change specific parameter for vCU  reportingIntervalPm  5min  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
      Sleep Until New Cycle  5min
    END
    ${FAULT_4639}  Create Dictionary  fault_id=4639  fault_name=Problem sending VES event to SMO/ONAP VES Endpoint
    ...  alarm_id=7115  alarm_name=BASE STATION INFORMATION  severity=regex"Minor|minor"
    Set Test Variable  ${FAULT_4639}


Step${index}: Check New 3GPP File Is Created On Vcu And Pano
    Log  \nStep${index}: Check New 3GPP File Is Created On Vcu And Pano  console=true
    Sleep Until New Cycle  5min
    Sleep  1min  TC will wait until PM report is loaded.
    ${next_to_last_pm_file_line_from_vcu}  Get Last 3GPP PM File Line From Vcu
    ${next_to_last_pm_file_from_vcu}  Set Variable  ${next_to_last_pm_file_line_from_vcu}[-1]
    ${next_to_last_pm_file_from_pano}  Get Last PM File Name From Pano  ${VCU_MRBTS_ID}

    Sleep Until New Cycle  5min
    Sleep  1min  TC will wait until PM report is loaded.

    ${last_pm_file_from_line_vcu}  Get Last 3GPP PM File Line From Vcu
    ${last_pm_file_from_vcu}  Set Variable  ${last_pm_file_from_line_vcu}[-1]
    ${last_pm_file_from_pano}  Get Last PM File Name From Pano  ${VCU_MRBTS_ID}
    Should Not Be Equal As Strings  ${next_to_last_pm_file_from_vcu}  ${last_pm_file_from_vcu}
    ...  A new 3GPP PM file was not created on vCU.
    Should Not Be Equal As Strings  ${next_to_last_pm_file_from_pano}  ${last_pm_file_from_pano}  A new 3GPP PM file was not created on Pano.


Step${index}: Change ActiveBulkPmReportingFormat To ${new_value}
    Log  \nStep${index}: Change ActiveBulkPmReportingFormat To ${new_value}  console=true
    Change specific parameter for vCU  activeBulkPmReportingFormat  ${new_value}  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1


Step3: Check New 3GPP File Is Not Created On Vcu And Pano
    Log  \nStep3: Check New 3GPP File Is Not Created On Vcu And Pano  console=true
    ${next_to_last_pm_file_line_from_vcu}  Get Last 3GPP PM File Line From Vcu
    ${next_to_last_pm_file_from_vcu}  Set Variable  ${next_to_last_pm_file_line_from_vcu}[-1]
    ${next_to_last_pm_file_from_pano}  Get Last PM File Name From Pano  ${VCU_MRBTS_ID}

    Sleep Until New Cycle  5min
    Sleep  1min  TC will wait until PM report is loaded.

    ${last_pm_file_from_line_vcu}  Get Last 3GPP PM File Line From Vcu
    ${last_pm_file_from_vcu}  Set Variable  ${last_pm_file_from_line_vcu}[-1]
    ${last_pm_file_from_pano}  Get Last PM File Name From Pano  ${VCU_MRBTS_ID}
    Should Be Equal As Strings  ${next_to_last_pm_file_from_vcu}  ${last_pm_file_from_vcu}  A new 3GPP PM file was created on vCU.
    Should Be Equal As Strings  ${next_to_last_pm_file_from_pano}  ${last_pm_file_from_pano}  A new 3GPP PM file was created on Pano.


Step5: Change VesEndpointIpAddress To Dummy IP And Check If Fid 4639 Is Visible
    Log  \nStep5: Change VesEndpointIpAddress To Dummy IP And Check If Fid 4639 Is Visible  console=true
    Change specific parameter for vCU  vesEndpointIpAddress  10.0.0.0  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1/VESENDPOINT-1
    Wait Until Keyword Succeeds  180s  15s  Check If Fault Is Visible In VCU WebEM  ${FAULT_4639}[alarm_id]  ${FAULT_4639}[alarm_name]
    ...  ${FAULT_4639}[fault_id]  ${FAULT_4639}[fault_name]  ${FAULT_4639}[severity]


Step6: Restore VesEndpointIpAddress And Check If Fid 4639 Is Cleared
    Log  \nStep6: Restore VesEndpointIpAddress And Check If Fid 4639 Is Cleared  console=true
    Change specific parameter for vCU  vesEndpointIpAddress  ${VM_WITH_PANO_IP}  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1/VESENDPOINT-1
    Wait Until Keyword Succeeds  180s  15s  Check If Fault Is Cleared From VCU WebEM  ${FAULT_4639}[alarm_id]  ${FAULT_4639}[fault_id]


Restore Parameters Value If Needed
    ${reporting_format}  VCU Get Parameter Value  activeBulkPmReportingFormat  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    IF  '${reporting_format}'!='3GPP_OMeS'
    ...  Change specific parameter for vCU  activeBulkPmReportingFormat  3GPP_OMeS  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1

    ${ves_ip_address}  VCU Get Parameter Value  vesEndpointIpAddress  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1/VESENDPOINT-1
    IF  '${ves_ip_address}'!='${VM_WITH_PANO_IP}'
    ...  Change specific parameter for vCU  vesEndpointIpAddress  ${VM_WITH_PANO_IP}  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1/VESENDPOINT-1


TC Setup
    Common VCU Setup
    Turn ON Pano And Check If Is Connected
    Modify Resource Search Order  PM__vCU__Break_Connection_To_Pano


TC Teardown
    Run Keyword If Test Failed  Restore Parameters Value If Needed
    Turn OFF Pano And Check If Is Disconnected
    Common VCU Teardown