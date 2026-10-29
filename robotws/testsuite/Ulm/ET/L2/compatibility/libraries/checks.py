"""Used to check if the latest execution of all Teal testcases match the last execution."""
import filecmp
import json

import deepdiff


def compare_dictionaries(resource1: dict, resource2: dict):
    """compares two dictionaries using deepdiff.
    if both are equal, the second return value is True, else False.

    Args:
        resource1 (dict): _description_
        resource2 (dict): _description_

    Returns:
        tuple: (differences, are_equal)
    """
    difference = deepdiff.DeepDiff(resource1, resource2, ignore_order=True)
    if not difference:
        return None, True
    else:
        return difference, False


def compare_with_golden_files(generated_output_files_dir: str, teal_json_files: list):
    """compares the old generated output with the new and checks for changes.

    Args:
        generated_output_files_dir (str): path to folder.
        teal_json_files (list): The json files (path to files) that were run to generate the new output.
    """
    diff_commands = []
    last_run_dir = f'{generated_output_files_dir}/last_run/'
    golden_run_dir = f'{generated_output_files_dir}/golden_files/'
    for json_file in teal_json_files:
        file_name_json = f'{json_file.parent.name}_{json_file.name}'
        file_name_cfg = file_name_json.replace('json', 'cfg')
        try:
            with open(f'{last_run_dir}{file_name_json}', encoding='utf-8') as output_file:
                last_run = json.load(output_file)
            with open(f'{golden_run_dir}{file_name_json}', encoding='utf-8') as golden_file:
                golden_dict = json.load(golden_file)
            function_output_result = compare_dictionaries(
                last_run, golden_dict)
            basic_setup_comparison_result = filecmp.cmp(
                f'{last_run_dir}{file_name_cfg}',
                f'{golden_run_dir}{file_name_cfg}')
            if basic_setup_comparison_result is False:
                diff_commands.append(f'code --diff {golden_run_dir}{file_name_cfg}'
                                     f' {last_run_dir}{file_name_cfg}')
            if function_output_result[1] is False:
                diff_commands.append(
                    f'code --diff {golden_run_dir}{file_name_json} {last_run_dir}{file_name_json}')
        except FileNotFoundError as e:
            print(e)
            print('Please consider running the golden file generator on master branch first.')
            break
    for command in diff_commands:
        print(command)
