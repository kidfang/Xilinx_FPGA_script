##xilinx_addresses=($(lspci | grep "Xilinx Corporation" | awk '{print $1}'))
xlbin_name=xilinx_v70_gen5x8_qdma_base_2
xilinx_addresses=($(xbutil examine | grep -i "$xlbin_name" | awk '{print $1}' | sed 's/\[//g; s/\]//g'))
json_file="global_config.json"

# 將Xilinx PCIe地址合併成JSON格式的陣列字串
addresses_json=$(printf '"%s",' "${xilinx_addresses[@]}")
addresses_json="[${addresses_json%,}]"

# 使用jq工具來更新JSON檔案
jq --argjson addresses "$addresses_json" '.global_config.cards = $addresses' "$json_file" > tmp.json

mv tmp.json "$json_file"

cat "$json_file" | jq
