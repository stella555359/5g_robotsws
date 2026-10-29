*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Commissioning_Wizard_Cell_Configuring_multiple_CC
    Step1: Copy an existing Cell
    Step2: Check SCF For Multi CC
    Step3: New Cell And Cellgroup
    Step4: Check For Cell and Cellgroup Addition

Case Setup: Cell_Configuring_multiple_CC
    Common Setup
    Init Test Variables: Cell_Configuring_multiple_CC

Case Teardown: Cell_Configuring_multiple_CC
    Common Teardown

Step1: Copy an existing Cell
    Switch To CW Page
    Wait Until Keyword Succeeds   3 times   100 ms   First Copy Cell In CW Site View   ${TEST_CELL}

Step2: Check SCF For Multi CC
    COAM WEBUI Save BTS Configuration   SCF_path=${OUTPUT_DIR}/018_new_plan.xml
    Check Cell Added With Cellgroup And No change in Cellgroup Num   018_new_plan.xml

Step3: New Cell And Cellgroup
    Switch To CW Page
    Wait Until Keyword Succeeds   3 times   100 ms   Add Cell In CW Site View   cell_type=${TEST_CELL_TECH}

Step4: Check For Cell and Cellgroup Addition
    COAM WEBUI Save BTS Configuration   SCF_path=${OUTPUT_DIR}/018_add_cell_cellgroup.xml
    Check SCF For Cell and Cellgroup Addition   018_add_cell_cellgroup.xml
    Check No nrCellList Definition Error

Init Test Variables: Cell_Configuring_multiple_CC
    Enter Into CW Page
    Set Test Cell and Cellgroup
    Set Cell and Cellgroup Num and Refs   018_old_plan.xml

Set Test Cell and Cellgroup
    ${cellgrp}   Get First Cellgroup In CW Site View
    ${cell}   Get First Cell In CW Site View
    Set Test Variable   ${TEST_CELL}   ${cell}
    Set Test Variable   ${TEST_CELLGRP}   ${cellgrp}

Set Cell and Cellgroup Num and Refs
    [Arguments]   ${plan}
    COAM WEBUI Save BTS Configuration   SCF_path=${OUTPUT_DIR}/${plan}
    ${cell_num}   Get Cell NUM: Cell_Configuring_multiple_CC   xml_plan=${plan}
    ${cellgrp_num}   ${cellsref}   Get Cellgroup Num And Ref List In Test Group   ${plan}
    ${celltech}   Get First Celltechnology: Cell_Configuring_multiple_CC   xml_plan=${plan}
    Set Test Variable   ${TEST_CELLGRP_NUM}   ${cellgrp_num}
    Set Test Variable   ${TEST_CELL_NUM}   ${cell_num}
    Set Test Variable   ${TEST_CELL_REFS}   ${cellsref}
    Set Test Variable   ${TEST_CELL_TECH}   ${celltech}

Check Cell Added With Cellgroup And No change in Cellgroup Num
    [Arguments]   ${plan}
    ${cell_num}   Get Cell Num: Cell_Configuring_multiple_CC   xml_plan=${plan}
    ${cellgrp_num}   ${cellsref}   Get Cellgroup Num And Ref List In Test Group   ${plan}
    Should Be Equal   ${TEST_CELLGRP_NUM}   ${cellgrp_num}
    Should Be Equal   ${TEST_CELL_NUM+1}   ${cell_num}
    Set Test Variable   ${TEST_CELL_NUM_AFTER_COPY}   ${cell_num}
    List Should Contain Sub List   ${cellsref}   ${TEST_CELL_REFS}
    Should Not Be Equal   ${cellsref}   ${TEST_CELL_REFS}

Check SCF For Cell and Cellgroup Addition
    [Arguments]   ${plan}
    ${cell_num}   Get Cell Num: Cell_Configuring_multiple_CC   xml_plan=${plan}
    ${cellgrp_num}   Get Cellgroup Num: Cell_Configuring_multiple_CC   xml_plan=${plan}
    Should Be Equal   ${TEST_CELLGRP_NUM+1}   ${cellgrp_num}
    Should Be Equal   ${TEST_CELL_NUM_AFTER_COPY+1}   ${cell_num}

Check No nrCellList Definition Error
    @{list}   COAM WEBUI Get Definition Errors
    Should Not Be Empty   ${list}
    FOR   ${error}   IN   @{list}
       Log Dictionary   ${error}
       Dictionary Should Not Contain Value   ${error}   nrCellList
    END

Get Cell Num: Cell_Configuring_multiple_CC
    [Arguments]   ${xml_plan}
    ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/${xml_plan}
    ${cell_elements}   XML.Get Elements   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    ${cell_num}   Get Length   ${cell_elements}
    [Return]   ${cell_num}

Get Cellgroup Num: Cell_Configuring_multiple_CC
    [Arguments]   ${xml_plan}
    ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/${xml_plan}
    ${cellgroup_elements}   XML.Get Elements   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELLGRP"]
    ${cellgrp_num}   Get Length   ${cellgroup_elements}
    [Return]   ${cellgrp_num}

Get Cellgroup Num And Ref List In Test Group
    [Arguments]   ${xml_plan}
    ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/${xml_plan}
    ${cellgroup_elements}   XML.Get Elements   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELLGRP"]
    ${cellgrp_num}   Get Length   ${cellgroup_elements}
    ${cellgrp_dn_prefix}   Set Variable   ${cellgroup_elements[0].attrib['distName'].split('NRCELLGRP')[0]}
    ${cellsref}   Get Elements Texts   ${scf_xml}   cmData/managedObject[@distName="${cellgrp_dn_prefix}${TEST_CELLGRP}"]/list[@name="nrCellList"]/p
    [Return]   ${cellgrp_num}   ${cellsref}

Get First Celltechnology: Cell_Configuring_multiple_CC
    [Arguments]   ${xml_plan}
    ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/${xml_plan}
    ${cell_elements}   XML.Get Elements   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    ${cell_dn}   Set Variable   ${cell_elements[0].attrib['distName']}
    ${celltech}   XML.Get Element Text   ${scf_xml}
    ...   cmData/managedObject[@distName="${cell_dn}"]/p[@name="cellTechnology"]
    [Return]   ${celltech}