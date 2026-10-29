
import logging
import contextlib
import taf.transport.ssh
import taf.sbts.oam.coam.admin
import taf.internal.aliasing.exceptions

from taf.internal.sbts.admin.exceptions.exception import AdminApiConnectionClosedException

CONST_CORE_ALIAS = 'ssh-core'


logger = logging.getLogger(__name__)
_PRIVATE_SSH_OBJ = None
_PRIVATE_ADMIN_API_OBJ = None

CORE_DEFAULT_HOST = "0"
CORE_DEFAULT_USER = 'ute'
CORE_DEFAULT_PASS = 'UTE.debian12'


def ssh_connect(hostname=CORE_DEFAULT_HOST,
                username=CORE_DEFAULT_USER,
                password=CORE_DEFAULT_PASS,
                alias=CONST_CORE_ALIAS,
                proxy=None, force=False):
    get_ssh_obj().connect_to(hostname=hostname,
                             username=username,
                             password=password,
                             alias=alias,
                             proxy=proxy)
    if force:
        get_ssh_obj().force_reconnect(connection=alias)


def execute(command, connection=CONST_CORE_ALIAS, timeout=None):
    logger.info("[%s] cmd | %s", connection, command)
    output = get_ssh_obj().execute(command, connection=connection, timeout=timeout)
    logger.debug("[%s] output | %s", connection, output)
    return output


def send_command(command, connection=CONST_CORE_ALIAS, timeout=None):
    logger.info("[%s] cmd | %s", connection, command)
    output = get_ssh_obj().send_command(command, connection=connection, timeout=timeout)
    logger.info("[%s] output | %s", connection, output)
    return output


def upload_file(local_path, remote_path, connection=CONST_CORE_ALIAS, timeout=None):
    logger.info("[%s] upload_file | %s -> %s", connection, local_path, remote_path)
    get_ssh_obj().upload_file(local_path, remote_path, connection, timeout=timeout)


@contextlib.contextmanager
def oam_http_session_context(*args, **kwargs):
    ctx = oam_http_session(*args, **kwargs)
    try:
        yield ctx
    finally:
        try:
            oam_http_session_td(ctx)
        except UnboundLocalError:
            pass


def oam_http_session(remote_ip=None, admin_api_log_path='/tmp/admin_logs', retries=3):
    oam_alias = "sshw-OAM-http-session"
    for retry in range(1, retries):
        try:
            get_admin_obj().setup_admin(bts_host='192.168.255.129', name=oam_alias,
                                        remote_host=remote_ip, admin_api_log_dir=admin_api_log_path)
            get_admin_obj().get_sw_release_name(connection=oam_alias)
            return oam_alias
        except AdminApiConnectionClosedException:
            logger.warning(
                'retry %s AdminApiConnectionClosedException(%s/%s)', oam_alias, retry, retries)
        except taf.internal.aliasing.exceptions.AliasLookupError:
            logger.warning('retry %s AliasLookupError(%s/%s)',
                           oam_alias, retry, retries)
    logger.error("oam_http_session: AdminConnectionError")
    raise Exc.AdminConnectionError


def oam_http_session_td(oam_alias):
    try:
        get_admin_obj().teardown(connection=oam_alias)
    except taf.internal.aliasing.exceptions.AliasLookupError:
        pass


def get_ssh_obj():
    global _PRIVATE_SSH_OBJ
    if _PRIVATE_SSH_OBJ is None:
        _PRIVATE_SSH_OBJ = taf.transport.ssh.ssh()
    return _PRIVATE_SSH_OBJ


def get_admin_obj():
    global _PRIVATE_ADMIN_API_OBJ
    if _PRIVATE_ADMIN_API_OBJ is None:
        _PRIVATE_ADMIN_API_OBJ = taf.sbts.oam.coam.admin.admin()
    return _PRIVATE_ADMIN_API_OBJ


def main():
    logging.basicConfig(
        format="%(asctime)s|%(levelname)s:%(message)s",
        encoding='utf-8',
        level=logging.DEBUG
    )
    ssh_connect()
    ret = execute('hostname')
    with oam_http_session_context() as oam_alias:
        release = get_admin_obj().get_sw_release_name(connection=oam_alias)
    logger.info(ret)
    logger.info(release)


class Exc:
    class AdminConnectionError(Exception):
        pass


if __name__ == "__main__":
    main()
