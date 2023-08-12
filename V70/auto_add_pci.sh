#!/bin/bash

xlbin_name=xilinx_v70_gen5x8_qdma_base_2
json_file="global_config.json"

#######
##xilinx_addresses=($(lspci | grep "Xilinx Corporation" | awk '{print $1}'))
xilinx_addresses=($(xbutil examine | grep -i "$xlbin_name" | awk '{print $1}' | sed 's/\[//g; s/\]//g'))

# Conbin the Xilinx PCIe address to JSON form array
addresses_json=$(printf '"%s",' "${xilinx_addresses[@]}")
addresses_json="[${addresses_json%,}]"

# use jq to update JSON file
jq --argjson addresses "$addresses_json" '.global_config.cards = $addresses' "$json_file" > tmp.json
mv tmp.json "$json_file"

# Print out the json file
cat "$json_file" | jq
