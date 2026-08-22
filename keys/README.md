# keys

Public material only. Private keys live in Bitwarden (items `personal` and
`hiveyard`) and are served by the Bitwarden SSH agent.

- `personal.pub`: GitHub lkaric, ssh + commit signing
- `hiveyard.pub`: GitHub mladenctrl, ssh + commit signing
- `allowed_signers`: lets `git log --show-signature` verify both locally
