//
//  JsonSort.m
//  Test
//
//  Created by zmz on 2018/11/1.
//  Copyright © 2018年 zmz. All rights reserved.
//

#import "JsonSort.h"

/**
 escape
 Json的escape规则参考：https://blog.csdn.net/kongwei521/article/details/39152257
 ------------------
 \"：双引号
 \\：反斜扛
 \b：退格
 \f：换页
 \n：换行
 \r：回车
 \t：跳格
 \u：其实 是unicode编码，如★为\u2605，😂为\ud83d\ude02，字符串中直接输就行了，理论上json中不存在\u出现
 */
static NSString *escapeToJson(NSString *string) {
    NSDictionary *replaceMap = @{
                                 @"\n": @"\\n",
                                 @"\b": @"\\b",
                                 @"\t": @"\\t",
                                 @"\r": @"\\r",
                                 @"\f": @"\\f",
                                 @"\"": @"\\\"",
                                 @"\\": @"\\\\",
                                 @"/": @"\\/",
                                 };
    NSMutableString *muString = [string mutableCopy];

    NSString *pattern = @"[\n\r\b\t\f\"\\/]";
    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *results = [exp matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
    [results enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *item, NSUInteger idx, BOOL *stop) {
        NSString *key = [string substringWithRange:item.range];
        NSString *shouldReplace = replaceMap[key];
        if (![shouldReplace isKindOfClass:[NSString class]]) { return ; }
        [muString replaceCharactersInRange:item.range withString:shouldReplace];
    }];
    return muString;
}

//递归json片段
static NSString *recursiveParasJson(NSObject *json_object, NSComparator cmp) {
    NSMutableString *muString = [NSMutableString string];
    if ([json_object isKindOfClass:[NSArray class]]) {
        [muString appendString:@"["];
        for (NSInteger i = 0; i < [(NSArray *)json_object count]; i++) {
            id item = [(NSArray *)json_object objectAtIndex:i];
            [muString appendString:recursiveParasJson(item, cmp)];
            
            //最后一个不加,
            if (i != [(NSArray *)json_object count]-1) {
                [muString appendString:@","];
            }
        }
        [muString appendString:@"]"];
    }
    else if ([json_object isKindOfClass:[NSDictionary class]]) {
        [muString appendString:@"{"];
        NSArray *allkeys = [(NSDictionary *)json_object allKeys];
        NSArray *sortedKeys = [allkeys sortedArrayUsingComparator:cmp];
        for (NSInteger i = 0; i < sortedKeys.count; i++) {
            NSString *key = sortedKeys[i];
            id value = [(NSDictionary *)json_object objectForKey:key];
            NSString *keyValue = [NSString stringWithFormat:@"\"%@\":%@", key, recursiveParasJson(value, cmp)];
            [muString appendString:keyValue];
            
            //最后一个不加,
            if (i != [(NSArray *)json_object count]-1) {
                [muString appendString:@","];
            }
        }
        [muString appendString:@"}"];
    }
    else if ([json_object isKindOfClass:[NSString class]]) {
        [muString appendFormat:@"\"%@\"", escapeToJson((NSString *)json_object)];
    }
    else if ([json_object isKindOfClass:[NSNumber class]]) {
        [muString appendFormat:@"%@", json_object];
    }
    else if ([json_object isKindOfClass:[NSNull class]]) {
        [muString appendString:@"null"];
    }
    else {
        NSLog(@"未知类型：%@", json_object);
    }
    return [muString copy];
}

/**
 json排序
 */
NSData *jsonSort(NSData *json, NSComparator cmp) {
    NSObject *source_json = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableLeaves error:nil];
    NSString *sorted = recursiveParasJson(source_json, cmp);
    
    NSData *data = [sorted dataUsingEncoding:NSUnicodeStringEncoding];
    return data;
}
