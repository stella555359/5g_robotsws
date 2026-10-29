*** Settings ***
Documentation
...   author: Tong Chen
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG2

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Huawei_sigspark_L3_call.robot
Variables    ../TestData/980_nidd_modify.py
Variables    ../TestData/5GC001783_5GC002040_modify_scf.py
Variables    ../TestData/5GC001783_modify_nidd.py

*** Variables ***
${BTS_ID}                        ${tl.gnbs[0].instance_id}
${RU_RESOURCE_BUILD_KEY}         LTX_AEQB
${RU_PRODUCT_CODE}               474413A.Y21
${RU_TYPE}                       ${tl.gnbs[0].dus[0].rus[0].radio_type.value}
${RU_1_SERIAL_NUM}               ${tl.gnbs[0].dus[0].rus[0].serial_number}
${SAVE LOG DIRECTORY}            ${OUTPUT DIR}
${SCF_DIR_1783}                  /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/5GC001783
${SCF_2DL_2UL_60M_2197}          ${SCF_DIR_1783}/SCF_SG2_TL${BTS_ID}_AEQB_2X2_60M_2197.xml
${SCF_4DL_2UL_20M_2197}          ${SCF_DIR_1783}/SCF_SG2_TL${BTS_ID}_AEQB_4X2_20M_2197.xml
${SCF_4DL_2UL_40M_2197}          ${SCF_DIR_1783}/SCF_SG2_TL${BTS_ID}_AEQB_4X2_40M_2197.xml
${SCF_4DL_2UL_80M_2197}          ${SCF_DIR_1783}/SCF_SG2_TL${BTS_ID}_AEQB_4X2_80M_2197.xml

${RECOVERY_TIMEOUT}    15 min

# UL/DL throughput
${UL_PORT}        ${tl.appserver.iperf_details.port}
${UL_LENGTH}      1024B
${UL_TIME}        6000
${DL_PORT}        ${tl.ues[0].iperf_details.port}
${DL_LENGTH}      1024B
${DL_TIME}        6000
${UL_THROUGHPUT}    200Mbits/sec
${DL_THROUGHPUT}    1500Mbits/sec
# BLER Percentage
${EXP_TPUT_PERCENTAGE}    0.8
${UL_EXPECT_60M}    65.138
${DL_EXPECT_60M}    417.562
${DL_4X4_EXPECT_60M}    834.376
${UL_EXPECT_20M}    20.275
${DL_4X4_EXPECT_20M}    262.24
${UL_EXPECT_40M}    41.813
${DL_4X4_EXPECT_40M}    546.116
${UL_EXPECT_80M}    86.093
${DL_4X4_EXPECT_80M}    1114
${UL_EXPECT_90M}    98.366
${DL_4X4_EXPECT_90M}    1245
${UL_EXPECT_100M}    108.146
${DL_4X4_EXPECT_100M}    1412

*** Keywords ***
Commission for 5GC000980 and Wait Cell On Air
    ${scf_file_path}    Add ALD information to scf    scf_file_path=${backup_scf_file}
    ${output_scf_file_path}    coam_gnb_classical.COAM Modify scf file    scf_file_path=${scf_file_path}
    ...    scf_parameters_list=${MODIFY_SCF_980_BASE}
    COAM commission scf and wait cell setup    scf_file_path=${output_scf_file_path}

ALD Should Be Ready
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${ald_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log To Console    Info: verify ALD should be ready...
    Check ALD Status
    ...    administrative_state=Unlocked    availability_status=-
    ...    operational_state=Enabled    procedural_status=-
    ...    ald_index=${ald_index}    download_dir=${download_dir}

RAEU Should Be Ready
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${raeu_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log To Console    Info: verify RAEU should be ready...
    Check RAEU Status
    ...    administrative_state=Unlocked    availability_status=-
    ...    operational_state=Enabled    procedural_status=-
    ...    raeu_index=${raeu_index}    download_dir=${download_dir}
