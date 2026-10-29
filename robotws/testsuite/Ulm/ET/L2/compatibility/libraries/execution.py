"""Used for the execution of TEAL runs to generate output files."""
import subprocess
import threading
import time

from libraries.helpers import subdivide_list

RUN_FAILED = False


def run_command_in_virtualenv(command, venv_path, robotws_parent_dir) -> None:
    """runs a python command in the robotws directory to simulate normal TEAL use.

    Args:
        command (str): the command to run
        venv_path (str): path to the virtual environment
    """
    activate_cmd = f'. {venv_path}'
    process = subprocess.Popen(f'{activate_cmd} && cd {robotws_parent_dir}/robotws && {command}',
                               shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    _, std_err = process.communicate()
    process.wait()
    if process.returncode != 0:
        global RUN_FAILED
        RUN_FAILED = True
        with open('/home/ute/DEVELOPMENT/errors.txt', 'a', encoding='utf-8') as error_file:
            error_file.write((std_err.decode(encoding='utf-8')))
            error_file.write('\n')
            error_file.write('='*80)


def create_threads(config_files, test_script_path, robotws_parent_dir, venv_path):
    """Create all the threads to start the execution of the TEAL runs to generate new output files.

    Args:
        teal_json_files (list): list of paths to the TEAL json files
        test_script_path (str): Path to the script to run each instance
        robotws_parent_dir (str): parent dir of robotws
        venv_path (str): Path to virtual environment that will be used for execution

    Returns:
        list: list containing the Thread objects.
    """
    threads = []
    for config_file in config_files:
        python_command = f'python {test_script_path} {config_file} {robotws_parent_dir}'
        threads.append(threading.Thread(target=run_command_in_virtualenv,
                                        args=(python_command, venv_path, robotws_parent_dir)))
    return threads


def run_threads_in_chunks(available_cpu_threads: int, threads: list) -> None:
    """Runs all created threads in smaller chunks to stop if an error occurs.

    Args:
        available_cpu_threads (int): the available cpu threads that should be used per chunk
        threads (list): a list containing the Thread objects that should be executed
    """
    sublist_of_threads = subdivide_list(input_list=threads, division_step=available_cpu_threads)
    start_of_execution = time.perf_counter()
    for current_iteration, thread_sublist in enumerate(sublist_of_threads):
        start_current_chunk = time.perf_counter()
        for thread in thread_sublist:
            thread.start()
        for thread in thread_sublist:
            thread.join()
        if RUN_FAILED:
            print('at least one run in the last runs failed, stopping execution.\n'
                  'Please check /home/ute/DEVELOPMENT/errors.txt.')
            break
        done_threads = current_iteration * \
            available_cpu_threads + len(thread_sublist)
        time_since_start = time.perf_counter() - start_of_execution
        time_last_chunk = time.perf_counter() - start_current_chunk
        print(
            f'\rdone with {done_threads}\t time since execution start: {time_since_start:.3f}\t'
            f'time last chunk: {time_last_chunk:.3f}\ttotal threads: {len(threads)}', end='')
    print()
