import taf.transport.ssh.connection as ssh_connection
import os
author = "Arunkumar A"
email = "arunkumar.a@nokia.com"
# try:
#    import taf.internal.node
# except ImportError:
#    os.system("pip install taf.internal.node")


class transport_connection(object):
    def __init__(self) -> None:
        ...

    def check_flags_in_swconfig_file(self, swconfigtxt_file, flags):
        file_count = []
        with open(file=swconfigtxt_file, mode="r") as fd:
            i = fd.readlines()
            if flags in i:
                file_count.append(flags)
                return bool(i)
            else:
                return False

    def enable_ssh_connection(self, hostname, username, password, list_of_flag, swconfigfilepath):
        check_connection_status = ssh_connection.connect(hostname, username, password)
        # check_connection_status = ssh_connection.is_connected()
        if not check_connection_status:
            raise Exception("SSH connection is broken. [ Tip ]: Check in connect function")
        else:
            check_file = os.path.exists(swconfigfilepath)
            if check_file:
                check_flag = self.check_flags_in_swconfig_file(swconfigtxt_file=swconfigfilepath, flags=list_of_flag)
                return check_flag
        ssh_connection.Connection.disconnect(self)
