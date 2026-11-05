#!/usr/bin/env python3
import re
import subprocess
import sys

def reconcile_gitmodules():
    try:
        up_gitmodules = subprocess.check_output(
            ['git', 'show', 'MERGE_HEAD:.gitmodules'], text=True
        )
    except Exception as e:
        print(f"ℹ️ Skip .gitmodules reconciliation: {e}")
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
    subprocess.run(['git', 'add', '.gitmodules'], check=False)
    print("✅ .gitmodules successfully reconciled and staged.")

def resolve_submodule_conflicts():
    try:
        unmerged = subprocess.check_output(['git', 'ls-files', '-u'], text=True)
    except Exception as e:
        print(f"ℹ️ Skip submodule conflict resolution: {e}")
        return

    for line in unmerged.splitlines():
        parts = line.split()
        if len(parts) >= 4 and parts[0] == '160000':
            path = parts[3]
            # For our custom core submodule, keep OURS (stage 2)
            # For other upstream submodules (e.g., plugins/prism_ui), take upstream (stage 3)
            target_stage = '2' if path == 'core/Clash.Meta' else '3'
            if parts[2] == target_stage:
                sha = parts[1]
                try:
                    subprocess.run(
                        ['git', 'update-index', '--cacheinfo', f'160000,{sha},{path}'],
                        check=True,
                    )
                    print(f"✅ Resolved submodule '{path}' to stage {target_stage} commit {sha}")
                except Exception as e:
                    print(f"⚠️ Failed to update index for submodule {path}: {e}")

def main():
    reconcile_gitmodules()
    resolve_submodule_conflicts()

if __name__ == '__main__':
    main()
