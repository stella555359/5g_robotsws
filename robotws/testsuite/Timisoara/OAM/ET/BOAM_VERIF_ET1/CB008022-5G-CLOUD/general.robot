*** Settings ***
Documentation
...   Author: Radu Turcu
...   Maintainer: Radu Turcu (radu.turcu@nokia.com)
...   Group in charge: BOAM_VERIF_ET1
...   References: doors
...   Feature Description: 5GC008022-CLOUD
...   robot -v AICLOG:0 -d results/
...   -V /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB008022-5G-CLOUD/config/7_18_UTE5GAIC001T00001/
...   -b debug.log -L TRACE /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB008022-5G-CLOUD/general.robot

Resource    ./resources/CB008022-CLOUD.robot

Suite Setup       AiC Common Suite Setup
Suite Teardown    AiC Common Suite Teardown

*** Variables ***
${BROWSER} =  chrome

#*** Test Cases ***

#1_vDU_WebEM_User_Access_Control_Permissions_Radio_module_Remove_Allowed
#    [Documentation]
#    ...    *****************
#    ...    [TEST PURPOSE] test
#    ...    Check vDU_WebEM_User_Access_Control_Permission_Radio_module_Remove_Allowed
#    ...    ******************
#    ...    History of changes
#    ...    ******************
#    ...    - 28.03.2022  https://***    - Created by RADU.TURCU@NOKIA.COM
#    [Tags]   CRT
#    [Setup]   Case Precondition
#    vDU_WebEM_User_Access_Control_Permission_Radio_module_Remove_Allowed
#    [Teardown]  Case Postcondition

#4_vDU_WebEM_status_Radio_Module_Status_widget_Radio_module_Remove_Operation
#    [Documentation]
#    ...    *****************
#    ...    [TEST PURPOSE] test
#    ...    vDU_WebEM_status_Radio_Module_Status_widget_Radio_module_Remove_Operation
#    ...    ******************
#    ...    History of changes
#    ...    ******************
#    ...    - 28.03.2022  https://***    - Created by RADU.TURCU@NOKIA.COM
#    [Tags]   CRT
#    [Setup]   Case Precondition
#    4vDU_WebEM_status_Radio_Module_Status_widget_Radio_module_Remove_Operation
#    [Teardown]  Case Postcondition

#6_eCPRI_RMOD_Reduction_Without_Service_Impact
#    [Documentation]
#    ...    *****************
#    ...    [TEST PURPOSE] test
#    ...    Check vDU_WebEM_User_Access_Control_Permission_Radio_module_Remove_Allowed
#    ...    ******************
#    ...    History of changes
#    ...    ******************
#    ...    - 28.03.2022  https://***    - Created by RADU.TURCU@NOKIA.COM
#    [Tags]   CRT
#    [Setup]   Case Precondition
#    eCPRI RMOD Reduction Without Service Impact Lock Disconnect
#    [Teardown]  Case Postcondition





