*** Settings ***
Documentation    Test for Cloud BTS termination from Mantaray.
...              Terminates CNF objects and deintegrates CLOUD objects in given NMS lab based on
...              variables ${MRBTS_CU} and ${MRBTS} from init.py
...              To terminate, fill out needed variable: ${NMS_LAB}
...              Location of init.py for terminating BTS must be passed in as argument when running this test.
...              Example command to run the script:
...              "robot --variablefile /home/ute/testline_configuration/11_16_MRBTS8699 -T -L TRACE -b debug.log
...              -d /home/ute/Mantaray_deployment
...              Author:    damian.kotula@nokia.com

Resource    ../../cloud_common_resources/mantaray/mantaray.robot

*** Variables ***
#Fill out variable:
${NMS_LAB}         #example: 1028

#Do not change. Declare used lab in ${NMS_LAB} variable.
${NMS_LAB_IP}    ${SRNCLAB${NMS_LAB}}

*** Test Cases ***

vDU Termination
    Terminate vDU
    Terminate Rannic Controller
    Terminate Sync Operator
    Deintegrate Cloud Server from NMS    nms_lab_ip=${NMS_LAB_IP}    nms_lab_number=${NMS_LAB}    hw_type=vDU

vCU Termination
    Terminate vCU
    Deintegrate Cloud Server from NMS    nms_lab_ip=${NMS_LAB_IP}    nms_lab_number=${NMS_LAB}    hw_type=vCU

*** Keywords ***
Terminate Sync Operator
   Terminate CNF    nms_lab_ip=${NMS_LAB_IP}    nop_type=nokia-sync-operator

Terminate Rannic Controller
   Terminate CNF    nms_lab_ip=${NMS_LAB_IP}    nop_type=ran-nic-sw-controller

Terminate vDU
   Terminate CNF    nms_lab_ip=${NMS_LAB_IP}    hw_type=vDU

Terminate vCU
   Terminate CNF    nms_lab_ip=${NMS_LAB_IP}    hw_type=vCU
