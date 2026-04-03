#!/usr/bin/env bash
set -euo pipefail

# Source library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../packages/lib.sh"

log_info "[GIT] Configurando Git com delta e nvimdiff..."

# Configurações básicas do Git
git config --global core.editor "nvim"
git config --global core.pager "delta"
git config --global init.defaultBranch "main"

# Delta como diff viewer
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate "true"
git config --global delta.side-by-side "true"
git config --global delta.line-numbers "true"
git config --global delta.hyperlinks "true"
git config --global delta.file-style "bold yellow"
git config --global delta.plus-style "syntax #003800"
git config --global delta.minus-style "syntax #380000"
git config --global delta.hunk-header-style "omit"

# Merge tool
git config --global merge.conflictstyle "diff3"
git config --global merge.tool "nvimdiff"
git config --global mergetool.nvimdiff.layout "LOCAL,MERGED,REMOTE"
git config --global mergetool.keepBackup "false"
git config --global mergetool.prompt "false"

# Diff com coloração
git config --global diff.tool "nvim_difftool"
git config --global diff.colorMoved "default"
git config --global diff.renames "copies"
git config --global difftool.nvim_difftool.cmd "nvim -c \"packadd nvim.difftool\" -c \"DiffTool \$LOCAL \$REMOTE\""

# Rebase e Pull
git config --global pull.rebase "true"
git config --global rebase.autoStash "true"
git config --global rebase.autoSquash "true"
git config --global rebase.updateRefs "true"

log_success "[GIT] Configuração aplicada!"
log_info "[GIT] Configuração atual:"
echo ""
echo "=== Core ==="
git config --global --get core.editor && git config --global --get core.pager
echo ""
echo "=== Delta ==="
git config --global --get interactive.diffFilter && git config --global --get delta.navigate && git config --global --get delta.side-by-side
echo ""
echo "=== Merge Tool ==="
git config --global --get merge.tool && git config --global --get mergetool.nvimdiff.layout
echo ""
