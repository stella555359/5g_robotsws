import os
import re
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.aic_connections import VduKubeConnection
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_robot_output_dir
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.aic_variables import mrbts_id


class tcpdump_aic:
    def __init__(self):
        self.container = None
        self.filename = None
        self.remote_output_dir = '/var/home/core'
        self.remote_filepath = None
        self.output_filepath = None
        self.interface = None

    def set_output_filepath(self, output_dir, filename):
        if not filename.endswith('.pcap'):
            filename += '.pcap'
        self.filename = filename
        self.output_filepath = os.path.join(output_dir, self.filename)
        self.remote_filepath = os.path.join(self.remote_output_dir, self.filename)

    def teardown_tcpdump_aic(self):
        with VduKubeConnection() as vdu:
            vdu.execute_command('sudo pkill tcpdump')
            vdu.execute_command_on_worker('sudo pkill tcpdump')

    def tcpdump_command(self, tcpdump_filter='sctp'):
        return f"sudo nsenter -r -n -t $(sudo crictl inspect --output yaml $(sudo crictl ps | " \
               f"grep  $(sudo crictl pods | grep {self.container} | awk '{{print $1}}') | " \
               f"grep nwmgmt | awk '{{print $1}}') | grep 'pid:' | awk '{{print $2}}') " \
               f"nohup tcpdump -s0 -i {self.interface} -w {self.filename} {tcpdump_filter} > /dev/null 2>&1 &\n"


class tcpdump_f1_aic(tcpdump_aic):
    def __init__(self):
        super().__init__()
        self.interface = 'f1cplane'
        self.container = 'ute-cran1-cprt-0'

    def start_f1c_tcpdump(self, filename, output_dir=None):
        if not output_dir:
            output_dir = get_robot_output_dir()
        self.set_output_filepath(output_dir, filename)
        with VduKubeConnection() as vdu:
            vdu.send_command(self.tcpdump_command())
            out = vdu.execute_command(f'sudo pgrep tcpdump')
            logger.info(out, also_console=True)

    def stop_f1c_tcpdump(self):
        with VduKubeConnection() as vdu:
            logger.debug(f"Stopping f1c tcpdump, cmd: sudo pkill -f tcpdump.*{self.filename}")
            vdu.execute_command(f"sudo pkill -f tcpdump.*{self.filename}")
            vdu.download_file(self.remote_filepath, self.output_filepath)
            vdu.execute_command(f'rm -f {self.remote_filepath}')
        assert os.path.exists(self.output_filepath)
        return self.output_filepath


class tcpdump_ngc_aic(tcpdump_aic):
    def __init__(self):
        super().__init__()
        self.interface = 'ngc'
        self.container = f'ute-cran{mrbts_id}-cpif-0'

    def start_ngc_tcpdump(self, filename, output_dir=None):
        if not output_dir:
            output_dir = get_robot_output_dir()
        self.set_output_filepath(output_dir, filename)
        with VduKubeConnection() as vdu:
            vdu.execute_command_on_worker(self.tcpdump_command())

    def stop_ngc_tcpdump(self):
        with VduKubeConnection() as vdu:
            logger.debug(f"Stopping ngc tcpdump, cmd: sudo pkill -f tcpdump.*{self.filename}")
            vdu.execute_command_on_worker(f"sudo pkill -f tcpdump.*{self.filename}")
            vdu.download_file_from_worker(self.remote_filepath, self.output_filepath)
            vdu.execute_command_on_worker(f'rm -f {self.remote_filepath}')
        assert os.path.exists(self.output_filepath)
        return self.output_filepath


class tcpdump_oamext_aic(tcpdump_aic):
    def __init__(self):
        super().__init__()
        self.interface = 'any'
        self.container = f'ute-cran{mrbts_id}-oamext-0'

    def start_oam_tcpdump(self, filename, output_dir=None):
        if not output_dir:
            output_dir = get_robot_output_dir()
        self.set_output_filepath(output_dir, filename)
        with VduKubeConnection() as vdu:
            vdu.execute_command_on_worker(self.tcpdump_command(tcpdump_filter=''))

    def stop_oam_tcpdump(self):
        with VduKubeConnection() as vdu:
            logger.debug(f"Stopping oamext tcpdump, cmd: sudo pkill -f tcpdump.*{self.filename}")
            vdu.execute_command_on_worker(f"sudo pkill -f tcpdump.*{self.filename}")
            vdu.download_file_from_worker(self.remote_filepath, self.output_filepath)
            vdu.execute_command_on_worker(f'rm -f {self.remote_filepath}')
        assert os.path.exists(self.output_filepath)
        return self.output_filepath


class tcpdump_aic_collector:
    def __init__(self):
        self.filename = None
        self.pcmd_filename = None
        self.output_dir = None
        self.output_dir_pcmd = None
        self.ngc_collector = tcpdump_ngc_aic()
        self.f1c_collector = tcpdump_f1_aic()
        self.oam_collector = tcpdump_oamext_aic()

    def start_f1c_and_ngc_tcpdump(self, filename, output_dir=None):
        if not output_dir:
            output_dir = get_robot_output_dir()
        self.filename = filename
        self.output_dir = output_dir
        self.f1c_collector.start_f1c_tcpdump(f'f1c_{filename}', output_dir)
        self.ngc_collector.start_ngc_tcpdump(f'ngc_{filename}', output_dir)

    def stop_f1c_and_ngc_tcpdump(self):
        output_filepath = os.path.join(self.output_dir, self.filename)
        filepath_f1c = self.f1c_collector.stop_f1c_tcpdump()
        filepath_ngc = self.ngc_collector.stop_ngc_tcpdump()
        self.merge_pcap([filepath_ngc, filepath_f1c], output_filepath)
        return output_filepath

    def start_pcmd_trace(self, filename, output_dir=None):
        if not output_dir:
            output_dir = get_robot_output_dir()
        self.pcmd_filename = f'pcmd_{filename}'
        self.output_dir_pcmd = output_dir
        self.oam_collector.start_oam_tcpdump(self.pcmd_filename, output_dir)

    def stop_pcmd_trace(self):
        output_filepath = os.path.join(self.output_dir_pcmd, self.pcmd_filename)
        self.oam_collector.stop_oam_tcpdump()
        return output_filepath

    @staticmethod
    def merge_pcap(filepaths, output_filepath):
        os.system(f"mergecap {' '.join(filepaths)} -w {output_filepath}")
        os.system(f"rm {' '.join(filepaths)}")

    def teardown_tcpdump(self):
        self.f1c_collector.teardown_tcpdump_aic()
