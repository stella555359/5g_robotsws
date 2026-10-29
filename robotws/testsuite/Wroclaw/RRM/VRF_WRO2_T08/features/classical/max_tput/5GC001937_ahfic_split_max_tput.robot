*** Settings ***
Documentation
...   author:  Marcin Bednarski
...   contact: marcin.bednarski@nokia.com

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/max_tput/resources/test_specific_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot

Force Tags      CA_VRF_WRO2

Suite Setup     Run Keywords  Prepare Testline  AND  Suite Setup
Test Setup      Test Setup
Test Teardown   Test Teardown

*** Test Cases ***
[1]Bi-Directional_Throughput_noDss_NsaSa_TputNsaSplitUDP_AhficS3_DL4x4CL_UL4x4CL_Bw10MhzAr430000
    [1]Bi-Directional_Throughput_noDss_NsaSa_TputNsaSplitUDP_AhficS3_DL4x4CL_UL4x4CL_Bw10MhzAr430000

[1]Bi-Directional_Throughput_noDss_NsaSa_TputNsaSplitTCP_AhficS1_DL4x4CL_UL4x4CL_Bw10MhzAr430000
    [1]Bi-Directional_Throughput_noDss_NsaSa_TputNsaSplitTCP_AhficS1_DL4x4CL_UL4x4CL_Bw10MhzAr430000

[1]Bi-Directional_Throughput_noDss_NsaSa_TputNsaSplitTCP_AhficS2_DL4x4CL_UL4x4CL_Bw10MhzAr430000
    [1]Bi-Directional_Throughput_noDss_NsaSa_TputNsaSplitTCP_AhficS2_DL4x4CL_UL4x4CL_Bw10MhzAr430000

[1]Bi-Directional_Throughput_noDss_NsaSa_TputNsaSplitTCP_AhficS3_DL4x4CL_UL4x4CL_Bw10MhzAr430000
    [1]Bi-Directional_Throughput_noDss_NsaSa_TputNsaSplitTCP_AhficS3_DL4x4CL_UL4x4CL_Bw10MhzAr430000
