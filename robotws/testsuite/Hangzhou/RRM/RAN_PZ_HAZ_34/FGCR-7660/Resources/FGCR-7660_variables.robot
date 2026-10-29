

*** Settings ***
Documentation  tion    Common variables for 1911-CA feature

*** Variables ***
${LUA_SCRIPT_PATH}               /opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
${X2AP_COMMAND}       {tshark_path} -r {input_file} -Y  \"x2ap\"  -T pdml > {output_file}
${E1AP_COMMAND}       {tshark_path} -r {input_file} -Y  \"e1ap\"  -T pdml > {output_file}
${S1AP_COMMAND}       {tshark_path} -r {input_file} -Y  \"s1ap\"  -T pdml > {output_file}

${retry_time}         5



${TIMEOUT}     10min
${P_console}    False


${dl_throughput}     550
${dl_and_ul_time}    10
${dl_cell}      1,2,3,4,5,6,7,8
${ul_cell}      1,2
${expected_dl_tput_max}    1200
${expected_ul_tput}        9
${expected_dl_tput_min}    10
${dl_num_exp}
${ul_num_exp}
${DURATION_TIME}         30
${8CC_num}         7
${4CC_num}         3
${2CC_num}         1
${1CC_num}         0
${8CC_num_for_Tput}    8
${4CC_num_for_Tput}    4
${2CC_num_for_Tput}    2
${1CC_num_for_Tput}    1
${detach_request}      True
${qct_dx50}          1
${reboor_index}      1
${ul_power_port_list}    ${tl.ues[0].iperf_details.ports[0:4]}
${dl_power_port_list}    ${tl.ues[0].iperf_details.ports[4:8]}




${SWCONFIG_DEFAULT_FILE_PATH_7660}  /opt/ute/swconfig/swconfig_MMW1_TL709.txt
${RECOVERY_TIMEOUT}            300
${SCF_DEFAULT_FILE_PATH_7660}          ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_709_7660.xml
${testline_name}               7_5_UTE5G402T709
