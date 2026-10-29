import paramiko
import os
import shutil
from taf.internal.aliasing import aliasing_scope
from functools import wraps
import logging


class NoSwconfigException(Exception):
    pass


class AliasInUse(Exception):
    pass


class SwconfigAtom(object):
    def __init__(self,
                 bts_host="192.168.255.129",
                 username="toor4nsn",
                 password="oZPS0POrRieRtu",
                 swconfig_output_directory="/home/ute/",
                 swconfig_output_filename="swconfig_tmp.txt",
                 alias="default"
                 ):
        self.bts_host = bts_host
        self.username = username
        self.password = password
        self.swconfig_output_filename = alias + "_" + swconfig_output_filename
        if swconfig_output_directory[-1] != "/":
            self.swconfig_output_directory = swconfig_output_directory + "/"
        else:
            self.swconfig_output_directory = swconfig_output_directory
        self.swconfig_output_path = self.swconfig_output_directory + self.swconfig_output_filename

    def disconnect(self):
        pass


class SwconfigOperations(object):
    """
    The Swconfig Operations module makes operations on swconfig.txt possible.
    Main purpose of this library is ability to modify, save, upload and check swconfig file on multiple bts's with
    object aliasing.
    Example of use in RobotFramework:
        *** Test Cases ***
        Modify Swconfig Flag
            Setup Swconfig Operations    alias=swconfig_1
            ${flag}    get_swconfig_flag_value     0x1003F    connection=swconfig_1
            Log To Console   ${\n} This is value of 0x1003F: ${flag} ${\n}
            Replace Swconfig Flag Value    0x1003F    1    activate=false    connection=swconfig_1
            Upload Swconfig To Bts    reboot_bts='false'    connection=swconfig_1
            Teardown All Aliases For Swconfig Operations

    """

    lookup_handler, store = aliasing_scope("connection", SwconfigAtom)

    def __init__(self):
        self.lookup_handler.store = self.store

    def _extract_connection_from_alias(func):
        @wraps(func)
        def wrapper(self, *args, **kwargs):
            bool_array = [str(arg).startswith("alias=") for arg in args]
            is_alias_in_args = any(bool_array)
            if "alias" in dict(kwargs):
                kwargs["connection"] = kwargs["alias"]
                kwargs.pop("alias")
            elif is_alias_in_args:
                alias_expression = args[bool_array.index(True)]
                alias = alias_expression[alias_expression.index('=') + 1:]
                kwargs["connection"] = alias
                args = list(args)
                args.pop(bool_array.index(True))
            else:
                for index, arg in enumerate(list(args)):
                    if arg in [item[0] for item in self.store.all]:
                        kwargs["connection"] = arg
                        args = args[:index] + args[index + 1:]
            kwargs.pop("alias", None)
            return func(self, *args, **kwargs)
        return wrapper

    def setup_swconfig_operations(self,
                                  bts_host="192.168.255.129",
                                  username="toor4nsn",
                                  password="oZPS0POrRieRtu",
                                  swconfig_output_directory="/home/ute/",
                                  swconfig_output_filename='swconfig_tmp.txt',
                                  name="default",
                                  **kwargs
                                  ):
        """
        Setup Swconfig Operations class.

        :param string bts_host: BTS IP Address.
        :param string username: AdminApi Username.
        :param string password: AdminApi Password.
        :param string swconfig_output_directory: Directory where swconfig will be stored on local machine.
        :param string swconfig_output_filename: Filename of stored swconfig.
        :param string name: connection alias.
        """
        if "alias" in kwargs.keys() and name == "default":
            name = kwargs["alias"]
        if name in [item[0] for item in self.store.all]:
            raise AliasInUse("Alias ({}) exists. Please remove it to reuse.".format(name))
        connection = SwconfigAtom(
                 bts_host=bts_host,
                 username=username,
                 password=password,
                 swconfig_output_directory=swconfig_output_directory,
                 swconfig_output_filename=swconfig_output_filename,
                 alias=name
                 )
        self.store.add(connection, name)
        self._get_swconfig(connection=name)
        return connection

    @_extract_connection_from_alias
    @lookup_handler.implicit_lookup
    def teardown_swconfig_operations(self, connection=None, **kwargs):
        """
        Teardown Swconfig Operations class.

        :param string connection: connection alias.
        """
        self.teardown(connection)

    def teardown_all_aliases_for_swconfig_operations(self):
        for connection in [item[1] for item in self.store.all]:
            self.teardown(connection)

    @lookup_handler.implicit_lookup
    def teardown(self, connection=None):
        if connection not in [item[1] for item in self.store.all]:
            logging.warning("Connection: {} not found in AdminConnection objects".format(connection))
        connection.disconnect()
        self.store.remove({item[1]: item[0] for item in self.store.all}[connection])
        logging.info("AdminConnection: {} closed".format(connection))

    @_extract_connection_from_alias
    @lookup_handler.implicit_lookup
    def _get_swconfig(self, connection=None):
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            client.connect(connection.bts_host, username=connection.username, password=connection.password)
            sftp = client.open_sftp()
            if not sftp.stat('/ffs/run/swconfig.txt'):
                raise NoSwconfigException()
            sftp.get('/ffs/run/swconfig.txt', connection.swconfig_output_path)
        finally:
            client.close()
        return connection.swconfig_output_path

    @_extract_connection_from_alias
    @lookup_handler.implicit_lookup
    def find_flag(self, flag, connection=None):
        """
        Searching for flag in current swconfig.

        :param string flag: flag that is searched.
        :param string connection: connection alias.
        :return : returns tuple: (<flag_activate_status>, <flag>)
        """
        with open(connection.swconfig_output_path, 'r+') as f1:
            flag_exist = False
            for line in f1.readlines():
                if line.find(flag) != -1:
                    if line.startswith('#'):
                        flag_exist = True
                        return False, flag
                    else:
                        flag_exist = True
                        return True, flag
            if not flag_exist:
                raise Exception('Flag ' + flag + ' not found in current swconfig')

    @_extract_connection_from_alias
    @lookup_handler.implicit_lookup
    def get_swconfig_flag_value(self, flag, reload_swconfig='false',  connection=None):
        """
        Searching for flag value in current swconfig.

        :param string flag: flag that is searched.
        :param boolean reload_swconfig: Defines do swconfig should be downloaded again.
        :param string connection: connection alias.
        :return : returns flag value.
        """
        if reload_swconfig.lower() == 'true':
            self._get_swconfig(connection=connection)
        is_commented, flag = self.find_flag(flag, connection)
        with open(connection.swconfig_output_path, 'r+') as f1:
            for line in f1.readlines():
                if line.find(flag) != -1:
                    value = line.split('=', 1)[1].split('#')[0]
        return value

    @_extract_connection_from_alias
    @lookup_handler.implicit_lookup
    def get_swconfig_local_path(self, connection=None):
        """
         Returns stored swconfig file path.

         :return : swconfig local file path.
         """
        return connection.swconfig_output_path

    @_extract_connection_from_alias
    @lookup_handler.implicit_lookup
    def replace_swconfig_flag_value(self, flag, new_value, activate, connection=None):
        """
         Replace swconfig flag in local swconfig.

         :param string flag: flag that's value needs to be replaced.
         :param string new_value: new value.
         :param string activate: 'true' or 'false' - defines do flag should be commented.
         :param string connection: connection alias.
        """
        is_commented, flag = self.find_flag(flag, connection)
        swconfig_path_out = connection.swconfig_output_path.replace(connection.swconfig_output_filename, 'stmp.txt')
        with open(connection.swconfig_output_path, 'r') as f_in:
            f_in_data = f_in.readlines()
        with open(swconfig_path_out, 'w') as f_in:
            for line in f_in_data:
                if line.find(flag) != -1:
                    line = self._flag_activate(line, activate)
                    value = line.split('=', 1)[1].split('#')[0]
                    if value.endswith('\n'):
                        f_in.write(line.replace(value, new_value + '\n'))
                    else:
                        f_in.write(line.replace(value, new_value + '\t'))
                else:
                    f_in.write(line)
        shutil.copyfile(swconfig_path_out, connection.swconfig_output_path)

    @staticmethod
    def _flag_activate(line, boolean):
        line = line.lstrip()
        result_line = False
        if boolean.lower() == 'true' and line.startswith('#'):
            line = line.lstrip('#')
            result_line = line
        elif boolean.lower() == 'true' and not line.startswith('#'):
            result_line = line
        elif boolean.lower() == 'false' and line.startswith('#'):
            result_line = line
        elif boolean.lower() == 'false' and not line.startswith('#'):
            line = "#" + str(line)
            result_line = line
        if result_line:
            return result_line
        else:
            raise Exception("Cant prepare line")

    @_extract_connection_from_alias
    @lookup_handler.implicit_lookup
    def upload_swconfig_to_bts(self, reboot_bts='false', connection=None):
        """
         Send modified swconfig to BTS and optionally reboots BTS.

         :param string reboot_bts: flag that's value needs to be replaced.
         :param string connection: connection alias.
         :return: body of uploaded swconfig.
        """
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            client.connect(connection.bts_host, username=connection.username, password=connection.password)
            sftp = client.open_sftp()
            sftp.put(connection.swconfig_output_path, '/ffs/run/swconfig.txt')
            if not sftp.stat('/ffs/run/swconfig.txt'):
                raise NoSwconfigException()
            _stdin, _stdout, _stderr = client.exec_command("sync")
            _stdin, _stdout, _stderr = client.exec_command("cat /ffs/run/swconfig.txt")
            swconfig_body = _stdout.read().decode()
            if reboot_bts.lower() == 'true':
                _stdin, _stdout, _stderr = client.exec_command("reboot")
                _stdout.read().decode()
        finally:
            client.close()
        return swconfig_body
