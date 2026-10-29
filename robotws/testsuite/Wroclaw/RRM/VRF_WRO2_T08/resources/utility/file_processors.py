import lzma
import re
import shutil
import subprocess
from pathlib import Path
from zipfile import ZipFile


def unzip(zip_path, target_dir):
    with ZipFile(zip_path, 'r') as logs:
        logs.extractall(target_dir)


def unxz(xz_path, target_file):
    with open(target_file, 'wb') as target:
        with lzma.open(xz_path) as xz_input:
            target.write(xz_input.read())


def merge_pcaps(out_pcap_path, *pcaps):
    subprocess.run(['mergecap', '-w', f'{str(out_pcap_path)}', *map(str, pcaps)], check=False)
    return out_pcap_path


def merge_text_files(out_txt_path, *files):
    with open(out_txt_path, 'ab') as output_file:
        for file in files:
            with open(file, 'rb') as input_file:
                output_file.write(input_file.read())
    return out_txt_path


def merge_bip_from_zip(out_pcap_path, zip_path):
    unzipped_dir = Path('/tmp/bip_unzipped')
    pcap_regex = re.compile(r'(BTS.*\.zip):(?:\n    .*?)+(.*?mirroring_L2L1.*\.pcap\.xz)')
    unzip(zip_path, unzipped_dir)
    contents_file = unzipped_dir / 'snapshot_file_list.txt'
    with open(contents_file, 'r') as contents:
        relevant_files = pcap_regex.findall(contents.read())
    files_to_merge = []
    for bip_zip_part, pcap_xz in relevant_files:
        unzip(unzipped_dir / bip_zip_part, unzipped_dir)
        unxz(unzipped_dir / pcap_xz, unzipped_dir / pcap_xz[:-3])
        files_to_merge.append(unzipped_dir / pcap_xz[:-3])
    merge_pcaps(out_pcap_path, *files_to_merge)
    shutil.rmtree(unzipped_dir)
    return out_pcap_path
