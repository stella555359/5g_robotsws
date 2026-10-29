import subprocess

scripts_path = "/home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/resources/scripts/"
burak_path = "/home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/tools/burak/"
bashrc_path = "/home/ute/.bashrc"
default_logs_path = "/home/ute/manualLogs"

functions_and_aliases = [
    "source /usr/share/bash-completion/completions/git",  # fixes lack of autocompletion of git commands

    "alias admin='source /home/ute/test_repo/bin/activate; python3 {}open_admin.py'".format(scripts_path),

    "alias setup_pycharm='bash {}/setup_pycharm.sh'".format(scripts_path),

    "alias fix_capslock='python3 {}turn_off_capslock.py'".format(scripts_path),

    "alias FIX_CAPSLOCK='fix_capslock'",

    "alias mount_rotta='sudo bash {}./mount_rotta.sh'".format(scripts_path),

    "alias mount_burak='sudo bash {}./mount_burak.sh'".format(burak_path),

    "alias beautify_delta='python3 {}beautify_delta.py'".format(scripts_path),

    "alias delta_from_scf='python3 {}delta_from_scf.py'".format(scripts_path),

    "alias all_in_one='sudo bash {}./all_in_one.sh'".format(scripts_path),

]

if __name__ == "__main__":
    subprocess.check_call(["pip3", "install", "-r", scripts_path + "requirements.txt"])

    with open(bashrc_path, "a") as bashrc:  # open .bashrc in append mode
        bashrc.writelines([line + "\n" for line in functions_and_aliases])
