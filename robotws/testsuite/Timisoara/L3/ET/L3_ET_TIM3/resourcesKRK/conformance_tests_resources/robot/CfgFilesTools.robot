*** Settings ***

# This module provides KWs that can be used for updating below configuration files
#    - SCF
#    - WTS config file (basic_wts_step2.cfg)
#    - iphy.xml (or new_iphy.xml located on AP)

Library           taf.config.wts                WITH NAME     wts_cfg

Resource          Tools.robot
Resource          Scf.robot
Resource          WtsXmlConfig.robot
Resource          WtsCfgConfig.robot

*** Variables ***

${MODULE}    CfgFilesTools

*** Keywords ***

Get Data From Config Xml File And Add to Scf
    [Documentation]   Get objects defined in an XML configuration file and add them to the SCF

    [Arguments]    ${cfg_file}
    ...            ${scf_file}

    Dated Log    cfg_file=${cfg_file}, scf_file=${scf_file}

    XmlStartsession     path=${cfg_file}

    SCF StartSession    scf_file=${scf_file}

    ${obj_xpath}    Set Variable    /TestConfig/managedObject

    ${obj_list}    getListElt   path=${obj_xpath}
 
    FOR    ${obj}    IN    @{obj_list}
        Dated Log    obj=${obj}
        Add Object To Scf    ${obj}
    END 

    XmlStopSession

    SCF StopSession    scf_file=${scf_file}


Add Object To Scf
    [Documentation]   Add an object, read from an XML file, to the SCF

    [Arguments]    ${obj}

    ${obj_xpath}    Set Variable    managedObject

    ${obj_class}    getAttrValue    attr_name=class    xmlRoot=${obj}
    Dated Log    obj_class=${obj_class}

    ${obj_dist_name}    getAttrValue    attr_name=distName    xmlRoot=${obj}
    Dated Log    obj_dist_name=${obj_dist_name}

    ${obj_version}    getAttrValue    attr_name=version    xmlRoot=${obj}
    Dated Log    obj_version=${obj_version}

    # remove the object if it's already in the SCF
    ${obj_exist}    SCF Is Object Exist    dist_name=${obj_dist_name}
    Run Keyword If     ${obj_exist}    Run Keywords
    ...    Dated Log    Removing obj_version=${obj_version}
    ...    AND    SCF Remove Object    dist_name=${obj_dist_name}

    # Add the object to the SCF
    SCF Add object    class_name=${obj_class}    dist_name=${obj_dist_name}    version=${obj_version}
    
    # get the list of elements belonging to the object
    ${elt_xpath}    Set Variable    ./p

    ${elt_list}    findAllElt    path=${elt_xpath}    xmlRoot=${obj}

    # loop adding the elements to the object
    FOR    ${elt}    IN    @{elt_list}
        ${attr_name}    Set Variable    name
        ${elt_name}    getAttrValue    attr_name=${attr_name}    xmlRoot=${elt}
        ${elt_value}    getNodeValue    xmlRoot=${elt}
        # Dated Log    elt_name=${elt_name}, elt_value=${elt_value}
        SCF Add Element    dist_name=${obj_dist_name}    element_name=${elt_name}    element_value=${elt_value}
    END

    # get the list of list belonging to the object
    ${list_xpath}    Set Variable    ./list
    ${list_list}    findAllElt    path=${list_xpath}    xmlRoot=${obj}
    # Dated Log    list_list=${list_list}

    # loop adding the lists to the object
    FOR    ${list}    IN    @{list_list}
        ${attr_name}    Set Variable    name
        ${list_name}    getAttrValue    attr_name=${attr_name}    xmlRoot=${list}
        SCF Add List    dist_name=${obj_dist_name}    list_name=${list_name}
        ${item_xpath}    Set Variable    ./item
        ${items}    findAllElt    path=${item_xpath}    xmlRoot=${list}
        Add Items To List    obj_dist_name=${obj_dist_name}    list_name=${list_name}    items=${items}
    END


Add Items To List
    [Documentation]   Add an item to a list of items in the SCF

    [Arguments]     ${obj_dist_name}
    ...             ${list_name}
    ...             ${items}

    Dated Log    items=${items}
    FOR    ${item}    IN    @{items}
        Add Elements To Item     obj_dist_name=${obj_dist_name}    list_name=${list_name}    item=${item}
    END


Add Elements To Item
    [Documentation]   Add a list of elements to an item in the SCF

    [Arguments]     ${obj_dist_name}
    ...             ${list_name}
    ...             ${item}

    ${elt_xpath}    Set Variable    ./p
    ${elt_list}    findAllElt    path=${elt_xpath}    xmlRoot=${item}

    ${elt_dict}     Create Dictionary

    FOR    ${elt}    IN    @{elt_list}
        ${attr_name}    Set Variable    name
        ${elt_name}    getAttrValue    attr_name=${attr_name}    xmlRoot=${elt}
        ${elt_value}    getNodeValue    xmlRoot=${elt}
        Dated Log    elt_name=${elt_name}, item_value=${elt_value}
        Set To Dictionary    ${elt_dict}   ${elt_name}=${elt_value}
    END

    SCF Add Items To List    dist_name=${obj_dist_name}    list_name=${list_name}    elements=${elt_dict}


Update UeNrCapa In WtsCfg File
    [Documentation]   Update the ue_nr_capacities parameter in the WTS config file (basic_wts_step2.cfg)

    [Arguments]    ${ue_nr_capa}

    ${oldValue}      getParam    prefix=ue_param    param=ue_nr_capabilities    occurrence=${1}    ignore_comments=True
    replaceValue     prefix=ue_param    occurrence=${1}
    ...              param=ue_nr_capabilities
    ...              oldValue=${oldValue}
    ...              newValue=${ue_nr_capa}
    ...              ignore_comments=True
    Dated log        WTS config file ue_nr_capacities value changed from ${oldValue} --> ${ue_nr_capa}


Update WTS Cfg File
    [Documentation]   Update the nr_arfcn of the 1st "set_cell" command in the WTS basic.cfg file
    ...               If the parameter "ue_nr_capa" is not null then update also the parameter
    ...               "ue_nr_capabilities" associated with the 1st command "ue_param "

    [Arguments]    ${ul_nr_arfcn}
    ...            ${dl_nr_arfcn}
    ...            ${ue_nr_capa}=${EMPTY}

    WtsCfgConfig.startSession

    ${oldValue}          getParam           prefix=set_cell          param=nr_arfcn    ignore_comments=True
    replaceValue         prefix=set_cell
    ...                  param=nr_arfcn
    ...                  oldValue=${oldValue}
    ...                  newValue=${ul_nr_arfcn}:${dl_nr_arfcn}
    ...                  ignore_comments=True
    Dated log            WTS config file arfcn value changed from ${oldValue} --> ${ul_nr_arfcn}:${dl_nr_arfcn}

    Run Keyword If    '${ue_nr_capa}'!='${EMPTY}'    Update UeNrCapa In WtsCfg File    ${ue_nr_capa}

    WtsCfgConfig.stopSession    rename=modified


Update Iphy Xml Cfg File
    [Documentation]   Update the "gscn" parameter in the iphy.xml file with the provided value
    [Arguments]    ${gscn}

    WtsXmlConfig.startSession           file=iphy
    WtsXmlConfig.setListEltText         //GSCN                          ${gscn}
    WtsXmlConfig.stopSession            file=iphy

