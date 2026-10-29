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

*** Variables ***
${NMS_LAB}                    #example: 1028
${VDU_SW_VERSION}             #example: vDUCNF00_0.300.28473-amd64
${VCU_SW_VERSION}             #example: vCUCNF25R2_25.250.383-amd64
${NOKIA_SYNC_VERSION}         #example: nokia-sync-operator_5.1.2-amd64
${RANNIC_SW_VERSION}          #example: ran-nic-sw-controller_3.10.3-amd64
${KOREDUMP_VERSION}           #example: koredump-operator_1.14.5-amd64

${NMS_LAB_IP}    ${SRNCLAB${NMS_LAB}}    #Do not change. Declare used lab in ${NMS_LAB} variable.

*** Test Cases ***
Upgrade vCU
    Verify Api On Lab    nms_lab_ip=${NMS_LAB_IP}    hw_type=vCU
    ${installed_sw} =    Get Software Version    hw_type=vCU
    _Prepare SW on NMS lab    sw_version=${installed_sw[0]}-amd64    nms_lab_ip=${NMS_LAB_IP}
    Perform CNF Upgrade     nms_lab_ip=${NMS_LAB_IP}    sw_version=${VCU_SW_VERSION}   hw_type=vCU

Upgrade vDU
    Verify Api On Lab    nms_lab_ip=${NMS_LAB_IP}    hw_type=vDU
    ${installed_sw} =    Get Software Version    hw_type=vDU
    _Prepare SW on NMS lab    sw_version=${installed_sw[0]}-amd64    nms_lab_ip=${NMS_LAB_IP}
    Perform CNF Upgrade     nms_lab_ip=${NMS_LAB_IP}    sw_version=${VDU_SW_VERSION}   hw_type=vDU

Upgrade Rannic
    ${rannic_sw} =    Get Rannic Version    vDU
    ${rannic_sw} =    Replace String    ${rannic_sw}    controller-    controller_
    _Prepare SW on NMS lab    sw_version=${rannic_sw}-amd64    nms_lab_ip=${NMS_LAB_IP}
    ...                       nop_type=ran-nic-sw-controller
    Perform CNF Upgrade     nms_lab_ip=${NMS_LAB_IP}    sw_version=${RANNIC_SW_VERSION}   nop_type=ran-nic-sw-controller

Upgrade Nokia Sync Operator
    ${nokia_sync_sw} =    Get Nokia Sync Version    vDU
    ${nokia_sync_sw} =    Replace String    ${nokia_sync_sw}    operator-    operator_
    _Prepare SW on NMS lab    sw_version=${nokia_sync_sw}-amd64    nms_lab_ip=${NMS_LAB_IP}
    ...                       nop_type=nokia-sync-operator
    Perform CNF Upgrade     nms_lab_ip=${NMS_LAB_IP}    sw_version=${NOKIA_SYNC_VERSION}   nop_type=nokia-sync-operator

Upgrade Koredump Operator vCU
    Perform CNF Upgrade     nms_lab_ip=${NMS_LAB_IP}    sw_version=${KOREDUMP_VERSION}   nop_type=koredump-operator-vcu

Upgrade Koredump Operator vDU
    Perform CNF Upgrade     nms_lab_ip=${NMS_LAB_IP}    sw_version=${KOREDUMP_VERSION}   nop_type=koredump-operator-vdu
