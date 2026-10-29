import os
import zipfile

__all__ = ['get_ru_reset_cause_from_snapshot']


def unzipfile(zip_path, unzip_path):
    with zipfile.ZipFile(zip_path, "r") as zf:
        if not os.path.exists(unzip_path):
            os.mkdir(unzip_path)
        zf.extractall(unzip_path)


def get_ru_reset_cause_from_snapshot(snapshot_log_path, runtime_name, snapshot_unzip_path=None):
    if not os.path.exists(snapshot_log_path):
        return "snapshot log not exists"
    if not snapshot_unzip_path:
        log_name = snapshot_log_path.split("/")[-1]
        snapshot_unzip_path = os.getcwd()+"/"+log_name.strip().replace(".zip", "")
    unzipfile(snapshot_log_path, snapshot_unzip_path)
    zip_name = ""
#   find zip which contain runtime.zip
    file_list_txt_path = snapshot_unzip_path+"/snapshot_file_list.txt"
    with open(file_list_txt_path, "r") as f:
        lines = f.readlines()
        for i in range(len(lines)):
            if runtime_name in lines[i]:
                break
        for j in range(1, i+1):
            if lines[i-j].strip().endswith(":"):
                break
        zip_name = lines[i-j].strip().rstrip(":")
    if not zip_name:
        return "can't find "+runtime_name
#   extract zip which contain run.zip
    zip_path = snapshot_unzip_path+"/"+zip_name
    unzip_path = zip_path .replace(".zip", "")
    if not os.path.exists(zip_path):
        return "can't find the zip which contain "+runtime_name
    unzipfile(zip_path, unzip_path)
#   extract run.zip
    zip_path = unzip_path+"/"+runtime_name
    unzip_path = zip_path.replace(".zip", "")
    if not os.path.exists(zip_path):
        return "can't find "+runtime_name
    unzipfile(zip_path, unzip_path)
#   extract runtime_DEFAULT.log.xz
    zip_path = unzip_path+"/"+"runtime_DEFAULT.log.xz"
    if not os.path.exists(zip_path):
        return "can't find runtime_DEFAULT.log.xz"
    os.system("xz -df "+zip_path)
    log_path = zip_path.replace(".xz", "")
    if not os.path.exists(log_path):
        return "can't fine runtime_DEFAULT.log"
#   serach keywords in runtime_DEFAULT.log
    reset_cause = ""
    with open(log_path, "r") as f:
        lines = f.readlines()
        for line in lines:
            if "Last reset cause" in line:
                reset_cause = line.split("Last reset cause:")[1].strip()
                break
    os.system("rm -rf "+snapshot_log_path)
    os.system("rm -rf "+snapshot_unzip_path)
    return reset_cause
