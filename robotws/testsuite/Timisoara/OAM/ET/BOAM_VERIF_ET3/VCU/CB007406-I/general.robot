*** Settings ***
Documentation
...    Author: Cristina Nicolae
...    Maintainer: Cristina Nicolae (cristina.nicolae@nokia.com)
...    Group in charge: VERIF_TIM_3_ET_GMS
...    References: DOORS
...    Feature Description: CB007406-5G-I
...    Sample execution: robot -v cranName:cran8 -L TRACE -b debug.log -d results/CB007406-5G-I general.robot

Resource   ./resources/CB007406-5G-I.robot
Resource   ./resources/xpath_CB007406-5G-I.robot

Suite Setup  Run Keyword  Login vCU
Suite Teardown  Run Keyword And Ignore Error  Logout vCU

*** Test Cases ***
[1][1.0] 5GC001569BA_gNB-CU_WebEM_DasboardView_exist
     [Tags]     CRT
 	 Check VM status Widget
     Check Alarm details view Widget

[1][1.0] 2. Check Active Alarms can be accessed and required information is visible
     [Tags]     CRT
	 Alarm 7702

[1][1.0] 4.Check Historical Alarms can be accessed and required information is visible
     [Tags]     CRT
 	 Historical Alarm view

[1][1.0] 7. Check Alarm Sorting is possible
     [Tags]     CRT
	 Alarm Filtering

[1][1.0] 2. Test_fault4350_CU
    [Tags]     CRT
    Alarm 4350
