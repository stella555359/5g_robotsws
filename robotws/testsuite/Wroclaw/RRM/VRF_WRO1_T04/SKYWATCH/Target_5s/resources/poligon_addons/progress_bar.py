import sys
import time


def format_time(seconds):
    """Konwertuje czas w sekundach na format HH:MM:SS lub MM:SS jeśli krótszy niż godzina."""
    hours, remainder = divmod(int(seconds), 3600)
    minutes, sec = divmod(remainder, 60)
    if hours > 0:
        return f"{hours:02d}:{minutes:02d}:{sec:02d}"
    else:
        return f"{minutes:02d}:{sec:02d}"


class ConsoleProgressBar:
    def __init__(self, total, length=30, desc="Progress"):
        self.total = total
        self.length = length
        self.desc = desc
        self.done = 0
        self.start_time = time.time()

    def update(self, n=1):
        self.done += n
        filled = int(self.length * self.done / self.total)
        bar = '#' * filled + '-' * (self.length - filled)
        percent = (self.done / self.total) * 100
        elapsed = time.time() - self.start_time
        elapsed_str = format_time(elapsed)
        # Wypisujemy pasek bezpośrednio do prawdziwego stdout (sys.__stdout__)
        sys.__stdout__.write(
            f"\r{self.desc}: [{bar}] {self.done}/{self.total} ({percent:6.2f}%) Elapsed: {elapsed_str}"
        )
        sys.__stdout__.flush()

    def close(self):
        elapsed_str = format_time(time.time() - self.start_time)
        sys.__stdout__.write(f"\nDone! Total time: {elapsed_str}\n")
        sys.__stdout__.flush()
