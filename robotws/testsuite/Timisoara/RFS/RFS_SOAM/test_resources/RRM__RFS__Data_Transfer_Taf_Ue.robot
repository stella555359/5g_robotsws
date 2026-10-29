*** Settings ***
Documentation    TC__RRM__RFS__Data_Transfer_Taf_Ue
Variables    tc_variables/RRM__RFS__Data_Transfer_Taf_Ue.py
Library    String
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${TECHNO}    WCDMA                 # Specified standalone technology on which call will be peformed;
                                   # Possible values: "WCDMA", "GSM", "LTE", "NR"
${BTS_CALL}    BTS1                 # Specified BTS on which call will be peformed; Default value: BTS1 (Master)
${CELLS_LIST}    DEFAULT           # Specify the cells list on which UE will be checked; Possible values: "DEFAULT" - means that UE is checked if it
                                   # is camped on a cell belonging to BTS; "30295 30294 30293"-User provides cells list with space between Cells Id.
                                   # For WCDMA - Global Cell Id is used, for LTE -  Eutran Cell Id is used, for GSM - Cell CI is used,
                                   # for NR - NRCellID is used.
${USE_ATTENUATOR}    NO            # Use attenuator to make call on multiple cells, one at a time. Possible Values: "YES", "NO"
${CALL_DIRECTION}    downlink      # Direction of data transfer call; possible values: "uplink", "downlink" and "uplink_downlink"
${CALL_DURATION}    100            # Duration of call in seconds
${downlink_MAX_TPUT}    150 Mbits/sec      # Downlink Maximum acceptable t-put; acceptable values: e.q. LTE - 150 Mbits/sec; WCDMA - 10 Mbits/sec;
                                           # GSM - 400 Kbits/sec
${downlink_MIN_TPUT}    145 Kbits/sec      # Downlink Minmum acceptable t-put; acceptable values: e.q. LTE - 5 Mbits/sec; WCDMA - 350 Kbits/sec;
                                           # GSM - 150 Kbits/sec
${uplink_MAX_TPUT}    50 Mbits/sec      # Uplink Maximum acceptable t-put; acceptable values: e.q. LTE - 50 Mbits/sec; WCDMA - 8 Mbits/sec;
                                        # GSM - 300 Kbits/sec
${uplink_MIN_TPUT}    78 Kbits/sec      # Uplink Minimum acceptable t-put; acceptable values: e.q. LTE - 3 Mbits/sec; WCDMA - 350 Kbits/sec;
                                        # GSM - 80 Kbits/sec
${PROTOCOL}    udp                 # Data transfer protocol. e.q. udp, tcp, ftp
${BANDWIDTH}    60 Mbits/sec       # max bandwidth for UDP in bits; acceptable values: e.q. LTE - 60 Mbits/sec; WCDMA 10 Mbits/sec;
                                   # GSM - 200 Kbits/sec
${UE_CAPABILITIES}    None         # Label used to identify a specific UE defined in ue config (from config: CAPABILITIES)
${MBN_PROFILE}    None             # Full local path to the MBN xml profile; Only applicable in case of AT command based UEs;
                                   # Example:/home/ute/btsauto/{44234681-CCDB-4C88-BD59-BDAD3D3C4DBD}.xml
${DETACH_UE}    False              # Specify whether to dettach UE after the test execution; Possible values: True/False. Default value: False
${CHECK_ATTACH_ONLY}    False      # Flag for skipping data transfer part and perform check of attach only; Possible values: True/False.
                                   # Default value: False
${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False  # Flag used to specify if cell Data Transfer Bandwith related parameters are read from Input Arguments
                                              # (False, default value) or from CELL_TARGET_BW file (True)

*** Keywords ***
TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-25015
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  Test for performing data transfer calls based on selected TECHNO variable: WCDMA, LTE, GSM, NR based on taf.ue solution
    ...  Data Call will be done in loop for all UEs who meet specified TECHNO.
    ...
    ...  Below are described the variables that you can complete:
    ...
    ...  - TECHNO          ----  Specified standalone technology on which call will be peformed;
    ...                          Possible values: "WCDMA", "GSM", "LTE", "NR"
    ...
    ...  - BTS_CALL        ----  Specified BTS on which call will be peformed; Default value: BTS1 (Master)
    ...
    ...  - CELLS_LIST      ----  Specify the cells list on which UE will be chekced; Possible values: "DEFAULT" - means that UE is checked if it
    ...  is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list with space between Cells Id.
    ...  For WCDMA - Global Cell Id is used, for LTE -  Eutran Cell Id is used, for GSM - Cell CI is used, for NR - NRCellID is used.
    ...
    ...  - USE_ATTENUATOR  ----  Use attenuator to make call on multiple cells, one at a time. Possible Values: "YES", "NO"
    ...
    ...  - CALL_DIRECTION  ----  Direction of data transfer call; possible values: "uplink", "downlink" and "uplink_downlink"
    ...
    ...  - CALL_DURATION   ----  Duration of call in seconds
    ...
    ...  - downlink_MAX_TPUT     ----  Downlink Maximum acceptable t-put; acceptable values: e.q. LTE - 150 Mbits/sec; WCDMA - 10 Mbits/sec;
    ...                                GSM - 400 Kbits/sec
    ...
    ...  - downlink_MIN_TPUT     ----  Downlink Minmum acceptable t-put; acceptable values: e.q. LTE - 5 Mbits/sec; WCDMA - 350 Kbits/sec;
    ...                                GSM - 150 Kbits/sec
    ...
    ...  - uplink_MAX_TPUT     ----  Uplink Maximum acceptable t-put; acceptable values: e.q. LTE - 50 Mbits/sec; WCDMA - 8 Mbits/sec;
    ...                              GSM - 300 Kbits/sec
    ...
    ...  - uplink_MIN_TPUT     ----  Uplink Minimum acceptable t-put; acceptable values: e.q. LTE - 3 Mbits/sec; WCDMA - 350 Kbits/sec;
    ...                              GSM - 80 Kbits/sec
    ...
    ...  - PROTOCOL        ----  Data transfer protocol. e.q. udp, tcp, ftp
    ...
    ...  - BANDWIDTH       ----  max bandwidth for UDP in bits; acceptable values: e.q. LTE - 60 Mbits/sec; WCDMA 10 Mbits/sec; GSM - 200 Kbits/sec
    ...
    ...  - UE_CAPABILITIES ----  Label used to identify a specific UE defined in ue config (from config: CAPABILITIES)
    ...
    ...  - DETACH_UE       ----  Specify whether to dettach UE after the test execution; Possible values: True/False. Default value: False
    ...
    ...  - MBN_PROFILE     ----  Full local path to the MBN xml profile; Only applicable in case of AT command based UEs;
    ...                          Example:/home/ute/btsauto/{44234681-CCDB-4C88-BD59-BDAD3D3C4DBD}.xml
    ...
    ...  - CHECK_ATTACH_ONLY    ----  Flag for skipping data transfer part and perform check of attach only; Possible values: True/False.
    ...                         Default value: False
    ...
    ...  - IMPORT_CELL_TARGET_BW_FROM_CONFIG  ----  Flag used to specify if cell Data Transfer Bandwith related parameters are read
    ...                                       from Input Arguments (False, default value) or from CELL_TARGET_BW file (True)
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 27.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25015 - Migration to taf.ue - Robot Resource Code Refactoring +
    ...  RRM_RFS_Data_Transfer_Taf_Ue
    ...  - 01.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26030 - Include option 5G SA on multiple sectors - taf_ue
    ...  - 26.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26147 - RRM__RFS__Data_Transfer_Ute_Ue Variable '${BACKUP_SCF_PATH}' not found
    ...  - 22.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26172 - [Calls][P2]Multiple cell per sector
    ...  - 13.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26165 - [Calls][P3]Set expected T-put according to specific Min/Max Tput of each
    ...  tested cell RRM__RFS__Data_Transfer_Ute_Ue
    ...  - 31.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26824 - [Calls] RRM__RFS__Data_Transfer_Taf_Ue fails with Variable
    ...  CELL_TARGET_BW not found after delivery of TAT 26165
    ...  - 10.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26800 - [Calls] Adapt RRM__RFS__Data_Transfer_Taf_Ue to
    ...  allow SBTS_SBTS configuration
    ...  - 22.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26920 - [Calls]RRM__RFS__Data_Transfer_Taf_Ue enhancement
    ...  for cell selection attenuation order in code
    ...  - 11.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27028 -
    ...  [Calls] RRM__RFS__Data_Transfer_Taf_Ue call is failed on BTS2 slave because of ${current_cell_R_id} variable
    ...  - 22.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27394 - [Calls] Variable '${WCDMA_Count}' not found
    ...  - 10.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27448 - Refactor - Remove mechanism based on NR, LTE, WCDMA, GSM Count variables
    ...  - 19.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27717 - [Cloud][RF5] Update robotws testcases - NRL, NR_NR, NR_SBTS, RRM, PM, LOGS
    ...  - 16.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30631 - Broken interface for Get SBTS Cell Ids from admin,
    ...  Get GSM cell IDs from BSC and admin, and Get NR Cell Ids from admin keywords - update according to new interface
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-25015_RRM__RFS__Data_Transfer_Taf_Ue.png


    Set Tags    CA-RRM    OWNER-bogdan.vinereanu@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com    PHASE-CR1    SW-WBTS18, BTS18,
    ...    SBTS18    CABLING-RFS_01_UE

    Step 1: TC Parameter Check
    Step 2: Get Cells List of ${TECHNO}
    Step 3: Start data transfer based on selected TECHNO ${TECHNO}
    Step 4: Check final number and state of Cells and RMs

    [Teardown]  Particular Teardown

Step ${index}: TC Parameter Check
    Log  Step ${index}: TC Parameter Check  console=True

    ${CELL_TARGET_BW_exists}=  Run Keyword And Return Status  Variable Should Exist  ${CELL_TARGET_BW}
    Run Keyword If  not ${CELL_TARGET_BW_exists} and '${IMPORT_CELL_TARGET_BW_FROM_CONFIG}'=='True'
    ...  Fail  IMPORT_CELL_TARGET_BW_FROM_CONFIG is set to True but CELL_TARGET_BW is not found!

    ${BTS_number}=  Fetch From Right  ${BTS_CALL}  BTS
    ${BTS_count}=  Set Variable  0
    ${admin_alias}=  Set Variable  None
    FOR  ${alias}  IN  @{alias_list}
        ${BTS_count}=  Evaluate  ${BTS_count}+1
        Run Keyword If  "${BTS_number}" == "${BTS_count}"  Run Keywords
        ...  Set Test Variable  ${admin_alias}  ${alias}
        ...  AND  Exit For Loop
    END
    Run Keyword If  "${admin_alias}"=="None"  Fail  Admin alias for ${BTS_CALL} not found!
    ${admin_alias_tech}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH]

    FOR  ${this_tech}  IN  NR LTE WCDMA GSM
        Run Keyword If
        ...  ('${TECHNO.upper()}' == '${this_tech}' and '${admin_alias_tech}' not in ['${this_tech}', 'SBTS'])
        ...  Fail  Parameter TECHNO set as ${TECHNO} but ${BTS_CALL} does not have ${TECHNO} configured!
    END

Step ${index}: Get Cells List of ${TECHNO}
    Log  Step ${index}: Get Cells List of selected techno: ${TECHNO}  console=True
    ${cells_list}=  Get cells list for call  ${TECHNO}  ${CELLS_LIST}  ${admin_alias}
    Set Test Variable  ${cells_list}
    Log  ${TECHNO} cells list: ${cells_list}  console=True
    ${ue_list}=  Create List  oneSingleUe
    ${techno_str}=  Set Variable If  "${TECHNO}"=="SBTS_WCDMA"  WCDMA  ${TECHNO}
    Set Test Variable  ${${techno_str.lower()}_ues}  ${ue_list}

Step ${index}: Start data transfer based on selected TECHNO ${TECHNO}
    Log  Step ${index}: Start data transfer based on selected techno: ${TECHNO}  console=True
    ${BTS_nb}=  Get Length  ${alias_list}
    ${CALL_DIRECTION}=  Set Variable  ${CALL_DIRECTION.lower()}
    ${PROTOCOL}=  Set Variable  ${PROTOCOL.lower()}
    ${CALL_DURATION}=  Catenate  SEPARATOR=   ${CALL_DURATION}  s
    ${ue_index}=  Set Variable  1
    Run Keyword If  '${CALL_DIRECTION}' not in ['uplink', 'downlink', 'uplink_downlink']
    ...  Fail  Wrong call direction set ${CALL_DIRECTION}. Accepted values: uplink, downlink, uplink_downlink
    Translate Call Direction  ${CALL_DIRECTION}
    ${common_args_dict}=  Create Dictionary
    ...  alias=${admin_alias}
    ...  TECHNO=${TECHNO}
    ...  USE_ATTENUATOR=${USE_ATTENUATOR}
    ...  cells_list=${cells_list}
    ...  CALL_DURATION=${CALL_DURATION}
    ...  call_type=data
    ...  PROTOCOL=${PROTOCOL}
    ...  BANDWIDTH=${BANDWIDTH}
    ...  call_direction=${CALL_DIRECTION}
    ...  capabilities=${UE_CAPABILITIES}
    ...  mbn_profile=${MBN_PROFILE}
    ...  attach_only=${CHECK_ATTACH_ONLY}

    Log  Start data call for selected techno: ${TECHNO}  console=True
    ${wcdma_cell_id}=  Set Variable If  '${TECHNO.lower()}'=='wcdma'  True  False
    ${ue_alias}=  Taf Ue Perform taf ue data call with one UE on cell list  common_args_dict=${common_args_dict}
    ...  ue_index=${ue_index}  wcdma_cell_id=${wcdma_cell_id}  detach_ue=${DETACH_UE}

    Log  End data call for selected techno: ${TECHNO}  console=True

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Translate Call Direction
    [Arguments]  ${direction}
    Run KeyWord If  '${direction}' == 'uplink'  Set Test Variable  ${CALL_DIRECTION}  ul
    Run KeyWord If  '${direction}' == 'downlink'  Set Test Variable  ${CALL_DIRECTION}  dl
    Run KeyWord If  '${direction}' == 'uplink_downlink'  Set Test Variable  ${CALL_DIRECTION}  ul_dl

Particular teardown
    Run Keyword If  '${DETACH_UE}' == 'True'
    ...  Run Keyword And Return Status  Taf Ue Detach All Used UEs  timeout=300

Get cells list for call
    [Arguments]  ${TECHNO}  ${CELLS_LIST}  ${admin_alias}
    ${get_full_techno_cells_list}=  Set Variable If  '${CELLS_LIST}' == 'DEFAULT'  ${True}  ${False}
    ${full_techno_cells_list}=  Run Keyword If  '${CELLS_LIST}' != 'DEFAULT'  Split String  ${CELLS_LIST}
    Run Keyword If  not ${get_full_techno_cells_list}  Return From Keyword  ${full_techno_cells_list}
    ${BCF_ID}=  Run Keyword If  '${TECHNO.upper()}' == 'GSM'  Get From Dictionary  ${${admin_alias.upper()}}  BCF_ID
    ${CELL_ID_LIST}  ${temp_cell_id_internal_id_mapping}=  Run Keyword If  '${TECHNO.upper()}' == 'GSM'
    ...  Get GSM cell IDs from BSC and admin  ${admin_alias}  ${BCF_ID}
    Run Keyword If  '${TECHNO.upper()}' == 'GSM'  Return From Keyword  ${CELLS_LIST}
    ${CELLS_LIST}  ${temp_cell_id_internal_id_mapping}=  Run Keyword If  "${TECHNO.upper()}" in ['LTE', 'WCDMA']
    ...  Get SBTS Cell Ids from admin  ${admin_alias}  ${TECHNO.upper()}
    ...  ELSE IF  '${TECHNO.upper()}' == 'NR'  Get NR Cell Ids from admin  ${admin_alias}
    ${cell_count}=  Get Length  ${CELLS_LIST}
    Run Keyword If  ${cell_count} == 0  Run Keywords
    ...  Log  No ${TECHNO} cells are found on BTS!  level=ERROR
    ...  AND  Fail  No ${TECHNO} cells are found on ${BTS_CALL}!
    Sort list  ${CELLS_LIST}
    [Return]  ${CELLS_LIST}

TC Setup
    Run Keyword And Continue On Failure  Common Test Setup  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown
