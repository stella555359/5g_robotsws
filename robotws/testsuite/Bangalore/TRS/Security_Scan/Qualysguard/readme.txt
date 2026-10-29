Usage:
Option 1: Start Scan with Build Download and Update
    sh start_scan.sh <build_release> <scan_profile> <scan_name>
    Example: sh start_scan.sh SBTS00_ENB_9999_221224_000005 scan1 Demo_Scan

Option 2: Start scan without Build Download
    python qualysguard_scan.py --profile <scan_profile> --name <scan_name>
    Example: python qualysguard_scan.py --profile scan1 --name Demo_Scan
