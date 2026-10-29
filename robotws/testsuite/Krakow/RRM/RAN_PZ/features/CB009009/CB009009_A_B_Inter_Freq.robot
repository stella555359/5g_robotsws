*** Settings ***
Documentation
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com
...    description: Original Marcin Bednarski's Test Suite adaptated for the sake of CB009009 testing in KRK

Library     taf.rfrl.bts.commissioning
Library     ../../regression/KRK4/resources/EnbOperations.py    WITH NAME    enb
Library     ../../regression/KRK4/resources/GnbPower.py   WITH NAME    gnb_power
Library     taf.rfrl.bts.devices.du.cell_operations.EnbCellOperations    WITH NAME      enbcell
Resource    ../FR5GC002198/resources/wro/test_specific_keywords.robot

Test Timeout    24 hours
Suite Setup     Run Keywords
...             enb.Power On eNB
...             AND  gnb_power.power_on_gnb  bts_id=${1}
...             AND  Perform Full Commissioning On Classical Enb
...             AND  enbcell.wait_for_all_cells_to_be_onair    timeout=${600}
...             AND  enb.Set NR DC Carrier Frequency    frequency=2058139
...             AND  Perform Full Commissioning on Classical gNB  bts_id=${1}  # Slave gNB commissioning
...             AND  gnbcell.wait_for_all_cells_to_be_onair  bts_id=${1}  timeout=${600}
...             AND  gnbbbu.upload_swconfig    sw_config_path=${CURDIR}/resources/swconfig.txt
...             AND  Common Suite Setup With Commissioning   prefix_tag=CB009009_InterFreq  # Master gNB commissioning
...             AND  Get Global Cell Id Ue Attaches To
...             AND  Get Highest Priority Anr Profile From Scf  freq_type=InterFreq
Suite Teardown  Common Suite Teardown

*** Test Cases ***
TC07 CB009009_A_B2 5GC002198 flag enabled without SRB3 with MeNB coord
    [Setup]   Test Setup   require_srb_3=${FALSE}
    Inter Gnb Pci Resolution And Neighbour Relation Addition
    Verify Anr Profile  profile_name=${anr_profile}  syslog_path=${current_syslog_path}
    [Teardown]   Test Teardown

TC09 CB009009_A_B2 5GC002198 flag enabled with SRB3
    [Setup]   Test Setup   require_srb_3=${TRUE}   max_ho_rerun=10
    Inter Gnb Pci Resolution And Neighbour Relation Addition
    Verify Anr Profile  profile_name=${anr_profile}  syslog_path=${current_syslog_path}
    [Teardown]   Test Teardown

5GC002198_A_B7_TC09 Meas Gap Release and DRX Setup in UE to allow inter-freq NR-CGI measurement reporting
    [Setup]   Test Setup   require_srb_3=${FALSE}
    Measure Gap Release And DRX Setup In UE To Allow Inter Frequency NR-CGI Measurement Reporting
    Verify Anr Profile  profile_name=${anr_profile}  syslog_path=${current_syslog_path}
    [Teardown]   Test Teardown

5GC002198_A_B2_TC06 Inter gNB PCI resolution and neighbour relation addition with MaxNumNrNrrelMoiAllowed
    [Setup]    Run Keywords
    ...        Append To List    ${additional_allowed_alarms}
    ...        Overload detected: Max number of neighbor relation objects added via ANR reached
    ...        AND    Test Setup   require_anr_moi_allowed=${TRUE}   max_ho_rerun=10
    Inter Gnb Pci Resolution And Neighbour Relation Addition With MaxNumNrNrrelMoiAllowed
    [Teardown]   Test Teardown

TC12_CB009009_B4_5GC002198_flag_enabled_-_Disable_UL_proactive_grant_scheduling
    [Setup]   Test Setup   require_srb_3=${FALSE}
    Set Ul Proactive Grant Parameters
    Inter Gnb Pci Resolution And Neighbour Relation Addition  check_ul_proactive_grant=${TRUE}
    Verify Anr Profile  profile_name=${anr_profile}  syslog_path=${current_syslog_path}
    [Teardown]   Test Teardown With Disabled UL Proactive Grant Scheduling
