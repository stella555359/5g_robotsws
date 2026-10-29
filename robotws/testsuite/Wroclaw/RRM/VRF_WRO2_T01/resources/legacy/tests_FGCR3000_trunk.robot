*** Settings ***
Documentation
...  author: Pawel Wisniewski, Mikolaj Guszpit
...  contact:       pawel.1.wisniewski@nokia.com
...  maintainer:    pawel.1.wisniewski@nokia.com
...  Description:   Test Cases for FGCR-3000 feature: This sector will be filled in the future.

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/keywords_FGCR3000.robot
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.l2_trace    WITH NAME    l2_trace
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/transmission_checker.py
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.installers.TTIDecoderInstaller    WITH NAME    tti


*** Keywords ***
[1]FGCR-3000_A_101_Reconfiguration_From_NR_Only_To_LTE_Only_Detection_UL_Quality_Is_Bad

    FOR   ${att}   IN   ${15}   ${20}   ${25}   ${30}   ${35}   ${40}
        ${status}=   Run Keyword And Return Status
        ...    FGCR-3000_A_101_Reconfiguration_From_NR_Only_To_LTE_Only_Detection_UL_Quality_Is_Bad__Trunk   ${att}
        Set test variable   ${passed}   ${status}
        Exit For Loop If    ${passed}==True
    END
    Run Keyword If   ${passed}==False   Fail

[1]FGCR-3000_B_201_Reconfig_From_LTE_Only_To_NR_Only_Detection_UL_Quality_Is_Improved

    FOR   ${att}   IN   ${15}   ${20}   ${25}   ${30}   ${35}   ${40}
        ${status}=   Run Keyword And Return Status
        ...    FGCR-3000_B_201_Reconfig_From_LTE_Only_To_NR_Only_Detection_UL_Quality_Is_Improved__Trunk   ${att}
        Set test variable   ${passed}   ${status}
        Exit For Loop If    ${passed}==True
    END
    Run Keyword If   ${passed}==False   Fail

[1]FGCR-3000_A_110_Reconfig_From_NR+LTE_To_LTE_Only_Detection_Of_Bad_UL_Channel_Quality

    FOR   ${att}   IN   ${15}   ${20}   ${25}   ${30}   ${35}   ${40}
        ${status}=   Run Keyword And Return Status
        ...    FGCR-3000_A_110_Reconfig_From_NR+LTE_To_LTE_Only_Detection_Of_Bad_UL_Channel_Quality__Trunk   ${att}
        Set test variable   ${passed}   ${status}
        Exit For Loop If    ${passed}==True
    END
    Run Keyword If   ${passed}==False   Fail

[1]FGCR-3000_B_206_Reconfig_From_LTE_Only_To_NR+LTE_Detection_UL_Quality_Is_Improved

    FOR   ${att}   IN   ${15}   ${20}   ${25}   ${30}   ${35}   ${40}
        ${status}=   Run Keyword And Return Status
        ...    FGCR-3000_B_206_Reconfig_From_LTE_Only_To_NR+LTE_Detection_UL_Quality_Is_Improved__Trunk   ${att}
        Set test variable   ${passed}   ${status}
        Exit For Loop If    ${passed}==True
    END
    Run Keyword If   ${passed}==False   Fail
