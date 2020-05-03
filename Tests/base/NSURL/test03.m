#import "ObjectTesting.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSString.h>
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
//#ifdef MACOS
//#define NSURLComponents MYURLComponents
//#endif

/**
 *  Structure to hold test data
 */

typedef struct {
    
    NSString* scheme;
    NSString* host;
    NSNumber* port;
    NSString* dir;
    NSString* file;
    NSString* extension;
    NSString* qname1;
    NSString* qvalue1;
    NSNumber* valid;
    
    NSString* path;
    NSString* query;
    NSString* urlString;
    
    NSURL*  url;
    
    
} TestSet;

NSString* encodeQuery(NSString* origin)
{
    NSCharacterSet* set = [NSCharacterSet URLQueryAllowedCharacterSet];
    return [origin stringByAddingPercentEncodingWithAllowedCharacters:set];
}

NSString* encodePath(NSString* origin)
{
    NSCharacterSet* set = [NSCharacterSet URLQueryAllowedCharacterSet];
    return [origin stringByAddingPercentEncodingWithAllowedCharacters:set];
}

BOOL getTestSetWithIndex(NSInteger index, TestSet* test)
{

    NSArray* schmArr  = [NSArray arrayWithObjects:@"https", nil];
    NSArray* hostArr  = [NSArray arrayWithObjects:@"localhost", @"somedomain.com", nil];
    NSArray* portArr  = [NSArray arrayWithObjects:@12345, @1000, @12, @65535, @"", nil];
    NSArray* dirArr   = [NSArray arrayWithObjects:@"dir", encodePath(@"путь"), @"", @"path", nil];
    NSArray* fileArr  = [NSArray arrayWithObjects:@"", @"file", nil];
    NSArray* extArr   = [NSArray arrayWithObjects:@"ext", nil];
    NSArray* nameArr  = [NSArray arrayWithObjects:@"paramName", @"paramName", @"name", @"", @"name", nil];
    NSArray* valueArr = [NSArray arrayWithObjects:encodeQuery(@"АаБбВвГгДд01234567890"), @"АаБбВвГгДд01234567890", @"value", encodeQuery(@"АаБбВвГгДдAaBbCcDd"), @"", nil];
    //is test set at index produces valid url
    NSArray* validArr = [NSArray arrayWithObjects: @YES, @NO, @YES, @YES, @YES, @YES, nil];
    
    //atleast one array should have element at specified index
    if(index >= [[[NSArray arrayWithObjects:
                    @([schmArr count]), @([hostArr count]), @([portArr count]),
                    @([dirArr count]),  @([fileArr count]), @([extArr count]),
                    @([nameArr count]), @([validArr count]), nil
                  ] valueForKeyPath:@"@max.self"]  integerValue] || index >= [validArr count]) return NO;
    
    //if value exists at index return that value, or last avaliable value ot index
    test->scheme    = ([schmArr count] > index)  ? [schmArr objectAtIndex:index]  : [schmArr lastObject];
    test->host      = ([hostArr count] > index)  ? [hostArr objectAtIndex:index]  : [hostArr lastObject];
    test->port      = ([portArr count] > index)  ? [portArr objectAtIndex:index]  : [portArr lastObject];
    test->dir       = ([dirArr count] > index)   ? [dirArr objectAtIndex:index]   : [dirArr lastObject];
    test->file      = ([fileArr count] > index)  ? [fileArr objectAtIndex:index]  : [fileArr lastObject];
    test->extension = ([extArr count] > index)   ? [extArr objectAtIndex:index]   : [extArr lastObject];
    test->qname1    = ([nameArr count] > index)  ? [nameArr objectAtIndex:index]  : [nameArr lastObject];
    test->qvalue1   = ([valueArr count] > index) ? [valueArr objectAtIndex:index] : [valueArr lastObject];
    test->valid     = ([validArr count] > index) ? [validArr objectAtIndex:index] : [validArr lastObject];
    
    test->path = [NSString stringWithFormat:@"/%@/%@.%@", test->dir, test->file, test->extension];
    test->query = [NSString stringWithFormat:@"%@=%@", test->qname1, test->qvalue1];
    
    test->urlString = [NSString stringWithFormat:@"%@://%@%@%@?%@",
                       test->scheme, test->host,
                       ([test->port integerValue])?[NSString stringWithFormat:@":%@", test->port]:@"",
                       test->path,
                       test->query];
    
    return YES;
}

void testNSURLComponents(NSURLComponents* comp, TestSet t)
{
    int i = 0;
    int pas = 0;
    
    PASS_EQUAL([comp string], t.urlString, "")
    PASS_EQUAL([comp URL], t.url, "%02d.%d NSString<->NSURL", i, pas);
    PASS_EQUAL([comp scheme], t.scheme, "%02d Check scheme set", i);
    PASS_EQUAL([comp host], t.host, "%02d Check host", i);
    PASS_EQUAL([comp port], ([t.port isKindOfClass:[NSNumber class]])?t.port:nil, "%02d Check port", i);
    PASS_EQUAL([comp path], [t.path stringByRemovingPercentEncoding], "%02d.%d Checking path", i, pas);
    PASS_EQUAL([comp query], [t.query stringByRemovingPercentEncoding], "%02d.%d Checking query", i, pas);
}

void testNSURLQueryItem()
{
    NSURLQueryItem* item = [[NSURLQueryItem alloc] init];
    PASS_EQUAL(item.name, @"", "NSURLQueryItem.name should not be nil");
    PASS_EQUAL(item.value, nil, "NSURLQueryItem.value should be nil");
      
    item = [[NSURLQueryItem alloc] initWithName:nil value:nil];
    PASS_EQUAL(item.name, @"", "NSURLQueryItem.name should not be nil");
    PASS_EQUAL(item.value, nil, "NSURLQueryItem.value should be nil");
    
}

int main (int argc, const char * argv[])
{

  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
  NSString* s = @"\U00010410\U00010430\U00010411\U00010431\U00010412\U00010432\U00010413\U00010433\U00010414\U00010434";
  NSLog(@"%@", s);
     
  testNSURLQueryItem();
    
  NSMutableArray* d = [NSMutableArray new];
 
  TestSet t;
  //run till getTestSetWithIndex produce new test set for specified index
  for(int i = 0; getTestSetWithIndex(i, &t); i++){
      
      NSLog(@"%@", t.urlString);
      [d addObject:t.urlString];
      
      
      NSURLQueryItem* item = [[NSURLQueryItem alloc] initWithName:t.qname1 value:t.qvalue1];
      PASS_EQUAL(item.name, t.qname1,   "NSURLQueryItem name");
      PASS_EQUAL(item.value, t.qvalue1, "NSURLQueryItem value");
      
      NSURL* url = [NSURL URLWithString:t.urlString];
      NSURLComponents* comp = [NSURLComponents componentsWithString:t.urlString];

      if(t.valid.boolValue){
          PASS(url, "%02d Should initialize NSURL from valid string", i);
          PASS(comp, "%02d Should initialize NSURLComponents from valid string", i);
      }
      else{
          PASS_EQUAL(url, nil, "%02d Should not produce NSURL from invalid string", i);
          PASS_EQUAL(comp, nil, "%02d Should not produce NSURLComponents from invalid string", i);
      }
      
      if(url){
          PASS_EQUAL([url absoluteString], t.urlString, "%02d NSString<->NSURL", i);
          PASS_EQUAL([url scheme], t.scheme, "%02d Check NSURLscheme", i);
          PASS_EQUAL([url host], t.host, "%02d Check NSURL host", i);
          PASS_EQUAL([url port], ([t.port isKindOfClass:[NSNumber class]])?t.port:nil, "%02d Check NSURL port", i);
          PASS_EQUAL([url path], t.path, "%02d Check NSURL path", i);
          PASS_EQUAL([url query], t.query, "%02d Check NSURL query", i);
      }
      
      if(url){
          t.url = url;
          
          NSURLComponents* comp = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
          
          testNSURLComponents(comp, t);
              
          NSURLQueryItem* item2 = [NSURLQueryItem queryItemWithName:[t.qname1 stringByRemovingPercentEncoding] value:[t.qvalue1 stringByRemovingPercentEncoding]];
              [comp setQueryItems:[NSArray arrayWithObject:item2]];
          
          comp = [[NSURLComponents alloc] init];
          [comp setScheme:t.scheme];
          [comp setHost:t.host];
          [comp setPort:([t.port isKindOfClass:[NSNumber class]])?t.port:nil];
          [comp setPath:t.path];
          [comp setQueryItems:[NSArray arrayWithObject:item2]];
          
          testNSURLComponents(comp, t);
      }
  }
    
  NSLog(@"%@", d);
    
  [pool drain];
  return 0;
    
}
