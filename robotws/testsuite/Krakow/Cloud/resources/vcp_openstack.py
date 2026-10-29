from .vcp_manager import VcpManager


class VcpOpenstack(VcpManager):
    def __init__(self):
        self.vcp_manager = None

    def setup(self, vcp_ip, vcp_user_name, vcp_password):
        """
        :vcp_ip: VCP ip
        :vcp_user_name: VCP user_name
        :vcp_password: VCP password
        """
        self.vcp_manager = self._get_vcp_device(vcp_ip, vcp_user_name, vcp_password)

    def server_start(self, server):
        """
        :server: Server name or id to start
        """
        self.execute_cmd('openstack server start ' + server)

    def server_stop(self, server):
        """
        :server: Server name or id to stop
        """
        self.execute_cmd('openstack server stop ' + server)
