"""Temperature converter — converts between Celsius and Fahrenheit."""

import argparse
import sys


def celsius_to_fahrenheit(celsius: float) -> float:
    """Convert Celsius to Fahrenheit. Result rounded to 2 decimal places."""
    return round(celsius * 9 / 5 + 32, 2)


def fahrenheit_to_celsius(fahrenheit: float) -> float:
    """Convert Fahrenheit to Celsius. Result rounded to 2 decimal places."""
    return round((fahrenheit - 32) * 5 / 9, 2)


def main() -> None:
    parser = argparse.ArgumentParser(description="Convert temperatures between Celsius and Fahrenheit")
    parser.add_argument("value", type=float, help="Temperature value to convert")
    parser.add_argument("--to", required=True, choices=["celsius", "fahrenheit"], dest="target", help="Target unit")

    args = parser.parse_args()

    if args.target == "fahrenheit":
        result = celsius_to_fahrenheit(args.value)
        print(f"{result:.2f} F")
    else:
        result = fahrenheit_to_celsius(args.value)
        print(f"{result:.2f} C")


if __name__ == "__main__":
    main()
