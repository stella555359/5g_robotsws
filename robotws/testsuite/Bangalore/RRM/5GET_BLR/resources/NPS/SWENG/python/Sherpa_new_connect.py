import sys
import StringTool
from taf.gnb.oam.coam.admin import AdminConnection

CELL_ID = '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1'


class Sherpa_new_connect:
    """
    new connect via coam with start and stop for l2ps traces
    cell_path default value is good for UTE TLs
    """
    managed_admin_connection = None

    def start_trace(self, myip, l2ps=True, l2lo=True, l2hi=True, cell_path=CELL_ID):
        StringTool.datedConsole(
            "start_trace PARAMETERS:   {}   {}   {}   {}   {}".format(myip, l2ps, l2lo, l2hi, cell_path))
        trace_ty1 = ""
        trace_ty2 = ""
        up_1 = ""
        up_2 = ""
        self.managed_admin_connection = AdminConnection(
            bts_host=myip,
            bts_port="443",
            username="Nemuadmin",
            password="nemuuser",
            use_ssl=True,
            update_interval=5000,
            admin_api_log_dir="",
            name="default",
            reconnect_with_default_on_failure=False)
        if l2ps:
            trace_ty1 = "Component"
            trace_ty2 = "Sherpa"
            up_1 = "L2Ps"
            up_2 = "L2Ps"
            self.send_requests(trace_ty1, trace_ty2, up_1, up_2, cell_path)
        if l2lo:
            trace_ty1 = "Component"
            trace_ty2 = "Sherpa"
            up_1 = "L2Lo"
            up_2 = "L2Lo"
            self.send_requests(trace_ty1, trace_ty2, up_1, up_2, cell_path)
        if l2hi:
            trace_ty1 = "Component"
            trace_ty2 = "Component"
            up_1 = "L2HiPdcp"
            up_2 = "L2HiRlc"
            self.send_requests(trace_ty1, trace_ty2, up_1, up_2, cell_path)

    def send_requests(self, trace_ty1, trace_ty2, up_1, up_2, cell_path):
        StringTool.datedConsole(
            "send_requests PARAMETERS:   {}   {}   {}   {}   {}".format(trace_ty1, trace_ty2, up_1, up_2, cell_path))
        if up_1.startswith('L2Hi'):
            self.managed_admin_connection.start_uplane_l2_trace(
                source_ip="10.0.1.2",
                vlan=1,
                dscp=32,
                destination_ip="10.0.1.1",
                destination_port=5678,
                nr_cell_dns=[],
                trace_type=trace_ty1,
                up_sw=up_1)
            self.managed_admin_connection.start_uplane_l2_trace(
                source_ip="10.0.1.2",
                vlan=1,
                dscp=32,
                destination_ip="10.0.1.1",
                destination_port=5678,
                nr_cell_dns=[cell_path],
                trace_type=trace_ty2,
                up_sw=up_2)
        else:
            self.managed_admin_connection.start_uplane_l2_trace(
                source_ip="10.0.1.2",
                vlan=1,
                dscp=32,
                destination_ip="10.0.1.1",
                destination_port=5678,
                nr_cell_dns=[cell_path],
                trace_type=trace_ty1,
                up_sw=up_1)
            self.managed_admin_connection.start_uplane_l2_trace(
                source_ip="10.0.1.2",
                vlan=1,
                dscp=32,
                destination_ip="10.0.1.1",
                destination_port=5678,
                nr_cell_dns=[cell_path],
                trace_type=trace_ty2,
                up_sw=up_2)

    def stop_trace(self, myip, l2ps, l2lo, l2hi):
        StringTool.datedConsole("stop_trace is running")
        if l2ps:
            StringTool.datedConsole(str(l2ps))
            try:
                self.managed_admin_connection.stop_uplane_l2_trace(trace_type="L2Ps", up_sw="Component")
                self.managed_admin_connection.stop_uplane_l2_trace(trace_type="L2Ps", up_sw="Sherpa")
            except Exception:
                StringTool.datedConsole(sys.exc_info())
        if l2lo:
            StringTool.datedConsole(str(l2lo))
            try:
                self.managed_admin_connection.stop_uplane_l2_trace(trace_type="l2lo", up_sw="Component")
                self.managed_admin_connection.stop_uplane_l2_trace(trace_type="L2Lo", up_sw="Sherpa")
            except Exception:
                StringTool.datedConsole(sys.exc_info())
        if l2hi:
            StringTool.datedConsole(str(l2hi))
            try:
                self.managed_admin_connection.stop_uplane_l2_trace(trace_type="L2HiRlc", up_sw="Component")
                self.managed_admin_connection.stop_uplane_l2_trace(trace_type="L2HiPdcp", up_sw="Component")
            except Exception:
                StringTool.datedConsole(sys.exc_info())
