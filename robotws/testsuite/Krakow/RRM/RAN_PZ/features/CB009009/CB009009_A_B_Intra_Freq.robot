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
...             AND  enb.Set NR DC Carrier Frequency    frequency=2071387
...             AND  Perform Full Commissioning on Classical gNB  bts_id=${1}  # Slave gNB commissioning
...             AND  gnbcell.wait_for_all_cells_to_be_onair  bts_id=${1}  timeout=${600}
...             AND  gnbbbu.upload_swconfig    sw_config_path=${CURDIR}/resources/swconfig.txt
...             AND  Common Suite Setup With Commissioning   prefix_tag=CB009009_IntraFreq  # Master gNB commissioning
...             AND  Get Global Cell Id Ue Attaches To
...             AND  Get Highest Priority Anr Profile From Scf  freq_type=IntraFreq
Suite Teardown  Common Suite Teardown

*** Test Cases ***
TC04_CB009009_A_B2_5GC001296_flag_enabled_without_SRB3
    [Setup]   Test Setup   require_srb_3=${FALSE}
    Inter Gnb Pci Resolution And Neighbour Relation Addition  FreqType=IntraFreq
    Verify Anr Profile  profile_name=${anr_profile}  syslog_path=${current_syslog_path}
    Verify Drx Config Release  pcap=${pcap_path}
    [Teardown]   Test Teardown

TC05_CB009009_A_B2_5GC001296_flag_enabled_with_SRB3
    [Setup]   Test Setup   require_srb_3=${TRUE}   max_ho_rerun=10
    Inter Gnb Pci Resolution And Neighbour Relation Addition  FreqType=IntraFreq
    Verify Anr Profile  profile_name=${anr_profile}  syslog_path=${current_syslog_path}
    Verify Drx Config Release  pcap=${pcap_path}
    [Teardown]   Test Teardown

5GC002198_A_B2_TC06 Inter gNB PCI resolution and neighbour relation addition with MaxNumNrNrrelMoiAllowed
    [Setup]    Run Keywords
    ...        Append To List    ${additional_allowed_alarms}
    ...        Overload detected: Max number of neighbor relation objects added via ANR reached
    ...        AND    Test Setup   require_anr_moi_allowed=${TRUE}   max_ho_rerun=10
    Perform Inter Gnb Handover From Gnb Cell 1 To Gnb2 Cell 2
    Repeat Keyword     10 times    Check Nrrel And Nradjrnrcell Objects Not Exist  nrrel_id=NRREL-256
    Confirm Srb3    syslog_path=${current_syslog_path}   require_srb3=${require_srb_3}
    Verify Nrcgi Report Not Received    syslog_path=${current_syslog_path}
    [Teardown]   Test Teardown

TC11_CB009009_B3_5GC001296_flag_enabled_-_Disable_UL_proactive_grant_scheduling
    [Setup]   Test Setup   require_srb_3=${FALSE}
    Set Ul Proactive Grant Parameters
    Inter Gnb Pci Resolution And Neighbour Relation Addition  FreqType=IntraFreq  check_ul_proactive_grant=${TRUE}
    Verify Anr Profile  profile_name=${anr_profile}  syslog_path=${current_syslog_path}
    Verify Drx Config Release  pcap=${pcap_path}
    [Teardown]   Test Teardown With Disabled UL Proactive Grant Scheduling
