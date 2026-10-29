*** Settings ***

Documentation
...    Author: Radu Turcu
...    Maintainer: Radu Turcu (radu.turcu@nokia.com)
...    Group in charge: BTS_OAM_VERIF
...    References: doors
...    Feature Description: 5GC007025-E
...    robot -d results general.robot
...  /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d results/
...  /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007025-5G-E/general.robot
...   robot -v AICLOG:0 -d results/
...   -V /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007025-5G-E/7_18_UTE5GAIC001T00001/
...   -b debug.log -L TRACE /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007025-5G-E/general.robot

#Resource    ../../vduResources/xpathSelenium.robot
#Resource    ../../vduResources/vduSelenium.robot
Resource    ./resources/5GC007025-E.robot

# robot -d results -v BROWSER:edge general.robot
# robot -d results -b debug.log general.robot

#Suite Setup     run keyword  Login vDU
#Suite Teardown  Run Keyword And Ignore Error  Logout vDU

Suite Setup       AiC Common Suite Setup
Suite Teardown    AiC Common Suite Teardown

*** Variables ***
${BROWSER} =  chrome

#*** Test Cases ***

#[1][1.0] 1_Create_a_new_vDU_configuration_file_with_TNL_configuration_Type_OAMFH
#    [Documentation]
#    ...    *****************
#    ...    [TEST PURPOSE] CB7025-E
#    ...    Create_a_new_vDU_configuration_file_with_TNL_configuration_Type_OAMFH
#    ...    ******************
#    ...    History of changes
#    ...    ******************
#    ...    - 11.05.2022  https://***    - Created by SLAVOLIUB-DENIS.PREDA@nokia.com
#    [Tags]         CRT
#    [Setup]   Case Precondition
#    Create_a_new_vDU_configuration_file_with_TNL_configuration_Type_OAMFH
#    Check_a_new_OAM-FH_process_added_inside_to_OAM-FH Pod
#    [Teardown]  Case Postcondition

#
#[1][1.0] 2_Check_a_new_OAM-FH_process_added_inside_to_OAM-FH Pod
#    [Documentation]
#    ...    *****************
#    ...    [TEST PURPOSE] CB7025-E
#    ...    Check_a_new_OAM-FH_process_added_inside_to_OAM-FH Pod
#    ...    ******************
#    ...    History of changes
#    ...    ******************
#    ...    - 24.04.2022  https://***    - Created by RADU.TURCU@NOKIA.COM
#    [Tags]         CRT
#    [Setup]   Case Precondition
#    Check_a_new_OAM-FH_process_added_inside_to_OAM-FH Pod
#    [Teardown]  Case Postcondition





