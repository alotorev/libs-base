#import "Testing.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSSet.h>
#if     defined(GNUSTEP_BASE_LIBRARY)
#import <Foundation/NSSerialization.h>
#endif


static NSUInteger fooCount = 0;

int main()
{
  START_SET("NSDictionary Blocks")
# ifndef __has_feature
# define __has_feature(x) 0
# endif
# if __has_feature(blocks)
  NSAutoreleasePool   *arp = [NSAutoreleasePool new];

  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: @"foo",
    @"key1", @"bar", @"key2", @"foo", @"key3", nil];
  [dict enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop){
    if ([obj isEqual: @"foo"]){ fooCount++;}}];
  PASS((2 == fooCount),
       "Can enumerate dictionary using a block");

  NSSet *fooKeys = [dict keysOfEntriesPassingTest: ^(id key, id obj, BOOL *stop){
    return [obj isEqual: @"foo"];}];
  PASS((([fooKeys count] == 2)
    && ([fooKeys containsObject: @"key1"])
    && ([fooKeys containsObject: @"key3"]))
  , "Can use blocks as predicates.");
  [arp release]; arp = nil;
# else
  SKIP("No Blocks support in the compiler.")
# endif
  END_SET("NSDictionary Blocks")
  return 0;
}
