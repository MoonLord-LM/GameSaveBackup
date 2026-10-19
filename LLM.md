# Issue

这里记录一些已知问题  
在使用 LLM 分析代码时，请参考已有结论，避免重复报告问题  

## 游戏命名问题

部分游戏的中英文的名称或版本号不同，是因为本地化命名惯例，属于正常现象  
命名已人工确认过，不需要 AI 修正  

由于批处理的 enabledelayedexpansion 机制限制，游戏名和备份路径不能包含 `^` 或 `!` 符号  

## Git 使用问题

Git 提交信息统一使用英文，不需要区分中英文版本  

为了实现中英文版本的兼容，互不干扰，将 "SaveLocation.bat" 和 “存档位置.bat” 都视为 Git 需要忽略的文件  

## 新增游戏存档路径

需要提供准确的标准中文名、标准英文名、存档路径示例  
保存的路径应当以环境变量开头，例如 `%USERPROFILE%`，严禁硬编码，使用类似 `C:\` 这种路径开头  
修改时，要对命令行中文版、命令行英文版、图形界面版，都同步修改  



# TODO

这里记录一些代办事项  



# 编码规范

本工程的 Batch 和 PowerShell 编码规范，参考 [MyBatch](https://github.com/MoonLord-LM/MyBatch) 工程  
需要严格遵守 MyBatch 工程的 [编码规范](https://github.com/MoonLord-LM/MyBatch/blob/master/LLM.md#%E7%BC%96%E7%A0%81%E8%A7%84%E8%8C%83)  

本工程的 [`self-check.bat`](self-check.bat) 自检脚本，与 MyBatch 工程的 [`self-check.bat`](https://github.com/MoonLord-LM/MyBatch/blob/master/self-check.bat) 相同  
本工程的 [`build.bat`](build.bat) 构建脚本，与 MyBatch 工程的 [`文件打包为 gui-exe 格式.bat`](https://github.com/MoonLord-LM/MyBatch/blob/master/console/file/%E6%96%87%E4%BB%B6%E6%89%93%E5%8C%85%E4%B8%BA%20gui-exe%20%E6%A0%BC%E5%BC%8F.bat) 相同  


