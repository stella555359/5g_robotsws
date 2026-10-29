import hashlib
import logging

BAD_VERSION_CHECKSUM = "64d20f8bd8d3f9c5e2f558a11ca2eab6e238710b"
INSTALL_PATHS = [
    "/home/ute/.config/wireshark/plugins/packet_iphy.lua",
    "/home/ute/.local/lib/wireshark/plugins/packet_iphy.lua",
]
PATCH_LINES = {
    5793: "\ttree_arr[1]:add(f_hdr_enb_id, buffer(offset, 2):uint(enb_id))\n",
    5794: "\ttree_arr[1]:add(f_hdr_cell_id, buffer(offset + 2, 2):uint(cell_id))\n",
}


def _sha1(file_path: str) -> str:
    hasher = hashlib.sha1()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hasher.update(chunk)
    return hasher.hexdigest()


def _patch(file_path: str):
    with open(file_path, "r") as f:
        lines = f.readlines()
    for n, patched in PATCH_LINES.items():
        lines[n] = patched
    with open(file_path, "w") as f:
        f.writelines(lines)


def patch_iphy_plugin():
    """Ad-hoc patch wireshark's plugin "packet_iphy" source file, if necessary.

    This is a workaround for WSLTE-2239.
    """
    for file_path in INSTALL_PATHS:
        try:
            if _sha1(file_path) == BAD_VERSION_CHECKSUM:
                logging.info(f"Found bad version of {file_path}. Applying patch..")
                _patch(file_path)
                logging.info("Done.")
        except OSError as err:
            logging.warn(f"{err} occured while checking {file_path}")
