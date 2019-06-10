# 效果
1.启动eureka服务并在eureka的web管理页面中的"Instances currently registered with Eureka"，
2.将鼠标悬停至注册的服务status栏上,即可看到效果

# 说明
界面操作取代了以下手动执行命令进行上下线操作，快速实现部署服务

curl -X PUT -i http://test:test@localhost:8761/eureka/apps/你的服务名称/localhost:1111/status?value=DOWN
curl -X PUT -i http://test:test@localhost:8761/eureka/apps/你的服务名称/localhost:1111/status?value=UP
