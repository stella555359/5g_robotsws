

class pet_ue(object):

    ROBOT_LIBRARY_SCOPE = 'SUITE'

    def __init__(self, **kwargs):
        self.host = kwargs.get('host')
        self.username = kwargs.get('host', 'noklab\\csv5-tester')
        self.password = kwargs.get('host', 'Nokia123!')
        self.serial = kwargs.get('serial', '')

    def showue(self):
        return f'host: {self.host}, serial: {self.serial}'


class pet_uc(object):

    ROBOT_LIBRARY_SCOPE = 'SUITE'

    def __init__(self, **kwargs):
        self.host = kwargs.get('host')
        self.username = kwargs.get('host', 'noklab\\csv5-tester')
        self.password = kwargs.get('host', 'Nokia123!')
        self.serial = kwargs.get('serial', '')

    def showue(self):
        return f'host: {self.host}, serial: {self.serial}'
