#!/bin/bash
set -e

echo "Selected PyTorch variant: ${PYTORCH_VARIANT:-none}"

if [ -n "$PYTORCH_VARIANT" ]; then
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

  # Remove any existing torch entry from requirements.txt and append the new one.
  sed -i '/^torch/d' requirements.txt
  echo "$TORCH_PACKAGE" >> requirements.txt

  # Install dependencies from requirements.txt
  pip install --no-cache-dir -r requirements.txt
else
  echo "No PyTorch variant specified, leaving requirements.txt unchanged."
fi

# If arguments are passed, execute them.
if [ "$#" -gt 0 ]; then
  exec "$@"
fi
