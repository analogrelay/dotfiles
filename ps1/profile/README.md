# Profile scripts

Scripts in this directory must be named `[order].[name].ps1`. Scripts will be sorted by `[order]` (using proper integer sorting, NOT ascii-betical sorting, but still, doing two-digit padding is desired so the order is preserved when listing files). Scripts with the same `[order]` value are run in an undefined order.

All scripts are dot-sourced. Functions/aliases/etc. created in earlier scripts are available in later scripts.