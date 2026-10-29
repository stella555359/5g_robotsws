*** Settings ***
Library  String
Library  taf.sbts.oam.coam.admin  WITH NAME  admin
Library  taf.rfrl.bts.devices.du.du_operations.GnbDuOperations  WITH NAME  gnbbbu
Library  taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations  WITH NAME  gnbcell

Resource  taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup  Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
...                                                               should_5G_neighbour_be_changed=${False}
...          increase_time_for_checking_bbmod=600
...          increase_timeout_for_update_sw=1800
...          increase_time_for_checking_radios=2100
...          increase_time_for_checking_cells=700
...          swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown  Common Suite Teardown

Test Setup  Common Preconditions With Watching Alarms
Test Teardown  Common Postconditions With Watching Alarms

*** Test Cases ***
CNI-106731_#2_n2_sub-band_of_n25_requiring_25MHz_NR_carrier_support_for_AHFIB_AHFIG_AHFII
    ${mplane_addr}=  Remove String  ${tl.gnbs[0].dus[0].oam_ip.v4}  /23
    admin.connect_to  bts_host=${mplane_addr}
    ${scf_file}=  Set Variable
    ...           ${EXECDIR}/commissionings/Krakow/7_7_UTE5GCLOUDT1SK129/${ENB_BRANCH}/SCF_main_gnb.xml
    admin.perform_commissioning  scf_file=${scf_file}
    ...                          timeout=${300}
    gnbbbu.wait_for_site_to_be_onair  interval=${11}
    gnbcell.wait_for_all_cells_to_be_onair  cell_type=nr
    ...                                     expected_cell_amount=${1}
    [Teardown]  admin.Teardown
