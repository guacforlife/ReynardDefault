#if __has_include(<rootless.h>)
#import <rootless.h>
#define jbRootPath(path) ROOT_PATH_NS(path)
#else
#define jbRootPath(path) (path)
#endif

static NSString *const kSuiteName = @"com.guacforlife.reynarddefaultprefs";
static NSString *const kEnabledKey = @"enabled";

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end
