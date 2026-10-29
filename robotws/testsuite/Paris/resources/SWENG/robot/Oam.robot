*** Settings ***
Documentation
...         == Purpose ==
...         Library to manage all OAM oriented services on Classical, CloudBTS, AIC,...
...
...         == Description ==
...         Proposed keywords will offer these services:
...         - connection/disconnection to/from specified OAM
...         - parameters modification
...         - full commissioning by applying a complete SCF
...         - get OAM info like the SCF file, the active Alarms,
...         - get crucial parameters from SCF for FDD and TDD Cells (nrCellId, cellTechnology, physCellId, cellDepType)
...
...         *Main keywords are:*
...         | OAM Set Params                      | <modify_param> | <oam>        | <timeout>              |                       |
...         | OAM Update RAD Debug Parameters     | <domain_name>  | <parameters> | <oam>                  | <persistency>         |
...         | OAM Get SCF Files                   |                |              |                        |                       |
...         | OAM Get SCF File                    | <oam>          | <dir>        | <file>                 | <timeout>             |
...         |                                     | <with_auto_configured_parameters>                      |                       |
...         | OAM Connect                         | <oam>          |              |                        |                       |
...         | OAM Disconnect                      | <oam>          |              |                        |                       |
...         | OAM Perform Full Commissioning      | <scf_file>     | <oam>        | <skip_relation_errors> |                       |
...         | OAM Get Active Alarms               | <oam>          | <textFormat> |                        |                       |
...         | OAM wait available                  | <oam>          | <wait_time>  |                        |                       |
...         | OAM Get GNB BTS Info                | <oam>          |              |                        |                       |
...         | OAM Get nrDrbDN                     | <oam>          | <callType>   | <bearerId>             |                       |
...         | OAM Get NR Cell GROUP               | <oam>          | <NRCellId>   |                        |                       |
...         | OAM Is Alarm Present                | <oam>          | <alarmId>    |                        |                       |
...         | OAM Is Fault Present                | <oam>          | <faultId>    |                        |                       |
...         | OAM Build FDD TDD Cells Dict        |                |              |                        |                       |
...         | OAM Get Parameter By Distname       | <oam>          | <dist_name>  | <parameter_list>       | <include_children>    |
...         |                                     | <timeout>      | <detailed_output> |              |                       |
...         | Download Package Using Git Update OAM    | <git_path> | <git_folder> | <git_file_name> | <target_dir> | <token_name> | <token_access> |
...
...         *Examples:*
...
...         *1. Connect to OAM and get BTS information:*
...         | OAM Connect                ${GNB_DU.oam}
...         | OAM Get GNB BTS Info       oam=${GNB_DU.oam}
...         | OAM Disconnect             ${GNB_DU.oam}
...
...         *2. Modify OAM parameter (Classical):*
...         | &{modify_param}=    Create Dictionary    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=enDcSyncStatus    value=asynchronous
...         | @{param_list}=      Create List          ${modify_param}
...         | OAM Set Params      modify_param=${param_list}    oam=${GNB_DU.oam}
...
...         *3. Get and process active alarms:*
...         | ${aliasGNB}=         OAM Connect                 ${GNB_DU.oam}
...         | ${active_alarms}=    OAM Get Active Alarms       oam=${GNB_DU.oam}    textFormat=${False}
...         | ${len}=              Get Length                  ${active_alarms}
...         | Log                  Found ${len} active alarms
...
...         *4. Perform full commissioning:*
...         | ${scf_file}=    Set Variable    /tmp/SCF_Modified.xml
...         | OAM Perform Full Commissioning    scf_file=${scf_file}    oam=${GNB_DU.oam}    skip_relation_errors=${True}
...
...         *5. Configure RAD debug parameters (Cloud AIC VDU):*
...         | @{rad_params}=       Create List
...         | ...                  ${{ {'name': 'rdFeatureFlagBitmapLevel', 'value': '4'} }}
...         | ...                  ${{ {'name': 'rdFeatureFlagBitmap4', 'value': '79'} }}
...         | ${result}=           OAM Update RAD Debug Parameters
...         | ...                  domain_name=L2PS
...         | ...                  parameters=${rad_params}
...         | ...                  oam=${GNB_DU.oam}
...         | Should Be Equal      ${result['status']}    succeeded
...
...         *6. Configure RAD debug parameters (Cloud AIC VCU):*
...         | @{rad_params}=       Create List    ${{ {'name': 'LoggingLevel', 'value': '1 - Debug'} }}
...         | ${result}=           OAM Update RAD Debug Parameters    domain_name=RLC    parameters=${rad_params}    oam=${GNB_CU.oam}
...
...         *7. Check if specific alarm is present:*
...         | ${is_present}=       OAM Is Alarm Present    alarmId=7516    oam=${GNB_DU.oam}
...         | Run Keyword If       ${is_present}           Dated Log       Alarm 7516 is active
...


Library           DateTime
Library           ../python/StringTool.py
Library           ../python/OsTool.py
Library           ../python/MultiScf.py                       WITH NAME               multiscf
Library           taf.sbts.oam.coam.admin                     WITH NAME               coam
Library           taf.gnb.oam.coam.vdu.interface.Vdu          WITH NAME               admin_du
Library           taf.gnb.oam.coam.cu.interface.cu            WITH NAME               admin_cu
Library           taf.selenium.sbts                           WITH NAME               selenium_coam
Resource          Connect.robot
Resource          Capture.robot
Resource          Restart.robot

*** Variables ***
${SCF_SETUP_PATH}                   ${EMPTY}
${SCF_DU_Max_Diff}                  8
${SCF_CU_Max_Diff}                  12
${VCU_IP}                           192.168.100.129
${VDU_IP}                           192.168.255.129

# ${VRAN_USER}                        Nemuadmin
# ${VRAN_PASS}                        nemuuser

*** Keywords ***
OAM Connect
    [Documentation]                 Connection to the OAM passed in argument.
    ...
    ...                             The keyword returns the connection Id (ex: HTTP_OamClassical_GNB_DU).
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    [Arguments]                     ${oam}
    ${return}                       Call method secure
    ...                             ${oam}                                  connect
    [Return]                        ${return}

OAM Disconnect
    [Documentation]                 Disconnection of the OAM passed in argument.
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    [Arguments]                     ${oam}
    Call method secure              ${oam}                                  disconnect

OAM Reset Site
    [Documentation]                 Reset the OAM url site whatever it is coam or megazone.
    ...                             In case of COAM : it will wait until available again.
    ...                             In case of megazone : it will wait until unvailable.
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    [Arguments]                     ${oam}
    Call method secure              ${oam}                                  startReset
    csn.reset_cache

OAM Wait Site Available
    [Documentation]                 Call a callback, then wait until the OAM url site is detected as available.
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    ...                              - callback : To Be Completed by the KW author.
    [Arguments]                     ${oam}
    ...                             ${callback}=None
    Call method secure              ${oam}                                  waitSiteAvailable
    Run Keyword if                  '${callback}'!='None'                   ${callback}

OAM Software Update
    [Documentation]                 Call a callback, then wait until the OAM url site is detected as available.
    ...
    ...                             The keyword returns True if software update was OK, else False.
    ...
    ...                             *Argument details:*
    ...                              - sw_package : Full Pathname to software package
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam})
    ...                              - should_activate : must be set to true
    ...                                                  for external devices/RFM plugin module/BSR/O-Ru SW update/Independent RU SW update
    ...                              - timeout : Time to wait for positive procedure result
    [Arguments]                     ${sw_package}
    ...                             ${oam}=${GNB_DU.oam}
    ...                             ${should_activate}=${True}
    ...                             ${timeout}=600
    ${result}                       Call method                 ${oam}      softwareUpdate
    ...                             sw_package=${sw_package}    should_activate=${should_activate}    timeout=${timeout}
    ${isUpdateOK}                   Set Variable if             '${result}'=='Software update has been completed'       ${True}     ${False}
    Should Be True                  ${isUpdateOK}               msg=ERROR - OAM Software Update Failed: ${result}
    [Return]                        ${result}

#===================================
# OAM Get Info
#===================================
OAM Get GNB BTS Info
    [Documentation]                 Get BTS info from the OAM passed in argument.
    ...                             <MRBTS_ID> and <NRCELL_DIST_NAME> are extracted/computed.
    ...                             Following variables are then build and declared as global variables:
    ...                             GNB_BTS_INFO, MRBTS_ID, NRCELL_DIST_NAME, NRBTS_ID and NRCELL_GRP.
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    [Arguments]                     ${oam}
    Call method secure              ${oam}                                  getBtsInfo

OAM Get Active Alarms
    [Documentation]                 Get Active alarms from the OAM passed in argument.
    ...
    ...                             Depending the textFormat argument, the keyword returns alarms either as a dictionary or as a text.
    ...                             Default is dictionary format.
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    ...                              - textFormat : If not set or set to false, the dictionary format will be used.
    ...                                If set to true, the text format is used.
    [Arguments]                     ${oam}=${GNB_DU.oam}
    ...                             ${textFormat}=${True}
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  getActiveAlarms
    ...                             textFormat=${textFormat}
    [Return]                        ${return}

OAM Get Snapshot
    [Documentation]                 Get Snapshot from the OAM passed in argument.
    ...
    ...                             The keyword returns the generated and renamed snapshot based on the input parameters.
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    ...                              - prefix : Allow to add a prefix to the snapshot filename (ex: SNAPSHOT_GNB).
    ...                              - isTimeStamped : Add or not a "%Y%m%d_%H%M%S" timestamp (ex: ${True}).
    ...                              - timeout : Max delay allowed for snapshot generation. Unit is seconds
    [Arguments]                     ${oam}=${GNB_DU.oam}
    ...                             ${prefix}=SNAPSHOT_GNB
    ...                             ${isTimeStamped}=${True}
    ...                             ${timeout}=3600
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  getSnapshot
    ...                             path=${LOG_PATH}                        prefix=${prefix}
    ...                             isTimeStamped=${isTimeStamped}          timeout=${timeout}
    [Return]                        ${return}

OAM Get Cells Nr
    [Documentation]                 INTERNAL USAGE
    ...                             Get BTS cells NR array from OAM passed in argument
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    [Arguments]                     ${oam}
    @{cellsNr}                      Call method secure                      ${oam}              getCellsNr
    [return]                        ${cellsNr}

OAM Get SW Version
    [Documentation]                 INTERNAL USAGE
    ...                             Get SW version from the OAM passed in argument
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    [Arguments]                     ${oam}
    ${return}                       Call method secure
    ...                             ${oam}                                  getSWVersion
    [Return]                        ${return}

OAM Get nrDrbDN
    [Documentation]                 Dedicated KW to get the nrDrbDN value.
    ...
    ...                             It first parse all the "NRDRB_5QI-x" or "NRDRB_QCI-x" objects.
    ...
    ...                             Then it check the one including the expected QCI in fiveqiValueList or qciValueList.
    ...
    ...                             If found, return the nrDrbDN parameter, otherwise return None.
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}), default: ${GNB_DU.oam}
    ...                              - callType: NSA or SA, default: NSA
    ...                              - bearerId: expected bearer Id, default: 9
    ...
    ...                             *Returned value:*
    ...                              - the nrDrbDN value if found. Otherwise return None
    [Arguments]                     ${oam}=${GNB_DU.oam}
    ...                             ${callType}=NSA
    ...                             ${bearerId}=9
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  getNrDrbDn
    ...                             call_type=${callType}                   bearer_id=${bearerId}
    [Return]                        ${return}

OAM Get NR Cell GROUP
    [Documentation]                 Dedicated KW to get the NR Cell Group associated to a cell Id.
    ...
    ...                             It first parse all the "NRCELLGRP" objects.
    ...
    ...                             Then it check the one including the expected cell Id in nrCellList.
    ...
    ...                             If found, return the distname of the NRCELLGRP, otherwise return None.
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}) default: ${GNB_DU.oam}
    ...                              - NRCellId: expected cell Id, default: 1
    ...
    ...                             *Returned value:*
    ...                              - the NRCELLGRP distname if found. Otherwise return None
    [Arguments]                     ${oam}=${GNB_DU.oam}
    ...                             ${NRCellId}=1
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  getNrCellGrp
    ...                             nr_cell_id=${NRCellId}
    [Return]                        ${return}

OAM Is Alarm Present
    [Documentation]                 Return True if specified alarmId is present. Otherwise, return False.
    ...                             * Note :* This KW is not designed for VRAN.
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    ...                              - Alarm Id : example: 7516
    ...
    ...                             *Returned value:*
    ...                              - Return ${EMPTY} if oam is unkown.
    ...                              - Return True if alarm Id is found, otherwise return False
    [Arguments]                     ${alarmId}
    ...                             ${oam}=${GNB_DU.oam}
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  isItemValuePresentInItemName
    ...                             item_name=alarmId                       item_value=${alarmId}
    [Return]                        ${return}

OAM Is Fault Present
    [Documentation]                 Return True if specified faultId is present. Otherwise, return False.
    ...                             * Note :* This KW is not designed for VRAN.
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    ...                              - faultId : example: 4655
    ...
    ...                             *Returned value:*
    ...                              - Return ${EMPTY} if oam is unkown.
    ...                              - Return True if alarm Id is found, otherwise return False
    [Arguments]                     ${faultId}
    ...                             ${oam}=${GNB_DU.oam}
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  isItemValuePresentInItemName
    ...                             item_name=faultId                       item_value=${faultId}
    [Return]                        ${return}


OAM Build FDD TDD Cells Dict
    [Documentation]                 Create the TDD and FDD Cells Lists
    ...
    ...                             The keyword creates 2 lists: the TDD_Cell_list and the FDD_Cell_list.
    ...                             Each list contains dictionaries with following keys: physCellId, cellDepType and nrCellId
    ...                             Example:
    ...                             TDD_Cell_list[0] = {'physCellId':'50', 'cellDepType': 'SA+NSA', 'nrCellId', '1'}
    ...                             TDD_Cell_list[1] = {'physCellId':'51', 'cellDepType': 'SA+NSA', 'nrCellId', '2'}
    ...
    ...                             FDD_Cell_list[0] = {'physCellId':'52', 'cellDepType': 'SA+NSA', 'nrCellId', '3'}
    ...                             FDD_Cell_list[1] = {'physCellId':'53', 'cellDepType': 'SA+NSA', 'nrCellId', '4'}
    ...
    ...                             *Argument details:*
    ...                              - no argument

    # As the SCF file may have been modified, we have to rebuild some global variables created during "Suite Setup".
    # This especially concerns the TNRCELL_NB and TNRCELL_NB_DU, variable which will be used to parse the SCF file
#    ${aliasGNB}                     OAM Connect                             ${GNB_DU.oam}
    OAM Connect                     ${GNB_DU.oam}
    OAM Get GNB BTS Info            oam=${GNB_DU.oam}
    OAM Disconnect                  ${GNB_DU.oam}
    # Explore the SCF to obtain info about FDD and TDD Cells
    OAM Get Info From SCF
    # Now show lists content
    OAM Show FDD and TDD cell lists


OAM Get Info From SCF
    [Documentation]                 INTERNAL USAGE.
    ...                             Create and fill the TDD and FDD cells lists.
    ...                             Create and fill the SA/NSA/SANSA cells dictionary.
    @{TDD_Cell_list}                Create List
    @{FDD_Cell_list}                Create List
    @{TDD_SA_Cell_list}             Create List
    @{TDD_NSA_Cell_list}            Create List
    @{FDD_SA_Cell_list}             Create List
    @{FDD_NSA_Cell_list}            Create List
    &{SA_Cell_Dict}                 Create Dictionary

    ${TDD_Cell_nb}                  set Variable                        ${0}
    ${FDD_Cell_nb}                  set Variable                        ${0}
    ${TDD_SA_Cell_nb}               set Variable                        ${0}
    ${TDD_NSA_Cell_nb}              set Variable                        ${0}
    ${FDD_SA_Cell_nb}               set Variable                        ${0}
    ${FDD_NSA_Cell_nb}              set Variable                        ${0}

    StringTool.printLineWithTitle   title=OAM Get Info From SCF
    ${temp_scf_file}                OAM Get SCF File                    dir=${LOG_PATH}         file=SCF_temporaire.xml
    Set Suite Variable              ${temp_scf_file}
    ${current_scf_fullname}         set Variable                        ${temp_scf_file}
    multiscf.load_scf               ${current_scf_fullname}

    StringTool.printLineWithTitle   title=Get SCF Cells Ids
    ${tnrcell_name}                 set variable if                     ${isAic}                TNRCELL_ID_LIST_DU[0]       TNRCELL_ID_LIST[0]
    ${tnrcell_data}                 set variable if                     ${isAic}                ${TNRCELL_ID_LIST_DU[0]}    ${TNRCELL_ID_LIST[0]}
    ${msg_display}=                 StringTool.getHeaderLine            ${tnrcell_name}         ${tnrcell_data}
    dated log                       ${msg_display}
    FOR  ${cell_id}  IN  @{tnrcell_data}
        Run keyword if              '${cell_id}'=='None'                Continue For Loop
        # Get Cell data:
        ${dist_name}                set variable                        MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ${cellTechnology}=          OAM Get Param From Any Of SCF       param=cellTechnology
        ...                                                             current_scf=${temp_scf_file}    dist_name=${dist_name}
        ${physCellId}=              OAM Get Param From Any Of SCF       param=physCellId
        ...                                                             current_scf=${temp_scf_file}    dist_name=${dist_name}
        ${cellDepType}=             OAM Get Param From Any Of SCF       param=cellDepType
        ...                                                             current_scf=${temp_scf_file}    dist_name=${dist_name}
        # Create a Dict with cell data:
        &{cell_info}                Create Dictionary                   nrCellId=${cell_id}
        ...                                                             cellTechnology=${cellTechnology}
        ...                                                             physCellId=${physCellId}
        ...                                                             cellDepType=${cellDepType}
        # Add the new created cell_info dictionary to the FDD or TDD list:
        Run Keyword If              '${cellTechnology}'=='TDD'          Append To List          ${TDD_Cell_list}    ${cell_info}
        Run Keyword If              '${cellTechnology}'=='FDD'          Append To List          ${FDD_Cell_list}    ${cell_info}
        # Add the cell_id info into the dedicated list: SA or NSA and TDD or FDD
        Run Keyword If              ('${cellTechnology}'=='TDD') and ('${cellDepType}'=='NSA' or '${cellDepType}'=='SA+NSA')
        ...                                                             Append To List          ${TDD_NSA_Cell_list}    ${cell_id}
        Run Keyword If              ('${cellTechnology}'=='TDD') and ('${cellDepType}'=='SA' or '${cellDepType}'=='SA+NSA')
        ...                                                             Append To List          ${TDD_SA_Cell_list}     ${cell_id}
        Run Keyword If              ('${cellTechnology}'=='FDD') and ('${cellDepType}'=='NSA' or '${cellDepType}'=='SA+NSA')
        ...                                                             Append To List          ${FDD_NSA_Cell_list}    ${cell_id}
        Run Keyword If              ('${cellTechnology}'=='FDD') and ('${cellDepType}'=='SA' or '${cellDepType}'=='SA+NSA')
        ...                                                             Append To List          ${FDD_SA_Cell_list}     ${cell_id}
        # Update the SA cell dictionary which will be used later to determine if a SA cell is blocked state or not
        Run Keyword If              '${cellDepType}'=='NSA'             Set To Dictionary       ${SA_Cell_Dict}     NRCELL-${cell_id}=${False}
        ...         ELSE                                                Set To Dictionary       ${SA_Cell_Dict}     NRCELL-${cell_id}=${True}
    END

    ${TDD_Cell_nb}                  get length                          ${TDD_Cell_list}
    ${FDD_Cell_nb}                  get length                          ${FDD_Cell_list}
    ${TDD_SA_Cell_nb}               get length                          ${TDD_SA_Cell_list}
    ${TDD_NSA_Cell_nb}              get length                          ${TDD_NSA_Cell_list}
    ${FDD_SA_Cell_nb}               get length                          ${FDD_SA_Cell_list}
    ${FDD_NSA_Cell_nb}              get length                          ${FDD_NSA_Cell_list}

    # Export all variables:
    Set Suite Variable              ${TDD_Cell_list}
    Set Suite Variable              ${FDD_Cell_list}
    Set Suite Variable              ${TDD_SA_Cell_list}
    Set Suite Variable              ${TDD_NSA_Cell_list}
    Set Suite Variable              ${FDD_SA_Cell_list}
    Set Suite Variable              ${FDD_NSA_Cell_list}
    Set Suite Variable              ${SA_Cell_Dict}
    Set Suite Variable              ${TDD_Cell_nb}
    Set Suite Variable              ${FDD_Cell_nb}
    Set Suite Variable              ${TDD_SA_Cell_nb}
    Set Suite Variable              ${TDD_NSA_Cell_nb}
    Set Suite Variable              ${FDD_SA_Cell_nb}
    Set Suite Variable              ${FDD_NSA_Cell_nb}
    StringTool.printLineWithTitle   title=-
    # local cleanup:
    run                             rm -f ${temp_scf_file}


OAM Get Param From Any Of SCF
    [Documentation]                 Get the value of the specified dist name parameter from any of SCF
    [Arguments]                     ${param}
    ...                             ${dist_name}
    ...                             ${current_scf}
    multiscf.load_scf               ${current_scf}
    # Get value from SCF:
    ${scope}                        set variable if                     ${isAic}    Aic     Classical
    ${param_value}                  multiscf.get_value_from_scf         p_name=${param}
    ...                                                                 dist_name=${dist_name}
    ...                                                                 scope=${scope}
    [return]                        ${param_value}


OAM Show FDD and TDD cell lists
    [Documentation]                 INTERNAL USAGE.
    ...                             Display the content of TDD and FDD lists.
    StringTool.printLineWithTitle   title=Show FDD and TDD cell lists
    OAM Display FDD or TDD List     cellType=TDD                        cellNb=${TDD_Cell_nb}
    OAM Display FDD or TDD List     cellType=FDD                        cellNb=${FDD_Cell_nb}
    StringTool.printLineWithTitle   title=-


OAM Display FDD or TDD List
    [Documentation]                 INTERNAL USAGE.
    ...                             Display the content of TDD or FDD lists.
    [Arguments]                     ${cellType}     ${cellNb}
    ${msg_display}=                 StringTool.getHeaderLine            ${cellType}_Cell_nb                  ${${cellType}_Cell_nb}
    dated log                       ${msg_display}
    FOR  ${item}  IN RANGE  ${cellNb}
        ${msg_display}=             StringTool.getHeaderLine            ${cellType}_Cell_list[${item}]      ${${cellType}_Cell_list[${item}]}
        dated log                   ${msg_display}
    END


OAM Number of Blocked Unblocked Cells
    [Documentation]                 INTERNAL USAGE.
    ...                             Get the number of blocked cells and the number of unblocked cells.
    ...                             * Note :* This KW is designed ONLY for CLASSICAL BTS.
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${TGNB_DU[0].oam}).
    ...
    ...                             *Returned value:*
    ...                              - Return ${EMPTY} if oam is unkown.
    ...                              - Return the number of blocked cells and the number of unblocked cells.
    [Arguments]                     ${oam}=${TGNB_DU[0].oam}
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${NbrCellBlocked}               set variable                            ${0}
    ${NbrCellUnblocked}             set variable                            ${0}
    ${NbrSACellBlocked}             set variable                            ${0}
    ${NbrSACellUnblocked}           set variable                            ${0}
    # Get cells status:
    StringTool.printLineWithTitle   title=Show Blocked-Unblocked Cells
    ${cmd}                          Set Variable                            get_cells_info
    ${cells_info}                   SBTS OAM Run Command                    oam=${oam}      cmd=${cmd}
    ${nbr_cell}=                    Get length                              ${cells_info}
    ${msg_display}=                 StringTool.getHeaderLine                Total Number of Cells               ${nbr_cell}
    dated log                       ${msg_display}
    # Number of unblocked cells:
    FOR  ${elem}  IN  @{cells_info}
        ${cell_name}                get from dictionary                     ${elem}    globalCellId
        &{cell_status}              get from dictionary                     ${elem}    status
        ${msg_display}=             StringTool.getHeaderLine                NRCELL-${cell_name}                 ${cell_status['blockingState']}
        dated log                   ${msg_display}
        ${status}                   run Keyword and return status           Dictionary should contain item      ${cell_status}
        ...                                                                                                     blockingState
        ...                                                                                                     Unblocked
        ${NbrCellUnblocked}         run Keyword if                          '${status}'=='True'
        ...                                                                 Evaluate                            ${NbrCellUnblocked}+${1}
        ...                                     ELSE                        set variable                        ${NbrCellUnblocked}
        # Check if Cell is SA or not:
        ${isSaOrNot}                Is Cell a SA cell or Not                NRCELL-${cell_name}
        # If Cell is SA and unblocked, then increment the NbrSACellUnblocked
        ${NbrSACellUnblocked}       run Keyword if                          '${status}'=='True' and '${isSaOrNot}'=='True'
        ...                                                                 Evaluate                            ${NbrSACellUnblocked}+${1}
        ...                                     ELSE                        set variable                        ${NbrSACellUnblocked}
    END
    # Number of blocked cells:
    FOR    ${elem}    IN    @{cells_info}
        &{cell_status}              get from dictionary                     ${elem}    status
        ${status}                   run Keyword and return status           Dictionary should contain item      ${cell_status}
        ...                                                                                                     blockingState
        ...                                                                                                     Blocked
        ${NbrCellBlocked}           run Keyword if                          '${status}'=='True'
        ...                                                                 Evaluate                            ${NbrCellBlocked}+${1}
        ...                                     ELSE                        set variable                        ${NbrCellBlocked}
        # Check if Cell is SA or not:
        ${isSaOrNot}                Is Cell a SA cell or Not                NRCELL-${cell_name}
        # If Cell is SA and blocked, then increment the NbrSACellBlocked
        ${NbrSACellBlocked}         run Keyword if                          '${status}'=='True' and '${isSaOrNot}'=='True'
        ...                                                                 Evaluate                            ${NbrSACellBlocked}+${1}
        ...                                     ELSE                        set variable                        ${NbrSACellBlocked}
    END
    ${msg_display}=                 StringTool.getHeaderLine                Number of Blocked Cell(s)           ${NbrCellBlocked}
    dated log                       ${msg_display}
    ${msg_display}=                 StringTool.getHeaderLine                Number of Blocked SA Cell(s)        ${NbrCellBlocked}
    dated log                       ${msg_display}
    ${msg_display}=                 StringTool.getHeaderLine                Number of UnBlocked Cell(s)         ${NbrCellUnblocked}
    dated log                       ${msg_display}
    ${msg_display}=                 StringTool.getHeaderLine                Number of UnBlocked SA Cell(s)      ${NbrSACellUnblocked}
    dated log                       ${msg_display}
    StringTool.printLineWithTitle   title=-
    [return]                        ${NbrSACellUnblocked}                   ${NbrCellUnblocked}
    [teardown]                      OAM Disconnect                          oam=${TGNB_DU[${0}].oam}


OAM Number of Blocked Unblocked Cells VRAN
    [Documentation]                 INTERNAL USAGE.
    ...                             Get the number of blocked cells and the number of unblocked cells.
    ...                             * Note :* This KW is designed ONLY for VRAN.
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    ...
    ...                             *Returned value:*
    ...                              - Return ${EMPTY} if oam is unkown.
    ...                              - Return the number of blocked cells and the number of unblocked cells.
    [Arguments]                     ${oam}=${TGNB_DU[0].oam}
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${NbrCellBlocked}               set variable                            ${0}
    ${NbrCellUnblocked}             set variable                            ${0}
    ${NbrSACellBlocked}             set variable                            ${0}
    ${NbrSACellUnblocked}           set variable                            ${0}
    # Get cells status:
    StringTool.printLineWithTitle   title=Show Blocked-Unblocked Cells
    ${cmd}                          Set Variable                            get_vdu_cells_status
    ${cells_info}                   OAM Run Command                         oam=${oam}      cmd=${cmd}
    ${nbr_cell}=                    Get length                              ${cells_info}
    ${msg_display}=                 StringTool.getHeaderLine                Total Number of Cells               ${nbr_cell}
    dated log                       ${msg_display}
    # Get the number of blocked/unblocked cells:
    FOR  ${cell}  IN  @{cells_info}
        ${cell_name}                Set Variable                            ${cell['name']}
        ${cell_status}              Set Variable                            ${cell['blocking_state']}
        ${msg_display}=             StringTool.getHeaderLine                ${cell_name}                        ${cell_status}
        dated log                   ${msg_display}
        ${NbrCellUnblocked}         run Keyword if                          '${cell_status}'=='Unblocked'
        ...                                                                 Evaluate            ${NbrCellUnblocked}+${1}
        ...                                     ELSE                        set variable        ${NbrCellUnblocked}
        ${NbrCellBlocked}           run Keyword if                          '${cell_status}'=='Blocked'
        ...                                                                 Evaluate            ${NbrCellBlocked}+${1}
        ...                                     ELSE                        set variable        ${NbrCellBlocked}
        # Check if Cell is SA or not:
        ${isSaOrNot}            Is Cell a SA cell or Not                    ${cell_name}
        # If Cell is SA and unblocked, then increment the NbrSACellUnblocked
        ${NbrSACellUnblocked}       run Keyword if                          '${cell_status}'=='Unblocked' and '${isSaOrNot}'=='True'
        ...                                                                 Evaluate            ${NbrSACellUnblocked}+${1}
        ...                                     ELSE                        Set Variable        ${NbrSACellUnblocked}
        ${NbrSACellBlocked}         run Keyword if                          '${cell_status}'=='Blocked' and '${isSaOrNot}'=='True'
        ...                                                                 Evaluate            ${NbrSACellBlocked}+${1}
        ...                                     ELSE                        Set Variable        ${NbrSACellBlocked}

    END
    ${msg_display}=                 StringTool.getHeaderLine                Number of Blocked Cell(s)           ${NbrCellBlocked}
    dated log                       ${msg_display}
    ${msg_display}=                 StringTool.getHeaderLine                Number of Blocked SA Cell(s)        ${NbrCellBlocked}
    dated log                       ${msg_display}
    ${msg_display}=                 StringTool.getHeaderLine                Number of UnBlocked Cell(s)         ${NbrCellUnblocked}
    dated log                       ${msg_display}
    ${msg_display}=                 StringTool.getHeaderLine                Number of UnBlocked SA Cell(s)      ${NbrSACellUnblocked}
    dated log                       ${msg_display}
    StringTool.printLineWithTitle   title=-
    [return]                        ${NbrSACellUnblocked}                   ${NbrCellUnblocked}
    [teardown]                      OAM Disconnect                          oam=${TGNB_DU[${0}].oam}


Is Cell a SA cell or Not
    [Documentation]                 INTERNAL USAGE.
    ...                             Return True if the cell type is SA or SA+NSA.
    [Arguments]                     ${cellId}
    # First, we process the error cases:
    ${IsKeyExist}                   run keyword and return status
    ...                             Dictionary should contain key       ${SA_Cell_Dict}     ${cellId}
    Should Be True                  ${IsKeyExist}                       msg=ERROR - THE KEY "${cellId}" DOES NOT EXIST!!
    # No imagined error detected, we can read the dictionary:
    return from keyword             ${SA_Cell_Dict}[${cellId}]

OAM Get Parameter By Distname
    [Documentation]                 Get Parameter By Distname from the OAM passed in argument.
    ...
    ...                             Depending the arguments, the keyword returns values as a dictionary.
    ...                             Default is dictionary format.
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    ...                              - dist_name : Distname where to get parameters (ex: MRBTS-1/NRBTS-1/NRCELL-1).
    ...                              - parameter_list : List of parameters to get (ex: ['adminState', 'operState']).
    ...                              - include_children : If set to True, parameters from children objects are included.
    ...                              - timeout : Max delay allowed for operation. Unit is seconds
    ...                              - detailed_output : If set to True, additional information is provided in the output
    ...                                such as parameter source, timestamp, etc.
    ...                          *Returned value:*
    ...                              - Return ${EMPTY} if oam is unkown.
    ...                              - Return a dictionary with the requested parameters and their values.
    [Arguments]                     ${oam}=${GNB_DU.oam}
    ...                             ${dist_name}=${EMPTY}
    ...                             ${parameter_list}=${EMPTY}
    ...                             ${include_children}=${False}
    ...                             ${timeout}=30
    ...                             ${detailed_output}=${False}
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  getParameterByDistname
    ...                             dist_name=${dist_name}
    ...                             parameter_list=${parameter_list}
    ...                             include_children=${include_children}
    ...                             timeout=${timeout}
    ...                             detailed_output=${detailed_output}
    [Return]                        ${return}

#===================================
# Modify PARAMETERS
#===================================
OAM Cell Lock
    [Documentation]                 Lock or Unlock the cell depending the state required.
    ...                             Action done through Selenium TAF library
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    ...                              - state : Lock or unlock the cell (ex: LOCK).
    ...                              - cell_id : the identity of the cell to be locked/unlocked (ex: 1).
    [Arguments]                     ${oam}=${GNB_DU.oam}
    ...                             ${state}=LOCK
    ...                             ${cell_id}=${EMPTY}
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  cellLock
    ...                             state=${state}                          cell_id=${cell_id}
    [Return]                        ${return}

OAM Validate SCF Online
    [Arguments]                     ${scf_file}
    ...                             ${oam}=${GNB_DU.oam}
    ...                             ${skip_relation_errors}=${True}
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  validateScfOnline
    ...                             scf_file=${scf_file}                    skip_relation_errors=${skip_relation_errors}
    csn.reset_cache
    [Return]                        ${return}

OAM Perform Full Commissioning
    [Documentation]                 Execute full commissioning of the OAM with the SCF set in arguments.
    ...
    ...                             The keyword returns the Commissioning status (completed, ongoing or failed)
    ...
    ...                             *Argument details:*
    ...                              - scf_file : xml file to be applyed on OAM.
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    ...                              - skip_relation_errors : Allow to ignore the relation errors generated by the SCF validation.
    [Arguments]                     ${scf_file}
    ...                             ${oam}=${GNB_DU.oam}
    ...                             ${skip_relation_errors}=True
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  fullCommissioning
    ...                             scf_file=${scf_file}                    skip_relation_errors=${skip_relation_errors}
    csn.reset_cache
    [Return]                        ${return}

OAM Perform Object Recommissioning AIC
    [Arguments]                     ${dist_name}
    ...                             ${parameter}
    ...                             ${oam}=${TGNB_DU[0].oam}
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  perform_object_recommissioning
    ...                             dist_name=${dist_name}
    ...                             parameter=${parameter}
    ...                             operation=update
    ...                             should_activate=${True}
    ...                             timeout=300
    [Return]                        ${return}

Oam Set Params AIC
    [Documentation]                 Set Params for AIC. Accept classical param dict syntax with nodeType param as below,
    ...                             then launch "OAM Set Params" on the specified nodes.
    ...                             [{'parameter': 'param1', 'dist_name': 'xxx-1', 'value': 12, 'nodeType': 'Vdu'}, {}, ...]
    ...
    ...                             *Argument details:*
    ...                              - modify_param : List of dictionaries like:
    ...                              [{'parameter': 'param1', 'dist_name': 'xxx-1', 'value': 12, 'nodeType': 'Vdu'}, {}, ...]
    ...                              - timeout : Max delay allowed for operation. Unit is seconds
    ...                             *Returned value:*
    ...                              - For VDU and VCU, return their respective commissioning status (completed, ongoing or failed)
    [Arguments]                     ${modify_param}
    ...                             ${timeout}=${600}
    ${first_dict}      ${second_dict}      Translate Dict     modify_param=${modify_param}    isAIC=${isAIC}

    # Classical case
    IF    not ${isAIC}
                            OAM Set Params    modify_param=${first_dict}    timeout=${timeout}
                            Return From Keyword
    END

    # Error case
    run keyword if    ${second_dict} is None and ${first_dict} is None    FAIL    No param to modify! Check please!

    # AIC case
    ${VDUret}    run keyword if   ${first_dict} is not None    OAM Set Params   modify_param=${first_dict}    timeout=${timeout}
    ${VCUret}    run keyword if   ${second_dict} is not None   OAM Set Params   oam=${GNB_CU.oam}   modify_param=${second_dict}   timeout=${timeout}
    [Return]                      ${VDUret}    ${VCUret}

OAM Set Params
    [Documentation]                 Modify some parameters in the database of the OAM set in arguments.
    ...
    ...                             The keyword returns the Commissioning status (completed, ongoing or failed)
    ...
    ...                             *Argument details:*
    ...                              - modify_param : List of dictionaries like:
    ...                              [{'parameter': 'enDcSyncStatus', 'dist_name': 'MRBTS-1/NRBTS-1/NRCELL-1', 'value': 'asynchronous'}, {}, ...]
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    ...                              - timeout : Max delay allowed for operation. Unit is seconds
    [Arguments]                     ${modify_param}
    ...                             ${oam}=${GNB_DU.oam}
    ...                             ${timeout}=${600}
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  setParams
    ...                             modify_param=${modify_param}
    ...                             timeout=${timeout}
    [Return]                        ${return}

OAM Update RAD Debug Parameters
    [Documentation]                 Configure RAD debug parameters on Cloud RAN VDU or VCU with persistent storage.
    ...
    ...                             This keyword allows dynamic configuration of RAD parameters on the VDU or VCU entity,
    ...                             with automatic domain reload to apply changes. The configuration is persistent
    ...                             and survives reboot.
    ...
    ...                             *Workflow:*
    ...                              1. Reload all RAD domains
    ...                              2. Reload parameters for specified domain
    ...                              3. Update RAD debug parameters
    ...                              4. Reload domains to apply changes
    ...                              5. Final parameter reload
    ...
    ...                             The keyword returns the final operation result dictionary with status.
    ...
    ...                             *Argument details:*
    ...                              - domain_name : RAD domain name (e.g., 'L2PS', 'RLC', 'MAC', 'PDCP')
    ...                              - parameters : List of parameter dictionaries with 'name' and 'value' keys
    ...                                            Example: [{'name': 'rdFeatureFlagBitmapLevel', 'value': '4'},
    ...                                                     {'name': 'rdFeatureFlagBitmap4', 'value': '79'}]
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}). Works with Cloud AIC DU and CU.
    ...                              - persistency : 'persistent' or 'non-persistent' (default: 'persistent')
    ...                              - timeout : Max delay allowed for operation. Unit is seconds (default: 300)
    ...
    ...                             *Example for VDU:*
    ...                              | # Configure L2PS domain RAD parameters for RIM feature debugging
    ...                              | @{rad_params}=    Create List
    ...                              | ...    ${{ {'name': 'rdFeatureFlagBitmapLevel', 'value': '4'} }}
    ...                              | ...    ${{ {'name': 'rdFeatureFlagBitmap4', 'value': '79'} }}
    ...                              | ${result}=    OAM Update RAD Debug Parameters
    ...                              | ...    domain_name=L2PS
    ...                              | ...    parameters=${rad_params}
    ...                              | ...    oam=${GNB_DU.oam}
    ...                              | Should Be Equal    ${result['status']}    succeeded
    ...
    ...                             *Example for VCU:*
    ...                              | # Configure RLC domain RAD parameters on VCU
    ...                              | @{rad_params}=    Create List
    ...                              | ...    ${{ {'name': 'LoggingLevel', 'value': '1 - Debug'} }}
    ...                              | ${result}=    OAM Update RAD Debug Parameters
    ...                              | ...    domain_name=RLC
    ...                              | ...    parameters=${rad_params}
    ...                              | ...    oam=${GNB_CU.oam}
    ...                              | Should Be Equal    ${result['status']}    succeeded
    ...
    ...                             *Notes:*
    ...                              - Only applicable to Cloud AIC DU and Cloud AIC CU architectures
    ...                              - Verify results via WebEM interface or container syslog traces
    ...                              - RAD parameter changes take effect after the reload sequence completes
    [Arguments]                     ${domain_name}
    ...                             ${parameters}
    ...                             ${oam}=${GNB_DU.oam}
    ...                             ${persistency}=persistent
    ...                             ${timeout}=${300}
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  radReloadDomains
    ...                             timeout=${timeout}
    ${return}                       Call method
    ...                             ${oam}                                  radReloadParams
    ...                             domain_name=${domain_name}
    ...                             timeout=${timeout}
    ${return}                       Call method
    ...                             ${oam}                                  updateRadDebugParams
    ...                             domain_name=${domain_name}
    ...                             parameters=${parameters}
    ...                             persistency=${persistency}
    ...                             timeout=${timeout}
    ${return}                       Call method
    ...                             ${oam}                                  radReloadDomains
    ...                             timeout=${timeout}
    ${return}                       Call method
    ...                             ${oam}                                  radReloadParams
    ...                             domain_name=${domain_name}
    ...                             timeout=${timeout}
    [Return]                        ${return}

OAM Change String in SCF
    [Documentation]                 Modifies all occurences of a string in the SCF file that is not a parameter/object.
    ...                             The original SCF file is not modified. A new SCF file is created and named scfmodified.xml.
    ...
    ...                             The keyword returns the path to the new created SCF file.
    ...
    ...                             Note:
    ...
    ...                             Generally it is recommended to use OAM Set Params method in here.
    ...                             If no alternative then use this method:
    ...
    ...                             You want to change all "MRBTS-1/NRBTS-1/" into "MRBTS-1/NRBTS-2/", then do this:
    ...                             | modifiedScfPath \ \ \ OAM Change String in SCF \ \ \ oldVal=MRBTS-1/NRBTS-1 \ \ \ newVal=MRBTS-1/NRBTS-2
    ...
    ...                             *Argument details:*
    ...                              - oldVal : string to be searched and replaced.
    ...                              - newVal : new value for the found string.
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    [Arguments]                     ${oldVal}
    ...                             ${newVal}
    ...                             ${oam}=${GNB_DU.oam}
    ${scf}                          OAM Get SCF File
    Dated Log                       Modification of SCF without applying it: scfmodified.xml
    ${scfModified}                  Call method
    ...                             ${oam}                                  changeStringInScf
    ...                             scfFilePath=${scf}        oldVal=${oldVal}            newVal=${newVal}
    return from keyword if          '${scfModified}'=='None'
    [Return]                        ${scfModified}


# ====================================================================================================================
# MODIFY THE vCU PARAMETERS THROUGH DELTA JSON METHOD
# ====================================================================================================================
OAM Send CU delta commissioning
    [Arguments]                     ${input_filepath}
    Log to console                  Sending vCU Delta Commissioning
    Wait Until Keyword Succeeds     5min  30s       admin_cu.Connect to     host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...                                                                     port=${tl.gnbs[0].cu.oam_http_connection_details.port}
    ...                                                                     username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                                                                     password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...                                                                     secure=True
    ${json_file_content}            OperatingSystem.Get File                ${input_filepath}
    @{delta_json_list}              multiscf.convert_to_list_from_json_string       ${json_file_content}
    ${delta_plan_list}              admin_cu.get_delta_plan_list
    Run Keyword If                  ${delta_plan_list}                      admin_cu.delete_delta_plan      ${delta_plan_list[0]['plan_id']}
    ${delta_res}=                   admin_cu.Generate delta plan            plan_name=DELTA-PLAN-1
    ${plan_id}                      Set variable                            ${delta_res['plan_id']}
    Wait until keyword succeeds     3x  2s
    ...                             Check if delta plan was created on CU   ${delta_res['action_id']}
    FOR  ${moc_dict}  IN  @{delta_json_list}
        ${mo_parameters}=           Run Keyword And Ignore Error            admin_cu.get_parameters    dist_name=${moc_dict["distName"]}
        Run keyword if              "${moc_dict["operation_type"]}" == "add" and "${mo_parameters[0]}" == "FAIL"
        ...                         Create MO in CU delta plan              plan_id=${plan_id}          dist_name=${moc_dict["distName"]}
        ${mo_uuid}                  Get CU Specifical MO UUID               plan_id=${plan_id}          mo_dn=${moc_dict["distName"]}
        ${parameters_count}         Get length                              ${moc_dict["parameters"]}
        Run keyword if              ${parameters_count} > 0
        ...                         Update parameters in CU delta plan      plan_id=${plan_id}
        ...                                                                 mo_uuid=${mo_uuid}
        ...                                                                 parameters_list=${moc_dict["parameters"]}
    END
    Validate and activate CU delta plan    plan_id=${plan_id}
    Run Keyword And Ignore Error    admin_cu.disconnect


Check if delta plan was created on CU
    [Arguments]                     ${action_id}
    ${delta_gen}=                   admin_cu.get_action_state_of_generating_delta_plan      ${action_id}
    Should be true                  '${delta_gen['status']}'=='success' or '${delta_gen['status']}'=='failure'
    Run keyword if                  '${delta_gen['status']}'=='failure'
    ...                             Fail    CU delta plan creation failed

Get CU Specifical MO UUID
    [Arguments]                     ${plan_id}      ${mo_dn}
    @{name_list}=                   split_string    ${mo_dn}    /
    Set suite variable              ${parent_mouuid}            None
    FOR  ${name}  IN  @{name_list}
                    ${mouuid}       Get CU Specifical MO UUID via DN Name       ${plan_id}      ${name}
    END
    [Return]                        ${mouuid}

Get CU Specifical MO UUID via DN Name
    [Arguments]                     ${plan_id}      ${name}
    &{delta_plan_tree}              admin_cu.get_delta_plan_tree_diff           plan_id=${plan_id}
    @{plan_tree}                    set variable                                ${delta_plan_tree["created"]}
    FOR  ${mo_info}  IN  @{plan_tree}
            run keyword if          '${mo_info["parent_mo_uuid"]}'=='${parent_mouuid}' and '${mo_info["name"]}'=='${name}'
            ...                     run keywords        Set suite variable      ${parent_mouuid}  ${mo_info["mo_uuid"]}
            ...                                    AND  exit for loop
    END
    [Return]                        ${parent_mouuid}

Update parameters in CU delta plan
    [Arguments]                     ${plan_id}    ${mo_uuid}    ${parameters_list}
    ${update_res}                   admin_cu.Update parameters of delta plan        ${plan_id}          ${mo_uuid}     ${parameters_list}
    Wait until keyword succeeds  3x  1s    Check if delta plan was updated on CU    ${plan_id}          ${update_res['action_id']}

Check if delta plan was updated on CU
    [Arguments]                     ${plan_id}     ${action_id}
    ${delta_upd}=                   admin_cu.get_action_state_of_updating_parameters_of_delta_plan      ${plan_id}      ${action_id}
    Should be true                  '${delta_upd['status']}'=='success' or '${delta_upd['status']}'=='failure'
    Run keyword if                  '${delta_upd['status']}'=='failure'
    ...                             Fail        CU delta plan update failed

Validate and activate CU delta plan
    [Arguments]                     ${plan_id}
    ${delta_validation}=            admin_cu.validate_delta_plan                        ${plan_id}
    Wait until keyword succeeds  10x  2s    Check if delta plan was validated on CU     ${plan_id}      ${delta_validation['action_id']}
    ${delta_act}=                   admin_cu.Activate Delta Plan                        ${plan_id}
#    Wait until keyword succeeds  24x  10s   Check if delta plan was activated on CU     ${plan_id}      ${delta_act['operation_id']}
    Check delta plan activation status on CU        ${plan_id}      ${delta_act['operation_id']}

Create MO in CU delta plan
    [Arguments]                     ${plan_id}    ${dist_name}
    ${uuid}                         Get CU parent MO UUID                               plan_id=${plan_id}      dist_name=${dist_name}
    ${nidd_id}                      Get CU NIDD ID for MO from local dictionary         dist_name=${dist_name}
    ${instance_id}                  multiscf.get_instance_id_for_mo                     dist_name=${dist_name}
    ${nidd}                         Convert to string                                   ${nidd_id}
    ${create_res}=                  admin_cu.create_managed_object_of_delta_plan        plan_id=${plan_id}
    ...                                                                                 parent_mo_uuid=${uuid}
    ...                                                                                 nidd_id=${nidd}
    ...                                                                                 instance_id=${instance_id}
    ...                                                                                 include_defaults=${True}
    Wait until keyword succeeds  3x  2s    Check if MO was created on CU                ${plan_id}      ${create_res['action_id']}

Get CU NIDD ID for MO from local dictionary
    [Arguments]                     ${dist_name}
    ${mo_name}                      multiscf.get_last_mo_name_from_path                 ${dist_name}
    ${nidd_id}                      Get From Dictionary                                 ${MO_CLASS_TO_CU_NIDD_ID_MAPPING}   ${mo_name}
    [Return]                        ${nidd_id}

Get CU parent MO UUID
    [Arguments]                     ${plan_id}    ${dist_name}

    ${parent_mo}                    multiscf.get_parent_mo_path                         ${dist_name}
    ${mo_uuid}                      Get CU Specifical MO UUID                           plan_id=${plan_id}      mo_dn=${parent_mo}
    [Return]                        ${mo_uuid}

Check if MO was created on CU
    [Arguments]                     ${plan_id}     ${action_id}
    ${create_mo}=                   admin_cu.get_create_managed_object_action_result    ${plan_id}              ${action_id}
    Should be true                  '${create_mo['status']}'=='success' or '${create_mo['status']}'=='failure'
    Run keyword if                  '${create_mo['status']}'=='failure'
    ...                             Fail        CU object creation failed

Check if delta plan was validated on CU
    [Arguments]                     ${plan_id}     ${action_id}
    ${delta_validation}=            admin_cu.get_action_state_of_validating_delta_plan    ${plan_id}            ${action_id}
    Should be true                  '${delta_validation['status']}'=='success' or '${delta_validation['status']}'=='failure'
    Run keyword if                  '${delta_validation['status']}'=='failure'
    ...                             Fail        CU delta plan validation failed

Check delta plan activation status on CU
    [Arguments]                     ${plan_id}      ${operation_id}
    ${max_loop}                     set variable    24
    FOR    ${i}    IN RANGE    0    ${max_loop}
            sleep                   10s
            ${delta_act}=           admin_cu.get_operation_state_of_activating_delta_plan          ${plan_id}      ${operation_id}
            Exit For Loop If        '${delta_act['status']}'=='success' or '${delta_act['status']}'=='failure'
    END
    Should be true                  '${delta_act['status']}'=='success'     msg=CU Delta plan activation status is: ${delta_act['status']}


# ====================================================================================================================
# MODIFY THE vDU PARAMETERS THROUGH DELTA JSON METHOD
# ====================================================================================================================
OAM Send DU delta commissioning
    [Arguments]                     ${input_filepath}
    Log to console                  Sending vDU Delta Commissioning
    Wait Until Keyword Succeeds     5min  30s       admin_du.Connect to     host=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
    ...                                                                     port=${tl.gnbs[0].dus[0].oam_http_connection_details.port}
    ...                                                                     username=${tl.gnbs[0].dus[0].oam_http_connection_details.username}
    ...                                                                     password=${tl.gnbs[0].dus[0].oam_http_connection_details.password}
    ...                                                                     secure=True
    ${json_file_content}            OperatingSystem.Get File                ${input_filepath}
    @{delta_json_list}              multiscf.convert_to_list_from_json_string       ${json_file_content}
    ${delta_plan_list}              admin_du.get_delta_plan_info_list
    Run Keyword If                  ${delta_plan_list}                      admin_du.delete_delta_plan_file    ${delta_plan_list[0]['plan_id']}
    ${delta_res}                    admin_du.Generate delta plan            plan_name=DELTA-PLAN-1              timeout=60
    ${plan_id}                      Set variable                            ${delta_res['plan_id']}
    Wait until keyword succeeds  3x  2s    Check if delta plan was created on DU    ${delta_res['action_id']}
    FOR  ${moc_dict}  IN  @{delta_json_list}
        ${mo_parameters}=           Run Keyword And Ignore Error            admin_du.search_parameter_of_current_plan
        ...                                                                     mo_dn=${moc_dict["distName"]}
        ...                                                                     para_name=${moc_dict["parameters"][0]["parameter_path"]}
        Run keyword if              "${moc_dict["operation_type"]}" == "add" and "${mo_parameters[0]}" == "FAIL"
        ...                         Create MO in DU delta plan                  plan_id=${plan_id}      dist_name=${moc_dict["distName"]}
        ${dict_of_params_add}       multiscf.get_dict_of_parameters_for_vran_du_delta    params_list=${moc_dict["parameters"]}    op_type=add
        ${dict_of_params_replace}   multiscf.get_dict_of_parameters_for_vran_du_delta    params_list=${moc_dict["parameters"]}    op_type=replace
        ${parameters_to_add_count}          Get length                      ${dict_of_params_add}
        ${parameters_to_replace_count}      Get length                      ${dict_of_params_replace}
        Run keyword if              ${parameters_to_add_count} > 0          Update parameters in DU delta plan
        ...                                                                     plan_id=${plan_id}
        ...                                                                     mo_dn=${moc_dict["distName"]}
        ...                                                                     updated_paras_dict=${dict_of_params_add}
        ...                                                                     operation=add
        Run keyword if              ${parameters_to_replace_count} > 0      Update parameters in DU delta plan
        ...                                                                     plan_id=${plan_id}
        ...                                                                     mo_dn=${moc_dict["distName"]}
        ...                                                                     updated_paras_dict=${dict_of_params_replace}
        ...                                                                     operation=replace
    END
    ${du_delta_is_different}        Check if DU delta plan is different from current plan    plan_id=${plan_id}
    Run keyword if                  ${du_delta_is_different} == ${False}
    ...                             Log to console      DU delta commissioning will not be sent because it does not change any parameter
    Run keyword if                  ${du_delta_is_different} == ${True}     Validate and activate DU delta plan    plan_id=${plan_id}
    Run Keyword And Ignore Error    admin_du.disconnect

Check if delta plan was created on DU
    [Arguments]                     ${action_id}
    ${delta_gen}=                   admin_du.get_delta_plan_generated_action_status     ${action_id}
    Should be true                  '${delta_gen['status']}'=='success' or '${delta_gen['status']}'=='failure'
    Run keyword if                  '${delta_gen['status']}'=='failure'
    ...                             Fail        DU delta plan creation failed

Update parameters in DU delta plan
    [Arguments]                     ${plan_id}    ${mo_dn}    ${updated_paras_dict}     ${operation}
    ${update_res}                   admin_du.update_vdu_parameter_of_delta_plan         plan_id=${plan_id}
    ...                                                                                 mo_dn=${mo_dn}
    ...                                                                                 updated_paras_dict=${updated_paras_dict}
    ...                                                                                 operation=${operation}
    Wait until keyword succeeds     3x  1s      Check if delta plan was updated on DU   ${plan_id}    ${update_res['action_id']}

Check if delta plan was updated on DU
    [Arguments]                     ${plan_id}     ${action_id}
    ${delta_upd}=                   admin_du.get_update_paras_action_status_of_delta_plan   ${plan_id}    ${action_id}
    Should be true                  '${delta_upd['status']}'=='success' or '${delta_upd['status']}'=='failure'
    Run keyword if                  '${delta_upd['status']}'=='failure'
    ...                             Fail        DU delta plan update failed

Check if DU delta plan is different from current plan
    [Arguments]                     ${plan_id}
    Log to console                  ${plan_id}
    ${delta_plan_info}              admin_du.get_delta_plan_info_list
    ${du_delta_plan_is_different}   Get From Dictionary                                 ${delta_plan_info[0]}    is_changed
    [Return]                        ${du_delta_plan_is_different}

Validate and activate DU delta plan
    [Arguments]                     ${plan_id}
    ${delta_validation}=            admin_du.validate_delta_plan                            ${plan_id}
    Wait until keyword succeeds     10x  2s     Check if delta plan was validated on DU     ${plan_id}      ${delta_validation['action_id']}
    ${delta_act}=                   admin_du.Activate Delta Plan    ${plan_id}
#    Wait until keyword succeeds     24x  10s    Check if delta plan was activated on DU     ${plan_id}      ${delta_act['id']}
    Check delta plan activation status on DU        ${plan_id}      ${delta_act['id']}

Create MO in DU delta plan
    [Arguments]                     ${plan_id}    ${dist_name}

    ${parent_mo_dn}                 multiscf.get_parent_mo_path                             ${dist_name}
    ${mo_name}                      multiscf.get_last_mo_name_with_id_from_path             ${dist_name}
    ${create_res}=                  admin_du.create_vdu_object_of_delta_plan                delta_plan_id=${plan_id}
    ...                                                                                     parent_mo_dn=${parent_mo_dn}
    ...                                                                                     mo_name=${mo_name}
    Wait until keyword succeeds     3x  2s      Check if MO was created on DU               ${plan_id}      ${create_res['action_id']}

Check if MO was created on DU
    [Arguments]                     ${plan_id}     ${action_id}
    ${create_mo}=                   admin_du.get_create_vdu_object_action_status_of_staged_plan    ${plan_id}    ${action_id}
    Should be true                  '${create_mo['status']}'=='success' or '${create_mo['status']}'=='failure'
    Run keyword if                  '${create_mo['status']}'=='failure'
    ...                             Fail        DU object creation failed

Check if delta plan was validated on DU
    [Arguments]                     ${plan_id}     ${action_id}
    ${delta_validation}=            admin_du.get_validate_plan_operation_status             ${plan_id}      ${action_id}
    Should be true                  '${delta_validation['status']}'=='success' or '${delta_validation['status']}'=='failure'
    Run keyword if                  '${delta_validation['status']}'=='failure'
    ...                             Fail        DU delta plan validation failed

Check delta plan activation status on DU
    [Arguments]                     ${plan_id}      ${operation_id}
    ${max_loop}                     set variable    24
    FOR    ${i}    IN RANGE    0    ${max_loop}
            sleep                   10s
            ${delta_act}=           admin_du.get_activate_delta_plan_operation_status       ${plan_id}      ${operation_id}
            Exit For Loop If        '${delta_act['status']}'=='success' or '${delta_act['status']}'=='failure'
    END
    Should be true                  '${delta_act['status']}'=='success'     msg=DU Delta plan activation status is: ${delta_act['status']}


#===================================
# Backup/restore SCF files
#===================================
OAM Get SCF Files
    [Documentation]                 Retrieve SCF file from all detected OAMs (DU and CU).
    ...                             For CU, job is done only if GNB_CU exists.
    ...                             The SCF are then available through ${SCF_SETUP_PATH} or ${SCF_CU_SETUP_PATH} global variables
    @{TSCF_SETUP_PATH}              Create List
    @{TSCF_CU_SETUP_PATH}           Create List
    Set suite variable              ${TSCF_SETUP_PATH}
    Set suite variable              ${TSCF_CU_SETUP_PATH}
    FOR     ${i}    IN RANGE        ${nbGNB}
        OAM Get SCF Files from GNB  index=${i}
        ${len}                      Get Length                              ${TSCF_CU_SETUP_PATH}
        run keyword if              ${len}<${nbGNB}
        ...                         Append to list                          ${TSCF_CU_SETUP_PATH}           ${EMPTY}
    END
    # Setting previous variable with (SCF_SETUP_PATH) content of table TSCF_SETUP_PATH (index 0)
    Set Suite Variable              ${SCF_SETUP_PATH}                       ${TSCF_SETUP_PATH[0]}
    # Setting previous variable with (SCF_CU_SETUP_PATH) content of table TSCF_CU_SETUP_PATH (index 0)
    Set Suite Variable              ${SCF_CU_SETUP_PATH}                    ${TSCF_CU_SETUP_PATH[0]}


OAM Get SCF Files from GNB
    [Documentation]                 INTERNAL USAGE.
    ...                             Intermediate service called by OAM Get SCF Files, since we are now using a for loop
    [Arguments]                     ${index}
    # Getting SCF for GNB DU and setting global variable : SCF_SETUP_PATH
    ${temp}                         OAM Get SCF File
    ...                             oam=${TGNB_DU[${index}].oam}            file=TSCF_DU${index}_Setup.xml
    Append to list                  ${TSCF_SETUP_PATH}                      ${temp}
    # Check SCF for CU shloud be retrieved, otherwise exit
    return from keyword if          '${TGNB_CU[${index}]}'=='None'
    # Getting SCF for GNB CU and setting global variable : SCF_CU_SETUP_PATH
    ${temp}                         OAM Get SCF File
    ...                             oam=${TGNB_CU[${index}].oam}            file=TSCF_CU${index}_Setup.xml
    Append to list                  ${TSCF_CU_SETUP_PATH}                   ${temp}


OAM Get SCF File
    [Documentation]                 Perform a SCF backup in an xml file.
    ...                             The keyword returns the path to the file with current SCF content.
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    ...                              - dir : Path to directory to store final SCF.
    ...                              - file : File name of final SCF.
    ...                              - timeout : Max delay allowed for operation. Unit is seconds
    ...                              - with_auto_configured_parameters : Include auto-configured parameters (default: False).
    [Arguments]                     ${oam}=${GNB_DU.oam}
    ...                             ${dir}=${LOG_PATH}
    ...                             ${file}=SCF.xml
    ...                             ${timeout}=${60}
    ...                             ${with_auto_configured_parameters}=${False}
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  getScfFile
    ...                             dir=${dir}                              file=${file}
    ...                             timeout=${timeout}
    ...                             with_auto_configured_parameters=${with_auto_configured_parameters}
    [Return]                        ${return}


OAM Get CU SCF File
    [Documentation]                 Perform a vCU SCF backup in an xml file.
    ...
    ...                             The keyword returns the path to the file with current SCF content.
    ...
    ...                             *Argument details:*
    ...                              - dir : Path to directory to store final SCF.
    ...                              - file : File name of final SCF.
    ...                              - timeout : Max delay allowed for operation. Unit is seconds
    ...                              - with_auto_configured_parameters : Include auto-configured parameters (default: False).
    [Arguments]                     ${dir}=${LOG_PATH}
    ...                             ${file}=SCF.xml
    ...                             ${timeout}=${60}
    ...                             ${with_auto_configured_parameters}=${False}

    return from keyword if          not ${isAic}                            ${None}
    ${return}                       Call method
    ...                             ${GNB_CU.oam}                           getScfFile
    ...                             dir=${dir}                              file=${file}
    ...                             timeout=${timeout}
    ...                             with_auto_configured_parameters=${with_auto_configured_parameters}
    [Return]                        ${return}


OAM Restore Files
    [Documentation]                 Restore the SCF file on all detected OAMs (DU and CU).
    ...                             For CU, job is done only if GNB_CU exists.
    ...
    ...                             *Argument details:*
    ...                              - reset_ap : True to require the AirPhone reset.
    ...                              - disconnect_oam : True to disconnect existing OAM connection
    [Arguments]                     ${reset_ap}=${False}
    ...                             ${disconnect_oam}=${False}
    FOR     ${i}        IN RANGE    ${nbGNB}
        OAM Restore Files from GNB  index=${i}
        ...                         reset_ap=${reset_ap}                    disconnect_oam=${disconnect_oam}
    END

OAM Restore Files from GNB
    [Documentation]                 INTERNAL USAGE.
    ...                             Intermediate service called by OAM Restore Files, since we are now using a for loop
    [Arguments]                     ${index}
    ...                             ${reset_ap}=${False}
    ...                             ${disconnect_oam}=${False}
    # disconnect the OAM connection so that a new connection is established afterward
    Run Keyword If                  ${disconnect_oam} == ${True}
    ...                             OAM Disconnect                          ${TGNB_DU[${index}].oam}
    OAM Restore File                oam=${TGNB_DU[${index}].oam}
    ...                             setupPath=${TSCF_SETUP_PATH[${index}]}  reset_ap=${reset_ap}
    return from keyword if          '${TGNB_CU[${index}]}'=='None'
    # disconnect the OAM connection so that a new connection is established afterward
    Run Keyword If                  ${disconnect_oam} == ${True}
    ...                             OAM Disconnect                          ${TGNB_CU[${index}].oam}
    OAM Restore File                oam=${TGNB_CU[${index}].oam}            setupPath=${TSCF_CU_SETUP_PATH[${index}]}


OAM Restore File
    [Documentation]                 Restore a SCF backuped in Test Suite Setup, if required.
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${TGNB_DU[x].oam} or ${TGNB_CU[x].oam}).
    ...                              - setupPath : Path to the SCF file to be restored on OAM.
    ...                              - reset_ap : True to require the AirPhone reset.
    [Arguments]                     ${oam}=${TGNB_DU[0].oam}
    ...                             ${setupPath}=${TSCF_SETUP_PATH[0]}
    ...                             ${reset_ap}=${False}
#    ...                             ${reconnect}=${False}
    # Check backup was done
    Run keyword if                  '${setupPath}'=='${EMPTY}'
    ...                             Run keywords
    ...                                 Dated log                           No SCF to restore (backup never done)
    ...         AND                     return from keyword
    # Doing a backup for teardown
    ${ScfFileName}                  getFileNameFromPath                     ${setupPath}
    ${file}                         Replace String                          ${ScfFileName}
    ...                             Setup                                   Teardown
    ${SCF_TEARDOWN_PATH}            OAM Get SCF File
    ...                                 oam=${oam}
    ...                                 file=${file}
    ${maxDiff}                      set variable if                         '${oam.unit}'=='DU'
    ...                             ${SCF_DU_Max_Diff}                      ${SCF_CU_Max_Diff}
    ${nbDiff}                       Run                                     diff ${SCF_TEARDOWN_PATH} ${setupPath} | wc -l
    # If less than 8 lines in diff, nothing (except an ID and a timestamp) was changed, so no restore
    Run keyword if                  ${nbDiff}<=${maxDiff}
    ...                             Run keywords
    ...                                 Dated log                           No change detected in SCF. No restore to perform
    ...         AND                     return from keyword
    # From here a restore is required
    OAM Perform Full Commissioning  oam=${oam}                              scf_file=${setupPath}
    Run Keyword if                  ${reset_ap}==${True}
    ...                             Run keywords
    ...                             Airscale Soft Reboot                    ${AP_DU}
    ...         AND                 Airscale Wait for Ready                 ${AP_DU}
    ...         AND                 WTS Clear
    ...         AND                 WTS Start processes
    # Wait for OAM available
    run keyword if                  ${isAic}
    ...                             OAM wait available      oam=${oam}      wait_time=60
    ...         ELSE                OAM wait available      oam=${oam}

OAM wait available
    [Documentation]                 Wait until the ProceduralState is in 'Configured' or 'OnAir' state.
    ...
    ...                             The keyword returns either True (if Cell is OnAir or Configured) or False
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${TGNB_DU[0].oam} or ${TGNB_CU[0].oam}).
    ...                              - timeout : Max delay allowed for operation. Unit is seconds
    [Arguments]                     ${oam}=${TGNB_DU[0].oam}
    ...                             ${wait_time}=300
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  waitAvailable
    ...                             wait_time=${wait_time}
    run keyword if                 '${return}'=='True' and not ${isAIC}
    ...                             wait until keyword succeeds             120      5
    ...                                 SSH Check Connect                   ${oam.entity.entryCard[0]}
    [Return]                        ${return}

Activate Test Dedicated Mode
    [Documentation]                 Activate the Test Mode on GNB
    ...                             The test line will be rebooted to activate the test mode
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${TGNB_DU[0].oam} or ${TGNB_CU[0].oam}).
    [Arguments]                     ${oam}=${TGNB_DU[0].oam}
    Dated Log                       Activate Test Dedicated Mode
    ${cmd}                          Set Variable                            reset_to_test_dedicated
    SBTS OAM Run Command            oam=${oam}                              cmd=${cmd}
    csn.reset_cache
    OAM wait available              oam=${oam}
    # check GNB + cells statuses
    Wait Until Keyword Succeeds     3min    30s
    ...                             Check GNB And Cells Status

Check GNB And Cells Status
    [Documentation]                 Check GNB And Cells Status
    ...                             proceduralState should be in Test
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${TGNB_DU[0].oam} or ${TGNB_CU[0].oam}).
    [Arguments]                     ${oam}=${TGNB_DU[0].oam}
    # check GNB status
    ${cmd}                          Set Variable    get_bts_statuses
    ${gnb_status}                   SBTS OAM Run Command    oam=${oam}    cmd=${cmd}
    Dated Log                       =======> Current GNB status = ${gnb_status}
    Should Contain Any              ${gnb_status['operationalState']}    Enabled   Disabled
    ...                             ignore_case=true
    Should Be Equal                 ${gnb_status['proceduralState']}     Test
    ...                             ignore_case=true
    ...                             msg=GNB is not in Test Mode, current status is ${gnb_status}
    Should Be Equal                 ${gnb_status['blockingState']}       Unblocked
    ...                             ignore_case=true
    # check cells status
    ${cmd}                          Set Variable    get_cells_info
    ${cells_info}                   SBTS OAM Run Command    oam=${oam}    cmd=${cmd}
    Dated log                       =======> Current cell(s) info = ${cells_info}
    FOR    ${cell}    IN    @{cells_info}
        Should Contain Any    ${cell['status']['proceduralStatus']}    not initialized   configured   OnAir
        ...                   ignore_case=true
        Should be equal       ${cell['status']['administrativeState']}    Unlocked
        ...                   ignore_case=true
    END

Get Runtime Id
    [Documentation]                 Get runtime id needed for Distinguish Name of Cells
    ...                             to start downlink test mode for instance
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${TGNB_DU[0].oam} or ${TGNB_CU[0].oam}).
    [Arguments]                     ${oam}=${TGNB_DU[0].oam}
    ${runtimeId}                          Set Variable    0
    ${cmd}                          Set Variable    get_cells_info
    ${cells_info}                   SBTS OAM Run Command    oam=${oam}    cmd=${cmd}
    FOR    ${cell}    IN    @{cells_info}
        ${runtimeIdList}    get regexp matches    ${cell['id']['internal']}
        ...             RUNTIME_VIEW-(\\d+)     1
        ${runtimeId}=    Strip String    ${runtimeIdList[0]}
    END
    [Return]                        ${runtimeId}

Start Downlink Test
    [Documentation]
    ...     Start 5G downlink test
    ...
    ...                             *Argument details:*
    ...    - param dist_name:       cell DN (/MRBTS-1/RAT-1/RUNTIME_VIEW-.../NRCELL_R-1).
    ...    - param test_model:      One of the following: TM1_1, TM1_2, TM2, TM2A, TM3_1, TM3_1A, TM3_2, TM3_3, TM3_1NR.
    ...    - param ru_mode:         One of the following: NR_Only, MSR (MSR is supported when RU contains EUTRA.Frequency.Band).
    ...    - param beam_pattern_id: Array of integer <0 to 1200> (mandatory, two items at most).
    ...    - param pci:             Physical Cell ID -  [1..1007].
    ...    - param polarization:    One of the following: "P_plus45_or_0", "P_minus45_or_90", "P_both".
    ...    - param loadType:        One of the following: "flatLoad", "burstLoad". (mandatory).
    ...    - param loadLevelFlat:   "low", "medium", "busy", "full". (required only when "loadType" set to "flatLoad").
    ...    - param loadLevelBurst:  "burst_13_5", "burst_19_2", "burst_32_7", "burst_46_2", "burst_59_6", "burst_73_1", "burst_86_5", "burst_100"
    ...                             (param required only when "loadType" set to "burstLoad").
    ...
    ...     *WARNING:* With value "medium" loadLevelFlat, below parameters num_of_ssb_beam_pattern_id and ssb_beam_pattern_id are not sent to gNB
    ...     even if they are provided in this keyword (feature specification)
    ...    - param numOfSsbBeamPatternId: "ssb_4", "ssb_8" or "ssb_32". (required only when "loadLevelFlat" set to "low").
    ...                                    Use "ssb_4" when FR1<=3GHz, "ssb_8" when 3GHz<FR1<6GHz and "ssb_32" when FR2.
    ...    - param ssbBeamPatternId: array of integer <0 to 1200>  (items number: 4, 8, 32 depends on value of "numOfSsbBeamPatternId").
    ...     For details see https://onion.wroclaw.nsn-rdnet.net/branches/master/cli-docs/tutorial-start5GDownlinkTest.html

    [Arguments]                     ${oam}
    ...                             ${cell_dn}                               ${test_model}
    ...                             ${beam_pattern_id}                       ${polarization}
    ...                             ${power_backoff}                         ${ru_mode}
    ...                             ${phys_cell_id}                          ${p_max}
    ...                             ${mimo_rank}                             ${load_type}
    ...                             ${load_level_flat}=None                  ${num_of_ssb_beam_pattern_id}=None
    ...                             ${ssb_beam_pattern_id}=None              ${load_level_burst}=None
    Dated Log                       Start downlink test
    ${cmd}                          Set Variable    start_5g_downlink_test
    &{args}                         Create Dictionary
    ...                                 dist_name="${cell_dn}"
    ...                                 test_model="${test_model}"
    ...                                 beam_pattern_id=${beam_pattern_id}
    ...                                 polarization="${polarization}"
    ...                                 power_backoff="${power_backoff}"
    ...                                 ru_mode="${ru_mode}"
    ...                                 codebook_2_antports=0
    ...                                 i11_codebook_4_antports=0
    ...                                 i2_codebook_4_antports=0
    ...                                 i13_codebook_4_antports=0
    ...                                 p_max="${p_max}"
    ...                                 mimo_rank="${mimo_rank}"
    ...                                 phys_cell_id="${phys_cell_id}"
    ...                                 load_type="${load_type}"

    Run keyword if                  '${load_type}'=='flatLoad' and '${load_level_flat}'=='low'
    ...                             Set To Dictionary
    ...                                 ${args}
    ...                                 load_level_flat="${load_level_flat}"
    ...                                 num_of_ssb_beam_pattern_id="${num_of_ssb_beam_pattern_id}"
    ...                                 ssb_beam_pattern_id=${ssb_beam_pattern_id}

    Run keyword if                  '${load_type}'=='flatLoad' and '${load_level_flat}'!='low'
    ...                             Set To Dictionary
    ...                                 ${args}
    ...                                 load_level_flat="${load_level_flat}"

    Run keyword if                  '${load_type}'=='burstLoad'
    ...                             Set To Dictionary
    ...                                 ${args}
    ...                                 load_level_burst="${load_level_burst}"

    ${result}                       SBTS OAM Run Command    oam=${oam}    cmd=${cmd}    cmd_args=${args}
    Log to console                  ${result}

Stop Downlink Test
    [Documentation]
    ...     Stop 5G downlink test
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${TGNB_DU[0].oam} or ${TGNB_CU[0].oam})
    ...                              - cell_dn :  cell DN (/MRBTS-1/RAT-1/RUNTIME_VIEW-.../NRCELL_R-1)
    [Arguments]                     ${oam}
    ...                             ${cell_dn}
    Dated Log                       Stop downlink test
    ${cmd}                          Set Variable    stop_5g_downlink_test
    &{args}                         Create Dictionary
    ...                                 dist_name="${cell_dn}"
    ${result}                       SBTS OAM Run Command    oam=${oam}    cmd=${cmd}    cmd_args=${args}
    Log to console                  ${result}


#===================================
# Tools to Access to Git files
#===================================

Download Package Using Git Update OAM
    [Documentation]                 Allows you to retrieve the specified BSR.zip file and then update the OAM with the files in the BSR.zip.
    ...
    ...                             *Argument details:*
    ...
    ...                             - git_path (optional): BSR Git project to be used. Ex: gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git
    ...
    ...                             - git_folder (mandatory): Name of the repository where the BSR file to retrieve is stored.
    ...
    ...                             - git_file_name (mandatory): Name of the BSR file to retrieve.
    ...
    ...                             - target_dir (optional): TL repository where the BSR file should be stored. Default: ${LOG_PATH}/BSR
    ...
    ...                             - token_name and token_access (optional): Token and access code to be used with the BSR Git project.
    ...                              For the default BSR Git project, it is: "NpsVrfToken" and "glpat-4yNB_jaBXxz_BsyeAsgL"
    ...
    ...                             IMPORTANT: Access to the BSR Git project is limited to group members: please ask any group member to add you.

    [Arguments]                     ${git_folder}       ${git_file_name}
    ...                             ${git_path}=gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git
    ...                             ${token_name}=NpsVrfToken
    ...                             ${token_access}=glpat-4yNB_jaBXxz_BsyeAsgL
    ...                             ${target_dir}=${LOG_PATH}/BSR

    ${target}=                      Download Package Using Git          git_path=${git_path}            git_folder=${git_folder}
    ...                                                                 git_file_name=${git_file_name}  target_dir=${target_dir}
    ...                                                                 token_name=${token_name}        token_access=${token_access}
    Dated Log                       OAM Software Load: ${target}
    ${result}=                      OAM Software Update                 sw_package=${target}
    Dated Log                       ${result}


#===================================
# General tools
#===================================
OAM Get VM
    [Documentation]                 Determine the reference of an OAM VM, like the CPIF VM located on the GNB_DU OAM
    ...
    ...                             The keyword returns the VM host Id.
    ...                             This VM host Id can be used as host parameter in a "SSH Connect" keyword.
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${TGNB_DU[0].oam} or ${TGNB_CU[0].oam}).
    ...                              - name : Name of the VM. ex: CPIF, CPUE, UPUE
    [Arguments]                     ${oam}=${TGNB_CU[0].oam}
    ...                             ${name}=CPIF
    ${vm}                           call method                             ${oam}
    ...                             getVM                                   name=${name}
    [Return]                        ${vm}

OAM Get Postfix
    [Documentation]                 INTERNAL USAGE.
    ...                             This method is to ensure backward compatibility
    ...                             It compute a postfix string that will be '' for DU and '_<unit>' for other units
    [Arguments]                     ${oam}

    ${postfix}                      set variable if                         '${oam.entity.unit}'=='DU' and not ${isAic}
    ...                             ${EMPTY}                                _${oam.entity.unit}
    [Return]                        ${postfix}

OAM Run Command
    [Documentation]                 Execute an OAM admin command and return the output
    ...                             It's up to the caller to analyze the output and to extract needed data
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${TGNB_DU[0].oam} or ${TGNB_CU[0].oam}).
    ...                              - cmd : the command to be run (available commands are provided in the following URL
    ...                                      https://docs.taf.nsn-rdnet.net/taf.sbts.oam.coam.admin/)
    ...                                      documentation see TAF documentation for list
    ...                              - cmdArgs : dictionary containing the list of parameters needed to run the command
    [Arguments]                     ${oam}=${TGNB_DU[0].oam}
    ...                             ${cmd}=${None}
    ...                             ${cmd_args}=${None}

    return from keyword if          '${cmd}' == '${None}'                   ${None}
    ${result}                           Call Method
    ...                                 ${oam}                              runOamCmd
    ...                                 ${cmd}                              ${cmd_args}
    [Return]                        ${result}


SBTS OAM Run Command
    [Documentation]                 Execute an SBTS OAM admin command and return the output
    ...                             It's up to the caller to analyze the output and to extract needed data
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${TGNB_DU[0].oam} or ${TGNB_CU[0].oam}).
    ...                              - cmd : the command to be run (available commands are provided in the following URL
    ...                                      https://docs.taf.nsn-rdnet.net/taf.sbts.oam.coam.admin/)
    ...                                      documentation see TAF documentation for list
    ...                              - cmdArgs : dictionary containing the list of parameters needed to run the command
    [Arguments]                     ${oam}=${TGNB_DU[0].oam}
    ...                             ${cmd}=${None}
    ...                             ${cmd_args}=${None}

    return from keyword if          '${cmd}' == '${None}'                   ${None}
    ${result}                           Call Method
    ...                                 ${oam}                              sbtsRunOamCmd
    ...                                 ${cmd}                              ${cmd_args}
    [Return]                        ${result}


Call method secure
    [Documentation]                 INTERNAL USAGE
    ...                             Call a method knowing the reference of an instance of class
    ...                             It is secure it the way no call is performed in case the reference is None
    [Arguments]                     ${obj}                                  ${method}
    return from keyword if          '${obj}'=='None'                        None
    ${return}                       call method
    ...                             ${obj}                                  ${method}
    [Return]                        ${return}
