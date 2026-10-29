*** Settings ***
Documentation    Common variables for 2376-IA feature

*** Variables ***
${LUA_SCRIPT_PATH}               /opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
${X2AP_COMMAND}       {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml
${E1AP_COMMAND}       {tshark_path} -r {pcap_file} -Y  \"\"  -T pdml
${S1AP_COMMAND}       {tshark_path} -r {pcap_file} -Y  \"s1ap\"  -T pdml

${PATH_S1_COMPLETE1}    s1ap.UEContextReleaseComplete_element
${PATH_S1_COMPLETE2}    s1ap.protocolIEs/*[Item 2]
${PATH_S1_SCONDARYRAT_INUECONTEXTRELEASECOMPLETE}   ${PATH_S1_COMPLETE1}/${PATH_S1_COMPLETE2}

${PATH_S1AP.SECONDARYRATDATAUSAGEREPORT_ELEMENT}    s1ap.s1ap.SecondaryRATDataUsageReport_element


${X2_LIST}    x2ap.SecondaryRATUsageReportList//x2ap.ProtocolIE_Single_Container_element/x2ap.value_element
${X2_ELEMENT}    x2ap.SecondaryRATUsageReport_Item_element
${X2_COMMANPATH}    ${X2_LIST}/${X2_ELEMENT}
${X2_RAB_ID}    x2ap.e_RAB_ID
${X2_SECONDARYRATTYPE}    x2ap.secondaryRATType

${X2_ERAB_COMM}    x2ap.e_RABUsageReportList//x2ap.ProtocolIE_Single_Container_element/x2ap.value_element
${X2AP_STARTTIMESTAMP}    ${X2_ERAB_COMM}/x2ap.E_RABUsageReport_Item_element/x2ap.startTimeStamp

${X2AP_ENDTIMESTAMP}    ${X2_ERAB_COMM}/x2ap.E_RABUsageReport_Item_element/x2ap.endTimeStamp

${X2AP_USAGECOUNTUL}    ${X2_ERAB_COMM}/x2ap.E_RABUsageReport_Item_element/x2ap.usageCountUL

${X2AP_USAGECOUNTDL}    ${X2_ERAB_COMM}/x2ap.E_RABUsageReport_Item_element/x2ap.usageCountDL


${E1_LIST}    e1ap.ProtocolIE_Field_element/e1ap.value_element/e1ap.Data_Usage_Report_List/
${E1_ELEMENT}    e1ap.Data_Usage_Report_Item_element/e1ap.dRB_Usage_Report_List/
${E1_COMMANPATH}    ${E1_LIST}/${E1_ELEMENT}

${E1_SECONDARYRATTYPE}    e1ap.secondaryRATType

${E1_ERAB_COMM}    e1ap.DRB_Usage_Report_Item_element
${E1AP_STARTTIMESTAMP}    e1ap.startTimeStamp

${E1AP_ENDTIMESTAMP}    e1ap.endTimeStamp

${E1AP_USAGECOUNTUL}    e1ap.usageCountUL

${E1AP_USAGECOUNTDL}    e1ap.usageCountDL


${S1_LIST}    s1ap.ProtocolIE_Field_element/s1ap.value_element
${S1_ELEMENT}    s1ap.SecondaryRATDataUsageReportList//s1ap.ProtocolIE_SingleContainer_element
${S1_ELEMENT_LIST}    s1ap.value_element/s1ap.SecondaryRATDataUsageReportItem_element
${S1_COMMANPATH}    ${S1_LIST}/${S1_ELEMENT}/${S1_ELEMENT_LIST}

${S1_SECONDARYRATTYPE}    ${S1_COMMANPATH}/s1ap.secondaryRATType
${S1_LIST_COMM}    s1ap.e_RABUsageReportList//s1ap.ProtocolIE_SingleContainer_element/s1ap.value_element
${D}    s1ap.E_RABUsageReportItem_element
${S1AP_STARTTIMESTAMP}    ${S1_COMMANPATH}/${S1_LIST_COMM}/${D}/s1ap.startTimestamp

${S1AP_ENDTIMESTAMP}    ${S1_COMMANPATH}/${S1_LIST_COMM}/${D}/s1ap.endTimestamp

${S1AP_USAGECOUNTUL}    ${S1_COMMANPATH}/${S1_LIST_COMM}/${D}/s1ap.usageCountUL

${S1AP_USAGECOUNTDL}    ${S1_COMMANPATH}/${S1_LIST_COMM}/${D}/s1ap.usageCountDL

${S1_IES}    s1ap.UEContextReleaseComplete_element/s1ap.protocolIEs//s1ap.ProtocolIE_Field_element
${S1_CONTEXTRELEASE_COMMONPATH}    ${S1_IES}/s1ap.value_element/s1ap.SecondaryRATDataUsageReportList


${S1_COMMON_MESSAGE_ELEMENT}    s1ap.S1AP_PDU/s1ap.initiatingMessage_element/s1ap.procedureCode

${SCF_DEFAULT_FILE_PATH_DU}    /home/ute/Projects/mmw1_config/${testline_name}/scf/GNB_SCF_DU_MMW1_TL${tl.gnbs[0].instance_id}.xml

${TIMEOUT}     10min
${P_console}    False
${DU_TIMEOUT}   30min
