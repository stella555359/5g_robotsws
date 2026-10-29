*** Settings ***
Documentation
    ...  This TC is created to download RFSW from netact.
    ...  Connect to netact on CMWAS VM IP.
    ...  Verify if the RFSW is imported already and if it's not, import the RFSW.
    ...  Reset vDU.
    ...  Download the RFSW.
    ...  Disconnect from netact VM.

Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${NETACT_VM_IP_CMWAS}  10.43.48.160  # IP from VM with CMWAS.
${PATH_TO_RFSW}  /media/BuildShareTimi01/vRAN/TA_RFSW/Trunk  # Path to RF software.
${DOWNLOAD_RFSW_TIMEOUT}  600  # Timeout for RF software to be downloaded.
${RESTORE_TIMEOUT}  900  # Timeout for vDU to be on air.


*** Keywords ***
TC__WebEM__vDU__Cloud_vDU_Check_Downloaded_SW_for_RMOD_on_passive_partition_in_offline_phase
    [Documentation]
    ...  [CASE LINK]:
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 19.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25555  - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  SW-SBTS24  FEATURE-CB009434

    Step1:Connect To Netact
    Step2:Download SW For RMOD On Passive Partition
    Step3:Disconnect From Netact


Step1:Connect To Netact
    Log  \nStep1:Connect to Netact  console=true
    netact.Add Node  cmwas  ${NETACT_VM_IP_CMWAS}  ${NETACT_USERNAME}  ${NETACT_PASSWORD}


Step2:Download SW For RMOD On Passive Partition
    Log  \nStep2:Download SW for RMOD on passive partition  console=true
    ${softwares}  OperatingSystem.List Directory  ${PATH_TO_RFSW}
    ${rf_software_with_zip}  Get From List  ${softwares}  0
    ${rf_software}  Fetch From Left  ${rf_software_with_zip}  .zip
    Log  RFSW is ${rf_software}  console=true
    Log  Import build ${rf_software}  console=true
    ${imported_status}  netact.Is Imported  ${rf_software}  MRBTS
    Run Keyword If  ${imported_status}
    ...  Log  Build ${rf_software} is already imported![OK]  console=true
    ...  ELSE
    ...  Run Keywords
    ...  netact.Import Build  ${PATH_TO_RFSW}/${rf_software_with_zip}  MRBTS  ${rf_software}
    ...  AND
    ...  Log  Build ${rf_software} was imported successfully![OK]  console=true
    Perform Reset On VDU
    Log  Download ${rf_software} on PLMN-PLMN/MRBTS-${VDU_MRBTS_ID}!  console=true
    ${download_status}  netact.Download SW  PLMN-PLMN/MRBTS-${VDU_MRBTS_ID}  ${rf_software}  ${DOWNLOAD_RFSW_TIMEOUT}
    Run Keyword If  '${download_status}' == 'SUCCESS'
    ...  Log  RFSW was downloaded completed and successfully![OK]  console=true
    ...  ELSE
    ...  Fail  RFSW was not downloaded completed and successfully![NOK]
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Check All Cells From VDU  operational_state=${ENABLED}  availability_status=${ONLINE}  administrative_state=${UNLOCKED}
    Log  All services are operational after RFSW download in offline phase.[OK]  console=true


Step3:Disconnect From Netact
    Log  \nStep3:Disconnect from Netact  console=true
    netact.Delete Node  cmwas


Perform Reset On VDU
    Reset Vdu
    ${ip_adresses}  Create List  ${VDU_OAM_IP}
    ${ping_lost_status}  Run Keyword And Return Status
    ...  ping.Wait For No Ping  ip_addresses=${ip_adresses}  timeout=60s
    Run Keyword If  ${ping_lost_status}==${FALSE}
    ...  Fail  Ping not lost during vDU reset. [NOK]
    Log  vDU is resetting...  console=true


TC Setup
    Common VDU Setup
    Modify Resource Search Order  WebEM__vDU__Cloud_vDU_Check_Downloaded_SW_for_RMOD_on_passive_partition_in_offline_phase


TC Teardown
    Run Keyword If Test Failed
    ...  netact.Delete Node  cmwas
    Common VDU Teardown
