"""Tests for temperature converter — written from spec only."""

import sys
import os

# Add src/ to path so we can import converter
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))

from converter import celsius_to_fahrenheit, fahrenheit_to_celsius


def test_freezing_point_c_to_f():
    assert celsius_to_fahrenheit(0) == 32.0


def test_boiling_point_c_to_f():
    assert celsius_to_fahrenheit(100) == 212.0


def test_freezing_point_f_to_c():
    assert fahrenheit_to_celsius(32) == 0.0


def test_boiling_point_f_to_c():
    assert fahrenheit_to_celsius(212) == 100.0


def test_intersection_point():
    """Both scales read -40 at the same temperature."""
    assert celsius_to_fahrenheit(-40) == -40.0
    assert fahrenheit_to_celsius(-40) == -40.0


def test_body_temperature():
    assert celsius_to_fahrenheit(37) == 98.6


def test_negative_fahrenheit():
    result = fahrenheit_to_celsius(-4)
    assert result == -20.0


def test_fractional_input():
    result = celsius_to_fahrenheit(36.6)
    assert result == 97.88


def test_round_trip():
    """Converting C->F->C should return the original value."""
    original = 25.0
    converted = fahrenheit_to_celsius(celsius_to_fahrenheit(original))
    assert converted == original
