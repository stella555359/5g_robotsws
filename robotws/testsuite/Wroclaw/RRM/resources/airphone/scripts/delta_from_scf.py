from taf.config.scf.interface import scf
import argparse

ok_green = '\033[92m'
end_grey = '\033[0m'

parser = argparse.ArgumentParser(description='Compare 2 scf files and create delta from differences')
parser.add_argument('scf_original', help='Please provide path to the original scf.xml file')
parser.add_argument('scf_changed', help='Please provide path to the changed scf.xml file')
parser.add_argument('output_dir', nargs='?', const=1, default="/home/ute/scf_delta.json",
                    help="Please provide output path for new delta, default is /home/ute/scf_delta.json")
args = parser.parse_args()

print("{}Creating...".format(ok_green))
scf().calculate_delta_scf(target_scf_path=args.scf_original, actual_scf_path=args.scf_changed,
                          delta_scf_path=args.output_dir)
print('Delta created at {} {}'.format(args.output_dir, end_grey))
