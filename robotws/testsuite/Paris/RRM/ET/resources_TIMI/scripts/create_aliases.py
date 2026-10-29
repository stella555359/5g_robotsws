import subprocess
scripts_path = "/home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/resources/scripts/"
bashrc_path = "/home/ute/.bashrc"
default_logs_path = "/home/ute/manualLogs"
kill_wts_command = "sudo killall edaemon && sudo killall egate"
start_egate_command = "sudo ./edaemon --port 22222 && sudo ./edaemon --port 10000 && ./egate " \
                      "--port 20000"

functions_and_aliases = [
    "source /usr/share/bash-completion/completions/git",  # fixes lack of autocompletion of git commands

    "alias kill_wts='{}'".format(kill_wts_command),

    "alias admin='python3 {}open_admin.py'".format(scripts_path),

    "alias egate='cd /opt/iphy/latest && {} && sleep 1 && telnet 0 20000'".format(start_egate_command),

    "alias core='python3 {}/installation_scripts/install_core.py'".format(scripts_path),

    "alias getrepo='git clone https://wrgitlab.int.net.nokia.com/RAN/robotws.git'",

    "alias getyaft='git clone https://gerrit.ext.net.nokia.com/gerrit/MN/RPSW/LFS/build/yaft'",

    "alias gotorepo='xdg-open /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/'",

    "alias prepare='git clone https://wrgitlab.int.net.nokia.com/RAN/robotws.git && sed -e "
    "122s/^/#/ -e 123s/^/#/ -i /home/ute/.bashrc && pip install ta5g_setups_and_teardowns &&"
    " pip install ta5g_pm_counters && pip install infomodel'",

    "alias pycharm='nohup /opt/pycharm/bin/pycharm.sh  /home/ute/robotws/ > /dev/null 2>/dev/null &'",

    "alias fix_capslock='python3 {}turn_off_capslock.py'".format(scripts_path),

    "alias FIX_CAPSLOCK='fix_capslock'",

    "alias reboot_gnb='ssh -q 192.168.255.129 \"ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN\"'",

    "alias reset_site='robot -o NONE -l NONE -r NONE "
    "-t reset_site {}script.robot'".format(scripts_path),

    "alias reset_testline='robot -o NONE -l NONE -r NONE "
    "-t pdu_reset_testline {}script.robot'".format(scripts_path),

    "alias mount_rotta='python3 {}mount_rotta.py'".format(scripts_path),

    "alias beautify_delta='python3 {}beautify_delta.py'".format(scripts_path),

    "alias delta_from_scf='python3 {}delta_from_scf.py'".format(scripts_path),

    "function start_logs() {{ robot -L TRACE -b debug.log -o ta5g_debug_logs/output.xml -l ta5g_debug_logs/log.html"
    " -v SOS_REPORT:\"${{2:-None}}\" -d \"${{1:-{}}}\" -t start_logs {}/script.robot;"
    " }}".format(default_logs_path, scripts_path),

    "function start_logs_and_reach_onair() {{ robot -L TRACE -b debug.log -o ta5g_debug_logs/output.xml -l"
    " ta5g_debug_logs/log.html -v LUA_PATH:\"${{1:-{1}../egate_2c_fdd_sansa.lua}}\" -v SOS_REPORT:\"${{3:-None}}\" "
    "-d \"${{2:-{0}}}\" -t start_logs_and_reach_onair {1}/script.robot; }}".format(default_logs_path, scripts_path),

    "function reach_onair() {{ robot -L TRACE -b debug.log -o ta5g_debug_logs/output.xml -l ta5g_debug_logs/log.html"
    " -v LUA_PATH:\"${{1:-{0}../egate_2c_fdd_sansa.lua}}\" -d /tmp/onair_logs -t manual_reach_onair {0}/script.robot; "
    "}}".format(scripts_path),

    "function git_pip_install() { pip install git+https://wrgitlab.int.net.nokia.com/TAF/talib_mirgration/ta5g/"
    "\"$1\".git@\"$2\"; }",

    "function get_scf() {{ robot -o NONE -l NONE -r NONE -v DST_SCF_PATH:\"${{1:-/home/ute/scf.xml}}\" "
    "-t get_scf {}script.robot; }}".format(scripts_path),

    "function get_gnb_swconfig() {{ robot -o NONE -l NONE -r NONE "
    "-v DST_GNB_SWCONFIG_PATH:\"${{1:-/home/ute/gnb_swconfig.txt}}\" "
    "-t get_gnb_swconfig {}script.robot; }}".format(scripts_path),

    "function get_ap_swconfig() {{ robot -o NONE -l NONE -r NONE "
    "-v DST_AP_SWCONFIG_PATH:\"${{1:-/home/ute/ap_swconfig.txt}}\" "
    "-t get_airphone_swconfig {}script.robot; }}".format(scripts_path),

    "function get_iphy_xml() {{ robot -o NONE -l NONE -r NONE -v DST_IPHY_XML_PATH:\"${{1:-/home/ute/}}\" "
    "-t get_iphy_xml {}script.robot; }}".format(scripts_path),

    "function put_iphy_xml() {{ robot -o NONE -l NONE -r NONE -v SRC_IPHY_XML_PATH:\"$1\" "
    "-v DST_UPDATED_IPHY_XML:\"${{2:-/home/ute/}}\" -t put_iphy_xml {}script.robot; }}".format(scripts_path),

    "function align_nrarfcn_to_scf() {{ robot -o NONE -l NONE -r NONE -v SRC_LUA_PATH:\"$1\" "
    "-t align_nrarfcn_to_scf {}script.robot; }}".format(scripts_path),
]

if __name__ == "__main__":

    subprocess.check_call(["pip3", "install", "-r", scripts_path + "requirements.txt"])

    with open(bashrc_path, "a") as bashrc:  # open .bashrc in append mode
        bashrc.writelines([line+"\n" for line in functions_and_aliases])
