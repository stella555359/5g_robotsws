*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${SCF_FILE}
#...               iphy_file=${IPHY_FILE}    vendor_change_list=${vendor_change_list}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO   RAN_5G_TDD    RAN_5G    Owner_naliu    CN1_SG06    CB006137
#...               CRT    SBTS00    SBTS23R1
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./resources/CB006137_BC_resource.robot
#
#*** Variables ***
#${RD_PARAM}                     0x580497=1;0x450027=1;0x420056=1;0x58056B=1;0x420062=1;0x580611=1;0x580641=1;0x420068=6
#${VENDOR_FILE}                  ${CURDIR}/config/vendor_lte_1227.xml
#${SCF_PATH}                     ${CURDIR}/config
#${SCF_FILE}                     CB006137_3F_3T_FDD_BBP_BC020.xml
#${IPHY_FILE}                    ${CURDIR}/config/WTS/CB006137_3F_3T_FDD_BBP_BC020_iphy.xml
#&{VENDOR_PARAMS_DICT}           maxNumLayerPrbDlL1Sp=150    maxNumStreamPrbDlL1Sp=300    maxNumLayerPrbUlL1Sp=150
#...                             maxNumStreamPrbUlL1Sp=300
#${list_name}                    bbL1SpPrbCapacity
#${ref_value1}                    ABIO\\d+FDD64
#${ref_value2}                    ABIO\\d+FDD32
#&{vendor_change_dict1}           params_dict=&{VENDOR_PARAMS_DICT}    list_name=${list_name}    ref_value=${ref_value1}
#&{vendor_change_dict2}           params_dict=&{VENDOR_PARAMS_DICT}    list_name=${list_name}    ref_value=${ref_value2}
#@{vendor_change_list}            ${vendor_change_dict1}    ${vendor_change_dict2}
#
#
#
#@{LOG_NAME_LIST}                snapshot    btsLog
#@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
#${COUNT}                        0
#${WTS_LOCAL}                    ${CURDIR}/config/WTS
#${WTS_CFG}                      CB006137_3F_3T_FDD_BBP_BC020.cfg
#${DL_TPUT_TARGET}               400
#${UL_TPUT_TARGET}               50
#
#*** Test Cases ***
#CB006137-ET-BC020_Single_UE__UL_CA__Call_with_baseband_pooling_of_PRBs_for_FDD_with_nonGBR_data_transmission
#    Multi UE Attach And Do UL DL Traffic    1    1    100    100
#    Multi UE Attach And Do UL DL Traffic    41    41    80    100
#    Multi UE Attach And Do UL DL Traffic    51    51    80    100
#    Check Multiple CA UEs Ul Pcell Throughput    1    1    0    1    20
#    Check Multiple CA UEs Ul Pcell Throughput    41    41    0    1    20
#    Check Multiple NonCA UEs Throughput    51    51    ul    40
#    common_Log_capture.Start Ttitrace With Streaming Mode
#    Sleep    3s    reason=capture ttitrace
#    Stop Ttitrace
#    common_log_analyzer.Convert Ttitrace From Pcap To Excelcsv    ${output_dir}/ttitrace_streaming/
#    common_log_analyzer.Format Tti In Stream Mode    ${output_dir}/ttitrace_streaming/output_dl.csv
#    ...    ${output_dir}/ttitrace_streaming/output_dl_formated.csv
#    common_log_analyzer.Format Tti In Stream Mode    ${output_dir}/ttitrace_streaming/output_ul.csv
#    ...    ${output_dir}/ttitrace_streaming/output_ul_formated.csv
#    Save Egate Log    ${output_dir}/egate/
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}ttitrace_5GC001227.ini
#    ...    i    save_log_directory=${output_dir}/ttitrace_streaming
#
#*** Keywords ***
