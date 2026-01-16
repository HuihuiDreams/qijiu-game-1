# 实施计划 - index.html 改进

> 📅 **开始日期**: ___________  
> 📅 **预计完成日期**: ___________  
> 👤 **执行人**: ___________

---

## 📊 进度总览

- [x] **第一阶段：高优先级修复** (3/3 完成) ✅
- [ ] **第二阶段：中优先级优化** (0/7 完成)
- [ ] **第三阶段：低优先级增强** (0/4 完成)

**总体进度**: 3/14 任务完成 (21%)

---

## 🔴 第一阶段：高优先级修复

### 任务 1: 修复 localStorage 错误处理 ✅

**目标**: 为所有 localStorage 操作添加完善的错误处理

#### 步骤 1.1: 创建 Storage 工具模块

- [ ] 在 `<script type="module">` 开始处（约第370行后）添加 Storage 工具对象
- [ ] 实现 `Storage.set(key, value)` 方法，包含 try-catch
- [ ] 实现 `Storage.get(key, defaultValue)` 方法，包含 try-catch
- [ ] 添加 `QuotaExceededError` 处理逻辑（自动清理最旧存档）
- [ ] 添加 `SecurityError` 处理（隐私模式检测）
- [ ] 添加错误日志记录

**代码位置**: 在 `const html = htm.bind(h);` 之后（约第378行）

**参考代码**:

```javascript
const Storage = {
    set: (key, value) => {
        try {
            localStorage.setItem(key, JSON.stringify(value));
            return { success: true };
        } catch (e) {
            if (e.name === 'QuotaExceededError') {
                // 清理最旧的存档
                const keys = Object.keys(localStorage)
                    .filter(k => k.startsWith('qijiu_save_slot_'))
                    .map(k => ({
                        key: k,
                        data: JSON.parse(localStorage.getItem(k))
                    }))
                    .sort((a, b) => (a.data.timestamp || 0) - (b.data.timestamp || 0));
                if (keys.length > 0) {
                    localStorage.removeItem(keys[0].key);
                    return Storage.set(key, value); // 重试
                }
            }
            console.error('Storage error:', e);
            return { success: false, error: e.name };
        }
    },
    get: (key, defaultValue = null) => {
        try {
            const item = localStorage.getItem(key);
            return item ? JSON.parse(item) : defaultValue;
        } catch (e) {
            console.error('Storage read error:', e);
            return defaultValue;
        }
    },
    remove: (key) => {
        try {
            localStorage.removeItem(key);
            return true;
        } catch (e) {
            console.error('Storage remove error:', e);
            return false;
        }
    }
};
```

#### 步骤 1.2: 替换所有 localStorage.setItem 调用

- [ ] 替换第1234行：`readTextIds` 初始化
- [ ] 替换第1245行：`unlockedEndings` 初始化
- [ ] 替换第1256行：`unlockedChapters` 初始化
- [ ] 替换第1269行：`loadSettings` 函数
- [ ] 替换第1277行：`handleTextSpeedChange` 函数
- [ ] 替换第1341行：章节解锁保存
- [ ] 替换第1452行：自动存档
- [ ] 替换第1485行：手动存档
- [ ] 替换第1532行：已读文本记录保存
- [ ] 替换第1652行：结局解锁保存

**查找模式**: 搜索 `localStorage.setItem`，共约 10 处需要替换

**替换示例**:

```javascript
// 旧代码
localStorage.setItem(READ_TEXT_KEY, JSON.stringify([...newReadTextIds]));

// 新代码
const result = Storage.set(READ_TEXT_KEY, [...newReadTextIds]);
if (!result.success) {
    console.warn('保存已读记录失败');
}
```

#### 步骤 1.3: 替换所有 localStorage.getItem 调用

- [ ] 替换第1234行：`readTextIds` 初始化
- [ ] 替换第1245行：`unlockedEndings` 初始化
- [ ] 替换第1256行：`unlockedChapters` 初始化
- [ ] 替换第1269行：`loadSettings` 函数
- [ ] 替换第1465行：`getAllSaves` 函数
- [ ] 替换第1472行：`handleSaveSlot` 函数
- [ ] 替换第1492行：`handleLoadSlot` 函数
- [ ] 替换第1514行：`loadAutoSave` 函数
- [ ] 替换第1629行：`hasAutoSave` 检查

**查找模式**: 搜索 `localStorage.getItem`，共约 9 处需要替换

**替换示例**:

```javascript
// 旧代码
const saved = localStorage.getItem(READ_TEXT_KEY);
return saved ? new Set(JSON.parse(saved)) : new Set();

// 新代码
const saved = Storage.get(READ_TEXT_KEY);
return saved ? new Set(saved) : new Set();
```

#### 步骤 1.4: 替换 localStorage.removeItem 调用

- [ ] 替换第1508行：`handleDeleteSlot` 函数

**替换示例**:

```javascript
// 旧代码
localStorage.removeItem(`${SAVE_SLOT_PREFIX}${slotId}`);

// 新代码
Storage.remove(`${SAVE_SLOT_PREFIX}${slotId}`);
```

#### 步骤 1.5: 测试验证

- [ ] 测试正常保存/读取功能
- [ ] 测试存储空间不足时的自动清理
- [ ] 测试隐私模式下的降级处理
- [ ] 检查控制台无错误

---

### 任务 2: 替换原生 alert/confirm 为自定义组件 ✅

**目标**: 创建统一风格的自定义对话框组件

#### 步骤 2.1: 创建 AlertDialog 组件

- [ ] 在组件定义区域（约第660行后，Icon 组件之后）添加 `AlertDialog` 组件
- [ ] 实现消息显示
- [ ] 实现确认按钮
- [ ] 添加淡入淡出动画
- [ ] 添加 ESC 键关闭支持

**代码位置**: 在 `const Icons = {...}` 之后（约第680行）

**参考代码**:

```javascript
const AlertDialog = ({ message, onClose }) => html`
    <div class="fixed inset-0 z-[100] bg-black/80 backdrop-blur flex items-center justify-center animate-in fade-in duration-300" onClick=${onClose}>
        <div class="bg-slate-900 border border-slate-700 p-6 md:p-8 rounded-xl shadow-2xl max-w-md w-[90%] animate-in zoom-in duration-300" onClick=${e => e.stopPropagation()}>
            <p class="text-slate-200 mb-6 font-serif-sc text-base md:text-lg leading-relaxed">${message}</p>
            <div class="flex justify-end">
                <button onClick=${onClose} class="px-6 py-2 bg-cyan-600 hover:bg-cyan-700 rounded transition-colors font-bold">
                    确定
                </button>
            </div>
        </div>
    </div>
`;
```

#### 步骤 2.2: 创建 ConfirmDialog 组件

- [ ] 在 `AlertDialog` 之后添加 `ConfirmDialog` 组件
- [ ] 实现消息显示
- [ ] 实现确认和取消按钮
- [ ] 添加键盘支持（Enter 确认，ESC 取消）

**参考代码**:

```javascript
const ConfirmDialog = ({ message, onConfirm, onCancel }) => {
    useEffect(() => {
        const handleKeyDown = (e) => {
            if (e.key === 'Escape') onCancel();
            if (e.key === 'Enter') onConfirm();
        };
        document.addEventListener('keydown', handleKeyDown);
        return () => document.removeEventListener('keydown', handleKeyDown);
    }, []);

    return html`
        <div class="fixed inset-0 z-[100] bg-black/80 backdrop-blur flex items-center justify-center animate-in fade-in duration-300" onClick=${onCancel}>
            <div class="bg-slate-900 border border-slate-700 p-6 md:p-8 rounded-xl shadow-2xl max-w-md w-[90%] animate-in zoom-in duration-300" onClick=${e => e.stopPropagation()}>
                <p class="text-slate-200 mb-6 font-serif-sc text-base md:text-lg leading-relaxed">${message}</p>
                <div class="flex gap-4 justify-end">
                    <button onClick=${onCancel} class="px-6 py-2 bg-slate-800 hover:bg-slate-700 rounded transition-colors font-bold">
                        取消
                    </button>
                    <button onClick=${onConfirm} class="px-6 py-2 bg-cyan-600 hover:bg-cyan-700 rounded transition-colors font-bold">
                        确认
                    </button>
                </div>
            </div>
        </div>
    `;
};
```

#### 步骤 2.3: 添加对话框状态管理

- [ ] 在 `App` 组件中添加 `dialogState` 状态
- [ ] 添加 `showAlert(message)` 函数
- [ ] 添加 `showConfirm(message, onConfirm, onCancel)` 函数

**代码位置**: 在 `App` 组件的状态定义区域（约第1207行）

**参考代码**:

```javascript
const [dialogState, setDialogState] = useState(null);

const showAlert = (message) => {
    return new Promise((resolve) => {
        setDialogState({ type: 'alert', message, onClose: () => {
            setDialogState(null);
            resolve();
        }});
    });
};

const showConfirm = (message) => {
    return new Promise((resolve) => {
        setDialogState({
            type: 'confirm',
            message,
            onConfirm: () => {
                setDialogState(null);
                resolve(true);
            },
            onCancel: () => {
                setDialogState(null);
                resolve(false);
            }
        });
    });
};
```

#### 步骤 2.4: 在 render 中添加对话框渲染

- [ ] 在 `App` 组件的 return 语句末尾添加对话框条件渲染

**代码位置**: 在 `</div>` 结束标签之前（约第1828行）

**参考代码**:

```javascript
${dialogState && dialogState.type === 'alert' && html`
    <${AlertDialog} message=${dialogState.message} onClose=${dialogState.onClose} />
`}
${dialogState && dialogState.type === 'confirm' && html`
    <${ConfirmDialog} 
        message=${dialogState.message} 
        onConfirm=${dialogState.onConfirm}
        onCancel=${dialogState.onCancel}
    />
`}
```

#### 步骤 2.5: 替换所有 alert() 调用

- [ ] 替换第1487行：存档成功提示
- [ ] 替换第1518行：没有自动存档提示
- [ ] 替换第1726行：快进限制提示

**替换示例**:

```javascript
// 旧代码
alert(`存档 ${slotId} 保存成功！`);

// 新代码
await showAlert(`存档 ${slotId} 保存成功！`);
```

#### 步骤 2.6: 替换所有 confirm() 调用

- [ ] 替换第1478行：存档确认
- [ ] 替换第1494行：读档确认
- [ ] 替换第1507行：删除确认

**替换示例**:

```javascript
// 旧代码
if (window.confirm(promptMsg)) {
    // ...
}

// 新代码
const confirmed = await showConfirm(promptMsg);
if (confirmed) {
    // ...
}
```

**注意**: 需要将包含这些调用的函数改为 `async` 函数

#### 步骤 2.7: 测试验证

- [ ] 测试所有对话框显示正常
- [ ] 测试键盘快捷键（Enter, ESC）
- [ ] 测试移动端触摸交互
- [ ] 检查样式与游戏主题一致

---

### 任务 3: 锁定外部资源版本 ✅

**目标**: 确保外部依赖的版本稳定性和可用性

#### 步骤 3.1: 锁定 Tailwind CSS 版本

- [ ] 查找 Tailwind CDN 链接（第25行）
- [ ] 添加版本参数或使用固定版本 URL
- [ ] 或者下载 Tailwind CSS 到本地

**当前代码**: `<script src="https://cdn.tailwindcss.com"></script>`

**选项 A - 添加版本**:

```html
<script src="https://cdn.tailwindcss.com@3.4.0"></script>
```

**选项 B - 本地化** (推荐):

- [ ] 下载 Tailwind CSS 3.4.0
- [ ] 保存为 `css/tailwind.min.css`
- [ ] 修改为 `<link rel="stylesheet" href="./css/tailwind.min.css">`

#### 步骤 3.2: 锁定字体服务版本

- [ ] 查找字体导入（第27行）
- [ ] 考虑使用本地字体文件或备用字体服务

**当前代码**: `@import url('https://fonts.loli.net/css2?family=...')`

**选项 A - 添加备用字体**:

```css
@import url('https://fonts.loli.net/css2?family=...');
/* 备用字体 */
@font-face {
    font-family: 'Inter';
    src: local('Inter'), local('Arial');
}
```

**选项 B - 本地化字体** (推荐):

- [ ] 下载字体文件到 `fonts/` 目录
- [ ] 使用 `@font-face` 定义本地字体

#### 步骤 3.3: 锁定 Preact 和 htm 版本

- [ ] 查找 ESM 导入（第374-376行）
- [ ] 确认版本号已固定（当前已固定为 10.19.3 和 3.1.1）
- [ ] 考虑添加备用 CDN 或本地化

**当前代码**:

```javascript
import { h, render, createContext } from 'https://esm.sh/preact@10.19.3';
import { useState, useEffect, useRef, useMemo, useContext } from 'https://esm.sh/preact@10.19.3/hooks';
import htm from 'https://esm.sh/htm@3.1.1';
```

**验证**: ✅ 版本已锁定，但可考虑添加错误处理和备用方案

#### 步骤 3.4: 添加资源加载错误处理

- [ ] 添加 Tailwind 加载失败检测
- [ ] 添加字体加载失败的回退
- [ ] 添加 Preact 加载失败的错误提示

**参考代码**:

```javascript
// 检测 Tailwind 是否加载
if (typeof tailwind === 'undefined') {
    console.error('Tailwind CSS 加载失败');
    // 显示错误提示或使用备用样式
}
```

#### 步骤 3.5: 测试验证

- [ ] 测试正常加载
- [ ] 模拟网络错误测试降级处理
- [ ] 检查所有功能正常

---

## 🟡 第二阶段：中优先级优化

### 任务 4: 性能优化

#### 步骤 4.1: 优化图片预加载

- [ ] 在 `Preloader` 组件中添加音频预加载（第686-707行）
- [ ] 添加图片加载失败的重试机制
- [ ] 添加加载进度详细信息显示

**修改位置**: 第686-707行的 `Preloader` 组件

**改进点**:

```javascript
// 添加音频预加载
const audioFiles = Object.values(ASSETS.audio);
const total = images.length + audioFiles.length;

audioFiles.forEach(src => {
    const audio = new Audio();
    audio.src = src;
    audio.preload = 'auto';
    audio.oncanplaythrough = audio.onerror = () => {
        loaded++;
        setProgress(Math.floor((loaded / total) * 100));
        if (loaded === total) {
            setTimeout(onLoadComplete, 500);
        }
    };
});
```

#### 步骤 4.2: 修复内存泄漏风险

- [ ] 检查所有 `setInterval` 和 `setTimeout` 都有清理（第1404、1418、1428行）
- [ ] 确保音频对象在组件卸载时释放
- [ ] 检查事件监听器清理

**检查清单**:

- [ ] 第1404行：`timerRef.current` 清理 ✅ (已有)
- [ ] 第1418行：return 清理函数 ✅ (已有)
- [ ] 第1428行：`autoTimerRef.current` 清理 ✅ (已有)
- [ ] 第1300行：音频清理 ✅ (已有)
- [ ] 添加全局事件监听器清理检查

#### 步骤 4.3: 优化状态更新

- [ ] 使用 `useMemo` 优化 `currentScene` 和 `currentLine` 计算
- [ ] 使用 `useCallback` 优化事件处理函数
- [ ] 考虑拆分 `gameState` 为多个独立状态

**修改位置**: 第1328-1329行附近

**参考代码**:

```javascript
const currentScene = useMemo(() => SCENES[gameState.sceneId], [gameState.sceneId]);
const currentLine = useMemo(() => 
    currentScene?.lines ? currentScene.lines[gameState.lineIndex] : null,
    [currentScene, gameState.lineIndex]
);
```

---

### 任务 5: 代码模块化拆分

#### 步骤 5.1: 创建目录结构

- [ ] 创建 `js/` 目录
- [ ] 创建 `css/` 目录（如果使用外部 CSS）

#### 步骤 5.2: 提取资源配置

- [ ] 创建 `js/assets.js` 文件
- [ ] 将 `ASSETS` 对象移动到新文件
- [ ] 在 `index.html` 中导入

#### 步骤 5.3: 提取剧本数据

- [ ] 创建 `js/scenes.js` 文件
- [ ] 将 `SCENES`、`ENDINGS_META`、`CHAPTERS_META` 移动到新文件
- [ ] 在 `index.html` 中导入

#### 步骤 5.4: 提取组件

- [ ] 创建 `js/components.js` 文件
- [ ] 将所有组件函数移动到新文件
- [ ] 在 `index.html` 中导入

#### 步骤 5.5: 提取游戏逻辑

- [ ] 创建 `js/game.js` 文件
- [ ] 将 `App` 组件和主要逻辑移动到新文件
- [ ] 在 `index.html` 中导入并初始化

#### 步骤 5.6: 提取样式（可选）

- [ ] 创建 `css/style.css` 文件
- [ ] 将 `<style>` 标签内容移动到新文件
- [ ] 在 `index.html` 中链接

#### 步骤 5.7: 测试验证

- [ ] 测试所有功能正常
- [ ] 检查文件加载顺序
- [ ] 验证模块导入正确

---

### 任务 6: 提取魔法数字和字符串

#### 步骤 6.1: 创建常量文件

- [ ] 在代码顶部创建 `CONSTANTS` 对象
- [ ] 定义所有魔法数字和字符串

**代码位置**: 在 `ASSETS` 定义之前（约第380行）

**参考代码**:

```javascript
const CONSTANTS = {
    TYPING_SPEED: {
        MIN: 10,
        MAX: 80,
        DEFAULT: 30
    },
    AUTO_MODE_DELAY: {
        BASE: 500,
        PER_CHAR: 80
    },
    STORAGE_KEYS: {
        AUTO_SAVE: 'qijiu_auto_save',
        SAVE_SLOT_PREFIX: 'qijiu_save_slot_',
        READ_TEXT: 'qijiu_read_text',
        UNLOCKED_ENDINGS: 'qijiu_unlocked_endings',
        UNLOCKED_CHAPTERS: 'qijiu_unlocked_chapters',
        SETTINGS: 'qijiu_settings'
    },
    ANIMATION: {
        FADE_DURATION: 500,
        SHAKE_DURATION: 600,
        RHYTHM_DURATION: 500
    }
};
```

#### 步骤 6.2: 替换所有魔法数字

- [ ] 替换第1415行：`textSpeed` 使用 `CONSTANTS.TYPING_SPEED`
- [ ] 替换第1427行：`delay` 计算使用 `CONSTANTS.AUTO_MODE_DELAY`
- [ ] 替换所有存储键名使用 `CONSTANTS.STORAGE_KEYS`

#### 步骤 6.3: 测试验证

- [ ] 测试所有功能正常
- [ ] 检查常量使用正确

---

### 任务 7: 添加可访问性支持

#### 步骤 7.1: 添加 ARIA 标签

- [ ] 为所有按钮添加 `aria-label`
- [ ] 为对话框添加 `role="dialog"` 和 `aria-labelledby`
- [ ] 为菜单添加 `role="menu"`

**查找位置**: 所有 `<button>` 标签

**示例**:

```html
<button 
    onClick=${onNext}
    aria-label="下一句对话"
    aria-keyshortcuts="Space,Enter"
>
```

#### 步骤 7.2: 添加键盘导航

- [ ] 添加 ESC 键打开菜单（第1740行按钮）
- [ ] 添加 Space/Enter 下一句（第1716行）
- [ ] 添加方向键导航选项（第821-838行 ChoiceScreen）

**代码位置**: 在 `App` 组件中添加全局键盘事件监听

**参考代码**:

```javascript
useEffect(() => {
    const handleKeyDown = (e) => {
        if (e.key === 'Escape' && !isMenuOpen) {
            setIsMenuOpen(true);
        }
        if ((e.key === ' ' || e.key === 'Enter') && !isMenuOpen && !isHistoryOpen) {
            e.preventDefault();
            handleNext(false);
        }
    };
    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
}, [isMenuOpen, isHistoryOpen]);
```

#### 步骤 7.3: 添加焦点管理

- [ ] 对话框打开时聚焦第一个按钮
- [ ] 对话框关闭时恢复焦点
- [ ] 添加焦点可见样式

#### 步骤 7.4: 测试验证

- [ ] 使用键盘完全操作游戏
- [ ] 使用屏幕阅读器测试
- [ ] 检查焦点管理正确

---

### 任务 8: SEO 和元数据优化

#### 步骤 8.1: 添加 favicon

- [ ] 创建或准备 favicon 图片
- [ ] 在 `<head>` 中添加 favicon 链接（第18行后）

**代码**:

```html
<link rel="icon" type="image/png" href="./favicon.png">
<link rel="apple-touch-icon" href="./favicon.png">
```

#### 步骤 8.2: 添加 Open Graph 标签

- [ ] 在 `<head>` 中添加 OG 标签（第23行后）

**代码**:

```html
<meta property="og:title" content="安定峰采购假药引发的惨案 VN风">
<meta property="og:type" content="game">
<meta property="og:description" content="一个关于修仙界丹药与爱恨情仇的视觉小说。">
<meta property="og:image" content="./qijiu_start_screen.png">
<meta property="og:url" content="[你的网站URL]">
```

#### 步骤 8.3: 添加 Twitter Card 标签

- [ ] 在 OG 标签后添加 Twitter Card 标签

**代码**:

```html
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="安定峰采购假药引发的惨案 VN风">
<meta name="twitter:description" content="一个关于修仙界丹药与爱恨情仇的视觉小说。">
<meta name="twitter:image" content="./qijiu_start_screen.png">
```

#### 步骤 8.4: 优化现有 meta 标签

- [ ] 检查 `description` 是否足够描述性
- [ ] 添加 `keywords` meta 标签（可选）
- [ ] 添加 `author` meta 标签

#### 步骤 8.5: 测试验证

- [ ] 使用 [Open Graph Debugger](https://developers.facebook.com/tools/debug/) 测试
- [ ] 使用 [Twitter Card Validator](https://cards-dev.twitter.com/validator) 测试

---

## 🟢 第三阶段：低优先级增强

### 任务 9: 代码质量提升

#### 步骤 9.1: 添加 JSDoc 注释

- [ ] 为所有主要函数添加 JSDoc 注释
- [ ] 为组件添加参数说明
- [ ] 为复杂逻辑添加行内注释

**优先级函数**:

- [ ] `handleNext` (第1523行)
- [ ] `handleSaveSlot` (第1471行)
- [ ] `handleLoadSlot` (第1491行)
- [ ] `handleChoice` (第1601行)

#### 步骤 9.2: 添加全局错误处理

- [ ] 添加 `window.onerror` 处理器
- [ ] 添加 `unhandledrejection` 处理器
- [ ] 添加用户友好的错误提示

**代码位置**: 在 `<script type="module">` 开始处（第370行后）

**参考代码**:

```javascript
window.addEventListener('error', (e) => {
    console.error('全局错误:', e);
    // 可以显示用户友好的错误提示
});

window.addEventListener('unhandledrejection', (e) => {
    console.error('未处理的 Promise 拒绝:', e);
});
```

---

### 任务 10: 用户体验增强

#### 步骤 10.1: 改进加载状态

- [ ] 在预加载器中显示当前加载的资源名称
- [ ] 添加加载时间估算
- [ ] 添加加载失败的重试按钮

**修改位置**: 第683-717行 `Preloader` 组件

#### 步骤 10.2: 添加离线支持（可选）

- [ ] 创建 Service Worker 文件
- [ ] 注册 Service Worker
- [ ] 实现资源缓存策略

**注意**: 这是一个较大的任务，可以单独规划

---

### 任务 11: 安全性增强

#### 步骤 11.1: 添加 Content Security Policy

- [ ] 在 `<head>` 中添加 CSP meta 标签

**代码**:

```html
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' 'unsafe-inline' https://cdn.tailwindcss.com https://esm.sh https://fonts.loli.net; style-src 'self' 'unsafe-inline' https://fonts.loli.net; img-src 'self' data:; font-src 'self' https://fonts.loli.net;">
```

#### 步骤 11.2: 优化防调试代码

- [ ] 改进开发模式检测（第316行）
- [ ] 添加更友好的开发提示
- [ ] 考虑弱化生产环境的防调试强度

---

## 📝 实施建议

### 工作流程

1. **按阶段执行**: 先完成第一阶段，再进入第二阶段
2. **小步提交**: 每完成一个任务就测试并提交
3. **测试驱动**: 每次修改后都要测试相关功能
4. **文档更新**: 修改代码时同步更新注释

### 测试 checklist

每次修改后检查：

- [ ] 游戏可以正常启动
- [ ] 存档/读档功能正常
- [ ] 所有对话框显示正常
- [ ] 移动端显示正常
- [ ] 控制台无错误
- [ ] 功能逻辑正确

### 遇到问题时的处理

1. **回滚**: 如果修改导致问题，立即回滚
2. **记录**: 记录遇到的问题和解决方案
3. **求助**: 复杂问题可以分步骤解决或寻求帮助

---

## ✅ 完成检查清单

完成所有任务后，检查以下项目：

- [ ] 所有高优先级任务完成
- [ ] 所有中优先级任务完成（或标记为可选）
- [ ] 代码通过测试
- [ ] 无控制台错误
- [ ] 移动端测试通过
- [ ] 性能无明显下降
- [ ] 文档已更新

---

**最后更新**: ___________  
**完成日期**: ___________
