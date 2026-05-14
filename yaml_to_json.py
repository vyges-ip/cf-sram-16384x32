#!/usr/bin/env python3
"""
Convert YAML metadata file to JSON format for IPM package.
Handles field mappings:
- status -> maturity (with capitalization)
- digital_supply_voltage -> supply_voltage (as array)
- date format conversion (DD-MM-YYYY -> MM-DD-YYYY)
"""

import yaml
import json
import sys
import os

def convert_yaml_to_json(yaml_file, json_file):
    """Convert YAML file to JSON with proper field mappings."""
    with open(yaml_file, 'r') as f:
        data = yaml.safe_load(f)
    
    info = data.get('info', {})
    
    # Convert status to maturity with proper capitalization
    if 'status' in info:
        status = info.pop('status')
        info['maturity'] = status.capitalize() if status else 'Verified'
    elif 'maturity' not in info:
        info['maturity'] = 'Verified'
    
    # Convert digital_supply_voltage to supply_voltage array
    if 'digital_supply_voltage' in info:
        voltage = info.pop('digital_supply_voltage')
        if voltage and str(voltage) != 'n/a':
            try:
                info['supply_voltage'] = [float(voltage)]
            except (ValueError, TypeError):
                info['supply_voltage'] = []
        else:
            info['supply_voltage'] = []
    elif 'supply_voltage' not in info:
        info['supply_voltage'] = []
    
    # Remove analog_supply_voltage if present (not in JSON format)
    if 'analog_supply_voltage' in info:
        info.pop('analog_supply_voltage')
    
    # Ensure license is empty string, not null
    if 'license' in info and info['license'] is None:
        info['license'] = ''
    
    # Ensure optional fields exist with defaults if not in YAML
    if 'cell_count' not in info:
        info['cell_count'] = ''
    if 'clock_freq_mhz' not in info:
        info['clock_freq_mhz'] = 100
    
    # Convert date format if needed (DD-MM-YYYY to MM-DD-YYYY)
    if 'date' in info:
        date_str = str(info['date'])
        if '-' in date_str:
            parts = date_str.split('-')
            if len(parts) == 3 and len(parts[0]) == 2:
                # Assume DD-MM-YYYY format, convert to MM-DD-YYYY
                info['date'] = '{}-{}-{}'.format(parts[1], parts[0], parts[2])
    
    json_data = {
        'info': info,
        'registers': data.get('registers', [])
    }
    
    with open(json_file, 'w') as f:
        json.dump(json_data, f, indent=4)
    
    print(f'{json_file} regenerated successfully from {yaml_file}')

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f'Usage: {sys.argv[0]} <yaml_file> <json_file>', file=sys.stderr)
        sys.exit(1)
    
    yaml_file = sys.argv[1]
    json_file = sys.argv[2]
    
    if not os.path.exists(yaml_file):
        print(f'Error: YAML file not found: {yaml_file}', file=sys.stderr)
        sys.exit(1)
    
    convert_yaml_to_json(yaml_file, json_file)

