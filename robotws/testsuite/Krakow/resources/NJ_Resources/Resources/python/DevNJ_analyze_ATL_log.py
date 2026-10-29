# -*- coding: utf-8 -*-
"""
:author: fuzeng.zhu
:contact: fuzeng.zhu@nokia-sbell.com
"""
import pyshark
import re
import os
import io
import gzip
import tarfile
import xmltodict
import json
import time
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_SCF_Filter import DevNJ_SCF_Filter
from pprint import pprint
import platform

if "Linux" == platform.system():
    cmd_asyncio = "pip3 install nest_asyncio"
    os.system(cmd_asyncio)
    try:
        cmd_asyncio = "source /home/ute/test_repo/bin/activate; pip3 install nest_asyncio"
        os.system(cmd_asyncio)
    except Exception as e:
        pass
    import nest_asyncio

'''
<ne3scommon:notificationType>ne3s_atl_logUploadNotification</ne3scommon:notificationType>
<ne3scommon:compression>gzip</ne3scommon:compression>
<ne3scommon:contentType>oats</ne3scommon:contentType>
'''


def pick_attachments_from_pcap(pcap_path, recog_xml_regexes=["ne3s_atl_logUploadNotification", "gzip", "oats"],
                               tmp_folder="/tmp/pyshark"):
    """
    Main Function:
    Keyword of pick_attachments_from_pcap provides function that analyze ATL log.

    Arguments:
    :param pcap_path: the path of pcap file that to be analyzed
    :param recog_xml_regexes: a list of filters, that can filter needed data in pcap file
    :tmp_folder: path to temporarily store intermediate files
    :return: parsed dict data from pcap file

    Examples:
    | ${alt_log} | Pick Attachments From Pcap | pcap_path=${path_to_wireshark_file} |
    ...                                       | recog_xml_regexes=["ne3s_atl_logUploadNotification", "gzip", "oats"] |
    """
    try:
        def remove_key_prefix(json_str):
            return re.sub(r"(\")(@)(\w+\":)", r"\1\3", json_str)

        if not os.path.exists(tmp_folder):
            os.makedirs(tmp_folder)

        dict_packet_to_zip_content = {}
        tmp_packet_txt_path = os.path.join(tmp_folder, "packet_tmp.txt")
        tmp_packet_zip_path = os.path.join(tmp_folder, "packet_attachment")
        if "Linux" == platform.system():
            nest_asyncio.apply()  # solve problem: RuntimeError: This event loop is already running
        cap = pyshark.FileCapture(pcap_path, display_filter="http")
        packets = [packet for packet in cap if packet.highest_layer == 'MIME_MULTIPART']
        for packet in packets:
            if "boundary" in packet.mime_multipart.field_names:
                str_boundary = packet.mime_multipart.boundary
            elif "first_boundary" in packet.mime_multipart.field_names:
                str_boundary = packet.mime_multipart.first_boundary
            else:
                continue
            with open(tmp_packet_txt_path, "wb+") as f:
                try:
                    for b in packet.DATA.tcp_reassembled_data.split(":"):
                        f.write((int(b, 16)).to_bytes(1, 'big'))
                except Exception as e:
                    print("packet {} exception {}".format(
                        packet.number, str(e)))
                    continue
            with open(tmp_packet_txt_path, "r", encoding="utf-8", errors='ignore') as f:
                lines = f.readlines()
            boundary_indexes = [lineNo for lineNo, line in enumerate(
                lines) if str_boundary.strip() in line]
            block_lines = None
            start_index = 0
            for bi in boundary_indexes:
                block_lines = lines[start_index: bi]
                # find this packet has xml block
                if "Content-Type: text/xml" in "".join(block_lines):
                    break
                start_index = bi + 1
            else:
                continue  # not a xml packet, go to next packet

            xml_content = "".join(block_lines)
            if not all([re.search(regex_str, xml_content) is not None for regex_str in recog_xml_regexes]):
                continue  # not match the recog_xml_regexes, go to next packet

            dict_packet_to_zip_content[packet.number] = {"xml_content": xml_content}
            xml_extracted = re.search(r'<SOAP-ENV:Body>.+<\/SOAP-ENV:Body>', xml_content)
            if xml_extracted:
                xml_json = remove_key_prefix(
                    json.dumps(xmltodict.parse(xml_extracted[0])))
                # dict_packet_to_zip_content[packet.number]["xml_json"] = xml_json
                dict_packet_to_zip_content[packet.number]["xml_dict"] = json.loads(
                    xml_json)

            dict_packet_to_zip_content[packet.number]["attachments"] = []

            # match the recog_xml_regexes, pick zip or tar
            with open(tmp_packet_zip_path, "wb+") as f:
                try:
                    for b in packet.mime_multipart.data_data.split(":"):
                        f.write((int(b, 16)).to_bytes(1, 'big'))
                except Exception as e:
                    print("packet {} exception: {}".format(
                        packet.number, str(e)))
                    continue

            if "gzip" in recog_xml_regexes:
                with gzip.open(tmp_packet_zip_path) as f:
                    with io.TextIOWrapper(f, encoding='utf-8') as wrapper:
                        zipped_xml = wrapper.read()
                        zipped_dict = json.loads(remove_key_prefix(
                            json.dumps(xmltodict.parse(zipped_xml))))
                        record = zipped_dict.get("log", {}).get("record")
                        if record and isinstance(record, dict):
                            zipped_dict["log"]["record"] = [record]
                        dict_packet_to_zip_content[packet.number]["attachments"].append(
                            {"zipped_xml": zipped_xml, "zipped_dict": zipped_dict})

            elif "tar" in recog_xml_regexes:
                tar_extracted_path = os.path.join(
                    tmp_folder, str(int(time.time() * 1000)))
                if os.path.exists(tar_extracted_path):
                    os.remove(tar_extracted_path)
                try:
                    tarfile.open(tmp_packet_zip_path).extractall(
                        tar_extracted_path)
                except Exception as e:
                    print("packet {} extract tar exception: {}".format(
                        packet.number, str(e)))
                dict_packet_to_zip_content[packet.number]["attachments"] = []
                for xml_file in os.listdir(tar_extracted_path):
                    xml_path = os.path.join(tar_extracted_path, xml_file)
                    if os.path.isfile(xml_path) and xml_path.lower().endswith(".xml"):
                        with open(xml_path) as f:
                            try:
                                zipped_xml = f.read()
                                zipped_dict = json.loads(remove_key_prefix(
                                    json.dumps(xmltodict.parse(zipped_xml))))
                                record = zipped_dict.get(
                                    "log", {}).get("record")
                                if record and isinstance(record, dict):
                                    zipped_dict["log"]["record"] = [record]
                                dict_packet_to_zip_content[packet.number]["attachments"].append(
                                    {"zipped_xml": zipped_xml, "zipped_dict": zipped_dict})
                            except Exception as e:
                                print("packet {} extract xml {} exception: {}".format(
                                    packet.number, xml_file, str(e)))

            else:
                pass

        return dict_packet_to_zip_content

    finally:
        for p in [tmp_packet_txt_path, tmp_packet_zip_path]:
            if os.path.exists(p):
                os.remove(p)


def get_default_comparer():
    # regex for UTC time string, eg. "2023-01-06T10:41:57+00:00"
    reg_str_utc = r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2}$"
    # regex for IPV4 or IPV6 string, eg. "192.168.25.33" or "fe80::3380:58b8:6310:f4d9%4"
    reg_str_NEIPAddress = r"^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\." \
                          "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" \
                          "(?::(\\d|[1-9]\\d{1,3}|[1-5]\\d{4}|6[0-4]\\d{3}|65[0-4]\\d{2}|655[0-2]\\d|6553[0-5]))?$"
    # regex for IPV4 string, eg. "192.168.25.33"
    reg_str_clientIPAddress = r"^(?:25[0-5]|2[0-4]\d|[0-1]?\d{1,2})(?:\.(?:25[0-5]|2[0-4]\d|[0-1]?\d{1,2})){3}$"
    # regex for string, starts with "SM-1019"
    reg_str_additional_example = r"^SM-1019"
    return {
        "creationTime": reg_str_utc,
        "$.record.*/NEIPAddress": reg_str_NEIPAddress,
        "$.record.*/additionalText": reg_str_additional_example,
        "$.record.*/clientIPAddress": reg_str_clientIPAddress,
        "$.record.*/eventTime": reg_str_utc,
        "$.record.*/logStatus": r"^success$",
        "$.record.*/operation": r"^unitUnblock$",
        "$.record.*/sessionID": r"^\d+$",
    }


def transfer_to_scf_comparer(plain_comparer):
    """
    Main Function:
    Keyword of transfer_to_scf_comparer provides function that transfer plain comparer to scf filter comparer

    Arguments:
    :param plain_comparer: a dictionary to compare, whose keys are user friendly words
    :return: a scf comparer to filter

    Examples:
    ${additionaltext_reset_antmod}  Evaluate  "^SM-1019,Unit reset request for ASI-\\d.ASI_R-\\d.ANTMOD_R-\\d$"
    ${plain_comparer}  Create Dictionary  NEIPAddress=192.168.255.129:3601
    ...                                 AdditionalText=${additionaltext_reset_antmod}
    ...                                 ClientIPAddress=192.168.255.126
    ...                                 LogStatus=success
    ...                                 Operation=unitReset
    | ${scf_comparer}  | Transfer to SCF Comparer | plain_comparer=${plain_comparer} |
    """

    scf_comparer = {}

    for scf_comparer_k, scf_comparer_v in get_default_comparer().items():
        for plain_k, plain_v in plain_comparer.items():
            if plain_k.lower() in scf_comparer_k.split("/")[-1].lower():
                scf_comparer[scf_comparer_k] = plain_v
                break
        else:
            scf_comparer[scf_comparer_k] = scf_comparer_v

    return scf_comparer


def get_copy_of_comparer(comparer):
    return json.loads(json.dumps(comparer))


def atl_log_compare(dict_zip_content, list_comparer):
    """
    Main Function:
    Keyword of atl_log_compare provides function that

    Arguments:
    :param dict_zip_content: parsed data from pcap file
    :param list_comparer: it is a list to compare
    :return: dictionry of Check Result

    Examples:
    ${list_comparer}  Create List  ${compare_dict_reset_hubmod_new}  ${compare_dict_reset_antmod_new}
    ...                            ${compare_dict_block_antmod_new}  ${compare_dict_unblock_new_antmod}
    | ${res} | Atl Log Compare | dict_zip_content=${alt_log} | list_comparer=${list_comparer} |
    """
    dict_res = {"res": True, "comparer_details": {}}
    scf_filter_on_logs = DevNJ_SCF_Filter(dict_zip_content)["$..attachments"]["$..zipped_dict"]["*"]

    for i, comparer in enumerate(list_comparer):
        comparer_filter = scf_filter_on_logs.filter(comparer)

        if len(comparer_filter):
            dict_res["comparer_details"][str(i)] = {"res": True, "objects": comparer_filter.MO_List,
                                                    "objects_cnt": len(comparer_filter)}
        else:
            dict_res["comparer_details"][str(i)] = {"res": False}
            dict_res["res"] = False

    return dict_res


def test_pick_gzip(pcap_path):
    print("=" * 20 + "test_pick_gzip" + "=" * 20)
    recog_xml_regexes = ["gzip"]

    res = pick_attachments_from_pcap(
        pcap_path, recog_xml_regexes=recog_xml_regexes)
    with open("/home/ute/test_pick_gzip.json", "w+") as f:
        json.dump(res, f)
    pprint(res)


def test_pick_tar(pcap_path):
    print("=" * 20 + "test_pick_tar" + "=" * 20)
    recog_xml_regexes = [r"PLMN-PLMN\/ASI-\d+", "tar", "oats"]
    res = pick_attachments_from_pcap(
        pcap_path, recog_xml_regexes=recog_xml_regexes)
    with open("/home/ute/test_pick_tar.json", "w+") as f:
        json.dump(res, f)
    pprint(res)


if __name__ == "__main__":

    pcap_file = "/tmp/atl_upload_succ_expect.pcap"
    test_pick_gzip(pcap_file)
    test_pick_tar(pcap_file)
    dict_log_info = pick_attachments_from_pcap(pcap_file, recog_xml_regexes=[
        "ne3s_atl_logUploadNotification", "gzip", "oats"])
    # dict_log_info = pick_attachments_from_pcap(pcap_file, recog_xml_regexes=["tar", "oats"])
    with open("/tmp/pcap.json", "w+") as f:
        json.dump(dict_log_info, f)
    comparer_1 = get_default_comparer()
    comparer_1["$.record.*/operation"] = "checkParameters"
    comparer_1["$.record.*/additionalText"] = r"^SM-1019;"

    comparer_2 = get_copy_of_comparer(comparer_1)
    comparer_2["$.record.*/operation"] = "getFaults"
    comparer_2["$.record.*/additionalText"] = r"Get faults request$"

    comparer_3 = get_default_comparer()
    comparer_3["$.record.*/operation"] = "unitReset"
    comparer_3["$.record.*/additionalText"] = r"^SM-1019;"

    res = atl_log_compare(dict_log_info, [comparer_1, comparer_2, comparer_3])
    with open("res.json", "w+") as f:
        json.dump(res, f)
    pprint(res)

    plain_comparer = {
        "NEIPAddress": "192.168.255.129:3601",
        "AdditionalText": "^SM-1019,Unit reset request for ASI-\\d.ASI_R-\\d.ANTMOD_R-\\d$",
        "ClientIPAddress": "192.168.255.126",
        "LogStatus": "success",
        "Operation": "unitReset"
    }
    scf_comparer = transfer_to_scf_comparer(plain_comparer)
    pprint(scf_comparer)
    res = atl_log_compare(dict_log_info, [scf_comparer])
    with open("res.json", "w+") as f:
        json.dump(res, f)
    pprint(res)
