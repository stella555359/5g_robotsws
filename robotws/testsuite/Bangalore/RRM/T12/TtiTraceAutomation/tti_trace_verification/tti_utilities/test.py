from concurrent.futures import ThreadPoolExecutor
import signal
import os

# Safe worker count
CPU_COUNT = min(os.cpu_count() or 4, 8)

# Ctrl+C handler
stop_now = False


def signal_handler(sig, frame):
    global stop_now
    stop_now = True
    print("\n🛑 Stopping...")


signal.signal(signal.SIGINT, signal_handler)


def do_task(i):
    """Task just prints i - NO return needed"""
    print(f"Processing task {i}")
    # Simulate work (replace with your actual work)
    import time

    time.sleep(1)


print(f"Running {CPU_COUNT} parallel workers...")
print("Starting 10 tasks...")

# PARALLEL EXECUTION - Prints happen during processing
with ThreadPoolExecutor(max_workers=CPU_COUNT) as executor:
    # Submit all 10 tasks at once
    futures = [executor.submit(do_task, i) for i in range(15)]

    # Wait for all to complete (but printing already happened)
    for future in futures:
        if stop_now:
            break
        future.result()  # Just wait, no storing needed

print("\n✅ All tasks completed!")


# for i in range(15):
#     print(f"Processin task {i}")
