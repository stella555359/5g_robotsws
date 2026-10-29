# # ﻿*** Settings ***
# # Suite Setup        
# # Suite Teardown      
# # Test Setup
# # Test Teardown
# # Test Timeout       10 min
# # 
# # Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
# # Resource   Resource/5GC001576_AA_Common_KW.robot
# # Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# # 
# # Documentation
# # ...    author: yingying.li@nokia-sbell.com
# # ...    contact: xia.wu@nokia-sbell.com
# # ...    squad group: 5G_PZ_MMW_HZ_3_SG
# # ...    Feature 5GC001250_AA in 5G20A program
# # 
# # Force Tags    CIT_TRUNK    CIT_20B        
# # ...    PY36
# # 
# # *** Variables ***
# # ${Max_loop_number}    3
# # ${ADMIN_IP_Address}     ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# # ${ROOT_USERNAME}       toor4nsn
# # ${ROOT_PASSWORD}        oZPS0POrRieRtu
# # ${WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
# # ${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
# # ${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
# # 
# # 
# # *** Test Cases ***
# # [1]5GC001250-AA_5GC000158_002_secondEndpointLabel_in_BACKPLANE_Detection_And_Add_RMOD
# #     [Documentation]    *****************
# #     ...    this case is to verify CABLINKs rate pdl check result and keep site not reset
# #     ...    ******************
# #     ...    *******************
# #     [Tags]     5GC001250-AA   CRT
# #     [Setup]      COAM Check cell on air
# #     [Teardown]    Case_teardown_ASOD
# #     Step 1: Check MO CABLINK_R for BBMOD
# #     Step 2: Add MO RMOD
# #     Step 3: Add MO CABLINK
# #     Step 4: Check RMOD status and ASOD not reset
# # 
# # 
# # *** Keywords ***
# # Step 1: Check MO CABLINK_R for BBMOD
# #     log to console     Step 1: Check MO CABLINK_R for BBMOD
# #      Get CABLINK Detection Results
# #      Get Cablink distname of RF    status=operationalState    CABLINK_STATUSES=${CABLINK_STATUSES}
# #      ...    CABLINK_STATUSES_A=${CABLINK_STATUSES_A}
# #      ${distname_RF}    Get RMOD Detection Results
# #      ${uptime1}      Get uptime from ASOD
# #      set suite variable     ${uptime1}
# # 
# # Step 2: Add MO RMOD
# #     log to console     Step 2: Add MO RMOD
# #     Admin Get MrbtsId And NrbtsId
# #     Run Keyword And Continue On Failure   Create RMOD_ASOD Object    Max_loop_number=${Max_loop_number}    distname_RF=${distname_RF}
# # 
# # Step 3: Add MO CABLINK
# #     log to console     Step 3: Add MO CABLINK
# #     Run Keyword And Continue On Failure    ADD CABLINK_ASOD object    Rmod_ID=${Rmod_ID}    distname_L=${distname_L}
# # 
# # Step 4: Check RMOD status and ASOD not reset
# #     log to console     Step 4: Check RMOD status and ASOD not reset
# #     run keyword and ignore error    selenium_coam.enable_virtual_display
# #     run keyword and ignore error    selenium_coam.logout
# #     selenium_coam.login    url=${WEBUI_URL}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
# #     run keyword and ignore error      selenium_coam.disable_message_box
# #     BuiltIn.Sleep   60
# #     ${uptime2}       Get uptime from ASOD
# #     Run Keyword And Continue On Failure     should be true    int(${uptime2})>int(${uptime1})
# # 
# # COAM Check cell on air
# #     [Arguments]    ${connection}=COAM
# #     wait until keyword succeeds     2s    1s
# #     ...      admin_cli.connect to   bts_host=${ADMIN_IP_Address}
# #     ...      username=Nemuadmin
# #     ...      password=nemuuser
# #     ...      name=${connection}
# #     COAM Check All Cells Onair
# # 
# # 
# # Get uptime from ASOD
# #    Connect to cOAM as toor4nsn
# #    csn.send command    command=cat /proc/uptime |awk '{print $1}'    connection=cOAM_toor4nsn
# #    ${uptime}    csn.Read Output    connection=cOAM_toor4nsn
# # #   ${uptime}    Convert To Integer     ${uptime}
# #    [Return]    ${uptime}
# # 
# # 
# # Connect to cOAM as toor4nsn
# #     [Arguments]  ${ip_address}=${ADMIN_IP_Address}  ${alias}=cOAM_toor4nsn  ${password}=${ROOT_PASSWORD}
# #     ${connection}=  ssh.Connect to  hostname=${ip_address}
# #     ...                             username=${ROOT_USERNAME}
# #     ...                             password=${password}
# #     ...                             alias=${alias}
# #     [Return]  ${connection}
# # 
# # Admin Get MrbtsId And NrbtsId
# #     admin_cli.collect scf   target_file_name=/home/ute/scf.xml    connection=COAM
# #     ${XML}=   Parse XML   /home/ute/scf.xml
# #     ${mrbtsId_element}=   Get Element   ${XML}   .//managedObject[@class="com.nokia.du.5g:MRBTS"]
# #     ${nrbtsId_element}=   Get Element   ${XML}   .//managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]
# #     set suite variable   ${mrbtsId}   ${mrbtsId_element.attrib['distName']}
# #     set suite variable   ${nrbtsId}   ${nrbtsId_element.attrib['distName']}
# # 
# # 
# # 
# # Case_teardown_ASOD
# #     Run Keyword And Ignore Error    coam_resource.WEBUI Logout
# #     Run Keyword And Continue On Failure      wait until keyword succeeds    10 min    0s    Delete RMOD object
# #     ...    Rmod_ID=${Rmod_ID}
# #     Run Keyword And Continue On Failure      wait until keyword succeeds    10 min    0s    Delete CABLINK object
# #     ...    CABLINK_ID=${CABLINK_ID}
# #     ${reset_site}    admin_cli.reset_site    connection=COAM
# #     Wait until keyword succeeds    30 min     20 s    COAM Check cell on air
# #     run keyword and ignore error    AdminCli disconnection and Test teardown
# # 	CI_interface.Common Case Teardown