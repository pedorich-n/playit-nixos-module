import argparse
import json
import re
import time


def main():
    parser = argparse.ArgumentParser("Mock playit-cli")
    parser.add_argument("--secret_path", type=str, required=True)

    subparsers = parser.add_subparsers()
    run_subparser = subparsers.add_parser("run")
    run_subparser.add_argument("mapping_override", type=lambda s: re.split(",", s), nargs='?')

    args = parser.parse_args()
    args_dict = vars(args)

    with open("/etc/playit-test/result.json", "w") as file:
        json_object = json.dumps(args_dict, indent=4, sort_keys=True)
        file.write(json_object)

    time.sleep(60)
