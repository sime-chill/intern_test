# 面试项目题

## 性能要求
1. 出于面积考虑，不能基于 FIFO 和状态机实现；
2. 仿真要求验证 burst 传输无气泡、逐级反压、传输不丢数据、无重复数据等场景； 
3. 仿真验证全面，覆盖关键场景，并且采用随机方式生成验证激励。

面试项目限时两天时间内完成，完成后把代码和仿真结果的截图上传到 GitHub 上，然后回复 GitHub 仓库链接地址即可。

## 仿真验证
### 情况一： data 的首拍数据跟 header 的单拍数据同步
仿真结果如下图所示：

![ex1](./fig/ex1.png)


### 情况二： data 的首拍数据快于 header 的单拍数据
仿真结果如下图所示：

![ex2](./fig/ex2.png)

### 情况三： data 的首拍数据慢于 header 的单拍数据
仿真结果如下图所示：

![ex3](./fig/ex3.png)