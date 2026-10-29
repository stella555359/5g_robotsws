*** Settings ***
Documentation
    ...  This TC verif if RFSW information is still stored on the vDU after reset vDU and reset rmod.
    ...  Connect to netact.
    ...  Import the RFSW and download.
    ...  Connect ssh on RU and check if SW version is ok.
    ...  Perform vDU reset and wait until all cells are onAir.
    ...  Connect ssh on RU and check if SW version is still the same.
    ...  Perform RU reset and wait until RUs and cells are onAir.
    ...  Connect ssh on RU and check if SW version is still the same.
    ...  Disconnect from netact.

Library  ../../common_resources/python_resources/extract.py
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${NETACT_VM_IP_CMWAS}  10.43.48.160  # IP from VM with CMWAS
${PATH_TO_RFSW}  /media/BuildShareTimi01/vRAN/TA_RFSW/Trunk/  # Path to RF software
${DOWNLOAD_RFSW_TIMEOUT}  1800  # Timeout for RFSW to be downloaded
${RECOVERY_TIMEOUT_AFTER_VDU_RESET}  1200  # Recovery timeout after vDU reset
${RECOVERY_TIMEOUT_AFTER_RU_RESET}  900  # Recovery timeout after RUs reset
${RMOD_USER}  serviceuser  # username used to login to RMOD from pod
${RMOD_PASS}  bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=  # password used to login to RMOD from pod


*** Keywords ***
TC__WebEM__vDU__Cloud_vDU_Robustness_Reset_vDU_and_check_RU_information_is_still_stored_on_the_vDU
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25558
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 11.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25558 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24  FEATURE-CB009434

    Step1:Connect To Netact
    Step2:Download SW For RMOD On Passive Partition
    Step3:Reset VDU And Check If RFSW Is Still On Passive Partition From RU
    Step4:Reset RUs And Check If RFSW Is Still On Passive Partition From RU
    Step5:Disconnect From Netact


Step1:Connect To Netact
    Log  \nStep1:Connect to Netact  console=true
    ${rmods_ips_list}  Get All ECPRI RMODs Ips From RMODs Dedicated Pod  ${RMOD_USER}
    Set Test Variable  ${RMODS_IPS_LIST}
    netact.Add Node  cmwas  ${NETACT_VM_IP_CMWAS}  ${NETACT_USERNAME}  ${NETACT_PASSWORD}


Step2:Download SW For RMOD On Passive Partition
    Log  \nStep2:Download SW for RMOD on passive partition  console=true
    ${softwares}  OperatingSystem.List Directory  ${PATH_TO_RFSW}
    ${rf_software_with_zip}  Get From List  ${softwares}  -1
    ${rf_software}  Fetch From Left  ${rf_software_with_zip}  .zip
    Set Test Variable  ${RF_SOFTWARE}
    ${file_list}  Zip File List  ${PATH_TO_RFSW}${rf_software_with_zip}
    FOR  ${item}  IN  @{file_list}
        ${status}  Run Keyword And Return Status
        ...  Should Match Regexp  ${item}  SRM-rfsw-image-install-*
        ${rf_sw_name}  Run Keyword If  ${status}
        ...  Run Keywords
        ...  Get ECPRI RFSW Name  ${item}
        ...  AND
        Set Test Variable  ${RF_SW_NAME}
        Exit For Loop If  ${status}
    END
    Log  RFSW is ${RF_SOFTWARE}!  console=true
    Log  Import build ${RF_SOFTWARE}!  console=true
    ${imported_status}  netact.Is Imported  ${RF_SOFTWARE}  MRBTS
    Run Keyword If  ${imported_status}
    ...  Log  Build ${RF_SOFTWARE} is already imported![OK]  console=true
    ...  ELSE
    ...  Run Keywords
    ...  netact.Import Build  ${PATH_TO_RFSW}${rf_software_with_zip}  MRBTS  ${RF_SOFTWARE}
    ...  AND
    ...  Log  Build ${RF_SOFTWARE} was imported successfully![OK]  console=true
    Log  Download ${RF_SOFTWARE} on PLMN-PLMN/MRBTS-${VDU_MRBTS_ID}!  console=true
    ${download_status}  netact.Download SW  PLMN-PLMN/MRBTS-${VDU_MRBTS_ID}  ${RF_SOFTWARE}  ${DOWNLOAD_RFSW_TIMEOUT}
    Run Keyword If  '${download_status}' == 'SUCCESS'
    ...  Log  RFSW was downloaded completed and successfully![OK]  console=true
    ...  ELSE
    ...  Fail  RFSW was not downloaded completed and successfully![NOK]
    FOR  ${rmod_ip}  IN  @{RMODS_IPS_LIST}
        Verify RFSW From ECPRI RMOD To Be On Passive Partition  ${rmod_ip}  ${RMOD_USER}  ${RMOD_PASSWORD}  ${RF_SW_NAME}
    END


Step3:Reset VDU And Check If RFSW Is Still On Passive Partition From RU
    Log  \nStep3:Reset vDU and check if RFSW is still on passive partition from RU  console=true
    vdu.Reset Vdu  timeout=120
    Log  Reset vDU is perform![OK]  console=true
    Wait Until Keyword Succeeds  400s  10s
    ...  Check All Cells From VDU  availability_status=${OFFLINE}  operational_state=${DISABLED}
    Log  Cells are Offline and Disabled![OK]  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT_AFTER_VDU_RESET}  10s
    ...  Check All Cells From VDU  availability_status=${ONLINE}  operational_state=${ENABLED}
    Log  Cells are Online and Enabled![OK]  console=true
    Log  Reset vDU was done successfully![OK]  console=true
    Log  Verify if RFSW is still on passive partition from RU after vDU reset!  console=true
    FOR  ${rmod_ip}  IN  @{RMODS_IPS_LIST}
        Verify RFSW From ECPRI RMOD To Be On Passive Partition  ${rmod_ip}  ${RMOD_USER}  ${RMOD_PASSWORD}  ${RF_SW_NAME}
    END


Step4:Reset RUs And Check If RFSW Is Still On Passive Partition From RU
    Log  \nStep4:Reset RUs and check if RFSW is still on passive partition from RU  console=true
    ${rmods_statuses}  vdu.Get Rmods Status
    ${rmods_id_list}  Create List
    FOR  ${rmod_statuses}  IN  @{rmods_statuses}
        Append To List  ${rmods_id_list}  ${rmod_statuses}[id]
    END
    ${reset_status}  vdu.Reset Rmods  ${rmods_id_list}
    Wait Until Keyword Succeeds  300s  10s
    ...  Verify RMODs Parameter From VDU  operational_state  ${DISABLED}
    Log  RUs are Disabled![OK]  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT_AFTER_RU_RESET}  10
    ...  Verify RMODs Parameter From VDU  availability_status  ${ONLINE}
    Log  RUs are Online![OK]  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT_AFTER_RU_RESET}  10s
    ...  Check All Cells From VDU  availability_status=${ONLINE}  operational_state=${ENABLED}
    Log  Cells are Online and Enabled![OK]  console=true
    Log  Reset RUs was done successfully![OK]  console=true
    Log  Verify if RFSW is still on passive partition from RU after RU reset!  console=true
    FOR  ${rmod_ip}  IN  @{RMODS_IPS_LIST}
        Verify RFSW From ECPRI RMOD To Be On Passive Partition  ${rmod_ip}  ${RMOD_USER}  ${RMOD_PASSWORD}  ${RF_SW_NAME}
    END


Step5:Disconnect From Netact
    Log  \nStep5:Disconnect from Netact  console=true
    netact.Delete Node  cmwas


TC Setup
    Common VDU Setup
    Modify Resource Search Order  WebEM__vDU__Cloud_vDU_Robustness_Reset_vDU_and_check_RU_information_is_still_stored_on_the_vDU


TC Teardown
    Run Keyword If Test Failed
    ...  netact.Delete Node  cmwas
    Common VDU Teardown
