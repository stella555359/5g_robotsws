from taf.transport.ssh import interface

'''
To get login and password from UEPC you need to config your cgwin env variables.
First you need to comment or remove below lines from $HOME/.bashrc file
# If not running interactively, don't do anything
#[[ "$-" != *i* ]] && return

If you got it, you need to add qxdm_login and qxdm_password variables do the same file. You can do it by writing to the
end of a file below lines
export qxdm_login=thedude@nokia.com
export qxdm_pass=thedudepas

Done !
'''


class LKCred:
    def __init__(self):
        self.login = None
        self.password = None
        self.ssh_client = None
        self.get_pass_cmd = 'env | grep qxdm_pass'
        self.get_login_cmd = 'env | grep qxdm_login'

    def get_credentials(self, uepc_ip, ue_pc_username, ue_pc_password):
        self.ssh_client = interface.ssh().connect_to(uepc_ip, ue_pc_username, ue_pc_password)

        self.ssh_client.send_command(self.get_pass_cmd)
        qxdm_password = self.ssh_client.read_output().strip().split("=")[1]
        self.ssh_client.send_command(self.get_login_cmd)
        qxdm_login = self.ssh_client.read_output().strip().split("=")[1]

        if not qxdm_login or not qxdm_password:
            raise EnvironmentError("Can't read Licence Keeper credentials")

        return {'login': qxdm_login, 'password': qxdm_password}
