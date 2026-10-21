# 语音模型下载说明

语音资源并非都能通过 Ollama 获取，建议先完成 LLM 下载，再根据 Jetson 上的推理环境和授权要求选择：

- **ASR**：SenseVoiceSmall（FunAudioLLM/SenseVoiceSmall），用于中文语音识别。模型页面：https://huggingface.co/FunAudioLLM/SenseVoiceSmall
- **TTS**：Piper（rhasspy/piper-voices），从语音列表选择支持中文的声音并下载 `.onnx` 与配套 `.onnx.json`。项目：https://github.com/rhasspy/piper-voices
- **唤醒词**：openWakeWord，预训练唤醒词通常不是中文自定义“猫头鹰”；中文自定义唤醒词需要单独训练/适配。项目：https://github.com/dscripka/openWakeWord
- **更自然的中文 TTS**：CosyVoice，权重较大且安装依赖更复杂，建议后续单独部署。项目：https://github.com/FunAudioLLM/CosyVoice

建议将这些模型分别放到外置硬盘 `03_Speech_Models/` 下，先确认许可和所需推理环境。脚本不会悄悄下载未知版本或不匹配的权重。
