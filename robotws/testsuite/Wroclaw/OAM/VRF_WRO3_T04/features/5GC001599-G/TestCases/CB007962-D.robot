*** Settings ***
Documentation
...  author:  Patryk Tatarek
...  contact: patryk.tatarek@nokia.com

Resource    ../Resources/CB007962-D_Keywords.robot

Library     ../Resources/Password_Complexity_Keywords.py
...        192.168.255.129
...        toor4nsn
...        oZPS0POrRieR

Library     ../Resources/FilesPermissionKeywords.py
...        192.168.255.129
...        toor4nsn
...        oZPS0POrRieR

*** Keywords ***
Check_Kernel_Settings_For_Reverse_Path_Filter
    CB007962-D_Keywords.Check Kernel Settings For Reverse Path Filter

Check_Kernel_Settings_For_Reverse_Path_Filter_ASIA
    CB007962-D_Keywords.Check Kernel Settings For Reverse Path Filter ASIA

Check_Kernel_Settings_For_Reverse_Path_Filter_ASIM
    CB007962-D_Keywords.Check Kernel Settings For Reverse Path Filter ASIM

Check_If_BTS_Logs_Packets_Without_Existing_Route
    CB007962-D_Keywords.Check If BTS Logs Packets Without Existing Route

Check_If_BTS_Ignores_And_Logs_DHCPDECLINE
    CB007962-D_Keywords.Check If BTS Ignores And Logs DHCPDECLINE

Check_If_Serviceuser_Can_Perform_Tunnel_Based_Access_To_Toor4nsn_Account
    CB007962-D_Keywords.Check If Serviceuser Can Perform Tunnel Based Access To Toor4nsn Account

SSH_LoginGracePeriod
    CB007962-D_Keywords.SSH LoginGracePeriod

Telnet_Server_Binary_And_Supporting_Files_Removal
    CB007962-D_Keywords.Telnet Server Binary And Supporting Files Removal

BTS_Alarms_User_If_SOE_Is_NOT_Enabled
    BTS Should Alarm User If SOE Is NOT Enabled

Files_Permission_Hardening
    sec_opr.check_sensitive_files_world_readeable_on_smod
    sec_opr.check_sensitive_files_world_readeable_on_bbmod
