*** Settings ***
Documentation
    ...  This TC is created to verify if RFSW upgrade is finished ok.
    ...  First, netact node is added.
    ...  RFSW is imported and download is started. Meanwhile, reset operation is performed on chosen RMOD.
    ...  After software download and RMOD reset, others RMODs are checked, that SW installation was performed successfully on them.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${FHGW_SSH_IP}  ${EMPTY}  # Mandatory. SSH ip for FHGW.
${FHGW_SSH_USERNAME}  ${EMPTY}  # Mandatory. SSH username for FRGW.
${FHGW_SSH_PASSWORD}  ${EMPTY}  # Mandatory. SSH password for FRGW.
${RMOD_SERIAL_NUMBER}  ${EMPTY}  # Mandatory. Serial number for radio module.
${NETACT_VM_IP_CMWAS}  ${EMPTY}  # IP from VM with CMWAS.
${PATH_TO_RFSW}  /media/BuildShareTimi01/vRAN/TA_RFSW/Trunk  # Path to RF software.
${DOWNLOAD_RFSW_TIMEOUT}  900  # Timeout for RFSW to be downloaded
${RECOVERY_TIMEOUT_AFTER_RU_RESET}  900  # Recovery timeout after RUs reset


*** Keywords ***
TC__WebEM__vDU__Robustness_Reset_one_RU_and_check_second_RU_upgrade_is_finished_ok
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25560
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  16.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25560 - Initial TAT creation
    ...  ******************
    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  FEATURE-CB009434

    Step0:TC Preconditions
    Step1:Connect To Netact
    Step2:Start RFSW Download On Pasive Partition On All RMODs
    Step3:Reset Chosen RU And Wait For Download Operation To Finish
    Step4:Verify Download Operation Failed On Chosen RMOD But Succeeded On Other RMODs
    Step5:Disconnect From Netact


Step0:TC Preconditions
    Log  \nStep0:TC preconditions.  console=true
    ${rmods_ids_list}  Create List
    ${rmods_info}  Get Rmods Status
    FOR  ${rmod}  IN  @{rmods_info}
        Append To List  ${rmods_ids_list}  ${rmod}[id]
        ${serial_number_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${rmod}[serial_number]  ${RMOD_SERIAL_NUMBER}
        Run Keyword If  ${serial_number_status}
        ...  Set Test Variable  ${RMOD_ID}  ${rmod}[id]
    END
    Remove Values From List  ${rmods_ids_list}  ${RMOD_ID}
    Set Test Variable  ${RMODS_IDS_LIST}
    Log  TC prerequisites are:  console=true
    Log  RMODs ids on which the RFSW will be installed with netact: ${RMODS_IDS_LIST}.  console=true
    Log  RMOD details on which reset operation will be performed during RFSW download:  console=true
    Log  Serial number: ${RMOD_SERIAL_NUMBER}.  console=true
    Log  Id: ${RMOD_ID}.  console=true


Step1:Connect To Netact
    Log  \nStep1:Connect to Netact  console=true
    netact.Add Node  cmwas  ${NETACT_VM_IP_CMWAS}  ${NETACT_USERNAME}  ${NETACT_PASSWORD}
    Log  Netact connection done successfully!  console=true


Step2:Start RFSW Download On Pasive Partition On All RMODs
    Log  \nStep2:Start RFSW download on pasive partition on all RMODs.  console=true
    ${rf_software}  ${rf_sw_code}  Get CPRI RFSW Package Name And Code From RFSW Zip File  ${PATH_TO_RFSW}
    Set Test Variable  ${RF_SW_CODE}
    Log  Import build ${rf_software}!  console=true
    ${imported_status}  netact.Is Imported  ${rf_software}  MRBTS
    Run Keyword If  ${imported_status}
    ...  Log  Build ${rf_software} is already imported![OK]  console=true
    ...  ELSE
    ...  Run Keywords
    ...  netact.Import Build  ${PATH_TO_RFSW}/${RF_SOFTWARE_WITH_ZIP}  MRBTS  ${rf_software}
    ...  AND
    ...  Log  Build ${rf_software} was imported successfully![OK]  console=true
    Log  Download ${rf_software} on PLMN-PLMN/MRBTS-${VDU_MRBTS_ID}!  console=true
    ${operation_id}  netact.Start Swm Operation  download  PLMN-PLMN/MRBTS-${VDU_MRBTS_ID}  ${rf_software}
    Set Test Variable  ${OPERATION_ID}
    Log  RFSW is being downloaded.  console=true


Step3:Reset Chosen RU And Wait For Download Operation To Finish
    Log  \nStep3:Reset chosen RU and wait for download operation to finish.  console=true
    ${id_list}  Create List  ${RMOD_ID}
    vdu.Reset Rmods  ${id_list}
    Wait Until Keyword Succeeds  300s  10s
    ...  Verify RMOD Parameter By RMOD Id  ${RMOD_ID}  operational_state  ${DISABLED}
    Log  RMOD with id: ${RMOD_ID} is Disabled. [OK]  console=true
    FOR  ${id}  IN  @{RMODS_IDS_LIST}
        Verify RMOD Parameter By RMOD Id  ${id}  operational_state  ${ENABLED}
    END
    Log  All other RMODs mapped on vDU are Enabled. [OK]  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT_AFTER_RU_RESET}  10s
    ...  Verify RMOD Parameter By RMOD Id  ${RMOD_ID}  operational_state  ${ENABLED}
    Log  RMOD is back Online!  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT_AFTER_RU_RESET}  10s
    ...  Check All Cells From VDU  availability_status=${ONLINE}  operational_state=${ENABLED}
    Log  Cells are Online and Enabled![OK]  console=true
    netact.Wait For Swm Operation  ${OPERATION_ID}  ${DOWNLOAD_RFSW_TIMEOUT}
    Log  Download operation is succesfully done.[OK]  console=true


Step4:Verify Download Operation Failed On Chosen RMOD But Succeeded On Other RMODs
    Log  \nStep4:Verify download operation failed on chosen RMOD but succeeded on other RMODs.  console=true
    ${rmods_info_list}  Connect To CPRI RMODs Through FHGW And Return RMODs Info List  ${FHGW_SSH_IP}  ${FHGW_SSH_USERNAME}  ${FHGW_SSH_PASSWORD}
    FOR  ${rmod_dictionary}  IN  @{rmods_info_list}
        ${serial_number_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${rmod_dictionary}[serial_number]  ${RMOD_SERIAL_NUMBER}
        Run Keyword If  ${serial_number_status}
        ...  Verify RFSW Not To Be Present On Passive Partition  ${rmod_dictionary}  ${RF_SW_CODE}
        ...  ELSE
        ...  Verify RFSW To Be Present On Passive Partition  ${rmod_dictionary}  ${RF_SW_CODE}
    END


Step5:Disconnect From Netact
    Log  \nStep5:Disconnect from Netact.  console=true
    netact.Delete Node  cmwas


Verify RFSW Not To Be Present On Passive Partition
    [Arguments]  ${rmod_info}  ${rf_sw_code}

    ${first_code_status}  Run Keyword And Return Status
    ...  Dictionary Should Contain Key  ${rmod_info}  passive_sw_code
    Run Keyword If  ${first_code_status}
    ...  Should Not Contain  ${rmod_info}[passive_sw_code]  ${rf_sw_code}  RFSW was still downloaded on first passive partition. [NOK]
    ${second_code_status}  Run Keyword And Return Status
    ...  Dictionary Should Contain Key  ${rmod_info}  second_passive_sw_code
    Run Keyword If  ${second_code_status}
    ...  Should Not Contain  ${rmod_info}[second_passive_sw_code]  ${rf_sw_code}  RFSW was still downloaded on second passive partition. [NOK]


Verify RFSW To Be Present On Passive Partition
    [Arguments]  ${rmod_info}  ${rf_sw_code}

    ${first_code_status}  Run Keyword And Return Status
    ...  Dictionary Should Contain Key  ${rmod_info}  passive_sw_code
    ${first_code_status}  Run Keyword If  ${first_code_status}
    ...  Run Keyword And Return Status
    ...  Should Contain  ${rmod_info}[passive_sw_code]  ${rf_sw_code}
    ${second_code_status}  Run Keyword And Return Status
    ...  Dictionary Should Contain Key  ${rmod_info}  second_passive_sw_code
    ${second_code_status}  Run Keyword If  ${second_code_status}
    ...  Run Keyword And Return Status
    ...  Should Contain  ${rmod_info}[second_passive_sw_code]  ${rf_sw_code}
    Run Keyword If  ${first_code_status} or ${second_code_status}
    ...  Log  RFSW was downloaded on passive partition for RMOD with serial number: ${rmod_info}[serial_number]. [OK]  console=true
    ...  ELSE
    ...  Fail  RFSW download didn't succeed on RMOD with serial number: ${rmod_info}[serial_number]. [NOK]


TC Setup
    Common VDU Setup
    Modify Resource Search Order  WebEM__vDU__Robustness_Reset_one_RU_and_check_second_RU_upgrade_is_finished_ok


TC Teardown
    Common VDU Teardown
