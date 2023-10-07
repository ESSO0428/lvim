#!/bin/bash

# 解析傳入的參數
params=("$@")
new_params=()

for ((i=0; i<${#params[@]}; i++)); do
    if [[ ${params[i]} == "--mark-open-file" ]]; then
        # 检查前綴是否为 "--" 或 "-"
        if [[ ${params[i+1]} =~ ^-[^-].* ]] || [[ ${params[i+1]} =~ ^--.* ]]; then
            continue
        else
            i=$((i+1))
            continue
        fi
    fi
    new_params+=("${params[i]}")
done

# 執行 jupyter notebook 命令，並傳遞處理過的參數
jupyter notebook "${new_params[@]}"
