*** Settings ***
Documentation    Common variables for 1581 feature

*** Variables ***
${LUA_SCRIPT_PATH}               /opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
${X2AP_COMMAND}       {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml
${SCF_DEFAULT_FILE_PATH_DU}     /home/ute/Projects/mmw1_config/${testline_name}/scf/GNB_SCF_DU_MMW1_TL${tl.gnbs[0].instance_id}.xml
