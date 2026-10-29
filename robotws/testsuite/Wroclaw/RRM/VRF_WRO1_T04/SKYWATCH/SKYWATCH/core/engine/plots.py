from core.RegexWatcher import log_path, timestamp


def generate_active_scenarios_in_time(timeout_at, csv_file):
    try:
        import pandas as pd
        import matplotlib.pyplot as plt
        import matplotlib.dates as mdates
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pandas"])
        subprocess.check_call([sys.executable, "-m", "pip", "install", "matplotlib"])
        import pandas as pd
        import matplotlib.pyplot as plt
        import matplotlib.dates as mdates

    dataframe = pd.read_csv(csv_file)
    date_range = pd.date_range(
        start=dataframe["Start"].min(),
        end=dataframe["Stop"].max(),
        freq="s"
    )
    activity = pd.Series(0, index=date_range, dtype=int)

    for start, end in zip(dataframe["Start"], dataframe["Stop"]):
        activity.loc[start:end] += 1

    plt.figure(figsize=(12, 5))
    plt.plot(activity.index, activity.values, color='tab:blue')
    plt.axvline(
        x=timeout_at,
        color='red',
        linestyle='--',
        linewidth=2,
        label='timeout'
    )
    plt.fill_between(activity.index, activity.values, color='skyblue', alpha=0.3)
    plt.title("Number of active scenarios in time (seconds)")
    plt.xlabel("Time")
    plt.ylabel("Active scenarios")
    plt.xticks(rotation=45)
    plt.grid(alpha=0.3)
    plt.tight_layout()
    plt.savefig(f"{log_path._get_target()}telnet_active_ues_{timestamp._get_target()}.png")
    # plt.show()

# csv_file="/home/ute/logs/2025-07-30-22-09-13/telnet_watcher_2025-07-30-22-09-13_timings.csv"
# df = pd.read_csv(csv_file)
#
# generate_active_scenarios_in_time(df)
