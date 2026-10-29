
import pathlib


class ScfDummy:
    def __init__(self):
        self.scf_path = pathlib.Path(__file__).parent.parent.joinpath("test_files", "test_scf_manager_scfc.xml")
        with open(self.scf_path, "r", encoding="utf-8") as rstream:
            self.scf_content = rstream.read()

    def get_scf_content(self):
        if self.scf_content is not None:
            return self.scf_content
        return '<empty>'
