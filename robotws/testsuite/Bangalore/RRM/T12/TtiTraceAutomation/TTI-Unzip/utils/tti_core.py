from pathlib import Path
import platform
import urllib.request

# from .main import DecodeTtiTraces


def _ensure_binary():
    package_dir = Path(__file__).parent.parent
    bin_dir = package_dir / "bin"
    bin_dir.mkdir(exist_ok=True)

    # checks if the system is linux or windows
    system = platform.system().lower()
    if system == "windows":
        bin_name = "TtiTraceHelper.exe"
        url = "https://s3-china-1.eecloud.nsn-net.net/mMIMO-debug-tool/TtiTraceHelper.exe "
    elif system == "linux":
        bin_name = "TtiTraceHelper"
        url = "https://s3-china-1.eecloud.nsn-net.net/mMIMO-debug-tool/TtiTraceHelper"
    else:
        raise OSError(f"Unsupported OS: {system}")

    bin_path = bin_dir / bin_name
    if not bin_path.exists():
        # download only once
        urllib.request.urlretrieve(url, bin_path)
        try:
            bin_path.chmod(0o755)  # safe on POSIX
        except PermissionError:
            pass

    return bin_path


def get_binary_path():
    return str(_ensure_binary())


# __all__ = ["get_binary_path", "DecodeTtiTraces"]
