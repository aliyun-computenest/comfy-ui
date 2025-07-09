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

## 部署架构
![](./img/deploy.png)

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

## 账号密码
默认账号和密码为:
1. 账号：admin
2. 密码：admin

### 常见问题
1. 出现某个节点类型不存在，通过manager安装缺少的节点，并重启。![img_1.png](img/issue1.png)![img.png](img/issue2.png)