*** Settings ***
Documentation    Common variables for 7077 feature

*** Variables ***
${PROGRAM}                                    ${None}
${PDML_CONVERT_NGAP_TEMPLATE}        {tshark_path} -r {pcap_file} -Y  \"ngap\"  -T pdml
${PDML_CONVERT_F1AP_TEMPLATE}        {tshark_path} -r {pcap_file} -Y  \"f1ap\"  -T pdml
${MRBTS_ID}                          ${tl.gnbs[0].instance_id}
${SCF_TEMPLATE_FILE_PATH}             /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${MRBTS_ID}.xml
${SCF_TEMPLATE_FILE_PATH_7077}        /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${MRBTS_ID}_7077.xml
${SWCONFIG_DEFAULT_FILE_PATH}        /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${MRBTS_ID}.txt
${RECOVERY_TIMEOUT}                  10 min
@{ENB1_PDU_PORT}                      ${tl.enbs[0].airscale.common_units[0].pdu_port.port_no}
${ENB_DEFAULT_SCF_FILE_7077}              /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${MRBTS_ID}_ENB.xml
