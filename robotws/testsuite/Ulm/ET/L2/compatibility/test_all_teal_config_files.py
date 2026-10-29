"""Used to run all currently known TEAL json files and compare them to the last good state."""
import os
import shutil
import argparse

from git import Repo
from libraries.checks import compare_with_golden_files
from libraries.execution import create_threads, run_threads_in_chunks
from libraries.get_all_config_files import get_config_files
from libraries.helpers import (compile_python_files_in_folder,
                               create_result_folders_if_not_present,
                               get_cpu_info, timing_decorator)

TEST_SCRIPT_PATH = 'testsuite/Ulm/ET/L2/compatibility/template_functions_tester.py'
ROBOTWS_PARENT_DIR = '/home/ute/DEVELOPMENT'
ULM_ET_BASE_PATH = f'{ROBOTWS_PARENT_DIR}/robotws/testsuite/Ulm/ET'
VENV_PATH = f'{ROBOTWS_PARENT_DIR}/robotws/.venv/bin/activate'


@timing_decorator
def main():
    """see module Docstring."""
    parser = argparse.ArgumentParser(
        prog='TEAL tester',
        description='Tests TEAL with all known TEAL json Files')
    parser.add_argument('-cg', '--create-golden', action='store_true')
    args = parser.parse_args()
    if args.create_golden:
        repo = Repo(f'{ROBOTWS_PARENT_DIR}/robotws')
        assert not repo.bare
        print('stashing changes and checking out to master...')
        repo.git.stash('save')
        current_branch = repo.active_branch.name
        repo.git.checkout('master')
    cpu_cores, _ = get_cpu_info()
    try:
        os.remove('/home/ute/DEVELOPMENT/errors.txt')
    except FileNotFoundError:
        pass
    generated_output_files_dir = f'{ROBOTWS_PARENT_DIR}/generated_output_files'
    create_result_folders_if_not_present(generated_output_files_dir)
    config_files = get_config_files(ULM_ET_BASE_PATH)
    compile_python_files_in_folder(
        folder_path=f'{ROBOTWS_PARENT_DIR}/robotws/testsuite/Ulm/ET/L2/libraries')
    all_threads = create_threads(
        config_files, TEST_SCRIPT_PATH, ROBOTWS_PARENT_DIR, VENV_PATH)
    run_threads_in_chunks(available_cpu_threads=cpu_cores, threads=all_threads)
    if args.create_golden:
        print('removing old golden files...')
        shutil.rmtree(f'{generated_output_files_dir}/golden_files/')
        print('done...\ncopying current run to golden files...')
        shutil.copytree(f'{generated_output_files_dir}/last_run',
                        f'{generated_output_files_dir}/golden_files')
        print('new golden files created...')
        print('checking back out to previous branch...')
        repo.git.checkout(current_branch)
        repo.git.stash('pop')
    compare_with_golden_files(generated_output_files_dir, config_files)


if __name__ == '__main__':
    main()
