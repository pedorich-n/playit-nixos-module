import argparse
import json
import re
import signal
import sys
import time


def signal_handler(signal, frame):
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)


def main():
    parser = argparse.ArgumentParser("Mock playit-cli")
    parser.add_argument("--secret_wait", action="store_true", required=False)
    parser.add_argument("--secret_path", type=str, required=True)

    subparsers = parser.add_subparsers()
    run_subparser = subparsers.add_parser("run")
    run_subparser.add_argument("mapping_override", type=lambda s: re.split(",", s), nargs='?')

    args = parser.parse_args()
    args_dict = vars(args)

    with open("/var/lib/playit/result.json", "w") as file:
        json_object = json.dumps(args_dict, indent=4, sort_keys=True)
        file.write(json_object)

    while True:
        time.sleep(1)
