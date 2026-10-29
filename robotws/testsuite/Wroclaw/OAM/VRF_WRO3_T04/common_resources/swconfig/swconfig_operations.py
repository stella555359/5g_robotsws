class swconfig_operations(object):

    def __init__(self, path_to_swconfig=None):
        self.path_to_swconfig = path_to_swconfig
        if path_to_swconfig:
            self.swconfig_content = self._read_sw_config()
        else:
            self.swconfig_content = ""
        self.current_flags = self.get_current_active_flags()

    def _read_sw_config(self):
        with open(self.path_to_swconfig, "r") as f:
            return f.read()

    @staticmethod
    def _validate_flag(flag_id, flag_value):
        assert len(flag_id) == 8, "Flag length not correct."
        assert flag_id[0:2] == "0x", "Flag format wrong, expected \'0x\' at the beginning."
        assert str(flag_value) == "1" or str(flag_value) == "0", "Flag value not correct."
        assert flag_id.isalnum(), "Flag should contain only alphanumeric characters."

    def append_flag(self, flag_id, flag_value):
        self._validate_flag(flag_id, flag_value)
        self.current_flags.update({flag_id.lower(): flag_value})

    def append_flags(self, flags):
        for flag_id, flag_value in flags.items():
            self._validate_flag(flag_id, flag_value)
            self.current_flags.update({flag_id: flag_value})

    def get_current_active_flags(self):
        current_flags = {}
        for line in self.swconfig_content.split("\n"):
            try:
                flag_id, flag_value = line[0:8].lower(), line[9]
                self._validate_flag(flag_id, flag_value)
            except (AssertionError, IndexError):
                continue
            else:
                if line[8] == "=":
                    current_flags.update({flag_id: flag_value})
        return current_flags

    def remove_flag(self, flag_id):
        try:
            self.current_flags.pop(flag_id.lower())
        except KeyError:
            pass

    def remove_flags(self, flags):
        for flag_id in flags:
            try:
                self.current_flags.pop(flag_id.lower())
            except KeyError:
                pass

    def save_swconfig(self, output_filename):
        with open(output_filename, "w") as f:
            for flag_id, flag_value in self.current_flags.items():
                f.write(flag_id + "=" + flag_value + "\n")
