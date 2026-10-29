# variable
Sys_module_login_ip = "192.168.255.1"
Sys_module_login_username = "toor4nsn"
Sys_module_login_password = "oZPS0POrRieRtu"
sw_config_path = "/ffs/run/"
swconfigfilepath = sw_config_path + "swconfig.txt"
backup_remote_path = sw_config_path + "backup/swconfig.txt"
syslog_alias = "btslog"
BTSLOG_Path_for_validation = "/tmp/btslog"
scf_commission = "baseline.xml"
NRBTS_moc = "NRBTS/NRCELL/"
redirection_configuration = {NRBTS_moc: {
                            "actBadUplinkRadioRedirect": "rIEventAndHighUlBlerOrUlNackFloodBased"
                            }
                            }
syslog_string_for_basic_verification = "bad uplink radio redirect"
verification_syslog_path = "/home/ute/Testlogs/syslog/"
