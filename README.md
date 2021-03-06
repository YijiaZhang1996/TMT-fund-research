# TMT-fund-research
在富国基金基金研究的实习过程中，我承担了TMT和消费基金研究两个课题。
代码可用于主题型基金数据库搭建、筛选和研究，具体功能及描述如下。

1.	根据一定的规则筛选行业可比基金池和重点基金作为研究对象。具体规则如下：
1）选取以下Wind行业主题基金作为初选池：电脑硬件、电子元器件、软件行业、通信设备、文化传媒、半导体。
2） 将初选池中的基金分为新基金和老基金：有3期及以上季度报告期数据的基金为老基金，否则为新基金。
3）老基金：计算2018Q1-2020Q2年季报十大重仓股中计算机、传媒、电子、通信四个申万以及行业总市值占十大重仓股总市值比重（数据未覆盖2018Q1-2020Q2全部区间的产品，按所覆盖的最大区间计算），筛选每季度平均值大于60%的加入可比基金池。
4）新基金：需要结合各季末十大重仓股行业比例和基金合同中所规定的投资主题和主要投资行业综合确定，无法在程序中体现。
5）在可比基金池中，综合考虑规模、业绩等因素，选择10只左右基金作为重点研究基金。

2.	查看基金的历史业绩。
对想要研究的基金，获取其在不同历史区间内、不同行情下的业绩表现，包括收益率、同类可比池中的排名等。
3.	计算所研究的基金的风险指标。
包括最大回撤、信息比率、Treynor比率、Jensen Alpha等。
4.	研究基金的持仓风格特征。
主要从主题行业纯度、子行业配置情况、操作风格等维度刻画基金的持仓风格。
5.	评价基金的选股能力。
通过建立T-M模型，对基金的选股和择时能力进行评价。
