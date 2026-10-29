*** Settings ***
Documentation    Test for Cloud BTS deployment from Mantaray.
...              To deploy, fill out needed variables: ${NMS_LAB}, ${VDU_SW_VERSION}, ${VCU_SW_VERSION},
...              ${NOKIA_SYNC_VERSION}, ${RANNIC_SW_VERSION}.
...              Deployment charts (filled out) should be available in folder specified in charts_dir variable.
...              Location of init.py for deploying BTS must be passed in as argument when running this test.
...              Example command to run the script:
...              "robot --variablefile /home/ute/testline_configuration/11_16_MRBTS8699 -T -L TRACE -b debug.log
...              -d /home/ute/Mantaray_deployment
...              /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/VRF_WRO3_T05/CloudRAN/Mantaray_deployment.robot"
...              Author:    damian.kotula@nokia.com

Resource    ../../cloud_common_resources/mantaray/mantaray.robot

*** Variables ***
#Fill out variables:
${NMS_LAB}              ____  #example: 1028
${VDU_SW_VERSION}             #example: vDUCNF00_0.300.28473-amd64
${VCU_SW_VERSION}             #example: vCUCNF00_0.250.27984-amd64
${NOKIA_SYNC_VERSION}         #example: nokia-sync-operator_5.1.2-amd64
${RANNIC_SW_VERSION}          #example: ran-nic-sw-controller_3.10.3-amd64
${KOREDUMP_VERSION}           #example: koredump-operator_1.14.5-amd64

#####################
${CCR_NAME}      project1                #Change if CCR on your lab has other name than project1
${NMS_LAB_IP}    ${SRNCLAB${NMS_LAB}}    #Do not change. Declare used lab in ${NMS_LAB} variable.

*** Test Cases ***
Integrate vCU Server
    ${api_available}=    Run Keyword And Return Status    Verify Api On Lab       nms_lab_ip=${nms_lab_ip}    hw_type=vCU
    IF    not ${api_available}    Fatal Error
    ...    msg=API on lab ${NMS_LAB} is not resolved by this BTS, deployment not possible. Raise ticket to SRN.
    Integrate Cloud Server with NMS    nms_lab_ip=${NMS_LAB_IP}    nms_lab_number=${NMS_LAB}    hw_type=vCU

Koredump Operator Deployment vCU
    ${ssh_conn}=         Connect To Admin via SSH    hw_type=vCU
    ${deployed_nops}=    Get Deployed NOP Chart Names    conn=${ssh_conn}
    ${is_koredump_deployed}=    Evaluate    any(item.startswith('koredump-operator') for item in ${deployed_nops})
    Disconnect from ADMIN via SSH    ${ssh_conn}    hw_type=vCU
    IF    ${is_koredump_deployed}
        Log    Koredump Operator already deployed on this OCP.    console=${True}
    ELSE
        Log    Starting Koredump Operator deployment.    console=${True}
        Perform CNF Deployment    nop_type=koredump-operator-vcu    sw_version=${KOREDUMP_VERSION}
        ...                       nms_lab_number=${NMS_LAB}         nms_lab_ip=${NMS_LAB_IP}    ccr_name=${CCR_NAME}
    END

vCU Deployment
    Perform CNF Deployment    hw_type=vCU                       sw_version=${VCU_SW_VERSION}
    ...                       nms_lab_number=${NMS_LAB}         nms_lab_ip=${NMS_LAB_IP}    ccr_name=${CCR_NAME}


Integrate vDU Server
    ${api_available}=     Run Keyword And Return Status    Verify Api On Lab       nms_lab_ip=${nms_lab_ip}    hw_type=vDU
    IF    not ${api_available}    Fatal Error
    ...    msg=API on lab ${NMS_LAB} is not resolved by this BTS, deployment not possible. Raise ticket to SRN.
    Integrate Cloud Server with NMS    nms_lab_ip=${NMS_LAB_IP}    nms_lab_number=${NMS_LAB}    hw_type=vDU

Koredump Operator Deployment vDU
    ${ssh_conn}=         Connect To Admin via SSH    hw_type=vDU
    ${deployed_nops}=    Get Deployed NOP Chart Names    conn=${ssh_conn}
    ${is_koredump_deployed}=    Evaluate    any(item.startswith('koredump-operator') for item in ${deployed_nops})
    Disconnect from ADMIN via SSH    ${ssh_conn}    hw_type=vDU
    IF    ${is_koredump_deployed}
        Log    Koredump Operator already deployed on this OCP.    console=${True}
    ELSE
        Log    Starting Koredump Operator deployment.    console=${True}
        Perform CNF Deployment    nop_type=koredump-operator-vdu    sw_version=${KOREDUMP_VERSION}
        ...                       nms_lab_number=${NMS_LAB}         nms_lab_ip=${NMS_LAB_IP}    ccr_name=${CCR_NAME}
    END

Rannic Deployment
    Perform CNF Deployment    nop_type=ran-nic-sw-controller    sw_version=${RANNIC_SW_VERSION}
    ...                       nms_lab_number=${NMS_LAB}         nms_lab_ip=${NMS_LAB_IP}    ccr_name=${CCR_NAME}

Nokia Sync Operator Deployment
    Perform CNF Deployment    nop_type=nokia-sync-operator      sw_version=${NOKIA_SYNC_VERSION}
    ...                       nms_lab_number=${NMS_LAB}         nms_lab_ip=${NMS_LAB_IP}    ccr_name=${CCR_NAME}

vDU Deployment
    Perform CNF Deployment    hw_type=vDU                       sw_version=${VDU_SW_VERSION}
    ...                       nms_lab_number=${NMS_LAB}         nms_lab_ip=${NMS_LAB_IP}    ccr_name=${CCR_NAME}
