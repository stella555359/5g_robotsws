# gnb_package.py
import requests
import re
import subprocess
import os

ROBOT_LIBRARY_SCOPE = "GLOBAL"

BASE_URL = (
    "https://artifactory-espoo2.int.net.nokia.com/"
    "artifactory/mn-cosi-sran-central-public-local/build/SBTS00/"
)

GNB_PKG_DIR = "/home/ute/mulu"


# ===== Robot Keywords =====
def get_latest_gnb_package():
    """
    Get the latest SBTS00_ENB_9999 package that meets the minimum size requirement.
    Returns a tuple: pkg_name, download_url, sw_path

    Arguments:
    - min_size_gb: minimum package size in GB (default 9)

    Example in Robot:
    ${pkg}    ${url}    ${sw_path}    Get Latest Gnb Package    9
    """
    min_size_gb = 9
    try:
        resp = requests.get(BASE_URL, timeout=30)
        resp.raise_for_status()
        html = resp.text
    except Exception as e:
        raise RuntimeError(f"Failed to fetch GNB packages: {e}")

    pattern = re.compile(r'href="(SBTS00_ENB_9999_[^/]+)/"')
    pkgs = pattern.findall(html)
    if not pkgs:
        raise RuntimeError("No SBTS00_ENB_9999 packages found")

    pkgs.sort(reverse=True)

    for pkg in pkgs:
        url = _build_download_url(pkg)
        size_gb = _get_file_size_gb(url)
        if size_gb >= float(min_size_gb):
            sw_path = os.path.join("/home/ute/mulu", f"{pkg}_release_BTSSM_downloadable_A54.zip")
            return pkg, url, sw_path

    latest_pkg = pkgs[0]
    url = _build_download_url(latest_pkg)
    sw_path = os.path.join("/home/ute/mulu", f"{latest_pkg}_release_BTSSM_downloadable_A54.zip")
    return latest_pkg, url, sw_path


def download_gnb_package(download_url, download_dir=GNB_PKG_DIR):
    """
    Download the given GNB package using aria2c.

    Example in Robot:
    Download Gnb Package    ${url}
    """
    exists, file_path = package_already_exists(download_url, download_dir)
    if exists:
        print(f"[INFO] Package already exists, skip download: {file_path}")
        return file_path
    else:
        clean_mulu_dir()

    if not os.path.exists(download_dir):
        os.makedirs(download_dir, exist_ok=True)

    cmd = [
        "aria2c",
        "-s", "16",
        "-j", "16",
        "-x", "16",
        "-d", download_dir,
        download_url
    ]

    subprocess.run(
        ["bash", "-c", "time " + " ".join(cmd)],
        check=True
    )


def _build_download_url(pkg_name):
    filename = f"{pkg_name}_release_BTSSM_downloadable_A54.zip"
    return f"{BASE_URL}{pkg_name}/{filename}"


def _get_file_size_gb(url):
    try:
        resp = requests.head(url, allow_redirects=True, timeout=30)
        resp.raise_for_status()
        size = int(resp.headers.get("Content-Length", 0))
        return size / (1024 ** 3)
    except Exception:
        return 0


def clean_mulu_dir(directory=GNB_PKG_DIR):
    if not os.path.exists(directory):
        print(f"Directory {directory} does not exist.")
        return
    for filename in os.listdir(directory):
        file_path = os.path.join(directory, filename)
        try:
            if os.path.isfile(file_path) or os.path.islink(file_path):
                os.remove(file_path)
                print(f"Deleted file: {file_path}")
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
        except Exception as e:
            print(f"Failed to delete {file_path}. Reason: {e}")


def package_already_exists(download_url, download_dir=GNB_PKG_DIR):
    """
    Check if the package zip already exists in download_dir.
    """
    filename = os.path.basename(download_url)
    file_path = os.path.join(download_dir, filename)
    return os.path.exists(file_path), file_path


if __name__ == "__main__":
    pkg, url, sw_path = get_latest_gnb_package()
    download_gnb_package(url, download_dir=GNB_PKG_DIR)
