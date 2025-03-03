#!/bin/bash
set -e

echo "Selected PyTorch variant: ${PYTORCH_VARIANT:-none}"

if [ -n "$PYTORCH_VARIANT" ]; then
  case "$PYTORCH_VARIANT" in
    cuda11)
      TORCH_PACKAGE="torch==2.0.1+cu117 torchvision==0.15.2+cu117 torchaudio==2.0.2 --extra-index-url https://download.pytorch.org/whl/cu117"
      echo "CUDA 11 variant selected; updating requirements.txt..."
      sed -i '/^torch/d' requirements.txt
      echo "$TORCH_PACKAGE" >> requirements.txt
      ;;
    cuda12)
      TORCH_PACKAGE="torch==2.0.1+cu12 torchvision==0.15.2+cu12 torchaudio==2.0.2 --extra-index-url https://download.pytorch.org/whl/cu12"
      echo "CUDA 12 variant selected; updating requirements.txt..."
      sed -i '/^torch/d' requirements.txt
      echo "$TORCH_PACKAGE" >> requirements.txt
      ;;
    amd)
      TORCH_PACKAGE="torch==2.0.1+rocm5.4 torchvision==0.15.2+rocm5.4 torchaudio==2.0.2 --extra-index-url https://download.pytorch.org/whl/rocm5.4"
      echo "AMD variant selected; updating requirements.txt..."
      sed -i '/^torch/d' requirements.txt
      echo "$TORCH_PACKAGE" >> requirements.txt
      ;;
    intel)
      echo "Intel variant selected; updating requirements.txt..."
      # For Intel, assume that the default torch version is acceptable.
      # Add the Intel Extension for PyTorch if it's not already present.
      if ! grep -q '^intel-extension-for-pytorch' requirements.txt; then
        echo "intel-extension-for-pytorch" >> requirements.txt
      fi
      ;;
    cpu)
      echo "CPU variant selected; leaving requirements.txt unchanged."
      ;;
    *)
      echo "Invalid PYTORCH_VARIANT: $PYTORCH_VARIANT"
      exit 1
      ;;
  esac
else
  echo "No PyTorch variant specified, leaving requirements.txt unchanged."
fi

# If arguments are passed, execute them.
if [ "$#" -gt 0 ]; then
  exec "$@"
fi
