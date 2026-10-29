*** Settings ***

Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: This is a Robot Test Suite for ORAN feature CB009420 'Basic L3 call script'.
...    Tested on: CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD_ORAN   STATE_CONFIGURED

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource  ./CB009420_Keywords.robot

Suite Setup    Prepare TL for CB009420
Suite Teardown    Sqd65 Common Teardown

Test Setup    Perform Preconditions of Test Scenario
Test Teardown    Perform Postconditions of Test Case

*** Variables ***

${TEST_MODE}  auto
${UE_ID_NSA}  12
${UE_ID_SA}  2
${DL_MBPS}  5
${UL_MBPS}  2
${BEARER_ID}  2
${PDU_ID}  1
${TARGET_CELLS}  2
${GW}  2

*** Test Cases ***

[1]CB009420_NSA_O-RU_startup_with_L3_call_Functional_Test

    [Documentation]  UE Attach, Bidirectional Data Traffic and Dettach in NSA without delta commissioning
    ...
    [Tags]  NSA_1

    FOR   ${UE_ID_NSA}                         ${TARGET_CELLS}      IN
    ...   11                                   1
    ...   12                                   2
          NSA UE Attach and Bidirectional Data Traffic Start    ${UE_ID_NSA}  ${TARGET_CELLS}  ${BEARER_ID}  ${DL_MBPS}  ${UL_MBPS}
    END
    Sleep                                   600s
    FOR   ${UE_ID_NSA}      IN
    ...   11
    ...   12
          NSA Bidirectional Data Traffic Validation and UE Dettach    ${UE_ID_NSA}  ${BEARER_ID}
    END

[1]CB009420_SA_O-RU_startup_with_L3_call_Functional_Test

    [Documentation]  UE Register, Bidirectional Data Trafic and Deregister in SA without delta commissioning
    ...
    [Tags]  SA_1

    FOR   ${UE_ID_SA}                         ${GW}      IN
    ...   1                                   1
    ...   2                                   2
          SA UE Register and Bidirectional Data Traffic Start    ${UE_ID_SA}  ${GW}  ${PDU_ID}  ${DL_MBPS}  ${UL_MBPS}
    END
    Sleep                                   600s
    FOR   ${UE_ID_SA}      IN
    ...   1
    ...   2
          SA Bidirectional Data Traffic Validation and UE Deregister    ${UE_ID_SA}  ${PDU_ID}
    END
