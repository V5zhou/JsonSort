//
//  ViewController.m
//  JsonSort
//
//  Created by zmz on 2018/11/9.
//  Copyright © 2018年 zmz. All rights reserved.
//

#import "ViewController.h"
#import "JsonSort.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    [self testLists];
}

- (NSArray *)testLists {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"myMachines" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    NSData *sorted_json = jsonSort(data, ^NSComparisonResult(NSString *obj1, NSString *obj2) {
        //可以自定义排序。
        //目前自定义排序方式为，先以key长度反序排，然后等长的再按字母顺序反序排。
        if (obj1.length > obj2.length) {
            return NSOrderedAscending;
        }
        else if (obj1.length < obj2.length) {
            return NSOrderedDescending;
        }
        else {
            return [obj2 compare:obj1];
        }
    });
    if (sorted_json) {
        NSString *path_to = [[NSBundle mainBundle] pathForResource:@"new" ofType:@"json"];
        NSLog(@"%@", path_to);
        [sorted_json writeToFile:path_to atomically:YES];
    }
    return nil;
}
@end
