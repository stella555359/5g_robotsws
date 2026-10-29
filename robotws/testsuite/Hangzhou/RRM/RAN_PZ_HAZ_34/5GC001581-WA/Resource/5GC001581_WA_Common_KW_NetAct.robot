*** Settings ***
Documentation     author: xinzhu
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: xinran.zhu@nokia-sbell.com


Library    String
Library    DateTime
Library    taf.ul.selenium.netact    WITH NAME    selenetact
Library    taf.ul.swing.core    WITH NAME    swing
Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    ./5GC001581-WA-keyword.robot




*** Variables ***
#NetAct
#${TLSmode}                   TLS
${TLSmode}                   no TLS
${NE_Type}                   MRBTS
${release}                   5G20BDU
#${release}                   5G20A
#${MR}                        MRC-5G/MR-5G
${MR}                        MRC-5GSC-HZ/MR-5GSCIV-HZ
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
${nrbts_id}                NRBTS-${tl.gnbs[0].global_bts_id}
${DU_URL}                     https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}:8666/
${WEBUI_URL}                  https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${CU_addr}                    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${CU_username}                ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${CU_password}                ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
@{portstate}    true    false
${connection}    COAM
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
    Connect to Test PC
    sleep    3
    csn.send_command    rm ${cache}    connection=ute
    sleep    3
    csn.disconnect    connection=ute


CM_Upload_NetAct
    Login netact
    Open Configuration
    Start CM Operations Manager
    CM.NetAct CM Upload    mrbts_id=${mrbts_id}
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




Login_DU_WEBEM
    [Arguments]    ${connection}=COAM
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    Set suite variable    ${connection}

Modify_PM_parameter_to_true_online_NetAct
    [Arguments]    ${modified_parameter}   ${abbreviation_parameter}    ${dist_name}   ${class_name}  ${MO_name}
    ...    ${connection}=COAM
    ${modified_parameter_value}    Get NIDD parameter value
    ...    class_name=${class_name}    pattern=${abbreviation_parameter}    connection=${connection}
    Login netact
    Open Configuration
    Start CM Editor
    ${row_number}       Get Table Row online        dist_name=${dist_name}    key=${modified_parameter}
    set suite variable    ${row_number}
    COAM Update Parameter    dist_name=${mrbts_id}/${nrbts_id}    parameter=actPCMDReport     value=True
    set suite variable     ${modified_parameter_value}
    run keyword and ignore error    swing.Teardown
    selenetact.logout

Modify_PM_parameter_to_false_online_NetAct
    [Arguments]    ${modified_parameter}   ${abbreviation_parameter}    ${dist_name}   ${class_name}  ${MO_name}
    ...    ${connection}=COAM
    ${modified_parameter_value}    Get NIDD parameter value
    ...    class_name=${class_name}    pattern=${abbreviation_parameter}    connection=${connection}
    Login netact
    Open Configuration
    Start CM Editor
    ${row_number}       Get Table Row online        dist_name=${dist_name}    key=${modified_parameter}
    set suite variable    ${row_number}
    COAM Update Parameter    dist_name=${mrbts_id}/${nrbts_id}    parameter=actPCMDReport     value=True
    set suite variable     ${modified_parameter_value}
    run keyword and ignore error    swing.Teardown
    selenetact.logout

Check_PM_parameter_changed
    [Arguments]   ${abbreviation_parameter}    ${class_name}
    ...        ${connection}=COAM
    ${current_value}    Get NIDD parameter value
    ...    class_name=${class_name}    pattern=${abbreviation_parameter}   connection=${connection}
    should be equal    ${new_value}    ${current_value}

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



