*** Settings ***
Documentation
    ...  Step 1. Check pano.log for latest PM
    ...  Step 2. Changing activateSendingBulkPmEvents to OMeS
    ...  Step 3. Check if 3GPP XML files was NOT created
    ...  Step 4. Changing activateSendingBulkPmEvents to 3GPP_OMeS
    ...  Step 5. Change vesEndpointIpAddress for dummy IP nad check if FID:4639 occured
    ...  Step 6. Change vesEndpointIpAddress for correct IP nad check if FID:4639 cleared
    ...  Step 7. Check pano.log for latest PM

Resource  ../../common_resources/ca_PM_general.robot
Resource  ../../common_resources/ca_ONAP_general.robot


*** Variables ***
${FID_4639_CLEAR_TIMEOUT}    900


*** Keywords ***
TC__PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - PM transfer from Wroclaw
    ...  - 18.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28773 - Update fid 4639 verification
    ...  - 03.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29028 - Use LMP ip address for ssh connection
    ...  - 25.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29407 - Change waiting time.
    ...  - 16.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30341 - Increase fid 4639 clear timeout

    Set Tags  CA-ONAP  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-marcin.berkowski@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  FEATURE-5GC001104

    Step 1. Check pano.Log For Latest PM
    Step 2. Changing ActivateSendingBulkPmEvents To OMeS
    Step 3. Check If 3GPP XML Files Was NOT Created
    Step 4. Changing ActivateSendingBulkPmEvents To 3GPP_OMeS
    Step 5. Change VesEndpointIpAddress For Dummy IP Nad Check If FID:4639 Occured
    Step 6. Change VesEndpointIpAddress For Correct IP Nad Check If FID:4639 Cleared
    Step 7. Check pano.Log For Latest PM


Step 1. Check Pano.Log For Latest PM
    Log  \nStep 1. Check pano.log for latest PM  console=true
    ${param_list}  Create List  reportingIntervalPm
    ${current_reporting_interval}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  ${param_list}
    ${current_reporting_interval}  Fetch From Left  ${current_reporting_interval}[0][parameters][reportingIntervalPm]  min
    ${reporting_interval}  Evaluate  ${current_reporting_interval} + 1
    Wait Until Keyword Succeeds  ${reporting_interval}min  1min
    ...  Check pano.Log For Latest PM


Step 2. Changing ActivateSendingBulkPmEvents To OMeS
    Log  \nStep 2. Changing activateSendingBulkPmEvents to OMeS  console=true
    Change Bulk Pm Reporting Format  OMeS


Step 3. Check If 3GPP XML Files Was NOT Created
    Log  \nStep 3. Check if 3GPP XML files was NOT created (after activateSendingBulkPmEvents=OMeS)  console=true
    ssh.Connect To  192.168.255.129  toor4nsn  oZPS0POrRieRtu
    ${pm_1}  ssh.Execute  command=${GET_CURRENT_PM_COMMAND}  connection=default  timeout=10s
    Sleep  6min
    ${pm_2}  ssh.Execute  command=${GET_CURRENT_PM_COMMAND}  connection=default  timeout=10s
    Should Be Equal  ${pm_1}  ${pm_2}
    ssh.Disconnect


Step 4. Changing ActivateSendingBulkPmEvents To 3GPP_OMeS
    Log  \nStep 4. Changing activateSendingBulkPmEvents to 3GPP_OMeS  console=true
    Change Bulk Pm Reporting Format  3GPP_OMeS
    Log  Waiting Until New PM Is Available on BTS  console=true
    Wait Until Keyword Succeeds  30min  1min
    ...  Check pano.Log For Latest PM


Step 5. Change VesEndpointIpAddress For Dummy IP Nad Check If FID:4639 Occured
    Log  \nStep 5. Change vesEndpointIpAddress for dummy IP nad check if FID:4639 occured  console=true
    Change VES Endpoint IP Address  10.0.0.0
    Log  Waiting for FID:4639  console=true
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4639}
    Assert Alarm Active  ${alarm_parameters}  timeout=360


Step 6. Change VesEndpointIpAddress For Correct IP Nad Check If FID:4639 Cleared
    Log  \nStep 6. Change vesEndpointIpAddress for correct IP nad check if FID:4639 cleared  console=true
    Change VES Endpoint IP Address  ${VM_WITH_PANO_IP}
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4639}
    Assert Alarm Inactive  ${alarm_parameters}  timeout=${FID_4639_CLEAR_TIMEOUT}


Step 7. Check Pano.Log For Latest PM
    Log  \nStep 7. Check pano.log for latest PM  console=true
    ${param_list}  Create List  reportingIntervalPm
    ${current_reporting_interval}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  ${param_list}
    ${current_reporting_interval}  Fetch From Left  ${current_reporting_interval}[0][parameters][reportingIntervalPm]  min
    ${reporting_interval}  Evaluate  ${current_reporting_interval} + 1
    Wait Until Keyword Succeeds  ${reporting_interval}min  1min
    ...  Check pano.Log For Latest PM


Change Bulk Pm Reporting Format
    [Arguments]  ${format}

    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  parameter=activeBulkPmReportingFormat  value=${format}
    ...  operation=update  skip_parameter_relation_errors=false  timeout=180
    Log  Parameter activeBulkPmReportingFormat=${format} [done]  console=true


Change VES Endpoint IP Address
    [Arguments]  ${ip_add}

    Log  KW:Change VES endpoint IP address; Argument ip_add: ${ip_add}  console=true
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1/VESENDPOINT-1  parameter=vesEndpointIpAddress
    ...  value=${ip_add}  operation=update  skip_parameter_relation_errors=false  timeout=180
    Log  Parameter vesEndpointIpAddress=${ip_add} [done]  console=true


Set Fault 4639 Parameters
    IF  '${ENB_BRANCH}'>='SBTS25R2'
        Set Test Variable  ${FAULT_4639}  ${FAULT_4639_SMO_ONAP_VES}
    ELSE
        Set Test Variable  ${FAULT_4639}  ${FAULT_4639_ONAP_VES}
    END


TC Setup
    Common Test Setup  tc_name=PANO__Break_connection_to_ONAP
    Set Fault 4639 Parameters
    ONAP 5GC001104 Test Setup


TC Teardown
    ONAP 5GC001104 Test Teardown
    Common Test Teardown
