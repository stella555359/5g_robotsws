import os
from subprocess import Popen
import tempfile
import time
try:
    import loguru
except ImportError:
    os.system('pip install loguru')
    import loguru


class ShellExecutor():
    def __init__(self):
        self.stdout = ''
        self.stderr = ''
        self.rc = ''

    def _check_timeout(self, proc, timeout):
        current_time = initial_time = time.time()
        while (current_time - initial_time) < timeout:
            if proc.poll() is not None:
                return True
            time.sleep(0.5)
            current_time = time.time()
        return False

    def execute_cmd(self, cmd, timeout=21600):
        self._clear()
        std_f = tempfile.NamedTemporaryFile()
        std_err_f = tempfile.NamedTemporaryFile()
        loguru.logger.info("Executing the cmd {}: ".format(cmd))
        try:
            proc = Popen(['/bin/bash', '-c', cmd], stdout=std_f, stderr=std_f, bufsize=0)
        except Exception as e:
            raise Exception("cmd : {} failed with error {}".format(cmd, e))
        timeout_flag = self._check_timeout(proc, timeout)
        std_f.seek(0)
        std_err_f.seek(0)
        self.stdout = std_f.read()
        self.stderr = std_err_f.read()
        self.rc = proc.returncode
        self.stderr = self.stderr.decode('UTF-8')
        self.stdout = self.stdout.decode('UTF-8')
        if timeout_flag:
            loguru.logger.info("Command Executed Successfully")
            loguru.logger.opt(raw=True, colors=True).info(f"» {self.stdout.lstrip()}")
        else:
            loguru.logger.info("Command Execution failed")
            loguru.logger.opt(raw=True, colors=True).info(f"» {self.stdout.lstrip()}")
            loguru.logger.info("Error string")
            loguru.logger.opt(raw=True, colors=True).info(f"» {self.stderr.lstrip()}")
            raise Exception("cmd : {} failed".format(cmd))
            exit(self.rc)
        loguru.logger.info("Return code of cmd {} is : {}".format(cmd, self.rc))
        try:
            if self.rc is not None and self.rc > 0:
                loguru.logger.info("Possible that cmd failed !!!! Please check !!!!")
        except Exception as e:
            raise Exception("cmd : {} failed with error {}".format(cmd, e))
        return self.stdout, self.stderr, self.rc

    def _clear(self):
        self.stdout = ''
        self.stderr = ''
        self.rc = ''
