# Prompt for LLM

This file is the prompt content for the LLM.  
Before making any operations, we must first load this file as basic instructions to avoid making partial modifications to the project.  
Before making any operations, we must first review the README.md file to understand the entire project.  
After completing operations, check common batch encoding issues, such as handling of special symbols.  
After completing operations, check for coding standard issues and apply fixes.  
After completing operations, ensure that the Chinese and English versions of .json configuration files have accurate content, consistent order, and are identical.  
After completing operations, ensure that the Chinese and English versions of .bat script code have accurate logic, consistent translation, and are identical.  
After completing operations, ensure that the Chinese and English versions of .md documentation files have accurate content, consistent translation, and are identical.  
When there are no explicit instructions, perform a complete review of this project and provide review results and modification suggestions.  

## Coding Standards

The entire project's batch scripts, configuration files, etc., strictly use UTF-8 without BOM encoding with \r\n line endings.  
For code style, such as spacing, logging, etc., refer to existing code and try to maintain consistency.  
Prioritize using simple and easy-to-understand code to implement functionality, reducing comments.  
Excessive blank lines do not need to be removed.  

## Issues That Can Be Ignored

Some games have different names in Chinese and English regions, which is a normal phenomenon and does not need correction.  
Due to the enabledelayedexpansion mechanism, game names and backup paths cannot contain the special symbols ^ or !, which is a known issue.  
Git commit messages should be unified in English, no need to differentiate between Chinese and English versions.  
To maintain compatibility between Chinese and English versions without interference, both Chinese and English versions of "SaveLocation.bat" should be treated as files to be ignored.  

# LLM 提示

本文件是给 LLM 使用的提示信息。  
在做任何操作前，需要先载入本文件作为基础的指令，避免对工程做局部修改。  
在做任何操作前，需要先查看 README.md 文件，理解整个工程。  
做完操作之后，检查批处理的常见编码错误，例如特殊符号的处理。  
做完操作之后，检查编码规范问题，并执行修改。  
做完操作之后，注意检查中英文版本的 .json 配置文件是否内容、顺序准确且一致。  
做完操作之后，注意检查中英文版本的 .bat 脚本代码是否逻辑、翻译准确且一致。  
做完操作之后，注意检查中英文版本的 .md 说明文件是否内容、翻译准确且一致。  
当没有明确指令时，对本项目做完整的审查，给出审查结果和修改建议。  

## 编码规范

整个项目的批处理脚本和配置文件等，严格使用 UTF-8 without BOM 编码，\r\n 的换行符。  
代码风格，例如空格、日志等，参考已有的代码，尽量保持一致。  
优先使用简单便于理解的代码来实现功能，减少注释。  
多余的空行不需要删除。  

## 可忽略问题

一些游戏在中文区和英文区的名称或版本号不同，是正常现象。  
由于使用变量的 enabledelayedexpansion 机制，游戏名称和备份路径中不能包含 ^ 或 ! 特殊符号，是已知问题。  
Git 的提交信息统一使用英文，不需要做中英文区分。  
为了保持中英文版本兼容，互不干扰，将中英文版本的 "存档位置.bat" 都视为需要忽略的文件。  
