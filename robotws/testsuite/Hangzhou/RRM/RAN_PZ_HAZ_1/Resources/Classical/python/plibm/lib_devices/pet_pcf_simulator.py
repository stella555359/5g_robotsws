# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import os
import time
import logging
try:
    from pet_ssh import cpc_linux
except Exception:
    from .pet_ssh import cpc_linux


class c_pcf_simulator(cpc_linux):

    def setup(self, appname='sim-5g-pcf'):
        self.appname = appname
        self.connect()
        killed = self.kill_process_with_keywords(appname)
        if killed:
            time.sleep(30)
        self.prompt = 'CLI>'
        self.exec_shell_command('cd /home/ute && ./{}'.format(appname))

    def exec_cli_command(self, command):
        self.send_char(command)
        time.sleep(0.1)
        response = self.read_shell_response()
        self.logger.debug('<---- {}'.format(response))
        return response

    def exec_cli_command_file(self, filename):
        output = []
        if os.path.exists(filename):
            lines = [x.strip() for x in open(filename).read().splitlines() if x.strip()]
            for line in lines:
                if not line.startswith('#'):
                    output.append(self.exec_cli_command(line))
        else:
            raise Exception('File {} does not exist'.format(filename))
        return output

    def teardown(self):
        self.kill_process_with_keywords(self.appname)
        return super(c_pcf_simulator, self).teardown()


if __name__ == '__main__':
    logging.basicConfig(format='%(asctime)s [%(levelname)5s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S',
                        level=logging.DEBUG)
    logging.info('OK')
    pcf = c_pcf_simulator(host='10.69.9.53', username='ute', password='qqwweeRR0-')
    pcf.setup()
    pcf.exec_cli_command_file('/tmp/a.pcf')
