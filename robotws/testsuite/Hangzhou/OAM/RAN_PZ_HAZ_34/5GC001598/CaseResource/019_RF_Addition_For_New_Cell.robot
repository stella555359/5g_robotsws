*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Commissioning_Wizard_RF_Addition_For_New_Cell
    Step1: Add Radio
    Step2: Add Cell
    Step3: Add Carriers
    # Step4: Add Cablink

Case Setup: RF_Addition_For_New_Cell
    Common Setup
    Init Test Variables: RF_Addition_For_New_Cell

Case Teardown: RF_Addition_For_New_Cell
    Common Teardown

Step1: Add Radio
    Switch To CW Page
    Add HW In CW Site View   hw_module=Radio   product_code=${TEST_RADIO_TYPE}
    Check SCF For Radio Addition   019_add_radio_plan.xml

Step2: Add Cell
    Switch To CW Page
    Wait Until Keyword Succeeds   3 times   100 ms   Add Cell In CW Site View   cell_type=${TEST_CELL_TECH}
    Check SCF For Cell Addition: RF_Addition_For_New_Cell   plan=019_add_cell_plan.xml

Step3: Add Carriers
    Switch To CW Page
    ${last_cell}   Wait Until Keyword Succeeds   3 times   100 ms   Get Last Cell In CW Site View
    Click Add Carriers In CW Site View   ${last_cell}
    Wait Until Keyword Succeeds   3 times   100 ms   Add Channel With Last Radio In CW Site View
    Check SCF For Channel Addition   019_add_channel_plan.xml

Step4: Add Cablink
    Switch To CW Page
    ${last_radio}   Get Last Radio In CW Site View
    Wait Until Keyword Succeeds   3 times   100 ms   Click Add Cablink in CW Site View   ${last_radio}
    Wait Until Keyword Succeeds   3 times   100 ms   Add Cablink With Last BBMOD In CW Site View
    Check SCF For Cablink Addition   019_add_cablink_plan.xml

Init Test Variables: RF_Addition_For_New_Cell
    Enter Into CW Page
    Set Test Radio Type
    Set Cell And Cellgroup And Celltechnology And Radio And Channel And Cablink Num   019_old_plan.xml

Set Test Radio Type
    ${radiotype}   Get First RMOD Type In CW Site View
    Set Test Variable   ${TEST_RADIO_TYPE}   ${radiotype}

Set Cell And Cellgroup And Celltechnology And Radio And Channel And Cablink Num
    [Arguments]   ${plan}
    COAM WEBUI Save BTS Configuration   SCF_path=${OUTPUT_DIR}/${plan}
    Sleep   3s
    ${parsed_xml}   XML.Parse XML   ${OUTPUT_DIR}/${plan}
    ${cell_num}   Get Cell NUM: RF_Addition_For_New_Cell   parsed_xml=${parsed_xml}
    ${cellgrp_num}   Get Cellgroup Num: RF_Addition_For_New_Cell   parsed_xml=${parsed_xml}
    ${celltech}   Get First Celltechnology: RF_Addition_For_New_Cell   parsed_xml=${parsed_xml}
    ${radio_num}   Get Radio Num   ${parsed_xml}
    ${channel_num}   Get Channel Num   ${parsed_xml}
    ${cablink_num}   Get Cablink Num   ${parsed_xml}
    Set Test Variable   ${TEST_CELLGRP_NUM}   ${cellgrp_num}
    Set Test Variable   ${TEST_CELL_NUM}   ${cell_num}
    Set Test Variable   ${TEST_CELL_TECH}   ${celltech}
    Set Test Variable   ${TEST_RADIO_NUM}   ${radio_num}
    Set Test Variable   ${TEST_CHANNEL_NUM}   ${channel_num}
    Set Test Variable   ${TEST_CABLINK_NUM}   ${cablink_num}

Check SCF For Radio Addition
    [Arguments]   ${plan}
    COAM WEBUI Save BTS Configuration   SCF_path=${OUTPUT_DIR}/${plan}
    Sleep   3s
    ${parsed_xml}   XML.Parse XML   ${OUTPUT_DIR}/${plan}
    Check Added One Radio   ${parsed_xml}

Check SCF For Cell Addition: RF_Addition_For_New_Cell
    [Arguments]   ${plan}
    COAM WEBUI Save BTS Configuration   SCF_path=${OUTPUT_DIR}/${plan}
    Sleep   3s
    ${parsed_xml}   XML.Parse XML   ${OUTPUT_DIR}/${plan}
    Check Added One Cell And One Cellgroup   ${parsed_xml}

Check SCF For Channel Addition
    [Arguments]   ${plan}
    COAM WEBUI Save BTS Configuration   SCF_path=${OUTPUT_DIR}/${plan}
    Sleep   3s
    ${parsed_xml}   XML.Parse XML   ${OUTPUT_DIR}/${plan}
    Check Added Channels   ${parsed_xml}

Check SCF For Cablink Addition
    [Arguments]   ${plan}
    COAM WEBUI Save BTS Configuration   SCF_path=${OUTPUT_DIR}/${plan}
    Sleep   3s
    ${parsed_xml}   XML.Parse XML   ${OUTPUT_DIR}/${plan}
    Check Added Cablink   ${parsed_xml}

Check Added One Radio
    [Arguments]   ${parsed_xml}
    ${radio_num}   Get Radio Num   ${parsed_xml}
    Should Be Equal   ${TEST_RADIO_NUM+1}   ${radio_num}

Check Added One Cell And One Cellgroup
    [Arguments]   ${parsed_xml}
    ${cell_num}   Get Cell NUM: RF_Addition_For_New_Cell   parsed_xml=${parsed_xml}
    ${cellgrp_num}   Get Cellgroup Num: RF_Addition_For_New_Cell   parsed_xml=${parsed_xml}
    Should Be Equal   ${TEST_CELLGRP_NUM+1}   ${cellgrp_num}

Check Added Channels
    [Arguments]   ${parsed_xml}
    ${channel_num}   Get Channel Num   ${parsed_xml}
    Should Be Equal   ${TEST_CHANNEL_NUM+2}   ${channel_num}

Check Added Cablink
    [Arguments]   ${parsed_xml}
    ${cablink_num}   Get Cablink Num   ${parsed_xml}
    Should Be Equal   ${TEST_CABLINK_NUM+1}   ${cablink_num}

Get Cell Num: RF_Addition_For_New_Cell
    [Arguments]   ${parsed_xml}
    ${cell_elements}   XML.Get Elements   ${parsed_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    ${cell_num}   Get Length   ${cell_elements}
    [Return]   ${cell_num}

Get Cellgroup Num: RF_Addition_For_New_Cell
    [Arguments]   ${parsed_xml}
    ${cellgroup_elements}   XML.Get Elements   ${parsed_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELLGRP"]
    ${cellgrp_num}   Get Length   ${cellgroup_elements}
    [Return]   ${cellgrp_num}

Get Radio Num
    [Arguments]   ${parsed_xml}
    ${radio_elements}   XML.Get Elements   ${parsed_xml}   cmData/managedObject[@class="com.nokia.srbts.eqm:RMOD"]
    ${radio_num}   Get Length   ${radio_elements}
    [Return]   ${radio_num}

Get First Celltechnology: RF_Addition_For_New_Cell
    [Arguments]   ${parsed_xml}
    ${cell_elements}   XML.Get Elements   ${parsed_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    ${cell_dn}   Set Variable   ${cell_elements[0].attrib['distName']}
    ${celltech}   XML.Get Element Text   ${parsed_xml}
    ...   cmData/managedObject[@distName="${cell_dn}"]/p[@name="cellTechnology"]
    [Return]   ${celltech}

Get Channel Num
    [Arguments]   ${parsed_xml}
    ${channel_elements}   XML.Get Elements   ${parsed_xml}   cmData/managedObject[@class="com.nokia.srbts.mnl:CHANNEL"]
    ${channel_num}   Get Length   ${channel_elements}
    [Return]   ${channel_num}

Get Cablink Num
    [Arguments]   ${parsed_xml}
    ${cablink_elements}   XML.Get Elements   ${parsed_xml}   cmData/managedObject[@class="com.nokia.srbts.eqm:CABLINK"]
    ${cablink_num}   Get Length   ${cablink_elements}
    [Return]   ${cablink_num}