try:
    import lzma
except ImportError:
    from backports import lzma
import re
import zipfile
from io import BytesIO


def get_all_cprt_logs(snapshot_path, output_path):
    with open(output_path, "w+") as f:
        f.close()
    with open(output_path, "a+") as f:
        snapshot_file_zip = snapshot_path

        search_snap(snapshot_file_zip, create_all_logs_together, f)


def search_snap(snapshot_file, func, result=None):
    try:
        with zipfile.ZipFile(snapshot_file) as myzip:
            for zfile in myzip.namelist():
                if zfile.endswith('zip'):
                    zfiledata = BytesIO(myzip.read(zfile))
                    search_snap(zfiledata, func, result)
                elif zfile.endswith('.log.xz') and zfile.find('runtime') > -1:
                    zfiledata = BytesIO(myzip.read(zfile))
                    with lzma.open(zfiledata, mode='rb') as log_file:
                        func(log_file, result)
    except zipfile.BadZipfile as error:
        if str(error) == "File is not a zip file":
            print("Some of the snapshot's parts are corrupted and can't be used properly by ZipFile")


def create_all_logs_together(log_file, writer):
    for row_id, line in enumerate(log_file):
        if len(line) > 1024:
            pass
        else:
            row = line.decode("utf-8", errors="ignore")
            row = row.replace('\r', '').replace('\n', '')
            if len(row.split()) > 3:
                comp = row.split()[1].split('-')
                if any(keyWord in comp[0] for keyWord in ['FCT', 'ASP', 'LINUX', 'L1_SYS_LOG']) and (
                        "[MessagesSender]" in row or "[MessagesReceiver]" in row
                ):
                    # Ex:         "text_before_date <...> text_after_date"
                    # Will return "<...> text_after_date"
                    row = re.sub(r'.*?(<\d+?-\d+?-\d+?T\d+?:\d+?:\d+?\.\d+?Z>.*)', r'\g<1>', row)
                    writer.write(row + '\n')


def check_if_narfcn_is_correct(log_input, log_output):
    with open(log_input, "r") as original_file, open(log_output, "w") as converted_file:
        for line in original_file:
            if "narfcn" in line:
                index = line.find("[MessagesSender]") + len("[MessagesSender]")
                converted_file.write(line[index:].strip() + " ")
    with open(log_output, "r") as converted_file:
        for line in converted_file:
            regexp1 = r"narfcnDl.*Narfcn.*126000"
            regexp2 = r"narfcnUl.*Narfcn.*136000"
            if re.search(regexp1, line) and re.search(regexp2, line):
                print("Narfcn is successfully checked")
            else:
                assert False, "Error: regexp not found"
