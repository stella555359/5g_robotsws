import os
from taf.ul.sc.util.helpers import generate_unix_remote_device
from moler.device import DeviceFactory


class VcpManager(object):
    """VCP server opreations"""

    BUILDS_PATH = '/home/stack/Builds/'
    VNFS_PATH = '/home/stack/VNFs'

    def __init__(self, vcp_ip, vcp_user_name, vcp_password):
        """
        :vcp_ip: VCP ip
        :vcp_user_name: VCP user_name
        :vcp_password: VCP password
        """
        self.vcp_manager = self._get_vcp_device(vcp_ip, vcp_user_name, vcp_password)

    def deploy_build(self, wft_build_path):
        """
        Downloads and creates CU image.
        :wft_build_path: wft path to location from where qcow2 can be downloaded
        :return: None
        """
        self.execute_cmd(vcp_dir=self.BUILDS_PATH,
                         command='wget {}'.format(wft_build_path),
                         timeout=900)
        path_on_vcp = self.BUILDS_PATH + os.path.basename(wft_build_path)
        self.execute_cmd(vcp_dir=self.VNFS_PATH,
                         command='./upload_build_image.sh {build_path}'.format(build_path=path_on_vcp))

    def update_build_name(self, target_build, cu_dir):
        """
        Updates image parameter to target_build in 5gbts_heat.env file for given CU.
        :target_build: string eg. 12.200.25
        :cu_dir: path to CU dir with  5gbts_heat.env file
        :return: None
        """
        self._update_heat_env_parameter(par='image', val=target_build, cu_dir=cu_dir)

    def update_cluster_id(self, new_cluster_id_value, cu_dir):
        """
        Updates cluster_id parameter to new_cluster_id_value in 5gbts_heat.env file for given CU.
        :new_cluster_id_value: desired cluster_id value
        :cu_dir: path to CU dir with  5gbts_heat.env file
        :return: None
        """
        self._update_heat_env_parameter(par='cluster_id',
                                        val='"{0}"'.format(new_cluster_id_value),  # inner " are needed
                                        cu_dir=cu_dir)

    def update_cu_yaml_config(self, wft_addons_path, cu_dir):
        """
        Updates *yaml config for given CU.
        :wft_addons_path: wft path to location from where Addons-nnnn.txz can be downloaded
        :cu_dir: path to CU dir with  5gbts_heat.env file
        :return: None
        """
        self.vcp_manager.get_cmd(cmd_name="cd", cmd_params={"path": cu_dir})()
        self.vcp_manager.get_cmd(cmd_name="mkdir", cmd_params={"path": 'addons'})()
        self.vcp_manager.get_cmd(cmd_name="cd", cmd_params={"path": 'addons'})()
        self.execute_cmd(vcp_dir=cu_dir + '/addons', command='wget {}'.format(wft_addons_path))
        addons_file = os.path.basename(wft_addons_path)
        self.vcp_manager.get_cmd(cmd_name='tar', cmd_params={'options': 'Jxvf', 'file': addons_file})()
        self.vcp_manager.get_cmd(cmd_name='tar', cmd_params={'options': '-xvzf', 'file': 'HeatTemplates.tgz'})()
        self.vcp_manager.get_cmd(cmd_name="cd", cmd_params={"path": 'OSP/5G'})()
        self.vcp_manager.get_cmd(cmd_name="cp", cmd_params={"src": "*yaml", "dst": cu_dir})()
        self.vcp_manager.get_cmd(cmd_name="cp", cmd_params={"src": "modules/*", "dst": cu_dir + "/modules/"})()
        self.vcp_manager.get_cmd(cmd_name="cd", cmd_params={"path": cu_dir})()
        self.vcp_manager.get_cmd(cmd_name="rm", cmd_params={"options": "-rf", "file": "addons"})()

    def execute_cmd(self, command, vcp_dir=None, timeout=300):
        """
        Executes command from vcp_dir vcp_cmd.
        :vcp_dir: Location on VCP where
        :vcp_cmd: command to run
        :timeout: command execution wait time
        :return: None
        """
        if vcp_dir:
            self.vcp_manager.get_cmd(cmd_name="cd", cmd_params={"path": vcp_dir})()
        cmd = self.vcp_manager.get_cmd(
            cmd_name='run_script',
            cmd_params={'script_command': command})
        cmd(timeout=timeout)

    def _update_heat_env_parameter(self, par, val, cu_dir):
        """
        Updates 5gbts_heat.env parameter value.
        Note. 'parameter: value' format is required.
        :par: string eg. image, cluster_id, ...
        :val: new value a parameter (par)
        :cu_dir: path to CU dir with  5gbts_heat.env file
        :return: None
        """
        self.vcp_manager.get_cmd(cmd_name="cd", cmd_params={"path": cu_dir})()
        update_cmd = self.vcp_manager.get_cmd(
            cmd_name='sed',
            cmd_params={'options': '-i',
                        'scripts': ['s/{par}: .*/{par}: {val}/'.format(par=par, val=val)],
                        'input_files': ['5gbts_heat.env']})
        update_cmd()

    def _get_vcp_device(self, vcp_ip, vcp_user_name, vcp_password):
        """
        Creates vcp moler device that will be used for further operations.
        :vcp_ip: vcp ip
        :vcp_user_name: vcp user_name
        :vcp_password: vcp vcp_password
        :return: moler device
        """
        generate_unix_remote_device(device_name="vcp",
                                    host=vcp_ip,
                                    login=vcp_user_name,
                                    password=vcp_password)
        manager = DeviceFactory.get_device("vcp")
        manager.goto_state("UNIX_REMOTE")
        prepare_cmd = manager.get_cmd(
            cmd_name='run_script',
            cmd_params={'script_command': 'source ~/overcloud-krk-sb15rc'})
        prepare_cmd()
        return manager
