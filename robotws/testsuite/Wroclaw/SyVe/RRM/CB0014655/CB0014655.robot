*** Settings ***
Documentation
...  Feature CB0014655
...
...  author/contact: jakub.szymczakiewicz@nokia.com     sebastian.lupkowski@nokia.com

Library      testsuite.Wroclaw.SyVe.RRM.CB0014655.Res14655

Test Setup       Prepare environment
Test Teardown    Cleanup the setup and collect logs if the test fails

*** Test Cases ***
CB0014655_B2_Validate_the_FH_C-plane_message_parsing_abstraction_layer_functionality_for_DL_UL_and_periodic_SRS_in_a_single_cell_with_multiple_UEs
    Given Testline is commissioned and on air
    And Ues are attached
    When Ues traffic is started
    And Bip collection is started
    Then Bip collection is stopped
    And Ues traffic is stopped
    And Required mesgs are collected in bip pcap


