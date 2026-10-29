import re
import csv


def split_file_into_datasets(file_path):
    """
    Split the RESP file into datasets based on the root message.

    :param file_path: Path to the RESP file.
    :return: List of datasets, where each dataset is a list of lines.
    """
    datasets = []

    with open(file_path, "r") as file:
        lines = file.readlines()

    while lines:
        root_message = lines.pop(0).strip()
        current_dataset = [root_message]

        while lines:
            line = lines.pop(0).strip()
            if root_message in line:
                current_dataset.append(line)
            else:
                lines.insert(0, line)
                break

        datasets.append(current_dataset)

    return datasets


def parse_uldata_from_resp(file_path):
    """
    Parse the RESP file to extract sfn, slot, rnti, crc, dtx and sinr values.

    :param file_path: Path to the RESP file.
    :return: Dictionary with sfn_slot as key and rnti-crc-dtx-snr mappings as lists.
    """
    datasets = split_file_into_datasets(file_path)
    result = {}
    target_msgs = [
        "UlData_PuschReceiveRespHarqUL1sw_t",
        "UlData_SrsReceiveRespPs_t",
        "UlDataFH_SrsSuMimoReceiveRespPs_t",
        "UlData_PucchReceiveRespPsL1sw_t",
        "UlData_PuschReceiveRespPs_t"
    ]
    for dataset in datasets:
        for target_msg in target_msgs:
            sfn, slot = None, None
            rnti_list, crc_list, snr_list, dtx_list = [], [], [], []
            pucch_rnti_list, pucch_crc_list, pucch_dtx_list = [], [], []

            for line in dataset:
                if sfn is None:
                    sfn_match = re.match(
                        r"{}.sfn\s*=\s*0x[0-9A-Fa-f]+\s*=\s*(\d+)".format(target_msg), line
                    )
                    if sfn_match:
                        sfn = sfn_match.group(1)
                        continue

                if slot is None:
                    slot_match = re.match(
                        r"{}.slot\s*=\s*0x[0-9A-Fa-f]+\s*=\s*(\d+)".format(target_msg), line
                    )
                    if slot_match:
                        slot = slot_match.group(1)
                        continue

                rnti_match = re.match(
                    r"{}.*grants\[\d+\]\.rnti\s*=\s*0x[0-9A-Fa-f]+\s*=\s*(\d+)".format(target_msg), line
                )
                crc_match = re.match(
                    r"{}.*grants\[\d+\]\.crc\s*=\s*0x[0-9A-Fa-f]+\s*=\s*(\d+)".format(target_msg), line
                )
                snr_match = re.match(
                    r"{}.*srsReceiveRespPsUes\[\d+\]\.snr\s*=\s*0x[0-9A-Fa-f]+\s*=\s*(\d+)".format(target_msg), line
                )
                sinr_match = re.match(
                    r"{}.*srsReceiveRespPsUes\[\d+\]\.sinr\s*=\s*0x[0-9A-Fa-f]+\s*=\s*(\d+)".format(target_msg), line
                )
                dtx_match = re.match(
                    r"{}.*srsReceiveRespPsUes\[\d+\]\.dtx\s*=\s*0x[0-9A-Fa-f]+\s*=\s*(\d+)".format(target_msg), line
                )
                pucch_rnti_match = re.match(
                    r"{}.*pucchResources\[\d+\]\.rnti\s*=\s*0x[0-9A-Fa-f]+\s*=\s*(\d+)".format(target_msg), line
                )
                pucch_crc_match = re.match(
                    r"{}.*pucchResources\[\d+\]\.crc\s*=\s*0x[0-9A-Fa-f]+\s*=\s*(\d+)".format(target_msg), line
                )
                pucch_dtx_match = re.match(
                    r"{}.*pucchResources\[\d+\]\.dtx\s*=\s*0x[0-9A-Fa-f]+\s*=\s*(\d+)".format(target_msg), line
                )

                if rnti_match:
                    rnti_list.append(int(rnti_match.group(1)))
                if crc_match:
                    crc_list.append(int(crc_match.group(1)))
                if snr_match:
                    snr_list.append(int(snr_match.group(1)))
                if sinr_match:
                    snr_list.append(int(sinr_match.group(1)))
                if dtx_match:
                    dtx_list.append(int(dtx_match.group(1)))
                if pucch_rnti_match:
                    pucch_rnti_list.append(int(pucch_rnti_match.group(1)))
                if pucch_crc_match:
                    pucch_crc_list.append(int(pucch_crc_match.group(1)))
                if pucch_dtx_match:
                    pucch_dtx_list.append(int(pucch_dtx_match.group(1)))

            if sfn and slot:
                key = f"sfn{sfn}_slot{slot}"
                result[key] = {"rnti": rnti_list, "crc": crc_list, "snr": snr_list, "dtx": dtx_list}
            if sfn and slot and "Pucch" in target_msg:
                key = f"pucch_sfn{sfn}_slot{slot}"
                result[key] = {"rnti": pucch_rnti_list, "crc": pucch_crc_list, "dtx": pucch_dtx_list}

    return result


def parse_pucch_data_from_resp(file_path):
    """
    Parse the RESP file to extract sfn, slot, rnti, crc, dtx values.

    :param file_path: Path to the RESP file.
    :return: Dictionary with sfn_slot as key and rnti-crc-dtx-snr mappings as lists.
    """
    datasets = split_file_into_datasets(file_path)
    result = {}
    target_msgs = [
        "UlData_PucchReceiveRespPsL1sw_t"
    ]
    for dataset in datasets:
        for target_msg in target_msgs:
            sfn, slot = None, None
            pucch_rnti_list, pucch_crc_list, pucch_dtx_list = [], [], []

            for line in dataset:
                if sfn is None:
                    sfn_match = re.match(
                        r"{}.sfn\s*=\s*0x[0-9A-Fa-f]+\s*=\s*(\d+)".format(target_msg), line
                    )
                    if sfn_match:
                        sfn = sfn_match.group(1)
                        continue

                if slot is None:
                    slot_match = re.match(
                        r"{}.slot\s*=\s*0x[0-9A-Fa-f]+\s*=\s*(\d+)".format(target_msg), line
                    )
                    if slot_match:
                        slot = slot_match.group(1)
                        continue

                pucch_rnti_match = re.match(
                    r"{}.*pucchResources\[\d+\]\.rnti\s*=\s*0x[0-9A-Fa-f]+\s*=\s*(\d+)".format(target_msg), line
                )
                pucch_crc_match = re.match(
                    r"{}.*pucchResources\[\d+\]\.crc\s*=\s*0x[0-9A-Fa-f]+\s*=\s*(\d+)".format(target_msg), line
                )
                pucch_dtx_match = re.match(
                    r"{}.*pucchResources\[\d+\]\.dtx\s*=\s*0x[0-9A-Fa-f]+\s*=\s*(\d+)".format(target_msg), line
                )

                if pucch_rnti_match:
                    pucch_rnti_list.append(int(pucch_rnti_match.group(1)))
                if pucch_crc_match:
                    pucch_crc_list.append(int(pucch_crc_match.group(1)))
                if pucch_dtx_match:
                    pucch_dtx_list.append(int(pucch_dtx_match.group(1)))

            if sfn and slot:
                key = f"sfn{sfn}_slot{slot}"
                result[key] = {"rnti": pucch_rnti_list, "crc": pucch_crc_list, "dtx": pucch_dtx_list}

    return result


def parse_pusch_summary(file_path):
    """
    Parse the CSV file to extract 'PuschRnti' and 'PuschCrcError' values for each sfn_slot.

    :param file_path: Path to the input CSV file.
    :return: Dictionary with sfn_slot as key and relevant mappings as lists.
    """
    result = {}

    with open(file_path, "r") as file:
        reader = csv.reader(file)
        headers = next(reader)

        sfn_slot_index = 0
        pusch_rnti_index = headers.index("PuschRnti")
        pusch_crc_error_index = headers.index("PuschCrcError")
        pusch_rv_index = headers.index("RV")

        for row in reader:
            sfn_slot = row[sfn_slot_index]
            pusch_rnti = list(
                map(int, row[pusch_rnti_index].strip().strip(";").split(";"))
            )
            pusch_crc_error = list(
                map(int, row[pusch_crc_error_index].strip().strip(";").split(";"))
            )
            pusch_rv = list(
                map(int, row[pusch_rv_index].strip().strip(";").split(";"))
            )

            result[sfn_slot] = {
                "PuschRnti": pusch_rnti,
                "PuschCrcError": pusch_crc_error,
                "RV": pusch_rv,
            }

    return result


def parse_pucch_summary(file_path):
    """
    Parse the CSV file to extract 'PuschRnti' and 'PuschCrcError' values for each sfn_slot.

    :param file_path: Path to the input CSV file.
    :return: Dictionary with sfn_slot as key and relevant mappings as lists.
    """
    result = {}

    with open(file_path, "r") as file:
        reader = csv.reader(file)
        headers = next(reader)

        sfn_slot_index = 0
        pucch_rnti_index = headers.index("PucchRnti")
        pucch_dtx_index = headers.index("PucchDtx")
        pucch_crc_error_index = headers.index("PucchCrcError")

        for row in reader:
            sfn_slot = row[sfn_slot_index]
            pucch_rnti = list(
                map(int, row[pucch_rnti_index].strip().strip(";").split(";"))
            )
            pucch_dtx = list(
                map(int, row[pucch_dtx_index].strip().strip(";").split(";"))
            )
            pucch_crc_error = list(
                map(int, row[pucch_crc_error_index].strip().strip(";").split(";"))
            )

            result[sfn_slot] = {
                "PucchRnti": pucch_rnti,
                "PucchDtx": pucch_dtx,
                "PucchCrcError": pucch_crc_error
            }

    return result


def Check_UL_5Gmax(resp_file, bundled_summary_file):
    """
    Compare the results from parse_uldata_from_resp and parse_pusch_summary.
    If a resp_result key is a substring of a bundled_result key, perform the comparison.

    :param resp_file: Path to the RESP file.
    :param bundled_summary_file: Path to the bundled summary CSV file.
    :raises Exception: If any comparison fails.
    """
    resp_result = parse_uldata_from_resp(resp_file)
    bundled_result = parse_pusch_summary(bundled_summary_file)
    print("RESP Result:", resp_result)
    print("Bundled Result:", bundled_result)

    for resp_key, resp_value in resp_result.items():
        matching_key = None
        for bundled_key in bundled_result:
            if resp_key in bundled_key:
                matching_key = bundled_key
                break

        if matching_key:
            resp_rnti = resp_value["rnti"]
            resp_crc = resp_value["crc"]
            bundled_rnti = bundled_result[matching_key]["PuschRnti"]
            bundled_crc = bundled_result[matching_key]["PuschCrcError"]
            bundled_rv = bundled_result[matching_key]["RV"]

            if not resp_rnti or not resp_crc:
                raise Exception(f"{resp_key}: RESP RNTI and CRC are both empty.")

            failed_parts = []
            for i, rnti in enumerate(resp_rnti):
                if rnti in bundled_rnti:
                    bundled_index = bundled_rnti.index(rnti)
                    RV = bundled_rv[bundled_index]
                    if RV > 0:
                        print(f'[WARN] <{matching_key}> Skipped to check CRC due to slot retransmission: RV = {RV}.')
                        print(f"RNTI --------------- {rnti}")
                        print(f"RESP CRC ----------- [ {resp_crc[i]} ]")
                        print(f"Bundled CRC -------- [ {bundled_crc[bundled_index]} ]")
                        print(f"Bundled RV --------- [ {bundled_rv[bundled_index]} ]")
                        continue
                    elif resp_crc[i] != bundled_crc[bundled_index]:
                        failed_parts.append(
                            f"RNTI {rnti}:\nRESP CRC ----------- [ {resp_crc[i]} ]"
                            f"\nBundled CRC -------- [ {bundled_crc[bundled_index]} ]"
                            f"\nBundled RV --------- [ {bundled_rv[bundled_index]} ]"
                        )
                    else:
                        print(f"{resp_key} (matches {matching_key}):")
                        print(f"  RNTI and CRC Match: PASS")
                        print(f"    RESP RNTI:    {resp_rnti}")
                        print(f"    RESP CRC:     {resp_crc}")
                        print(f"    Bundled RNTI: {bundled_rnti}")
                        print(f"    Bundled CRC:  {bundled_crc}")
                else:
                    failed_parts.append(f"RNTI {rnti}: Not found in Bundled RNTI")

            if failed_parts:
                raise Exception(
                    f"Comparison failed for {resp_key} (matches {matching_key}):\n"
                    + "\n".join(failed_parts)
                )
        else:
            raise Exception(f"{resp_key}: NO MATCHING KEY in bundled_result")


def Check_PUCCH_RESP(resp_file, bundled_summary_file):
    """
    Compare the results from parse_uldata_from_resp and parse_pucch_summary.
    If a resp_result key is a substring of a bundled_result key, perform the comparison.

    :param resp_file: Path to the RESP file.
    :param bundled_summary_file: Path to the bundled summary CSV file.
    :raises Exception: If any comparison fails.
    """
    resp_result = parse_pucch_data_from_resp(resp_file)
    bundled_result = parse_pucch_summary(bundled_summary_file)
    print("RESP Result:", resp_result)
    print("Bundled Result:", bundled_result)

    for resp_key, resp_value in resp_result.items():
        matching_key = None
        for bundled_key in bundled_result:
            if resp_key in bundled_key:
                matching_key = bundled_key
                break

        if matching_key:
            resp_rnti = resp_value["rnti"]
            resp_crc = resp_value["crc"]
            resp_dtx = resp_value["dtx"]
            bundled_rnti = bundled_result[matching_key]["PucchRnti"]
            bundled_crc = bundled_result[matching_key]["PucchCrcError"]
            bundled_dtx = bundled_result[matching_key]["PucchDtx"]

            if not resp_rnti or not resp_crc:
                raise Exception(f"{resp_key}: RESP RNTI and CRC are both empty.")

            failed_parts = []
            for i, rnti in enumerate(resp_rnti):
                if rnti in bundled_rnti:
                    bundled_index = bundled_rnti.index(rnti)
                    if resp_crc[i] != bundled_crc[bundled_index]:
                        failed_parts.append(
                            f"RNTI {rnti}:\nRESP CRC ----------- [ {resp_crc[i]} ]"
                            f"\nBundled CRC -------- [ {bundled_crc[bundled_index]} ]"
                        )
                    if resp_dtx[i] != bundled_dtx[bundled_index]:
                        failed_parts.append(
                            f"RNTI {rnti}:\nRESP DTX ----------- [ {resp_dtx[i]} ]"
                            f"\nBundled DTX -------- [ {bundled_dtx[bundled_index]} ]"
                        )
                else:
                    failed_parts.append(f"RNTI {rnti}: Not found in Bundled RNTI")

            if failed_parts:
                raise Exception(
                    f"Comparison failed for {resp_key} (matches {matching_key}):\n"
                    + "\n".join(failed_parts)
                )

            print(f"{resp_key} (matches {matching_key}):")
            print(f"  RNTI, CRC and DTX Match: PASS")
            print(f"    RESP RNTI: {resp_rnti}")
            print(f"    RESP CRC: {resp_crc}")
            print(f"    RESP DTX: {resp_dtx}")
            print(f"    Bundled RNTI: {bundled_rnti}")
            print(f"    Bundled CRC: {bundled_crc}")
            print(f"    Bundled DTX: {bundled_dtx}")
        else:
            raise Exception(f"{resp_key}: NO MATCHING KEY in bundled_result")


def parse_pdsch_summary(file_path):
    """
    Parse the CSV file to extract RV==0 and corresponding CrcErrorOfPDSCH values for each sfn_slot.

    :param file_path: Path to the input CSV file.
    :return: Dictionary with sfn_slot as key and relevant mappings as lists.
    """
    result = {}

    with open(file_path, "r") as file:
        reader = csv.reader(file)
        headers = next(reader)

        sfn_slot_index = 0
        pdsch_rv_index = headers.index("RV")
        crc_error_Of_pdsch_index = headers.index("CrcErrorOfPDSCH")

        for row in reader:
            sfn_slot = row[sfn_slot_index]
            pdsch_rv_raw = row[pdsch_rv_index].strip().strip(";").split(";")
            crc_error_raw = row[crc_error_Of_pdsch_index].strip().strip(";").split(";")

            rv_zero = []
            crc_zero = []
            for rv_str, crc_str in zip(pdsch_rv_raw, crc_error_raw):
                rv_str = rv_str.strip()
                crc_str = crc_str.strip()
                if rv_str.isdigit() and int(rv_str) == 0:
                    rv_zero.append(0)
                    if crc_str.isdigit():
                        crc_zero.append(int(crc_str))
                    elif crc_str:
                        crc_zero.append(crc_str)
                    else:
                        crc_zero.append(None)
            result[sfn_slot] = {
                "RV": rv_zero,
                "CrcErrorOfPDSCH": crc_zero,
            }

    return result


def Check_Dl_5Gmax(bundled_summary_file):
    """
    Compare the results from parse_pdsch_summary.
    If a rv result key is zero, perform the comparison.
    :param bundled_summary_file: Path to the bundled summary CSV file.
    :raises Exception: If any comparison fails.
    """
    bundled_result = parse_pdsch_summary(bundled_summary_file)
    print("Bundled Result:", bundled_result)
    bad_slot_dict = {}
    for sfn_slot, value in bundled_result.items():
        pdsch_rv = value["RV"]
        CrcErrorOfPDSCH = value["CrcErrorOfPDSCH"]
        for i in range(len(pdsch_rv)):
            rv = pdsch_rv[i]
            crc_error = CrcErrorOfPDSCH[i]
            if crc_error == 0:
                print(f"SFN_Slot: {sfn_slot}, RV: {rv}, CrcErrorOfPDSCH: {crc_error}, Result: PASS")
            else:
                print(f"SFN_Slot: {sfn_slot}, RV: {rv}, CrcErrorOfPDSCH: {crc_error}, Result: FAIL")
                tmp_dict = {}
                tmp_dict["RV"] = rv
                tmp_dict["CrcErrorOfPDSCH"] = crc_error
                bad_slot_dict[sfn_slot] = tmp_dict
    if len(bad_slot_dict) > 0:
        for slot, item in bad_slot_dict.items():
            print(f"CrcErrorOfPDSCH : FAIL")
            print(f"  SFN slot ---------- [ {slot} ]")
            print(f"  RV ---------------- [ {item['RV']} ]")
            print(f"  CrcErrorOfPDSCH --- [ {item['CrcErrorOfPDSCH']} ]")
        raise Exception(f"[ERROR] DL 5GMax is failed with CrcErrorOfPDSCH is NOT 0: \n{bad_slot_dict}")


def ieee754_hex_to_float32(hex_str):
    """
    Convert IEEE 754 floating point to the decimal number.
    """
    bits = bin(int(hex_str, 16))[2:].zfill(32)
    sign = int(bits[0], 2)
    exponent = int(bits[1:9], 2)
    fraction = bits[9:]

    mantissa = 0.0
    for i, bit in enumerate(fraction):
        mantissa += int(bit) * (2 ** -(i + 1))

    if exponent == 0:
        value = ((-1) ** sign) * (2 ** (-126)) * mantissa
    else:
        value = ((-1) ** sign) * (2 ** (exponent - 127)) * (1 + mantissa)
    return float(f"{value:.6f}")


def Check_SRS_SNR_RESP(resp_file):
    """
    Compare the results from parse_uldata_from_resp.
    Check snr and dtx values for the special sfn_slot.
    Return the list of SNR and DTX values in result.

    :param resp_file: Path to the RESP file.
    :raises Exception: If any comparison fails.
    """
    resp_result = parse_uldata_from_resp(resp_file)
    print("RESP Result:", resp_result)
    snr_dtx_results = []  # List to store SNR and DTX values
    for sfn_slot, value in resp_result.items():
        srs_snr = value["snr"]
        print("snr result:", srs_snr)
        srs_dtx = value["dtx"]
        print("dtx result:", srs_dtx)
        for i in range(len(srs_snr)):
            snr_hex = hex(srs_snr[i])
            print("snr_hex result:", snr_hex)
            snr = ieee754_hex_to_float32(snr_hex)
            print("snr result:", snr)
            dtx = int(srs_dtx[i])
            snr_dtx_results.append((snr, dtx))  # Append SNR and DTX as a tuple
            if dtx != 0:
                raise Exception(f"DTX is not 0: DTX: {dtx}")
    return snr_dtx_results  # Return the list of SNR and DTX values


def Get_SRS_Dump_Value(dump_file, keyword):
    """
    Get the results from srs_dump file in RU side.

    :param dump_file: Path to the dump file.
    :param keyword: Define the keyword to get value.
    :raises Exception: If any comparison fails.
    """
    with open(dump_file, 'r') as file:
        lines = file.readlines()

    for i, line in enumerate(lines):
        if keyword in line:
            value_line = lines[i + 1].strip()
            values = [float(x) for x in value_line.split()]
            return values if len(values) > 1 else values[0]
    raise Exception(f"Keyword '{keyword}' not found in the file.")


if __name__ == "__main__":
    pass
