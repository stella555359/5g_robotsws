*** Settings ***
Documentation
...  author: Jiang Johnny
...  contact: johnny.1.jiang@nokia-sbell.com  jingmin.he@nokia-sbell.com
Resource   ../../common/NetAct_selenium.robot
Resource   ../../common/NetAct_swing.robot
Resource   ../../common/NetAct_ssh.robot
Resource   ../../common/gnb.robot
Resource   ../../common/taf_env.robot
Library   decode_csv.py
Library   Collections

*** Variables ***
#${NetAct_page}   https://kungfulbwas.kungfu.srnhz.nsn-rdnet.net/
#${NetAct_user}   omc
#${NetAct_password}  Nokia126_
${module_table_id}    modules:modulesForm:moduleResultTable
${report_table_id}    report:reportsForm:reportResultTable
${license_table_id}    reportForm:reportTable
${license_page_button}   reportForm:reportTable:itemsPerPagecomboboxButton
&{License_level}   5G000004.TTL=gold   5G000003.TTL=silver   5G000002.TTL=bronze   5G000001.TTL=base
...   5G000005.T=bandwidth   5G000006.T=beam   5G000007.T=power
${Adminstration_folder}   //*[@id="calypso-container"]/div[2]/div/a[1]/img
#${NEIW_position}   //*[@id="calypso-container"]/div[2]/div/a[24]/img
${result_xpath}   //*[@id="mainForm:main_table:result"]
${total_xpath}   //*[@id="mainForm:main_table:total_number_ne"]
${main_table_xpath}   //*[@id="mainForm:main_table"]
${IP}   ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${NEIW_NE_Type}   MRBTS
${NEIW_position}   //span[text()='NE Integration Wizard']
${file_name}   old_commission.xml

*** Keywords ***
Module Create Generate Report
    [Arguments]   ${row}
    selenium_netact.wait_for_enable   //td[@id='${module_table_id}:${row}:${row}:actionColumn']//img[@alt='Generate report']
    selenium_netact.click_button   //td[@id='${module_table_id}:${row}:${row}:actionColumn']//img[@alt='Generate report']
    selenium_netact.wait_for_enable   //td[@id='${module_table_id}:${row}:${row}:actionColumn']//img[@alt='Generate report']

Download SWEM Report as CSV
    [Arguments]    ${report_type}=aggregated    ${report_title}=SWEM for 5G RAN CM
    Close All Java Application Forced
    ${netact_info}   Set Variable   ${NetAct_mapping['${NETACT_NAME}']}
    ${NetAct_page}   ${NetAct_user}   ${NetAct_password}   ${MODULE_ROOT}    ${MODULE_NAME}    Set Variable   ${netact_info["url"]}
    ...   ${netact_info["username"]}   ${netact_info["password"]}    Reporting    Software Asset Monitoring
    Open Netact Start Page   url=${NetAct_page}   username=${NetAct_user}   password=${NetAct_password}   showall=${false}
    Open Sub page in home page   root_path=//span[text()='${MODULE_ROOT}']   page_path=//span[text()='${MODULE_NAME}']    page_name=${MODULE_NAME}
    Create SWEM report    report_title=${report_title}
    log to console     \n********create report finished!******\n
    sleep   3min
#    selenium_netact.switch_to_page    Software Asset Monitoring
    run     cd ${WEB_DOWNLOAD_DIR};rm -rf 5G+RAN_CM_SWEM+for+5G* SRAN_CM_SWEM+for+SRAN*
    FOR   ${refresh_times}    IN RANGE    3
      run keyword and ignore error    selenium_netact.click_button    //*[@id="report:reportsForm:refreshButton"]/span
      sleep   15s
    END
    run keyword if   '${report_type.lower()}'=='aggregated'
    ...    wait until keyword succeeds     3x    10s
    ...   selenium_netact.click_button    //*[@id="report:reportsForm:reportResultTable:1:1:downloadButton"]/img
    ...   ELSE    wait until keyword succeeds     3x   10s
    ...   selenium_netact.click_button    //*[@id="report:reportsForm:reportResultTable:2:2:downloadButton"]/img
    run keyword if  '${report_title}'=='SWEM for 5G RAN CM'
    ...   wait until keyword succeeds    5x    30s    Check CM Report Exist    csv_type=5G+RAN_CM_SWEM+for+5G
    ...   report_type=${report_type}
    ...   ELSE IF   '${report_title}'=='SWEM for SRAN CM'
    ...   wait until keyword succeeds    5x    30s    Check CM Report Exist    csv_type=SRAN_CM_SWEM+for+SRAN
    ...   report_type=${report_type}
    [Teardown]   Run Keyword and Ignore Error   selenium_netact.logout

Check CM Report Exist
    [Arguments]   ${csv_type}=5G+RAN_CM_SWEM+for+5G    ${report_type}=aggregated
    ${res}    run    ls ${WEB_DOWNLOAD_DIR}| grep ${csv_type}*
    should contain   ${res}    ${csv_type}
    Should Contain   ${res}    ${report_type}
    Should End With  ${res}    .zip

Get Licensed Capacity Via CSV
    [Arguments]     ${sales_item}=5G000003    ${report_type}=aggregated
    ${csv_type}    run keyword if   ${sales_item.count('5G00000')} > 0  set variable   5G+RAN_CM_SWEM+for+5G
    ...   ELSE    set variable     SRAN_CM_SWEM+for+SRAN
    ${res}    run    cd ${WEB_DOWNLOAD_DIR};ls | grep ${csv_type}+*.zip
    ${res_zip}    strip string    ${res}
    ${csv_name}    wait until keyword succeeds    3x    10s    _Check Csv Existing    res_zip=${res_zip}
    ${row}    get_row_as_defined_str    csv_filename=${WEB_DOWNLOAD_DIR}/${csv_name}    str1=${sales_item}   str2=MRBTS-${BTS_ID}
    ${license}    fetch from right    ${row}    ;
    ${location_level}   Run Keyword and Return Status   Log   ${TEST_NAME}
    run keyword if    ${location_level}    run keyword and ignore error    _move_report_to_casefolder   csv=${csv_name}
    [Return]     ${license}

_move_report_to_casefolder
    [Arguments]    ${csv}
    ${case_folder}      Remove string   ${TEST_NAME}    ${SPACE}
     Create Directory    ${WEB_DOWNLOAD_DIR}/${case_folder}
     run     mv ${WEB_DOWNLOAD_DIR}/${csv} ${WEB_DOWNLOAD_DIR}/${case_folder}/${csv}


_Check Csv Existing
    [Arguments]    ${res_zip}
    run    unzip ${WEB_DOWNLOAD_DIR}/${res_zip} -d ${WEB_DOWNLOAD_DIR}
    sleep   3s
    ${res_csv}    run    ls ${WEB_DOWNLOAD_DIR}| grep .csv
    ${res_csv}    strip string    ${res_csv}
    should contain   ${res_csv}    .csv
    [Return]    ${res_csv}

Integrating NE to NetAct
    run keyword and ignore error  Renew Registrations on NE3SWS Network Element
    Open Netact Start Page   url=${START_PAGE}    username=${START_PAGE_USER}    password=${START_PAGE_PASSWORD}    showall=${false}
    Integrate NE via NEIW   DN=${DN}   Adminstration_folder=${Adminstration_folder}   NEIW_position=${NEIW_position}
    ...   NE_Type=MRBTS   release=${release}   MR=${MR_NEIW}   IP=${IP}
    ...   NE3SWS_IPversion=${NE3SWS_IPversion}   NE3SWS_mode=${NE3SWS_mode}
    sleep   10s
    Run Keyword And Ignore Error    selenium_netact.Logout
    CM Upload in Backend ENV

Renew Registrations on NE3SWS Network Element
    ${renew_Registration_command}=   set variable  racclimx.sh -op NE3S_RenewRegistration -DN ${DN} -v
    Connect to NetAct WasNode and execute command
    ...   wasNode_IP=${LAB_INFO['GANSU']['VM_IP']}
    ...   omc_uername=${LAB_INFO['GANSU']['SERVICE_USER']}
    ...   omc_passowrd=${LAB_INFO['GANSU']['SERVICE_PASSWORD']}
    ...   command=${renew_Registration_command}

COAM Get Info of WebUI for Integration
    [Arguments]   ${file_name}=old_commission.xml
    ${connection}   wait until keyword succeeds  5min   1min   coam.connect_to   bts_host=${WEBUI_ADDR}   name=COAM
    COAM Backup SCF   local_dir=${OUTPUT_DIR}   file_name=${file_name}   connection=COAM
    ${XML}   xml.parse xml   ${OUTPUT_DIR}/${file_name}
    ${distname}   xml.get element attribute   ${XML}   distName    xpath=cmData/managedObject[@class="com.nokia.srbts:MRBTS"]
    ${btsid}   should match regexp   ${distname}   \\d+
    set suite variable  ${MO_NAME}   MRBTS-${bts_id}
    ${oam_tls_status}   xml.get element text   ${XML}   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:MPLANENW"]/p[@name="oamTls"]
    run keyword if    '${oam_tls_status}'=='off'    Set Suite Variable    ${NE3SWS_mode}    no TLS
    ...    ELSE    Set Suite Variable    ${NE3SWS_mode}    TLS
    ${status_ip}=    run keyword and return status    should contain    ${oam_addr}    :
    run keyword if    ${status_ip}    Set Suite Variable    ${NE3SWS_IPversion}    IPv6
    ...    ELSE    Set Suite Variable    ${NE3SWS_IPversion}    IPv4
    Set Suite Variable    ${DN}    PLMN-PLMN/${MO_NAME}
    [Teardown]   run keyword and ignore error  coam.teardown   connection=${connection}

Set Global Lab Information
    [Arguments]  ${lab_name}=QIN
    Set Suite Variable    ${LAB_INFO}    ${LAB_INFO['${lab_name}']}
    ${lab_info_keys} =    Get Dictionary Keys    ${LAB_INFO}
    FOR    ${key_name}   IN    @{lab_info_keys}
       Set Suite Variable   ${${key_name}}   ${LAB_INFO['${key_name}']}
    END
    LogIn NetAct VM And Get Config File FP
    ${Cluster_XML} =   Parse XML    ${OUTPUT_DIR}/ClusterConfig.xml
    ${START_PAGE}   ${HOST_IP}   Get Start Page And HOST From ClusterConfig FP   ${Cluster_XML}
    Set Suite Variable    ${HOST_IP}
    Set Suite Variable    ${START_PAGE}
    ${smanager_XML} =   Parse XML    ${OUTPUT_DIR}/smanagerConf.xml
    Get Node Service From smanagerConf And Set As Global Vars    XML=${smanager_XML}

Integrating NE to NetAct Case Setup
    ${release}   Get gnb release
    ${release}   run keyword if   '${release}'=='TRUNK'   set variable   SBTS22R4
    Set Suite Variable   ${lab_name}   HAN
    Set Suite Variable   ${release}   ${release}
    Set Suite Variable   ${MRC_name}   ${LAB_INFO['${lab_name}']['MRC']}
    Set Suite Variable   ${MR_name}   ${LAB_INFO['${lab_name}']['MR']}
    Set Suite Variable   ${MR_NEIW}   MRC-${MRC_name}/MR-${MR_name}
    run keyword and ignore error  selenium_coam.enable_virtual_display
    IPV6 no proxy setting   ip_addr=${IP}
    NetAct.Set Global Lab Information    lab_name=${lab_name}
    NetAct.COAM Get Info of WebUI for Integration   file_name=${file_name}

Integrating NE to NetAct Case Teardown
    run keyword and ignore error  selenium_coam.disable_virtual_display

CM Upload on NetAct Background
    log to console  CM Upload on NetAct Background
    ${upload_command}   set variable  racclimx.sh -v -op Upload -DN PLMN-PLMN/MRBTS-${GLOBAL_BTS_ID}
    ${expect_output}   set variable   The operation was successfully completed.:Upload is Successful
    ${netact_info}   Set Variable   ${NetAct_mapping['${NETACT_NAME}']}
    ${netact_nodeip}   ${NetAct_user}   ${NetAct_password}     Set Variable   ${netact_info["netact_nodeip"]}
    ...   ${netact_info["username"]}   ${netact_info["password"]}
    wait until keyword succeeds  2 times   10s   Connect to NetAct WasNode and execute command   wasNode_IP=${netact_nodeip}
    ...   omc_uername=${NetAct_user}   omc_passowrd=${NetAct_password}  command=${upload_command}   expect_output=${expect_output}

Get Original Capacity
    Download SWEM Report as CSV    report_type=aggregated    report_title=SWEM for SRAN CM
    ${bandwidth_ori}    Get Licensed Capacity Via CSV    sales_item=SR000024    report_type=aggregated
    ${beam_ori}    Get Licensed Capacity Via CSV    sales_item=SR000025    report_type=aggregated
    ${TRP_ori}    Get Licensed Capacity Via CSV    sales_item=SR000026    report_type=aggregated
    ${bandwidth_ori}    Convert To Number    ${bandwidth_ori}
     ${beam_ori}    Convert To Number   ${beam_ori}
     ${TRP_ori}     Convert To Number    ${TRP_ori}
     ${bandwidth_ori}    convert to integer    ${bandwidth_ori}
     ${beam_ori}    convert to integer   ${beam_ori}
     ${TRP_ori}     convert to integer    ${TRP_ori}
     set suite variable   ${bandwidth_ori}
     set suite variable    ${beam_ori}
     set suite variable   ${TRP_ori}
