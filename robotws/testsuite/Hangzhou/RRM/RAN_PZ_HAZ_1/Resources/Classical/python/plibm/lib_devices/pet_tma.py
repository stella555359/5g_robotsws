# -*- coding: utf-8 -*-

"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import six
import logging
import telnetlib
import time
import re
import os


known_errors = [
    'Failure Cannot execute command as previous command still running',
    'Assert',
]


class c_pet_tma(object):

    def __init__(self, host, logfile='', logger=None):
        self.host = host
        self.port = 5003
        self.logfile = logfile
        self.conn = None

        self.name = 'TMA_{}'.format(host)
        self.error_messages = []
        self.monitoring_error = []
        self.last_command = ''

        if logfile:
            self.logger = self.get_logger(self.name, logfile)
        else:
            self.logger = logger or logging.getLogger(__file__)

    def get_logger(self, logger_name='', log_filename=''):
        from logging.handlers import RotatingFileHandler
        FORMATTER = logging.Formatter("%(asctime)s,%(msecs)3d [%(name)s] - [%(levelname)5s] %(message)s",
                                      "%m-%d %H:%M:%S")
        logger = logging.getLogger(logger_name)
        logger.setLevel(logging.DEBUG)
        if logger.handlers:
            logger.handlers.pop()
        if log_filename:
            file_handler = RotatingFileHandler(log_filename, maxBytes=50 * 1024 * 1024)
            file_handler.setFormatter(FORMATTER)
            logger.addHandler(file_handler)
        logger.propagate = False
        return logger

    def connect(self):
        if not self.conn:
            self.logger.info('Connect to TMA 5003...')
            self.conn = telnetlib.Telnet(self.host, 5003, 5)
            self.logger.info('Connect to TMA 5003 done.')

    def disconnect(self):
        if self.conn:
            self.logger.info('Disconnect from TMA 5003...')
            self.conn.close()
            self.conn = None

    def execute_tm500_command(self, command='', ignore_error=False, timeout=300, wait_response=True):
        self.connect()
        output = ''
        try:
            self.logger.info('CLI ---> {}'.format(command))
            self.conn.write(six.b(command + '\r\n'))
            self.last_command = command
            if not wait_response:
                return ''
            special_str = 'SSH connection Error :Connection failed to establish'
            if 'DISCONNECT' in command.upper() or 'STRT' in command.upper():
                failed_keyword = ['I: TIMEOUT - no response found', 'ASSERT']
            else:
                failed_keyword = ['FAILURE', 'I: TIMEOUT - no response found', 'ASSERT', 'FAILED']
            index, b, output = self.conn.expect([six.b(r'C:[\s\S]+\r\n')], timeout)
            output = output.decode('utf-8', 'ignore')
            output += self.conn.read_very_eager().decode('utf-8', 'ignore')
            for line in output.splitlines():
                if line.strip():
                    self.logger.info('CLI <--- ' + line)

            if [x for x in failed_keyword if x.upper() in output.upper()]:
                if ignore_error:
                    self.logger.warning('Error received')
                elif special_str.lower() in output.lower():
                    self.logger.warning(
                        'Found SSH connection Error :Connection failed to establish in TM500 output, ignore it.')
                else:
                    r = []
                    for keyword in failed_keyword:
                        for line in output.splitlines():
                            if keyword.lower() in line.lower():
                                r.append(line)
                    raise Exception('TM500 Command Execution Failed. {}'.format(';'.join(r)))
        except Exception as E:
            self.logger.exception(E)
        finally:
            self.pause = False
        return output

    def execute_tm500_command_without_check(self, command):
        return self.execute_tm500_command(command, ignore_error=True)

    def cli_disconnect(self):
        self.execute_tm500_command('#$$DISCONNECT', ignore_error=True, wait_response=False)

    def cli_keep_alive(self):
        self.execute_tm500_command('CHOW', ignore_error=True, wait_response=False)

    def _contains_keyword(self, text, keywords):
        for keyword in keywords:
            if keyword.lower() in text.lower():
                return True
        return False

    def run_script_file(self, filename='', failed_keyword=['Assert'], timeout=300):
        self.connect()
        if os.path.exists(filename):
            script = open(filename).readlines()
            script = [x.strip().splitlines()[0] for x in script if x.strip()]
            script = [x for x in script if 'CONNECT' in x.upper() or 'PORT' in x.upper() or not x.startswith('#')]
            return self.run_script_list(script, failed_keyword)
        else:
            self.monitoring_error.append(f'Could not find file: {filename}')
            raise Exception(f'Could not find {filename}')

    def run_script_file2(self, filename='', failed_keyword=['Assert'], last_command='', timeout=300):
        self.connect()
        command = 'SCRIPT "{}" 1 1'.format(filename)
        try:
            self.pause = True
            self.logger.info(f'CLI ---> {command}')
            self.conn.write(six.b(command + '\r\n'))
            self.last_command = command
            failed_keyword = ['FAILURE', 'I: TIMEOUT - no response found']

            output = ''
            exp_str = 'C: SCRIPT'
            self.logger.info('Expected: [{}]'.format(exp_str))
            start_time = time.time()
            while time.time() < start_time + timeout:
                response = self.conn.read_very_eager().decode('utf-8', 'ignore')
                for line in response.splitlines():
                    if line.strip():
                        self.logger.info('CLI <--- ' + line)
                output += response

                if exp_str in output:
                    break

                if [x for x in failed_keyword if x.upper() in output.upper()]:
                    raise Exception('Error happened in run TM500 Script, found failed keyword.')
                    break
                time.sleep(1)

        except Exception as E:
            self.logger.exception(E)
            self.monitoring_error.append(str(E))
        finally:
            self.pause = False
        return output

    def run_script_list(self, script=[], failed_keyword=['Assert']):
        def _log(s):
            from robot.api import logger
            logger.info(s)
            pass

        self.connect()
        output = ''
        for line in script:
            _log(line)
            text = self.execute_tm500_command(line)
            _log(text)
            output += text
            if self._contains_keyword(text, failed_keyword):
                self.logger.info(f'found failed keyword {failed_keyword}')
                _log(f'found failed keyword {failed_keyword}')
                self.monitoring_error.append(f'Found Fail keyword in TM500 output: {text}')
                break
        return output

    def read_tm500_output(self, timeout=0, exp_str=''):
        self.connect()
        delay_timeout = float(timeout)
        if delay_timeout > 0:
            output = ''
            st = time.time()
            while (True):
                if six.PY3:
                    buf = self.conn.read_very_eager().decode()
                else:
                    buf = self.conn.read_very_eager()
                if buf:
                    self.logger.info(buf)
                    output += buf
                if time.time() - st > delay_timeout:
                    break
                if exp_str in output:
                    return output
                time.sleep(0.01)
        else:
            if six.PY3:
                output = self.conn.read_very_eager().decode()
            else:
                output = self.conn.read_very_eager()
        return output

    def wait_until_find_expected_string_in_tm500_output(self, timeout, interval, expect_str):
        self.connect()
        st = time.time()
        found = False
        output = ''
        from robot.utils import timestr_to_secs
        while time.time() - st <= timestr_to_secs(timeout):
            ret = self.read_tm500_output()
            if ret.strip():
                self.logger.info(ret)
                output += ret
                if isinstance(expect_str, list):
                    if [x for x in expect_str if x.upper() in output.upper()]:
                        found = True
                        break
                else:
                    if expect_str.upper() in output.upper():
                        found = True
                        break
            if 'ASSERTED' in output.upper():
                raise Exception('Found Error in TM500 Output.')
            time.sleep(timestr_to_secs(interval))
        if not found:
            raise Exception('Could not find [{}] in TM500 output in {} seconds.'.format(
                expect_str, timeout))
        else:
            return output


if __name__ == '__main__':
    logging.basicConfig(format='%(asctime)s,%(msecs)3d [%(levelname)5s] %(message)s',
                        datefmt='%Y-%m-%d %H:%M:%S', level=logging.DEBUG)
    tma = c_pet_tma('10.106.210.27')
    tma.connect()
    tma.execute_tm500_command('CHOW')
    tma.disconnect()
