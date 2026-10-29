*** Settings ***
Documentation
...  Tests for CB012250-D

Resource  ../../common_resources/vdu_frame.robot
Resource  ../resources/common_vdu.robot
Resource  ../resources/LOGS_general.robot
Resource  ../resources/AIC_NetAct.robot
Resource  ../../common_resources/M2M_Interface.robot


Library    taf.transport.ssh  WITH NAME  csn
Library    taf.gnb.oam.coam.vdu  WITH NAME  vdu
Library    ../resources/python/utils.py
Library    SSHLibrary
Library     DateTime

Variables  ../resources/python/My_NetAct.py
#Variables  ../../common_resources/python_resources/common_variables.py


*** Keywords ***

TC__CB012250_D_M2M_interface_to_fetch_SmartNIC_status_from_vDU

    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Execute M2M command for rannic
    ...  ******************
    ...  *AUTHOR*: radu.turcu@nokia.com

    Set Tags  CA-WebEM  OWNER-radu.turcu@nokia.com  AUTHOR-radu.turcu@nokia.com    GROUP_IN_CHARGE-TIM_7_Vrf
    ...  PHASE-CRT  SW-SBTS25R2  FEATURE-CB012250-D
    Step 0: Precondition
    Step 1: Execute M2M RanNic command TC1

TC__CB012250_D_M2M_interface_to_fetch_SmartNIC_synchronization_status_from_vDU

   [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Execute M2M command for rannic
    ...  ******************
    ...  *AUTHOR*: radu.turcu@nokia.com

    Set Tags  CA-WebEM  OWNER-radu.turcu@nokia.com  AUTHOR-radu.turcu@nokia.com    GROUP_IN_CHARGE-TIM_7_Vrf
    ...  PHASE-CRT  SW-SBTS25R2  FEATURE-CB012250-D
    Step 0: Precondition
    Step 1: Execute M2M RanNic command TC2


Step 0: Precondition
   [Documentation]
    ...   In this step Precond

    Log    \nStep 0: Precondition    console=${True}

Step 1: Execute M2M RanNic command TC1
    Log  \nStep 3: Start Diagnostic Check through NMS.  console=true
    ${current_date_time}  Get Current Time For Diagnostic Check
    Set Test Variable  ${CURRENT_DATE_TIME}
    ${diagnostic_post_output}  Run M2M Command  GET
    ...    "https://${VDU_OAM_IP}/api/licensed/v1/ran-nics?rnicmodDn=MRBTS-${VDU_MRBTS_ID}%2FEQM_R-1%2FAPEQM_R-1%2FRNICMOD_R-1&scope=general"
    ...    Bearer  ${TOKEN}
    Should Contain  ${diagnostic_post_output}  "configurationDn":
    Should Contain  ${diagnostic_post_output}  "moduleStatus":
    Should Contain  ${diagnostic_post_output}  "proceduralState":
    Should Contain  ${diagnostic_post_output}  "usageState":
    Should Contain  ${diagnostic_post_output}  "portsInformation":
    Should Contain  ${diagnostic_post_output}  "label":
    Should Contain  ${diagnostic_post_output}  "runtimeDn":
    Should Contain  ${diagnostic_post_output}  "productCode":
    Should Contain  ${diagnostic_post_output}  "productName":
    Should Contain  ${diagnostic_post_output}  "serialNumber":


Step 1: Execute M2M RanNic command TC2
    Log  \nStep 3: Start Diagnostic Check through NMS.  console=true
    ${current_date_time}  Get Current Time For Diagnostic Check
    Set Test Variable  ${CURRENT_DATE_TIME}
    ${diagnostic_post_output}  Run M2M Command  GET
    ...    "https://${VDU_OAM_IP}/api/licensed/v1/ran-nics?rnicmodDn=MRBTS-${VDU_MRBTS_ID}%2FEQM_R-1%2FAPEQM_R-1%2FRNICMOD_R-1&scope=sync"
    ...    Bearer  ${TOKEN}
    Should Contain  ${diagnostic_post_output}  "configurationDn":
    Should Contain  ${diagnostic_post_output}  "productCode":
    Should Contain  ${diagnostic_post_output}  "runtimeDn":
    Should Contain  ${diagnostic_post_output}  "satellites":
    Should Contain  ${diagnostic_post_output}  "satelliteType":
#    Should Contain  ${diagnostic_post_output}  "ptpMasterId":
    Should Contain  ${diagnostic_post_output}  "availabilityStatus":
    Should Contain  ${diagnostic_post_output}  "syncInputType":
    Should Contain  ${diagnostic_post_output}  "usabilityStatus":
    Should Contain  ${diagnostic_post_output}  "testClockStatus":
    Should Contain  ${diagnostic_post_output}  "tuningMode":

Test Teardown
    [Documentation]
    ...   Teardown test
    Log    \nTeardown: no teardown test    console=${True}

TC Setup
    Common VDU Setup
    Login Using M2M Interface  ${VDU_OAM_IP}

TC Teardown
    Test Teardown
    Common VDU Teardown
    Logs To Rotta Copy
