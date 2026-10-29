*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ./Common.robot

*** Variables ***


*** Keyword ***
Enter Into CW Page
    COAM_WEBUI_Click_Button   xpath=//span[@ui-tooltip='Configuration']
    Sleep   3s
    COAM_WEBUI_Move_To_Element   xpath=//span[contains(text(),'Configuration Reset')]
    Sleep   3s
    COAM_WEBUI_Move_To_Element   xpath=//span[contains(text(),'Configuration Management')]
    Sleep   3s
    # COAM_WEBUI_Wait_For_Visibility   xpath=//span[contains(text(),'Commissioning Wizard')]
    # Sleep   3s
    # COAM_WEBUI_Click_Button   xpath=//span[contains(text(),'Commissioning Wizard')]
    COAM_WEBUI_Click_Button   xpath=//span[contains(text(),'Configuration Management')]
    COAM_WEBUI_Wait_For_Visibility   xpath=//div[@class='commissioning-wizard-container']
    Sleep   3s

Switch To CW Page
    COAM_WEBUI_Click_Button   xpath=//div[contains(text(),'Commissioning Wizard')]
    COAM_WEBUI_Wait_For_Visibility   xpath=//div[@class='commissioning-wizard-container']
    Sleep   3s

Add HW In CW Site View
    [Arguments]   ${hw_module}   ${product_code}
    [Documentation]
    ...   product_code:
    ...   ASIK (474021A)
    ...   ASIB (473764A)
    ...   ABIL (474020A)
    ...   ABIL (474020B)
    ...   ABIO (475266A)
    ...   AHFB (474036A)
    ${object_name}   Set Variable If
    ...   '${hw_module}'=='System Module'   SMOD
    ...   '${hw_module}'=='BBMOD'   BBMOD
    ...   '${hw_module}'=='Radio'   RMOD

    COAM_WEBUI_Click_Button   xpath=//div[contains(text(), "Add ${hw_module}")]/..//button
    COAM_WEBUI_Wait_For_Visibility   xpath=//div[@class="hw-element-select-wrapper"]
    Sleep   3s
    COAM_WEBUI_Input_Value   xpath=//div[@class="hw-element-select-wrapper"]/input   text=${product_code}
    COAM_WEBUI_Click_Button   xpath=//div[@class="hw-element-select-wrapper"]//div[contains(text(), "${product_code}")]
    COAM_WEBUI_Wait_For_Visibility   xpath=//div[contains(@distname, "${object_name}")]
    Sleep   3s

Add Cell In CW Site View
    [Arguments]   ${cell_type}   ${index}=last()
    # ${length}   COAM_WEBUI_Execute_Script
    # ...   script=return $("div:contains('Add Cell')").siblings("div").children("button").children("i.plus").length
    ${cell_num}   COAM_WEBUI_Execute_Script   script=return $("div[distname*='NRCELL-']").length
    COAM_WEBUI_Click_Button   xpath=(//div[contains(text(), "Add Cell")]/..//button/i[@class="plus"])[${index}]
    COAM_WEBUI_Wait_For_Visibility   xpath=//div[@class="hw-element-select-wrapper"]
    COAM_WEBUI_Move_To_Element   xpath=//div[@class="hw-element-select-wrapper"]
    COAM_WEBUI_Input_Value   xpath=//div[@class="hw-element-select-wrapper"]/input   text=${cell_type}
    COAM_WEBUI_Click_Button   xpath=//div[@class="hw-element-select-wrapper"]//div[contains(text(), "${cell_type}")]
    COAM_WEBUI_Wait_For_Visibility   xpath=(//div[contains(@distname, "NRCELL-")])[${cell_num+1}]
    Sleep   2s

Check BBMOD Error IN CW Site View
    COAM_WEBUI_Wait_For_Visibility  xpath=//div[contains(@distname, "BBMOD")]//div[@class='widget-error-container']
    Sleep   1s

Auto Align BBMOD HW Type IN CW Site View
    COAM_WEBUI_Click_Button   xpath=//div[contains(@distname, "BBMOD")]//i[@class='retweet']
    Sleep   1s

Get First Cell In CW Site View
    ${first_cell}   COAM_WEBUI_Get_Element_Text
    ...   xpath=(//div[contains(@class, "CELL-column")][1]//span[contains(text(), 'NRCELL')])[1]
    [Return]   ${first_cell}

Get First Cellgroup In CW Site View
    #${first_cellgrp}   COAM_WEBUI_Get_Element_Text
    #...   xpath=(//div[contains(@class, "CELL-column")][1]//div[contains(text(), 'NRCELLGRP')])[1]
    ${first_cellgrp_dn}   COAM_WEBUI_Execute_Script
    ...   script=return document.querySelectorAll("div[distname*='NRCELLGRP-']")[0].attributes.distname.value
    ${first_cellgrp}   Set Variable   NRCELLGRP${first_cellgrp_dn.split('NRCELLGRP')[1]}
    [Return]   ${first_cellgrp}

First Copy Cell In CW Site View
    [Arguments]   ${input_cell}
    ${cell_num}   COAM_WEBUI_Execute_Script   script=return document.querySelectorAll("div[distname*='NRCELL-']").length
    COAM_WEBUI_Click_Button   xpath=(//div[contains(text(), "Add Cell")]/..//button/i[@class="copy"])[1]
    COAM_WEBUI_Wait_For_Visibility   xpath=//div[@class="hw-element-select-wrapper"]
    COAM_WEBUI_Move_To_Element   xpath=//div[@class="hw-element-select-wrapper"]
    COAM_WEBUI_Input_Value   xpath=//div[@class="hw-element-select-wrapper"]/input   text=${input_cell}
    COAM_WEBUI_Click_Button   xpath=//div[@class="hw-element-select-wrapper"]//div[contains(text(), "${input_cell}")]
    Sleep   1s
    ${new_cell_num}   COAM_WEBUI_Execute_Script   script=return document.querySelectorAll("div[distname*='NRCELL-']").length
    Should Be Equal As Numbers   ${new_cell_num}   ${cell_num+1}

Delete Cell In CW Site View
    [Arguments]   ${input_cell}
    ${cell_num}   COAM_WEBUI_Execute_Script   script=return document.querySelectorAll("div[distname*='NRCELL-']").length
    COAM_WEBUI_Click_Button
    ...   xpath=//div[contains(@class, "CELL-column")]//div[contains(@distname, '${input_cell}')]//button[@title="Remove"]
    COAM_WEBUI_Wait_For_Visibility   xpath=//ui-modal[@a-title="NR Cell Removal"]
    Sleep   1s
    COAM_WEBUI_Click_Button   xpath=//ui-modal[@a-title="NR Cell Removal"]//button[contains(text(),'OK')]
    Sleep   1s
    ${new_cell_num}   COAM_WEBUI_Execute_Script   script=return document.querySelectorAll("div[distname*='NRCELL-']").length
    Should Be Equal As Numbers   ${new_cell_num}   ${cell_num-1}

Last Copy Cell In CW Site View
    [Arguments]   ${input_cell}
    ${cell_num}   COAM_WEBUI_Execute_Script   script=return document.querySelectorAll("div[distname*='NRCELL-']").length
    COAM_WEBUI_Click_Button   xpath=(//div[contains(text(), "Add Cell")]/..//button/i[@class="copy"])[last()]
    COAM_WEBUI_Wait_For_Visibility   xpath=//div[@class="hw-element-select-wrapper"]
    COAM_WEBUI_Move_To_Element   xpath=//div[@class="hw-element-select-wrapper"]
    COAM_WEBUI_Input_Value   xpath=//div[@class="hw-element-select-wrapper"]/input   text=${input_cell}
    COAM_WEBUI_Click_Button   xpath=//div[@class="hw-element-select-wrapper"]//div[contains(text(), "${input_cell}")]
    Sleep   1s
    ${new_cell_num}   COAM_WEBUI_Execute_Script   script=return document.querySelectorAll("div[distname*='NRCELL-']").length
    Should Be Equal As Numbers   ${new_cell_num}   ${cell_num+1}

First Cell Set Cellgroup In CW Site View
    [Arguments]   ${input_cellgrp}
    COAM_WEBUI_Click_Button   xpath=(//button[@title='Change Cell Group'])[1]
    COAM_WEBUI_Wait_For_Visibility   xpath=//ul[@class="dropdown-list"]/li[contains(text(), '${input_cellgrp}')]
    COAM_WEBUI_Move_To_Element   xpath=//ul[@class="dropdown-list"]/li[contains(text(), '${input_cellgrp}')]
    COAM_WEBUI_Click_Button   xpath=//ul[@class="dropdown-list"]/li[contains(text(), '${input_cellgrp}')]

Get First RMOD Type In CW Site View
    ${rmod_type}   COAM_WEBUI_Execute_Script
    ...   script=return document.querySelectorAll("div[class='RMOD-column']")[0].firstElementChild.textContent.split('RMOD')[0]
    [Return]   ${rmod_type}

Get Last Cell In CW Site View
    ${last_cell}   COAM_WEBUI_Get_Element_Text
    ...   xpath=(//div[contains(@class, "CELL-column")][1]//span[contains(text(), 'NRCELL')])[last()]
    [Return]   ${last_cell}

Get Last Radio In CW Site View
    ${radio_line}   COAM_WEBUI_Get_Element_Text
    ...   xpath=(//div[contains(@aria-label, 'Radio Module')])[last()]//div[contains(@class, "second-line")]
    ${last_radio}   Set Variable   ${radio_line.split(' ')[0]}
    [Return]   ${last_radio}

Click Add Carriers In CW Site View
    [Arguments]   ${input_cell}
    COAM_WEBUI_Click_Button
    ...   xpath=//div[contains(@class, "CELL-column")]//div[contains(@distname, '${input_cell}')]//button[contains(@aria-label, "Add carriers")]
    Sleep   1s

Add Channel With Last Radio In CW Site View
    COAM_WEBUI_Click_Button
    ...   xpath=((//div[contains(@aria-label, 'Radio Module')])[last()]//div[@class="dropdown-icon"])[1]
    COAM_WEBUI_Wait_For_Visibility   xpath=//div[@class="modules-list"]
    COAM_WEBUI_Move_To_Element   xpath=//div[@class="modules-list"]
    COAM_WEBUI_Wait_For_Visibility   xpath=//div[@class="modules-list"]//div[contains(text(), 'TXRX')]
    COAM_WEBUI_Click_Button   xpath=//div[@class="modules-list"]//div[contains(text(), 'TXRX')]
    Sleep   1s

Click Add Cablink in CW Site View
    [Arguments]   ${input_radio}
    COAM_WEBUI_Wait_For_Visibility
    ...   xpath=(//div[contains(@class, "RMOD-column")]//div[contains(@distname, '${input_radio}')]//i[contains(@class, 'plug')])[1]
    COAM_WEBUI_Move_To_Element
    ...   xpath=(//div[contains(@class, "RMOD-column")]//div[contains(@distname, '${input_radio}')]//i[contains(@class, 'plug')])[1]
    COAM_WEBUI_Click_Button
    ...   xpath=(//div[contains(@class, "RMOD-column")]//div[contains(@distname, '${input_radio}')]//i[contains(@class, 'plug')])[1]
    Sleep   1s

Add Cablink With Last BBMOD In CW Site View
    COAM_WEBUI_Wait_For_Visibility
    ...   xpath=((//div[contains(@aria-label, 'Baseband Module')])[last()]//button[contains(@aria-label, 'addCablink')])[1]
    COAM_WEBUI_Move_To_Element
    ...   xpath=((//div[contains(@aria-label, 'Baseband Module')])[last()]//button[contains(@aria-label, 'addCablink')])[1]
    COAM_WEBUI_Click_Button
    ...   xpath=((//div[contains(@aria-label, 'Baseband Module')])[last()]//button[contains(@aria-label, 'addCablink')])[1]
    Sleep   1s
