#!/bin/bash
set -e

echo "Selected PyTorch variant: $PYTORCH_VARIANT"

# Modify requirements.txt dynamically
case "$PYTORCH_VARIANT" in
    cuda11)
        TORCH_PACKAGE="torch==<CUDA11_VERSION>+cu11 torchvision torchaudio -f https://download.pytorch.org/whl/cu11/torch_stable.html"
        ;;
    cuda12)
        TORCH_PACKAGE="torch==<CUDA12_VERSION>+cu12 torchvision torchaudio -f https://download.pytorch.org/whl/cu12/torch_stable.html"
        ;;
    amd)
        TORCH_PACKAGE="torch==<AMD_VERSION> torchvision torchaudio -f https://download.pytorch.org/whl/rocm5.4/torch_stable.html"
        ;;
    intel)
        TORCH_PACKAGE="torch==<INTEL_VERSION>"
        ;;
    *)
        echo "Invalid PYTORCH_VARIANT: $PYTORCH_VARIANT"
        exit 1
        ;;
esac

# Remove any existing torch entry and add the correct one
sed -i '/^torch/d' requirements.txt
echo "$TORCH_PACKAGE" >> requirements.txt

# Install dependencies
pip install --no-cache-dir -r requirements.txt

# Execute the main command
exec "$@"
