from taf.ul.bts_components import Smod, Bbmod


def execute_bsh_command(bsh, command, target_ip="192.168.255.129", target_username="toor4nsn",
                        target_password="oZPS0POrRieRtu", via_ip=None, via_username="ute",
                        via_password=None, alias="connection"):
    """
    Executes a command on a BBMOD device via SMOD, optionally through a proxy.

    Args:
        bsh (str): The login shortcut to identify the BBMOD device.
        command (str): The command to execute on the BBMOD device.
        target_ip (str, optional): IP address of the target SMOD. Defaults to "192.168.255.129".
        target_username (str, optional): Username for the target SMOD. Defaults to "toor4nsn".
        target_password (str, optional): Password for the target SMOD. Defaults to "oZPS0POrRieRtu".
        via_ip (str, optional): IP address of the proxy SMOD, if needed. Defaults to None.
        via_username (str, optional): Username for the proxy SMOD. Defaults to "ute".
        via_password (str, optional): Password for the proxy SMOD. Defaults to None.
        alias (str, optional): Alias prefix for connections. Defaults to "connection".

    Returns:
        str or None: The output of the executed command,
        None if command does not exist or exception if BSH value is wrong.
    """
    proxy = Smod()
    smod = Smod()
    bbmod = Bbmod()

    if via_ip:
        proxy.connect_to(address=via_ip, username=via_username, password=via_password,
                         alias=f"{alias}_proxy", proxy=None)
        proxy_alias = f"{alias}_proxy"
    else:
        proxy_alias = None

    smod.connect_to(address=target_ip,
                    username=target_username, password=target_password, alias=f"{alias}_smod", proxy=proxy_alias)

    for entry in smod.get_bbmods_topology_info(get_other_cpus_info=True):
        if bsh in entry.get('login_shortcut', ''):
            bbmod.connect_to(address=entry['address'], username=entry['username'], password=entry['password'],
                             alias=f"{alias}_bbmod", proxy=f"{alias}_smod")
            return bbmod.execute(command=command).rstrip("\n")
    return None
