import taf.collectors.core.interface as core_interface
import taf.collectors.btslog.interface as btslog_interface
import os
import shutil
import glob

'''
    These KW are to collect syslog via BTS Log.
    Syslogs are being collected in LOG_DIR. After collecting finish, syslogs are moved to final_dest
    and named after the Test Case it was collected for.
'''


class SyslogCollector:

    def __init__(self, log_dir="/tmp/btslog2", collector_name="btslog"):
        self.LOG_DIR = log_dir
        self.COLLECTOR_NAME = collector_name
        self._clear_log_dir()
        self.btslog = btslog_interface.btslog().create_btslog_collector(name=self.COLLECTOR_NAME, log_dir=self.LOG_DIR)
        self.core = core_interface.core()

    def SYSLOG_Start_Syslog(self):
        self.core.setup_collectors(names=self.COLLECTOR_NAME)
        self.core.start_collectors(names=self.COLLECTOR_NAME)

    def SYSLOG_Stop_and_Save_Syslog(self, test_name, final_dest):
        if not os.path.exists(final_dest):
            os.makedirs(final_dest)
        self.core.stop_collectors(names=self.COLLECTOR_NAME)
        self.core.collect_collectors(names=self.COLLECTOR_NAME)
        self.core.teardown_collectors(names=self.COLLECTOR_NAME)

        self._extract_syslog_file(self.LOG_DIR, final_dest, test_name)

    def _extract_syslog_file(self, source_dir, dest_dir, test_name="default"):
        file_name = "SYSLOG_{}.log".format(test_name)
        shutil.move(self._get_syslog_file(source_dir), os.path.join(dest_dir, file_name))

    def _clear_log_dir(self):
        filelist = glob.glob(os.path.join(self.LOG_DIR, "*"))
        for f in filelist:
            os.remove(f)

    @staticmethod
    def _get_syslog_file(source_dir):
        return glob.glob(source_dir + "/SYSLOG_*")[0]
