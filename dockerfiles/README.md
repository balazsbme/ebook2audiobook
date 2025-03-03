# Guide for Using the Docker Image for ebook2audiobook

## Overview
This guide explains how to use the Docker image for the `ebook2audiobook` project. It includes details on building, running, and selecting the appropriate PyTorch variant for different hardware configurations.

## Available PyTorch Variants
You can specify the PyTorch variant via the `PYTORCH_VARIANT` environment variable. Available options:

- **cuda11** – Use for systems with CUDA 11.
- **cuda12** – Use for systems with CUDA 12.
- **amd** – Use for AMD GPU support.
- **intel** – Use for Intel GPU/ROCm support.
- **cpu** (Optional) – Use for CPU-only installations (if a CPU-specific PyTorch wheel is available).

## Methods of Usage

### 1. Pre-Built, Tagged Images (Build-Time Selection)
This method involves building separate images for each variant, ensuring that the correct PyTorch version is pre-installed.

#### How It Works:
- A build argument (`PYTORCH_VARIANT`) determines which PyTorch variant gets installed.
- Each image is tagged accordingly (e.g., `cuda11`, `cuda12`, `amd`, `intel`, etc.).

#### Pros:
- Faster startup since the correct PyTorch wheel is already installed.
- Clear versioning and explicit control over each build.

#### Build Commands:
```sh
docker build --platform linux/amd64 -t athomasson2/ebook2audiobook:cuda11 --build-arg PYTORCH_VARIANT=cuda11 .
docker push athomasson2/ebook2audiobook:cuda11

docker build --platform linux/amd64 -t athomasson2/ebook2audiobook:cuda12 --build-arg PYTORCH_VARIANT=cuda12 .
docker push athomasson2/ebook2audiobook:cuda12

docker build --platform linux/amd64 -t athomasson2/ebook2audiobook:amd --build-arg PYTORCH_VARIANT=amd .
docker push athomasson2/ebook2audiobook:amd

docker build --platform linux/amd64 -t athomasson2/ebook2audiobook:intel --build-arg PYTORCH_VARIANT=intel .
docker push athomasson2/ebook2audiobook:intel
```

#### Usage:
To pull and run the appropriate image based on your hardware:
```sh
docker run -p 7860:7860 athomasson2/ebook2audiobook:cuda11
```

---

### 2. Unified Image with Runtime Selection
This method allows you to use a single image and select the PyTorch variant at runtime.

#### How It Works:
- The image includes an entrypoint script (`entrypoint.sh`) that modifies `requirements.txt` and installs the correct PyTorch package based on the `PYTORCH_VARIANT` environment variable.
- This allows flexibility in selecting the hardware variant at runtime.

#### Pros:
- One image supports multiple hardware configurations.
- Simplifies deployment if you want to decide the variant at runtime.

#### Cons:
- Extra installation step at startup, slightly increasing container startup time.

#### Build Command:
```sh
docker build --platform linux/amd64 -t athomasson2/ebook2audiobook:latest .
```

#### Usage:
You can run the container with the default or specify a variant:
```sh
# Default (cuda11)
docker run -p 7860:7860 athomasson2/ebook2audiobook:latest

# Override for CUDA 12
docker run -p 7860:7860 -e PYTORCH_VARIANT=cuda12 athomasson2/ebook2audiobook:latest

# Override for AMD GPU
docker run -p 7860:7860 -e PYTORCH_VARIANT=amd athomasson2/ebook2audiobook:latest

# Override for Intel GPU
docker run -p 7860:7860 -e PYTORCH_VARIANT=intel athomasson2/ebook2audiobook:latest

# Optional: Override to CPU-only (if supported)
docker run -p 7860:7860 -e PYTORCH_VARIANT=cpu athomasson2/ebook2audiobook:latest
```

---

### 3. Running the Entrypoint Script During Build
If you want the PyTorch variant to be installed during the build process (instead of at runtime), you can modify the Dockerfile to execute the entrypoint script.

#### Modify the Dockerfile:
```dockerfile
RUN chmod +x /entrypoint.sh && /entrypoint.sh
```
This ensures that `entrypoint.sh` updates `requirements.txt` and installs the correct PyTorch version before finalizing the image build.

---

## Auto-Detection and Docker Compose

### Auto-Detection:
- Containers are isolated from the host system, making auto-detecting GPU hardware challenging.
- The NVIDIA Container Toolkit can expose GPU details to the container, but determining the exact PyTorch version to install requires additional logic.
- A startup script could query `nvidia-smi` and install the appropriate version, but this approach adds complexity and may not support non-NVIDIA hardware well.

### Using Docker Compose:
Docker Compose does not auto-detect hardware but allows defining services with specific images or environment variables. Example `docker-compose.yml`:
```yaml
version: '3.8'
services:
  ebook2audiobook:
    image: athomasson2/ebook2audiobook:latest
    ports:
      - "7860:7860"
    environment:
      - PYTORCH_VARIANT=cuda12
```
This lets you specify the PyTorch variant in a structured way.

---

## Summary
| Method | Description | Pros | Cons |
|--------|-------------|------|------|
| **Pre-Built, Tagged Images** | Build separate images for each variant | Fast startup, explicit control | Requires multiple images |
| **Unified Image with Runtime Selection** | Install the correct PyTorch version at startup | One image for all variants | Slightly slower startup |
| **Entrypoint During Build** | Modify `requirements.txt` and install PyTorch at build time | Optimized image | Must predefine variant |

For most users, **pre-built images** are best for production, while **runtime selection** is best for flexibility.

---

This guide ensures that you understand all usage cases, how to build and run the container, and the available options for configuring PyTorch dynamically. If anything changes, update this guide accordingly!

