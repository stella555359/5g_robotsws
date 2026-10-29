*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Library     Telnet
Library     String
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem

Library     taf.transport.ssh    WITH NAME   csn
Library     taf.analyzer.pcap   WITH NAME   wireshark
Library     ute_wtssim

# Library     ../Library/emil_messages.py
Library     ../Library/utils.py

Variables    ../../libraries/global_vars.py
# Variables    ../Library/SubscriberTrace_var.py
# Variables    ../Library/emil_vars.py
# Variables    ../Library/emil_messages.py
Variables    ../Library/variables.py

# Resource    COAM.robot
Resource    DCAP.robot
Resource    PCMD.robot
Resource    Decode.robot
Resource    L3Call.robot
Resource    Core_Sim.robot
# Resource    ../../5GC001778/Resource/emil.robot
# Resource    ../../5GC001778/Resource/collect_log.robot
Resource    ../../common/taf_coam.robot
Resource    ../../common/taf_log.robot
Resource    ../../common/qc_tag.robot
Resource    ../../common/gnb.robot
Resource    ../../common/L3_Call.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot



*** Variables ***
${testline_name}   7_5_UTE5G402T845
${BTSID}    MRBTS-${tl.gnbs[0].instance_id}
${INSID}   ${BTSID}/NRBTS-${tl.gnbs[0].global_bts_id}


*** Keyword ***
CB008411 Common Suite Setup
    Log To Console   Common Suite Setup
    robot_common_operations.Common Suite Setup

    # Connet to WTS VM
    # Kill egate and edaemon
    # Start WTS on UTE   WTS_CFG=${WTS_CFG}
    # Check NG link Up

    Wait Until Keyword Succeeds    3x   30s   COAM Login
    COAM Backup SCF
    COAM Backup Full SCF
    Get ALL Suite Variables
    Run Keyword And Ignore Error   COAM Logout


CB008411 Common Suite Teardown
    Log To Console   Common Suite Teardown
    robot_common_operations.Common Suite Teardown

    Wait Until Keyword Succeeds    3x   15s   COAM Login
    Run Keyword And Ignore Error   COAM SCF Commission
    ...   filepath=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00.xml
    Run Keyword And Ignore Error   COAM Logout
    # Run Keyword And Ignore Error   Disconnect to WTS VM



Get ALL Suite Variables
    Set Suite Variable   ${MRBTS_ID}   ${tl.gnbs[0].instance_id}
    Set Suite Variable   ${NRBTS_ID}   ${tl.gnbs[0].global_bts_id}
    Set Suite Variable   ${MRBTS}   MRBTS-${MRBTS_ID}
    Set Suite Variable   ${NRBTS}   NRBTS-${NRBTS_ID}
    Set Suite Variable   ${INSID}   ${MRBTS}/${NRBTS}
    Set Suite Variable   ${LOCAL_SSH_ADDR}   ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Set Suite Variable   ${LOCAL_SSH_USER}   ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    Set Suite Variable   ${LOCAL_SSH_PWD}   ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

    ${SW_Release}   COAM Get SW Release
    Set Suite Variable   ${SW_Release}

    ${LOCAL_SMOD_NAME}   Get SMOD Product Name
    # Set Suite Variable   ${LOCAL_SMOD_NAME}   ASIM

    ${local_xml}   XML.Parse XML   ${OUTPUT_DIR}/full_commission.xml
    ${gNbIdLength}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="gNbIdLength"]
    Set Suite Variable   ${gNbIdLength}

    ${mcc}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="mcc"]
    ${mnc}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="mnc"]
    ${mnclength}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="mncLength"]

    ${local_tmp}   Set Variable If
    ...   '${mnclength}'=='2'   ${mcc.zfill(3)}f${mnc.zfill(int(${mnclength}))}
    ...   '${mnclength}'=='3'   ${mcc.zfill(3)}${mnc.zfill(int(${mnclength}))}
    Set Suite Variable   ${PLMN_IDENTITY}   ${local_tmp[1]}${local_tmp[0]}${local_tmp[3]}${local_tmp[2]}${local_tmp[5]}${local_tmp[4]}

    ${ssbScs}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${INSID}/NRCELL-1"]/p[@name="ssbScs"]
    Set Suite Variable   ${ssbScs}

    ${cellTechnology}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${INSID}/NRCELL-1"]/p[@name="cellTechnology"]
    Set Suite Variable   ${cellTechnology}

    ${chBw}   Run Keyword If   '${cellTechnology}'=='TDD'
    ...   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${INSID}/NRCELL-1"]/p[@name="chBw"]
    ...   ELSE IF   '${cellTechnology}'=='FDD'
    ...   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${INSID}/NRCELL-1/NRCELL_FDD-1"]/p[@name="chBwDl"]
    Set Suite Variable    ${chBw}

    ${arfcnSsbPbch}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${INSID}/NRCELL-1"]/p[@name="arfcnSsbPbch"]
    Set Suite Variable   ${arfcnSsbPbch}

    ${AMF_IP}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${INSID}/SERVEDAMF-1"]/p[@name="amfIPAddress"]
    Set Suite Variable   ${AMF_IP}


