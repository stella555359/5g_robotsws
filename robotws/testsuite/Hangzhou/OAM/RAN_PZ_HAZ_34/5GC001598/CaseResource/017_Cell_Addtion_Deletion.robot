*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Commissioning_Wizard_Cell_Addtion_Deletion
    Step1: Cell Addition Last Button
    Step2: Set Cellgroup For Newly cell
    Step3: Cell Deletion Original One

Case Setup: Cell_Addtion_Deletion
    Common Setup
    Init Test Variables: Cell_Addtion_Deletion

Case Teardown: Cell_Addtion_Deletion
    Common Teardown

Step1: Cell Addition Last Button
    Switch To CW Page
    Wait Until Keyword Succeeds   3 times   100 ms   Last Copy Cell In CW Site View   ${TEST_CELL}
    Check SCF For Cell Addition: Cell_Addtion_Deletion   plan=017_add_plan.xml

Step2: Set Cellgroup For Newly cell
    Switch To CW Page
    Wait Until Keyword Succeeds   3 times   100 ms   First Cell Set Cellgroup In CW Site View   ${TEST_CELLGRP}
    Check SCF For Cellgroup Setting   017_set_cellgroup_plan.xml

Step3: Cell Deletion Original One
    Switch To CW Page
    Wait Until Keyword Succeeds   3 times   100 ms   Delete Cell In CW Site View   ${TEST_CELL}
    Check SCF For Cell Deletion   017_delete_plan.xml

Init Test Variables: Cell_Addtion_Deletion
    COAM WEBUI Save BTS Configuration   SCF_path=${OUTPUT_DIR}/017_old_plan.xml
    ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/017_old_plan.xml
    Set Cellgroup Variables   ${scf_xml}
    Set Cell Variables   ${scf_xml}

Set Cellgroup Variables
    [Arguments]   ${parsed_xml}
    ${cellgroup_elements}   XML.Get Elements   ${parsed_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELLGRP"]
    Should Not Be Empty   ${cellgroup_elements}
    ${cellgrp_num}   Get Length   ${cellgroup_elements}
    ${cellgrp_dn}   Set Variable   ${cellgroup_elements[0].attrib['distName']}
    ${cellsref}   Get Elements Texts   ${parsed_xml}   cmData/managedObject[@distName="${cellgrp_dn}"]/list[@name="nrCellList"]/p
    Should Not Be Empty   ${cellsref}
    ${cellgrp_dn_prefix}   Set Variable   ${cellgroup_elements[0].attrib['distName'].split('NRCELLGRP')[0]}
    ${cellgrp}   Set Variable   NRCELLGRP${cellgrp_dn.split('NRCELLGRP')[1]}
    Set Test Variable   ${TEST_CELLGRP_NUM}   ${cellgrp_num}
    Set Test Variable   ${TEST_CELLGRP_DN}   ${cellgrp_dn}
    Set Test Variable   ${TEST_CELLGRP_DN_PREFIX}   ${cellgrp_dn_prefix}
    Set Test Variable   ${TEST_CELLGRP}   ${cellgrp}
    Set Test Variable   ${TEST_CELLLIST}   ${cellsref}

Set Cell Variables
    [Arguments]   ${parsed_xml}
    ${cell_elements}   XML.Get Elements   ${parsed_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    Should Not Be Empty   ${cell_elements}
    ${cell_num}   Get Length   ${cell_elements}
    ${cell_dn_prefix}   Set Variable   ${cell_elements[0].attrib['distName'].split('NRCELL')[0]}
    ${cell}   Set Variable   NRCELL-${TEST_CELLLIST[0]}
    ${cell_dn}  Set Variable   ${cell_dn_prefix}${cell}
    Element Should Exist   ${parsed_xml}   cmData/managedObject[@distName="${cell_dn}"]
    Set Test Variable   ${TEST_CELL_NUM}   ${cell_num}
    Set Test Variable   ${TEST_CELL_DN}   ${cell_dn}
    Set Test Variable   ${TEST_CELL_DN_PREFIX}   ${cell_dn_prefix}
    Set Test Variable   ${TEST_CELL}   ${cell}

Check SCF For Cell Addition: Cell_Addtion_Deletion
    [Arguments]   ${plan}
    COAM WEBUI Save BTS Configuration   SCF_path=${OUTPUT_DIR}/${plan}
    Check Added One Cell And No change in Cellgroup NUM   ${plan}

Check Added One Cell And No change in Cellgroup NUM
    [Arguments]   ${plan}
    ${cellgrp_num}   ${cell_num}   Get Cell And Cellgroup NUM   ${plan}
    Should Be Equal   ${TEST_CELLGRP_NUM}   ${cellgrp_num}
    Should Be Equal   ${TEST_CELL_NUM+1}   ${cell_num}

Check SCF For Cellgroup Setting
    [Arguments]   ${plan}
    COAM WEBUI Save BTS Configuration   SCF_path=${OUTPUT_DIR}/${plan}
    Check Newly Cell Mapped to Cellgroup   ${plan}

Check Newly Cell Mapped to Cellgroup
    [Arguments]   ${plan}
    COAM WEBUI Save BTS Configuration   SCF_path=${OUTPUT_DIR}/${plan}
    ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/${plan}
    ${cellsref}   Get Elements Texts   ${scf_xml}   cmData/managedObject[@distName="${TEST_CELLGRP_DN}"]/list[@name="nrCellList"]/p
    List Should Contain Sub List   ${cellsref}   ${TEST_CELLLIST}
    Should Not Be Equal   ${cellsref}   ${TEST_CELLLIST}

Check SCF For Cell Deletion
    [Arguments]   ${plan}
    COAM WEBUI Save BTS Configuration   SCF_path=${OUTPUT_DIR}/${plan}
    Check No Change In Cell And Cellgroup NUM   ${plan}
    Check Cell Deleted   ${plan}   ${TEST_CELL}

Check No Change In Cell And Cellgroup NUM
    [Arguments]   ${plan}
    ${cellgrp_num}   ${cell_num}   Get Cell And Cellgroup NUM   ${plan}
    Should Be Equal   ${TEST_CELLGRP_NUM}   ${cellgrp_num}
    Should Be Equal   ${TEST_CELL_NUM}   ${cell_num}

Get Cell And Cellgroup NUM
    [Arguments]   ${xml_plan}
    ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/${xml_plan}
    ${cellgroup_elements}   XML.Get Elements   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELLGRP"]
    Should Not Be Empty   ${cellgroup_elements}
    ${cellgrp_num}   Get Length   ${cellgroup_elements}
    ${cell_elements}   XML.Get Elements   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    Should Not Be Empty   ${cell_elements}
    ${cell_num}   Get Length   ${cell_elements}
    [Return]   ${cellgrp_num}   ${cell_num}

Check Cell Deleted
    [Arguments]   ${xml_plan}   ${cell}
    ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/${xml_plan}
    ${cell_dn}   Set Variable   ${TEST_CELL_DN_PREFIX}${cell}
    ${cell_elements}   XML.Get Elements   ${scf_xml}   cmData/managedObject[@distName="${cell_dn}"]
    Should Be Empty   ${cell_elements}
