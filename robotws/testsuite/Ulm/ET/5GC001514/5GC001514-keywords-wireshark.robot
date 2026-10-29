*** Settings ***
Documentation    This is a Robot keyword File, for 5GC001514 wireshark verification
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
*** Variables***

${filter_X2SetupResp}                (x2ap.procedureCode==36)&&(ip.src==10.0.1.2)
${filter_ConfigurationUpdate}        (x2ap.procedureCode==37)&&(x2ap.id==245)
${filter_NGSetupRequest}             (ngap.procedureCode==21)&&(ip.src==10.0.1.2)


*** Keywords ***

verify wireshark cell not available
    [Documentation]    [PRIVATE]    verify wireshark contains ENDC PartialResetRequired message with cause cell not available
    ...       :Autor: Sylvia Schneider
    Log To Console    verify wireshark contains ENDCPartialResetRequired message with cause cell not available
    ${msg}     Run     tshark -r ${resultDir}/wireshark.pcap -Y "(x2ap.procedureCode==40)&&(x2ap.radioNetwork==11)" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg} > 0
    ...     wrong number of ENDCPartialResetRequired message with cause cell not available


verify wireshark X2AP NGAP reset
    [Documentation]    [PRIVATE]    verify wireshark X2AP NGAP reset
    ...       :Autor: Sylvia Schneider
    verify wireshark X2AP reset
    verify wireshark NGAP reset


verify wireshark X2AP reset
    [Documentation]    [PRIVATE]    verify wireshark X2AP reset
    ...       :Autor: Sylvia Schneider
    Log To Console    verify wireshark contains 1 ResetRequest message
    ${msg}     Run     tshark -r ${resultDir}/wireshark.pcap -Y "(x2ap.procedureCode == 7)&&(ip.src==10.0.1.2)" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==${1}
    ...     wrong number of ResetRequest messages


verify wireshark NGAP reset
    [Documentation]    [PRIVATE]    verify wireshark NGAP reset
    ...       :Autor: Sylvia Schneider
    Log To Console    verify wireshark contains 1 NGRequest message with cause release-due-to-ngran-generated-reason
    ${msg}     Run     tshark -r ${resultDir}/wireshark.pcap -Y "(ngap.procedureCode == 20)&&(ngap.radioNetwork == 3)" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==${1}
    ...     wrong number of NGRequest messages


verify wireshark 2 ConfigurationUpdate messages
    [Documentation]    [PRIVATE]    verify wireshark 2 ConfigurationUpdate present
    ...       :Autor: Sylvia Schneider
    Log To Console    verify wireshark contains ENDC  2 ConfigurationUpdate messages
    ${msg}     Run     tshark -r ${resultDir}/wireshark.pcap -Y "(x2ap.procedureCode==37)&&(ip.src==10.0.1.2)" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==${2}
    ...     wrong number of ConfigurationUpdate messages


verify wireshark ServedNRcellsToDeleteListENDCConfUpd
    [Documentation]    [PRIVATE]    verify wireshark ENDC ConfigurationUpdate contains ServedNRcellsToDeleteListENDCConfUpd
    ...       :Autor: Sylvia Schneider
    Log To Console    verify wireshark contains ENDC ConfigurationUpdate message with list
    Log To Console    --ServedNRcellsToDeleteListENDCConfUpd with nRcellIdentifier "decimal value 16385"
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/conf_update_del.xml
    ...   packet_filter=(x2ap.procedureCode==37)&&(x2ap.id==262)
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/wireshark.pcap
    teardown tshark
    ${pdml_xml}    parse xml    ${resultDir}/conf_update_del.xml
    Run Keyword And Continue On Failure   Element Attribute should match    ${pdml_xml}
    ...    showname
    ...    *decimal value 16385*
    ...    xpath=.//field[@name="x2ap.nRcellIdentifier"]


verify wireshark ServedNRcellsENDCX2ManagementList
    [Documentation]    [PRIVATE]    verify wireshark ENDC ConfigurationUpdate contains ServedNRcellsENDCX2ManagementList
    ...       :Autor: Sylvia Schneider
    Log To Console    --ServedNRcellsENDCX2ManagementList with nRcellIdentifier "decimal value 16385" and "nrpCI=50"
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/conf_update_mgmtList.xml
    ...   packet_filter=(x2ap.procedureCode==37)&&(x2ap.id==253)
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/wireshark.pcap
    teardown tshark
    ${pdml_xml}    parse xml    ${resultDir}/conf_update_mgmtList.xml
    Run Keyword And Continue On Failure   Element Attribute should match    ${pdml_xml}
    ...    showname
    ...    *decimal value 16385*
    ...    xpath=.//field[@name="x2ap.nRcellIdentifier"]
    Run Keyword And Continue On Failure   Element Attribute should match    ${pdml_xml}
    ...    show
    ...    50
    ...    xpath=.//field[@name="x2ap.nrpCI"]


verify wireshark ENDCX2SetupResponse CPCL
    [Documentation]    [PRIVATE]    verify wireshark ENDCX2SetupResponse present
    ...       :Autor: Sylvia Schneider
    Log To Console    verify wireshark ENDCX2SetupResponse present
    ${msg}     Run     tshark -r ${resultDir}/wireshark.pcap -Y "${filter_X2SetupResp}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}>=${1}
    ...     wrong number of ENDCX2SetupResponse messages


verify wireshark ENDCConfigurationUpdate CPCL
    [Documentation]    [PRIVATE]    verify wireshark initiating message, ENDC ConfigurationUpdate present
    ...       :Autor: Sylvia Schneider
    Log To Console    verify wireshark initiating message, ENDC ConfigurationUpdate present
    ${msg}     Run     tshark -r ${resultDir}/wireshark.pcap -Y "${filter_ConfigurationUpdate}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}>=${1}
    ...     wrong number of ENDCConfigurationUpdate messages


verify wireshark NGSetupRequest CPCL
    [Documentation]    [PRIVATE]    verify wireshark NGSetupRequest
    ...       :Autor: Sylvia Schneider
    Log To Console    verify wireshark NGSetupRequest present
    ${msg}     Run     tshark -r ${resultDir}/wireshark.pcap -Y "${filter_NGSetupRequest}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==${1}
    ...     wrong number of NGSetupRequest messages
