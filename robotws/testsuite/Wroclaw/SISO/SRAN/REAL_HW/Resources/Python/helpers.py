"""
:copyright: Nokia
:author: piotr.korczynski@nokia.com
:maintainer: piotr.korczynski@nokia.com

File contains helper functions
"""

import attr
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from robot.api.deco import keyword
import json
import os
import yaml
import subprocess
import random
import io
import csv

from pathlib import Path
import tempfile

import difflib


@keyword(name='Load Json File As Dictionary')
def load_json_file_as_dictionary(file_path):
    """
    Load Json File As Dictionary is function which returns json file as a dictionary.
    Args:
        file_path (string): Path to the Json File

    Return:
        Dictionary
    """
    with open(file_path) as ute_variables:
        return json.load(ute_variables)


@keyword(name='Find Init Object Using Attribute Value')
def find_init_object_using_attribute_value(obj, value, depth=0, max_depth=12):
    """
    This function is used to find an object using attribute value. It is used to gather information from
    __init__.py file.
    Args:
        obj (Testline class): Testline class represented by tl variable.
        value (string): Any kind of attribute value available within Testline class.
        depth (int): Current recursion depth.
        max_depth (int): Maximum allowed recursion depth.

    Returns:
        obj (class) - Python type object of class containing attribute value.
    """
    if depth > max_depth:
        return None
    try:
        if isinstance(obj, list):
            for item in obj:
                found = find_init_object_using_attribute_value(item, value, depth + 1, max_depth)
                if found is not None:
                    return found
        elif hasattr(obj, "__dict__"):
            for attr_name, attr_value in obj.__dict__.items():
                if attr_value == value:
                    return obj
                else:
                    found = find_init_object_using_attribute_value(attr_value, value, depth + 1, max_depth)
                    if found is not None:
                        return found
        elif isinstance(obj, str) and obj == value:
            return obj
        return None
    except RecursionError:
        return None


@keyword(name='Find Objects With Attribute Name')
def find_objects_with_attribute_name(obj, attr_name, max_depth=8):
    """
    This function is used to find all unique objects that have a given attribute name.
    It traverses a tree of objects, which can be a pseudo data class created by the attrs library.
    Args:
        obj (object): The root object or any object within the tree structure.
        attr_name (str): The name of the attribute to search for.
        max_depth (int): The maximum depth of recursion allowed.

    Returns:
        list - A list of unique objects that contain the specified attribute name.
    """
    found_objects = set()
    current_depth = 0

    def recursive_search(current_obj, current_depth):
        if current_depth > max_depth:
            return
        try:
            if isinstance(current_obj, list):
                for item in current_obj:
                    recursive_search(item, current_depth + 1)
            elif hasattr(current_obj, "__dict__"):
                if attr_name in current_obj.__dict__:
                    found_objects.add(current_obj)
                for attr_value in current_obj.__dict__.values():
                    recursive_search(attr_value, current_depth + 1)
        except RecursionError:
            pass

    recursive_search(obj, current_depth)
    return list(found_objects)


@keyword(name='Find Objects Of Class')
def find_objects_of_class(obj, class_name, max_depth=8):
    """
    This function is used to find all unique objects that are instances of a given class name.
    It traverses a tree of objects, which can be a pseudo data class created by the attrs library.
    Args:
        obj (object): The root object or any object within the tree structure.
        class_name (str): The name of the class to search for instances of.
        max_depth (int): The maximum depth of recursion allowed.

    Returns:
        list - A list of unique objects that are instances of the specified class.
    """
    found_objects = set()
    current_depth = 0

    def recursive_search(current_obj, current_depth):
        if current_depth > max_depth:
            return
        try:
            if current_obj.__class__.__name__ == class_name:
                found_objects.add(current_obj)

            if isinstance(current_obj, list):
                for item in current_obj:
                    recursive_search(item, current_depth + 1)
            elif hasattr(current_obj, "__dict__"):
                for attr_value in current_obj.__dict__.values():
                    recursive_search(attr_value, current_depth + 1)
        except RecursionError:
            pass

    recursive_search(obj, current_depth)
    return list(found_objects)


def _find_config_yml(directory):
    for root, _, files in os.walk(directory):
        logger.info(files)
        if 'config.yaml' in files:
            config_path = os.path.join(root, 'config.yaml')
            logger.info(config_path)
            return config_path, root
            with open(config_path, 'r') as yml_file:
                return yaml.safe_load(yml_file), root
    return None, None


def _sparse_checkout(repo_dir, temp_dir, repo_url):
    subprocess.run(['git', 'clone', '--depth', '1', '--no-checkout', repo_url, temp_dir])
    os.chdir(temp_dir)
    subprocess.run(['git', 'sparse-checkout', 'set', repo_dir])
    subprocess.run(['git', 'checkout'])

    return temp_dir


@keyword(name='Get Topology Config Directory Path')
def get_topology_config_directory_path(local_dir, repo_dir):
    """
    This function is used to provide path to topology_configs testline folder.
    In case there is no topology config folder prepared by agent it will use git clone sparse
    to pull data
    Args:
        local_dir (str): path to folder with local topology_configs copy
        repo_dir (str): testline folder name , CLOUD_<TESTLINE_NAME>

    Returns:
        config - config.yaml object
        config_dir - directory with current topology configs structure
    """
    topology_config_repository = 'git@gitlabe2.ext.net.nokia.com:uca/ran/topology-configs.git'
    config, config_dir = _find_config_yml(local_dir)
    if config is None:
        temp_dir = '/home/ute/tmp_topology_configs'
        _sparse_checkout(repo_dir, temp_dir, topology_config_repository)
        repo_path = os.path.join(temp_dir, repo_dir)
        if os.path.exists(repo_path):
            config, config_dir = _find_config_yml(repo_path)
        else:
            config, config_dir = _find_config_yml(temp_dir)
    return config, config_dir


@keyword(name='Get New Value From Range')
def get_new_value_from_range(min_value, max_value, step, current_value):
    """
    Generates a new value from a range, ensuring it is not the current value.

    This function creates a sequence of numbers from min_value to max_value with a specified step,
    removes the current_value from that sequence, and then returns a random value from the remaining options.

    Args:
        min_value (float): The minimum value of the range.
        max_value (float): The maximum value of the range.
        step (float): The increment between values in the range.
        current_value (float): The value to be excluded from the selection.

    Returns:
        float: A new value from the range that is not the current_value.

    Raises:
        ValueError: If no other values are available in the range besides the current_value.
    """
    min_value = float(min_value)
    max_value = float(max_value)
    step = float(step)
    current_value = float(current_value)

    # Generate all possible values in the range
    possible_values = []
    val = min_value
    while val <= max_value:
        possible_values.append(round(val, 4))  # Round to handle float inaccuracies
        val += step

    # Remove the current value if it exists in the list
    if current_value in possible_values:
        possible_values.remove(current_value)

    if not possible_values:
        raise ValueError("No other values available in the specified range to select from.")

    # Return a random choice from the remaining values
    # return random.choice(possible_values)
    return round(random.choice(possible_values), 2)


@keyword(name='Analyze Vswr Data')
def analyze_vswr_data(json_file_path, vswr_max_value=None):
    """
    Analyzes VSWR data from a JSON file to identify value stability over time.

    This function reads a JSON file, extracts data from the 'VSWR' key,
    and processes it as CSV data. It assumes the first row is a header
    and subsequent rows contain antenna information followed by a series
    of VSWR measurements.

    It categorizes each antenna based on whether its VSWR values change
    or remain constant, and also checks if any value exceeds a maximum threshold.

    Args:
        json_file_path (str): The path to the JSON file containing the VSWR data.
        vswr_max_value (float, optional): The maximum acceptable VSWR value. If any measurement
                                          exceeds this, the antenna is flagged. Defaults to None (no check).

    Returns:
        tuple[list, list]: A tuple containing two lists:
                           - The first list contains identifiers of antennas with at least one value
                             exceeding `vswr_max_value`.
                           - The second list contains identifiers of antennas where all values are
                             within the `vswr_max_value` limit.
    """
    with open(json_file_path) as f:
        data = json.load(f)

    vswr_data_string = data.get('VSWR')
    if not vswr_data_string:
        raise ValueError("Key 'VSWR' not found in the provided JSON file.")

    if vswr_max_value is not None:
        vswr_max_value = float(vswr_max_value)

    antennas_beyond_max = []
    antennas_within_max = []

    for rmod in vswr_data_string:
        rmod_name = rmod.get('name')
        for ant_line in rmod.get('antennaLines', []):
            vswr_values = []
            measure_datas = ant_line.get('measureDatas', {})
            for band_data in measure_datas.values():
                if isinstance(band_data, dict):
                    for value in band_data.values():
                        vswr_values.append(float(value))

            if vswr_values:
                average_vswr = sum(vswr_values) / len(vswr_values)
                ant_line['average_vswr'] = round(average_vswr, 2)
            else:
                ant_line['average_vswr'] = None

            # Check if any value is greater than the maximum allowed value.
            if vswr_max_value is not None and any(v > vswr_max_value for v in vswr_values):
                antennas_beyond_max.append(ant_line)
            else:
                antennas_within_max.append(ant_line)

    return antennas_beyond_max, antennas_within_max


@keyword(name='Compare Snapshot Files')
def compare_snapshot_files(initial_file, final_file):
    """Compares the content of two snapshot files and returns a result and diff summary.

    Args:
        initial_file (str): Path to the initial snapshot file.
        final_file (str): Path to the final snapshot file.

    Returns:
        dict: {'result': 'NO_DIFF' or 'DIFF_FOUND', 'diff': <diff string>}
    """
    with open(initial_file, 'r', encoding='utf-8') as f:
        initial_lines = f.readlines()
    with open(final_file, 'r', encoding='utf-8') as f:
        final_lines = f.readlines()

    diff = list(
        difflib.unified_diff(
            initial_lines,
            final_lines,
            fromfile=initial_file,
            tofile=final_file,
            lineterm=''
        )
    )

    if not diff:
        return {'result': 'NO_DIFF', 'diff': ''}
    return {'result': 'DIFF_FOUND', 'diff': '\n'.join(diff)}
