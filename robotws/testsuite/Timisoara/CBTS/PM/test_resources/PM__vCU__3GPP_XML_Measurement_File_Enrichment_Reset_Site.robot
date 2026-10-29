*** Settings ***
Documentation
...  This TC is checking PM files to contain specific data.
...  First act3gppXmlEnrichment parameter is changed to true.
...  Bts name and nrcell name are changed to test names.
...  TC waits for new PM file to be generated on Pano server. This new file will be downloaded
...  and it must contain CUSTOM_BTS_NAME and CUSTOM_CELL_NAME.
...  vCU reset is performed. After it, a new PM file is downloaded and it must also contain the data
...  mentioned previously.
...  In the end, TC is restoring the original names for changed parameters.

Library  XML  use_lxml=true
Resource  ../../common_resources/vcu_frame.robot
Resource  ../resources/PM_general.robot


*** Variables ***
${VCU_RECOVERY_TIMEOUT}  900s  # Timeout for VCU to be onAir
${PM_FILE_PANO_TIMEOUT}  180s  # Timeout for PM report is loaded


*** Keywords ***
TC__PM__vCU__3GPP_XML_Measurement_File_Enrichment_Reset_Site
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

    Step0: TC Prerequisites
    Step1: Turn On Files Enrichment
    Step2: Change Vcu And Cell Name
    Step3: Save And Check Latest PM File From Pano
    Step4: Vcu Reset
    Step5: Save And Check Latest PM File From Pano


Step0: TC Prerequisites
    ${vcu_cells_status}  Get Cells Statuses
    ${cell_dictionary}  Evaluate  random.choice(${vcu_cells_status})  random
    ${cell_id}  Fetch From Right  ${cell_dictionary}[dist_names][config]  -
    Set Test Variable  ${CELL_ID}  ${cell_dictionary}[id]
    Set Test Variable  ${CUSTOM_BTS_NAME}  bts@test
    Set Test Variable  ${CUSTOM_CELL_NAME}  @test_cell!

    ${rep_interval_value}  VCU Get Parameter Value  reportingIntervalPm  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    IF  '${rep_interval_value}'!='5min'
      Change specific parameter for vCU  reportingIntervalPm  5min  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
      Sleep Until New Cycle  5min
    END


Step1: Turn On Files Enrichment
    Log  \nStep1: Turn On Files Enrichment  console=true
    ${3gpp_enrichment_value}  VCU Get Parameter Value  act3gppXmlEnrichment  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    IF  '${3gpp_enrichment_value}'!='true'
    ...  Change specific parameter for vCU  act3gppXmlEnrichment  true  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1


Step2: Change Vcu And Cell Name
    Log  \nStep2: Change Vcu And Cell Name  console=true
    Change specific parameter for vCU  btsName  ${CUSTOM_BTS_NAME}  MRBTS-${VCU_MRBTS_ID}
    Change specific parameter for vCU  cellName  ${CUSTOM_CELL_NAME}  MRBTS-${VCU_MRBTS_ID}/NRBTS-${VCU_NRBTS_ID}/NRCELL-${CELL_ID}


Step${index}: Save And Check Latest PM File From Pano
    Log  \nStep${index}: Save And Check Latest PM File From Pano  console=true
    Sleep Until New Cycle  5min
    Sleep  ${PM_FILE_PANO_TIMEOUT}  TC will wait until PM report is loaded.
    ${pm_gz_file}  Get Last PM File Name From Pano  ${VCU_MRBTS_ID}
    ${file_exists}  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${TEST_RESULTS_DIR}/${pm_gz_file}
    Should Not Be True  ${file_exists}  A new PM file was not created on Pano server.
    ${scp_parameters}  Set Variable  ${VM_WITH_PANO_USR}@${VM_WITH_PANO_IP}:/home/ute/.local/pano/pm_files/${pm_gz_file} ${TEST_RESULTS_DIR}
    Run  sshpass -p "${VM_WITH_PANO_PASSWD}" scp ${scp_parameters}
    Run  gzip -dk ${TEST_RESULTS_DIR}/${pm_gz_file}

    ${pm_xml_file}  Remove String  ${pm_gz_file}  .gz
    ${xml}  Parse Xml  ${TEST_RESULTS_DIR}/${pm_xml_file}

    ${custom_bts_name_matches}  Get Elements  ${xml}  //measEntity[@userLabel="${CUSTOM_BTS_NAME}"]
    Should Not Be Empty  ${custom_bts_name_matches}  PM XML file doesn't contain custom BTS name: ${CUSTOM_BTS_NAME}.
    ${sw_version_matches}  Get Elements  ${xml}  //measEntity[@swVersion="${VCU_ACTIVE_SW_VERSION}"]
    Should Not Be Empty  ${sw_version_matches}  PM XML file doesn't contain sw version: ${VCU_ACTIVE_SW_VERSION}.
    ${custom_cell_name_matches}  Get Elements  ${xml}  //*[contains(@measObjLdn, '${CUSTOM_CELL_NAME}')]
    Should Not Be Empty  ${custom_cell_name_matches}  PM XML file doesn't contain custom cell name: ${CUSTOM_CELL_NAME}.


Step4: Vcu Reset
    Log  \nStep4: Vcu Reset  console=true
    Reset VCU And Wait For Ping
    Wait Until Keyword Succeeds  ${VCU_RECOVERY_TIMEOUT}  10s  Check All Cells From VCU  operational_state=${ENABLED}


Restore Original Names
    Change specific parameter for vCU  btsName  ${VCU_MRBTS_NAME}  MRBTS-${VCU_MRBTS_ID}
    Log  Delete cell name.  console=true
    ${parameter}  Create Dictionary  parameterName=cellName  operation=delete
    ${parameter_list}  Create List  ${parameter}
    ${changed_parameter}  Create Dictionary  distName=MRBTS-${VCU_MRBTS_ID}/NRBTS-${VCU_NRBTS_ID}/NRCELL-${CELL_ID}  operation=update
    ...  parameters=${parameter_list}
    ${changed_parameter_list}  Create List  ${changed_parameter}
    ${changed_parameter_string}  Evaluate  json.dumps(${changed_parameter_list})  json
    vcu.Perform Delta Recommissioning  ${changed_parameter_string}


TC Setup
    Common VCU Setup
    Turn ON Pano And Check If Is Connected
    Modify Resource Search Order  PM__vCU__3GPP_XML_Measurement_File_Enrichment_Reset_Site


TC Teardown
    Restore Original Names
    Turn OFF Pano And Check If Is Disconnected
    Common VCU Teardown