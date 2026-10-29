*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ./Common.robot

*** Variables ***


*** Keyword ***
Open CW Modal View
    [Arguments]   ${step_name}=General BTS/Site Settings
    COAM_WEBUI_Click_Button   xpath=//a[contains(text(),'Steps')]
    COAM_WEBUI_Wait_For_Visibility   xpath=//wizard-steps
    Sleep   3s
    COAM_WEBUI_Input_Value   xpath=//input[@placeholder='Step name']   text=${step_name}
    COAM_WEBUI_Click_Button   xpath=//wizard-steps//span[text()="${step_name}"]
    COAM_WEBUI_Wait_For_Visibility   xpath=//div[contains(@class, 'wizard-steps-modal-container')]
    Sleep   3s

Open CW Modal View Cell Page
    [Arguments]   ${cell_type}=NR TDD   ${step_name}=Basic Cell Settings
    COAM_WEBUI_Click_Button   xpath=//a[contains(text(),'Steps')]
    COAM_WEBUI_Wait_For_Visibility   xpath=//wizard-steps
    Sleep   3s
    COAM_WEBUI_Input_Value   xpath=//input[@placeholder='Step name']   text=${cell_type}
    COAM_WEBUI_Click_Button   xpath=//wizard-steps//span[text()="${cell_type}"]
    Sleep   3s
    COAM_WEBUI_Click_Button   xpath=//wizard-steps//span[text()="${step_name}"]
    COAM_WEBUI_Wait_For_Visibility   xpath=//div[contains(@class, 'wizard-steps-modal-container')]
    Sleep   3s

Done CW Modal View
    COAM_WEBUI_Click_Button   xpath=//button[contains(text(),'Done')]
    Sleep   5s

Modify Input Parameter In CW Modal View
    [Arguments]   ${parameter_name}   ${value}
    # COAM_WEBUI_Input_Value   xpath=//wizard-parameter-input//label[contains(text(),'${parameter_name}')]/../..//input   text=${value}
    COAM_WEBUI_Input_Value   xpath=//label[contains(text(),'${parameter_name}')]/../..//input   text=${value}
    Sleep   5s

Select Parameter In CW Modal View
    [Arguments]   ${parameter_name}   ${value}
    COAM_WEBUI_Click_Button   xpath=//label[contains(text(), '${parameter_name}')]/../..//button
    Sleep   3s
    COAM_WEBUI_Scroll_To_Element   xpath=//label[contains(text(), '${parameter_name}')]/../..//wf-dropdown-item//span[contains(text(), '${value}')]
    COAM_WEBUI_Wait_For_Visibility   xpath=//label[contains(text(), '${parameter_name}')]/../..//wf-dropdown-item//span[contains(text(), '${value}')]
    COAM_WEBUI_Click_Button   xpath=//label[contains(text(), '${parameter_name}')]/../..//wf-dropdown-item//span[contains(text(), '${value}')]
    Sleep   5s

Get Input Parameter In CW Modal View
    [Arguments]   ${parameter_name}
    ${xpath}   Set Variable   //wizard-parameter-input//label[contains(text(),'${parameter_name}')]/../..//input
    ${value}   COAM_WEBUI_Execute_Script
    ...   script=return document.evaluate("${xpath}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.value
    Sleep   5s
    [Return]   ${value}

Add SMOD IN CW Modal View
    [Arguments]   ${product_code}=ASIK (474021A)
    COAM_WEBUI_Click_Button   xpath=//button[contains(text(),'Add SMOD')]
    COAM_WEBUI_Wait_For_Visibility   xpath=//div[@class='wizard-widget-container']/div[@class='hw-element-select-wrapper']
    Sleep   3s
    COAM_WEBUI_Input_Value
    ...   xpath=//div[@class='wizard-widget-container']/div[@class='hw-element-select-wrapper']/input
    ...   text=${product_code}
    COAM_WEBUI_Click_Button
    ...   xpath=//div[@class='wizard-widget-container']/div[@class='hw-element-select-wrapper']//div[contains(text(), "${product_code}")]
    Sleep   3s

Add BBMOD IN CW Modal View
    [Arguments]   ${product_code}=ABIL 474020A
    COAM_WEBUI_Click_Button   xpath=//span[contains(text(),'Add BBMOD')]
    COAM_WEBUI_Wait_For_Visibility   xpath=//ul[@class='dropdown-menu scroll-dropdown-native']
    Sleep   3s
    COAM_WEBUI_Click_Button   xpath=//span[contains(text(),'${product_code}')]
    COAM_WEBUI_Wait_For_Visibility   xpath=//wizard-expandable-panel
    Sleep   3s

Add RMOD IN CW Modal View
    [Arguments]   ${product_code}=AHFB 474036A
    COAM_WEBUI_Click_Button   xpath=//span[contains(text(),'Add RMOD')]
    COAM_WEBUI_Wait_For_Visibility   xpath=//ul[@class='dropdown-menu scroll-dropdown-native']
    COAM_WEBUI_Input_Value
    ...   xpath=//ul[@class='dropdown-menu scroll-dropdown-native']//input[@type='search']
    ...   text=${product_code}
    COAM_WEBUI_Click_Button   xpath=//span[contains(text(),'${product_code}')]
    COAM_WEBUI_Wait_For_Visibility   xpath=//wizard-expandable-panel
    Sleep   3s

Add RMOD Link IN CW Modal View
    [Arguments]   ${bbmod}=BBMOD-1   ${start_point}=S-RF1   ${rmod}=RMOD-1   ${end_point}=OPT-IF1   ${type}=FDDCPRI
    COAM_WEBUI_Click_Button   xpath=//rmod-link-configuration//ui-expandable-panel//module-header[contains(text(), "${bbmod}")]
    COAM_WEBUI_Wait_For_Visibility   xpath=//ui-expandable-panel-body
    Sleep   3s
    # Available RMOD modules
    COAM_WEBUI_Click_Button   xpath=//ui-expandable-panel-body//table/tbody//td[contains(text(), '${start_point}')]/following-sibling::td[1]
    COAM_WEBUI_Wait_For_Visibility   xpath=//ul[@class='dropdown-menu scroll-dropdown-native']
    COAM_WEBUI_Click_Button   xpath=//ul[@class='dropdown-menu scroll-dropdown-native']/wf-dropdown-item//span[contains(text(), '${rmod}')]
    Sleep   3s
    # End point
    COAM_WEBUI_Click_Button   xpath=//ui-expandable-panel-body//table/tbody//td[contains(text(), '${start_point}')]/following-sibling::td[2]
    COAM_WEBUI_Wait_For_Visibility   xpath=//ul[@class='dropdown-menu scroll-dropdown-native']
    COAM_WEBUI_Click_Button   xpath=//ul[@class='dropdown-menu scroll-dropdown-native']/wf-dropdown-item//span[contains(text(), '${end_point}')]
    Sleep   3s
    # Radio protocol type
    COAM_WEBUI_Click_Button   xpath=//ui-expandable-panel-body//table/tbody//td[contains(text(), '${start_point}')]/following-sibling::td[3]
    COAM_WEBUI_Wait_For_Visibility   xpath=//ul[@class='dropdown-menu scroll-dropdown-native']
    COAM_WEBUI_Click_Button   xpath=//ul[@class='dropdown-menu scroll-dropdown-native']/wf-dropdown-item//span[contains(text(), '${type}')]
    Sleep   3s

Add NRCELL IN CW Modal View
    [Arguments]   ${cell_name}=cell0   ${cell_id}=0   ${local_cell_id}=0   ${physical_cell_id}=0
    COAM_WEBUI_Click_Button   xpath=//button[contains(text(),'Add NRCELL')]
    COAM_WEBUI_Wait_For_Visibility   xpath=//nr-cell-definition//wizard-expandable-panel
    Modify Input Parameter In CW Modal View   parameter_name=Cell name   value=${cell_name}
    Modify Input Parameter In CW Modal View   parameter_name=Cell ID   value=${cell_id}
    Modify Input Parameter In CW Modal View   parameter_name=Local cell resource ID   value=${local_cell_id}
    Modify Input Parameter In CW Modal View   parameter_name=Physical layer cell ID   value=${physical_cell_id}

Cell Antennas Settings
    [Arguments]   ${ant_set}   ${rmod}=RMOD-1
    FOR   ${index}   IN   @{ant_set.keys()}
       Select ANT Settings   rmod=${rmod}   ant_idx=${index}   set=${ant_set['${index}']}
    END

Select ANT Settings
    [Arguments]   ${rmod}=RMOD-1   ${ant_idx}=1   ${set}=TXRX
    COAM_WEBUI_Scroll_To_Element   xpath=(//div[@class='cell-mapping-table-container']//table)[last()]
    Sleep   3s
    ${xpath}   Set Variable
    ...   //div[@class='cell-mapping-table-container']//table/tbody//td[contains(text(), '${rmod}')]/following-sibling::td[${ant_idx}]
    ${list_xpath}   Set Variable   //span[contains(text(), '${set}')]
    Wait Until Keyword Succeeds   3 times   2s   Run Keywords
    ...   COAM_WEBUI_Click_Button   xpath=${xpath}//button   AND
    ...   Sleep   3s   AND
    ...   COAM_WEBUI_Wait_For_Visibility   xpath=${xpath}${list_xpath}
    COAM_WEBUI_Click_Button   xpath=${xpath}${list_xpath}
    Sleep   3s

Modify Cell Carriers
    [Arguments]   ${freqBand}   ${cell_power}
    ...   ${chBwDl}   ${chBwUl}
    ...   ${nrarfcnDl}   ${nrarfcnUl}
    ...   ${cell_type}=FDD
    ...   ${cell_obj}=NRCELL-0
    # COAM_WEBUI_Click_Button   xpath=//span[contains(text(), '${cell_type}')]/../../..//button[@ui-tooltip="Expand all"]
    ${pre_xpat}   Set Variable
    ...   //wizard-accordion-header[contains(@title, '${cell_obj}')]/../../../../../../../div[contains(@class, 'ui-expandable-panel-body')]
    #Frequency band Indicator NR
    COAM_WEBUI_Input_Value   xpath=${pre_xpat}//label[contains(text(),'Frequency band Indicator NR')]/../..//input   text=${freqBand}
    #NRARFCN(TX RX)
    COAM_WEBUI_Input_Value   xpath=(${pre_xpat}//label[contains(text(),'NRARFCN')]/../..//input)[1]   text=${nrarfcnDl}
    COAM_WEBUI_Input_Value   xpath=(${pre_xpat}//label[contains(text(),'NRARFCN')]/../..//input)[2]   text=${nrarfcnUl}
    #Bandwidth
    #Cellpower
    Wait Until Keyword Succeeds   3 times   2s   Select Parameter In CW Modal View   parameter_name=Cell power   value=${cell_power}

Add NR Cell Group IN CW Modal View
    [Arguments]   ${grp_obj}=NRCELLGRP-0   ${scs}=15 KHz
    COAM_WEBUI_Click_Button   xpath=//button[contains(text(),'Add NR Cell Group')]
    Sleep   3s
    Run Keyword And Ignore Error   COAM_WEBUI_Click_Button   xpath=//nr-cell-group-configuration//button[@ui-tooltip="Expand all"]
    Sleep   3s
    Select Parameter In CW Modal View   parameter_name=SCS   value=${scs}
    Sleep   3s

NR Cell Assignment to Group
    [Arguments]   ${cell_id}=0   ${grp_obj}=NRCELLGRP-0
    COAM_WEBUI_Click_Button
    ...   xpath=//nr-cell-and-cell-group-mapping//table//td[1]//div[contains(text(), '${cell_id}')]/../../../../../../../..//button
    COAM_WEBUI_Wait_For_Visibility   xpath=//span[contains(text(),'${grp_obj}')]
    COAM_WEBUI_Click_Button   xpath=//span[contains(text(),'${grp_obj}')]
    Sleep   3s

