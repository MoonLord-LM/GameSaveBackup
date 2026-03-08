# Prompt for LLM

This file is the prompt content for the LLM.  
Before making any operations, we must first load this file as basic instructions to avoid making partial modifications to the project.  
Before making any operations, we must first review the README.md file to understand the entire project.  
When calling PowerShell commands such as Get-Content, Set-Content, and Add-Content, explicitly add -Encoding utf8 to prevent garbled text.  
After completing operations, check common batch encoding issues, such as handling of special symbols.  
After completing operations, check for coding standard issues and apply fixes.  
After completing operations, ensure that the Chinese and English versions of .json configuration files have accurate content, consistent order, and are identical.  
After completing operations, ensure that the Chinese and English versions of .bat script code have accurate logic, consistent translation, and are identical.  
After completing operations, ensure that the Chinese and English versions of .md documentation files have accurate content, consistent translation, and are identical.  
When there are no explicit instructions, perform a complete review of this project and provide review results and modification suggestions, but do not modify files.  
After each complete review, summarize the result as a modification suggestion within 30 words and record it in the check result section of LLM.md.  
Translate check results into Chinese and English, sort by time in descending order, and keep only the latest one for each LLM.

## Coding Standards

The entire project's batch scripts, configuration files, etc., strictly use UTF-8 without BOM encoding with \r\n line endings.  
For code style, such as spacing, logging, etc., refer to existing code and try to maintain consistency.  
Prioritize using simple and easy-to-understand code to implement functionality, reducing comments.  
Excessive blank lines do not need to be removed.  

## Issues That Can Be Ignored

Some games have different names or version numbers in Chinese and English regions, which is a normal phenomenon and does not need correction.  
Due to the enabledelayedexpansion mechanism, game names and backup paths cannot contain the special symbols ^ or !, which is a known issue.  
Git commit messages should be unified in English, no need to differentiate between Chinese and English versions.  
To maintain compatibility between Chinese and English versions without interference, both Chinese and English versions of "SaveLocation.bat" should be treated as files to be ignored.  

## Check Result

| LLM+Version | Time (UTC+8) | Conclusion |
| -- | -- | -- |
| GPT-5 Codex | 2026-03-08 22:46 | Aligned LLM prompts and normalized batch CRLF after bilingual review |

# LLM 提示

本文档是给 LLM 使用的提示信息。  
在做任何操作前，需要先加载本文档作为基础指令，避免对工程做局部修改。  
在做任何操作前，需要先查看 README.md 文件，理解整个工程。  
在调用 PowerShell 的 Get-Content、Set-Content、Add-Content 等命令时，必须显式添加 -Encoding utf8 参数，防止乱码。  
做完操作之后，检查批处理常见编码问题，例如特殊符号处理。  
做完操作之后，检查是否符合本文档约定的编码规范，并执行修正。  
做完操作之后，注意检查中英文版本的 .json 配置文件是否内容正确，且顺序一致。  
做完操作之后，注意检查中英文版本的 .bat 脚本代码是否符合需求，且翻译一致。  
做完操作之后，注意检查中英文版本的 .md 说明文件是否内容准确，且翻译一致。  
当没有明确指令时，对本项目做完整审查，但只需要给出审查结果和修改建议，不直接修改除本文件之外的文件。  
每次完整审查后，将结果概括为不超过 30 字，并记录到 LLM.md 的结论部分。  
检查结果翻译中英文，按时间倒序排列，对于每个 LLM 只需保留最新的一条即可。

## 编码规范

整个项目的批处理脚本和配置文件等，严格使用 UTF-8 without BOM 编码，\r\n 换行。  
代码风格（如空格、日志等）参考现有代码，尽量保持一致。  
优先使用简单且易理解的代码实现功能，减少注释。  
多余的空行不需要删除。  

## 可忽略问题

部分游戏在中英文区名称或版本号不同属于正常现象，不需要修正。  
由于 enabledelayedexpansion 机制限制，游戏名和备份路径不能包含 ^ 或 !，这是已知问题。  
Git 提交信息统一使用英文，不区分中英文版本。  
为保持中英文版本兼容互不干扰，中英文版本的 "SaveLocation.bat" 都视为需忽略文件。  

## 自检结果

| LLM+版本 | 时间 (UTC+8) | 结论 |
| -- | -- | -- |
| GPT-5 Codex | 2026-03-08 22:46 | 对齐 LLM 提示并修复批处理 CRLF 行尾 |
