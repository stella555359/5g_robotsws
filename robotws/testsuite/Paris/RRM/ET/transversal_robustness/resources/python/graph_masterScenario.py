import matplotlib.pyplot as plt
import re
import csv
import os
import pprint
import argparse


def read_data_from_file(file_path):
    with open(file_path, 'r') as file:
        data = file.readlines()
    return data


def parse_data(data):
    ue_data = {str(i): {'timestamps': [0], 'values': [0]} for i in range(99)}
    pattern_traffic = re.compile(r'^(\d+(\.\d+)?);wts;trf_data_(start|stop) ue=(\d+)\s.*$')

    for line in data:
        match = pattern_traffic.match(line.strip())
        if match:
            groups = match.groups()
            if len(groups) == 4:
                timestamp, _, action, ue = groups
                ue_key = str(int(ue))
                if action == "start":
                    ue_data[ue_key]['timestamps'].append(float(timestamp))
                    ue_data[ue_key]['values'].append(1 + int(ue))
                elif action == "stop":
                    ue_data[ue_key]['timestamps'].append(float(timestamp))
                    ue_data[ue_key]['values'].append(0)
            else:
                print(f"line does not match pattern_traffic : {line.strip()}")

    pp = pprint.PrettyPrinter(indent=4, width=80, compact=True)
    pp.pprint(ue_data)
    return ue_data


def plot_ue_data(ue_data, output_dir, mini=0, maxi='600'):
    plt.figure(figsize=(18, 6))  # define the format of the graph
    for ue, data in ue_data.items():
        if data['timestamps']:
            plt.step(data['timestamps'], data['values'], label=f"UE {ue}", where='post')
    plt.xlabel("Timestamp")
    plt.ylabel("traffic state")
    plt.title("traffic on/off for each UE")
    plt.legend(loc='upper left', bbox_to_anchor=(1, 1))  # Move the label outside of the graph
    plt.gca().set_aspect('auto', adjustable='box')

    if maxi == 'max':
        maxi = max(max(data['timestamps']) for data in ue_data.values() if data['timestamps'])
    else:
        maxi = float(maxi)

    plt.xlim(mini, maxi)
    plt.ylim(0, max(max(data['values']) for data in ue_data.values() if data['values']) + 1)

    # Save the plot as JPG and PDF
    plt.savefig(os.path.join(output_dir, "graph.jpg"), bbox_inches='tight')
    # plt.savefig(os.path.join(output_dir, "graph.pdf"), bbox_inches='tight')

    plt.show()


def save_ue_data_to_csv(ue_data, output_dir):
    with open(os.path.join(output_dir, "ue_data.csv"), 'w', newline='') as csvfile:
        fieldnames = ['UE', 'Timestamp', 'Value']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames, delimiter=';')

        writer.writeheader()
        for ue, data in ue_data.items():
            for timestamp, value in zip(data['timestamps'], data['values']):
                writer.writerow({'UE': ue, 'Timestamp': timestamp, 'Value': value})


def main():
    parser = argparse.ArgumentParser(description='Process and plot UE data.')
    parser.add_argument(
        '--file_path', type=str, default='./UeScenario/master_scenario.sce', help='Path to the input file'
        )
    parser.add_argument(
        '--mini', type=float, default=0, help='specify the min timestamp value in abscisse'
        )
    parser.add_argument(
        '--maxi', type=str, default='600',
        help='specify the max timestamp value in abscisse (use the tag "max" to display up to the max possible value)'
        )
    args = parser.parse_args()

    file_path = args.file_path
    output_dir = os.path.dirname(file_path)
    data = read_data_from_file(file_path)
    ue_data = parse_data(data)
    save_ue_data_to_csv(ue_data, output_dir)
    plot_ue_data(ue_data, output_dir, args.mini, args.maxi)


if __name__ == "__main__":
    main()
