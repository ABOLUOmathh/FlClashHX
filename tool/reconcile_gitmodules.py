#!/usr/bin/env python3
import re
import subprocess
import sys

def main():
    try:
        up_gitmodules = subprocess.check_output(
            ['git', 'show', 'MERGE_HEAD:.gitmodules'], text=True
        )
    except Exception as e:
        print(f"ℹ️ Skip reconcile_gitmodules: {e}")
        return

    # 1. Keep core/Clash.Meta pointing to ABOLUOmathh/mihomo
    res = re.sub(
        r'(\[submodule\s+"core/Clash\.Meta"\][\s\S]*?url\s*=\s*)[^\n]+',
        r'\1https://github.com/ABOLUOmathh/mihomo.git',
        up_gitmodules,
    )
    res = re.sub(
        r'(\[submodule\s+"core/Clash\.Meta"\][\s\S]*?branch\s*=\s*)[^\n]+',
        r'\1FlClashHX',
        res,
    )

    # 2. Convert any ssh git@github.com: to https://github.com/
    res = re.sub(r'git@github\.com:', r'https://github.com/', res)

    with open('.gitmodules', 'w', encoding='utf-8') as f:
        f.write(res)
    print("✅ .gitmodules successfully reconciled for FlClashHX.")

if __name__ == '__main__':
    main()
