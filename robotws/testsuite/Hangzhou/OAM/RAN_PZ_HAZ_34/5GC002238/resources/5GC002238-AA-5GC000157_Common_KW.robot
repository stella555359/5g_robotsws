*** Settings ***
Library    String
Library    DateTime
Library    taf.ul.selenium.netact    WITH NAME    selenetact
Library    taf.ul.swing.core    WITH NAME    swing
Resource    ../../common/coam_resource.robot

*** Variables ***
#NetAct
#${TLSmode}                   TLS
${TLSmode}                   no TLS
${NE_Type}                   MRBTS
${release}                   5G20BDU
#${release}                   5G20A
#${MR}                        MRC-5G/MR-5G
${MR}                        MRC-5GSC-HZ/MR-test
${IPversion}                 IPv4
${NE_IP}                     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
#${NetAct_URL}                https://dalianlbwas.dalian.srnhz.nsn-rdnet.net
${NetAct_URL}                https://gansulbwas.gansu.srnhz.nsn-rdnet.net
${NetAct_usr}                omc
${NetAct_pwd}                Nokia126_
${java_download_path}        /home/ute/Downloads
${Actual_CM_path}            /home/ute/Downloads
${cache}                     /home/ute/security_dialog_*.png
${Adminstration_folder}           //*[@id="calypso-container"]/div[2]/div/a[1]/img
${NE_Integration_Wizard_xpath}    //span[contains(text(),'NE Integration Wizard')]
${main_table_xpath}               //*[@id="mainForm:main_table"]
${total_xpath}                    //*[@id="mainForm:main_table:total_number_ne"]
${result_xpath}                   //*[@id="mainForm:main_table:result"]
${Monitoring_xpath}               //a[@class='folder app']//span[@class='appTitle'][contains(text(),'Monitoring')]
${Monitor_xpath}                  //a[24]//div[1]//span[1]
${configuration_xpath}            //a[@class='folder app']//span[@class='appTitle'][contains(text(),'Configuration')]
${CM_Operations_xpath}            //span[contains(text(),'CM Operations Manager')]
${CM_Editor_xpath}                //span[contains(text(),'CM Editor')]
# new
${mrbts_id}                MRBTS-${tl.gnbs[0].instance_id}
${DU_URL}                     https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}:8666/
${WEBUI_URL}                  https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${CU_addr}                    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${CU_username}                ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${CU_password}                ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
@{portstate}    true    false
@{e_list}
*** Keywords ***
#NetAct
#NetAct login/logout
Login netact
    log to console    Login netact
    Remove File    ${java_download_path}/*.jnlp
    selenetact.enable_virtual_display
    selenetact.Set Download Dir    ${java_download_path}
    Wait Until Keyword Succeeds   5m   30s   selenetact.Login    ${NetAct_URL}   ${NetAct_usr}   ${NetAct_pwd}
    Sleep     5

Logout netact
    log to console    Logout netact
    selenetact.logout
    selenetact.disable_virtual_display

#gNB integration on NetAct
Integrate_gNB_to_NetAct
    [Documentation]   Integrate gNB to NetAct
    ...    Example
    ...    |  Integrate_gNB_to_NetAct | ${mrbts_id} |
    [Arguments]   ${mrbts_id}
    log to console    Integrate_gNB_to_NetAct
    selenetact.open_sub_page   category_xpath=${Adminstration_folder}   page_xpath=${NE_Integration_Wizard_xpath}   page_name=NE_Integration_Wizard
    selenetact.switch_to_page    page_name=NE_Integration_Wizard
    sleep    5
    ${status}=   Check if NE or MR in Table list   TextField_xpath=//input[@id='mainForm:main_table:rootMOFilterInput']
    ...    Text=PLMN-PLMN/${mrbts_id}   main_table_xpath=${main_table_xpath}   total_xpath=${total_xpath}   result_xpath=${result_xpath}
    ${status_remove}=   Run Keyword If  ${status}   Delete Configuration   DN=PLMN-PLMN/${mrbts_id}
    ${status}=   Check if NE or MR in Table list   TextField_xpath=//input[@id='mainForm:main_table:rootMOFilterInput']
    ...   Text=PLMN-PLMN/${mrbts_id}   main_table_xpath=${main_table_xpath}   total_xpath=${total_xpath}   result_xpath=${result_xpath}
    Configure NE in NIEW Page   NE_Type=${NE_Type}    release=${release}    MR=${MR}    IP=${NE_IP}
    ...   IPversion=${IPversion}   TLSmode=${TLSmode}
    sleep    10
    ${status}=    Check if NE or MR in Table list   TextField_xpath=//input[@id='mainForm:main_table:rootMOFilterInput']
    ...   Text=PLMN-PLMN/${mrbts_id}   main_table_xpath=${main_table_xpath}   total_xpath=${total_xpath}   result_xpath=${result_xpath}
    ${status}=   Run Keyword And Return Status  Run Keyword If
    ...    ${status}   Integrate Action with Integrate Button    DN=PLMN-PLMN/${mrbts_id}
    Sleep   10s
    #${status}=   Run Keyword If  ${status}   Check Integration status   DN=PLMN-PLMN/${mrbts_id}
    selenetact.close_page   page_name=NE_Integration_Wizard
    sleep    30

Delete Configuration
    log to console    Delete Configuration
    [Arguments]   ${DN}
    #select
    ${status}    Select target With DN   ${DN}
    run keyword if  not ${status}   Return From Keyword   False
    #delete
    sleep   5s
    run keyword and ignore error  selenetact.wait_for_enable    //*[@id="deleteNEButton"]   20s
    Wait Until Keyword Succeeds   3 times   5s   selenetact.click_button    //*[@id="deleteNEButton"]
    run keyword and ignore error  selenetact.wait_for_enable   //*[@id="mainForm:deleteConfirmButton"]   20s
    ${status}=   Run Keyword And Return Status   Wait Until Keyword Succeeds   3 times   5s   selenetact.click_button
    ...    //*[@id="mainForm:deleteConfirmButton"]
    Input value on NEIW    //*[@id="mainForm:main_table:rootMOFilterInput"]   ${DN}
    FOR    ${i}    IN RANGE    5
        ${num_text}    Wait Until Keyword Succeeds   3 times   5s   selenetact.get_elem_text    //*[@id="mainForm:main_table:result"]
        ${num_text_reg}=   should match regexp  ${num_text}   \\d+
        ${num_nbr}=   BuiltIn.Convert To Integer   ${num_text_reg}
        ${status}    Run Keyword And Return Status    Should Be True    ${num}==0
        Exit For Loop If    ${status}
    END
    [Return]    ${status}

Input value on NEIW
    [Arguments]   ${TextField_xpath}   ${Text}
    ${TextField_text}=   Wait Until Keyword Succeeds   31s   10s   selenetact.get_elem_text   ${TextField_xpath}
    ${status}=   Run Keyword And Return Status   should match regexp   ${TextField_text}   ${Text}
    Return From Keyword If    ${status}
    FOR    ${i}    IN RANGE    5
        Wait Until Keyword Succeeds   31s   10s   selenetact.write_value_and_enter    ${TextField_xpath}    ${Text}
        ${TextField_text}=   Wait Until Keyword Succeeds   31s   10s   selenetact.get_elem_text   ${TextField_xpath}
        ${status}=   Run Keyword And Return Status   should match regexp   ${TextField_text}   ${Text}
        Exit For Loop If    ${status}
        Wait Until Keyword Succeeds   31s   10s   selenetact.click_button    ${TextField_xpath}
    END
    Sleep   5s
    [Return]    ${status}

Select Value Type From List
    [Arguments]    ${index}    ${value}   ${list_element_nbr}=3
    FOR   ${i}    IN RANGE    ${list_element_nbr}
        Wait Until Keyword Succeeds   3 times   5s   selenetact.click_button   ${index}
        ${status}=   Run Keyword And Return Status   Wait Until Keyword Succeeds   3 times   5s
    ...   selenetact.click_button    //*[@title="${value}"]
        Exit For Loop If   ${status}
    END
    sleep   2s
    Return From Keyword If   ${status}   ${status}
    [Return]    ${status}

Integrate Action with Integrate Button
    log to console    Integrate Action with Integrate Button
    [Arguments]   ${DN}
    #select DN
    ${status}    Select target With DN   ${DN}
    run keyword if  not ${status}   Return From Keyword   ${status}
    #integrate
    run keyword and ignore error  Wait Until Keyword Succeeds   3 times   5s   selenetact.wait_for_enable   //*[@id="mainForm:integrate"]
    ${status}    Run Keyword And Return Status    Wait Until Keyword Succeeds   3 times   5s
    ...   selenetact.Click Button   //*[@id="mainForm:integrate"]
    #check if reintegration dialog appeard
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   3 times   5s   selenetact.wait_for_visibility
    ...   //*[@id="mainForm:duplicatedMosPanel_shadow"]
    FOR    ${i}    IN RANGE    1
        Sleep    5s
        ${DNs}   selenetact.get_elem_text   //*[@id="mainForm:duplicatedList"]
        ${contain}   Run Keyword And Return Status   Should Contain   ${DNs}   ${DN}
        run keyword if  not ${contain}   FAIL   Dialog does not contain DN ${DN}.
        #confirm
        Run Keyword And Ignore Error   Wait Until Keyword Succeeds   3 times   5s
    ...   selenetact.wait_for_enable   //*[@id="mainForm:continueButton"]
        Wait Until Keyword Succeeds   3 times   5s   selenetact.Click Button   //*[@id="mainForm:continueButton"]
        Run Keyword And Ignore Error   Wait Until Keyword Succeeds   3 times   5s
    ...   selenetact.wait_for_enable   //*[@id="mainForm:withVerificationConfirmButton"]
        Wait Until Keyword Succeeds   3 times   5s   selenetact.Click Button   //*[@id="mainForm:withVerificationConfirmButton"]
        Run Keyword And Ignore Error   Wait Until Keyword Succeeds   3 times   5s   selenetact.wait_for_enable   //*[@id="newNEButton"]
    END

Select target With DN
    [Arguments]   ${DN}
    run keyword and ignore error  selenetact.wait_for_visibility    //*[@id="mainForm:main_table"]
    Input value on NEIW   //*[@id="mainForm:main_table:rootMOFilterInput"]   ${DN}
    #1, select
    ${status}  Run Keyword And Return Status   Wait Until Keyword Succeeds   3 times   5s   selenetact.select_checkbox
    ...   //*[@id="mainForm:main_table:selectAllCheckBox"]    #select all, only 1 is visible
    [Return]    ${status}

Check if NE or MR in Table list
    [Arguments]   ${TextField_xpath}   ${Text}   ${main_table_xpath}   ${total_xpath}   ${result_xpath}
    Wait Until Keyword Succeeds   31s   10s   selenetact.wait_for_visibility   ${main_table_xpath}
    Input value on NEIW  ${TextField_xpath}   ${Text}
    ${result_text}    Wait Until Keyword Succeeds   31s   10s   selenetact.get_elem_text    ${result_xpath}
    ${result_text_reg}=  Should Match Regexp   ${result_text}   \\d+
    ${result_text_nbr}=   BuiltIn.Convert To Integer   ${result_text_reg}
    ${status}=   Run Keyword If   "${result_text_nbr}"=="0"   set variable  False
    ...   ELSE   set variable  True
    [Return]  ${status}

Configure NE in NIEW Page
    log to console    Configure NE in NIEW Page
    [Arguments]    ${NE_Type}    ${release}    ${MR}    ${IP}    ${IPversion}   ${TLSmode}
    Wait Until Keyword Succeeds   3 times   5s   selenetact.click_button   //input[@id='newNEButton']
    run keyword and ignore error  Wait Until Keyword Succeeds   3 times   5s
    ...   selenetact.wait_for_visibility    //*[@id="newNEInitConfiguration_container"]
    run keyword and ignore error  Wait Until Keyword Succeeds   3 times   5s
    ...   selenetact.wait_for_visibility   //*[@id="selectionForm:neTypeFilterInput"]
    #select NE type
    ${status}   Select Value Type From List   //*[@id="selectionForm:neTypeFilterInput"]   ${NE_Type}
    #Select release
    ${status}   Select Value Type From List    //*[@id="selectionForm:adaptationReleaseFilterInput"]   ${release}
    #Select MR
    ${status}   Select Value Type From List   //*[@id="selectionForm:dynamicPanel:0:mrfqdnInput"]   ${MR}
    #input IP
    ${status}   Input value on NEIW
    ...    //*[starts-with(@id,'selectionForm:dynamicPanel:') and contains(@id,':address')]   ${IP}
    #input DN
    ${status}   Input value on NEIW
    ...    //*[starts-with(@id,'selectionForm:dynamicPanel:') and contains(@id,':fqdn')]    PLMN-PLMN/${mrbts_id}
    #input NE name
    ${status}   Input value on NEIW   //*[@id="selectionForm:dynamicPanel:3:string"]   ${mrbts_id}
    #input NE3SWS IP version
    ${status}   Select Value Type From List   //*[@id="selectionForm:dynamicPanel:6:enumInput"]   ${IPversion}
    #input NE3SWS agent security mode
    ${status}   Select Value Type From List   //*[@id="selectionForm:dynamicPanel:7:enumInput"]   ${TLSmode}
    #save button
    run keyword and ignore error   selenetact.wait_for_visibility   //*[@id="selectionForm:save"]
    Wait Until Keyword Succeeds   3 times   5s   selenetact.click_button    //*[@id="selectionForm:save"]

Check Integration status
    log to console    Check Integration status
    [Arguments]   ${DN}
    #filter
    Input value on NEIW    //*[@id="mainForm:main_table:rootMOFilterInput"]   ${DN}
    ${total_text}=   Wait Until Keyword Succeeds   5 times   5s   selenetact.get_elem_text    //*[@id="mainForm:main_table:total_number_ne"]
    ${total_text_reg}=   should match regexp  ${total_text}   \\d+
    ${total_nbr}=   BuiltIn.Convert To Integer   ${total_text_reg}
    FOR   ${i}    IN RANGE    ${total_nbr}
        ${status}   ${val}   Run Keyword And Ignore Error   selenetact.get_elem_text   //*[@id="mainForm:main_table:${i}:rootMO"]
        Continue For Loop If   '${status}'=='FAIL'
        ${index}   Set Variable If   '${val}'=='${DN}'   ${i}    #correct number of row.
        Exit For Loop If   '${val}'=='${DN}'
    END
    #wait until status not Ongoing
    Sleep   5s
    FOR   ${i}    IN RANGE    240
        ${status_int}   Wait Until Keyword Succeeds   5 times   5s   selenetact.get_elem_text
    ...   //*[@id="mainForm:main_table:${index}:integrationStatus"]
        Exit For Loop If    '${status_int}'!='Ongoing' and '${status_int}'!='In queue'
        ${mod}   Evaluate   ${i}%5
        Run Keyword If   '${mod}'=='0'   selenetact.click_button   //span[@class='buttonIcon spanIconforfocus refreshIcon']    #referesh
        Sleep   5s
    END
    Run Keyword If   '${status_int}'=='Ongoing'   LOG   Operation takes more than 20m.    WARN
    ${status}=   Run Keyword And Return Status   Should Be Equal   ${status_int}   Completed    #status completed
    #show details
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds   5 times   5s   selenetact.click_button
    ...   //*[@id="mainForm:main_table:${index}:integrationStatus"]
    Run Keyword And Ignore Error  selenetact.wait_for_enable   //*[@id="ShowFullLogLink"]
    #show full log
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds   5 times   5s   selenetact.click_button   //*[@id="ShowFullLogLink"]
    Run Keyword And Ignore Error  selenetact.wait_for_visibility   //*[@id="show_log_form:log_display_body"]
    ${output}    Run Keyword And Ignore Error  Wait Until Keyword Succeeds   5 times   5s   selenetact.get_elem_text
    ...   //*[@id="show_log_form:log_display_body"]
    [Return]    ${status}

#NetAct FM Operations
Open Monitoring
    log to console    Open Monitoring
    selenetact.Wait For Visibility    ${Monitoring_xpath}
    selenetact.Click Button    ${Monitoring_xpath}
    run keyword and ignore error    Wait Until Keyword Succeeds    3 times   5s    selenetact.Click Button    ${Monitoring_xpath}

Start Monitor
    log to console    Start Monitor
    selenetact.Wait For Visibility    ${Monitor_xpath}
    selenetact.Click Button    ${Monitor_xpath}
    swing.Setup    javaws_path=/usr/bin/javaws
    swing.Start Application    alias=app    jnlp_file=${java_download_path}/start.jnlp
    ...    close_security_dialogs=${True}    remote_port=${34213}    timeout=${500}
    swing.Application Started    Monitor     remote_port=${34213}
    swing.Switch to Application    Monitor

Perform FM upload
    log to console    Perform FM upload
    Wait Until Keyword Succeeds    30 sec    5 sec    swing.Select Main Window
    sleep    10s
    ${output}=    swing.List Components In Context
    swing.Select From Main Menu And Wait    Window|Reset Workspace
    sleep    3s
    swing.Select From Main Menu And Wait    Tools|Managed Objects|Object Explorer
    sleep    3s
    Wait Until Keyword Succeeds    16s    5s   swing.Select Tree Node    Objects    PLMN-PLMN|${mrbts_id}
    sleep    3s
    Wait Until Keyword Succeeds    16s    5s   swing.Select From Tree Node Popup Menu   Objects   PLMN-PLMN|${mrbts_id}  Alarm Upload
    sleep    15s
    Wait Until Keyword Succeeds    16s    5s   swing.Select From Tree Node Popup Menu   Objects   PLMN-PLMN|${mrbts_id}  Find In|Alarm List
    sleep    5s
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    1 min    5 sec
    ...   My Swing Table Row Count Should Be Stable    DesktopViewTable    8 sec
    ${status}    Check If Alarm Exist On Alarm List    DesktopViewTable    9255    Minor
    Should Be Equal    ${status}    ${False}

Get active alarm On Alarm list
    [Documentation]   Check if Swing Table Row Count is Stable
    ...    Example
    ...    |  Get active alarm On Alarm list |7109 | Critical |
    [Arguments]  ${alarm_nbr}   ${alarm_level}
    Wait Until Keyword Succeeds    30 sec    5 sec    swing.Select Main Window
    sleep    10s
    ${output}=    swing.List Components In Context
    swing.Select From Main Menu And Wait    Window|Reset Workspace
    sleep    3s
    swing.Select From Main Menu And Wait    Tools|Managed Objects|Object Explorer
    sleep    3s
    Wait Until Keyword Succeeds    16s    5s   swing.Select Tree Node    Objects    PLMN-PLMN|${mrbts_id}
    sleep    3s
    Wait Until Keyword Succeeds    16s    5s   swing.Select From Tree Node Popup Menu   Objects   PLMN-PLMN|${mrbts_id}  Find In|Alarm List
    sleep    5s
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    1 min    5 sec
    ...   My Swing Table Row Count Should Be Stable    DesktopViewTable    8 sec
    ${status}    Check If Alarm Exist On Alarm List    DesktopViewTable    ${alarm_nbr}    ${alarm_level}
    Should Be Equal    ${status}    ${True}

My Swing Table Row Count Should Be Stable
    [Documentation]   Check if Swing Table Row Count is Stable
    ...    Example
    ...    |  My Swing Table Row Count Should Be Stable |DesktopViewTable | 1 |
    [Arguments]    ${tableId}    ${sleepTimeSeconds}=5
    ${rowCount}=    swing.Get Table Row Count    ${tableId}
    Sleep    ${sleepTimeSeconds}s
    ${newRowCount}=    swing.Get Table Row Count    ${tableId}
    Should Be Equal As Integers    ${rowCount}    ${newRowCount}

Check If Alarm Exist On Alarm List
    [Documentation]   Check If Alarm Exist On Alarm List
    ...    *RETURN VALUE*
    ...    if alarm exists,return true and the row where alarm is located
    ...    if alarm doesn't exists,return false and none
    ...    Example
    ...    |  Check If Alarm Exist On Alarm List | DesktopViewTable | 7100 | Critical |
    [Arguments]    ${table_name}   ${alarmNbr}   ${severity}
    ${rowCount}=    swing.Get Table Row Count    ${table_name}
    FOR    ${index}    IN RANGE    ${rowCount}
       ${alarm_number}   wait until keyword succeeds  3 times   5s   swing.Get Table Cell Value   ${table_name}   ${index}   alarmName
       ${alarm_number_status}    run keyword if  '${alarm_number}'=='${alarmNbr}'   set variable  ${true}
        ...   ELSE   set variable  ${false}
       ${alarm_severity_status}=    Run Keyword If   '${alarm_number}' == '${alarmNbr}'   Checks Whether Given Alarm Severity Exists In Table Cell
       ...    ${severity}   ${table_name}   ${index}    0
       ${alarmRow}   set variable   ${index}
        Run Keyword If    ${alarm_severity_status} and ${alarm_number_status}    Exit For Loop
    END
    ${status}   Run Keyword If    ${alarm_severity_status} and ${alarm_number_status}    set variable  ${true}
    ...   ELSE   set variable  ${false}
    [Return]  ${status}

Checks Whether Given Alarm Severity Exists In Table Cell
    [Documentation]   Checks Whether Given Alarm Exists In Table Cell
    ...    *RETURN VALUE*
    ...    if alarm exists,return true
    ...    if alarm doesn't exists,return false
    ...    Example
    ...    |  Check If Alarm Exist On Alarm List | Critial |DesktopViewTable | 1 | 1 |
    [Arguments]  ${severity}   ${table}   ${rowCount}   ${columnCount}
    ${alarm_severity_column}    wait until keyword succeeds  3 times   5s   swing.Get Table Cell Value    ${table}    ${rowCount}   ${columnCount}
    ${alarm_severity_status}    run keyword if  '${alarm_severity_column}'=='${severity}'   set variable  ${true}
    ...   ELSE   set variable  ${false}
    [Return]  ${alarm_severity_status}

#NetAct CM Operations
Open Configuration
    log to console    Open Configuration
    selenetact.Wait For Visibility    ${configuration_xpath}
    selenetact.Click Button    ${configuration_xpath}
    run keyword and ignore error    Wait Until Keyword Succeeds    3 times   5s    selenetact.Click Button    ${configuration_xpath}

Start CM Operations Manager
    log to console    Start CM Operations
    selenetact.Wait For Visibility    ${CM_Operations_xpath}
    selenetact.Click Button    ${CM_Operations_xpath}
    swing.Setup    javaws_path=/usr/bin/javaws
    swing.Start Application    alias=CM Operation    jnlp_file=${java_download_path}/racpmc.jnlp
    ...    close_security_dialogs=${True}    remote_port=${34211}    timeout=${500}
    swing.Application Started    CM Operation     remote_port=${34211}
    swing.Switch to Application    CM Operation
    Sleep   10

Start CM Editor
    log to console   Start CM Editor
    selenetact.Click Button    ${CM_Editor_xpath}
    Sleep     5
    swing.Setup    javaws_path=/usr/bin/javaws
    swing.Start Application    alias=CM Editor    jnlp_file=${java_download_path}/cmedit.jnlp
    ...    close_security_dialogs=${True}    remote_port=${34212}    timeout=${500}
    swing.Application Started    CM Editor     remote_port=${34212}
    swing.Switch to Application    CM Editor
    Sleep   10

Connect to Test PC
    csn.connect_to
    ...    hostname=${host_addr}
    ...    username=${host_username}
    ...    password=${host_password}
    ...    alias=ute

Remove cache
    5GC002238-AA-5GC000157_Common_KW.Connect to Test PC
    sleep    3
    csn.send_command    rm ${cache}    connection=ute
    sleep    3
    csn.disconnect    connection=ute

#case level keyword

common_teardown_157
    run keyword and ignore error    WEBUI Logout
    FOR    ${i}    IN RANGE    6
        Run Keyword And Ignore Error    swing.Teardown
    END
    run keyword and ignore error    Logout netact
    run keyword and ignore error    selenetact.disable_virtual_display

Trigger fault 61652 on WebEM
    WEBUI Login
    #Get MRBTS Id online
    ${port_status}    Wait Until Keyword Succeeds    1min    10s
    ...    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/SECADM-1    filter_param=Activate service port state
    Run keyword if    '${port_status}' != '${portstate[0]}'    Change portstatus   ${portstate[0]}
    set test variable    ${default_port_status}    ${port_status}
    #Run Keyword If   '${port_status}' != '${portstate[0]}'     Validate and activate and check activate plan status


Clear fault 61652 on WebEM
    Run keyword if    '${default_port_status}' != '${portstate[0]}'    Change portstatus   ${portstate[1]}


Change portstatus
    [Arguments]    ${portstate_value}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/SECADM-1    filter_param=Activate service port state
    ...    new_value=${portstate_value}
    Validate and activate and check activate plan status
    ${current_value}    Wait Until Keyword Succeeds    1min    10s
    ...    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/SECADM-1    filter_param=Activate service port state
    should be equal    ${current_value}    ${portstate_value}

Check_alarm_NetAct
    Login netact
    Open Monitoring
    Start Monitor
#    Get active alarm On Alarm list    alarm_nbr=7109    alarm_level=Critical
    Get active alarm On Alarm list    alarm_nbr=7220    alarm_level=Minor
    run keyword and ignore error    swing.Teardown
    Logout netact

CM_Upload_NetAct
    Login netact
    Open Configuration
    Start CM Operations Manager
    CM.NetAct CM Upload    mrbts_id=${mrbts_id}
    run keyword and ignore error    swing.Teardown
    Logout netact



Create_CM_Plan_NetAct_BTSname
    Login netact
    Open Configuration
    Start CM Editor
    ${new_plan_name}    Create CM Plan    plan_name=${plan_name}
    set suite variable    ${new_plan_name}
    ${row_number}       Get Table Row        dist_name=${mrbts_id}
    set suite variable    ${row_number}
    Modify Exist Parameter in New Plan    dist_name=${mrbts_id}
    ...    plan_name_new=${new_plan_name}     row=${row_number}    column_plan=1    column_actual=2     new_value=${new_para_value}
    ${output}    Check CM Plan Create Succefully    new_plan_name=${new_plan_name}
    Should Be Equal    ${output}    PASS
    run keyword and ignore error    swing.Teardown
    Logout netact

Delete_plan_on_CM_Editor
    log to console    Delete_plan_on_CM_Editor
    Login netact
    Open Configuration
    Start CM Editor
    Delete CM Plan    new_plan_name=${new_plan_name}
    run keyword and ignore error    swing.Teardown
    Logout netact

Download_CM_Plan_NetAct_BTSname
    Login netact
    Open Configuration
    Start CM Operations Manager
    Download CM Plan    new_plan_name=${new_plan_name}
    run keyword and ignore error    swing.Teardown
    Logout netact

Download_validate_CM_Plan_NetAct_BTSname
    Login netact
    Open Configuration
    Start CM Operations Manager
    Download CM Plan    new_plan_name=${new_plan_name}
    Validate CM Plan    new_plan_name=${new_plan_name}
    run keyword and ignore error    swing.Teardown
    Logout netact

Activate_CM_Plan_NetAct_BTSname
    Login netact
    Open Configuration
    Start CM Operations Manager
    ${Backup_plan_name}    ${status}    Download CM Plan    new_plan_name=${new_plan_name}    create_back_plan=${True}
    set suite variable    ${Backup_plan_name}
    Activate CM Plan    new_plan_name=${new_plan_name}
    run keyword and ignore error    swing.Teardown
    Logout netact

Check_BTS_name_changed
    Login netact
    Open Configuration
    Start CM Editor
    ${row_number}       Get Table Row online       dist_name=${mrbts_id}
    set suite variable    ${row_number}
    ${BTS_name}    Get parameter value on CM Editor    dist_name=${mrbts_id}    row=${row_number}    column=1

    should be equal    ${BTS_name}    ${new_para_value}
    run keyword and ignore error    swing.Teardown
    Logout netact

Check_HW_User_label_changed
    Login netact
    Open Configuration
    Start CM Editor
    ${row_number}       Get Table Row online   key=User label    dist_name=${mrbts_id}/HW-1
    set suite variable    ${row_number}
    ${User_label}    Get parameter value on CM Editor    dist_name=${mrbts_id}/HW-1    row=${row_number}    column=1
    should be equal    ${User_label}   ${new_para_value}
    run keyword and ignore error    swing.Teardown
    Logout netact

Restore_CM_by_Backup_plan
    log to console    Restore_CM_by_Backup_plan
    Login netact
    Open Configuration
    Start CM Operations Manager
    Download CM Plan    new_plan_name=${Backup_plan_name}
    Activate CM Plan    new_plan_name=${Backup_plan_name}
    run keyword and ignore error    swing.Teardown
    Logout netact

Delete_New_and_Backup_plan_on_Operations Manager
    log to console    Delete_New_and_Backup_plan_on_Operations Manager
    Login netact
    Open Configuration
    Start CM Operations Manager
    Delete CM Plan on Operations Manager    new_plan_name=${new_plan_name}
    Delete CM Plan on Operations Manager    new_plan_name=${Backup_plan_name}
    run keyword and ignore error    swing.Teardown
    Logout netact

Provision_CM_Plan_NetAct_BTSname
    Login netact
    Open Configuration
    Start CM Operations Manager
    ${Backup_plan_name}    ${status}    Provision CM Plan    new_plan_name=${new_plan_name}    create_back_plan=${True}
    set suite variable    ${Backup_plan_name}
    run keyword and ignore error    swing.Teardown
    Logout netact

Modify_parameter_online_NetAct_BTSname
    Login netact
    Open Configuration
    Start CM Editor
    ${row_number}       Get Table Row online        dist_name=${mrbts_id}
    set suite variable    ${row_number}
    ${para_original_value}    ${CM_finished}    Modify parameter online
    ...    dist_name=${mrbts_id}    mrbts_id=${mrbts_id}    row=${row_number}    column=1    new_value=${new_para_value}
    set suite variable    ${para_original_value}
    run keyword and ignore error    swing.Teardown
    selenetact.logout

Restore_CM_by_online_modify
    log to console    Restore_CM_by_online_modify
    Login netact
    Open Configuration
    Start CM Editor
    ${row_number}       Get Table Row online       dist_name=${mrbts_id}
    set suite variable    ${row_number}
    Modify parameter online    dist_name=${mrbts_id}    mrbts_id=${mrbts_id}    row=${row_number}    column=1    new_value=${para_original_value}
    run keyword and ignore error    swing.Teardown
    Logout netact


Delete_send_to_Network_plan
    log to console    Delete_send_to_Network_plan
    Login netact
    Open Configuration
    Start CM Operations Manager
    Delete CM Plan on Operations Manager    new_plan_name=Sent_to_Network
    Delete CM Plan on Operations Manager    new_plan_name=Sent_to_Network
    run keyword and ignore error    swing.Teardown
    Logout netact

Delete_CM_and_send_to_Network_plan
    log to console    Delete_CM_and_send_to_Network_plan
    Login netact
    Open Configuration
    Start CM Operations Manager
    Delete CM Plan on Operations Manager    new_plan_name=Sent_to_Network
    Delete CM Plan on Operations Manager    new_plan_name=${new_plan_name}
    run keyword and ignore error    swing.Teardown
    Logout netact


Get Table Row online
    [Arguments]   ${dist_name}    ${key}=BTS name    ${column}=0   ${table_name}=Vertical actual table
    Wait Until Keyword Succeeds    30s    5s    swing.Select Main Window
    Wait Until Keyword Succeeds    10s    1s    swing.Select From Main Menu    View|Go To Managed Object...
    Wait Until Keyword Succeeds    10s    1s    swing.Select Window    Go To Managed Object
    Wait Until Keyword Succeeds    10s    1s    swing.Clear Text Field    goToViewTextFieldDN
    Wait Until Keyword Succeeds    10s    1s    swing.Type Into Text Field    goToViewTextFieldDN    PLMN-PLMN/${dist_name}
    Wait Until Keyword Succeeds    10s    1s    swing.Select Table Cell    objectSelectionTable    0    0
    Wait Until Keyword Succeeds    10s    1s    swing.Push Button    Go To
    Wait Until Keyword Succeeds    10s    1s    swing.Push Button    Close
    Wait Until Keyword Succeeds    30s    5s    swing.Select Main Window
    ${rowCount}   swing.Get Table Row Count    ${table_name}
    FOR    ${i}    IN RANGE    ${rowCount}
        log    ${i}
        ${rowValue}    swing.Get Table Cell Value    ${table_name}   ${i}    ${column}
        Exit For Loop IF    '${rowValue}'=='${key}'
    END
    [Return]     ${i}


Get Table Row
    [Arguments]   ${dist_name}    ${key}=BTS name    ${column}=0   ${table_name}=Vertical plan and actual table
    Wait Until Keyword Succeeds    30s    5s    swing.Select Main Window
    Wait Until Keyword Succeeds    10s    1s    swing.Select From Main Menu    View|Go To Managed Object...
    Wait Until Keyword Succeeds    10s    1s    swing.Select Window    Go To Managed Object
    Wait Until Keyword Succeeds    10s    1s    swing.Clear Text Field    goToViewTextFieldDN
    swing.Type Into Text Field    goToViewTextFieldDN    PLMN-PLMN/${mrbts_id}
    Wait Until Keyword Succeeds    10s    1s    swing.Select Table Cell    objectSelectionTable    0    0
    swing.Push Button    Go To
    swing.Push Button    Close
    Wait Until Keyword Succeeds    30s    5s    swing.Select Main Window
    ${rowCount}   swing.Get Table Row Count    ${table_name}
    FOR    ${i}    IN RANGE    ${rowCount}
        log    ${i}
        ${rowValue}    swing.Get Table Cell Value    ${table_name}   ${i}    ${column}
        Exit For Loop IF    '${rowValue}'=='${key}'
    END
    [Return]     ${i}


Check fault on WebEM
    [Arguments]    ${alarm_filter}   ${Alarm_ID_CP}    ${Alarm_name_CP}    ${Fault_ID_CP}
    ...    ${Fault_name_CP}    ${Severity_CP}    ${Alarm_ob_CP}
    @{alarm info}=    Wait Until Keyword Succeeds    5min    10s
    ...    selenium_coam.get_active_alarm_info    alarm_filter=${alarm_filter}    timeout=100
    ${fault_dic}   set variable    ${alarm info}[0]
    ${Alarm_ID}    set variable    ${fault_dic}[Alarm ID]
    ${Alarm_name}    set variable    ${fault_dic}[Alarm name]
    ${Fault_ID}    set variable    ${fault_dic}[Fault ID]
    ${Fault_name}    set variable    ${fault_dic}[Fault name]
    ${Severity}    set variable    ${fault_dic}[Severity]
    ${Alarming_object}    set variable    ${fault_dic}[Alarming object]
    should be equal     ${Alarm_ID}     ${Alarm_ID_CP}
    should be equal     ${Alarm_name}     ${Alarm_name_CP}
    should be equal     ${Fault_ID}     ${Fault_ID_CP}
    should be equal     ${Fault_name}     ${Fault_name_CP}
    should be equal     ${Severity}     ${Severity_CP}
    should be equal     ${Alarming_object}     ${Alarm_ob_CP}


Check fault disappear on WebEM
    [Arguments]    ${alarm_filter}
    @{alarm info}=    Wait Until Keyword Succeeds    5min    10s
    ...    selenium_coam.get_active_alarm_info    alarm_filter=${alarm_filter}    timeout=100
    should be equal    ${alarm info}    ${e_list}

Backup_SCF_file_on_WebEM
    log to console    Backup_SCF_file_on_WebEM
    ${flag_result}   ${scf_file}    Run Keyword And Ignore Error    selenium_coam.backup_bts_site_configuration    download_timeout=600
    sleep    5s
    ${scf_file_path}    OperatingSystem.Copy File    ${scf_file}    ${SAVE LOG DIRECTORY}
    set suite variable     ${scf_file_path}

Obtain_BTS_Name_ID
    Backup_SCF_file_on_WebEM
    ${BTS_Name}    Wait Until Keyword Succeeds    2min    10s
    ...    selenium_coam.get_parameter_value    dist_name=${mrbtsId}    filter_param=BTS name
    set suite variable     ${BTS_Name}
