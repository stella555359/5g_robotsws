*** Settings ***
Documentation
...    Author: Nicolae Cristina (cristina.nicolae@nokia.com), Catlan Radu-Vasile (radu-vasile.catlan@nokia.com)
...    Maintainer: Nicolae Cristina (cristina.nicolae@nokia.com), Catlan Radu-Vasile (radu-vasile.catlan@nokia.com)
...    Group in charge: I_MN_RAN_BOAM_VRF_OM_VERIF_TIM_3_ET_GMS
...    Feature Description: CB007406-A
...    Sample execution: robot -L TRACE -b debug.log -d results /home/ute/robotws/testsuite/Timisoara/OAM/ET/
...     BOAM_VERIF_ET3/VCU/CB007406-A/general.robot

Resource    ./resources/CB007406-A.robot

Suite Teardown  Run Keyword  Close Connection
Force Tags  df

*** Variables ***


*** Test Cases ***

[1][1.0] 2. Check vCU deployment with 1N, 2N and N+ option for 5G PODs
    [Tags]         CRT
	Verify All Pods Are Running
   
