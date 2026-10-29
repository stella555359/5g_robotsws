*** Settings ***
Documentation
...  Author:        Maciej Cupial, Adam Tokarski
...  Contact:       maciej.cupial@nokia.com, adam.tokarski@nokia.com
...  Feature owner: Karol Malutkiewicz, Witold Galka
...  Description:   Power Saving feature for 5G site
...                 Feature Corner:     https://feature-corner.nsn-net.net/materials/clbkj7uvc2084464wkzdj046wlm

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/keywords_8951.resource
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.PmUtils    WITH NAME    pu
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/multi_UE.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/cplane_collector.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.robot


*** Variables ***
${ue_alias}               UE_1
@{cells_to_deactivate}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}    ${11}    ${12}


*** Keywords ***
[1]CB009920_HYBRID_US#01_COUNTER_US#02
    [Documentation]
    ...    The idea of this hybrid TC is to combine all 9920 TCs in one keyword:
    ...    0st PART: CB009920_1  and result is stored as var_1 = True/False
    ...    1th PART: CB009920_11 and result is stored as var_0 = True/False
    ...    2nd PART: CB009920_2  and result is stored as var_2 = True/False

    Perform Commissioning 8951 LTE
    Set default lnRelGnbCellId
    Activate 9920
    # PART 0
    Prepare And Activate Feature 8951 And 9920
    Verify 9920_1 Activation
    Set Suite Variable  ${act_with_8951}  'TRUE'
    # PART 1
    Deactivate 9920
    Check If Initial M8080C163 Counter Value Is Zero
    Check Lte Cells
    Lock non energy saving nr cells
    Triggering Counter By Attach Loop
    Collect Counter M8080C163 And Check Value
    Set Suite Variable  ${reject_counter}  'TRUE'
    # PART 2
    Prepare And Deactivate Feature 8951
    Activate 9920
    Verify 9920_2 Activation
    Set Suite Variable  ${act_no_8951}  'TRUE'


[1]CB009920_7_power_saving_Removal_of_LNRELGNBCELL_negative
    [Documentation]
    ...    In this test case we are checking 'anrNrNbrRelRemGuardTime' parameter

    ${global_cells_ids}    ${nr_cells_ids}    Get Cells Info

    # Preconditions
    Commissioning 9920 7 LTE
    Commissioning 9920 7 5G     ${global_cells_ids}
    Wait Until Cells Status     ${global_cells_ids}[0]    power_saving_status=on
    Verify LNRELGNBCELL pwSavingDeactInd    ${nr_cells_ids}[0]    True

    # Test steps
    Deactivate endcAnrAutoRemDisallNrCellEss

    # Postconditions
    Wait for anrNrNbrRelRemGuardTime and Verify LNRELGNBCELL Removal   ${nr_cells_ids}[0]
