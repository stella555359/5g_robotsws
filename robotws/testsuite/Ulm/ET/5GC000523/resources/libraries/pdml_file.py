from robot.libraries.BuiltIn import BuiltIn
import os


def strip_headers(source_file, target_file):
    """
    Strips tshark header from given pdml file.
    """
    try:
        line_counter = 0
        with open(source_file) as in_file, open(target_file, 'w') as out_file:
            while True:
                if "xml version" in in_file.readline():
                    break
                if line_counter > 100:
                    BuiltIn().log("ERR: Error with PDML format")
                    return None
                line_counter += 1
            out_file.writelines(in_file.readlines())
        os.chmod(target_file, 0o666)
    except IOError as e:
        BuiltIn().log("File %s not found" % source_file, "ERROR")
        BuiltIn().log(str(e), "ERROR")
        return None
    return
