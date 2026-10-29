*** Settings ***
Documentation
...            == Purpose ==
...            Library to manage the main actions done on WTS XML File
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


Resource          Tools.robot
Resource          Connect.robot
Library           ../python/OsTool.py
Library           ../python/XmlConfig.py  WITH NAME   XmlConfig
Library           ../python/XmlMultiCellCreator.py  WITH NAME   Creator
Library             String

*** Variables ***
${MODULE}                           WtsXmlConfig

*** Keywords ***
startSession
    [Documentation]                 Start a modification session on a WTS or AP XML config file.
    ...                             It will download this file locally on VM to modify it.
    ...
    ...                             *Argument details:*
    ...                              - file : Where to start a session: on WTS or on AP.
    [Arguments]                     ${file}=WTS_XML
    Set Suite Variable              ${WTS_TXT_CFG_PATH}    ${tl.core.dir_path}/${tl.core.cfg_filename}
    run keyword if                  '${file}'=='WTS_XML'
    ...                             startSession WTS
    ...      ELSE                   startSession iphy

startSession WTS
    [Documentation]                 INTERNAL USAGE
    ...                             Start a modification session on WTS XML config file
    ...                             It will download this file locally on VM to modify it
    ${alias}                        SSH Wait For Connect                    ${HOST_EPCSIM}
    ${cmd}                          set variable
    ...                             grep "^set_uec " ${WTS_TXT_CFG_PATH} | sed -e "s/.*file=//g" | cut -d " " -f1
    ${WTS_XML_REMOTE_FILE}          SSH Cmd                                 ${cmd}
    ...                             ${alias}
    ${isPath}  ${value}             Run Keyword And Ignore Error        Should Contain          ${WTS_XML_REMOTE_FILE}      /
    run keyword if                  '${isPath}'=='PASS'
    ...        set suite variable              ${WTS_XML_REMOTE_FILE}    ${WTS_XML_REMOTE_FILE.split("/")[-1]}
    set suite variable              ${WTS_XML_REMOTE_FILE}
    ...                             ${WTS_XML_REMOTE_FILE.replace("\n","").replace("\r","")}
    Set Suite Variable              ${WTS_XML_REMOTE_PATH}
    ...                             ${tl.core.dir_path}/${WTS_XML_REMOTE_FILE}
    ${WTS_XML_LOCAL_PATH}           getTempDir
    Set Suite Variable              ${WTS_XML_LOCAL_PATH}
    ...                             ${WTS_XML_LOCAL_PATH}/${WTS_XML_REMOTE_FILE}
    Dated Log                       ${MODULE}.startSession : Download ${WTS_XML_REMOTE_PATH} in ${WTS_XML_LOCAL_PATH}
    ${outUpload}                    csn.download_file
    ...                                 remote_path=${WTS_XML_REMOTE_PATH}
    ...                                 local_path=${WTS_XML_LOCAL_PATH}
    ...                                 connection=${alias}
    XmlConfig.startSession             path=${WTS_XML_LOCAL_PATH}

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
    Dated Log                       ${MODULE}.startSession : Download ${IPHY_REMOTE_PATH} in ${IPHY_LOCAL_PATH}
    ${outUpload}                    csn.download_file
    ...                             remote_path=${IPHY_REMOTE_PATH}
    ...                             local_path=${IPHY_LOCAL_PATH}
    ...                             connection=${alias}
    XmlConfig.startSession          path=${IPHY_LOCAL_PATH}

stopSession
    [Documentation]                 Stop a modification session on WTS or AP XML config file.
    ...                             It will upload the locally modified file on WTS or on AP.
    ...
    ...                             *Argument details:*
    ...                              - file : Where to stop a session: on WTS or on AP.
    ...                              - upload : if not set, or if no modification was done during session, no upload will be performed.
    [Arguments]                     ${file}=WTS_XML
    ...                             ${upload}=${True}
    run keyword if                 '${file}'=='WTS_XML'
    ...                             stopSession WTS                 upload=${upload}
    ...      ELSE                   stopSession iphy                upload=${upload}

stopSession WTS
    [Documentation]                 INTERNAL USAGE
    ...                             Stop a modification session on WTS XML config file
    ...                             It will upload the local file on WTS
    ...                             if <upload> flag is not set, or if no modification was done
    ...                             during session, no upload will be performed
    [Arguments]                     ${upload}=${True}
    ${isModified}                   XmlConfig.stopSession
    ${toUpload}                     Evaluate        ${isModified} and ${upload}
    Dated Log                       ${MODULE}.stopSession${SPACE} : Upload ${WTS_XML_LOCAL_PATH}
    Dated Log                       to do : ${toUpload} (upload=${upload}, modified=${isModified})
    Run Keyword if                  ${toUpload}
    ...                             csn.upload_file
    ...                                 remote_path=${WTS_XML_REMOTE_PATH}
    ...                                 local_path=${WTS_XML_LOCAL_PATH}
    ...                                 connection=${HOST_EPCSIM.alias}

stopSession iphy
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${upload}=${True}
    ${isModified}                   XmlConfig.stopSession
    ${toUpload}                     Evaluate        ${isModified} and ${upload}
    Dated Log                       ${MODULE}.stopSession${SPACE} : Upload ${IPHY_LOCAL_PATH}
    Dated Log                       to do : ${toUpload} (upload=${upload}, modified=${isModified})

    Run Keyword if                  ${toUpload}
    ...                             csn.upload_file
    ...                                 remote_path=${IPHY_REMOTE_PATH}
    ...                                 local_path=${IPHY_LOCAL_PATH}
    ...                                 connection=${AP_DU.sys[0].M.alias}

stopSession for beam
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${file}=WTS_XML
    ...                             ${upload}=${True}
    run keyword if                 '${file}'=='WTS_XML'
    ...                             stopSession WTS for beam                 upload=${upload}
    ...      ELSE                   stopSession iphy                         upload=${upload}

stopSession WTS for beam
    [Documentation]                 INTERNAL USAGE
    ...                             Stop a modification session on WTS XML config file
    ...                             It will upload the local file on WTS
    ...                             if <upload> flag is not set, or if no modification was done
    ...                             during session, no upload will be performed
    [Arguments]                     ${upload}=${True}
    ${isModified}                   XmlConfig.stopSessionafteraddingnewtree
    ${toUpload}                     Evaluate        ${isModified} and ${upload}
    Dated Log                       ${MODULE}.stopSession${SPACE} : Upload ${WTS_XML_LOCAL_PATH}
    Dated Log                       to do : ${toUpload} (upload=${upload}, modified=${isModified})
    Run Keyword if                  ${toUpload}
    ...                             csn.upload_file
    ...                                 remote_path=${WTS_XML_REMOTE_PATH}
    ...                                 local_path=${WTS_XML_LOCAL_PATH}
    ...                                 connection=${HOST_EPCSIM.alias}

XmlStartSession 
    [Documentation]                 INTERNAL USAGE
    ...                             Start a modification session on a local XML file
    [Arguments]                     ${path}
    XmlConfig.startSession          path=${path}

XmlStopSession
    [Documentation]                 INTERNAL USAGE
    ...                             Stop a modification session on a local XML file
    ${isModified}                   XmlConfig.stopSession

countElt
    [Documentation]                 INTERNAL USAGE
    ...                             Count the number of element matching a particular path
    [Arguments]                     ${path}
    ...                             ${debug}=${True}
    ${count}                        XmlConfig.countElt          path=${path}        debug=${debug}
    [Return]                        ${count}

getListAllElt
    [Documentation]                 INTERNAL USAGE
    ...                             Return list of all elements in WTS XML config file tree
    ...                             path for each element will be traces in console ONLY if debug flag is set to True
    [Arguments]                     ${debug}=${True}
    ${list}                         XmlConfig.getListAllElt     debug=${debug}
    [Return]                        ${list}

getListElt
    [Documentation]                 INTERNAL USAGE
    ...                             Get list of elements in tree matching a particular path
    [Arguments]                     ${path}
    ...                             ${debug}=${True}
    ${list}                         XmlConfig.getListElt        path=${path}        debug=${debug}
    [Return]                        ${list}

getFirstElt
    [Documentation]                 INTERNAL USAGE
    ...                             Get first element of a list of elements matching a particular path
    [Arguments]                     ${path}
    ...                             ${debug}=${True}
    ${elt}                          XmlConfig.getFirstElt       path=${path}        debug=${debug}
    [Return]                        ${elt}

getLastElt
    [Documentation]                 INTERNAL USAGE
    ...                             Get last element of a list of elements matching a particular path
    [Arguments]                     ${path}
    ...                             ${debug}=${True}
    ${elt}                          XmlConfig.getLastElt        path=${path}        debug=${debug}
    [Return]                        ${elt}

getElt
    [Documentation]                 INTERNAL USAGE
    ...                             Retrieve an element matching a particular path, assuming it is unique
    ...                             if not the case (unexisting or several occurences), an exception is raised
    [Arguments]                     ${path}
    ...                             ${debug}=${True}
    ${elt}                          XmlConfig.getElt            path=${path}        debug=${debug}
    [Return]                        ${elt}

getText
    [Documentation]                 INTERNAL USAGE
    ...                             Retrieve value of a field matching a particular path, assuming it is unique
    ...                             if not the case (unexisting or several occurences), an exception is raised
    [Arguments]                     ${path}
    ...                             ${debug}=${True}
    ${text}                         XmlConfig.getText           path=${path}        debug=${debug}
    [Return]                        ${text}

getPathElt
    [Documentation]                 INTERNAL USAGE
    ...                             return full path of an element
    [Arguments]                     ${elt}
    ${path}                         XmlConfig.getPathElt        elt=${elt}
    [Return]                        ${path}

setText
    [Documentation]                 Set a field (knowing its path) to a particular value.
    ...                             Retrieved element is supposed to be unique, otherwise, an exception will be raised.
    ...
    ...                             *Argument details:*
    ...                              - path : path to search.
    ...                              - val : value to set.
    [Arguments]                     ${path}
    ...                             ${val}
    ...                             ${debug}=${True}
    XmlConfig.setText               path=${path}                val=${val}          debug=${debug}

setListEltText
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
    XmlConfig.setListEltText        path=${path}                val=${val}          debug=${debug}

setSubEltText
    [Documentation]                 INTERNAL USAGE
    ...                             Set a field from an element, knowing its name. This sub element is supposed to be unique
    ...                             Otherwise, an exception will be raised
    [Arguments]                     ${elt}
    ...                             ${subEltName}
    ...                             ${value}
    ...                             ${debug}=${True}
    XmlConfig.setSubEltText         elt=${elt}                  subEltName=${subEltName}
    ...                             value=${value}              debug=${debug}

addTree
    [Documentation]                 INTERNAL USAGE
    ...                             Add a sub tree by copy from an existing one. From a path, it will : retrieve the last element of the list,
    ...                             get the parent of it, add by copy a new element to the parent, then update the index
    ...
    ...                             *Argument details:*
    ...                              - path : Path of element to search and copy.
    ...                              - debug : debug flag for display.
    [Arguments]                     ${path}
    ...                             ${debug}=${True}
    ${newElt}                       XmlConfig.addTree           path=${path}        debug=${debug}
    [Return]                        ${newElt}

removeTree
    [Documentation]                 remove from global tree an element knowing its path (assuming it is unique)
    ...
    ...                             *Argument details:*
    ...                              - path : Path of element to remove.
    ...                              - debug : debug flag for display.
    [Arguments]                     ${path}
    ...                             ${debug}=${True}
    XmlConfig.removeTree            path=${path}                debug=${debug}

AddNewTree
    [Documentation]                 Add a particular tree following the desired position.if we want to add after the following si
    ...                             siblings use pos="after" else if we want to precede use pos="before"
    ...
    ...                             *Argument details:*
    ...                              - path : Path of element to search.
    ...                              - add_xml : Data content xml we want to paste.
    ...                              - pos : Choose where you want to paste your data: it can be 'after' or 'before'.
    ...                              - debug : debug flag for display.
    [Arguments]                     ${path}
    ...                             ${add_xml}
    ...                             ${pos}="after"  
    ...                             ${debug}=${True}
    XmlConfig.AddNewTree            path=${path}      add_xml=${add_xml}        pos=${pos}          debug=${debug}

Iphy Create Multi Cells
    [Documentation]                 This KW is dedicated when we want to pass iphy.xml from x cells FDD to y cells FDD ,
    ...                             where y is > x
    ...                             For the moment each RE object contains 1 cell (Restricted for multiple Cells on RE obj)
    ...
    ...                             *Argument details:*
    ...                              - path : Path of iphyXml
    ...                              - cabling : eg ["1.1","1.10","2.9","2.10","3.9","3.10"] or ["1.1","2.9","3.10"]
    ...                              this corresponds of ports activs on AP side
    ...                              - suffixName: suffix you want to add in output name
    [Arguments]                     ${path}
    ...                             ${cabling}
    ...                             ${suffixName}=XmlMultiCellCreator
    ${newIphy}                      Creator.createMultipleCellIphy
    ...                             iphyBasePath=${path}      cablingAP=${cabling}    suffixName=${suffixName}
    [Return]                         ${newIphy}

Airphone Xml Create Multi Cells
    [Documentation]                 This KW is dedicated when we want to pass  airphone.xml from x cells FDD to y cells FDD , where y>x
    ...                             cells FDD , where y>x
    ...
    ...                             *Argument details:*
    ...                              - path : Path of airphone.xml
    ...                              - noOfDesiredCells : eg: 6 - it should be integer
    ...                              - suffixName: suffix you want to add in output name
    [Arguments]                     ${path}
    ...                             ${noOfDesiredCells}
    ...                             ${suffixName}=XmlMultiCellCreator
    ${newApXml}                     Creator.createMultipleCellApXml
    ...                             apXmlBasePath=${path}      noOfCells=${noOfDesiredCells}    suffixName=${suffixName}
    [Return]                         ${newApXml}

Basic Cfg Create Multi Cells
    [Documentation]                 This KW is dedicated when we want to pass  basic_setup.cfg from x cells FDD to y cells FDD , where y>x
    ...                             cells FDD , where y>x
    ...
    ...                             *Argument details:*
    ...                              - path : Path of basic_setup.cfg
    ...                              - noOfDesiredCells : eg: 6 - it should be integer
    ...                              - suffixName: suffix you want to add in output name
    [Arguments]                     ${path}
    ...                             ${noOfDesiredCells}
    ...                             ${suffixName}=XmlMultiCellCreator
    ${newBasicCfg}                  Creator.createMultipleCellBasicCfg
    ...                             basicCfgBasePath=${path}      noOfCells=${noOfDesiredCells}    suffixName=${suffixName}
    [Return]                         ${newBasicCfg}

