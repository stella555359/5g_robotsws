*** Settings ***
Documentation
...    author: Jakub Kupiec, Marcin Szlapa
...    contact: jakub.kupiec@nokia.com, marcin.szlapa@nokia.com
...    Description: Test Cases 5GC001250-JA--5GC000269_Linux_Hardening_on_RAU&RAC

Resource    testsuite/Krakow/resources/RAN_PZ_KRK4/linux_hardening/hardening_keywords.robot
Resource    testsuite/Krakow/resources/RAN_PZ_KRK4/linux_hardening/LinuxHardening.robot
Resource    testsuite/Krakow/resources/RAN_PZ_KRK4/linux_hardening/connections.robot
Resource    taf/rfrl/bts/robot/logs_collecting.robot

Force Tags    STATE_GNB_NOT_COMMISSIONED    CLOUD_5G_ASOD_AEUD_ENB
...           CRT__WITH__RAN_5G_TDD__WITH__master_pDU
...           CRT__WITH__RAN_5G_TDD__WITH__21B_pDU

Suite Setup      Preconditions
Suite Teardown   Postconditions_DU_CU
Test Setup       Run Keyword And Ignore Error     Collect logs during test
Test Teardown    Run Keyword And Ignore Error     Collect logs after test finished

*** Test Cases ***
[1][1.0] 5GC001250-JA-5GC000269_097_DU_CCS_API
    DU_CCS_API

[1][1.0] 5GC001250-JA-5GC000269_098_DU_Process_with_lower_privilages
    DU_Process_with_lower_privileges

[1][1.0] 5GC001250-JA-5GC000269_099_DU_Process_user_accounts_ntpd
    DU_Process_user_accounts_ntpd

[1][1.0] 5GC001250-JA-5GC000269_100_DU_Crypto_Agent_Encrypted_File_System
    DU_Crypto_Agent_Encrypted_File_System

[1][1.0] 5GC001250-JA-5GC000269_101_DU_Crypto_Agent_Private_Keys
    DU_Crypto_Agent_Private_Keys

[1][1.0] 5GC001250-JA-5GC000269_102_DU_Crypto_Agent_Private_Keys_B
    DU_Crypto_Agent_Private_Keys_B

[1][1.0] 5GC001250-JA-5GC000269_103_DU_Crypto_Agent_certificates_protection
    DU_Crypto_Agent_certificates_protected

[1][1.0] 5GC001250-JA-5GC000269_104_DU_File_Permission_Rules_passwd
    DU_File_Permission_Rules_passwd

[1][1.0] 5GC001250-JA-5GC000269_105_DU_Orphaned_Files
    DU_Orphaned_Files

[1][1.0] 5GC001250-JA-5GC000269_106_DU_PATH_Environment_Variable
    DU_PATH_Environment_Variable

[1][1.0] 5GC001250-JA-5GC000269_107_DU_Root_Writable_Files
    DU_Root_Writeable_Files

[1][1.0] 5GC001250-JA-5GC000269_108_DU_System_Executables_SUID_&_SGID
    DU_System_Executables_SUID_SGID

[1][1.0] 5GC001250-JA-5GC000269_109_DU_Temporary_Accounts
    DU_Temporary_Accounts

[1][1.0] 5GC001250-JA-5GC000269_110_DU_Unauthorizes_World-Writable_Files
    DU_Unauthorized_World-Writeable_Directories

[1][1.0] 5GC001250-JA-5GC000269_111_DU_Unused_Linux_Accounts
    DU_Unused_Linux_Accounts

[1][1.0] 5GC001250-JA-5GC000269_112_DU_World-Writable_Directories
    DU_World-Writeable_Directories

[1][1.0] 5GC001250-JA-5GC000269_203_DU_File_Permission_Rules_group
	DU_File_Permission_Rules_group

[1][1.0] 5GC001250-JA-5GC000269_204_DU_File_Permission_Rules_shadow
	DU_File_Permission_Rules_shadow

[1][1.0] 5GC001250-JA-5GC000269_205_DU_File_Permission_Rules_fstab
	DU_File_Permission_Rules_fstab

[1][1.0] 5GC001250-JA-5GC000269_206_DU_File_Permission_Rules_hosts
	DU_File_Permission_Rules_hosts

[1][1.0] 5GC001250-JA-5GC000269_208_DU_File_Permission_Rules_services
	DU_File_Permission_Rules_services
