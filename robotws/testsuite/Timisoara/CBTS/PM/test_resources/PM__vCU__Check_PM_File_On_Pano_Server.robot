*** Settings ***
Documentation
...  First, activateSendingBulkPmEvents and reportingIntervalPm are set to true and 5min respectively.
...  Then TC is getting the last PM file from vCU.
...  The last PM file sent to pano server must have the same file size as the one mentioned above.
...  In the end, TC is checking if PM file is validated (xml.gz file tail must be 'validate.ok').

Resource  ../../common_resources/vcu_frame.robot
Resource  ../resources/PM_general.robot


*** Variables ***
${PM_FILE_PANO_TIMEOUT}  180s  # Timeout for PM report is loaded


*** Keywords ***
TC__PM__vCU__Check_PM_File_On_Pano_Server
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29360
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  10.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29360 - TC creation
    ...  04.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30281 - Increased wait time to 180s for checking PM file availability in PANO

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  FEATURE-CB006088

    Step1: Set Last PM File From Vcu
    Step2: Compare File Size From Vcu And Pano And Check If File Is Validated


Step1: Set Last PM File From Vcu
    Log  \nStep1: Set Last PM File From Vcu  console=true
    ${send_pm_events_value}  VCU Get Parameter Value  activateSendingBulkPmEvents  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    IF  '${send_pm_events_value}'!='true'
    ...  Change specific parameter for vCU  activateSendingBulkPmEvents  true  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${rep_interval_value}  VCU Get Parameter Value  reportingIntervalPm  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    IF  '${rep_interval_value}'!='5min'
      Change specific parameter for vCU  reportingIntervalPm  5min  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
      Sleep Until New Cycle  5min
    END
    Sleep Until New Cycle  5min
    Sleep  ${PM_FILE_PANO_TIMEOUT}  TC will wait until PM report is loaded.

    ${last_pm_file_line_from_vcu}  Get Last 3GPP PM File Line From Vcu
    Set Test Variable  ${LAST_PM_FILE_LINE_FROM_VCU}


Step2: Compare File Size From Vcu And Pano And Check If File Is Validated
    Log  \nStep2: Compare File Size From Vcu And Pano And Check If File Is Validated  console=true
    SSHLibrary.Open Connection  ${VM_WITH_PANO_IP}
    SSHLibrary.Login  ${VM_WITH_PANO_USR}  ${VM_WITH_PANO_PASSWD}
    Sleep  2s
    ${vcu_pm_file_name}  Set Variable  ${LAST_PM_FILE_LINE_FROM_VCU}[-1]
    ${pano_pm_file_lines}  SSHLibrary.Execute Command  ls -l /home/ute/.local/pano/pm_files | grep ${vcu_pm_file_name}
    Should Not Be Empty  ${pano_pm_file_lines}  Last PM file from vCU is not visible on Pano server.
    ${pano_pm_file_lines}  Split To Lines  ${pano_pm_file_lines}

    ${pano_pm_file_size}  Get Regexp Matches  ${pano_pm_file_lines}[0]  ${SPACE}\\d+${SPACE}+[A-Z]
    ${pano_pm_file_size}  Remove String Using Regexp  ${pano_pm_file_size}[0]  ${SPACE}  [A-Z]
    List Should Contain Value  ${LAST_PM_FILE_LINE_FROM_VCU}  ${pano_pm_file_size}
    ...  Last PM file has different size on vCU and Pano server.

    Should Contain  ${pano_pm_file_lines}[1]  validate.ok  Last PM file is not validated.

    [Teardown]  SSHLibrary.Close Connection


TC Setup
    Common VCU Setup
    Turn ON Pano And Check If Is Connected
    Modify Resource Search Order  PM__vCU__Check_PM_File_On_Pano_Server


TC Teardown
    Turn OFF Pano And Check If Is Disconnected
    Common VCU Teardown