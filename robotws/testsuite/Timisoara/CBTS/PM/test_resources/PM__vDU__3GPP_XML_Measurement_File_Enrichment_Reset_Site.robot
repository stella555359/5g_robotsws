*** Settings ***
Documentation
...  This TC is checking PM files to contain specific data.
...  First act3gppXmlEnrichment parameter is changed to true.
...  Bts name and nrcell name are changed to test names.
...  TC waits for new PM file to be generated on Pano server. This new file will be downloaded
...  and it must contain CUSTOM_BTS_NAME and CUSTOM_CELL_NAME.
...  vDU reset is performed. After it, a new PM file is downloaded and it must also contain the data
...  mentioned previously.
...  In the end, TC is restoring the original names for changed parameters.

Library  XML  use_lxml=true
Resource  ../../common_resources/vdu_frame.robot
Resource  ../resources/PM_general.robot


*** Variables ***
${VDU_RECOVERY_TIMEOUT}  900s  # Timeout for VDU to be onAir
${PM_FILE_PANO_TIMEOUT}  180s  # Timeout for PM report is loaded


*** Keywords ***
TC__PM__vDU__3GPP_XML_Measurement_File_Enrichment_Reset_Site
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28678
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  29.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28678 - TC creation
    ...  14.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28762 - Use TEST_RESULTS_DIR variable
    ...  21.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28794 - Change BTS custom name
    ...  24.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28795 - Add sw version xml check
    ...  13.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30162 - Increased wait time to 180s for checking PM file availability in PANO

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  FEATURE-CB006088

    Step0: TC Prerequisites
    Step1: Turn On Files Enrichment
    Step2: Change Vdu And Cell Name
    Step3: Save And Check Latest PM File From Pano
    Step4: Vdu Reset
    Step5: Save And Check Latest PM File From Pano


Step0: TC Prerequisites
    ${vdu_cells_status}  Get Vdu Cells Status
    ${cell_dictionary}  Evaluate  random.choice(${vdu_cells_status})  random
    ${cell_id}  Fetch From Right  ${cell_dictionary}[dist_names][config]  -
    Set Test Variable  ${CELL_ID}  ${cell_dictionary}[id]
    Set Test Variable  ${CUSTOM_BTS_NAME}  bts@test
    Set Test Variable  ${CUSTOM_CELL_NAME}  @test_cell!

    ${rep_interval_value}  VDU Get Parameter Value  reportingIntervalPm  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    IF  '${rep_interval_value}'!='5min'
        Change specific parameter for vDU  reportingIntervalPm  5min  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
        Sleep Until New Cycle  5min
    END


Step1: Turn On Files Enrichment
    Log  \nStep1: Turn On Files Enrichment  console=true
    ${3gpp_enrichment_value}  VDU Get Parameter Value  act3gppXmlEnrichment  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    IF  '${3gpp_enrichment_value}'!='true'
        Change specific parameter for vDU  act3gppXmlEnrichment  true  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    END


Step2: Change Vdu And Cell Name
    Log  \nStep2: Change Vdu And Cell Name  console=true
    Change specific parameter for vDU  btsName  ${CUSTOM_BTS_NAME}  MRBTS-${VDU_MRBTS_ID}
    Change specific parameter for vDU  cellName  ${CUSTOM_CELL_NAME}  MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${CELL_ID}


Step${index}: Save And Check Latest PM File From Pano
    Log  \nStep${index}: Save And Check Latest PM File From Pano  console=true
    Sleep Until New Cycle  5min
    Sleep  ${PM_FILE_PANO_TIMEOUT}  TC will wait until PM report is loaded.
    ${pm_gz_file}  Get Last PM File Name From Pano
    ${file_exists}  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${TEST_RESULTS_DIR}/${pm_gz_file}
    Should Not Be True  ${file_exists}  A new PM file was not created on Pano server.
    ${scp_parameters}  Set Variable  ${VM_WITH_PANO_USR}@${VM_WITH_PANO_IP}:/home/ute/.local/pano/pm_files/${pm_gz_file} ${TEST_RESULTS_DIR}
    Run  sshpass -p "${VM_WITH_PANO_PASSWD}" scp ${scp_parameters}
    Run  gzip -dk ${TEST_RESULTS_DIR}/${pm_gz_file}

    ${pm_xml_file}  Remove String  ${pm_gz_file}  .gz
    ${xml}  Parse Xml  ${TEST_RESULTS_DIR}/${pm_xml_file}

    ${custom_bts_name_matches}  Get Elements  ${xml}  //measEntity[@userLabel="${CUSTOM_BTS_NAME}"]
    Should Not Be Empty  ${custom_bts_name_matches}  PM XML file doesn't contain custom BTS name: ${CUSTOM_BTS_NAME}.
    ${sw_version_matches}  Get Elements  ${xml}  //measEntity[@swVersion="${VDU_ACTIVE_SW_VERSION}"]
    Should Not Be Empty  ${sw_version_matches}  PM XML file doesn't contain sw version: ${VDU_ACTIVE_SW_VERSION}.
    ${custom_cell_name_matches}  Get Elements  ${xml}  //*[contains(@measObjLdn, '${CUSTOM_CELL_NAME}')]
    Should Not Be Empty  ${custom_cell_name_matches}  PM XML file doesn't contain custom cell name: ${CUSTOM_CELL_NAME}.


Step4: Vdu Reset
    Log  \nStep4: Vdu Reset  console=true
    Reset VDU And Wait For Ping
    Wait Until Keyword Succeeds  ${VDU_RECOVERY_TIMEOUT}  10s  Check All Cells From VDU  availability_status=${ONLINE}  operational_state=${ENABLED}


Restore Original Names
    Change specific parameter for vDU  btsName  ${VDU_MRBTS_NAME}  MRBTS-${VDU_MRBTS_ID}
    Log  Delete cell name.  console=true
    ${parameter}  Create Dictionary  parameterName=cellName  operation=delete
    ${parameter_list}  Create List  ${parameter}
    ${changed_parameter}  Create Dictionary  distName=MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${CELL_ID}  operation=update
    ...  parameters=${parameter_list}
    ${changed_parameter_list}  Create List  ${changed_parameter}
    ${changed_parameter_string}  Evaluate  json.dumps(${changed_parameter_list})  json
    vdu.Perform Delta Recommissioning  ${changed_parameter_string}


TC Setup
    Common VDU Setup
    Turn ON Pano And Check If Is Connected
    Modify Resource Search Order  PM__vDU__3GPP_XML_Measurement_File_Enrichment_Reset_Site


TC Teardown
    Restore Original Names
    Turn OFF Pano And Check If Is Disconnected
    Common VDU Teardown