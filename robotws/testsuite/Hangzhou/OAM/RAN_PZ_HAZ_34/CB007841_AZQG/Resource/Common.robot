*** Settings ***
Documentation
...  author: Chen Liang
...  contact: liang.6.chen@nokia-sbell.com
Library     String
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME   csn
Resource    ../../common/taf_coam.robot
Resource    ../../common/taf_log.robot
Resource    ../../common/qc_tag.robot
Resource    ../../common/gnb.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Variables   ../../libraries/global_vars.py

*** Variables ***

*** Keyword ***
Common Suite Setup 7841
    Log To Console   ${EMPTY}
    ${TEST_NAME}   Set Variable   Suite_Setup
    Set Suite Variable   ${MRBTS_ID}   ${tl.gnbs[0].instance_id}
    Set Suite Variable   ${NRBTS_ID}   ${tl.gnbs[0].global_bts_id}
    Set Suite Variable   ${MRBTS}   MRBTS-${MRBTS_ID}
    Set Suite Variable   ${NRBTS}   NRBTS-${NRBTS_ID}
    Set Suite Variable   ${INSID}   ${MRBTS}/${NRBTS}
    Set Suite Variable   ${gnb_addr}   ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Set Suite Variable   ${lmp_addr}   ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Set Suite Variable   ${test_pc_host}    10.57.167.32
    Set Suite Variable   ${test_pc_password}    iW_K#8.ute%A10h0m0ra    
    COAM Try Connect gNB   ${gnb_addr}
    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
    Wait Until Keyword Succeeds   5m   1m   COAM Login
    Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir
    COAM Backup SCF
    COAM Backup Full SCF
    Get ALL Suite Variables
    Run Keyword And Ignore Error   Start Syslog Collection

Common Suite Teardown
    Run Keyword And Ignore Error   COAM WEBUI Logout
    Run Keyword And Ignore Error   Run Keyword If Any Tests Failed   Catch Snapshot COAM
    Run Keyword And Ignore Error   Stop and Save Syslog Collection
    Run Keyword And Ignore Error   Check Error Log From Syslog
    Run Keyword And Ignore Error   COAM Logout

Get ALL Suite Variables
    Set Suite Variable   ${LOCAL_SSH_ADDR}   ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Set Suite Variable   ${LOCAL_SSH_USER}   ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    Set Suite Variable   ${LOCAL_SSH_PWD}   ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

    ${SMOD_NAME}   Get SMOD Product Name
    Set Suite Variable   ${SMOD_NAME}

    ${local_xml}   XML.Parse XML   ${OUTPUT_DIR}/full_commission.xml
    ${gNbIdLength}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="gNbIdLength"]
    Set Suite Variable   ${gNbIdLength}

    ${mcc}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="mcc"]
    ${mnc}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="mnc"]
    ${mnclength}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="mncLength"]

    ${local_tmp}   Set Variable If
    ...   '${mnclength}'=='2'   ${mcc}f${mnc.zfill(int(${mnclength}))}
    ...   '${mnclength}'=='3'   ${mcc}${mnc.zfill(int(${mnclength}))}
    Set Suite Variable   ${PLMN_IDENTITY}   ${local_tmp[1]}${local_tmp[0]}${local_tmp[3]}${local_tmp[2]}${local_tmp[5]}${local_tmp[4]}

    ${ssbScs}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${INSID}/NRCELL-1"]/p[@name="ssbScs"]
    Set Suite Variable   ${ssbScs}

    ${chBw}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${INSID}/NRCELL-1"]/p[@name="chBw"]
    Set Suite Variable   ${chBw}

    ${arfcnSsbPbch}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${INSID}/NRCELL-1"]/p[@name="arfcnSsbPbch"]
    Set Suite Variable   ${arfcnSsbPbch}
    ${AMF_IP}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${INSID}/SERVEDAMF-1"]/p[@name="amfIPAddress"]
    Set Suite Variable   ${AMF_IP}
