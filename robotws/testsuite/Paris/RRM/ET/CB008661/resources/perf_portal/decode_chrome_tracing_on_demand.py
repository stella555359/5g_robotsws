import datetime
import os
import re
import subprocess
import sys
from report import Report

SUPPORT_MESSAGE = (
    "An error occur, a mail was sent to support\n"
    "For more, contact I_MN_5GSC_SW_ENG_PERF_SERVER@groups.nokia.com\n"
)

ROOT_DIR = "/5g_storage/PatchServer/perfport"
TMP_DIR = f"{ROOT_DIR}/webserver/tmp"
DEST_DIR = f"{ROOT_DIR}/webserver/ChromeFile"

CHROME_TRACING_CONVERTER = f"{ROOT_DIR}/external_tools/gnb/uplane/tools/tm2chrome/tm2chrome.py"
CHROME_TRACING_2HTML = f"{ROOT_DIR}/external_tools/catapult/tracing/bin/trace2html"


def print_help():
    cmd = sys.argv[0]
    print(f"{cmd} error: parse parameter error\n{cmd} <snapshot_file_full_path>\n")


def print_log(message):
    print(f"[{datetime.datetime.utcnow()}] {message}", flush=True)


def run(command, message, shell=True):
    print_log(f"{message} start")
    start = datetime.datetime.utcnow()
    result = subprocess.run(
        command,
        shell=shell,
        check=False,
        universal_newlines=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode:
        message = (
            f"{command} has return a non null value: {result.returncode}"
            f"STDOUT: {result.stdout}"
            f"STDERR: {result.stderr}"
        )
        print_log(message)
        raise subprocess.CalledProcessError(result.returncode, message)
    end = datetime.datetime.utcnow()
    print_log(f"{message} duration: {end - start}")


class ChromeDecoder:
    def uncompress_snapshot(self, snap_file):
        run(
            f"/bin/xz -cd {snap_file} > {self.tmp_dir}/{self.snapshot_file_name}",
            "uncompress snapshot file",
        )

    def decode_chrome_tracing(self):
        file_snapshot = f"{self.tmp_dir}/{self.snapshot_file_name}"
        file_chrome = f"{self.tmp_dir}/{self.chrome_tracing_file}"
        run(
            f"python3 {CHROME_TRACING_CONVERTER} -f {file_snapshot} -o {file_chrome}",
            "convert snapshot to chrome tracing file",
        )

    def chrome_tracing_to_html(self):
        file_chrome = f"{self.tmp_dir}/{self.chrome_tracing_file}"
        run(f"{CHROME_TRACING_2HTML} {file_chrome}", "convert chrome tracing to html")

    def store_html_result(self):
        file_html_chrome = f"{self.tmp_dir}/{self.chrome_tracing_html}"
        dest_html_chrome = f"{DEST_DIR}/{self.chrome_tracing_html}"
        run(f"mv {file_html_chrome} {dest_html_chrome}", "save chrome html file to repository")

    def clean_tmp_dir(self):
        run(f"rm -rf {self.tmp_dir}", "delete temporary dir")

    def __init__(self, snap_file):
        self.snapshot_file_name = re.sub(r"\.xz$", "", os.path.basename(snap_file))
        self.chrome_tracing_file = re.sub(r"^TimeMarker", "ChromeTracing", self.snapshot_file_name)
        self.chrome_tracing_html = re.sub(r"\.json", ".html", self.chrome_tracing_file)
        print_log(f"Start working for {self.snapshot_file_name}")
        print_log(f"PID: {os.getpid()}")

        self.tmp_dir = f"{TMP_DIR}/{os.getpid()}_{self.snapshot_file_name}"
        print_log(f"tmp dir: {self.tmp_dir}")

        os.mkdir(self.tmp_dir)
        self.uncompress_snapshot(snap_file)
        self.decode_chrome_tracing()
        self.chrome_tracing_to_html()
        self.store_html_result()
        self.clean_tmp_dir()

        print_log("End without error")


if __name__ == "__main__":

    if len(sys.argv) != 2:
        print_help()
        sys.exit(1)
    snapshot_file = sys.argv[1]

    try:
        ChromeDecoder(snapshot_file)
    except Exception:
        Report().error()
        print(SUPPORT_MESSAGE, flush=True)
        print_log("End with error")
