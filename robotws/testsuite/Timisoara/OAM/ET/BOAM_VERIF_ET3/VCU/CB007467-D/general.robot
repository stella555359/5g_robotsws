*** Settings ***
Documentation
...    Author: Andrada Bugiu / Cristina Nicolae
...    Maintainer: Adrian Alpredi (adrian.alpredi@nokia.com)
...    Group in charge: BTS_OAM_CU
...    References: doors
...    Feature Description: 5GC007467-D-b
...    Execution command:  robot -L TRACE -b debug.log general.robot

Resource   ./resources/5GC007467-D.robot
Resource   ./resources/xpath_7467D.robot
Suite Setup     Run Keyword  Login CU
Suite Teardown  Run Keyword And Ignore Error  Logout CU

*** Test Cases ***
[1][1.0] 27. Cloud VNFC Status View from CU WebEM main navigation menu
        [Tags]     CRT
       Go to VNFC Status tableview
 		Check if the list of pods with their properties and statuses is available as a table

[1][1.0] 30. POD Details panel is available
        [Tags]     CRT
        Go to VNFC Status tableview
        Check details panel
        Verify IP not empty

[1][1.0] 2. Passive supervision for containerized CU OAM CpConfig service on vCU CNF deployment over NCIR CaaS platform
        [Tags]      CRT
        Kill process

[1][1.0] 10. Check if guard timer[15min] exceeded and minimum configuration of 5G Pods is not reached for redundant Pods [N+]
        [Tags]         CRT
        Generate fault 4473
        Check VCU recovery
