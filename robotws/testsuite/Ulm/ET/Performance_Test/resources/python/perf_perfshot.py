
import os

from robot.libraries.BuiltIn import BuiltIn
from testsuite.Ulm.ET.Performance_Test.resources.python import perf_paramiko
from testsuite.Ulm.ET.Performance_Test.resources.python import bash_helper
from testsuite.Ulm.ET.Performance_Test.resources.python import perf_log_collection

rbi = BuiltIn()

console_debug = False

CONST_PERFSHOT_LOCAL_TMP_DIR = "/tmp/perfshot"
CONST_PERFSHOT_REMOTE_LOG_GLOB = "/var/fct_tmp/perfCapture_*.tgz"
CONST_PERFSHOT_ARCHIVE_VM_PATH = "/home/ute/DEVELOPMENT/perfshot/perfshot.tgz"
CONST_PERFSHOT_ARCHIVE_REMOTE_PATH = "/var/fct_tmp/perfshot.tgz"


def prepare_perfshot(p_console=console_debug):
    rbi.log("\nPreparing Perfshot...", console=True)
    bash_helper.run_bash_subprocess("ssh-keygen -f '/home/ute/.ssh/known_hosts' -R '192.168.255.1'")

    clone_perfshot()

    perf_paramiko.transfer_file_to_smod(
        CONST_PERFSHOT_ARCHIVE_VM_PATH, CONST_PERFSHOT_ARCHIVE_REMOTE_PATH)

    perf_paramiko.run_smod_cmd(
        'cd /var/fct_tmp; tar xvfz perfshot.tgz && chmod a+x perfshot.sh smem')


def run_perfshot(perfshot_arg='--pet', hws='null', p_console=console_debug, *args, **kwargs):
    rbi.log(f"Collecting Perfshot: .../{kwargs['subfolder']}", console=True)
    bash_helper.run_bash_subprocess(
        f"mkdir -p {CONST_PERFSHOT_LOCAL_TMP_DIR}/ && rm -f {CONST_PERFSHOT_LOCAL_TMP_DIR}/*")
    perf_paramiko.run_smod_cmd(f'rm -f {CONST_PERFSHOT_REMOTE_LOG_GLOB}')

    if hws != 'null':
        hws_arr = hws.split(',')
        if 'smod' in hws_arr:
            hws_arr.remove('smod')
            rbi.log("    - System Module", console=p_console)
            perf_paramiko.run_smod_cmd(
                f"cd /var/fct_tmp; ./perfshot.sh {perfshot_arg}")

        for baseband in hws_arr:
            rbi.log(f"    - Baseband [ {baseband} ]", console=p_console)
            perf_paramiko.run_smod_cmd(
                f"bsh {baseband} 'cd /var/fct_tmp; ./perfshot.sh {perfshot_arg}'")

    collect_perfshot(*args, **kwargs)


def collect_perfshot(*args, **kwargs):
    perf_paramiko.transfer_file_from_smod(
        CONST_PERFSHOT_REMOTE_LOG_GLOB, CONST_PERFSHOT_LOCAL_TMP_DIR)
    for item in os.listdir(CONST_PERFSHOT_LOCAL_TMP_DIR):
        path_to_file = f"{CONST_PERFSHOT_LOCAL_TMP_DIR}/{item}"
        if os.path.isfile(path_to_file):
            perf_log_collection.queue_logs_to_turandot(
                path_to_file, *args, **kwargs)


def clone_perfshot(p_console=console_debug):
    bash_helper.clone_repo('git@gitlabe1.ext.net.nokia.com:5G_RAN_ARCHI_SPEC_NPS_06/perfshot.git', p_console=p_console)
