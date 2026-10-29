*** Settings ***
Documentation
...            == Purpose ==
...            Library to manage the main actions done on XML File
...
...            == Description ==
...            Proposed keywords will offer these services:
...             - start a modification session on an XML config file
...             - perform some get/set on some particular elements in the XML tree
...             - Add/remove some particular elements in the tree
...             - end modification session (flush modifications in file)
...
...            Main concepts for those manipulations are:
...            - tree      : this is logical tree representing all elements in their arborescency.
...            - element   : this is a particular object in the tree. It has a tag (its name), and some attributes.
...                        \ In case, this is a final element, it also has a "text", which is the value of the field.
...            - path      : this is the full sequence of element tags to reach a particular element.
...                        \ Each element in the path is separated by a "/".
...
...            *Main keywords are:*
...            | startSession    | <file> |           |         |         |
...            | setListEltText  | <path> | <val>     |         |         |
...            | setText         | <path> | <val>     | <debug> |         |
...            | removeTree      | <path> | <debug>   |         |         |
...            | AddNewTree      | <path> | <add_xml> | <pos>   | <debug> |
...            | restoreFilename |        |           |         |         |
...            | stopSession     | <file> | <upload>  |         |         |
...
...            *Example:*
...            To be completed.
...


Library           taf.transport.ssh                           WITH NAME    csn
Library           ../../../../../resources/SWENG/python/OsTool.py
Library           ../python/DedicatedXmlConfig.py             WITH NAME   DedicatedXmlConfig
Library           String

*** Variables ***
${DEDICATED_MODULE}                  DedicatedXmlConfig

*** Keywords ***

dedicated setListEltText
    [Documentation]                 Set fields matching a particular path. Here, search may lead to a list of element.
    ...                             Then, all elements will be updated with same new value
    ...
    ...                             *Argument details:*
    ...                              - path : path to search.
    ...                              - val : value to set.
    ...                              - debug : debug flag for display.
    [Arguments]                     ${path}
    ...                             ${val}
    ...                             ${debug}=${True}
    DedicatedXmlConfig.setListEltText        path=${path}         val=${val}          debug=${debug}

startSession iphy
    [Documentation]                 INTERNAL USAGE
    ...                             Start a modification session on AP iphy file.
    ...                             It will download this file locally on VM to modify it.
    ${alias}                        SSH Wait For Connect                 ${AP_DU.sys[0].M}
    ${IPHY_LOCAL_PATH}              getTempDir
    ${IPHY_REMOTE_PATH}             set variable                        /rom/simmode/iphy.xml
    Set Suite Variable              ${IPHY_LOCAL_PATH}
    ...                             ${IPHY_LOCAL_PATH}/iphy.xml
    set suite variable              ${IPHY_REMOTE_PATH}
    Dated Log                       ${DEDICATED_MODULE}.startSession : Download ${IPHY_REMOTE_PATH} in ${IPHY_LOCAL_PATH}
    ${outUpload}                    csn.download_file
    ...                             remote_path=${IPHY_REMOTE_PATH}
    ...                             local_path=${IPHY_LOCAL_PATH}
    ...                             connection=${alias}
    DedicatedXmlConfig.startSession          path=${IPHY_LOCAL_PATH}

stopSession iphy
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${upload}=${True}
    ${isModified}                   DedicatedXmlConfig.stopSession
    ${toUpload}                     Evaluate        ${isModified} and ${upload}
    Dated Log                       ${DEDICATED_MODULE}.stopSession${SPACE} : Upload ${IPHY_LOCAL_PATH}
    Dated Log                       to upload_file : ${toUpload} (upload=${upload}, modified=${isModified})

    Run Keyword if                  ${toUpload}
    ...                             csn.upload_file
    ...                                 remote_path=${IPHY_REMOTE_PATH}
    ...                                 local_path=${IPHY_LOCAL_PATH}
    ...                                 connection=${AP_DU.sys[0].M.alias}
