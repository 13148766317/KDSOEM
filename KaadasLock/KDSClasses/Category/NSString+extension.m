//
//  NSString+extension.m
//  xiaokaizhineng
//
//  Created by orange on 2019/1/24.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "NSString+extension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (extension)

- (NSString *)md5
{
    NSAssert(self, @"字符串不能为空");
    unsigned char md5[CC_MD5_DIGEST_LENGTH];
    CC_MD5(self.UTF8String, CC_MD5_DIGEST_LENGTH, md5);
    NSMutableString *ms = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i)
    {
        [ms appendFormat:@"%x", md5[i]];
    }
    return ms.copy;
}

+ (NSString *)uuid
{
    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfstr = CFUUIDCreateString(kCFAllocatorDefault, cfuuid);
    CFRelease(cfuuid);
    return (__bridge_transfer NSString *)cfstr;
}

//SHA256加密
+ (NSString*)sha256HashFor:(NSString*)input{
    
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];

    // This is an iOS5-specific method.
    // It takes in the data, how much data, and then output format, which in this case is an int array.
    CC_SHA256(data.bytes, data.length, digest);

    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];

    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }

    return output;
}

+(long long int)bytesToIntWithBytes:(Byte[_Nullable])byte offset:(int)offset
{
    long long int value;
    value = (long long int)((byte[offset]&0xFF)
                | ((byte[offset+1]<<8) & 0xFF00)
                | ((byte[offset+2]<<16)& 0xFF0000)
                | ((byte[offset+3]<<24) & 0xFF000000)
                  );
    return value;
}

+ (int)data2Int:(NSData *)data{
    Byte *byte = (Byte *)[data bytes];
    // 有大小端模式问题？
     return (byte[3] << 24) + (byte[2] << 16) + (byte[1] << 8) + (byte[0]);
}

  //将十进制转化为十六进制
+(NSString *)ToHex:(long long int)tmpid
  {
      NSString *nLetterValue;
      NSString *str =@"";
      long long int ttmpig;
      for (int i = 0; i<9; i++) {
          ttmpig=tmpid%16;
          tmpid=tmpid/16;
         switch (ttmpig)
         {
             case 10:
                 nLetterValue =@"A";break;
             case 11:
                 nLetterValue =@"B";break;
             case 12:
                nLetterValue =@"C";break;
             case 13:
                 nLetterValue =@"D";break;
             case 14:
                 nLetterValue =@"E";break;
             case 15:
                 nLetterValue =@"F";break;
             default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];

         }
         str = [nLetterValue stringByAppendingString:str];
         if (tmpid == 0) {
             break;
         }
     }
     return str;
}

+ (NSString *)removeSpaceAndNewline:(NSString *)str{
    
    NSString *temp = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    
    NSString *text = [temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    
    return text;
}

    
@end
