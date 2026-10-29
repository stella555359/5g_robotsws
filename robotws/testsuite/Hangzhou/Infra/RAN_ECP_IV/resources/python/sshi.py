from taf.hw.fhgw.cli.interface import cli


class sshi(cli):

    """ SSH interface """

    DEFAULT_PROMPT = r"([$#]|(?i)password:|\(y/n\))"

    def connect_to(self, ip, username, password, port=22, prompt=DEFAULT_PROMPT,
                   timeout="120s", width=None, alias="default", keyfile=""):
        cli.connect_to(self,
                       ip=ip,
                       username=username,
                       password=password,
                       port=port,
                       prompt=prompt,
                       timeout=timeout,
                       width=width,
                       alias=alias,
                       keyfile=keyfile
                       )
        self.call_sshlib("set_client_configuration", escape_ansi=True, _alias=alias)
        return alias

    def disconnect_all(self):
        for alias in list(self.sshconn.ssh_pool.keys()):
            self.disconnect(alias)

    def call_sshlib(self, func_name, *args, **kwargs):
        # _alias in kwargs: specify the sshconnection (sshlibrary) instance that to execute the function.
        alias = kwargs.pop("_alias", "default")
        try:
            conn = self.sshconn.ssh_pool[alias]
        except KeyError:
            raise RuntimeError("Need relevant alias [%s] to be created by sshi.connect_to beforehand." % alias)
        func_name = func_name.strip().lower().replace(" ", "_")
        return getattr(conn, func_name)(*args, **kwargs)
