*** Settings ***
Documentation
...            == Purpose ==
...            Library to manage the main actions done on WTS CFG File
...
...            == Description ==
...            Proposed keywords will offer these services:
...            - start a modification session on CFG config file
...            - perform get/set values of a specific parameters
...            - remove a configuration line from WTS CFG file
...            - insert a configuration line at a specific position on WTS CFG file
...            - replace the old value of a parameter with a new one
...            - end modification session (flush modifications in file)
...
...            *Main keywords are:*
...            | startSession       |                 |          |              |                   |              |                   |
...            | replaceValue       | <prefix>        | <param>  | <newValue>   | <oldValue>        | <occurrence> | <ignore_comments> |
...            | getParam           | <prefix>        | <param>  | <occurrence> | <ignore_comments> |              |                   |
...            | restoreFilename    |                 |          |              |                   |              |                   |
...            | setConfigLine      | <configuration> | <line>   |              |                   |              |                   |
...            | getIndexUsingParam | <prefix>        | <param>  | <paramVal>   | <ignore_comments> |              |                   |
...            | deleteConfig       | <line>          |          |              |                   |              |                   |
...            | stopSession        | <upload>        | <rename> |              |                   |              |                   |
...
...            *Example:*
...            To be completed.
...


Resource          Tools.robot
Resource          Connect.robot
Library           ../python/OsTool.py
Library           ../python/CfgConfig.py  WITH NAME   CfgConfig

*** Variables ***
${MODULE}                           WtsCfgConfig


*** Keywords ***

startSession
    [Documentation]                 Start a modification session on WTS CFG config file.
    ...                             It will download this file locally on VM to modify it.
    ${alias}                        SSH Wait For Connect                    ${HOST_EPCSIM}
    ${WTS_CFG_LOCAL_PATH}           getTempDir
    ${WTS_TXT_CFG_PATH}             set variable                            ${tl.core.dir_path}/${tl.core.cfg_filename}
    Dated Log                       ${MODULE}.startSession : Download ${tl.core.cfg_filename} in ${WTS_CFG_LOCAL_PATH}
    Set Suite Variable              ${WTS_CFG_LOCAL_PATH}
    ...                             ${WTS_CFG_LOCAL_PATH}/${tl.core.cfg_filename}
    Set Suite Variable              ${ori_cfg_filename}
    ...                             ${tl.core.cfg_filename}
    ${outUpload}                    csn.download_file
    ...                             remote_path=${WTS_TXT_CFG_PATH}
    ...                             local_path=${WTS_CFG_LOCAL_PATH}
    ...                             connection=${alias}
    CfgConfig.startSession          path=${WTS_CFG_LOCAL_PATH}

stopSession
    [Documentation]                 Stop a modification session on WTS CFG config file.
    ...                             It will upload the locally modified file on WTS.
    ...
    ...                             *Argument details:*
    ...                              - upload : If not set, or if no modification was done during session, no upload will be performed.
    ...                              - rename : extension to be added after file name and before final extension.
    [Arguments]                     ${upload}=${True}
    ...                             ${rename}=${EMPTY}
    ${isModified}                   CfgConfig.stopSession
    Run keyword if                  ${isModified} and '${rename}'!='${EMPTY}'
    ...                             RenameFileName               rename=${rename}
    Set Suite Variable              ${WTS_CFG_REMOTE_PATH}
    ...                             ${tl.core.dir_path}/${tl.core.cfg_filename}
    ${toUpload}                     Evaluate        ${isModified} and ${upload}
    Dated Log                       ${MODULE}.stopSession${SPACE} : Upload ${WTS_CFG_LOCAL_PATH} in ${WTS_CFG_REMOTE_PATH}.
    Dated Log                       To do : ${toUpload} (upload=${upload}, modified=${isModified})
    Run Keyword if                  ${toUpload}
    ...                             csn.upload_file
    ...                             remote_path=${WTS_CFG_REMOTE_PATH}
    ...                             local_path=${WTS_CFG_LOCAL_PATH}
    ...                             connection=${HOST_EPCSIM.alias}

RenameFileName
    [Documentation]                 INTERNAL USAGE
    ...                             Add <rename> extension after file name and before final extension.
    ...                             But this is NOT done if this extension is already present.
    ...                             This is to avoid having a file named : basic.modfied.modified.modified.cfg after several tests.
    [Arguments]                     ${rename}=${EMPTY}
    ${extension}                    getFileExtension             ${tl.core.cfg_filename}
    ${newExtension}                 Set variable                 .${rename}${extension}
    ${tl.core.cfg_filename}         set variable if              ${tl.core.cfg_filename.endswith("${newExtension}")}
    ...                             ${tl.core.cfg_filename}
    ...                             ${tl.core.cfg_filename.replace("${extension}","${newExtension}")}
    # Dated log                       EXTENSION=${extension} NEWEXTENSION=${newExtension} MODIFIED=${tl.core.cfg_filename}

getIndex
    [Documentation]                 Search a specific pattern in a specific line of the WTS CFG file.
    ...
    ...                             The keyword returns the index of the matching line
    ...
    ...                             *Argument details:*
    ...                              - prefix : criteria to select the line which must start with this string.
    ...                              - param : pattern to be searched in the selected line.
    ...                              - occurrence : define the occurence of the param. It could be positive or negative.
    ...                                if occurrence is positive, keyword will return the i th first occurence.
    ...                                if occurrence is negative, keyword will return the i th last occurence.
    ...                              - ignore_comments : Set to True to ignore comments in cfg file set.
    [Arguments]                     ${prefix}
    ...                             ${param}
    ...                             ${occurrence}=${1}
    ...                             ${ignore_comments}=False

    # ADT - add "occurrence" parameter
    ${index}                        cfgConfig.getIndex              prefix=${prefix}        param=${param}
    ...                             occurrence=${occurrence}        ignoreComments=${ignore_comments}
    [Return]                        ${index}

setConfigLine
    [Documentation]                 Insert a configuration at a specific line in the WTS CFG file.
    ...
    ...                             *Argument details:*
    ...                              - configuration : text to be inserted in the WTS CFG file.
    ...                              - line : specify the line number where the configuration will be inserted.
    [Arguments]                     ${configuration}
    ...                             ${line}
    CfgConfig.insertConfig          cfg=${configuration}            line=${line}

getParam
    [Documentation]                 Search a specific occurence of a parameter in a specific line of the WTS CFG file.
    ...
    ...                             The keyword returns the i th value of the parameter
    ...
    ...                             *Argument details:*
    ...                              - prefix : criteria to select the line starting with this string.
    ...                              - param : pattern to be searched in the selected line.
    ...                              - occurrence : define the occurence of the param. It could be positive or negative.
    ...                                if occurrence is positive, keyword will return the i th first occurence.
    ...                                if occurrence is negative, keyword will return the i th last occurence.
    ...                              - ignore_comments : Set to True to ignore comments in cfg file set.
    [Arguments]                     ${prefix}
    ...                             ${param}
    ...                             ${occurrence}=${1}
    ...                             ${ignore_comments}=False
    ${res}                          CfgConfig.getValue              prefix=${prefix}        param=${param}
    ...                             occurrence=${occurrence}        ignoreComments=${ignore_comments}
    [Return]                        ${res}

replaceValue
    [Documentation]                 replace the value of a parameter with a new one
    ...
    ...                             *Argument details:*
    ...                              - prefix : criteria to select the line starting with this string.
    ...                              - param : pattern to be searched in the selected line.
    ...                              - newValue : new value of the selected parameter.
    ...                              - oldValue : old value of the selected parameter.
    ...                              - occurrence : define the occurence of the param. It could be positive or negative.
    ...                                if occurrence is positive, keyword will return the i th first occurence.
    ...                                if occurrence is negative, keyword will return the i th last occurence.
    ...                              - ignore_comments : Set to True to ignore comments in cfg file set.
    [Arguments]                     ${prefix}
    ...                             ${param}
    ...                             ${newValue}
    ...                             ${oldValue}
    ...                             ${occurrence}=${1}
    ...                             ${ignore_comments}=False
    CfgConfig.replaceValue          prefix=${prefix}                param=${param}              oldValue=${oldValue}
    ...                             newValue=${newValue}            occurrence=${occurrence}    ignoreComments=${ignore_comments}

deleteConfig
    [Documentation]                 delete a configuration line from the WTS CFG file.
    ...                             Note: the line is deleted from the internal structure
    ...                                   but line is still present in the file.
    ...
    ...                             *Argument details:*
    ...                              - line : the number of the line to be deleted

    [Arguments]                     ${line}
    CfgConfig.deleteConfig          ${line}

appendConfig
    [Documentation]                 add a configuration at the end of a line in the WTS CFG file.
    ...
    ...                             *Argument details:*
    ...                              - configuration : line to be added.
    ...                              - line : the line number where to add the configuration.

    [Arguments]                     ${configuration}
     ...                            ${line}
    CfgConfig.appendConfig          cfg=${configuration}                 line= ${line}

restoreFilename
    [Documentation]                 restore the original cfg filename.
    set suite variable              ${tl.core.cfg_filename}              ${ori_cfg_filename}

appendStringToFile
    [Documentation]                 INTERNAL USAGE
    ...                             append a string to the end of file.
    [Arguments]                     ${str}
    CfgConfig.appendStringToFile    ${str}

addStringBeforeLine
    [Documentation]                 Add a string before a given line.
    ...
    ...                             *Argument details:*
    ...                              - str : string or line to be added.
    ...                              - line : regular expression corresponding to the line to be searched.
    [Arguments]                     ${str}
    ...                             ${line}
    CfgConfig.addStringBeforeLine   ${str}                               ${line}

getIndexUsingParam
    [Documentation]                 Get the index of the line corresponding to the given parameters.
    ...
    ...                             The keyword returns the index of the line containing the provided parameters.
    ...
    ...                             *Argument details:*
    ...                              - prefix : criteria to select the line which must start with this string.
    ...                              - param : pattern to be searched in the selected line.
    ...                              - paramVal : value tha the parameter must have.
    ...                              - ignore_comments : Set to True to ignore comments in cfg file set.
    [Arguments]                     ${prefix}
    ...                             ${paramId}
    ...                             ${paramVal}
    ...                             ${ignore_comments}=False
    ${res}                          CfgConfig.getIndexUsingParam         prefix=${prefix}    paramId=${paramId}
    ...                             paramVal=${paramVal}                 ignoreComments=${ignore_comments}
    [Return]                        ${res}

getConfigLineUsingIndex
    [Documentation]                 INTERNAL USAGE
    ...                             Get the config line corresponding to the index given parameters
    ...                             ${index} = line index
    [Arguments]                     ${index}
    ${res}                          CfgConfig.getConfigLineUsingIndex    index=${index}
    [Return]                        ${res}

getConfigLineUsingParam
    [Documentation]                 INTERNAL USAGE
    ...                             Get the i th config line corresponding to the given parameters.
    ...                             ${prefix} = line prefix.
    ...                             ${paramId} = param identifier.
    ...                             ${paramVal} = value of the param.
    ...                             ${ignore_comments} = set to True to ignored all comment lines.
    [Arguments]                     ${prefix}
    ...                             ${paramId}
    ...                             ${paramVal}
    ...                             ${ignore_comments}=False
    ${res}                          CfgConfig.getConfigLineUsingParam    prefix=${prefix}    paramId=${paramId}
    ...                             paramVal=${paramVal}                 ignoreComments=${ignore_comments}
    [Return]                        ${res}

getCellsList
    [Documentation]                 INTERNAL USAGE
    ...                             Get the cell list from basic.cfg.
    ...                             ${prefix} = line prefix.
    ...                             ${param} = param identifier (default: id).
    ...                             ${arfcn} = used to identify gNB or eNB - can be nr_arfcn or earfcn (default: nr_arfcn).
    [Arguments]                     ${prefix}=set_cell
    ...                             ${param}=id    ${arfcn}=nr_arfcn
    ${res}                          CfgConfig.getCellsList    prefix=set_cell
    [Return]                        ${res}

Set Cell Attachment for UE
    [Documentation]                Modify all ue in provided list to set according cell correctly.
    ...                            Check if cell exists in basic_setup.cfg file & modify it if necessary in "basic_step2_modified.cfg" file.
    ...                            *Argument details:*
    ...                            - *list_of_ue*: list of UEs dictionary containing at less ue & target_cells keys (arg is mandatory)
    [Arguments]     ${list_of_ue}
    WtsCfgConfig.startSession
    ${cell_list}    WtsCfgConfig.getCellsList
    FOR    ${ue}    IN     @{list_of_ue}
        List Should Contain Value     ${cell_list}     ${ue.target_cells}     Cell ${ue.target_cells} doesnt exists
        ${oldCell}        WtsCfgConfig.getParam    set_ue simulated id=${ue.ue}    cell    ignore_comments=True
        log to console    Doing UE id=${ue.ue} found: ${oldCell} new:${ue.target_cells}
        run keyword if    '${oldCell}' != '${ue.target_cells}'
        ...               WtsCfgConfig.replaceValue    set_ue simulated id=${ue.ue}    cell    ${ue.target_cells}
        ...               ${oldCell}    ignore_comments=True
    END
    WtsCfgConfig.stopSession    rename=modified


Get First SA UE Id
    [Documentation]                 Return the id of the first SA UE associated to the NRCELL passed in input parameter
    ...
    ...                             *Argument details:*
    ...                             - cell: string like NRCELL-x where x is the cell Id found in SCF file.
    ...                             - basic_file: full pathname to the basic.cfg file to be analyzed.
    ...                             - display: boolean to allow or not the display of created dictionary content.
    ...
    ...                             *Default values:*
    ...                              cell=NRCELL-1
    ...                              basic_file=${tl.core.dir_path}/${tl.core.cfg_filename}
    ...
    ...                             *Example:*
    ...                             ${firstSaUeOnCell2}   Get First SA UE Id   cell=NRCELL-2   basic_file=${tl.core.dir_path}/${tl.core.cfg_filename}
    ...                             With new variant, the "${Dict_1st_SA_UE_Id}[NRCELL-2]" will be setted to 21.

    [Arguments]                     ${cell}=NRCELL-1
    ...                             ${basic_file}=${tl.core.dir_path}/${tl.core.cfg_filename}
    ...                             ${display}=${False}
    Create Dict of 1rst SA UE Id    basic_file=${basic_file}        display=${display}
    [Return]                        ${Dict_1st_SA_UE_Id}[${cell}]


Create Dict of 1rst SA UE Id
    [Documentation]                 Create the ${Dict_1st_SA_UE_Id} dictionary and then display its content on console.
    ...                             This dict will contain, for each NRCell, the first SA UE Id defined for this cell.
    ...                             The construction of this dictionary is based on the basic.cfg file passed as a parameter and
    ...                             on the list of mobiles defined by TNRCELL_ID_LIST[] (ClassicalBTS case) or TNRCELL_ID_LIST_DU[] (VRAN case).
    ...
    ...                             Dictionary Usage: ${Dict_1st_SA_UE_Id}[NRCELL-X] where NRCELL-X is the cell identifier.
    ...
    ...                             *Argument details:*
    ...                             - basic_file: full pathname to the basic.cfg file to be analyzed.
    ...                             - display: boolean to allow or not the display of created dictionary content.
    ...
    ...                             *Default value:*
    ...                             - basic_file=${tl.core.dir_path}/${tl.core.cfg_filename}
    ...                             - display=${False}
    ...
    ...                             *Example:*
    ...                             With 2T+2F+AEQE LO_LO variant, the "${Dict_1st_SA_UE_Id}[NRCELL-2]" will be setted to 21.

    [Arguments]                     ${basic_file}=${tl.core.dir_path}/${tl.core.cfg_filename}
    ...                             ${display}=${False}

    &{Dict_1st_SA_UE_Id}            Create Dictionary
    # Preparation of the command to be executed on basic_file
    ${cmd_part1}                    set variable            grep -n "enb=2 cell
    ${cmd_part2}                    set variable            ${basic_file} | cut -d ' ' -f3 | sort -n| head -1 | cut -d '=' -f2
    # Get the list of cells:
    ${nrCellIdList}                 set variable if         ${isAic}    ${TNRCELL_ID_LIST_DU[0]}    ${TNRCELL_ID_LIST[0]}
    FOR   ${cell_id}   IN   @{nrCellIdList}
            Run keyword if          '${cell_id}'=='None'    Continue For Loop
            ${value}                run                     ${cmd_part1}=${cellId}" ${cmd_part2}
            ${SA_UE_id}=            Set Variable if         '${value}'==''      None    ${value}
            Set To Dictionary       ${Dict_1st_SA_UE_Id}    NRCELL-${cell_id}=${SA_UE_id}
    END
    Set Suite Variable              ${Dict_1st_SA_UE_Id}
    run keyword if                  ${display}==${True}     Show Dict of 1rst SA UE Id


Show Dict of 1rst SA UE Id
    [Documentation]                 Could be usefull for debug as it displays the content of the "First SA UEs id" dictionary.
    ...                             Display example: Dict_1st_SA_UE_Id={'NRCELL-1': '1', 'NRCELL-2': '21', 'NRCELL-3': '51', 'NRCELL-4': '71'}
    StringTool.printLineWithTitle   title=Show Dict of the first SA mobile for each cell
    ${msg_display}=                 StringTool.getHeaderLine            Dict_1st_SA_UE_Id                   ${Dict_1st_SA_UE_Id}
    dated log                       ${msg_display}
    StringTool.printLineWithTitle   title=-


Get First NSA UE Id
    [Documentation]                 Return the NSA UE Id associated to the techno (FDD or TDD) and the cell rank
    [Arguments]                     ${techno}=TDD
    ...                             ${cell_rank}=1
    ...                             ${display}=${False}

    ${nb_of_nsa_ues}                Count Nb of NSA UEs     basic_file=${tl.core.dir_path}/${tl.core.cfg_filename}
    # Return 'None' if there is no NSA UE in basic file:
    return from keyword if          ${nb_of_nsa_ues}==0     None

    Create Dict of 1rst NSA UE Id   basic_file=${tl.core.dir_path}/${tl.core.cfg_filename}   display=${display}
    ${techno_cell_nb}=              convert to integer      ${${techno}_Cell_nb}
    ${nsa_ue_list_size}=            get length              ${NSA_UE_Id_List}
    # Return 'None' if input data is inconsistent:
    return from keyword if          ${techno_cell_nb}==0 or ${cell_rank}>${nsa_ue_list_size}      None
    # input data are consistent, then do the job:
    ${cell_rank}=                   run keyword if          '${techno}'=='FDD'
    ...                                                     evaluate    ${cell_rank} - ${TDD_Cell_nb} - 1
    ...                                         ELSE        evaluate    ${cell_rank} - 1
    ${nrCellId}=                    convert to integer      ${${techno}_Cell_list[${cell_rank}].nrCellId}
    ${nrCellId}=                    evaluate                ${nrCellId} - 1
    # Return None if nrCellId is greater than the nb of NSA Ues: it is the case when basic.cfg is purged because keepAllUeDataInCfgFile=False
    return from keyword if          ${nrCellId}>${nsa_ue_list_size}                                 None
    # Return the found value:
    [Return]                        ${NSA_UE_Id_List[${nrCellId}][0]}


Count Nb of NSA UEs
    [Documentation]                 INTERNAL USAGE.
    [Arguments]                     ${basic_file}=${tl.core.dir_path}/${tl.core.cfg_filename}
    ${response}                     run                     grep "^set_ue simulated id=" ${basic_file} | grep imsi | wc -l
    [Return]                        ${response}


Create Dict of 1rst NSA UE Id
    [Documentation]                 INTERNAL USAGE.
    [Arguments]                     ${basic_file}=${tl.core.dir_path}/${tl.core.cfg_filename}
    ...                             ${display}=${False}
    @{ueid_list}=                   Create list
    ${command}                      Catenate
    ...                                 grep "^set_ue simulated id=" ${basic_file} | grep imsi |
    ...                                 awk '{print $3}' | awk -F"=" '{print $2}'
    ${response}                     run                     ${command}
    @{tmp_ids_list}                 Split string            ${response}     \n
    ${len}                          get length              ${tmp_ids_list}
    FOR    ${i}    IN RANGE    0    ${len}
        ${current}=                 Set Variable            ${tmp_ids_list[${i}]}
        ${current}=                 convert to integer      ${current}
        Append to list              ${ueid_list}            ${current}
    END
    ${NSA_UE_Id_List}=              create_nsa_ue_id_list   ${ueid_list}
    Set suite variable              ${NSA_UE_Id_List}
    run keyword if                  ${display}==${True}     Show 1rst NSA UE Ids


Show 1rst NSA UE Ids
    [Documentation]                 INTERNAL USAGE.
    ...                             Display the content of the "NSA_UE_Id_List" list.
    StringTool.printLineWithTitle   title=Show the first NSA UE for each cell
    ${list_size}=                   get length              ${NSA_UE_Id_List}
    Dated Log                       >>> Size of NSA_UE_ID_LIST = ${list_size}
    FOR    ${i}    IN RANGE    0    ${list_size}
        ${msg_display}=             StringTool.getHeaderLine            NSA_UE_Id_List[${i}]        ${NSA_UE_Id_List[${i}][0]}
        Dated log                   ${msg_display}
    END
    StringTool.printLineWithTitle   title=-

