import json
import argparse

parser = argparse.ArgumentParser(description='Beautify delta')
parser.add_argument('input_path', help='Please provide path to ugly delta.')
parser.add_argument('output_path', nargs='?', const=1, default="/home/ute/beautiful_delta.json",
                    help="Please provide output path for new delta, default is /home/ute/beautiful_delta.json")
args = parser.parse_args()

with open(args.input_path, "r") as ugly_delta:
    ugly_delta_as_json_object = json.load(ugly_delta)
with open(args.output_path, "w") as pretty_delta:
    json.dump(ugly_delta_as_json_object, pretty_delta, indent=2)
