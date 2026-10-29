*** Settings ***
Documentation       Set of kewords to do wtscfgconfig operation
Resource          ./Tools.robot
Resource          ./Connect.robot
Library           ../python/OsTool.py
Library           ../python/CfgConfig.py  WITH NAME   CfgConfig

*** Variables ***
${MODULE}                           WtsCfgConfig


*** Keywords ***

startSession
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
    [Documentation]                 Stop a modification session on WTS CFG config file
    ...                             It will upload the local file on WTS
    ...                             if <upload> flag is not set, or if no modification was done
    ...                             during session, no upload will be performed
    [Arguments]                     ${upload}=${True}
    ...                             ${rename}=${EMPTY}
    ${isModified}                   CfgConfig.stopSession
    Run keyword if                  ${isModified}
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
    [Documentation]                 Add <rename> extension after file name and before final extension
    ...                             But this is NOT done if this extension is already present
    ...                             This is to avoid having a file named : basic.modfied.modified.modified.cfg after several tests
    [Arguments]                     ${rename}=${EMPTY}
    ${extension}                    getFileExtension             ${tl.core.cfg_filename}
    ${newExtension}                 Set variable                 .${rename}${extension}
    ${tl.core.cfg_filename}         set variable if              ${tl.core.cfg_filename.endswith("${newExtension}")}
    ...                             ${tl.core.cfg_filename}
    ...                             ${tl.core.cfg_filename.replace("${extension}","${newExtension}")}
    # Dated log                       EXTENSION=${extension} NEWEXTENSION=${newExtension} MODIFIED=${tl.core.cfg_filename}

getIndex
    [Documentation]                 return the line of a parameter according to its occurrence
    ...                             if occurrence =1 , it returns the first occurrence of the parameter according to the prefix
    ...                             if occurrence =-1, it returns the last occurrence of the parameter according to the prefix
    ...                             to ignore comments in cfg file set : ${ignore_comments} to True
    [Arguments]                     ${prefix}
    ...                             ${param}
    ...                             ${occurrence}=${1}
    ...                             ${ignore_comments}=False

    # ADT - add "occurrence" parameter
    ${index}                        cfgConfig.getIndex              prefix=${prefix}            param=${param}
    ...                             occurrence=${occurrence}        ignoreComments=${ignore_comments}
    [Return]                        ${index}

setConfigLine
    [Documentation]                 insert a configuation at a specific line on the WTS CFG file
    [Arguments]                     ${configuration}
    ...                             ${line}
    CfgConfig.insertConfig          cfg=${configuration}            line=${line}

getParam
    [Documentation]                 get the i th value of a parameter
    ...                             i : is set with ${occurrence}
    ...                             if occurrence is negative it returns the i th last occurrence
    ...                             to ignore comments in cfg file set : ${ignore_comments} to True

    [Arguments]                     ${prefix}
    ...                             ${param}
    ...                             ${occurrence}=${1}
    ...                             ${ignore_comments}=False
    ${res}                          CfgConfig.getValue              prefix=${prefix}        param=${param}
    ...                             occurrence=${occurrence}            ignoreComments=${ignore_comments}
    [Return]                        ${res}

replaceValue
    [Documentation]                 replace the value of a parameter with a new one
    [Arguments]                     ${prefix}
    ...                             ${param}
     ...                            ${newValue}
     ...                            ${oldValue}
     ...                            ${occurrence}=${1}
     ...                            ${ignore_comments}=False
     CfgConfig.replaceValue         prefix=${prefix}                param=${param}           oldValue=${oldValue}
     ...                            newValue=${newValue}            occurrence=${occurrence}        ignoreComments=${ignore_comments}

deleteConfig
    [Documentation]                 delete a line from the configuration
    ...                             Note: the line is deleted from the internal structure
    ...                                   but still present in the file
    ...                             ${line} = the number of the line to be deleted

    [Arguments]                     ${line}
    CfgConfig.deleteConfig          ${line}

appendConfig
    [Documentation]                 add a configuration at the end of a line
    ...                             ${configuration} = line to be added
    ...                             ${line} = the line number where to add the configuration

    [Arguments]                     ${configuration}
     ...                            ${line}

    CfgConfig.appendConfig          cfg=${configuration}             line= ${line}

restoreFilename
    [Documentation]                 restore the original cfg filename

    set suite variable              ${tl.core.cfg_filename}          ${ori_cfg_filename}

appendStringToFile
    [Documentation]                 append a string to the end of file
    [Arguments]                     ${str}

    CfgConfig.appendStringToFile    ${str}

addStringBeforeLine
    [Documentation]                 Add a string before a given line
    ...                             ${str} = string/line to be added
    ...                             ${line} = regular expression corresponding to the line
    ...                                       being searched in the config file

    [Arguments]    ${str}
    ...            ${line}

    CfgConfig.addStringBeforeLine     ${str}    ${line}

getIndexUsingParam
    [Documentation]                 Get the index of the line corresponding to the given parameters
    ...                             ${prefix} = line prefix
    ...                             ${paramId} = param identifier
    ...                             ${paramVal} = value of the param
    ...                             ${ignore_comments} = set to True to ignored all comment lines

    [Arguments]                     ${prefix}
    ...                             ${paramId}
    ...                             ${paramVal}
    ...                             ${ignore_comments}=False

    ${res}                          CfgConfig.getIndexUsingParam    prefix=${prefix}    paramId=${paramId}
    ...                             paramVal=${paramVal}            ignoreComments=${ignore_comments}

    [Return]                        ${res}

getConfigLineUsingIndex
    [Documentation]                 Get the config line corresponding to the index given parameters
    ...                             ${index} = line index

    [Arguments]                     ${index}

    ${res}                          CfgConfig.getConfigLineUsingIndex    index=${index}

    [Return]                        ${res}

getConfigLineUsingParam
    [Documentation]                 Get the i th config line corresponding to the given parameters
    ...                             ${prefix} = line prefix
    ...                             ${paramId} = param identifier
    ...                             ${paramVal} = value of the param
    ...                             ${ignore_comments} = set to True to ignored all comment lines

    [Arguments]                     ${prefix}
    ...                             ${paramId}
    ...                             ${paramVal}
    ...                             ${ignore_comments}=False

    ${res}                          CfgConfig.getConfigLineUsingParam    prefix=${prefix}    paramId=${paramId}
    ...                             paramVal=${paramVal}                 ignoreComments=${ignore_comments}
    [Return]                        ${res}

