*** Settings ***
Documentation       Set of keywords to do SCF operation
Library         taf.config.scf   WITH NAME      scf
Resource        Tools.robot
Resource        Oam.robot

*** Keywords ***

SCF StartSession
    [Documentation]               starts a modification session on local scf file
    ...                           scf_file: path to SCF file
    [Arguments]                   ${scf_file}
    Dated Log                     Loaded SCF : ${scf_file}
    set suite variable            ${scf_file}
    scf.load_scf                  file_path=${scf_file}


SCF StopSession
    [Documentation]               save modifications to scf_file
    [Arguments]                   ${scf_file}
    scf.save_scf                  file_path=${scf_file}
    Dated Log                     Saved SCF: ${scf_file}

SCF Add list
    [Arguments]                   ${dist_name}
    ...                           ${list_name}
    [Documentation]               Adds an empty list to object in SCF file
    ...                           the object is mapped by the ${dist_name}
    scf.add_list_to_scf           dist_name=${dist_name}    list_name=${list_name}
    Dated Log                     New list : ${list_name} is added to :${scf_file} using the distname : ${dist_name}


SCF Add items to list
    [Arguments]                   ${dist_name}
    ...                           ${list_name}
    ...                           ${elements}
    [Documentation]               Adds elements to a specific list in scf file
    ...                           elements :is a dictionary of items to be added to the list
    ...                                 -the key is an element name
    ...                                 - value is an element value
    scf.add_item_to_list           dist_name=${dist_name}    list_name=${list_name}   elements=${elements}
    Dated Log                      New item=(${elements}) is added to liste=(${list_name})

SCF Add elements to list
    [Arguments]                   ${dist_name}
    ...                           ${list_name}
    ...                           ${elements}
    [Documentation]               Adds elements to a specific list in scf file
    ...                           elements : list of elements to be added to the list
    scf.add_elements_to_list      dist_name=${dist_name}    list_name=${list_name}   elements=${elements}
    Dated Log                     New item=(${elements}) is added to liste=(${list_name})

SCF Add object
    [Arguments]                    ${dist_name}
    ...                            ${class_name}
    ...                            ${version}
    [Documentation]                adds a managed Object to SCF file
    scf.add_object_to_scf          class_name=${class_name}      dist_name=${dist_name}        version=${version}
    Dated Log                      new object is added with class_name=(${class_name}) \n
    Dated Log                      version=(${version}) \n dist_name=(${dist_name})


SCF Add element
    [Arguments]                    ${dist_name}
    ...                            ${element_name}
    ...                            ${element_value}
    scf.add_element_to_scf         dist_name=${dist_name}       p_name=${element_name}    value=${element_value}
    Dated Log                      new element is added : element_name= (${element_name}) \n
    Dated Log                      element_value=(${element_value}) \n dist_name=(${dist_name})


SCF Remove list
    [Arguments]                     ${dist_name}
    ...                             ${list_name}
    Run Keyword And Ignore Error    scf.remove_list_from_scf        dist_name=${dist_name}    list_name=${list_name}
    Dated Log                       list=(${list_name}) is removed


SCF Remove element
    [Arguments]                     ${dist_name}
    ...                             ${element_name}
    ...                             ${index}=0
    [Documentation]                 Removes elements from SCF file
    ...                             if element_name or index is given it removes only single element
    ...                             otherwise the whole managedObject is removed
    ...                             index : optional argument used if more than one match expected (indexing stats from 0)
    scf.remove_element_from_scf     dist_name=${dist_name}      p_name=${element_name}       index=${index}
    Dated Log                       Element=(${element_name}) is removed

SCF Set element
    [Arguments]                     ${dist_name}
    ...                             ${element_name}
    ...                             ${element_value}
    [Documentation]                 Modify Element value. Raises exception if more or less than one element found
    ${result}    ${msg} =           Run Keyword And Ignore Error      scf.modify_scf_element         dist_name=${dist_name}
    ...                                                                                             p_name=${element_name}
    ...                                                                                             value=${element_value}
    Run Keyword If                  '${result}' is None or '${result}' == 'FAIL'
    ...                             scf.add_element_to_scf         dist_name=${dist_name}       p_name=${element_name}    value=${element_value}

SCF Set element in List
    [Arguments]                     ${dist_name}
    ...                             ${list_name}
    ...                             ${element_name}
    ...                             ${element_value}
    [Documentation]                 Modify or Add element value in list. Raises exception if more or less than one element found
    ${elements}                     create dictionary                       ${element_name}=${element_value}
    ${result_modify}    ${msg}      Run Keyword And Ignore Error
    ...                             scf.modify_scf_element
    ...                                 dist_name=${dist_name}
    ...                                 list_name=${list_name}
    ...                                 p_name=${element_name}
    ...                                 value=${element_value}
    return from keyword if          '${result_modify}' == 'PASS'
    ${result_list_check}            scf.is_list_in_object
    ...                                 dist_name=${dist_name}              list_name=${list_name}
    Run Keyword if             not ${result_list_check}
    ...                             scf.add_list_to_scf
    ...                                 dist_name=${dist_name}
    ...                                 list_name=${list_name}
    Run Keyword if             not ${result_list_check}
    ...                             scf.add_item_to_list
    ...                                 dist_name=${dist_name}
    ...                                 list_name=${list_name}
    ...                                 elements=${elements}
    # Add case of failure because more than one element were found
    ${isMultiple}                   Evaluate                                str(${msg.startswith("MultipleMatches:")})
    ${action}                       set variable if                         '${isMultiple}'=='True'
    ...                             modify                                  add
    @{mod_string}=                  Create List
    ...                             ${action}:${dist_name}:${list_name}:${element_name}=${element_value}
    Run Keyword If                  '${result_modify}' is None or '${result_modify}' == 'FAIL'
    ...                             scf.perform_scf_modification            modification_strings=@{mod_string}


SCF Is Object Exist
    [Documentation]                 Check if the object exists in the SCF file
    ...                             return True if the object exists, False otherwise

    [Arguments]                     ${dist_name}

    ${object_exist}=                scf.is_object_in_scf    dist_name=${dist_name}
    [Return]                        ${object_exist}


SCF Is Element Exist
    [Documentation]                 Check if the element exists in the SCF file
    ...                             return True if the element exists, False otherwise

    [Arguments]                     ${dist_name}
    ...                             ${element_name}

    ${element_exist}=               scf.is_element_in_object    dist_name=${dist_name}    p_name=${element_name}
    [Return]                        ${element_exist}


SCF Remove Element List
    [Documentation]     Check if the object with "dist_name" exists, if yes then remove the elements
    ...                 provided in "elt_list"
    ...                 Return ${True} if at least 1 element has been removed, ${False} otherwise

    [Arguments]         ${dist_name}
    ...                 @{elt_list}

    ${object_exist}=    SCF Is Object Exist    ${dist_name}

    # Do nothing if the object does not exist
    Run keyword if    not ${object_exist}    Return From Keyword    ${False}

    # loop removing elements in the objects

    ${elt_removed}=    Set Variable    ${False}

    FOR    ${elt}    IN    @{elt_list}
         ${element_exist}=    SCF Is Element Exist    dist_name=${dist_name}    element_name=${elt}
         Run keyword if    not ${element_exist}    Continue For Loop
         Dated Log    Removing ${elt} from object ${dist_name}
         SCF Remove element    dist_name=${dist_name}    element_name=${elt}
         ${elt_removed}=    Set Variable    ${True}

    END
    [Return]    ${elt_removed}


SCF Remove Object
    [Arguments]                     ${dist_name}
    [Documentation]                 Removes elements from SCF file
    ...                             if element_name or index is given it removes only single element
    ...                             otherwise the whole managedObject is removed
    ...                             index : optional argument used if more than one match expected (indexing stats from 0)
    scf.remove_element_from_scf     dist_name=${dist_name}
    Dated Log                       Object ${dist_name} has been removed

SCF Get Single Value
    [Arguments]                     ${dist_name}        ${p_name}
    [Documentation]                 Retrieves one single element from an SCF file, dist_name is a regular espression
    ${value}                        scf.get_all_values_from_scf          dist_name=${dist_name}
    ...                             p_name=${p_name}
    [Return]                        ${value}

