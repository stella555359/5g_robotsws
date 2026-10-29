*** Settings ***
Documentation
...            == Purpose ==
...            Library to manage all SCF services.
...
...            == Description ==
...            Proposed keywords will offer services to create/modify/delete elements in a *SCF* or *NIDD* file.
...
...            - The first step is to start a session in order to load in volatile memory the SCF file to be modifed.
...            - The last step is to Stop the session in order to save the new SCF.
...
...            *Main keywords are:*
...            | =Keyword Name=          | =Param1=    | =Param2=       | =Param3=        | =Param4=        |
...            | SCF StartSession        | <scf_file>  |
...            | SCF Set element         | <dist_name> | <element_name> | <element_value> |
...            | SCF Set element in list | <dist_name> | <list_name>    | <element_name>  | <element_value> |
...            | SCF Add items to list   | <dist_name> | <list_name>    | <elements>      |
...            | SCF Add list            | <dist_name> | <list_name>    |
...            | SCF Remove list         | <dist_name> | <list_name>    |
...            | SCF StopSession         | <scf_file>  |
...
...            *Example:*
...            - Start a session by loading a SCF file named *initial_SCF_File*.
...            - Then remove a list, create the same list in order to set items and element in this new empty list.
...            - Close the session by saving the new SCF in a new file named *modified_SCF_File*.
...            | SCF StartSession \ \ \ \ \ \ \ scf_file=${initial_SCF_File}
...            | SCF Remove list \ \ \ \ \ \ \ \ dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
...            | \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ list_name=tddFrameStructure
...            | SCF Add list \ \ \ \ \ \ \ \ \ \ \ dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
...            | \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ list_name=tddFrameStructure
...            | SCF Add items to list \ \ dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
...            | \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ list_name=tddFrameStructure
...            | \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ elements=${tdLte_fs}
...            | SCF Set element \ \ \ \ \ \ \ \ dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
...            | \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ element_name=prachConfigurationIndex
...            | \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ element_value=96
...            | SCF StopSession \ \ \ \ \ \ \ \ scf_file=${modified*_SCF_File}
...
...            *New for AIC:*
...            The param scope and aicListEntity are for AIC technology, could be ignored in classical case.
...            - aicListEntity: specifies the AIC application entity (vdu, vcu or vcuvdu).
...            - scope: specifies the techno entity (classical, aic or both).
...            eg: if same robot is applied to both aic and classical, and there is a parameter in scf specific to aic, u need to set as follows:
...            aicEntityList=vduvcu scope=aic.
...                if same robot is applied to both aic and classical, and there is a parameter in scf specific to classical, need to set as follows:
...            aicEntityList=none scope=classical.
...                if same robot is applied to both aic and classical, and there is a parameter in scf applicable to both classical and aic,
...                you need to set as follows:
...            aicEntityList=vcu scope=both (aiclistentity is ignored when in classical).

Library                             taf.config.scf   WITH NAME      scf
#Resource                             ../NPS/SWENG/robot/Tools.robot
#Resource                            ../NPS/SWENG/robot/Oam.robot
Library                             ../python/XmlScf.py
Library                             ../python/ScfMultiCellsCreator.py
#Library                             ../python/MultiScf.py   WITH NAME     multiscf

*** Keywords ***

SCF StartSession
    [Documentation]                 starts a modification session on local scf file.
    ...
    ...                             Data will be stored in volatile memory,
    ...                             loaded file will not be edited until "SCF StopSession" keyword call.
    ...
    ...                             *Argument details:*
    ...                             - scf_file: path to SCF file to be loaded. (classical or vdu in AIC case).
    ...                             - second_scf_file: path of VCU SCF file to be loaded. (only AIC).
    [Arguments]                     ${scf_file}=${None}    ${second_scf_file}=${None}
    set suite variable              ${scf_file}
    multiscf.load_scf               scf_path=${scf_file}    second_scf_path=${second_scf_file}


SCF StopSession
    [Documentation]                 Save all changes.
    ...
    ...                             If another path than the one given during the load operation is given,
    ...                             then a new file will be created, the old one remaining unchanged.
    ...
    ...                             *Argument details:*
    ...                             - scf_file: path to new SCF file to be generated. (classical or vdu in AIC case)
    ...                             - second_scf_file: path of VCU SCF file to be loaded. (only AIC)
    [Arguments]                     ${scf_file}=${None}    ${second_scf_file}=${None}
    multiscf.save_scf               file_path=${scf_file}    second_file_path=${second_scf_file}
    Dated Log                       Saved SCF: ${scf_file} and ${second_scf_file}

SCF Add list
    [Documentation]                 Adds an empty list to object in loaded SCF file.
    ...                             The object is mapped by the attribute dist_name.
    ...
    ...                             Changes are saved only after 'SCF StopSession' keyword call.
    ...
    ...                             *Argument details:*
    ...                             - dist_name: the managed object where to add list_name.
    ...                             - list_name: name of the new list.
    ...                             - aicListEntity: can be None (default value), Vdu, Vcu or VduVcu (specifies the application entity).
    ...                             - scope: can be classical (for classical only, default value) or aic (for aic only) or both.
    ...
    ...                             Note: in <managedObject> as ‘distName’, SBTS prefix can be ommited.
    ...                             \ne.g.: both ‘SBTS-1900/NGNODEB-1’ and ‘NGNODE-1’ are valid and equivalent.
    [Arguments]                     ${dist_name}
    ...                             ${list_name}
    ...                             ${aicListEntity}=None
    ...                             ${scope}=Classical
    multiscf.add_list_to_scf        dist_name=${dist_name}    list_name=${list_name}
    ...                             aicListEntity=${aicListEntity}     scope=${scope}
    Dated Log                       New list : ${list_name} is added to :${scf_file} using the distname : ${dist_name}


SCF Add items to list
    [Documentation]                 Adds the items from elements dictionary (name, value) to the list in object in loaded SCF.
    ...                             The object is mapped by the attribute dist_name.
    ...
    ...                             Changes are saved only after 'SCF StopSession' keyword call.
    ...
    ...                             *Argument details:*
    ...                             - dist_name: the managed object where to find the list.
    ...                             - list_name: name of the target list.
    ...                             - elements: dictionary of elements added to the list,
    ...                                         key is an element name, value is an element value.
    ...                             - aicListEntity: can be None (default value), Vdu, Vcu or VduVcu (specifies the application entity).
    ...                             - scope: can be: classical (for classical only, default value) or aic (for aic only) or both.
    ...
    ...                             Note: in <managedObject> as ‘distName’, SBTS prefix can be ommited
    ...                             \ne.g.: both ‘SBTS-1900/NGNODEB-1’ and ‘NGNODE-1’ are valid and equivalent.
    [Arguments]                     ${dist_name}
    ...                             ${list_name}
    ...                             ${elements}
    ...                             ${aicListEntity}=None
    ...                             ${scope}=Classical
    multiscf.add_item_to_list       dist_name=${dist_name}    list_name=${list_name}   elements=${elements}
    ...                             aicListEntity=${aicListEntity}     scope=${scope}
    Dated Log                       New item=(${elements}) is added to liste=(${list_name})

SCF Add elements to list
    [Documentation]                 Adds the elements from elements list to the list in object in loaded SCF.
    ...                             The object is mapped by the attribute dist_name.
    ...
    ...                             Changes are saved only after 'SCF StopSession' keyword call.
    ...
    ...                             *Argument details:*
    ...                             - dist_name: the managed object where to add elements.
    ...                             - list_name: name of the target list.
    ...                             - elements: list of elements to add to the target list.
    ...                             - aicListEntity: can be None (default value), Vdu, Vcu or VduVcu (specifies the application entity).
    ...                             - scope: can be: classical (for classical only, default value) or aic (for aic only) or both.
    ...                             Note: in <managedObject> as ‘distName’, SBTS prefix can be ommited
    ...                             \ne.g.: both ‘SBTS-1900/NGNODEB-1’ and ‘NGNODE-1’ are valid and equivalent.
    [Arguments]                     ${dist_name}
    ...                             ${list_name}
    ...                             ${elements}
    ...                             ${aicListEntity}=None
    ...                             ${scope}=Classical
    multiscf.add_elements_to_list   dist_name=${dist_name}    list_name=${list_name}   elements=${elements}
    ...                             aicListEntity=${aicListEntity}     scope=${scope}
    Dated Log                       New item=(${elements}) is added to liste=(${list_name})

SCF Add object
    [Documentation]                 Adds whole managedObject to loaded SCF.
    ...                             All parameters are mandatory and are added as attributes to the object.
    ...
    ...                             Changes are saved only after 'SCF StopSession' keyword call.
    ...
    ...                             *Argument details:*
    ...                             - dist_name: the managed object where to add elements.
    ...                             - class_name: added as attribute 'class'.
    ...                             - version: added as attribute 'version'.
    ...                             - aicListEntity: can be None (default value), Vdu, Vcu or VduVcu (specifies the application entity).
    ...                             - scope: can be: classical (for classical only, default value) or aic (for aic only) or both.
    [Arguments]                     ${dist_name}
    ...                             ${class_name}
    ...                             ${version}
    ...                             ${aicListEntity}=None
    ...                             ${scope}=Classical
    multiscf.add_object_to_scf      class_name=${class_name}      dist_name=${dist_name}        version=${version}
    ...                             aicListEntity=${aicListEntity}     scope=${scope}
    Dated Log                       new object is added with class_name=(${class_name}) \n
    Dated Log                       version=(${version}) \n dist_name=(${dist_name})

SCF Add element
    [Documentation]                 Adds element to object in loaded SCF.
    ...                             The object is mapped by the attribute dist_name.
    ...                             The element is added at the end of list of objects children.
    ...
    ...                             Changes are saved only after 'SCF StopSession' keyword call.
    ...
    ...                             *Argument details:*
    ...                             - dist_name: the managed object where to add element.
    ...                             - element_name: name of attribute of new element.
    ...                             - element_value: value of new element.
    ...                             - aicListEntity: can be None (default value), Vdu, Vcu or VduVcu (specifies the application entity).
    ...                             - scope: can be: classical (for classical only, default value) or aic (for aic only) or both.
    [Arguments]                     ${dist_name}
    ...                             ${element_name}
    ...                             ${element_value}
    ...                             ${aicListEntity}=None
    ...                             ${scope}=Classical
    multiscf.add_element_to_scf     dist_name=${dist_name}       p_name=${element_name}    value=${element_value}
    ...                             aicListEntity=${aicListEntity}     scope=${scope}
    Dated Log                       new element is added : element_name= (${element_name}) \n
    Dated Log                       element_value=(${element_value}) \n dist_name=(${dist_name})

SCF Remove list
    [Documentation]                 Removes list from loaded SCF inside managed object indicated in ‘dist_name’.
    ...
    ...                             *Argument details:*
    ...                             - dist_name: the managed object where to remove list.
    ...                             - list_name: name of attribute in list tag.
    ...                             - aicListEntity: can be None (default value), Vdu, Vcu or VduVcu (specifies the application entity).
    ...                             - scope: can be: classical (for classical only, default value) or aic (for aic only) or both.
    [Arguments]                     ${dist_name}
    ...                             ${list_name}
    ...                             ${aicListEntity}=None
    ...                             ${scope}=Classical
    Run Keyword And Ignore Error    multiscf.remove_list_from_scf        dist_name=${dist_name}    list_name=${list_name}
    ...                             aicListEntity=${aicListEntity}     scope=${scope}
    Dated Log                       list=(${list_name}) is removed

SCF Remove element
    [Documentation]                 Removes elements from loaded SCF file. Attributes are mapped to SCF element’s attributes.
    ...                             If element_name or index is given it removes only single element.
    ...                             If not the whole managedObject is removed.
    ...
    ...                             Changes are saved only after 'SCF StopSession' keyword call.
    ...
    ...                             *Argument details:*
    ...                             - dist_name: the managed object where to remove list.
    ...                             - element_name: name of attribute in list tag.
    ...                             - index : optional argument. Should be used if more than one match expected.
    ...                                       Indexing starts from 0.
    ...                                       If not given and param element_name not given, the whole managedObject is removed.
    ...                             - aicListEntity: can be None (default value), Vdu, Vcu or VduVcu (specifies the application entity).
    ...                             - scope: can be: classical (for classical only, default value) or aic (for aic only) or both.
    [Arguments]                     ${dist_name}
    ...                             ${element_name}
    ...                             ${index}=0
    ...                             ${aicListEntity}=None
    ...                             ${scope}=Classical
    multiscf.remove_element_from_scf     dist_name=${dist_name}      p_name=${element_name}       index=${index}
    ...                             aicListEntity=${aicListEntity}     scope=${scope}
    Dated Log                       Element=(${element_name}) is removed

SCF Set element
    [Documentation]                 Modify Element value. Attributes are mapped to SCF element’s attributes.
    ...                             Raises exception if more or less than one element found.
    ...
    ...                             *Argument details:*
    ...                             - dist_name: the managed object where to find element_name.
    ...                             - element_name: name of attribute.
    ...                             - element_value: new value.
    ...                             - aicListEntity: can be None (default value), Vdu, Vcu or VduVcu (specifies the application entity).
    ...                             - scope: can be: classical (for classical only, default value) or aic (for aic only) or both.
    ...                             - bestEffort: is used in AIC only to modify element if present in both Vdu or/and Vcu (default: False).
    [Arguments]                     ${dist_name}
    ...                             ${element_name}
    ...                             ${element_value}
    ...                             ${aicListEntity}=vduvcu
    ...                             ${scope}=Both
    ...                             ${bestEffort}=${False}
    run keyword if                  ${isAic}               run keywords
    ...                             multiscf.modify_scf_element
    ...                                                                   dist_name=${dist_name}
    ...                                                                   p_name=${element_name}
    ...                                                                   value=${element_value}
    ...                                                                   bestEffort=${bestEffort}
    ...                                                                   aicListEntity=${aicListEntity}
    ...                                                                   scope=${scope}
    ...      AND                    return from keyword
    ${result}    ${msg} =           Run Keyword And Ignore Error          multiscf.modify_scf_element
    ...                                                                   dist_name=${dist_name}
    ...                                                                   p_name=${element_name}
    ...                                                                   value=${element_value}
    ...                                                                   bestEffort=${bestEffort}
    ...                                                                   aicListEntity=VDU
    ...                                                                   scope=classical
    return from keyword if          '${result}' == 'PASS'
    Run Keyword If                  '${result}' is None or '${result}' == 'FAIL'
    ...                             multiscf.add_element_to_scf
    ...                                 dist_name=${dist_name}
    ...                                 p_name=${element_name}
    ...                                 value=${element_value}
    ...                                 aicListEntity=VDU
    ...                                 scope=classical

SCF Set element in List
    [Documentation]                 Modify or Add element value in list. Attributes are mapped to SCF element’s attributes.
    ...                             Raises exception if more or less than one element found.
    ...
    ...                             *Argument details:*
    ...                             - dist_name: the managed object where to find element_name.
    ...                             - list_name: ‘name’ attribute in <list> tag.
    ...                             - element_name: name of attribute.
    ...                             - element_value: new value.
    ...                             - aicListEntity: can be None (default value), Vdu, Vcu or VduVcu (specifies the application entity).
    ...                             - scope: can be: classical (for classical only, default value) or aic (for aic only) or both.
    [Arguments]                     ${dist_name}
    ...                             ${list_name}
    ...                             ${element_name}
    ...                             ${element_value}
    ...                             ${aicListEntity}=None
    ...                             ${scope}=Classical
    ${elements}                     create dictionary                       ${element_name}=${element_value}
    run keyword if                  ${isAic}               run keywords
    ...                              multiscf.modify_scf_element
    ...                                 dist_name=${dist_name}
    ...                                 list_name=${list_name}
    ...                                 p_name=${element_name}
    ...                                 value=${element_value}
    ...                                 aicListEntity=${aicListEntity}    scope=${scope}
    ...      AND                    return from keyword
    ${result_modify}    ${msg}      Run Keyword And Ignore Error
    ...                             multiscf.modify_scf_element
    ...                                 dist_name=${dist_name}
    ...                                 list_name=${list_name}
    ...                                 p_name=${element_name}
    ...                                 value=${element_value}
    ...                                 aicListEntity=${aicListEntity}    scope=${scope}
    return from keyword if          '${result_modify}' == 'PASS'
    ${result_list_check}            multiscf.is_list_in_object
    ...                                 dist_name=${dist_name}              list_name=${list_name}
    ...                                 aicListEntity=${aicListEntity}    scope=${scope}
    Run Keyword Unless              ${result_list_check}
    ...                             multiscf.add_list_to_scf
    ...                                 dist_name=${dist_name}
    ...                                 list_name=${list_name}
    ...                                 aicListEntity=${aicListEntity}    scope=${scope}
    Run Keyword Unless              ${result_list_check}
    ...                             multiscf.add_item_to_list
    ...                                 dist_name=${dist_name}
    ...                                 list_name=${list_name}
    ...                                 elements=${elements}
    ...                                 aicListEntity=${aicListEntity}    scope=${scope}
    # Add case of failure because more than one element were found
    ${isMultiple}                   Evaluate                                str(${msg.startswith("MultipleMatches:")})
    ${action}                       set variable if                         '${isMultiple}'=='True'
    ...                             modify                                  add
    @{mod_string}=                  Create List
    ...                             ${action}:${dist_name}:${list_name}:${element_name}=${element_value}
    Run Keyword If                  '${result_modify}' is None or '${result_modify}' == 'FAIL'
    ...                             multiscf.perform_scf_modification            modification_strings=@{mod_string}
    ...                             aicListEntity=${aicListEntity}    scope=${scope}

SCF Is Object Exist
    [Documentation]                 Checks whether given object exists in loaded SCF.
    ...                             The object is mapped by the attribute distName.
    ...
    ...                             The keyword returns True if object exists, False otherwise
    ...
    ...                             *Argument details:*
    ...                             - dist_name: dist name of checked object.
    ...                             - aicListEntity: can be None (default value), Vdu, Vcu or VduVcu (specifies the application entity).
    ...                             - scope: can be: classical (for classical only, default value) or aic (for aic only) or both.
    [Arguments]                     ${dist_name}
    ...                             ${aicListEntity}=None
    ...                             ${scope}=Classical
    ${object_exist}=                multiscf.is_object_in_scf    dist_name=${dist_name}
    ...                             aicListEntity=${aicListEntity}    scope=${scope}
    [Return]                        ${object_exist}

SCF Is Element Exist
    [Documentation]                 Checks whether given element exists directly under given object.
    ...                             The object is mapped by the attribute distName.
    ...
    ...                             The keyword returns True if element exists, False otherwise
    ...
    ...                             *Argument details:*
    ...                             - dist_name: dist name of checked object.
    ...                             - element_name: name of the checked element.
    ...                             - aicListEntity: can be None (default value), Vdu, Vcu or VduVcu (specifies the application entity).
    ...                             - scope: can be: classical (for classical only, default value) or aic (for aic only) or both.
    [Arguments]                     ${dist_name}
    ...                             ${element_name}
    ...                             ${aicListEntity}=None
    ...                             ${scope}=Classical
    ${element_exist}=               multiscf.is_element_in_object    dist_name=${dist_name}    p_name=${element_name}
    ...                             aicListEntity=${aicListEntity}     scope=${scope}
    [Return]                        ${element_exist}

SCF Remove Element List
    [Documentation]                 Check if the object with "dist_name" exists.
    ...                             If yes then remove the elements provided in "elt_list"
    ...
    ...                             The keyword returns True if at least 1 element has been removed, False otherwise
    ...
    ...                             *Argument details:*
    ...                             - dist_name: dist name of the managed object.
    ...                             - elt_list: list of element to be removed.
    ...                             - aicListEntity: can be None (default value), Vdu, Vcu or VduVcu (specifies the application entity).
    ...                             - scope: can be: classical (for classical only, default value) or aic (for aic only) or both.
    [Arguments]                     ${dist_name}
    ...                             @{elt_list}
    ...                             ${aicListEntity}=None
    ...                             ${scope}=Classical
    ${object_exist}=                SCF Is Object Exist        ${dist_name}    aicListEntity=${aicListEntity}     scope=${scope}
    # Do nothing if the object does not exist
    Run keyword if                  not ${object_exist}        Return From Keyword        ${False}
    # loop removing elements in the objects
    ${elt_removed}=                 Set Variable               ${False}
    FOR    ${elt}    IN    @{elt_list}
         ${element_exist}=          SCF Is Element Exist       dist_name=${dist_name}     element_name=${elt}
         ...                                                   aicListEntity=${aicListEntity}     scope=${scope}
         Run keyword if             not ${element_exist}       Continue For Loop
         Dated Log                  Removing ${elt} from object ${dist_name}
         SCF Remove element         dist_name=${dist_name}     element_name=${elt}    aicListEntity=${aicListEntity}     scope=${scope}
         ${elt_removed}=            Set Variable               ${True}
    END
    [Return]    ${elt_removed}

SCF Remove Object
    [Documentation]                 Remove the whole managed object from loaded SCF file.
    ...                             Attributes are mapped to SCF element’s attributes.
    ...
    ...                             *Argument details:*
    ...                             - dist_name: dist name of the managed object to be removed.
    ...                             - aicListEntity: can be None (default value), Vdu, Vcu or VduVcu (specifies the application entity).
    ...                             - scope: can be: classical (for classical only, default value) or aic (for aic only) or both.
    [Arguments]                     ${dist_name}
    ...                             ${aicListEntity}=None
    ...                             ${scope}=Classical
    multiscf.remove_element_from_scf     dist_name=${dist_name}        aicListEntity=${aicListEntity}     scope=${scope}
    Dated Log                       Object ${dist_name} has been removed

SCF Get Single Value
    [Documentation]                 Retrieves one single element from an SCF file
    ...
    ...                             The keyword returns list of all matched values of p_name element.
    ...
    ...                             *Argument details:*
    ...                             - dist_name: dist name of the managed object.
    ...                             - p_name: name of element to be searched.
    ...                             - aicListEntity: can be None (default value), Vdu, Vcu or VduVcu (specifies the application entity).
    ...                             - scope: can be: classical (for classical only, default value) or aic (for aic only) or both.
    [Arguments]                     ${dist_name}
    ...                             ${p_name}
    ...                             ${aicListEntity}=None
    ...                             ${scope}=Classical
    ${value}                        multiscf.get_all_values_from_scf          dist_name=${dist_name}
    ...                             p_name=${p_name}      aicListEntity=${aicListEntity}     scope=${scope}
    [Return]                        ${value}

SCF Get Single Value By Pattern
    [Documentation]                 Retrieves one single element from an SCF file, expects regular expressions in dist_name or p_name.
    ...
    ...                             The keyword returns list of all matched values of p_name element.
    ...
    ...                             *Argument details:*
    ...                             - dist_name: dist name of the managed object.
    ...                             - p_name: name of element to be searched.
    ...                             - aicListEntity: can be None (default value), Vdu, Vcu or VduVcu (specifies the application entity).
    ...                             - scope: can be: classical (for classical only, default value) or aic (for aic only) or both.
    [Arguments]                     ${dist_name}
    ...                             ${p_name}
    ...                             ${aicListEntity}=None
    ...                             ${scope}=Classical
    ${value}                        multiscf.get_all_values_from_scf_by_pattern          dist_name=${dist_name}
    ...                             p_name=${p_name}     aicListEntity=${aicListEntity}     scope=${scope}
    [Return]                        ${value}

Get Bwp Profile Dedicated
    [Documentation]                 This function will return the id of BWProfile eg for MRBTS-1/NRBTS-1/BWP_PROFILE-33
    ...                             the returned value will be "33". If there is the need to get bwpType=initial,
    ...                             a new robot keyword should be created, or add bwpType=initial
    ...
    ...                             *Argument details:*
    ...                             - scf_file: path to SCF file to be loaded.
    ...                             - bwpType: type od bandwidth. Default is 'dedicated'.
    [Arguments]                     ${scf_file_path}
    ...                             ${bwpType}=dedicated
    ${bwpProfile}                   XmlScf.getBwpProfileId        scfFilePath=${scf_file_path}        bwpType=${bwpType}
    [Return]                        ${bwpProfile}

SCF Create Multi Cells
    [Documentation]                 This function will create desired number of cells starting with existing cells
    ...                             on base SCF. Eg: 2cells -> 3 cells, 1cell- 6 cells
    ...                             Also you can configure  channelConfig 4UL4DL
    ...
    ...                             *Argument details:*
    ...                             - scf_file: path to SCF file to be loaded.
    ...                             - desiredNumOfCells: Eg 3;4;6
    ...                             - channelConfig: Eg 2ul2dl; 4UL4DL ; 4dl2ul
    ...                             - suffixScfName: name of your scf eg:mySCF => mySCF_4dl2ul_SCF_multiCell_created.xml
    [Arguments]                     ${scf_file_path}
    ...                             ${desiredNumOfCells}=3
    ...                             ${channelConfig}=2UL2DL
    ...                             ${suffixScfName}=new
    ${newSCF}                       ScfMultiCellsCreator.createMultipleCellScf
    ...                             scfBasePath=${scf_file_path}
    ...                             desiredNumOfCells=${desiredNumOfCells}
    ...                             channelConfig=${channelConfig}
    ...                             suffixScfName=${suffixScfName}
    [Return]                        ${newSCF}

SCF Display Multi Cells
    [Documentation]                 This function will display all infos for all created cells in SCF
    ...                             To be called before or after: SCF Create Multi Cells
    ...
    ...                             *Argument details:*
    ...                             - scf_file: path to SCF file to be loaded.
    [Arguments]                     ${scf_file_path}
    ScfMultiCellsCreator.dispalySCFInfo          scfPath=${scf_file_path}

Add TTI Route in SCF for AIC
    [Documentation]                 For AIC a route is needed in MRBTS-x/TNLSVC-1/TNL-3/IPNO-1/IPRT-1
    ...                             This Kw is not automatically used when activating TTI traces,
    ...                               please use it at the begining of your test independently
    ...                             Do not forget to perform yourself OAM Commisioning a the end
    ...                             - destIpAddr   : usually 10.0.1.1
    ...                             - destinationIpPrefixLength : usually 32
    ...                             - gateway   : vdu GW it changes for each TL !!!!!
    ...                             - scf_file :  SCF file path
    ...                             - scf_file_out :  SCF file path where it will be saved.
    ...                             - route_dn: 5GUplane DN eg. MRBTS-1/TNLSVC-1/TNL-3/IPNO-1/IPRT-1
    ...                             If nothing is done it will modify the initial file SCF_SETUP_PATH
    [Arguments]    ${route_dn}     ${destIpAddr}=10.0.1.1      ${destinationIpPrefixLength}=32
    ...            ${gateway}=172.16.1.201         ${scf_file}=${SCF_SETUP_PATH}      ${scf_file_out}=${SCF_SETUP_PATH}
    ...            ${aicListEntity}=VDU           ${scope}=AIC
    SCF Start Session        scf_file=${scf_file}
    ${is_DN_for_route}       SCF Is Object Exist      ${route_dn}    aicListEntity=${aicListEntity}      scope=${scope}
    Dated Log                Result for is_DN_for_route: ${is_DN_for_route}
    Run keyword If           ${is_DN_for_route}       Run Keywords
    ...                      SCF Set element in List    dist_name=${route_dn}
    ...                             list_name=staticRoutes
    ...                             element_name=destIpAddr
    ...                             element_value=${destIpAddr}    aicListEntity=${aicListEntity}      scope=${scope}
    ...    AND               SCF Set element in List    dist_name=${route_dn}
    ...                             list_name=staticRoutes
    ...                             element_name=destinationIpPrefixLength
    ...                             element_value=${destinationIpPrefixLength}
    ...                             aicListEntity=${aicListEntity}      scope=${scope}
    ...    AND               SCF Set element in List    dist_name=${route_dn}
    ...                             list_name=staticRoutes
    ...                             element_name=gateway
    ...                             element_value=${gateway}
    ...                             aicListEntity=${aicListEntity}      scope=${scope}
    SCF Stop Session        scf_file=${scf_file_out}
    [Return]                ${scf_file_out}
