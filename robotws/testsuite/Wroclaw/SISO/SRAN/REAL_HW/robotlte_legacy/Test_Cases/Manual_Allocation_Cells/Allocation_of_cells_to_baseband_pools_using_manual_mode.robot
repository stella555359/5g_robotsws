*** Settings ***
Library  taf.sbts.oam.coam.admin  WITH NAME  admin
Library  XML    use_lxml=${TRUE}
Library  OperatingSystem
Library  Collections

#Resource  ../../../robotlte_legacy/hran_ta/resources/ca_delta_resource.robot
Resource  ./delta_manual_alloc_resource.robot
Resource  ../../../robotlte_legacy/bbpool_allocation.robot
*** Variables ***

${IGNORE_ERRORS}               ${FALSE}
${RECOMMISSIONING_TIMEOUT}     600
${STARTUP_TIMEOUT}             ${EMPTY}
${DELTA_CUSTOM_NAME}           ${EMPTY}
${COUNT_CELLS_OFF}             ${EMPTY}
${BTS_ID}                      ${EMPTY}
${DELTA_JSON_PATH}             ${EMPTY}
${BBMOD_PRODUCT_CODE}          ${EMPTY}
${BBMOD_SN}                    ${EMPTY}

*** Keywords ***
Allocation of cells to baseband pools using manual mode
    [Documentation]
    ...    Description:
    ...    Test supports BBMOD for which parameter actbbpooling is set to 'true'.
    ...    Test supports LTE technologie.
    ...    Test checks behavior of BTS and cells after Delta Commissining with json file.
    ...    Delta file introduces manual cell allocation.
    ...    Delta File need to be prepared by user and stored in same folder as TS and in folder ABIO.
    ...    The test requires 3x delta .json with the names:
    ...    delta_manual_mode.json,
    ...    delta_manual_mode_several_cells.json,
    ...    manual_mode_exceeding_Loki_capacity.json.
    ...
    ...    |  **Author:**      daria.wronska@nokia.com
    ...    |  **Maintainer:**  daria.wronska@nokia.com
    ...
    ...    Arguments:
    ...    +--------------------+-------+------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                  |
    ...    +====================+=======+==============================================================================+
    ...    | DELTA_JSON_PATH    | Yes   | Should be chosen as path to folder JSON_FILES,  add to TS.                   |
    ...    |                    |       | Example:                                                                     |
    ...    |                    |       | ${DELTA_JSON_PATH}=                                                          |
    ...    |                    |       | /testsuite/WMP/GVe/Wroclaw/AiFSiteS/CRT/10_16_UTESRANSISO906/JSON_FILES      |
    ...    +--------------------+-------+------------------------------------------------------------------------------+
    ...    | BBMOD_product_code | Yes   | Set 'Product code' to select on which BBMOD is tested, add to TS.            |
    ...    |                    |       | Example:                                                                     |
    ...    |                    |       | ${BBMOD_product_code}=    475266                                             |
    ...    +--------------------+-------+------------------------------------------------------------------------------+
    ...    | BBMOD_SN           | Yes   | Set 'Serial number' to select on which BBMOD is tested, add to TS.           |
    ...    |                    |       | Example:                                                                     |
    ...    |                    |       | ${BBMOD_SN}=     L1223309845                                                 |
    ...    +--------------------+-------+------------------------------------------------------------------------------+
    ...    | COUNT_CELLS_OFF    | Yes   | Indicates how many cells are affected by fault 1868 in Step 4, add to TS.    |
    ...    |                    |       | Example:                                                                     |
    ...    |                    |       | ${COUNT_CELLS_OFF}=    3                                                     |
    ...    +--------------------+-------+------------------------------------------------------------------------------+
    ...    | BTS_ID             | Yes   | Set to select on which BTS test is going to be performed, add to TS.         |
    ...    |                    |       | Example:                                                                     |
    ...    |                    |       | ${BTS_ID}=    1435                                                           |
    ...    +--------------------+-------+------------------------------------------------------------------------------+

    Step 1: Check Delta Commissioning Json File Exists And Required Parameters
    Step 2: Allocation Of Cells To Baseband Bools Using Manual Mode
    Step 3: Allocation Of Cells To Baseband Pools Using Manual Mode On Several Cells
    Step 4: Allocation Of Cells To Baseband Pools Using Manual Mode Exceeding Loki Capacity

Step 1: Check Delta Commissioning Json File Exists And Required Parameters
    [Documentation]
    ...    Description:
    ...    Checking if delta .json files exist.
    ...    Checking if required object exists: BBPOOLALLOC-0 for reconfigurations cells.
    ...    Checking if LNBTS parameter actBbPooling is set to 'true'.
    ...
    ...    |  **Author:**      daria.wronska@nokia.com
    ...    |  **Maintainer:**  daria.wronska@nokia.com

    Log  === Step 1: Check Delta Commissioning Json File Exists And Required Parameters ===  console=${TRUE}
    Cheking If Delta Json Files Exist
    Checking If BBPOOLALLOC-0 For Reconfigurations Cells Exists
    Checking If ActBbPooling Is Set To 'True'

Step 2: Allocation Of Cells To Baseband Bools Using Manual Mode
    [Documentation]
    ...  Description:
    ...  Validate delta against SCF excluded file delta_manual_mode.json.
    ...  Perform delta file delta_manual_mode.json commissioning.
    ...  Validate delta against SCF included file delta_manual_mode.json.
    ...  Verify BTS state and verify unexpected alarms.
    ...  Return to configuration with default SCF.
    ...  Verify BTS state and verify unexpected alarms.
    ...
    ...  |  **Author:**      daria.wronska@nokia.com
    ...  |  **Maintainer:**  daria.wronska@nokia.com
    ...
    ...  Arguments:
    ...  +--------------------+-------+------------------------------------------------------------------------------+
    ...  | Argument           | Man.  | Description                                                                  |
    ...  +====================+=======+==============================================================================+
    ...  | DELTA_JSON_PATH    | Yes   | Should be chosen as path to folder JSON_FILES,  add to TS.                   |
    ...  |                    |       | Example:                                                                     |
    ...  |                    |       | ${DELTA_JSON_PATH}=                                                          |
    ...  |                    |       |/testsuite/WMP/GVe/Wroclaw/AiFSiteS/CRT/10_16_UTESRANSISO906/JSON_FILES       |
    ...  +--------------------+-------+------------------------------------------------------------------------------+
    ...  | BTS_ID             | Yes   | Set to select on which BTS test is going to be performed, add to TS.         |
    ...  |                    |       | Example:                                                                     |
    ...  |                    |       | ${BTS_ID}=    1435                                                           |
    ...  +--------------------+-------+------------------------------------------------------------------------------+

   Log  === Step 2: Allocation Of Cells To Baseband Bools Using Manual Mode ===  console=${TRUE}
   ${SCF_XML}=  scf.load scf  ${cfg.NODES['${BTS_ID}']['scf_file_path']}
   Set Test Variable  ${SCF_XML}  ${SCF_XML}
   ${json}=  OperatingSystem.Get File  path=${DELTA_JSON_PATH}/delta_manual_mode.json
   ${json}=  Evaluate  json.loads('''${json}''')  json
   Set Test Variable  ${DELTA_JSON_FILE}  ${json}
   Validate Delta Against SCF  excluded
   Set Test Variable  ${DELTA_FOR_RECOMM}  ${DELTA_JSON_PATH}/delta_manual_mode.json
   ca_delta_resource.Perform Delta File Commissioning
   ${SCF_XML}=  admin.Get Current SCF File
   ...  local_dir_path=${cfg.test_logs_path}
   ...  file_name=SCF_recommissioning2.xml
   ...  connection=${BTS_ID}
   Set Test Variable  ${SCF_XML}  ${SCF_XML}
   Validate Delta Against SCF  included
   Verify BTS State  ${BTS_ID}  ${CONFIGURATION_STARTUP_TIMEOUT}
   Sleep  120  Wait for BTS status will be final.
   Verify Alarms  alias=${BTS_ID}
   [Teardown]    Force Recommissioning With Current Branch On Every Node

Step 3: Allocation Of Cells To Baseband Pools Using Manual Mode On Several Cells
    [Documentation]
    ...  Description:
    ...  Validate delta against SCF excluded file delta_manual_mode_several_cells.json.
    ...  Perform delta file delta_manual_mode.json commissioning.
    ...  Validate delta against SCF included file delta_manual_mode_several_cells.json.
    ...  Verify BTS state and verify unexpected alarms.
    ...  Return to configuration with default SCF.
    ...  Verify BTS state and verify unexpected alarms.
    ...
    ...  |  **Author:**      daria.wronska@nokia.com
    ...  |  **Maintainer:**  daria.wronska@nokia.com
    ...
    ...  Arguments:
    ...  +--------------------+-------+------------------------------------------------------------------------------+
    ...  | Argument           | Man.  | Description                                                                  |
    ...  +====================+=======+==============================================================================+
    ...  | DELTA_JSON_PATH    | Yes   | Should be chosen as path to folder JSON_FILES,  add to TS.                   |
    ...  |                    |       | Example:                                                                     |
    ...  |                    |       | ${DELTA_JSON_PATH}=                                                          |
    ...  |                    |       | /testsuite/WMP/GVe/Wroclaw/AiFSiteS/CRT/10_16_UTESRANSISO906/JSON_FILES      |
    ...  +--------------------+-------+------------------------------------------------------------------------------+
    ...  | BTS_ID             | Yes   | Set to select on which BTS test is going to be performed, add to TS.         |
    ...  |                    |       | Example:                                                                     |
    ...  |                    |       | ${BTS_ID}=    1435                                                           |
    ...  +--------------------+-------+------------------------------------------------------------------------------+

   Log  === Step 3: Allocation Of Cells To Baseband Pools Using Manual Mode On Several Cells ===  console=${TRUE}
   ${SCF_XML}=  scf.load scf  ${cfg.NODES['${BTS_ID}']['scf_file_path']}
   Set Test Variable  ${SCF_XML}
   ${json}=  OperatingSystem.Get File  path=${DELTA_JSON_PATH}/delta_manual_mode_several_cells.json
   ${json}=  Evaluate  json.loads('''${json}''')  json
   Set Test Variable  ${DELTA_JSON_FILE}  ${json}
   Validate Delta Against SCF  excluded
   Set Test Variable  ${DELTA_FOR_RECOMM}  ${DELTA_JSON_PATH}/delta_manual_mode_several_cells.json
   ca_delta_resource.Perform Delta File Commissioning
   ${SCF_XML}=  admin.Get Current SCF File
   ...  local_dir_path=${cfg.test_logs_path}
   ...  file_name=SCF_recommissioning3.xml
   ...  connection=${BTS_ID}
   Set Test Variable  ${SCF_XML}
   Validate Delta Against SCF  included
   Verify BTS State  ${BTS_ID}  ${CONFIGURATION_STARTUP_TIMEOUT}
   Sleep  120  Wait for BTS status will be final.
   Verify Alarms  alias=${BTS_ID}
   [Teardown]    Force Recommissioning With Current Branch On Every Node

Step 4: Allocation Of Cells To Baseband Pools Using Manual Mode Exceeding Loki Capacity
    [Documentation]
    ...  Description:
    ...  Validate delta against SCF excluded file delta_manual_mode_several_cells.json.
    ...  Perform delta file delta_manual_mode.json commissioning.
    ...  Validate delta against SCF included file delta_manual_mode_several_cells.json.
    ...  Verify expected faults 1868.
    ...  Verify BTS state and verify unexpected alarms.
    ...  Return to configuration with default SCF.
    ...  Verify BTS state and verify unexpected alarms.
    ...
    ...  |  **Author:**      daria.wronska@nokia.com
    ...  |  **Maintainer:**  daria.wronska@nokia.com
    ...
    ...  Arguments:
    ...  +--------------------+-------+------------------------------------------------------------------------------+
    ...  | Argument           | Man.  | Description                                                                  |
    ...  +====================+=======+==============================================================================+
    ...  | DELTA_JSON_PATH    | Yes   | Should be chosen as path to folder JSON_FILES,  add to TS.                   |
    ...  |                    |       | Example:                                                                     |
    ...  |                    |       | ${DELTA_JSON_PATH}=                                                          |
    ...  |                    |       | /testsuite/WMP/GVe/Wroclaw/AiFSiteS/CRT/10_16_UTESRANSISO906/JSON_FILES      |
    ...  +--------------------+-------+------------------------------------------------------------------------------+

   Log  === Step 4: Allocation Of Cells To Baseband Pools Using Manual Mode Exceeding Loki Capacity ===  console=${TRUE}
   ${json}=  OperatingSystem.Get File  path=${DELTA_JSON_PATH}/delta_manual_mode_exceeding_Loki_capacity.json
   ${json}=  Evaluate  json.loads('''${json}''')  json
   Set Test Variable  ${DELTA_JSON_FILE}  ${json}
   Validate SCF Exclude Delta Json File
   Set Test Variable  ${DELTA_FOR_RECOMM}  ${DELTA_JSON_PATH}/delta_manual_mode_exceeding_Loki_capacity.json
   Preparing Variables For Delta Json File
   ca_delta_resource.Perform Delta File Commissioning
   Validate SCF Included Delta Json File
   Checking If Expected Fault Exists
   [Teardown]    Force Recommissioning With Current Branch On Every Node

