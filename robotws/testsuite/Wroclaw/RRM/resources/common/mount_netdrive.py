import os.path
import subprocess


def mount_netdrive(sw_dir: str = '/mnt/UUF_SW/') -> None:
    """Mounts a burak network drive containing software and creates a shortcut to it unders specified directory.

    This function attempts to mount a burak network drive with a shortcut to it at the specified directory.
    If the directory does not exist it will be created with appropriate permissions.
    The network drive is mounted using the CIFS protocol with the provided credentials.

    :param sw_dir: The directory where the network drive should be mounted. Defaults to '/mnt/UUF_SW/'
    :raises Exception: If the mount command fails.
    """
    if not os.path.exists(os.path.join(sw_dir, 'SBTS')):
        if not os.path.exists(sw_dir):
            cmd = r"sudo mkdir /mnt/UUF_SW &&" \
                  r"sudo chmod 777 /mnt/UUF_SW &&" \
                  r"sudo mount -t cifs //10.42.248.45/Global_veryfication/[1]\ SW /mnt/UUF_SW/ -o" \
                  r" username=wro5grrm,password='5gpass!1'" \
                  r",domain=noklab,file_mode=0777,dir_mode=0777,uid=ute,gid=ute"
        else:
            cmd = r"sudo mount -t cifs //10.42.248.45/Global_veryfication/[1]\ SW /mnt/UUF_SW/ -o" \
                  r" username=wro5grrm,password='5gpass!1'" \
                  r",domain=noklab,file_mode=0777,dir_mode=0777,uid=ute,gid=ute"
        try:
            subprocess.check_output(cmd, universal_newlines=True, shell=True)
        except subprocess.CalledProcessError as e:
            raise OSError("Network drive failed to mount.") from e
