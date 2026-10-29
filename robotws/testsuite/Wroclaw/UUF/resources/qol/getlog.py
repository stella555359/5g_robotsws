import argparse
import os
import subprocess
import zipfile
import re
import random
import string

# Set up argument parser
parser = argparse.ArgumentParser(description='Download files with wget, zip them, and handle errors.')
parser.add_argument('url', type=str, help='The URL to download.')
parser.add_argument('-f', '--force', action='store_true', help='Force zip file creation even if wget fails.')
parser.add_argument('-v', '--verbose', action='store_true', help='Display wget messages.')

# Parse arguments
args = parser.parse_args()

# Set your target directory
TARGET_DIR = '/home/ute/burak/agent/download/'
DOWNLOAD_DIR = '/tmp/getlog'
WGET_COMMAND = 'wget'
ILLEGAL_CHARACTERS = re.compile(r'[<>:"/\\|?*]')


def random_string(length=6):
    """Generate a random string of fixed length."""
    letters_and_digits = string.ascii_letters + string.digits
    return ''.join(random.choice(letters_and_digits) for i in range(length))


def sanitize_file_names(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            sanitized_name = re.sub(ILLEGAL_CHARACTERS, '', file)
            if sanitized_name != file:
                os.rename(os.path.join(root, file), os.path.join(root, sanitized_name))


def download_files(url, force_zip, verbose):
    # Ensure download directory exists
    random = random_string()
    os.makedirs(DOWNLOAD_DIR, exist_ok=True)
    download_path = os.path.join(DOWNLOAD_DIR, random)
    os.makedirs(download_path, exist_ok=True)
    print("downloading...")
    # Prepare wget command
    wget_command = [WGET_COMMAND, '-r', '-np', '-nH', '--cut-dirs=3', '-R', 'index.html', url]
    if not verbose:
        wget_command.insert(1, '-q')  # Quiet mode

    # Run wget command
    result = subprocess.run(wget_command, cwd=download_path)

    # Handle wget result based on arguments
    if result.returncode != 0 and not force_zip:
        print(
            "!!! ERROR !!!: wget command failed \nuse -f/--force to force zip creation, \nuse -v/--verbose for more "
            "info\n\nExiting without creating a zip file.")
        return
    print("zipping...")
    # Proceed with zipping
    sanitize_file_names(download_path)
    zip_filename = f"{random}.zip"
    zip_path = os.path.join(TARGET_DIR, zip_filename)
    with zipfile.ZipFile(zip_path, 'w') as zipf:
        for root, dirs, files in os.walk(download_path):
            for file in files:
                file_path = os.path.join(root, file)
                zipf.write(file_path, os.path.relpath(file_path, download_path))

    # Optionally, clean up the download directory
    for root, dirs, files in os.walk(download_path):
        for file in files:
            os.remove(os.path.join(root, file))

    print_message = ('Files have been successfully downloaded and zipped as '
                     '\nfile://burak1/csv4all/UUF/SBTS/agent/download/{}').format(
        zip_filename)
    if result.returncode != 0:
        print_message = ('wget encountered an error, but the zip file was created anyways '
                         '\nfile://burak1/csv4all/UUF/SBTS/agent/download/{}').format(
            zip_filename)
    print(print_message)


if __name__ == '__main__':
    download_files(args.url, args.force, args.verbose)
