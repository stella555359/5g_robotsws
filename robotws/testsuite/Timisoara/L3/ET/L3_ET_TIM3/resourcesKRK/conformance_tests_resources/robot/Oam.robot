*** Settings ***
Library           DateTime
Library           ../python/StringTool.py
Library           ../python/OsTool.py
Library           taf.sbts.oam.coam.admin            		  WITH NAME               coam
Library           taf.gnb.oam.coam.cu               		  WITH NAME               cu
Library           taf.selenium.sbts                           WITH NAME               selenium_coam
Library           taf.rfrl.common_resources.python.coam_parameter
Resource          Connect.robot
Resource          Capture.robot
Resource          Restart.robot

*** Variables ***
${SCF_SETUP_PATH}                   ${EMPTY}

*** Keywords ***
OAM Connect
    [Documentation]                 Connection to an Oam (seee Oam.py for Oam Class)
    [Arguments]                     ${oam}
    ${return}                       Call method secure
    ...                             ${oam}                                  connect
    [Return]                        ${return}

OAM Disconnect
    [Documentation]                 Disconnection to an Oam (seee Oam.py for Oam Class)
    [Arguments]                     ${oam}
    Call method secure              ${oam}                                  disconnect

OAM Reset Site
    [Documentation]                 Reset the OAM url site whatever it is coam or megazone
    ...                             In case of COAM : it will wait until available again
    ...                             In case of megazone : it will wait until unvailable
    [Arguments]                     ${oam}
    Call method secure              ${oam}                                  startReset
    csn.reset_cache

OAM Wait Site Available
    [Documentation]                 Call a callback, then wait until the OAM url site is detected as available
    [Arguments]                     ${oam}
    ...                             ${callback}=None
    Call method secure              ${oam}                                  waitSiteAvailable
    Run Keyword if                  '${callback}'!='None'                   ${callback}

#===================================
# OAM Get Info
#===================================
OAM Get GNB BTS Info
    [Documentation]                 Get BTS info from GNB OAM
    ...                             From these, <MRBTS_ID> and <NRCELL_DIST_NAME> are extracted/computed
    ...                             BTS_INFO, MRBTS_ID and NRCELL_DIST_NAME are then put in global suite variables
    [Arguments]                     ${oam}
    Call method secure              ${oam}                                  getBtsInfo

OAM Get Cells Nr
    [Documentation]                 Get BTS cells NR array from GNB OAM
    [Arguments]                     ${oam}
    @{cellsNr}                      Call method secure                      ${oam}                                  getCellsNr
    [return]                        ${cellsNr}

OAM Get SW Version
    [Documentation]                 Get SW version from an OAM
    [Arguments]                     ${oam}
    ${return}                       Call method secure
    ...                             ${oam}                                  getSWVersion
    [Return]                        ${return}

OAM Get Active Alarms
    [Documentation]                 Get Active alarms from an OAM
    [Arguments]                     ${oam}=${GNB_DU.oam}
    ${return}                       Call method secure
    ...                             ${oam}                                  getActiveAlarms
    [Return]                        ${return}

OAM Get Snapshot
    [Documentation]                 Get Snapshot from OAM
    [Arguments]                     ${oam}=${GNB_DU.oam}
    ...                             ${prefix}=SNAPSHOT_GNB
    ...                             ${isTimeStamped}=${True}
    ...                             ${timeout}=600
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  getSnapshot
    ...                             path=${LOG_PATH}                        prefix=${prefix}
    ...                             isTimeStamped=${isTimeStamped}          timeout=${timeout}
    [Return]                        ${return}


#===================================
# Modify PARAMETERS
#===================================
OAM Cell Lock
    [Documentation]                 Lock or Unlock a cell
    [Arguments]                     ${oam}=${GNB_DU.oam}
    ...                             ${state}=LOCK
    ...                             ${cell_id}=${EMPTY}
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  cellLock
    ...                             state=${state}                          cell_id=${cell_id}
    [Return]                        ${return}

OAM Perform Full Commissioning
    [Documentation]                 Execute full Commissioning to OAM
    ...                             SCF file path need to be set as argument
    [Arguments]                     ${scf_file}
    ...                             ${oam}=${GNB_DU.oam}
    ...                             ${skip_relation_errors}=True
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  fullCommissioning
    ...                             scf_file=${scf_file}                    skip_relation_errors=${skip_relation_errors}
    [Return]                        ${return}

OAM Set Params
    [Documentation]                 Modify some parameters in SCF
    [Arguments]                     ${modify_param}
    ...                             ${oam}=${GNB_DU.oam}
    ...                             ${timeout}=${600}
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  setParams
    ...                             modify_param=${modify_param}            timeout=${timeout}
    [Return]                        ${return}


OAM Change String in SCF
    [Documentation]                 Modify some string in SCF that is not a parameter/object
    ...                             Generally it is recomanded to use OAM Set Params method in here .
    ...                             If no alternative then use this method
    ...                             eg: <managedObject ..distName="MRBTS-1/NRBTS-1/  into ..MRBTS-2/NRBTS-2/
    ...                             EG: modifiedScfPath   OAM Change String in SCF  oldVal=MRBTS-1/NRBTS-1   newVal=MRBTS-1/NRBTS-2
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
    [Documentation]                 Retrieve SCF files from all OAMs (DU and CU)
    ...                             For CU, job is done only if GNB_CU exists
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
    [Documentation]                 Perform a backup of SCF in an xml file
    [Arguments]                     ${oam}=${GNB_DU.oam}                    ${dir}=${LOG_PATH}
    ...                             ${file}=SCF.xml                         ${timeout}=${30}
    return from keyword if          '${oam}'=='None'                        ${EMPTY}
    ${return}                       Call method
    ...                             ${oam}                                  getScfFile
    ...                             dir=${dir}                              file=${file}
    ...                             timeout=${timeout}
    [Return]                        ${return}

OAM wait available
    [Documentation]                 Wait until the ProceduralState is in 'Configured' or 'OnAir' state
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
OAM Get Postfix
    [Documentation]                 This method is to ensure backward compatibility
    ...                             It compute a postfix string that will be '' for DU and '_<unit>' for other units
    [Arguments]                     ${oam}
    ${postfix}                      set variable if                         '${oam.unit}'=='DU'
    ...                             ${EMPTY}                                _${oam.unit}
    [Return]                        ${postfix}

Call method secure
    [Documentation]                 Call a method knowing the reference of an instance of class
    ...                             It is secure it the way no call is performed in case the reference is None
    [Arguments]                     ${obj}                                  ${method}
    return from keyword if          '${obj}'=='None'                        None
    ${return}                       call method
    ...                             ${obj}                                  ${method}
    [Return]                        ${return}

#OAM Set Params Old
#    [Documentation]                 Modify some parameters in SCF
#    [Arguments]                     ${modify_param}
#    ...                             ${oam}=${GNB_DU.oam}
#    ...                             ${timeout}=${600}
#    ${alias}                        OAM Connect                             ${oam}
#    Dated Log New Line              OAM Set Params:\n\t@{modify_param}
#    ${para_file}                    coam_parameter.create_update_parameters_delta
#    ...                                 parameters=${modify_param}
#    ...                                 connection=${alias}
#    ${status}                       coam_parameter.perform_scf_delta_commission
#    ...                                 delta_file=${para_file['updated']}
#    ...                                 timeout=${timeout}
#    ...                                 connection=${alias}
#    Dated log                       OAM Set Params:status=${status}
#    Should contain                  ${status}                               PASS
#    ...                             msg=SCF Set parameters:Status was ${status}
#    ...                             ignore_case=${True}
#    OAM wait available              oam=${oam}
#    [Return]                        ${status}
#    [Teardown]                      OAM Disconnect                          ${oam}
