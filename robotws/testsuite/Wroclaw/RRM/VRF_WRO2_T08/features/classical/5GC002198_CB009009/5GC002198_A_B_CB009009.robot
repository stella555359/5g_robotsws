*** Settings ***
Documentation
...    author: Marcin Bednarski
...    contact: marcin.bednarski@nokia.com

Resource    ./resources/test_specific_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot
Library     ./resources/test_specific_keywords.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/utility/anr_knife.py

Force Tags      CA_VRF_WRO2
Suite Setup    ANR Knife
Test Teardown   Test Teardown

*** Test Cases ***
5GC002198_B_B1_TC13 Automatic Neighbour Removal Procedure - twice idleTime modification
    [Setup]   Test Setup   require_srb_3=${FALSE}   require_ue=${FALSE}   disable_removal=${TRUE}
    Automatic Neighbour Removal Procedure Twice IdleTime Modification

5GC002198_B_B5_TC18 Online modification disable flag actAutoNrNbRemoval
    [Setup]   Test Setup   require_srb_3=${FALSE}   require_ue=${FALSE}   disable_removal=${TRUE}
    Modification Disable Flag ActAutoNrNbRemoval

5GC002198_A_B2_TC04 Inter gNB PCI resolution and neighbour relation addition without SRB3
    [Setup]   Test Setup   require_srb_3=${FALSE}
    Inter Gnb Pci Resolution And Neighbour Relation Addition

5GC002198_A_B2_TC05 Inter gNB PCI resolution and neighbour relation addition with SRB3
    [Setup]   Test Setup   require_srb_3=${TRUE}
    Inter Gnb Pci Resolution And Neighbour Relation Addition

[1][1.0] TC01 CB009009_A_B1 5GC001296 and 5GC002198 flags enabled
    [Setup]   Test Setup    require_srb_3=${TRUE}    dedicated_DRX_profile=${TRUE}
    TC01 CB009009_A_B1 5GC001296 and 5GC002198 flags enabled

[1][1.0] TC09 CB009009_A_B2 5GC002198 flag enabled with SRB3
    [Setup]   Test Setup    require_srb_3=${TRUE}    dedicated_DRX_profile=${TRUE}
    TC09 CB009009_A_B2 5GC002198 flag enabled with SRB3
