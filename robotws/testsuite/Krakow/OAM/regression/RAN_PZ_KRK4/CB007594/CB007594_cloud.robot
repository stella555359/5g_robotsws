*** Settings ***
Documentation
...    author: Wang Cuicui
...    contact: cuicui.wang@nokia-sbell.com
...    Feature: CB007594 Offline Mode ASIR WebEM - phase 2

Library    DateTime
Library    Collections
Library    resources/CB007594.py
Library    ../../../../resources/NJ_Resources/Resources/python/DevNJ_OfflineMode_ASIR_Selenium.py  virtual_enable=${False}   WITH NAME    OFF_ASIR
Resource   ../../../../resources/NJ_Resources/Resources/robot/DevNJ_5GOAM_keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource   ../../../../resources/NJ_Resources/Resources/robot/DevNJ_sbts_setup.robot
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags  5G_SC        5G_SC_CRT
...         CLOUD_5G_CLASSICAL_ASIR_ASIKR_ABILB4_ASIAL_ABIAB1_APHA_2xAHFHIA_RFS_FDD
...         21ab1_classicalbts      master_classicalbts_all
...         SBTS22R2    SBTS00
...         5G_SC    CRT    STATE_SW_UPLOADED    RAN_5GSC

#Suite Setup    Common Suite Setup for CB007594
#Suite Teardown    Common Suite Teardown For CB007594
Suite Setup         Common Suite Setup for CB007594
Suite Teardown      Common Suite Teardown For CB007594
Test Teardown       Common Postconditions
Test Setup          Common Preconditions


*** Variables ***
@{additional_allowed_alarms}  CRL Update Failure
${target_file_name_5G} =    ${OUTPUT DIR}/5G_snapshot.zip
${target_file_name_4G} =    ${OUTPUT DIR}/4G_snapshot.zip
${hub_mod_id} =  1
${ant_port_id} =  1
${ant_port_id1} =  2
${profile_id} =  1
${cell_id} =  1
${bts_id} =  1
${band_of_pRRH} =  ARHQD (Band 78)
${prrh_type2} =  AWHQJ
${cell_type} =   BTS
${type_id} =  1
${cell_identifier}=  1
${local_cell_identifier}=  1
${oam_ip}=  ${tl.enbs[0].oam_ip.v4}

*** Test Cases ***

[1]CB007594_A_TC023_Offline_ASiR_Webem_Edit_Configuration_Cell_From_snapshot_5G
    Run keyword And Ignore Error  OFF_ASIR.logout  online_mode=${False}
    sleep   5s
    Offline Login  url=file://${OUTPUT DIR}/index.html
    OFF_ASIR.Load Snapshot  snapshot_path=${target_file_name_5G}
    OFF_ASIR.Enter Config Man  sub_menu=edit_offline
    ${ant_port_list}  create list  ${ant_port_id}-1     ${ant_port_id1}-1
    OFF_ASIR.modify profile  profile_id=${profile_id}  profile_label=hub${hub_mod_id}-${ant_port_id}
    ...                      prrh_type=${prrh_type2}  ant_port_list=${ant_port_list}
    OFF_ASIR.populate cell mapping info  bts_id=${bts_id}  cell_id=${cell_id}  profile_id=${profile_id}
    ...                                  band_class=${band_of_pRRH}  antl1=ANTL1  antl2=ANTL2
    ${result}=  OFF_ASIR.prevalidate
    log to console  ${result}
    Should Be Equal As Strings  first=&{result}[ret]  second=${True}
    OFF_ASIR.delete profile  profile_id=${profile_id}
    ${new_profile_id}  OFF_ASIR.create profile  hub_mod_id=${hub_mod_id}  profile_label=hub${hub_mod_id}-${ant_port_id}
    ...                                         prrh_type=${prrh_type2}  ant_port_list=${ant_port_list}
    OFF_ASIR.populate cell mapping info  bts_id=${bts_id}  cell_id=${cell_id}  profile_id=${new_profile_id}
    ...                                  band_class=${band_of_pRRH}  antl1=ANTL1  antl2=ANTL2
    OFF_ASIR.Delete Cell Manually    cell_type=${cell_type}    cell_id=${cell_id}  type_id=${type_id}
    OFF_ASIR.create_cell_manually      cell_type=${cell_type}  type_id=${type_id}
    ${para_dict}  Create Dictionary  Cell technology=TDD
    ...                              AirScale local cell identifier=${local_cell_identifier}
    ...                              AirScale cell identifier=${cell_identifier}
    OFF_ASIR.populate_cell_details   cell_type=${cell_type}  type_id=${type_id}   cell_id=${cell_id}
    ...                          para_dict=${para_dict}
    ${chan_dict}  Create Dictionary    1=TXRX    2=TXRX    3=TX    4=TX
    OFF_ASIR.populate_radio_antenna_mapping      cell_type=${cell_type}    cell_id=${cell_id}  type_id=${type_id}
    ...                           hubmod_id=${hub_mod_id}    chan_dict=${chan_dict}
    OFF_ASIR.populate cell mapping info  bts_id=${bts_id}  cell_id=${cell_id}  profile_id=${new_profile_id}
    ...                                  band_class=${band_of_pRRH}  antl1=ANTL1  antl2=ANTL2
    ${result}=  OFF_ASIR.prevalidate
    Should Be Equal As Strings  first=&{result}[ret]  second=${True}
    ${result}=   OFF_ASIR.prevalidate_in_tab
    Should Be Equal As Strings  first=&{result}[ret]  second=${True}
#    ${result}=   OFF_ASIR.save_scf_in_tab
    Append To List    ${to_remove_list}     ${result}
    log to console  ${result}


*** Keywords ***
Common Suite Setup for CB007594
    [Documentation]  This keyword used to perform *suite setup* for feature *CB007594*
    ...
    ...    Main Steps:
    ...    - 1. Common Suite setup
    ...    - 2. Download offline mode ASIR WebEM tool and grant it with execution permission
    ...    - 3. Save 5G and 4G snapshot that used in cases
    ...    - 4. Initialize offline ASIR WebEM tool
    ...
    ...    Arguments:
    ...    - None
    ...
    ...    Return value:
    ...    - None
    ...
    ...    Examples:
    ...    | Common Suite Setup for CB007594 |
    ...
    ...    Version:
    ...    | author | Version | Delivery Date | Comments |
    ...    | Wang Cuicui | 1.0.0 | 2022/1/11 | First approved version by VA |

    gnbbbu.Upload swconfig  commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
    Common Suite Setup With Commissioning    asir_hub=${True}

    ${expected_status}  Create Dictionary  availabilityStatus=Online
    Wait Until Keyword Succeeds  15 min  30s  Check Sbts Cell Status  expected_status_dict=${expected_status}

    ${delete_list}    Download Offline Asir Webem From Local Server  load_build=${ENB_BUILD}
     ...               dest_dir=${OUTPUT DIR}
    Log To Console  \n=====Start: Save 5G Snapshot=====
    ${ret}  Collect Sbts Snapshot  target_file_name=${target_file_name_5G}  timeout=1200
    Log To Console  \n=====End: Save 5G Snapshot=====
    Append To List   ${delete_list}    ${target_file_name_5G}
    Set Suite Variable     ${to_remove_list}    ${delete_list}
    OFF_ASIR.Clean Browser
	Offline Login  url=file://${OUTPUT DIR}/index.html


Common Suite Teardown For CB007594
    [Documentation]  This keyword used to perform *test teardown* for feature *CB007594*
    ...
    ...    Main Steps:
    ...    - 1. Logout offline mode ASIR WebEM tool
    ...    - 2. Remove/Clear offline ASIR WebEM related resources
    ...
    ...    Arguments:
    ...    - None
    ...
    ...    Return value:
    ...    - None
    ...
    ...    Version:
    ...    | Auther | Version | Delivery Date | Comments |
    ...    | Wang Cuicui | 1.0.0 | 2022/1/11 | First approved version by VA |

    Run keyword And Ignore Error  OFF_ASIR.logout  online_mode=${False}
   # Remove Unused Offline Asir Webem Resource  to_remove_list=${to_remove_list}
    #    Common Suite Teardown For Sbts
    Common Suite Teardown

Offline Login
    [Arguments]      ${url}
    Create Chrome Webdriver
    OFF_ASIR.Login  url=${url}  online_mode=${False}  browser=${webdriver}
