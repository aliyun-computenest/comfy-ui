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


| Model Name | Type | Parameter Scale | Main Function | Special Features | Use Cases |
|---------|------|---------|----------|----------|----------|
| **WanX-2.1** | Multimodal Video Generation | I2V-14B, T2V-14B, VACE-1.3B, I2V-1.3B | Image-to-Video/Text-to-Video | Supports multiple parameter scales, flexible configuration | General video generation, suitable for different performance requirements |
| **WanX-2.2** | Multimodal Video Generation | I2V-14B, T2V-14B, TI2V-5B | Image-to-Video/Text-to-Video | Upgraded version with performance optimization | High-quality video generation |
| **Qwen-Image** | Image Generation | - | Text-to-Image Generation | Alibaba Tongyi Qianwen image model | Image generation with excellent Chinese understanding |
| **WanX-2.2 Fun Camera** | Video Generation | - | Fun Camera Effects | Special visual effects and filters | Creative video production, entertainment applications |
| **WanX-2.2 Fun Control** | Video Control | - | Video Generation Control | Precise control of video generation process | Professional video production, fine-grained control |
| **WanX-2.2 Fun Inpaint** | Video Repair | - | First and Last Frame Repair | Intelligent completion of video first and last frames | Video post-processing, content repair |
| **WanX-2.2 S2V** | Speech-to-Video | - | Speech-Driven Video Generation | Generate corresponding videos from speech | Speech visualization, educational content creation |
| **HunyuanVideo** | Video Generation | - | Hunyuan Video Generation | Tencent Hunyuan large model video version | High-quality video content creation |
| **Qwen-Image-Edit** | Image Editing | - | Intelligent Image Editing | Natural language-based image editing | Image post-processing, content modification |
| **Hunyuan3D-2.1** | 3D Generation | - | 3D Model Generation | Latest version 3D content generation | 3D modeling, game development |
| **Hunyuan3D-2.0** | 3D Generation | - | 3D Model Generation | 3D content creation | 3D design, virtual reality |
| **Flux1-dev** | Image Generation | - | Developer Version Image Generation | Experimental features, highly customizable | R&D testing, feature validation |
| **Flux1-Krea** | Image Generation | - | Creative Image Generation | Artistic style image generation | Artistic creation, design work |
| **Flux1-kontext** | Image Generation | - | Context-Aware Image Generation | Context-understanding intelligent generation | Continuous content creation, story illustration |
| **HunyuanImage2.1** | Image Generation | - | Hunyuan Image Generation v2.1 | Tencent Hunyuan image model upgraded version | High-quality image generation, commercial applications |


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