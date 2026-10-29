*** Settings ***
Documentation
...    authors: Rafal Kawa, Marcin Bednarski
...    contact: rafal.kawa@nokia.com, marcin.bednarski@nokia.com
...    description: Original Marcin Bednarski's Test Suite adaptated by Rafal Kawa for the sake of FR2 testing in KRK

Library     taf.rfrl.bts.commissioning
Library     ../../regression/KRK4/resources/EnbOperations.py    WITH NAME    enb
Library     ../../regression/KRK4/resources/GnbPower.py   WITH NAME    gnb_power
Library     taf.rfrl.bts.devices.du.cell_operations.EnbCellOperations    WITH NAME      enbcell
Library     ./resources/wro/test_specific_keywords.py
Resource    ./resources/wro/test_specific_keywords.robot

Test Timeout    24 hours
Suite Setup     Run Keywords
...             enb.Power On eNB
...             AND    gnb_power.power_on_gnb  bts_id=${1}
...             AND    Perform Full Commissioning On Classical Enb
...             AND    enbcell.wait_for_all_cells_to_be_onair    timeout=${600}
...             AND    enb.Set NR DC Carrier Frequency    frequency=2058139
...             AND    Perform Full Commissioning on Classical gNB  bts_id=${1}  # Slave gNB commissioning
...             AND    gnbcell.wait_for_all_cells_to_be_onair  bts_id=${1}  timeout=${600}
...             AND    gnbbbu.upload_swconfig    sw_config_path=${CURDIR}/resources/swconfig.txt
...             AND    Common Suite Setup With Commissioning  # Master gNB commissioning
...             AND    Get Global Cell Id Ue Attaches To
Suite Teardown  Common Suite Teardown
Test Teardown   Test Teardown

*** Test Cases ***
5GC002198_A_B2_TC04 Inter gNB PCI resolution and neighbour relation addition without SRB3
    [Setup]   Test Setup   require_srb_3=${FALSE}
    Inter Gnb Pci Resolution And Neighbour Relation Addition

5GC002198_A_B2_TC05 Inter gNB PCI resolution and neighbour relation addition with SRB3
    [Setup]   Test Setup   require_srb_3=${TRUE}   max_ho_rerun=10
    Inter Gnb Pci Resolution And Neighbour Relation Addition

5GC002198_A_B7_TC09 Meas Gap Release and DRX Setup in UE to allow inter-freq NR-CGI measurement reporting
    [Setup]   Test Setup   require_srb_3=${FALSE}
    Measure Gap Release And DRX Setup In UE To Allow Inter Frequency NR-CGI Measurement Reporting

5GC002198_A_B2_TC06 Inter gNB PCI resolution and neighbour relation addition with MaxNumNrNrrelMoiAllowed
    [Setup]    Run Keywords
    ...        Append To List    ${additional_allowed_alarms}
    ...        Overload detected: Max number of neighbor relation objects added via ANR reached
    ...        AND    Test Setup   require_anr_moi_allowed=${TRUE}   max_ho_rerun=10
    Inter Gnb Pci Resolution And Neighbour Relation Addition With MaxNumNrNrrelMoiAllowed

5GC002198_B_B5_TC18 Online modification disable flag actAutoNrNbRemoval
    [Setup]   Test Setup   require_srb_3=${FALSE}   require_ue=${FALSE}   require_reset=${TRUE}
    Modification Disable Flag ActAutoNrNbRemoval

5GC002198_B_B1_TC13 Automatic Neighbour Removal Procedure - twice idleTime modification
    [Setup]   Test Setup   require_srb_3=${FALSE}   require_ue=${FALSE}   require_reset=${TRUE}
    Automatic Neighbour Removal Procedure Twice IdleTime Modification
