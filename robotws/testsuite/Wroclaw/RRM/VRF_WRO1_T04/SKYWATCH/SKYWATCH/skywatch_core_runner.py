import os
from helpful_scripts.utilities import update_repo_symlink_if_needed
from core.asyncio_scenario_runner import run_skywatch_project, reset_all_loggers


def main():
    update_repo_symlink_if_needed(os.getcwd())
    run_skywatch_project(timeout=None, testname=None)


if __name__ == "__main__":
    main()
