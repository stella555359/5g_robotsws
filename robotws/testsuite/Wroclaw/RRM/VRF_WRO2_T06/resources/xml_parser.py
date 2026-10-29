import os
import subprocess
from robot.api import logger
import xml.etree.ElementTree as ET
import logging
import operator
from collections.abc import Iterable

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)


def convert_pcap_to_pdml(pcap_file, timeout=300):
    """
    Converts a PCAP file to PDML XML format using tshark,
    always including a predefined set of extra arguments.

    Args:
        pcap_file (str): The path to the input PCAP file.
        timeout (int, optional): Maximum time in seconds to wait for tshark to complete. Defaults to 300.

    Returns:
        str: The path to the generated PDML XML file.

    Raises:
        FileNotFoundError: If tshark is not found.
        subprocess.TimeoutExpired: If tshark exceeds the specified timeout.
        RuntimeError: If tshark fails or produces an empty PDML file.
    """
    base, _ = os.path.splitext(pcap_file)
    logger.info(f"Converting PCAP: {pcap_file}")
    pdml_file = base + ".xml"

    # --- Hardcoded tshark_extra_args ---
    # Example: Always dissect TCP port 8080 as HTTP and TCP port 1234 as a custom protocol 'my_proto'
    # Adjust these arguments based on your specific, consistent needs.
    hardcoded_tshark_extra_args = [
        '-d', 'tcp.port==8080,http',
        '-d', 'tcp.port==49140,ntrstr'
        # Add other common arguments here, e.g., for SSL keylog if always applicable:
        # '-o', 'ssl.keylog_file:/path/to/default/sslkeylog.txt'
    ]
    # --- End of Hardcoded tshark_extra_args ---

    tshark_command = ["tshark", "-T", "pdml", "-r", pcap_file]
    tshark_command.extend(hardcoded_tshark_extra_args)  # Always add the hardcoded arguments

    logger.info(f"Executing tshark command: {' '.join(tshark_command)}")

    try:
        with open(pdml_file, "w", encoding="utf-8") as f:
            result = subprocess.run(
                tshark_command,
                stdout=f,
                stderr=subprocess.PIPE,
                text=True,
                timeout=timeout
            )

        if result.returncode != 0:
            raise RuntimeError(f"tshark failed with exit code {result.returncode}:\n{result.stderr}")

        if os.path.getsize(pdml_file) == 0:
            logger.warning(f"PDML file '{pdml_file}' is empty. "
                           f"This might indicate an empty PCAP or un-dissectable packets.")
            raise RuntimeError("PDML file is empty although tshark succeeded")

        logger.info(f"Successfully converted '{pcap_file}' to '{pdml_file}'")
        return pdml_file

    except FileNotFoundError:
        raise FileNotFoundError("tshark command not found. "
                                "Please ensure Wireshark/tshark is installed and in your system's PATH.")
    except subprocess.TimeoutExpired:
        raise subprocess.TimeoutExpired(f"tshark timed out after {timeout} seconds "
                                        f"for {pcap_file}", timeout=timeout)
    except Exception as e:
        logger.error(f"An unexpected error occurred during conversion of {pcap_file}: {e}")
        raise


def validate_field_and_children_in_xml_file(
        xml_file,
        target_field_name,
        child_field_name=None,
        attribute_to_check="show",
        condition=">0",
        error_message_template="Validation failed: '{child_field_name}' value is '{value}' "
                               "(not meeting condition) in element: {element_info}",
        not_found_message_template="Validation failed: '{child_field_name}' not found "
                                   "within '{target_field_name}' element: {element_info}"
):
    """
    Robot Framework keyword:
    - child_field_name can be string, list, or None
    - supports decimal and colon-separated hex values
    - logs all failures to log.html
    - fails once at the end if needed
    """

    # --- build condition ---
    condition = condition.replace(" ", "")
    ops = {
        ">=": operator.ge,
        "<=": operator.le,
        ">": operator.gt,
        "<": operator.lt,
        "=": operator.eq,
        "==": operator.eq,
        "!=": operator.ne,
    }

    expected_condition_func = None  # Initialize to be assigned later

    for op_str, op_func in ops.items():
        if condition.startswith(op_str):
            try:
                threshold = int(condition[len(op_str):])
            except ValueError:
                raise AssertionError(f"Invalid condition: {condition}")

            # Replace lambda with a nested def function
            def _check_value_against_condition(value_to_check):
                """
                Checks if a given value meets the predefined condition
                using the captured operator function and threshold.
                """
                return op_func(value_to_check, threshold)

            expected_condition_func = _check_value_against_condition
            break
    else:
        raise AssertionError(f"Unsupported condition: {condition}")

    # --- normalize child_field_name ---
    if child_field_name is None:
        children_to_check = None
    elif isinstance(child_field_name, str):
        children_to_check = {child_field_name}
    elif isinstance(child_field_name, Iterable):
        children_to_check = set(child_field_name)
    else:
        raise AssertionError("child_field_name must be string, list, or None")

    tree = ET.parse(xml_file)
    root = tree.getroot()

    failures = []
    elements_found = False

    def convert_value(raw_value: str) -> int:
        try:
            if ":" in raw_value:
                return int(raw_value.replace(":", ""), 16)
            return int(raw_value)
        except ValueError:
            raise AssertionError(f"Invalid numeric value: {raw_value}")

    for target in root.iter("field"):
        if target.get("name") != target_field_name:
            continue

        elements_found = True
        element_info = ET.tostring(target, encoding="unicode").strip()

        if children_to_check:
            found_children = set()

            for child in target.iter("field"):
                name = child.get("name")
                if name not in children_to_check:
                    continue

                found_children.add(name)
                raw_value = child.get(attribute_to_check)

                if raw_value is None:
                    msg = f"Attribute '{attribute_to_check}' not found for '{name}' in element: {element_info}"
                    logger.error(msg)
                    failures.append(msg)
                    continue

                try:
                    numeric_value = convert_value(raw_value)
                    if not expected_condition_func(numeric_value):  # Use the def function here
                        msg = error_message_template.format(
                            child_field_name=name,
                            value=raw_value,
                            element_info=element_info
                        )
                        logger.warning(msg)
                        failures.append(msg)
                except Exception as e:
                    msg = f"Could not apply condition '{condition}' to value '{raw_value}' for '{name}': {e}"
                    logger.error(msg)
                    failures.append(msg)

            for missing in children_to_check - found_children:
                msg = not_found_message_template.format(
                    child_field_name=missing,
                    target_field_name=target_field_name,
                    element_info=element_info
                )
                logger.warning(msg)
                failures.append(msg)

        else:
            raw_value = target.get(attribute_to_check)

            if raw_value is None:
                msg = f"Attribute '{attribute_to_check}' not found for '{target_field_name}' in element: {element_info}"
                logger.error(msg)
                failures.append(msg)
                continue

            try:
                numeric_value = convert_value(raw_value)
                if not expected_condition_func(numeric_value):  # Use the def function here
                    msg = error_message_template.format(
                        child_field_name=target_field_name,
                        value=raw_value,
                        element_info=element_info
                    )
                    logger.warning(msg)
                    failures.append(msg)
            except Exception as e:
                msg = f"Could not apply condition '{condition}' to value '{raw_value}' for '{target_field_name}': {e}"
                logger.error(msg)
                failures.append(msg)

    # ? NEW: fail if target field was never found
    if not elements_found:
        raise AssertionError(
            f"Validation failed: target field '{target_field_name}' was not found in XML file '{xml_file}'."
        )

    if failures:
        raise AssertionError(
            f"{len(failures)} validation error(s) found. "
            f"See Robot Framework log.html for details."
        )

    logger.info("XML validation passed with no errors.")


def validate_lack_of_field_in_xml_file(
    xml_file,
    target_field_name,
    not_found_message_template="Field '{field}' should NOT be present in XML, but it was found."
):
    """
    Robot Framework keyword:
    Validates that a given field is NOT present in the XML file.

    Arguments:
    - xml_file: Path to XML file
    - target_field_name: XML tag to check
    - not_found_message_template: Optional custom error message

    Example in Robot:
    Validate Lack Of Field In Xml File    example.xml    password
    """

    try:
        tree = ET.parse(xml_file)
        root = tree.getroot()
    except ET.ParseError as e:
        raise AssertionError(f"Invalid XML file: {e}")

    found_elements = root.findall(f".//{target_field_name}")

    if found_elements:
        message = not_found_message_template.format(field=target_field_name)
        raise AssertionError(message)

    # Robot treats no exception as PASS
    return f"Field '{target_field_name}' correctly not found in XML."
