*** Settings ***
Documentation
...    Author: Adrian Cretu / Oana Ciuculescu
...    Maintainer: Adrian Cretu / Oana Ciuculescu (adrian.1.cretu@nokia.com / oana.ciuculescu@nokia.com)
...    Group in charge: VERIF_TIM_3_ET_GMS
...    References: DOORS
...    Feature Description: CB001719-5G-B
...    Sample execution: robot -v cranName:cran5 -L TRACE -b debug.log -d results/CB001719-5G-B general.robot

Resource     ./resources/CB001719-5G-B.robot
Resource     ./resources/xpath_CB001719-5G-B.robot

Suite Setup  Run Keyword  Login vCU
Suite Teardown  Run Keyword And Ignore Error  Logout vCU

*** Test Cases ***

[1][1.0] 1.Check if Xn Link lock or unlock buttons are available on vCU WebEM dashboard to perform lock or unlock operations

    #[1]Check if operator can select on which Xn Link(s) lock/unlock operation shall be executed.
    Check Xn Link buttons
    Verify Xn Link state

    #[2]Xn Link(s) lock/unlock operation shall be executed for both Xn links
    Change Xn Links   ${lockbutton}  ${unlockbutton}
    Change Xn Links   ${unlockbutton}  ${lockbutton}

    #[3]Xn Link(s) lock/unlock operation shall be executed for one filtered Xn link
    Change one Xn Link using filter
