- redis 端口 6379
- redis 过期时间是 5 分钟，过期视为不在线
- 对于匿名用户，使用 "#{IP} #{UA}" 然后取 MD5 的方式判断唯一性