# Prompt for LLM

This file is the prompt content for the LLM.  
Before making any operations, we must first load this file as basic instructions.  
Before making any operations, we must first review the README.md file to understand the entire project.  
Before making any operations, we must first review the coding standards in this file and follow them strictly.  
When calling PowerShell commands such as Get-Content, Set-Content, and Add-Content, explicitly add -Encoding utf8 to prevent garbled text.  
When reading and writing files, always use the latest version as the standard, no need to care about Git version management, the code has GitHub to fall back on, and will not be lost.  
When recording time, call PowerShell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'" to get accurate time.  
After completing operations, check common batch encoding issues, such as handling of special symbols.  
After completing operations, ensure that the Chinese and English versions of .json configuration files have accurate content and consistent ordering.  
After completing operations, ensure that the Chinese and English versions of .bat scripts have accurate logic and consistent translation.  
After completing operations, ensure that the Chinese and English versions of .md documentation files have accurate content and consistent translation.  
When there are no explicit instructions, perform a complete self-review of this project and only provide review results or modification suggestions.  
After each self-review, evaluate the status (✅/⚠️/⛔), summarize the conclusion in no more than 30 words, translate it into Chinese and English, and record it in the corresponding check result section of this file.  
Sort the self-check result entries by time in descending order, and keep only the latest entry for each LLM.  

## Coding Standards

The entire project's batch scripts, configuration files, etc., strictly use UTF-8 without BOM encoding with \r\n line endings.  
For .md files, prioritize the Chinese text as the source of truth and keep the English text aligned with it.  
For .md files, ensure that ordinary single-line text ends with 2 spaces to achieve line break effect.  
For code style, such as spacing, logging, etc., refer to existing code and try to maintain consistency.  
For batch scripts, prioritize code readability over performance optimization, using simple and easy-to-understand code to implement functionality, reducing comments.  
Excessive blank lines do not need to be removed.  

## Issues That Can Be Ignored

Some games have different names or version numbers in Chinese and English regions, which is a normal phenomenon and does not need correction.  
Due to the enabledelayedexpansion mechanism, game names and backup paths cannot contain the special symbols ^ or !, which is a known issue.  
Git commit messages should be unified in English, no need to differentiate between Chinese and English versions.  
To maintain compatibility between Chinese and English versions without interference, both Chinese and English versions of "SaveLocation.bat" should be treated as files to be ignored.  

## Self Check Result

| LLM Version | Time UTC+8 | Status | Conclusion |
| -- | -- | -- | -- |
| GPT-5.1 Cursor | 2026-03-09 11:29:16 | ✅ | Quick review, no major issues. |
| DeepSeek Chat | 2026-03-09 03:05:02 | ✅ | Fixed missing 2 trailing spaces in LLM.md, verified compliance. |
| Claude Haiku 4.5 | 2026-03-09 01:15:08 | ✅ | Reverted complex optimization, restored simple readable code per specification. |
| GPT-5 Codex | 2026-03-08 23:43:00 | ✅ | Keep Chinese and English instructions aligned line by line. |

# LLM 提示

本文档是给 LLM 使用的提示信息。  
在做任何操作前，需要先加载本文档作为基础指令。  
在做任何操作前，需要先查看 README.md 文件，理解整个工程。  
在做任何操作前，需要先查看本文档约定的编码规范，严格按规范执行。  
在调用 PowerShell 的 Get-Content、Set-Content、Add-Content 等命令时，必须显式添加 -Encoding utf8 参数，防止乱码。  
在读写文件时，始终以最新版本为准，不需要关心 Git 版本管理，代码有 GitHub 兜底，不会丢失。  
在记录时间时，调用 PowerShell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'" 获取准确的时间。  
做完操作之后，检查批处理常见编码问题，例如特殊符号处理。  
做完操作之后，注意检查中英文版本的 .json 配置文件是否内容准确，且顺序一致。  
做完操作之后，注意检查中英文版本的 .bat 脚本逻辑是否正确，且翻译一致。  
做完操作之后，注意检查中英文版本的 .md 说明文件是否内容准确，且翻译一致。  
当没有明确指令时，对本工程做完整的自检审查，给出审查结果或修改建议。  
每次自检审查后，评估状态（✅/⚠️/⛔），将结论简单概括不超过 30 字，翻译为对应语言，然后记录到本文件的自检结果对应位置。  
自检结果的条目按时间倒序排列，并且每个 LLM 只记录最新的一条。  

## 编码规范

整个工程的代码、配置、说明等各种文本文件，严格使用 UTF-8 without BOM 编码，\r\n 换行。  
处理 .md 文件时，优先以中文为准，如果有英文内容，需与中文保持一致。  
处理 .md 文件时，要保证普通单行文本的结尾要有 2 个空格，以实现换行效果。  
对于批处理脚本，代码易读优先于性能优化，优先使用简单易懂的代码实现功能，减少注释。  
批处理脚本的代码风格（如空格、日志等）参考现有代码，尽量保持一致。  
如果需要生成临时文件，使用 `%temp%\MyBatch_%random%_%random%_%random%_%random%.tmp` 这样的路径防止冲突，并且在脚本结束前做清理。  
尽量避免在 echo 命令中，使用英文的括号 ( ) 或中文的括号（）符号，避免干扰。  
判断上一条命令是否成功/失败，用 if errorlevel 0/1 的写法，比较简洁。  

示例代码：
```
@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion



:: 这一行是注释，对整个文件进行总结说明



echo 这里是代码正文
echo 注意开头的固定 3 行代码和结尾的固定 3 行代码
echo 开头、总结注释、代码主体、结尾，中间固定隔开 3 行
echo 文件末尾固定保留 1 个空行



echo.
pause
exit /b

```

## 可忽略问题

部分游戏的中英文的名称或版本号不同，是因为本地化命名惯例，属于正常现象，不需要修正。  
由于 enabledelayedexpansion 机制限制，游戏名和备份路径不能包含 ^ 或 !，这是已知问题。  
Git 提交信息统一使用英文，不区分中英文版本。  
为保持中英文版本兼容互不干扰，中英文版本的 "SaveLocation.bat" 都视为需忽略文件。  

## 自检结果

| LLM 版本 | 时间 UTC+8 | 状态 | 结论 |
| -- | -- | -- | -- |
| GPT-5.1 Cursor | 2026-03-09 11:29:16 | ✅ | 快速整体检查，未发现明显问题。 |
| DeepSeek Chat | 2026-03-09 03:05:02 | ✅ | 修复LLM.md缺少2尾随空格问题，已验证符合规范。 |
| Claude Haiku 4.5 | 2026-03-09 01:15:08 | ✅ | 回滚复杂优化，恢复简洁易读代码，符合规范。 |
| GPT-5 Codex | 2026-03-08 23:43:00 | ✅ | 保持中英文提示词逐条对齐。 |
