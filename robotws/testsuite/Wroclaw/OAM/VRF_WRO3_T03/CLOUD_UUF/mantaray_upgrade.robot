*** Settings ***
Documentation    Test suite for performing CNF upgrades on vDU, vCU, and additional components like Nokia Sync Operator and RAN NIC SW Controller.
...              This suite verifies the API on the specified NMS lab and performs upgrades for the given hardware type or NOP type.
...              Variables ${NMS_LAB}, ${VDU_SW_VERSION}, ${VCU_SW_VERSION}, ${NOKIA_SYNC_VERSION}, ${RANNIC_SW_VERSION} must be set appropriately.
...              The NMS lab IP is automatically derived from the ${NMS_LAB} variable.
...              To execute the test, ensure the required software versions are available and the NMS lab is accessible.
...              Example command to run the test suite:
...              "robot --variable NMS_LAB:1019 --outputdir /path/to/outputdir testsuite/Wroclaw/OAM/VRF_WRO3_T01"
...              Author:    damian.kotula@nokia.com

Resource    ../../cloud_common_resources/mantaray/mantaray.robot
Resource    ../resources/common.robot

*** Variables ***
${NMS_LAB}                    #example: 1027
${VDU_SW_VERSION}             #example: vDUCNF00_0.300.28473-amd64
${VCU_SW_VERSION}             #example: vCUCNF25R2_25.250.391-amd64
${NOKIA_SYNC_VERSION}         #example: nokia-sync-operator_5.1.2-amd64
${RANNIC_SW_VERSION}          #example: ran-nic-sw-controller_3.10.3-amd64
${FHGW_SW_VERSION}            #example: FHGW26R2_003

${NMS_LAB_IP}    ${SRNCLAB${NMS_LAB}}    #Do not change. Declare used lab in ${NMS_LAB} variable.

*** Test Cases ***
Upgrade vDU
    Perform CNF Upgrade     nms_lab_ip=${NMS_LAB_IP}    sw_version=${VDU_SW_VERSION}   hw_type=vDU

Upgrade vCU
    Perform CNF Upgrade     nms_lab_ip=${NMS_LAB_IP}    sw_version=${VCU_SW_VERSION}   hw_type=vCU

BlueGreen Upgrade vCU
    Perform CNF BlueGreen Upgrade   nms_lab_ip=${NMS_LAB_IP}  sw_version=${VCU_SW_VERSION}   hw_type=vCU

Upgrade Rannic
    Perform CNF Upgrade     nms_lab_ip=${NMS_LAB_IP}    sw_version=${RANNIC_SW_VERSION}   nop_type=ran-nic-sw-controller

Upgrade Nokia Sync Operator
    Perform CNF Upgrade     nms_lab_ip=${NMS_LAB_IP}    sw_version=${NOKIA_SYNC_VERSION}   nop_type=nokia-sync-operator

Upgrade FHGW
    Verify Api On Lab       nms_lab_ip=${NMS_LAB_IP}    hw_type=vDU
    Perform FHGW Upgrade    nms_lab_ip=${NMS_LAB_IP}    sw_version=${FHGW_SW_VERSION}

#vCU Rollback
#    Perform CNF Rollback  nms_lab_ip=${NMS_LAB_IP}  hw_type=vCU  rollback_plan_name=8700_rollback_before_vCUCNF00_0.250.30656-amd64
#    ...  cnf_dn=PLMN-PLMN/CNF-87001  delete_rollback_plan=${False}

#vDU Rollback
#    Perform CNF Rollback  nms_lab_ip=${NMS_LAB_IP}  hw_type=vDU  rollback_plan_name=${None}  cnf_dn=${None}

#BlueGreen Roolback vCU
#    Perform CNF BlueGreen Rollback  nms_lab_ip=${NMS_LAB_IP}  rollback_plan_name=8512_rollback_before_vCUCNF25R3_26.250.159-amd64
#    ...  gb_dist_names=PLMN-PLMN/CNF-8512199    delete_rollback_plan=${False}

#FHGW Rollback
#    Perform FHGW Rollback   nms_lab_ip=${NMS_LAB_IP}
