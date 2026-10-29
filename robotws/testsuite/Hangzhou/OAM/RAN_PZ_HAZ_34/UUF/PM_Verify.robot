*** Settings ***
Resource   ../5GI000114/Resource/NetAct_Fast_Pass_common.robot

Documentation
    ...    Author: johnny.1.jiang@nokia-sbell.com

*** Variables ***
${counters}    //*[@class="ReactVirtualized__Grid__innerScrollContainer"]
${custom}     //*[@class="epic-layout-panel "]/pm-tree-wrapper/pm-menu/pm-menu-item/pm-menu/pm-menu-item[4]/div/span
${absolute_time}    //*[@id="text-dialog-confirm"]/epic-wizard/epic-wizard-step[2]/div/pm-time-selection/epic-tabs
${object_selection}    //*[@id="text-dialog-confirm"]/epic-wizard/epic-wizard-step[3]/div/pm-object-filter/epic-tabs



*** Keyword ***
Case Setup: PM Verify Pipe
    Remove File    ${OUTPUT_DIR}/start.jnlp
    Open Netact Start Page    ${START_PAGE}    ${START_PAGE_USER}    ${START_PAGE_PASSWORD}    ${false}
    selenium_netact.open_sub_page   category_xpath=//*[@id="calypso-container"]/div[2]/div/a[4]/img
    ...     page_xpath=//*[@id="calypso-container"]/div[2]/div/a[29]/img
    ...     page_name=Performance Manager+
    selenium_netact.wait_for_visibility      elem_xpath=//*[@class="content-explorer-placeholder"]

Case Teardown: PM Verify Pipe
    Run Keyword And Ignore Error   Close All Java Application Forced
    Run Keyword And Ignore Error   selenium_netact.Logout
    Run Keyword And Ignore Error   selenium_coam.Logout
    Run Keyword And Ignore Error   Common Case Teardown
    run keyword if test failed  run keyword and ignore error  Catch Logs from NetAct   node_ip=${HOST_IP['${WAS_DMGR_HOSTS[0]}']}
    ...   username=${ROOT_USER}    password=${ROOT_PASSWORD}   Log_Area=PM
    run keyword if test failed  run keyword and ignore error  Catch Logs from NetAct
    ...   node_ip=${HOST_IP['${JBI_COMMONMEDIATION_HOSTS[0]}']}    username=${ROOT_USER}    password=${ROOT_PASSWORD}   Log_Area=COMMON_MEDIATION