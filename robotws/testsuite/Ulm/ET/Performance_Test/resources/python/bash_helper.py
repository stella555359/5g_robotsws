

import subprocess
import traceback

import logging

from pathlib import Path


logger = logging.getLogger(__name__)


def run_bash_subprocess(
        cmd, shell=True, capture_output=True,
        check=False, cwd=None, supress_all_logs=False, return_rc=False, bash=True):
    output = None
    error = None
    try:
        redir_output = '> /dev/null 2>&1' if supress_all_logs else ''
        if bash:
            full_cmd = f'bash -c "{cmd} {redir_output}"'
        else:
            full_cmd = f'{cmd} {redir_output}'
        logger.debug(
            f'\n    execute: {full_cmd}\n    cwd={cwd}\n')
        result = subprocess.run(
            full_cmd,
            check=check, capture_output=capture_output, shell=shell, cwd=cwd)
        output = result.stdout
        error = result.stderr
        if result.returncode != 0:
            logger.debug("    [ERROR] - [run_bash_subprocess] cmd: {}, Ret: {}, error: {}".format(
                cmd, result.returncode, error
            ))
        if not supress_all_logs:
            logger.debug(f"\n    [OUTPUT]:{output}\n    [ERROR]:{error}\n")

        return (output, result.returncode) if return_rc else output
    except Exception as e:
        logger.debug(f"\n    cmd: {cmd}\n    [OUTPUT]:{output}\n    [ERROR]:{error}\n")
        logger.debug(f"    run_bash_subprocess e={e}\n{traceback.format_exc()}")
        return (None, 1) if return_rc else None


def clone_repo(repo,
               clone_target_dir='/home/ute/DEVELOPMENT', id='/home/ute/.ssh/ca_ute_gitlab/id_rsa'):
    try:
        repo_name = Path(repo).stem
        if not Path(f"{clone_target_dir}/{repo_name}").exists():
            logger.debug(f"Cloning: {repo}")
            run_bash_subprocess(f"ssh-agent bash -c 'ssh-add {id};cd {clone_target_dir}/ && git clone {repo}'")
        else:
            logger.debug(f"repo exists")
    except Exception as e:
        logger.debug(f"Cloning fail: {e}")
