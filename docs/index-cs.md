---

# ComfyUI社区版 - 容器集群版本

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

部署ComfyUI社区版服务实例，需要对部分阿里云资源进行访问和创建操作。因此您的账号需要包含如下资源的权限。**说明**：当您的账号是RAM账号时，才需要添加此权限。

| 权限策略名称                          | 备注                         |
|---------------------------------|----------------------------|
| AliyunVPCFullAccess             | 管理专有网络（VPC）的权限             |
| AliyunROSFullAccess             | 管理资源编排服务（ROS）的权限           |
| AliyunCSFullAccess              | 管理容器服务（CS）的权限              |
| AliyunComputeNestUserFullAccess | 管理计算巢服务（ComputeNest）的用户侧权限 |
| AliyunOSSFullAccess             | 管理网络对象存储服务（OSS）的权限         |

## 计费说明

### 容器集群版本费用

计费方式：按量付费（小时）或包年包月
预估费用在创建实例时可实时看到。

## 整体架构

![acs-arch.png](acs-arch.png)

## 部署流程

### 容器集群版本部署

1. 单击[部署链接](https://computenest.console.aliyun.com/service/instance/create/cn-hangzhou?type=user&ServiceName=ComfyUI-ACS%E7%A4%BE%E5%8C%BA%E7%89%88)。根据界面提示填写参数，可以看到对应询价明细，确认参数后点击**下一步：确认订单**。
   ![img.png](acs%2Fimg.png)

2. 根据情况可选择已有的ACK和ACS集群，或者新建ACK或者新建ACS集群部署
3. 如选择新建ACS集群。可直接选择默认参数：![img_6.png](img_6.png)
4. 如选择新建ACK集群。需要选择worker节点。注意此处的节点需要和后续的显卡配置一直。比如选择A10节点则后续的GPU配置也应当选择A10![img_7.png](img_7.png)
5. 选择需要使用的模型和网络区配置。![img_8.png](img_8.png)
6. 点击**下一步：确认订单**后可以也看到价格预览，随后点击**立即部署**，等待部署完成。
   ![price.png](acs%2Fprice.png)

7. 等待部署完成后就可以开始使用服务。
   ![img_2.png](acs%2Fimg_2.png)

## 参数说明

| 参数组      | 参数项      | 说明                                                                                   |
|----------|----------|--------------------------------------------------------------------------------------|
| 服务实例     | 服务实例名称   | 长度不超过64个字符，必须以英文字母开头，可包含数字、英文字母、短划线（-）和下划线（_）                                   |
|          | 地域       | 服务实例部署的地域                                                                            |
|          | 付费类型     | 资源的计费类型：按量付费和包年包月                                                                    |
| 容器集群配置   | 集群规格     | 容器集群的节点规格配置                                                                          |
| 网络配置     | 可用区      | 容器集群所在可用区                                                                           |
|          | VPC ID   | 资源所在VPC                                                                             |
|          | 交换机ID    | 资源所在交换机                                                                              |

## 内置模型说明


### 主要模型概览

| 模型名称 | 类型 | 参数规模 | 主要功能 | 特色功能 | 适用场景 |
|---------|------|---------|----------|----------|----------|
| **WanX-2.1** | 多模态视频生成 | I2V-14B, T2V-14B, VACE-1.3B, I2V-1.3B | 图像到视频/文本到视频 | 支持多种参数规模，灵活配置 | 通用视频生成，适合不同性能需求 |
| **WanX-2.2** | 多模态视频生成 | I2V-14B, T2V-14B, TI2V-5B | 图像到视频/文本到视频 | 升级版本，性能优化 | 高质量视频生成 |
| **Qwen-Image** | 图像生成 | - | 文本到图像生成 | 阿里通义千问图像模型 | 中文理解优秀的图像生成 |
| **WanX-2.2 Fun Camera** | 视频生成 | - | 趣味相机效果 | 特殊视觉效果和滤镜 | 创意视频制作，娱乐应用 |
| **WanX-2.2 Fun Control** | 视频控制 | - | 视频生成控制 | 精确控制视频生成过程 | 专业视频制作，精细化控制 |
| **WanX-2.2 Fun Inpaint** | 视频修复 | - | 首尾帧修复 | 视频首尾帧智能补全 | 视频后期处理，内容修复 |
| **WanX-2.2 S2V** | 语音到视频 | - | 语音驱动视频生成 | 从语音生成对应视频 | 语音可视化，教育内容制作 |
| **HunyuanVideo** | 视频生成 | - | 混元视频生成 | 腾讯混元大模型视频版本 | 高质量视频内容创作 |
| **Qwen-Image-Edit** | 图像编辑 | - | 智能图像编辑 | 基于自然语言的图像编辑 | 图像后期处理，内容修改 |
| **Hunyuan3D-2.1** | 3D生成 | - | 3D模型生成 | 最新版本3D内容生成 | 3D建模，游戏开发 |
| **Hunyuan3D-2.0** | 3D生成 | - | 3D模型生成 | 3D内容创建 | 3D设计，虚拟现实 |
| **Flux1-dev** | 图像生成 | - | 开发者版图像生成 | 实验性功能，高度可定制 | 研发测试，功能验证 |
| **Flux1-Krea** | 图像生成 | - | 创意图像生成 | 艺术风格图像生成 | 艺术创作，设计工作 |
| **Flux1-kontext** | 图像生成 | - | 上下文感知图像生成 | 理解上下文的智能生成 | 连续内容创作，故事插图 |
| **HunyuanImage2.1** | 图像生成 | - | 混元图像生成2.1版 | 腾讯混元图像模型升级版 | 高质量图像生成，商业应用 |


### 如何上传自己的模型

1. 在计算巢控制台找到部署的服务实例，并切换Tab到资源界面，并找到所属产品为对象存储 OSS的资源，点击进入。![img_3.png](img_3.png)
2. 访问"文件列表"，在路径为/llm-model/model下为所有类型的模型。![img_4.png](img_4.png)
3. 可根据自己的需求上传模型，并重启comfyui客户端即可。![img_5.png](img_5.png)

## 使用流程

本服务已经内置了两个可以直接使用的工作流。其中涉及的插件和模型也已经准备好。
![img_1.png](img/workflows.png)

### 图生视频或文生视频功能

1. 在下图处选择想要的功能。建议只选择一种进行使用，避免爆内存。![img.png](img/option.png)
2. 按图中指引选择工作流侧栏，选择wanx-21.json并打开。![img.png](img/app2.png)
3. 在此处选择示例图片或选择自己本机电脑上传。![img.png](img/app3.png)
4. 在TextEncode处填写描述词。上面部分是你想要生成的内容，下面部分是你不想要生成的内容。![img.png](img/prompt.png)
5. 在ImageClip Encode处可设置图片的分辨率和帧数。本模型最高可设置720*720。![img.png](img/definition.png)
6. 其余参数可参考官网：https://comfyui-wiki.com/zh/interface/node-options  或以下文档：https://github.com/kijai/ComfyUI-WanVideoWrapper/blob/main/readme.md

PS：如果使用vace模型，可使用工作流vace.json作为参考
![img_9.png](img_9.png)

### 文生图功能

1. 工作流框处选择该工作流funny_pictures.json。![img.png](img/text2img.png)
2. 输入你想要的内容。![img.png](img/text2img2.png)
3. 这里可以输入一些比较搞怪的内容，比如我这里是关羽大战白雪公主。
4. 可以在此处设置图片的分辨率和图片的数量。如果想加快生产速度，可将batch_size设置为1.![img.png](img/text2img3.png)
5. 等待图片的生成。

### 图生图功能

访问模版，或自己导入工作流使用。![img2img.png](img%2Fimg2img.png)

## API调用

### API 端点概览

| 端点 | 方法 | 功能 | 说明 |
|------|------|------|------|
| `/queue` | GET | 获取队列状态 | 查看当前任务队列 |
| `/prompt` | POST | 提交工作流 | 执行生成任务 |
| `/history/{prompt_id}` | GET | 获取执行历史 | 查看任务执行结果 |
| `/upload/image` | POST | 上传图片 | 上传输入图片文件 |
| `/view` | GET | 下载输出文件 | 获取生成的结果文件 |

支持公网或者私网的API调用。
可参考一下代码实现一个API调用的脚本。

```python
import requests
import json
import time

def run_workflow_file(workflow_file, server="http://127.0.0.1:8188"):
    """运行本地工作流JSON文件"""

    # 加载工作流
    with open(workflow_file, 'r', encoding='utf-8') as f:
        workflow = json.load(f)

    # 提交
    response = requests.post(f"{server}/prompt", json={"prompt": workflow})
    prompt_id = response.json()['prompt_id']
    print(f"任务提交: {prompt_id}")

    # 等待完成
    while True:
        response = requests.get(f"{server}/history/{prompt_id}")
        history = response.json()
        if prompt_id in history:
            break
        print("等待中...")
        time.sleep(3)

    # 下载所有输出文件
    outputs = history[prompt_id]['outputs']
    for node_id, node_output in outputs.items():
        # 处理不同类型的输出
        for file_type in ['images', 'videos', 'gifs']:
            if file_type in node_output:
                for file_info in node_output[file_type]:
                    filename = file_info['filename']
                    file_url = f"{server}/view?filename={filename}&type=output"

                    response = requests.get(file_url)
                    with open(filename, 'wb') as f:
                        f.write(response.content)
                    print(f"已下载: {filename}")

# 使用示例
run_workflow_file("my_workflow.json")
```

其中本地工作流采用下图提供的方式来获取：
![img_6.png](acs%2Fimg_6.png)

由于Comfyui未提供官方的API文档，此处根据文生视频和图生视频提供两个完整的示例：关于如何使用API来调用工作流进行文生图或者文生视频等
访问：https://github.com/aliyun-computenest/comfyui-acs/
找到demo文件夹
![img_7.png](acs%2Fimg_7.png)

### 文生视频API方式

1. 打开text_to_video_workflow.json为定义的工作流，确认好模型。（里面默认定义的模型为14B的万相2.1文生视频模型）
2. 确认好Prompt和生成的分辨率等参数
3. 修改代码中server服务地址，由127.0.0.1到你的实际服务地址。![img_8.png](acs%2Fimg_8.png)
4. 本地执行python text_to_video_example.py，等待视频生成

### 图生视频API方式

1. 打开image_to_video_workflow.json为定义的工作流，确认好模型。（里面默认定义的模型为14B的万相2.1图生视频模型）
2. 确认好Prompt和生成的分辨率等参数
3. 修改代码中server服务地址，由127.0.0.1到你的实际服务地址。![img_8.png](acs%2Fimg_8.png)
4. 本地执行python image_to_video_example.py，等待视频生成

## 账号密码

默认账号和密码为:
1. 账号：admin
2. 密码：admin

## 常见问题

1. 出现某个节点类型不存在，通过manager安装缺少的节点，并重启。![img_1.png](img/issue1.png)![img.png](img/issue2.png)