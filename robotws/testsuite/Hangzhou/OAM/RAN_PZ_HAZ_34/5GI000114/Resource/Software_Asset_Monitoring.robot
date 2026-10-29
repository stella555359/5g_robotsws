*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Library    taf.ul.selenium.netact    WITH NAME    selenium_netact

*** Variables ***
${config_form}   modules:moduleConfigurationWizardForm
${config_step}   ${config_form}:wizardStep
${time_boundary}   ${config_step}:excludedPeriod_timeBoundariesView

*** Keyword ***
Check Module Definitions
    [Arguments]   ${table_id}=modules:modulesForm:moduleResultTable   ${row}=0
    ...   ${check_name}=Example   ${check_type}=5G RAN CM   ${check_enabled}=Yes   ${check_mail}=Default   ${check_user}=System
    #Check element text correct
    ${module_name}   selenium_netact.get_elem_text   //td[@id='${table_id}:${row}:${row}:moduleNameColumn']
    ${module_type}   selenium_netact.get_elem_text   //td[@id='${table_id}:${row}:${row}:moduleTypeColumn']
    ${module_enabled}   selenium_netact.get_elem_text   //td[@id='${table_id}:${row}:${row}:moduleEnabledColumn']
    ${mail_settings}   selenium_netact.get_elem_text   //td[@id='${table_id}:${row}:${row}:mailSettingsColumn']
    ${user}   selenium_netact.get_elem_text   //td[@id='${table_id}:${row}:${row}:userColumn']
    Should Contain   ${module_name}   ${check_name}
    Should Contain   ${module_type}   ${check_type}
    Should Contain   ${module_enabled}   ${check_enabled}
    Should Contain   ${mail_settings}   ${check_mail}
    Should Contain   ${user}   ${check_user}

Check Module Button Enabled
    [Arguments]   ${table_id}=modules:modulesForm:moduleResultTable   ${row}=0
    ...   ${btn_modify}=enabled   ${btn_delete}=disabled   ${btn_report}=enabled
    ${action_ele}   Set Variable   //td[@id='${table_id}:${row}:${row}:actionColumn']
    ${modify_class}   selenium_netact.get_element_attribute   ${action_ele}//img[@alt='Modify']   class
    ${delete_class}   selenium_netact.get_element_attribute   ${action_ele}//img[@alt='Delete']   class
    ${report_class}   selenium_netact.get_element_attribute   ${action_ele}//img[@alt='Generate report']   class

    Run Keyword If   '${btn_modify}'!='enabled' and '${btn_modify}'!='disabled'   Fail   Parameter 'btn_modify' Error!
    Run Keyword If   '${btn_delete}'!='enabled' and '${btn_delete}'!='disabled'   Fail   Parameter 'btn_delete' Error!
    Run Keyword If   '${btn_report}'!='enabled' and '${btn_report}'!='disabled'   Fail   Parameter 'btn_report' Error!
    #Check Button Status
    Run Keyword If   '${btn_modify}'=='enabled'   Should Not Contain   ${modify_class}   disabled
    ...   ELSE   Should Contain   ${modify_class}   disabled
    Run Keyword If   '${btn_delete}'=='enabled'   Should Not Contain   ${delete_class}   disabled
    ...   ELSE   Should Contain   ${delete_class}   disabled
    Run Keyword If   '${btn_report}'=='enabled'   Should Not Contain   ${report_class}   disabled
    ...   ELSE   Should Contain   ${report_class}   disabled

Delete Module
    [Arguments]   ${table_id}=modules:modulesForm:moduleResultTable   ${row}=0
    selenium_netact.wait_for_visibility   //a[@id='${table_id}:${row}:${row}:deleteButton']
    selenium_netact.click_button   //a[@id='${table_id}:${row}:${row}:deleteButton']
    selenium_netact.wait_for_visibility   //input[@id='modules:module_confirmNotificationRemovalView:okBtn']
    selenium_netact.click_button   //input[@id='modules:module_confirmNotificationRemovalView:okBtn']
    Sleep   20s

Basic Configuration Settings
    [Arguments]   ${module_name}=Example   ${module_type}=5G RAN CM   ${enabled}=Yes
    #Input Name
    selenium_netact.write_value   //input[@id='${config_step}:moduleName']   ${module_name}
    #Input Module type
    selenium_netact.write_value   //input[@id='${config_step}:moduleTypecomboboxField']   ${module_type}
    #Input Enabled
    selenium_netact.write_value   //input[@id='${config_step}:moduleEnabledcomboboxField']   ${enabled}
    Sleep   3s

Report Generation Scheduling
    #Repeat daily at
    selenium_netact.wait_for_visibility   //input[@id='${config_step}:dailyAt']
    selenium_netact.write_value   //input[@id='${config_step}:dailyAt']   12:30
    #Add New
    selenium_netact.click_button   //a[@id='${config_step}:addNewExcludedPeriod']
    selenium_netact.wait_for_visibility   //div[@id='${time_boundary}:excludedPeriod_timeBoundariesCDiv']
    #Click Start Date
    selenium_netact.click_button   //table[@id='${time_boundary}:startedAfter']//tr[1]/td//td[4]
    Sleep   2s
    selenium_netact.click_button   //td[@id='${time_boundary}:startedAfterDayCell15']
    Sleep   2s
    #Click End Date
    selenium_netact.click_button   //table[@id='${time_boundary}:startedBefore']//tr[1]/td//td[4]
    Sleep   2s
    selenium_netact.click_button   //td[@id='${time_boundary}:startedBeforeDayCell16']
    Sleep   2s
    #Click OK
    selenium_netact.click_button   //input[@id='${time_boundary}:okButton']
    Sleep   3s

Aggregation Level
    [Arguments]   ${Agg_level}=Off   ${highest_value}=1
    #Aggregation level
    selenium_netact.wait_for_visibility   //input[@id='${config_step}:moduleFloatingcomboboxField']
    selenium_netact.write_value   //input[@id='${config_step}:moduleFloatingcomboboxField']   ${Agg_level}
    #Use <N>th highest value
    selenium_netact.wait_for_visibility   //input[@name='${config_step}:moduleNthMaxValue']
    selenium_netact.write_value   //input[@name='${config_step}:moduleNthMaxValue']   ${highest_value}
    Sleep   3s

Select All Features
    selenium_netact.wait_for_visibility   //a[@id='${config_step}:definitionsTable:selectAllCheckBox']
    ${img_src} =   selenium_netact.get_element_attribute   //a[@name='${config_step}:definitionsTable:selectAllCheckBox']/img   src
    Run Keyword If   ${img_src.find('allSelected')}==-1   selenium_netact.click_button   //a[@id='${config_step}:definitionsTable:selectAllCheckBox']
    Sleep   3s

Edit Selected Features Details
    [Arguments]   ${row}=0   ${initial_base}=1   ${warning_threshold}=2
    selenium_netact.wait_for_visibility   //table[@id='${config_step}:definitionsEditTable']
    selenium_netact.write_value   //input[@id='${config_step}:definitionsEditTable:${row}:${row}:initialBaseValue']   ${initial_base}
    selenium_netact.write_value   //input[@id='${config_step}:definitionsEditTable:${row}:${row}:warningThreshold']   ${warning_threshold}
    Sleep   3s
