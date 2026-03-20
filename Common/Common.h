#import <rootless.h>

#define jbRootPath(path) ROOT_PATH_NS(path)

static NSString *const kSuiteName = @"com.guacforlife.reynarddefaultprefs";
static NSString *const kEnabledKey = @"enabled";

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end
