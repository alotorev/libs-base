#import "ObjectTesting.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSString.h>
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSValue.h>


int main (int argc, const char * argv[])
{

  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
  NSURLQueryItem* item = [[NSURLQueryItem alloc] init];
  PASS_EQUAL(item.name, @"", "Name should not be nil");
  PASS_EQUAL(item.value, nil, "Value should be nil");
    
  item = [[NSURLQueryItem alloc] initWithName:nil value:nil];
  PASS_EQUAL(item.name, @"", "Name should not be nil");
  PASS_EQUAL(item.value, nil, "Value should be nil");
    
  NSArray* namesArr = @[
      @"name",
      @"Имя",
      @"1234144"
  ];
    
  NSArray* valuesArr = @[
    @"value",
    @"%30%31%32%33%34%35%36%37%38%39",
    @"[izvafwe]"
  ];

  for(int i = 0; i < namesArr.count && valuesArr.count; i++){
      NSString* name = [namesArr objectAtIndex:i];
      NSString* value = [valuesArr objectAtIndex:i];
      
      item = [[NSURLQueryItem alloc] initWithName:name value:value];
      PASS_EQUAL(item.name, name, "Name is %s", [name UTF8String]);
      PASS_EQUAL(item.value, value, "Value is %s", [value UTF8String]);
  }
    
  NSArray* schemaArr = @[@"http", @"https", @"ftp"];
  NSArray* hostArr =  @[@"somedomain.com", @"localhost"];
  NSArray* portArr = @[@123, @100000, @0];
  NSArray* dirArr  = @[@"dir", @"dir", @".."];
  NSArray* fileArr = @[@"file", @"file", @"file"];
  NSArray* extensionArr = @[@"ext", @"a", @"a"];
  NSArray* qname1Arr = @[@"paramName", @"%30%31%32%33%34%35%36%37%38%39",@"name", @"name"];
  NSArray* qvalue1Arr = @[@"%30%31%32%33%34%35%36%37%38%39", @"%30%31%32%33%34%35%36%37%38%39", @"некодированный"];
    
    
  for(int i = 0; i < [schemaArr count]; i++){
      
      NSString* schema = [schemaArr objectAtIndex:i];
      NSString* host = [hostArr objectAtIndex:i];
      NSNumber* port = [portArr objectAtIndex:i];
      NSString* dir = [dirArr objectAtIndex:i];
      NSString* file = [fileArr objectAtIndex:i];
      NSString* extension = [extensionArr objectAtIndex:i];
      NSString* qname1 = [qname1Arr objectAtIndex:i];
      NSString* qvalue1 = [qvalue1Arr objectAtIndex:i];
      
      NSString* urlString = [NSString stringWithFormat:@"%@://%@:%@/%@/%@.%@?%@=%@",
                             schema,host,port,dir,file,extension,qname1,qvalue1];
      
          NSURLComponents* comp = [NSURLComponents componentsWithString:urlString];
          NSLog(@"%@", ([[comp URL] absoluteString]));
      
          PASS_EQUAL([comp host], host, "Checking host")
          PASS_EQUAL([comp port], port, "Cheking ports");
      
          item = [[comp queryItems] lastObject];
          PASS(item, "Geting query item from url");
          PASS_EQUAL(item.name, [qname1 stringByRemovingPercentEncoding], "Checking query item name");
          PASS_EQUAL(item.value, [qvalue1 stringByRemovingPercentEncoding], "Checking query item value");
  }
    
  [pool drain];
  return 0;
    
}
