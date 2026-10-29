*** Settings ***
Documentation
...            == Purpose ==
...            Library to manage services related to configuration files.
...
...            == Description ==
...            Proposed keywords will offer services to update elements in the following files:
...             - SCF
...             - WTS config file (basic_wts_step2.cfg)
...             - iphy.xml (or new_iphy.xml located on AP)
...
...            *Main keywords are:*
...            | =Keyword Name=                               | =Param1=      | =Param2=      | =Param3=     |
...            | Get Data From Config Xml File And Add to Scf | <cfg_file>    | <scf_file>    |
...            | Update WTS Cfg File                          | <ul_nr_arfcn> | <dl_nr_arfcn> | <ue_nr_capa> |
...            | Update Iphy Xml Cfg File | <gscn> |
...
...            *Example:*
...            |    ${scf_file_path} \ \ \ \ \ \ \ \ \ \ \ Set Variable \ \ \ \ \ \ \ ${LOGDIR}/${scf_file_name}
...            |    ${cfg_file_path} \ \ \ \ \ \ \ \ \ \ \ Set Variable \ \ \ \ \ \ \ ${LOGDIR}/${cfg_file_name}
...            |    Get Data From Config Xml File And Add to Scf \ \ \ ${cfg_file_path} \ \ \ ${scf_file_path}
...            |    Update WTS Cfg File \ \ \ \ \ \ \ \ ${test_param.nrarfcnUl}
...            |    ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ ${test_param.nrarfcnDl}
...            |    ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ ${test_param.ue_nr_capa}
...            |    Update Iphy Xml Cfg File \ \ \ ${test_param.gscn}


Library                             taf.config.wts             WITH NAME     wts_cfg
Resource                            Tools.robot
Resource                            Scf.robot
Resource                            WtsXmlConfig.robot
Resource                            WtsCfgConfig.robot

*** Variables ***

${MODULE}                           CfgFilesTools

*** Keywords ***

Get Data From Config Xml File And Add to Scf
    [Documentation]                 Get objects defined in an XML configuration file and add them to the SCF
    ...
    ...                             *Argument details:*
    ...                             - cfg_file: path to CFG file to be explored.
    ...                             - scf_file: path to SCF file to be modified.
    [Arguments]                     ${cfg_file}
    ...                             ${scf_file}
    Dated Log                       cfg_file=${cfg_file}, scf_file=${scf_file}
    XmlStartsession                 path=${cfg_file}
    SCF StartSession                scf_file=${scf_file}
    ${obj_xpath}                    Set Variable               /TestConfig/managedObject
    ${obj_list}                     getListElt                 path=${obj_xpath}
    FOR       ${obj}      IN        @{obj_list}
                                    Dated Log                  obj=${obj}
                                    Add Object To Scf          ${obj}
    END
    XmlStopSession
    SCF StopSession                 scf_file=${scf_file}


Update WTS Cfg File
    [Documentation]                 Update the nr_arfcn of the 1st "set_cell" command in the WTS basic.cfg file.
    ...                             If the parameter "ue_nr_capa" is not null then update also the parameter
    ...                             "ue_nr_capabilities" associated with the 1st command "ue_param "
    ...
    ...                             *Argument details:*
    ...                             - ul_nr_arfcn: new value for UL NR ARFCN parameter.
    ...                             - dl_nr_arfcn: new value for DL NR ARFCN parameter.
    ...                             - ue_nr_capa: new value for UE NR Capabilities parameter.
    [Arguments]                     ${ul_nr_arfcn}
    ...                             ${dl_nr_arfcn}
    ...                             ${ue_nr_capa}=${EMPTY}
    WtsCfgConfig.startSession
    ${oldValue}                     getParam            prefix=set_cell      param=nr_arfcn      ignore_comments=True
    replaceValue                    prefix=set_cell
    ...                             param=nr_arfcn
    ...                             oldValue=${oldValue}
    ...                             newValue=${ul_nr_arfcn}:${dl_nr_arfcn}
    ...                             ignore_comments=True
    Dated log                       WTS config file arfcn value changed from ${oldValue} --> ${ul_nr_arfcn}:${dl_nr_arfcn}
    Run Keyword If                  '${ue_nr_capa}'!='${EMPTY}'
    ...                             Update UeNrCapa In WtsCfg File        ${ue_nr_capa}
    WtsCfgConfig.stopSession        rename=modified


Update Iphy Xml Cfg File
    [Documentation]                 Update the "gscn" parameter in the iphy.xml file with the provided value
    ...
    ...                             *Argument details:*
    ...                             - gscn: New value for the GSCN parameter.
    [Arguments]                     ${gscn}
    WtsXmlConfig.startSession       file=iphy
    WtsXmlConfig.setListEltText     //GSCN                     ${gscn}
    WtsXmlConfig.stopSession        file=iphy


Add Object To Scf
    [Documentation]                 INTERNAL USAGE
    ...                             Add an object, read from an XML file, to the SCF
    ...
    ...                             *Argument details:*
    ...                             - obj: path. To Be Completed.
    [Arguments]                     ${obj}
    ${obj_xpath}                    Set Variable               managedObject
    ${obj_class}                    getAttrValue               attr_name=class       xmlRoot=${obj}
    Dated Log                       obj_class=${obj_class}
    ${obj_dist_name}                getAttrValue               attr_name=distName    xmlRoot=${obj}
    Dated Log                       obj_dist_name=${obj_dist_name}
    ${obj_version}                  getAttrValue               attr_name=version     xmlRoot=${obj}
    Dated Log                       obj_version=${obj_version}
    # remove the object if it's already in the SCF:
    ${obj_exist}                    SCF Is Object Exist        dist_name=${obj_dist_name}
    Run Keyword If                  ${obj_exist}               Run Keywords
    ...                             Dated Log                  Removing obj_version=${obj_version}
    ...                      AND    SCF Remove Object          dist_name=${obj_dist_name}
    # Add the object to the SCF
    SCF Add object                  class_name=${obj_class}    dist_name=${obj_dist_name}    version=${obj_version}
    # get the list of elements belonging to the object:
    ${elt_xpath}                    Set Variable               ./p
    ${elt_list}                     findAllElt                 path=${elt_xpath}     xmlRoot=${obj}
    # loop adding the elements to the object:
    FOR    ${elt}    IN    @{elt_list}
           ${attr_name}             Set Variable                  name
           ${elt_name}              getAttrValue                  attr_name=${attr_name}    xmlRoot=${elt}
           ${elt_value}             getNodeValue                  xmlRoot=${elt}
           # Dated Log                elt_name=${elt_name}, elt_value=${elt_value}
           SCF Add Element          dist_name=${obj_dist_name}    element_name=${elt_name}    element_value=${elt_value}
    END
    # get the list of list belonging to the object:
    ${list_xpath}                   Set Variable               ./list
    ${list_list}                    findAllElt                 path=${list_xpath}    xmlRoot=${obj}
    # Dated Log                       list_list=${list_list}
    # loop adding the lists to the object:
    FOR    ${list}    IN    @{list_list}
           ${attr_name}             Set Variable                         name
           ${list_name}             getAttrValue                         attr_name=${attr_name}    xmlRoot=${list}
           SCF Add List             dist_name=${obj_dist_name}           list_name=${list_name}
           ${item_xpath}            Set Variable                         ./item
           ${items}                 findAllElt                           path=${item_xpath}        xmlRoot=${list}
           Add Items To List        obj_dist_name=${obj_dist_name}       list_name=${list_name}    items=${items}
    END


Add Items To List
    [Documentation]                 INTERNAL USAGE
    ...                             Add an item to a list of items in the SCF
    ...
    ...                             *Argument details:*
    ...                             - obj_dist_name: the managed object where to find the list.
    ...                             - list_name: name of the target list.
    ...                             - item: path. To Be Completed.
    [Arguments]                     ${obj_dist_name}
    ...                             ${list_name}
    ...                             ${items}
    Dated Log                       items=${items}
    FOR    ${item}    IN    @{items}
           Add Elements To Item     obj_dist_name=${obj_dist_name}       list_name=${list_name}    item=${item}
    END


Add Elements To Item
    [Documentation]                 INTERNAL USAGE
    ...                             Add a list of elements to an item in the SCF
    ...
    ...                             *Argument details:*
    ...                             - obj_dist_name: the managed object where to find the list.
    ...                             - list_name: name of the target list.
    ...                             - item: path to cfg file.
    [Arguments]                     ${obj_dist_name}
    ...                             ${list_name}
    ...                             ${item}
    ${elt_xpath}                    Set Variable               ./p
    ${elt_list}                     findAllElt                 path=${elt_xpath}            xmlRoot=${item}
    ${elt_dict}                     Create Dictionary
    FOR    ${elt}    IN    @{elt_list}
        ${attr_name}                Set Variable               name
        ${elt_name}                 getAttrValue               attr_name=${attr_name}       xmlRoot=${elt}
        ${elt_value}                getNodeValue               xmlRoot=${elt}
        Dated Log                   elt_name=${elt_name}, item_value=${elt_value}
        Set To Dictionary           ${elt_dict}                ${elt_name}=${elt_value}
    END
    SCF Add Items To List           dist_name=${obj_dist_name}    list_name=${list_name}    elements=${elt_dict}


Update UeNrCapa In WtsCfg File
    [Documentation]                 INTERNAL USAGE
    ...                             Update the ue_nr_capacities parameter in the WTS config file (basic_wts_step2.cfg).
    ...
    ...                             *Argument details:*
    ...                             - ue_nr_capa: new UE NR Capabilities to setup.
    [Arguments]                     ${ue_nr_capa}
    ${oldValue}                     getParam                   prefix=ue_param
    ...                                                        param=ue_nr_capabilities
    ...                                                        occurrence=${1}
    ...                                                        ignore_comments=True
    replaceValue                    prefix=ue_param
    ...                             occurrence=${1}
    ...                             param=ue_nr_capabilities
    ...                             oldValue=${oldValue}
    ...                             newValue=${ue_nr_capa}
    ...                             ignore_comments=True
    Dated log                       WTS config file ue_nr_capacities value changed from ${oldValue} --> ${ue_nr_capa}

Update Arfcn in WTS Cfg multi Cell
    [Documentation]                 Update the nr_arfcn parmeter(s) in the WTS basic.cfg file for each specified cell.
    ...
    ...                             *Argument details:*
    ...                             - cells_list: list of cells dictionary with new value for UL NR ARFCN parameter / cell.
    ...                             - cells_type: type of cells to modify - can be gnb or enb (default: gnb)
    ...                             [{'id':1, 'ul_nr_arfcn':1234, 'dl_nr_arfcn':5678}, {'id':5, 'ul_nr_arfcn':0000, 'dl_nr_arfcn':2222}]
    [Arguments]                     ${cells_list}=${EMPTY}    ${cells_type}=gnb
    WtsCfgConfig.startSession
    FOR    ${cell}    IN    @{cells_list}
           ${prefix}                       set variable    set_cell id=${cell.id} ${cells_type}
           ${oldValue}                     getParam    prefix=${prefix}    param=nr_arfcn      ignore_comments=True
           replaceValue                    prefix=${prefix}
           ...                             param=nr_arfcn
           ...                             oldValue=${oldValue}
           ...                             newValue=${cell.ul_nr_arfcn}:${cell.dl_nr_arfcn}
           ...                             ignore_comments=True
    END
    WtsCfgConfig.stopSession        rename=modified

Update UeNrCapa In WTS Cfg multi UE
    [Documentation]                 Update the ue_nr_capacities parameter in the WTS config file (basic_wts_step2.cfg)
    ...                             for the specified UEs.
    ...
    ...                             *Argument details:*
    ...                             - ues_list: list of ues dictionary with new value for ue_nr_capabilities / ue.
    ...                             [{'ue':1, 'nrcapa':E120100000...000014F}, {'ue':5, 'nrcapa':ABCD11122333...32432432432}]
    [Arguments]                     ${ues_list}=${EMPTY}
    WtsCfgConfig.startSession
    FOR    ${ue}    IN    @{ues_list}
           ${prefix}                       set variable    ue_param id=${ue.ue}
           ${oldValue}                     getParam    prefix=${prefix}    param=ue_nr_capabilities    ignore_comments=True
           replaceValue                    prefix=${prefix}
           ...                             param=ue_nr_capabilities
           ...                             oldValue=${oldValue}
           ...                             newValue=${ue.nrcapa}
           ...                             ignore_comments=True
    END
    WtsCfgConfig.stopSession        rename=modified
