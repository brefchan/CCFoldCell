# CCFoldCell
Cell展开收起动效(OC实现)
之前在https://github.com/Ramotion/folding-cell 看到了用Swift实现的很炫酷的Cell折叠效果,准备用在公司的项目里面,可惜公司的项目是OC实现,所以,自己动手丰衣足食,我用OC实现了同样的效果


###项目演示
![image](https://github.com/bref-Chan/CCFoldCell/blob/master/image/CCFoldCell.gif)   


###使用方法

#### Cell Xib 设置

首先,下载Demo,把CCFoldCell文件夹拖入你的工程,创建一个新的Cell继承CCFoldCell,新Cell必须要用Xib.

然后,在Xib中选中你的Cell


![image](https://github.com/bref-Chan/CCFoldCell/blob/master/image/CheckCell.png) 


在右边属性设置里面设置FoldCell属性


![image](https://github.com/bref-Chan/CCFoldCell/blob/master/image/SetCellProperty.png) 


>Item Count属性表示翻转动画时,你的内容视图分成多少块翻转视图来进行翻转,值越大,则每块翻转视图越小,反之亦然.注意,值必须设置成2以上
>BackViewColor属性表示你的翻转视图的背后的颜色是什么.

然后用AutoLayout进行Cell的布局,布局的规范是,翻转前的视图称为Foreground视图,将翻转完成时显示的视图称为Contener视图
所以你需要在Cell中布局2个视图,注意2个视图之间不能有任何的相关约束,顶部约束都必须相对于Cell的contentView来进行


![image](https://github.com/bref-Chan/CCFoldCell/blob/master/image/2view.png) 


然后分别将这2个视图与containerView和foregroundView Outlets绑定,然后将2个视图相对于Cell的contentView的顶部约束和 containerViewTop 和 foregroundViewTop Outlets绑定


![image](https://github.com/bref-Chan/CCFoldCell/blob/master/image/bindOutlets.png) 


#### Cell 方法重写

接下来在Cell的.m文件中重写父类
```
- (NSTimeInterval)animationDurationWithItemIndex:(NSInteger)itemIndex animationType:(AnimationType)type;
```
方法,里面返回的是每次翻转的用时,用NSNumber装起来放入数组返回,例如Demo中的翻转用时返回的是
```
- (NSTimeInterval)animationDurationWithItemIndex:(NSInteger)itemIndex animationType:(AnimationType)type
{
    NSArray<NSNumber *> *array = @[@(0.5f),@(.25f),@(.25f)];
    return array[itemIndex].doubleValue;
}
```
那么,Cell的设置就已经完成了,现在讲解的是在视图控制器中如何让Cell进行动画

####动画的开始时机

在UITableView的

```
- (void)tableView:(UITableView *)tableView willDisplayCell:(DemoCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

```

中进行Cell样式的展示,根据Cell的高度来判断Cell是否进行了翻转,具体代码为

```
- (void)tableView:(UITableView *)tableView willDisplayCell:(DemoCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![cell isKindOfClass:[DemoCell class]]) return;
    
    cell.backgroundColor = [UIColor clearColor];
    
    CGFloat cellHeight = self.cellHeights[indexPath.row].floatValue;
    if (cellHeight == kCloseCellHeight) {
        [cell selectedAnimationByIsSelected:NO animated:NO completion:nil];
    }else
    {
        [cell selectedAnimationByIsSelected:YES animated:NO completion:nil];
    }
    
    [cell setNumber:indexPath.row];
}
```

然后在UITableViewDelegate

```
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
```

中进行Cell的动画触发
使用Cell的

```
- (void)selectedAnimationByIsSelected:(BOOL)isSelected animated:(BOOL)animated completion:(void(^)())completion;
```

方法来设置Cell是否是翻转状态,是否进行动画.

Demo中的实现为

```
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DemoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (![cell isKindOfClass:[DemoCell class]]) return;
    
    if (cell.isAnimating) return;
    
    NSTimeInterval duration = 0.f;
    
    CGFloat cellHeight = self.cellHeights[indexPath.row].floatValue;
    
    if (cellHeight == kCloseCellHeight) {
        self.cellHeights[indexPath.row] = @(kOpenCellHeight);
        [cell selectedAnimationByIsSelected:YES animated:YES completion:nil];
        duration = 1.f;
    }else
    {
        self.cellHeights[indexPath.row] = @(kCloseCellHeight);
        [cell selectedAnimationByIsSelected:NO animated:YES completion:nil];
        duration = 1.f;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [tableView beginUpdates];
        [tableView endUpdates];
    } completion:nil];
    
}
```
    
    
    
### 大功告成
  
现在就可以运行项目,欣赏流畅的Cell折叠效果了
