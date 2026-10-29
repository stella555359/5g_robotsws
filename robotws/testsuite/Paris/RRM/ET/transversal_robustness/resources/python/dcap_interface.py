import os
import sys
import time
from zipfile import ZipFile
from io import TextIOWrapper
from taf.sw.dcap.rd import rd

dcap_object = None


def _dcap_initialize():
    global dcap_object
    if not dcap_object:
        print(f"Initialize dcap connection")
        dcap_object = rd()
        dcap_connection = dcap_object.connect_to(host='127.0.0.1', port='9443', username=None, password=None,
                                                 secure=True)


def dcap_stop_all_traces():
    _dcap_initialize()
    traces = dcap_object.get_all_trace_info()
    for trace in traces:
        tracer_id = trace['tracer_id']
        trace_status = trace['status']
        print(f"Trace {tracer_id}: {trace_status}")
        if trace_status not in ("ready", "failed", "packaging", "stopping", "postProcessing"):
            dcap_stop(tracer_id)


def _print_all_traces_status():
    _dcap_initialize()
    traces = dcap_object.get_all_trace_info()
    for trace in traces:
        tracer_id = trace['tracer_id']
        trace_status = trace['status']
        print(f"Trace {tracer_id}: {trace_status}")


def _get_trace_status(tracer_id):
    trace_info = dcap_object.get_trace_info_by_id(tracer_id)
    print(f"Trace {tracer_id} info: {trace_info}")
    return trace_info["status"]


def dcap_start(trace_types, duration_seconds):
    _dcap_initialize()
    print(f"Starting dcap Trace")
    bts = {
        "host": "192.168.255.129",
        "port": 443,
        "username": "Nemuadmin",
        "password": "nemuuser",
    }
    trace = dcap_object.start_trace(bts, gnb_custom_profile=trace_types, duration=(float(duration_seconds) / 60))
    tracer_id = trace['tracer_id']
    trace_status = _get_trace_status(tracer_id)
    while trace_status == 'starting':
        print(f"Waiting for trace {tracer_id} to start ({trace_status})")
        time.sleep(5)
        trace_status = _get_trace_status(tracer_id)
    print(f"Trace {tracer_id} started")
    return tracer_id


def dcap_start_tti(duration_seconds):
    return dcap_start(("L2Ps_Component",), duration_seconds)


def dcap_start_cplane(duration_seconds):
    return dcap_start(("cp_5g",), duration_seconds)


def dcap_stop(tracer_id):
    _dcap_initialize()
    print(f"Trace {tracer_id} stopping")
    dcap_object.stop_trace(tracer_id)
    trace_status = _get_trace_status(tracer_id)
    while (not trace_status.startswith('ready')) and (trace_status != 'failed'):
        print(f"Waiting for the trace to stop ({trace_status})")
        time.sleep(5)
        trace_status = _get_trace_status(tracer_id)
    print(f"Trace {tracer_id} {trace_status}")


def dcap_get_results(tracer_id, target_dir):
    _dcap_initialize()
    print(f"Getting result for Trace {tracer_id}")
    trace_results_file_name = dcap_object.get_results(tracer_id, target_dir)
    print(f"Results for Trace {tracer_id}: {trace_results_file_name}")
    _extract_control_messages(target_dir, trace_results_file_name)
    return trace_results_file_name


def _analyze_control_plane_file(control_plane_file, output_file):
    syscom_msg_name = {
        "d580": "ITF_L2_PS_CNFG_ADDRESSDISTRIBUTIONREQ_ID     ",
        "d581": "ITF_L2_PS_CNFG_ADDRESSDISTRIBUTIONRESP_ID    ",
        "d373": "ITF_L2_PS_CELL_CELLGROUPSETUPREQ_ID          ",
        "d374": "ITF_L2_PS_CELL_CELLGROUPSETUPRESP_ID         ",
        "d360": "ITF_L2_PS_CELL_CELLSETUPREQ_ID               ",
        "d361": "ITF_L2_PS_CELL_CELLSETUPRESP_ID              ",
        "d369": "ITF_L2_PS_CELL_SYSTEMINFOCONFIGURATIONREQ_ID ",
        "d36a": "ITF_L2_PS_CELL_SYSTEMINFOCONFIGURATIONRESP_ID",
    }
    syscom_msg_id_offset = 112
    msg_header_length = 28
    msg_sequence_number = 0
    msg_id = int.from_bytes(control_plane_file.read(2), byteorder='little')
    while msg_id != 0:
        msg_length = int.from_bytes(control_plane_file.read(2), byteorder='little')
        msg_content = control_plane_file.read(msg_length - 4).hex()
        if (msg_id == 0xCDCD) and (len(msg_content) >= (syscom_msg_id_offset + 4)):
            syscom_msg_id = msg_content[syscom_msg_id_offset:syscom_msg_id_offset + 4]
            if syscom_msg_id in syscom_msg_name:
                print(f"{msg_sequence_number:6} {syscom_msg_name[syscom_msg_id]} {msg_length:6} {len(msg_content):6}")
                output_file.write(f"Emil frame {msg_sequence_number:6} {syscom_msg_name[syscom_msg_id]}\n")
                output_file.write(f"{msg_content[syscom_msg_id_offset + msg_header_length:]}\n")
        msg_id = int.from_bytes(control_plane_file.read(2), byteorder='little')
        msg_sequence_number += 1


def _extract_gnb_sw_release(trace_file, output_file):
    gnb_sw_release = "unknown"
    for line in TextIOWrapper(trace_file).readlines():
        if 'swReleaseVersionPackageName=\\"' in line:
            gnb_sw_release = line.split('swReleaseVersionPackageName=\\"')[1].split("_release_BTSSM_downloadable")[0]
            break
    print(f"gnb_sw_release: {gnb_sw_release}")
    output_file.write(f"gnb_sw_release: {gnb_sw_release}\n")


def _extract_control_messages(target_dir, dcap_file_name):
    output_file_name = target_dir + "/dcap_control_messages.log"
    output_file = open(output_file_name, "w")
    dcap_file = ZipFile(dcap_file_name)
    control_plane_file_names = []
    for trace_file_name in dcap_file.namelist():
        if trace_file_name.endswith(".5gm"):
            control_plane_file_names.append(trace_file_name)
        if "ConsoleTrace" in trace_file_name:
            trace_file = dcap_file.open(trace_file_name, "r")
            _extract_gnb_sw_release(trace_file, output_file)
            trace_file.close()
    for control_plane_file_name in sorted(control_plane_file_names):
        print(control_plane_file_name)
        control_plane_file = dcap_file.open(control_plane_file_name, "r")
        _analyze_control_plane_file(control_plane_file, output_file)
        control_plane_file.close()
    dcap_file.close()
    output_file.close()
    return output_file_name


def dcap_start_container():
    os.system("/usr/local/bin/DCAP_Basic_controller start")
    status = os.system("/usr/local/bin/DCAP_Basic_controller status")
    counter = 0
    while (status != 0) and (counter < 10):
        counter += 1
        time.sleep(10)
        status = os.system("/usr/local/bin/DCAP_Basic_controller status")
        print(f"dcap status is {status} after try {counter}")
    if status != 0:
        raise BaseException(f"dcap status is {status}")


def dcap_stop_container():
    os.system("/usr/local/bin/DCAP_Basic_controller stop")


if __name__ == '__main__':
    # dcap_stop_all_traces()
    # tracer_id = dcap_start(("cp_5g", "L2Ps_Component"))
    # time.sleep(30)
    # dcap_stop(tracer_id)
    # _print_all_traces_status()
    # dcap_start_container()
    # tracer_id = dcap_start_cplane(duration_seconds=60)
    # time.sleep(10)
    # dcap_stop(tracer_id)
    # dcap_stop_container()
    _extract_control_messages(target_dir=sys.argv[1], dcap_file_name=sys.argv[2])
