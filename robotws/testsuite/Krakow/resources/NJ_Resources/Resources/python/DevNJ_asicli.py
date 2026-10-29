import os


def prepare_asi_cli_env_for_enb(local_asicli_file, dest_asicli_dir):
    os.system("sudo rm -rf {}".format(dest_asicli_dir))
    os.system("sudo mkdir -p {}".format(dest_asicli_dir))
    os.system("sudo tar zxf {} -C {}".format(local_asicli_file, dest_asicli_dir))
    os.system("sudo chown -R ute.ute {}".format(dest_asicli_dir))
