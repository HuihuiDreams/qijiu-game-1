---
description: 项目开发过程中的经验总结、问题排查与最佳实践
---

# 经验教训与最佳实践总结

## 遇到的问题

### 1. git commit 命令长时间处于 RUNNING 状态

**现象**：

- 执行 `git commit -m "..."` 后，命令状态一直显示 `RUNNING`
- 等待 10-30 秒后仍未完成
- 有时候实际上已经完成，但状态查询未能正确返回

**可能原因**：

- Windows 系统上 Git 处理大文件（如 index.html 约 100KB）需要更长时间
- Git 可能配置了 GPG 签名，等待签名输入
- 文件编码转换（CRLF/LF）耗时
- 网络或磁盘 I/O 延迟

**解决方案**：

- 分步执行命令，避免使用 `&&` 连接多个 Git 命令
- 使用 `git status` 或 `git log -1` 验证操作是否成功
- 增加等待时间，但不要依赖 command_status 的返回状态

---

### 2. git push 显示 "Everything up-to-date"

**现象**：

- 执行 `git push` 返回 `Everything up-to-date`
- 但本地确实有新的更改

**可能原因**：

- 之前的 `git commit` 命令没有成功执行
- 更改没有被正确 staged（`git add` 未执行）
- 之前的后台命令仍在运行，文件被锁定

**解决方案**：

- 在 push 之前先执行 `git status` 确认状态
- 确保 `git add` 和 `git commit` 都成功完成后再 push
- 使用 `git log -1 --oneline` 确认最新提交

---

### 3. AI 模型思维死循环 (Thought Loops)

**现象**：

- 模型在思考过程中反复模拟操作指令，如反复生成 `(Action)`, `(view_file)`, `(Execute)` 等文本。
- 只有思考过程（Thinking），迟迟不发出实际的工具调用（Tool Call）。
- 最终因触发 Token 长度限制而报错。

**可能原因**：

- **过度规划/犹豫**：模型在确定行动前试图在思维中“演练”输出格式，导致陷入自我重复。
- **伪日志 (Pseudo-logging)**：在思考中使用了类似 `(Tool: name)` 或 `Action: command` 的格式，这与模型训练中的某些输出模式冲突，导致模型误以为任务已完成或陷入补全循环。

**解决方案**：

- **果断行动**：一旦决定了下一步操作，立即调用工具，**不要**在思考中详细描述工具调用的格式。
- **避免伪格式**：在 `<thought>` 块中，严禁使用 `(Action)`, `(Tool)`, `(Execute)` 等类似代码或日志的格式化文本。直接用自然语言描述意图（例如：“我将读取文件” 而不是 “(Action: read_file)”）。
- **立即执行**：不要试图在一次思考中罗列太多步骤的详细执行日志，一步一步来。

---

## 最佳实践

### 推荐的 Git 操作流程

```bash
# 步骤 1: 添加文件
git add <文件名>

# 步骤 2: 检查状态
git status

# 步骤 3: 提交（使用较长等待时间）
git commit -m "提交信息"

# 步骤 4: 验证提交
git log -1 --oneline

# 步骤 5: 推送
git push
```

### 命令执行建议

1. **分步执行**：不要用 `&&` 连接多个 Git 命令
   - ❌ `git add . && git commit -m "msg" && git push`
   - ✅ 分三步执行

2. **等待时间设置**：
   - `git add`: 2000-3000ms
   - `git commit`: 5000-10000ms（大文件可能需要更长）
   - `git push`: 10000ms

3. **状态验证**：
   - commit 后用 `git log -1` 验证
   - push 后检查返回信息是否包含 `->` 符号

4. **处理超时**：
   - 如果 command_status 返回 RUNNING，不要急于重试
   - 先用 `git status` 检查当前状态
   - 确认状态后再决定下一步操作

5. **避免死循环**：
   - 思考时使用自然语言，避免模拟工具调用的格式。
   - 不要犹豫，决定了就 Call Tool。

---

## 常见问题排查

| 问题 | 检查命令 | 解决方法 |
|------|----------|----------|
| 不确定是否有未提交的更改 | `git status` | 查看 "Changes not staged" |
| 不确定最新提交是什么 | `git log -1 --oneline` | 确认提交信息 |
| 不确定本地是否领先远程 | `git status` | 查看 "ahead of origin" |
| push 失败 | `git remote -v` | 确认远程仓库配置 |

---

## 更新日志

- 2026-01-11: 初次创建，记录 Git 操作问题和解决方案
- 2026-01-12: 新增“思维死循环”问题的排查与预防方案
