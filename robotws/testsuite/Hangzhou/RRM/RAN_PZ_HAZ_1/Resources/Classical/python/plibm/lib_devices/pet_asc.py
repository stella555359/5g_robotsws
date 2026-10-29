# -*- coding: utf-8 -*-

"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import six
import logging
import paramiko


class MapItem(object):
    pass


class c_pet_asc(object):

    def __init__(self, host, port, username='switch', password='switch', logger=None):
        self.host = host
        self.port = int(port)
        self.username = username
        self.password = password

        self.conn = None
        self.prompt = 'ASC>'
        self.ssh = None
        self.logger = logger or logging.getLogger('PET_TA')

    def connect(self):
        if not bool(self.ssh):
            self.logger.info('Connect to {} ...'.format(self.host))
            self.ssh = paramiko.SSHClient()
            self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            self.ssh.connect(self.host, self.port, self.username, self.password)
            self.chan = self.ssh.invoke_shell()
            for line in self.read_until_prompt():
                self.logger.info(line)
            self.logger.info('Connect ASC done.')

    def read_until_prompt(self):
        response = ''
        while self.prompt not in response:
            if six.PY2:
                response += self.chan.recv(9999)
            else:
                response += self.chan.recv(9999).decode('iso-8859-1')
        return response.splitlines()

    def disconnect(self):
        self.logger.info('Disconnect from ASC')
        if self.ssh:
            self.chan.close()
            self.ssh.close()
            self.ssh = None
        self.logger.info('Disconnect from ASC done.')

    def execute_command(self, command):
        self.connect()
        self.logger.info('Execute command: {}'.format(command))
        self.chan.send(command + '\n')
        response = self.read_until_prompt()
        self.logger.info('Command Response:')
        for line in response:
            self.logger.info(line)
        return '\n'.join(response)

    def get_resource_map(self):
        output = self.execute_command('showgroups').splitlines()
        self.map = {}
        for line in [x for x in output if '0000' in x]:
            item = MapItem()
            item.name = line.strip().split()[0]
            item.user = line.strip().split()[1].strip()
            item.status = line.strip().split()[2]
            item.available = item.status[0] == 'A'
            item.locked = item.status[1] == 'L'
            item.poweron = item.status[2] == 'P'
            self.map[item.name] = item
        return self.map


if __name__ == '__main__':
    import logging
    logging.basicConfig(format='%(asctime)s [%(levelname)5s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S',
                        level=logging.INFO)
    asc = c_pet_asc(host='10.69.65.65', port=3202)
    asc.connect()
    # shenick.stop_running_test_group()
    # asc.execute_command('showgroups')
    map = asc.get_resource_map()
    print(map['Units-1'].user)
    asc.disconnect()
    logging.info('OK')
