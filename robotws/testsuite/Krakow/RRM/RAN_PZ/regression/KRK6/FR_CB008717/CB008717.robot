*** Settings ***
Documentation
...   author: Piotr Brzezicki, Mateusz Potoniec
...   contact: piotr.brzezicki@nokia.com, mateusz.potoniec@nokia.com
...   maintainer: piotr.brzezicki@nokia.com, mateusz.potoniec@nokia.com


Resource    ./resources/suite_specific_keywords.robot

Suite Setup       Suite Setup
Suite Teardown    Suite Teardown

*** Test Cases ***
CB008717-5G-K_101_#B1_Successful_SCell_Addition_8CC
    [Setup]    Test Setup
    pmcount.Wait For Next Full Pm Interval
    ue.Attach UE   QC_MTP_SDX65
    ${CELL_ID}=    ue.Get Ue Info    QC_MTP_SDX65   CELL_ID
    Should Be Equal    ${DESIRED_CELL_ID}    ${CELL_ID}
    Execute And Verify Large Udp Dl And Ul Data Transfer For Short Time
    ue.Detach Ue    QC_MTP_SDX65
    Verify That Legacy Pm Counters Were Not Incremented
    [Teardown]    Test Teardown

CB008717-5G-K_501_#B5_Release_of_UE_due_to_AMF_context_release
    [Setup]    Run Keywords
    ...            Delta Commissioning With OnAir Check         delta=${k_501_preconditions}    AND
    ...            Test Setup
    Attach UE With NRDC Establishment Verification
    Execute And Verify Large UDP DL And UL Data Transfer For Short Time
    Detach UE With NRDC Release Verification
    Attach UE With NRDC Establishment Verification
    Execute And Verify Large UDP DL And UL Data Transfer For Short Time
    Detach UE With NRDC Release Verification
    [Teardown]    Run Keywords
    ...            Delta Commissioning With OnAir Check        delta=${k_501_rollback}    AND
    ...            Test Teardown

CB008717-JC_101_#B1_Activation_NRDC_A4_after_ICS
    [Setup]    Run Keywords
    ...            Delta Commissioning With OnAir Check        delta=${jc_101_preconditions}    AND
    ...            Test Setup
    Attach UE And Verify That Inter-Freq And Inter-RAT Measurements Were Configured
    Reconfigure NRBTS/IdentifiedFwaUeList = <UE RFSP Index>
    Attach UE And Verify That Inter-Freq And Inter-RAT Measurements Were NOT Configured
    [Teardown]    Run Keywords
    ...            Delta Commissioning With OnAir Check        delta=${jc_101_rollback}    AND
    ...            Test Teardown

CB008717-JC_301_#B19_IMM_UE_Inactivity_timer_expiry_with_NRDC_A4_configured
    [Setup]    Run Keywords
    ...            Delta Commissioning With OnAir Check        delta=${jc_301_preconditions}     AND
    ...            Test Setup
    Attach UE And A4 NRDC Is Configured And RRC Release Contains Frequencies For Reselection
    [Teardown]    Run Keywords
    ...            Delta Commissioning With OnAir Check         delta=${jc_301_rollback}    AND
    ...            Test Teardown

CB008717-JA_101_#B1_RRC_Reestablishment_to_other_cell_with_A4RetryTimer_in_new_cell
    [Setup]    Run Keywords
    ...            Delta Commissioning With OnAir Check    delta=${ja_101_preconditions}    AND
    ...            Test Setup
    Attach UE To Each Cell
    Attach UE And Trigger Reestablishment To Other Cell During A4 Supervision Timer Running
    [Teardown]    Run Keywords
    ...            Delta Commissioning With OnAir Check    delta=${ja_101_rollback}    AND
    ...            Test Teardown
