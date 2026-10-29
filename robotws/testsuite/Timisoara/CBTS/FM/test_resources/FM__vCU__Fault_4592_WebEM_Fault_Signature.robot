*** Settings ***
Documentation
    ...  This TC is created to verify that the fault signature fields are populated in the alarm raised
    ...  for fault ID 4592 on vCU.
    ...  Connect SSH to the OAM VLAN IP.
    ...  Query how many pods does the container have and depending on the number of pods, 1N or 2N,
    ...  trigger vCU restart by deleting a pod, once or twice consecutively.
    ...  Check that after the vCU restart fault 4592 is raised and reported in WebEM.
    ...  Check fault signature fields are properly updated according to the OM_GEN_SFS_FM.3055.

Resource  ../../common_resources/vcu_frame.robot
Resource  ../../common_resources/M2M_Interface.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__FM__vCU__Fault_4592_WebEM_Fault_Signature
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25244
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25244 - Initial TAT creation
    ...  - 27.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28779 - Check affected cells

    Set Tags  CA-FM  OWNER-mircea.vladulescu@nokia.com  AUTHOR-victor.banicioiu@nokia.com  MAINTAINER-victor.banicioiu@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CB007823

    Step 1: Connect To OAM VLAN And Query Pods
    Step 2: Trigger VCU Restart
    Step 3: Check Alarm Is Raised In WebEM
    Step 4: Check VCU Is Recovered
    Step 5: Check Fault 4592 And Fault Signature Fields Using M2M Interface


Step 1: Connect To OAM VLAN And Query Pods
    Log  \nStep 1: Connect to OAM VLAN and query pods  console=true
    ${AFFECTED_CELLS}  Create List
    Set Test Variable  ${AFFECTED_CELLS}
    ${cells_on_vcu}  vcu.Get Cells Statuses
    Should Not Be Empty  ${cells_on_vcu}
    FOR  ${cell}  IN  @{cells_on_vcu}
        ${status_cell}  Run Keyword And Return Status  Should Contain  ${ENABLED}  ${cell}[operational_state]
        IF  ${status_cell}  Append To List  ${AFFECTED_CELLS}  ${cell}[dist_names][config]
    END
    Open SSH Connection To VCU And Connect To Openshift
    Check The Type Of Pods The Container Has


Step 2: Trigger VCU Restart
    Log  \nStep 2: Trigger vCU restart  console=true
    Run Keyword If  ${HAS_REDUNDANCY_PODS}
    ...  Run Keywords
    ...  SSHLibrary.Write  kubectl delete pod ${PODS_TO_DELETE}[0] -n ${VCU_CRAN}
    ...  AND
    ...  SSHLibrary.Write  kubectl delete pod ${PODS_TO_DELETE}[1] -n ${VCU_CRAN}
    ...  ELSE
    ...  SSHLibrary.Write  kubectl delete pod ${PODS_TO_DELETE}[0] -n ${VCU_CRAN}
    ${timestamp}  Get Current Date  exclude_millis=true
    Set Test Variable  ${FAULT_TIMESTAMP}  ${timestamp}


Step 3: Check Alarm Is Raised In WebEM
    Log  \nStep 3: Check alarm is raised in WebEM  console=true
    Sleep  150s  Wait for API to reload
    Wait Until Keyword Succeeds  180s  10s
    ...  Check All Cells From VCU  operational_state=${DISABLED}
    Log  vCU reset is started.  console=true
    Sleep  60s  Wait for alarm to be raised
    ${alarms_history}  vcu.Get Historical Alarms  sorted_by=appearTime  sort_order=desc  filter_by_text=7115
    Check If Alarm Was Raised After Timestamp  ${FAULT_TIMESTAMP}  ${alarms_history}  alarm_id=7115  alarm_name=BASE STATION INFORMATION
    ...  fault_id=4592  fault_name=BTS Reset Cause


Step 4: Check VCU Is Recovered
    Log  \nStep 4: Check vCU is recovered  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check Affected Cells To Be Enabled
    Log  vCU is recovered after reset. [OK]  console=true


Step 5: Check Fault 4592 And Fault Signature Fields Using M2M Interface
    Log  \nStep 5: Check fault 4592 and fault signature fields using M2M interface  console=true
    ${url}  Catenate  SEPARATOR=  "https://${VCU_OAM_IP}/api/licensed/v2/alarms/historical?
    ...  pageNumber=1&itemsPerPage=5&sortedBy=appearTime&sortOrder=desc&filterByText=4592"
    ${hist_alarms_output}  Run M2M Command  GET  ${url}  Bearer  ${TOKEN}
    ${alarms_list}  Change M2M Output To List Of Alarm Dicts  ${hist_alarms_output}
    Should Be Equal As Strings  ${alarms_list}[0][appearTime]  ${APPEAR_TIMESTAMP}
    ...  Error: "The selected fault 4592 entry is not the same as the one selected for alarm 7115" [NOK].
    Check Fault Signature Fields For OM_GEN_SFS_FM_3055  ${alarms_list}[0][faultSignature]  ${VCU_ACTIVE_SW_VERSION}


Check The Type Of Pods The Container Has
    SSHLibrary.Write  oc get pod -n ${VCU_CRAN}
    ${pods_output}  SSHLibrary.Read Until Prompt
    ${pod_matches}  Get Regexp Matches  ${pods_output}  [a-z-0-9]+-cpcl-[0-9]
    ${pods_to_delete}  Get Regexp Matches  ${pods_output}  [a-z-0-9]+-oamext-[0-9]
    ${length}  Get Length  ${pod_matches}
    ${has_redundancy_pods}  Run Keyword And Return Status
    ...  Should Be Equal  ${length}  2
    Set Test Variable  ${HAS_REDUNDANCY_PODS}  ${has_redundancy_pods}
    Set Test Variable  ${PODS_TO_DELETE}  ${pods_to_delete}


Check Affected Cells To Be Enabled
    ${cells_on_vcu}  vcu.Get Cells Statuses
    FOR  ${cell}  IN  @{cells_on_vcu}
        ${status}  Run Keyword And Return Status  List Should Contain Value  ${AFFECTED_CELLS}  ${cell}[dist_names][config]
        IF  ${status}
            Should Contain  ${UNLOCKED}  ${cell}[administrative_state]
            Should Contain  ${ENABLED}  ${cell}[operational_state]
        END
    END


TC Setup
    Common VCU Setup
    Modify Resource Search Order  FM__vCU__Fault_4592_WebEM_Fault_Signature
    Login Using M2M Interface  ${VCU_OAM_IP}


TC Teardown
    Close All Connections
    Logout Using M2M Interface  ${VCU_OAM_IP}
    Common VCU Teardown
