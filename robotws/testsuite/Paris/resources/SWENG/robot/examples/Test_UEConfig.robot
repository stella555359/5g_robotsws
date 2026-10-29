*** Settings ***
Documentation        A test on UE configuration

Library                 OperatingSystem
Resource                ../WtsXmlConfig.robot
Resource                ../Tools.robot

*** Variables ***
${current_dir}            ${CURDIR}
@{features}
@{features2}

*** Test Cases ***

Test JIRA 94
    [Tags]    DEBUG
    ${iphy_path}                    Join Path         ${current_dir}    new_iphy.xml
    ${iphy_path_ori}                Join Path         ${current_dir}    new_iphy_ori.xml
    OperatingSystem.Copy File       ${iphy_path_ori}    ${iphy_path}
    Create Features List
    Create Features List 2
    Dated Log                       ${features}
    XmlStartSession                 path=${iphy_path}
    ${pathFieldList}                addObjectEltAll    Elt=//soap-config    name=supportedFeatures
    @{new_pathFieldList}            Evaluate                   [item + '/supportedFeatures' for item in $pathFieldList]
    Should Be True                  isinstance(${features}, list)    '${features} is not a list'
    FOR                             ${elt}    IN               @{new_pathFieldList}
                                    ${res}          addItemsFromList    pathElt=${elt}    itemlist=@{features}
                                    Dated Log                  ${res}
                                    END
    Dated Log                       features: ${features2}
    addItemsFromListAll    Elt=//identity   itemlist=@{features2}
    XmlStopSession

*** Keywords ***

Create Features List
    ${feature1}    Create Dictionary    feature=FILE_DOWNLOAD    support=1
    Append To List    ${features}    ${feature1}
    ${feature2}    Create Dictionary    feature=BEAMFORMING_PATTERNS_FILE    support=1
    Append To List    ${features}    ${feature2}
    ${feature3}    Create Dictionary    feature=BEAMFORMING_DATA_FILE_FORMAT_V1    support=0
    Append To List    ${features}    ${feature3}
    ${feature4}    Create Dictionary    feature=BEAMFORMING_DATA_FILE_FORMAT_V2    support=1
    Append To List    ${features}    ${feature4}

Create Features List 2
    ${feature1}    Create Dictionary    Hero=Superman
    Append To List    ${features2}    ${feature1}