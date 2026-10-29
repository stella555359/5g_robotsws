*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/NetAct_Fast_Pass_common.robot


*** Variables ***
${counters}    //*[@class="ReactVirtualized__Grid__innerScrollContainer"]
${custom_old}     //*[@class="epic-layout-panel "]/pm-tree-wrapper/pm-menu/pm-menu-item/pm-menu/pm-menu-item[4]/div/span
${custom_new}     //*[@class="epic-layout-panel "]/pm-tree-wrapper/pm-menu/pm-menu-item/pm-menu/pm-menu-item[5]/div/span
${absolute_time}   //label[text()='Absolute time']/../input
${continue_button}    //*[@class="csfWidgets button datagrid-row-actions button--call-to-action"]
${script_cmd_pm_new}    document.querySelector('.ReactVirtualized__List').scrollTo(0,1200) 
${script_cmd_pm_old}    document.querySelector('.ReactVirtualized__List').scrollTo(0,1200)

*** Keyword ***
PM_Verify_PM_pipe_Test_Case
    Step1: Select the NR Cell Availability
    Step2: Add New Board Custom
    Step3: Check Chart Data
    #Step4: Check PM Error Log

Step1: Select the NR Cell Availability
    selenium_netact.wait_for_enable     elem_xpath=${counters}//div[3]//*[@class="node "]/../i
    Sleep   15s
    selenium_netact.click_button    button_xpath=${counters}//div[3]//*[@class="node "]/../i
    Sleep   3s
    #Run Keyword If   '${NETACT}'!='CLAB737'   selenium_netact.execute_script   script_cmd=${script_cmd_pm_old}
    selenium_netact.execute_script   script_cmd=${script_cmd_pm_new}
    Sleep   10s
    selenium_netact.click_button    button_xpath=${counters}//div[10]//*[@class="node "]/../i
    Sleep   20s
    selenium_netact.execute_script      script_cmd=document.querySelector('.ReactVirtualized__List').scrollTo(0,1720)
    Sleep   15s
    selenium_netact.move_to_element   elem_xpath=${counters}//div[9]
    Sleep   5s
    selenium_netact.click_button    button_xpath=${counters}//div[9]//span/div/div[2]/button
    Sleep   5s
    selenium_netact.move_to_element   elem_xpath=//*[@class="epic-layout-panel "]/pm-tree-wrapper/pm-menu/pm-menu-item/div/span[1]
    Sleep   3s
    selenium_netact.click_button   button_xpath=${custom_new}
    #Run Keyword If    '${NETACT}'!='CLAB737'    selenium_netact.click_button   button_xpath=${custom_new}
    #selenium_netact.click_button   button_xpath=${custom_old}
    Sleep   10s

Step2: Add New Board Custom
    # -----------------step 2------------------
    # selenium_netact.click_button   button_xpath=${absolute_time}
    # Sleep   3s
    # -----------------step 3------------------
    wait until keyword succeeds  30s   5s   selenium_netact.click_button   button_xpath=${continue_button}
    Sleep   3s
    selenium_netact.click_button   button_xpath=//epic-radio//div[@class="radio-small "][2]
    Sleep   3s
    wait until keyword succeeds  30s   5s   selenium_netact.click_button   button_xpath=${continue_button}
    Sleep   3s
    selenium_netact.click_button   button_xpath=//div[contains(text(),'PLMN')]
    Sleep   3s
    selenium_netact.click_button   button_xpath=//div[contains(@class,'items open ps-container ps-theme-default')]//span[text()='NRBTS']
    Sleep   10s
    selenium_netact.click_button   button_xpath=//li[contains(@title, '${NO_NAME}')]
    Sleep   3s
    selenium_netact.click_button   button_xpath=//div[@class='actions']/button[1]
    Sleep   3s
    # -----------------step 4------------------
    wait until keyword succeeds  30s   5s   selenium_netact.click_button   button_xpath=${continue_button}
    #selenium_netact.click_button   button_xpath=//*[@class="navbar"]/div/ul/li[4]/div/a/span
    Sleep   3s
    selenium_netact.click_button   button_xpath=//*[@class="select-wrap left"]/pm-select-box/div/ul/li[3]
    Sleep   3s
    wait until keyword succeeds  30s   5s   selenium_netact.click_button   button_xpath=${continue_button}
    #selenium_netact.move_to_element   elem_xpath=//*[@id="finish-epic"]
    Sleep   3s
    wait until keyword succeeds  30s   5s   selenium_netact.click_button   button_xpath=${continue_button}
    Sleep   3s

Step3: Check Chart Data
    selenium_netact.wait_for_visibility     elem_xpath=//*[@class="chart "]    timeout=70
    selenium_netact.move_to_element   elem_xpath=//*[@class="chart "]
    ${value}    selenium_netact.get_elem_text   elem_xpath=//*[@class='chart ']/div/*[name()='svg']/*[name()='g'][9]/*[name()='text'][2]
    Run Keyword If    '${value}'=='0'  Fail
    ...    ELSE    log    'validation succeed!'
    Sleep   3s
    selenium_netact.move_to_element   elem_xpath=//*[@class="chart "]
    Sleep   3s
    selenium_netact.click_button   button_xpath=//*[@class="chart "]
    Sleep   3s
    selenium_netact.click_button   button_xpath=//*[@class="hover-provider "]/pm-panel-header/div/div/panel-options/span
    Sleep   3s
    selenium_netact.click_button   button_xpath=//*[@class="hover-provider "]/pm-panel-header/div/div/panel-options/pm-menu/pm-menu-item
    Sleep  5s
    selenium_netact.execute_script      script_cmd=document.querySelector('.ag-body-viewport').scrollTo(400,0)
    Sleep   3s
    ${value2}    selenium_netact.get_elem_text   elem_xpath=//*[@id="csf-data-grid-1-actions-header-0"]/div[2]
    Run Keyword If    '${value2}'=='0' or '${value2}'=='----'   log    ${value2}
    ...    ELSE    log    'validation succeed!'

Step4: Check PM Error Log
    ${current_time}   Get Current Date   result_format=epoch
    ${yesterday_time}   Subtract Time From Date   ${current_time}   8 hours   result_format=epoch

    ${pm_file_path}   Set Variable   /var/opt/oss/log/etload/werlogA51A.0.log
    FOR   ${index}    IN RANGE    len(${PM_HOSTS})
      csn.Connect To  hostname=${HOST_IP['${PM_HOSTS[${index}]}']}  username=${SERVICE_USER}  password=${SERVICE_PASSWORD}
      ...   alias=PM_${index}  timeout=60
      csn.Download File  remote_path=${pm_file_path}  local_path=${OUTPUT_DIR}/werlogA51A.0.${index}.log  connection=PM_${index}
      ${output}   csn.Execute   command=cat ${pm_file_path}   connection=PM_${index}   timeout=60
      csn.Disconnect   connection=PM_${index}
      Check PM Output Detail   ${output}   ${yesterday_time}
    END

   [Teardown]   Run Keyword And Ignore Error   csn.Reset Cache

Check PM Output Detail
    [Arguments]   ${output}   ${yesterday_time}
    ${output}   Strip String   ${output}   characters=-\r\n
    @{detail_list}   Split String   ${output}   ------------
    Reverse List   ${detail_list}
    FOR   ${detail}   IN   @{detail_list}
       ${detail_time}   Get Lines Containing String   ${detail}   Time:
       ${detail_time}   Remove String   ${detail_time}   Time:${SPACE}
       ${detail_time}   Format_Date_String   date_str=${detail_time}
       Run Keyword If   ${detail_time} > ${yesterday_time}   Log To Console   ${detail}
       Run Keyword If   ${detail_time} > ${yesterday_time}   Should Not Contain   ${detail}   ${MO_NAME}
       Exit For Loop If   ${detail_time} < ${yesterday_time}
    END

Case Setup: PM Verify Pipe
    Remove File    ${OUTPUT_DIR}/start.jnlp
    Open Netact Start Page   url=${START_PAGE}   username=${START_PAGE_USER}   password=${START_PAGE_PASSWORD}   showall=${false}
    selenium_netact.open_sub_page   category_xpath=//span[text()='Reporting']
    ...     page_xpath=//span[text()='Performance Manager+']
    ...     page_name=Performance Manager+
    Run Keyword If    '${NETACT}'!='CLAB737'    selenium_netact.wait_for_visibility      elem_xpath=//*[@class="tree-explorer-placeholder"]
    ...    ELSE    selenium_netact.wait_for_visibility      elem_xpath=//*[@class="content-explorer-placeholder"]
    Sleep   10s

Case Teardown: PM Verify Pipe
    Run Keyword And Ignore Error   Close All Java Application Forced
    Run Keyword And Ignore Error   selenium_netact.Logout
    Run Keyword And Ignore Error   selenium_coam.Logout
