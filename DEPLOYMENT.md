# DDAD.online 部署指南

## GitHub Pages 部署步骤

### 1. 确保仓库设置正确

1. 进入你的GitHub仓库页面
2. 点击 **Settings** (设置)
3. 在左侧菜单中找到 **Pages**
4. 在 **Source** (源) 部分，选择 **GitHub Actions**（不是选择分支）

### 2. 推送工作流文件

确保 `.github/workflows/static.yml` 文件已经推送到仓库：

```bash
git add .github/workflows/static.yml
git commit -m "Add GitHub Pages deployment workflow"
git push
```

### 3. 检查部署状态

1. 进入仓库的 **Actions** 标签页
2. 查看最新的工作流运行状态
3. 如果失败，点击查看详细日志

### 4. 常见问题排查

#### 问题1: 权限错误
**错误信息**: `Error: HttpError: Resource not accessible by integration`

**解决方案**:
1. 进入 Settings > Actions > General
2. 滚动到 **Workflow permissions**
3. 选择 **Read and write permissions**
4. 勾选 **Allow GitHub Actions to create and approve pull requests**
5. 点击 Save

#### 问题2: Pages未启用
**解决方案**:
1. 进入 Settings > Pages
2. 在 **Source** 下选择 **GitHub Actions**
3. 保存设置

#### 问题3: CNAME文件冲突
如果你使用自定义域名，确保：
- `CNAME` 文件内容只有一行：`ddad.online`
- DNS记录已正确配置

### 5. 验证部署

部署成功后：
1. 访问 `https://yourusername.github.io/ddad.online` 或你的自定义域名
2. 检查所有页面元素是否正常加载
3. 测试导航链接和交互功能

### 6. 自定义域名配置

#### DNS配置（已完成）
你需要在域名提供商处添加以下记录：

**方式A: A记录（推荐）**
```
类型: A
名称: @
值: 185.199.108.153
     185.199.109.153
     185.199.110.153
     185.199.111.153
```

**方式B: CNAME记录**
```
类型: CNAME
名称: www
值: yourusername.github.io
```

#### GitHub设置
1. 进入 Settings > Pages
2. 在 **Custom domain** 输入 `ddad.online`
3. 勾选 **Enforce HTTPS**（DNS生效后）
4. 点击 Save

### 7. 等待DNS生效

- DNS记录可能需要几分钟到48小时生效
- 使用 `dig ddad.online` 或在线工具检查DNS状态
- HTTPS证书会在域名验证后自动配置

## 手动部署（备选方案）

如果GitHub Actions遇到问题，可以使用传统方式：

1. 进入 Settings > Pages
2. Source 选择 `main` 分支
3. 文件夹选择 `/ (root)`
4. 点击 Save

## 更新网站

每次推送到main分支都会自动触发部署：

```bash
# 修改文件后
git add .
git commit -m "Update content"
git push
```

## 监控部署

- 查看 Actions 标签页了解部署状态
- 每次部署大约需要1-3分钟
- 部署完成后可能需要额外几分钟CDN缓存刷新

## 故障排除命令

```bash
# 检查DNS解析
dig ddad.online

# 检查HTTPS证书
curl -I https://ddad.online

# 本地测试
python -m http.server 8000
# 访问 http://localhost:8000
```

## 联系支持

如果遇到持续问题：
1. 检查 [GitHub Status](https://www.githubstatus.com/)
2. 查看 [GitHub Pages 文档](https://docs.github.com/en/pages)
3. 在仓库中创建 Issue

---

**祝部署顺利！** 🚀
