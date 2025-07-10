# ComfyUI Community Edition

>**Disclaimer:** This service is provided by a third party. While we strive to ensure its security, accuracy, and reliability, we cannot guarantee it is completely free from failures, interruptions, errors, or attacks. Therefore, our company hereby declares: We make no representations, warranties, or commitments regarding the content, accuracy, completeness, reliability, applicability, and timeliness of this service, and assume no responsibility for any direct or indirect losses or damages arising from your use of this service; We assume no responsibility for the content, accuracy, completeness, reliability, applicability, and timeliness of third-party websites, applications, products, and services accessed through this service - you should bear the risks and responsibilities arising from their use; We assume no responsibility for any losses or damages arising from your use of this service, including but not limited to direct losses, indirect losses, profit losses, goodwill losses, data losses, or other economic losses, even if our company has been previously informed of the possibility of such losses or damages; We reserve the right to modify this disclaimer from time to time, so please check this disclaimer regularly before using this service. If you have any questions or concerns about this disclaimer or this service, please contact us.

## Overview

ComfyUI is the most powerful open-source node-based generative AI application, supporting the creation of images, videos, and audio content. Leveraging cutting-edge open-source models, it enables video and image generation.

According to the official documentation, ComfyUI features:

+ **Node/Graph/Flowchart Interface** - Experiment and create complex Stable Diffusion workflows without writing any code
+ **Full Support** for SD1.x, SD2.x, and SDXL
+ **Asynchronous Queue System**
+ **Multiple Optimizations** - Only re-executes parts of the workflow that changed between executions
+ **Command Line Options** - `--lowvram` enables running on GPUs with less than 3GB memory (automatically enabled on low-memory GPUs)
+ **CPU Support** - Works even without GPU using `--cpu` (slower)
+ **Model Loading** - Supports ckpt, safetensors, and diffusers models/checkpoints. Standalone VAE and CLIP models
+ **Embeddings/Textual Inversion**
+ **LoRAs** (regular, locon, and loha)
+ **Hypernetworks**
+ **Workflow Loading** - Load complete workflows from generated PNG files (including seeds)
+ **JSON Export/Import** - Save/load workflows as JSON files
+ **Complex Workflows** - Node interface for creating complex workflows like "Hires fix" or more advanced workflows
+ **Area Composition**
+ **Inpainting** - Using regular and inpainting models
+ **ControlNet and T2I Adapters**
+ **Upscaling Models** (ESRGAN, ESRGAN variants, SwinIR, Swin2SR, etc.)
+ **unCLIP Models**
+ **GLIGEN**
+ **Model Merging**
+ **Latent Previews** using TAESD
+ **Fast Startup**
+ **Fully Offline** - Downloads nothing
+ **Configuration Files** for setting model search paths

## Prerequisites

Deploying the ComfyUI Community Edition service instance requires access and creation permissions for certain Alibaba Cloud resources. Therefore, your account needs permissions for the following resources. **Note**: These permissions are only required when your account is a RAM account.

| **Permission Policy Name** | **Description** |
|---------------------------|-----------------|
| AliyunECSFullAccess | Permission to manage Elastic Compute Service (ECS) |
| AliyunVPCFullAccess | Permission to manage Virtual Private Cloud (VPC) |
| AliyunROSFullAccess | Permission to manage Resource Orchestration Service (ROS) |
| AliyunComputeNestUserFullAccess | User-side permission to manage Compute Nest Service |

## Billing Information

The costs for deploying the Community Edition on Compute Nest mainly include:

+ **Selected vCPU and memory specifications**
+ **System disk type and capacity**
+ **Public network bandwidth**

## Parameter Description

| **Parameter Group** | **Parameter** | **Description** |
|-------------------|---------------|-----------------|
| Service Instance | Service Instance Name | Maximum 64 characters, must start with an English letter, can include numbers, English letters, hyphens (-), and underscores (_) |
| | Region | Region where the service instance is deployed |
| | Payment Type | Billing type for resources: Pay-as-you-go and Subscription |
| ECS Instance Configuration | Instance Type | Available instance specifications in the availability zone |
| Network Configuration | Availability Zone | Availability zone where the ECS instance is located |
| | VPC ID | VPC where resources are located |
| | Switch ID | Switch where resources are located |

## Deployment Process

1. **Access Compute Nest** [deployment link](https://computenest.console.aliyun.com/service/instance/create/ap-southeast-1?type=user&ServiceId=service-11cf4eb33d1442ea8533) and fill in deployment parameters as prompted

2. **Fill in instance parameters** and select your desired purchase method and instance type
   ![img.png](img.png)

3. **Important Note**: If you want to use image-to-video functionality, to reduce the possibility of RAM overflow, please select memory specifications of 60GB or higher + A10 or higher GPU specifications

4. **Configure network settings** - Choose to create a new dedicated network or use an existing VPC. Fill in availability zone and network parameters
   ![img_1.png](img_1.png)

5. **Create instance** - Click "Create Now" and wait for service instance deployment to complete

6. **Access instance details** - After deployment completion, click the instance ID to enter the details interface
   ![img_2.png](img_2.png)

7. **Access service** - Visit the service instance's usage URL. We use secure proxy for direct access to prevent your data from being exposed to the public network
   ![Service Access](./img/serviceInstance3.png)

8. **Enter ComfyUI interface**
![img_3.png](img_3.png)

##  Switch ComfyUI's default language to English

1. Click the settings button in the image


![img_4.png](img_4.png)
2. Search for "Language" in the search box, then switch the option to English

![img_5.png](img_5.png)
3. Then the UI will automatically change.

## Usage Guide

### 📊 **Model Categories Overview**

| **Category** | **Directory** | **Total Size** | **Model Count** | **Primary Function** |
|--------------|---------------|----------------|-----------------|---------------------|
| Diffusion Models | `/diffusion_models` | 53GB | 6 models | Core image/video generation |
| Text Encoders | `/text_encoders` | 22GB | 2 models | Text understanding |
| CLIP Models | `/clip` | 17GB | 4 models | Vision-language understanding |
| Checkpoints | `/checkpoints` | 17GB | 1 model | Complete model checkpoints |
| UNET Models | `/unet` | 14GB | 1 model | Neural network architecture |
| VAE Models | `/vae` | 1.5GB | 5 models | Latent space processing |
| CLIP Vision | `/clip_vision` | 2.4GB | 1 model | Visual understanding |
| Face Restoration | `/facerestore_models` | 1.3GB | 4 models | Face enhancement |
| Video Interpolation | `/interpolation` | 824MB | 4 models | Frame interpolation |
| Content Safety | `/nsfw_detector` | 329MB | 1 model | Content moderation |
| Upscaling | `/upscale_models` | 192MB | 3 models | Image super-resolution |
| VAE Approximation | `/vae_approx` | 19MB | 4 models | Fast preview generation |
| Text Embeddings | `/embeddings` | 260KB | 2 models | Negative prompts |
| Configurations | `/configs` | 52KB | 11 files | Model configurations |

---

### 🎯 **Diffusion Models** (`/diffusion_models`) - 53GB

| **Model Name** | **Size** | **Type** | **Parameters** | **Function** | **Best For** |
|----------------|----------|----------|----------------|--------------|--------------|
| `Wan2_1-I2V-14B-480P_fp8_e4m3fn.safetensors` | 16GB | Image→Video | 14B | Animate static images | Image animation |
| `Wan2_1-T2V-14B_fp8_e4m3fn.safetensors` | 14GB | Text→Video | 14B | Generate videos from text | Text-to-video |
| `flux1-dev.safetensors` | 12GB | Text→Image | - | Experimental image generation | Testing new features |
| `wan21_vace_1_3b.safetensors` | 6.7GB | Video Editing | 1.3B | Enhanced video editing | Professional editing |
| `wan2.1/Wan2_1-T2V-1_3B_fp8_e4m3fn.safetensors` | 1.4GB | Text→Video | 1.3B | Fast video generation | Quick previews |

---

### 🧠 **Text Encoders** (`/text_encoders`) - 22GB

| **Model Name** | **Size** | **Format** | **Precision** | **Function** | **Best For** |
|----------------|----------|------------|---------------|--------------|--------------|
| `wan2.1/umt5-xxl-enc-bf16.safetensors` | 11GB | SafeTensors | BF16 | Multi-language text encoding | High-quality generation |
| `wan2.1/models_t5_umt5-xxl-enc-bf16.pth` | 11GB | PyTorch | BF16 | T5-based text encoding | PyTorch workflows |

---

### 🎨 **CLIP Models** (`/clip`) - 17GB

| **Model Name** | **Size** | **Type** | **Precision** | **Function** | **Best For** |
|----------------|----------|----------|---------------|--------------|--------------|
| `t5xxl_fp16.safetensors` | 9.2GB | T5 Text Encoder | FP16 | Advanced text understanding | Complex prompts |
| `umt5_xxl_fp8_e4m3fn.safetensors` | 6.3GB | UMT5 Encoder | FP8 | Efficient text encoding | Resource optimization |
| `wan2.1/open-clip-xlm-roberta-large-vit-huge-14_visual_fp16.safetensors` | 1.2GB | Multilingual CLIP | FP16 | Cross-language vision | International content |
| `clip_l.safetensors` | 235MB | CLIP Language | - | Vision-language alignment | Standard workflows |

---

### 💾 **Checkpoints** (`/checkpoints`) - 17GB

| **Model Name** | **Size** | **Type** | **Precision** | **Function** | **Best For** |
|----------------|----------|----------|---------------|--------------|--------------|
| `flux1-schnell-fp8.safetensors` | 17GB | Fast Image Gen | FP8 | Rapid image generation | Production workflows |

---

### 🔧 **UNET Models** (`/unet`) - 14GB

| **Model Name** | **Size** | **Type** | **Quantization** | **Function** | **Best For** |
|----------------|----------|----------|------------------|--------------|--------------|
| `Wan2.1_14B_VACE-Q6_K.gguf` | 14GB | Video Editing | Q6_K | Professional video editing | High-quality editing |

---

### 🔄 **VAE Models** (`/vae`) - 1.5GB

| **Model Name** | **Size** | **Type** | **Precision** | **Function** | **Best For** |
|----------------|----------|----------|---------------|--------------|--------------|
| `ae.safetensors` | 320MB | Standard VAE | - | Basic latent processing | General use |
| `vae-ft-mse-840000-ema-pruned.safetensors` | 320MB | Fine-tuned VAE | - | High-quality reconstruction | Quality workflows |
| `diffusion_pytorch_model.safetensors` | 320MB | Standard VAE | - | Broad compatibility | General compatibility |
| `wan2.1/Wan2_1_VAE_bf16.safetensors` | 243MB | Wan2.1 VAE | BF16 | Video-optimized processing | Video generation |
| `wan21_vace_vae.safetensors` | 243MB | VACE VAE | - | Video editing processing | Video editing |

---

### 👁️ **CLIP Vision Models** (`/clip_vision`) - 2.4GB

| **Model Name** | **Size** | **Architecture** | **Training Data** | **Function** | **Best For** |
|----------------|----------|------------------|-------------------|--------------|--------------|
| `CLIP-ViT-H-14-laion2B-s32B-b79K.safetensors` | 2.4GB | ViT-Huge-14 | LAION-2B | Visual understanding | High-quality analysis |

---

### 🎬 **Video Interpolation Models** (`/interpolation`) - 824MB

#### GIMM-VFI Directory (`/interpolation/gimm-vfi` & `/interpolation/GIMM-VFI_safetensors`)

| **Model Name** | **Size** | **Type** | **Function** | **Best For** |
|----------------|----------|----------|--------------|--------------|
| `gimmvfi_f_arb_lpips_fp32.safetensors` | 117MB | Full VFI Model | Complete frame interpolation | Production workflows |
| `gimmvfi_r_arb_lpips_fp32.safetensors` | 76MB | Refinement Model | Frame quality enhancement | Quality improvement |
| `flowformer_sintel_fp32.safetensors` | 62MB | Motion Model | Advanced motion understanding | Complex motion |
| `raft-things_fp32.safetensors` | 21MB | Optical Flow | Motion estimation | Motion calculation |

---

### 🔍 **Face Restoration Models** (`/facerestore_models`) - 1.3GB

| **Model Name** | **Size** | **Type** | **Function** | **Best For** |
|----------------|----------|----------|--------------|--------------|
| `codeformer-v0.1.0.pth` | 360MB | CodeFormer | Advanced face enhancement | Professional portraits |
| `GFPGANv1.4.pth` | 333MB | GFPGAN v1.4 | Improved face restoration | High-quality restoration |
| `GFPGANv1.3.pth` | 333MB | GFPGAN v1.3 | Face restoration | General face enhancement |
| `GPEN-BFR-512.onnx` | 272MB | GPEN (ONNX) | Real-time face restoration | Fast processing |

---

### ⬆️ **Upscaling Models** (`/upscale_models`) - 192MB

| **Model Name** | **Size** | **Scale** | **Type** | **Function** | **Best For** |
|----------------|----------|-----------|----------|--------------|--------------|
| `8x_NMKD-Superscale_150000_G.pth` | 64MB | 8x | NMKD | Extreme upscaling | Maximum resolution |
| `4x_foolhardy_Remacri.pth` | 64MB | 4x | Enhanced ESRGAN | Sharp upscaling | General upscaling |
| `4x_NMKD-Siax_200k.pth` | 64MB | 4x | NMKD Siax | Alternative upscaling | Artistic enhancement |

---

### 🚫 **Content Safety Models** (`/nsfw_detector`) - 329MB

| **Model Name** | **Size** | **Architecture** | **Function** | **Best For** |
|----------------|----------|------------------|--------------|--------------|
| `vit-base-nsfw-detector/model.safetensors` | 329MB | ViT-Base | Content moderation | Safety filtering |

**Additional Files:**
- `config.json` - Model configuration
- `preprocessor_config.json` - Input preprocessing
- `confusion_matrix.png` - Performance metrics

---

### ⚡ **VAE Approximation Models** (`/vae_approx`) - 19MB

| **Model Name** | **Size** | **Target** | **Function** | **Best For** |
|----------------|----------|------------|--------------|--------------|
| `taef1_decoder.pth` | 4.8MB | SD3/FLUX | Fast preview for SD3/FLUX | Modern models |
| `taesd3_decoder.pth` | 4.8MB | SD3 | Fast preview for SD3 | SD3 workflows |
| `taesdxl_decoder.pth` | 4.7MB | SDXL | Fast preview for SDXL | SDXL workflows |
| `taesd_decoder.pth` | 4.7MB | SD1.5 | Fast preview for SD1.5 | SD1.5 workflows |

---



## Model Downloads

1. **Recommended source**: ModelScope (魔搭)
2. **Model storage path**: `/root/storage/models`

## Account Credentials

Default username and password:
- **Username**: admin
- **Password**: admin

## Frequently Asked Questions

1. **Missing node types**: If you encounter "node type does not exist" errors, install missing nodes through the manager and restart
   ![Issue 1](img/issue1.png)
   ![Issue 2](img/issue2.png)

---

*This documentation provides comprehensive guidance for deploying and using ComfyUI Community Edition on Alibaba Cloud's Compute Nest platform.*