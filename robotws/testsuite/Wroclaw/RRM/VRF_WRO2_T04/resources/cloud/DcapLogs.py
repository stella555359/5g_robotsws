from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_robot_output_dir
import zipfile
from DcapSession import DcapSession
from aic_variables import mrbts_id, nrbts_id
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import wait_until_function_succeeds


class DcapLogs:
    def __init__(self):
        self.syslog_id_vdu = None
        self.syslog_id_vcu = None
        self.tti_id_vdu = None

    def start_syslog_on_vdu(self):
        with DcapSession(mrbts_id=mrbts_id, unit_type='vdu') as vdu:
            trace_id = vdu.dcap.start_trace(bts=vdu.bts_info, vdu_custom_profile=['syslogVdu', 'snapshotVdu'])
            self.syslog_id_vdu = trace_id['tracer_id']
            self.wait_for_trace_status(vdu, self.syslog_id_vdu, expected_status='running')
            logger.info(self.syslog_id_vdu, also_console=True)
        return self.syslog_id_vdu

    def stop_syslog_on_vdu_and_collect_snapshot(self):
        with DcapSession(mrbts_id=mrbts_id, unit_type='vdu') as vdu:
            vdu.dcap.stop_trace(self.syslog_id_vdu)
            self.wait_for_trace_status(vdu, self.syslog_id_vdu, expected_status='ready')
            return vdu.dcap.get_results(self.syslog_id_vdu, target_dir=get_robot_output_dir())

    def start_syslog_on_vcu(self):
        with DcapSession(mrbts_id=mrbts_id, unit_type='vcu') as vcu:
            trace_id = vcu.dcap.start_trace(bts=vcu.bts_info, vcu_custom_profile=['syslogVcu', 'snapshotVcu'])
            self.syslog_id_vcu = trace_id['tracer_id']
            self.wait_for_trace_status(vcu, self.syslog_id_vcu, expected_status='running')
            logger.info(self.syslog_id_vcu, also_console=True)
        return self.syslog_id_vcu

    def stop_syslog_on_vcu_and_collect_snapshot(self):
        with DcapSession(mrbts_id=mrbts_id, unit_type='vcu') as vcu:
            vcu.dcap.stop_trace(self.syslog_id_vcu)
            self.wait_for_trace_status(vcu, self.syslog_id_vcu, expected_status='ready')
            return vcu.dcap.get_results(self.syslog_id_vcu, target_dir=get_robot_output_dir())

    @staticmethod
    @wait_until_function_succeeds(retry_time_in_seconds=3000, retry_interval_in_seconds=30)
    def wait_for_trace_status(dcap, trace_id, expected_status='ready'):
        trace_status = dcap.dcap.get_trace_info_by_id(trace_id)['status']
        assert trace_status == expected_status, \
            f"Trace status {trace_status} is different than expected: {expected_status}. Waiting for correct status.."

    def start_collecting_tti(self, nr_cells=None):
        with DcapSession(mrbts_id=mrbts_id, unit_type='vdu') as vdu:
            bts_info = vdu.bts_info.copy()
            if nr_cells:
                bts_info['nrCells'] = [f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell}'
                                       for cell in nr_cells.split(',')]
            trace_id = vdu.dcap.start_trace(bts=bts_info, vdu_custom_profile=['L2Ps_Component'])
            self.tti_id_vdu = trace_id['tracer_id']
            self.wait_for_trace_status(vdu, self.tti_id_vdu, expected_status='running')
            logger.info(self.tti_id_vdu, also_console=True)
        return self.tti_id_vdu

    def stop_collecting_tti(self):
        with DcapSession(mrbts_id=mrbts_id, unit_type='vdu') as vdu:
            vdu.dcap.stop_trace(self.tti_id_vdu)
            self.wait_for_trace_status(vdu, self.tti_id_vdu, expected_status='ready')
            filepath = vdu.dcap.get_results(self.tti_id_vdu, target_dir=get_robot_output_dir())
        return unpack_tti_file(filepath)


def unpack_tti_file(zip_filepath, output_dir=None):
    if not output_dir:
        output_dir = get_robot_output_dir()
    with zipfile.ZipFile(zip_filepath, 'r') as zip_f:
        for filename in zip_f.namelist():
            if "L2_component.pcap" in filename:
                return zip_f.extract(filename, output_dir)
