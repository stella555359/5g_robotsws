*** Settings ***
Documentation    Common variables for 5GC002569-A-574 Inter-eNB intra-gNB handover feature

*** Variables ***
${SCF_DEFAULT_FILE_PATH_CU_255}              /opt/ute/scf/SCF_CU_MMW1_TL${tl.gnbs[0].cu.instance_id}.xml
${SCF_DEFAULT_FILE_PATH_DU_416}          /opt/ute/scf/SCF_DU_MMW1_TL${tl.gnbs[0].dus[0].instance_id}.xml

${SWCONFIG_DEFAULT_FILE_PATH_DU_416}        /opt/ute/swconfig/swconfig_MMW1_TL${tl.gnbs[0].dus[0].instance_id}.txt

${E500_SCRIPTS_SGW_CHANGE}     ${CURDIR}/../TestData/E500_script_SGW_CHANGE

${eNB_A3_MEAS_ID}    1
