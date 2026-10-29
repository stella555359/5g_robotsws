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
flag_parameter = {"rdFeatureFlagBitmap": "4",
                  "rdFeatureFlagBitmapLevel": "3"}
bad_UL_BLER_flags = ["0x58057A=4", "0x58057f=3"]
rad_param = ["rdFeatureFlagBitmap4", "rdFeatureFlagBitmapLevel"]
flag_domain = "L2PS"
flag_persistency = "Persistent"
rediprio_name = "Redirection priority for RRC Connection Release"
arfcnssbPbch_1062 = 636576
erfcn_eutra = 9580
redirFreqNr = "redirFreqNr"
redirFreqEutra = "redirFreqEutra"
redirSsbScs = "redirSsbScs"
Scs = "30 KHz"
redirRat = "RAT for Redirection"
RAT_redir = "redirRat"
nr = "nr"
eutra = "eutra"
NRREDRT = "NRREDRT"
badULRedirectDeprioTimer = "Bad UL redirect deprioritization timer"
deprioritization_timer = "badULRedirectDeprioTimer"
badULRedirectDeprioTimer_5min = "5min"
DeprioTimer_5min = "5min"
ulbler = "UL BLER"
ul_bler = "ulBler"
ulBlerThresholdRedirectData = "UL BLER threshold for data redirection"
ulBlerThresholdRedirectVoNR = "UL BLER threshold for VoNR redirection"
redir_Vonr = "ulBlerThresholdRedirectVoNR"
redir_Data = "ulBlerThresholdRedirectData"
ulblerPercentage = 3
actBadUplinkRadioRedirect = "Activate bad UL radio based redirection"
bler_base_redir = "actBadUplinkRadioRedirect"
highUlBlerBased = "highUlBlerBased"
redirPrioBadUlRadio = "Redirection priority for bad UL radio"
NR_RRC_REL_REDIR_RAD_NR = ["M55124C00521"]
NR_RRC_REL_REDIR_RAD_LTE = ["M55124C00522"]
