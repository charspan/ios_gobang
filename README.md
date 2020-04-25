# iOS五子棋大战
项目是基于学习[慕课网——iOS-五子棋大战](https://www.imooc.com/learn/646)而开发的，思路清晰，代码精简，源码中还含有大量的注释，是本人用来学习ios基础知识的demo。

### 一.项目介绍

#### 1. 简介：
使用OC开发的一款单机版五子棋小游戏，在教学demo的基础上进行了多项优化，如：屏幕适配、快速计算落子点、支持边缘落子、修复AI无法判断XAAXAX的落子形式等等，[适合ios小白或者刚入门的新手学习研究]()。

#### 2.效果图：

<figure class="third">
    <img src="/img/index.png" width="220"/>
    <img src="/img/win.png" width="220">
    <img src="/img/lose.png" width="220">
</figure>

### 二. 五子棋AI思路介绍

#### 1. AI简介

![AI.png](/img/AI.png)

这里的AI（人工智能）比较简单，这个算法可深可浅，此项目就是比较浅的，深的可以去看[算法](http://blog.csdn.net/onezeros/article/details/5542379)，此项目AI的大体思路是：

- 先遍历棋盘上面的点，找到AI的棋子有活四，死四的点，既下一步能形成5个点的落子点，找到就直接在此点落子。

- 如果没找到，就遍历玩家活四，或者死四的点，并在此进行落点进行防守，ps：活四是没法防守的。

- 如果没找到，就直接找AI有形成活三，或者死三的点，进行落子进攻。

- 如果没找到，就找用户能形成活三，死三的点进行防守。……一直找到活二的点……

#### 2. 核心代码

```objective-c
// 寻找AI的最优落子点
+ (GobangPoint *)searchBestPoint:(NSMutableArray *)places {
    // 初始化KWOmni
    Robot *robot = [[Robot alloc] initWithArr:places];
    // 申明最优的落子点
    GobangPoint *bestPoint;
    // 定义连珠数量
    int num = 5;
    // 从能实现五连珠一直找到能实现2连珠的落子点
    while(num > 1) {
        // 在AI的角度寻找能实现num连珠的点
        bestPoint = [robot nextStep:robot.myType num:num thre:num - 1 x:0 y:0];
        // 找到了可用的最优点，返回该点
        if([robot checkPoint:bestPoint]) {
               return bestPoint;
        }
        // 在用户的角度寻找能实现num连珠的点
        bestPoint = [robot nextStep:robot.oppoType num:num thre:num - 1 x:0 y:0];
        // 找到了可用的最优点，返回该点
        if([robot checkPoint:bestPoint]) {
            return bestPoint;
        }
        num--;
    }
    // 如果什么都没有则返回不可用的点
    GobangPoint *sad = [[GobangPoint alloc] init];
    return sad;
}
```

#### 三. 感谢

1. [dadahua](https://github.com/dadahua/GoBangProject)
2. [慕课网——iOS-五子棋大战](https://www.imooc.com/learn/646)

#### 四.结语
 如果项目能对你有所帮助，就给个star或赞鼓励下，有什么没明白的欢迎留言交流。
