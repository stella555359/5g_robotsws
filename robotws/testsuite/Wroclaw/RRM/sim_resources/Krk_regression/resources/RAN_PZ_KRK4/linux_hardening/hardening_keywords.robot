*** Settings ***

Library   testsuite.Wroclaw.RRM.sim_resources.Krk_regression.resources.RAN_PZ_KRK4.linux_hardening.linux_hardening_keywords.LinuxHardening
...    WITH NAME   linuxhardening
Library  testsuite.Wroclaw.RRM.sim_resources.Krk_regression.resources.cu_webem.cu_webem_keywords.CuWebem    WITH NAME    cu

*** Keywords ***
DU_perform_commissioning
    linuxhardening.perform_du_commissioning    path_to_scf=${CURDIR}/../../../../../commissionings/Krakow/7_7_UTE5GCLOUDT143/DU_SCF.xml

CU_perform_commissioning
    cu.perform_cu_commissioning    path_to_scf=${CURDIR}/../../../../../commissionings/Krakow/7_7_UTE5GCLOUDT143/CU_SCF.xml

CU_Path_Environment_Variable_OAM
	linuxhardening.cu_path_environment_variable      vm_tag=OAM

CU_Path_Environment_Variable_CPCL
	linuxhardening.cu_path_environment_variable      vm_tag=CPCL

CU_Path_Environment_Variable_CPIF
	linuxhardening.cu_path_environment_variable      vm_tag=CPIF

CU_Path_Environment_Variable_CPNB
	linuxhardening.cu_path_environment_variable      vm_tag=CPNB

CU_Path_Environment_Variable_CPUE
	linuxhardening.cu_path_environment_variable      vm_tag=CPUE

CU_Path_Environment_Variable_UPUE
	linuxhardening.cu_path_environment_variable      vm_tag=UPUE

CU_Path_Environment_Variable_CPNRT
	linuxhardening.cu_path_environment_variable      vm_tag=CPNRT

CU_Path_Environment_Variable_DB
	linuxhardening.cu_path_environment_variable      vm_tag=DB

CU_Process_user_accounts_dhcpd_OAM
	linuxhardening.cu_process_user_accounts          vm_tag=OAM      not_allowed_process=dhcpd

CU_Process_user_accounts_dhcpd_CPCL
	linuxhardening.cu_process_user_accounts          vm_tag=CPCL      not_allowed_process=dhcpd

CU_Process_user_accounts_dhcpd_CPIF
	linuxhardening.cu_process_user_accounts          vm_tag=CPIF      not_allowed_process=dhcpd

CU_Process_user_accounts_dhcpd_CPNB
	linuxhardening.cu_process_user_accounts          vm_tag=CPNB      not_allowed_process=dhcpd

CU_Process_user_accounts_dhcpd_CPUE
	linuxhardening.cu_process_user_accounts          vm_tag=CPUE      not_allowed_process=dhcpd

CU_Process_user_accounts_dhcpd_UPUE
	linuxhardening.cu_process_user_accounts          vm_tag=UPUE      not_allowed_process=dhcpd

CU_Process_user_accounts_dhcpd_CPNRT
	linuxhardening.cu_process_user_accounts          vm_tag=CPNRT      not_allowed_process=dhcpd

CU_Process_user_accounts_dhcpd_DB
	linuxhardening.cu_process_user_accounts          vm_tag=DB      not_allowed_process=dhcpd

CU_Root_Writeable_Files_A_OAM
	linuxhardening.cu_root_writeable_files_a               vm_tag=OAM

CU_Root_Writeable_Files_A_CPCL
	linuxhardening.cu_root_writeable_files_a               vm_tag=CPCL

CU_Root_Writeable_Files_A_CPIF
	linuxhardening.cu_root_writeable_files_a               vm_tag=CPIF

CU_Root_Writeable_Files_A_CPNB
	linuxhardening.cu_root_writeable_files_a               vm_tag=CPNB

CU_Root_Writeable_Files_A_CPUE
	linuxhardening.cu_root_writeable_files_a               vm_tag=CPUE

CU_Root_Writeable_Files_A_UPUE
	linuxhardening.cu_root_writeable_files_a               vm_tag=UPUE

CU_Root_Writeable_Files_A_CPNRT
	linuxhardening.cu_root_writeable_files_a               vm_tag=CPNRT

CU_Root_Writeable_Files_A_DB
	linuxhardening.cu_root_writeable_files_a               vm_tag=DB

CU_System_Executables_SUID_SGID_OAM
	linuxhardening.cu_system_executables_suid_sgid             vm_tag=OAM

CU_System_Executables_SUID_SGID_CPCL
	linuxhardening.cu_system_executables_suid_sgid             vm_tag=CPCL

CU_services_and_processes_OAM
	linuxhardening.cu_services_and_processes         vm_tag=OAM

CU_System_Executables_SUID_SGID_CPIF
	linuxhardening.cu_system_executables_suid_sgid             vm_tag=CPIF

CU_services_and_processes_CPCL
	linuxhardening.cu_services_and_processes         vm_tag=CPCL

CU_System_Executables_SUID_SGID_CPNB
	linuxhardening.cu_system_executables_suid_sgid             vm_tag=CPNB

CU_services_and_processes_CPIF
	linuxhardening.cu_services_and_processes         vm_tag=CPIF

CU_System_Executables_SUID_SGID_CPUE
	linuxhardening.cu_system_executables_suid_sgid             vm_tag=CPUE

CU_services_and_processes_CPNB
	linuxhardening.cu_services_and_processes         vm_tag=CPNB

CU_System_Executables_SUID_SGID_UPUE
	linuxhardening.cu_system_executables_suid_sgid             vm_tag=UPUE

CU_services_and_processes_CPUE
	linuxhardening.cu_services_and_processes         vm_tag=CPUE

CU_System_Executables_SUID_SGID_CPNRT
	linuxhardening.cu_system_executables_suid_sgid             vm_tag=CPNRT

CU_services_and_processes_UPUE
	linuxhardening.cu_services_and_processes         vm_tag=UPUE

CU_services_and_processes_CPNRT
	linuxhardening.cu_services_and_processes         vm_tag=CPNRT

CU_System_Executables_SUID_SGID_DB
	linuxhardening.cu_system_executables_suid_sgid             vm_tag=DB

CU_Temporary_accounts_OAM
	linuxhardening.cu_temporary_accounts             vm_tag=OAM

CU_services_and_processes_DB
	linuxhardening.cu_services_and_processes         vm_tag=DB

CU_Temporary_accounts_CPCL
	linuxhardening.cu_temporary_accounts             vm_tag=CPCL

CU_Terminating_External_Interfaces_OAM
	linuxhardening.cu_terminating_external_interface        vm_tag=OAM

CU_Temporary_accounts_CPIF
	linuxhardening.cu_temporary_accounts             vm_tag=CPIF

CU_Terminating_External_Interfaces_CPCL
	linuxhardening.cu_terminating_external_interface         vm_tag=CPCL

CU_Temporary_accounts_CPNB
	linuxhardening.cu_temporary_accounts             vm_tag=CPNB

CU_Terminating_External_Interfaces_CPIF
	linuxhardening.cu_terminating_external_interface         vm_tag=CPIF

CU_Terminating_External_Interfaces_CPNB
	linuxhardening.cu_terminating_external_interface         vm_tag=CPNB

CU_Terminating_External_Interfaces_CPUE
	linuxhardening.cu_terminating_external_interface         vm_tag=CPUE

CU_Terminating_External_Interfaces_UPUE
	linuxhardening.cu_terminating_external_interface         vm_tag=UPUE

CU_Terminating_External_Interfaces_CPNRT
	linuxhardening.cu_terminating_external_interface         vm_tag=CPNRT

CU_Terminating_External_Interfaces_DB
	linuxhardening.cu_terminating_external_interface         vm_tag=DB

CU_Orphaned_Files_OAM
    linuxhardening.cu_orphaned_files       vm_tag=OAM

CU_Orphaned_Files_CPCL
    linuxhardening.cu_orphaned_files       vm_tag=CPCL

CU_Orphaned_Files_CPIF
    linuxhardening.cu_orphaned_files       vm_tag=CPIF

CU_Orphaned_Files_CPNB
    linuxhardening.cu_orphaned_files       vm_tag=CPNB

CU_Orphaned_Files_CPUE
    linuxhardening.cu_orphaned_files       vm_tag=CPUE

CU_Orphaned_Files_UPUE
    linuxhardening.cu_orphaned_files       vm_tag=UPUE

CU_Orphaned_Files_CPNRT
    linuxhardening.cu_orphaned_files       vm_tag=CPNRT

CU_Orphaned_Files_DB
    linuxhardening.cu_orphaned_files       vm_tag=DB

CU_file_permission_rules_passwd_OAM
	linuxhardening.file_permission_rules        vm_tag=DB       files_path=/etc/passwd

CU_file_permission_rules_passwd_CPCL
	linuxhardening.file_permission_rules        vm_tag=DB       files_path=/etc/passwd

CU_file_permission_rules_passwd_CPIF
	linuxhardening.file_permission_rules        vm_tag=DB       files_path=/etc/passwd

CU_file_permission_rules_passwd_CPNB
	linuxhardening.file_permission_rules        vm_tag=DB       files_path=/etc/passwd

CU_file_permission_rules_passwd_CPUE
	linuxhardening.file_permission_rules        vm_tag=DB       files_path=/etc/passwd

CU_file_permission_rules_passwd_UPUE
	linuxhardening.file_permission_rules        vm_tag=DB       files_path=/etc/passwd

CU_file_permission_rules_passwd_CPNRT
	linuxhardening.file_permission_rules        vm_tag=DB       files_path=/etc/passwd

CU_file_permission_rules_passwd_DB
	linuxhardening.file_permission_rules        vm_tag=DB       files_path=/etc/passwd

CU_Temporary_accounts_CPUE
	linuxhardening.cu_temporary_accounts             vm_tag=CPUE

CU_Temporary_accounts_UPUE
	linuxhardening.cu_temporary_accounts             vm_tag=UPUE

CU_Temporary_accounts_CPNRT
	linuxhardening.cu_temporary_accounts             vm_tag=CPNRT

CU_Temporary_accounts_DB
	linuxhardening.cu_temporary_accounts             vm_tag=DB

CU_Unauthorized_World-Writeable_Files_OAM
	linuxhardening.cu_unauthorized_world_writeable_files         vm_tag=OAM

CU_Unauthorized_World-Writeable_Files_CPCL
	linuxhardening.cu_unauthorized_world_writeable_files         vm_tag=CPCL

CU_Unauthorized_World-Writeable_Files_CPIF
	linuxhardening.cu_unauthorized_world_writeable_files         vm_tag=CPIF

CU_Unauthorized_World-Writeable_Files_CPNB
	linuxhardening.cu_unauthorized_world_writeable_files         vm_tag=CPNB

CU_Unauthorized_World-Writeable_Files_CPUE
	linuxhardening.cu_unauthorized_world_writeable_files         vm_tag=CPUE

CU_Unauthorized_World-Writeable_Files_UPUE
	linuxhardening.cu_unauthorized_world_writeable_files         vm_tag=UPUE

CU_Unauthorized_World-Writeable_Files_CPNRT
	linuxhardening.cu_unauthorized_world_writeable_files         vm_tag=CPNRT

CU_Unauthorized_World-Writeable_Files_DB
	linuxhardening.cu_unauthorized_world_writeable_files         vm_tag=DB

CU_Unused_Linux_Accounts_OAM
	linuxhardening.unused_linux_accounts            vm_tag=OAM

CU_Unused_Linux_Accounts_CPCL
	linuxhardening.unused_linux_accounts            vm_tag=CPCL

CU_Unused_Linux_Accounts_CPIF
	linuxhardening.unused_linux_accounts            vm_tag=CPIF

CU_Unused_Linux_Accounts_CPNB
	linuxhardening.unused_linux_accounts            vm_tag=CPNB

CU_Unused_Linux_Accounts_CPUE
	linuxhardening.unused_linux_accounts            vm_tag=CPUE

CU_Unused_Linux_Accounts_UPUE
	linuxhardening.unused_linux_accounts            vm_tag=UPUE

CU_Unused_Linux_Accounts_CPNRT
	linuxhardening.unused_linux_accounts            vm_tag=CPNRT

CU_Unused_Linux_Accounts_DB
	linuxhardening.unused_linux_accounts            vm_tag=DB

DU_Unused_Linux_Accounts
    linuxhardening.unused_linux_accounts          vm_tag=FCT

DU_CCS_API
    linuxhardening.find_user_on_bb1      vm_tag=FCT

DU_Crypto_Agent_Encrypted_File_System
    linuxhardening.du_crypto_agent_encrypted_file_system      vm_tag=FCT

CU_World-Writable_Directories_OAM
	linuxhardening.cu_world_writable_directories         vm_tag=OAM

CU_World-Writable_Directories_CPCL
	linuxhardening.cu_world_writable_directories         vm_tag=CPCL

CU_World-Writable_Directories_CPIF
	linuxhardening.cu_world_writable_directories         vm_tag=CPIF

CU_World-Writable_Directories_CPNB
	linuxhardening.cu_world_writable_directories         vm_tag=CPNB

CU_World-Writable_Directories_CPUE
	linuxhardening.cu_world_writable_directories         vm_tag=CPUE

CU_World-Writable_Directories_UPUE
	linuxhardening.cu_world_writable_directories         vm_tag=UPUE

CU_World-Writable_Directories_CPNRT
	linuxhardening.cu_world_writable_directories         vm_tag=CPNRT

CU_World-Writable_Directories_DB
	linuxhardening.cu_world_writable_directories         vm_tag=DB

CU_Root_Writeable_Files_B_OAM
	linuxhardening.cu_root_writeable_files_b             vm_tag=OAM

CU_Root_Writeable_Files_B_CPCL
	linuxhardening.cu_root_writeable_files_b             vm_tag=CPCL

CU_Root_Writeable_Files_B_CPIF
	linuxhardening.cu_root_writeable_files_b             vm_tag=CPIF

CU_Root_Writeable_Files_B_CPNB
	linuxhardening.cu_root_writeable_files_b             vm_tag=CPNB

CU_Root_Writeable_Files_B_CPUE
	linuxhardening.cu_root_writeable_files_b             vm_tag=CPUE

CU_Root_Writeable_Files_B_UPUE
	linuxhardening.cu_root_writeable_files_b             vm_tag=UPUE

CU_Root_Writeable_Files_B_CPNRT
	linuxhardening.cu_root_writeable_files_b             vm_tag=CPNRT

CU_Root_Writeable_Files_B_DB
	linuxhardening.cu_root_writeable_files_b             vm_tag=DB

CU_file_permission_rules_group_OAM
	linuxhardening.file_permission_rules               vm_tag=OAM       files_path=/etc/group

CU_file_permission_rules_group_CPCL
	linuxhardening.file_permission_rules               vm_tag=CPCL       files_path=/etc/group

CU_file_permission_rules_group_CPIF
	linuxhardening.file_permission_rules               vm_tag=CPIF       files_path=/etc/group

CU_file_permission_rules_group_CPNB
	linuxhardening.file_permission_rules               vm_tag=CPNB       files_path=/etc/group

CU_file_permission_rules_group_CPUE
	linuxhardening.file_permission_rules               vm_tag=CPUE       files_path=/etc/group

CU_file_permission_rules_group_UPUE
	linuxhardening.file_permission_rules               vm_tag=UPUE       files_path=/etc/group

CU_file_permission_rules_group_CPNRT
	linuxhardening.file_permission_rules               vm_tag=CPNRT       files_path=/etc/group

CU_file_permission_rules_group_DB
	linuxhardening.file_permission_rules               vm_tag=DB       files_path=/etc/group

CU_file_permission_rules_shadow_OAM
	linuxhardening.file_permission_rules               vm_tag=OAM       files_path=/etc/shadow

CU_file_permission_rules_shadow_CPCL
	linuxhardening.file_permission_rules               vm_tag=CPCL       files_path=/etc/shadow

CU_file_permission_rules_shadow_CPIF
	linuxhardening.file_permission_rules               vm_tag=CPIF       files_path=/etc/shadow

CU_file_permission_rules_shadow_CPNB
	linuxhardening.file_permission_rules               vm_tag=CPNB       files_path=/etc/shadow

CU_file_permission_rules_shadow_CPUE
	linuxhardening.file_permission_rules               vm_tag=CPUE       files_path=/etc/shadow

CU_file_permission_rules_shadow_UPUE
	linuxhardening.file_permission_rules               vm_tag=UPUE       files_path=/etc/shadow

CU_file_permission_rules_shadow_CPNRT
	linuxhardening.file_permission_rules               vm_tag=CPNRT       files_path=/etc/shadow

CU_file_permission_rules_shadow_DB
	linuxhardening.file_permission_rules               vm_tag=DB       files_path=/etc/shadow

CU_file_permission_rules_fstab_OAM
	linuxhardening.file_permission_rules               vm_tag=OAM       files_path=/etc/fstab

CU_file_permission_rules_fstab_CPCL
	linuxhardening.file_permission_rules               vm_tag=CPCL       files_path=/etc/fstab

CU_file_permission_rules_fstab_CPIF
	linuxhardening.file_permission_rules               vm_tag=CPIF       files_path=/etc/fstab

CU_file_permission_rules_fstab_CPNB
	linuxhardening.file_permission_rules               vm_tag=CPNB       files_path=/etc/fstab

CU_file_permission_rules_fstab_CPUE
	linuxhardening.file_permission_rules               vm_tag=CPUE       files_path=/etc/fstab

CU_file_permission_rules_fstab_UPUE
	linuxhardening.file_permission_rules               vm_tag=UPUE       files_path=/etc/fstab

CU_file_permission_rules_fstab_CPNRT
	linuxhardening.file_permission_rules               vm_tag=CPNRT       files_path=/etc/fstab

CU_file_permission_rules_fstab_DB
	linuxhardening.file_permission_rules               vm_tag=DB       files_path=/etc/fstab

CU_file_permission_rules_inittab_OAM
	linuxhardening.file_permission_rules               vm_tag=OAM       files_path=/etc/inittab

CU_file_permission_rules_inittab_CPCL
	linuxhardening.file_permission_rules               vm_tag=CPCL       files_path=/etc/inittab

CU_file_permission_rules_inittab_CPIF
	linuxhardening.file_permission_rules               vm_tag=CPIF       files_path=/etc/inittab

CU_file_permission_rules_inittab_CPNB
	linuxhardening.file_permission_rules               vm_tag=CPNB       files_path=/etc/inittab

CU_file_permission_rules_inittab_CPUE
	linuxhardening.file_permission_rules               vm_tag=CPUE       files_path=/etc/inittab

CU_file_permission_rules_inittab_UPUE
	linuxhardening.file_permission_rules               vm_tag=UPUE       files_path=/etc/inittab

CU_file_permission_rules_inittab_CPNRT
	linuxhardening.file_permission_rules               vm_tag=CPNRT       files_path=/etc/inittab

CU_file_permission_rules_inittab_DB
	linuxhardening.file_permission_rules               vm_tag=DB       files_path=/etc/inittab

CU_file_permission_rules_hosts_OAM
	linuxhardening.file_permission_rules               vm_tag=OAM       files_path=/etc/hosts

CU_file_permission_rules_hosts_CPCL
	linuxhardening.file_permission_rules               vm_tag=CPCL       files_path=/etc/hosts

CU_file_permission_rules_hosts_CPIF
	linuxhardening.file_permission_rules               vm_tag=CPIF       files_path=/etc/hosts

CU_file_permission_rules_hosts_CPNB
	linuxhardening.file_permission_rules               vm_tag=CPNB       files_path=/etc/hosts

CU_file_permission_rules_hosts_CPUE
	linuxhardening.file_permission_rules               vm_tag=CPUE       files_path=/etc/hosts

CU_file_permission_rules_hosts_UPUE
	linuxhardening.file_permission_rules               vm_tag=UPUE       files_path=/etc/hosts

CU_file_permission_rules_hosts_CPNRT
	linuxhardening.file_permission_rules               vm_tag=CPNRT       files_path=/etc/hosts

CU_file_permission_rules_hosts_DB
	linuxhardening.file_permission_rules               vm_tag=DB       files_path=/etc/hosts

CU_file_permission_rules_issue_OAM
	linuxhardening.file_permission_rules               vm_tag=OAM       files_path=/etc/issue

CU_file_permission_rules_issue_CPCL
	linuxhardening.file_permission_rules               vm_tag=CPCL       files_path=/etc/issue

CU_file_permission_rules_issue_CPIF
	linuxhardening.file_permission_rules               vm_tag=CPIF       files_path=/etc/issue

CU_file_permission_rules_issue_CPNB
	linuxhardening.file_permission_rules               vm_tag=CPNB       files_path=/etc/issue

CU_file_permission_rules_issue_CPUE
	linuxhardening.file_permission_rules               vm_tag=CPUE       files_path=/etc/issue

CU_file_permission_rules_issue_UPUE
	linuxhardening.file_permission_rules               vm_tag=UPUE       files_path=/etc/issue

CU_file_permission_rules_issue_CPNRT
	linuxhardening.file_permission_rules               vm_tag=CPNRT       files_path=/etc/issue

CU_file_permission_rules_issue_DB
	linuxhardening.file_permission_rules               vm_tag=DB       files_path=/etc/issue

CU_file_permission_rules_services_OAM
	linuxhardening.file_permission_rules               vm_tag=OAM       files_path=/etc/services

CU_file_permission_rules_services_CPCL
	linuxhardening.file_permission_rules               vm_tag=CPCL       files_path=/etc/services

CU_file_permission_rules_services_CPIF
	linuxhardening.file_permission_rules               vm_tag=CPIF       files_path=/etc/services

CU_file_permission_rules_services_CPNB
	linuxhardening.file_permission_rules               vm_tag=CPNB       files_path=/etc/services

CU_file_permission_rules_services_CPUE
	linuxhardening.file_permission_rules               vm_tag=CPUE       files_path=/etc/services

CU_file_permission_rules_services_UPUE
    linuxhardening.file_permission_rules               vm_tag=UPUE       files_path=/etc/services

CU_file_permission_rules_services_CPNRT
    linuxhardening.file_permission_rules               vm_tag=CPNRT       files_path=/etc/services

CU_file_permission_rules_services_DB
	linuxhardening.file_permission_rules               vm_tag=DB       files_path=/etc/services

CU_Process_user_accounts_ntpd_OAM
	linuxhardening.cu_process_user_accounts          vm_tag=OAM      not_allowed_process=ntpd

CU_Process_user_accounts_ntpd_CPCL
	linuxhardening.cu_process_user_accounts          vm_tag=CPCL      not_allowed_process=ntpd

CU_Process_user_accounts_ntpd_CPIF
	linuxhardening.cu_process_user_accounts          vm_tag=CPIF     not_allowed_process=ntpd

CU_Process_user_accounts_ntpd_CPNB
	linuxhardening.cu_process_user_accounts          vm_tag=CPNB     not_allowed_process=ntpd

CU_Process_user_accounts_ntpd_CPUE
	linuxhardening.cu_process_user_accounts          vm_tag=CPUE      not_allowed_process=ntpd

CU_Process_user_accounts_ntpd_UPUE
	linuxhardening.cu_process_user_accounts          vm_tag=UPUE      not_allowed_process=ntpd

CU_Process_user_accounts_ntpd_CPNRT
	linuxhardening.cu_process_user_accounts          vm_tag=CPNRT      not_allowed_process=ntpd

CU_Process_user_accounts_ntpd_DB
	linuxhardening.cu_process_user_accounts          vm_tag=DB      not_allowed_process=ntpd

CU_Process_user_accounts_ospfd_OAM
	linuxhardening.cu_process_user_accounts          vm_tag=OAM      not_allowed_process=ospfd

CU_Process_user_accounts_ospfd_CPCL
	linuxhardening.cu_process_user_accounts          vm_tag=CPCL      not_allowed_process=ospfd

CU_Process_user_accounts_ospfd_CPIF
	linuxhardening.cu_process_user_accounts          vm_tag=CPIF      not_allowed_process=ospfd

CU_Process_user_accounts_ospfd_CPNB
	linuxhardening.cu_process_user_accounts          vm_tag=CPNB     not_allowed_process=ospfd

CU_Process_user_accounts_ospfd_CPUE
	linuxhardening.cu_process_user_accounts          vm_tag=CPUE      not_allowed_process=ospfd

CU_Process_user_accounts_ospfd_UPUE
	linuxhardening.cu_process_user_accounts          vm_tag=UPUE      not_allowed_process=ospfd

CU_Process_user_accounts_ospfd_CPNRT
	linuxhardening.cu_process_user_accounts          vm_tag=CPNRT     not_allowed_process=ospfd

CU_Process_user_accounts_ospfd_DB
	linuxhardening.cu_process_user_accounts          vm_tag=DB     not_allowed_process=ospfd

CU_Process_user_accounts_zebrad_OAM
	linuxhardening.cu_process_user_accounts          vm_tag=OAM      not_allowed_process=zebrad

CU_Process_user_accounts_zebrad_CPCL
	linuxhardening.cu_process_user_accounts          vm_tag=CPCL      not_allowed_process=zebrad

CU_Process_user_accounts_zebrad_CPIF
	linuxhardening.cu_process_user_accounts          vm_tag=CPIF      not_allowed_process=zebrad

CU_Process_user_accounts_zebrad_CPNB
	linuxhardening.cu_process_user_accounts          vm_tag=CPNB      not_allowed_process=zebrad

CU_Process_user_accounts_zebrad_CPUE
	linuxhardening.cu_process_user_accounts          vm_tag=CPUE      not_allowed_process=zebrad

CU_Process_user_accounts_zebrad_UPUE
	linuxhardening.cu_process_user_accounts          vm_tag=UPUE      not_allowed_process=zebrad

CU_Process_user_accounts_zebrad_CPNRT
	linuxhardening.cu_process_user_accounts          vm_tag=CPNRT      not_allowed_process=zebrad

CU_Process_user_accounts_zebrad_DB
	linuxhardening.cu_process_user_accounts          vm_tag=DB      not_allowed_process=zebrad

CU_check_if_OAM_ssh_key_exist
    linuxhardening.check_if_oam_vm_ssh_key_exist

DU_check_onAir
    linuxhardening.check_on_air

DU_wait_for_onAir
    linuxhardening.wait_for_on_air

DU_check_active_alarms
    linuxhardening.check_active_alarms

DU_check_link_to_CU
    linuxhardening.check_link_to_cu

DU_File_Permission_Rules_passwd
    linuxhardening.file_permission_rules          vm_tag=FCT       files_path=/etc/passwd        expected_permission=-rw-r--r--

DU_File_Permission_Rules_group
    linuxhardening.file_permission_rules          vm_tag=FCT       files_path=/etc/group         expected_permission=-rw-r--r--

DU_File_Permission_Rules_shadow
    linuxhardening.file_permission_rules          vm_tag=FCT       files_path=/etc/shadow        expected_permission=-rw-------

DU_File_Permission_Rules_fstab
    linuxhardening.file_permission_rules          vm_tag=FCT       files_path=/etc/fstab         expected_permission=-rw-r--r--

DU_File_Permission_Rules_hosts
    linuxhardening.file_permission_rules          vm_tag=FCT       files_path=/etc/hosts         expected_permission=-rw-r--r--

DU_File_Permission_Rules_issue
    linuxhardening.file_permission_rules          vm_tag=FCT       files_path=/etc/issue

DU_File_Permission_Rules_services
    linuxhardening.file_permission_rules          vm_tag=FCT       files_path=/etc/services      expected_permission=-rw-r--r--

DU_Process_with_lower_privileges
    linuxhardening.du_process_with_lower_privileges      vm_tag=FCT

DU_Orphaned_Files
    linuxhardening.du_orphaned_files       vm_tag=FCT

DU_PATH_environment_variable
    linuxhardening.du_path_environment_variable      vm_tag=FCT

DU_Root_Writeable_Files
    linuxhardening.du_root_writeable_files     vm_tag=FCT

DU_Process_user_accounts_ntpd
    linuxhardening.cu_process_user_accounts      vm_tag=FCT      not_allowed_process=ntpd

DU_Process_user_accounts_ospfd
    linuxhardening.cu_process_user_accounts      vm_tag=FCT      not_allowed_process=ospfd

DU_Process_user_accounts_zebrad
    linuxhardening.cu_process_user_accounts      vm_tag=FCT      not_allowed_process=zebrad

DU_Unauthorized_World-Writeable_Directories
    linuxhardening.du_unauthorized_world_writeable_directories     vm_tag=FCT

DU_World-Writeable_Directories
    linuxhardening.du_world_writable_directories     vm_tag=FCT
