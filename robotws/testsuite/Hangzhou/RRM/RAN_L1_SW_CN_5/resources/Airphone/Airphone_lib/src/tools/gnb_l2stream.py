import os

from robot.libraries.BuiltIn import BuiltIn
from common_lib import common_lib
from taf.collectors.tcpdump import tcpdump
from taf.collectors.l2stream3 import l2stream3
from taf.collectors.core import core
from cm import cm
from taf.converters.eventdecoder import eventdecoder
from .tti_stream_mode_convert import *

builtin_obj = BuiltIn()
comm_obj = common_lib()
tcpdump_obj = tcpdump()
l2stream3_obj = l2stream3()
core_obj = core()
eventdecoder_obj = eventdecoder()


class gnb_l2stream_base(object):
    def __init__(self, alias):
        self._setup_l2stream_flag = False
        self.alias = alias
        self.remote_host = None
        self.fct_ip = "192.168.255.1"
        self.webadmin_user = "Nemuadmin"
        self.webadmin_password = "nemuuser"

    def _setup_l2stream(self):
        if not self._setup_l2stream_flag:
            self._setup_l2stream_flag = True
            self.cm_obj = cm()

    def _start_to_capture_gnb_l2stream_log(self, tcpdump_collector_name, options, l2stream_collector_name,
                                           webservice,  destination_ip_addr,  l2_stream_configuration,
                                           sudo_password="ute"
                                           ):
        tcpdump_obj.create_tcpdump_collector(name=tcpdump_collector_name,
                                             options=options,
                                             sudo_password=sudo_password)
        l2stream3_obj.create_sbts_l2stream_collector(name=l2stream_collector_name,
                                                     webservice=webservice,
                                                     destination_ip_addr=destination_ip_addr,
                                                     collector=tcpdump_collector_name,
                                                     l2_stream_configuration=l2_stream_configuration)
        core_obj.setup_collectors(names=l2stream_collector_name)
        core_obj.start_collectors(names=l2stream_collector_name)
        l2stream3_obj.set_suite_alias(l2stream_collector_name)

    def _stop_to_capture_gnb_l2stream_log(self, target_dir, l2stream_collector_name):
        core_obj.stop_collectors(names=l2stream_collector_name)
        core_obj.collect_collectors(names=l2stream_collector_name, target_dir=target_dir)
        core_obj.teardown_collectors(names=l2stream_collector_name)

    def _start_to_capture_gnb_ttitrace(self, tag=None, cell_id="all", up_sw="L2Ps,L2Lo,L2HiPdcp,L2HiRlc"):
        self._setup_l2stream()
        # define log name
        log_name = "gnbtti_{}".format(tag) if tag else "gnbtti"

        # generate admin port
        bts_port, use_ssl = comm_obj.define_admin_port()

        # get swbuild release
        release = builtin_obj.get_variable_value('${RELEASE}')

        # generate executor for admin
        executor = {}
        executor['host'] = self.fct_ip
        executor['user'] = self.webadmin_user
        executor['password'] = self.webadmin_password
        executor['port'] = bts_port
        executor['release'] = release

        # generate ttitrace pci value
        phsicalCellIds = self.cm_obj.get_all_physical_cell_ids() \
            if cell_id.lower() == "all" else self.cm_obj.get_physical_cell_id_for_specific_cell(cellIds=cell_id)

        # localIpAddr = self.cm_obj.get_scf_parameter_value("IPNO-1/IPIF-1/IPADDRESSV4-1:localIpAddr")
        web_card, dest_ip = comm_obj.get_eif_info_of_control_pc()
        options = "-i {} udp and dst port 5678 and dst {}".format(web_card, dest_ip)

        # consist l2stream configuration
        l2_stream_configuration = []
        for sub_up_sw in up_sw.split(','):
            l2_stream_config = {}
            if sub_up_sw.lower().count("l2ps") or sub_up_sw.lower().count("l2lo"):
                l2_stream_config["nr_phy_cell_ids"] = phsicalCellIds
                l2_stream_config["up_sw"] = sub_up_sw
                l2_stream_config["trace_type"] = "Component"
            if sub_up_sw.lower().count("l2hipdcp") or sub_up_sw.lower().count("l2hirlc"):
                l2_stream_config["up_sw"] = sub_up_sw
                l2_stream_config["trace_type"] = "Component"
            if l2_stream_config:
                l2_stream_configuration.append(l2_stream_config)

        self._start_to_capture_gnb_l2stream_log(
                                                tcpdump_collector_name="tcpdump_ttitrace",
                                                options=options,
                                                l2stream_collector_name=log_name,
                                                webservice=executor,
                                                destination_ip_addr=dest_ip,
                                                l2_stream_configuration=l2_stream_configuration,
                                                )

    def _stop_capture_gnb_ttitrace(self, tag=None, target_dir=None, decode_flag=False, filters=None):
        self._setup_l2stream()
        log_name = "gnbtti_{}".format(tag) if tag else "gnbtti"
        if not target_dir:
            target_dir = builtin_obj.get_variable_value('${SAVE LOG DIRECTORY}')
        self._stop_to_capture_gnb_l2stream_log(
                                                target_dir=target_dir,
                                                l2stream_collector_name=log_name,
                                                )
        if decode_flag:
            self._convert_ttitrace_from_pcap_to_excelcsv(tag=tag)
            self._format_tti_in_stream_mode(tag=tag, input_csv_name="output_dl.csv",
                                            output_csv_name="format_output_dl.csv", filters=filters)
            self._format_tti_in_stream_mode(tag=tag, input_csv_name="output_ul.csv",
                                            output_csv_name="format_output_ul.csv", filters=filters)

    def _convert_ttitrace_from_pcap_to_excelcsv(self, tag=None, target_dir=None):
        self._setup_l2stream()
        log_name = "gnbtti_{}".format(tag) if tag else "gnbtti"
        if not target_dir:
            target_dir = builtin_obj.get_variable_value('${SAVE LOG DIRECTORY}')
            log_folder = "{}/{}/tcpdump_ttitrace".format(target_dir, log_name)
        else:
            log_folder = target_dir
        file_path = os.path.join(log_folder, "tcpdump_ttitrace.pcap")
        eventdecoder_obj.create_eventdecoder_converter(name="converter", input_file_path=file_path,
                                                       output_file_format="excelCsv", excel_csv_options="-w")
        eventdecoder_obj.convert(name="converter")
        execdir = builtin_obj.get_variable_value('${EXECDIR}')
        cmd = "cp {}/output_dl.csv {};cp {}/output_ul.csv {}".format(execdir, log_folder, execdir, log_folder)
        comm_obj.execute_cmd_on_pc(cmd)

    def _format_tti_in_stream_mode(self,
                                   input_csv_name,
                                   output_csv_name,
                                   filters=None,
                                   tag=None,
                                   target_dir=None,
                                   ):
        self._setup_l2stream()
        log_name = "gnbtti_{}".format(tag) if tag else "gnbtti"
        if not target_dir:
            target_dir = builtin_obj.get_variable_value('${SAVE LOG DIRECTORY}')
        input_csv_name = "{}/{}/tcpdump_ttitrace/{}".format(target_dir, log_name, input_csv_name)
        output_csv_name = "{}/{}/tcpdump_ttitrace/{}".format(target_dir, log_name, output_csv_name)
        if filters:
            format_tti_stream_mode_with_filters(input_csv_name, output_csv_name, filters)
        else:
            format_tti_stream_mode_no_filters(input_csv_name, output_csv_name)

    def _start_to_capture_gnb_sherpa(self, tag=None, cell_id="all", up_sw="L2Ps,L2Lo,L2HiPdcp,L2HiRlc"):
        self._setup_l2stream()

        # define log name
        log_name = "gnbsherpa_{}".format(tag) if tag else "gnbsherpa"

        # generate admin port
        bts_port, use_ssl = comm_obj.define_admin_port()

        # get swbuild release
        release = builtin_obj.get_variable_value('${RELEASE}')

        # generate executor for admin
        executor = {}
        executor['host'] = self.fct_ip
        executor['user'] = self.webadmin_user
        executor['password'] = self.webadmin_password
        executor['port'] = bts_port
        executor['release'] = release

        # generate ttitrace pci value
        phsicalCellIds = self.cm_obj.get_all_physical_cell_ids() \
            if cell_id.lower() == "all" else self.cm_obj.get_physical_cell_id_for_specific_cell(cell_id=cell_id)

        # localIpAddr = self.cm_obj.get_scf_parameter_value("IPNO-1/IPIF-1/IPADDRESSV4-1:localIpAddr")
        web_card, dest_ip = comm_obj.get_eif_info_of_control_pc()
        options = "-i {} udp and dst {} and dst port 5678".format(web_card, dest_ip)

        # consist l2stream configuration
        l2_stream_configuration = []
        for sub_up_sw in up_sw.split(','):
            l2_stream_config = {}
            if sub_up_sw.lower().count("l2ps") or sub_up_sw.lower().count("l2lo"):
                l2_stream_config["nr_phy_cell_ids"] = phsicalCellIds
                l2_stream_config["up_sw"] = sub_up_sw
                l2_stream_config["trace_type"] = "Sherpa"
            if sub_up_sw.lower().count("l2hipdcp") or sub_up_sw.lower().count("l2hirlc"):
                l2_stream_config["up_sw"] = sub_up_sw
                l2_stream_config["trace_type"] = "Sherpa"
            if l2_stream_config:
                l2_stream_configuration.append(l2_stream_config)

        self._start_to_capture_gnb_l2stream_log(
                                                tcpdump_collector_name="tcpdump_sherpa",
                                                options=options,
                                                l2stream_collector_name=log_name,
                                                webservice=executor,
                                                destination_ip_addr=dest_ip,
                                                l2_stream_configuration=l2_stream_configuration,
                                                )

    def _stop_capture_gnb_sherpa(self, tag, target_dir):
        self._setup_l2stream()
        log_name = "gnbsherpa_{}".format(tag) if tag else "gnbsherpa"
        if not target_dir:
            target_dir = builtin_obj.get_variable_value('${SAVE LOG DIRECTORY}')
        self._stop_to_capture_gnb_l2stream_log(
                                                target_dir=target_dir,
                                                l2stream_collector_name=log_name,
                                                )


class gnb_l2stream_gnb1(object):
    def __init__(self):
        alias = "gnb1"
        self.gnb_l2stream_base_instance_1 = gnb_l2stream_base(alias)

    def start_to_capture_gnb_sherpa(self, tag=None, cell_id="all", up_sw="L2Ps,L2Lo,L2HiPdcp,L2HiRlc"):
        """
        This keyword is used to start sherpa with streaming mode.
         | Input Parameters | Man. | Description |
         | tag              | No   | the file alias like name. |
         | cell_id          | No   | the captured sherpa cell id number like 1,2,3 or all |
         | up_sw            | No   | the captured sherpa cell module,like "L2Ps, L2Lo, L2HiPdcp, L2HiRlc |

        Examples:
         | Start To Capture Gnb Sherpa | tag=sherpatest | cell_id=1,2 | up_sw=L2Ps,L2Lo,L2HiPdcp
         | Start To Capture Gnb Sherpa | tag=sherpatest | cell_id=all | up_sw=L2Ps
        """
        self.gnb_l2stream_base_instance_1._start_to_capture_gnb_sherpa(tag=tag, cell_id=cell_id, up_sw=up_sw)

    def stop_capture_gnb_sherpa(self, tag=None, target_dir=None):
        """
        This keyword is used to stop sherpa with streaming mode.
         | Input Parameters | Man. | Description |
         | tag              | No   | the file alias like name. |
         | target_dir       | No   | the path to save sherpa path |

        Examples:
         | Stop Capture Gnb Sherpa | tag=sherpa | target_dir=/tmp
        """
        self.gnb_l2stream_base_instance_1._stop_capture_gnb_sherpa(tag, target_dir)

    def start_to_capture_gnb_ttitrace(self, tag=None, cell_id="all", up_sw="L2Ps,L2Lo,L2HiPdcp,L2HiRlc"):
        """
        This keyword is used to start ttitrace with streaming mode.
         | Input Parameters | Man. | Description |
         | tag              | No   | the file alias like name. |
         | cell_id          | No   | the captured ttitrace cell id number like 1,2,3 or all |
         | up_sw            | No   | the captured ttitrace cell module,like "L2Ps, L2Lo, L2HiPdcp, L2HiRlc |

        Examples:
         | Start To Capture Gnb Ttitrace | tag=ttitest | cell_id=1,2 | up_sw=L2Ps,L2Lo,L2HiPdcp
         | Start To Capture Gnb Ttitrace | tag=ttitest | cell_id=all | up_sw=L2Ps
        """
        self.gnb_l2stream_base_instance_1._start_to_capture_gnb_ttitrace(tag=tag,
                                                                         cell_id=cell_id,
                                                                         up_sw=up_sw)

    def stop_capture_gnb_ttitrace(self, tag=None, target_dir=None, decode_flag=False, filters=None):
        """
        This keyword is used to stop ttitrace with streaming mode.
         | Input Parameters | Man. | Description |
         | tag              | No   | the file alias like name. |
         | target_dir       | No   | the path to save ttitrace path |

        Examples:
         | Stop Capture Gnb Ttitrace | tag=ttitest | target_dir=/tmp
        """
        self.gnb_l2stream_base_instance_1._stop_capture_gnb_ttitrace(tag=tag,
                                                                     target_dir=target_dir,
                                                                     decode_flag=decode_flag,
                                                                     filters=filters)

    def convert_ttitrace_from_pcap_to_excelcsv(self, tag=None, target_dir=None):
        """
        This keyword is used to convert ttitrace pcap to excelcsv format.
         | Input Parameters | Man. | Description |
         | tag              | No   | the file alias like name. |
         | target_dir       | No   | the path to save ttitrace csv path |

        Examples:
         | Convert Ttitrace From Pcap To Excelcsv | tag=ttitest | target_dir=/tmp
        """
        self.gnb_l2stream_base_instance_1._convert_ttitrace_from_pcap_to_excelcsv(tag=tag, target_dir=target_dir)

    def format_tti_in_stream_mode(self,
                                  input_csv_name,
                                  output_csv_name,
                                  filters=None,
                                  tag=None,
                                  target_dir=None
                                  ):
        """
        This keyword is to convert tti collected by stream mode.
         | Input Parameters | Man. | Description |
         | input_csv_name   | Yes   | the inputting file name you want to convert. |
         | output_csv_name  | Yes   | the outputing file name you want to convert. |
         | filters          | No   | the outputing file name you want to convert. |
         | target_dir       | No   | the path to save ttitrace csv path |

        Examples:
         | Format Tti In Stream Mode | tag=ttitest | input_csv_name=output_dl.csv |
         | output_csv_name=format_output_dl.csv |
        """
        self.gnb_l2stream_base_instance_1._format_tti_in_stream_mode(input_csv_name=input_csv_name,
                                                                     output_csv_name=output_csv_name,
                                                                     filters=filters,
                                                                     tag=tag,
                                                                     target_dir=target_dir,
                                                                     )


class gnb_l2stream_gnb2(object):
    def __init__(self):
        alias = "gnb2"
        self.gnb_l2stream_base_instance_2 = gnb_l2stream_base(alias)


class gnb_l2stream(gnb_l2stream_gnb1, gnb_l2stream_gnb2):
    def __init__(self):
        gnb_l2stream_gnb1.__init__(self)
        gnb_l2stream_gnb2.__init__(self)


if __name__ == "__main__":
    gnb_l2stream_obj = gnb_l2stream()
    help(gnb_l2stream_obj)
