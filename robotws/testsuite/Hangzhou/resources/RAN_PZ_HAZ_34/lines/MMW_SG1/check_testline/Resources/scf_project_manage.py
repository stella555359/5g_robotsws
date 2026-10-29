import shutil
import os
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
#  from git.repo import Repo


def backup_project(src_path, backup_path):
    """
    Author: Cheng Catherine  5G_PZ_MMW_HZ_1_SG
    copy src_path to backup_path, and before copying, delete backup_path if backup_path already exists.
    :param src_path: src project path, e.g. /home/ute/Projects/mmw1_config/
    :param backup_path: backup project path, e.g. /tmp/mmw1_config/
    :return:
    """
    BuiltIn().log_to_console("\n=== backup_project: start to backup project")
    if os.path.exists(src_path):
        print("\n=== start to backup project")
        if os.path.exists(backup_path):
            shutil.rmtree(backup_path)
        shutil.copytree(src_path, backup_path)
    else:
        print("\n=== cannot backup project due to src project not exist")


def restore_project_if_needed(src_path, backup_path):
    """
    Author: Cheng Catherine  5G_PZ_MMW_HZ_1_SG
    restore src_path from backup_path.
    :param src_path: src project path, e.g. /home/ute/Projects/mmw1_config/
    :param backup_path: backup project path, e.g. /tmp/mmw1_config/
    :return:
    """
    BuiltIn().log_to_console("\n=== restore_project_if_needed: start to restore project")
    if not os.path.exists(backup_path):
        raise Exception("\n=== restore_project: cannot restore due to backup project not exists")
    elif os.path.exists(src_path):
        print("\n=== restore_project: no need to backup due to src project exists")
    else:
        print("\n=== restore_project: start to restore project")
        shutil.copytree(backup_path, src_path)
        raise Exception("git clone might failed, restore project successfully")


def redo_git_clone(dst_url, dst_path):
    """
    Author: Cheng Catherine  5G_PZ_MMW_HZ_1_SG
    delete old project of dst_path, then clone new project from url to dst_path
    :param dst_url: valid git url, e.g. "git@wrgitlab.ext.net.nokia.com:mmw1/mmw1_config.git"
    :param dst_path: Path to which the repository should be cloned to, e.g. /home/ute/Projects/mmw1_config/
    :return:
    """
    BuiltIn().log_to_console("\n=== redo_git_clone: start to clone new project")
    git_cmd = "git remote set-url origin git@wrgitlab.ext.net.nokia.com:mmw1/mmw1_config.git;" \
              "git clone -v " + dst_url + " " + dst_path
    if os.path.exists(dst_path):
        print("\n=== redo_git_clone: start to delete project")
        shutil.rmtree(dst_path)
    print("\n=== redo_git_clone: start to clone project")
    # Repo.clone_from(url=dst_url, to_path=dst_path)
    rc, output = OperatingSystem().run_and_return_rc_and_output(git_cmd)
    print("\n=== redo_git_clone result: %s, out_put: %s", rc, output)


if __name__ == '__main__':
    url = "git@wrgitlab.ext.net.nokia.com:mmw1/mmw1_config.git"
    path = "/home/ute/Projects/mmw1_config/"
    back_path = "/home/ute/Projects/mmw1_config_backup"
    remote_url = "git@wrgitlab.ext.net.nokia.com:RAN/robotws.git"
    set_remote_url(remote_url)
    backup_project(path, back_path)
    redo_git_clone(url, path)
    restore_project_if_needed(path, back_path)
