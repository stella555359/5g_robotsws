"""Remote command execution and file transfer."""
import errno
import os
import pathlib
import stat

from taf.transport.ssh import ssh as Ssh
from typing import Any, Optional

ssh = Ssh()


def _rstat(path: str, conn: Any) -> bool:
    """Returns os.stat() of a remote path."""
    fp = conn.files
    return fp.stat(remote_path=path, timeout=30)


def remote_run(cmd: str, conn: Any) -> Optional[str]:
    """Run command on the remote, wait for it to finish, and return its output content.

    Args:
        cmd: Command to execute; it may contain pipes and other shell specifics.
        conn: Remote connection (instance of taf.transport.ssh.connection.Connection).

    Returns:
        Output of executed command.

    Raises:
        AssertionError: If command finishes with exit code other that 0.
    """
    ssh.send_command(cmd, connection=conn)
    ssh.await_execution_end(connection=conn)
    error_msg = f"Command `{cmd}` failed with STDERR: %s"
    stdout = ssh.read_output(connection=conn).strip()
    stderr = ssh.read_error(connection=conn).strip()
    exit_code = ssh.get_exit_status(connection=conn)
    assert exit_code == 0, error_msg % stderr
    return stdout


def put(src: str, dest: str, conn: Any) -> str:
    """Copy a file from the local system to a location on the remote machine.

    Args:
        src: Local path to a file to copy to the remote server.
        dest: Remote absolute path where the file should be copied to.
            If `dest` is a non-existent path and ends with "/", it is created.
            If `dest` is a file, the parent directory of `dest` is not created and the
            exception is raised if it does not already exist.
        conn: Remote connection (instance of taf.transport.ssh.connection.Connection).

    Returns:
        Path to copied file on the remote system.

    Raises:
        OSError: If `src` does not exist, or if `dest` is a file and its parent
            directory does not exist.
    """
    local_path, remote_path = pathlib.Path(src), pathlib.Path(dest)

    if not local_path.is_file():
        raise OSError(errno.ENOENT, os.strerror(errno.ENOENT), src)

    try:
        rstat = _rstat(dest, conn)
        if stat.S_ISDIR(rstat.st_mode):
            remote_path = remote_path.joinpath(local_path.name)
    except FileNotFoundError:
        if dest.endswith("/"):
            remote_run(f"mkdir -p {dest}", conn)
            remote_path = remote_path.joinpath(local_path.name)
    finally:
        ssh.upload_file(src, remote_path.as_posix(), connection=conn)

    return remote_path.as_posix()


def fetch(src: str, dest: str, conn: Any) -> str:
    """Fetch a file from the remote machine and store it locally.

    Args:
        src: The file on the remote system to fetch.
        dest: A local path to save file into.
            If `dest` is a non-existent path and ends with "/", it is created.
            If `dest` is a file, the parent directory of `dest` is not created and the
            exception is raised if it does not already exist.
        conn: Remote connection (instance of taf.transport.ssh.connection.Connection).

    Returns:
        Path to saved file on the local system.

    Raises:
        OSError: If `src` does not exist, or if `dest` is a file and its parent
            directory does not exist.
    """
    local_path, remote_path = pathlib.Path(dest), pathlib.Path(src)

    rstat = _rstat(src, conn)
    if not stat.S_ISREG(rstat.st_mode):
        raise OSError(errno.ENOENT, os.strerror(errno.ENOENT), src)

    if not local_path.exists() and dest.endswith("/"):
        local_path.mkdir(parents=True)

    if local_path.is_dir():
        local_path = local_path.joinpath(remote_path.name)

    ssh.download_file(src, local_path.as_posix(), connection=conn)
    return local_path.as_posix()
