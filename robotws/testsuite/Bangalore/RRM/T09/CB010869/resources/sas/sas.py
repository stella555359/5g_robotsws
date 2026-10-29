import os
from robot.libraries.BuiltIn import BuiltIn
from base_lib.ute_fsmaccess import ute_fsmaccess
from base_lib.ta_ssh_telnet import ta_ssh_telnet
from common_lib import common_lib
import traceback

curdir = os.path.dirname(__file__)
ssh_obj = ta_ssh_telnet()
comm_obj = common_lib()
builtin_obj = BuiltIn()


class sas_certificate(object):
    def __init__(self, alias):
        self.alias = alias
        self.remote_host = None
        self.source_file_path = "%s/SASSim/" % curdir
        self.target_file_path = "/rom/etc/sas/"
        self.name_source_target = [
            ("nokia04.cert", "cbrsVendorCertChain.pem"),
            ("nokia04.key", "cbrsPrivKey.pem.crk"),
            ("ca.cert", "cbrsRootCACertificate.pem")
        ]

    def _install_sas_certificate(self):
        self.fsm_obj = ute_fsmaccess()
        self.fsm_obj.setup_enb_fsm_access(remote_host=self.remote_host, alias=self.alias, fallback_prompt="#",
                                          host="192.168.255.129")
        self.fsm_obj.execute_command_on_enb("rm -rf %s" % self.target_file_path, alias=self.alias)
        self.fsm_obj.execute_command_on_enb("mkdir %s" % self.target_file_path, alias=self.alias)
        for source, target in self.name_source_target:
            self.fsm_obj.put_enb_file(self.source_file_path +
                                      source, self.target_file_path +
                                      target, alias=self.alias)
        self.fsm_obj.execute_command_on_enb(
            "ln -s /rom/etc/sas/cbrsRootCACertificate.pem /rom/etc/sas/aaae4089.0",
            alias=self.alias)
        self.fsm_obj.execute_command_on_enb("chown btssw:btssw /rom/etc/sas/ -R", alias=self.alias)


class sas(object):
    """
    user guide:
    https://confluence.int.net.nokia.com/pages/viewpage.action?spaceKey=siso1test&title=sas+simulator+user+guide
    https://confluence.int.net.nokia.com/login.action?os_destination=%2Fpages%2Fviewpage.
    action%3FspaceKey%3DSCPETNJ%26title%3DHow%2Bto%2BEnable%2BCBRS&permissionViolation=true
    """

    def __init__(self):
        self.sas_start = False
        self.source_file_path = "%s/SASSim/" % curdir

    def _update_sas_config(self):
        comm_obj.execute_cmd_on_pc("rm -rf %s/SASlog/*.log" % self.source_file_path)
        comm_obj.modify_parameter_defined_as_key_equal_value("%s/SAS_Sim.conf" % self.source_file_path,
                                                             "port_number=4433")

    def start_sas_server(self):
        sas1 = sas_certificate("enb1")
        builtin_obj.log("step: install sas certificate in enb1")
        sas1._install_sas_certificate()
        enb2_pc = builtin_obj.get_variable_value('${tl.test_pcs[1].default_ssh_connection_details.addr}')
        if enb2_pc is not None:
            builtin_obj.log("step: install sas certificate in enb2")
            sas2 = sas_certificate("enb2")
            sas2.remote_host = enb2_pc
            sas2._install_sas_certificate()
        builtin_obj.log("step: update sas config file")
        self._update_sas_config()
        builtin_obj.log("step: restart sas server")
        old_pids = comm_obj.get_linux_process_id("python", "SAS_Sim_persistent")
        comm_obj.kill_linux_process(old_pids)
        comm_obj.execute_cmd_on_pc("cd %s;nohup python SAS_Sim_persistent.py > /tmp/nohup_sas.out 2>&1 &"
                                   % self.source_file_path,
                                   prompt="nohup")
        pid = comm_obj.get_linux_process_id("SAS_Sim_persistent.py")
        assert (len(pid) > 0)
        self.sas_start = True

    def collect_sas_logs(self, tag=""):
        if self.sas_start is True:
            if "startup" in tag:
                tag = "%s_logs" % tag
            save_log_dir = comm_obj._get_save_log_dir(tag)
            comm_obj.execute_cmd_on_pc(("cp -r %s/SASlog %s" % (self.source_file_path, save_log_dir)),
                                       timeout="60")


#     def stop_sas_server(self):
#         if self.sas_start is True:
#             ssh_obj.disconnect_from_host(self.sas_conn)
#             self.collect_sas_logs()

if __name__ == "__main__":
    sas_obj = sas()
    help(sas_obj)
