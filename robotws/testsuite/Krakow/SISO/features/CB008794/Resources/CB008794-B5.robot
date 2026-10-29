*** Settings ***
Documentation
...   author: Rafal Kawa
...   contact: rafal.kawa@nokia.com
...   desctiption: Keywords for verification of CB008794-B5

Library     ./RfcOperations.py

*** Keywords ***
CB008794-B5_1_RFC2.0_unencrypted_Private_Keys_and_access_right_check
    check_permissions_of_rfc_files    find_cmd_operators=/ -name "*.pem" -print 2>/dev/null    required_permissions=644
    check_permissions_of_rfc_files    find_cmd_operators=/ -name "*.crt" -print 2>/dev/null    required_permissions=644
    check_permissions_of_rfc_files    find_cmd_operators=/ -name "*.key" -print 2>/dev/null    required_permissions=600

CB008794-B5_2_RFC2.0_Default_users_password_check_unprotected_files
    check_permissions_of_particular_rfc_file    file_path=/etc/shadow    required_permissions=600
    check_permissions_of_particular_rfc_file    file_path=/mnt/data/webOmt_cfg_file.xml   required_permissions=640
    check_permissions_of_particular_rfc_file    file_path=/mnt/data/historyPwd.db   required_permissions=640

CB008794-B5_3_RFC2.0_Local_Account_Check_for_No_Extra_users
    check_rfc_system_users

CB008794-B5_4_RFC2.0_Authorization_policy
    check_permissions_of_particular_rfc_file   file_path=/home/webserver/appweb/appweb.conf   required_permissions=700

CB008794-B5_9_RFC2.0_Check_Authorization_Privileges
    check_rfc_directories_with_permissions_777

CB008794-B5_13_RFC2.0_Check_Only_Exe_Rights_In_CGI_Scripting_Directory
    check_permissions_in_rfc_webserver
