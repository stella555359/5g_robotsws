*** Settings ***
Documentation    Test for Cloud BTS deployment from Mantaray.
...              To deploy, fill out needed variables: ${NMS_LAB}, ${VDU_SW_VERSION}, ${VCU_SW_VERSION},
...              ${NOKIA_SYNC_VERSION}, ${RANNIC_SW_VERSION}.
...              Deployment charts (filled out) should be available in folder specified in charts_dir variable.
...              Location of init.py for deploying BTS must be passed in as argument when running this test.
...              Example command to run the script:
...              "robot --variablefile /home/ute/testline_configuration/11_16_MRBTS8699 -T -L TRACE -b debug.log
...              -d /home/ute/Mantaray_deployment
...              Author:    damian.kotula@nokia.com

Resource    ../../cloud_common_resources/mantaray/mantaray.robot

*** Variables ***
#Fill out variables:
${NMS_LAB}                    #example: 1027
${VDU_SW_VERSION}             #example: vDUCNF00_0.300.28473-amd64
${VCU_SW_VERSION}             #example: vCUCNF00_0.250.28880-amd64
${NOKIA_SYNC_VERSION}         #example: nokia-sync-operator_5.1.2-amd64
${RANNIC_SW_VERSION}          #example: ran-nic-sw-controller_3.10.3-amd64

#####################
${CCR_NAME}      ccr                #Change if CCR on your lab has other name than project1
${NMS_LAB_IP}    ${SRNCLAB${NMS_LAB}}    #Do not change. Declare used lab in ${NMS_LAB} variable.

*** Test Cases ***

vDU Deployment
    Verify Api On Lab       nms_lab_ip=${nms_lab_ip}    hw_type=vDU
    Integrate Cloud Server with NMS  nms_lab_ip=${NMS_LAB_IP}  nms_lab_number=${NMS_LAB}  hw_type=vDU
    Deploy Rannic Sw Controller
    Deploy Sync Operator
    Deploy vDU

vCU Deployment
    Verify Api On Lab       nms_lab_ip=${nms_lab_ip}    hw_type=vCU
    Integrate Cloud Server with NMS    nms_lab_ip=${NMS_LAB_IP}  nms_lab_number=${NMS_LAB}  hw_type=vCU
    Deploy vCU

vCU Blue Green Deployment
    Verify Api On Lab       nms_lab_ip=${nms_lab_ip}    hw_type=vCU
    mantaray._Enable Credential Management Feature  nms_lab_ip=${NMS_LAB_IP}
    Integrate Cloud Server with NMS    nms_lab_ip=${NMS_LAB_IP}  nms_lab_number=${NMS_LAB}  hw_type=vCU
    Deploy vCU BlueGreen

#vCU Rollback
#    Perform CNF Rollback  nms_lab_ip=${NMS_LAB_IP}  hw_type=vCU  rollback_plan_name=${None}  cnf_dn=${None}

#vDU Rollback
#    Perform CNF Rollback  nms_lab_ip=${NMS_LAB_IP}  hw_type=vDU  rollback_plan_name=${None}  cnf_dn=${None}

*** Keywords ***
Deploy Sync Operator
    Perform CNF Deployment    nop_type=nokia-sync-operator      sw_version=${NOKIA_SYNC_VERSION}
    ...                       nms_lab_number=${NMS_LAB}         nms_lab_ip=${NMS_LAB_IP}    ccr_name=${CCR_NAME}

Deploy Rannic Sw Controller
    Perform CNF Deployment    nop_type=ran-nic-sw-controller    sw_version=${RANNIC_SW_VERSION}
    ...                       nms_lab_number=${NMS_LAB}         nms_lab_ip=${NMS_LAB_IP}    ccr_name=${CCR_NAME}

Deploy vDU
    Perform CNF Deployment    hw_type=vDU                       sw_version=${VDU_SW_VERSION}
    ...                       nms_lab_number=${NMS_LAB}         nms_lab_ip=${NMS_LAB_IP}    ccr_name=${CCR_NAME}

Deploy vCU
    Perform CNF Deployment    hw_type=vCU                       sw_version=${VCU_SW_VERSION}
    ...                       nms_lab_number=${NMS_LAB}         nms_lab_ip=${NMS_LAB_IP}    ccr_name=${CCR_NAME}

Deploy vCU BlueGreen
    Perform CNF Deployment    hw_type=vCU                       sw_version=${VCU_SW_VERSION}
    ...                       nms_lab_number=${NMS_LAB}         nms_lab_ip=${NMS_LAB_IP}    ccr_name=${CCR_NAME}  blue_green=${True}