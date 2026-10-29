from moler.device import DeviceFactory
from moler.device.unixlocal import UnixLocal
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
import robot.api.logger as logger
import datetime
from robot.libraries.BuiltIn import BuiltIn
import json

# ============= Generic keywords ================

tl = BuiltIn().get_variable_value("${tl}")


@load_moler_configuration_from_tl()
def convert_pcap_to_json(
    path, output_path="/home/ute/logs/output.json", delete_previous_output=False
):
    if delete_previous_output:
        logger.info("clearing previous json file", also_console=True)
        logger.info(output_path, also_console=True)
        unix = DeviceFactory.get_device("UnixLocal")
        _cmd = unix.get_cmd(cmd_name="rm", cmd_params={"file": output_path})
        _cmd(timeout=60)

    ute_pcap_path = f"/home/ute/tmp/test_data.pcap"
    ute_json_path = f"/home/ute/tmp/test_data.json"
    integration_vm_address = "7-7-ute5gcloudt095-integration.sc5g.krk-lab.nsn-rdnet.net"
    integration_vm_username = "ute"

    # Copy pcap file to uepc
    local_pc: UnixLocal = DeviceFactory.get_device("UnixLocal")
    _cmd = local_pc.get_cmd(cmd_name="mkdir", cmd_params={
                            "path": "/home/ute/tmp"})
    try:
        _cmd(timeout=30)
    except Exception:
        pass

    _cmd = local_pc.get_cmd(
        cmd_name="scp",
        cmd_params={
            "source": path,
            "dest": f"{integration_vm_username}@{integration_vm_address}:{ute_pcap_path}",
            "password": "UTE.debian12",
        },
    )
    _cmd(timeout=30)

    # Convert pcap to json on ute integration VM
    input_tmp_path = "/home/ute/tmp/test_data.pcap"
    output_tmp_path = "/home/ute/tmp/test_data.json"
    conversion_command = f'tshark -2 -R "ntrstr" -r "{input_tmp_path}" -T json > "{output_tmp_path}"'

    _cmd = local_pc.get_cmd(
        cmd_name="run_script",
        cmd_params={
            "script_command": f"ssh {integration_vm_username}@{integration_vm_address} '{conversion_command}'"
        },
    )
    _cmd(timeout=300)

    # Upload json file to ute VM
    _cmd = local_pc.get_cmd(
        cmd_name="scp",
        cmd_params={
            "source": f"{integration_vm_username}@{integration_vm_address}:{ute_json_path}",
            "dest": output_path,
            "password": "ute",
        },
    )
    _cmd(timeout=300)

    # Delete temporary files from integration VM
    delete_command_1 = "rm /home/ute/tmp/test_data.pcap"
    delete_command_2 = "rm /home/ute/tmp/test_data.json"
    _cmd = local_pc.get_cmd(
        cmd_name="run_script",
        cmd_params={
            "script_command": f"ssh {integration_vm_username}@{integration_vm_address} '{delete_command_1}'"
        },
    )
    _cmd(timeout=300)

    _cmd = local_pc.get_cmd(
        cmd_name="run_script",
        cmd_params={
            "script_command": f"ssh {integration_vm_username}@{integration_vm_address} '{delete_command_2}'"
        },
    )
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


# ============== Feature specific keywords ================


def verify_presence_of_pcmd_messages_uecalltype(path: str):
    with open(path, "r") as f:
        data = f.read()
    parsed_packets = json.loads(
        data, object_pairs_hook=array_on_duplicate_keys)
    ueCallType_found = False

    logger.info(f'{" Performing ueCallType verification ":-^100}',
                also_console=True)

    for packet in parsed_packets:
        try:
            recording_session_element = next(
                gen_dict_extract(
                    "nsetapx.startRecordingSession_element", packet)
            )
        except StopIteration:
            continue

        logger.info(recording_session_element, also_console=True)

        extension_element = None
        extension_extractor = gen_dict_extract(
            "nsetapx.extension_element", recording_session_element
        )
        for _ in range(3):
            try:
                extension_element = next(extension_extractor)
            except StopIteration:
                raise AssertionError(
                    "Unexpected packet structure, ueCallType is not nested 3 extension elements deep"
                )
        try:
            ueCallType_element = next(
                gen_dict_extract("nsetapx.ueCallType", extension_element)
            )
        except StopIteration:
            continue
        ueCallType_found = True
        logger.info(
            f"ueCallType value: {ueCallType_element}", also_console=True)

    if not ueCallType_found:
        raise AssertionError("ueCallType not found in any of packets")


def verify_presence_of_pcmd_messages_pwrheadroomrecord(path: str):
    with open(path, "r") as f:
        data = f.read()
    parsed_packets = json.loads(
        data, object_pairs_hook=array_on_duplicate_keys)
    pwrHeadroomRecord_found = False

    # DuVendorExtensionRecordDataType: pwrHeadroomRecord (25)

    logger.info(
        f'{" Performing pwrHeadroomRecord verification ":-^100}', also_console=True
    )

    for packet in parsed_packets:
        for du_record_element in gen_dict_extract("nsetapx.DuRecord_element", packet):
            try:
                data_tree = next(
                    gen_dict_extract("nsetapx.data_tree", du_record_element)
                )
            except StopIteration:
                continue

            try:
                vendor_extension_data_element = next(
                    gen_dict_extract(
                        "nsetapx.vendorExtensionData_element", data_tree)
                )
            except StopIteration:
                continue

            ver_id = next(
                gen_dict_extract("nsetapx.ver_Id",
                                 vendor_extension_data_element)
            )

            if ver_id != "25":
                continue
            logger.info("Found packet with expected ver-id (25)",
                        also_console=True)

            logger.info(du_record_element, also_console=True)

            try:
                ver_payload_tree = next(
                    gen_dict_extract(
                        "nsetapx.ver_Payload_tree", vendor_extension_data_element
                    )
                )
            except StopIteration:
                continue

            try:
                du_vendor_extension_record_data_type = next(
                    gen_dict_extract(
                        "nsetapx.DuVendorExtensionRecordDataType", ver_payload_tree
                    )
                )
                du_vendor_extension_record_data_type_tree = next(
                    gen_dict_extract(
                        "nsetapx.DuVendorExtensionRecordDataType_tree", ver_payload_tree
                    )
                )
            except StopIteration:
                continue

            if du_vendor_extension_record_data_type is None:
                logger.info(
                    "Vendor extension data type is none, continuing", also_console=True
                )
                continue

            if du_vendor_extension_record_data_type != "25":
                logger.info(
                    "Du vendor extension record data type is not 25, continueing",
                    also_console=True,
                )
                continue

            logger.info(
                f"Found packet with expected record data type (25)", also_console=True
            )

            pwrHeadroomRecord = next(
                gen_dict_extract(
                    "nsetapx.pwrHeadroomRecord",
                    du_vendor_extension_record_data_type_tree,
                )
            )

            if pwrHeadroomRecord is None:
                raise AssertionError("pwrHeadroomRecord is None")

            pwrHeadroomRecord_tree = next(
                gen_dict_extract(
                    "nsetapx.pwrHeadroomRecord_tree",
                    du_vendor_extension_record_data_type_tree,
                )
            )
            nsetapx_data_element = next(
                gen_dict_extract("nsetapx.data_element",
                                 pwrHeadroomRecord_tree)
            )

            if "per.extension_bit" not in nsetapx_data_element:
                raise AssertionError(
                    "per.extension_bit not found in nsetapx data element"
                )

            if "per.extension_present_bit" not in nsetapx_data_element:
                raise AssertionError(
                    "per.extension_present_bit not found in nsetapx data element"
                )

            powerHeadroomReport = next(
                gen_dict_extract("nsetapx.powerHeadroomReport",
                                 nsetapx_data_element)
            )

            logger.info(
                f"powerHeadroomReport value: {powerHeadroomReport}", also_console=True
            )

            if powerHeadroomReport is None:
                raise AssertionError(
                    "powerHeadroomReport is none in pwrHeadroomReport object"
                )

            pwrHeadroomRecord_found = True

    if not pwrHeadroomRecord_found:
        raise AssertionError("pwrHeadroomRecord not found in any of packets")


def verify_presence_of_pcmd_messages_channelstateinfo(path: str):
    with open(path, "r") as f:
        data = f.read()
    parsed_packets = json.loads(
        data, object_pairs_hook=array_on_duplicate_keys)
    channelStateInfo_found = False

    # ver-Id: id-VER-GNB-DU-ChannelStateInfoReportTraceRecord (23)

    logger.info(
        f'{" Performing channelStateInfoTraceRecord verification ":-^100}',
        also_console=True,
    )

    for packet in parsed_packets:
        for du_record_element in gen_dict_extract("nsetapx.DuRecord_element", packet):
            try:
                data_tree = next(
                    gen_dict_extract("nsetapx.data_tree", du_record_element)
                )
            except StopIteration:
                continue

            try:
                vendor_extension_data_element = next(
                    gen_dict_extract(
                        "nsetapx.vendorExtensionData_element", data_tree)
                )
            except StopIteration:
                continue

            ver_id = next(
                gen_dict_extract("nsetapx.ver_Id",
                                 vendor_extension_data_element)
            )

            if ver_id != "23":
                continue
            logger.info("Found packet with expected ver-id (23)",
                        also_console=True)

            logger.info(du_record_element, also_console=True)

            try:
                ver_payload_tree = next(
                    gen_dict_extract(
                        "nsetapx.ver_Payload_tree", vendor_extension_data_element
                    )
                )
            except StopIteration:
                continue

            try:
                du_vendor_extension_record_data_type = next(
                    gen_dict_extract(
                        "nsetapx.DuVendorExtensionRecordDataType", ver_payload_tree
                    )
                )
                du_vendor_extension_record_data_type_tree = next(
                    gen_dict_extract(
                        "nsetapx.DuVendorExtensionRecordDataType_tree", ver_payload_tree
                    )
                )
            except StopIteration:
                continue

            if du_vendor_extension_record_data_type is None:
                logger.info(
                    "Vendor extension data type is none, continuing", also_console=True
                )
                continue

            if du_vendor_extension_record_data_type != "23":
                logger.info(
                    "Du vendor extension record data type is not 23, continueing",
                    also_console=True,
                )
                continue

            logger.info(
                f"Found packet with expected record data type (23)", also_console=True
            )

            csiReportroomRecord = next(
                gen_dict_extract(
                    "nsetapx.csiReportRecord", du_vendor_extension_record_data_type_tree
                )
            )

            if csiReportroomRecord is None:
                raise AssertionError("csiReportRecord is None")

            channelStateInfo_found = True

            csiReportRecord_tree = next(
                gen_dict_extract(
                    "nsetapx.csiReportRecord_tree",
                    du_vendor_extension_record_data_type_tree,
                )
            )
            nsetapx_data_element = next(
                gen_dict_extract("nsetapx.data_element", csiReportRecord_tree)
            )

    if not channelStateInfo_found:
        raise AssertionError("channelStateInfo not found in any of packets")


def verify_presence_of_pcmd_messages_beamusagetracerecord(path: str):
    with open(path, "r") as f:
        data = f.read()
    parsed_packets = json.loads(
        data, object_pairs_hook=array_on_duplicate_keys)
    beamusagetrace_found = False
    endMarker_found = False

    # ver-Id: id-VER-GNB-DU-BeamUsageTraceRecord (9)

    logger.info(
        f'{" Performing BeamUsageTraceRecord verification ":-^100}', also_console=True
    )

    for packet in parsed_packets:
        for du_record_element in gen_dict_extract("nsetapx.DuRecord_element", packet):
            try:
                data_tree = next(
                    gen_dict_extract("nsetapx.data_tree", du_record_element)
                )
            except StopIteration:
                continue

            try:
                vendor_extension_data_element = next(
                    gen_dict_extract(
                        "nsetapx.vendorExtensionData_element", data_tree)
                )
            except StopIteration:
                continue

            ver_id = next(
                gen_dict_extract("nsetapx.ver_Id",
                                 vendor_extension_data_element)
            )

            if ver_id != "9":
                continue
            logger.info("Found packet with expected ver-id (9)",
                        also_console=True)

            logger.info(du_record_element, also_console=True)

            try:
                ver_payload_tree = next(
                    gen_dict_extract(
                        "nsetapx.ver_Payload_tree", vendor_extension_data_element
                    )
                )
            except StopIteration:
                continue

            try:
                du_vendor_extension_record_data_type = next(
                    gen_dict_extract(
                        "nsetapx.DuVendorExtensionRecordDataType", ver_payload_tree
                    )
                )
                du_vendor_extension_record_data_type_tree = next(
                    gen_dict_extract(
                        "nsetapx.DuVendorExtensionRecordDataType_tree", ver_payload_tree
                    )
                )
            except StopIteration:
                continue

            if du_vendor_extension_record_data_type is None:
                logger.info(
                    "Vendor extension data type is none, continuing", also_console=True
                )
                continue

            if du_vendor_extension_record_data_type != "9":
                logger.info(
                    "Du vendor extension record data type is not 9, continueing",
                    also_console=True,
                )
                continue

            logger.info(
                f"Found packet with expected record data type (9)", also_console=True
            )

            if du_vendor_extension_record_data_type_tree is None:
                raise AssertionError(
                    "du_vendor_extension_record_data_type_tree is None"
                )

            beamusagetrace_found = True

            beamUsageRecord = next(
                gen_dict_extract(
                    "nsetapx.beamUsageRecord", du_vendor_extension_record_data_type_tree
                )
            )
            beamUsageRecord_tree = next(
                gen_dict_extract(
                    "nsetapx.beamUsageRecord_tree",
                    du_vendor_extension_record_data_type_tree,
                )
            )

            nsetapx_data_element = next(
                gen_dict_extract("nsetapx.data_r1_element",
                                 beamUsageRecord_tree)
            )

            if "nsetapx.endMarker" not in nsetapx_data_element:
                raise AssertionError(
                    "nsetapx.endMarker not found in nsetapx data element"
                )

            endMarker = next(
                gen_dict_extract("nsetapx.endMarker", nsetapx_data_element)
            )
            logger.info(f"endMarker value: {endMarker}", also_console=True)
            record_timestamp = next(
                gen_dict_extract("nsetapx.tstamp", du_record_element)
            )
            # timestamp format: Apr 10, 2024 13:37:54.384414000 UTC
            parsed_timestamp = datetime.datetime.strptime(
                record_timestamp[:-7], "%b %d, %Y %H:%M:%S.%f"
            )
            logger.info(
                f"parsed timestamp: {parsed_timestamp}", also_console=True)

            if endMarker == "1":
                endMarker_found = True
                logger.info('endMarker with value "1" found',
                            also_console=True)

    if not beamusagetrace_found:
        raise AssertionError("beamusagetrace not found in any of packets")

    if not endMarker_found:
        raise AssertionError("endMarker not found in any of packets")
