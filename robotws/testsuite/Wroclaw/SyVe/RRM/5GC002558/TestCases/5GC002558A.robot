*** Settings ***
Documentation
...  UL and DL PRB blanking on both edges
...
...  author: jakub.kaszczyszyn@nokia.com

Library         testsuite.Wroclaw.SyVe.RRM.resources.Rfrl   WITH NAME   rfrl
Library         testsuite.Wroclaw.SyVe.RRM.5GC002558.resources.Resources2558
Library         testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot

Force Tags      CLOUD_5G_CLASSICAL_2xANDROID_ASIKL_ABILB1_3xAHLOA  STATE_SW_UPLOADED
...             RAN_5G    RAN_5G_FDD     RAN_5G_MP    RAN_5G_MP_CUSTOMER    RAN_5G_FDD_MP


Suite Setup    Confirm SW version and make sure BBU modules are enabled after installation

Test Teardown       Run Keywords
                    ...    Detach Qualcomm Ue    AND
                    ...    Make Sure Ue Actions Are Cleared    AND
                    ...    All cells are unblocked after test   AND
                    ...    Common step trigger

Suite Teardown    Collect snapshot if suite fails

*** Test Cases ***

[1]5GC002558-A_End_1Call2S_Tput_Class_ASIK_ABIL_SA_20MHz_2x2_PRB-Blanking_both_edges_2UE
   [Setup]          Run Keywords    Set Test Variables For Test    AND
                    ...    Restart Ue   AND
                    ...    And Add scout external execution id to the reporting portal
    Update Sw Config And Prepare Gnb With Proper Bandwidth     20MHz
    Wait for bts to reach on air state
    Selected sector is ready for test
    Prb Blanking Is Configured On Cell  7   9   7   1
    Asp Log File Is Downloaded And Number Of Blanked Prbs Is Checked In Asp Startup Log     7   9   7   1
    Prepare And Attach Ue
    Proper Tcp Traffic Is Launched And Reached    20MHz

[1]5GC002558-A_End_1Call2S_Tput_Class_ASIK_ABIL_SA_15MHz_2x2_PRB-Blanking_both_edges_succesful_activation
   [Setup]          Run Keywords    Set Test Variables For Test    eda_test=True      AND
                    ...    Restart Ue   AND
                    ...    And Add scout external execution id to the reporting portal
    Update Sw Config And Prepare Gnb With Proper Bandwidth    15MHz
    Wait for bts to reach on air state
    Selected sector is ready for test
    Prepare And Attach Ue    eda_test=True
