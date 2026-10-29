*** Settings ***
Documentation    Common variables

*** Variables ***
${PROGRAM}                            ${None}
${BTS_ID}                             ${tl.gnbs[0].instance_id}
${BTS_ID_for_ENB}                     ${tl.enbs[0].instance_id}
${ENB_dist_name}                      MRBTS-${BTS_ID_for_ENB}/LNBTS-${BTS_ID_for_ENB}/LNCEL-1
${SWCONFIG_DEFAULT_FILE_PATH}         /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${BTS_ID}.txt
#${SCF_DEFAULT_FILE_PATH}              /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${BTS_ID}_4cc_ABIO.xml
${SCF_DEFAULT_FILE_PATH}         /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}.xml
${ENB_SCF_DEFAULT_FILE_PATH}       /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}_ENB.xml
${TSHARK_PATH}            /usr/bin/tshark
${PDML_CONVERT_X2AP_TEMPLATE}      {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml
