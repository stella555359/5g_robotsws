from moler.device import DeviceFactory
from moler.device.unixlocal import UnixLocal
from typing import List
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
import robot.api.logger as logger
import time
import datetime
from robot.libraries.BuiltIn import BuiltIn
from typing import Union
import json
import pickle

tl = BuiltIn().get_variable_value("${tl}")


@load_moler_configuration_from_tl()
def convert_pcap_to_json(path, output_path="/home/ute/logs/output.json", delete_previous_output=False):
    if delete_previous_output:
        logger.info("clearing previous json file", also_console=True)
        logger.info(output_path, also_console=True)
        unix = DeviceFactory.get_device("UnixLocal")
        _cmd = unix.get_cmd(cmd_name="rm", cmd_params={"file": output_path})
        _cmd(timeout=60)

    ute_pcap_path = f"/home/ute/tmp/test_data.pcap"
    ute_json_path = f"/home/ute/tmp/test_data.json"
    integration_vm_address = "7-7-UTE5GCLOUDT095-integration.sc5g.krk-lab.nsn-rdnet.net"
    integration_vm_username = "ute"

    # Copy pcap file to uepc
    local_pc: UnixLocal = DeviceFactory.get_device("UnixLocal")
    _cmd = local_pc.get_cmd(cmd_name="mkdir", cmd_params={
        "path": "/home/ute/tmp"
    })
    try:
        _cmd(timeout=30)
    except Exception:
        pass

    _cmd = local_pc.get_cmd(cmd_name="scp", cmd_params={
        "source": path,
        "dest": f"{integration_vm_username}@{integration_vm_address}:{ute_pcap_path}",
        "password": "ute"})
    _cmd(timeout=30)

    # Convert pcap to json on ute integration VM
    conversion_command = \
        'tshark -2 -R "ntrstr" -r "/home/ute/tmp/test_data.pcap" -T json > "/home/ute/tmp/test_data.json"'

    _cmd = local_pc.get_cmd(cmd_name="run_script", cmd_params={
        "script_command": f"ssh {integration_vm_username}@{integration_vm_address} '{conversion_command}'"
    })
    _cmd(timeout=300)

    # Upload json file to ute VM
    _cmd = local_pc.get_cmd(cmd_name="scp", cmd_params={
        "source": f"{integration_vm_username}@{integration_vm_address}:{ute_json_path}",
        "dest": output_path,
        "password": "ute"})
    _cmd(timeout=300)

    # Delete temporary files from integration VM
    delete_command_1 = "rm /home/ute/tmp/test_data.pcap"
    delete_command_2 = "rm /home/ute/tmp/test_data.json"
    _cmd = local_pc.get_cmd(cmd_name="run_script", cmd_params={
        "script_command": f"ssh {integration_vm_username}@{integration_vm_address} '{delete_command_1}'"
    })
    _cmd(timeout=300)

    _cmd = local_pc.get_cmd(cmd_name="run_script", cmd_params={
        "script_command": f"ssh {integration_vm_username}@{integration_vm_address} '{delete_command_2}'"
    })
    _cmd(timeout=300)


def gen_dict_extract(key, var):
    if hasattr(var, "items"):
        for k, v in var.items():
            if k == key:
                yield v
            if isinstance(v, dict):
                for result in gen_dict_extract(key, v):
                    yield result
            elif isinstance(v, list):
                for d in v:
                    for result in gen_dict_extract(key, d):
                        yield result


def array_on_duplicate_keys(ordered_pairs):
    """Convert duplicate keys to arrays."""
    d = {}
    for k, v in ordered_pairs:
        if k in d:
            if type(d[k]) is list:
                d[k].append(v)
            else:
                d[k] = [d[k], v]
        else:
            d[k] = v
    return d


class TputMessage:
    def __init__(self, timestamp: datetime.datetime, tput: Union[float, int, str], source: str):
        self.timestamp: datetime.datetime = timestamp
        self.tput: float = float(tput)
        self.source: str = source

    def __str__(self):
        return (
            f"============================= \n"
            f"timestamp: {self.timestamp} \n"
            f"tput_value: {self.tput} \n"
            f"data source: {self.source}"
        )


def verify_lack_of_pcmd_messages(path: str):
    with open(path, "r") as f:
        data = f.read()
    parsed_packets = json.loads(
        data, object_pairs_hook=array_on_duplicate_keys)
    logger.info(parsed_packets, also_console=True)
    if len(parsed_packets) != 0:
        raise AssertionError(f"pcmd messages were found in collected logs")


def verify_presence_of_pcmd_messages(path: str):
    with open(path, "r") as f:
        data = f.read()
    parsed_packets = json.loads(
        data, object_pairs_hook=array_on_duplicate_keys)
    cu_record_found = None
    du_record_found = None

    for packet in parsed_packets:
        alive_element = None
        for element in gen_dict_extract("nsetapx.alive_element", packet):
            alive_element = element
            logger.info("Printing alive element", also_console=True)
            logger.info(alive_element, also_console=True)

        for element in gen_dict_extract("nsetapx.gnb_cu_Id_element", packet):
            logger.info("Printing CU ID element", also_console=True)
            logger.info(element, also_console=True)
            cu_record_found = True
            logger.console(cu_record_found)

        for element in gen_dict_extract("nsetapx.gnb_du_Ids_element", packet):
            logger.info("Printing DU IDs element", also_console=True)
            logger.info(element, also_console=True)
            du_record_found = True
            logger.console(cu_record_found)

        if alive_element is None:
            raise AssertionError(
                f"alive element not found in packet: {packet}")
    if cu_record_found is None:
        raise AssertionError(f"cu record element not found in any of packets")
    if du_record_found is None:
        raise AssertionError(f"du record element not found in any of packets")


def verify_presence_of_pcmd_latency_messages(path: str):
    with open(path, "r") as f:
        data = f.read()
    parsed_packets = json.loads(
        data, object_pairs_hook=array_on_duplicate_keys)
    latency_messages_found = 0
    zero_latency_for_positive_tput = 0
    first_non_zero_tput_found = False
    positive_tput_messages = 0

    for packet in parsed_packets:
        for DL_element in gen_dict_extract("nsetapx.DlRadioBearerRlcMeasData_element", packet):
            logger.info(
                "===============================================================",
                also_console=True,
            )
            logger.info("Printing DlRadioBearerRlcMeas Data element",
                        also_console=True)
            logger.info(DL_element, also_console=True)
            tp_value = None
            for sumOfRlc_element in gen_dict_extract("nsetapx.sumOfRlcPduTxBytes", DL_element):
                tp_value = int(sumOfRlc_element)
            latency_value = None
            latency_element = None
            rlcsdus_value = None
            for latency_element in gen_dict_extract("nsetapx.avgIpLatency_element", DL_element):
                logger.info("Printing avgIpLatency element", also_console=True)
                logger.info(latency_element, also_console=True)
                latency_messages_found += 1
                latency_value = int(next(gen_dict_extract(
                    "nsetapx.sumOfDelays", latency_element)))
                rlcsdus_value = int(next(gen_dict_extract(
                    "nsetapx.numOfRlcSdus", latency_element)))
                latency_element = latency_element
                logger.info(
                    f"Packet tput value: {tp_value}", also_console=True)
                logger.info(
                    f"Packet sumOfDelays value: {latency_value}", also_console=True)
                logger.info(
                    f"Packet numOfRlcSdus value: {rlcsdus_value}", also_console=True)
            if latency_element is not None:
                if not (0 <= latency_value <= 1074176):
                    raise AssertionError(
                        f"nsetapx.sumOfDelays value is outside allowed range, value: {latency_value}, "
                        f"allowed range: 0 <= value <= 1074176"
                    )

                if tp_value > 0:
                    positive_tput_messages += 1

                if tp_value > 1000 and latency_value == 0:
                    zero_latency_for_positive_tput += 1
                    if not first_non_zero_tput_found:
                        raise AssertionError(
                            f"Latency of value 0 was found for non 0 throughput for first pcmd tput message"
                        )

                if tp_value > 0 and latency_value < 0:
                    raise AssertionError(
                        f"Latency of negative value was found for non 0 throughput")

                if latency_value > 0 and rlcsdus_value <= 0:
                    raise AssertionError(
                        f"nsetapx.numOfRlcSdus is 0 or negative for positive latency value")
                if tp_value > 0:
                    if not first_non_zero_tput_found:
                        logger.info("First message with tput > 0",
                                    also_console=True)
                    first_non_zero_tput_found = True

    if latency_messages_found == 0:
        raise AssertionError(
            f"latency message element not found in any of packets")
    logger.info("Latency message verification successfull", also_console=True)
    logger.info(
        f"number of found latency messages: {latency_messages_found}", also_console=True)
    logger.info(
        f"number of latency values 0 for non 0 throughput: {zero_latency_for_positive_tput}",
        also_console=True,
    )
    logger.info(
        f"number of messages with latency information and positive throughput: {positive_tput_messages}",
        also_console=True,
    )


def verify_presence_of_pcmd_cu_vendor_messages(path: str):
    with open(path, "r") as f:
        data = f.read()
    parsed_packets = json.loads(
        data, object_pairs_hook=array_on_duplicate_keys)

    # ver-Id: id-VER-GNB-CU-UeCuUpConnectivityTraceRecord (23)
    # CuVendorExtensionRecordDataType: ueCuUpConnectivityRecord (23)
    message_type_1_found = None

    # ver-Id: id-VER-GNB-CUUP-BearerCtxSetupTraceRecord (0)
    message_type_2_found = None

    # ver-Id: id-VER-GNB-CUUP-CuUpBearerTraceRecord (2)
    message_type_3_found = None

    for packet in parsed_packets:
        for CuRecord_element in gen_dict_extract("nsetapx.CuRecord_element", packet):
            try:
                ver_id = int(next(gen_dict_extract(
                    "nsetapx.ver_Id", CuRecord_element)))
                ver_id_tree = next(gen_dict_extract(
                    "nsetapx.ver_Payload_tree", CuRecord_element))
            except StopIteration:
                continue
            if ver_id == 23:
                try:
                    cu_vendor_extension_record_datatype = int(
                        next(gen_dict_extract(
                            "nsetapx.CuVendorExtensionRecordDataType", ver_id_tree))
                    )
                except StopIteration:
                    continue
                if cu_vendor_extension_record_datatype == 23:
                    message_type_1_found = True
                    logger.info(
                        f"==================================================",
                        also_console=True,
                    )
                    logger.info(
                        f"Found message of type ver-Id: id-VER-GNB-CU-UeCuUpConnectivityTraceRecord (23)",
                        also_console=True,
                    )
                    logger.info(ver_id_tree, also_console=True)

        for CuUpRecord_element in gen_dict_extract("nsetapx.CuUpRecord_element", packet):
            try:
                ver_id = int(next(gen_dict_extract(
                    "nsetapx.ver_Id", CuUpRecord_element)))
                ver_id_tree = next(gen_dict_extract(
                    "nsetapx.ver_Payload_tree", CuUpRecord_element))
            except StopIteration:
                continue
            if ver_id == 0:
                try:
                    bearer_ctx_setup_record = int(
                        next(gen_dict_extract(
                            "nsetapx.bearerCtxSetupRecord", ver_id_tree))
                    )
                    bearer_ctx_setup_record_tree = next(
                        gen_dict_extract(
                            "nsetapx.bearerCtxSetupRecord_tree", ver_id_tree)
                    )
                    result = int(next(gen_dict_extract(
                        "nsetapx.result", bearer_ctx_setup_record_tree)))
                except StopIteration:
                    continue
                if result == 0 and bearer_ctx_setup_record == 0:
                    message_type_2_found = True
                    logger.info(
                        f"==================================================",
                        also_console=True,
                    )
                    logger.info(
                        f"Found message of type ver-Id: id-VER-GNB-CUUP-BearerCtxSetupTraceRecord (0)",
                        also_console=True,
                    )
                    logger.info(ver_id_tree, also_console=True)
            elif ver_id == 2:
                message_type_3_found = True
                logger.info(
                    f"==================================================",
                    also_console=True,
                )
                logger.info(
                    f"Found message of type ver-Id: id-VER-GNB-CUUP-CuUpBearerTraceRecord (2)",
                    also_console=True,
                )
                logger.info(ver_id_tree, also_console=True)

    if message_type_1_found is None:
        raise AssertionError(
            f"#ver-Id: id-VER-GNB-CU-UeCuUpConnectivityTraceRecord (23) not found in any of packets"
        )
    if message_type_2_found is None:
        raise AssertionError(
            f"#ver-Id: id-VER-GNB-CUUP-BearerCtxSetupTraceRecord (0) not found in any of packets")
    if message_type_3_found is None:
        raise AssertionError(
            f"ver-Id: id-VER-GNB-CUUP-CuUpBearerTraceRecord (2) not found in any of packets")


def get_tputs_from_json(path: str) -> List[TputMessage]:
    with open(path, "r") as f:
        data = f.read()
    parsed_packets = json.loads(
        data, object_pairs_hook=array_on_duplicate_keys)

    pcmd_tput_dl = []
    for packet in parsed_packets:
        timestamp: Union[str, None] = None
        rlc_sum: Union[int, None] = None
        for timestamp in gen_dict_extract("nsetapx.tstamp", packet):
            timestamp = timestamp

        for rlc_sum in gen_dict_extract("nsetapx.sumOfRlcPduTxBytes", packet):
            rlc_sum = rlc_sum

        if timestamp is None or rlc_sum is None:
            continue

        logger.info(
            f"raw timestamp: {timestamp}, converted timestamp: {timestamp[:-7]}",
            also_console=True,
        )
        timestamp = timestamp[:-7]
        parsed_time = datetime.datetime.strptime(
            timestamp, "%b  %d, %Y %H:%M:%S.%f")
        message = TputMessage(timestamp=parsed_time,
                              tput=rlc_sum, source="pcmd")
        pcmd_tput_dl.append(message)
    return pcmd_tput_dl


def get_tputs_from_json_custom(path: str, tp_field_name: str) -> List[TputMessage]:
    with open(path, "r") as f:
        data = f.read()
    parsed_packets = json.loads(
        data, object_pairs_hook=array_on_duplicate_keys)

    pcmd_tput = []
    logger.info(f"Processing {len(parsed_packets)} packets", also_console=True)
    logger.info(f"Looking for tput field: {tp_field_name}", also_console=True)
    for packet in parsed_packets:
        timestamp: Union[str, None] = None
        tp_sum: Union[int, None] = None
        try:
            timestamp = next(gen_dict_extract("nsetapx.tstamp", packet))
        except StopIteration:
            continue

        try:
            tp_sum = int(next(gen_dict_extract(tp_field_name, packet)))
            logger.info(f"raw value of tput: {tp_sum}", also_console=True)
        except StopIteration:
            continue
        try:
            logger.info(
                f"raw timestamp: {timestamp}, converted timestamp: {timestamp[:-7]}",
                also_console=True,
            )
            timestamp = timestamp[:-7]
            parsed_time = datetime.datetime.strptime(
                timestamp, "%b  %d, %Y %H:%M:%S.%f")
        except TypeError:
            logger.info(
                f"Malformed timestamp: {timestamp}, skipping", also_console=True)
            continue
        parsed_time = parsed_time + datetime.timedelta(hours=2)
        message = TputMessage(timestamp=parsed_time,
                              tput=tp_sum, source="pcmd")
        logger.info(
            f"Created TputMessage from json: {message}", also_console=True)
        pcmd_tput.append(message)
    return pcmd_tput


def get_tputs_from_counter(counter_data: dict) -> List[TputMessage]:
    output_list = []
    for timestamp, value in counter_data[0]["timestamps"][0].items():
        converted_date = datetime.datetime.fromtimestamp(int(timestamp))
        logger.console(
            f"original timestamp: {timestamp} converted time: {converted_date}, value: {value}")
        tput_message = TputMessage(converted_date, value, "counter")
        output_list.append(tput_message)
    return output_list


def save_tput_messages(messages: List[TputMessage], filepath: str):
    with open(filepath, "wb") as file:
        pickle.dump(messages, file)


def convert_counter_values_to_tp_messages(counter_data: List) -> List[TputMessage]:
    output_list = []
    for timestamp, value in counter_data[0]["timestamps"][0].items():
        converted_date = datetime.datetime.fromtimestamp(int(timestamp))
        logger.console(
            f"original timestamp: {timestamp} converted time: {converted_date}, value: {value}")
        converted_value = int(value) * 1000
        tput_message = TputMessage(converted_date, converted_value, "counter")
        output_list.append(tput_message)
    logger.console(f"current time: {time.time()}", time.time())
    return output_list


def sum_tput_messages(messages: List[TputMessage]) -> int:
    sum = 0
    for message in messages:
        sum += message.tput
    return sum


def get_current_datetime() -> datetime.datetime:
    value = datetime.datetime.now()
    logger.info(f"Providing current time: {value}", also_console=True)
    return value


def filter_tput_messages_below_timestamp(
    messages: List[TputMessage],
    cutoff_timestamp: datetime.datetime,
    correction_offset: datetime.timedelta = datetime.timedelta(minutes=15),
) -> List[TputMessage]:
    corrected_cutoff_timestamp = cutoff_timestamp - correction_offset
    logger.info(
        f"Corrected cutoff time: {corrected_cutoff_timestamp}", also_console=True)
    filtered_messages = list(filter(
        lambda message: message.timestamp >= corrected_cutoff_timestamp, messages))
    logger.info(
        f"Number of filtered messages {len(messages) - len(filtered_messages)}",
        also_console=True,
    )
    return filtered_messages


def wait_for_next_pm_counter_collection(sleep_time: int = 15):
    logger.info(
        f"Sleeping for {sleep_time} minutes waiting for next counter collection perdiod",
        also_console=True,
    )
    logger.info(f"Current time: {datetime.datetime.now()}", also_console=True)
    time.sleep(60 * sleep_time)


def compare_tput_sums(tput_sum_a: float, tput_sum_b: float, difference_threshold: float = 0.15):
    acceptable_difference = tput_sum_a * difference_threshold
    if acceptable_difference == 0:
        logger.info(
            "Acceptable margin is 0, \
                applying a correction in order to account for losses in converting counter values from KB to B",
            also_console=True,
        )
        acceptable_difference = 10000
    if (tput_sum_a + acceptable_difference) >= tput_sum_b >= (tput_sum_a - acceptable_difference):
        logger.info(
            f"tput difference: {abs(tput_sum_a - tput_sum_b)}"
            f" within acceptable margin: {acceptable_difference}, {difference_threshold * 100}%",
            also_console=True,
        )
        return

    raise AssertionError(
        f"tput difference: {abs(tput_sum_a - tput_sum_b)}"
        f" out of acceptable margin: {acceptable_difference}, {difference_threshold * 100}%"
    )


def verify_presence_of_pcmd_F_messages_after_enabling_them(path: str):
    with open(path, "r") as f:
        data = f.read()
    parsed_packets = json.loads(
        data, object_pairs_hook=array_on_duplicate_keys)

    # ver-Id: id-VER-GNB-CUUP-CuUpDlRadioBearerPdcpThroughputTraceRecord (5)
    cu_up_dl_rb_pdcp_tp_trace_record_found = None
    # ver-Id: id-VER-GNB-DU-DuUlRadioBearerRlcThroughputTraceRecord (17)
    du_ul_rb_rlc_tp_trace_record_found = None

    for packet in parsed_packets:
        for CuUpRecord_element in gen_dict_extract("nsetapx.CuUpRecord_element", packet):
            try:
                ver_id = int(next(gen_dict_extract(
                    "nsetapx.ver_Id", CuUpRecord_element)))
                ver_id_tree = next(gen_dict_extract(
                    "nsetapx.ver_Payload_tree", CuUpRecord_element))
            except StopIteration:
                continue
            if ver_id != 5:
                continue
            logger.info("Found correct ver_id for message type 5",
                        also_console=True)
            try:
                cu_vendor_extension_record_datatype = int(
                    next(gen_dict_extract(
                        "nsetapx.CuUpVendorExtensionRecordDataType", ver_id_tree))
                )
            except StopIteration:
                continue
            if cu_vendor_extension_record_datatype != 5:
                continue
            logger.info(
                "Found correct vendor_extension for message type 5", also_console=True)
            try:
                trace_record = next(
                    gen_dict_extract(
                        "nsetapx.CuUpDlRadioBearerPdcpThroughputData_element",
                        ver_id_tree,
                    )
                )
            except StopIteration:
                continue

            logger.info(
                f"==================================================", also_console=True)
            logger.info(
                f"Found message of type ver-Id: id-VER-GNB-CUUP-CuUpDlRadioBearerPdcpThroughputTraceRecord (5)",
                also_console=True,
            )
            logger.info(ver_id_tree, also_console=True)
            logger.info(trace_record, also_console=True)

            if "nsetapx.endMarker" not in trace_record:
                logger.info(
                    f"nsetapx.endMarker property was not found in trace record",
                    also_console=True,
                )
                continue

            if "nsetapx.drb_Id" not in trace_record:
                logger.info(
                    f"nsetapx.drb_Id property was not found in trace record",
                    also_console=True,
                )
                continue

            if "nsetapx.dataCollectionDuration" not in trace_record:
                logger.info(
                    f"nsetapx.dataCollectionDuration property was not found in trace record",
                    also_console=True,
                )
                continue

            if "nsetapx.timeOfUeDataBurstTx" not in trace_record:
                logger.info(
                    f"nsetapx.timeOfUeDataBurstTx property was not found in trace record",
                    also_console=True,
                )
                continue

            if "nsetapx.sumOfPdcpSduTxDataBurstBytes" not in trace_record:
                logger.info(
                    f"nsetapx.sumOfPdcpSduTxDataBurstBytes property was not found in trace record",
                    also_console=True,
                )
                continue

            cu_up_dl_rb_pdcp_tp_trace_record_found = True

        for DuRecord_element in gen_dict_extract("nsetapx.DuRecord_element", packet):
            try:
                ver_id = int(next(gen_dict_extract(
                    "nsetapx.ver_Id", DuRecord_element)))
                ver_id_tree = next(gen_dict_extract(
                    "nsetapx.ver_Payload_tree", DuRecord_element))
            except StopIteration:
                continue
            if ver_id != 17:
                continue
            logger.info("Found correct ver_id for message type 17",
                        also_console=True)
            try:
                du_vendor_extension_record_datatype = int(
                    next(gen_dict_extract(
                        "nsetapx.DuVendorExtensionRecordDataType", ver_id_tree))
                )
            except StopIteration:
                continue
            if du_vendor_extension_record_datatype != 17:
                continue
            logger.info(
                "Found correct vendor_extension for message type 17", also_console=True)
            try:
                trace_record = next(
                    gen_dict_extract(
                        "nsetapx.DuUlRadioBearerRlcThroughputData_element", ver_id_tree)
                )
            except StopIteration:
                continue

            logger.info(
                f"==================================================", also_console=True)
            logger.info(
                f"Found message of type ver-Id: id-VER-GNB-DU-DuUlRadioBearerRlcThroughputTraceRecord (17)",
                also_console=True,
            )
            logger.info(ver_id_tree, also_console=True)
            logger.info(trace_record, also_console=True)

            if "nsetapx.endMarker" not in trace_record:
                logger.info(
                    f"nsetapx.endMarker property was not found in trace record",
                    also_console=True,
                )
                continue

            if "nsetapx.drb_Id" not in trace_record:
                logger.info(
                    f"nsetapx.drb_Id property was not found in trace record",
                    also_console=True,
                )
                continue

            if "nsetapx.dataCollectionDuration" not in trace_record:
                logger.info(
                    f"nsetapx.dataCollectionDuration property was not found in trace record",
                    also_console=True,
                )
                continue

            if "nsetapx.timeOfUeDataBurstRx" not in trace_record:
                logger.info(
                    f"nsetapx.timeOfUeDataBurstRx property was not found in trace record",
                    also_console=True,
                )
                continue

            if "nsetapx.sumOfRlcSduRxDataBurstBytes" not in trace_record:
                logger.info(
                    f"nsetapx.sumOfRlcSduRxDataBurstBytes property was not found in trace record",
                    also_console=True,
                )
                continue

            du_ul_rb_rlc_tp_trace_record_found = True

    if cu_up_dl_rb_pdcp_tp_trace_record_found is None:
        raise AssertionError(
            f"CuUpDlRadioBearerPdcpThpTraceRecord element not found in any of packets")
    if du_ul_rb_rlc_tp_trace_record_found is None:
        raise AssertionError(
            f"DuUlRadioBearerRlcThpTraceRecord element not found in any of packets")


def verify_presence_of_pcmd_B_messages_after_enabling_them(path: str):
    with open(path, "r") as f:
        data = f.read()
    parsed_packets = json.loads(
        data, object_pairs_hook=array_on_duplicate_keys)

    # ver-Id: id-VER-GNB-CUUP-CuUpUlRadioBearerPdcpMeasTraceRecord (3)
    cu_up_ul_rb_pdcp_meas_trace_record_found = None
    # ver-Id: id-VER-GNB-CUUP-CuUpDlRadioBearerPdcpMeasTraceRecord (4)
    cu_up_dl_rb_pdcp_meas_trace_record_found = None

    for packet in parsed_packets:
        for CuUpRecord_element in gen_dict_extract("nsetapx.CuUpRecord_element", packet):
            try:
                ver_id = int(next(gen_dict_extract(
                    "nsetapx.ver_Id", CuUpRecord_element)))
                ver_id_tree = next(gen_dict_extract(
                    "nsetapx.ver_Payload_tree", CuUpRecord_element))
            except StopIteration:
                continue
            if ver_id == 3:
                logger.info(
                    "Found correct ver_id for message type 3", also_console=True)
                try:
                    du_vendor_extension_record_datatype = int(
                        next(gen_dict_extract(
                            "nsetapx.CuUpVendorExtensionRecordDataType", ver_id_tree))
                    )
                except StopIteration:
                    continue
                if du_vendor_extension_record_datatype != 3:
                    continue
                logger.info(
                    "Found correct vendor_extension for message type 3", also_console=True)
                try:
                    trace_record = next(
                        gen_dict_extract(
                            "nsetapx.CuUpUlRadioBearerPdcpMeasData_element", ver_id_tree)
                    )
                except StopIteration:
                    continue
                logger.info(
                    f"==================================================", also_console=True)
                logger.info(f"Found message of type ver-Id: "
                            "id-VER-GNB-CUUP-CuUpUlRadioBearerPdcpMeasTraceRecord (3)",
                            also_console=True)
                logger.info(ver_id_tree, also_console=True)
                logger.info(trace_record, also_console=True)

                if "nsetapx.endMarker" not in trace_record:
                    logger.info(
                        f"nsetapx.endMarker property was not found in trace record",
                        also_console=True,
                    )
                    continue

                if "nsetapx.drb_Id" not in trace_record:
                    logger.info(
                        f"nsetapx.drb_Id property was not found in trace record",
                        also_console=True,
                    )
                    continue

                if "nsetapx.dataCollectionDuration" not in trace_record:
                    logger.info(
                        f"nsetapx.dataCollectionDuration property was not found in trace record",
                        also_console=True,
                    )
                    continue

                if "nsetapx.sumOfPdcpSduRxBytes" not in trace_record:
                    logger.info(
                        f"nsetapx.sumOfPdcpSduRxBytes property was not found in trace record",
                        also_console=True,
                    )
                    continue

                if "nsetapx.sumOfPdcpSduRxBytesDiscarded" not in trace_record:
                    logger.info(
                        f"nsetapx.sumOfPdcpSduRxBytesDiscarded property was not found in trace record",
                        also_console=True,
                    )
                    continue

                cu_up_ul_rb_pdcp_meas_trace_record_found = True

            elif ver_id == 4:
                logger.info(
                    "Found correct ver_id for message type 4", also_console=True)
                try:
                    du_vendor_extension_record_datatype = int(
                        next(gen_dict_extract(
                            "nsetapx.CuUpVendorExtensionRecordDataType", ver_id_tree))
                    )
                except StopIteration:
                    continue
                if du_vendor_extension_record_datatype != 4:
                    continue
                logger.info(
                    "Found correct vendor_extension for message type 4", also_console=True)
                try:
                    trace_record = next(
                        gen_dict_extract(
                            "nsetapx.CuUpDlRadioBearerPdcpMeasData_element", ver_id_tree)
                    )
                except StopIteration:
                    continue
                logger.info(
                    f"==================================================", also_console=True)
                logger.info(f"Found message of type ver-Id: id-VER-GNB-CUUP-CuUpDlRadioBearerPdcpMeasTraceRecord (4)",
                            also_console=True)
                logger.info(ver_id_tree, also_console=True)
                logger.info(trace_record, also_console=True)

                if "nsetapx.endMarker" not in trace_record:
                    logger.info(
                        f"nsetapx.endMarker property was not found in trace record",
                        also_console=True,
                    )
                    continue

                if "nsetapx.drb_Id" not in trace_record:
                    logger.info(
                        f"nsetapx.drb_Id property was not found in trace record",
                        also_console=True,
                    )
                    continue

                if "nsetapx.dataCollectionDuration" not in trace_record:
                    logger.info(
                        f"nsetapx.dataCollectionDuration property was not found in trace record",
                        also_console=True,
                    )
                    continue

                if "nsetapx.sumOfPdcpSduTxBytes" not in trace_record:
                    logger.info(
                        f"nsetapx.sumOfPdcpSduTxBytes property was not found in trace record",
                        also_console=True,
                    )
                    continue

                if "nsetapx.sumOfPdcpSduTxBytesDiscarded" not in trace_record:
                    logger.info(
                        f"nsetapx.sumOfPdcpSduTxBytesDiscarded property was not found in trace record",
                        also_console=True,
                    )
                    continue

                cu_up_dl_rb_pdcp_meas_trace_record_found = True

    if cu_up_ul_rb_pdcp_meas_trace_record_found is None:
        raise AssertionError(
            f"ver-Id: id-VER-GNB-CUUP-CuUpUlRadioBearerPdcpMeasTraceRecord (3) element not found in any of packets"
        )
    if cu_up_dl_rb_pdcp_meas_trace_record_found is None:
        raise AssertionError(
            f"ver-Id: id-VER-GNB-CUUP-CuUpDlRadioBearerPdcpMeasTraceRecord (4) element not found in any of packets"
        )
