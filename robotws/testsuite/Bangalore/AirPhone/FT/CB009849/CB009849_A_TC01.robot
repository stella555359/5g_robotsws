*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Keerthi Chittoor
                 ...              :contact      : keerthi.chittoor@nokia.com
                 ...              :Description  : This script is to validate CB008235-A
                 ...                               03 test cases
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,12.05.2025,vadivelan.manickavasagam@nokia.com

Resource          ./resources/Keywords/CB009849_Keywords.robot
Resource          ../resources/Variables/general_common_variables.robot
Resource          ./resources/Variables/CB009849_variables.robot

#Suite Setup       CB009849 Suite Setup
#Suite Teardown    CB009849 Suite Teardown

*** Test Cases ***
CB009849_A_2_TC_01_Verify Successful user reconfiguration with 5QI1 DRB, UE supports transform precoder
    [Documentation]
         ...    author: keerthi.chittoor@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,12.05.2025,keerthi.chittoor@nokia.com
         ...    To verify reconfiguration with 5QI1 DRB,UE supports
         ...    transform precoder on FDD
    SA UE Attach And Send Traffic
    Transformer precoder Activation for UE1
    Transformer precoder Deactivation for UE1
    User Modify with 5QI1 DRB Addition
    User Modify with 5QI1 DRB Release
