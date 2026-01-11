---
description: Git 操作经验总结和最佳实践
---

# Git 操作经验总结

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

## 最佳实践

### 推荐的 Git 操作流程

```
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
