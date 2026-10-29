from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.transfer_files import download_files
from taf.rfrl.utilities.converters.converters import convert_pcap_to_csv
from taf.rfrl.ue.connections.device_aliases import ue_pc as ue_pc_name
from taf.rfrl.bts.connections import device_aliases as connection_names
from robot.libraries.BuiltIn import BuiltIn
from moler.device import DeviceFactory


class bip_operations:

    def __init__(self):
        self.cmd_tshark = None
        self.wireshark_path = r"/cygdrive/c/Program\ Files/Wireshark"

    @load_moler_configuration_from_tl()
    def start_bip_on_pc(self, file_name):
        ue_pc = DeviceFactory.get_device(name=ue_pc_name.format(0))
        self.cmd_tshark = ue_pc.get_cmd(cmd_name="run_script",
                                        cmd_params={
                                            'script_command': "{}/tshark.exe -c 100000 -i "
                                                              "'Ethernet 2' -w /cygwin64/{}.pcap".format(
                                                                self.wireshark_path, file_name)})
        self.cmd_tshark.start(timeout=60)

    @load_moler_configuration_from_tl()
    def wait_till_bip_collection_finished(self):
        self.cmd_tshark.await_done()

    @load_moler_configuration_from_tl()
    def download_bip_to_vm(self, file_name, output_dir):
        download_files(
            local_dir=output_dir,
            remote_file="{}.pcap".format(file_name),
            device_name=ue_pc_name.format(0),
            remote_dir="/")

    @load_moler_configuration_from_tl()
    def set_pcap_file_permission(self, file_name):
        vm = DeviceFactory.get_device(name='UnixLocal')
        vm.goto_state('UNIX_LOCAL')
        chmod_cmd = vm.get_cmd(cmd_name='chmod', cmd_params={'permission': '777', 'filename': "{}".format(file_name)})
        chmod_cmd()

    @load_moler_configuration_from_tl()
    def set_up_bip_on_asoe(self):
        gnb = DeviceFactory.get_device(name=connection_names.ssh_bts_du.format('GNB', 0, 0))
        gnb.goto_state("FCT")
        ddal_cmd = gnb.get_cmd(cmd_name="run_script",
                               cmd_params={
                                   'script_command': "ddal -s ddal_sfp_ctrl_set 1 DDAL_SFP_CTRL_TX_DIS "
                                                     "DDAL_SFP_TX_ENABLE"})
        enter_cli_cmd = gnb.get_cmd(cmd_name="run_script",
                                    cmd_params={
                                        'script_command': "cli -k 1234",
                                        'prompt': "<0>%"})
        set_cli_cmd = gnb.get_cmd(cmd_name="run_script",
                                  cmd_params={
                                      'script_command': "set port 16 up",
                                      'prompt': "<0>%"})
        exit_cli_cmd = gnb.get_cmd(cmd_name="run_script",
                                   cmd_params={
                                       'script_command': "exit"})
        ffs_cmd = gnb.get_cmd(cmd_name="run_script",
                              cmd_params={
                                  'script_command': "/usr/bin/lfs-nw_switch-mirror-tool.sh -S 1010"
                                                    " -f L1_L2_LOKIA_SNF -d 16"})
        ddal_cmd()
        enter_cli_cmd()
        set_cli_cmd()
        exit_cli_cmd()
        ffs_cmd()

    def convert_pcap_to_csv_for_PrachReceiveReq(self):
        output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
        file_name = BuiltIn().get_variable_value("${file_name}")
        convert_pcap_to_csv(
            pcap_file="{}/{}.pcap".format(output_dir, file_name),
            csv_file="{}/{}_PrachReceiveReq.csv".format(output_dir, file_name),
            fields=["_ws.col.Info", "3gpp.sfn", "3gpp.slot"],
            filters=["uldata_prachreceivereq"]
        )
