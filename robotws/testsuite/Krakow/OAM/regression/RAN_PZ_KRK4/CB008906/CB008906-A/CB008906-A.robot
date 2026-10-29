*** Settings ***
Documentation
...    author: Longmei Zhao
...    contact: longmei.zhao@nokia-sbell.com
...    Feature: CB008906-A ASIR Controller RUEM Log Basic Parity

Library    ta_emss
Library    DateTime
Library    String
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin
Library    taf.sbts.oam.sc.rest.rest
Library    ../../../../../resources/NJ_Resources/Resources/python/DevNJ_analyze_ATL_log.py
Library    ../../../../../resources/NJ_Resources/Resources/python/DevNJ_sbts_keywords.py
Library    ../../../../../resources/NJ_Resources/Resources/python/DevNJ_ASIR_Selenium.py  virtual_enable=${True}
Resource   ../../../../../resources/NJ_Resources/Resources/robot/DevNJ_emssim.robot
Resource   ../../../../../resources/NJ_Resources/Resources/robot/DevNJ_sbts_setup.robot
Resource   ../../../../../resources/NJ_Resources/Resources/robot/DevNJ_wireshark_resource.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup         Suite Setup
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions
Test Teardown       CB008906 Postconditions


*** Variables ***
@{additional_allowed_alarms}  CRL Update Failure  Diagnostic Files collected
${bts_id}=    1
${asi_id}=    42
# ${tl.gnbs[0].global_bts_id}
${forbidden_alarm}=    61008
@{allowed_faults_asir}=  ${61648}
${network_interface}=    fp0
${NEIPAddress}=    192.168.255.129:3601
${ClientIPAddress}=    192.168.255.126
${mplane_ip}=    ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4.split("/")[0]}
${host_ip}=   10.84.183.152
# ${tl.test_pc.default_ssh_connection_details.addr}
${username}=    ${tl.test_pc.default_ssh_connection_details.username}
${password}=    ${tl.test_pc.default_ssh_connection_details.password}

&{expected_status_cells}=    administrativeState=Unlocked  operationalState=Enabled
&{expected_status_unlock_hubmod}=    localState=Unblocked  operationalState=Enabled
&{expected_status_block_antmod}=    localState=blocked  operationalState=disabled
&{expected_status_unblock_antmod}=    localState=unblocked  operationalState=enabled

*** Test Cases ***
[1]CB008906-SR-A_TC004_Logfile_Compliant_with_OAtS2.1_with_ASiR_WebEm_State_Operations
    Prepare ASiR EMSSim Setup  bts_id=${bts_id}  mplane_ip=${mplane_ip}  host=${host_ip}
    Sleep  10s
    Log To Console  \n ==== Start To Activate EMSsim ====
    Run EMSSIM Command  ne3s_activate 10   bts_id=${bts_id}  get_full_data=True  alias=asirAC
    Log To Console  \n ==== Start To Collect Tcpdump ====
    ${path_to_wireshark_file}=  Start Tcpdump On gNB  options=-i ${network_interface}

    #Reset Hub
    Log To Console  \n ==== Reset HUb ====
    DevNJ_ASIR_Selenium.Asir Webem Login
    DevNJ_ASIR_Selenium.Reset Hubmod  hub_mod_id=1
    Run Keyword And Ignore Error  DevNJ_ASIR_Selenium.Logout
    DevNJ_ASIR_Selenium.Clean Browser
    Sleep  2s
    Log To Console  \n ==== Check HUBMOD Status ====
#    Wait Until Keyword Succeeds  10x  30s  Check HUBMOD Status  expected_status_dict=${expected_status_unlock_hubmod}
    Wait Until Keyword Succeeds  10x  30s  verify_hubmod_status   expected_statuses=${expected_status_unlock_hubmod}
    Log To Console  \n ==== Check Sbts Cell Status ====
    Wait Until Keyword Succeeds  5x  60s  Check Sbts Cell Status  expected_status_dict=${expected_status_cells}

    #Block pRRH
    Log To Console  \n ==== Block ANTMOD ====
    DevNJ_ASIR_Selenium.Asir Webem Login
    DevNJ_ASIR_Selenium.Block ANTMOD  ant_mod_id=1
    Run Keyword And Ignore Error  DevNJ_ASIR_Selenium.Logout
    DevNJ_ASIR_Selenium.Clean Browser
    Sleep  2s
    Log To Console  \n ==== Check Antmod Status ====
#    Wait Until Keyword Succeeds  3x  10s  Check Antmod Status  ant_list=1  expected_status_dict=${expected_status_block_antmod}
    verify_antmod_status  expected_statuses=${expected_status_block_antmod}

    #Unblock pRRH
    Log To Console  \n ==== UnBlock ANTMOD ====
    DevNJ_ASIR_Selenium.Asir Webem Login
    DevNJ_ASIR_Selenium.Unblock ANTMOD  ant_mod_id=1
    Run Keyword And Ignore Error  DevNJ_ASIR_Selenium.Logout
    DevNJ_ASIR_Selenium.Clean Browser
    Sleep  2s
    Log To Console  \n ==== Check Antmod Status ====
#    Wait Until Keyword Succeeds  3x  10s  Check Antmod Status  ant_list=1  expected_status_dict=${expected_status_unblock_antmod}
    verify_antmod_status  expected_statuses=${expected_status_unblock_antmod}
    Log To Console  \n ==== Check Sbts Cell Status ====
    Wait Until Keyword Succeeds  5x  60s  Check Sbts Cell Status  expected_status_dict=${expected_status_cells}

    #Reset pRRH
    Log To Console  \n ==== Reset ANTMOD ====
    DevNJ_ASIR_Selenium.Asir Webem Login
    DevNJ_ASIR_Selenium.Reset ANTMOD  ant_mod_id=1
    Run Keyword And Ignore Error  DevNJ_ASIR_Selenium.Logout
    DevNJ_ASIR_Selenium.Clean Browser
    Sleep  2s
    Log To Console  \n ==== Check Antmod Status ====
#    Wait Until Keyword Succeeds  10x  10s  Check Antmod Status  ant_list=1  expected_status_dict=${expected_status_unblock_antmod}
    verify_antmod_status  expected_statuses=${expected_status_unblock_antmod}
    Log To Console  \n ==== Check Sbts Cell Status ====
    Wait Until Keyword Succeeds  5x  60s  Check Sbts Cell Status  expected_status_dict=${expected_status_cells}

    Run EMSSIM Command  ne3s_deactivate  alias=asirAC
    Sleep  5s
    Stop Tcpdump On gNB
    Log To Console  \n ==== wireshark log collected ====
    ${alt_log}  Pick Attachments From Pcap  pcap_path=${path_to_wireshark_file}
    ...                                     recog_xml_regexes=["ne3s_atl_logUploadNotification", "gzip", "oats"]

    #Some parameters are not given in the following dictionary because the keyword of Transfer to SCF Comparer has defined the matched rules.
    ${additionaltext_reset_antmod}  Evaluate  "^SM-1019,Unit reset request for ASI-\\d+.ASI_R-\\d.ANTMOD_R-\\d$"
    ${compare_dict_reset_antmod}  Create Dictionary  NEIPAddress=${NEIPAddress}
    ...                                       AdditionalText=${additionaltext_reset_antmod}
    ...                                       ClientIPAddress=${ClientIPAddress}
    ...                                       LogStatus=success
    ...                                       Operation=unitReset
    ${compare_dict_reset_antmod_new}  Transfer to SCF Comparer  ${compare_dict_reset_antmod}

    ${additionaltext_reset_hubmod}  Evaluate  "^SM-1019,Unit reset request for ASI-\\d+.ASI_R-\\d.HUBMOD_R-\\d$"
    ${compare_dict_reset_hubmod}  Create Dictionary  NEIPAddress=${NEIPAddress}
    ...                                       AdditionalText=${additionaltext_reset_hubmod}
    ...                                       ClientIPAddress=${ClientIPAddress}
    ...                                       LogStatus=success
    ...                                       Operation=unitReset
    ${compare_dict_reset_hubmod_new}  Transfer to SCF Comparer  ${compare_dict_reset_hubmod}

    ${additionaltext_block_antmod}  Evaluate  "^SM-1019,Unit block request for ASI-\\d+.ASI_R-\\d.ANTMOD_R-\\d$"
    ${compare_dict_block_antmod}  Create Dictionary  NEIPAddress=${NEIPAddress}
    ...                                       AdditionalText=${additionaltext_block_antmod}
    ...                                       ClientIPAddress=${ClientIPAddress}
    ...                                       LogStatus=success
    ...                                       Operation=unitBlock
    ${compare_dict_block_antmod_new}  Transfer to SCF Comparer  ${compare_dict_block_antmod}

    ${additionaltext_unblock_antmod}  Evaluate  "^SM-1019,Unit unblock request for ASI-\\d+.ASI_R-\\d.ANTMOD_R-\\d$"
    ${compare_dict_unblock_antmod}  Create Dictionary  NEIPAddress=${NEIPAddress}
    ...                                         AdditionalText=${additionaltext_unblock_antmod}
    ...                                         ClientIPAddress=${ClientIPAddress}
    ...                                         LogStatus=success
    ...                                         Operation=unitUnblock
    ${compare_dict_unblock_new_antmod}  Transfer to SCF Comparer  ${compare_dict_unblock_antmod}

    ${list_comparer}  Create List  ${compare_dict_reset_hubmod_new}  ${compare_dict_reset_antmod_new}
    ...                            ${compare_dict_block_antmod_new}  ${compare_dict_unblock_new_antmod}
    ${res}  Atl Log Compare  dict_zip_content=${alt_log}  list_comparer=${list_comparer}
    Should Be Equal As Strings  ${res}[res]  True

CB008906-SR-A_TC005_Optimized_AdditionalText_and_LogRecord_Order_Check_with_ASiR_CM_Viewing_Modifying_Operations
    Prepare ASiR EMSSim Setup  bts_id=${bts_id}  mplane_ip=${mplane_ip}  host=${host_ip}
    Sleep  10s
    Log To Console  \n ==== Start To Activate EMSsim ====
    Run EMSSIM Command  ne3s_activate 10   bts_id=${bts_id}  get_full_data=True  alias=asirAC
    Log To Console  \n ==== Start To Collect Tcpdump ====
    ${path_to_wireshark_file}=  Start Tcpdump On gNB  options=-i ${network_interface}

    DevNJ_ASIR_Selenium.Asir Webem Login
    Log To Console  \n ==== Start to Modify asiName and not trigger ASiR reset ===
    DevNJ_ASIR_Selenium.Enter Config Man
    ${asiname}  Set Variable  ASI_8906_Test_Tesla
    ${select_para_dict_asiName}  Create Dictionary  para_mo=ASI-${asi_id}  para_abbr=asiName  value=${asiname}
    ${select_para_list_to_modify}  Create List   ${select_para_dict_asiName}
    DevNJ_ASIR_Selenium.Modify Parameter  ${select_para_list_to_modify}
    Sleep  2s
    &{dict_res_prevalidate}  DevNJ_ASIR_Selenium.Prevalidate
    Sleep  2s
    Should Be Equal As Strings   first=${dict_res_prevalidate}[ret]  second=True
    Log To Console  \n ==== Prevalidate Result is &{dict_res_prevalidate}[ret] ====
    Log To Console  \n ==== Activate the plan ====
    DevNJ_ASIR_Selenium.Activate
    Run Keyword And Ignore Error  DevNJ_ASIR_Selenium.Logout
    DevNJ_ASIR_Selenium.Clean Browser

    Run EMSSIM Command  ne3s_deactivate  alias=asirAC
    Sleep  5s
    Stop Tcpdump On gNB
    Log To Console  \n ==== wireshark log collected ====

    ${alt_log}  Pick Attachments From Pcap  pcap_path=${path_to_wireshark_file}
    ...                                     recog_xml_regexes=["ne3s_atl_logUploadNotification", "gzip", "oats"]

    ${additionaltext_modify_name}  Evaluate  "^SM-1019,Reconfiguration request.*ASI-\\d+.*asiName.*ASI.8906.Test.Tesla.*$"
    ${compare_dict_midify_asiName}  Create Dictionary  NEIPAddress=${NEIPAddress}
    ...                   AdditionalText=${additionaltext_modify_name}
    ...                   ClientIPAddress=${ClientIPAddress}
    ...                   LogStatus=success
    ...                   Operation=reconfiguration
    ${compare_dict_midify_asiName_new}  Transfer to SCF Comparer  ${compare_dict_midify_asiName}

    ${list_comparer}  Create List  ${compare_dict_midify_asiName_new}
    ${res}  Atl Log Compare  dict_zip_content=${alt_log}  list_comparer=${list_comparer}
    Should Be Equal As Strings  first=${res}[res]  second=True

    #Modify ASIId
    Prepare ASiR EMSSim Setup  bts_id=${bts_id}  mplane_ip=${mplane_ip}  host=${host_ip}
    Sleep  10s
    Log To Console  \n ==== Start To Activate EMSsim ====
    Run EMSSIM Command  ne3s_activate 10   bts_id=${bts_id}  get_full_data=True  alias=asirAC
    Log To Console  \n ==== Start To Collect Tcpdump ====
    ${path_to_wireshark_file}=  Start Tcpdump On gNB  options=-i ${network_interface}

    DevNJ_ASIR_Selenium.Asir Webem Login
    Log To Console  \n ==== Start to Modify asiId and trigger ASiR reset ===
    DevNJ_ASIR_Selenium.Enter Config Man
    ${new_ASI_id}  Set Variable  123
    ${select_para_dict_asiId}  Create Dictionary  para_mo=ASI-${asi_id}  para_abbr=asiId  value=${new_ASI_id}
    ${select_para_list_to_modify}  Create List   ${select_para_dict_asiId}
    Wait Until Keyword Succeeds  2x  60s  DevNJ_ASIR_Selenium.Modify Parameter  ${select_para_list_to_modify}
    Sleep  2s
    &{dict_res_prevalidate}  DevNJ_ASIR_Selenium.Prevalidate
    Sleep  2s
    Should Be Equal As Strings   first=${dict_res_prevalidate}[ret]  second=True
    Log To Console  \n ==== Prevalidate Result is ${dict_res_prevalidate}[ret] ====
    Log To Console  \n ==== Activate the plan ====
    DevNJ_ASIR_Selenium.Activate
    Run Keyword And Ignore Error  DevNJ_ASIR_Selenium.Logout
    DevNJ_ASIR_Selenium.Clean Browser
    Log To Console  \n ==== Check Sbts Cell Status ====
    Wait Until Keyword Succeeds  15x  60s  Check Sbts Cell Status  expected_status_dict=${expected_status_cells}

    Run EMSSIM Command  ne3s_deactivate  alias=asirAC
    Sleep  5s
    Stop Tcpdump On gNB
    Log To Console  \n ==== wireshark log collected ====

    ${alt_log}  Pick Attachments From Pcap  pcap_path=${path_to_wireshark_file}
    ...                                     recog_xml_regexes=["ne3s_atl_logUploadNotification", "gzip", "oats"]

    ${additiontext_modify_asiId}  Evaluate  "^.*ASI-${new_ASI_id}.*$"
    ${compare_dict_midify_asiId}  Create Dictionary  NEIPAddress=${NEIPAddress}
    ...                   AdditionalText=${additiontext_modify_asiId}
    ...                   ClientIPAddress=${ClientIPAddress}
    ...                   LogStatus=success
    ...                   Operation=reconfiguration
    ${compare_dict_midify_asiName_new}  Transfer to SCF Comparer  ${compare_dict_midify_asiId}

    ${list_comparer}  Create List  ${compare_dict_midify_asiName_new}
    ${res}  Atl Log Compare  dict_zip_content=${alt_log}  list_comparer=${list_comparer}
    Should Be Equal As Strings  ${res}[res]  True

CB008906-SR-A_TC008_ASiR_ATLlog_Record_Delete_is_Logged
    ${start_time}  DateTime.Get Current Date  result_format=epoch  exclude_millis=True
    Prepare ASiR EMSSim Setup  bts_id=${bts_id}  mplane_ip=${mplane_ip}  host=${host_ip}
    Sleep  5s
    Log To Console  \n ==== Deactivate EMSsim ====
    Run Keyword And Ignore Error  Run EMSSIM Command  ne3s_deactivate  alias=asirAC

    DevNJ_ASIR_Selenium.Clean Browser
    #Run shell script
    Log To Console  \n ==== Start to execuate script to get alarms ====
    # TODO:  host. pass

    FOR  ${index}  IN RANGE  1  1200
        taf.sbts.oam.sc.rest.rest.connect_to
        ...  host=${NEIPAddress.split(":")[0]}  port=${NEIPAddress.split(":")[1]}  username=Nemuadmin  password=nemuuser
        taf.sbts.oam.sc.rest.rest.get_active_alarms
        taf.sbts.oam.sc.rest.rest.disconnect
    END

    Log To Console  \n ==== Execuate script to get alarms end====

    Log To Console  \n ==== Start To Collect Tcpdump ====
    ${path_to_wireshark_file}=  Start Tcpdump On gNB  options=-i ${network_interface}
    Run EMSSIM Command  ne3s_activate 10   bts_id=${bts_id}  get_full_data=True  alias=asirAC
    Sleep  2s
    Wait Until Keyword Succeeds  5x  5s  Run EMSSIM Command  ne3s_upload_atl -time 1  gnb_id=${bts_id}
    ...        get_full_data=True  alias=asirAC
    Sleep  2s
    Wait Until Keyword Succeeds  5x  5s  Run EMSSIM Command  ne3s_deactivate  alias=asirAC
    Sleep  5s
    Stop Tcpdump On gNB
    Log To Console  \n ==== wireshark log collected ====

    ${alt_log}  Pick Attachments From Pcap  pcap_path=${path_to_wireshark_file}  recog_xml_regexes=["tar", "oats"]

    ${additiontext_delete}  Evaluate  "^SM-1019,There are some ATL logs that are overwritten before uploaded.*$"
    ${compare_dict}  Create Dictionary  NEIPAddress=${NEIPAddress}
    ...                   AdditionalText=${additiontext_delete}
    ...                   ClientIPAddress=${ClientIPAddress}
    ...                   LogStatus=success
    ...                   Operation=AutonomousSecurityEvent
    ${compare_dict_new}  Transfer to SCF Comparer  ${compare_dict}

    ${list_comparer}  Create List  ${compare_dict_new}
    ${res}  Atl Log Compare  dict_zip_content=${alt_log}  list_comparer=${list_comparer}
    Should Be Equal As Strings  ${res}[res]  True

    # Check ASiR History Alarm  appeared_time_later_than=${start_time}  forbidden_fault_id_list=${forbidden_alarm}
    #Check ASiR Active Alarm  forbidden_fault_id_list=${forbidden_alarm}
    verify_only_allowed_alarms_are_active  allowed_alarms=${allowed_faults_asir}

[1]CB008906-SR-A_TC011_ASI_ATLlog_Not_Lost_during_Site_Reset_or_SW_Upgrade
    Prepare ASiR EMSSim Setup  bts_id=${bts_id}  mplane_ip=${mplane_ip}  host=${host_ip}
    Sleep  10s
    Log To Console  \n ==== Start To Activate EMSsim ====
    Run EMSSIM Command  ne3s_activate 10   bts_id=${bts_id}  get_full_data=True  alias=asirAC
    Emss Proxy Clear Events
    Emss Proxy Format Events  events_format=full  bts_id=${bts_id}

    #Modify userLabel for BTS
    DevNJ_ASIR_Selenium.Asir Webem Login
    Log To Console  \n ==== Start to modify userLabel for BTS  ===
    DevNJ_ASIR_Selenium.Enter Config Man
    ${select_para_dict_userlabel}  Create Dictionary  para_mo=ASI-${asi_id}/BTS-1  para_abbr=userLabel  value=test
    ${select_para_list_to_modify}  Create List  ${select_para_dict_userlabel}
    DevNJ_ASIR_Selenium.Modify Parameter  ${select_para_list_to_modify}
    Sleep  2s
    &{dict_res_prevalidate}  DevNJ_ASIR_Selenium.Prevalidate
    Sleep  2s
    Should Be Equal As Strings   first=${dict_res_prevalidate}[ret]  second=True
    Log To Console  \n ==== Prevalidate Result is ${dict_res_prevalidate}[ret] ====
    Log To Console  \n ==== Activate the plan ====
    DevNJ_ASIR_Selenium.Activate
    Run Keyword And Ignore Error  DevNJ_ASIR_Selenium.Logout
    DevNJ_ASIR_Selenium.Clean Browser

    Log To Console  \n ==== Reset Sbts ====
    Reset Sbts
    Log To Console  \n ==== Check Sbts Cell Status ====
    Wait Until Keyword Succeeds  15x  60s  Check Sbts Cell Status  expected_status_dict=${expected_status_cells}

    Log To Console  \n ==== Start To Collect Tcpdump ====
    ${path_to_wireshark_file}=  Start Tcpdump On gNB  options=-i ${network_interface}
    Run EMSSIM Command  ne3s_upload_atl -time 1  gnb_id=${bts_id}  get_full_data=True  alias=asirAC
    Sleep  10s
    Run EMSSIM Command  ne3s_deactivate  alias=asirAC
    Sleep  5s
    Stop Tcpdump On gNB
    Log To Console  \n ==== wireshark log collected ====

    ${alt_log}  Pick Attachments From Pcap  pcap_path=${path_to_wireshark_file}  recog_xml_regexes=["tar", "oats"]

    ${additiontext_modify_userLabel}  Evaluate  "^SM-1019,Reconfiguration request.*ASI-\\d+.BTS-1.*userLabel.*test.*$"
    ${compare_dict}  Create Dictionary  NEIPAddress=${NEIPAddress}
    ...                   AdditionalText=${additiontext_modify_userLabel}
    ...                   ClientIPAddress=${ClientIPAddress}
    ...                   LogStatus=success
    ...                   Operation=reconfiguration
    ${compare_dict_new}  Transfer to SCF Comparer  ${compare_dict}

    ${list_comparer}  Create List  ${compare_dict_new}
    ${res}  Atl Log Compare  dict_zip_content=${alt_log}  list_comparer=${list_comparer}
    Should Be Equal As Strings  ${res}[res]  True

*** Keywords ***
CB008906 Postconditions
    Run Keyword And Ignore Error  DevNJ_ASIR_Selenium.Logout  online_mode=${True}
    DevNJ_ASIR_Selenium.Clean Browser
    Perform Full Commissioning on ASIR hub
    sleep  60
    Wait for onAir on all DUs
    Common Postconditions

Suite Setup
    OperatingSystem.Run  sudo apt-get update; sudo apt-get -y install tshark
    OperatingSystem.Run  sudo iptables -I INPUT --proto tcp --match multiport --dport 80,443,8080,8443,6080 -j ACCEPT
    OperatingSystem.Run    sudo iptables -I INPUT 1 -p tcp -i eth0 -m tcp --dport 6443 -j ACCEPT
    Common Suite Setup With OnAir Test Line Preparation
    ...  swconfig_from_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
