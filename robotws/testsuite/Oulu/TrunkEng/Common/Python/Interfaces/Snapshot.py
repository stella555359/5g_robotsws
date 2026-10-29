import zipfile
import lzma
import re
from io import BytesIO
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info


class Snapshot:

    def __int__(self):
        self.logger = BuiltIn().get_library_instance("LOG")

    @staticmethod
    def find_part_zip_from_file_list(snapshot_zip, searched_file_regex):
        current_part = ""
        with zipfile.ZipFile(snapshot_zip, "r") as zfile:
            for name in zfile.namelist():
                if name == "snapshot_file_list.txt":
                    with zfile.open(name) as f:
                        for line in f:
                            line = line.decode('utf-8')
                            if "BTS_part" in line:
                                current_part = line.replace(":", "").strip()
                            if re.search(searched_file_regex, line):
                                return current_part

    def check_ru_startup_info_print(self, snapshot_zip):
        info("Checking that 'validation of data read from SFP failed' -print is found from RU startup logs")
        correct_part_zip = self.find_part_zip_from_file_list(snapshot_zip, r"BTS_.*_RMOD_L_\d+_startup.zip")
        info(f"Correct part: {correct_part_zip}")
        with zipfile.ZipFile(snapshot_zip, "r") as zfile:
            for name in zfile.namelist():
                if correct_part_zip in name:
                    bts_part_filedata = BytesIO(zfile.read(name))
                    with zipfile.ZipFile(bts_part_filedata) as bts_part_zip:
                        for bts_part_file in bts_part_zip.namelist():
                            if "startup.zip" in bts_part_file:
                                zfiledata = BytesIO(bts_part_zip.read(bts_part_file))
                                with zipfile.ZipFile(zfiledata) as ru_file_zip:
                                    for ru_file in ru_file_zip.namelist():
                                        if ".xz" in ru_file:
                                            rufiledata = BytesIO(ru_file_zip.read(ru_file))
                                            with lzma.open(rufiledata, mode='rt', encoding='utf-8') as fid:
                                                for line in fid:
                                                    if "validation of data read from SFP failed" in line:
                                                        info(f"'validation of data read from SFP failed' "
                                                             f"-print found from {ru_file} from {bts_part_file}")
                                                        info(line)
        info("'validation of data read from SFP failed' -print was not found")
