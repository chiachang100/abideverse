import json
import argparse
import sys

def main():
    parser = argparse.ArgumentParser(
        description="Sort a JSON array by a specific key."
    )

    parser.add_argument(
        "-i", "--input", required=True,
        help="Input JSON file"
    )
    parser.add_argument(
        "-o", "--output", required=True,
        help="Output JSON file"
    )
    parser.add_argument(
        "-k", "--key", required=True,
        help="Key to sort by"
    )
    parser.add_argument(
        "-s", "--sort", default="asc", choices=["asc", "desc"],
        help="Sort order: asc or desc (default: asc)"
    )

    args = parser.parse_args()

    try:
        with open(args.input, "r", encoding="utf-8") as f:
            data = json.load(f)

        if not isinstance(data, list):
            raise ValueError("JSON root must be an array/list.")

        reverse = args.sort == "desc"

        # Sort the list by key
        data.sort(key=lambda x: x.get(args.key), reverse=reverse)

        with open(args.output, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

        print(f"✔ Sorted JSON saved → {args.output}")

    except Exception as e:
        print(f"✘ Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
