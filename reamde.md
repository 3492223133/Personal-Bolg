# 个人博客系统 前后端接口文档

**技术栈**

后端：SpringBoot + MyBatis-Plus + JWT + Redis + MySQL

前端：Vue3 + Vite + Element Plus + Axios

**请求格式**：POST/GET，统一 `application/json`

**基础域名**：`http://localhost:8080`

**令牌携带**：请求头 `Authorization: Bearer {token}`

------

## 统一规范

### 1. 统一返回格式

json









```
{
  "code": 200,       // 状态码 200成功 500失败 401未登录 403无权限
  "msg": "提示信息",
  "data": {}         // 业务数据
}
```

### 2. 分页通用入参

plaintext









```
pageNum: 页码
pageSize: 每页条数
```

### 3. 状态码说明

表格







| 码值 | 含义              |
| :--- | :---------------- |
| 200  | 请求成功          |
| 401  | 登录过期 / 未登录 |
| 403  | 权限不足          |
| 500  | 服务器异常        |

------

# 一、用户模块接口

## 1. 用户登录

- 请求方式：`POST`
- 接口地址：`/user/login`
- 请求参数：

json









```
{
  "username":"账号",
  "password":"密码"
}
```

- 返回数据：

json









```
{
  "token":"登录令牌",
  "nickname":"昵称",
  "avatar":"头像",
  "role":"角色"
}
```

## 2. 获取当前登录用户信息

- 请求方式：`GET`
- 接口地址：`/user/info`
- 请求头：携带 Token
- 返回：用户基本信息

## 3. 退出登录

- 请求方式：`POST`
- 接口地址：`/user/logout`

## 4. 用户注册

- 请求方式：`POST`
- 接口地址：`/user/register`
- 参数：username、password、nickname

------

# 二、文章模块接口

## 1. 分页查询博客文章（前台首页）

- 请求方式：`GET`
- 地址：`/article/list`
- 参数：pageNum、pageSize、categoryId (可选)、tagId (可选)
- 返回：分页文章列表（标题、封面、简介、发布时间、浏览量）

## 2. 获取文章详情

- 请求方式：`GET`
- 地址：`/article/detail/{id}`
- 路径参数：文章 id
- 自动累加浏览量

## 3. 文章搜索

- 请求方式：`GET`
- 地址：`/article/search`
- 参数：keyword、pageNum、pageSize

## 4. 后台新增文章

- 请求方式：`POST`
- 地址：`/article/add`
- 请求体：

json









```
{
  "title":"标题",
  "cover":"封面图地址",
  "content":"文章富文本内容",
  "categoryId":"分类id",
  "tagIds":[1,2],
  "status":1
}
```

## 5. 编辑文章

- 请求方式：`PUT`
- 地址：`/article/update`
- 参数：同新增 + 文章 id

## 6. 删除文章

- 请求方式：`DELETE`
- 地址：`/article/delete/{id}`

## 7. 后台获取所有文章（管理）

- 请求方式：`GET`
- 地址：`/article/admin/list`
- 需管理员权限

------

# 三、分类模块接口

## 1. 查询全部分类

- GET `/category/all`

## 2. 后台新增分类

- POST `/category/add`
- 参数：categoryName、sort

## 3. 修改分类

- PUT `/category/update`

## 4. 删除分类

- DELETE `/category/delete/{id}`

------

# 四、标签模块接口

## 1. 获取全部标签

- GET `/tag/all`

## 2. 新增标签

- POST `/tag/add`
- 参数：tagName

## 3. 删除标签

- DELETE `/tag/delete/{id}`

------

# 五、评论留言模块

## 1. 获取文章评论列表

- GET `/comment/list/{articleId}`

## 2. 发表评论

- POST `/comment/add`
- 参数：articleId、content、parentId (父评论 id，0 为一级评论)

## 3. 后台删除评论

- DELETE `/comment/delete/{id}`

------

# 六、文件上传接口

## 1. 图片上传（文章封面 / 内容图片）

- 请求方式：`POST`
- 地址：`/upload/image`
- 表单提交：file 文件
- 返回：`{url: "图片在线地址"}`

------

# 七、网站配置模块

## 1. 获取网站基本信息

- GET `/web/info`
- 返回：网站名称、简介、博主头像、个性签名、公告等

## 2. 后台修改网站配置

- PUT `/web/update`

------

# 八、前端常用请求封装示例（Vue3 Axios）

javascript



运行







```
import axios from 'axios'
import { useUserStore } from '@/stores/user'

const request = axios.create({
  baseURL: 'http://localhost:8080',
  timeout: 8000
})

// 请求拦截
request.interceptors.request.use(config => {
  const user = useUserStore()
  if(user.token){
    config.headers.Authorization = `Bearer ${user.token}`
  }
  return config
})

// 响应拦截
request.interceptors.response.use(res=>{
  return res.data
},err=>{
  ElMessage.error('请求失败')
})

export default request
```

------

# 九、路由权限控制要点

1. 未登录拦截后台管理路由
2. 普通用户仅可浏览前台
3. 管理员可进入 `/admin` 所有页面
4. 401 状态码自动清空 token 跳转到登录页

------

# 十、可直接对接完整接口清单（精简版）

plaintext









```
用户
POST  /user/login
GET   /user/info
POST  /user/logout

文章
GET   /article/list
GET   /article/detail/:id
POST  /article/add
PUT   /article/update
DELETE /article/delete/:id

分类
GET /category/all
POST /category/add

标签
GET /tag/all

评论
GET /comment/list/:aid
POST /comment/add

上传
POST /upload/image
```