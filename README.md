# AWS System Manager Patch Manager

## Installation

Depending on your OS, select the installation method here: https://opentofu.org/docs/intro/install/

## Provision the infrastructure

1. Make necessary adjustment on the variables.
2. Run `tofu init` to initialize the modules and other necessary resources.
3. Run `tofu plan` to check what will be created/deleted.
4. Run `tofu apply` to apply the changes. Type `yes` when asked to proceed.

## Checking of Kernel

```bash
# Check Kernel Version
uname -r

# List installed and active kernel live patch
kpatch list

# List available kernel live patches for advisories
yum updateinfo list
```

## References

- [[AWS] Kernel Live Patching on AL2](https://docs.aws.amazon.com/linux/al2/ug/al2-live-patching.html)
