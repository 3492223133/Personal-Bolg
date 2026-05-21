# Blog 博客系统 API 接口文档

## 目录

- [1. 基础说明](#1-基础说明)
- [2. 统一响应格式](#2-统一响应格式)
- [3. 认证机制](#3-认证机制)
- [4. 用户模块](#4-用户模块)
- [5. 文章模块](#5-文章模块)
- [6. 分类模块](#6-分类模块)
- [7. 标签模块](#7-标签模块)
- [8. 评论模块](#8-评论模块)
- [9. 文件模块](#9-文件模块)
- [10. 前端对接说明](#10-前端对接说明)

---

## 1. 基础说明

### 1.1 开发环境

| 项目 | 地址 |
|------|------|
| 前端开发服务器 | `http://localhost:5173` |
| 后端 API 服务器 | `http://localhost:8080` |
| API 前缀 | `/api` |

### 1.2 Vite 代理配置

前端通过 Vite 代理将 `/api` 请求转发到后端，避免跨域问题：

```js
// vite.config.js
server: {
  port: 5173,
  proxy: {
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true
    }
  }
}
```

### 1.3 请求方式

| 方法 | 用途 |
|------|------|
| `GET` | 获取资源 |
| `POST` | 创建资源 |
| `PUT` | 更新资源 |
| `DELETE` | 删除资源 |

---

## 2. 统一响应格式

所有 API 接口返回统一的 JSON 格式：

```json
{
  "code": 200,
  "message": "操作成功",
  "data": { ... }
}
```

### 2.1 状态码说明

| code | 含义 |
|------|------|
| 200 | 请求成功 |
| 400 | 请求参数错误 |
| 401 | 未授权 / Token 过期 |
| 403 | 权限不足 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

### 2.2 分页响应格式

分页接口返回的 `data` 结构：

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [ ... ],
    "total": 100,
    "size": 10,
    "current": 1,
    "pages": 10
  }
}
```

---

## 3. 认证机制

### 3.1 认证流程

```
1. 用户登录 → POST /api/user/login → 返回 token
2. 前端存储 token 到 localStorage
3. 后续请求在 Header 中携带: Authorization: Bearer <token>
4. 后端验证 token 有效性
5. Token 过期 → 返回 401 → 前端跳转登录页
```

### 3.2 前端实现

```js
// src/utils/request.js - 请求拦截器
request.interceptors.request.use(config => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers['Authorization'] = `Bearer ${token}`
  }
  return config
})

// 响应拦截器 - 401 处理
request.interceptors.response.use(
  response => { /* 正常处理 */ },
  error => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      router.push('/login')
    }
  }
)
```

### 3.3 路由守卫

```js
// src/router/index.js
router.beforeEach((to, from) => {
  // requiresAuth: 需要登录
  // requiresAdmin: 需要管理员权限（role === 'admin'）
  if (to.meta.requiresAuth && !token) return '/login'
  if (to.meta.requiresAdmin && userInfo.role !== 'admin') return '/'
})
```

---

## 4. 用户模块

### 4.1 用户登录

**POST** `/api/user/login`

**请求体 (JSON):**
```json
{
  "username": "admin",
  "password": "123456"
}
```

**成功响应:**
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "userId": 1,
    "username": "admin",
    "nickname": "管理员",
    "avatar": "https://example.com/avatar.png",
    "role": "admin"
  }
}
```

**错误响应:**
```json
{
  "code": 400,
  "message": "用户名或密码错误",
  "data": null
}
```

---

### 4.2 用户注册

**POST** `/api/user/register`

**请求体 (JSON):**
```json
{
  "username": "newuser",
  "password": "123456",
  "nickname": "新用户"
}
```

**成功响应:**
```json
{
  "code": 200,
  "message": "注册成功",
  "data": null
}
```

---

### 4.3 获取用户列表（管理员）

**GET** `/api/user/list`

**请求参数 (Query):**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| current | number | 是 | 当前页码 |
| size | number | 是 | 每页条数 |
| keyword | string | 否 | 搜索关键词（用户名/昵称） |

**成功响应:**
```json
{
  "code": 200,
  "data": {
    "records": [
      {
        "id": 1,
        "username": "admin",
        "nickname": "管理员",
        "email": "admin@example.com",
        "avatar": "https://example.com/avatar.png",
        "role": "admin",
        "createTime": "2026-01-01 12:00:00"
      }
    ],
    "total": 1,
    "size": 10,
    "current": 1
  }
}
```

---

### 4.4 获取用户详情

**GET** `/api/user/{id}`

**路径参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| id | number | 用户ID |

**成功响应:**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "username": "admin",
    "nickname": "管理员",
    "email": "admin@example.com",
    "avatar": "https://example.com/avatar.png",
    "role": "admin",
    "createTime": "2026-01-01 12:00:00"
  }
}
```

---

### 4.5 更新用户信息

**PUT** `/api/user/{id}`

**路径参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| id | number | 用户ID |

**请求体 (JSON):**
```json
{
  "nickname": "新昵称",
  "email": "newemail@example.com",
  "avatar": "https://example.com/new-avatar.png",
  "role": "user"
}
```

**成功响应:**
```json
{
  "code": 200,
  "message": "更新成功",
  "data": null
}
```

---

### 4.6 删除用户

**DELETE** `/api/user/{id}`

**路径参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| id | number | 用户ID |

**成功响应:**
```json
{
  "code": 200,
  "message": "删除成功",
  "data": null
}
```

> **注意：** 不能删除管理员账户。

---

## 5. 文章模块

### 5.1 获取文章列表（分页）

**GET** `/api/article/list`

**请求参数 (Query):**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| current | number | 是 | 当前页码 |
| size | number | 是 | 每页条数 |
| keyword | string | 否 | 搜索关键词（标题） |
| categoryId | number | 否 | 按分类筛选 |
| tagId | number | 否 | 按标签筛选 |

**成功响应:**
```json
{
  "code": 200,
  "data": {
    "records": [
      {
        "id": 1,
        "title": "文章标题",
        "summary": "文章摘要",
        "content": "<p>文章内容</p>",
        "cover": "https://example.com/cover.jpg",
        "categoryId": 1,
        "category": {
          "id": 1,
          "name": "技术"
        },
        "tags": [
          { "id": 1, "name": "Vue" }
        ],
        "tagIds": [1, 2],
        "viewCount": 100,
        "likeCount": 10,
        "favoriteCount": 5,
        "commentCount": 3,
        "status": 1,
        "createTime": "2026-01-01 12:00:00",
        "publishTime": "2026-01-01 12:00:00"
      }
    ],
    "total": 20,
    "size": 10,
    "current": 1
  }
}
```

---

### 5.2 获取文章详情

**GET** `/api/article/detail`

**请求参数 (Query):**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | number | 是 | 文章ID |

**成功响应:**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "title": "文章标题",
    "summary": "文章摘要",
    "content": "<h1>文章内容</h1><p>段落...</p>",
    "cover": "https://example.com/cover.jpg",
    "categoryId": 1,
    "category": { "id": 1, "name": "技术" },
    "tags": [{ "id": 1, "name": "Vue" }],
    "viewCount": 101,
    "likeCount": 10,
    "favoriteCount": 5,
    "createTime": "2026-01-01 12:00:00",
    "updateTime": "2026-01-02 10:00:00"
  }
}
```

---

### 5.3 创建/发布文章

**POST** `/api/article`

**请求参数 (Query):**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| tagIds | string | 否 | 标签ID列表，逗号分隔，如 "1,2,3" |

**请求体 (JSON):**
```json
{
  "title": "文章标题",
  "content": "<p>文章内容（支持 HTML 或 Markdown）</p>",
  "cover": "https://example.com/cover.jpg",
  "categoryId": 1
}
```

**成功响应:**
```json
{
  "code": 200,
  "message": "发布成功",
  "data": { "id": 2 }
}
```

---

### 5.4 更新文章

**PUT** `/api/article/{id}`

**路径参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| id | number | 文章ID |

**请求参数 (Query):**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| tagIds | string | 否 | 标签ID列表，逗号分隔 |

**请求体 (JSON):**
```json
{
  "title": "更新后的标题",
  "content": "<p>更新后的内容</p>",
  "cover": "https://example.com/new-cover.jpg",
  "categoryId": 2
}
```

---

### 5.5 删除文章

**DELETE** `/api/article/{id}`

**路径参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| id | number | 文章ID |

---

### 5.6 搜索文章

**GET** `/api/article/search`

**请求参数 (Query):**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| keyword | string | 是 | 搜索关键词 |

**成功响应:**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "title": "相关文章",
      "summary": "摘要内容...",
      "category": { "id": 1, "name": "技术" },
      "createTime": "2026-01-01 12:00:00"
    }
  ]
}
```

---

### 5.7 文章归档

**GET** `/api/article/archive`

**说明:** 无需参数，返回按日期分组的文章列表。

**成功响应:**
```json
{
  "code": 200,
  "data": [
    {
      "date": "2026年01月",
      "articles": [
        {
          "id": 1,
          "title": "文章标题",
          "category": { "id": 1, "name": "技术" },
          "createTime": "2026-01-15 10:00:00",
          "viewCount": 88
        }
      ]
    }
  ]
}
```

---

### 5.8 点赞/取消点赞

**POST** `/api/article/{articleId}/like`

**路径参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| articleId | number | 文章ID |

**请求参数 (Query):**

| 参数 | 类型 | 说明 |
|------|------|------|
| userId | number | 用户ID |

**成功响应:**
```json
{
  "code": 200,
  "data": {
    "isLiked": true,
    "likeCount": 11
  }
}
```

---

### 5.9 检查点赞状态

**GET** `/api/article/{articleId}/like/check`

**路径参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| articleId | number | 文章ID |

**请求参数 (Query):**

| 参数 | 类型 | 说明 |
|------|------|------|
| userId | number | 用户ID |

**成功响应:**
```json
{
  "code": 200,
  "data": {
    "isLiked": true,
    "likeCount": 11
  }
}
```

---

### 5.10 收藏/取消收藏

**POST** `/api/article/{articleId}/favorite`

**路径参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| articleId | number | 文章ID |

**请求参数 (Query):**

| 参数 | 类型 | 说明 |
|------|------|------|
| userId | number | 用户ID |

**成功响应:**
```json
{
  "code": 200,
  "data": {
    "isFavorited": true,
    "favoriteCount": 6
  }
}
```

---

### 5.11 检查收藏状态

**GET** `/api/article/{articleId}/favorite/check`

**请求参数:** 同点赞状态检查

---

### 5.12 获取用户收藏列表

**GET** `/api/article/favorites`

**请求参数 (Query):**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| userId | number | 是 | 用户ID |
| current | number | 是 | 当前页码 |
| size | number | 是 | 每页条数 |

**成功响应:**
```json
{
  "code": 200,
  "data": {
    "records": [ { /* 文章对象 */ } ],
    "total": 5
  }
}
```

---

### 5.13 保存草稿

**POST** `/api/article/draft`

**请求参数 (Query):**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| tagIds | string | 否 | 标签ID列表，逗号分隔 |

**请求体 (JSON):**
```json
{
  "title": "草稿标题",
  "content": "草稿内容",
  "cover": "",
  "categoryId": 1
}
```

---

### 5.14 发布草稿

**POST** `/api/article/{articleId}/publish`

**路径参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| articleId | number | 草稿文章ID |

---

### 5.15 获取草稿列表

**GET** `/api/article/drafts`

**请求参数 (Query):**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| userId | number | 是 | 用户ID |
| current | number | 是 | 当前页码 |
| size | number | 是 | 每页条数 |

---

### 5.16 定时发布

**POST** `/api/article/{articleId}/schedule`

**路径参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| articleId | number | 文章ID |

**请求参数 (Query):**

| 参数 | 类型 | 说明 |
|------|------|------|
| publishTime | string | ISO 8601 格式时间 |

---

### 5.17 设置私密文章

**POST** `/api/article/{articleId}/private`

**路径参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| articleId | number | 文章ID |

**请求参数 (Query):**

| 参数 | 类型 | 说明 |
|------|------|------|
| password | string | 访问密码 |

---

### 5.18 获取版本历史

**GET** `/api/article/{articleId}/versions`

**路径参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| articleId | number | 文章ID |

---

### 5.19 回滚版本

**POST** `/api/article/version/{versionId}/rollback`

**路径参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| versionId | number | 版本ID |

---

## 6. 分类模块

### 6.1 获取分类列表

**GET** `/api/category/list`

**说明:** 无需参数，返回全部分类。

**成功响应:**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "name": "技术",
      "sort": 1,
      "articleCount": 15,
      "createTime": "2026-01-01 12:00:00"
    }
  ]
}
```

---

### 6.2 创建分类

**POST** `/api/category`

**请求体 (JSON):**
```json
{
  "name": "新分类",
  "sort": 1
}
```

---

### 6.3 更新分类

**PUT** `/api/category/{id}`

**请求体 (JSON):**
```json
{
  "name": "更新后的分类名",
  "sort": 2
}
```

---

### 6.4 删除分类

**DELETE** `/api/category/{id}`

> **注意：** 如果该分类下有文章，则无法删除。

---

## 7. 标签模块

### 7.1 获取标签列表

**GET** `/api/tag/list`

**成功响应:**
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "name": "Vue",
      "createTime": "2026-01-01 12:00:00"
    }
  ]
}
```

---

### 7.2 创建标签

**POST** `/api/tag`

**请求体 (JSON):**
```json
{
  "name": "新标签"
}
```

---

### 7.3 更新标签

**PUT** `/api/tag/{id}`

**请求体 (JSON):**
```json
{
  "name": "更新后的标签名"
}
```

---

### 7.4 删除标签

**DELETE** `/api/tag/{id}`

---

## 8. 评论模块

### 8.1 获取文章评论列表

**GET** `/api/comment/article/{articleId}`

**路径参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| articleId | number | 文章ID |

**请求参数 (Query):**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| current | number | 是 | 当前页码 |
| size | number | 是 | 每页条数 |

**成功响应:**
```json
{
  "code": 200,
  "data": {
    "records": [
      {
        "id": 1,
        "articleId": 1,
        "userId": 2,
        "userNickname": "评论者昵称",
        "nickname": "游客昵称",
        "content": "评论内容",
        "parentId": 0,
        "articleTitle": "所属文章标题",
        "createTime": "2026-01-15 14:00:00"
      }
    ],
    "total": 5
  }
}
```

> **字段说明:** `parentId` 为 0 表示顶级评论，非 0 表示回复某条评论。

---

### 8.2 获取所有评论列表（管理员）

**GET** `/api/comment/list`

**请求参数 (Query):**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| current | number | 是 | 当前页码 |
| size | number | 是 | 每页条数 |

---

### 8.3 发表评论

**POST** `/api/comment`

**请求体 (JSON):**
```json
{
  "articleId": 1,
  "userId": 2,
  "content": "评论内容",
  "parentId": 0,
  "nickname": "游客昵称（未登录时使用）",
  "email": "email@example.com"
}
```

---

### 8.4 删除评论

**DELETE** `/api/comment/{id}`

> **注意：** 删除评论时会同时删除所有子回复。

---

### 8.5 点赞评论

**POST** `/api/comment/{commentId}/like`

---

## 9. 文件模块

### 9.1 上传图片

**POST** `/api/file/upload`

**请求方式:** `multipart/form-data`

**表单字段:**

| 字段 | 类型 | 说明 |
|------|------|------|
| file | File | 图片文件 |

**成功响应:**
```json
{
  "code": 200,
  "message": "上传成功",
  "data": "https://example.com/uploads/2026/01/image.png"
}
```

---

## 10. 前端对接说明

### 10.1 前端项目结构

```
src/
├── api/              # API 接口封装（与后端一一对应）
│   ├── article.js    # 文章相关接口
│   ├── category.js   # 分类相关接口
│   ├── tag.js        # 标签相关接口
│   ├── comment.js    # 评论相关接口
│   ├── user.js       # 用户相关接口
│   └── file.js       # 文件上传接口
├── stores/           # Pinia 状态管理
│   ├── user.js       # 用户认证状态
│   └── theme.js      # 主题状态
├── utils/
│   └── request.js    # Axios 实例（拦截器、错误处理）
├── views/            # 页面组件
│   ├── admin/        # 管理后台页面
│   └── ...           # 前台页面
└── router/
    └── index.js      # 路由配置 + 导航守卫
```

### 10.2 请求工具说明

```js
// src/utils/request.js 核心功能：
// 1. 自动添加 Authorization Header (Bearer Token)
// 2. 统一错误处理（ElMessage 提示）
// 3. 401 自动跳转登录页
// 4. 10秒请求超时
// 5. 开发环境打印请求 URL 便于调试
```

### 10.3 路由权限说明

| meta 字段 | 含义 | 重定向 |
|-----------|------|--------|
| `requiresAuth: true` | 需要登录 | 未登录 → `/login` |
| `requiresAdmin: true` | 需要管理员角色 | 非管理员 → `/` |

### 10.4 数据流示意

```
用户操作 → Vue 组件 → Pinia Store → API 函数 → Axios 实例
                                                      ↓
                                               Vite 代理 (/api)
                                                      ↓
                                               后端 Spring Boot
                                                      ↓
                                               MySQL 数据库
```

### 10.4 新增页面步骤

1. 在 `src/views/` 创建 `.vue` 文件
2. 如需 API，在 `src/api/` 添加接口函数
3. 在 `src/router/index.js` 添加路由配置
4. 设置合适的 `meta` 权限

---

## 附录：常见错误码

| code | 说明 | 前端处理 |
|------|------|----------|
| 200 | 成功 | 正常处理数据 |
| 400 | 参数错误 | ElMessage.error 提示 |
| 401 | 未授权 | 清除 token，跳转登录页 |
| 403 | 无权限 | ElMessage.error("权限不足") |
| 404 | 不存在 | ElMessage.error("资源不存在") |
| 500 | 服务器错误 | ElMessage.error("服务器错误") |

---

> 文档更新时间：2026-05-21
> 对应前端版本：vue-blog v1.0
