*** Settings ***
Documentation
...  author:  Patryk Tatarek
...  contact: patryk.tatarek@nokia.com

Library    ../Resources/SecurityMethods.py
...        192.168.255.129
...        toor4nsn
...        oZPS0POrRieRtu
...        WITH NAME    sec_opr

Resource    ../../../common_resources/admin/admin.robot

*** Keywords ***
[1]5GC001599-G_BTS_stores_default_password_with_SHA512_length_ASIB
    sec_opr.check_local_user_password_hashed_with_sha512
    sec_opr.check_webem_user_password_hashed_with_sha512    Nemuadmin

[1]5GC001599-G_BTS_stores_default_password_with_SHA512_length_ASIL
    sec_opr.check_local_user_password_hashed_with_sha512
    sec_opr.check_webem_user_password_hashed_with_sha512    Nemuadmin

[1]5GC001599-G_BTS_stores_new_password_with_SHA512_length_ASIB
    sec_opr.change_ssh_user_password    serviceuser    !Pasw2@21    Pl(FzaYj5~c5;q
    sec_opr.check_local_user_password_hashed_with_sha512    serviceuser
    sec_opr.change_webem_user_password    Nemuadmin    nemuuser    !Pasw2@21
    sec_opr.check_webem_user_password_hashed_with_sha512    Nemuadmin
    [Teardown]    Run Keywords    sec_opr.remove_users_json_and_reboot
    ...           AND    Wait Until Keyword Succeeds    15min    120sec    Wait until BTS reach Configured or OnAir state
    ...           AND    sec_opr.change_ssh_user_password    serviceuser    Pl(FzaYj5~c5;q    !Pasw2@21
    ...           AND    Reset Site And Reconnect
    ...           AND    Wait Until Keyword Succeeds    15min    120sec    Wait until BTS reach Configured or OnAir state

[1]5GC001599-G_BTS_stores_new_password_with_SHA512_length_ASIL
    sec_opr.change_ssh_user_password    serviceuser    !Pasw2@21    Pl(FzaYj5~c5;q
    sec_opr.check_local_user_password_hashed_with_sha512    serviceuser
    sec_opr.change_webem_user_password    Nemuadmin    nemuuser    !Pasw2@21
    sec_opr.check_webem_user_password_hashed_with_sha512    Nemuadmin
    [Teardown]    Run Keywords    sec_opr.remove_users_json_and_reboot
    ...           AND    Wait Until Keyword Succeeds    15min    120sec    Wait until BTS reach Configured or OnAir state
    ...           AND    sec_opr.change_ssh_user_password    serviceuser    Pl(FzaYj5~c5;q    !Pasw2@21
    ...           AND    Reset Site And Reconnect
    ...           AND    Wait Until Keyword Succeeds    15min    120sec    Wait until BTS reach Configured or OnAir state

[1]5GC001599-G_CC&S_AaShell_Hardening_Part 1_ASIB
    sec_opr.check_path_traversal_disabled_in_aashell

[1]5GC001599-G_CC&S_AaShell_Hardening_Part 2_ASIL
    sec_opr.check_path_traversal_disabled_in_aashell

[1]5GC001599-G_CC&S_AaShell_Hardening_Part 1_ASIL
    sec_opr.check_aashell_binds_to_localhost_only
    sec_opr.check_aashell_available_for_serviceuser

[1]5GC001599-G_CC&S_AaShell_Hardening_Part 2_ASIB
    sec_opr.check_aashell_binds_to_localhost_only
    sec_opr.check_aashell_available_for_serviceuser

[1]5GC001599-G_NFS_share_export_restricted_to_internal_IPv4_network_ASIB
    sec_opr.check_nfs_restricted_to_internal_network_v4

[1]5GC001599-G_NFS_share_export_restricted_to_internal_IPv4_network_ASIL
    sec_opr.check_nfs_restricted_to_internal_network_v4

[1]5GC001599-G_NFS_share_export_restricted_to_internal_IPv6_network_ASIB
    sec_opr.check_nfs_restricted_to_internal_network_v6

[1]5GC001599-G_NFS_share_export_restricted_to_internal_IPv6_network_ASIL
    sec_opr.check_nfs_restricted_to_internal_network_v6

[1]5GC001599-G_Sensitive_data_is_not_world_readable_ASIB
    sec_opr.check_sensitive_files_world_readeable_on_smod
    sec_opr.check_sensitive_files_world_readeable_on_bbmod

[1]5GC001599-G_Sensitive_data_is_not_world_readable_ASIL
    sec_opr.check_sensitive_files_world_readeable_on_smod
    sec_opr.check_sensitive_files_world_readeable_on_bbmod

[1]5GC001599-G_Check_Service_Binding_on_gBN_ASIB
    sec_opr.check_service_binding

[1]5GC001599-G_Check_Service_Binding_on_gBN_ASIL
    sec_opr.check_service_binding
