# MP3压缩工具使用指南

## 安装状态

✅ FFmpeg 8.0.1 已成功安装

## 使用方法

### 基本用法

```powershell
.\compress-mp3.ps1 -InputFile "你的文件.mp3"
```

这将使用默认的中等质量(128kbps)压缩文件,输出为 `你的文件-compressed.mp3`

### 指定质量级别

```powershell
# 高质量 (192kbps) - 音质好,文件较大
.\compress-mp3.ps1 -InputFile "music.mp3" -Quality high

# 中等质量 (128kbps) - 默认,平衡音质和大小
.\compress-mp3.ps1 -InputFile "music.mp3" -Quality medium

# 低质量 (96kbps) - 适合语音或播客
.\compress-mp3.ps1 -InputFile "podcast.mp3" -Quality low

# 极低质量 (64kbps) - 文件最小,仅适合语音
.\compress-mp3.ps1 -InputFile "voice.mp3" -Quality verylow
```

### 转换为单声道(文件大小减半)

```powershell
.\compress-mp3.ps1 -InputFile "podcast.mp3" -Quality low -Mono
```

### 指定输出文件名

```powershell
.\compress-mp3.ps1 -InputFile "input.mp3" -OutputFile "output.mp3" -Quality medium
```

## 质量建议

| 用途 | 推荐质量 | 比特率 | 说明 |
|------|---------|--------|------|
| 音乐 | high | 192kbps | 接近CD音质 |
| 一般音乐 | medium | 128kbps | 大多数人听不出差异 |
| 播客/有声书 | low | 96kbps | 语音清晰 |
| 语音录音 | verylow + Mono | 64kbps | 最小文件 |

## 批量压缩

如果需要压缩文件夹中的所有MP3:

```powershell
Get-ChildItem *.mp3 | ForEach-Object {
    .\compress-mp3.ps1 -InputFile $_.FullName -Quality medium
}
```

## 注意事项

1. **重启PowerShell**: 首次安装FFmpeg后,需要重启PowerShell窗口才能使用
2. **执行策略**: 如果遇到脚本执行错误,运行:

   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **文件覆盖**: 如果输出文件已存在,会自动覆盖
4. **音质损失**: 压缩是有损的,无法恢复原始质量

## 快速测试

让我们测试一下(如果您有MP3文件的话):

```powershell
# 示例:压缩当前目录下的test.mp3
.\compress-mp3.ps1 -InputFile "test.mp3" -Quality medium
```
