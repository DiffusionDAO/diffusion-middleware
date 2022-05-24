## GET /api/v0/concentration
字段     | 类型    |    说明         |    必需
---------|--------|-----------------|----------
code     | int    |状态码(200 为成功)|    是
telegram | int    | telegram 群粉丝数|    是
discord  | int    | discord 群粉丝数 |    是
twitter  | int    | twitter 关注数   |    是
medium   | int    | medium 关注数    |    是

示例：
```json
{
  code: 200,
  data: {
    telegram: 128,
    discord: 364,
    twitter: 542,
    medium: 746,
  }
}
```