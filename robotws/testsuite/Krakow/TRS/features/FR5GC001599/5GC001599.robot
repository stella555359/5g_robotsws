*** Settings ***
Documentation
...    author: Marcin Szlapa, Jakub Kupiec
...    contact: marcin.szlapa@nokia.com, jakub.kupiec@nokia.com
...    Description: Test Cases 5GC001599

Library    testsuite.Krakow.TRS.features.FR5GC001599.resources.cu_keywords.CuKeywords
Library    testsuite.Krakow.resources.cu_webem.cu_webem_keywords.CuWebem
Resource   testsuite/Krakow/resources/throughput_ota_aeub_regression.robot
Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource   taf/rfrl/bts/robot/logs_collecting.robot
Variables  taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags    STATE_GNB_NOT_COMMISSIONED    CLOUD_5G_ASIKL_ABILB1_AEUD_ENB
...           CRT__WITH__RAN_5G_TDD_MP

Suite Setup       Common Suite Setup With Commissioning    prefix_tag=MPLANE
Suite Teardown    Common Suite Teardown
Test Setup        Common Preconditions
Test Teardown     Common Postconditions

*** Variables ***
@{additional_allowed_alarms} =  Automatic BTS Operator Certificate retrieval unsuccessful

*** Test Cases ***
5GC001599_A_01_VM-CU File permission and mask
    [Tags]  pDU22R2
    Run keyword and continue on failure
    ...  verify_unauthorized_world_writeable_files_are_not_present_on_the_system
    Run keyword and continue on failure
    ...  verify_files_owned_by_root_are_not_writeable_for_other_user_or_group
    Run keyword and continue on failure
    ...  verify_orphaned_files_with_unknown_user_or_group_id_are_not_present_on_the_system
    Run keyword and continue on failure
    ...  verify_system_executables_with_user_id_or_group_id_attributes_set_are_not_present_on_the_system
    verify_world_writable_directories_are_not_present_on_the_system

5GC001599_A_02_VM-CU External file mount restrictions
    check_mount_options_in_fstab
    verify_robot_user_is_not_allowed_to_mount_filesystems

5GC001599_A_03_VM-CU Web server hardening
    [Tags]  pDU22R2
    verify_web_server_runs_in_chroot_jail
    verify_permissions_of_web_server_config_files
    verify_permissions_of_web_server_content_served_files

5GC001599_A_04_VM-CU IP packet forwarding IPv4
    verify_ip_forwarding_is_enabled_only_on_loopback_interface  ipv4

5GC001599_A_05_VM-CU IP packet forwarding IPv6
    verify_ip_forwarding_is_enabled_only_on_loopback_interface  ipv6

5GC001599_A_06_VM-CU Proxy ARP disable
    verify_proxy_arp_is_disabled_on_all_interface

5GC001599_A_07_VM-CU Broadcast ICMP ignored
    verify_broadcast_icmp_is_ignored_on_cu

5GC001599_A_08_VM-CU Multicast limited
    verify_that_multicast_is_not_set_for_external_interfaces

5GC001599_A_09_VM-CU Gratuitous ARP disable
    [Tags]  pDU22R2
    verify_value_of_drop_gratuitous_arp

5GC001599_G_10_VM-CU Services should not bind to all interfaces
    verify_services_do_not_bind_to_all_interfaces

5GC001599_G_12_VM-CU AaShell hardening
    verify_aashell_binds_to_loopback_address_only

5GC001599_G_11_VM-CU SHA512 hashes for passwords
    verify_default_password_hash
    change_local_and_service_users_passwords
    verify_default_password_hash
