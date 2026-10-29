*** Settings ***
Documentation
...  This test case is monitoring PPM 3GPP files creation. SBTS must have LTE deployed.
...  Parameters setting:
...      - reportingIntervalPm=15min
...      - mtCellAvailability=15min
...      - actPartialPmReportFile=true
...      - activeBulkPmReportingFormat=3GPP_OMeS
...  First check: PPM 3GPP file must be created every 1 minute after the previous file is deleted in
...  /ffs/run/logs/oam/pmstat/ppm_3GPP location. PPM file creation and LTE Cell Avail counter value are checked for 7 minutes.
...  Second and third checks: PPM file right before Site Reset and PDU Power Reset is saved and it must be transferred
...  to PANO server after reset operations.

Resource  ../../common_resources/ca_PM_general.robot
Resource  ../../common_resources/ca_ONAP_general.robot


*** Variables ***
${VM_WITH_PANO_IP}  10.5.47.47  #IP address for PANO server
${VM_WITH_PANO_USR}  ute  #Username for logging into PANO server virtual machine
${VM_WITH_PANO_PASSWD}  UTE.debian12  #Password for logging into PANO server virtual machine
${RESTORE_TIMEOUT}  1200  #Time for SBTS to reach on air state after reset.


*** Keywords ***
TC__PM__PPM_File_Transfer_To_ONAP
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30001
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30001 - Initial TAT creation
    ...  - 20.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30227 - Fix checking LTE Cell Avail meas
    ...  - 19.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30356 - Add faults for watchdog
    ...  - 19.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30351 - Add RSA certificate to clear 61510 fault
    ...  - 19.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30351 - Refactor pano connection and drop unique PPM file check

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  FEATURE-CB013879

    Step0: TC Preconditions
    Step1: Check PPM File Is Generated Every 1 Minute And Check LTE Cell Avail Value
    Step2: Perform Site Reset And Check PPM File On Pano
    Step3: Perform BTS Power Reset And Check PPM File On Pano


Step0: TC Preconditions
    Set Parameter To New Value  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  reportingIntervalPm  15min
    ${lnbts_id}  Admin Get LNBTS ID
    Set Parameter To New Value  MRBTS-${BTS_ID}/LNBTS-${lnbts_id}/PMRNL-1  mtCellAvailability  15min
    IF  ${SCF_COUNT_NR}
        ${nrbts_id}  Admin Get NRBTS ID
        Set Parameter To New Value  MRBTS-${BTS_ID}/NRBTS-${nrbts_id}/NRPMRNL-1  miNrCellAvailability  15min
    END
    Set Parameter To New Value  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  actPartialPmReportFile  true
    Set Parameter To New Value  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  activeBulkPmReportingFormat  3GPP_OMeS
    Set Test Variable  ${PATH_TO_PPM_3GPP_FILES}  /ffs/run/logs/oam/pmstat/ppm_3GPP

    ${fault_61510_params}  Get String With Alarm Parameters  ${FAULT_61510}
    ${fid_61510_is_active}  Run Keyword And Return Status  Assert Alarm Active  parameters=${fault_61510_params}
    IF  ${fid_61510_is_active}
        Set Certificate Automatic Management  37416  ccRT-XnWF-W4pG-MuGp
        Assert Alarm Inactive  parameters=${fault_61510_params}  timeout=600
    END


Step1: Check PPM File Is Generated Every 1 Minute And Check LTE Cell Avail Value
    Log  \nStep1: Check PPM File Is Generated Every 1 Minute And Check LTE Cell Avail Value   console=true
    Sleep Until New Cycle  minutes_for_cycle=15min
    Open Connection To Primary Core
    ${last_ppm_file_previous_interval}  Wait Until Keyword Succeeds  10s  1s  Get PPM File Not Empty  ${PATH_TO_PPM_3GPP_FILES}  *MRBTS-${BTS_ID}*
    ${first_ppm_file}  Wait Until Keyword Succeeds  40s  8s  Wait For New PPM File To Be Generated  ${PATH_TO_PPM_3GPP_FILES}
    ...  ${last_ppm_file_previous_interval}  1 minute  *MRBTS-${BTS_ID}*
    Wait For New 1 Minute Interval
    ${current_ppm_file}  Wait Until Keyword Succeeds  100s  8s  Wait For New PPM File To Be Generated  ${PATH_TO_PPM_3GPP_FILES}  ${first_ppm_file}
    ...  1 minute  *MRBTS-${BTS_ID}*
    SSHLibrary.Get File  ${PATH_TO_PPM_3GPP_FILES}/${current_ppm_file}[0]  ${BTS_FILES}/${current_ppm_file}[0]
    Check LTE Cell Avail Value  ${BTS_FILES}/${current_ppm_file}[0]  60
    Log  PPM file is generated as expected after 1 minute and LTE Cell Avail is 60.  console=true
    ${counter_value}  Set Variable  120
    FOR  ${index}  IN RANGE  2  8
        Wait For New 1 Minute Interval
        ${new_ppm_file}  Wait Until Keyword Succeeds  40s  8s  Wait For New PPM File To Be Generated  ${PATH_TO_PPM_3GPP_FILES}  ${current_ppm_file}
        ...  ${index} minutes  *MRBTS-${BTS_ID}*
        ${new_file_is_not_generated}  Run Keyword And Return Status  Lists Should Be Equal  ${new_ppm_file}  ${current_ppm_file}
        IF  ${new_file_is_not_generated}  Fail  There is no new PPM file generated as expected after ${index} minutes from current interval.
        ${current_ppm_file}  Set Variable  ${new_ppm_file}
        SSHLibrary.Get File  ${PATH_TO_PPM_3GPP_FILES}/${new_ppm_file}[0]  ${BTS_FILES}/${new_ppm_file}[0]
        Check LTE Cell Avail Value  ${BTS_FILES}/${new_ppm_file}[0]  ${counter_value}
        Log  PPM file is generated as expected after ${index} minutes and LTE Cell Avail is ${counter_value}.  console=true
        ${counter_value}  Evaluate  ${counter_value}+60
    END

    [Teardown]  Run Keywords  SSHLibrary.Close Connection  AND  Run Keyword And Ignore Error  Run  rm ${BTS_FILES}/*.gz


Step2: Perform Site Reset And Check PPM File On Pano
    Log  \nStep2: Perform Site Reset And Check PPM File On Pano  console=true
    Open Connection To Primary Core
    ${first_ppm_file}  Wait Until Keyword Succeeds  10s  2s  Get PPM File Not Empty  ${PATH_TO_PPM_3GPP_FILES}  *MRBTS-${BTS_ID}*
    ${ppm_file}  Wait Until Keyword Succeeds  70s  10s  Wait For New PPM File To Be Generated  ${PATH_TO_PPM_3GPP_FILES}
    ...  ${first_ppm_file}  2 minutes  *MRBTS-${BTS_ID}*

    Log  Perform Site Reset...  console=true
    coam.Reset Site  timeout=600  wait_for_reconnection=False

    ${ping_is_lost}  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=${OAM_BTS_IP}  timeout=5
    ${no_of_iterations}  Set Variable  0
    WHILE  not ${ping_is_lost} and ${no_of_iterations} < 10
        ${status}  ${next_ppm_file}  Run Keyword And Ignore Error  Wait Until Keyword Succeeds  10s  1s
        ...  Wait For New PPM File To Be Generated  ${PATH_TO_PPM_3GPP_FILES}  ${ppm_file}  Site Reset  *MRBTS-${BTS_ID}*
        ${ppm_file}  Set Variable If  '${status}'=='PASS'  ${next_ppm_file}  ${ppm_file}
        ${ping_is_lost}  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=${OAM_BTS_IP}  timeout=1
        ${no_of_iterations}  Evaluate  ${no_of_iterations}+1
    END
    Log  Ping to primary core is lost after Site Reset.  console=true

    Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=300
    Log  Primary core is reachable after Site Reset.  console=true

    Open Connection To Primary Core
    ${ppm_file_after_site_reset}  Wait Until Keyword Succeeds  10s  2s  Get PPM File Not Empty  ${PATH_TO_PPM_3GPP_FILES}  *MRBTS-${BTS_ID}*
    Lists Should Be Equal  ${ppm_file}  ${ppm_file_after_site_reset}  There is new PPM file generated right after Site Reset.
    Log  ${ppm_file}[0] is still visible after Site Reset.  console=true

    Turn ON Pano And Check If Is Connected  ${VM_WITH_PANO_IP}  ${VM_WITH_PANO_USR}  ${VM_WITH_PANO_PASSWD}
    Wait Until Keyword Succeeds  600  30  Check PPM 3GPP File On Pano Server  ${ppm_file}[0]  Site Reset

    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  30s  Admin Check All Required State
    Log  SBTS is on Air after Site Reset.  console=true

    [Teardown]  Run Keywords  SSHLibrary.Close All Connections  AND  Turn OFF Pano And Check If Is Disconnected
    ...  ${VM_WITH_PANO_IP}  ${VM_WITH_PANO_USR}  ${VM_WITH_PANO_PASSWD}



Step3: Perform BTS Power Reset And Check PPM File On Pano
    Log  \nStep3: Perform BTS Power Reset And Check PPM File On Pano  console=true
    Open Connection To Primary Core
    ${first_ppm_file}  Wait Until Keyword Succeeds  10s  2s  Get PPM File Not Empty  ${PATH_TO_PPM_3GPP_FILES}  *MRBTS-${BTS_ID}*
    ${ppm_file}  Wait Until Keyword Succeeds  70s  15s  Wait For New PPM File To Be Generated  ${PATH_TO_PPM_3GPP_FILES}
    ...  ${first_ppm_file}  2 minutes  *MRBTS-${BTS_ID}*
    SSHLibrary.Close Connection

    Log  Perform PDU Power Reset...  console=true
    ${serial_number}  Get Primary Core Serial Number
    Pdu BTS Interface Off  SMOD_${serial_number}
    Wait For Target To Be Not Reachable  hostname=${OAM_BTS_IP}  timeout=300
    Log  Ping to primary core is lost.  console=true

    Pdu BTS Interface On  SMOD_${serial_number}
    Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=300
    Log  Primary core is reachable after PDU Power Reset.  console=true

    Wait Until Keyword Succeeds  120  20s  Open Connection To Primary Core
    ${ppm_file_after_power_reset}  Wait Until Keyword Succeeds  10s  2s  Get PPM File Not Empty  ${PATH_TO_PPM_3GPP_FILES}  *MRBTS-${BTS_ID}*
    Lists Should Be Equal  ${ppm_file}  ${ppm_file_after_power_reset}  There is new PPM file generated right after PDU Power Reset.
    Log  ${ppm_file}[0] is still visible after PDU Power Reset.  console=true

    Turn ON Pano And Check If Is Connected  ${VM_WITH_PANO_IP}  ${VM_WITH_PANO_USR}  ${VM_WITH_PANO_PASSWD}
    Wait Until Keyword Succeeds  600  30  Check PPM 3GPP File On Pano Server  ${ppm_file}[0]  PDU Power Reset

    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  30s  Admin Check All Required State
    Log  SBTS is on Air after PDU power off/on.  console=true

    [Teardown]  Run Keywords  SSHLibrary.Close All Connections  AND  Turn OFF Pano And Check If Is Disconnected
    ...  ${VM_WITH_PANO_IP}  ${VM_WITH_PANO_USR}  ${VM_WITH_PANO_PASSWD}


Check LTE Cell Avail Value
    [Arguments]  ${path_to_ppm_gz_file}  ${expected_counter_value}

    ${path_to_ppm_xml_file}  Remove String  ${path_to_ppm_gz_file}  .gz
    Run  gzip -d -c ${path_to_ppm_gz_file} > ${path_to_ppm_xml_file}
    Run  sed -i "s/></>\\n</g" ${path_to_ppm_xml_file}

    ${meas_data_file}  Parse XML  ${path_to_ppm_xml_file}
    ${required_meas_element}  Get Element  ${meas_data_file}  //measInfo[@measInfoId="LTE_Cell_Avail"]
    ${meas_type_element}  Get Element  ${required_meas_element}  child::measType[text()="VS.LTE_Cell_Avail.SAMPLES_CELL_AVAIL"]
    ${p_value}  Get Element Attribute  ${meas_type_element}  p
    ${lncel_meas_value_elements}  Get Elements  ${required_meas_element}  child::measValue
    FOR  ${lncel_element}  IN  @{lncel_meas_value_elements}
        ${counter_value}  Get Element Text  ${lncel_element}  child::r[@p="${p_value}"]
        ${counter_has_required_value}  Run Keyword And Return Status  Should Be Equal As Integers  ${counter_value}  ${expected_counter_value}
        IF  not ${counter_has_required_value}
            ${obj_details}  Get Element Attribute  ${lncel_element}  measObjLdn
            ${lncel_id}  Get Regexp Matches  ${obj_details}  LNCEL=\\d+
            Log  LTE Cell Avail for ${lncel_id}[0] has unexpected value '${counter_value}' in PPM report ${path_to_ppm_xml_file}.  level=ERROR
            Set Test Failed  LTE Cell Avail for ${lncel_id}[0] has unexpected value '${counter_value}' in PPM report ${path_to_ppm_xml_file}.
        END
    END


Check PPM 3GPP File On Pano Server
    [Arguments]  ${expected_ppm_file}  ${operation}

    SSHLibrary.Open Connection  ${VM_WITH_PANO_IP}
    SSHLibrary.Login  ${VM_WITH_PANO_USR}  ${VM_WITH_PANO_PASSWD}
    Sleep  2s
    ${ppm_files_location}  Set Variable  /home/ute/.local/pano/pm_files
    ${ppm_file}  SSHLibrary.List Directory  ${ppm_files_location}  pattern=${expected_ppm_file}
    Should Not Be Empty  ${ppm_file}  Expected ${expected_ppm_file} was not transferred on PANO server: ${VM_WITH_PANO_IP} after ${operation}.
    Log  ${expected_ppm_file} is transferred on PANO server: ${VM_WITH_PANO_IP}.  console=true


TC Setup
    Common Test Setup  tc_name=PM__PPM_File_Transfer_To_ONAP


TC Teardown
    Common Test Teardown
