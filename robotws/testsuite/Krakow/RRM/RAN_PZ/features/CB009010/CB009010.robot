*** Settings ***
Documentation
...    author: Sara Nowak
...    contact: sara.nowak@nokia.com
...    description: Original Rafal Kawa's Test Suite adaptated for the sake of CB009010 testing in KRK

Library     taf.rfrl.bts.commissioning
Library     ../../regression/KRK4/resources/EnbOperations.py
Library     ../../regression/KRK4/resources/GnbPower.py   WITH NAME    gnb_power
Resource    taf/rfrl/bts/robot/common/enb_cell.robot
Resource    ../FR5GC002198/resources/wro/test_specific_keywords.robot
Resource    resources/suite_specific_keywords.robot

Test Timeout    24 hours
Suite Setup     Run Keywords
...             Power On eNB
...             AND  gnb_power.power_on_gnb  bts_id=${1}
...             AND  Perform Full Commissioning On Classical Enb    bts_id=0    prefix_tag=CB009010
...             AND  Wait Until Keyword Succeeds    12min    15s    Verify eNB Cell is onAir    cell_id=0
...             AND  Set NR DC Carrier Frequency    frequency=2058139
...             AND  Perform Full Commissioning on Classical gNB  bts_id=${1}  prefix_tag=CB009010  # Slave gNB commissioning
...             AND  gnb_cells.wait_for_all_cells_to_be_onair  bts_id=${1}  timeout=${600}
...             AND  gnbbbu.upload_swconfig    sw_config_path=${CURDIR}/resources/swconfig.txt
...             AND  Common Suite Setup With Commissioning   prefix_tag=CB009010_InterFreq  # Master gNB commissioning
...             AND  Get Global Cell Id Ue Attaches To
...             AND  Get Highest Priority Anr Profile From Scf  freq_type=InterFreq
Suite Teardown  Run Keywords
...             Perform Full Commissioning On Classical Enb    bts_id=0
...             AND  Wait Until Keyword Succeeds    12min    15s    enbcell.Verify Setup Of All Cells    bts_id=0    du_id=0
...             AND  Common Suite Teardown

*** Test Cases ***
CB009010_01_NSA_FR2_Inter_freq_inter_gnb_HO_with_ANR_succesfully_with_hoForPlmnResForOpUseEnabled_true
    [Setup]   Test Setup CB009010  require_srb_3=${FALSE}
    Inter Gnb Pci Resolution And Neighbour Relation Addition
    Verify Anr Profile  profile_name=${anr_profile}  syslog_path=${current_syslog_path}
    Check ADJ_NRPLMNSET_NSA Object Exist With Correctly Set Parameters
    [Teardown]   Test Teardown CB009010
