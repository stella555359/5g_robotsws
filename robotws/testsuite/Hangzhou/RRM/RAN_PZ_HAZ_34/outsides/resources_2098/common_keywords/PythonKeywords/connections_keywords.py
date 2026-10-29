from taf.transport.ssh.ssh_keywords import SSHManager
from taf.gnb.oam.megazone_client.interface import megazone_client
from taf.sbts.oam.coam.admin.interface import admin
from taf.internal.aliasing.exceptions import AliasLookupError
import logging


def close_ssh_connections():
    """
    Iterate over all ssh connections in store and close all of connections
    """
    logger = logging.getLogger()
    manager = SSHManager()
    keys = manager.store._store.keys()
    for connection in keys:
        try:
            manager.disconnect(connection)
        except AliasLookupError as inst:
            logger.info("Exception occured: {}".format(inst))


def close_cloud_sessions():
    """
    Iterate over all sessions in session store of cloud and teardown all of this sessions
    """
    logger = logging.getLogger()
    client = megazone_client()
    keys = client.session_store._store.keys()
    for alias in keys:
        logger.info("Close connection with alias: {}".format(alias))
        client.teardown_session(alias)


def close_coam_sessions():
    """
    Iterate over all sessions in session store of coam and teardown all of this sessions
    """
    logger = logging.getLogger()
    admin_client = admin()
    keys = admin_client.lookup_handler.store._store.keys()
    for alias in keys:
        logger.info("Close connection with alias: {}".format(alias))
        admin_client.teardown(alias)
