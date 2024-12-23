---
title: Copilot Chat Prompts Index
author: Andy6
date: Thursday, October, 10, 2024
---

# Copilot Chat Prompts Index

<!--toc:start-->
- [Copilot Chat Prompts Index](#copilot-chat-prompts-index)
  - [Explain](#explain)
  - [Ask](#ask)
  - [Review](#review)
  - [ReviewClear](#reviewclear)
  - [Fix](#fix)
  - [Optimize](#optimize)
  - [OneLineComment](#onelinecomment)
  - [OneParagraphComment](#oneparagraphcomment)
  - [Docs](#docs)
  - [Tests](#tests)
  - [CodeGraph](#codegraph)
  - [MermaidUml](#mermaiduml)
  - [MermaidSequence](#mermaidsequence)
  - [FixDiagnostic](#fixdiagnostic)
  - [Commit](#commit)
  - [CommitStaged](#commitstaged)
<!--toc:end-->

此附錄包含了配置 [lua/user/copilot.lua](../../lua/user/copilot.lua) 內的 `prompts` 所需的所有 `.md` 文件。

透過讀取這些 `md`，來配置 `CopiltChat` 提示詞。

## Explain

概述: 用於生成解釋選定代碼的提示。

見: [Explain.md](./Explain.md)

## Ask

概述: 用於生成詢問問題的提示。

見: [Ask.md](./Ask.md)

## Review

概述: 用於生成代碼審查的提示。

見: [Review.md](./Review.md)

## ReviewClear

概述: 用於清除代碼審查的提示。

見: [ReviewClear.md](./ReviewClear.md)

## Fix

概述: 用於生成修復代碼問題的提示。

見: [Fix.md](./Fix.md)

## Optimize

概述: 用於生成優化代碼的提示。

見: [Optimize.md](./Optimize.md)

## OneLineComment

概述: 用於生成單行註釋的提示。

見: [OneLineComment.md](./OneLineComment.md)

## OneParagraphComment

概述: 用於生成一段註釋的提示。

見: [OneParagraphComment.md](./OneParagraphComment.md)

## Docs

概述: 用於生成文件註釋的提示。

見: [Docs.md](./Docs.md)

## Tests

概述: 用於生成測試代碼的提示。

見: [Tests.md](./Tests.md)

## CodeGraph

概述: 
1. 類似 callgraph，但主要專注於當前檔案中變數和函數之間的關係，使用 mermaid 呈現結果。
2. 目前僅適用於 `Python`，用於其他語言效果未知。
3. 提示詞仍非完美，仍有改善 的空間。

見: [CodeGraph.md](./CodeGraph.md)

## MermaidUml

概述: 
1. 用於生成 UML 圖表，包括類圖、繼承關係、實現和依賴。
2. 使用 Mermaid 的 `classDiagram` 呈現結果。
3. 適用於展示靜態結構，側重於類之間的靜態關係。

見: [MermaidUml.md](./MermaidUml.md)

## MermaidSequence

概述: 
1. 用於生成序列圖，展示參與者之間的動態交互。
2. 使用 Mermaid 的 `sequenceDiagram` 呈現結果。
3. 適用於描述函數調用、消息流或用戶操作的執行過程。

見: [MermaidSequence.md](./MermaidSequence.md)

## FixDiagnostic

概述: 用於生成修復診斷問題的提示。

見: [FixDiagnostic.md](./FixDiagnostic.md)

## Commit

概述: 用於生成提交訊息的提示。

見: [Commit.md](./Commit.md)

## CommitStaged

概述: 用於生成已暫存變更的提交訊息提示。

見: [CommitStaged.md](./CommitStaged.md)

