//
//  ViewController.m
//  Pedometer
//
//  Created by mac on 2017/6/21.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"
#import <HealthKit/HealthKit.h>
#import "arcView.h"
#import "PedometerCell.h"
@interface ViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) HKHealthStore *healthStore;
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (strong, nonatomic) IBOutlet UIScrollView *indicators;
@property (weak, nonatomic) IBOutlet UITableView *RankingTable;
@property (nonatomic, strong) NSMutableArray *dataArr;
@end

@implementation ViewController{
    arcView *view1;
    UIButton *btn2;
    // 计步器走的步数；
    int i;
    int v;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self creatUI];
    [self getAuthority];
    _dataArr = [[NSMutableArray alloc] init];
}
//创建UI
-(void)creatUI{
    _indicators.contentSize=CGSizeMake([UIScreen mainScreen].bounds.size.width,700);
    view1  =[[arcView alloc]initWithFrame:CGRectMake(0,0,APPW,APPW-30)];
    view1.backgroundColor = [UIColor whiteColor];
    view1.num = v;
    [_headView addSubview:view1];
}
#pragma mark 获取权限 ~~~~~~~~~~~~~pedometer begin
-(void)getAuthority{
    //查看healthKit在设备上是否可用，iPad上不支持HealthKit
    if (![HKHealthStore isHealthDataAvailable]) {
        //  self.StepsLable.text = @"该设备不支持HealthKit";
    }
    
    //创建healthStore对象
    self.healthStore = [[HKHealthStore alloc]init];
    //设置需要获取的权限 这里仅设置了步数
    HKObjectType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSSet *healthSet = [NSSet setWithObjects:stepType,nil];
    
    //从健康应用中获取权限
    [self.healthStore requestAuthorizationToShareTypes:nil readTypes:healthSet completion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            //获取步数后我们调用获取步数的方法
            [self readStepCount];
        }
        else
        {
            NSLog(@"获取步数权限失败");
        }
    }];
}
#pragma mark 读取步数 查询数据
- (void)readStepCount
{
    //查询采样信息
    HKSampleType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    //NSSortDescriptor来告诉healthStore怎么样将结果排序
    NSSortDescriptor *start = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    NSSortDescriptor *end = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    //获取当前时间
    NSDate *now = [NSDate date];
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calender components:unitFlags fromDate:now];
    int hour = (int)[dateComponent hour];
    int minute = (int)[dateComponent minute];
    int second = (int)[dateComponent second];
    NSDate *nowDay = [NSDate dateWithTimeIntervalSinceNow:  - (hour*3600 + minute * 60 + second) ];
    //时间结果与想象中不同是因为它显示的是0区
    NSDate *nextDay = [NSDate dateWithTimeIntervalSinceNow:  - (hour*3600 + minute * 60 + second)  + 86400];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:nowDay endDate:nextDay options:(HKQueryOptionNone)];
    /*查询的基类是HKQuery，这是一个抽象类，能够实现每一种查询目标，这里我们需要查询的步数是一个HKSample类所以对应的查询类是HKSampleQuery。下面的limit参数传1表示查询最近一条数据，查询多条数据只要设置limit的参数值就可以了*/
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc]initWithSampleType:sampleType predicate:predicate limit:0 sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        //设置一个int型变量来作为步数统计
        int allStepCount = 0;
        for (int i = 0; i < results.count; i ++) {
            //把结果转换为字符串类型
            HKQuantitySample *result = results[i];
            HKQuantity *quantity = result.quantity;
            NSMutableString *stepCount = (NSMutableString *)quantity;
            NSString *stepStr =[ NSString stringWithFormat:@"%@",stepCount];
            //获取51 count此类字符串前面的数字
            NSString *str = [stepStr componentsSeparatedByString:@" "][0];
            int stepNum = [str intValue];
            //把一天中所有时间段中的步数加到一起
            allStepCount = allStepCount + stepNum;
        }
        NSString *str1 = [NSString stringWithFormat:@"%ld",(long)allStepCount];
        //查询要放在多线程中进行，如果要对UI进行刷新，要回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update UI in UI thread here
            i = [str1 intValue];
            v = i+v;
            view1.num = v;
        });
    }];
    //执行查询
    [self.healthStore executeQuery:sampleQuery];
}
#pragma mark ~~~~~~~~~~~~~~pedometer end

#pragma mark ~~~~~~~~~~~~~~tableView begin
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellid = @"pedometerCell";
    PedometerCell *cell = (PedometerCell *) [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"Pedometer" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"pedometerCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"pedometerCell" forIndexPath:indexPath];
    }
    tableView.tableFooterView = [[UIView alloc] init];
    return cell;
}
#pragma mark ~~~~~~~~~~~~~~tableView end
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
