"""
:copyright: Nokia Networks
:author: Grzegorz Kaczor
:contact: grzegorz.kaczor@nokia.com
"""


import re
import logging
import traceback
from robot.libraries.BuiltIn import BuiltIn
DELIMITER_PATTERN = re.compile(r": ")


def validate_blackbox(blackbox_path: str, *args, **kwargs) -> (dict, dict):
    build_in = BuiltIn()
    statuses = {}
    outputs = {}
    running_robot = False
    blackbox = parse_blackbox_file(filepath=blackbox_path)
    for function in args:
        status = False
        output = None
        function_name = ""
        try:
            function_name = function.__name__ if callable(function) else str(function)
            kwargs["outputs"] = outputs
            if isinstance(function, str):
                logging.debug(f"Attempting to run {function} as a keyword with parameters: {kwargs}")
                running_robot = True
                status, output = build_in.run_keyword(function, blackbox, kwargs)
            elif callable(function):
                logging.debug(f"Running {function_name} as a python function with parameters: {kwargs}")
                status, output = function(blackbox, kwargs)
            else:
                logging.error(f"Given function '{function}' is neither keyword name nor a function")
        except Exception as e:
            logging.error(f"Given function '{function}' returned error when validating blackbox {e}")
            logging.error(traceback.format_exc())

        statuses[function_name] = status
        outputs[function_name] = output
    if running_robot:
        try:
            build_in.set_test_variable("${validate_blackbox_statuses}", statuses)
            build_in.set_test_variable("${validate_blackbox_outputs}", outputs)
        except Exception as e:
            logging.debug("Failed setting ${validate_blackbox_statuses} and ${validate_blackbox_outputs} as variables")
    assert False not in statuses.values(), f"Validation failed for at least one given validation method: {statuses}"
    return statuses, outputs


def parse_blackbox_file(filepath: str) -> list:
    content = ""
    with open(filepath, "r") as blackbox_file:
        content = blackbox_file.read()
    content = content.split("---")
    parsed_result = []
    for element in content:
        section = parse_section(element)
        if section:
            parsed_result.append(section)
    return parsed_result


def parse_section(section: str) -> dict:
    parsed_section = {}
    split_section = section.split("\n")
    key = ""
    temp_section = []
    for element in split_section:
        if element:
            element = element.strip()
            line = re.split(DELIMITER_PATTERN, element.strip())
            line_length = len(line)
            if key and line_length == 1 and element.endswith(":"):
                if parsed_section.get(key):
                    raise AttributeError(f"Duplicate sections in: {section}: {key}")
                parsed_section[key] = temp_section
                key = line[0][:-1] if line[0].endswith(":") else line[0]
                temp_section = []
            elif key and line_length >= 1:
                temp_section.append(element)
            elif line_length >= 2:
                if parsed_section.get(line[0]):
                    raise AttributeError(f"Duplicate sections in: {section}: {line[0]}")
                parsed_section[line[0]] = line[1] if line_length == 2 else ": ".join(line[1:])
            elif line_length == 1:
                key = line[0][:-1] if line[0].endswith(":") else line[0]
    if key:
        if parsed_section.get(key):
            raise AttributeError(f"Duplicate sections in: {section}: {key}")
        parsed_section[key] = temp_section
    return parsed_section
