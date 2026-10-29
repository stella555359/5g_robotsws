*** Settings ***
Documentation
...               IPHY/WTS CFG File Management

Resource          Tools.robot
Resource          Connect.robot
Library           ../python/OsTool.py
Library           ../python/XmlConfig.py  WITH NAME   XmlConfig
Library           String
*** Variables ***
${MODULE}                           WtsXmlConfig
*** Keywords ***
startSession
    [Arguments]                     ${file}=WTS_XML
    Set Suite Variable              ${WTS_TXT_CFG_PATH}    ${tl.core.dir_path}/${tl.core.cfg_filename}
    run keyword if                  '${file}'=='WTS_XML'
    ...                             startSession WTS
    ...      ELSE                   startSession iphy

startSession iphy
    [Documentation]                 Start a modification session on AP iphy file
    ...                             It will download this file locally on VM to modify ir
    ${alias}                        SSH Wait For Connect                 ${HOST_AP_SYS0_M}
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

startSession WTS
    [Documentation]                 Start a modification session on WTS XML config file
    ...                             It will download this file locally on VM to modify ir
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

stopSession
    [Arguments]                     ${file}=WTS_XML
    ...                             ${upload}=${True}
    run keyword if                 '${file}'=='WTS_XML'
    ...                             stopSession WTS                 upload=${upload}
    ...      ELSE                   stopSession iphy                upload=${upload}

stopSession iphy
    [Arguments]                     ${upload}=${True}
    ${isModified}                   XmlConfig.stopSession
    ${toUpload}                     Evaluate        ${isModified} and ${upload}
    Dated Log                       ${MODULE}.stopSession${SPACE} : Upload ${IPHY_LOCAL_PATH}
    Dated Log                       to do : ${toUpload} (upload=${upload}, modified=${isModified})

    Run Keyword if                  ${toUpload}
    ...                             csn.upload_file
    ...                                 remote_path=${IPHY_REMOTE_PATH}
    ...                                 local_path=${IPHY_LOCAL_PATH}
    ...                                 connection=${HOST_AP_SYS0_M.alias}

stopSession WTS for beam
    [Documentation]                 Stop a modification session on WTS XML config file
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

stopSession for beam
    [Arguments]                     ${file}=WTS_XML
    ...                             ${upload}=${True}
    run keyword if                 '${file}'=='WTS_XML'
    ...                             stopSession WTS for beam                 upload=${upload}
    ...      ELSE                   stopSession iphy                         upload=${upload}

stopSession WTS
    [Documentation]                 Stop a modification session on WTS XML config file
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

XmlStartSession
    [Documentation]                 Start a modification session on a local XML file

    [Arguments]                     ${path}

    XmlConfig.startSession          path=${path}

XmlStopSession
    [Documentation]                 Stop a modification session on a local XML file

    ${isModified}                   XmlConfig.stopSession

getListAllElt
    [Documentation]                 Return list of all elements in WTS XML config file tree
    ...                             path for each element will be traces in console ONLY if debug flag is set to True
    [Arguments]                     ${debug}=${True}
    ${list}                         XmlConfig.getListAllElt     debug=${debug}
    [Return]                        ${list}

getListElt
    [Documentation]                 Get list of elements in tree matching a particular path
    [Arguments]                     ${path}
    ...                             ${debug}=${True}
    ${list}                         XmlConfig.getListElt        path=${path}        debug=${debug}
    [Return]                        ${list}

getFirstElt
    [Documentation]                 Get first element of a list of elements matching a particular path
    [Arguments]                     ${path}
    ...                             ${debug}=${True}
    ${elt}                          XmlConfig.getFirstElt       path=${path}        debug=${debug}
    [Return]                        ${elt}

getLastElt
    [Documentation]                 Get last element of a list of elements matching a particular path
    [Arguments]                     ${path}
    ...                             ${debug}=${True}
    ${elt}                          XmlConfig.getLastElt        path=${path}        debug=${debug}
    [Return]                        ${elt}

countElt
    [Documentation]                 Count the number of element matching a particular path
    [Arguments]                     ${path}
    ...                             ${debug}=${True}
    ${count}                        XmlConfig.countElt          path=${path}        debug=${debug}
    [Return]                        ${count}

getElt
    [Documentation]                 Retrieve an element matching a particular path, assuming it is unique
    ...                             if not the case (unexisting or several occurences), an exception is raised
    [Arguments]                     ${path}
    ...                             ${debug}=${True}
    ${elt}                          XmlConfig.getElt            path=${path}        debug=${debug}
    [Return]                        ${elt}

getText
    [Documentation]                 Retrieve value of a field matching a particular path, assuming it is unique
    ...                             if not the case (unexisting or several occurences), an exception is raised
    [Arguments]                     ${path}
    ...                             ${debug}=${True}
    ${text}                         XmlConfig.getText           path=${path}        debug=${debug}
    [Return]                        ${text}

getPathElt
    [Documentation]                 return full path of an element
    [Arguments]                     ${elt}
    ${path}                         XmlConfig.getPathElt        elt=${elt}
    [Return]                        ${path}

setText
    [Documentation]                 Set a field (knowing its path) to a particular value. Retrieved element is supposed to be unique
    ...                             Otherwise, an exception will be raised
    [Arguments]                     ${path}
    ...                             ${val}
    ...                             ${debug}=${True}
    XmlConfig.setText               path=${path}                val=${val}          debug=${debug}

setListEltText
    [Documentation]                 Set fields matching a particular path. Here, search may lead to a list of element
    ...                             Then, all elements will be updated with same new value
    [Arguments]                     ${path}
    ...                             ${val}
    ...                             ${debug}=${True}
    XmlConfig.setListEltText        path=${path}                val=${val}          debug=${debug}

setSubEltText
    [Documentation]                 Set a field from an element, knowing its name. This sub element is supposed to be unique
    ...                             Otherwise, an exception will be raised
    [Arguments]                     ${elt}
    ...                             ${subEltName}
    ...                             ${value}
    ...                             ${debug}=${True}
    XmlConfig.setSubEltText         elt=${elt}                  subEltName=${subEltName}
    ...                             value=${value}              debug=${debug}

addTree
    [Documentation]                 Add a sub tree by copy from an existing one. From a path, it will : retrieve the last element of the list,
    ...                             get the parent of it, add by copy a new element to the parent, then update the index
    [Arguments]                     ${path}
    ...                             ${debug}=${True}
    ${newElt}                       XmlConfig.addTree           path=${path}        debug=${debug}
    [Return]                        ${newElt}

removeTree
    [Documentation]                 remove from global tree an element knowing its path (assuming it is unique)
    [Arguments]                     ${path}
    ...                             ${debug}=${True}
    XmlConfig.removeTree            path=${path}                debug=${debug}


AddNewTree
    [Documentation]                 Add a particular tree following the desired position.if we want to add after the following si
    ...                             siblings use pos="after" else if we want to precede use pos="before"
    [Arguments]                     ${path}
    ...                             ${add_xml}
    ...                             ${pos}="after"
    ...                             ${debug}=${True}
    XmlConfig.AddNewTree            path=${path}      add_xml=${add_xml}        pos=${pos}          debug=${debug}
