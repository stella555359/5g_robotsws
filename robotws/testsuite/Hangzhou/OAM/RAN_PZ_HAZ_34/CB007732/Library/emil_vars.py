from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

emil_host = tl.ues[0].ssh_connection_details.addr
emil_user = tl.ues[0].ssh_connection_details.username
emil_password = tl.ues[0].ssh_connection_details.password
# emil_host = "10.57.150.56"
# emil_user = "mn5gran"
# emil_password = "nokia123@"
emil_path = "/cygdrive/c/Program Files/Emil"
emil_win_path = "C:\\Programe Files\\Emil"
emil_log_dir = "/cygdrive/c/temp/emil_logs"
emil_win_dir = "C:\\\\temp\\\\emil_logs\\\\"
emil_cmd_pre = "start /wait Emil.exe"
emil_protocol = "5G Cell Trace"
emil_param = "-AutoClose -Profile SourceProfileUser.ini -ProfilePath " \
             "\"C:\\Program Files\\Emil\\profiles\\%s\" -Variable OutPath" % emil_protocol
