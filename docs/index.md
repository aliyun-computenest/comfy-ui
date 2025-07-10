# ComfyUI社区版

>**免责声明：**本服务由第三方提供，我们尽力确保其安全性、准确性和可靠性，但无法保证其完全免于故障、中断、错误或攻击。因此，本公司在此声明：对于本服务的内容、准确性、完整性、可靠性、适用性以及及时性不作任何陈述、保证或承诺，不对您使用本服务所产生的任何直接或间接的损失或损害承担任何责任；对于您通过本服务访问的第三方网站、应用程序、产品和服务，不对其内容、准确性、完整性、可靠性、适用性以及及时性承担任何责任，您应自行承担使用后果产生的风险和责任；对于因您使用本服务而产生的任何损失、损害，包括但不限于直接损失、间接损失、利润损失、商誉损失、数据损失或其他经济损失，不承担任何责任，即使本公司事先已被告知可能存在此类损失或损害的可能性；我们保留不时修改本声明的权利，因此请您在使用本服务前定期检查本声明。如果您对本声明或本服务存在任何问题或疑问，请联系我们。

## 概述
ComfyUI是 最强大的开源节点式生成式AI应用，支持创建图像、视频及音频内容。依托前沿开源模型可实现视频与图像生成。
依据官方文档，ComfyUI具有以下特点：
+ 节点/图形/流程图界面，用于实验和创建复杂的稳定扩散工作流程，无需编写任何代码。
+ 完全支持 SD1.x、SD2.x 和 SDXL
+ 异步队列系统
+ 多项优化 只重新执行工作流中在两次执行之间发生变化的部分。
+ 命令行选项：--lowvram 可使其在 3GB 内存以下的 GPU 上运行（在低内存的 GPU 上自动启用）
+ 即使没有 GPU 也能使用： --cpu（慢速）
+ 可加载 ckpt、safetensors 和 diffusers 模型/检查点。独立的 VAE 和 CLIP 模型。
+ 嵌入/文本反演
+ Loras （常规、locon 和 loha）
+ 超网络
+ 从生成的 PNG 文件加载完整的工作流（含种子
+ 以 Json 文件保存/加载工作流。
+ 节点界面可用于创建复杂的工作流程，如 "Hires fix "或更高级的工作流程。
+ 区域合成
+ 使用常规和内绘模型进行内绘。
+ 控制网络和 T2I 适配器
+ 升级模型（ESRGAN、ESRGAN 变体、SwinIR、Swin2SR 等）
+ unCLIP 模型
+ GLIGEN
+ 模型合并 
+ 使用 TAESD 进行潜伏预览 
+ 启动速度极快。 
+ 完全离线工作：不会下载任何东西。 
+ 配置文件可设置模型的搜索路径。

## 前提条件
<font style="color:rgb(51, 51, 51);">部署ComfyUI社区版服务实例，需要对部分阿里云资源进行访问和创建操作。因此您的账号需要包含如下资源的权限。</font><font style="color:rgb(51, 51, 51);"> </font>**<font style="color:rgb(51, 51, 51);">说明</font>**<font style="color:rgb(51, 51, 51);">：当您的账号是RAM账号时，才需要添加此权限。</font>

| <font style="color:rgb(51, 51, 51);">权限策略名称</font> | <font style="color:rgb(51, 51, 51);">备注</font> |
| --- | --- |
| <font style="color:rgb(51, 51, 51);">AliyunECSFullAccess</font> | <font style="color:rgb(51, 51, 51);">管理云服务器服务（ECS）的权限</font> |
| <font style="color:rgb(51, 51, 51);">AliyunVPCFullAccess</font> | <font style="color:rgb(51, 51, 51);">管理专有网络（VPC）的权限</font> |
| <font style="color:rgb(51, 51, 51);">AliyunROSFullAccess</font> | <font style="color:rgb(51, 51, 51);">管理资源编排服务（ROS）的权限</font> |
| <font style="color:rgb(51, 51, 51);">AliyunComputeNestUserFullAccess</font> | <font style="color:rgb(51, 51, 51);">管理计算巢服务（ComputeNest）的用户侧权限</font> |


## 计费说明
<font style="color:rgb(51, 51, 51);"> 社区版在计算巢部署的费用主要涉及：</font>

+ <font style="color:rgb(51, 51, 51);">所选vCPU与内存规格</font>
+ <font style="color:rgb(51, 51, 51);">系统盘类型及容量</font>
+ <font style="color:rgb(51, 51, 51);">公网带宽</font>


## 参数说明
| <font style="color:rgb(51, 51, 51);">参数组</font> | <font style="color:rgb(51, 51, 51);">参数项</font> | <font style="color:rgb(51, 51, 51);">说明</font> |
| --- | --- | --- |
| <font style="color:rgb(51, 51, 51);">服务实例</font> | <font style="color:rgb(51, 51, 51);">服务实例名称</font> | <font style="color:rgb(51, 51, 51);">长度不超过64个字符，必须以英文字母开头，可包含数字、英文字母、短划线（-）和下划线（_）</font> |
| | <font style="color:rgb(51, 51, 51);">地域</font> | <font style="color:rgb(51, 51, 51);">服务实例部署的地域</font> |
| | <font style="color:rgb(51, 51, 51);">付费类型</font> | <font style="color:rgb(51, 51, 51);">资源的计费类型：按量付费和包年包月</font> |
| <font style="color:rgb(51, 51, 51);">ECS实例配置</font> | <font style="color:rgb(51, 51, 51);">实例类型</font> | <font style="color:rgb(51, 51, 51);">可用区下可以使用的实例规格</font> |
| <font style="color:rgb(51, 51, 51);">网络配置</font> | <font style="color:rgb(51, 51, 51);">可用区</font> | <font style="color:rgb(51, 51, 51);">ECS实例所在可用区</font> |
| | <font style="color:rgb(51, 51, 51);">VPC ID</font> | <font style="color:rgb(51, 51, 51);">资源所在VPC</font> |
| | <font style="color:rgb(51, 51, 51);">交换机ID</font> | <font style="color:rgb(51, 51, 51);">资源所在交换机</font> |


## 部署流程
1. 访问计算巢 [部署链接](https://computenest.console.aliyun.com/service/instance/create/cn-hangzhou?type=user&ServiceName=Comfy-UI社区版)，按提示填写部署参数
2. 填写实例参数![](./img/param1.png)，选择你想购买的方式和实例类型。
3. **注意** 如果您想要使用图生视频功能，为了降低爆RAM内存的可能，请选择60G以上的内存规格+A10以上的显卡规格。
3. 根据需求选择新建专用网络或直接使用已有的专有网络。填写可用区和网络参数![](./img/param2.png)
5. 点击立即创建，等待服务实例部署完成![](./img/param3.png)
6. 服务实例部署完成后，点击实例ID进入到详情界面![](./img/serviceInstance2.png)
7. 访问服务实例的使用URL，这里我们采用安全代理直接访问。避免您的数据暴露到公网被别人获取![](./img/serviceInstance3.png)
8. 进入ComfyUI使用界面

## 使用流程
本服务已经内置了两个可以直接使用的工作流。其中涉及的插件和模型也已经准备好。
### 图生视频或文生视频功能
1. 在下图处选择想要的功能。建议只选择一种进行使用，避免爆内存。![img.png](img/option.png)
2. 按图中指引选择工作流侧栏，选择wans.json并打开。![img.png](img/app2.png)
3. 在此处选择示例图片或选择自己本机电脑上传。![img.png](img/app3.png)
4. 在TextEncode处填写描述词。上面部分是你想要生成的内容，下面部分是你不想要生成的内容。![img.png](img/prompt.png)
5. 在ImageClip Encode处可设置图片的分辨率和帧数。本模型最高可设置720*720。![img.png](img/definition.png)
6. 其余参数可参考官网：https://comfyui-wiki.com/zh/interface/node-options  或以下文档：https://github.com/kijai/ComfyUI-WanVideoWrapper/blob/main/readme.md

### 文生图功能
1. 工作流框处选择该工作流。![img.png](img/text2img.png)
2. 输入你想要的内容。![img.png](img/text2img2.png)
3. 这里可以输入一些比较搞怪的内容，比如我这里是关羽大战白雪公主。
4. 可以在此处设置图片的分辨率和图片的数量。如果想加快生产速度，可将batch_size设置为1.![img.png](img/text2img3.png)
5. 等待图片的生成。

### 图生图功能
访问模版，或自己导入工作流使用。![img2img.png](img%2Fimg2img.png)

## 模型下载
1. 推荐前往魔搭下载
2. 模型存储路径为：/root/storage/models

## 内置模型说明

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



## 账号密码
默认账号和密码为:
1. 账号：admin
2. 密码：admin

### 常见问题
1. 出现某个节点类型不存在，通过manager安装缺少的节点，并重启。![img_1.png](img/issue1.png)![img.png](img/issue2.png)