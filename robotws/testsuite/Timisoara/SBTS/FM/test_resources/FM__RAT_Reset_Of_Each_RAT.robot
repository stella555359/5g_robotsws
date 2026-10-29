*** Settings ***
Documentation
    ...  This test was created to perform reset on every RAT.
    ...  On WCDMA RAT, reset is performed twice, through CPFCTNODE process crash and DSP crash.
    ...  On GSM RAT, reset is performed once, through DSP crash.
    ...  On LTE, C-CPNODE00 process is crashed, and on NR, CPCL process is crashed.
    ...  Alarms and cells verifications are done after every crash.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  300  # [in seconds] Timeout for alarm to be reported in WebEM.
${CELLS_TIMEOUT}  300  # [in seconds] Timeout for cells to be in expected state.


*** Keywords ***
TC__FM__RAT_Reset_Of_Each_RAT
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28216
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 11.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28216 - Initial TAT creation
    ...  - 22.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28278 - Enhancement for fault signature
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  *******************


    Set Tags  CA-FM  OWNER-OWNER-lucian.ciurel@nokia.com  AUTHOR-anna.benzar@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS25


    Step0: TC Preconditions
    Step1: Reset WCDMA RAT
    Step2: Reset GSM RAT
    Step3: Reset LTE RAT
    Step4: Reset NR RAT


Step0: TC Preconditions
    Log  \nStep0: TC preconditions.  console=true
    Perform Site Reset
    ${fault_670x_rat_auto_rst}  Copy Dictionary  ${FAULT_6707_RAT_AUTO_RST}
    Set To Dictionary  ${fault_670x_rat_auto_rst}  fault_id=regex"6707|6708|6709"
    ${fault_670x_rat_auto_rst_params}  Get String With Alarm Parameters  ${fault_670x_rat_auto_rst}
    Set Test Variable  ${FAULT_PARAMETERS}  ${fault_670x_rat_auto_rst_params}
    ${fault_4383_rat_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_4383_RAT_AUTO_RST}
    Set Test Variable  ${FAULT_4383_PARAMS}  ${fault_4383_rat_auto_rst_params}
    ${fault_7107_params}  Get String With Alarm Parameters  ${FAULT_7107}
    Set Test Variable  ${FAULT_7107_PARAMS}
    ${nsa_saNsa_cells}  Get List Of NSA and SA+NSA Cells
    ${nsa_saNsa_cells_status}  Run Keyword And Return Status  Should Not Be Empty  ${nsa_saNsa_cells}
    Set Test Variable  ${NSA_CELLS_STATUS}  ${nsa_saNsa_cells_status}
    Set Affected Cells and BBMODs For NR Process Crash


Step1: Reset WCDMA RAT
    Log  \nStep1: Reset WCDMA RAT.  console=true
    Crash Given Process  CPFCTNODE
    Log  Wait for alarm to appear in WebEM...  console=true
    Assert Alarm Active  parameters=${FAULT_4383_PARAMS}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4383_RAT_AUTO_RST}[fault_id] "${FAULT_4383_RAT_AUTO_RST}[fault_name]" reported in WebEM. [OK]  console=true
    Assert Every  class_name=WNCEL  parameters=operationalState=${ENABLED}  timeout=${CELLS_TIMEOUT}
    Log  Everything is back online after CPFCTNODE crash. [OK]  console=true
    Log  Check fault signature for fault ${FAULT_4383_RAT_AUTO_RST}[fault_id]...  console=true
    Set Fault Signature Variables For Process Crash  CPFCTNODE  WCDMA
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_4383_RAT_AUTO_RST}[fault_id]  category=${CATEGORY}  extra_info=${EXTRA_INFO}
    ...  info=${INFO}  load_name=${SW_VERSION}  minor=${MINOR_ID}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Change Parameter ActForce(Unit)AutoReset  true  actForceAutoReset
    Choose DSP For Crash  WCDMA
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=wcdmaCrash
    ${cells_status}  Run Keyword In Background
    ...  Assert Every  class_name=WNCEL  parameters=operationalState=${DISABLED}  timeout=${CELLS_TIMEOUT}  alias=wcdmaCrash
    Verify SMOD Type And Trigger DSP Crash
    Assert Alarm Active  parameters=${FAULT_PARAMETERS}  timeout=${ALARM_TIMEOUT}
    Log  Fault 6707|6708|6709 "${FAULT_6707_RAT_AUTO_RST}[fault_name]" reported in WebEM. [OK]  console=true
    Log  Wait for alarm and cells check to be done...  console=true
    ${cells_status}  Run Keyword And Return Status  Collect Keyword Result  ${cells_status}  timeout=${CELLS_TIMEOUT}
    Should Be True  ${cells_status}  WCDMA cells were not failed while fault 6707/6708/6790 occured. [NOK]
    Log  WCDMA cells were failed while fault 6707/6708/6709 occured. [OK]  console=true
    Wait Until Keyword Succeeds  ${CELLS_TIMEOUT}  10  Check Modules And Cells
    Log  Check fault signature for fault ${FAULT_6707_RAT_AUTO_RST}[fault_id]...  console=true
    Set FaultSignature Variables For DSP Crash  ${CORE_ID}[dist_name]  WCDMA
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_6707_RAT_AUTO_RST}[fault_id]  category=${CATEGORY}
    ...  extra_info=${EXTRA_INFO}  load_name=${SW_VERSION}  minor=${MINOR}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}

    [Teardown]  Teardown Admin  alias=wcdmaCrash


Step2: Reset GSM RAT
    Log  \nStep2: Reset GSM RAT.  console=true
    Choose DSP For Crash  GSM
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=gsmCrash
    ${cells_status}  Run Keyword In Background
    ...  Assert Every  class_name=GNCEL  parameters=operationalState=${DISABLED}  timeout=${CELLS_TIMEOUT}  alias=gsmCrash
    Verify SMOD Type And Trigger DSP Crash
    Assert Alarm Active  parameters=${FAULT_PARAMETERS}  timeout=${ALARM_TIMEOUT}
    Log  Fault 6707|6708|6709 "${FAULT_6707_RAT_AUTO_RST}[fault_name]" reported in WebEM. [OK]  console=true
    Log  Wait for alarm and cells check to be done...  console=true
    ${cells_status}  Run Keyword And Return Status  Collect Keyword Result  ${cells_status}  timeout=${CELLS_TIMEOUT}
    Should Be True  ${cells_status}  GSM cells were not failed while fault 6707/6708/6709 occured. [NOK]
    Log  GSM cells were failed while fault 6707/6708/6790 occured. [OK]  console=true
    Wait Until Keyword Succeeds  ${CELLS_TIMEOUT}  10  Check Modules And Cells
    Log  Check fault signature for fault ${FAULT_6707_RAT_AUTO_RST}[fault_id]...  console=true
    Set FaultSignature Variables For DSP Crash  ${CORE_ID}[dist_name]  GSM
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_6707_RAT_AUTO_RST}[fault_id]  category=${CATEGORY}
    ...  extra_info=${EXTRA_INFO}  load_name=${SW_VERSION}  minor=${MINOR}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}

    [Teardown]  Teardown Admin  alias=gsmCrash


Step3: Reset LTE RAT
    Log  \nStep3: Reset LTE RAT.  console=true
    ${date_netact}  Get Current Date  time_zone=UTC  result_format=datetime
    Change FEATCADM Parameter  actRatResetEnhancement  true
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=lteCrash
    IF  ${NSA_CELLS_STATUS}
      ${nr_cells_status}  Run Keyword In Background  Assert Every  class_name=NRCEL  parameters=operationalState=${DISABLED}  timeout=${CELLS_TIMEOUT}
    END
    ${lte_cells_status}  Run Keyword In Background
    ...  Assert Every  class_name=LNCEL  parameters=operationalState=${DISABLED}  timeout=${CELLS_TIMEOUT}  alias=lteCrash
    Crash Given Process  C-CPNODE
    Log  Wait for alarm and cells check to be done...  console=true
    Assert Alarm Active  parameters=${FAULT_4383_PARAMS}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4383_RAT_AUTO_RST}[fault_id] "${FAULT_4383_RAT_AUTO_RST}[fault_name]" reported in WebEM. [OK]  console=true
    ${nsa_status}  Run Keyword And Return Status  Should Be Equal As Strings  ${nr_cells_status}  ${NONE}
    IF  ${nsa_status} == ${FALSE}
      Assert Alarm Active  parameters=${FAULT_7107_PARAMS}  timeout=${ALARM_TIMEOUT}
      Log  Fault ${FAULT_7107}[fault_id] "${FAULT_7107}[fault_name]" reported in WebEM. [OK]  console=true
    END
    IF  ${nsa_status} == ${FALSE}
      Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}s  30s
      ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_7107}  time_from=${date_netact}
      ...  additional_fault_id=${FAULT_7107}[fault_id]  suppl_info=trigger=link-status-change, failureService=NSA
      Log  Fault ${FAULT_7107}[fault_id] "${FAULT_7107}[fault_name]" - reported & cleared from NetAct. [OK]  console=true
    END
    IF  ${nsa_status} == ${TRUE}
      ${nr_cells_status}  Log  There are no NSA or SA+NSA cells on BTS, NR cells check is skipped.  console=true
    ELSE
      ${nr_cells_status}  Run Keyword And Return Status  Collect Keyword Result  ${nr_cells_status}  timeout=${CELLS_TIMEOUT}
    END
    IF  ${nr_cells_status}
      Log  NSA/SA+NSA cells were failed during C-CPNODE crash. [OK]  console=true
    ELSE IF  ${nr_cells_status} == ${FALSE}
      Fail  NSA/SA+NSA cells didn't reset during C-CPNODE crash. [NOK]
    END
    ${lte_cells_status}  Run Keyword And Return Status  Collect Keyword Result  ${lte_cells_status}  timeout=${CELLS_TIMEOUT}
    Should Be True  ${lte_cells_status}  LTE cells were not failed during C-CPNODE crash. [NOK]
    Log  LTE cells were failed during C-CPNODE crash. [OK]  console=true
    Wait Until Keyword Succeeds  ${CELLS_TIMEOUT}  10  Check Modules And Cells
    Log  Check fault signature for fault ${FAULT_4383_RAT_AUTO_RST}[fault_id]...  console=true
    Set Fault Signature Variables For Process Crash  C-CPNODE  LTE
    ${MINOR_ID}  Fetch From Left  ${MINOR_ID}  00
    ${MINOR_ID}  Replace String Using Regexp  ${MINOR_ID}  -  _
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_4383_RAT_AUTO_RST}[fault_id]  filtering_minor_field=${MINOR_ID}  category=${CATEGORY}
    ...  extra_info=${EXTRA_INFO}  info=${INFO}  load_name=${SW_VERSION}  minor=${MINOR_ID}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}
    ...  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}

    [Teardown]  Teardown Admin  alias=lteCrash


Step4: Reset NR RAT
    Log  \nStep4: Reset NR RAT.  console=true
    Change FEATCADM Parameter  actRatResetEnhancement  false
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=nrCrash
    ${fault_status}  Run Keyword In Background  Assert Alarm Active  parameters=${FAULT_4383_PARAMS}  timeout=${ALARM_TIMEOUT}  alias=nrCrash
    Crash Given Process  CPCL
    Log  Wait for modules, cells and alarms check to be done...  console=true
    Wait until Keyword Succeeds  ${CELLS_TIMEOUT}  10s  Check BBMODs status to be degraded or offline  ${AFFECTED_BBMODS}
    Log  All affected BBMODs are degraded or offline during CPCL crash. [OK]  console=true
    Wait until Keyword Succeeds  ${CELLS_TIMEOUT}  10s  Check Parameters Status For Cells  ${AFFECTED_CELLS}  operationalState=${DISABLED}
    Log  All affected cells are failed during CPCL crash. [OK]  console=true
    ${fault_status}  Run Keyword And Return Status  Collect Keyword Result  ${fault_status}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${fault_status}
    ...  Fault ${FAULT_4383_RAT_AUTO_RST}[fault_id] "${FAULT_4383_RAT_AUTO_RST}[fault_name]" didn't occur in WebEM. [NOK]
    Log  Fault ${FAULT_4383_RAT_AUTO_RST}[fault_id] "${FAULT_4383_RAT_AUTO_RST}[fault_name]" reported in WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  ${CELLS_TIMEOUT}  10  Check Modules And Cells
    Log  Check fault signature for fault ${FAULT_4383_RAT_AUTO_RST}[fault_id]...  console=true
    Set Fault Signature Variables For Process Crash  CPCL  NR
    ${MINOR_ID}  Fetch From Left  ${MINOR_ID}  00
    ${MINOR_ID}  Replace String Using Regexp  ${MINOR_ID}  -  _
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_4383_RAT_AUTO_RST}[fault_id]  filtering_minor_field=${MINOR_ID}  category=${CATEGORY}
    ...  extra_info=${EXTRA_INFO}  info=${INFO}  load_name=${SW_VERSION}  minor=${MINOR_ID}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}
    ...  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}

    [Teardown]  Teardown Admin  alias=nrCrash


Set Fault Signature Variables For Process Crash
    [Arguments]  ${process}  ${rat}
    ${sw_node}  Query Infomodel  get object //SW_NODE_L-* is [rat=${rat} hostname=regex"${process}"]
    ${node_id}  Convert To Hex  ${sw_node}[nodeId]  prefix=0x
    ${node_id}  Convert To Lower Case  ${node_id}
    ${minor_id}  Set Variable If  '${ENB_BRANCH}' < 'SBTS24R3'  ${node_id}  ${node_id}${SPACE}${process}
    ${is_ccu}  Run Keyword And Return Status  Should Contain  ${sw_node}[dist_name]  /CCU
    ${is_bbu}  Run Keyword And Return Status  Should Contain  ${sw_node}[dist_name]  /BBU
    ${is_board}  Run Keyword And Return Status  Should Contain  ${sw_node}[dist_name]  /BOARD
    IF  ${is_ccu}
       ${module_l_dn}  Fetch From Left  ${sw_node}[dist_name]  /CCU_L
    ELSE IF  ${is_bbu}
       ${module_l_dn}  Fetch From Left  ${sw_node}[dist_name]  /BBU_L
    ELSE IF  ${is_board}
      ${module_l_dn}  Fetch From Left  ${sw_node}[dist_name]  /BOARD_L
    END
    ${module_l_parameters}  coam.Get Parameters  ${module_l_dn}
    ${module_r_dn}  Get Module Dist Name By Serial Number And Class  ${module_l_parameters}[serialNumber]  SMOD
    Set Test Variable  ${PRODUCT_NAME}  ${module_l_parameters}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${module_l_parameters}[serialNumber]
    Set Test Variable  ${PRODUCT_CODE}  ${module_l_parameters}[productCode]
    Set Unit Position For Fault Signature  ${module_r_dn}
    Set Test Variable  ${CATEGORY}  TIMEOUT
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=.*${rat}:[0-9]+
    Set Test Variable  ${INFO}  Node communication failure
    Set Test Variable  ${MINOR_ID}
    Set Test Variable  ${RESET_COUNTER}  [0-9]+
    Set Test Variable  ${SCOPE}  ${rat} RAT


Set FaultSignature Variables For DSP Crash
    [Arguments]  ${selected_dsp}  ${rat}

    ${bbmod_l_dn}  Fetch From Left  ${selected_dsp}  /BBU
    ${bbmod_l_parameters}  coam.Get Parameters  ${bbmod_l_dn}
    ${bbmod_r_dn}  Get Module Dist Name By Serial Number And Class  ${bbmod_l_parameters}[serialNumber]  BBMOD
    Set Test Variable  ${PRODUCT_NAME}  ${bbmod_l_parameters}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${bbmod_l_parameters}[serialNumber]
    Set Test Variable  ${PRODUCT_CODE}  ${bbmod_l_parameters}[productCode]
    Set Unit Position For Fault Signature  ${bbmod_r_dn}
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=.*${rat}:[0-9]+
    Set Test Variable  ${RESET_COUNTER}  [0-9]+
    Set Test Variable  ${SCOPE}  ${rat} RAT
    Set Test Variable  ${MINOR}  0x[0-9]+


Crash Given Process
    [Arguments]  ${process_name}

    Log  Crash ${process_name} process...  console=true
    Open connection to primary core
    SSHLibrary.Write   ps aux | grep lxc | grep ${process_name}
    ${command_output}  SSHLibrary.Read until prompt
    Should not Be Empty  ${command_output}  ${process_name} doesn't exist on PC, please check again.
    ${process_ids}  Get regexp matches  ${command_output}  root +[0-9]*
    ${process_id}  Fetch From Right  ${process_ids}[0]  ${SPACE}
    SSHLibrary.Write  kill -9 ${process_id}
    SSHLibrary.Read until prompt
    SSHLibrary.Close connection


Get List Of NSA and SA+NSA Cells
    ${nsa_saNsa_cells}  Create List
    ${all_cells}  Get Cells Info
    FOR  ${cell}  IN  @{all_cells}
         ${nsa_status}  Run Keyword And Return Status  Should Be Equal As Strings  ${cell}[cellDepType]  NSA
         ${sa_nsa_status}  Run Keyword And Return Status  Should Be Equal As Strings  ${cell}[cellDepType]  SA+NSA
         IF  ${nsa_status} or ${sa_nsa_status}  Append To List  ${nsa_saNsa_cells}  ${cell}[id][internal]
    END

    RETURN  ${nsa_saNsa_cells}


Set Affected Cells and BBMODs For NR Process Crash
    ${affected_bbmods}  Create List
    ${affected_cells}  Create List
    ${bbmods_list}  Get Ids For All  BBMOD
    FOR  ${bbmod}  IN  @{bbmods_list}
         ${cells_on_bbmod}  Get Cell Mapping By Module Id  ${bbmod}
         ${nr_cells_status}  Verify If Nr Cells Are Mapped On Current Module  ${cells_on_bbmod}
         IF  ${nr_cells_status} == ${FALSE}  CONTINUE
         Append To List  ${affected_cells}  @{cells_on_bbmod}
         Append To List  ${affected_bbmods}  ${bbmod}
    END
    ${rmods_list}  Get Ids For All  RMOD
    FOR  ${rmod}  IN  @{rmods_list}
         ${cells_on_rmod}  Get Cell Mapping By Module Id  ${rmod}
         ${nr_cells_status}  Verify If Nr Cells Are Mapped On Current Module  ${cells_on_rmod}
         IF  ${nr_cells_status} == ${FALSE}  CONTINUE
         Append To List  ${affected_cells}  @{cells_on_rmod}
    END
    Should Not Be Empty  ${affected_cells}
    ${affected_cells}  Remove Duplicates  ${affected_cells}
    Should Not Be Empty  ${affected_bbmods}
    Set Test Variable  ${AFFECTED_CELLS}
    Set Test Variable  ${AFFECTED_BBMODS}


Verify If Nr Cells Are Mapped On Current Module
    [Arguments]  ${cells}

    FOR  ${cell_dn}  IN  @{cells}
       ${nrcell_status}  Run Keyword And Return Status  Should Contain  ${cell_dn}  NRCELL
       IF  ${nrcell_status}  RETURN  ${TRUE}
    END

    RETURN  ${FALSE}


Check BBMODs status to be degraded or offline
    [Arguments]  ${bbmods_dns_list}

    FOR  ${bbmod_dn}  IN  @{bbmods_dns_list}
        ${degraded_status}  Run Keyword And Return Status  Assert  BBMOD  ${bbmod_dn}  parameters=availabilityStatus=${DEGRADED}
        ${offline_status}  Run Keyword And Return Status  Assert  BBMOD  ${bbmod_dn}  parameters=availabilityStatus=${OFFLINE}
        IF  ${degraded_status} == ${FALSE} and ${offline_status} == ${FALSE}  Fail  BBMOD with dist name: ${bbmod_dn} is not degraded or offline.
    END


TC Setup
    Common Test Setup  tc_name=FM__RAT_Reset_Of_Each_RAT
    Setup Netact

TC Teardown
    Teardown Netact
    Common Test Teardown
