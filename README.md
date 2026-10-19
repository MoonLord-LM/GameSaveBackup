# GameSaveBackup

一个简单的文件备份工具，可用于游戏存档或其他用途。  

A simple file backup tool that can be used for game saves and other purposes.  

## [使用说明]

依赖 Git 运行，需要先安装 [`git`](https://git-scm.com/downloads)  

以下文件，任选其一，下载运行即可：  
命令行中文版：[`备份.bat`](https://github.com/MoonLord-LM/GameSaveBackup/blob/master/source/备份.bat)  
命令行英文版：[`Backup.bat`](https://github.com/MoonLord-LM/GameSaveBackup/blob/master/source/Backup.bat)  
图形界面 ps1 版：[`GameSaveBackup.ps1`](https://github.com/MoonLord-LM/GameSaveBackup/blob/master/source/GameSaveBackup.ps1)  
图形界面 exe 版：[`GameSaveBackup.exe`](https://github.com/MoonLord-LM/GameSaveBackup/blob/master/build/GameSaveBackup.exe)  

### 实现机制

双向同步：按本地文件与备份文件的最近修改时间，自动判断执行「备份」还是「还原」  
版本控制：每次产生备份文件变动，都会提交到本地 Git 仓库，可追溯历史  
文件安全：修改本地文件时，会先将旧文件删除到回收站，支持从回收站找回  
备份位置：所有备份数据统一存放在程序所在文件夹的 `Backup` 子文件夹内  

### 配置文件

配置文件路径：程序文件夹下的 `Backup/config.json`  
当文件不存在时，程序会使用内嵌的默认配置，并自动创建该文件  

格式示例如下：  

```json
[
  {
    "name": "艾尔登法环",
    "save": "%USERPROFILE%\\AppData\\Roaming\\EldenRing"
  },
  {
    "name": "缺氧",
    "save": "%USERPROFILE%\\Documents\\Klei\\OxygenNotIncluded",
    "ignore": [
      "%USERPROFILE%\\Documents\\Klei\\OxygenNotIncluded\\RetiredColonies"
    ]
  }
]
```

配置文件是一个 JSON 数组，每个 { } 元素代表一个需要备份的项目，多个元素用逗号分隔  
`name` 属性，游戏名称，同时也作为备份的子文件夹名使用，不能包含 Windows 文件名非法字符（`< > : " / \ \| ? *`）  
`save` 属性，存档所在路径，建议使用 `%USERPROFILE%` / `%PROGRAMDATA%` 等环境变量路径开头  
`ignore` 可选属性，排除路径数组，备份时需要排除的文件或文件夹  

### 默认配置

默认的备份配置如下：  

| 名称 | 备份路径 |
| --- | --- |
| 艾尔登法环 | `%USERPROFILE%\AppData\Roaming\EldenRing` |
| 幻兽帕鲁 | `%USERPROFILE%\AppData\Local\Pal\Saved\SaveGames` |
| 部落幸存者 | `%USERPROFILE%\AppData\LocalLow\SZSS INTERACTIVE\Settlement Survival` |
| 最后纪元 | `%USERPROFILE%\AppData\LocalLow\Eleventh Hour Games\Last Epoch` |
| 虐杀原形 | `%USERPROFILE%\Documents\Prototype` |
| 尼尔：机械纪元 | `%USERPROFILE%\Documents\My Games\NieR_Automata` |
| 真三国无双 8：帝国 | `%USERPROFILE%\Documents\KoeiTecmo\Dynasty Warriors 9 Empires` |
| 无双大蛇 3 | `%USERPROFILE%\Documents\KoeiTecmo\WARRIORS OROCHI 4` |
| 真三国无双 5 | `%USERPROFILE%\Documents\KOEI\Shin Sangokumusou 5` |
| 亿万僵尸 | `%USERPROFILE%\Documents\My Games\They Are Billions` |
| 星球基地 | `%USERPROFILE%\Documents\Planetbase` |
| 缺氧 | `%USERPROFILE%\Documents\Klei\OxygenNotIncluded` |
| 饥荒联机版 | `%USERPROFILE%\Documents\Klei\DoNotStarveTogether` |
| 博德之门 3 | `%USERPROFILE%\AppData\Local\Larian Studios\Baldur's Gate 3` |
| 三国志 8：重制版 | `%USERPROFILE%\Documents\KoeiTecmo\SAN8R` |
| 古墓丽影 10：崛起 | `%USERPROFILE%\Documents\CPY_SAVES\CPY\391220` |
| 古墓丽影 11：暗影 | `%USERPROFILE%\Documents\Shadow of the Tomb Raider` |
| 光与影：33 号远征队 | `%USERPROFILE%\AppData\Local\Sandfall\Saved` |
| 对马岛之魂 | `%USERPROFILE%\Documents\Ghost of Tsushima DIRECTOR'S CUT` |
| 纪念碑谷 | `%USERPROFILE%\AppData\LocalLow\ustwo games\Monument Valley` |
| 虫虫大作战 | `%PROGRAMDATA%\AlderGames\BugBits` |
| 棋弈无限：围棋 | `%USERPROFILE%\AppData\LocalLow\Studio Amateur\JustGo` |

## [代码结构]

```
GameSaveBackup/
├── source/
│   ├── 备份.bat                 # 中文命令行版
│   ├── Backup.bat               # 英文命令行版
│   └── GameSaveBackup.ps1       # 图形界面 ps1 版
├── build/
│   ├── build.bat                # 构建脚本
│   └── GameSaveBackup.exe       # 图形界面 exe 版
├── self-check.bat               # 自检脚本
├── LLM.md                       # 提示信息
└── README.md                    # 工程说明
```
