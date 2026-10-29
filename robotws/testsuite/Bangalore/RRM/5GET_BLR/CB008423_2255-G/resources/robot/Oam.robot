*** Settings ***
Documentation
...            == Purpose ==
...            Library to manage all OAM oriented services on Classical, CloudBTS, AIC,...
...
...            == Description ==
...            Proposed keywords will offer these services:
...            - connection/disconnection to/from specified OAM
...            - parameters modification
...            - full commissioning by applying a complete SCF
...            - get OAM info like the SCF file, the active Alarms, 
...
...            *Main keywords are:*
...            | OAM Set Params                  | <modify_param> | <oam>        | <timeout>              |           |
...            | OAM Get SCF Files               |                |              |                        |           |
...            | OAM Get SCF File                | <oam>          | <dir>        | <file>                 | <timeout> |
...            | OAM Connect                     | <oam>          |              |                        |           |
...            | OAM Disconnect                  | <oam>          |              |                        |           |
...            | OAM Perform Full Commissioning  | <scf_file>     | <oam>        | <skip_relation_errors> |           |
...            | OAM Get Active Alarms           | <oam>          | <textFormat> |                        |           |
...            | OAM wait available              | <oam>          | <wait_time>  |                        |           |
...            | OAM Get GNB BTS Info            | <oam>          |              |                        |           |
...
...            *Example:*
...            To be completed.
...


Library           DateTime
Library           ../python/StringTool.py
Library           ../python/OsTool.py
Library           taf.gnb.oam.coam.admin                      WITH NAME               coam
Library           taf.gnb.oam.coam.cu                         WITH NAME               cu
Library           taf.selenium.sbts                           WITH NAME               selenium_coam
Library           taf.rfrl.common_resources.python.coam_parameter
Resource          Connect.robot
Resource          Capture.robot
Resource          Restart.robot

*** Variables ***
${SCF_SETUP_PATH}                   ${EMPTY}
${SCF_DU_Max_Diff}                  8
${SCF_CU_Max_Diff}                  12

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
    ...                             ${timeout}=1200
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
    [Return]                        ${return}

OAM Set Params
    [Documentation]                 Modify some parameters in the database of the OAM set in arguments.
    ...
    ...                             The keyword returns the Commissioning status (completed, ongoing or failed)
    ...
    ...                             *Argument details:*
    ...                              - modify_param : List of dictionaries 'param':'value'.
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    ...                              - timeout : Max delay allowed for operation. Unit is seconds
    [Arguments]                     ${modify_param}
    ...                             ${oam}=${GNB_DU.oam}
    ...                             ${timeout}=${600}
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  setParams
    ...                             modify_param=${modify_param}            timeout=${timeout}
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

#===================================
# Backup/restore SCF files
#===================================
OAM Get SCF Files
    [Documentation]                 Retrieve SCF file from all detected OAMs (DU and CU).
    ...                             For CU, job is done only if GNB_CU exists.
    ...                             The SCF are then available through ${SCF_SETUP_PATH} or ${SCF_CU_SETUP_PATH} global variables
    # Getting SCF for GNB DU and setting global variable : SCF_SETUP_PATH
    ${SCF_SETUP_PATH}               OAM Get SCF File
    ...                             oam=${GNB_DU.oam}                       file=SCF_DU_Setup.xml
    Set Suite Variable              ${SCF_SETUP_PATH}
    # Check SCF for CU shloud be retrieved, otherwise exit
    Set Suite Variable              ${SCF_CU_SETUP_PATH}                    ${EMPTY}
    return from keyword if          '${GNB_CU}'=='None'
    # Getting SCF for GNB CU and setting global variable : SCF_CU_SETUP_PATH
    ${SCF_CU_SETUP_PATH}            OAM Get SCF File
    ...                             oam=${GNB_CU.oam}                       file=SCF_CU_Setup.xml
    Set Suite Variable              ${SCF_CU_SETUP_PATH}

OAM Get SCF File
    [Documentation]                 Perform a SCF backup in an xml file.
    ...
    ...                             The keyword returns the path to the file with current SCF content.
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    ...                              - dir : Path to directory to store final SCF.
    ...                              - file : File name of final SCF.
    ...                              - timeout : Max delay allowed for operation. Unit is seconds
    [Arguments]                     ${oam}=${GNB_DU.oam}
    ...                             ${dir}=${LOG_PATH}
    ...                             ${file}=SCF.xml
    ...                             ${timeout}=${60}
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  getScfFile
    ...                             dir=${dir}                              file=${file}
    ...                             timeout=${timeout}
    [Return]                        ${return}

OAM Restore Files
    [Documentation]                 Restore the SCF file on all detected OAMs (DU and CU).
    ...                             For CU, job is done only if GNB_CU exists.
    ...
    ...                             *Argument details:*
    ...                              - reset_ap : True to require the AirPhone reset.
    [Arguments]                     ${reset_ap}=${False}
    OAM Restore File                oam=${GNB_DU.oam}                       setupPath=${SCF_SETUP_PATH}    reset_ap=${reset_ap}
    return from keyword if          '${GNB_CU}'=='None'
    OAM Restore File                oam=${GNB_CU.oam}                       setupPath=${SCF_CU_SETUP_PATH}

OAM Restore File
    [Documentation]                 Restore a SCF backuped in Test Suite Setup, if required.
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    ...                              - setupPath : Path to the SCF file to be restored on OAM.
    ...                              - reset_ap : True to require the AirPhone reset.
    [Arguments]                     ${oam}=${GNB_DU.oam}
    ...                             ${setupPath}=${SCF_SETUP_PATH}
    ...                             ${reset_ap}=${False}
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
    ${maxDiff}                      set variable if                         '${oam}'=='${GNB_DU.oam}'
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
    OAM wait available              oam=${oam}

OAM wait available
    [Documentation]                 Wait until the ProceduralState is in 'Configured' or 'OnAir' state.
    ...
    ...                             The keyword returns either True (if Cell is OnAir or Configured) or False
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    ...                              - timeout : Max delay allowed for operation. Unit is seconds
    [Arguments]                     ${oam}=${GNB_DU.oam}
    ...                             ${wait_time}=300
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  waitAvailable
    ...                             wait_time=${wait_time}
    run keyword if                 '${return}'=='True'
    ...                             wait until keyword succeeds             120      5
    ...                                 SSH Check Connect                   ${GNB_DU.entryCard[0]}
    [Return]                        ${return}


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
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    ...                              - name : Name of the VM. ex: CPIF, CPUE, UPUE
    [Arguments]                     ${oam}=${GNB_CU.oam}
    ...                             ${name}=CPIF
    ${vm}                           call method                             ${oam}
    ...                             getVM                                   name=${name}
    [Return]                        ${vm}

OAM Get Postfix
    [Documentation]                 INTERNAL USAGE
    ...                             This method is to ensure backward compatibility
    ...                             It compute a postfix string that will be '' for DU and '_<unit>' for other units
    [Arguments]                     ${oam}
    ${postfix}                      set variable if                         '${oam.entity.unit}'=='DU'
    ...                             ${EMPTY}                                _${oam.entity.unit}
    [Return]                        ${postfix}

OAM Run Command
    [Documentation]                 Execute an OAM admin command and return the output
    ...                             It's up to the caller to analyze the output and to extract needed data
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    ...                              - cmd : the command to be run (available commands are provided in the following URL
    ...                                      https://docs.taf.nsn-rdnet.net/taf.gnb.oam.coam.admin/)
    ...                                      documentation see TAF documentation for list
    ...                              - cmdArgs : dictionary containing the list of parameters needed to run the command
    [Arguments]                     ${oam}=${GNB_DU.oam}
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
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    ...                              - cmd : the command to be run (available commands are provided in the following URL
    ...                                      https://docs.taf.nsn-rdnet.net/taf.gnb.oam.coam.admin/)
    ...                                      documentation see TAF documentation for list
    ...                              - cmdArgs : dictionary containing the list of parameters needed to run the command
    [Arguments]                     ${oam}=${GNB_DU.oam}
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
