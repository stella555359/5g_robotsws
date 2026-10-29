*** Settings ***
Documentation        An example on Scf file operations

Library                             OperatingSystem
Library                             ../../python/ScfVendorOperations.py
Resource                            ../Tools.robot

Test Setup          File Testing            ${Nidd_file}

*** Variables ***
${Nidd_file}        testsuite/Paris/resources/SWENG/python/pytest/NIDD/vendor_1AE512BF_ori.xml
${dest_file}        /tmp/vendor_test.xml
@{list_params}      anrLTEIntraRscReportAmount
...                 anrUtraInactivityTimer
...                 badChEstPer
...                 JamesTheKiller
@{to_remove}        anrLTEIntraRscReportAmount
...                 anrUtraInactivityTimer
&{dict_1}           text=CentrCellOutTriggReset
...                 textId=8
&{dict_2}           text=CentrEnbAutoConfig
...                 textId=8
@{items_toremove}   ${dict_1}       ${dict_2}
@{param_toadd}      pipiLTEIntraRscReportAmount         5
@{item_toadd}       ${dict_1}
&{new_val1}    beamIdOfWeight=1
...            imagPartofWeighforAnt0=3
...            imagPartofWeighforAnt1=2
...            imagPartofWeighforAnt2=1
...            imagPartofWeighforAnt3=4
...            realPartofWeighforAnt0=25000
...            realPartofWeighforAnt1=10000
...            realPartofWeighforAnt2=25000
...            realPartofWeighforAnt3=10000
&{new_val2}    beamIdOfWeight=2
...            imagPartofWeighforAnt0=3
...            imagPartofWeighforAnt1=2
...            imagPartofWeighforAnt2=1
...            imagPartofWeighforAnt3=4
...            realPartofWeighforAnt0=25000
...            realPartofWeighforAnt1=10000
...            realPartofWeighforAnt2=25000
...            realPartofWeighforAnt3=10000
&{old_val1}    beamIdOfWeight=1
...            imagPartofWeighforAnt0=0
...            imagPartofWeighforAnt1=0
...            imagPartofWeighforAnt2=0
...            imagPartofWeighforAnt3=0
...            realPartofWeighforAnt0=10000
...            realPartofWeighforAnt1=10000
...            realPartofWeighforAnt2=10000
...            realPartofWeighforAnt3=10000
&{old_val2}    beamIdOfWeight=2
...            imagPartofWeighforAnt0=0
...            imagPartofWeighforAnt1=0
...            imagPartofWeighforAnt2=0
...            imagPartofWeighforAnt3=0
...            realPartofWeighforAnt0=10000
...            realPartofWeighforAnt1=10000
...            realPartofWeighforAnt2=10000
...            realPartofWeighforAnt3=10000
@{old_items_list}       &{old_val1}     &{old_val2}
@{new_items_list}       &{new_val1}     &{new_val2}
@{param_val1}       actIntTrigOnFaultCancellation
...                 false
@{param_val2}       allowExceedAnrMOI
...                 2
@{param_val3}       anrUtraTRCGI
...                 10400ms
@{replacement_params_list}      @{param_val1}   @{param_val2}   @{param_val3}

*** Test Cases ***
Get MO
    ${mo_dict}                      ScfVendorOperations.get moelements byclass                    LNBTS
    Set Suite Variable              ${mo_dict}

Get List On Demand
    ${list_on_demand}               ScfVendorOperations.get namedlist fromManagedObject           sonReportTextList
    ...                             ${mo_dict}

Get Parameters List
    ${params_on_demand}             ${missing_params}
    ...                             ScfVendorOperations.get namedParameters fromManagedObject
    ...                             ${list_params}                            ${mo_dict}

Remove Parameters List
    ${modified_mo}                  ScfVendorOperations.remove namedParameters fromManagedObject
    ...                             ${to_remove}                            ${mo_dict}

Remove Items List
    ${list_name}        Set Variable                                    sonReportTextList
    ${modified_mo}      ScfVendorOperations.remove items fromList       ${items_toremove}
    ...                 ${list_name}                                    ${mo_dict}

Add Parameters
     ${modified_mo}      ScfVendorOperations.add parameter toManagedObject
     ...                 ${param_toadd}                                 ${mo_dict}

Add Item To List
    ${list_name}        Set Variable                                    sonReportTextList
    ${modified_mo}      ScfVendorOperations.add items toList            ${item_toadd}
    ...                 ${list_name}                                    ${mo_dict}

Replace Items in List
    ${list_name}        Set Variable                                    dlInterferenceBFWeightSet
    ${modified_mo}      ScfVendorOperations.replace items inList        ${old_items_list}
    ...                 ${new_items_list}                               ${list_name}
    ...                 ${mo_dict}

Replace Parameters List
    ${modified_mo}      ScfVendorOperations.replace params inMo         ${replacement_params_list}
    ...                 ${mo_dict}

Replace and Save
    ${modified_mo}      ScfVendorOperations.replace params inMo         ${replacement_params_list}
    ...                 ${mo_dict}

    ScfVendorOperations.save back toxml     ${dest_file}
    ${Tmp_file_ls}                    OperatingSystem.run               ls -altr ${dest_file}
    Dated log                         Obtained file ${Tmp_file_ls}

*** Keywords ***

File Testing
    [Arguments]                                             ${file_path}
    ScfVendorOperations.setup reader                        ${file_path}