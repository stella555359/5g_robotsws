"""Includes helper functions for test_all_json_files.py"""
import subprocess
import time
import os
import importlib.util

import psutil


def subdivide_list(input_list: list, division_step: int) -> list:
    """takes a list and a division step to return a list containing sub_lists of the original

    Args:
        input_list (list): _description_
        division_step (int): _description_

    Returns:
        list: _description_
    """
    subdivided_list = []
    len_input = len(input_list)
    for i in range(len_input//division_step):
        sublist = [list_item for list_item in input_list[i *
                                                         division_step: i*division_step+division_step]]
        subdivided_list.append(sublist)
    subdivided_list.append(
        [list_item for list_item in input_list[len_input - len_input % division_step:]])
    return subdivided_list


def create_result_folders_if_not_present(generated_output_files_dir) -> None:
    """create folders necessary for the result files, starting at generated_output_files_dir"""
    os.makedirs(f'{generated_output_files_dir}/last_run', exist_ok=True)
    os.makedirs(f'{generated_output_files_dir}/golden_files', exist_ok=True)


def get_cpu_info():
    """
    Retrieve information about the CPU, including the number of physical and logical cores.

    This function uses the `psutil` library to obtain information about the CPU.

    Returns:
        tuple: A tuple containing two integers:
            - The number of physical CPU cores (excluding hyper-threading).
            - The total number of logical CPU cores, which includes hyper-threading.
    """
    # Get CPU count and usage
    cpu_count_physical = psutil.cpu_count(logical=False)
    cpu_count_logical = psutil.cpu_count(logical=True)
    return cpu_count_physical, cpu_count_logical


def compile_python_files_in_folder(folder_path: str) -> None:
    """compiles all python files in the folder

    Args:
        folder_path (str): path to folder to compile
    """
    print('compiling all python files for faster execution if not already done...')
    subprocess.run(
        f'python -m compileall -q {folder_path}', shell=True, check=True)
    print('done compiling all python files.')


def timing_decorator(func):
    """used to time execution of python functions. should be used as decorator.

    Args:
        func (function): the function that should be timed.
    """
    def wrapper(*args, **kwargs):
        start_time = time.time()
        result = func(*args, **kwargs)
        end_time = time.time()
        execution_time = end_time - start_time
        print(f"{func.__name__} Execution Time: {execution_time} seconds")
        return result
    return wrapper


def dynamic_import(file_path):
    if not file_path.endswith(".py"):
        raise ValueError(f"The file at {file_path} is not a Python file.")
    module_name = file_path.split("/")[-1].replace(".py", "")
    spec = importlib.util.spec_from_file_location(module_name, file_path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module
