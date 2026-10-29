*** Settings ***
Documentation
...    author: Han Ruiyu
...    contact: ruiyu.han@nokia-sbell.com
...    squad group: NSB MN 5G&SC 5G Pz Verf CN 07 SG
Library    OperatingSystem
Library   Collections
Library   String
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001681_794/resources/common.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001681_794/resources/emil/emil.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/DCAP.robot
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001681_794/libraries/dcap_server_1.py

Suite Setup    common.Common Setup
#Suite Teardown    Cplane and Uplane log Teardown

*** Variables ***
${UTF_ip}    ${dcap_ip}
${DCAP_port}   443
${UTF_username}    ${dcap_username}
${UTF_password}    ${dcap_password}

&{bts_classical}      alias=gnb_dcap    host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    username=Nemuadmin    password=nemuuser
    ...     port=443    bts_id=${tl.gnbs[0].global_bts_id}

#@{gnb_custom_profile}    L1stream    bip_interface_mirroring    L2Ps_Component    condor5gSyslog    cp_5g
@{gnb_custom_profile}    cp_5g    bip_interface_mirroring    L2Ps_Component    condor5gSyslog

#@{bts_custom_profile}    ipCapture
@{bts_custom_profile}
#
#@{l1_trace}    ID 10: Syscom: management and control plane
@{l1_trace}

#@{files_check}    IP-capture    interface-mirroring    5G_L1_component    syslog.log    5G_L2_component    control-plane
@{files_check}    interface-mirroring    syslog.log    5G_L2_component    control-plane
##manul set nrcell_internalid with format '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-295/NRCELL_R-1',
## if there is no manul set, comment the whole line
#${nrcell_internalid}   /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-295/NRCELL_R-1


*** Test Cases ***
UTF_Log_Collecting_and_Check
    log to console   \n UTF Log Collecting\n
    Create Bts On DCAP    DCAP_host=${UTF_ip}
    ...   DCAP_port=${DCAP_port}   bts_mr_id=${bts_classical['bts_id']}    
    ...   username=${UTF_username}    password=${UTF_password}    bts=${bts_classical}
    ${first_nrcell}    Get DCAP First Nrcell    bts_id=${bts_classical['bts_id']}
    ${nrcell_internalid}    Get Variable Value    ${nrcell_internalid}    ${first_nrcell}
    ${cells}    Create List    ${nrcell_internalid}
    Start DCAP log    bts=${bts_classical}
    ...               bts_custom_profile=${bts_custom_profile}
    ...               gnb_custom_profile=${gnb_custom_profile}
    ...               cells=${cells}
    ...               l1_trace=${l1_trace}
    Wait Until Keyword Succeeds    5min   30s    All Traces Should be Runnning
    All Traces Should not contain Error or Failure
    sleep   30s
    log to console   \n UTF Log Collecting Stoped!\n
    ${downloaded_emil_file_path}    Stop Dcap Basic trace
    Log To Console    \n Get the exact dcap log\n
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    RUN   unzip ${downloaded_emil_file_path} -d ${OUTPUT_DIR}/dcap_tmp_${curr_data}
    Log To Console    \n Check Log existing... \n
    Check File Existing and not Empty    files_check=${files_check}    path=${OUTPUT_DIR}/dcap_tmp_${curr_data}
    [Teardown]    Run Keyword And Ignore Error    Stop Dcap Basic trace
