//
//  LYKCarouseScrollController.m
//  lunbo
//
//  Created by ws on 16/1/12.
//  Copyright © 2016年 ws. All rights reserved.
//

#define  LYKViewWith self.view.frame.size.width
#define LYKViewHeight self.view.frame.size.height

#define LYKTitleHeight 25


#import "LYKLoopScrollController.h"
#import "UIImageView+WebCache.h"


@interface LYKLoopScrollController ()<UIScrollViewDelegate>{
    
    NSMutableArray *imageUrlArr;
    NSMutableArray *imageTitleArr;
    NSTimer *_timer;
    
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@end


@implementation LYKLoopScrollController




- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    NSLog(@"%@",NSStringFromCGRect(self.view.frame));
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    NSLog(@"%@",NSStringFromCGRect(self.view.frame));
    [self setUpSubView];
    
    
    [self startTimer];

}


/**
 *  开始时间
 */
- (void)startTimer{
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFire) userInfo:nil repeats:YES];
}

/**
 *  停止时间
 */
- (void)stopTimer{
    
    [_timer invalidate];
}

/**
 *  设置scrollView
 */
- (void)setUpSubView{
    
    if (!self.scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, LYKViewWith, LYKViewHeight)];
        scrollView.scrollsToTop = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.pagingEnabled = YES;
        scrollView.scrollEnabled = YES;
        scrollView.userInteractionEnabled = YES;
        scrollView.delegate = self;
        self.scrollView = scrollView;
        [self.view addSubview:scrollView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDidChick:)];
        [scrollView addGestureRecognizer:tap];
        
    }
    
    if (!self.pageControl) {
        
        CGFloat scale =  LYKViewWith / 375;
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        
        
        
        pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        pageControl.frame = CGRectMake(140 * scale, self.view.frame.size.height-29, self.view.frame.size.width-30 * scale, 25);
        NSLog(@"%@",NSStringFromCGRect(pageControl.frame));
        self.pageControl = pageControl;
        [self.view addSubview:pageControl];
        
        
        
        NSLog(@"%@",NSStringFromCGRect(pageControl.frame));
    }
    
    [self reloadData];
}

/**
 *  刷新数据源，在数据源方法实现的前提下必须调用
 */
- (void)reloadData{
    
    imageUrlArr = [NSMutableArray arrayWithArray:[self.dataSouce LYKLoopScrollControllerForImageUrl:self]];
    imageTitleArr = [NSMutableArray arrayWithArray:[self.dataSouce LYKLoopScrollControllerForImageTitle:self]];
    self.pageControl.numberOfPages = imageUrlArr.count;
    [self.pageControl sizeToFit];
    CGFloat scale =  LYKViewHeight / [UIScreen mainScreen].bounds.size.width;
    

    
    
    
    
    
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    self.scrollView.contentSize = CGSizeMake(imageUrlArr.count * LYKViewWith, LYKViewHeight);
    for (int i = 0; i < imageUrlArr.count; ++i) {
        UIImageView *imageV = [[UIImageView alloc] init];
        NSURL *url = [NSURL URLWithString:imageUrlArr[i]];
        [imageV setImageWithURL:url placeholderImage:[self.dataSouce LYKLoopScrollControllerForPlaceHoderImage:self]];

        
        imageV.frame = CGRectMake(LYKViewWith * (i + 1), 0, LYKViewWith, LYKViewHeight);
        [self.scrollView addSubview:imageV];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageV.frame.size.height - LYKTitleHeight, imageV.frame.size.width, LYKTitleHeight)];
        label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        label.font = [UIFont systemFontOfSize:self.titleLabelFont];
        [imageV addSubview:label];
        label.text = [NSString stringWithFormat:@"  %@",imageTitleArr[i]];
        
        
    }
    
    NSURL *firstUrl = [NSURL URLWithString:[imageUrlArr lastObject]];
    UIImageView *firstImageV = [[UIImageView alloc] init];
    [firstImageV setImageWithURL:firstUrl placeholderImage:[self.dataSouce LYKLoopScrollControllerForPlaceHoderImage:self]];
    firstImageV.frame = CGRectMake(0, 0, LYKViewWith, LYKViewHeight);
    [self.scrollView addSubview:firstImageV];
    
    
    NSURL *lastUrl = [NSURL URLWithString:[imageUrlArr firstObject]];
    UIImageView *lastImageV = [[UIImageView alloc] init];
    [lastImageV setImageWithURL:lastUrl placeholderImage:[self.dataSouce LYKLoopScrollControllerForPlaceHoderImage:self]];
    lastImageV.frame = CGRectMake(LYKViewWith * (imageUrlArr.count + 1), 0, LYKViewWith, LYKViewHeight);
    [self.scrollView addSubview:lastImageV];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, firstImageV.frame.size.height - LYKTitleHeight, firstImageV.frame.size.width, LYKTitleHeight)];
    label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    label.font = [UIFont systemFontOfSize:self.titleLabelFont];
    [firstImageV addSubview:label];
    label.text = [NSString stringWithFormat:@"  %@",[imageTitleArr lastObject]];
    
    self.scrollView.contentSize = CGSizeMake((imageUrlArr.count + 2) * LYKViewWith, LYKViewHeight);

    [self.scrollView setContentOffset:CGPointMake(LYKViewWith, 0) animated:NO];
}


/**
 *  监听滚动的方法
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger page = offsetX / LYKViewWith;;
    if (offsetX <= 0) {
        [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width * (imageUrlArr.count + 1) - LYKViewWith, 0) animated:NO];
        
        page = imageUrlArr.count;
        
    } else if (offsetX >= scrollView.contentSize.width - LYKViewWith) {
        [scrollView setContentOffset:CGPointMake(LYKViewWith, 0) animated:NO];
        page = 0;
    }
    
    
    
    self.pageControl.currentPage = page - 1;
}

/**
 *  定时器调用的方法
 */
- (void)timeFire{
    
    CGFloat offSize = self.scrollView.contentOffset.x;
    [self.scrollView setContentOffset:CGPointMake(offSize + LYKViewWith, 0) animated:YES];
}

/**
 *  在拖动的时候停止轮播
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self stopTimer];
}


/**
 *  在拖动的时候开始轮播
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [self startTimer];
}


- (void)scrollViewDidChick:(UIGestureRecognizer *)tap{
    
    CGPoint touchOff = [tap locationOfTouch:0 inView:self.scrollView];
    
    NSInteger touchPage = (touchOff.x - LYKViewWith) / LYKViewWith;
//    NSLog(@"%ld",touchPage);
    if ([self.delegate respondsToSelector:@selector(LYKLoopScrollControllerDidChick:index:)]) {
        [self.delegate LYKLoopScrollControllerDidChick:self index:touchPage];
    }
    
}

@end
