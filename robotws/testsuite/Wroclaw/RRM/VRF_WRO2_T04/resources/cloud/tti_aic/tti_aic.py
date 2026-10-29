import os.path
import time
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.VduSession import VduAdminSession
from taf.converters.eventdecoder import eventdecoder


def update_uplane_configuration(uplane_ip_addr='10.0.1.1', uplane_port=5678, dscp=0, vdu_id=0):
    with VduAdminSession(vdu_id=vdu_id) as admin:
        result = admin.update_uplane_configuration(uplane_ip_addr, uplane_port, dscp)
        time.sleep(10)
        return admin.get_trs_api_operation_status(result)


def start_uplane_trace_on_vdu(component, dn_cell_list=[], trace_type='Component', vdu_id=0):
    with VduAdminSession(vdu_id=vdu_id) as admin:
        admin.start_uplane_trace_stream(target_component=component, nr_cell_dn_list=dn_cell_list,
                                        trace_type=trace_type)
        time.sleep(3)
        active_trace = admin.get_active_trace_streams()
        return active_trace[0]['trace_id']


def stop_uplane_trace_on_vdu(vdu_id=0):
    with VduAdminSession(vdu_id=vdu_id) as admin:
        active_trace = admin.get_active_trace_streams()
        admin.stop_uplane_trace_stream(trace_id=active_trace[0]['trace_id'])


def convert_tti_to_json(input_file_path):
    ed = eventdecoder()
    output_filepath = input_file_path.replace('.pcap', '')
    logger.info(output_filepath, also_console=True)
    ed.create_eventdecoder_converter(name='converter', input_file_path=input_file_path,
                                     output_file_format='json',
                                     output_file_path=output_filepath)
    ed.convert(name='converter')
    return output_filepath + '.json'
