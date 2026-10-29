from taf.transport.ssh.exceptions import ConnectFailedError


class ADETTimeout(Exception):
    pass


class RadioNotInstalled(Exception):
    pass


def retry_if_ap_failed_startup(exception):
    return isinstance(exception, ADETTimeout) or isinstance(exception, RadioNotInstalled)\
           or isinstance(exception, ConnectFailedError)
