# 说明
脚本需在墙内机器运行，并且运行机器上必须配置好 aws cli 环境，自动检测指定区域所有静态ip的连通性，如果不通，则删除当前静态ip，并新建静态ip绑定至实例。


---
依赖jq

https://github.com/stedolan/jq


安装jq
```bash
wget http://stedolan.github.io/jq/download/linux64/jq -O /usr/local/bin/jq
chmod +x /usr/local/bin/jq
```

---

# 使用方法

下载脚本

```
wget https://raw.githubusercontent.com/angelsky11/change-lightsail-ip/master/change-lightsail-ip.sh
```

运行

```bash
chmod +x change-lightsail-ip.sh
./change-lightsail-ip.sh YOUR_REGION
```
YOUR_REGION请参考下表替换修改
|  地区   |   地区码   |
| --- | --- |
|美国东部（俄亥俄）| us-east-2 |
|美国东部（弗吉尼亚北部）| us-east-1  |
|美国西部（俄勒冈）| us-west-2 |
|亚太地区（孟买）| ap-south-1 |
|亚太地区（首尔）| ap-northeast-2 |
|亚太地区（新加坡）| ap-southeast-1 |
|亚太地区（悉尼）| ap-southeast-2 |
|亚太地区 (东京) | ap-northeast-1 |
|加拿大（中部）| ca-central-1 |
|欧洲（法兰克福）| eu-central-1 |
|欧洲 (爱尔兰) | eu-west-1 |
|欧洲（伦敦）| eu-west-2 |
|欧洲（巴黎）| eu-west-3 |



可添加定时任务每10分钟检测一次


运行`crontab -e`后添加下面一行：
```
*/10 * * * * /YOUR_PATH/change-lightsail-ip.sh YOUR_REGION
```
如果不想10分钟一次请自行搜索crontab用法


# server酱微信消息推送

https://sc.ftqq.com


修改以下两个参数
```bash
#server酱开关，0为关闭，1为开启
NOTIFICATION=0
#server酱api
SERVERCHAN_KEY='YOUR_SERVERCHAN_API'
```

---

如有使用问题请先搜索后发信息 https://t.me/angelsky11
