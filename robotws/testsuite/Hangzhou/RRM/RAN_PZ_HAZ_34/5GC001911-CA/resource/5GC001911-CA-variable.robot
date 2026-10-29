
*** Settings ***
Documentation    Common variables for 1911-CA feature

*** Variables ***
${LUA_SCRIPT_PATH}               /opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
${X2AP_COMMAND}       {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml
${E1AP_COMMAND}       {tshark_path} -r {pcap_file} -Y  \"e1ap\"  -T pdml
${S1AP_COMMAND}       {tshark_path} -r {pcap_file} -Y  \"s1ap\"  -T pdml

${retry_time}         5


${SCF_DEFAULT_FILE_PATH_DU}          /home/ute/Projects/mmw1_config/${testline_name}/scf/GNB_SCF_DU_MMW1_TL${tl.gnbs[0].instance_id}.xml
${IPSL_CONFIG_UTE}                 ${CURDIR}/../testdata/IPSL_CONFIG_TL${tl.gnbs[0].instance_id}
${IPSL_CONFIG_CPC}                   C:/IPSL/TA_TMP/1911_CA
${TIMEOUT}     10min
${P_console}    False


${dl_throughput}    1600M
${dl_and_ul_time}    120


#DL prot
${UE1_DL_PORTs}        ${tl.ues[0].iperf_details.ports}
${UE1_DL_PORT_QCI8}    ${tl.ues[0].iperf_details.port}
${UE1_DL_PORT_QCI7}    ${UE1_DL_PORTs[1]}
${UE1_DL_PORT_QCI9}    ${UE1_DL_PORTs[2]}



#UL port
${UL_PORTS}            ${tl.appserver.iperf_details.ports}
${UE1_UL_PORT_QCI8}    ${UL_PORTS[0]}
${UE1_UL_PORT_QCI7}    ${UL_PORTS[2]}
${UE1_UL_PORT_QCI9}    ${UL_PORTS[3]}


#port list
@{UE1_DL_PORT_QCI7_8_9}      ${UE1_DL_PORT_QCI8}  ${UE1_DL_PORT_QCI7}  ${UE1_DL_PORT_QCI9}
@{UE1_UL_PORT_QCI7_8_9}      ${UE1_UL_PORT_QCI8}  ${UE1_UL_PORT_QCI7}  ${UE1_UL_PORT_QCI9}


${QCI8}       Item 0: id-E-RABs-ToBeAdded-SgNBAddReq-Item
${QCI7}       Item 1: id-E-RABs-ToBeAdded-SgNBAddReq-Item
${QCI9}       Item 2: id-E-RABs-ToBeAdded-SgNBAddReq-Item
${QCIXpath1}  x2ap.ProtocolIE_Single_Container_element/x2ap.value_element/x2ap.E_RABs_ToBeAdded_SgNBAddReq_Item_element
${QCIXpath2}  x2ap.resource_configuration/x2ap.sgNBPDCPpresent_element/x2ap.full_E_RAB_Level_QoS_Parameters_element/x2ap.qCI
${QCI8xpath}
${QCI7xpath}
${QCI9xpath}
