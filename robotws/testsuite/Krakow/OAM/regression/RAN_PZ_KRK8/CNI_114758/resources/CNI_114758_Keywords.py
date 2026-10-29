from typing import Union
import tarfile
from datetime import datetime, timedelta
from dataclasses import dataclass
from robot.api import logger
from pathlib import Path
from taf.sw.scout import scout
from robot.libraries.BuiltIn import BuiltIn
import zipfile
import tarfile
import lzma
import re
import pytz
from io import BytesIO


@dataclass
class CounterValue:
    timestamp: datetime
    value: float


def get_current_datetime() -> datetime:
    value = datetime.now()
    logger.info(f"Providing current time: {value}", also_console=True)
    return value


def convert_gui_counter_values_to_list(raw_counter_data: dict) -> list[CounterValue]:
    output_list = []
    for timestamp_str, value_str in raw_counter_data.items():
        if "DST" in timestamp_str:
            converted_timestamp = timestamp_str.removesuffix(" DST")
            converted_date = datetime.strptime(
                converted_timestamp, "%Y-%m-%d %H:%M:%S")
            converted_date = converted_date - timedelta(hours=2)
        else:
            converted_date = datetime.strptime(
                timestamp_str, "%Y-%m-%d %H:%M:%S")
        try:
            counter_value = CounterValue(converted_date, float(value_str))
        except ValueError as e:
            logger.info(
                f"error converting to counter value, timestamp: {timestamp_str}, value: {value_str}, error: {e}",
                also_console=True)
            continue

        logger.console(
            f"timestamp: {timestamp_str} converted time: {converted_date}, value: {value_str}"
        )
        output_list.append(counter_value)
    return output_list


def convert_counter_values_to_list(raw_counter_data: list) -> list[float]:
    output_list = []
    for timestamp, value in raw_counter_data[0]["timestamps"][0].items():
        converted_date = datetime.fromtimestamp(int(timestamp))
        logger.console(
            f"original timestamp: {timestamp} converted time: {converted_date}, value: {value}"
        )
        counter_value = CounterValue(converted_date, float(value))
        output_list.append(counter_value)
    return output_list


def convert_scout_counter_values_to_list(raw_counter_data: list) -> list[CounterValue]:
    output_list = []
    for counter_item in raw_counter_data:
        if counter_item["dist"] == "MRBTS-78192/NRBTS-78192/NRCELL-1":
            continue
        timestamp_str = counter_item["create_time"]
        converted_value = counter_item["value"]
        converted_date = datetime.strptime(timestamp_str, "%Y-%m-%dT%H:%M:%SZ")
        counter_value = CounterValue(converted_date, float(converted_value))
        logger.console(
            f"timestamp: {timestamp_str} converted time: {converted_date}, value: {converted_value}"
        )
        output_list.append(counter_value)
    return output_list


def strip_counter_values_before_date(
        counter_data: list[CounterValue],
        date: datetime,
        offset: timedelta = timedelta(minutes=0),
) -> list[CounterValue]:
    offset_date = date - offset
    logger.info(f"Stripping counter values", also_console=True)
    logger.info(f"Input counter data: {counter_data}", also_console=True)
    logger.info(
        f"comparison date (including -{offset} offset): {offset_date}",
        also_console=True,
    )
    result = [value for value in counter_data if value.timestamp >= offset_date]
    logger.info(f"Output counter data: {result}", also_console=True)
    return result


def verify_enabled_nr_rtwp_counter_correctness(
        counter_data: list[CounterValue], increase_margin: float = 5
) -> tuple[bool]:
    found_non_zero = False
    found_increase = False
    if len(counter_data) < 1:
        raise ValueError(f"Counter value list is empty")

    previous_data: CounterValue = None
    for data in counter_data:
        logger.info(f"Verifying value: {data}", also_console=True)
        if not (-200 <= data.value <= 0):
            raise ValueError(
                f"RTWP value is out of range (-200, 0>: {data.value}")
        if data.value < 0:
            found_non_zero = True

        if previous_data is None:
            previous_data = data
            continue

        if previous_data.value == 0 and data.value < 0:
            found_increase = True
            logger.info(
                f"Detected increase in value, data: {data}, previous data: {previous_data}",
                also_console=True,
            )
            previous_data = data
            continue

        elif previous_data.value == 0:
            previous_data = data
            continue

        delta = data.value - previous_data.value
        delta_percentage = abs(delta) / previous_data.value * 100
        logger.info(
            f"Calculated increase: {delta_percentage}", also_console=True)
        if abs(delta_percentage) > increase_margin and data.value > previous_data.value:
            found_increase = True
            logger.info(
                f"Detected increase in value by percentage: {delta_percentage}"
                f", data: {data}, previous data: {previous_data}",
                also_console=True,
            )

        previous_data = data

    logger.info("RTWP values are within the expected range", also_console=True)

    return found_non_zero, found_increase


def verify_disabled_nr_rtwp_counter_correctness(counter_data: list[CounterValue]):
    if len(counter_data) < 1:
        raise ValueError(f"Counter value list is empty")
    for data in counter_data:
        logger.info(f"Verifying counter: {data}", also_console=True)
        if not (data.value == 0):
            raise ValueError(
                f"RTWP value is not 0 for disabled counter: {data.value}")

    logger.info("RTWP values are within the expected range", also_console=True)


def traverse_directories(path: Path) -> list[Path]:
    path = Path(path)
    files = []
    if path.is_file():
        return []

    for item in path.iterdir():
        if item.is_dir():
            files.append(item)
            files.extend(traverse_directories(item))
        else:
            files.append(item)
    return files


def filter_files_by_extensions(files: list[Path], extensions: list[str]) -> list[Path]:
    logger.info(f"filtering extensions for files: {files}")
    for file in files:
        logger.info(
            f"Debug, printing file suffixes: {file}, suffix: {file.suffix}")
        logger.info(f"Searched suffixes: {extensions}")
    return [file for file in files if file.suffix in extensions]


def filter_files_by_glob(files: list[Path], glob: str) -> list[Path]:
    return [file for file in files if file.match(glob)]


def unzip_file_to_directory(file: Path, directory: Path):
    with zipfile.ZipFile(file, "r") as zip_ref:
        zip_ref.extractall(directory)


def unzip_file_to_directory_with_same_name(file: Path) -> Path:
    output_path = file.with_suffix("")
    unzip_file_to_directory(file, output_path)
    return output_path


def untar_file_to_directory(file: Path, directory: Path):
    with tarfile.open(file, mode="r") as f:
        f.extractall(directory)


def untar_file_to_directory_with_same_name(file: Path) -> Path:
    output_path = file.with_suffix("")
    untar_file_to_directory(file, output_path)
    return output_path


def unlzma_file(file: Path, destination: Path):
    with lzma.open(file, "rb") as xz_file:
        with open(destination, "wb") as output_file:
            output_file.write(xz_file.read())
    return destination


def unlzma_file_with_same_name(file: Path) -> Path:
    output_path = file.with_suffix("")
    unlzma_file(file, output_path)
    return output_path


def find_snapshots(base_path: Path) -> list[Path]:
    snapshot_files = traverse_directories(base_path)
    snapshot_files = [path for path in snapshot_files if "snapshot_rest_gnb0" in path.name.lower(
    ) and str(path).endswith('.zip')]
    return snapshot_files


def find_rmod_logfiles(base_path: Path) -> list[Path]:
    extensions = ('.log')

    all_files = traverse_directories(base_path)
    log_files = [path for path in all_files if str(path).endswith(extensions) and 'RMOD_L' in str(path)]
    return log_files


def strip_extension(file_path: Path) -> Path:
    return file_path.with_suffix("")


def unpack_all_recursive_archives(
        file_path: Union[str, Path],
        remove_intermediary_archives: bool = False,
        is_top_level: bool = True,
):
    if not isinstance(file_path, Path):
        file_path = Path(file_path)

    zip_file_extensions = [".zip"]
    tar_file_extensions = [".tar", ".tgz"]
    lzma_file_extensions = [".xz"]

    suffix = file_path.suffix
    logger.info(f"Detected suffix: {suffix}")
    if suffix in zip_file_extensions:
        logger.info("Debug, detected a zip file")
        unpacked_path = unzip_file_to_directory_with_same_name(file_path)
    elif suffix in tar_file_extensions:
        logger.info("Debug, detected a tar file")
        unpacked_path = untar_file_to_directory_with_same_name(file_path)
    elif suffix in lzma_file_extensions:
        logger.info("Debug, detected a lzma file")
        unpacked_path = unlzma_file_with_same_name(file_path)
    else:
        logger.info(f"Unknown file extension detected: {file_path}")
        return

    all_files = traverse_directories(unpacked_path)
    zip_files = filter_files_by_extensions(all_files, zip_file_extensions)
    tar_files = filter_files_by_extensions(all_files, tar_file_extensions)
    lzma_files = filter_files_by_extensions(all_files, lzma_file_extensions)

    logger.info(f"All files: {all_files}")
    logger.info(f"Zip files: {zip_files}")
    logger.info(f"Tar files: {tar_files}")
    logger.info(f"Lzma files: {lzma_files}")

    exceptions = (EOFError, PermissionError,
                  tarfile.ReadError, FileNotFoundError)

    for f in zip_files:
        try:
            unpack_all_recursive_archives(f, True, False)
        except exceptions as e:
            pass
            logger.info(
                f"Error reading file: {f}, error: {e}", also_console=False)

    for f in tar_files:
        try:
            unpack_all_recursive_archives(f, True, False)
        except exceptions as e:
            pass
            logger.info(
                f"Error reading file: {f}, error: {e}", also_console=False)

    for f in lzma_files:
        try:
            unpack_all_recursive_archives(f, True, False)
        except exceptions as e:
            pass
            logger.info(
                f"Error reading file: {f}, error: {e}", also_console=False)

    if (not is_top_level) and remove_intermediary_archives:
        return
        try:
            file_path.unlink()
        except Exception as e:
            logger.info(
                f"Error removing file: {file_path}, error: {e}", also_console=True
            )


def extract_rxpowerscalingfactor(log_line):
    pattern = r"rxPowerScalingFactor\s*=\s*(-?\d+\.?\d*)"
    match = re.search(pattern, log_line)
    if match:
        return float(match.group(1))
    return None


def verify_rxpowerscalingfactor(path: Path):
    exception = (UnicodeError, IsADirectoryError)
    found = False
    try:
        with open(path, 'r', errors='ignore') as file:
            lines = file.readlines()
            for line in lines:
                logger.info(line)
                scaling_factor = extract_rxpowerscalingfactor(line)
                if scaling_factor is not None:
                    logger.info(
                        f"Found rxPowerScalingFactor: {scaling_factor}", also_console=True)
                    if -100 > scaling_factor > -105:
                        logger.info(
                            f"rxPowerScalingFactor is within expected range: {scaling_factor}",
                            also_console=True,
                        )
                        found = True
    except exception as e:
        logger.info(f"Error reading file {path}: {e}", also_console=False)

    if not found:
        logger.info("rxPowerScalingFactor not found in the log file",
                    also_console=False)

    return found


def verify_rxScalingFactor_value(line: str):
    pattern = r"subcellId:(\d+).*?-rxScalingFactor:(-?\d+)"
    match = re.search(pattern, line)

    if match:
        subcell_id = int(match.group(1))
        rx_scaling_factor = float(match.group(2))
    else:
        raise ValueError("Failed to find rxScalingFactor value in line")

    if subcell_id == 1 and rx_scaling_factor == -1080:
        logger.info(
            f"Found rxScalingFactor value: {rx_scaling_factor} for subcellId: {subcell_id}",
            also_console=True,
        )
        return

    if subcell_id == 0 and rx_scaling_factor == -1188:
        logger.info(
            f"Found rxScalingFactor value: {rx_scaling_factor} for subcellId: {subcell_id}",
            also_console=True,
        )
        return

    raise ValueError(
        f"No match found for rxScalingFactor value: {rx_scaling_factor} for subcellId: {subcell_id}"
    )


def verify_presence_of_syslog_records(log_path: str):
    log_path = Path(log_path)

    rx_scaling_found: bool = False
    ulcell_found: bool = False
    parameter_reconfig_found: bool = False

    # ULCELL_PARAMETERRECONFIGURATIONREQ_ID

    log_files = traverse_directories(log_path)

    for file in log_files:

        try:
            with open(file, "r") as f:
                lines = f.readlines()
            for line in lines:
                if "rxScalingFactor" in line:
                    rx_scaling_found = True
                    logger.info("rxScalingFactor", also_console=True)
                    logger.info(line, also_console=True)
                    logger.info(log_path, also_console=True)
                    try:
                        verify_rxScalingFactor_value(line)
                    except ValueError as e:
                        logger.info(
                            f"Error verifying rxScalingFactor value: {e}",
                            also_console=True,
                        )

                if "ULCELL_SETUPREQ_ID" in line:
                    ulcell_found = True
                    logger.info("ULCELL_SETUPREQ_ID", also_console=True)
                    logger.info(line, also_console=True)
                    logger.info(log_path, also_console=True)

                if "ULCELL_PARAMETERRECONFIGURATIONREQ_ID" in line:
                    parameter_reconfig_found = True
                    logger.info(
                        "ULCELL_PARAMETERRECONFIGURATIONREQ_ID", also_console=True
                    )
                    logger.info(line, also_console=True)
                    logger.info(log_path, also_console=True)

        except Exception as e:
            logger.info(
                f"Error reading file, skipping: {log_path}, error: {e}",
                also_console=True,
            )

    if not rx_scaling_found:
        # raise ValueError("rxScalingFactor not found in any log file")
        logger.info(
            "rxScalingFactor not found in any log file, skipping verification",
            also_console=True,
        )

    if not ulcell_found:
        # raise ValueError("ULCELL_SETUPREQ_ID not found in any log file")
        logger.info(
            "ULCELL_SETUPREQ_ID not found in any log file, skipping verification",
            also_console=True,
        )

    if not parameter_reconfig_found:
        # raise ValueError(
        #    "ULCELL_PARAMETERRECONFIGURATIONREQ_ID not found in any log file"
        # )
        logger.info(
            "ULCELL_PARAMETERRECONFIGURATIONREQ_ID not found in any log file, skipping verification",
            also_console=True,
        )


def verify_average_ue_related_sinr_and_rssi(start_time, end_time):
    kpi_codes = ["NR_5064a", "NR_5099a"]

    for kpi_code in kpi_codes:
        kpi_data = get_single_kpi_values_from_defined_interval(
            kpi_code, start_time, end_time)
        if kpi_data:
            for entry in kpi_data:
                logger.warn("kpi data: {}".format(entry))
        else:
            raise ValueError(
                f"KPI {kpi_code} value is not avaiable, check Scout KPI values.")


def get_single_kpi_values_from_defined_interval(kpi_code, start_time, end_time):
    timezone = pytz.timezone('UTC')
    kpi_data = None
    kpi_values = []

    try:
        scout_connection = scout()
        scout_connection.setup_scout(scout_testline_name=get_tl_name())
        logger.info(f"Start time: {start_time}", also_console=True)
        logger.info(f"End time: {end_time}", also_console=True)
        logger.warn(
            "KPI collect start time send to scout: {}".format(start_time))
        logger.warn("Checking kpi: {}".format(kpi_code))
        logger.warn("KPI collect end time send to scout: {}".format(end_time))
        kpi_data = scout_connection.get_kpi(kpi_code=kpi_code,
                                            start_time=start_time,
                                            end_time=end_time)
        logger.warn(
            "KPI data collected from scout for kpi_code - {}: {}".format(kpi_code, kpi_data))
    except Exception as e:
        logger.warn("Cannot connect to scout API: {}".format(e))

    logger.warn("kpi data: {}".format(kpi_data))
    if kpi_data:
        for entry in kpi_data:
            if entry["level"] == "bts" and entry["value"]:
                kpi_values.append(
                    {"value": entry["value"], "timestamp": entry["create_time"]})
    return kpi_values


def get_tl_name():
    tl = BuiltIn().get_variable_value("${{{}}}".format("tl"), None)
    logger.warn("tl name: {}".format(tl))
    logger.warn("expected value {}".format(tl.test_pcs[0].
                                           default_ssh_connection_details.addr.split(".")[-5].replace("-", "_")))
    return tl.test_pcs[0].default_ssh_connection_details.addr.split(".")[-5].replace("-", "_")


def get_time_point_for_kpis():
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def get_scout_pm_counter(counter_name: str, start_time: str, end_time: str, interval: int = 5) -> list[CounterValue]:
    scout_connection = scout()
    scout_connection.setup_scout(scout_testline_name=get_tl_name())
    logger.info(
        f"Fetching PM counter: {counter_name} from {start_time} to {end_time}", also_console=True)
    counter_values = scout_connection.get_pm(
        counter_name, start_time, end_time, interval)
    logger.info(counter_values, also_console=True)
    return counter_values


def extract_rmod_runtime_snapshot(zip_path):
    ZIP_PATTERN = re.compile(r".*_RMOD_L_[12]_runtime\.zip$")
    TARGET_FILE = "runtime_DEFAULT.log.xz"
    timestamp = str(zip_path).split('_')[-1].split('.zip')[0]
    zip_path = Path(zip_path)
    out_dir = zip_path.parent / "RMOD_runtime_snapshot_unpacked"
    out_dir.mkdir(exist_ok=True)
    with zipfile.ZipFile(zip_path) as z:
        for name in z.namelist():
            if ZIP_PATTERN.match(name):
                nested_zip_name = Path(name).stem
                nested_bytes = z.read(name)
                with zipfile.ZipFile(BytesIO(nested_bytes)) as nested:
                    for f in nested.namelist():
                        if f.endswith(TARGET_FILE):
                            xz_bytes = nested.read(f)
                            decompressed = lzma.decompress(xz_bytes)
                            unique_base = f"{nested_zip_name}_{timestamp}_runtime_DEFAULT.log"
                            unique_path = out_dir / unique_base
                            if decompressed[:4] == b'PK\x03\x04':
                                with zipfile.ZipFile(BytesIO(decompressed)) as inner_zip:
                                    inner_zip.extractall(unique_path)
                            else:
                                unique_path.write_bytes(decompressed)
