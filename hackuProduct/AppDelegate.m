
#import "AppDelegate.h"
#import "BookShelfCollectionViewController.h"
#import "TimelineViewController.h"
#import "FriendViewController.h"
#import "OtherViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize window;
@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    
    BookShelfCollectionViewController *bookShelfCollectionVC = [[BookShelfCollectionViewController alloc] init];
    TimelineViewController *timelineVC = [[TimelineViewController alloc] init];
    FriendViewController *friendVC = [[FriendViewController alloc] init];
    OtherViewController *otherVC = [[OtherViewController alloc] init];
    
    UIFont *tabFont = [UIFont fontWithName:@"HiraKakuProN-W6" size:13.0f];
    
    NSDictionary *attributesNormal = @{NSFontAttributeName:tabFont, NSForegroundColorAttributeName:[UIColor darkGrayColor]};
    [[UITabBarItem appearance] setTitleTextAttributes:attributesNormal forState:UIControlStateNormal];
    
    NSDictionary *selectedAttributes = @{NSFontAttributeName:tabFont, NSForegroundColorAttributeName:[UIColor whiteColor]};
    [[UITabBarItem appearance] setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
    
    [bookShelfCollectionVC setTitle:@"本棚"];
    [timelineVC setTitle:@"タイムライン"];
    [friendVC setTitle:@"フレンド"];
    [otherVC setTitle:@"その他"];
    
    UINavigationController *firstNavi = [[UINavigationController alloc] initWithRootViewController:bookShelfCollectionVC];
    [viewControllers addObject:firstNavi];
    
    UINavigationController *secondNavi = [[UINavigationController alloc] initWithRootViewController:timelineVC];
    [viewControllers addObject:secondNavi];
    
    UINavigationController *thirdNavi = [[UINavigationController alloc] initWithRootViewController:friendVC];
    [viewControllers addObject:thirdNavi];
    
    UINavigationController *fourthNavi = [[UINavigationController alloc] initWithRootViewController:otherVC];
    [viewControllers addObject:fourthNavi];
    
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:0.22 green:0.80 blue:0.49 alpha:1.0];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:0.22 green:0.80 blue:0.49 alpha:1.0]];
    [UINavigationBar appearance].titleTextAttributes = @{
                                                         NSForegroundColorAttributeName: [UIColor whiteColor],
                                                         NSFontAttributeName: [UIFont fontWithName:@"HiraKakuProN-W6" size:20.0f],
                                                         };
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    
    self.tabBarController = [[UITabBarController alloc] init];
    [self.tabBarController setViewControllers:viewControllers];
    
    self.window.rootViewController = self.tabBarController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)switchTabBarController:(NSInteger)selectedViewIndex
{
    UITabBarController *controller = (UITabBarController *)tabBarController;
    controller.selectedViewController = [controller.viewControllers objectAtIndex:selectedViewIndex];
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
