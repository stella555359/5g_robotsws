import os
import shutil
import subprocess


def download_package_using_git(git_path, git_folder, git_file_name, token_name, token_access,
                               target_dir='Traces'):
    print(f'\tDownloading Git file from: {git_path}/{git_folder}')
    print(f'\tinto the following folder: {target_dir}')
    print(f'\twith the git token access: {token_name} / {token_access}')

    tmp_git_dir = '/tmp/tempGitFiles'
    git_full_path = f'https://{token_name}:{token_access}@{git_path}' if token_name else f'https://{git_path}'

    # Create target directory and remove the temporary directory used during git clone command:
    os.makedirs(target_dir, exist_ok=True)
    shutil.rmtree(tmp_git_dir, ignore_errors=True)

    result = subprocess.run(['git', 'clone', git_full_path, tmp_git_dir], capture_output=True, text=True)

    if 'fatal' not in result.stderr:
        shutil.copy(f'{tmp_git_dir}/{git_folder}/{git_file_name}', f'{target_dir}/')
        print('File Successfully Downloaded from Git project!')
    else:
        print(f'ERROR: Git Clone Command Failed: {result.stderr}')

    # Temporary directory cleanup:
    shutil.rmtree(tmp_git_dir, ignore_errors=True)

    return f'{target_dir}/{git_file_name}'
