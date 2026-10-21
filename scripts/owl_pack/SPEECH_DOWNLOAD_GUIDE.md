# Speech model download guide

Not all speech assets come from Ollama. Finish LLM downloads first, then pick ASR/TTS by Jetson runtime and license:

- **ASR**: SenseVoiceSmall (FunAudioLLM/SenseVoiceSmall) for speech recognition. Model page: https://huggingface.co/FunAudioLLM/SenseVoiceSmall
- **TTS**: Piper (rhasspy/piper-voices) — pick a voice that supports your language and download `.onnx` plus matching `.onnx.json`. Project: https://github.com/rhasspy/piper-voices
- **Wake word**: openWakeWord — pretrained wake words are usually not a custom "Owl" phrase; custom wake words need separate training/adaptation. Project: https://github.com/dscripka/openWakeWord
- **Higher-quality TTS**: CosyVoice — larger weights and heavier deps; deploy later as a separate stack. Project: https://github.com/FunAudioLLM/CosyVoice

Place these under external disk `03_Speech_Models/` after checking licenses and required runtimes. Scripts will not silently pull unknown or mismatched weights.
